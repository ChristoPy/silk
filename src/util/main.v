module util

import term
import src.types { CompileError }

const errors_map = {
	'unexpected_token':            'I was not expecting this.'
	'unexpected_eof':              'The program ended unexpectedly.'
	'identifier_already_declared': 'This identifier has already been declared.'
	'identifier_not_declared':     'This identifier has not been declared.'
}

const reasons_map = {
	'literal':                  '${term.bold('Expected:')} String, Number, Boolean, Array, Object or Function.'
	'statement':                '${term.bold('Expected:')} ${term.cyan('import')}, ${term.cyan('const')} or ${term.cyan('function')}.'
	'nested_statement':         '${term.bold('Expected:')} ${term.cyan('const')}, ${term.cyan('let')}, ${term.cyan('return')} or a function call.'
	'scoped_statement':         '${term.bold('Expected:')} ${term.cyan('let')}, ${term.cyan('const')}, ${term.cyan('function')} or ${term.cyan('return')}'
	'expression_value':         'Expected value of ${term.cyan('Number')}, ${term.cyan('String')}, ${term.cyan('Boolean')}, ${term.cyan('Identifier')}, ${term.cyan('Array')} or ${term.cyan('Object')}.'
	'dangling_comma':           'Cannot have a dangling comma.'
	'import':                   'Cannot import with this name. It has already been declared.'
	'const':                    'Cannot declare a constant with this name. It has already been declared.'
	'let':                      'Cannot declare a variable with this name. It has already been declared.'
	'function':                 'Cannot declare a function with this name. It has already been declared.'
	'let_value_does_not_exist': 'Cant use this variable as value. It has not exist.'
	'name_clash':               'Cannot use this name. It has already been declared.'
	'undefined_reference':      'Cannot use this name. It has not been declared.'
	'undefined_token':          'This token cannot be used by the language.'
}

pub fn throw_error(error CompileError) {
	line := error.wrong_token.line
	column := error.wrong_token.column
	wrong_bit := error.wrong_token.value

	line_length := line.str().len
	pad_left := ' '.repeat(line_length)
	wrong_bit_indicator := term.red('^'.repeat(wrong_bit.len))
	wrong_bit_pad := ' '.repeat(column - 1)

	file_path := term.bold('(${error.file_name}:${line}:${column})')
	kind := term.bold(term.red('${error.kind}Error:'))
	message := util.errors_map[error.id]

	println('${pad_left} ╭─${file_path} ${kind} ${message}')
	println('${pad_left} │')
	println('${line} │ ${error.line_content}')
	println('${pad_left} │ ${wrong_bit_pad}${wrong_bit_indicator}')
	if error.context != '' {
		context := util.reasons_map[error.context]
		println('${pad_left} • ${context}')
	}
	exit(1)
}
