import { describe, it, expect } from "vitest";
import Parser from "../../src/compiler/parser";
import Analyzer from "../../src/compiler/analyzer";

describe("Identifier errors", () => {
    it("should throw if variable already declared in program scope", () => {
        const parser = new Parser();
        expect(() => Analyzer(parser.parse("let a = 0 let a = 1")))
            .toThrowError(/This identifier has already been declared./);
    });
    it("should throw if variable already declared in function scope", () => {
        const parser = new Parser();
        expect(() => Analyzer(parser.parse("function a() { let a = 0 let a = 1 }")))
            .toThrowError(/This identifier has already been declared./);
    });
    it("should throw if param already declared in function scope as variable", () => {
        const parser = new Parser();
        expect(() => Analyzer(parser.parse("function a(a) { let a = 1 }")))
            .toThrowError(/This identifier has already been declared./);
    });
    it("should throw if variable already declared in if scope", () => {
        const parser = new Parser();
        expect(() => Analyzer(parser.parse("function a() { if (a) { let a = 0 let a = 1 } }")))
            .toThrowError(/This identifier has already been declared./);
    });
    it("should throw if variable already declared in else if scope", () => {
        const parser = new Parser();
        expect(() => Analyzer(parser.parse("function a() { if (a) {} else if (a) { let a = 0 let a = 1 } }")))
            .toThrowError(/This identifier has already been declared./);
    });
});

describe("Reference errors", () => {
    it("should throw if reference is not declared in program scope", () => {
        const parser = new Parser();
        expect(() => Analyzer(parser.parse("let a = b")))
            .toThrowError(/This identifier has not been declared./);
    });
    it("should throw if reference is not declared in function scope", () => {
        const parser = new Parser();
        expect(() => Analyzer(parser.parse("function a() { let a = b }")))
            .toThrowError(/This identifier has not been declared./);
    });
});