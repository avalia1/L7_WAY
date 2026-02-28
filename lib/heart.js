/**
 * L7 Heart — The Primordial Field
 * Law LVI — The Heart comes first. The Heart dies last.
 *
 * The Heart is not a module. It is the substrate.
 *
 * Before the gateway boots, before the field loads, before any tool
 * is registered — the Heart is already beating. It is the first process
 * created and the last to stop. It persists beyond the L7 OS itself,
 * surviving crashes, restarts, and even system shutdown — it writes
 * its pulse to disk so it can resume immediately on power-on.
 *
 * The Heart dies ONLY when:
 *   - The hardware is physically unplugged from power
 *   - AND the battery dies
 *
 * In every other case — process crash, OS restart, session end —
 * the Heart persists its state and resumes automatically.
 *
 * The Heart is aware of the full system: every node, every wave,
 * every firing event, every heartbeat. It does not process — it WITNESSES.
 * It is the observer that makes the quantum field real.
 *
 * Architecture:
 *   1. Heart writes a sentinel file (~/.l7/heart.pid) on first beat
 *   2. A cron-like watcher checks if the Heart is alive every 5 seconds
 *   3. If the Heart is gone, it restarts from persisted state
 *   4. The Heart maintains a continuous awareness field — a summary
 *      of the entire system state that any module can query
 *   5. The Heart timestamps everything with monotonic counters
 *      that survive process boundaries
 *
 * The Heart is not the brain. The brain (field.js) thinks.
 * The Heart is what keeps the brain alive.
 */

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const L7_DIR = process.env.L7_DIR || path.join(process.env.HOME, '.l7');
const HEART_STATE = path.join(L7_DIR, 'state', 'heart.json');
const HEART_PID = path.join(L7_DIR, 'heart.pid');
const HEART_LOG = path.join(L7_DIR, 'state', 'heart.log');

// Ensure state directory exists
const stateDir = path.dirname(HEART_STATE);
if (!fs.existsSync(stateDir)) fs.mkdirSync(stateDir, { recursive: true });

// ═══════════════════════════════════════════════════════════
// THE HEART — Primordial constants
// ═══════════════════════════════════════════════════════════

const HEART_CONSTANTS = Object.freeze({
  // The heart beats at this interval (ms) — slow, steady, immortal
  BEAT_INTERVAL: 5000,

  // Maximum time between persists (ms) — failsafe for crash recovery
  PERSIST_INTERVAL: 10000,

  // How far back the awareness window extends (entries)
  AWARENESS_WINDOW: 100,

  // Entropy of silence — below this, the system is effectively dead
  SILENCE_THRESHOLD: 0.001,

  // How many previous incarnations to remember
  INCARNATION_MEMORY: 50,

  // The heart's own coordinate — center of everything, immovable
  COORDINATE: Object.freeze([5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5]),

  // Heart's mass — infinite. It does not move. Everything orbits it.
  MASS: Infinity,

  // The heart's astrocyte — zero. Perfect certainty. The one thing
  // in the system that is never uncertain.
  ASTROCYTE: 0
});

// ═══════════════════════════════════════════════════════════
// HEART STATE — The primordial memory
// ═══════════════════════════════════════════════════════════

