module util

import term
import src.types { CompileError }

pub fn throw_error(error CompileError) {
	line_length := error.line.str().len
	pad_left := ' '.repeat(line_length)
	wrong_bit_indicator := term.red('^'.repeat(error.wrong_bit.len))
	wrong_bit_pad := ' '.repeat(error.column - 1)

	file_path := term.bold('(${error.file_name}:${error.line}:${error.column})')
	kind := term.bold(term.red('${error.kind}:'))

	println('${pad_left} ╭─${file_path} ${kind} ${error.message}')
	println('${pad_left} │')
	println('${error.line} │ ${error.line_content}')
	println('${pad_left} │ ${wrong_bit_pad}${wrong_bit_indicator}')
	if error.context != '' {
		println('${pad_left} • ${error.context}')
	}
	exit(1)
}
