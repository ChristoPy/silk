module compiler

import types { AST, ASTNode, ASTNodeBinaryExpressionMeta, ASTNodeElseMeta, ASTNodeFunctionCallMeta, ASTNodeFunctionMeta, ASTNodeIfMeta, ASTNodeImportStatementMeta, ASTNodeIndexExpressionMeta, ASTNodeMemberExpressionMeta, ASTNodeObjectMetaValue, ASTNodeReturnMeta, ASTNodeVariableMeta, ASTNodeVariableMetaValue, Modules, SubNodeAST, Token }

struct Scope {
pub mut:
	id    string
	names []string
}

// ObjectShape describes known keys (and nested shapes) of an object literal.
// number_fields records which keys hold a number literal (for index validation).
struct ObjectShape {
pub mut:
	fields       map[string]ObjectShape
	number_fields map[string]bool
}

struct AnalyzerError {
pub mut:
	occurred   bool
	token      Token
	kind       string
	id         string
	context    string
	suggestion string // e.g. closest declared name for "did you mean?"
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
	function_arities          map[string]int
	// function name (user + program main) -> number of parameters
	used_import_aliases      map[string]bool
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
		state.error.suggestion = state.suggest_closest_name(token.value)
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

// levenshtein returns edit distance between a and b (number of insert/delete/substitute).
fn levenshtein(a string, b string) int {
	if a.len == 0 {
		return b.len
	}
	if b.len == 0 {
		return a.len
	}
	mut row := []int{len: b.len + 1}
	for i := 0; i <= b.len; i++ {
		row[i] = i
	}
	for i := 1; i <= a.len; i++ {
		mut prev := row[0]
		row[0] = i
		for j := 1; j <= b.len; j++ {
			mut sub_cost := 0
			if a[i - 1] != b[j - 1] {
				sub_cost = 1
			}
			mut curr := prev + sub_cost
			if row[j] + 1 < curr {
				curr = row[j] + 1
			}
			if row[j - 1] + 1 < curr {
				curr = row[j - 1] + 1
			}
			prev = row[j]
			row[j] = curr
		}
	}
	return row[b.len]
}

// suggest_closest_name returns the declared name closest to `bad`, or "" if none close enough.
fn (mut state Analyzer) suggest_closest_name(bad string) string {
	mut candidates := map[string]bool{}
	for scope in state.names {
		for n in scope.names {
			candidates[n] = true
		}
	}
	if bad in candidates {
		return ''
	}
	mut best_name := ''
	mut best_dist := 999
	for name, _ in candidates {
		d := levenshtein(bad, name)
		if d < best_dist {
			best_dist = d
			best_name = name
		}
	}
	// Only suggest if within a small edit distance (typo-like)
	if best_name != '' && best_dist <= 3 {
		return best_name
	}
	return ''
}

// suggest_closest_from_keys returns the key from `keys` closest to `bad`, or "" if none close enough.
fn suggest_closest_from_keys(keys []string, bad string) string {
	if bad in keys {
		return ''
	}
	mut best_key := ''
	mut best_dist := 999
	for key in keys {
		d := levenshtein(bad, key)
		if d < best_dist {
			best_dist = d
			best_key = key
		}
	}
	if best_key != '' && best_dist <= 3 {
		return best_key
	}
	return ''
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
		state.used_import_aliases[meta.name.value] = true
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
						mut keys := []string{}
						for f in mmodule.functions {
							keys << f.name
						}
						state.error.suggestion = suggest_closest_from_keys(keys, prop_tok.value)
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
	// No suggestion: we don't have a shape or module to suggest from
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
				keys := shape.fields.keys()
				state.error.suggestion = suggest_closest_from_keys(keys, property.value)
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
				keys := shape.fields.keys()
				state.error.suggestion = suggest_closest_from_keys(keys, key)
				return
			}
			sub_shape := shape.fields[key]
			state.verify_member_chain(sub_shape, inner.property)
		}
		else {}
	}
}

