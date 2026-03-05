export function parse(s) {
  try {
    const v = JSON.parse(s);
    return { ok: true, value: v };
  } catch (e) {
    return { ok: false, error: String(e) };
  }
}

export function stringify(value) {
  try {
    const s = JSON.stringify(value);
    return { ok: true, value: s };
  } catch (e) {
    return { ok: false, error: String(e) };
  }
}
