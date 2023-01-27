const ERRORS = {
    unexpectedToken: 'I was not expecting this.',
    unexpectedEndOfInput: 'The program ended unexpectedly.',
};
const REASONS = {
    literal: 'Expected: String, Number, Boolean, Array, Object, Function',
    statement: 'Expected: Import, Let, Function',
    expressionValue: 'Expected: String, Number, Boolean, Array, Object, Function',
    scopedStatement: 'Expected: Let, Function, Return',
    danglingComma: 'Cannot have a dangling comma.',
}

const formatError = (type, id, wrongBit, line, context) => {
    let header = `  ┌─ error: ${type}Error\n`;
    let message = `${line} │  ${wrongBit}\n  │  ${'^'.repeat(wrongBit.length || 1)} ${ERRORS[id]}\n`;
    let footer = '';

    if (context) {
        footer = REASONS[context];
    }

    return header + message + footer;
};

export const throwError = (type, id, wrongBit, line, context) => {
    const message = formatError(type, id, wrongBit, line, context);

    console.warn(message);
    process.exit(1);
};
