import { describe, it, expect } from "vitest";
import Parser from "../src/parser";
import Analyzer from "../src/analyzer";

describe("Identifier errors", () => {
    it("should throw if reference is not declared", () => {
        const parser = new Parser();
        expect(() => Analyzer(parser.parse("let a = b")))
            .toThrowError(/This identifier has not been declared./);
    });
    it("should throw if variable already declared", () => {
        const parser = new Parser();
        expect(() => Analyzer(parser.parse("let a = 0 let a = 1")))
            .toThrowError(/This identifier has already been declared./);
    });
    it("should throw if function already declared", () => {
        const parser = new Parser();
        expect(() => Analyzer(parser.parse("function a() {} function a() {}")))
            .toThrowError(/This identifier has already been declared./);
    });
    it("should throw if function not declared", () => {
        const parser = new Parser();
        expect(() => Analyzer(parser.parse("a()")))
            .toThrowError(/This identifier has not been declared./);
    });
    it("should throw if function call param not declared", () => {
        const parser = new Parser();
        expect(() => Analyzer(parser.parse("a(c)")))
            .toThrowError(/This identifier has not been declared./);
    });
});