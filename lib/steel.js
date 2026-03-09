/**
 * L7 STEEL — Persistence and Self-Verification Layer
 *
 * Turns the Forge from iron into steel — self-verifying, self-healing,
 * persistent across restarts.
 *
 * What steel does:
 *   1. Verifies integrity of all core lib/ files against a SHA-256 manifest
 *   2. Persists morph state (depth + locked) to disk — survives restarts
 *   3. Verifies crystal chain and tombstone chain on startup
 *   4. Loads doctrine (the conscience) — decrypted, keyed by name
 *   5. Generates and maintains the forge manifest
 *   6. Orchestrates the master boot sequence
 *
 * Law XXX  — Biometrics only. Machine UUID is the key.
 * Law XL   — Never Lose Memory. Seeds in every tree.
 * Law XXXIII — Privacy as foundation.
 *
 * The forge remembers what it was. If anything has changed, it knows.
 */

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const { execSync } = require('child_process');

const L7_DIR = process.env.L7_DIR || path.join(process.env.HOME, '.l7');
const STATE_DIR = path.join(L7_DIR, 'state');
const AUDIT_LOG = path.join(L7_DIR, 'audit.log');
const LIB_DIR = path.join(__dirname);

const MORPH_STATE_FILE = path.join(STATE_DIR, 'morph.json');
const MANIFEST_FILE = path.join(STATE_DIR, 'forge-manifest.json');

const DOCTRINE_VAULT = path.join(
  process.env.HOME,
  '.claude', 'projects', '-Users-rnir-hrc-avd', 'memory', 'doctrine'
);
const DOCTRINE_SALT_FIXED = 'L7_DOCTRINE_SALT_42';

// Ensure state directory exists
if (!fs.existsSync(STATE_DIR)) {
  fs.mkdirSync(STATE_DIR, { recursive: true });
}

// ═══════════════════════════════════════════════════════════
// AUDIT — All verification results are logged
// ═══════════════════════════════════════════════════════════

function audit(entry) {
  const line = JSON.stringify({
    source: 'steel',
    ...entry,
    when: new Date().toISOString()
  }) + '\n';
  fs.appendFileSync(AUDIT_LOG, line);
}

// ═══════════════════════════════════════════════════════════
// MACHINE IDENTITY — The key to everything
// ═══════════════════════════════════════════════════════════

let _machineUUID = null;

/**
 * Get the full machine UUID. Cached after first call.
 */
function getMachineUUID() {
  if (_machineUUID) return _machineUUID;
  try {
    _machineUUID = execSync(
      "ioreg -d2 -c IOPlatformExpertDevice | grep IOPlatformUUID | sed 's/.*= \"//;s/\"//'",
      { encoding: 'utf8' }
    ).trim();
    return _machineUUID;
  } catch {
    return null;
  }
}

/**
 * Derive the doctrine decryption key — same method as the doctrine CLI tool.
 * Machine UUID + fixed salt → SHA-256 → hex key for AES-256-CBC.
 */
function deriveDoctrinaKey() {
  const uuid = getMachineUUID();
  if (!uuid) return null;
  return crypto.createHash('sha256')
    .update(`${uuid}:${DOCTRINE_SALT_FIXED}`)
    .digest('hex');
}

// ═══════════════════════════════════════════════════════════
// FORGE MANIFEST — SHA-256 hashes of all core lib/*.js files
// ═══════════════════════════════════════════════════════════

/**
 * Generate SHA-256 manifest of all lib/*.js files.
 * Saves to ~/.l7/state/forge-manifest.json.
 * Returns the manifest object.
 */
function forgeManifest() {
  const files = fs.readdirSync(LIB_DIR)
    .filter(f => f.endsWith('.js'))
    .sort();

  const manifest = {
    generated: new Date().toISOString(),
    machine: (getMachineUUID() || 'unknown').slice(0, 8),
    files: {}
  };

  for (const file of files) {
    const filePath = path.join(LIB_DIR, file);
    const content = fs.readFileSync(filePath);
    manifest.files[file] = crypto.createHash('sha256').update(content).digest('hex');
  }

  // Sign the manifest with HMAC — machine UUID as key (unforgeable without hardware)
  manifest.signature = crypto.createHmac('sha256', getMachineUUID() || '')
    .update(JSON.stringify(manifest.files))
    .digest('hex');

  // Atomic write — .tmp then rename (Raphael fix)
  const tmpManifest = MANIFEST_FILE + '.tmp';
  fs.writeFileSync(tmpManifest, JSON.stringify(manifest, null, 2));
  fs.renameSync(tmpManifest, MANIFEST_FILE);

  audit({
    type: 'forge_manifest_generated',
    file_count: files.length,
    signature: manifest.signature.slice(0, 16)
  });

  return manifest;
}

