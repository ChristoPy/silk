module compiler

import src.types { CompileError }
import src.util { throw_error }
import src.parser { Parser }

pub struct Compiler {
pub mut:
	parser Parser
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
}

pub fn (mut state Compiler) generate_js() string {
	// TODO implement JS code generation
	return state.parser.tokenizer.code
}
