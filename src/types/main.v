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

pub type ASTNode = ASTLeafNode | ASTRootNode | VariableDeclarationNode

pub struct AST {
pub mut:
	name  string
	nodes []ASTNode
}

pub struct VariableDeclarationNode {
pub mut:
	kind   string
	name   string
	value  ASTLeafNode
	column int
	line   int
}

pub struct ASTRootNode {
pub mut:
	name  string
	nodes []ASTNode
}

pub struct ASTLeafNode {
pub mut:
	name   string
	value  string
	column int
	line   int
}

pub struct MatchResult {
pub:
	found bool
	value string
}

pub struct Error {
pub:
	message   string
	column    int
	line      int
	wrong_bit string
}
