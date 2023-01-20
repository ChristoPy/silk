import { describe, it, expect } from "vitest";
import Parser from "../src/parser";

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
                    type: "FunctionDeclaration",
                    value: {
                        name: "add",
                        params: [],
                        body: [
                            {
                                type: "VariableDeclaration",
                                value: {
                                    name: {
                                        type: "Identifier",
                                        value: "x",
                                    },
                                    value: {
                                        type: "NumberLiteral",
                                        value: 1,
                                    },
                                },
                            },
                            {
                                type: "FunctionDeclaration",
                                value: {
                                    name: "nested",
                                    params: [],
                                    body: [
                                        {
                                            type: "VariableDeclaration",
                                            value: {
                                                name: {
                                                    type: "Identifier",
                                                    value: "y",
                                                },
                                                value: {
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
                    type: "FunctionDeclaration",
                    value: {
                        name: "add",
                        params: [
                            {
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
                    type: "FunctionDeclaration",
                    value: {
                        name: "add",
                        params: [
                            {
                                type: "Identifier",
                                value: "x",
                            },
                            {
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
                    type: "FunctionDeclaration",
                    value: {
                        name: "add",
                        params: [],
                        body: [
                            {
                                type: "ReturnStatement",
                                value: {
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
                    type: "FunctionDeclaration",
                    value: {
                        name: "add",
                        params: [],
                        body: [
                            {
                                type: "ReturnStatement",
                                value: {
                                    type: "NumberLiteral",
                                    value: 1,
                                },
                            },
                            {
                                type: "ReturnStatement",
                                value: {
                                    type: "NumberLiteral",
                                    value: 2,
                                },
                            },
                            {
                                type: "ReturnStatement",
                                value: {
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
        const ast = parser.parse(`function add() { return 1 return "hello" return true return false return name }`);
        expect(ast).toEqual({
            type: "Program",
            body: [
                {
                    type: "FunctionDeclaration",
                    value: {
                        name: "add",
                        params: [],
                        body: [
                            {
                                type: "ReturnStatement",
                                value: {
                                    type: "NumberLiteral",
                                    value: 1,
                                },
                            },
                            {
                                type: "ReturnStatement",
                                value: {
                                    type: "StringLiteral",
                                    value: "hello",
                                },
                            },
                            {
                                type: "ReturnStatement",
                                value: {
                                    type: "BooleanLiteral",
                                    value: true,
                                },
                            },
                            {
                                type: "ReturnStatement",
                                value: {
                                    type: "BooleanLiteral",
                                    value: false,
                                },
                            },
                            {
                                type: "ReturnStatement",
                                value: {
                                    type: "Identifier",
                                    value: "name",
                                },
                            },
                        ],
                    },
                },
            ],
        });
    });
});
