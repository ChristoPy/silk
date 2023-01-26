const TOKENS_SPEC = [
    [/^\s+/, 'SKIP'],
    [/^\/\/.*/, 'SKIP'],
    [/^\d+/, 'NUMBER'],
    [/^"[^"]*"/, 'STRING'],
    [/^let/, 'LET'],
    [/^function/, 'FUNCTION'],
    [/^true/, 'BOOLEAN'],
    [/^false/, 'BOOLEAN'],
    [/^return/, 'RETURN'],
    [/^import/, 'IMPORT'],
    [/^from/, 'FROM'],
    [/^[a-zA-Z_][a-zA-Z0-9_]*/, 'IDENTIFIER'],
    [/^=/, 'EQUALS'],
    [/^\(/, 'LPAREN'],
    [/^\)/, 'RPAREN'],
    [/^\{/, 'LBRACE'],
    [/^\}/, 'RBRACE'],
    [/^\[/, 'LBRACKET'],
    [/^\]/, 'RBRACKET'],
    [/^{/, 'LBRACE'],
    [/^}/, 'RBRACE'],
    [/^:/, 'COLON'],
    [/^,/, 'COMMA'],
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
            const match = this._matchToken(regex, string);

            if (match === null) {
                continue;
            }

            if (type === 'SKIP') {
                return this.getNextToken();
            }

            return {
                type,
                value: match
            };
        }

        throw new SyntaxError(`Unexpected token "${string[0]}"`);
    }

    _matchToken(regex, value) {
        const matched = regex.exec(value);
        if (matched === null) {
            return null
        }

        const match = matched[0];
        this._cursor += match.length;

        return match;
    }
}