import { describe, it, expect } from "vitest";
import Parser from "../src/parser";

describe("syntax", () => {
    it("should break if missing identifier", () => {
        const code = 'import';
        const parser = new Parser();
        expect(() => parser.parse(code)).toThrow();
    });
    it("should break if missing from", () => {
        const code = 'import vitest';
        const parser = new Parser();
        expect(() => parser.parse(code)).toThrow();
    });
    it("should break if missing path", () => {
        const code = 'import vitest from';
        const parser = new Parser();
        expect(() => parser.parse(code)).toThrow();
    });
});

describe("import statement", () => {
    it("should parse import statement", () => {
        const parser = new Parser();
        const ast = parser.parse(`import vitest from "vitest"`);
        expect(ast).toEqual({
            type: "Program",
            body: [
                {
                    line: 1,
                    type: "ImportStatement",
                    value: {
                        name: "vitest",
                        path: "vitest",
                    },
                },
            ],
        });
    });
});