// is_literal_zero returns true if value is the number literal 0.
fn (mut state Analyzer) is_literal_zero(value ASTNodeVariableMetaValue) bool {
	match value {
		Token {
			return value.kind == 'Number' && value.value == '0'
		}
		else {
			return false
		}
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
		ASTNode {
			if value.name == 'MemberExpression' {
				member_meta := value.meta as ASTNodeMemberExpressionMeta
				if shape := state.get_shape_for(member_meta.name.value) {
					return state.shape_has_number_at(member_meta.property, shape)
				}
			}
			if value.name == 'BinaryExpression' {
				bin_meta := value.meta as ASTNodeBinaryExpressionMeta
				return state.is_number_expression(bin_meta.left) && state.is_number_expression(bin_meta.right)
			}
		}
		else {}
	}
	return false
}

// shape_has_number_at returns true if the property path (single key or nested member) resolves to a number in shape.
fn (mut state Analyzer) shape_has_number_at(property ASTNodeVariableMetaValue, shape ObjectShape) bool {
	match property {
		Token {
			return property.value in shape.number_fields
		}
		ASTNode {
			if property.name == 'MemberExpression' {
				inner := property.meta as ASTNodeMemberExpressionMeta
				key := inner.name.value
				if key !in shape.fields {
					return false
				}
				sub_shape := shape.fields[key]
				return state.shape_has_number_at(inner.property, sub_shape)
			}
		}
		else {}
	}
	return false
}

// array_literal_length returns (length, true) if base is a literal array, otherwise (0, false).
fn array_literal_length(base ASTNodeVariableMetaValue) (int, bool) {
	match base {
		SubNodeAST {
			if base.name == 'Array' {
				return base.body.len, true
			}
		}
		else {}
	}
	return 0, false
}

// literal_index_value returns (index, true) if index is a number literal token, otherwise (0, false).
fn literal_index_value(index ASTNodeVariableMetaValue) (int, bool) {
	match index {
		Token {
			if index.kind == 'Number' {
				val := index.value.int()
				return val, true
			}
		}
		else {}
	}
	return 0, false
}

fn (mut state Analyzer) on_index_expression(meta ASTNodeIndexExpressionMeta) {
	if state.error.occurred {
		return
	}
	state.on_variable_value(meta.base)
	if state.error.occurred {
		return
	}
	state.on_variable_value(meta.index)
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
	// Literal index bounds: when both base and index are literals, require 0 <= index < length
	len, has_len := array_literal_length(meta.base)
	idx, has_idx := literal_index_value(meta.index)
	if has_len && has_idx && (idx < 0 || idx >= len) {
		index_token := state.index_expression_index_token(meta.index)
		state.error.occurred = true
		state.error.token = index_token
		state.error.kind = 'Reference'
		state.error.id = 'index_out_of_bounds'
		state.error.context = 'index_out_of_bounds'
	}
}

fn (mut state Analyzer) index_expression_index_token(value ASTNodeVariableMetaValue) Token {
	match value {
		Token {
			return value
		}
		ASTNode {
			if value.name == 'IndexExpression' {
				inner := value.meta as ASTNodeIndexExpressionMeta
				return state.index_expression_index_token(inner.index)
			}
			if value.name == 'MemberExpression' {
				inner := value.meta as ASTNodeMemberExpressionMeta
				return state.member_expression_rightmost_token(inner.property)
			}
		}
		else {}
	}
	return Token{}
}

fn (mut state Analyzer) member_expression_rightmost_token(property ASTNodeVariableMetaValue) Token {
	match property {
		Token {
			return property
		}
		ASTNode {
			if property.name == 'MemberExpression' {
				inner := property.meta as ASTNodeMemberExpressionMeta
				return state.member_expression_rightmost_token(inner.property)
			}
		}
		else {}
	}
	return Token{}
}

// callable_token returns a token suitable for error reporting (callee name or dot position).
fn (mut state Analyzer) callable_token(callee ASTNodeVariableMetaValue) Token {
	match callee {
		Token {
			return callee
		}
		ASTNode {
			if callee.name == 'MemberExpression' {
				member_meta := callee.meta as ASTNodeMemberExpressionMeta
				return state.member_expression_property_token(member_meta.property)
			}
		}
		else {}
	}
	return Token{}
}

