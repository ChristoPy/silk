import { describe, it, expect } from "vitest";
import Parser from "../src/compiler/parser";

describe("Syntax", () => {
    it("should break if missing function name", () => {
        const parser = new Parser();
        expect(() => parser.parse("function")).toThrow();
    });
    it("should break if missing function opening parenthesis", () => {
        const parser = new Parser();
        expect(() => parser.parse("function add")).toThrow();
    });
    it("should break if missing function closing parenthesis", () => {
        const parser = new Parser();
        expect(() => parser.parse("function add(")).toThrow();
    });
    it("should break if missing function opening curly brace", () => {
        const parser = new Parser();
        expect(() => parser.parse("function add()")).toThrow();
    });
    it("should break if missing function closing curly brace", () => {
        const parser = new Parser();
        expect(() => parser.parse("function add() {")).toThrow();
    });
})

describe("Empty Function Declaration", () => {
    it("should break if trailing comma", () => {
        const parser = new Parser();
        expect(() => parser.parse("function add(a,) {}")).toThrow();
    });
    it("should parse an empty function declaration", () => {
        const parser = new Parser();
        const ast = parser.parse("function add() {}");
        expect(ast).toEqual({
            type: "Program",
            body: [
                {
                    line: 1,
                    type: "FunctionDeclaration",
                    value: {
                        name: "add",
                        params: [],
                        body: [],
                    },
                },
            ],
        });
    });
});

describe("Function Declaration with Declarations", () => {
    it("should parse a function declaration with declarations", () => {
        const parser = new Parser();
        const ast = parser.parse(`function add() {
            let x = 1

            function nested() {
                let y = 2
            }
        }`);
        expect(ast).toEqual({
            type: "Program",
            body: [
                {
                    line: 1,
                    type: "FunctionDeclaration",
                    value: {
                        name: "add",
                        params: [],
                        body: [
                            {
                                line: 2,
                                type: "VariableDeclaration",
                                value: {
                                    name: "x",
                                    value: {
                                        line: 2,
                                        type: "NumberLiteral",
                                        value: 1,
                                    },
                                },
                            },
                            {
                                line: 4,
                                type: "FunctionDeclaration",
                                value: {
                                    name: "nested",
                                    params: [],
                                    body: [
                                        {
                                            line: 5,
                                            type: "VariableDeclaration",
                                            value: {
                                                name: "y",
                                                value: {
                                                    line: 5,
                                                    type: "NumberLiteral",
                                                    value: 2,
                                                },
                                            },
                                        },
                                    ],
                                },
                            },
                        ],
                    },
                },
            ],
        });
    });
});

describe("Function Declaration with parameters", () => {
    it("should parse a function declaration with one parameter", () => {
        const parser = new Parser();
        const ast = parser.parse("function add(x) {}");
        expect(ast).toEqual({
            type: "Program",
            body: [
                {
                    line: 1,
                    type: "FunctionDeclaration",
                    value: {
                        name: "add",
                        params: [
                            {
                                line: 1,
                                type: "Identifier",
                                value: "x",
                            },
                        ],
                        body: [],
                    },
                },
            ],
        });
    });
    it("should parse a function declaration with multiple parameters", () => {
        const parser = new Parser();
        const ast = parser.parse("function add(x, y) {}");
        expect(ast).toEqual({
            type: "Program",
            body: [
                {
                    line: 1,
                    type: "FunctionDeclaration",
                    value: {
                        name: "add",
                        params: [
                            {
                                line: 1,
                                type: "Identifier",
                                value: "x",
                            },
                            {
                                line: 1,
                                type: "Identifier",
                                value: "y",
                            },
                        ],
                        body: [],
                    },
                },
            ],
        });
    });
})

describe("Function Declaration return statements", () => {
    it("should parse one return statement", () => {
        const parser = new Parser();
        const ast = parser.parse("function add() { return 1 }");
        expect(ast).toEqual({
            type: "Program",
            body: [
                {
                    line: 1,
                    type: "FunctionDeclaration",
                    value: {
                        name: "add",
                        params: [],
                        body: [
                            {
                                line: 1,
                                type: "ReturnStatement",
                                value: {
                                    line: 1,
                                    type: "NumberLiteral",
                                    value: 1,
                                },
                            },
                        ],
                    },
                },
            ],
        });
    });
    it("should parse multiple return statements", () => {
        const parser = new Parser();
        const ast = parser.parse("function add() { return 1 return 2 return 3 }");
        expect(ast).toEqual({
            type: "Program",
            body: [
                {
                    line: 1,
                    type: "FunctionDeclaration",
                    value: {
                        name: "add",
                        params: [],
                        body: [
                            {
                                line: 1,
                                type: "ReturnStatement",
                                value: {
                                    line: 1,
                                    type: "NumberLiteral",
                                    value: 1,
                                },
                            },
                            {
                                line: 1,
                                type: "ReturnStatement",
                                value: {
                                    line: 1,
                                    type: "NumberLiteral",
                                    value: 2,
                                },
                            },
                            {
                                line: 1,
                                type: "ReturnStatement",
                                value: {
                                    line: 1,
                                    type: "NumberLiteral",
                                    value: 3,
                                },
                            },
                        ],
                    },
                },
            ],
        });
    });
    it("should parse a return statement with all possible value types", () => {
        const parser = new Parser();
        const ast = parser.parse(`function add() { return 1 return "hello" return true return false return name return hello() return hello(1) }`);
        expect(ast).toEqual({
            type: "Program",
            body: [
                {
                    line: 1,
                    type: "FunctionDeclaration",
                    value: {
                        name: "add",
                        params: [],
                        body: [
                            {
                                line: 1,
                                type: "ReturnStatement",
                                value: {
                                    line: 1,
                                    type: "NumberLiteral",
                                    value: 1,
                                },
                            },
                            {
                                line: 1,
                                type: "ReturnStatement",
                                value: {
                                    line: 1,
                                    type: "StringLiteral",
                                    value: "hello",
                                },
                            },
                            {
                                line: 1,
                                type: "ReturnStatement",
                                value: {
                                    line: 1,
                                    type: "BooleanLiteral",
                                    value: true,
                                },
                            },
                            {
                                line: 1,
                                type: "ReturnStatement",
                                value: {
                                    line: 1,
                                    type: "BooleanLiteral",
                                    value: false,
                                },
                            },
                            {
                                line: 1,
                                type: "ReturnStatement",
                                value: {
                                    line: 1,
                                    type: "Identifier",
                                    value: "name",
                                },
                            },
                            {
                                line: 1,
                                type: "ReturnStatement",
                                value: {
                                    line: 1,
                                    type: "FunctionCall",
                                    value: {
                                        name: "hello",
                                        params: []
                                    },
                                },
                            },
                            {
                                line: 1,
                                type: "ReturnStatement",
                                value: {
                                    line: 1,
                                    type: "FunctionCall",
                                    value: {
                                        name: "hello",
                                        params: [
                                            {
                                                line: 1,
                                                type: "NumberLiteral",
                                                value: 1
                                            }
                                        ]
                                    },
                                },
                            },
                        ],
                    },
                },
            ],
        });
    });
});
