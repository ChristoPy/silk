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
	name string
	body []ASTNode
}

pub struct SubNodeAST {
pub mut:
	name string
	body []ASTNodeVariableMetaValue
}

pub type ASTNodeMeta = ASTNodeImportStatementMeta | ASTNodeVariableMeta
pub type ASTNodeVariableMetaValue = ASTNodeObjectMetaValue | SubNodeAST | Token

pub struct ASTNode {
pub mut:
	name   string
	column int
	line   int
	meta   ASTNodeMeta
}

pub struct ASTNodeVariableMeta {
pub mut:
	keyword Token
	name    Token
	equal   Token
	value   ASTNodeVariableMetaValue
}

pub struct ASTNodeObjectMetaValue {
pub mut:
	key   Token
	value ASTNodeVariableMetaValue
}

pub struct ASTNodeImportStatementMeta {
pub mut:
	keyword Token
	name    Token
	from    Token
	path    Token
}

pub struct MatchResult {
pub:
	found bool
	value string
}

pub struct CompileError {
pub:
	kind         string
	message      string
	column       int
	line         int
	line_content string
	wrong_bit    string
	context      string
	file_name    string
}
