export function get(url) {
  try {
    const p = fetch(url).then(function (r) { return r.text(); });
    return { ok: true, value: p };
  } catch (e) {
    return { ok: false, error: String(e) };
  }
}

export function post(url, body) {
  try {
    const p = fetch(url, { method: 'POST', body: body }).then(function (r) { return r.text(); });
    return { ok: true, value: p };
  } catch (e) {
    return { ok: false, error: String(e) };
  }
}
