import Parser from './parser.js';

export default function compile(program) {
    const parser = new Parser();

    try {
        parser.parse(program);
    } catch (error) {
        console.warn(error.message);
        process.exit(1);
    }

    return program;
};