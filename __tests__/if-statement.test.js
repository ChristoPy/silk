import { describe, it, expect } from "vitest";
import Parser from "../src/parser";

describe("If Syntax", () => {
    it("should break if outside of a function", () => {
        const code = `
            if (something) {
                return "Hello, world!"
            }
        `;

        const parser = new Parser();
        expect(() => parser.parse(code)).toThrow();
    });
    it("should break if missing open parenthesis", () => {
        const code = `
            function greet() {
                if something) {
                    return "Hello, world!"
                }
            }
        `;

        const parser = new Parser();
        expect(() => parser.parse(code)).toThrow();
    });
    it("should break if missing condition", () => {
        const code = `
            function greet() {
                if () {
                    return "Hello, world!"
                }
            }
        `;
        const parser = new Parser();
        expect(() => parser.parse(code)).toThrow();
    });
    it("should break if missing close parenthesis", () => {
        const code = `
            function greet() {
                if (something {
                    return "Hello, world!"
                }
            }
        `;

        const parser = new Parser();
        expect(() => parser.parse(code)).toThrow();
    });
    it("should break if missing open curly brace", () => {
        const code = `
            function greet() {
                if (something)
                    return "Hello, world!"
                }
            }
        `;

        const parser = new Parser();
        expect(() => parser.parse(code)).toThrow();
    });
    it("should break if missing close curly brace", () => {
        const code = `
            function greet() {
                if (something) {
                    return "Hello, world!"
            }
        `;

        const parser = new Parser();
        expect(() => parser.parse(code)).toThrow();
    });
});

describe("Else If Syntax", () => {
    it("should break if missing if condition aftwerwards", () => {
        const code = `
            function greet() {
                if (something) {
                    return "Hello, world!"
                } else
            }
        `;

        const parser = new Parser();
        expect(() => parser.parse(code)).toThrow();
    });
});

describe("AST", () => {
    it("should parse if statement", () => {
        const code = `
            function greet() {
                if (something) {
                    return "Hello, world!"
                }
            }
        `;

        const parser = new Parser();
        const ast = parser.parse(code);

        expect(ast).toEqual({
            type: "Program",
            body: [
                {
                    line: 2,
                    type: "FunctionDeclaration",
                    value: {
                        name: "greet",
                        params: [],
                        body: [
                            {
                                line: 3,
                                type: "IfStatement",
                                condition: {
                                    line: 3,
                                    type: "Identifier",
                                    value: "something",
                                },
                                body: [
                                    {
                                        line: 4,
                                        type: "ReturnStatement",
                                        value: {
                                            line: 4,
                                            type: "StringLiteral",
                                            value: "Hello, world!",
                                        },
                                    },
                                ],
                                fallback: null,
                            },
                        ],
                    },
                },
            ],
        });
    });
    it("should parse if else statement", () => {
        const code = `
            function greet() {
                if (something) {
                    return "Hello, world!"
                } else if (something) {
                    return "Hello, visitor!"
                }
            }
        `;

        const parser = new Parser();
        const ast = parser.parse(code);

        expect(ast).toEqual({
            type: "Program",
            body: [
                {
                    line: 2,
                    type: "FunctionDeclaration",
                    value: {
                        name: "greet",
                        params: [],
                        body: [
                            {
                                line: 3,
                                type: "IfStatement",
                                condition: {
                                    line: 3,
                                    type: "Identifier",
                                    value: "something",
                                },
                                body: [
                                    {
                                        line: 4,
                                        type: "ReturnStatement",
                                        value: {
                                            line: 4,
                                            type: "StringLiteral",
                                            value: "Hello, world!",
                                        },
                                    },
                                ],
                                fallback: {
                                    line: 5,
                                    type: "IfStatement",
                                    condition: {
                                        line: 5,
                                        type: "Identifier",
                                        value: "something",
                                    },
                                    body: [
                                        {
                                            line: 6,
                                            type: "ReturnStatement",
                                            value: {
                                                line: 6,
                                                type: "StringLiteral",
                                                value: "Hello, visitor!",
                                            },
                                        },
                                    ],
                                    fallback: null,
                                },
                            },
                        ],
                    },
                },
            ],
        });
    });
});
