import { describe, it, expect } from "vitest";
import Parser from "../src/compiler/parser";

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
    it("should throw an error if variable value ends without the property to get accessed", () => {
        const parser = new Parser();
        expect(() => parser.parse("let a = b.")).toThrow();
    });
    it("should throw an error if variable value ends with accessing a property in a function call 1", () => {
        const parser = new Parser();
        expect(() => parser.parse("let a = b().")).toThrow();
    })
    it("should throw an error if variable value ends with accessing a property in a function call 1", () => {
        const parser = new Parser();
        expect(() => parser.parse("let a = b().c")).toThrow();
    })
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
                            line: 1,
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
                    line: 1,
                    type: "VariableDeclaration",
                    value: {
                        name: "a",
                        value: {
                            line: 1,
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


describe("Nested identifiers and function call", () => {
    it("should parse a nested identifier", () => {
        const parser = new Parser();
        const ast = parser.parse("let a = b.c");
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
                            type: "MemberExpression",
                            object: {
                                line: 1,
                                type: "Identifier",
                                value: "b",
                            },
                            property: {
                                line: 1,
                                type: "Identifier",
                                value: "c",
                            }
                        },
                    },
                },
            ],
        });
    });
    it("should parse a nested function call", () => {
        const parser = new Parser();
        const ast = parser.parse("let a = something.b()");
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
                            type: "MemberExpression",
                            object: {
                                line: 1,
                                type: "Identifier",
                                value: "something",
                            },
                            property: {
                                line: 1,
                                type: "FunctionCall",
                                value: {
                                    name: "b",
                                    params: [],
                                },
                            }
                        },
                    },
                },
            ],
        });
    });
    it("should parse multiple nested identifiers", () => {
        const parser = new Parser();
        const ast = parser.parse("let value = a.b.c.d.e.f");
        expect(ast).toEqual({
            type: "Program",
            body: [
                {
                    type: "VariableDeclaration",
                    line: 1,
                    value: {
                        name: "value",
                        value: {
                            type: "MemberExpression",
                            line: 1,
                            object: {
                                type: "Identifier",
                                value: "a",
                                line: 1
                            },
                            property: {
                                type: "MemberExpression",
                                line: 1,
                                object: {
                                    type: "Identifier",
                                    value: "b",
                                    line: 1
                                },
                                property: {
                                    type: "MemberExpression",
                                    line: 1,
                                    object: {
                                        type: "Identifier",
                                        value: "c",
                                        line: 1
                                    },
                                    property: {
                                        type: "MemberExpression",
                                        line: 1,
                                        object: {
                                            type: "Identifier",
                                            value: "d",
                                            line: 1
                                        },
                                        property: {
                                            type: "MemberExpression",
                                            line: 1,
                                            object: {
                                                type: "Identifier",
                                                value: "e",
                                                line: 1
                                            },
                                            property: {
                                                line: 1,
                                                type: "Identifier",
                                                value: "f"
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            ]
        });
    });
});