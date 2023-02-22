import { throwError } from './utils.js';

const EMPTY = () => ({
    path: "program",
    scopes: {
        program: {},
    },
});

let state = EMPTY();

function addIdentifier(scope, name, node) {
    if (!state.scopes[scope]) {
        state.scopes[scope] = {};
    }
    state.scopes[scope][name] = node;
}
function throwIfFound(scope, name, node, context) {
    if (!state.scopes[scope]) return
    if (state.scopes[scope][name]) {
        state = EMPTY();
        throwError('Reference', 'identifierAlreadyDeclared', name, node.line, context);
    }
}
function throwIfNotFound(scope, name, node, context) {
    // when scope is program we don't need to check for nested scopes
    if (scope === "program") {
        if (!state.scopes[scope][name]) {
            state = EMPTY();
            throwError('Reference', 'identifierNotDeclared', name, node.line, context);
        }
    }
    // when a scope has a dot, it means it's a nested scope
    // we need to check the existence of the identifier in the nested scope
    // and the previous scope until we find it or it reaches the program scope again
    if (scope.includes(".")) {
        const [parentScope, nestedScope] = scope.split(".");
        if (!state.scopes[nestedScope][name]) {
            if (!state.scopes[parentScope][name]) {
                state = EMPTY();
                throwError('Reference', 'identifierNotDeclared', name, node.line, context);
            }
        }
    }
}
function functionCall(name, node, context) {
    throwIfNotFound(state.path, name, node, context || "functionNameDoesNotExist");
    node.value.params.forEach(param => {
        if (param.type === "Identifier") {
            throwIfNotFound(state.path, param.value, node, "functionParamDoesNotExist");
        }
    });
}

function traverse(scope, node) {
    if (node.type === "ImportStatement") {
        if (!/^[A-Z][a-z]+(?:[A-Z][a-z]+)*$/.test(node.value.name)) {
            state = EMPTY();
            throwError('Syntax', 'unexpectedToken', node.value.name, node.line, "importNameMustBePascalCase");
        }
        throwIfFound("program", node.value.name, node, "import");
        addIdentifier("program", node.value.name, node);
    }
    if (node.type === "VariableDeclaration") {
        const reference = node.value.value;
        if (reference.type === "Identifier") {
            throwIfNotFound(state.path, reference.value, node, "letValueDoesNotExist");
        }
        if (reference.type === "FunctionCall") {
            functionCall(reference.value.name, node.value.value, "letValueDoesNotExist");
        }
        throwIfFound(scope, node.value.name, node, "let");
        addIdentifier(scope, node.value.name, node);
    }
    if (node.type === "FunctionDeclaration") {
        throwIfFound(scope, node.value.name, node, "function");
        addIdentifier(scope, node.value.name, node);
        addIdentifier(`function_${node.value.name}`, node.value.name, node);
        node.value.params.forEach(param => {
            throwIfFound(`function_${node.value.name}`, param.value, node, "functionParamDoesNotExist");
            addIdentifier(`function_${node.value.name}`, param.value, node);
        });
        state.path = `program.function_${node.value.name}`;
        traverse(`function_${node.value.name}`, node.value);
        state.path = scope;
    }
    if (node.type === "FunctionCall") {
        functionCall(node.value.name, node)
    }
    if (node.type === "IfStatement") {
        let functionScope = state.path
        state.path += `.if_${node.line}`;
        const { condition } = node;
        if (condition.type === "Identifier") {
            throwIfNotFound(functionScope, condition.value, node, "ifConditionDoesNotExist");
        }
        if (condition.type === "FunctionCall") {
            functionCall(condition.value.name, condition, "ifConditionDoesNotExist");
        }

        traverse(state.path, node.body);
        if (node.fallback) {
            state.path += `.else_${node.line}`;
            traverse(state.path, node.fallback);
        }
    }

    // assuming the first node is the root node
    if (node.body && node.type !== "FunctionDeclaration") {
        // keep the same scope until the validation bubbles to the previous scope
        node.body.forEach(childNode => traverse(scope, childNode));
    }
}

export default function Analyzer(ast) {
    traverse("program", ast);
    state = EMPTY();
};
