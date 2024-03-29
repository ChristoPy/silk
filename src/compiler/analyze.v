module compiler

import types { AST, ASTNode, ASTNodeFunctionCallMeta, ASTNodeFunctionMeta, ASTNodeImportStatementMeta, ASTNodeObjectMetaValue, ASTNodeReturnMeta, ASTNodeVariableMeta, ASTNodeVariableMetaValue, Modules, SubNodeAST, Token }

struct Scope {
pub mut:
	id    string
	names []string
}

struct AnalyzerError {
pub mut:
	occurred bool
	token    Token
	kind     string
	id       string
	context  string
}

struct Analyzer {
pub mut:
	scope          []string
	names          []Scope
	global_names   Modules
	exported_names []string
	error          AnalyzerError
}

fn (mut state Analyzer) prevent_name_clash(token Token) {
	if state.error.occurred {
		return
	}

	for mut scope in state.names {
		if scope.id == state.scope.last() {
			if scope.names.contains(token.value) {
				state.error.occurred = true
				state.error.token = token
				state.error.kind = 'Reference'
				state.error.id = 'identifier_already_declared'
				state.error.context = 'name_clash'
				break
			}
		}
	}
}

fn (mut state Analyzer) prevent_undefined_reference(token Token) {
	if state.error.occurred {
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
		state.error.occurred = true
		state.error.token = token
		state.error.kind = 'Reference'
		state.error.id = 'identifier_not_declared'
		state.error.context = 'undefined_reference'
	}
}

fn (mut state Analyzer) add_name_on_scope(name string) {
	if state.error.occurred {
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

fn (mut state Analyzer) verify_name_on_global_scope(token Token) {
	if state.error.occurred {
		return
	}

	name := token.value.substr(1, token.value.len - 1)
	mut found := false
	for _, mut mmodule in state.global_names {
		if mmodule.name == name {
			found = true
			break
		}
	}

	if !found {
		state.error.occurred = true
		state.error.token = token
		state.error.kind = 'Reference'
		state.error.id = 'module_not_found'
		state.error.context = 'undefined_reference'
	}
}

fn (mut state Analyzer) on_function_call(meta ASTNodeFunctionCallMeta) {
	state.prevent_undefined_reference(meta.name)
	for _, node in meta.args {
		state.on_variable_value(node)
	}
}

fn (mut state Analyzer) on_variable_value(meta ASTNodeVariableMetaValue) {
	if state.error.occurred {
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
			state.on_function_call(meta.meta as ASTNodeFunctionCallMeta)
		}
		else {
			panic('not implemented: ${meta}')
		}
	}
}

fn (mut state Analyzer) verify_variable_reference(reference SubNodeAST) {
	if state.error.occurred {
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
	state.verify_name_on_global_scope(meta.path)
}

fn (mut state Analyzer) on_variable_declaration(meta ASTNodeVariableMeta) {
	state.prevent_name_clash(meta.name)
	state.on_variable_value(meta.value)
	state.add_name_on_scope(meta.name.value)
}

fn (mut state Analyzer) on_function_declaration(meta ASTNodeFunctionMeta) {
	state.prevent_name_clash(meta.name)
	state.add_name_on_scope(meta.name.value)

	state.scope << meta.name.value
	state.names << Scope{
		id: meta.name.value
		names: []string{}
	}

	if meta.exported {
		if meta.name.value != 'main' {
			state.error.occurred = true
			state.error.token = meta.name
			state.error.kind = 'Reference'
			state.error.id = 'cannot_export_function'
			state.error.context = 'exported_function_must_be_main'
			return
		}

		state.exported_names << meta.name.value
	}

	for _, node in meta.args {
		state.prevent_name_clash(node)
		state.add_name_on_scope(node.value)
	}

	state.traverse(meta.name.value, meta.body)
	state.scope.pop()
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
			'LetDeclaration' {
				state.on_variable_declaration(node.meta as ASTNodeVariableMeta)
			}
			'FunctionCallStatement' {
				state.on_function_call(node.meta as ASTNodeFunctionCallMeta)
			}
			'ReturnStatement' {
				meta := node.meta as ASTNodeReturnMeta
				state.on_variable_value(meta.value)
			}
			else {
				panic('not implemented: ${node}')
			}
		}
		if state.error.occurred {
			break
		}
	}
}

fn analize(ast AST, modules Modules) Analyzer {
	mut state := Analyzer{
		scope: ['program']
		names: [
			Scope{
				id: 'program'
				names: []string{}
			},
		]
		global_names: modules
	}
	state.traverse(ast.name, ast.body)
	return state
}
