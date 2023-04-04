module types

pub struct Module {
pub mut:
	name      string
	functions map[string]string
}

pub type Modules = map[string]Module
