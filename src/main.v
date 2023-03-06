module main

import cli { Command }
import term
import os
import src.compiler { Compiler }

fn main() {
	mut command := Command{
		name: 'silk'
		description: 'The smooth JavaScript subset.'
		version: '0.0.1'
	}
	mut command_new := Command{
		name: 'new'
		description: 'Creates a new Silk project.'
		usage: '<name>'
		required_args: 1
		execute: make_project
	}
	mut command_build := Command{
		name: 'build'
		description: 'Build project inside its folder.'
		execute: build_project
	}
	command.add_command(command_new)
	command.add_command(command_build)
	command.setup()
	command.parse(os.args)
}

fn make_project(command Command) ! {
	name := command.args[0]

	os.mkdir(name) or {
		println(term.warn_message('Could not make project folder: ${err}'))
		return
	}

	os.write_file('${name}/main.silk', 'import IO from "silk/io"\n\nfunction main() {\n  IO.print("Hello, from Silk!")\n}\n') or {
		println(term.warn_message('Could not write project files: ${err}'))
		return
	}
	println(term.ok_message('Project ${term.bold(name)} created successfuly!'))
}

fn build_project(command Command) ! {
	file_content := os.read_file('main.silk') or {
		println(term.warn_message('Could not read main.silk: ${err}'))
		return
	}

	mut state := Compiler{}
	ast := state.compile('main.silk', file_content)

	println(ast)
}
