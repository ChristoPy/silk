import Tokenizer from "./tokenizer.js";

export default class Parser {
    constructor() {
        this._code = '';
        this._tokenizer = new Tokenizer();
    }
    parse(code) {
        this._code = code;
        this._tokenizer.init(code);

        // Start the parser off by looking ahead one token
        // so we can determine which parsing function to call
        // based on the first token.
        this._lookahead = this._tokenizer.getNextToken();

        return this.Program();
    }

    /**
     * Program
     *   : Literal
     *   ;
     */
    Program() {
        return {
            type: 'Program',
            body: this.Literal()
        }
    }


    /**
     * Literal
     *  : NumberLiteral
     *  | StringLiteral
     * ;
     */
    Literal() {
        const token = this._lookahead;
        const possibilities = {
            NUMBER: this.NumberLiteral,
            STRING: this.StringLiteral
        };

        if (!possibilities[token.type]) {
            throw new Error(`Unexpected token ${token.type}, expected NUMBER or STRING`);
        }

        return possibilities[token.type].call(this);
    }

    /**
     * NumberLiteral
     *  : NUMBER
     *  ;
     */
    NumberLiteral() {
        const token = this._eat('NUMBER');
        return {
            type: 'NumberLiteral',
            value: Number(token.value)
        };
    }

    /**
     * StringLiteral
     *  : STRING
     *  ;
     */
    StringLiteral() {
        const token = this._eat('STRING');
        return {
            type: 'StringLiteral',
            value: token.value.slice(1, -1)
        };
    }

    // Helper function to eat a token of a particular type
    // and return it. If the token is not of the expected
    // type, an error is thrown.
    _eat(tokenType) {
        const token = this._lookahead;

        if (token === null) {
            throw new Error(`Unexpected end of input, expected ${tokenType}`);
        }

        if (token.type !== tokenType) {
            throw new Error(`Unexpected token ${token.type}, expected ${tokenType}`);
        }

        // Advance the parser's cursor by one token
        // to it can be used in the next call
        this._lookahead = this._tokenizer.getNextToken();

        return token;
    }
}