// expected_arity returns (expected_count, true) for a callable, or (0, false) if not a function / unknown.
fn (mut state Analyzer) expected_arity(callee ASTNodeVariableMetaValue) (int, bool) {
	match callee {
		Token {
			name := callee.value
			if name in state.function_arities {
				return state.function_arities[name], true
			}
			return 0, false
		}
		ASTNode {
			if callee.name == 'MemberExpression' {
				member_meta := callee.meta as ASTNodeMemberExpressionMeta
				base_name := member_meta.name.value
				if base_name in state.import_aliases {
					path := state.import_aliases[base_name]
					if path in state.global_names {
						mmodule := state.global_names[path]
						prop_tok := state.member_expression_property_token(member_meta.property)
						for f in mmodule.functions {
							if f.name == prop_tok.value {
								return f.arguments.len, true
							}
						}
					}
				}
			}
		}
		else {}
	}
	return 0, false
}

fn (mut state Analyzer) on_function_call(meta ASTNodeFunctionCallMeta) {
	state.on_variable_value(meta.callee)
	if state.error.occurred {
		return
	}
	for _, node in meta.args {
		state.on_variable_value(node)
		if state.error.occurred {
			return
		}
	}
	expected, is_function := state.expected_arity(meta.callee)
	if is_function && meta.args.len != expected {
		state.error.occurred = true
		state.error.token = state.callable_token(meta.callee)
		state.error.kind = 'Reference'
		state.error.id = 'wrong_argument_count'
		state.error.context = 'wrong_argument_count'
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
			} else if meta.name == 'BinaryExpression' {
				state.error.occurred = true
				state.error.token = (meta.meta as ASTNodeBinaryExpressionMeta).op
				state.error.kind = 'Syntax'
				state.error.id = 'binary_only_in_declaration'
				state.error.context = 'binary_only_in_declaration'
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
		state.used_import_aliases[meta.name.value] = false
	}
}

