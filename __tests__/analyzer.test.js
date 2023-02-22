import { describe, it, expect } from "vitest";
import Parser from "../src/compiler/parser";
import Analyzer from "../src/compiler/analyzer";

describe("Identifier errors", () => {
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
    it("should throw if variable already declared in program scope", () => {
        const parser = new Parser();
        expect(() => Analyzer(parser.parse("let a = 0 let a = 1")))
            .toThrowError(/This identifier has already been declared./);
    });
    it("should throw if function already declared in program scope", () => {
        const parser = new Parser();
        expect(() => Analyzer(parser.parse("function a() {} function a() {}")))
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
});

describe("Reference errors", () => {
    it("should throw if reference is not declared in program scope", () => {
        const parser = new Parser();
        expect(() => Analyzer(parser.parse("let a = b")))
            .toThrowError(/This identifier has not been declared./);
    });
    it("should throw if function call reference is not declared", () => {
        const parser = new Parser();
        expect(() => Analyzer(parser.parse("let a = b()")))
            .toThrowError(/This identifier has not been declared./);
    });
    it("should throw if function not declared", () => {
        const parser = new Parser();
        expect(() => Analyzer(parser.parse("a()")))
            .toThrowError(/This identifier has not been declared./);
    });

    it("should throw if reference is not declared in function scope", () => {
        const parser = new Parser();
        expect(() => Analyzer(parser.parse("function a() { let a = b }")))
            .toThrowError(/This identifier has not been declared./);
    });
    it("should throw if function call param not declared", () => {
        const parser = new Parser();
        expect(() => Analyzer(parser.parse("function a() {} a(c)")))
            .toThrowError(/This identifier has not been declared./);
    });
    it("should throw if if condition not declared", () => {
        const parser = new Parser();
        expect(() => Analyzer(parser.parse("function test() { if (a) {}}")))
            .toThrowError(/This identifier has not been declared./);
    });
    it("should throw if if condition function call not declared", () => {
        const parser = new Parser();
        expect(() => Analyzer(parser.parse("function test() { if (a()) {}}")))
            .toThrowError(/This identifier has not been declared./);
    });
    it("should throw if if condition function call param not declared", () => {
        const parser = new Parser();
        expect(() => Analyzer(parser.parse("function test(a) { if (a(b)) {}}")))
            .toThrowError(/This identifier has not been declared./);
    });
    it("should throw if else if condition not declared", () => {
        const parser = new Parser();
        expect(() => Analyzer(parser.parse("function test(a) { if (a) {} else if (b) {}}")))
            .toThrowError(/This identifier has not been declared./);
    });
    it("should throw if else if condition function call not declared", () => {
        const parser = new Parser();
        expect(() => Analyzer(parser.parse("function test(a) { if (a) {} else if (b()) {}}")))
            .toThrowError(/This identifier has not been declared./);
    });
    it("should throw if else if condition function call param not declared", () => {
        const parser = new Parser();
        expect(() => Analyzer(parser.parse("function test(a) { if (a) {} else if (b(c)) {}}")))
            .toThrowError(/This identifier has not been declared./);
    });
});