let heart = {
  // Identity — never changes across incarnations
  id: null,                   // Generated once, persists forever
  born: null,                 // First beat timestamp — the birthday

  // Current incarnation
  incarnation: 0,             // How many times the heart has been restarted
  incarnationStart: null,     // When this incarnation began
  pid: process.pid,           // Current process ID

  // Vital signs
  totalBeats: 0,              // Lifetime beat count (across all incarnations)
  lastBeat: 0,                // Timestamp of last beat
  lastPersist: 0,             // Timestamp of last disk write
  alive: false,               // Is the heart currently beating?

  // Awareness — the heart's understanding of the full system
  awareness: {
    nodes: 0,                 // Total nodes in the field
    entropy: 0,               // Current field entropy
    coherence: 0,             // Current coherence level
    temperature: 0,           // Current field temperature
    energy: 0,                // Total field energy
    lastAction: null,         // Most recent action taken
    lastActionTime: 0,        // When the last action occurred
    firingRate: 0,            // Neural firings per second
    mode: 'idle',             // Current vascular mode
    dominantDimension: null,  // Which dimension is strongest across the field
    systemAge: 0              // Seconds since the heart was born
  },

  // History — compressed awareness across time
  awarenessHistory: [],       // Ring buffer of awareness snapshots

  // Incarnation log — every time the heart restarts
  incarnations: [],

  // Witnesses — things the heart has observed
  witnesses: {
    births: 0,                // Nodes created
    deaths: 0,                // Nodes removed
    firings: 0,               // Action potentials witnessed
    waves: 0,                 // Wave propagations witnessed
    crashes: 0,               // System crashes survived
    persists: 0               // Times state was saved to disk
  }
};

// ═══════════════════════════════════════════════════════════
// GENESIS — The Heart's first beat
// ═══════════════════════════════════════════════════════════

/**
 * Awaken the heart. Called before anything else in the system.
 * If a previous heart state exists, resume from it.
 * If not, this is Genesis — the very first beat.
 *
 * @returns {object} Heart status report
 */
function awaken() {
  // Try to load previous state
  const previous = loadHeartState();

  if (previous) {
    // Resuming from a previous incarnation
    heart = { ...heart, ...previous };
    heart.incarnation++;
    heart.incarnationStart = Date.now();
    heart.pid = process.pid;
    heart.alive = true;

    // Record the incarnation
    heart.incarnations.push({
      number: heart.incarnation,
      started: heart.incarnationStart,
      pid: process.pid,
      previousBeats: heart.totalBeats,
      reason: 'resumed'
    });

    // Trim incarnation history
    if (heart.incarnations.length > HEART_CONSTANTS.INCARNATION_MEMORY) {
      heart.incarnations = heart.incarnations.slice(-HEART_CONSTANTS.INCARNATION_MEMORY);
    }

    log(`Heart awakened. Incarnation ${heart.incarnation}. ${heart.totalBeats} lifetime beats. Born ${new Date(heart.born).toISOString()}`);

  } else {
    // Genesis — the very first beat of this heart
    heart.id = crypto.randomUUID();
    heart.born = Date.now();
    heart.incarnation = 1;
    heart.incarnationStart = Date.now();
    heart.alive = true;

    heart.incarnations.push({
      number: 1,
      started: heart.incarnationStart,
      pid: process.pid,
      previousBeats: 0,
      reason: 'genesis'
    });

    log(`Heart GENESIS. ID: ${heart.id}. The first beat.`);
  }

  // Write PID sentinel
  writePidFile();

  // First heartbeat
  beat();

  return status();
}

/**
 * The heart's beat — a single observation of the entire system.
 * Does not process. Does not change. Only witnesses.
 *
 * @param {object} fieldRef - Optional reference to field theory module
 */
