export function now() {
    return Date.now();
}

export function format(timestamp) {
    return new Date(timestamp).toISOString();
}

export function parse(s) {
  try {
    const t = Date.parse(s);
    if (Number.isNaN(t)) {
      return { ok: false, error: 'Invalid date' };
    }
    return { ok: true, value: t };
  } catch (e) {
    return { ok: false, error: String(e) };
  }
}
