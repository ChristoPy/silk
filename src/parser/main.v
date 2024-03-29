module parser

import util { throw_error }
import types { AST, ASTNode, ASTNodeFunctionCallMeta, ASTNodeFunctionMeta, ASTNodeImportStatementMeta, ASTNodeObjectMetaValue, ASTNodeReturnMeta, ASTNodeVariableMeta, ASTNodeVariableMetaValue, CompileError, SubNodeAST, SubToken, Token }
import tokenizer { Tokenizer }

pub struct Parser {
pub mut:
	ast       AST
	tokenizer Tokenizer
	lookahead Token
}

pub fn (mut state Parser) parse(file string, code string) {
	state.tokenizer.init(file, code)
	state.lookahead = state.tokenizer.get_next_token()
	state.ast.name = file
	state.ast.body = []ASTNode{}

	state.program()
}

fn (mut state Parser) program() {
	mut statements := []ASTNode{}

	for state.lookahead.kind != 'EOF' {
		statements << state.statement()
	}

	state.ast.body << statements
}

fn (mut state Parser) nested_block() []ASTNode {
	mut statements := []ASTNode{}

	for state.lookahead.kind != 'RBrace' {
		statements << state.nested_statement()
	}

	return statements
}

/**
* Statement
*   : ImportStatement
*   | ConstantDeclaration
*   | FunctionDeclaration
*   | ExportStatement
*   ;
*/
fn (mut state Parser) statement() ASTNode {
	mut token := state.lookahead

	match token.kind {
		'Import' {
			return state.import_statement()
		}
		'Const' {
			return state.constant_declaration()
		}
		'Function' {
			return state.function_declaration(false)
		}
		'Export' {
			return state.export_statement()
		}
		else {
			throw_error(CompileError{
				kind: 'Syntax'
				id: 'unexpected_token'
				context: 'statement'
				file_name: state.tokenizer.file
				wrong_token: token
				line_content: state.tokenizer.code.split('\n')[token.line - 1]
			})
		}
	}

	// Should never reach here
	return ASTNode{}
}

/**
* NestedStatement
*   : ConsttandDeclaration
*   | LetDeclaration
*   | ReturnStatement
*   | FunctionCallStatement
*   ;
*/
fn (mut state Parser) nested_statement() ASTNode {
	mut token := state.lookahead

	match token.kind {
		'Const' {
			return state.constant_declaration()
		}
		'Let' {
			return state.let_declaration()
		}
		'Return' {
			return state.return_statement()
		}
		'Identifier' {
			return state.function_call_statement()
		}
		else {
			throw_error(CompileError{
				kind: 'Syntax'
				id: 'unexpected_token'
				context: 'nested_statement'
				file_name: state.tokenizer.file
				wrong_token: token
				line_content: state.tokenizer.code.split('\n')[token.line - 1]
			})
		}
	}

	// Should never reach here
	return ASTNode{}
}

/**
* ImportStatement
*   : Import Identifier From String
*   ;
*/
fn (mut state Parser) import_statement() ASTNode {
	keyword := state.eat_sub('Import')
	name := state.eat('Identifier')
	from := state.eat_sub('From')
	path := state.eat('String')

	return ASTNode{
		name: 'ImportStatement'
		line: keyword.line
		column: keyword.column
		meta: ASTNodeImportStatementMeta{
			keyword: keyword
			name: name
			from: from
			path: path
		}
	}
}

/**
* ConstantDeclaration
*   : Const Identifier Equals ExpressionValue
*   ;
*/
fn (mut state Parser) constant_declaration() ASTNode {
	keyword := state.eat_sub('Const')
	name := state.eat('Identifier')
	equal := state.eat_sub('Equals')
	value := state.expression_value()

	return ASTNode{
		name: 'ConstantDeclaration'
		line: keyword.line
		column: keyword.column
		meta: ASTNodeVariableMeta{
			keyword: keyword
			name: name
			equal: equal
			value: value
		}
	}
}

/**
* LetDeclaration
*   : Let Identifier Equals ExpressionValue
*   ;
*/
fn (mut state Parser) let_declaration() ASTNode {
	keyword := state.eat_sub('Let')
	name := state.eat('Identifier')
	equal := state.eat_sub('Equals')
	value := state.expression_value()

	return ASTNode{
		name: 'LetDeclaration'
		line: keyword.line
		column: keyword.column
		meta: ASTNodeVariableMeta{
			keyword: keyword
			name: name
			equal: equal
			value: value
		}
	}
}

/**
* ReturnStatement
*   : Return ExpressionValue
*   ;
*/
fn (mut state Parser) return_statement() ASTNode {
	keyword := state.eat_sub('Return')
	value := state.expression_value()

	return ASTNode{
		name: 'ReturnStatement'
		line: keyword.line
		column: keyword.column
		meta: ASTNodeReturnMeta{
			keyword: keyword
			value: value
		}
	}
}

/**
* FunctionCallStatement
*   : Identifier GenericFunctionCall
*   ;
*/
fn (mut state Parser) function_call_statement() ASTNode {
	name := state.eat('Identifier')
	return state.generic_function_call(name)
}

/**
* GenericFunctionCall
*   : LParen RParen
*   | LParen ExpressionValueList RParen
*   ;
*/
fn (mut state Parser) generic_function_call(name Token) ASTNode {
	mut args := []Token{}
	mut ref := &args

	state.list('LParen', 'RParen', fn [mut ref] (param ASTNodeVariableMetaValue) {
		ref << param as Token
	})

	return ASTNode{
		name: 'FunctionCallStatement'
		line: name.line
		column: name.column
		meta: ASTNodeFunctionCallMeta{
			name: name
			args: args
		}
	}
}

