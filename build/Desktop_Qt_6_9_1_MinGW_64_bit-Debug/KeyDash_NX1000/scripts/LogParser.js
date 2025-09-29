// eslint-disable-next-line
.pragma library

function _toNumber(x) {
    if (x === undefined || x === null || x === "") return NaN;
    if (typeof x === "number") return x;
    const n = Number(String(x).trim());
    return isNaN(n) ? NaN : n;
}

function _coerceKeys(obj) {
    // normalize keys to lower-case for flexible CSV headers
    const out = {};
    for (let k in obj) out[k.toLowerCase()] = obj[k];
    return out;
}

function normalizeRow(raw, index) {
    const r = _coerceKeys(raw);
    // accepted timestamp keys
    const t = _toNumber(r["timestamp_ms"]) || _toNumber(r["time_ms"]) ||
              (_toNumber(r["t"]) * 1000) || 0;

    return {
        idx: index,
        t: Math.max(0, t|0),
        rpm: _toNumber(r["rpm"]) || 0,
        map: _toNumber(r["map"]) || 0,
        tps: _toNumber(r["tps"]) || _toNumber(r["throttle"]) || 0,
        clt: _toNumber(r["clt"]) || _toNumber(r["coolant"]) || 0,
        iat: _toNumber(r["iat"]) || _toNumber(r["intake"]) || 0,
        afr: _toNumber(r["afr"]) || _toNumber(r["lambda"]) || 0,
        batt: _toNumber(r["volt"]) || _toNumber(r["batt"]) || 0,
        raw: raw
    };
}

function parseCsv(text) {
    // tiny CSV parser (no quotes inside fields). Good enough for logs.
    const lines = text.replace(/\r\n?/g, "\n").split("\n").filter(l => l.trim().length);
    if (!lines.length) return { frames: [], duration: 0 };
    const headers = lines[0].split(",").map(h => h.trim());
    const frames = [];
    for (let i = 1; i < lines.length; i++) {
        const cols = lines[i].split(",");
        const row = {};
        for (let c = 0; c < headers.length; c++) row[headers[c]] = cols[c] !== undefined ? cols[c] : "";
        frames.push(normalizeRow(row, i - 1));
    }
    const duration = frames.length ? frames[frames.length - 1].t : 0;
    return { frames, duration };
}

function parseJson(text) {
    let arr = [];
    try { arr = JSON.parse(text); } catch (e) { return { frames: [], duration: 0 }; }
    if (!Array.isArray(arr)) return { frames: [], duration: 0 };
    const frames = arr.map((o, i) => normalizeRow(o, i));
    const duration = frames.length ? frames[frames.length - 1].t : 0;
    return { frames, duration };
}

function parse(text) {
    const trimmed = (text || "").trim();
    if (!trimmed) return { frames: [], duration: 0 };
    // heuristic: JSON if starts with [ or {
    if (trimmed[0] === "[" || trimmed[0] === "{") return parseJson(trimmed);
    return parseCsv(trimmed);
}

function hhmmss(ms) {
    const s = Math.floor(ms / 1000);
    const h = Math.floor(s / 3600);
    const m = Math.floor((s % 3600) / 60);
    const sec = s % 60;
    const pad = n => (n < 10 ? "0" + n : String(n));
    return (h ? pad(h) + ":" : "") + pad(m) + ":" + pad(sec);
}

// exports
var LogParser = { parse, hhmmss };
