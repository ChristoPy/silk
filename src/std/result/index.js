export function ok(value) {
    return { ok: true, value: value };
}

export function err(error) {
    return { ok: false, error: error };
}

export function is_ok(result) {
    return result.ok === true;
}

export function is_err(result) {
    return result.ok === false;
}

export function unwrap_or(result, default_value) {
    if (result.ok === true) {
        return result.value;
    }
    return default_value;
}
