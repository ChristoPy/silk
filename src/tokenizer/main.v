module tokenizer

import regex
import util { throw_error }
import types { CompileError, Token, TokenSpec }

// vfmt off
const tokens_spec = [
	TokenSpec{ name: 'Skip'       pattern: regex.regex_opt(r'^\s+')                    or { panic(err) } },
	TokenSpec{ name: 'Comment'    pattern: regex.regex_opt(r'^//.*')                   or { panic(err) } },
	TokenSpec{ name: 'Number'     pattern: regex.regex_opt(r'^\d+')                    or { panic(err) } },
	TokenSpec{ name: 'String'     pattern: regex.regex_opt(r'^"[^"]*"')                or { panic(err) } },
	TokenSpec{ name: 'Identifier' pattern: regex.regex_opt(r'^[a-zA-Z_][a-zA-Z0-9_]*') or { panic(err) } },
	// Multi-char operators must come before their single-char prefixes
	TokenSpec{ name: 'EqEq'      pattern: regex.regex_opt(r'^==')                     or { panic(err) } },
	TokenSpec{ name: 'Equals'     pattern: regex.regex_opt(r'^=')                      or { panic(err) } },
	TokenSpec{ name: 'NotEq'     pattern: regex.regex_opt(r'^!=')                     or { panic(err) } },
	TokenSpec{ name: 'Bang'      pattern: regex.regex_opt(r'^!')                      or { panic(err) } },
	TokenSpec{ name: 'LtEq'      pattern: regex.regex_opt(r'^<=')                     or { panic(err) } },
	TokenSpec{ name: 'GtEq'      pattern: regex.regex_opt(r'^>=')                     or { panic(err) } },
	TokenSpec{ name: 'Lt'        pattern: regex.regex_opt(r'^<')                      or { panic(err) } },
	TokenSpec{ name: 'Gt'        pattern: regex.regex_opt(r'^>')                      or { panic(err) } },
	TokenSpec{ name: 'And'       pattern: regex.regex_opt(r'^&&')                     or { panic(err) } },
	TokenSpec{ name: 'Or'        pattern: regex.regex_opt(r'^\|\|')                   or { panic(err) } },
	TokenSpec{ name: 'LParen'     pattern: regex.regex_opt(r'^\(')                     or { panic(err) } },
	TokenSpec{ name: 'RParen'     pattern: regex.regex_opt(r'^)')                      or { panic(err) } },
	TokenSpec{ name: 'LBrace'     pattern: regex.regex_opt(r'^{')                      or { panic(err) } },
	TokenSpec{ name: 'RBrace'     pattern: regex.regex_opt(r'^}')                      or { panic(err) } },
	TokenSpec{ name: 'LBracket'   pattern: regex.regex_opt(r'^\[')                     or { panic(err) } },
	TokenSpec{ name: 'RBracket'   pattern: regex.regex_opt(r'^]')                      or { panic(err) } },
	TokenSpec{ name: 'Colon'      pattern: regex.regex_opt(r'^:')                      or { panic(err) } },
	TokenSpec{ name: 'Comma'      pattern: regex.regex_opt(r'^,')                      or { panic(err) } },
	TokenSpec{ name: 'Dot'        pattern: regex.regex_opt(r'^\.')                     or { panic(err) } },
	TokenSpec{ name: 'Plus'       pattern: regex.regex_opt(r'^\+')                     or { panic(err) } },
	TokenSpec{ name: 'Minus'      pattern: regex.regex_opt(r'^-')                      or { panic(err) } },
	TokenSpec{ name: 'Star'       pattern: regex.regex_opt(r'^\*')                     or { panic(err) } },
	TokenSpec{ name: 'Slash'      pattern: regex.regex_opt(r'^/')                       or { panic(err) } },
]
// vfmt on

// reserved_words: lexeme -> token kind. Any word matching the identifier pattern is
// first tokenized as Identifier; if the lexeme is in this map, we reclassify as the
// keyword. So "nullish" stays Identifier, "null" becomes Null. This also allows us to
// prevent the use of reserved keywords as identifiers.
const reserved_words = {
	'const':    'Const'
	'let':      'Let'
	'function': 'Function'
	'return':   'Return'
	'true':     'Boolean'
	'false':    'Boolean'
	'null':     'Null'
	'import':   'Import'
	'from':     'From'
	'export':   'Export'
	'if':       'If'
	'else':     'Else'
	'for':      'For'
	'while':    'While'
}

// is_reserved_word_kind returns true if this token kind is a reserved word (cannot be used as identifier).
pub fn is_reserved_word_kind(kind string) bool {
	for _, v in tokenizer.reserved_words {
		if v == kind {
			return true
		}
	}
	return false
}

pub struct Tokenizer {
pub mut:
	code   string
	line   int
	cursor int
	column int
	eof    bool
	file   string
}

pub fn (mut state Tokenizer) init(file string, code string) {
	state.code = code
	state.line = 1
	state.cursor = 0
	state.column = 1
	state.eof = false
	state.file = file
}

pub fn (mut state Tokenizer) get_next_token() Token {
	if !state.has_more_tokens() {
		state.eof = true
		return Token{
			kind: 'EOF'
			column: state.cursor
			line: state.line
			value: ''
		}
	}

	mut token := Token{}
	piece := state.code.substr(state.cursor, state.code.len)

	for spec in tokenizer.tokens_spec {
		matched := match_token(spec.name, spec.pattern, piece)
		if matched.len == 0 {
			token.column = state.column
			token.line = state.line
			token.value = piece.substr(0, 1)
			continue
		}

		if matched.contains('\n') {
			state.line += matched.split('\n').len - 1
			state.column = 0
		}

		token = Token{
			kind: spec.name
			column: state.column
			line: state.line
			value: matched
		}

		state.cursor += matched.len
		state.column += matched.len
		// Reserved words: reclassify Identifier as keyword when lexeme is in the map
		if token.kind == 'Identifier' && token.value in tokenizer.reserved_words {
			token.kind = tokenizer.reserved_words[token.value]
		}
		break
	}

	if token.kind == 'Skip' || token.kind == 'Comment' {
		return state.get_next_token()
	}
	if token.kind == '' && state.eof == false {
		throw_error(CompileError{
			kind: 'Syntax'
			id: 'unexpected_token'
			context: 'undefined_token'
			file_name: state.file
			wrong_token: token
			line_content: state.code.split('\n')[state.line - 1]
		})
	}

	return token
}

pub fn (mut state Tokenizer) has_more_tokens() bool {
	return state.cursor < state.code.len
}

fn match_token(name string, pattern regex.RE, value string) string {
	mut other_pattern := pattern

	if name == 'Comment' {
		other_pattern.flag = regex.f_nl
	}
	start, end := other_pattern.match_string(value)

	if start == -1 {
		return ''
	}
	return value.substr(start, end)
}
