import { describe, it, expect } from "vitest";
import Tokenizer from "../src/compiler/tokenizer";

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
        expect(tokens.type).toEqual("NUMBER");
        expect(tokens.value).toEqual("1");
    });

    it("should tokenize a long number", () => {
        const tokenizer = new Tokenizer();
        tokenizer.init("1234243");
        const tokens = tokenizer.getNextToken();
        expect(tokens.type).toEqual("NUMBER");
        expect(tokens.value).toEqual("1234243");
    });
});

describe("Tokenize Strings", () => {
    it("should tokenize a string", () => {
        const tokenizer = new Tokenizer();
        tokenizer.init('"Hello, World!"');
        const tokens = tokenizer.getNextToken();
        expect(tokens.type).toEqual("STRING");
        expect(tokens.value).toEqual('"Hello, World!"');
    });
});

describe("Tokenize Identifiers", () => {
    it("should tokenize an identifier", () => {
        const tokenizer = new Tokenizer();
        tokenizer.init("hello");
        const tokens = tokenizer.getNextToken();
        expect(tokens.type).toEqual("IDENTIFIER");
        expect(tokens.value).toEqual("hello");
    });
});

describe("Tokenize Operators", () => {
    it("should tokenize equal operator", () => {
        const tokenizer = new Tokenizer();
        tokenizer.init("=");
        const tokens = tokenizer.getNextToken();
        expect(tokens.type).toEqual("EQUALS");
        expect(tokens.value).toEqual("=");
    });
});

describe("Tokenize lines", () => {
    it("should tokenize a line", () => {
        const tokenizer = new Tokenizer();
        tokenizer.init(`let 
        hello 
        = 
        1`);
        const token = tokenizer.getNextToken();
        expect(token).toEqual({ type: "LET", value: "let", line: 1 });

        const token2 = tokenizer.getNextToken();
        expect(token2).toEqual({ type: "IDENTIFIER", value: "hello", line: 2 });

        const token3 = tokenizer.getNextToken();
        expect(token3).toEqual({ type: "EQUALS", value: "=", line: 3 });
    });
});