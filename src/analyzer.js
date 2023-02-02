import { throwError } from './utils.js';

const identifiers = {};

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

function traverse(scope, node) {
    if (node.type === "ImportStatement") {
        addIdentifier(identifiers, node, "external", "import");
    }
    if (node.type === "VariableDeclaration") {
        const value = node.value.value;
        if (value.type === "Identifier") {
            throwIfNotFound(identifiers, value.value, node.line, "letValueDoesNotExist");
        }
        addIdentifier(identifiers, node, scope, "let");
    }
    if (node.type === "FunctionCall") {
        throwIfNotFound(identifiers, node.value.name, node.line, "functionNameDoesNotExist");

        const { params } = node.value
        params.forEach(param => {
            if (param.type === "Identifier") {
                throwIfNotFound(identifiers, param.value, node.line, "functionParamDoesNotExist");
            }
        });
    }
    if (node.type === "FunctionDeclaration") {
        addIdentifier(identifiers, node, scope, "function");
    }

    // assuming the first node is the root node
    if (node.body) {
        node.body.forEach(childNode => traverse(scope, childNode));
    }
}

export default function Analyzer(ast) {
    traverse("program", ast);
};
