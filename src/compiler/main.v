module compiler

import src.types { AST, Token }
import src.parser { Parser }

pub struct Compiler {
pub mut:
	parser Parser
}

pub fn (mut state Compiler) parse(file_name string, source string) {
	state.parser.parse(source)
}
