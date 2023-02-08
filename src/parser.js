import Tokenizer from "./tokenizer.js";
import { throwError } from './utils.js';
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

    /**
     * Statement
     *   : VariableDeclaration
     *   | FunctionDeclaration
     *   | FunctionCall
     *   | ImportStatement
     *   ;
     */
    Statement() {
        const token = this._lookahead;
        if (token === null) return {};

        const possibilities = {
            LET: this.VariableDeclaration,
            FUNCTION: this.FunctionDeclaration,
            IDENTIFIER: this.FunctionCall,
            IMPORT: this.ImportStatement,
        };

        if (!possibilities[token.type]) {
            throwError('Syntax', 'unexpectedToken', token.value, token.line, 'statement');
        }

        return possibilities[token.type].call(this);
    }

    /**
     * ImportStatement
     *  : IMPORT IDENTIFIER FROM StringLiteral
     *  ;
     */
    ImportStatement() {
        const keyword = this._eat('IMPORT');
        const id = this._eat('IDENTIFIER');

        this._eat('FROM');
        const path = this.StringLiteral();

        return {
            type: 'ImportStatement',
            line: keyword.line,
            value: {
                name: id.value,
                path: path.value
            }
        };
    }

    /**
     * FunctionCall
     *  : IDENTIFIER LPAREN RPAREN
     *  | IDENTIFIER LPAREN Parameters RPAREN
     *  ;
     */
    FunctionCall() {
        const id = this._eat('IDENTIFIER');

        this._eat('LPAREN');
        const params = this.GenericList();
        this._eat('RPAREN');

        return {
            type: 'FunctionCall',
            line: id.line,
            value: {
                name: id.value,
                params
            }
        };
    }

    /**
     * VariableDeclaration
     *   : LET IDENTIFIER EQUALS Literal
     *   | LET IDENTIFIER EQUALS Identifier
     *   ;
     */
    VariableDeclaration() {
        const keyword = this._eat('LET');
        const id = this._eat('IDENTIFIER');
        this._eat('EQUALS');

        return {
            type: 'VariableDeclaration',
            line: keyword.line,
            value: {
                name: id.value,
                value: this.ExpressionValue()
            }
        };
    }

    /*
    * FunctionDeclaration
    *   : FUNCTION IDENTIFIER LPAREN RPAREN Block
    *   ;
    */
    FunctionDeclaration() {
        const keyword = this._eat('FUNCTION');
        const id = this._eat('IDENTIFIER');

        this._eat('LPAREN');
        const params = this.IdentifierList();
        this._eat('RPAREN');

        const body = this.Block();

        return {
            type: 'FunctionDeclaration',
            line: keyword.line,
            value: {
                name: id.value,
                params: params,
                body: body.body
            }
        };
    }

    /**
     * IdentifierList
     *  : Identifier
     *  | Identifier COMMA IdentifierList
     *  ;
     */
    IdentifierList() {
        return this.List(this.Identifier, "RPAREN");
    }

    /**
     * GenericList
     *  : Literal
     *  | Literal COMMA GenericList
     *  | Identifier
     *  | Identifier COMMA GenericList
     *  ;
     */
    GenericList() {
        return this.List(() => {
            if (this._lookahead && this._lookahead.type === 'IDENTIFIER') {
                return this.IdentifierOrFunctionCall();
            }
            return this.Literal();
        }, "RPAREN");
    }

    /**
     * List
     * : Literal
     * | Literal COMMA List
     * | Identifier
     * | Identifier COMMA List
     * ;
     */
    List(fn, limiter) {
        const params = [];

        let endWithComma = false;
        while (this._lookahead && this._lookahead.type !== limiter) {
            params.push(fn.call(this));
            endWithComma = false;

            if (this._lookahead && this._lookahead.type === 'COMMA') {
                this._eat('COMMA');
                endWithComma = true;
            }
        }

        if (endWithComma) throwError('Syntax', 'unexpectedToken', ',', this._tokenizer._line, 'danglingComma');
        return params;
    }

    /**
     * ExpressionValue
     *  : Literal
     *  | Identifier
     *  ;
     */
    ExpressionValue() {
        const token = this._lookahead;
        if (token === null) {
            throwError('Syntax', 'unexpectedToken', '', this._tokenizer._line, 'expressionValue');
        };

        const possibilities = {
            NUMBER: this.NumberLiteral,
            STRING: this.StringLiteral,
            BOOLEAN: this.BooleanLiteral,
            IDENTIFIER: this.IdentifierOrFunctionCall,
            LBRACKET: this.ArrayLiteral,
            LBRACE: this.ObjectLiteral,
        };

        if (!possibilities[token.type]) {
            throwError('Syntax', 'unexpectedToken', token.value, token.line, 'expressionValue');
        }

        return possibilities[token.type].call(this);
    }

    /**
     * Block
     *   : LBRACE RBRACE
     *   | LBRACE Statement RBRACE
     *   ;
     */
    Block() {
        this._eat('LBRACE');

        const statements = [];
        while (this._lookahead && this._lookahead.type !== 'RBRACE') {
            statements.push(this.ScopedStatement());
        }

        this._eat('RBRACE');

        return {
            type: 'Block',
            body: statements
        };
    }

    /**
     * ScopedStatement
     *   : VariableDeclaration
     *   | FunctionDeclaration
     *   | FunctionCall
     *   | ReturnStatement
     *   ;
     */
    ScopedStatement() {
        const token = this._lookahead;
        if (token === null) {
            throwError('Syntax', 'unexpectedToken', '', this._tokenizer._line, 'scopedStatement');
        };

        const possibilities = {
            IF: this.IfStatement,
            LET: this.VariableDeclaration,
            FUNCTION: this.FunctionDeclaration,
            IDENTIFIER: this.IdentifierOrFunctionCall,
            RETURN: this.ReturnStatement,
        };

        if (!possibilities[token.type]) {
            throwError('Syntax', 'unexpectedToken', token.value, token.line, 'scopedStatement');
        }

        return possibilities[token.type].call(this);
    }

    /**
     * IfStatement
     *  : IF LPAREN ConditionValue RPAREN Block ElseIfStatement
     * ;
     */
    IfStatement() {
        const keyword = this._eat('IF');

        this._eat('LPAREN');
        const condition = this.ConditionValue();
        this._eat('RPAREN');

        const body = this.Block();
        const fallback = this.ElseIfStatement();

        return {
            type: 'IfStatement',
            line: keyword.line,
            condition,
            body: body.body,
            fallback
        };
    }

    /**
     * ElseIfStatement
     * : ELSE IfStatement
     * ;
     */
    ElseIfStatement() {
        if (this._lookahead && this._lookahead.type !== 'ELSE') {
            return null;
        }

        this._eat('ELSE');

        return this.IfStatement();
    }

    /**
     * ConditionValue
     * : Identifier
     * | FunctionCall
     */
    ConditionValue() {
        const token = this._lookahead;

        if (token === null) {
            throwError('Syntax', 'unexpectedEndOfInput', '', this._tokenizer._line);
        };

        const possibilities = {
            IDENTIFIER: this.IdentifierOrFunctionCall,
        };

        if (!possibilities[token.type]) {
            throwError('Syntax', 'unexpectedToken', token.value, token.line, 'conditionValue');
        }

        return possibilities[token.type].call(this);
    }

    /**
     * ReturnStatement
     *  : RETURN ExpressionValue
     *  ;
     */
    ReturnStatement() {
        const keyword = this._eat('RETURN');
        return {
            type: 'ReturnStatement',
            line: keyword.line,
            value: this.ExpressionValue()
        };
    }

    /**
     * IdentifierOrFunctionCall
     *   : IDENTIFIER
     *   | FunctionCall
     *   ;
     */
    IdentifierOrFunctionCall() {
        const token = this._eat('IDENTIFIER');

        if (!this._lookahead || this._lookahead && this._lookahead.type !== 'LPAREN') {
            return {
                line: token.line,
                type: 'Identifier',
                value: token.value
            };
        }

        this._eat('LPAREN');
        const params = this.GenericList();
        this._eat('RPAREN');

        return {
            type: 'FunctionCall',
            line: token.line,
            value: {
                name: token.value,
                params
            }
        };
    }

    /**
     * ArrayLiteral
     *  : LBRACKET RBRACKET
     * | LBRACKET ExpressionValue RBRACKET
     * | LBRACKET ExpressionValue COMMA ArrayLiteral
     * ;
     */
    ArrayLiteral() {
        this._eat('LBRACKET');
        const elements = this.List(() => {
            return this.ExpressionValue();
        }, "RBRACKET");
        this._eat('RBRACKET');

        return {
            type: 'ArrayLiteral',
            line: this._tokenizer._line,
            value: elements
        };
    }

    /**
     * ObjectLiteral
     * : LBRACE RBRACE
     * | LBRACE ObjectProperty RBRACE
     * | LBRACE ObjectProperty COMMA ObjectLiteral
     * ;
     */
    ObjectLiteral() {
        this._eat('LBRACE');

        const properties = this.List(() => {
            return this.ObjectProperty();
        }, "RBRACE");

        this._eat('RBRACE');

        return {
            type: 'ObjectLiteral',
            line: this._tokenizer._line,
            value: properties
        };
    }

    /**
     * ObjectProperty
     * : IDENTIFIER COLON ExpressionValue
     * ;
     */
    ObjectProperty() {
        const key = this._eat('IDENTIFIER');
        this._eat('COLON');

        return {
            key: key.value,
            line: key.line,
            value: this.ExpressionValue()
        };
    }

    /**
     * Literal
     *   : NumberLiteral
     *   | StringLiteral
     *   ;
     */
    Literal() {
        const token = this._lookahead;
        if (token === null) return {}

        const possibilities = {
            NUMBER: this.NumberLiteral,
            STRING: this.StringLiteral,
            BOOLEAN: this.BooleanLiteral
        };

        if (!possibilities[token.type]) {
            throwError('Syntax', 'unexpectedToken', token.value, token.line, 'literal');
        }

        return possibilities[token.type].call(this);
    }

    /**
     * NumberLiteral
     *   : NUMBER
     *   ;
     */
    NumberLiteral() {
        const token = this._eat('NUMBER');
        return {
            type: 'NumberLiteral',
            line: token.line,
            value: Number(token.value)
        };
    }

    /**
     * StringLiteral
     *   : STRING
     *   ;
     */
    StringLiteral() {
        const token = this._eat('STRING');
        return {
            type: 'StringLiteral',
            line: token.line,
            value: token.value.slice(1, -1)
        };
    }

    /*
    * BooleanLiteral
    *   : TRUE
    *   | FALSE
    *   ;
    * */
    BooleanLiteral() {
        const token = this._eat('BOOLEAN');
        return {
            type: 'BooleanLiteral',
            line: token.line,
            value: token.value === 'true' ? true : false
        };
    }

    /**
     * Identifier
     *   : IDENTIFIER
     *   ;
     */
    Identifier() {
        const token = this._eat('IDENTIFIER');
        return {
            type: 'Identifier',
            line: token.line,
            value: token.value
        };
    }

    // Helper function to eat a token of a particular type
    // and return it. If the token is not of the expected
    // type, an error is thrown.
    _eat(tokenType) {
        const token = this._lookahead;

        if (token === null) {
            throwError('Syntax', 'unexpectedEndOfInput', '', this._tokenizer._line);
        }

        if (token.type !== tokenType) {
            throwError('Syntax', 'unexpectedToken', token.value, token.line);
        }

        // Advance the parser's cursor by one token
        // to it can be used in the next call
        this._lookahead = this._tokenizer.getNextToken();

        return token;
    }
}