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
                        name: {
                            type: "Identifier",
                            value: "a",
                        },
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
                        name: {
                            type: "Identifier",
                            value: "a",
                        },
                        value: {
                            type: "StringLiteral",
                            value: "Hello, World!",
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
                        name: {
                            type: "Identifier",
                            value: "a",
                        },
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

