import { describe, it, expect } from "vitest";
import Parser from "../../src/compiler/parser";
import Analyzer from "../../src/compiler/analyzer";

describe("Reference errors", () => {
    it("should throw if condition reference not declared", () => {
        const parser = new Parser();
        expect(() => Analyzer(parser.parse("function a() { if (b) {} }")))
            .toThrowError(/This identifier has not been declared./);
    });
    it("should throw if if condition function call not declared", () => {
        const parser = new Parser();
        expect(() => Analyzer(parser.parse("function test(a) { if (b()) {}}")))
            .toThrowError(/This identifier has not been declared./);
    });
    it("should throw if if condition function call param not declared", () => {
        const parser = new Parser();
        expect(() => Analyzer(parser.parse("function test(a) { if (a(b)) {}}")))
            .toThrowError(/This identifier has not been declared./);
    });
    it("should throw if else if condition reference not declared", () => {
        const parser = new Parser();
        expect(() => Analyzer(parser.parse("function test(a) { if (a) {} else if (b) {} }")))
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