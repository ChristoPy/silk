import { describe, it, expect } from "vitest";
import Parser from "../src/parser";

describe("import statement", () => {
    it("should parse import statement", () => {
        const parser = new Parser();
        const ast = parser.parse(`import vitest from "vitest"`);
        expect(ast).toEqual({
            type: "Program",
            body: [
                {
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
