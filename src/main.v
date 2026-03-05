module main

import cli { Command }
import term
import os
import compiler { Compiler }

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
		description: 'Build a Silk project from a folder.'
		usage: '[path]'
		execute: build_project
	}
	command.add_command(command_new)
	command.add_command(command_build)
	command.setup()
	command.parse(os.args)
}

fn make_project(command Command) ! {
	project_root := os.getwd()
	name := command.args[0]
	project_dir := os.join_path(project_root, name)

	os.mkdir(project_dir) or {
		println(term.warn_message('Could not make project folder: ${err}'))
		return
	}

	main_path := os.join_path(project_dir, 'main.silk')
	os.write_file(main_path, 'import IO from "std/io"\n\nfunction main() {\n  IO.print("Hello, from Silk!")\n}\n') or {
		println(term.warn_message('Could not write project files: ${err}'))
		return
	}
	println(term.ok_message('Project ${term.bold(name)} created successfuly!'))
}

fn get_project_files(project_root string) []string {
	files_on_disk := os.ls(project_root) or {
		println(term.warn_message('Could not read project folder: ${err}'))
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

fn get_silk_std_path(project_root string) string {
	root := os.getenv('SILK_ROOT')
	if root != '' {
		p := os.join_path(root, 'src', 'std')
		if os.exists(p) {
			return p
		}
	}
	parent_std := os.join_path(project_root, '..', 'src', 'std')
	if os.exists(parent_std) {
		return os.real_path(parent_std)
	}
	executable_path := os.executable()
	executable_dir := os.dir(executable_path)
	executable_std := os.join_path(executable_dir, '..', 'src', 'std')
	if os.exists(executable_std) {
		return os.real_path(executable_std)
	}
	return ''
}

fn prepare_build_folder(project_root string) ! {
	dist_path := os.join_path(project_root, 'dist')
	if os.exists(dist_path) {
		os.rmdir_all(dist_path) or {
			println(term.warn_message('Could not clear build folder: ${err}'))
			return
		}
	}
	os.mkdir(dist_path) or {
		println(term.warn_message('Could not make build folder: ${err}'))
		return
	}
	std_path := get_silk_std_path(project_root)
	if std_path == '' {
		println(term.warn_message('Could not find Silk standard library. Set SILK_ROOT to the Silk repo root, or run build from a project inside the repo.'))
		return
	}
	dist_std := os.join_path(dist_path, 'std')
	os.cp_all(std_path, dist_std, true) or {
		println(term.warn_message('Could not copy standard library: ${err}'))
		return
	}
}

fn build_project(command Command) ! {
	// Determine project root: either an explicit path argument or the current directory.
	mut project_root := os.getwd()
	if command.args.len > 0 {
		provided := command.args[0]
		if !os.exists(provided) || !os.is_dir(provided) {
			println(term.warn_message('Provided path is not a project folder: ${provided}'))
			return
		}
		project_root = os.real_path(provided)
	}
	files := get_project_files(project_root)

	if files.len == 0 {
		println(term.warn_message('No .silk files found in current folder.'))
		return
	}

	prepare_build_folder(project_root) or { return }

	dist_path := os.join_path(project_root, 'dist')
	mut state := Compiler{}
	for file in files {
		file_path := os.join_path(project_root, file)
		file_content := os.read_file(file_path) or {
			println(term.warn_message('Could not read file ${file}: ${err}'))
			return
		}
		state.parse(file, file_content)

		name := file.split('.')[0]
		output_path := os.join_path(dist_path, '${name}.js')
		os.write_file(output_path, state.generate_js()) or {
			println(term.warn_message('Could not write output file ${output_path}: ${err}'))
			return
		}
	}

	println(term.ok_message('Project built successfuly!'))
}
