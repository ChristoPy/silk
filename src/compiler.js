import Parser from './parser.js';

export default function compile(program) {
    const parser = new Parser();
    parser.parse(program);

    return program;
};