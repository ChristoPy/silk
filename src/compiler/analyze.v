module compiler

import src.types { AST, ASTNodeImportStatementMeta, ASTNodeVariableMeta, ASTNodeFunctionMeta }

struct Scope {
pub mut:
	id string
	names []string
}

struct Analyzer {
pub mut:
	scope []string
	names []Scope
}

fn (mut state Analyzer) prevent_name_clash(name string) {
	for scope in state.names {
		for n in scope.names {
			if n == name {
				println('name clash: $name')
				exit(1)
			}
		}
	}
}

fn (mut state Analyzer) add_name_on_scope(name string) {
	for mut scope in state.names {
		if scope.id == state.scope.last() {
			if !scope.names.contains(name) {
				scope.names << name
			}
		}
	}
}

fn (mut state Analyzer) on_import_statement(meta ASTNodeImportStatementMeta) {
	state.prevent_name_clash(meta.name.value)
	state.add_name_on_scope(meta.name.value)
}

fn (mut state Analyzer) on_variable_declaration(meta ASTNodeVariableMeta) {
	state.prevent_name_clash(meta.name.value)
	state.add_name_on_scope(meta.name.value)
}

fn (mut state Analyzer) on_function_declaration(meta ASTNodeFunctionMeta) {
	state.prevent_name_clash(meta.name.value)
	state.add_name_on_scope(meta.name.value)
}

fn (mut state Analyzer) traverse(name string, body []types.ASTNode) {
	for _, node in body {
		if node.name == 'ImportStatement' {
			state.on_import_statement(node.meta as ASTNodeImportStatementMeta)
		}
		if node.name == 'ConstantDeclaration' {
			state.on_variable_declaration(node.meta as ASTNodeVariableMeta)
		}
		if node.name == "FunctionDeclaration" {
			state.on_function_declaration(node.meta as ASTNodeFunctionMeta)
		}
	}
	println('scope: $state.scope')
}

fn analize(ast AST) {
	mut state := Analyzer{
		scope: ["program"]
		names: [
			Scope{
				id: "program"
				names: []string{}
			}
		]
	}
	state.traverse(ast.name, ast.body)
	println('names: $state.names')
}
