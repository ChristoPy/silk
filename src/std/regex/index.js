export function match(s, pattern) {
  try {
    const re = new RegExp(pattern);
    return { ok: true, value: re.test(s) };
  } catch (e) {
    return { ok: false, error: String(e) };
  }
}

export function replace(s, pattern, replacement) {
  try {
    const re = new RegExp(pattern);
    return { ok: true, value: s.replace(re, replacement) };
  } catch (e) {
    return { ok: false, error: String(e) };
  }
}