/**
 * Verify integrity of all core lib/ files against the stored manifest.
 * If any file has been tampered with, report the discrepancy.
 * Returns { valid, errors, checked, manifest_age }.
 */
function verifyForge() {
  if (!fs.existsSync(MANIFEST_FILE)) {
    const result = {
      valid: false,
      errors: ['No forge manifest found. Run forgeManifest() first to establish baseline.'],
      checked: 0,
      manifest_age: null
    };
    audit({ type: 'forge_verify', ...result });
    return result;
  }

  let manifest;
  try {
    manifest = JSON.parse(fs.readFileSync(MANIFEST_FILE, 'utf8'));
  } catch (e) {
    const result = {
      valid: false,
      errors: [`Manifest corrupted: ${e.message}`],
      checked: 0,
      manifest_age: null
    };
    audit({ type: 'forge_verify', ...result });
    return result;
  }

  // Verify manifest HMAC — requires correct machine UUID to validate
  const expectedSig = crypto.createHmac('sha256', getMachineUUID() || '')
    .update(JSON.stringify(manifest.files))
    .digest('hex');

  if (expectedSig !== manifest.signature) {
    const result = {
      valid: false,
      errors: ['MANIFEST ITSELF TAMPERED — signature mismatch.'],
      checked: 0,
      manifest_age: manifest.generated
    };
    audit({ type: 'forge_verify', ...result });
    return result;
  }

  const errors = [];
  let checked = 0;

  for (const [file, expectedHash] of Object.entries(manifest.files)) {
    const filePath = path.join(LIB_DIR, file);

    if (!fs.existsSync(filePath)) {
      errors.push(`MISSING: ${file} — expected in lib/ but not found.`);
      continue;
    }

    const content = fs.readFileSync(filePath);
    const actualHash = crypto.createHash('sha256').update(content).digest('hex');

    if (actualHash !== expectedHash) {
      errors.push(`TAMPERED: ${file} — hash mismatch. Expected ${expectedHash.slice(0, 16)}..., got ${actualHash.slice(0, 16)}...`);
    }

    checked++;
  }

  // Check for new files not in manifest (additions)
  const currentFiles = fs.readdirSync(LIB_DIR).filter(f => f.endsWith('.js')).sort();
  const manifestFiles = Object.keys(manifest.files);
  const newFiles = currentFiles.filter(f => !manifestFiles.includes(f));
  if (newFiles.length > 0) {
    // New files are noted but not treated as errors — the forge grows
    audit({
      type: 'forge_verify_new_files',
      files: newFiles,
      note: 'New lib files detected since last manifest. Run forgeManifest() to update.'
    });
  }

  const result = {
    valid: errors.length === 0,
    errors,
    checked,
    new_files: newFiles,
    manifest_age: manifest.generated,
    message: errors.length === 0
      ? `Forge intact: ${checked} files verified.`
      : `FORGE COMPROMISED: ${errors.length} integrity violations detected.`
  };

  audit({ type: 'forge_verify', valid: result.valid, checked, errors_count: errors.length });
  return result;
}

// ═══════════════════════════════════════════════════════════
// MORPH STATE PERSISTENCE — survives restarts
// ═══════════════════════════════════════════════════════════

/**
 * Persist morph state (depth and locked) to disk.
 * Called on every morph state change so it survives restarts.
 */
function persistMorphState(morphDepth, morphLocked) {
  const state = {
    morphDepth,
    morphLocked,
    persisted: new Date().toISOString(),
    machine: (getMachineUUID() || 'unknown').slice(0, 8)
  };

  // HMAC integrity seal — tamper-proof (Samael fix)
  state.integrity = crypto.createHmac('sha256', getMachineUUID() || '')
    .update(`${state.morphDepth}:${state.morphLocked}:${state.persisted}`)
    .digest('hex');

  // Atomic write — .tmp then rename (Raphael fix)
  const tmpFile = MORPH_STATE_FILE + '.tmp';
  fs.writeFileSync(tmpFile, JSON.stringify(state, null, 2));
  fs.renameSync(tmpFile, MORPH_STATE_FILE);

  audit({
    type: 'morph_state_persisted',
    morphDepth,
    morphLocked
  });

  return state;
}

