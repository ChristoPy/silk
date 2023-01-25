import { describe, it, expect } from "vitest";
import Parser from "../src/parser";

describe("Function Call", () => {
    it("should break if trailing comma", () => {
        const parser = new Parser();
        expect(() => parser.parse("add(1,)")).toThrow();
    });
    it("should parse a function call with no arguments", () => {
        const parser = new Parser();
        const ast = parser.parse("add()");
        expect(ast).toEqual({
            type: "Program",
            body: [
                {
                    type: "FunctionCall",
                    value: {
                        name: "add",
                        params: [],
                    },
                },
            ],
        });
    });
    it("should parse a function call with one argument", () => {
        const parser = new Parser();
        const ast = parser.parse("add(1)");
        expect(ast).toEqual({
            type: "Program",
            body: [
                {
                    type: "FunctionCall",
                    value: {
                        name: "add",
                        params: [
                            {
                                type: "NumberLiteral",
                                value: 1,
                            },
                        ],
                    },
                },
            ],
        });
    });
    it("should parse a function call with multiple arguments", () => {
        const parser = new Parser();
        const ast = parser.parse("add(1, 2, 3)");
        expect(ast).toEqual({
            type: "Program",
            body: [
                {
                    type: "FunctionCall",
                    value: {
                        name: "add",
                        params: [
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
            ],
        });
    });
    it("should support any literal or identifier as a parameter", () => {
        const parser = new Parser();
        const ast = parser.parse(`add(1, "a", true, false, identifier)`);
        expect(ast).toEqual({
            type: "Program",
            body: [
                {
                    type: "FunctionCall",
                    value: {
                        name: "add",
                        params: [
                            {
                                type: "NumberLiteral",
                                value: 1,
                            },
                            {
                                type: "StringLiteral",
                                value: "a",
                            },
                            {
                                type: "BooleanLiteral",
                                value: true,
                            },
                            {
                                type: "BooleanLiteral",
                                value: false,
                            },
                            {
                                type: "Identifier",
                                value: "identifier",
                            },
                        ],
                    },
                },
            ],
        });
    });
    it("should support function calls as parameters", () => {
        const parser = new Parser();
        const ast = parser.parse(`add(1, add(2, 3))`);
        expect(ast).toEqual({
            type: "Program",
            body: [
                {
                    type: "FunctionCall",
                    value: {
                        name: "add",
                        params: [
                            {
                                type: "NumberLiteral",
                                value: 1,
                            },
                            {
                                type: "FunctionCall",
                                value: {
                                    name: "add",
                                    params: [
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
                        ],
                    },
                },
            ],
        });
    });
});