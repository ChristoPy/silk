module compiler

import types { AST, ASTNode, ASTNodeFunctionCallMeta, ASTNodeFunctionMeta, ASTNodeImportStatementMeta, ASTNodeIndexExpressionMeta, ASTNodeMemberExpressionMeta, ASTNodeObjectMetaValue, ASTNodeReturnMeta, ASTNodeVariableMeta, ASTNodeVariableMetaValue, Modules, SubNodeAST, Token }

struct Scope {
pub mut:
	id    string
	names []string
}

// ObjectShape describes known keys (and nested shapes) of an object literal
struct ObjectShape {
pub mut:
	fields map[string]ObjectShape
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
	scope                     []string
	names                     []Scope
	global_names              Modules
	exported_names            []string
	error                     AnalyzerError
	top_level_seen_non_import bool
	object_shapes             map[string]map[string]ObjectShape
	import_aliases            map[string]string
	number_vars               map[string]map[string]bool
	// scope id -> var name -> true (variables known to hold a number literal)
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

// get_shape_for returns the shape for base_name from the innermost scope that
// declares it. If that scope has no shape (e.g. parameter), returns none and
// does not fall back to an outer scope (proper shadowing).
fn (mut state Analyzer) get_shape_for(base_name string) ?ObjectShape {
	for i := state.names.len - 1; i >= 0; i-- {
		scope := state.names[i]
		if !scope.names.contains(base_name) {
			continue
		}
		// Innermost scope that declares base_name
		if scope.id in state.object_shapes && base_name in state.object_shapes[scope.id] {
			return state.object_shapes[scope.id][base_name]
		}
		return none
	}
	return none
}

fn (mut state Analyzer) on_member_expression(meta ASTNodeMemberExpressionMeta) {
	if state.error.occurred {
		return
	}
	state.prevent_undefined_reference(meta.name)
	if state.error.occurred {
		return
	}
	if shape := state.get_shape_for(meta.name.value) {
		state.verify_member_chain(shape, meta.property)
		return
	}
	// No object shape - check if base is an imported module (single-level .function only)
	if meta.name.value in state.import_aliases {
		path := state.import_aliases[meta.name.value]
		if path in state.global_names {
			mmodule := state.global_names[path]
			// Only allow Identifier.property (one level)
			match meta.property {
				Token {
					prop_tok := meta.property as Token
					mut found := false
					for f in mmodule.functions {
						if f.name == prop_tok.value {
							found = true
							break
						}
					}
					if !found {
						state.error.occurred = true
						state.error.token = prop_tok
						state.error.kind = 'Reference'
						state.error.id = 'nested_property_not_declared'
						state.error.context = 'undefined_nested_reference'
					}
				}
				else {
					// e.g. IO.foo.bar not allowed on modules
					prop_token := state.member_expression_property_token(meta.property)
					state.error.occurred = true
					state.error.token = prop_token
					state.error.kind = 'Reference'
					state.error.id = 'nested_property_not_declared'
					state.error.context = 'undefined_nested_reference'
				}
			}
		}
		return
	}
	// No known shape and not an import - reject (no dynamic property access)
	prop_token := state.member_expression_property_token(meta.property)
	state.error.occurred = true
	state.error.token = prop_token
	state.error.kind = 'Reference'
	state.error.id = 'nested_property_not_declared'
	state.error.context = 'undefined_nested_reference'
}

fn (mut state Analyzer) member_expression_property_token(property ASTNodeVariableMetaValue) Token {
	match property {
		Token {
			return property
		}
		ASTNode {
			inner := property.meta as ASTNodeMemberExpressionMeta
			// First key in chain is inner.name
			return inner.name
		}
		else {
			return Token{}
		}
	}
}

fn (mut state Analyzer) verify_member_chain(shape ObjectShape, property ASTNodeVariableMetaValue) {
	if state.error.occurred {
		return
	}
	match property {
		Token {
			if property.value !in shape.fields {
				state.error.occurred = true
				state.error.token = property
				state.error.kind = 'Reference'
				state.error.id = 'nested_property_not_declared'
				state.error.context = 'undefined_nested_reference'
			}
		}
		ASTNode {
			inner := property.meta as ASTNodeMemberExpressionMeta
			key := inner.name.value
			if key !in shape.fields {
				state.error.occurred = true
				state.error.token = inner.name
				state.error.kind = 'Reference'
				state.error.id = 'nested_property_not_declared'
				state.error.context = 'undefined_nested_reference'
				return
			}
			sub_shape := shape.fields[key]
			state.verify_member_chain(sub_shape, inner.property)
		}
		else {}
	}
}

fn (mut state Analyzer) is_number_expression(value ASTNodeVariableMetaValue) bool {
	match value {
		Token {
			if value.kind == 'Number' {
				return true
			}
			if value.kind == 'Identifier' {
				for i := state.names.len - 1; i >= 0; i-- {
					scope := state.names[i]
					if scope.names.contains(value.value) {
						scope_id := scope.id
						return scope_id in state.number_vars && value.value in state.number_vars[scope_id]
					}
				}
			}
		}
		else {}
	}
	return false
}

fn (mut state Analyzer) on_index_expression(meta ASTNodeIndexExpressionMeta) {
	if state.error.occurred {
		return
	}
	state.on_variable_value(meta.base)
	if state.error.occurred {
		return
	}
	if !state.is_number_expression(meta.index) {
		index_token := state.index_expression_index_token(meta.index)
		state.error.occurred = true
		state.error.token = index_token
		state.error.kind = 'Reference'
		state.error.id = 'index_must_be_number'
		state.error.context = 'index_must_be_number_literal_or_reference'
		return
	}
}

fn (mut state Analyzer) index_expression_index_token(value ASTNodeVariableMetaValue) Token {
	match value {
		Token {
			return value
		}
		ASTNode {
			// Nested index like arr[i][j] - use the inner index for error location
			if value.name == 'IndexExpression' {
				inner := value.meta as ASTNodeIndexExpressionMeta
				return state.index_expression_index_token(inner.index)
			}
		}
		else {}
	}
	return Token{}
}

fn (mut state Analyzer) on_function_call(meta ASTNodeFunctionCallMeta) {
	state.on_variable_value(meta.callee)
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
			if meta.name == 'FunctionCallStatement' {
				state.on_function_call(meta.meta as ASTNodeFunctionCallMeta)
			} else if meta.name == 'MemberExpression' {
				state.on_member_expression(meta.meta as ASTNodeMemberExpressionMeta)
			} else if meta.name == 'IndexExpression' {
				state.on_index_expression(meta.meta as ASTNodeIndexExpressionMeta)
			} else {
				panic('not implemented: ${meta}')
			}
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
	if state.scope.len == 1 && state.top_level_seen_non_import {
		state.error.occurred = true
		state.error.token = meta.name
		state.error.kind = 'Syntax'
		state.error.id = 'import_not_at_top_level'
		state.error.context = 'import_after_statement'
		return
	}
	state.prevent_name_clash(meta.name)
	state.add_name_on_scope(meta.name.value)
	state.verify_name_on_global_scope(meta.path)
	if !state.error.occurred {
		path := meta.path.value.substr(1, meta.path.value.len - 1)
		state.import_aliases[meta.name.value] = path
	}
}

fn build_object_shape(obj SubNodeAST) ObjectShape {
	mut fields := map[string]ObjectShape{}
	for node in obj.body {
		data := node as ASTNodeObjectMetaValue
		key := data.key.value
		match data.value {
			SubNodeAST {
				if data.value.name == 'Object' {
					fields[key] = build_object_shape(data.value)
				} else {
					fields[key] = ObjectShape{}
				}
			}
			else {
				fields[key] = ObjectShape{}
			}
		}
	}
	return ObjectShape{
		fields: fields
	}
}

fn (mut state Analyzer) on_variable_declaration(meta ASTNodeVariableMeta) {
	state.prevent_name_clash(meta.name)
	state.on_variable_value(meta.value)
	state.add_name_on_scope(meta.name.value)

	// Record object shape when value is an object literal
	match meta.value {
		SubNodeAST {
			if meta.value.name == 'Object' {
				shape := build_object_shape(meta.value)
				scope_id := state.scope.last()
				if scope_id !in state.object_shapes {
					state.object_shapes[scope_id] = map[string]ObjectShape{}
				}
				state.object_shapes[scope_id][meta.name.value] = shape
			}
		}
		else {}
	}
	// Record variables that hold a number literal (for array index validation)
	match meta.value {
		Token {
			if meta.value.kind == 'Number' {
				scope_id := state.scope.last()
				if scope_id !in state.number_vars {
					state.number_vars[scope_id] = map[string]bool{}
				}
				state.number_vars[scope_id][meta.name.value] = true
			}
		}
		else {}
	}
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
				if state.scope.len == 1 {
					state.top_level_seen_non_import = true
				}
				state.on_variable_declaration(node.meta as ASTNodeVariableMeta)
			}
			'FunctionDeclaration' {
				if state.scope.len == 1 {
					state.top_level_seen_non_import = true
				}
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
		object_shapes: map[string]map[string]ObjectShape{}
		import_aliases: map[string]string{}
		number_vars: map[string]map[string]bool{}
	}
	state.traverse(ast.name, ast.body)
	return state
}