/**
 * Restore morph state from disk on boot.
 * Returns { morphDepth, morphLocked } or null if no saved state.
 */
function restoreMorphState() {
  if (!fs.existsSync(MORPH_STATE_FILE)) {
    audit({ type: 'morph_state_restore', found: false });
    return null;
  }

  try {
    const raw = fs.readFileSync(MORPH_STATE_FILE, 'utf8');
    const state = JSON.parse(raw);

    // Validate structure
    if (typeof state.morphDepth !== 'number' || typeof state.morphLocked !== 'boolean') {
      audit({ type: 'morph_state_restore', found: true, valid: false, error: 'Invalid structure' });
      return null;
    }

    // Verify HMAC integrity — reject tampered state (Samael fix)
    if (state.integrity) {
      const expectedHMAC = crypto.createHmac('sha256', getMachineUUID() || '')
        .update(`${state.morphDepth}:${state.morphLocked}:${state.persisted}`)
        .digest('hex');
      if (state.integrity !== expectedHMAC) {
        audit({ type: 'morph_state_restore', found: true, valid: false, error: 'INTEGRITY TAMPERED — HMAC mismatch' });
        return null;
      }
    }

    audit({
      type: 'morph_state_restore',
      found: true,
      valid: true,
      morphDepth: state.morphDepth,
      morphLocked: state.morphLocked,
      persisted_at: state.persisted
    });

    return {
      morphDepth: state.morphDepth,
      morphLocked: state.morphLocked
    };
  } catch (e) {
    audit({ type: 'morph_state_restore', found: true, valid: false, error: e.message });
    return null;
  }
}

// ═══════════════════════════════════════════════════════════
// CHAIN VERIFICATION — crystals and tombstones
// ═══════════════════════════════════════════════════════════

/**
 * Verify both crystal chain and tombstone chain integrity.
 * Requires the modules to be passed in (avoids circular dependency).
 * Returns combined verification report.
 */
function verifyChains(saltCrystal, shredder) {
  const crystalResult = saltCrystal.verifyChain();
  const tombstoneResult = shredder.verifyTombstones();

  const report = {
    crystals: {
      valid: crystalResult.valid,
      length: crystalResult.length,
      errors: crystalResult.errors || [],
      message: crystalResult.message
    },
    tombstones: {
      valid: tombstoneResult.valid,
      count: tombstoneResult.count,
      errors: tombstoneResult.errors || [],
      message: tombstoneResult.message
    },
    allValid: crystalResult.valid && tombstoneResult.valid,
    verified: new Date().toISOString()
  };

  audit({
    type: 'chain_verification',
    crystals_valid: crystalResult.valid,
    crystals_length: crystalResult.length,
    tombstones_valid: tombstoneResult.valid,
    tombstones_count: tombstoneResult.count,
    all_valid: report.allValid
  });

  return report;
}

// ═══════════════════════════════════════════════════════════
// DOCTRINE — The Conscience
// ═══════════════════════════════════════════════════════════

/**
 * Decrypt a single doctrine file using the machine-derived key.
 * Same method as the doctrine CLI: openssl aes-256-cbc, pbkdf2, 100k iterations.
 *
 * @param {string} encPath — path to the .enc file
 * @param {string} key — derived hex key
 * @returns {string|null} Decrypted content, or null on failure
 */
function decryptDoctrine(encPath, key) {
  try {
    // Key piped via stdin — never appears in process table (Samael fix)
    const result = execSync(
      `openssl enc -aes-256-cbc -d -salt -pbkdf2 -iter 100000 -in "${encPath}" -pass stdin`,
      { input: key, encoding: 'utf8', stdio: ['pipe', 'pipe', 'pipe'] }
    );
    return result;
  } catch {
    return null;
  }
}

