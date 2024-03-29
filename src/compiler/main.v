module compiler

import types { CompileError, Module, Function, Modules }
import util { throw_error }
import parser { Parser }

const standard_module = Module{
	name: 'std/print'
	functions: [Function{
		name: 'print'
		arguments: ['value']
	}]
}

pub struct Compiler {
pub mut:
	parser  Parser
	modules Modules
}

pub fn (mut state Compiler) parse(file_name string, source string) {
	state.parser.parse(file_name, source)
	state.modules = {
		'std/print': compiler.standard_module
	}
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
