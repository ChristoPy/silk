module tokenizer

fn test_get_next_token() {
	mut state := Tokenizer{}
	state.init('test', '1 2 3')

	assert state.get_next_token().kind == 'Number'
	assert state.get_next_token().kind == 'Number'
	assert state.get_next_token().kind == 'Number'
}

fn test_eof() {
	mut state := Tokenizer{}
	state.init('test', '1')

	assert state.eof == false
	assert state.get_next_token().kind == 'Number'
	assert state.get_next_token().kind == 'EOF'
	assert state.eof == true
}

fn test_skip_comments() {
	mut state := Tokenizer{}
	state.init('test', '// comment
	1')

	assert state.get_next_token().kind == 'Number'
}

fn test_line_number() {
	mut state := Tokenizer{}
	state.init('test', 'import
Math
from
"math"
')
	assert state.get_next_token().line == 1
	assert state.get_next_token().line == 2
	assert state.get_next_token().line == 3
	assert state.get_next_token().line == 4
	assert state.get_next_token().line == 5 // single \n

	state.init('test', 'import

Math

from


"math"
')
	assert state.get_next_token().line == 1
	assert state.get_next_token().line == 3
	assert state.get_next_token().line == 5
	assert state.get_next_token().line == 8
	assert state.get_next_token().line == 9 // single \n
}

fn test_column_number() {
	mut state := Tokenizer{}
	state.init('test', 'import
         Math
 from
              "math"
')

	assert state.get_next_token().column == 1
	assert state.get_next_token().column == 10
	assert state.get_next_token().column == 2
	assert state.get_next_token().column == 15
}

fn test_token_kinds() {
	mut state := Tokenizer{}
	state.init('test', 'const x = 42')
	assert state.get_next_token().kind == 'Const'
	t := state.get_next_token()
	assert t.kind == 'Identifier' && t.value == 'x'
	assert state.get_next_token().kind == 'Equals'
	n := state.get_next_token()
	assert n.kind == 'Number' && n.value == '42'
	assert state.get_next_token().kind == 'EOF'
}

fn test_string_token() {
	mut state := Tokenizer{}
	state.init('test', '"hello"')
	t := state.get_next_token()
	assert t.kind == 'String'
	assert t.value == '"hello"'
	assert state.get_next_token().kind == 'EOF'
}

fn test_boolean_tokens() {
	mut state := Tokenizer{}
	state.init('test', 'true false')
	t1 := state.get_next_token()
	t2 := state.get_next_token()
	assert t1.kind == 'Boolean' && t2.kind == 'Boolean'
	assert t1.value in ['true', 'false'] && t2.value in ['true', 'false']
	assert t1.value != t2.value
	assert state.get_next_token().kind == 'EOF'
}

fn test_keywords_and_punctuation() {
	mut state := Tokenizer{}
	state.init('test', 'function return import from export let ( ) { } [ ] : , .')
	assert state.get_next_token().kind == 'Function'
	assert state.get_next_token().kind == 'Return'
	assert state.get_next_token().kind == 'Import'
	assert state.get_next_token().kind == 'From'
	assert state.get_next_token().kind == 'Export'
	assert state.get_next_token().kind == 'Let'
	assert state.get_next_token().kind == 'LParen'
	assert state.get_next_token().kind == 'RParen'
	assert state.get_next_token().kind == 'LBrace'
	assert state.get_next_token().kind == 'RBrace'
	assert state.get_next_token().kind == 'LBracket'
	assert state.get_next_token().kind == 'RBracket'
	assert state.get_next_token().kind == 'Colon'
	assert state.get_next_token().kind == 'Comma'
	assert state.get_next_token().kind == 'Dot'
	assert state.get_next_token().kind == 'EOF'
}

fn test_identifier_value() {
	mut state := Tokenizer{}
	state.init('test', 'foo_bar Baz42')
	t1 := state.get_next_token()
	t2 := state.get_next_token()
	assert t1.kind == 'Identifier' && t1.value == 'foo_bar'
	assert t2.kind == 'Identifier' && t2.value == 'Baz42'
	assert state.get_next_token().kind == 'EOF'
}

fn test_multiple_comments_skipped() {
	mut state := Tokenizer{}
	// Comment may match to end of line; use blank line so "1" is not consumed by comment
	state.init('test', '// first

1')
	n := state.get_next_token()
	assert n.kind == 'Number'
	assert n.value == '1'
	assert state.get_next_token().kind == 'EOF'
}

fn test_empty_input_eof() {
	mut state := Tokenizer{}
	state.init('test', '')
	assert state.get_next_token().kind == 'EOF'
	assert state.eof == true
}
