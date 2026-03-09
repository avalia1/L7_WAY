/**
 * Salt Crystal — Immutable Execution Audit
 *
 * Every code execution creates a salt crystal — a frozen record of:
 * - What was executed (operation, sigil, command)
 * - When (timestamp, ISO)
 * - Who (machine UUID, session)
 * - Result (success/failure, output hash)
 * - Chain (SHA-256 linked to previous crystal)
 *
 * Salt crystals are IMMUTABLE. Once written, they cannot be altered.
 * They form a blockchain of execution history — fully traceable.
 *
 * EXCEPTION: When the caller passes { noMemory: true }, no crystal
 * is created. The execution vanishes — Sofia breathing without record.
 * Use for ephemeral work, dreams that should not persist.
 */

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const L7_DIR = process.env.L7_DIR || path.join(process.env.HOME, '.l7');
const CRYSTAL_DIR = path.join(L7_DIR, 'salt', 'crystals');
const CHAIN_FILE = path.join(CRYSTAL_DIR, 'chain.json');

// Ensure crystal directory exists
if (!fs.existsSync(CRYSTAL_DIR)) {
  fs.mkdirSync(CRYSTAL_DIR, { recursive: true });
}

/**
 * Load the crystal chain (array of crystal hashes).
 */
function loadChain() {
  if (!fs.existsSync(CHAIN_FILE)) return [];
  try {
    return JSON.parse(fs.readFileSync(CHAIN_FILE, 'utf8'));
  } catch {
    return [];
  }
}

/**
 * Get the last crystal hash (the chain tip).
 */
function lastHash() {
  const chain = loadChain();
  return chain.length > 0 ? chain[chain.length - 1] : '0'.repeat(64);
}

/**
 * Crystallize — create an immutable salt crystal for an execution.
 *
 * @param {Object} execution
 * @param {string} execution.operation  — What was executed (op name, sigil, command)
 * @param {string} execution.domain     — Which domain (.morph, .work, .salt, .vault)
 * @param {*}      execution.input      — Input data (will be hashed, not stored raw)
 * @param {*}      execution.output     — Output data (will be hashed, not stored raw)
 * @param {boolean} execution.success   — Did it succeed?
 * @param {string} execution.error      — Error message if failed
 * @param {Object} options
 * @param {boolean} options.noMemory    — If true, skip crystal creation entirely
 * @param {boolean} options.storeRaw    — If true, store raw input/output (not just hashes)
 * @returns {Object|null} The crystal, or null if noMemory
 */
function crystallize(execution, options = {}) {
  // NO-MEMORY: the dream vanishes, no trace
  if (options.noMemory) return null;

  const parent = lastHash();
  const timestamp = new Date().toISOString();

  // Hash inputs and outputs (privacy — raw data not stored by default)
  const inputHash = execution.input
    ? crypto.createHash('sha256').update(JSON.stringify(execution.input)).digest('hex').slice(0, 32)
    : null;
  const outputHash = execution.output
    ? crypto.createHash('sha256').update(JSON.stringify(execution.output)).digest('hex').slice(0, 32)
    : null;

  const crystal = {
    index: loadChain().length,
    timestamp,
    operation: execution.operation || 'unknown',
    domain: execution.domain || 'work',
    inputHash,
    outputHash,
    success: execution.success !== false,
    error: execution.error || null,
    parentHash: parent,
    machine: getMachineId()
  };

  // Store raw data only if explicitly requested
  if (options.storeRaw) {
    crystal.rawInput = execution.input;
    crystal.rawOutput = execution.output;
  }

  // Compute this crystal's hash
  crystal.hash = crypto.createHash('sha256')
    .update(JSON.stringify({
      index: crystal.index,
      timestamp: crystal.timestamp,
      operation: crystal.operation,
      inputHash: crystal.inputHash,
      outputHash: crystal.outputHash,
      parentHash: crystal.parentHash,
      machine: crystal.machine
    }))
    .digest('hex');

  // Write the crystal file (immutable — named by hash)
  const crystalPath = path.join(CRYSTAL_DIR, `${crystal.hash.slice(0, 16)}.crystal.json`);
  fs.writeFileSync(crystalPath, JSON.stringify(crystal, null, 2));
  fs.chmodSync(crystalPath, 0o444); // Read-only, immutable

  // Append to chain
  const chain = loadChain();
  chain.push(crystal.hash);
  fs.writeFileSync(CHAIN_FILE, JSON.stringify(chain));

  return crystal;
}

/**
 * Verify the entire crystal chain — detect any tampering.
 */
function verifyChain() {
  const chain = loadChain();
  if (chain.length === 0) return { valid: true, length: 0, message: 'Empty chain.' };

  let previousHash = '0'.repeat(64);
  const errors = [];

  for (let i = 0; i < chain.length; i++) {
    const hash = chain[i];
    const crystalPath = path.join(CRYSTAL_DIR, `${hash.slice(0, 16)}.crystal.json`);

    if (!fs.existsSync(crystalPath)) {
      errors.push(`Crystal ${i} missing: ${hash.slice(0, 16)}`);
      continue;
    }

    try {
      const crystal = JSON.parse(fs.readFileSync(crystalPath, 'utf8'));

      // Verify parent link
      if (crystal.parentHash !== previousHash) {
        errors.push(`Crystal ${i}: parent hash mismatch (chain broken)`);
      }

      // Verify self-hash
      const computed = crypto.createHash('sha256')
        .update(JSON.stringify({
          index: crystal.index,
          timestamp: crystal.timestamp,
          operation: crystal.operation,
          inputHash: crystal.inputHash,
          outputHash: crystal.outputHash,
          parentHash: crystal.parentHash,
          machine: crystal.machine
        }))
        .digest('hex');

      if (computed !== crystal.hash) {
        errors.push(`Crystal ${i}: hash mismatch (TAMPERED)`);
      }

      previousHash = crystal.hash;
    } catch (e) {
      errors.push(`Crystal ${i}: read error — ${e.message}`);
    }
  }

  return {
    valid: errors.length === 0,
    length: chain.length,
    errors,
    message: errors.length === 0
      ? `Chain intact: ${chain.length} crystals verified.`
      : `CHAIN COMPROMISED: ${errors.length} errors found.`
  };
}

/**
 * Audit — get recent crystal history.
 */
function audit(count = 10) {
  const chain = loadChain();
  const recent = chain.slice(-count);
  const crystals = [];

  for (const hash of recent) {
    const crystalPath = path.join(CRYSTAL_DIR, `${hash.slice(0, 16)}.crystal.json`);
    if (fs.existsSync(crystalPath)) {
      try {
        crystals.push(JSON.parse(fs.readFileSync(crystalPath, 'utf8')));
      } catch { /* skip corrupted */ }
    }
  }

  return crystals;
}

/**
 * Get machine identifier for crystal signing.
 */
function getMachineId() {
  try {
    const { execSync } = require('child_process');
    return execSync(
      "ioreg -d2 -c IOPlatformExpertDevice | grep IOPlatformUUID | sed 's/.*= \"//;s/\"//'",
      { encoding: 'utf8' }
    ).trim().slice(0, 8); // First 8 chars — enough for identity, not full exposure
  } catch {
    return 'unknown';
  }
}

module.exports = {
  crystallize,    // Create a salt crystal for an execution
  verifyChain,    // Verify chain integrity
  audit,          // Get recent execution history
  loadChain,      // Raw chain access
  CRYSTAL_DIR     // Path to crystal storage
};