fn build_object_shape(obj SubNodeAST) ObjectShape {
	mut fields := map[string]ObjectShape{}
	mut number_fields := map[string]bool{}
	for node in obj.body {
		data := node as ASTNodeObjectMetaValue
		key := data.key.value
		match data.value {
			Token {
				if data.value.kind == 'Number' {
					number_fields[key] = true
				}
				fields[key] = ObjectShape{}
			}
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
		number_fields: number_fields
	}
}

fn (mut state Analyzer) on_declaration_value(value ASTNodeVariableMetaValue) {
	if state.error.occurred {
		return
	}
	match value {
		ASTNode {
			if value.name == 'BinaryExpression' {
				// Recursively analyze math expressions in declarations, so nested
				// binary expressions are still treated as declaration math.
				bin_meta := value.meta as ASTNodeBinaryExpressionMeta
				state.on_declaration_value(bin_meta.left)
				if state.error.occurred {
					return
				}
				state.on_declaration_value(bin_meta.right)
				if state.error.occurred {
					return
				}
				if !state.is_number_expression(bin_meta.left) || !state.is_number_expression(bin_meta.right) {
					state.error.occurred = true
					state.error.token = bin_meta.op
					state.error.kind = 'Reference'
					state.error.id = 'binary_operands_must_be_numbers'
					state.error.context = 'binary_operands_must_be_numbers'
				}
				if bin_meta.op.kind == 'Slash' && state.is_literal_zero(bin_meta.right) {
					state.error.occurred = true
					state.error.token = bin_meta.op
					state.error.kind = 'Reference'
					state.error.id = 'division_by_zero'
					state.error.context = 'division_by_zero'
				}
				return
			}
		}
		else {}
	}
	state.on_variable_value(value)
}

fn (mut state Analyzer) on_variable_declaration(meta ASTNodeVariableMeta) {
	state.prevent_name_clash(meta.name)
	state.on_declaration_value(meta.value)
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
	// Record variables that hold a number (literal, reference, or number binary expr) for array index validation
	if state.is_number_expression(meta.value) {
		scope_id := state.scope.last()
		if scope_id !in state.number_vars {
			state.number_vars[scope_id] = map[string]bool{}
		}
		state.number_vars[scope_id][meta.name.value] = true
	}
}

// block_has_any_return returns true if body contains at least one ReturnStatement (including inside if/else).
fn block_has_any_return(body []ASTNode) bool {
	for node in body {
		if node.name == 'ReturnStatement' {
			return true
		}
		if node.name == 'IfStatement' {
			meta := node.meta as ASTNodeIfMeta
			if block_has_any_return(meta.body) {
				return true
			}
		}
		if node.name == 'ElseStatement' {
			meta := node.meta as ASTNodeElseMeta
			if block_has_any_return(meta.body) {
				return true
			}
		}
	}
	return false
}

// block_has_fall_through returns true if some path reaches the end of body without returning.
fn block_has_fall_through(body []ASTNode, start int) bool {
	if start >= body.len {
		return true
	}
	node := body[start]
	if node.name == 'ReturnStatement' {
		return false
	}
	if node.name == 'IfStatement' {
		if_meta := node.meta as ASTNodeIfMeta
		if start + 1 < body.len && body[start + 1].name == 'ElseStatement' {
			else_meta := body[start + 1].meta as ASTNodeElseMeta
			if_ft := block_has_fall_through(if_meta.body, 0)
			else_ft := block_has_fall_through(else_meta.body, 0)
			if !if_ft && !else_ft {
				return block_has_fall_through(body, start + 2)
			}
			return true
		}
		return block_has_fall_through(body, start + 1)
	}
	return block_has_fall_through(body, start + 1)
}

fn (mut state Analyzer) on_function_declaration(meta ASTNodeFunctionMeta) {
	state.prevent_name_clash(meta.name)
	state.add_name_on_scope(meta.name.value)
	state.function_arities[meta.name.value] = meta.args.len

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
	if state.error.occurred {
		state.scope.pop()
		return
	}
	if block_has_any_return(meta.body) && block_has_fall_through(meta.body, 0) {
		state.error.occurred = true
		state.error.token = meta.name
		state.error.kind = 'Reference'
		state.error.id = 'return_path_inconsistent'
		state.error.context = 'return_path_inconsistent'
	}
	state.scope.pop()
}

fn (mut state Analyzer) analyze_block(body []ASTNode) {
	mut last_was_if := false
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
			'IfStatement' {
				state.on_if_statement(node.meta as ASTNodeIfMeta)
				last_was_if = true
			}
			'ElseStatement' {
				if !last_was_if {
					state.error.occurred = true
					state.error.token = (node.meta as ASTNodeElseMeta).keyword.as_token()
					state.error.kind = 'Syntax'
					state.error.id = 'else_without_if'
					state.error.context = 'else_without_if'
					return
				}
				state.on_else_statement(node.meta as ASTNodeElseMeta)
				last_was_if = false
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

fn (mut state Analyzer) on_if_statement(meta ASTNodeIfMeta) {
	state.on_variable_value(meta.condition)
	if state.error.occurred {
		return
	}
	state.analyze_block(meta.body)
}

fn (mut state Analyzer) on_else_statement(meta ASTNodeElseMeta) {
	state.analyze_block(meta.body)
}

fn (mut state Analyzer) traverse(name string, body []ASTNode) {
	state.analyze_block(body)
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
		function_arities: map[string]int{}
		used_import_aliases: map[string]bool{}
	}
	state.traverse(ast.name, ast.body)
	if !state.error.occurred {
		for alias, _ in state.import_aliases {
			if !state.used_import_aliases[alias] {
				// Report first unused import; we need a token - use the one from the AST
				for node in ast.body {
					if node.name == 'ImportStatement' {
						import_meta := node.meta as ASTNodeImportStatementMeta
						if import_meta.name.value == alias {
							state.error.occurred = true
							state.error.token = import_meta.name
							state.error.kind = 'Reference'
							state.error.id = 'unused_import'
							state.error.context = 'unused_import'
							break
						}
					}
				}
				break
			}
		}
	}
	return state
}
