module compiler

import types { CompileError, Module, Function, Modules }
import util { throw_error }
import parser { Parser }

pub const standard_module = Module{
	name: 'std/io'
	functions: [Function{
		name: 'print'
		arguments: ['value']
	}]
}


const standard_module_string = Module{
	name: 'std/string'
	functions: [
		Function{ name: 'uppercase', arguments: ['s'] },
		Function{ name: 'lowercase', arguments: ['s'] },
		Function{ name: 'trim', arguments: ['s'] },
		Function{ name: 'length', arguments: ['s'] },
		Function{ name: 'slice', arguments: ['s', 'start', 'end'] },
		Function{ name: 'includes', arguments: ['s', 'sub'] },
		Function{ name: 'split', arguments: ['s', 'sep'] },
		Function{ name: 'replace', arguments: ['s', 'from', 'to'] },
		Function{ name: 'concat', arguments: ['a', 'b'] },
	]
}

const standard_module_number = Module{
	name: 'std/number'
	functions: [
		Function{ name: 'round', arguments: ['n'] },
		Function{ name: 'floor', arguments: ['n'] },
		Function{ name: 'ceil', arguments: ['n'] },
		Function{ name: 'abs', arguments: ['n'] },
		Function{ name: 'min', arguments: ['a', 'b'] },
		Function{ name: 'max', arguments: ['a', 'b'] },
		Function{ name: 'parse', arguments: ['s'] },
	]
}

const standard_module_array = Module{
	name: 'std/array'
	functions: [
		Function{ name: 'length', arguments: ['arr'] },
		Function{ name: 'join', arguments: ['arr', 'sep'] },
		Function{ name: 'concat', arguments: ['a', 'b'] },
		Function{ name: 'slice', arguments: ['arr', 'start', 'end'] },
		Function{ name: 'indexOf', arguments: ['arr', 'elem'] },
		Function{ name: 'first', arguments: ['arr'] },
		Function{ name: 'last', arguments: ['arr'] },
	]
}

const standard_module_object = Module{
	name: 'std/object'
	functions: [
		Function{ name: 'keys', arguments: ['obj'] },
		Function{ name: 'values', arguments: ['obj'] },
		Function{ name: 'has', arguments: ['obj', 'key'] },
	]
}

const standard_module_json = Module{
	name: 'std/json'
	functions: [
		Function{ name: 'parse', arguments: ['s'] },
		Function{ name: 'stringify', arguments: ['value'] },
	]
}

const standard_module_http = Module{
	name: 'std/http'
	functions: [
		Function{ name: 'get', arguments: ['url'] },
		Function{ name: 'post', arguments: ['url', 'body'] },
	]
}

const standard_module_time = Module{
	name: 'std/time'
	functions: [
		Function{ name: 'now', arguments: [] },
		Function{ name: 'format', arguments: ['timestamp'] },
		Function{ name: 'parse', arguments: ['s'] },
	]
}

const standard_module_env = Module{
	name: 'std/env'
	functions: [
		Function{ name: 'get', arguments: ['name'] },
		Function{ name: 'has', arguments: ['name'] },
	]
}

const standard_module_regex = Module{
	name: 'std/regex'
	functions: [
		Function{ name: 'match', arguments: ['s', 'pattern'] },
		Function{ name: 'replace', arguments: ['s', 'pattern', 'replacement'] },
	]
}

const standard_module_math = Module{
	name: 'std/math'
	functions: [
		Function{ name: 'random', arguments: [] },
		Function{ name: 'sqrt', arguments: ['n'] },
		Function{ name: 'pow', arguments: ['base', 'exp'] },
	]
}

const standard_module_result = Module{
	name: 'std/result'
	functions: [
		Function{ name: 'ok', arguments: ['value'] },
		Function{ name: 'err', arguments: ['error'] },
		Function{ name: 'isOk', arguments: ['result'] },
		Function{ name: 'isErr', arguments: ['result'] },
		Function{ name: 'unwrapOr', arguments: ['result', 'default_value'] },
	]
}

pub const standard_modules = {
	'std/io':     compiler.standard_module,
	'std/string': compiler.standard_module_string,
	'std/number': compiler.standard_module_number,
	'std/array':  compiler.standard_module_array,
	'std/object': compiler.standard_module_object,
	'std/json':   compiler.standard_module_json,
	'std/http':   compiler.standard_module_http,
	'std/time':   compiler.standard_module_time,
	'std/env':    compiler.standard_module_env,
	'std/regex':  compiler.standard_module_regex,
	'std/math':   compiler.standard_module_math,
	'std/result': compiler.standard_module_result,
}

pub struct Compiler {
pub mut:
	parser  Parser
	modules Modules
}

pub fn (mut state Compiler) parse(file_name string, source string) {
	state.parser.parse(file_name, source)
	state.modules = compiler.standard_modules
	state.compile()
}

fn (mut state Compiler) compile() {
	result := analize(state.parser.ast, state.modules)

	if result.error.occurred {
		wrong_token := result.error.token

		throw_error(CompileError{
			kind: result.error.kind
			id: result.error.id
			context: result.error.context
			file_name: state.parser.tokenizer.file
			wrong_token: wrong_token
			line_content: state.parser.tokenizer.code.split('\n')[wrong_token.line - 1]
			suggestion: result.error.suggestion
		})
		return
	}

	state.modules[state.parser.tokenizer.file] = Module{
		name: state.parser.tokenizer.file
	}
	for name in result.exported_names {
		state.modules[state.parser.tokenizer.file].functions << Function{
			name: name
			arguments: []
		}
	}
}

pub fn (mut state Compiler) generate_js() string {
	// TODO implement JS code generation
	return state.parser.tokenizer.code
}
