module types

import regex

pub struct Token {
	pub mut:
		name string
		skip bool
		column int
		line int
		value string
}

pub struct TokenSpec {
	pub: name string
	pub mut:
		pattern regex.RE
}

pub struct Tokenizer {
	pub mut:
		code string
		line int
		cursor int
		tokens []Token
		eof bool
}

pub struct MatchResult {
	pub:
		found bool
		value string
}
pub struct TokenMatchResult {
	pub:
		found bool
		token Token
}
