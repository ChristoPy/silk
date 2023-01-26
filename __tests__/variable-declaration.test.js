import { describe, it, expect } from "vitest";
import Parser from "../src/parser";

describe("Literals", () => {
    it("should parse a literal number", () => {
        const parser = new Parser();
        const ast = parser.parse("let a = 1");
        expect(ast).toEqual({
            type: "Program",
            body: [
                {
                    type: "VariableDeclaration",
                    value: {
                        name: "a",
                        value: {
                            type: "NumberLiteral",
                            value: 1,
                        },
                    },
                },
            ],
        });
    });
    it("should parse a literal string", () => {
        const parser = new Parser();
        const ast = parser.parse('let a = "Hello, World!"');
        expect(ast).toEqual({
            type: "Program",
            body: [
                {
                    type: "VariableDeclaration",
                    value: {
                        name: "a",
                        value: {
                            type: "StringLiteral",
                            value: "Hello, World!",
                        },
                    },
                },
            ],
        });
    });
    it("should parse a literal boolean (true)", () => {
        const parser = new Parser();
        const ast = parser.parse("let a = true");
        expect(ast).toEqual({
            type: "Program",
            body: [
                {
                    type: "VariableDeclaration",
                    value: {
                        name: "a",
                        value: {
                            type: "BooleanLiteral",
                            value: true,
                        },
                    },
                },
            ],
        });
    });
    it("should parse a literal boolean (false)", () => {
        const parser = new Parser();
        const ast = parser.parse("let a = false");
        expect(ast).toEqual({
            type: "Program",
            body: [
                {
                    type: "VariableDeclaration",
                    value: {
                        name: "a",
                        value: {
                            type: "BooleanLiteral",
                            value: false,
                        },
                    },
                },
            ],
        });
    });
    it("should parse a literal array", () => {
        const parser = new Parser();
        const ast = parser.parse("let a = [1, 2, 3]");
        expect(ast).toEqual({
            type: "Program",
            body: [
                {
                    type: "VariableDeclaration",
                    value: {
                        name: "a",
                        value: {
                            type: "ArrayLiteral",
                            value: [
                                {
                                    type: "NumberLiteral",
                                    value: 1,
                                },
                                {
                                    type: "NumberLiteral",
                                    value: 2,
                                },
                                {
                                    type: "NumberLiteral",
                                    value: 3,
                                },
                            ],
                        },
                    },
                },
            ],
        });
    });
    it("should parse a literal object", () => {
        const parser = new Parser();
        const ast = parser.parse('let a = {b: 1, c: true, d: "Hello, World!", e: [1, 2, 3], f: {g: 1, h: 2}}');
        expect(ast).toEqual({
            type: "Program",
            body: [
                {
                    type: "VariableDeclaration",
                    value: {
                        name: "a",
                        value: {
                            type: "ObjectLiteral",
                            value: [
                                {
                                    key: "b",
                                    value: {
                                        type: "NumberLiteral",
                                        value: 1,
                                    },
                                },
                                {
                                    key: "c",
                                    value: {
                                        type: "BooleanLiteral",
                                        value: true,
                                    },
                                },
                                {
                                    key: "d",
                                    value: {
                                        type: "StringLiteral",
                                        value: "Hello, World!",
                                    },
                                },
                                {
                                    key: "e",
                                    value: {
                                        type: "ArrayLiteral",
                                        value: [
                                            {
                                                type: "NumberLiteral",
                                                value: 1,
                                            },
                                            {
                                                type: "NumberLiteral",
                                                value: 2,
                                            },
                                            {
                                                type: "NumberLiteral",
                                                value: 3,
                                            },
                                        ],
                                    },
                                },
                                {
                                    key: "f",
                                    value: {
                                        type: "ObjectLiteral",
                                        value: [
                                            {
                                                key: "g",
                                                value: {
                                                    type: "NumberLiteral",
                                                    value: 1,
                                                },
                                            },
                                            {

                                                key: "h",
                                                value: {
                                                    type: "NumberLiteral",
                                                    value: 2,
                                                },
                                            },
                                        ],
                                    },
                                },
                            ],
                        },
                    },
                },
            ],
        });
    });
});

describe("Identifers", () => {
    it("should parse an identifier", () => {
        const parser = new Parser();
        const ast = parser.parse("let a = b");
        expect(ast).toEqual({
            type: "Program",
            body: [
                {
                    type: "VariableDeclaration",
                    value: {
                        name: "a",
                        value: {
                            type: "Identifier",
                            value: "b",
                        },
                    },
                },
            ],
        });
    });
});

describe("Function call", () => {
    it("should parse a function call", () => {
        const parser = new Parser();
        const ast = parser.parse("let a = b()");
        expect(ast).toEqual({
            type: "Program",
            body: [
                {
                    type: "VariableDeclaration",
                    value: {
                        name: "a",
                        value: {
                            type: "FunctionCall",
                            value: {
                                name: "b",
                                params: [],
                            },
                        },
                    },
                },
            ],
        });
    });
});
