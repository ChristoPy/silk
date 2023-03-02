module tokenizer

import src.types { MatchResult, Token, TokenMatchResult, TokenSpec, Tokenizer }
import regex

const tokens_spec = [
	TokenSpec{
		name: 'SKIP'
		pattern: regex.regex_opt(r'^\s+') or { panic(err) }
	},
	TokenSpec{
		name: 'SKIP'
		pattern: regex.regex_opt(r'^//.*') or { panic(err) }
	},
	TokenSpec{
		name: 'NUMBER'
		pattern: regex.regex_opt(r'^\d+') or { panic(err) }
	},
	TokenSpec{
		name: 'STRING'
		pattern: regex.regex_opt(r'^"[^"]*"') or { panic(err) }
	},
	TokenSpec{
		name: 'LET'
		pattern: regex.regex_opt(r'^let') or { panic(err) }
	},
	TokenSpec{
		name: 'FUNCTION'
		pattern: regex.regex_opt(r'^function') or { panic(err) }
	},
	TokenSpec{
		name: 'BOOLEAN'
		pattern: regex.regex_opt(r'^true') or { panic(err) }
	},
	TokenSpec{
		name: 'BOOLEAN'
		pattern: regex.regex_opt(r'^false') or { panic(err) }
	},
	TokenSpec{
		name: 'RETURN'
		pattern: regex.regex_opt(r'^return') or { panic(err) }
	},
	TokenSpec{
		name: 'IMPORT'
		pattern: regex.regex_opt(r'^import') or { panic(err) }
	},
	TokenSpec{
		name: 'FROM'
		pattern: regex.regex_opt(r'^from') or { panic(err) }
	},
	TokenSpec{
		name: 'IF'
		pattern: regex.regex_opt(r'^if') or { panic(err) }
	},
	TokenSpec{
		name: 'ELSE'
		pattern: regex.regex_opt(r'^else') or { panic(err) }
	},
	TokenSpec{
		name: 'IDENTIFIER'
		pattern: regex.regex_opt(r'^[a-zA-Z_][a-zA-Z0-9_]*') or { panic(err) }
	},
	TokenSpec{
		name: 'EQUALS'
		pattern: regex.regex_opt(r'^=') or { panic(err) }
	},
	TokenSpec{
		name: 'LPAREN'
		pattern: regex.regex_opt(r'^\(') or { panic(err) }
	},
	TokenSpec{
		name: 'RPAREN'
		pattern: regex.regex_opt(r'^)') or { panic(err) }
	},
	TokenSpec{
		name: 'LBRACE'
		pattern: regex.regex_opt(r'^{') or { panic(err) }
	},
	TokenSpec{
		name: 'RBRACE'
		pattern: regex.regex_opt(r'^}') or { panic(err) }
	},
	TokenSpec{
		name: 'LBRACKET'
		pattern: regex.regex_opt(r'^\[') or { panic(err) }
	},
	TokenSpec{
		name: 'RBRACKET'
		pattern: regex.regex_opt(r'^]') or { panic(err) }
	},
	TokenSpec{
		name: 'LBRACE'
		pattern: regex.regex_opt(r'^{') or { panic(err) }
	},
	TokenSpec{
		name: 'RBRACE'
		pattern: regex.regex_opt(r'^}') or { panic(err) }
	},
	TokenSpec{
		name: 'COLON'
		pattern: regex.regex_opt(r'^:') or { panic(err) }
	},
	TokenSpec{
		name: 'COMMA'
		pattern: regex.regex_opt(r'^,') or { panic(err) }
	},
	TokenSpec{
		name: 'DOT'
		pattern: regex.regex_opt(r'^\.') or { panic(err) }
	},
]

pub fn get_next_token(mut tokenizer Tokenizer) TokenMatchResult {
	if !has_more_tokens(tokenizer) {
		tokenizer.eof = true
		tokenizer.code = ''
		return TokenMatchResult{}
	}

	mut token := Token{}
	piece := tokenizer.code.substr(tokenizer.cursor, tokenizer.code.len)

	for spec in tokens_spec {
		matched := match_token(spec.pattern, piece)
		if matched.found {
			if matched.value.contains('\n') {
				tokenizer.line += matched.value.split('\n').len
			}

			tokenizer.cursor += matched.value.len
			tokenizer.code = piece

			token = Token{
				name: spec.name
				skip: spec.name == 'SKIP'
				column: tokenizer.cursor
				line: tokenizer.line
				value: matched.value
			}
			break
		}
	}

	found := token.name.len > 1
	return TokenMatchResult{
		found: found
		token: token
	}
}

fn has_more_tokens(tokenizer Tokenizer) bool {
	return tokenizer.cursor < tokenizer.code.len
}

fn match_token(pattern regex.RE, value string) MatchResult {
	start, end := pattern.match_string(value)

	if start == -1 {
		return MatchResult{
			found: false
		}
	}
	return MatchResult{
		found: true
		value: value.substr(start, end)
	}
}
