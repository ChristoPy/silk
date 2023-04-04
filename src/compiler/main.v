module compiler

import types { CompileError, Module }
import util { throw_error }
import parser { Parser }

pub struct Compiler {
pub mut:
	parser  Parser
	modules map[string]Module
}

pub fn (mut state Compiler) parse(file_name string, source string) {
	state.parser.parse(file_name, source)
	state.compile()
}

fn (mut state Compiler) compile() {
	result := analize(state.parser.ast)

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
		state.modules[state.parser.tokenizer.file].functions[name] = name
	}
}

pub fn (mut state Compiler) generate_js() string {
	// TODO implement JS code generation
	return state.parser.tokenizer.code
}
