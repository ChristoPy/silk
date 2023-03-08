module parser

import src.types { AST, Token, ASTRootNode, ASTLeafNode, VariableDeclarationNode, ASTNode }
import src.tokenizer { Tokenizer }

pub struct Parser {
pub mut:
	ast ASTRootNode
	tokenizer Tokenizer
	lookahead Token
}

pub fn (mut state Parser) parse(code string) {
	state.tokenizer.init(code)
	state.lookahead = state.tokenizer.get_next_token()
	state.ast.name = 'Program'

	state.program()
	println(state.ast)
}

fn (mut state Parser) program() {
	mut statements := []ASTNode{}

	for state.lookahead.name != 'EOF' {
		statements << state.statement()
	}

	state.ast.nodes << statements
}

fn (mut state Parser) statement() ASTNode {
	token := state.lookahead

	match token.name {
		"LET" { return state.variable_declaration()}
		else { panic(token.name) }
	}
}

fn (mut state Parser) variable_declaration() VariableDeclarationNode {
	keyword := state.eat('LET')
	identifier := state.eat('IDENTIFIER')
	state.eat('EQUALS')
	value := state.expression_value()

	return VariableDeclarationNode {
		kind: 'VariableDeclaration',
		name: identifier.value,
		value: value,
		line: keyword.line,
		column: keyword.column,
	}
}

fn (mut state Parser) expression_value() ASTLeafNode {
	token := state.lookahead

	match token.name {
		"NUMBER" { return state.number_literal() }
		"STRING" { return state.string_literal() }
		"BOOLEAN" { return state.boolean_literal() }
		else { println('Error: Unexpected token ${token.value[0].ascii_str()}') exit(1) }
	}
}

fn (mut state Parser) number_literal() ASTLeafNode {
	token := state.eat('NUMBER')

	return ASTLeafNode {
		name: 'NumberLiteral',
		value: token.value,
		line: token.line,
		column: token.column,
	}
}

fn (mut state Parser) string_literal() ASTLeafNode {
	token := state.eat('STRING')

	return ASTLeafNode {
		name: 'StringLiteral',
		value: token.value,
		line: token.line,
		column: token.column,
	}
}

fn (mut state Parser) boolean_literal() ASTLeafNode {
	token := state.eat('BOOLEAN')

	return ASTLeafNode {
		name: 'BooleanLiteral',
		value: token.value,
		line: token.line,
		column: token.column,
	}
}

fn (mut state Parser) eat(token_name string) Token {
	token := state.lookahead

	if token.name != token_name {
		println('Error: Expected $token_name, got ${state.lookahead.name}')
		exit(1)
	}

	state.lookahead = state.tokenizer.get_next_token()
	return token
}