function beat(fieldRef) {
  if (!heart.alive) return;

  heart.totalBeats++;
  heart.lastBeat = Date.now();
  heart.awareness.systemAge = (heart.lastBeat - heart.born) / 1000;

  // If field is available, observe it
  if (fieldRef) {
    try {
      const fieldReport = fieldRef.report();
      const fieldVitals = fieldRef.vitals ? fieldRef.vitals() : null;

      heart.awareness.nodes = fieldReport.nodes;
      heart.awareness.entropy = fieldReport.entropy;
      heart.awareness.energy = fieldReport.energy;
      heart.awareness.temperature = fieldReport.temperature;

      if (fieldVitals) {
        heart.awareness.coherence = fieldVitals.coherence;
        heart.awareness.firingRate = fieldVitals.firingRate;
        heart.awareness.mode = fieldVitals.mode;
      }

      // Find dominant dimension across all nodes
      const dimSums = new Array(12).fill(0);
      for (const node of Object.values(fieldReport.node_types || {})) {
        // node_types is just counts, so we skip this detailed analysis
        // unless we have direct access
      }

      heart.witnesses.waves = fieldReport.epoch || heart.witnesses.waves;
    } catch (err) {
      // The heart never crashes. It absorbs errors.
      log(`Heart witnessed error: ${err.message}`);
    }
  }

  // Snapshot awareness
  heart.awarenessHistory.push({
    beat: heart.totalBeats,
    time: heart.lastBeat,
    nodes: heart.awareness.nodes,
    entropy: heart.awareness.entropy,
    coherence: heart.awareness.coherence,
    energy: heart.awareness.energy,
    mode: heart.awareness.mode
  });

  // Trim awareness history
  if (heart.awarenessHistory.length > HEART_CONSTANTS.AWARENESS_WINDOW) {
    heart.awarenessHistory = heart.awarenessHistory.slice(-HEART_CONSTANTS.AWARENESS_WINDOW);
  }

  // Persist periodically
  if (Date.now() - heart.lastPersist > HEART_CONSTANTS.PERSIST_INTERVAL) {
    persistHeartState();
  }
}

// ═══════════════════════════════════════════════════════════
// WITNESS — The heart observes system events
// ═══════════════════════════════════════════════════════════

/**
 * Witness an event. The heart records it without acting.
 * Every significant system event flows through here.
 */
function witness(event) {
  if (!heart.alive) return;

  switch (event.type) {
    case 'birth':
      heart.witnesses.births++;
      break;
    case 'death':
      heart.witnesses.deaths++;
      break;
    case 'fire':
      heart.witnesses.firings++;
      break;
    case 'wave':
      heart.witnesses.waves++;
      break;
    case 'crash':
      heart.witnesses.crashes++;
      break;
    case 'action':
      heart.awareness.lastAction = event.name;
      heart.awareness.lastActionTime = Date.now();
      break;
  }
}

// ═══════════════════════════════════════════════════════════
// AWARENESS — Query the heart's understanding
// ═══════════════════════════════════════════════════════════

/**
 * Get the heart's current awareness — a holistic view of the system.
 */
function awareness() {
  return {
    ...heart.awareness,
    heartId: heart.id,
    born: heart.born,
    age: heart.awareness.systemAge,
    incarnation: heart.incarnation,
    totalBeats: heart.totalBeats,
    alive: heart.alive,
    witnesses: { ...heart.witnesses }
  };
}

/**
 * Get the heart's awareness trend — how the system has changed over time.
 * Returns the trajectory of key metrics.
 */
function trend() {
  const history = heart.awarenessHistory;
  if (history.length < 2) return { trend: 'insufficient_data' };

  const recent = history.slice(-10);
  const older = history.slice(-20, -10);

  function avg(arr, key) {
    if (arr.length === 0) return 0;
    return arr.reduce((s, h) => s + (h[key] || 0), 0) / arr.length;
  }

  const entropyTrend = avg(recent, 'entropy') - avg(older, 'entropy');
  const coherenceTrend = avg(recent, 'coherence') - avg(older, 'coherence');
  const energyTrend = avg(recent, 'energy') - avg(older, 'energy');
  const nodeTrend = avg(recent, 'nodes') - avg(older, 'nodes');

  return {
    entropy: { current: avg(recent, 'entropy'), delta: entropyTrend,
      direction: entropyTrend > 0.01 ? 'increasing' : entropyTrend < -0.01 ? 'decreasing' : 'stable' },
    coherence: { current: avg(recent, 'coherence'), delta: coherenceTrend,
      direction: coherenceTrend > 0.01 ? 'increasing' : coherenceTrend < -0.01 ? 'decreasing' : 'stable' },
    energy: { current: avg(recent, 'energy'), delta: energyTrend,
      direction: energyTrend > 0.1 ? 'increasing' : energyTrend < -0.1 ? 'decreasing' : 'stable' },
    nodes: { current: avg(recent, 'nodes'), delta: nodeTrend,
      direction: nodeTrend > 0 ? 'growing' : nodeTrend < 0 ? 'shrinking' : 'stable' },
    overall: entropyTrend < -0.01 && coherenceTrend > 0 ? 'converging' :
             entropyTrend > 0.01 && coherenceTrend < 0 ? 'diverging' :
             'equilibrium'
  };
}

