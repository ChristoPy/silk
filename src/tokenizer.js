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

        // Numbers
        const numberMatches = /^\d+/.exec(string);
        if (numberMatches !== null) {
            const match = numberMatches[0]
            this._cursor += match.length;

            return {
                type: 'NUMBER',
                value: Number(match)
            };
        }

        // String
        const stringMatches = /^"[^"]*"/.exec(string);
        if (stringMatches !== null) {
            const match = stringMatches[0];
            this._cursor += match.length;

            return {
                type: 'STRING',
                value: match
            };
        }

        return null;
    }
}