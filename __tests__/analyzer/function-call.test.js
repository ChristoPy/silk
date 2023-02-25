import { describe, it, expect } from "vitest";
import Parser from "../../src/compiler/parser";
import Analyzer from "../../src/compiler/analyzer";

describe("Reference errors", () => {
    it("should throw if function not declared", () => {
        const parser = new Parser();
        expect(() => Analyzer(parser.parse("a()")))
            .toThrowError(/This identifier has not been declared./);
    });
    it("should throw if reference is not declared in function scope", () => {
        const parser = new Parser();
        expect(() => Analyzer(parser.parse("function a() { b() }")))
            .toThrowError(/This identifier has not been declared./);
    });
    it("should throw if function call param not declared", () => {
        const parser = new Parser();
        expect(() => Analyzer(parser.parse("function a() {} a(c)")))
            .toThrowError(/This identifier has not been declared./);
    });
});