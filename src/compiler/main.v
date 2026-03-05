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

pub const standard_modules = {
	'std/io':     compiler.standard_module,
	'std/string': compiler.standard_module_string,
	'std/number': compiler.standard_module_number,
	'std/array':  compiler.standard_module_array,
	'std/object': compiler.standard_module_object,
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
