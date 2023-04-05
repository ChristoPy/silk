module types

pub struct Module {
pub mut:
	name      string
	functions []Function
}

pub struct Function {
pub mut:
	name string
	arguments []string
}

pub type Modules = map[string]Module
