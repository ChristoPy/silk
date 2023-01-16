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