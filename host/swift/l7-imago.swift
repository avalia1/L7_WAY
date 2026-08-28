// ══════════════════════════════════════════════════════════════
// IMAGO — The Image Maker (♀ Venus)
// L7-native image creation. Atomized. No external models.
// Text → atoms → transmutation → image. Pick to evolve.
//
// Planet: Venus ♀ — beauty, creation, desire, reflection
// Metal: Copper — warm, conductive, alive
// Tarot: The Empress (III) — abundance, creativity, generation
//
// Creator: Alberto Valido Delgado
// System: L7 Universal OS
// License: Proprietary (Law XXII)
// ══════════════════════════════════════════════════════════════

import Cocoa
import WebKit

let L7_DIR = ProcessInfo.processInfo.environment["L7_DIR"]
    ?? NSHomeDirectory() + "/.l7"

struct Venus {
    static let bg      = NSColor(red: 0.04, green: 0.06, blue: 0.05, alpha: 1)
    static let surface = NSColor(red: 0.06, green: 0.08, blue: 0.07, alpha: 1)
    static let accent  = NSColor(red: 0.18, green: 0.85, blue: 0.55, alpha: 1)
    static let text    = NSColor(red: 0.88, green: 0.92, blue: 0.90, alpha: 1)
}

let IMAGO_HTML: String = ###"""
<!DOCTYPE html>
<html><head>
<meta charset="utf-8">
<title>Imago — The Image Maker</title>
<style>
*{margin:0;padding:0;box-sizing:border-box}
body{background:#0a0e0c;color:#e0ebe6;font:14px/1.5 system-ui,-apple-system,sans-serif;
  overflow:hidden;height:100vh;display:flex;flex-direction:column}

