module parser

import src.util { throw_error }
import src.types { AST, ASTNode, ASTNodeImportStatementMeta, ASTNodeVariableMeta, ASTNodeVariableMetaValue, CompileError, SubNodeAST, Token }
import src.tokenizer { Tokenizer }
import json

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

	for state.lookahead.name != 'EOF' {
		statements << state.statement()
	}

	state.ast.body << statements
}

fn (mut state Parser) statement() ASTNode {
	mut token := state.lookahead

	match token.name {
		'IMPORT' {
			return state.import_statement()
		}
		'CONST' {
			return state.constant_declaration()
		}
		else {
			throw_error(CompileError{
				kind: 'SyntaxError'
				message: 'Unexpected token'
				context: 'Expected token of type LET, got ${token.name}'
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
	keyword := state.eat('IMPORT')
	name := state.eat('IDENTIFIER')
	from := state.eat('FROM')
	path := state.eat('STRING')

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
	keyword := state.eat('CONST')
	name := state.eat('IDENTIFIER')
	equal := state.eat('EQUALS')
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

fn (mut state Parser) expression_value() ASTNodeVariableMetaValue {
	token := state.lookahead

	match token.name {
		'NUMBER' {
			return state.number_literal()
		}
		'STRING' {
			return state.string_literal()
		}
		'BOOLEAN' {
			return state.boolean_literal()
		}
		'IDENTIFIER' {
			return state.identifier()
		}
		'LBRACKET' {
			return state.array_literal()
		}
		else {
			throw_error(CompileError{
				kind: 'SyntaxError'
				message: 'Unexpected token'
				context: 'Expected token of type NUMBER, STRING, BOOLEAN or IDENTIFIER, got ${token.name}'
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

fn (mut state Parser) array_literal() SubNodeAST {
	mut token := state.eat('LBRACKET')

	mut root := SubNodeAST{
		name: 'ArrayLiteral'
	}

	mut dangling_comma := false
	for state.lookahead.name != 'RBRACKET' {
		root.body << state.expression_value()

		if state.lookahead.name == 'COMMA' {
			state.eat('COMMA')
			dangling_comma = true
		} else {
			dangling_comma = false
		}
	}

	if dangling_comma {
		throw_error(CompileError{
			kind: 'SyntaxError'
			message: 'Unexpected token'
			context: 'Expected dangling comma to be followed by a value'
			line: state.lookahead.line
			line_content: state.tokenizer.code.split('\n')[state.lookahead.line - 1]
			column: state.lookahead.column
			wrong_bit: state.lookahead.value
			file_name: state.tokenizer.file
		})
	}

	token.name = 'ArrayLiteral'
	state.eat('RBRACKET')

	return root
}

fn (mut state Parser) number_literal() Token {
	mut token := state.eat('NUMBER')
	token.name = 'NumberLiteral'
	return token
}

fn (mut state Parser) string_literal() Token {
	mut token := state.eat('STRING')
	token.name = 'StringLiteral'
	return token
}

fn (mut state Parser) boolean_literal() Token {
	mut token := state.eat('BOOLEAN')
	token.name = 'BooleanLiteral'
	return token
}

fn (mut state Parser) identifier() Token {
	mut token := state.eat('IDENTIFIER')
	token.name = 'Identifier'
	return token
}

fn (mut state Parser) eat(token_name string) Token {
	token := state.lookahead

	if token.name != token_name {
		println('Error: Expected ${token_name}, got ${state.lookahead.name}')
		exit(1)
	}

	state.lookahead = state.tokenizer.get_next_token()
	return token
}