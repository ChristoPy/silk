export function round(n) {
  return Math.round(n);
}

export function floor(n) {
  return Math.floor(n);
}

export function ceil(n) {
  return Math.ceil(n);
}

export function abs(n) {
  return Math.abs(n);
}

export function min(a, b) {
  return Math.min(a, b);
}

export function max(a, b) {
  return Math.max(a, b);
}

export function parse(s) {
  try {
    const n = Number(s);
    if (Number.isNaN(n)) {
      return { ok: false, error: 'Invalid number' };
    }
    return { ok: true, value: n };
  } catch (e) {
    return { ok: false, error: String(e) };
  }
}
