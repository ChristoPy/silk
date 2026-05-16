module types

import regex

pub struct SubToken {
pub mut:
	column int
	line   int
}

pub fn (s SubToken) as_token() Token {
	return Token{
		kind: ''
		column: s.column
		line: s.line
		value: ''
	}
}

pub struct Token {
pub mut:
	kind   string
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

pub type ASTNodeMeta = ASTNodeBinaryExpressionMeta
	| ASTNodeIfMeta
	| ASTNodeElseMeta
	| ASTNodeFunctionCallMeta
	| ASTNodeFunctionMeta
	| ASTNodeImportStatementMeta
	| ASTNodeIndexExpressionMeta
	| ASTNodeMemberExpressionMeta
	| ASTNodeReturnMeta
	| ASTNodeVariableMeta
	| ASTNodeAssignmentMeta
	| ASTNodeUnaryExpressionMeta
pub type ASTNodeVariableMetaValue = ASTNode | ASTNodeObjectMetaValue | SubNodeAST | Token

pub struct ASTNode {
pub mut:
	name   string
	column int
	line   int
	meta   ASTNodeMeta
}

pub struct ASTNodeFunctionCallMeta {
pub mut:
	callee ASTNodeVariableMetaValue
	args   []ASTNodeVariableMetaValue
}

pub struct ASTNodeFunctionMeta {
pub mut:
	keyword  SubToken
	name     Token
	args     []Token
	body     []ASTNode
	exported bool
}

pub struct ASTNodeExportMeta {
pub mut:
	value SubToken
}

pub struct ASTNodeVariableMeta {
pub mut:
	keyword SubToken
	name    Token
	equal   SubToken
	value   ASTNodeVariableMetaValue
}

pub struct ASTNodeReturnMeta {
pub mut:
	keyword SubToken
	value   ASTNodeVariableMetaValue
}

pub struct ASTNodeObjectMetaValue {
pub mut:
	key   Token
	value ASTNodeVariableMetaValue
}

pub struct ASTNodeImportStatementMeta {
pub mut:
	keyword SubToken
	name    Token
	from    SubToken
	path    Token
}

pub struct ASTNodeMemberExpressionMeta {
pub mut:
	name     Token
	property ASTNodeVariableMetaValue
}

pub struct ASTNodeIndexExpressionMeta {
pub mut:
	base  ASTNodeVariableMetaValue
	index ASTNodeVariableMetaValue
}

pub struct ASTNodeBinaryExpressionMeta {
pub mut:
	left  ASTNodeVariableMetaValue
	op    Token // Plus, Minus, Star, Slash, EqEq, NotEq, Lt, Gt, LtEq, GtEq, And, Or
	right ASTNodeVariableMetaValue
}

pub struct ASTNodeUnaryExpressionMeta {
pub mut:
	op    Token // Bang
	right ASTNodeVariableMetaValue
}

pub struct ASTNodeAssignmentMeta {
pub mut:
	name  Token
	equal SubToken
	value ASTNodeVariableMetaValue
}

pub struct ASTNodeIfMeta {
pub mut:
	keyword   SubToken
	condition ASTNodeVariableMetaValue
	body      []ASTNode
}

pub struct ASTNodeElseMeta {
pub mut:
	keyword SubToken
	body    []ASTNode
}

pub struct MatchResult {
pub:
	found bool
	value string
}

pub struct CompileError {
pub mut:
	kind         string
	id           string
	context      string
	file_name    string
	wrong_token  Token
	line_content string
	suggestion   string // e.g. "Did you mean: score?" when identifier not declared
}