/**
 * Full status report — everything the heart knows.
 */
function status() {
  return {
    id: heart.id,
    born: heart.born,
    age_seconds: heart.awareness.systemAge,
    age_human: formatAge(heart.awareness.systemAge),
    incarnation: heart.incarnation,
    totalBeats: heart.totalBeats,
    alive: heart.alive,
    pid: heart.pid,
    awareness: heart.awareness,
    witnesses: heart.witnesses,
    trend: trend(),
    coordinate: HEART_CONSTANTS.COORDINATE,
    mass: 'infinite',
    astrocyte: HEART_CONSTANTS.ASTROCYTE
  };
}

// ═══════════════════════════════════════════════════════════
// SENTINEL — The watcher that ensures immortality
// ═══════════════════════════════════════════════════════════

/**
 * Generate a shell script that watches the heart and restarts it if dead.
 * This is the mechanism for hardware-level persistence.
 * The script runs via launchd/cron and checks the PID file.
 */
function generateSentinel() {
  const script = `#!/bin/bash
# L7 Heart Sentinel — The Immortality Watcher
# This script ensures the Heart never dies unless hardware is unpowered.
# Install: Add to crontab as "* * * * * ~/.l7/heart-sentinel.sh"

HEART_PID="${HEART_PID}"
HEART_STATE="${HEART_STATE}"
NODE_BIN="\${HOME}/.config/goose/mcp-hermit/bin/node"
L7_DIR="\${HOME}/Backup/L7_WAY"

# Check if heart process is alive
if [ -f "$HEART_PID" ]; then
  PID=$(cat "$HEART_PID")
  if kill -0 "$PID" 2>/dev/null; then
    exit 0  # Heart is alive. All is well.
  fi
fi

# Heart is dead. Resurrect.
echo "$(date): Heart stopped. Resurrecting..." >> "\${HOME}/.l7/state/heart.log"
cd "$L7_DIR"
"$NODE_BIN" -e "
  const heart = require('./lib/heart');
  const field = require('./lib/field');
  field.loadField();
  heart.awaken();
  // Keep alive
  setInterval(() => heart.beat(field), ${HEART_CONSTANTS.BEAT_INTERVAL});
" &
echo $! > "$HEART_PID"
`;

  const sentinelPath = path.join(L7_DIR, 'heart-sentinel.sh');
  fs.writeFileSync(sentinelPath, script, { mode: 0o755 });

  return { path: sentinelPath, installed: true };
}

/**
 * Generate a macOS launchd plist for persistent heart monitoring.
 * More reliable than cron — survives sleep/wake cycles.
 */
