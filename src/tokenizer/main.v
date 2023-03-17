module tokenizer

import regex
import src.util { throw_error }
import src.types { CompileError, Token, TokenSpec }

// vfmt off
const tokens_spec = [
	TokenSpec{ name: 'Skip'       pattern: regex.regex_opt(r'^\s+')                    or { panic(err) } },
	TokenSpec{ name: 'Comment'    pattern: regex.regex_opt(r'^//.*')                   or { panic(err) } },
	TokenSpec{ name: 'Number'     pattern: regex.regex_opt(r'^\d+')                    or { panic(err) } },
	TokenSpec{ name: 'String'     pattern: regex.regex_opt(r'^"[^"]*"')                or { panic(err) } },
	TokenSpec{ name: 'Const'      pattern: regex.regex_opt(r'^const')                  or { panic(err) } },
	TokenSpec{ name: 'Let'        pattern: regex.regex_opt(r'^let')                    or { panic(err) } },
	TokenSpec{ name: 'Function'   pattern: regex.regex_opt(r'^function')               or { panic(err) } },
	TokenSpec{ name: 'Return'     pattern: regex.regex_opt(r'^return')                 or { panic(err) } },
	TokenSpec{ name: 'Boolean'    pattern: regex.regex_opt(r'^true')                   or { panic(err) } },
	TokenSpec{ name: 'Boolean'    pattern: regex.regex_opt(r'^false')                  or { panic(err) } },
	TokenSpec{ name: 'Import'     pattern: regex.regex_opt(r'^import')                 or { panic(err) } },
	TokenSpec{ name: 'From'       pattern: regex.regex_opt(r'^from')                   or { panic(err) } },
	TokenSpec{ name: 'Match'      pattern: regex.regex_opt(r'^match')                  or { panic(err) } },
	TokenSpec{ name: 'Identifier' pattern: regex.regex_opt(r'^[a-zA-Z_][a-zA-Z0-9_]*') or { panic(err) } },
	TokenSpec{ name: 'Equals'     pattern: regex.regex_opt(r'^=')                      or { panic(err) } },
	TokenSpec{ name: 'LParen'     pattern: regex.regex_opt(r'^\(')                     or { panic(err) } },
	TokenSpec{ name: 'RParen'     pattern: regex.regex_opt(r'^)')                      or { panic(err) } },
	TokenSpec{ name: 'LBrace'     pattern: regex.regex_opt(r'^{')                      or { panic(err) } },
	TokenSpec{ name: 'RBrace'     pattern: regex.regex_opt(r'^}')                      or { panic(err) } },
	TokenSpec{ name: 'LBracket'   pattern: regex.regex_opt(r'^\[')                     or { panic(err) } },
	TokenSpec{ name: 'RBracket'   pattern: regex.regex_opt(r'^]')                      or { panic(err) } },
	TokenSpec{ name: 'Colon'      pattern: regex.regex_opt(r'^:')                      or { panic(err) } },
	TokenSpec{ name: 'Comma'      pattern: regex.regex_opt(r'^,')                      or { panic(err) } },
	TokenSpec{ name: 'Dot'        pattern: regex.regex_opt(r'^\.')                     or { panic(err) } },
]
// vfmt on

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
		break
	}

	if token.kind == 'Skip' || token.kind == 'Comment' {
		return state.get_next_token()
	}
	if token.kind == '' && state.eof == false {
		throw_error(CompileError{
			kind: 'Syntax'
			message: 'Unexpected token.'
			line: state.line
			line_content: state.code.split('\n')[state.line - 1]
			column: state.column
			wrong_bit: piece[0].ascii_str()
			context: 'I was not expecting this.'
			file_name: state.file
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
