module compiler

import types { ASTNode, ASTNodeAssignmentMeta, ASTNodeBinaryExpressionMeta, ASTNodeElseMeta, ASTNodeFunctionCallMeta, ASTNodeFunctionMeta, ASTNodeIfMeta, ASTNodeImportStatementMeta, ASTNodeIndexExpressionMeta, ASTNodeMemberExpressionMeta, ASTNodeObjectMetaValue, ASTNodeReturnMeta, ASTNodeUnaryExpressionMeta, ASTNodeVariableMeta, ASTNodeVariableMetaValue, CompileError, Function, Module, Modules, SubNodeAST, Token }
import util { throw_error }
import parser { Parser }

pub const standard_module = Module{
	name: 'std/io'
	functions: [Function{
		name: 'print'
		arguments: ['value']
	}]
}


const standard_module_string = Module{
	name: 'std/string'
	functions: [
		Function{ name: 'uppercase', arguments: ['s'] },
		Function{ name: 'lowercase', arguments: ['s'] },
		Function{ name: 'trim', arguments: ['s'] },
		Function{ name: 'length', arguments: ['s'] },
		Function{ name: 'slice', arguments: ['s', 'start', 'end'] },
		Function{ name: 'includes', arguments: ['s', 'sub'] },
		Function{ name: 'split', arguments: ['s', 'sep'] },
		Function{ name: 'replace', arguments: ['s', 'from', 'to'] },
		Function{ name: 'concat', arguments: ['a', 'b'] },
	]
}

const standard_module_number = Module{
	name: 'std/number'
	functions: [
		Function{ name: 'round', arguments: ['n'] },
		Function{ name: 'floor', arguments: ['n'] },
		Function{ name: 'ceil', arguments: ['n'] },
		Function{ name: 'abs', arguments: ['n'] },
		Function{ name: 'min', arguments: ['a', 'b'] },
		Function{ name: 'max', arguments: ['a', 'b'] },
		Function{ name: 'parse', arguments: ['s'] },
	]
}

const standard_module_array = Module{
	name: 'std/array'
	functions: [
		Function{ name: 'length', arguments: ['arr'] },
		Function{ name: 'join', arguments: ['arr', 'sep'] },
		Function{ name: 'concat', arguments: ['a', 'b'] },
		Function{ name: 'slice', arguments: ['arr', 'start', 'end'] },
		Function{ name: 'indexOf', arguments: ['arr', 'elem'] },
		Function{ name: 'first', arguments: ['arr'] },
		Function{ name: 'last', arguments: ['arr'] },
	]
}

const standard_module_object = Module{
	name: 'std/object'
	functions: [
		Function{ name: 'keys', arguments: ['obj'] },
		Function{ name: 'values', arguments: ['obj'] },
		Function{ name: 'has', arguments: ['obj', 'key'] },
	]
}

const standard_module_json = Module{
	name: 'std/json'
	functions: [
		Function{ name: 'parse', arguments: ['s'] },
		Function{ name: 'stringify', arguments: ['value'] },
	]
}

const standard_module_http = Module{
	name: 'std/http'
	functions: [
		Function{ name: 'get', arguments: ['url'] },
		Function{ name: 'post', arguments: ['url', 'body'] },
	]
}

const standard_module_time = Module{
	name: 'std/time'
	functions: [
		Function{ name: 'now', arguments: [] },
		Function{ name: 'format', arguments: ['timestamp'] },
		Function{ name: 'parse', arguments: ['s'] },
	]
}

const standard_module_env = Module{
	name: 'std/env'
	functions: [
		Function{ name: 'get', arguments: ['name'] },
		Function{ name: 'has', arguments: ['name'] },
	]
}

const standard_module_regex = Module{
	name: 'std/regex'
	functions: [
		Function{ name: 'match', arguments: ['s', 'pattern'] },
		Function{ name: 'replace', arguments: ['s', 'pattern', 'replacement'] },
	]
}

const standard_module_math = Module{
	name: 'std/math'
	functions: [
		Function{ name: 'random', arguments: [] },
		Function{ name: 'sqrt', arguments: ['n'] },
		Function{ name: 'pow', arguments: ['base', 'exp'] },
	]
}

const standard_module_result = Module{
	name: 'std/result'
	functions: [
		Function{ name: 'ok', arguments: ['value'] },
		Function{ name: 'err', arguments: ['error'] },
		Function{ name: 'isOk', arguments: ['result'] },
		Function{ name: 'isErr', arguments: ['result'] },
		Function{ name: 'unwrapOr', arguments: ['result', 'default_value'] },
	]
}

pub const standard_modules = {
	'std/io':     compiler.standard_module,
	'std/string': compiler.standard_module_string,
	'std/number': compiler.standard_module_number,
	'std/array':  compiler.standard_module_array,
	'std/object': compiler.standard_module_object,
	'std/json':   compiler.standard_module_json,
	'std/http':   compiler.standard_module_http,
	'std/time':   compiler.standard_module_time,
	'std/env':    compiler.standard_module_env,
	'std/regex':  compiler.standard_module_regex,
	'std/math':   compiler.standard_module_math,
	'std/result': compiler.standard_module_result,
}

pub struct Compiler {
pub mut:
	parser  Parser
	modules Modules
}

