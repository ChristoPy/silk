module tokenizer

fn test_get_next_token() {
	mut state := Tokenizer{}
	state.init('test', '1 2 3')

	assert state.get_next_token().name == 'Number'
	assert state.get_next_token().name == 'Number'
	assert state.get_next_token().name == 'Number'
}

fn test_eof() {
	mut state := Tokenizer{}
	state.init('test', '1')

	assert state.eof == false
	assert state.get_next_token().name == 'Number'
	assert state.get_next_token().name == 'EOF'
	assert state.eof == true
}

fn test_skip_comments() {
	mut state := Tokenizer{}
	state.init('test', '// comment
	1')

	assert state.get_next_token().name == 'Number'
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
