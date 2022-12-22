export default class Parser {
    parse(code) {
        this.code = code;

        return this.Program();
    }

    /**
     * Program
     *   : NumberLiteral
     *   ;
     */
    Program() {
        return {
            type: 'Program',
            body: this.NumberLiteral()
        }
    }

    /**
     * NumberLiteral
     *  : NUMBER
     *  ;
     */
    NumberLiteral() {
        return {
            type: 'NumberLiteral',
            value: Number(this.code)
        };
    }
}