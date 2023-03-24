module compiler

import src.types { AST, ASTNode, ASTNodeFunctionCallMeta, ASTNodeFunctionMeta, ASTNodeImportStatementMeta, ASTNodeObjectMetaValue, ASTNodeVariableMeta, ASTNodeVariableMetaValue, SubNodeAST, Token }

struct Scope {
pub mut:
	id    string
	names []string
}

struct AnalyzerError {
pub mut:
	occured bool
	token   Token
	context string
}

struct Analyzer {
pub mut:
	scope []string
	names []Scope
	error AnalyzerError
}

fn (mut state Analyzer) prevent_name_clash(token Token) {
	for scope in state.names {
		for n in scope.names {
			if n == token.value {
				state.error.occured = true
				state.error.token = token
				break
			}
		}
	}
}

fn (mut state Analyzer) prevent_undefined_reference(token Token) {
	if state.error.occured {
		return
	}

	mut reference_exists := false
	for scope in state.names {
		for n in scope.names {
			if n == token.value {
				reference_exists = true
				break
			}
		}
	}

	if !reference_exists {
		state.error.occured = true
		state.error.token = token
	}
}

fn (mut state Analyzer) add_name_on_scope(name string) {
	if state.error.occured {
		return
	}

	for mut scope in state.names {
		if scope.id == state.scope.last() {
			if !scope.names.contains(name) {
				scope.names << name
			}
		}
	}
}

fn (mut state Analyzer) on_variable_value(meta ASTNodeVariableMetaValue) {
	if state.error.occured {
		return
	}

	match meta {
		Token {
			if meta.kind == 'Identifier' {
				state.prevent_undefined_reference(meta)
			}
		}
		SubNodeAST {
			state.verify_variable_reference(meta)
		}
		ASTNode {
			nested_meta := meta.meta as ASTNodeFunctionCallMeta
			state.prevent_undefined_reference(nested_meta.name)
			for _, node in nested_meta.args {
				state.on_variable_value(node)
			}
		}
		else {
			panic('not implemented: ${meta}')
		}
	}
}

fn (mut state Analyzer) verify_variable_reference(reference SubNodeAST) {
	if state.error.occured {
		return
	}

	match reference.name {
		'Array' {
			for _, node in reference.body {
				state.on_variable_value(node)
			}
		}
		'Object' {
			for _, node in reference.body {
				data := node as ASTNodeObjectMetaValue
				state.on_variable_value(data.value)
			}
		}
		else {
			panic('not implemented: ${reference}')
		}
	}
}

fn (mut state Analyzer) on_import_statement(meta ASTNodeImportStatementMeta) {
	state.prevent_name_clash(meta.name)
	state.add_name_on_scope(meta.name.value)
}

fn (mut state Analyzer) on_variable_declaration(meta ASTNodeVariableMeta) {
	state.prevent_name_clash(meta.name)
	state.on_variable_value(meta.value)
	state.add_name_on_scope(meta.name.value)
}

fn (mut state Analyzer) on_function_declaration(meta ASTNodeFunctionMeta) {
	state.prevent_name_clash(meta.name)
	state.add_name_on_scope(meta.name.value)
}

fn (mut state Analyzer) traverse(name string, body []ASTNode) {
	for _, node in body {
		match node.name {
			'ImportStatement' {
				state.on_import_statement(node.meta as ASTNodeImportStatementMeta)
			}
			'ConstantDeclaration' {
				state.on_variable_declaration(node.meta as ASTNodeVariableMeta)
			}
			'FunctionDeclaration' {
				state.on_function_declaration(node.meta as ASTNodeFunctionMeta)
			}
			else {
				panic('not implemented: ${node}')
			}
		}
		if state.error.occured {
			break
		}
	}
}

fn analize(ast AST) Analyzer {
	mut state := Analyzer{
		scope: ['program']
		names: [
			Scope{
				id: 'program'
				names: []string{}
			},
		]
	}
	state.traverse(ast.name, ast.body)
	return state
}
