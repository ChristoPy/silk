module compiler

import src.parser { Parser }

fn test_no_name_clashes() {
	mut state := Parser{}
	state.parse('testfile', 'import name from "value" import name from "value"')
	mut result := analize(state.ast)
	assert result.error == true

	state = Parser{}
	state.parse('testfile', 'const a = b')
	result = analize(state.ast)
	assert result.error == true

	state = Parser{}
	state.parse('testfile', 'function test(){} function test(){}')
	result = analize(state.ast)
	assert result.error == true
}

fn test_no_undefined_references() {
	mut state := Parser{}
	state.parse('testfile', 'const a = b')
	mut result := analize(state.ast)
	assert result.error == true

	state = Parser{}
	state.parse('testfile', 'const a = [b]')
	result = analize(state.ast)
	assert result.error == true

	state = Parser{}
	state.parse('testfile', 'const a = [[b]]')
	result = analize(state.ast)
	assert result.error == true

	state = Parser{}
	state.parse('testfile', 'const a = {key: a}')
	result = analize(state.ast)
	assert result.error == true

	state = Parser{}
	state.parse('testfile', 'const a = {key: {key: a}}')
	result = analize(state.ast)
	assert result.error == true
}
