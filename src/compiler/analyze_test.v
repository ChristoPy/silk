module compiler

import parser { Parser }

const modules = {
	'std': standard_module
}

const modules_with_std_io = {
	'std/io': standard_module
}

fn test_no_name_clashes() {
	mut state := Parser{}
	state.parse('testfile', 'import name from "value" import name from "value"')
	mut result := analize(state.ast, compiler.modules)
	assert result.error.occurred == true

	state = Parser{}
	state.parse('testfile', 'function test(){} function test(){}')
	result = analize(state.ast, compiler.modules)
	assert result.error.occurred == true

	state = Parser{}
	state.parse('testfile', 'function test(){ let a = 0 let a = 0 }')
	result = analize(state.ast, compiler.modules)
	assert result.error.occurred == true

	state = Parser{}
	state.parse('testfile', 'const a = 0 function test(){ let a = 0 }')
	result = analize(state.ast, compiler.modules)
	assert result.error.occurred == false

	state = Parser{}
	state.parse('testfile', 'function test(a){ let a = 0 }')
	result = analize(state.ast, compiler.modules)
	assert result.error.occurred == true

	state = Parser{}
	state.parse('testfile', 'function test(a, a){}')
	result = analize(state.ast, compiler.modules)
	assert result.error.occurred == true
}

