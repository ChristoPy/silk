module compiler

import src.parser { Parser }

fn test_no_name_clashes() {
	mut state := Parser{}
	state.parse('testfile', 'import name from "value" import name from "value"')
	mut result := analize(state.ast)
	assert result.error.occurred == true

	state = Parser{}
	state.parse('testfile', 'function test(){} function test(){}')
	result = analize(state.ast)
	assert result.error.occurred == true

	state = Parser{}
	state.parse('testfile', 'function test(){ let a = 0 let a = 0 }')
	result = analize(state.ast)
	assert result.error.occurred == true

	state = Parser{}
	state.parse('testfile', 'const a = 0 function test(){ let a = 0 }')
	result = analize(state.ast)
	assert result.error.occurred == false

	state = Parser{}
	state.parse('testfile', 'function test(a){ let a = 0 }')
	result = analize(state.ast)
	assert result.error.occurred == true

	state = Parser{}
	state.parse('testfile', 'function test(a, a){}')
	result = analize(state.ast)
	assert result.error.occurred == true
}

fn test_no_undefined_references() {
	mut state := Parser{}
	state.parse('testfile', 'const a = b')
	mut result := analize(state.ast)
	assert result.error.occurred == true

	state = Parser{}
	state.parse('testfile', 'const a = [b]')
	result = analize(state.ast)
	assert result.error.occurred == true

	state = Parser{}
	state.parse('testfile', 'const a = [[b]]')
	result = analize(state.ast)
	assert result.error.occurred == true

	state = Parser{}
	state.parse('testfile', 'const a = {key: a}')
	result = analize(state.ast)
	assert result.error.occurred == true

	state = Parser{}
	state.parse('testfile', 'const a = {key: {key: a}}')
	result = analize(state.ast)
	assert result.error.occurred == true

	state = Parser{}
	state.parse('testfile', 'const a = test(1)')
	result = analize(state.ast)
	assert result.error.occurred == true

	state = Parser{}
	state.parse('testfile', 'function test() {} const a = test(b)')
	result = analize(state.ast)
	assert result.error.occurred == true

	state = Parser{}
	state.parse('testfile', 'function test() { const a = b }')
	result = analize(state.ast)
	assert result.error.occurred == true

	state = Parser{}
	state.parse('testfile', 'function test() { other() }')
	result = analize(state.ast)
	assert result.error.occurred == true

	state = Parser{}
	state.parse('testfile', 'function test() { return a }')
	result = analize(state.ast)
	assert result.error.occurred == true

	state = Parser{}
	state.parse('testfile', 'function test(a) { return a }')
	result = analize(state.ast)
	assert result.error.occurred == false

	state = Parser{}
	state.parse('testfile', 'const a = 0 function test() { return a }')
	result = analize(state.ast)
	assert result.error.occurred == false
}
