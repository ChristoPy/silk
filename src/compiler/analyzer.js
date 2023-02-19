import { throwError } from './utils.js';

const EMPTY = () => ({
    program: {},
});
let identifiers = EMPTY();

function addIdentifier(scope, name, node, context) {
    if (!identifiers[scope]) {
        identifiers[scope] = {};
    }
    const identifier = identifiers[scope][name];
    if (identifier) {
        identifiers = EMPTY();
        throwError('Syntax', 'identifierAlreadyDeclared', name, node.line, context);
    }

    identifiers[scope][name] = { value: node };
}
function throwIfNotFound(scope, name, node, context) {
    let notFound = false;
    const isNestedScope = scope.includes(".");

    notFound = identifiers[scope][name] ? false : true;
    if (isNestedScope && notFound) {
        notFound = identifiers.program[name] ? false : true;
    }

    if (notFound) {
        identifiers = EMPTY();
        throwError('Syntax', 'identifierNotDeclared', name, node.line, context);
    }
}

function traverse(scope, node) {
    if (node.type === "ImportStatement") {
        if (/^[A-Z][a-z]+(?:[A-Z][a-z]+)*$/.test(node.value.name)) {
            addIdentifier(scope, node.value.name, node, "import");
            return
        }
        identifiers = EMPTY();
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
        // make params available in the function scope
        node.value.params.forEach((value) => {
            addIdentifier(`function.${node.value.name}`, value.value, "functionParam");
        });
        // make the function body available in the function scope
        traverse(`function.${node.value.name}`, node.value);
    }

    // assuming the first node is the root node
    if (node.body && node.type !== "FunctionDeclaration") {
        // keep the same scope until the validation bubbles to the previous scope
        node.body.forEach(childNode => traverse(scope, childNode));
    }
}

export default function Analyzer(ast) {
    traverse("program", ast);
};
