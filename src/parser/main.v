module parser

import util { throw_error }
import types { AST, ASTNode, ASTNodeBinaryExpressionMeta, ASTNodeElseMeta, ASTNodeFunctionCallMeta, ASTNodeFunctionMeta, ASTNodeIfMeta, ASTNodeImportStatementMeta, ASTNodeIndexExpressionMeta, ASTNodeMemberExpressionMeta, ASTNodeObjectMetaValue, ASTNodeReturnMeta, ASTNodeVariableMeta, ASTNodeVariableMetaValue, CompileError, SubNodeAST, SubToken, Token }
import tokenizer

pub struct Parser {
pub mut:
	ast       AST
	tokenizer tokenizer.Tokenizer
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
*   : ConstantDeclaration
*   | LetDeclaration
*   | ReturnStatement
*   | FunctionCallStatement
*   | IfStatement
*   | ElseStatement
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
		'If' {
			return state.if_statement()
		}
		'Else' {
			return state.else_statement()
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
	value := state.declaration_value()

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
	value := state.declaration_value()

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
* IfStatement
*   : If LParen ExpressionValue RParen LBrace NestedBlock RBrace
*   ;
*/
fn (mut state Parser) if_statement() ASTNode {
	keyword := state.eat_sub('If')
	state.eat('LParen')
	condition := state.expression_value()
	state.eat('RParen')
	state.eat('LBrace')
	body := state.nested_block()
	state.eat('RBrace')

	return ASTNode{
		name: 'IfStatement'
		line: keyword.line
		column: keyword.column
		meta: ASTNodeIfMeta{
			keyword: keyword
			condition: condition
			body: body
		}
	}
}

/**
* ElseStatement
*   : Else LBrace NestedBlock RBrace
*   ;
*/
fn (mut state Parser) else_statement() ASTNode {
	keyword := state.eat_sub('Else')
	state.eat('LBrace')
	body := state.nested_block()
	state.eat('RBrace')

	return ASTNode{
		name: 'ElseStatement'
		line: keyword.line
		column: keyword.column
		meta: ASTNodeElseMeta{
			keyword: keyword
			body: body
		}
	}
}

/**
* FunctionCallStatement
*   : Callable LParen RParen
*   | Callable LParen ExpressionValueList RParen
*   ;
* Callable : Identifier ( Dot Identifier )*
*/
fn (mut state Parser) function_call_statement() ASTNode {
	callable := state.parse_callable()
	return state.generic_function_call(callable)
}

fn (mut state Parser) parse_callable() ASTNodeVariableMetaValue {
	base := state.eat('Identifier')
	mut props := []Token{}
	for state.lookahead.kind == 'Dot' {
		state.eat('Dot')
		props << state.eat('Identifier')
	}
	if props.len == 0 {
		return base
	}
	mut prop_expr := ASTNodeVariableMetaValue(props[props.len - 1])
	for i := props.len - 2; i >= 0; i-- {
		prop_expr = ASTNode{
			name: 'MemberExpression'
			line: props[i].line
			column: props[i].column
			meta: ASTNodeMemberExpressionMeta{
				name: props[i]
				property: prop_expr
			}
		}
	}
	return ASTNode{
		name: 'MemberExpression'
		line: base.line
		column: base.column
		meta: ASTNodeMemberExpressionMeta{
			name: base
			property: prop_expr
		}
	}
}

fn (mut state Parser) callable_line_column(callable ASTNodeVariableMetaValue) (int, int) {
	match callable {
		Token {
			return callable.line, callable.column
		}
		ASTNode {
			return callable.line, callable.column
		}
		else {
			return 0, 0
		}
	}
}

/**
* GenericFunctionCall
*   : LParen RParen
*   | LParen ExpressionValueList RParen
*   ;
*/
fn (mut state Parser) generic_function_call(callable ASTNodeVariableMetaValue) ASTNode {
	mut args := []ASTNodeVariableMetaValue{}
	mut ref := &args

	state.list('LParen', 'RParen', fn [mut ref] (param ASTNodeVariableMetaValue) {
		ref << param
	})

	line, column := state.callable_line_column(callable)
	return ASTNode{
		name: 'FunctionCallStatement'
		line: line
		column: column
		meta: ASTNodeFunctionCallMeta{
			callee: callable
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
		'Null' {
			return state.eat('Null')
		}
		'LParen' {
			// Parenthesized value: reuse declaration_value so math inside parentheses
			// follows the same rules as top-level declaration expressions.
			state.eat('LParen')
			value := state.declaration_value()
			state.eat('RParen')
			return value
		}
		'Identifier' {
			value := state.identifier_or_function_call()
			return state.parse_index_suffix(value)
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

/**
* DeclarationValue (variable declarations only)
*   : AdditiveExpression
*
* AdditiveExpression
*   : MultiplicativeExpression ( ( Plus | Minus ) MultiplicativeExpression )*
*
* MultiplicativeExpression
*   : ExpressionValue ( ( Star | Slash ) ExpressionValue )*
*   ;
*/
fn (mut state Parser) declaration_value() ASTNodeVariableMetaValue {
	return state.declaration_additive()
}

fn (mut state Parser) declaration_additive() ASTNodeVariableMetaValue {
	mut left := state.declaration_multiplicative()
	for state.lookahead.kind in ['Plus', 'Minus'] {
		op_tok := state.eat(state.lookahead.kind)
		right := state.declaration_multiplicative()
		line, column := state.value_line_column(left)
		left = ASTNode{
			name: 'BinaryExpression'
			line: line
			column: column
			meta: ASTNodeBinaryExpressionMeta{
				left: left
				op: op_tok
				right: right
			}
		}
	}
	return left
}

fn (mut state Parser) declaration_multiplicative() ASTNodeVariableMetaValue {
	mut left := state.expression_value()
	for state.lookahead.kind in ['Star', 'Slash'] {
		op_tok := state.eat(state.lookahead.kind)
		right := state.expression_value()
		line, column := state.value_line_column(left)
		left = ASTNode{
			name: 'BinaryExpression'
			line: line
			column: column
			meta: ASTNodeBinaryExpressionMeta{
				left: left
				op: op_tok
				right: right
			}
		}
	}
	return left
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
*   | Identifier ( Dot Identifier )*
*   ;
*/
fn (mut state Parser) identifier_or_function_call() ASTNodeVariableMetaValue {
	base := state.eat('Identifier')

	if state.lookahead.kind == 'LParen' {
		return state.generic_function_call(base)
	}

	// Member chain: . prop . prop ...
	mut props := []Token{}
	for state.lookahead.kind == 'Dot' {
		state.eat('Dot')
		props << state.eat('Identifier')
	}

	if props.len == 0 {
		return base
	}

	// Build nested MemberExpression from right to left, then attach to base
	mut prop_expr := ASTNodeVariableMetaValue(props[props.len - 1])
	for i := props.len - 2; i >= 0; i-- {
		prop_expr = ASTNode{
			name: 'MemberExpression'
			line: props[i].line
			column: props[i].column
			meta: ASTNodeMemberExpressionMeta{
				name: props[i]
				property: prop_expr
			}
		}
	}
	return ASTNode{
		name: 'MemberExpression'
		line: base.line
		column: base.column
		meta: ASTNodeMemberExpressionMeta{
			name: base
			property: prop_expr
		}
	}
}

// parse_index_suffix parses optional [ expression_value ] after an indexable value (identifier, member, or index).
fn (mut state Parser) parse_index_suffix(start ASTNodeVariableMetaValue) ASTNodeVariableMetaValue {
	match start {
		ASTNode {
			if start.name == 'FunctionCallStatement' {
				return start
			}
		}
		else {}
	}
	mut current := start
	for state.lookahead.kind == 'LBracket' {
		state.eat('LBracket')
		index := state.expression_value()
		state.eat('RBracket')
		line, column := state.value_line_column(current)
		current = ASTNode{
			name: 'IndexExpression'
			line: line
			column: column
			meta: ASTNodeIndexExpressionMeta{
				base: current
				index: index
			}
		}
	}
	return current
}

fn (mut state Parser) value_line_column(value ASTNodeVariableMetaValue) (int, int) {
	match value {
		Token {
			return value.line, value.column
		}
		ASTNode {
			return value.line, value.column
		}
		else {
			return 0, 0
		}
	}
}

fn (mut state Parser) eat(token_name string) Token {
	token := state.lookahead

	if token.kind != token_name {
		mut err_id := 'unexpected_token'
		mut err_context := 'undefined_token'
		if token_name == 'Identifier' && tokenizer.is_reserved_word_kind(token.kind) {
			err_id = 'reserved_word_as_identifier'
			err_context = 'reserved_word_as_identifier'
		}
		throw_error(CompileError{
			kind: 'Syntax'
			id: err_id
			context: err_context
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