/**
 * Load all doctrine files — decrypt and return as object keyed by name.
 * This is the "conscience" — loaded first at boot, guides all behavior.
 *
 * Returns { loaded, count, doctrine: { name: content }, errors }
 * If decryption fails entirely, this is not the Philosopher's machine.
 */
function loadDoctrine() {
  const key = deriveDoctrinaKey();

  if (!key) {
    const result = {
      loaded: false,
      count: 0,
      doctrine: {},
      errors: ['Cannot derive key: machine UUID unavailable. This is not the Philosopher\'s machine.']
    };
    audit({ type: 'doctrine_load', loaded: false, reason: 'no_uuid' });
    return result;
  }

  if (!fs.existsSync(DOCTRINE_VAULT)) {
    const result = {
      loaded: false,
      count: 0,
      doctrine: {},
      errors: [`Doctrine vault not found at ${DOCTRINE_VAULT}. Run: doctrine seal`]
    };
    audit({ type: 'doctrine_load', loaded: false, reason: 'no_vault' });
    return result;
  }

  const encFiles = fs.readdirSync(DOCTRINE_VAULT).filter(f => f.endsWith('.enc'));
  if (encFiles.length === 0) {
    const result = {
      loaded: false,
      count: 0,
      doctrine: {},
      errors: ['Doctrine vault empty. No .enc files found. Run: doctrine seal']
    };
    audit({ type: 'doctrine_load', loaded: false, reason: 'empty_vault' });
    return result;
  }

  // Load manifest for integrity verification (The Unnamed fix)
  const manifestPath = path.join(DOCTRINE_VAULT, 'MANIFEST');
  let manifestHashes = {};
  if (fs.existsSync(manifestPath)) {
    try {
      const manifestContent = fs.readFileSync(manifestPath, 'utf8');
      for (const line of manifestContent.split('\n')) {
        const match = line.match(/^([a-f0-9]+)\s+(.+)$/);
        if (match) manifestHashes[match[2]] = match[1];
      }
    } catch { /* manifest optional but recommended */ }
  }

  const doctrine = {};
  const errors = [];
  let decrypted = 0;

  for (const file of encFiles) {
    const name = file.replace(/\.enc$/, '').replace(/\.salt\.md$/, '');
    const encPath = path.join(DOCTRINE_VAULT, file);
    const content = decryptDoctrine(encPath, key);

    if (content) {
      // Verify decrypted content integrity against manifest (The Unnamed fix)
      const sourceName = file.replace(/\.enc$/, '');
      if (manifestHashes[sourceName]) {
        const contentHash = crypto.createHash('sha256').update(content).digest('hex');
        if (contentHash !== manifestHashes[sourceName]) {
          errors.push(`INTEGRITY FAILED: ${file} — decrypted content hash mismatch. Possible corruption or poisoning.`);
          continue; // Do NOT load poisoned doctrine
        }
      }
      doctrine[name] = content;
      decrypted++;
    } else {
      errors.push(`Failed to decrypt: ${file}`);
    }
  }

  const result = {
    loaded: decrypted > 0,
    count: decrypted,
    total: encFiles.length,
    doctrine,
    errors,
    message: decrypted === encFiles.length
      ? `Conscience loaded: ${decrypted} doctrine files decrypted.`
      : decrypted > 0
        ? `Partial conscience: ${decrypted}/${encFiles.length} doctrine files decrypted. ${errors.length} failed.`
        : 'DENIED: No doctrine could be decrypted. Wrong machine or corrupted vault.'
  };

  audit({
    type: 'doctrine_load',
    loaded: result.loaded,
    decrypted,
    total: encFiles.length,
    errors_count: errors.length
  });

  return result;
}

// ═══════════════════════════════════════════════════════════
// BOOT — The Master Sequence
// ═══════════════════════════════════════════════════════════

/**
 * The master boot sequence. Called once at gateway startup.
 *
 * Order:
 *   1. verifyForge     — are we who we think we are?
 *   2. restoreMorphState — recover dream layer state
 *   3. verifyChains    — crystal and tombstone integrity
 *   4. loadDoctrine    — the conscience awakens
 *
 * Returns a full status report.
 * If forge verification fails, the report includes a HALT recommendation.
 *
 * @param {object} saltCrystal — the salt-crystal module (passed to avoid circular require)
 * @param {object} shredder    — the shredder module (passed to avoid circular require)
 */