pub fn (mut state Compiler) parse(file_name string, source string) {
	state.parser.parse(file_name, source)
	state.modules = compiler.standard_modules
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
			suggestion: result.error.suggestion
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
	mut lines := []string{}
	for node in state.parser.ast.body {
		lines << emit_node(node, 0)
	}
	return lines.join('\n') + '\n'
}

fn emit_node(node ASTNode, indent int) string {
	pad := '  '.repeat(indent)
	match node.name {
		'ImportStatement' {
			meta := node.meta as ASTNodeImportStatementMeta
			raw := meta.path.value
			path := raw.substr(1, raw.len - 1)
			return '${pad}import ${meta.name.value} from "./${path}/index.js"'
		}
		'ConstantDeclaration' {
			meta := node.meta as ASTNodeVariableMeta
			return '${pad}const ${meta.name.value} = ${emit_value(meta.value)};'
		}
		'LetDeclaration' {
			meta := node.meta as ASTNodeVariableMeta
			return '${pad}let ${meta.name.value} = ${emit_value(meta.value)};'
		}
		'AssignmentStatement' {
			meta := node.meta as ASTNodeAssignmentMeta
			return '${pad}${meta.name.value} = ${emit_value(meta.value)};'
		}
		'FunctionDeclaration' {
			meta := node.meta as ASTNodeFunctionMeta
			prefix := if meta.exported { 'export ' } else { '' }
			mut arg_names := []string{}
			for arg in meta.args {
				arg_names << arg.value
			}
			args_str := arg_names.join(', ')
			body_str := emit_body(meta.body, indent + 1)
			return '${pad}${prefix}function ${meta.name.value}(${args_str}) {\n${body_str}\n${pad}}'
		}
		'FunctionCallStatement' {
			meta := node.meta as ASTNodeFunctionCallMeta
			return '${pad}${emit_call(meta)};'
		}
		'ReturnStatement' {
			meta := node.meta as ASTNodeReturnMeta
			return '${pad}return ${emit_value(meta.value)};'
		}
		'IfStatement' {
			meta := node.meta as ASTNodeIfMeta
			body_str := emit_body(meta.body, indent + 1)
			return '${pad}if (${emit_value(meta.condition)}) {\n${body_str}\n${pad}}'
		}
		'ElseStatement' {
			meta := node.meta as ASTNodeElseMeta
			body_str := emit_body(meta.body, indent + 1)
			return '${pad}else {\n${body_str}\n${pad}}'
		}
		else {
			panic('emit_node: unhandled node: ${node.name}')
		}
	}
	return ''
}

fn emit_body(body []ASTNode, indent int) string {
	mut lines := []string{}
	for node in body {
		lines << emit_node(node, indent)
	}
	return lines.join('\n')
}

fn emit_value(value ASTNodeVariableMetaValue) string {
	match value {
		Token {
			return value.value
		}
		SubNodeAST {
			if value.name == 'Array' {
				mut items := []string{}
				for item in value.body {
					items << emit_value(item)
				}
				return '[${items.join(', ')}]'
			}
			if value.name == 'Object' {
				mut pairs := []string{}
				for node in value.body {
					data := node as ASTNodeObjectMetaValue
					pairs << '${data.key.value}: ${emit_value(data.value)}'
				}
				return '{${pairs.join(', ')}}'
			}
			return ''
		}
		ASTNode {
			match value.name {
				'BinaryExpression' {
					meta := value.meta as ASTNodeBinaryExpressionMeta
					op := op_to_js(meta.op.kind)
					return '(${emit_value(meta.left)} ${op} ${emit_value(meta.right)})'
				}
				'UnaryExpression' {
					meta := value.meta as ASTNodeUnaryExpressionMeta
					return '!${emit_value(meta.right)}'
				}
				'MemberExpression' {
					meta := value.meta as ASTNodeMemberExpressionMeta
					return '${meta.name.value}.${emit_member_chain(meta.property)}'
				}
				'IndexExpression' {
					meta := value.meta as ASTNodeIndexExpressionMeta
					return '${emit_value(meta.base)}[${emit_value(meta.index)}]'
				}
				'FunctionCallStatement' {
					meta := value.meta as ASTNodeFunctionCallMeta
					return emit_call(meta)
				}
				else {
					return ''
				}
			}
		}
		ASTNodeObjectMetaValue {
			return ''
		}
	}
}

fn emit_member_chain(property ASTNodeVariableMetaValue) string {
	match property {
		Token {
			return property.value
		}
		ASTNode {
			if property.name == 'MemberExpression' {
				meta := property.meta as ASTNodeMemberExpressionMeta
				return '${meta.name.value}.${emit_member_chain(meta.property)}'
			}
			return ''
		}
		else {
			return ''
		}
	}
}

fn emit_call(meta ASTNodeFunctionCallMeta) string {
	callee_str := emit_value(meta.callee)
	mut arg_strs := []string{}
	for arg in meta.args {
		arg_strs << emit_value(arg)
	}
	return '${callee_str}(${arg_strs.join(', ')})'
}

fn op_to_js(kind string) string {
	return match kind {
		'Plus' { '+' }
		'Minus' { '-' }
		'Star' { '*' }
		'Slash' { '/' }
		'EqEq' { '===' }
		'NotEq' { '!==' }
		'Lt' { '<' }
		'Gt' { '>' }
		'LtEq' { '<=' }
		'GtEq' { '>=' }
		'And' { '&&' }
		'Or' { '||' }
		else { kind }
	}
}
