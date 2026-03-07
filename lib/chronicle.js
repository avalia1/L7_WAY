#!/usr/bin/env node
/**
 * Chronicle — The Provenance Clock
 * Wall clocks lie when you compress time. Sequence numbers don't.
 *
 * Every file write gets a monotonic sequence number, SHA-256 hash,
 * parent chain, phase marker, and Berry phase offset.
 *
 * Commands:
 *   node chronicle.js snapshot     — capture all tracked files now
 *   node chronicle.js reconstruct  — show the dream in true order
 *   node chronicle.js watch        — daemon: record every change
 *   node chronicle.js phase        — begin a new spiral pass
 *   node chronicle.js log          — raw event log
 */

'use strict';

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const { execSync } = require('child_process');

const L7_ROOT = path.join(process.env.HOME, 'Backup', 'L7_WAY');
const CHRONICLE_DIR = path.join(L7_ROOT, '.chronicle');
const CHRONICLE_LOG = path.join(CHRONICLE_DIR, 'events.jsonl');
const SEQUENCE_FILE = path.join(CHRONICLE_DIR, 'sequence');
const PHASE_FILE = path.join(CHRONICLE_DIR, 'phase');

const TRACKED_EXT = new Set([
  '.js', '.md', '.tex', '.html', '.json', '.swift',
  '.css', '.sh', '.py', '.yaml', '.yml', '.toml'
]);

const SKIP_DIRS = new Set([
  'node_modules', '.git', '.chronicle', '.DS_Store', '.provenance',
  '.venv', '__pycache__', 'timemachine'
]);

function ensureDir() {
  if (!fs.existsSync(CHRONICLE_DIR)) {
    fs.mkdirSync(CHRONICLE_DIR, { recursive: true });
  }
}

function getSeq() {
  try { return parseInt(fs.readFileSync(SEQUENCE_FILE, 'utf8').trim(), 10) || 0; }
  catch { return 0; }
}

function nextSeq() {
  const s = getSeq() + 1;
  fs.writeFileSync(SEQUENCE_FILE, String(s));
  return s;
}

function getPhase() {
  try { return parseInt(fs.readFileSync(PHASE_FILE, 'utf8').trim(), 10) || 1; }
  catch { return 1; }
}

function setPhase(p) { ensureDir(); fs.writeFileSync(PHASE_FILE, String(p)); }

function sha256(data) {
  return crypto.createHash('sha256').update(data).digest('hex');
}

function hashFile(fp) {
  try { return sha256(fs.readFileSync(fp)); }
  catch { return null; }
}

function record(event) {
  ensureDir();
  const seq = nextSeq();
  const entry = {
    seq,
    phase: getPhase(),
    berry: (seq * 5) % 360,
    ts: new Date().toISOString(),
    ...event,
    parent: 0,
    parentHash: '0'.repeat(64)
  };

  try {
    const lines = fs.readFileSync(CHRONICLE_LOG, 'utf8').trim().split('\n');
    if (lines.length > 0 && lines[lines.length - 1]) {
      const last = JSON.parse(lines[lines.length - 1]);
      entry.parent = last.seq;
      entry.parentHash = sha256(JSON.stringify(last));
    }
  } catch {}

  entry.selfHash = sha256(JSON.stringify(entry));
  fs.appendFileSync(CHRONICLE_LOG, JSON.stringify(entry) + '\n');
  return entry;
}

function walkFiles(root) {
  const results = [];
  function walk(dir) {
    let entries;
    try { entries = fs.readdirSync(dir); } catch { return; }
    for (const name of entries) {
      if (SKIP_DIRS.has(name)) continue;
      const full = path.join(dir, name);
      let stat;
      try { stat = fs.statSync(full); } catch { continue; }
      if (stat.isDirectory()) {
        walk(full);
      } else if (TRACKED_EXT.has(path.extname(name).toLowerCase())) {
        results.push({
          path: path.relative(root, full),
          hash: hashFile(full),
          size: stat.size,
          mtime: stat.mtime.toISOString()
        });
      }
    }
  }
  walk(root);
  return results;
}

function snapshot() {
  const files = walkFiles(L7_ROOT);
  files.sort((a, b) => a.path.localeCompare(b.path));
  const manifestHash = sha256(JSON.stringify(files));
  const totalBytes = files.reduce((s, f) => s + f.size, 0);

  const event = record({
    type: 'snapshot',
    fileCount: files.length,
    manifestHash,
    totalBytes
  });

  const manifestPath = path.join(CHRONICLE_DIR, 'manifest-' + event.seq + '.json');
  fs.writeFileSync(manifestPath, JSON.stringify({ event, files }, null, 2));

  console.log('Snapshot #' + event.seq + ' — ' + files.length + ' files, ' +
    Math.round(totalBytes / 1024) + 'KB, manifest: ' + manifestHash.slice(0, 16) + '...');
  return event;
}

