import { describe, it, expect } from "vitest";
import Tokenizer from "../src/tokenizer";

describe("Tokenize Spaces", () => {
    it("should skip space", () => {
        const tokenizer = new Tokenizer();
        tokenizer.init(" ");
        const tokens = tokenizer.getNextToken();
        expect(tokens).toEqual(null);
    });

    it("should skip a tab", () => {
        const tokenizer = new Tokenizer();
        tokenizer.init("\t");
        const tokens = tokenizer.getNextToken();
        expect(tokens).toEqual(null);
    });

    it("should skip a newline", () => {
        const tokenizer = new Tokenizer();
        tokenizer.init("\n");
        const tokens = tokenizer.getNextToken();
        expect(tokens).toEqual(null);
    });
});

describe("Tokenize Comment", () => {
    it("should skip a comment", () => {
        const tokenizer = new Tokenizer();
        tokenizer.init("// This is a comment");
        const tokens = tokenizer.getNextToken();
        expect(tokens).toEqual(null);
    });
});

describe("Tokenize Numbers", () => {
    it("should tokenize a number", () => {
        const tokenizer = new Tokenizer();
        tokenizer.init("1");
        const tokens = tokenizer.getNextToken();
        expect(tokens).toEqual({ type: "NUMBER", value: "1" });
    });

    it("should tokenize a long number", () => {
        const tokenizer = new Tokenizer();
        tokenizer.init("1234243");
        const tokens = tokenizer.getNextToken();
        expect(tokens).toEqual({ type: "NUMBER", value: "1234243" });
    });
});

describe("Tokenize Strings", () => {
    it("should tokenize a string", () => {
        const tokenizer = new Tokenizer();
        tokenizer.init('"Hello, World!"');
        const tokens = tokenizer.getNextToken();
        expect(tokens).toEqual({ type: "STRING", value: '"Hello, World!"' });
    });
});

describe("Tokenize Identifiers", () => {
    it("should tokenize an identifier", () => {
        const tokenizer = new Tokenizer();
        tokenizer.init("hello");
        const tokens = tokenizer.getNextToken();
        expect(tokens).toEqual({ type: "IDENTIFIER", value: "hello" });
    });
});

describe("Tokenize Operators", () => {
    it("should tokenize equal operator", () => {
        const tokenizer = new Tokenizer();
        tokenizer.init("=");
        const tokens = tokenizer.getNextToken();
        expect(tokens).toEqual({ type: "EQUALS", value: "=" });
    });
});