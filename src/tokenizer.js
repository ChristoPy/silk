const TOKENS_SPEC = [
    [/^\d+/, 'NUMBER'],
    [/^"[^"]*"/, 'STRING']
]

export default class Tokenizer {
    init(code) {
        this._code = code;
        this._cursor = 0;
    }

    // EOF is when the cursor can't go any further
    // It's already out of bounds
    isEOF() {
        return this._cursor == this._code.length;
    }

    hasMoreTokens() {
        return this._cursor < this._code.length;
    }

    getNextToken() {
        if (!this.hasMoreTokens()) {
            return null;
        }

        const string = this._code.slice(this._cursor);

        for (const [regex, type] of TOKENS_SPEC) {
            const matches = regex.exec(string);
            if (matches !== null) {
                const match = matches[0];
                this._cursor += match.length;

                return {
                    type,
                    value: match
                };
            }
        }

        throw new SyntaxError(`Unexpected token ${string[0]}`);
    }
}