import { describe, it, expect } from "vitest";
import Parser from "../src/parser";

describe("Empty Function Declaration", () => {
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
        const ast = parser.parse("function add() { let x = 1 }");
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
                        ],
                    },
                },
            ],
        });
    });
});
