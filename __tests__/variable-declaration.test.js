import { describe, it, expect } from "vitest";
import Parser from "../src/parser";

describe("Syntax errors", () => {
    it("should throw an error if variable declaration is missing an identifier", () => {
        const parser = new Parser();
        expect(() => parser.parse("let")).toThrow();
    });
    it("should throw an error if variable declaration is missing an assignment operator", () => {
        const parser = new Parser();
        expect(() => parser.parse("let a")).toThrow();
    });
    it("should throw an error if variable declaration is missing an assignment value", () => {
        const parser = new Parser();
        expect(() => parser.parse("let a =")).toThrow();
    });
});

describe("Literals", () => {
    it("should parse a literal number", () => {
        const parser = new Parser();
        const ast = parser.parse("let a = 1");
        expect(ast).toEqual({
            type: "Program",
            body: [
                {
                    line: 1,
                    type: "VariableDeclaration",
                    value: {
                        name: "a",
                        value: {
                            line: 1,
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
                    line: 1,
                    type: "VariableDeclaration",
                    value: {
                        name: "a",
                        value: {
                            line: 1,
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
                    line: 1,
                    type: "VariableDeclaration",
                    value: {
                        name: "a",
                        value: {
                            line: 1,
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
                    line: 1,
                    type: "VariableDeclaration",
                    value: {
                        name: "a",
                        value: {
                            line: 1,
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
                    line: 1,
                    type: "VariableDeclaration",
                    value: {
                        name: "a",
                        value: {
                            line: 1,
                            type: "ArrayLiteral",
                            value: [
                                {
                                    line: 1,
                                    type: "NumberLiteral",
                                    value: 1,
                                },
                                {
                                    line: 1,
                                    type: "NumberLiteral",
                                    value: 2,
                                },
                                {
                                    line: 1,
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
                    line: 1,
                    type: "VariableDeclaration",
                    value: {
                        name: "a",
                        value: {
                            type: "ObjectLiteral",
                            line: 1,
                            value: [
                                {
                                    key: "b",
                                    line: 1,
                                    value: {
                                        line: 1,
                                        type: "NumberLiteral",
                                        value: 1,
                                    },
                                },
                                {
                                    key: "c",
                                    line: 1,
                                    value: {
                                        line: 1,
                                        type: "BooleanLiteral",
                                        value: true,
                                    },
                                },
                                {
                                    key: "d",
                                    line: 1,
                                    value: {
                                        line: 1,
                                        type: "StringLiteral",
                                        value: "Hello, World!",
                                    },
                                },
                                {
                                    key: "e",
                                    line: 1,
                                    value: {
                                        line: 1,
                                        type: "ArrayLiteral",
                                        value: [
                                            {
                                                line: 1,
                                                type: "NumberLiteral",
                                                value: 1,
                                            },
                                            {
                                                line: 1,
                                                type: "NumberLiteral",
                                                value: 2,
                                            },
                                            {
                                                line: 1,
                                                type: "NumberLiteral",
                                                value: 3,
                                            },
                                        ],
                                    },
                                },
                                {
                                    key: "f",
                                    line: 1,
                                    value: {
                                        line: 1,
                                        type: "ObjectLiteral",
                                        value: [
                                            {
                                                line: 1,
                                                key: "g",
                                                value: {
                                                    line: 1,
                                                    type: "NumberLiteral",
                                                    value: 1,
                                                },
                                            },
                                            {
                                                line: 1,
                                                key: "h",
                                                value: {
                                                    line: 1,
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
                    line: 1,
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

// describe("Function call", () => {
//     it("should parse a function call", () => {
//         const parser = new Parser();
//         const ast = parser.parse("let a = b()");
//         expect(ast).toEqual({
//             type: "Program",
//             body: [
//                 {
//                     type: "VariableDeclaration",
//                     value: {
//                         name: "a",
//                         value: {
//                             type: "FunctionCall",
//                             value: {
//                                 name: "b",
//                                 params: [],
//                             },
//                         },
//                     },
//                 },
//             ],
//         });
//     });
// });
