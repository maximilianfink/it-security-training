// "Attacker server": records every request it receives and shows them on a dashboard.
// Only reachable inside the lab network (http://collector:8000) and from the VM (http://localhost:8000).
const http = require('http');

const hits = [];

function escape(s) {
  return String(s).replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));
}

function pretty(body) {
  try { return JSON.stringify(JSON.parse(body), null, 2); } catch { return body; }
}

http.createServer((req, res) => {
  if (req.method === 'GET' && req.url === '/') {
    const rows = hits.slice().reverse().map((h) => `<tr><td>${h.time}</td><td>${escape(h.from)}</td>
      <td>${escape(h.method)} ${escape(h.url)}</td><td><pre>${escape(pretty(h.body))}</pre></td></tr>`).join('');
    res.writeHead(200, { 'content-type': 'text/html; charset=utf-8' });
    return res.end(`<!doctype html><meta http-equiv="refresh" content="3"><title>Collector</title>
      <style>body{font-family:monospace;background:#111;color:#0f0}td,th{border:1px solid #0f0;padding:4px;vertical-align:top}table{border-collapse:collapse;width:100%}pre{margin:0;white-space:pre-wrap}</style>
      <h1>&#9760; Attacker collector – ${hits.length} hit(s)</h1>
      <table><tr><th>Time</th><th>From</th><th>Request</th><th>Data</th></tr>${rows}</table>`);
  }
  let body = '';
  req.on('data', (chunk) => { body += chunk; });
  req.on('end', () => {
    const hit = { time: new Date().toLocaleTimeString('de-DE'), from: req.socket.remoteAddress, method: req.method, url: req.url, body };
    hits.push(hit);
    console.log(`[collector] ${hit.method} ${hit.url} from ${hit.from} ${body}`);
    res.end('ok');
  });
}).listen(8000, () => console.log('[collector] listening on :8000'));