fn test_did_you_mean_suggestion() {
	// Typo "scor" -> suggest "score"
	mut state := Parser{}
	state.parse('testfile', 'const score = 98
function sumScore(value) {
  let newScore = scor
  return newScore
}')
	mut result := analize(state.ast, compiler.modules)
	assert result.error.occurred == true
	assert result.error.id == 'identifier_not_declared'
	assert result.error.suggestion == 'score'

	// Typo in top level: "usar" -> suggest "user"
	state = Parser{}
	state.parse('testfile', 'const user = { name: "x" }
const x = usar.name')
	result = analize(state.ast, compiler.modules)
	assert result.error.occurred == true
	assert result.error.suggestion == 'user'

	// No suggestion when nothing close (or no declarations)
	state = Parser{}
	state.parse('testfile', 'const a = xyzzy')
	result = analize(state.ast, compiler.modules)
	assert result.error.occurred == true
	assert result.error.suggestion == ''
}

fn test_no_undefined_references() {
	mut state := Parser{}
	state.parse('testfile', 'const a = b')
	mut result := analize(state.ast, compiler.modules)
	assert result.error.occurred == true

	state = Parser{}
	state.parse('testfile', 'const a = [b]')
	result = analize(state.ast, compiler.modules)
	assert result.error.occurred == true

	state = Parser{}
	state.parse('testfile', 'const a = [[b]]')
	result = analize(state.ast, compiler.modules)
	assert result.error.occurred == true

	state = Parser{}
	state.parse('testfile', 'const a = {key: a}')
	result = analize(state.ast, compiler.modules)
	assert result.error.occurred == true

	state = Parser{}
	state.parse('testfile', 'const a = {key: {key: a}}')
	result = analize(state.ast, compiler.modules)
	assert result.error.occurred == true

	state = Parser{}
	state.parse('testfile', 'const a = test(1)')
	result = analize(state.ast, compiler.modules)
	assert result.error.occurred == true

	state = Parser{}
	state.parse('testfile', 'function test() {} const a = test(b)')
	result = analize(state.ast, compiler.modules)
	assert result.error.occurred == true

	state = Parser{}
	state.parse('testfile', 'function test() { const a = b }')
	result = analize(state.ast, compiler.modules)
	assert result.error.occurred == true

	state = Parser{}
	state.parse('testfile', 'function test() { other() }')
	result = analize(state.ast, compiler.modules)
	assert result.error.occurred == true

	state = Parser{}
	state.parse('testfile', 'function test() { return a }')
	result = analize(state.ast, compiler.modules)
	assert result.error.occurred == true

	state = Parser{}
	state.parse('testfile', 'function test(a) { return a }')
	result = analize(state.ast, compiler.modules)
	assert result.error.occurred == false

	state = Parser{}
	state.parse('testfile', 'const a = 0 function test() { return a }')
	result = analize(state.ast, compiler.modules)
	assert result.error.occurred == false

	state = Parser{}
	state.parse('testfile', 'import print from "stdd"')
	result = analize(state.ast, compiler.modules)
	assert result.error.occurred == true
}

fn test_exported_functions() {
	mut state := Parser{}
	state.parse('testfile', 'function test() {}')
	mut result := analize(state.ast, compiler.modules)
	assert result.exported_names == []

	state = Parser{}
	state.parse('testfile', 'export function main() {}')
	result = analize(state.ast, compiler.modules)
	assert result.exported_names == ['main']

	state = Parser{}
	state.parse('testfile', 'export function test() {}')
	result = analize(state.ast, compiler.modules)
	assert result.error.occurred == true
}

fn test_import_clash_with_const() {
	mut state := Parser{}
	state.parse('testfile', 'import Foo from "std/io" const Foo = 1')
	mut result := analize(state.ast, compiler.modules_with_std_io)
	assert result.error.occurred == true

	state = Parser{}
	state.parse('testfile', 'const Foo = 1 import Foo from "std/io"')
	result = analize(state.ast, compiler.modules_with_std_io)
	assert result.error.occurred == true
}

fn test_valid_import_no_error() {
	mut state := Parser{}
	state.parse('testfile', 'import IO from "std/io" const x = 1')
	mut result := analize(state.ast, compiler.modules_with_std_io)
	assert result.error.occurred == false
}

fn test_import_only_at_top_level() {
	mut state := Parser{}
	state.parse('testfile', 'const x = 1 import IO from "std/io"')
	mut result := analize(state.ast, compiler.modules_with_std_io)
	assert result.error.occurred == true
	assert result.error.id == 'import_not_at_top_level'

	state = Parser{}
	state.parse('testfile', 'function f() {} import IO from "std/io"')
	result = analize(state.ast, compiler.modules_with_std_io)
	assert result.error.occurred == true
	assert result.error.id == 'import_not_at_top_level'

	state = Parser{}
	state.parse('testfile', 'import A from "std/io" import B from "std/io" const x = 1')
	result = analize(state.ast, compiler.modules_with_std_io)
	assert result.error.occurred == false
}

fn test_undefined_in_function_call_args() {
	mut state := Parser{}
	state.parse('testfile', 'function f(a) { g(a, b) }')
	mut result := analize(state.ast, compiler.modules)
	assert result.error.occurred == true

	state = Parser{}
	state.parse('testfile', 'const x = 1 function f() { g(x, y) }')
	result = analize(state.ast, compiler.modules)
	assert result.error.occurred == true
}

fn test_return_with_valid_reference() {
	mut state := Parser{}
	state.parse('testfile', 'function f() { const x = 0 return x }')
	mut result := analize(state.ast, compiler.modules)
	assert result.error.occurred == false

	state = Parser{}
	state.parse('testfile', 'const x = 10 function f() { return x }')
	result = analize(state.ast, compiler.modules)
	assert result.error.occurred == false
}

fn test_same_name_in_different_functions_no_clash() {
	mut state := Parser{}
	state.parse('testfile', 'function f() { let a = 1 return a } function g() { let a = 2 return a }')
	mut result := analize(state.ast, compiler.modules)
	assert result.error.occurred == false
}

fn test_undefined_in_object_value() {
	mut state := Parser{}
	state.parse('testfile', 'const a = { x: 1, y: z }')
	mut result := analize(state.ast, compiler.modules)
	assert result.error.occurred == true
}

fn test_undefined_in_array_element() {
	mut state := Parser{}
	state.parse('testfile', 'const a = [1, two, 3]')
	mut result := analize(state.ast, compiler.modules)
	assert result.error.occurred == true
}

fn test_valid_object_and_array_with_definitions() {
	mut state := Parser{}
	state.parse('testfile', 'const x = 1 const y = 2 const a = { k: x } const b = [y, x]')
	mut result := analize(state.ast, compiler.modules)
	assert result.error.occurred == false
}

fn test_function_call_with_literal_args_no_error() {
	mut state := Parser{}
	state.parse('testfile', 'function f() { g(1, "a", true) }')
	mut result := analize(state.ast, compiler.modules)
	assert result.error.occurred == true
}

fn test_defined_function_call_no_error() {
	mut state := Parser{}
	state.parse('testfile', 'function g() {} function f() { g() }')
	mut result := analize(state.ast, compiler.modules)
	assert result.error.occurred == false
}

fn test_nested_object_valid_access() {
	mut state := Parser{}
	state.parse('testfile', 'const user = { name: "Jane", details: { age: 30 } }
function f() {
  const x = user.details.age
  return user.name
}')
	mut result := analize(state.ast, compiler.modules)
	assert result.error.occurred == false
}

fn test_same_name_object_in_different_functions_scoped_shape() {
	// Each function has its own "user" with a different shape; member access uses the inner scope.
	mut state := Parser{}
	state.parse('testfile', 'function f() {
  const user = { name: "f" }
  return user.name
}
function g() {
  const user = { age: 30 }
  return user.age
}')
	mut result := analize(state.ast, compiler.modules)
	assert result.error.occurred == false

	// In f, user has only "name"; user.age should error
	state = Parser{}
	state.parse('testfile', 'function f() {
  const user = { name: "f" }
  return user.age
}')
	result = analize(state.ast, compiler.modules)
	assert result.error.occurred == true
	assert result.error.id == 'nested_property_not_declared'

	// In g, user has only "age"; user.name should error
	state = Parser{}
	state.parse('testfile', 'function g() {
  const user = { age: 30 }
  return user.name
}')
	result = analize(state.ast, compiler.modules)
	assert result.error.occurred == true
	assert result.error.id == 'nested_property_not_declared'

	// Global user shadowed by local user: inside f, user.x uses f's shape (only "name"), not global's
	state = Parser{}
	state.parse('testfile', 'const user = { name: "global", id: 1 }
function f() {
  const user = { name: "local" }
  return user.name
}')
	result = analize(state.ast, compiler.modules)
	assert result.error.occurred == false

	state = Parser{}
	state.parse('testfile', 'const user = { name: "global", id: 1 }
function f() {
  const user = { name: "local" }
  return user.id
}')
	result = analize(state.ast, compiler.modules)
	assert result.error.occurred == true
	assert result.error.id == 'nested_property_not_declared'
}

fn test_nested_object_invalid_key_at_leaf() {
	mut state := Parser{}
	state.parse('testfile', 'const user = { name: "Jane", details: { age: 30 } }
const city = user.details.city')
	mut result := analize(state.ast, compiler.modules)
	assert result.error.occurred == true
	assert result.error.id == 'nested_property_not_declared'
	assert result.error.context == 'undefined_nested_reference'
}

fn test_nested_object_invalid_key_first_level() {
	mut state := Parser{}
	state.parse('testfile', 'const user = { name: "Jane" }
const x = user.foo')
	mut result := analize(state.ast, compiler.modules)
	assert result.error.occurred == true
	assert result.error.id == 'nested_property_not_declared'
}

fn test_member_access_on_non_object_errors() {
	mut state := Parser{}
	state.parse('testfile', 'const x = 1
const y = x.foo')
	mut result := analize(state.ast, compiler.modules)
	assert result.error.occurred == true
	assert result.error.id == 'nested_property_not_declared'
}

fn test_import_member_valid() {
	mut state := Parser{}
	state.parse('testfile', 'import IO from "std/io"
const x = 0
function main() {
  return x
}')
	mut result := analize(state.ast, compiler.modules_with_std_io)
	assert result.error.occurred == false
	// Reference IO.print as value (member expression) - valid
	state = Parser{}
	state.parse('testfile', 'import IO from "std/io"
const fn_ref = IO.print')
	result = analize(state.ast, compiler.modules_with_std_io)
	assert result.error.occurred == false
	// Call IO.print(...) - valid
	state = Parser{}
	state.parse('testfile', 'import IO from "std/io"
function main() {
  IO.print("Hello, from Silk!")
}')
	result = analize(state.ast, compiler.modules_with_std_io)
	assert result.error.occurred == false
}

fn test_import_member_invalid_property() {
	mut state := Parser{}
	state.parse('testfile', 'import IO from "std/io"
const x = IO.unknown')
	mut result := analize(state.ast, compiler.modules_with_std_io)
	assert result.error.occurred == true
	assert result.error.id == 'nested_property_not_declared'
	assert result.error.context == 'undefined_nested_reference'
}

fn test_member_access_in_assignments() {
	// const and let assignments use the correct (innermost) shape
	mut state := Parser{}
	state.parse('testfile', 'function f() {
  const user = { name: "a", id: 1 }
  const n = user.name
  let id = user.id
  return n
}')
	mut result := analize(state.ast, compiler.modules)
	assert result.error.occurred == false

	state = Parser{}
	state.parse('testfile', 'function f() {
  const user = { name: "a" }
  const bad = user.id
  return bad
}')
	result = analize(state.ast, compiler.modules)
	assert result.error.occurred == true
	assert result.error.id == 'nested_property_not_declared'
}

fn test_member_access_as_function_argument() {
	// member access in call args uses correct scope
	mut state := Parser{}
	state.parse('testfile', 'const user = { name: "x" }
function f(x) { return x }
const a = f(user.name)')
	mut result := analize(state.ast, compiler.modules)
	assert result.error.occurred == false

	state = Parser{}
	state.parse('testfile', 'function f(n) { return n }
function g() {
  const user = { id: 1 }
  f(user.id)
}')
	result = analize(state.ast, compiler.modules)
	assert result.error.occurred == false

	state = Parser{}
	state.parse('testfile', 'const user = { name: "x" }
function f(x) { return x }
const a = f(user.bad)')
	result = analize(state.ast, compiler.modules)
	assert result.error.occurred == true
	assert result.error.id == 'nested_property_not_declared'
}

fn test_member_access_in_nested_assignments() {
	// member access in object literal and array literal values
	mut state := Parser{}
	state.parse('testfile', 'const user = { name: "x", details: { age: 10 } }
const obj = { label: user.name, inner: user.details.age }
const arr = [user.name, user.details.age]')
	mut result := analize(state.ast, compiler.modules)
	assert result.error.occurred == false

	state = Parser{}
	state.parse('testfile', 'const user = { name: "x" }
const obj = { bad: user.age }')
	result = analize(state.ast, compiler.modules)
	assert result.error.occurred == true
	assert result.error.id == 'nested_property_not_declared'

	state = Parser{}
	state.parse('testfile', 'function f() {
  const user = { a: 1, b: 2 }
  const nested = { x: user.a, y: user.b, z: user.c }
  return nested
}')
	result = analize(state.ast, compiler.modules)
	assert result.error.occurred == true
	assert result.error.id == 'nested_property_not_declared'
}

fn test_member_access_with_parameter_shadowing() {
	// Parameter shadows global: no shape for param, so user.prop errors (do not use global shape)
	mut state := Parser{}
	state.parse('testfile', 'const user = { name: "global", id: 1 }
function f(user) {
  return user.name
}')
	mut result := analize(state.ast, compiler.modules)
	assert result.error.occurred == true
	assert result.error.id == 'nested_property_not_declared'

	// Same: param "u" shadows nothing; "user" in user.name refers to global - valid
	state = Parser{}
	state.parse('testfile', 'const user = { name: "global" }
function f(u) {
  return user.name
}')
	result = analize(state.ast, compiler.modules)
	assert result.error.occurred == false

	// Param and local: local user shadows param; use local shape
	state = Parser{}
	state.parse('testfile', 'function f(user) {
  const user = { name: "local" }
  return user.name
}')
	result = analize(state.ast, compiler.modules)
	assert result.error.occurred == true
	// name clash: param user and const user in same scope
	assert result.error.id == 'identifier_already_declared'

	// Param "data" has no shape; data.x errors
	state = Parser{}
	state.parse('testfile', 'function f(data) {
  return data.x
}')
	result = analize(state.ast, compiler.modules)
	assert result.error.occurred == true
	assert result.error.id == 'nested_property_not_declared'
}

fn test_array_index_number_literal() {
	mut state := Parser{}
	state.parse('testfile', 'const arr = [10, 20, 30]
const first = arr[0]
const second = arr[1]')
	mut result := analize(state.ast, compiler.modules)
	assert result.error.occurred == false

	state = Parser{}
	state.parse('testfile', 'function f() {
  const xs = [1, 2, 3]
  let i = 0
  return xs[i]
}')
	result = analize(state.ast, compiler.modules)
	assert result.error.occurred == false
}

fn test_array_index_reference_to_number() {
	mut state := Parser{}
	state.parse('testfile', 'const arr = [10, 20]
const idx = 1
const val = arr[idx]')
	mut result := analize(state.ast, compiler.modules)
	assert result.error.occurred == false
}

fn test_array_index_must_be_number() {
	mut state := Parser{}
	state.parse('testfile', 'const arr = [1, 2, 3]
const x = arr["0"]')
	mut result := analize(state.ast, compiler.modules)
	assert result.error.occurred == true
	assert result.error.id == 'index_must_be_number'

	state = Parser{}
	state.parse('testfile', 'const arr = [1, 2]
const name = "x"
const bad = arr[name]')
	result = analize(state.ast, compiler.modules)
	assert result.error.occurred == true
	assert result.error.id == 'index_must_be_number'

	state = Parser{}
	state.parse('testfile', 'const arr = [1, 2]
const idx = "not a number"
const bad = arr[idx]')
	result = analize(state.ast, compiler.modules)
	assert result.error.occurred == true
	assert result.error.id == 'index_must_be_number'
}

fn test_array_index_nested() {
	mut state := Parser{}
	state.parse('testfile', 'const matrix = [[1, 2], [3, 4]]
const cell = matrix[0][1]')
	mut result := analize(state.ast, compiler.modules)
	assert result.error.occurred == false
}

fn test_array_index_outer_scope_number_variable() {
	// Index variable from outer (program) scope: const at top level, used inside function
	mut state := Parser{}
	state.parse('testfile', 'const idx = 0
const arr = [10, 20, 30]
function main() {
  return arr[idx]
}')
	mut result := analize(state.ast, compiler.modules)
	assert result.error.occurred == false

	state = Parser{}
	state.parse('testfile', 'const i = 1
const xs = ["a", "b", "c"]
function f() {
  const first = xs[i]
  return first
}')
	result = analize(state.ast, compiler.modules)
	assert result.error.occurred == false
}

fn test_array_index_member_expression_number() {
	// Index can be obj.param when that property is a number literal in the object shape
	mut state := Parser{}
	state.parse('testfile', 'const config = { index: 0, name: "x" }
const arr = [10, 20, 30]
const first = arr[config.index]')
	mut result := analize(state.ast, compiler.modules)
	assert result.error.occurred == false

	state = Parser{}
	state.parse('testfile', 'const opts = { i: 1 }
const xs = ["a", "b", "c"]
function f() {
  return xs[opts.i]
}')
	result = analize(state.ast, compiler.modules)
	assert result.error.occurred == false
}

fn test_array_index_member_expression_non_number_rejected() {
	// Index obj.param when param is not a number (e.g. string) is rejected
	mut state := Parser{}
	state.parse('testfile', 'const config = { name: "x", index: 0 }
const arr = [10, 20]
const bad = arr[config.name]')
	mut result := analize(state.ast, compiler.modules)
	assert result.error.occurred == true
	assert result.error.id == 'index_must_be_number'
}

fn test_null_as_variable_value() {
	mut state := Parser{}
	state.parse('testfile', 'const x = null')
	mut result := analize(state.ast, compiler.modules)
	assert result.error.occurred == false

	state = Parser{}
	state.parse('testfile', 'function f() { let maybe = null\nreturn maybe }')
	result = analize(state.ast, compiler.modules)
	assert result.error.occurred == false

	state = Parser{}
	state.parse('testfile', 'const obj = { a: null }\nconst arr = [null, 1]')
	result = analize(state.ast, compiler.modules)
	assert result.error.occurred == false

	state = Parser{}
	state.parse('testfile', 'function f() { return null }')
	result = analize(state.ast, compiler.modules)
	assert result.error.occurred == false
}

fn test_math_in_variable_declaration() {
	mut state := Parser{}
	state.parse('testfile', 'const a = 1 + 2
const b = 10 - 3
function f() {
  let c = a + b
  return c
}')
	mut result := analize(state.ast, compiler.modules)
	assert result.error.occurred == false

	state = Parser{}
	state.parse('testfile', 'const x = 1
const y = 2
const sum = x + y
const arr = [10, 20, 30]
const first = arr[sum]')
	result = analize(state.ast, compiler.modules)
	assert result.error.occurred == false
}

fn test_math_operands_must_be_numbers() {
	mut state := Parser{}
	state.parse('testfile', 'const name = "x"
const bad = 1 + name')
	mut result := analize(state.ast, compiler.modules)
	assert result.error.occurred == true
	assert result.error.id == 'binary_operands_must_be_numbers'

	state = Parser{}
	state.parse('testfile', 'const a = 1
const b = "y"
const bad = a + b')
	result = analize(state.ast, compiler.modules)
	assert result.error.occurred == true
	assert result.error.id == 'binary_operands_must_be_numbers'
}
