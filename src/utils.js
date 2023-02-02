const ERRORS = {
    unexpectedToken: 'I was not expecting this.',
    unexpectedEndOfInput: 'The program ended unexpectedly.',
    identifierAlreadyDeclared: 'This identifier has already been declared.',
};
const REASONS = {
    literal: 'Expected: String, Number, Boolean, Array, Object or Function',
    statement: 'Expected: Import, Let or Function',
    expressionValue: 'Expected: Name, String, Number, Boolean, Array, Object or Function',
    scopedStatement: 'Expected: Name, Let, Function or Return',
    danglingComma: 'Cannot have a dangling comma.',
    conditionValue: 'Expected: Name or Function',
    import: 'You can\'t import with this name. It has already been declared.',
    let: 'You can\'t declare a variable with this name. It has already been declared.',
    letValueDoesNotExist: 'You can\'t use this variable as value. It does not exist.',
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

    throw new Error(message);
};
