import Parser from './parser.js';
import Analyzer from './analyzer.js';

export default function compile(program) {
    const parser = new Parser();

    try {
        Analyzer(parser.parse(program));
    } catch (error) {
        console.warn(error.message);
        process.exit(1);
    }

    return program;
};