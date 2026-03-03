module util

import term
import types { CompileError }

const errors_map = {
	'unexpected_token':             'I was not expecting this.'
	'unexpected_eof':               'The program ended unexpectedly.'
	'identifier_already_declared':  'This identifier has already been declared.'
	'identifier_not_declared':      'This identifier has not been declared.'
	'module_not_found':             'This module could not be found.'
	'cannot_export_function':       'Can only export main.'
	'import_not_at_top_level':      'Imports must appear at the top level.'
	'nested_property_not_declared': 'This property has not been declared.'
	'index_must_be_number':         'Array index must be a number literal or a reference to a number.'
	'reserved_word_as_identifier': 'A reserved word cannot be used as an identifier (variable or function name).'
	'binary_only_in_declaration':   'Arithmetic operations are only allowed in variable declarations (const/let).'
	'binary_operands_must_be_numbers': 'Both operands must be numbers (literals or references to numbers).'
	'else_without_if':              'An else block must come immediately after an if block.'
}

const reasons_map = {
	'literal':                        '${term.bold('Expected:')} String, Number, Boolean, Array, Object or Function.'
	'statement':                      '${term.bold('Expected:')} ${term.cyan('import')}, ${term.cyan('const')} or ${term.cyan('function')}.'
	'nested_statement':               '${term.bold('Expected:')} ${term.cyan('const')}, ${term.cyan('let')}, ${term.cyan('return')} or a function call.'
	'scoped_statement':               '${term.bold('Expected:')} ${term.cyan('let')}, ${term.cyan('const')}, ${term.cyan('function')} or ${term.cyan('return')}'
	'expression_value':               'Expected value of ${term.cyan('Number')}, ${term.cyan('String')}, ${term.cyan('Boolean')}, ${term.cyan('Identifier')}, ${term.cyan('Array')} or ${term.cyan('Object')}.'
	'dangling_comma':                 'Cannot have a dangling comma.'
	'import':                         'Cannot import with this name. It has already been declared.'
	'const':                          'Cannot declare a constant with this name. It has already been declared.'
	'let':                            'Cannot declare a variable with this name. It has already been declared.'
	'function':                       'Cannot declare a function with this name. It has already been declared.'
	'let_value_does_not_exist':       'Cant use this variable as value. It has not exist.'
	'name_clash':                     'Cannot use this name. It has already been declared.'
	'undefined_reference':            'Cannot use this name. It has not been declared.'
	'undefined_token':                'This token cannot be used by the language.'
	'exported_function_must_be_main': 'The exported function must be called main.'
	'import_after_statement':         'All ${term.cyan("import")} statements must come before any other statement.'
	'undefined_nested_reference':     'Cannot access this nested property. It does not exist on the object.'
	'index_must_be_number_literal_or_reference': 'Index must be a number literal (e.g. 0) or a variable that holds a number.'
	'reserved_word_as_identifier': 'Use a different name; this word is reserved by the language.'
	'binary_only_in_declaration': 'Use arithmetic only in const/let initializers.'
	'binary_operands_must_be_numbers': 'Use number literals or variables that hold numbers.'
	'else_without_if': 'Move this else so it comes right after an if block in the same scope.'
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
	if error.suggestion != '' {
		println('${pad_left} • ${term.bold('Did you mean:')} ${term.cyan(error.suggestion)}?')
	}
	exit(1)
}