/*
* FunctionDeclaration
*   : Function Identifier LParen RParen Block
*   | Function Identifier LParen IdentifierList RParen Block
*   ;
*/
fn (mut state Parser) function_declaration(exported bool) ASTNode {
	keyword := state.eat_sub('Function')
	name := state.eat('Identifier')

	mut args := []Token{}
	mut ref := &args

	state.identifier_list('LParen', 'RParen', fn [mut ref] (param Token) {
		ref << param
	})

	state.eat('LBrace')
	body := state.nested_block()
	state.eat('RBrace')

	return ASTNode{
		name: 'FunctionDeclaration'
		line: keyword.line
		column: keyword.column
		meta: ASTNodeFunctionMeta{
			exported: exported
			keyword: keyword
			name: name
			args: args
			body: body
		}
	}
}

fn (mut state Parser) export_statement() ASTNode {
	state.eat_sub('Export')
	return state.function_declaration(true)
}

/**
* ExpressionValue
*   : Number
*   | String
*   | Boolean
*   | IdentifierOrFunctionCall
*   | ArrayLiteral
*   | ObjectLiteral
*   ;
*/
fn (mut state Parser) expression_value() ASTNodeVariableMetaValue {
	token := state.lookahead

	match token.kind {
		'Number' {
			return state.eat('Number')
		}
		'String' {
			return state.eat('String')
		}
		'Boolean' {
			return state.eat('Boolean')
		}
		'Identifier' {
			return state.identifier_or_function_call()
		}
		'LBracket' {
			return state.array_literal()
		}
		'LBrace' {
			return state.object_literal()
		}
		else {
			throw_error(CompileError{
				kind: 'Syntax'
				id: 'unexpected_token'
				context: 'expression_value'
				file_name: state.tokenizer.file
				wrong_token: token
				line_content: state.tokenizer.code.split('\n')[token.line - 1]
			})
		}
	}

	// Should never reach here
	return token
}

fn (mut state Parser) generic_list(left string, limiter string, callback fn ()) {
	state.eat(left)
	mut dangling_comma := false
	for state.lookahead.kind != limiter {
		callback()

		if state.lookahead.kind != limiter {
			state.eat('Comma')
			dangling_comma = true
		} else {
			dangling_comma = false
		}
	}

	if dangling_comma {
		throw_error(CompileError{
			kind: 'Syntax'
			id: 'unexpected_token'
			context: 'dangling_comma'
			file_name: state.tokenizer.file
			wrong_token: state.lookahead
			line_content: state.tokenizer.code.split('\n')[state.lookahead.line - 1]
		})
	}
	state.eat(limiter)
}

/**
* ExpressionValueList
*   : ExpressionValue
*   | ExpressionValue Comma ExpressionValueList
*   ;
*/
fn (mut state Parser) list(left string, limiter string, callback fn (ASTNodeVariableMetaValue)) {
	state.generic_list(left, limiter, fn [callback, mut state] () {
		callback(state.expression_value())
	})
}

/**
* IdentifierList
*   : Identifier
*   | Identifier Comma IdentifierList
*   ;
*/
fn (mut state Parser) identifier_list(left string, limiter string, callback fn (Token)) {
	state.generic_list(left, limiter, fn [callback, mut state] () {
		callback(state.eat('Identifier'))
	})
}

/**
* ObjectLiteral
*   : LBrace RBrace
*   | LBrace Identifier Colon ExpressionValue RBrace
*   | LBrace Identifier Colon ExpressionValue Comma ObjectLiteral
*   ;
*/
fn (mut state Parser) object_literal() SubNodeAST {
	mut root := SubNodeAST{
		name: 'Object'
	}

	mut ref := &root
	state.list('LBrace', 'RBrace', fn [mut ref, mut state] (key ASTNodeVariableMetaValue) {
		state.eat('Colon')
		value := state.expression_value()

		ref.body << ASTNodeObjectMetaValue{
			key: key as Token
			value: value
		}
	})

	return root
}

/**
* ArrayLiteral
*   : LBracket RBracket
*   | LBracket ExpressionValue RBracket
*   | LBracket ExpressionValue Comma ArrayLiteral
*   ;
*/
fn (mut state Parser) array_literal() SubNodeAST {
	mut root := SubNodeAST{
		name: 'Array'
	}

	mut ref := &root
	state.list('LBracket', 'RBracket', fn [mut ref] (value ASTNodeVariableMetaValue) {
		ref.body << value
	})

	return root
}

/**
* IdentifierOrFunctionCall
*   : Identifier
*   | Identifier GenericFunctionCall
*   | Identifier DOT
*   ;
*/
fn (mut state Parser) identifier_or_function_call() ASTNodeVariableMetaValue {
	name := state.eat('Identifier')
	no_follow := ['LParen']

	if state.lookahead.kind in no_follow {
		if state.lookahead.kind == 'LParen' {
			return state.generic_function_call(name)
		}
	}

	return name
}

fn (mut state Parser) eat(token_name string) Token {
	token := state.lookahead

	if token.kind != token_name {
		throw_error(CompileError{
			kind: 'Syntax'
			id: 'unexpected_token'
			context: 'undefined_token'
			file_name: state.tokenizer.file
			wrong_token: token
			line_content: state.tokenizer.code.split('\n')[token.line - 1]
		})
		exit(1)
	}

	state.lookahead = state.tokenizer.get_next_token()
	return token
}

fn (mut state Parser) eat_sub(token_name string) SubToken {
	token := state.eat(token_name)

	return SubToken{
		line: token.line
		column: token.column
	}
}
