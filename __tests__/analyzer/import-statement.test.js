import { describe, it, expect } from "vitest";
import Parser from "../../src/compiler/parser";
import Analyzer from "../../src/compiler/analyzer";

describe("Import errors", () => {
    it("should throw if import not in PascalCase", () => {
        const parser = new Parser();
        expect(() => Analyzer(parser.parse(`import math from "std/math"`)))
            .toThrowError(/I was not expecting this./);
    });
    it("should throw if import already done", () => {
        const parser = new Parser();
        expect(() => Analyzer(parser.parse(`import Vitest from "vitest" import Vitest from "vitest"`)))
            .toThrowError(/This identifier has already been declared./);
    });
});