.topbar{display:flex;align-items:center;gap:12px;padding:14px 20px;
  background:linear-gradient(135deg,#0c1410,#101a16);border-bottom:1px solid #1a2e24}
.brand{font:300 20px system-ui;color:#2dd98c;letter-spacing:3px}
.brand span{font-size:24px;margin-right:6px}
.prompt-wrap{flex:1;display:flex;gap:8px}
#prompt{flex:1;background:rgba(255,255,255,0.06);border:1px solid #1a2e24;
  border-radius:24px;padding:12px 22px;color:#e0ebe6;font:15px system-ui;outline:none;transition:border 0.3s}
#prompt:focus{border-color:#2dd98c}
#prompt::placeholder{color:#607a6a}
.btn{padding:12px 28px;border-radius:24px;border:1px solid #f2b326;
  background:linear-gradient(135deg,rgba(242,179,38,0.15),rgba(210,60,40,0.1));
  color:#f2b326;font:600 14px system-ui;cursor:pointer;letter-spacing:1px;transition:all 0.3s}
.btn:hover{background:linear-gradient(135deg,rgba(242,179,38,0.3),rgba(210,60,40,0.2));
  box-shadow:0 0 20px rgba(242,179,38,0.25)}
.btn:disabled{opacity:0.4;cursor:not-allowed}
.btn-sm{padding:7px 16px;font-size:12px;border-radius:16px}

.controls{display:flex;align-items:center;gap:16px;padding:8px 20px;
  background:#0c1410;border-bottom:1px solid rgba(26,46,36,0.5);flex-wrap:wrap}
.ctrl{display:flex;align-items:center;gap:6px}
.ctrl label{font:500 11px system-ui;color:#607a6a;text-transform:uppercase;letter-spacing:1px}
.ctrl select,.ctrl input[type=range]{background:rgba(255,255,255,0.06);border:1px solid #1a2e24;
  border-radius:8px;padding:5px 10px;color:#e0ebe6;font:12px system-ui;-webkit-appearance:none}
input[type=range]{width:80px;accent-color:#2dd98c}
.breadcrumb{display:flex;gap:4px;align-items:center;flex-wrap:wrap}
.breadcrumb span{padding:3px 10px;border-radius:10px;font:11px system-ui;color:#607a6a;cursor:pointer;transition:all 0.2s}
.breadcrumb span:hover,.breadcrumb span.active{color:#2dd98c;background:rgba(45,217,140,0.12)}
.breadcrumb .sep{color:#1a2e24;cursor:default;padding:0 2px}
.breadcrumb .sep:hover{background:none;color:#1a2e24}

.grid-area{flex:1;overflow-y:auto;padding:16px;display:flex;flex-wrap:wrap;
  gap:14px;align-content:flex-start;justify-content:center}
.card{position:relative;border-radius:12px;overflow:hidden;cursor:pointer;
  border:2px solid transparent;transition:all 0.3s;background:#080c0a;flex-shrink:0}
.card:hover{border-color:#2dd98c;transform:scale(1.02);box-shadow:0 4px 30px rgba(45,217,140,0.2)}
.card.selected{border-color:#f2b326;box-shadow:0 0 30px rgba(242,179,38,0.3)}
.card canvas{display:block;border-radius:10px}
.card .info{position:absolute;bottom:0;left:0;right:0;padding:8px 10px;
  background:linear-gradient(transparent,rgba(10,14,12,0.92));
  font:10px monospace;color:#607a6a;opacity:0;transition:opacity 0.3s}
.card:hover .info{opacity:1}

.statusbar{display:flex;align-items:center;justify-content:space-between;
  padding:8px 20px;background:#0c1410;border-top:1px solid #1a2e24;font:11px system-ui;color:#607a6a}
.statusbar .dot{width:7px;height:7px;border-radius:50%;background:#2dd98c;display:inline-block;margin-right:6px}

.empty{flex:1;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:16px;color:#607a6a}
.empty .symbol{font-size:72px;color:#2dd98c;opacity:0.3}
.empty p{font:300 16px system-ui;max-width:420px;text-align:center;line-height:1.7}
.empty .hint{font:12px system-ui;color:#3a4e42;margin-top:4px}
</style>
</head><body>

<div class="topbar">
  <div class="brand"><span>&#9792;</span>IMAGO</div>
  <div class="prompt-wrap">
    <input type="text" id="prompt" placeholder="Describe what you see... words become atoms become image" autofocus>
    <button class="btn" id="genBtn" onclick="generate()">FORGE</button>
  </div>
</div>

<div class="controls">
  <div class="ctrl">
    <label>Stage</label>
    <select id="stage">
      <option value="auto">Auto (all 4)</option>
      <option value="nigredo">Nigredo (decompose)</option>
      <option value="albedo">Albedo (purify)</option>
      <option value="citrinitas">Citrinitas (illuminate)</option>
      <option value="rubedo">Rubedo (complete)</option>
    </select>
  </div>
  <div class="ctrl">
    <label>Count</label>
    <select id="count">
      <option value="4" selected>4</option>
      <option value="6">6</option>
      <option value="9">9</option>
    </select>
  </div>
  <div class="ctrl">
    <label>Complexity</label>
    <input type="range" id="complexity" min="1" max="10" value="7">
  </div>
  <div class="ctrl">
    <label>Astrocyte</label>
    <input type="range" id="astrocyte" min="0" max="100" value="25">
  </div>
  <div class="ctrl">
    <label>Size</label>
    <select id="size">
      <option value="512">512</option>
      <option value="768" selected>768</option>
      <option value="1024">1024</option>
    </select>
  </div>
  <div class="breadcrumb" id="breadcrumb"></div>
  <div style="flex:1"></div>
  <button class="btn btn-sm" onclick="evolveSelected()">EVOLVE</button>
  <button class="btn btn-sm" onclick="saveSelected()">SAVE</button>
</div>

<div class="grid-area" id="grid">
  <div class="empty">
    <div class="symbol">&#9792;</div>
    <p>The Empress forges images from words.<br>No external models. Atomized and rebuilt by the Forge.</p>
    <div class="hint">Nigredo → Albedo → Citrinitas → Rubedo</div>
  </div>
</div>

<div class="statusbar">
  <div><span class="dot"></span><span id="status">Ready</span></div>
  <div id="info"></div>
  <div>IMAGO v4.0 — L7 Native — No External Dependencies</div>
</div>

<script>
// ═══════════════════════════════════════════
// THE FORGE — L7 Native Image Transmutation
// Words → Atoms → 4-Stage Alchemy → Image
// ═══════════════════════════════════════════

const grid = document.getElementById('grid');
const statusEl = document.getElementById('status');
const infoEl = document.getElementById('info');

let history = [];
let selectedCards = new Set();
let allCards = [];

// ─── Seeded PRNG (Mulberry32) ───
function rng(seed) {
  return function() {
    seed |= 0; seed = seed + 0x6D2B79F5 | 0;
    var t = Math.imul(seed ^ (seed >>> 15), 1 | seed);
    t = t + Math.imul(t ^ (t >>> 7), 61 | t) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  }
}

// ─── ATOMIZER: Text → 12D Coordinate + Color Palette + Form DNA ───
function atomize(text) {
  let hash = 0;
  for (let i = 0; i < text.length; i++) hash = ((hash << 5) - hash + text.charCodeAt(i)) | 0;
  hash = Math.abs(hash);

  const words = text.toLowerCase().split(/\s+/).filter(w => w.length > 1);

  // Color extraction from semantics
  const colorSeeds = {
    fire:['#ff4400','#ff8800','#ffcc00','#ff2200'],    red:['#cc0000','#ff2222','#aa0000','#ff4444'],
    water:['#0055ff','#00aaff','#0088cc','#44aaff'],   blue:['#0033cc','#2266ff','#0055aa','#4488ff'],
    earth:['#885522','#44aa44','#228833','#669944'],    green:['#00cc44','#22aa22','#44dd66','#118833'],
    air:['#bbbbff','#aaccff','#ddddff','#8899cc'],     white:['#eeeeff','#ddddee','#ccccdd','#ffffff'],
    gold:['#ffd700','#daa520','#b8860b','#ffcc00'],    sun:['#ffaa00','#ff8800','#ffd700','#ffee44'],
    moon:['#c0c0ff','#8888cc','#aaaaee','#9999bb'],    night:['#0a0a2e','#1a1a4e','#2a2a6e','#111133'],
    ocean:['#003366','#006699','#0099cc','#004488'],    forest:['#1a3a1a','#2a5a2a','#3a7a3a','#224422'],
    desert:['#c2956a','#daa06d','#e8c07a','#aa7744'],  crystal:['#88ccff','#aaddff','#cceeff','#66aadd'],
    blood:['#8b0000','#a00000','#cc0000','#660000'],   copper:['#b87333','#da8a67','#c97b4b','#aa6633'],
    silver:['#c0c0c0','#d0d0d0','#e0e0e0','#aaaaaa'],  mercury:['#00ebd2','#33ccaa','#66aa88','#00ccaa'],
    purple:['#8800ff','#aa44ff','#cc88ff','#6622cc'],  black:['#111111','#1a1a1a','#222222','#0a0a0a'],
    storm:['#334455','#445566','#556677','#667788'],   love:['#ff4488','#ff66aa','#cc3377','#ff88bb'],
    dream:['#6644aa','#8866cc','#aa88ee','#5533aa'],   star:['#ffffcc','#ffff88','#ffffff','#ffffaa'],
    ice:['#aaeeff','#88ddff','#66ccff','#ccf0ff'],     lava:['#ff3300','#ff5500','#cc2200','#ff7700'],
    space:['#0a0a22','#1a1a44','#222266','#3333aa'],   emerald:['#2dd98c','#33cc77','#22aa66','#44eebb'],
  };

  let palette = ['#2dd98c','#f2b326','#4488ff','#ff6644']; // default L7
  for (const [k, v] of Object.entries(colorSeeds)) {
    if (words.some(w => w.includes(k))) { palette = v; break; }
  }

  // Intensity from adjectives
  let intensity = 0.6;
  const intensifiers = {bright:0.85,vivid:0.9,intense:0.9,bold:0.8,fierce:0.95,loud:0.85,
    soft:0.3,gentle:0.25,calm:0.2,quiet:0.15,subtle:0.2,faint:0.1,
    chaos:1,wild:0.95,explosive:1,violent:1,storm:0.9,rage:1,
    peace:0.15,serene:0.1,tranquil:0.1};
  for (const w of words) { if (intensifiers[w] !== undefined) intensity = intensifiers[w]; }

  // Geometry DNA
  let geometry = 'mixed';
  const geoMap = {circle:'circular',sphere:'circular',spiral:'spiral',round:'circular',orbit:'circular',
    square:'angular',cube:'angular',grid:'angular',lattice:'angular',matrix:'angular',
    triangle:'triangular',pyramid:'triangular',peak:'triangular',mountain:'triangular',
    wave:'wave',flow:'wave',river:'wave',stream:'wave',wind:'wave',ocean:'wave',
    tree:'fractal',branch:'fractal',root:'fractal',vine:'fractal',fractal:'fractal',
    star:'radial',burst:'radial',explode:'radial',radiate:'radial',sun:'radial',
    hex:'hexagonal',hexagon:'hexagonal',honeycomb:'hexagonal',graphene:'hexagonal',
    sigil:'sigil',symbol:'sigil',glyph:'sigil',rune:'sigil',seal:'sigil',
    nebula:'nebula',cloud:'nebula',smoke:'nebula',mist:'nebula',fog:'nebula',
    crystal:'crystal',gem:'crystal',diamond:'crystal',prism:'crystal',
    mandala:'mandala',sacred:'mandala',geometry:'mandala',flower:'mandala'};
  for (const w of words) { if (geoMap[w]) { geometry = geoMap[w]; break; } }

  // 12D coordinate from text hash
  const r = rng(hash);
  const coord = Array.from({length: 12}, () => 1 + Math.floor(r() * 10));

  return { hash, palette, intensity, geometry, coord, words, seed: hash };
}

// ═══ THE FOUR STAGES ═══

// NIGREDO — Decomposition. Raw chaos. Points scattered.
function nigredo(ctx, w, h, r, atoms) {
  const n = 200 + Math.floor(atoms.intensity * 800);
  for (let i = 0; i < n; i++) {
    const x = r() * w;
    const y = r() * h;
    const s = 1 + r() * 4;
    ctx.beginPath();
    ctx.arc(x, y, s, 0, Math.PI * 2);
    ctx.fillStyle = atoms.palette[Math.floor(r() * atoms.palette.length)];
    ctx.globalAlpha = 0.05 + r() * 0.15;
    ctx.fill();
  }
  // Dark veil
  ctx.globalAlpha = 0.3;
  ctx.fillStyle = '#000000';
  ctx.fillRect(0, 0, w, h);
}

// ALBEDO — Purification. Structure emerges. Lines, geometry.
function albedo(ctx, w, h, r, atoms) {
  ctx.globalAlpha = 1;
  const geo = atoms.geometry;

  if (geo === 'circular' || geo === 'spiral' || geo === 'mandala') {
    const cx = w/2, cy = h/2;
    const rings = 4 + Math.floor(r() * 8);
    for (let ring = 0; ring < rings; ring++) {
      const radius = (ring + 1) * Math.min(w, h) / (rings * 2.2);
      const sides = 6 + Math.floor(r() * 20);
      const rot = r() * Math.PI * 2 + ring * 0.3;
      ctx.beginPath();
      for (let i = 0; i <= sides; i++) {
        const a = rot + (i / sides) * Math.PI * 2;
        const pr = radius * (1 + Math.sin(a * 3 + ring) * 0.1 * atoms.intensity);
        const px = cx + Math.cos(a) * pr;
        const py = cy + Math.sin(a) * pr;
        i === 0 ? ctx.moveTo(px, py) : ctx.lineTo(px, py);
      }
      ctx.closePath();
      ctx.strokeStyle = atoms.palette[ring % atoms.palette.length];
      ctx.lineWidth = 0.8 + r() * 1.5;
      ctx.globalAlpha = 0.2 + 0.4 * (1 - ring / rings);
      ctx.stroke();
      // Inner connections
      if (r() > 0.3) {
        for (let i = 0; i < sides; i += 2) {
          const a1 = rot + (i / sides) * Math.PI * 2;
          const a2 = rot + ((i + Math.floor(sides / 3)) / sides) * Math.PI * 2;
          ctx.beginPath();
          ctx.moveTo(cx + Math.cos(a1) * radius, cy + Math.sin(a1) * radius);
          ctx.lineTo(cx + Math.cos(a2) * radius, cy + Math.sin(a2) * radius);
          ctx.globalAlpha = 0.08;
          ctx.stroke();
        }
      }
    }
  } else if (geo === 'angular' || geo === 'hexagonal') {
    const cols = 6 + Math.floor(r() * 10);
    const rows = 6 + Math.floor(r() * 8);
    const cw = w / cols, ch = h / rows;
    for (let y = 0; y < rows; y++) {
      for (let x = 0; x < cols; x++) {
        const ox = geo === 'hexagonal' && y % 2 ? cw * 0.5 : 0;
        const px = x * cw + ox + cw / 2;
        const py = y * ch + ch / 2;
        const sides = geo === 'hexagonal' ? 6 : 4;
        const sz = Math.min(cw, ch) * 0.4 * (0.5 + r() * 0.5);
        ctx.beginPath();
        for (let i = 0; i <= sides; i++) {
          const a = (i / sides) * Math.PI * 2 - Math.PI / (geo === 'hexagonal' ? 6 : 4);
          const vx = px + Math.cos(a) * sz;
          const vy = py + Math.sin(a) * sz;
          i === 0 ? ctx.moveTo(vx, vy) : ctx.lineTo(vx, vy);
        }
        ctx.closePath();
        ctx.strokeStyle = atoms.palette[Math.floor(r() * atoms.palette.length)];
        ctx.lineWidth = 0.5 + r();
        ctx.globalAlpha = 0.1 + r() * 0.25;
        ctx.stroke();
        if (r() > 0.7) {
          ctx.fillStyle = atoms.palette[Math.floor(r() * atoms.palette.length)];
          ctx.globalAlpha = 0.03 + r() * 0.06;
          ctx.fill();
        }
      }
    }
  } else if (geo === 'wave') {
    const waves = 12 + Math.floor(atoms.intensity * 20);
    for (let i = 0; i < waves; i++) {
      const freq = 1 + r() * 5;
      const amp = 10 + r() * h * 0.12;
      const yOff = h * (i / waves);
      const phase = r() * Math.PI * 2;
      ctx.beginPath();
      for (let x = 0; x <= w; x += 2) {
        const y = yOff + Math.sin(x / w * Math.PI * 2 * freq + phase) * amp *
          Math.cos(x / w * Math.PI * freq * 0.3);
        x === 0 ? ctx.moveTo(x, y) : ctx.lineTo(x, y);
      }
      ctx.strokeStyle = atoms.palette[i % atoms.palette.length];
      ctx.lineWidth = 0.5 + r() * 2;
      ctx.globalAlpha = 0.1 + r() * 0.25;
      ctx.stroke();
    }
  } else if (geo === 'fractal') {
    const maxD = 5 + Math.floor(atoms.intensity * 4);
    const bRatio = 0.6 + r() * 0.15;
    const spread = 0.4 + r() * 0.6;
    function branch(x, y, len, angle, d) {
      if (d > maxD || len < 2) return;
      const x2 = x + Math.cos(angle) * len;
      const y2 = y + Math.sin(angle) * len;
      ctx.beginPath(); ctx.moveTo(x, y); ctx.lineTo(x2, y2);
      ctx.strokeStyle = atoms.palette[d % atoms.palette.length];
      ctx.lineWidth = Math.max(0.3, (maxD - d) * 0.7);
      ctx.globalAlpha = 0.15 + 0.4 * (1 - d / maxD);
      ctx.stroke();
      const nb = 2 + Math.floor(r() * 2);
      for (let b = 0; b < nb; b++) branch(x2, y2, len * bRatio, angle + (r() - 0.5) * spread * Math.PI, d + 1);
    }
    const starts = 1 + Math.floor(r() * 3);
    for (let s = 0; s < starts; s++) branch(w * (0.2 + r() * 0.6), h * (0.65 + r() * 0.25), Math.min(w, h) * 0.18, -Math.PI / 2 + (r() - 0.5) * 0.5, 0);
  } else if (geo === 'sigil') {
    const cx = w / 2, cy = h / 2;
    const outerR = Math.min(w, h) * 0.36;
    ctx.beginPath(); ctx.arc(cx, cy, outerR, 0, Math.PI * 2);
    ctx.strokeStyle = atoms.palette[0]; ctx.lineWidth = 1.5; ctx.globalAlpha = 0.4; ctx.stroke();
    const pts = [], np = 5 + Math.floor(r() * 8);
    for (let i = 0; i < np; i++) {
      const a = (i / np) * Math.PI * 2 - Math.PI / 2;
      pts.push({x: cx + Math.cos(a) * outerR, y: cy + Math.sin(a) * outerR});
    }
    const skip = 1 + Math.floor(r() * (np - 1));
    ctx.beginPath(); let idx = 0; ctx.moveTo(pts[0].x, pts[0].y);
    for (let i = 0; i < np; i++) { idx = (idx + skip) % np; ctx.lineTo(pts[idx].x, pts[idx].y); }
    ctx.closePath(); ctx.strokeStyle = atoms.palette[1]; ctx.lineWidth = 1.2; ctx.globalAlpha = 0.5; ctx.stroke();
    for (let i = 0; i < 3; i++) {
      const ir = outerR * (0.2 + r() * 0.4);
      ctx.beginPath(); ctx.arc(cx, cy, ir, r() * Math.PI * 2, r() * Math.PI * 2 + Math.PI * (0.5 + r()));
      ctx.strokeStyle = atoms.palette[(i + 2) % atoms.palette.length]; ctx.globalAlpha = 0.3; ctx.stroke();
    }
    for (const p of pts) { ctx.beginPath(); ctx.arc(p.x, p.y, 3, 0, Math.PI * 2); ctx.fillStyle = atoms.palette[0]; ctx.globalAlpha = 0.6; ctx.fill(); }
  } else if (geo === 'nebula') {
    const particles = 600 + Math.floor(atoms.intensity * 2000);
    const centers = [{x: w * (0.3 + r() * 0.4), y: h * (0.3 + r() * 0.4), rad: Math.min(w, h) * (0.15 + r() * 0.2)},
      {x: w * (0.2 + r() * 0.6), y: h * (0.2 + r() * 0.6), rad: Math.min(w, h) * (0.1 + r() * 0.25)}];
    for (let i = 0; i < particles; i++) {
      const c = centers[Math.floor(r() * centers.length)];
      const a = r() * Math.PI * 2;
      const d = c.rad * Math.sqrt(r());
      ctx.beginPath(); ctx.arc(c.x + Math.cos(a) * d, c.y + Math.sin(a) * d, 1 + r() * 4, 0, Math.PI * 2);
      ctx.fillStyle = atoms.palette[Math.floor(r() * atoms.palette.length)];
      ctx.globalAlpha = 0.02 + r() * 0.1; ctx.fill();
    }
  } else if (geo === 'radial') {
    const cx = w / 2, cy = h / 2;
    const rays = 12 + Math.floor(r() * 24);
    for (let i = 0; i < rays; i++) {
      const a = (i / rays) * Math.PI * 2;
      const len = Math.min(w, h) * (0.2 + r() * 0.3);
      ctx.beginPath(); ctx.moveTo(cx, cy);
      ctx.lineTo(cx + Math.cos(a) * len, cy + Math.sin(a) * len);
      ctx.strokeStyle = atoms.palette[i % atoms.palette.length];
      ctx.lineWidth = 0.5 + r() * 2; ctx.globalAlpha = 0.15 + r() * 0.2; ctx.stroke();
    }
  } else if (geo === 'crystal') {
    const nc = 4 + Math.floor(atoms.intensity * 6);
    for (let c = 0; c < nc; c++) {
      const cx = w * (0.1 + r() * 0.8), cy = h * (0.1 + r() * 0.8);
      const facets = 4 + Math.floor(r() * 4), sz = 20 + r() * Math.min(w, h) * 0.15;
      const rot = r() * Math.PI;
      ctx.beginPath();
      for (let i = 0; i <= facets; i++) {
        const a = rot + (i / facets) * Math.PI * 2;
        const vr = sz * (0.7 + r() * 0.3);
        const vx = cx + Math.cos(a) * vr, vy = cy + Math.sin(a) * vr * 1.5;
        i === 0 ? ctx.moveTo(vx, vy) : ctx.lineTo(vx, vy);
      }
      ctx.closePath();
      const g = ctx.createLinearGradient(cx - sz, cy - sz, cx + sz, cy + sz);
      g.addColorStop(0, atoms.palette[c % atoms.palette.length] + '33');
      g.addColorStop(1, atoms.palette[(c + 1) % atoms.palette.length] + '22');
      ctx.fillStyle = g; ctx.globalAlpha = 0.3; ctx.fill();
      ctx.strokeStyle = atoms.palette[c % atoms.palette.length]; ctx.lineWidth = 0.8; ctx.globalAlpha = 0.4; ctx.stroke();
    }
  } else {
    // Mixed — flow field
    const lines = 100 + Math.floor(atoms.intensity * 300);
    const steps = 30 + Math.floor(r() * 40);
    const freq = 0.5 + r() * 3;
    const phase = r() * Math.PI * 2;
    for (let i = 0; i < lines; i++) {
      let x = r() * w, y = r() * h;
      ctx.beginPath(); ctx.moveTo(x, y);
      for (let s = 0; s < steps; s++) {
        const a = Math.sin(x * freq / w + phase) * Math.cos(y * freq / h + phase) * Math.PI * 2;
        x += Math.cos(a) * 3; y += Math.sin(a) * 3;
        ctx.lineTo(x, y);
      }
      ctx.strokeStyle = atoms.palette[i % atoms.palette.length];
      ctx.lineWidth = 0.3 + r() * 1.2; ctx.globalAlpha = 0.08 + r() * 0.15; ctx.stroke();
    }
  }
}

// CITRINITAS — Illumination. Glow, radiance, depth.
function citrinitas(ctx, w, h, r, atoms) {
  // Radial glow from center
  const cx = w * (0.3 + r() * 0.4), cy = h * (0.3 + r() * 0.4);
  const maxR = Math.max(w, h) * 0.8;
  const grad = ctx.createRadialGradient(cx, cy, 0, cx, cy, maxR);
  grad.addColorStop(0, atoms.palette[0] + '20');
  grad.addColorStop(0.4, atoms.palette[1 % atoms.palette.length] + '0a');
  grad.addColorStop(1, 'transparent');
  ctx.globalAlpha = 1;
  ctx.fillStyle = grad;
  ctx.fillRect(0, 0, w, h);

  // Highlight particles — bright sparks
  const sparks = 20 + Math.floor(atoms.intensity * 50);
  for (let i = 0; i < sparks; i++) {
    const sx = r() * w, sy = r() * h;
    const sr = 1 + r() * 3;
    const sg = ctx.createRadialGradient(sx, sy, 0, sx, sy, sr * 4);
    sg.addColorStop(0, atoms.palette[Math.floor(r() * atoms.palette.length)] + 'aa');
    sg.addColorStop(1, 'transparent');
    ctx.fillStyle = sg;
    ctx.globalAlpha = 0.3 + r() * 0.5;
    ctx.fillRect(sx - sr * 4, sy - sr * 4, sr * 8, sr * 8);
  }
}

// RUBEDO — Completion. Final color, harmony, the stone.
function rubedo(ctx, w, h, r, atoms) {
  // Color wash overlay
  const grad = ctx.createLinearGradient(0, 0, w, h);
  grad.addColorStop(0, atoms.palette[0] + '12');
  grad.addColorStop(0.5, atoms.palette[1 % atoms.palette.length] + '08');
  grad.addColorStop(1, atoms.palette[2 % atoms.palette.length] + '10');
  ctx.globalAlpha = 1;
  ctx.fillStyle = grad;
  ctx.fillRect(0, 0, w, h);

  // Vignette
  const vg = ctx.createRadialGradient(w / 2, h / 2, Math.min(w, h) * 0.3, w / 2, h / 2, Math.max(w, h) * 0.7);
  vg.addColorStop(0, 'transparent');
  vg.addColorStop(1, 'rgba(0,0,0,0.4)');
  ctx.fillStyle = vg;
  ctx.fillRect(0, 0, w, h);

  // Signature — tiny L7 mark
  ctx.globalAlpha = 0.08;
  ctx.fillStyle = atoms.palette[0];
  ctx.font = '9px monospace';
  ctx.fillText('L7', w - 20, h - 8);
}

// ═══ GENERATE ═══
function generate(parentSeed) {
  const prompt = document.getElementById('prompt').value.trim();
  if (!prompt && !parentSeed) return;

  const stageSelect = document.getElementById('stage').value;
  const count = parseInt(document.getElementById('count').value);
  const complexity = parseInt(document.getElementById('complexity').value) / 10;
  const astrocyte = parseInt(document.getElementById('astrocyte').value) / 100;
  const size = parseInt(document.getElementById('size').value);

  const atoms = atomize(prompt || 'creation');
  atoms.intensity = Math.max(atoms.intensity, complexity);

  const baseSeed = parentSeed || atoms.hash;

  grid.innerHTML = '';
  allCards = [];
  selectedCards.clear();

  if (!parentSeed) {
    history = [{prompt, seed: baseSeed, label: prompt.slice(0, 22)}];
  }
  updateBreadcrumb();
  statusEl.textContent = `Forging ${count} images...`;

  const area = grid.getBoundingClientRect();
  let cols = count <= 4 ? 2 : 3;
  let cardW = Math.floor((area.width - (cols + 1) * 14) / cols);
  let cardH = Math.floor(cardW * 0.85);
  const maxH = Math.floor((area.height - 14 * (Math.ceil(count / cols) + 1)) / Math.ceil(count / cols));
  if (cardH > maxH) { cardH = maxH; cardW = Math.floor(cardH / 0.85); }
  cardW = Math.max(180, Math.min(520, cardW));
  cardH = Math.max(180, Math.min(440, cardH));

  for (let i = 0; i < count; i++) {
    const seed = baseSeed + i * 7919 + Math.floor(astrocyte * 10000) * (i + 1);
    const rand = rng(seed);

    const card = document.createElement('div');
    card.className = 'card';
    card.style.width = cardW + 'px';
    card.style.height = cardH + 'px';
    card.dataset.seed = seed;
    card.dataset.index = i;

    const canvas = document.createElement('canvas');
    const dpr = window.devicePixelRatio || 1;
    canvas.width = size;
    canvas.height = size;
    canvas.style.width = cardW + 'px';
    canvas.style.height = cardH + 'px';

    const ctx = canvas.getContext('2d');
    const cw = size, ch = size;

    // Background
    ctx.fillStyle = '#080c0a';
    ctx.fillRect(0, 0, cw, ch);

    // Apply transmutation stages
    const stages = stageSelect === 'auto'
      ? ['nigredo', 'albedo', 'citrinitas', 'rubedo']
      : [stageSelect];

    // Vary atoms per card for diversity
    const cardAtoms = {...atoms, intensity: atoms.intensity * (0.7 + rand() * 0.6)};
    // Shift geometry for some cards
    const geos = ['circular','angular','hexagonal','wave','fractal','sigil','nebula','radial','crystal','spiral','mandala','mixed'];
    if (i > 0 && atoms.geometry === 'mixed') {
      cardAtoms.geometry = geos[Math.floor(rand() * geos.length)];
    }

    for (const stage of stages) {
      if (stage === 'nigredo') nigredo(ctx, cw, ch, rand, cardAtoms);
      if (stage === 'albedo') albedo(ctx, cw, ch, rand, cardAtoms);
      if (stage === 'citrinitas') citrinitas(ctx, cw, ch, rand, cardAtoms);
      if (stage === 'rubedo') rubedo(ctx, cw, ch, rand, cardAtoms);
    }

    const info = document.createElement('div');
    info.className = 'info';
    info.textContent = `seed: ${seed.toString(16)} | ${cardAtoms.geometry} | stages: ${stages.join('→')}`;

    card.appendChild(canvas);
    card.appendChild(info);

    card.addEventListener('click', (e) => {
      if (e.shiftKey) {
        card.classList.toggle('selected');
        if (selectedCards.has(i)) selectedCards.delete(i); else selectedCards.add(i);
      } else {
        document.querySelectorAll('.card.selected').forEach(c => c.classList.remove('selected'));
        selectedCards.clear();
        selectedCards.add(i);
        card.classList.add('selected');
      }
      infoEl.textContent = `Selected: ${selectedCards.size} | seed: 0x${seed.toString(16)}`;
    });

    card.addEventListener('dblclick', () => {
      history.push({prompt, seed, label: `v${i+1}`});
      generate(seed);
    });

    grid.appendChild(card);
    allCards.push({seed, canvas, card, atoms: cardAtoms});
  }

  statusEl.textContent = `${count} images forged | ${atoms.geometry} | ${atoms.palette[0]}`;
  infoEl.textContent = 'Double-click to evolve | Shift-click multi-select';
}

function evolveSelected() {
  if (selectedCards.size === 0) { statusEl.textContent = 'Select an image first'; return; }
  let combined = 0;
  for (const idx of selectedCards) {
    combined ^= allCards[idx].seed;
    combined = (combined * 31 + 17) | 0;
  }
  history.push({prompt: document.getElementById('prompt').value, seed: Math.abs(combined), label: `evolve(${selectedCards.size})`});
  generate(Math.abs(combined));
}

function saveSelected() {
  if (!allCards.length) return;
  const targets = selectedCards.size > 0 ? [...selectedCards] : [0];
  for (const idx of targets) {
    const c = allCards[idx];
    if (!c) continue;
    const link = document.createElement('a');
    link.download = `imago-${c.seed.toString(16)}.png`;
    link.href = c.canvas.toDataURL('image/png');
    link.click();
  }
  statusEl.textContent = `Saved ${targets.length} image(s)`;
}

function updateBreadcrumb() {
  const el = document.getElementById('breadcrumb');
  el.innerHTML = '';
  history.forEach((h, i) => {
    if (i > 0) { const s = document.createElement('span'); s.className = 'sep'; s.textContent = '\u203A'; el.appendChild(s); }
    const s = document.createElement('span');
    s.textContent = h.label;
    if (i === history.length - 1) s.className = 'active';
    s.addEventListener('click', () => { history = history.slice(0, i + 1); generate(h.seed); });
    el.appendChild(s);
  });
}

document.addEventListener('keydown', (e) => {
  if (e.key === 'Enter' && document.activeElement === document.getElementById('prompt')) generate();
  if (e.key === 'e' && e.metaKey) { e.preventDefault(); evolveSelected(); }
  if (e.key === 's' && e.metaKey && e.shiftKey) { e.preventDefault(); saveSelected(); }
});
</script>
</body></html>
"""###

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var webView: WKWebView!
    var keepAlive: NSObjectProtocol!

    func applicationDidFinishLaunching(_ n: Notification) {
        NSApp.setActivationPolicy(.regular)

        // ─── ANTI-DECAY: Prevent App Nap ───
        keepAlive = ProcessInfo.processInfo.beginActivity(
            options: [.userInitiatedAllowingIdleSystemSleep],
            reason: "L7 Imago — the Empress does not sleep"
        )

        let scr = NSScreen.main?.frame ?? NSRect(x: 0, y: 0, width: 1400, height: 900)
        let w = min(scr.width * 0.88, 1680)
        let h = min(scr.height * 0.88, 1050)

        window = NSWindow(
            contentRect: NSRect(x: (scr.width - w) / 2, y: (scr.height - h) / 2, width: w, height: h),
            styleMask: [.titled, .closable, .resizable, .miniaturizable, .fullSizeContentView],
            backing: .buffered, defer: false
        )
        window.title = "Imago"
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.backgroundColor = Venus.bg
        window.isMovableByWindowBackground = true
        window.minSize = NSSize(width: 700, height: 500)

        let cfg = WKWebViewConfiguration()
        cfg.preferences.setValue(true, forKey: "developerExtrasEnabled")
        webView = WKWebView(frame: window.contentView!.bounds, configuration: cfg)
        webView.autoresizingMask = [.width, .height]
        webView.loadHTMLString(IMAGO_HTML, baseURL: nil)
        window.contentView?.addSubview(webView)

        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        buildMenus()

        // ─── ANTI-DECAY: Keep alive when occluded ───
        NotificationCenter.default.addObserver(
            forName: NSWindow.didChangeOcclusionStateNotification,
            object: window, queue: .main
        ) { [weak self] _ in
            self?.webView.evaluateJavaScript("1", completionHandler: nil)
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ s: NSApplication) -> Bool { true }

    func buildMenus() {
        let bar = NSMenu()
        let appItem = NSMenuItem(); let appMenu = NSMenu()
        appMenu.addItem(withTitle: "About Imago", action: #selector(about), keyEquivalent: "")
        appMenu.addItem(.separator())
        appMenu.addItem(withTitle: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        appItem.submenu = appMenu; bar.addItem(appItem)
        let editItem = NSMenuItem(); let editMenu = NSMenu(title: "Edit")
        editMenu.addItem(withTitle: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x")
        editMenu.addItem(withTitle: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
        editMenu.addItem(withTitle: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v")
        editMenu.addItem(withTitle: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")
        editItem.submenu = editMenu; bar.addItem(editItem)
        NSApp.mainMenu = bar
    }

    @objc func about() {
        let a = NSAlert()
        a.messageText = "\u{2640} Imago \u{2014} The Image Maker"
        a.informativeText = "Planet: Venus\nMetal: Copper\nTarot: The Empress (III)\n\nL7-native image creation.\nWords \u{2192} Atoms \u{2192} Transmutation \u{2192} Image\nNo external models. Built by the Forge.\n\nNigredo \u{2192} Albedo \u{2192} Citrinitas \u{2192} Rubedo\n\n\u{00A9} 2026 Alberto Valido Delgado\nAVLI CLOUD"
        a.runModal()
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
