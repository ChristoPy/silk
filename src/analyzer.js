import { throwError } from './utils.js';

let identifiers = {};

function addIdentifier(scope, name, node, context) {
    if (identifiers[name]) {
        identifiers = {};
        throwError('Syntax', 'identifierAlreadyDeclared', name, node.line, context);
    }

    identifiers[name] = { value: node, scope };
}
function throwIfNotFound(scope, name, node, context) {
    if (!identifiers[name]) {
        identifiers = {};
        throwError('Syntax', 'identifierNotDeclared', name, node.line, context);
    }
}

function traverse(scope, node) {
    if (node.type === "ImportStatement") {
        if (/^[A-Z][a-z]+(?:[A-Z][a-z]+)*$/.test(node.value.name)) {
            addIdentifier(scope, node.value.name, node, "import");
            return
        }
        identifiers = {};
        throwError('Syntax', 'unexpectedToken', node.value.name, node.line, "importNameMustBePascalCase");
    }
    if (node.type === "VariableDeclaration") {
        const reference = node.value.value;
        if (reference.type === "Identifier") {
            throwIfNotFound(scope, reference.value, node, "letValueDoesNotExist");
        }
        if (reference.type === "FunctionCall") {
            throwIfNotFound(scope, reference.value, node, "functionNameDoesNotExist");
        }
        addIdentifier(scope, node.value.name, node, "let");
    }
    if (node.type === "FunctionCall") {
        throwIfNotFound(scope, node.value.name, node, "functionNameDoesNotExist");
        const { params } = node.value
        params.forEach(param => {
            if (param.type === "Identifier") {
                throwIfNotFound(scope, param.value, node, "functionParamDoesNotExist");
            }
        });
    }
    if (node.type === "FunctionDeclaration") {
        addIdentifier(scope, node.value.name, node, "function");
    }

    // assuming the first node is the root node
    if (node.body) {
        // keep the same scope until the validation bubbles to the previous scope
        node.body.forEach(childNode => traverse(scope, childNode));
    }
}

export default function Analyzer(ast) {
    traverse("program", ast);
};
