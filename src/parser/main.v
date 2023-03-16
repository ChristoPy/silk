module parser

import src.util { throw_error }
import src.types { SubToken, AST, ASTNode, ASTNodeFunctionCallMeta, ASTNodeFunctionMeta, ASTNodeImportStatementMeta, ASTNodeObjectMetaValue, ASTNodeVariableMeta, ASTNodeVariableMetaValue, CompileError, SubNodeAST, Token }
import src.tokenizer { Tokenizer }
import json
import term

pub struct Parser {
pub mut:
	ast       AST
	tokenizer Tokenizer
	lookahead Token
}

pub fn (mut state Parser) parse(file string, code string) {
	state.tokenizer.init(file, code)
	state.lookahead = state.tokenizer.get_next_token()
	state.ast.name = 'Program'

	state.program()
	println(json.encode(state.ast))
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
			return state.function_declaration()
		}
		else {
			throw_error(CompileError{
				kind: 'SyntaxError'
				message: 'Unexpected token'
				context: 'Expected ${term.cyan('import')} or ${term.cyan('const')}, got "${token.value}"'
				line: token.line
				line_content: state.tokenizer.code.split('\n')[token.line - 1]
				column: token.column
				wrong_bit: token.value
				file_name: state.tokenizer.file
			})
		}
	}

	// Should never reach here
	return ASTNode{}
}

fn (mut state Parser) nested_statement() ASTNode {
	mut token := state.lookahead

	match token.kind {
		'Const' {
			return state.constant_declaration()
		}
		'Let' {
			return state.let_declaration()
		}
		'Identifier' {
			return state.function_call_statement()
		}
		else {
			throw_error(CompileError{
				kind: 'SyntaxError'
				message: 'Unexpected token'
				context: 'Expected ${term.cyan('const')}, got "${token.value}"'
				line: token.line
				line_content: state.tokenizer.code.split('\n')[token.line - 1]
				column: token.column
				wrong_bit: token.value
				file_name: state.tokenizer.file
			})
		}
	}

	// Should never reach here
	return ASTNode{}
}

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

fn (mut state Parser) function_call_statement() ASTNode {
	name := state.eat('Identifier')

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

fn (mut state Parser) function_declaration() ASTNode {
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
			keyword: keyword
			name: name
			args: args
			body: body
		}
	}
}

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
			return state.eat('Identifier')
		}
		'LBracket' {
			return state.array_literal()
		}
		'LBrace' {
			return state.object_literal()
		}
		else {
			throw_error(CompileError{
				kind: 'SyntaxError'
				message: 'Unexpected value'
				context: 'Expected value of ${term.cyan('Number')}, ${term.cyan('String')}, ${term.cyan('Boolean')}, ${term.cyan('Identifier')}, ${term.cyan('Array')} or ${term.cyan('Object')}, got "${token.value}"'
				line: token.line
				line_content: state.tokenizer.code.split('\n')[token.line - 1]
				column: token.column
				wrong_bit: token.value
				file_name: state.tokenizer.file
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
			kind: 'SyntaxError'
			message: 'Unexpected token'
			context: 'Cannot have a dangling comma'
			line: state.lookahead.line
			line_content: state.tokenizer.code.split('\n')[state.lookahead.line - 1]
			column: state.lookahead.column
			wrong_bit: state.lookahead.value
			file_name: state.tokenizer.file
		})
	}
	state.eat(limiter)
}

fn (mut state Parser) list(left string, limiter string, callback fn (ASTNodeVariableMetaValue)) {
	state.generic_list(left, limiter, fn [callback, mut state] () {
		callback(state.expression_value())
	})
}

fn (mut state Parser) identifier_list(left string, limiter string, callback fn (Token)) {
	state.generic_list(left, limiter, fn [callback, mut state] () {
		callback(state.eat('Identifier'))
	})
}

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

fn (mut state Parser) eat(token_name string) Token {
	token := state.lookahead

	if token.kind != token_name {
		throw_error(CompileError{
			kind: 'SyntaxError'
			message: 'Unexpected Token'
			context: 'Expected ${term.cyan(token_name)} got "${state.lookahead.kind}"'
			line: token.line
			line_content: state.tokenizer.code.split('\n')[token.line - 1]
			column: token.column
			wrong_bit: token.value
			file_name: state.tokenizer.file
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
