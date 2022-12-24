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
     *   : Statement
     *   ;
     */
    Program() {
        const statements = [];

        while (this._lookahead !== null) {
            statements.push(this.Statement());
        }

        return {
            type: 'Program',
            body: statements,
        }
    }

    Statement() {
        const token = this._lookahead;

        if (token === null) {
            return {};
        }

        const possibilities = {
            LET: this.VariableDeclaration,
        };

        if (!possibilities[token.type]) {
            throw new Error(`Unexpected token ${token.type}, expected LET, FUNCTION, IF, or LOOP`);
        }

        return possibilities[token.type].call(this);
    }

    /**
     * VariableDeclaration
     * : LET IDENTIFIER EQUALS Literal
     * | LET IDENTIFIER EQUALS Identifier
     * ;
     */
    VariableDeclaration() {
        this._eat('LET');

        const id = this._eat('IDENTIFIER');

        this._eat('EQUALS');

        let init = null;
        if (this._lookahead.type === 'IDENTIFIER') {
            init = this.Identifier();
        } else {
            init = this.Literal();
        }

        return {
            type: 'VariableDeclaration',
            value: {
                name: {
                    type: 'Identifier',
                    value: id.value
                },
                value: init
            }
        };
    }

    /**
     * Literal
     *  : NumberLiteral
     *  | StringLiteral
     * ;
     */
    Literal() {
        const token = this._lookahead;

        if (token === null) {
            return {};
        }

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

    /**
     * Identifier
     * : IDENTIFIER
     * ;
     */
    Identifier() {
        const token = this._eat('IDENTIFIER');
        return {
            type: 'Identifier',
            value: token.value
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