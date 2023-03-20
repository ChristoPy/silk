module compiler

import src.parser { Parser }

fn test_no_name_clashes() {
	mut state := Parser{}
	state.parse('testfile', 'import name from "value" import name from "value"')
	mut result := analize(state.ast)
	assert result.error == true

	state = Parser{}
	state.parse('testfile', 'const a = 0 const a = 1')
	result = analize(state.ast)
	assert result.error == true

	state = Parser{}
	state.parse('testfile', 'function test(){} function test(){}')
	result = analize(state.ast)
	assert result.error == true
}
