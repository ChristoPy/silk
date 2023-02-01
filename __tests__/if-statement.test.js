import { describe, it, expect } from "vitest";
import Parser from "../src/parser";

describe("Syntax", () => {
    it("should break if outside of a function", () => {
        const code = `
            if (something) {
                return "Hello, world!"
            }
        `;

        const parser = new Parser();
        expect(() => parser.parse(code)).toThrow();
    });
    it("should break if missing condition", () => {
        const code = `
            function greet() {
                if () {
                    return "Hello, world!"
                }
            }
        `;
        const parser = new Parser();
        expect(() => parser.parse(code)).toThrow();
    });
    it("should break if missing open parenthesis", () => {
        const code = `
            function greet() {
                if something) {
                    return "Hello, world!"
                }
            }
        `;

        const parser = new Parser();
        expect(() => parser.parse(code)).toThrow();
    });
    it("should break if missing close parenthesis", () => {
        const code = `
            function greet() {
                if (something {
                    return "Hello, world!"
                }
            }
        `;

        const parser = new Parser();
        expect(() => parser.parse(code)).toThrow();
    });
    it("should break if missing open curly brace", () => {
        const code = `
            function greet() {
                if (something)
                    return "Hello, world!"
                }
            }
        `;

        const parser = new Parser();
        expect(() => parser.parse(code)).toThrow();
    });
    it("should break if missing close curly brace", () => {
        const code = `
            function greet() {
                if (something) {
                    return "Hello, world!"
            }
        `;

        const parser = new Parser();
        expect(() => parser.parse(code)).toThrow();
    });
});
