module util

import src.types { CompileError }

pub fn throw_error(error CompileError) {
	line_length := error.line.str().len
	spaces := ' '.repeat(line_length)
	wrong_bit := '^'.repeat(error.wrong_bit.len)

	println('${spaces} ╭─ Error: ${error.kind}Error')
	println('${error.line} │ ${error.wrong_bit}')
	println('${spaces} │ ${wrong_bit} ${error.message}')
	if error.context != '' {
		println('${error.context}')
	}
	exit(1)
}
