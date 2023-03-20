module compiler

import src.types { AST, ASTNode, ASTNodeFunctionMeta, ASTNodeImportStatementMeta, ASTNodeVariableMeta, ASTNodeVariableMetaValue, Token }

struct Scope {
pub mut:
	id    string
	names []string
}

struct Analyzer {
pub mut:
	scope []string
	names []Scope
	error bool
}

fn (mut state Analyzer) prevent_name_clash(name string) {
	for scope in state.names {
		for n in scope.names {
			if n == name {
				state.error = true
				break
			}
		}
	}
}

fn (mut state Analyzer) prevent_undefined_reference(name string) {
	if state.error {
		return
	}

	mut reference_exists := false

	for scope in state.names {
		for n in scope.names {
			if n == name {
				reference_exists = true
				break
			}
		}
	}

	if !reference_exists {
		state.error = true
	}
}

fn (mut state Analyzer) add_name_on_scope(name string) {
	if state.error {
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

fn (mut state Analyzer) on_variable_reference(value ASTNodeVariableMetaValue) {
	if state.error {
		return
	}

	as_token := value as Token
	if as_token.kind != 'Identifier' {
		return
	}

	state.prevent_undefined_reference(as_token.value)
}

fn (mut state Analyzer) on_import_statement(meta ASTNodeImportStatementMeta) {
	state.prevent_name_clash(meta.name.value)
	state.add_name_on_scope(meta.name.value)
}

fn (mut state Analyzer) on_variable_declaration(meta ASTNodeVariableMeta) {
	state.prevent_name_clash(meta.name.value)
	state.on_variable_reference(meta.value)
	state.add_name_on_scope(meta.name.value)
}

fn (mut state Analyzer) on_function_declaration(meta ASTNodeFunctionMeta) {
	state.prevent_name_clash(meta.name.value)
	state.add_name_on_scope(meta.name.value)
}

fn (mut state Analyzer) traverse(name string, body []ASTNode) {
	for _, node in body {
		if node.name == 'ImportStatement' {
			state.on_import_statement(node.meta as ASTNodeImportStatementMeta)
		}
		if node.name == 'ConstantDeclaration' {
			state.on_variable_declaration(node.meta as ASTNodeVariableMeta)
		}
		if node.name == 'FunctionDeclaration' {
			state.on_function_declaration(node.meta as ASTNodeFunctionMeta)
		}
		if state.error {
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
