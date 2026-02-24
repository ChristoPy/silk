module compiler

import parser { Parser }

const modules = {
	'std': standard_module
}

const modules_with_std_print = {
	'std/print': standard_module
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
	state.parse('testfile', 'import Foo from "std/print" const Foo = 1')
	mut result := analize(state.ast, compiler.modules_with_std_print)
	assert result.error.occurred == true

	state = Parser{}
	state.parse('testfile', 'const Foo = 1 import Foo from "std/print"')
	result = analize(state.ast, compiler.modules_with_std_print)
	assert result.error.occurred == true
}

fn test_valid_import_no_error() {
	mut state := Parser{}
	state.parse('testfile', 'import IO from "std/print" const x = 1')
	mut result := analize(state.ast, compiler.modules_with_std_print)
	assert result.error.occurred == false
}

fn test_import_only_at_top_level() {
	mut state := Parser{}
	state.parse('testfile', 'const x = 1 import IO from "std/print"')
	mut result := analize(state.ast, compiler.modules_with_std_print)
	assert result.error.occurred == true
	assert result.error.id == 'import_not_at_top_level'

	state = Parser{}
	state.parse('testfile', 'function f() {} import IO from "std/print"')
	result = analize(state.ast, compiler.modules_with_std_print)
	assert result.error.occurred == true
	assert result.error.id == 'import_not_at_top_level'

	state = Parser{}
	state.parse('testfile', 'import A from "std/print" import B from "std/print" const x = 1')
	result = analize(state.ast, compiler.modules_with_std_print)
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