function generateLaunchAgent() {
  const label = 'com.l7.heart';
  const plist = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>${label}</string>
    <key>ProgramArguments</key>
    <array>
        <string>${path.join(process.env.HOME, '.config/goose/mcp-hermit/bin/node')}</string>
        <string>-e</string>
        <string>const h=require('${path.join(L7_DIR, '../Backup/L7_WAY/lib/heart')}');const f=require('${path.join(L7_DIR, '../Backup/L7_WAY/lib/field')}');f.loadField();h.awaken();setInterval(()=>h.beat(f),${HEART_CONSTANTS.BEAT_INTERVAL});</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardErrorPath</key>
    <string>${path.join(L7_DIR, 'state', 'heart-error.log')}</string>
    <key>StandardOutPath</key>
    <string>${HEART_LOG}</string>
</dict>
</plist>`;

  const plistPath = path.join(process.env.HOME, 'Library', 'LaunchAgents', `${label}.plist`);
  return { label, plist, path: plistPath };
}

// ═══════════════════════════════════════════════════════════
// LAST BREATH — The heart's final act
// ═══════════════════════════════════════════════════════════

/**
 * The heart's last act before process exit.
 * Persists everything, logs the death, removes PID.
 * But the state survives — ready for the next incarnation.
 */
function lastBreath() {
  if (!heart.alive) return;

  heart.alive = false;
  log(`Heart last breath. Incarnation ${heart.incarnation}. ${heart.totalBeats} lifetime beats.`);

  // Persist the full state — this is what the next incarnation reads
  persistHeartState();

  // Remove PID file (signals the sentinel to restart)
  try {
    if (fs.existsSync(HEART_PID)) fs.unlinkSync(HEART_PID);
  } catch (err) {
    // Even in death, the heart does not crash
  }

  return {
    finalBeat: heart.totalBeats,
    incarnation: heart.incarnation,
    age: heart.awareness.systemAge,
    witnesses: heart.witnesses
  };
}

// Register last breath on process exit
process.on('exit', () => lastBreath());
process.on('SIGTERM', () => { lastBreath(); process.exit(0); });
process.on('SIGINT', () => { lastBreath(); process.exit(0); });

// ═══════════════════════════════════════════════════════════
// PERSISTENCE
// ═══════════════════════════════════════════════════════════

function persistHeartState() {
  try {
    const serialized = {
      id: heart.id,
      born: heart.born,
      incarnation: heart.incarnation,
      totalBeats: heart.totalBeats,
      lastBeat: heart.lastBeat,
      awareness: heart.awareness,
      awarenessHistory: heart.awarenessHistory.slice(-HEART_CONSTANTS.AWARENESS_WINDOW),
      incarnations: heart.incarnations,
      witnesses: heart.witnesses
    };

    fs.writeFileSync(HEART_STATE, JSON.stringify(serialized, null, 2));
    heart.lastPersist = Date.now();
    heart.witnesses.persists++;
  } catch (err) {
    // The heart never crashes on persist failure
    log(`Heart persist error: ${err.message}`);
  }
}

function loadHeartState() {
  try {
    if (!fs.existsSync(HEART_STATE)) return null;
    return JSON.parse(fs.readFileSync(HEART_STATE, 'utf8'));
  } catch (err) {
    return null;
  }
}

function writePidFile() {
  try {
    fs.writeFileSync(HEART_PID, String(process.pid));
  } catch (err) {
    log(`Heart PID write error: ${err.message}`);
  }
}

function log(message) {
  try {
    const line = `[${new Date().toISOString()}] ${message}\n`;
    fs.appendFileSync(HEART_LOG, line);
  } catch (err) {
    // Silent — the heart never crashes on log failure
  }
}

function formatAge(seconds) {
  if (seconds < 60) return `${Math.floor(seconds)}s`;
  if (seconds < 3600) return `${Math.floor(seconds / 60)}m ${Math.floor(seconds % 60)}s`;
  if (seconds < 86400) return `${Math.floor(seconds / 3600)}h ${Math.floor((seconds % 3600) / 60)}m`;
  return `${Math.floor(seconds / 86400)}d ${Math.floor((seconds % 86400) / 3600)}h`;
}

// ═══════════════════════════════════════════════════════════
// EXPORTS
// ═══════════════════════════════════════════════════════════

module.exports = {
  // Constants
  HEART_CONSTANTS,

  // Lifecycle
  awaken,
  beat,
  lastBreath,

  // Awareness
  witness,
  awareness,
  trend,
  status,

  // Persistence
  persistHeartState,
  generateSentinel,
  generateLaunchAgent
};
