module tokenizer

import regex
import src.types { Token, TokenSpec }

// vfmt off
const tokens_spec = [
	TokenSpec{ name: 'SKIP' pattern: regex.regex_opt(r'^\s+') or { panic(err) } },
	TokenSpec{ name: 'SKIP' pattern: regex.regex_opt(r'^//.*') or { panic(err) } },
	TokenSpec{ name: 'NUMBER' pattern: regex.regex_opt(r'^\d+') or { panic(err) } },
	TokenSpec{ name: 'STRING' pattern: regex.regex_opt(r'^"[^"]*"') or { panic(err) } },
	TokenSpec{ name: 'LET' pattern: regex.regex_opt(r'^let') or { panic(err) } },
	TokenSpec{ name: 'FUNCTION' pattern: regex.regex_opt(r'^function') or { panic(err) } },
	TokenSpec{ name: 'BOOLEAN' pattern: regex.regex_opt(r'^true') or { panic(err) } },
	TokenSpec{ name: 'BOOLEAN' pattern: regex.regex_opt(r'^false') or { panic(err) } },
	TokenSpec{ name: 'RETURN' pattern: regex.regex_opt(r'^return') or { panic(err) } },
	TokenSpec{ name: 'IMPORT' pattern: regex.regex_opt(r'^import') or { panic(err) } },
	TokenSpec{ name: 'FROM' pattern: regex.regex_opt(r'^from') or { panic(err) } },
	TokenSpec{ name: 'IF' pattern: regex.regex_opt(r'^if') or { panic(err) } },
	TokenSpec{ name: 'ELSE' pattern: regex.regex_opt(r'^else') or { panic(err) } },
	TokenSpec{ name: 'IDENTIFIER' pattern: regex.regex_opt(r'^[a-zA-Z_][a-zA-Z0-9_]*') or { panic(err) } },
	TokenSpec{ name: 'EQUALS' pattern: regex.regex_opt(r'^=') or { panic(err) } },
	TokenSpec{ name: 'LPAREN' pattern: regex.regex_opt(r'^\(') or { panic(err) } },
	TokenSpec{ name: 'RPAREN' pattern: regex.regex_opt(r'^)') or { panic(err) } },
	TokenSpec{ name: 'LBRACE' pattern: regex.regex_opt(r'^{') or { panic(err) } },
	TokenSpec{ name: 'RBRACE' pattern: regex.regex_opt(r'^}') or { panic(err) } },
	TokenSpec{ name: 'LBRACKET' pattern: regex.regex_opt(r'^\[') or { panic(err) } },
	TokenSpec{ name: 'RBRACKET' pattern: regex.regex_opt(r'^]') or { panic(err) } },
	TokenSpec{ name: 'LBRACE' pattern: regex.regex_opt(r'^{') or { panic(err) } },
	TokenSpec{ name: 'RBRACE' pattern: regex.regex_opt(r'^}') or { panic(err) } },
	TokenSpec{ name: 'COLON' pattern: regex.regex_opt(r'^:') or { panic(err) } },
	TokenSpec{ name: 'COMMA' pattern: regex.regex_opt(r'^,') or { panic(err) } },
	TokenSpec{ name: 'DOT' pattern: regex.regex_opt(r'^\.') or { panic(err) } },
]
// vfmt on

pub struct Tokenizer {
pub mut:
	code   string
	line   int
	cursor int
	eof    bool
}

pub fn (mut state Tokenizer) init(code string) {
	state.code = code
	state.line = 1
	state.cursor = 0
	state.eof = false
}

pub fn (mut state Tokenizer) get_next_token() Token {
	if !state.has_more_tokens() {
		state.eof = true
		return Token{
			name: 'EOF'
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
		}

		state.cursor += matched.len

		token = Token{
			name: spec.name
			column: state.cursor
			line: state.line
			value: matched
		}
		break
	}

	if token.name == 'SKIP' {
		return state.get_next_token()
	}
	if token.name == '' && state.eof == false {
		println('Unexpected token: ${piece[0].ascii_str()}')
		exit(1)
	}

	return token
}

pub fn (mut state Tokenizer) has_more_tokens() bool {
	return state.cursor < state.code.len
}

fn match_token(name string, pattern regex.RE, value string) string {
	start, end := pattern.match_string(value)

	if start == -1 {
		return ''
	}
	return value.substr(start, end)
}
