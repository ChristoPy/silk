module tokenizer

fn test_get_next_token() {
	mut state := Tokenizer{}
	state.init('test', '1 2 3')

	assert state.get_next_token().name == 'NUMBER'
	assert state.get_next_token().name == 'NUMBER'
	assert state.get_next_token().name == 'NUMBER'
}

fn test_eof() {
	mut state := Tokenizer{}
	state.init('test', '1')

	assert state.eof == false
	assert state.get_next_token().name == 'NUMBER'
	assert state.get_next_token().name == 'EOF'
	assert state.eof == true
}

fn test_skip_comments() {
	mut state := Tokenizer{}
	state.init('test', '// comment
	1')

	assert state.get_next_token().name == 'NUMBER'
}
