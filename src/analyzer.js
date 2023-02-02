import { throwError } from './utils.js';

function addIdentifier(identifiers, node, scope, context) {
    const { value, line } = node;

    if (identifiers[value.name]) {
        throwError('Syntax', 'identifierAlreadyDeclared', value.name, line, context);
    }
    identifiers[value.name] = { value: value.value, scope };
}
function throwIfNotFound(identifiers, name, line, context) {
    if (!identifiers[name]) {
        throwError('Syntax', 'identifierNotDeclared', name, line, context);
    }
}

export default function Analyzer(ast) {
    const identifiers = {}

    for (const node of ast.body) {
        if (node.type === "ImportStatement") {
            addIdentifier(identifiers, node, "external", "import");
        }
        if (node.type === "VariableDeclaration") {
            const value = node.value.value;
            if (value.type === "Identifier") {
                throwIfNotFound(identifiers, value.value, node.line, "letValueDoesNotExist");
            }
            addIdentifier(identifiers, node, "program", "let");
        }
        if (node.type === "FunctionDeclaration") {
            addIdentifier(identifiers, node, "program", "function");
        }
    }

    return { identifiers }
};
