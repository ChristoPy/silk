module compiler

import src.types { AST, Token }
import src.tokenizer { Tokenizer }

pub struct Compiler {
mut:
	tokenizer Tokenizer
}

pub fn (mut state Compiler) compile(file_name string, source string) AST {
	mut ast := AST{
		name: 'program'
		nodes: []Token{}
	}
	state.tokenizer = Tokenizer{
		code: source
		line: 1
		eof: false
	}
	for {
		if !state.tokenizer.has_more_tokens() {
			break
		}
		result := state.tokenizer.get_next_token() or { exit(1) }
		ast.nodes << result
	}
	return ast
}