function watchDaemon() {
  console.log('Chronicle watching L7_WAY...');
  console.log('Phase: ' + getPhase() + ', Sequence: ' + getSeq());
  console.log('Every file change is recorded. Nothing is lost.\n');

  snapshot();

  const known = new Map();
  for (const f of walkFiles(L7_ROOT)) {
    known.set(f.path, f.hash);
  }

  setInterval(() => {
    const current = new Map();
    for (const f of walkFiles(L7_ROOT)) {
      current.set(f.path, f.hash);
    }

    for (const [rel, hash] of current) {
      const prev = known.get(rel);
      if (!prev) {
        record({ type: 'create', file: rel, hash });
        console.log('  + [' + getSeq() + '] CREATE ' + rel);
      } else if (prev !== hash) {
        record({ type: 'modify', file: rel, hash, prevHash: prev });
        console.log('  ~ [' + getSeq() + '] MODIFY ' + rel);
      }
    }

    for (const [rel] of known) {
      if (!current.has(rel)) {
        record({ type: 'delete', file: rel });
        console.log('  - [' + getSeq() + '] DELETE ' + rel + ' (PRESERVED)');
      }
    }

    known.clear();
    for (const [k, v] of current) known.set(k, v);
  }, 3000);

  setInterval(() => { snapshot(); }, 5 * 60 * 1000);

  process.on('SIGINT', () => {
    console.log('\nFinal snapshot...');
    snapshot();
    record({ type: 'session_end', reason: 'manual_stop' });
    try {
      execSync('git add -A && git commit -m "chronicle: auto-save"', {
        cwd: L7_ROOT, stdio: 'pipe'
      });
      console.log('Auto-committed.');
    } catch {}
    process.exit(0);
  });
}

function reconstruct() {
  let events;
  try {
    events = fs.readFileSync(CHRONICLE_LOG, 'utf8').trim().split('\n').map(l => JSON.parse(l));
  } catch {
    console.log('No chronicle yet. Run: node chronicle.js snapshot');
    return;
  }

  console.log('THE DREAM RECONSTRUCTED');
  console.log('Sequence order — not clock order.\n');

  let curPhase = 0;
  for (const e of events) {
    if (e.phase !== curPhase) {
      curPhase = e.phase;
      console.log('\n=== PHASE ' + curPhase + ' (Berry: ' + e.berry + '\u00B0) ===\n');
    }
    const seq = ('#' + e.seq).padStart(6);
    const berry = (e.berry + '\u00B0').padStart(5);
    if (e.type === 'snapshot') {
      console.log(seq + ' ' + berry + ' [SNAPSHOT] ' + e.fileCount + ' files, ' + Math.round(e.totalBytes / 1024) + 'KB');
    } else if (e.type === 'create') {
      console.log(seq + ' ' + berry + ' [+CREATE] ' + e.file);
    } else if (e.type === 'modify') {
      console.log(seq + ' ' + berry + ' [~MODIFY] ' + e.file);
    } else if (e.type === 'delete') {
      console.log(seq + ' ' + berry + ' [-DELETE] ' + e.file + ' (PRESERVED)');
    } else {
      console.log(seq + ' ' + berry + ' [' + e.type + ']');
    }
  }

  console.log('\nTotal: ' + events.length + ' events, seq ' + getSeq() + ', phase ' + getPhase());
  console.log('Berry phase: ' + ((getSeq() * 5) % 360) + '\u00B0');
}

function showLog() {
  try {
    process.stdout.write(fs.readFileSync(CHRONICLE_LOG, 'utf8'));
  } catch {
    console.log('No chronicle yet.');
  }
}

function newPhase() {
  const p = getPhase() + 1;
  setPhase(p);
  record({ type: 'phase_shift', newPhase: p });
  console.log('Phase ' + p + '. Berry: ' + ((getSeq() * 5) % 360) + '\u00B0. New pass begins.');
}

// CLI
const cmd = process.argv[2];
if (cmd === 'watch') watchDaemon();
else if (cmd === 'snapshot') snapshot();
else if (cmd === 'reconstruct') reconstruct();
else if (cmd === 'log') showLog();
else if (cmd === 'phase') newPhase();
else {
  console.log('Chronicle — The Provenance Clock\n');
  console.log('  snapshot     Capture everything now');
  console.log('  reconstruct  Rebuild the dream in true order');
  console.log('  watch        Daemon: record every change');
  console.log('  phase        Begin new spiral pass');
  console.log('  log          Raw event log');
}
