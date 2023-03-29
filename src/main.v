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

fn get_project_files() []string {
	files_on_disk := os.ls('.') or {
		println(term.warn_message('Could not read project files: ${err}'))
		return []
	}

	mut files := []string{}
	for file in files_on_disk {
		if file.ends_with('.silk') {
			files << file
		}
	}
	return files
}

fn prepare_build_folder() ! {
	if os.exists('.build') {
		old_files := os.ls('.build') or {
			println(term.warn_message('Could not read build folder: ${err}'))
			return
		}
		for file in old_files {
			os.rm('.build/${file}') or {
				println(term.warn_message('Could not remove build file: ${err}'))
				return
			}
		}
	} else {
		os.mkdir('.build') or {
			println(term.warn_message('Could not make build folder: ${err}'))
			return
		}
	}
}

fn build_project(command Command) ! {
	files := get_project_files()

	if files.len == 0 {
		println(term.warn_message('No .silk files found in project folder.'))
		return
	}

	prepare_build_folder() or { return }

	mut state := Compiler{}
	for file in files {
		file_content := os.read_file(file) or {
			println(term.warn_message('Could not read main.silk: ${err}'))
			return
		}
		state.parse(file, file_content)

		name := file.split('.')[0]
		os.write_file('.build/${name}.js', state.generate_js()) or {
			println(term.warn_message('Could not write build file: ${err}'))
			return
		}
	}

	println(term.ok_message('Project built successfuly!'))
}
