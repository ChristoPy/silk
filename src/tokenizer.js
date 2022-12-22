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
        if (!isNaN(string)) {
            let number = '';

            while (!isNaN(string[this._cursor])) {
                number += string[this._cursor];
                this._cursor++;
            }

            return {
                type: 'NUMBER',
                value: Number(number)
            };
        }

        // String
        if (string[0] === '"') {
            let stringValue = '';

            do {
                stringValue += string[this._cursor];
                this._cursor++;
            } while (string[this._cursor] !== '"' && !this.isEOF());

            // Add the last quote
            stringValue += '"';
            this._cursor++;

            return {
                type: 'STRING',
                value: stringValue
            };
        }

        return null;
    }
}