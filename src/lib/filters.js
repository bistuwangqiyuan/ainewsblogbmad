export function parseSources(raw) {
    if (!raw) return [];
    return raw
        .split(',')
        .map((s) => s.trim())
        .filter((s) => !!s)
        .filter((v, i, arr) => arr.indexOf(v) === i);
}

export function toQueryParams(form) {
    const fd = form instanceof FormData ? form : new FormData(form);
    const p = new URLSearchParams();
    for (const [k, v] of fd.entries()) {
        if (v) p.set(k, v);
    }
    return p.toString();
}
