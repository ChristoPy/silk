export function get(name) {
    if (typeof process !== 'undefined' && process.env) {
        const v = process.env[name];
        return v !== undefined ? v : '';
    }
    return '';
}

export function has(name) {
    if (typeof process !== 'undefined' && process.env) {
        const v = process.env[name];
        return v !== undefined && v !== '';
    }
    return false;
}
