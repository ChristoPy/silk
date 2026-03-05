export function ok(value) {
    return { ok: true, value: value };
}

export function err(error) {
    return { ok: false, error: error };
}

export function isOk(result) {
    return result.ok === true;
}

export function isErr(result) {
    return result.ok === false;
}

export function unwrapOr(result, default_value) {
    if (result.ok === true) {
        return result.value;
    }
    return default_value;
}
