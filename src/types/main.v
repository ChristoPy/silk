module types

import regex

pub struct Token {
pub mut:
	name   string
	column int
	line   int
	value  string
}

pub struct TokenSpec {
pub:
	name string
pub mut:
	pattern regex.RE
}

pub struct AST {
pub mut:
	name  string
	nodes []Token
}

pub struct ASTNode {
pub mut:
	name   string
	nodes  []Token
	value  string
	column int
	line   int
}

pub struct MatchResult {
pub:
	found bool
	value string
}
