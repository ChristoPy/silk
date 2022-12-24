import { describe, it, expect } from "vitest";
import Parser from "../src/parser";

describe("Parser AST", () => {
    it("should have a root node with a body", () => {
        const parser = new Parser();
        const ast = parser.parse("");
        expect(ast).toEqual({
            type: "Program",
            body: [],
        });
    });
});
