module compiler

import src.parser { Parser }

pub struct Compiler {
pub mut:
	parser Parser
}

pub fn (mut state Compiler) parse(file_name string, source string) {
	state.parser.parse(file_name, source)
}