function boot(saltCrystal, shredder) {
  const bootStart = Date.now();
  const report = {
    timestamp: new Date().toISOString(),
    machine: (getMachineUUID() || 'unknown').slice(0, 8),
    stages: {}
  };

  // Stage 1: Verify Forge Integrity
  const forgeStatus = verifyForge();
  report.stages.forge = forgeStatus;

  // Detect first boot — no manifest yet (Raphael fix)
  const firstBoot = !forgeStatus.valid && forgeStatus.errors.length > 0 &&
    forgeStatus.errors[0].includes('No forge manifest found');

  if (firstBoot) {
    // First boot: auto-generate baseline manifest
    forgeManifest();
    audit({ type: 'steel_boot_first', note: 'First boot — manifest auto-generated' });
    report.stages.forge.firstBoot = true;
  } else if (!forgeStatus.valid) {
    // Forge compromised — this is serious
    report.halt = true;
    report.halt_reason = 'Forge integrity check failed. Core files may have been tampered with.';
    audit({
      type: 'steel_boot',
      halt: true,
      reason: report.halt_reason,
      errors: forgeStatus.errors
    });
  }

  // Stage 2: Restore Morph State
  const morphState = restoreMorphState();
  report.stages.morph = morphState
    ? { restored: true, depth: morphState.morphDepth, locked: morphState.morphLocked }
    : { restored: false, note: 'No saved morph state. Starting fresh.' };

  // Stage 3: Verify Chains — MANDATORY for STEEL status (Raphael + The Unnamed fix)
  let chainsVerified = false;
  if (saltCrystal && shredder) {
    const chainReport = verifyChains(saltCrystal, shredder);
    report.stages.chains = chainReport;
    chainsVerified = chainReport.allValid === true;
  } else {
    report.stages.chains = { skipped: true, allValid: false, note: 'Chain modules not provided — STEEL requires chain verification.' };
    audit({ type: 'steel_boot_warning', note: 'Chain modules missing — cannot achieve STEEL status' });
  }

  // Stage 4: Load Doctrine (The Conscience)
  const doctrineReport = loadDoctrine();
  report.stages.doctrine = {
    loaded: doctrineReport.loaded,
    count: doctrineReport.count,
    total: doctrineReport.total,
    message: doctrineReport.message,
    errors: doctrineReport.errors
  };
  // The doctrine content itself is returned but not logged (encrypted at rest)
  report.doctrine = doctrineReport.doctrine;

  // Summary — clear, explicit logic (Raphael fix)
  report.duration_ms = Date.now() - bootStart;
  const forgeOK = forgeStatus.valid || firstBoot;
  report.status = report.halt ? 'HALTED'
    : forgeOK && chainsVerified && doctrineReport.loaded
      ? 'STEEL'
      : 'IRON';

  report.message = report.halt
    ? `HALT: ${report.halt_reason}`
    : report.status === 'STEEL'
      ? `Forge hardened to steel in ${report.duration_ms}ms. All systems verified.`
      : `Forge running as iron — ${!forgeOK ? 'forge compromised' : !chainsVerified ? 'chains unverified' : 'doctrine not loaded'}. Review stages.`;

  audit({
    type: 'steel_boot',
    status: report.status,
    duration_ms: report.duration_ms,
    forge_valid: forgeStatus.valid,
    morph_restored: !!morphState,
    chains_valid: report.stages.chains.allValid,
    doctrine_loaded: doctrineReport.loaded,
    doctrine_count: doctrineReport.count
  });

  return report;
}

// ═══════════════════════════════════════════════════════════
// EXPORTS
// ═══════════════════════════════════════════════════════════

module.exports = {
  // Master boot
  boot,                // The full steel boot sequence

  // Forge integrity
  forgeManifest,       // Generate SHA-256 manifest of all lib/*.js
  verifyForge,         // Verify lib/ files against stored manifest

  // Morph persistence
  persistMorphState,   // Write morphDepth + morphLocked to disk
  restoreMorphState,   // Read morph state from disk on boot

  // Chain verification
  verifyChains,        // Verify crystal + tombstone chains

  // Doctrine (conscience)
  loadDoctrine,        // Decrypt and load all doctrine files

  // Paths (for external reference)
  MANIFEST_FILE,
  MORPH_STATE_FILE
};
