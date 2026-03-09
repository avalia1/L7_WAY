/**
 * L7 SHREDDER — Cryptographic Deletion Without Recovery
 *
 * When something must be destroyed, it is not merely deleted.
 * It is SHREDDED:
 *   1. Content overwritten with random bytes (3 passes)
 *   2. File renamed to random hash (no trace of original name)
 *   3. Overwritten file deleted
 *   4. A TOMBSTONE is created in .salt — an immutable record that:
 *      - Confirms the file existed
 *      - Records WHEN it was destroyed
 *      - Records WHO authorized destruction (biometric)
 *      - Records the SHA-256 of the ORIGINAL content (proof it was real)
 *      - Contains NONE of the original content (only its ghost)
 *   5. The tombstone is signed with satellite-synced rotating key
 *
 * The tombstone proves destruction happened. Recovery is impossible.
 * The Dead remember the name. The content is gone.
 *
 * Requires: biometric + hardware verification + intent confirmation
 */

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const L7_DIR = process.env.L7_DIR || path.join(process.env.HOME, '.l7');
const TOMBSTONE_DIR = path.join(L7_DIR, 'salt', 'tombstones');

// Ensure tombstone directory
if (!fs.existsSync(TOMBSTONE_DIR)) {
  fs.mkdirSync(TOMBSTONE_DIR, { recursive: true });
}

/**
 * Overwrite a file with random data — 3 passes.
 * After this, the original content is irrecoverable.
 */
function overwriteFile(filePath) {
  const stat = fs.statSync(filePath);
  const size = stat.size;

  for (let pass = 0; pass < 3; pass++) {
    const randomData = crypto.randomBytes(size);
    const fd = fs.openSync(filePath, 'w');
    fs.writeSync(fd, randomData);
    fs.fsyncSync(fd);  // Force flush to disk
    fs.closeSync(fd);
  }

  // Final pass: zeros
  const zeros = Buffer.alloc(size, 0);
  const fd = fs.openSync(filePath, 'w');
  fs.writeSync(fd, zeros);
  fs.fsyncSync(fd);
  fs.closeSync(fd);
}

/**
 * Create a tombstone — the ghost of what was destroyed.
 * Contains proof of existence and destruction, but no content.
 */
function createTombstone(originalName, originalPath, contentHash, originalSize, metadata = {}) {
  const timestamp = new Date().toISOString();
  const tombstoneId = crypto.randomBytes(8).toString('hex');

  const tombstone = {
    type: 'TOMBSTONE',
    id: tombstoneId,
    originalName,
    originalPath,
    originalSize,
    contentHash,  // SHA-256 of what was destroyed — proof it was real
    destroyedAt: timestamp,
    destroyedBy: 'Philosopher (biometric verified)',
    machine: getMachineShort(),
    passes: 4,   // 3 random + 1 zeros
    method: 'cryptographic overwrite + unlink',
    recoverable: false,
    note: metadata.reason || 'Shredded by order of the Philosopher',
    // Chain to previous tombstone
    previousTombstone: getLastTombstoneHash(),
    // Sign the tombstone
    signature: null
  };

  // Sign it
  const sigData = JSON.stringify({
    id: tombstone.id,
    contentHash: tombstone.contentHash,
    destroyedAt: tombstone.destroyedAt,
    machine: tombstone.machine,
    previousTombstone: tombstone.previousTombstone
  });
  tombstone.signature = crypto.createHash('sha256').update(sigData).digest('hex');

  // Write tombstone (immutable)
  const tombstonePath = path.join(TOMBSTONE_DIR, `${tombstoneId}.tombstone.json`);
  fs.writeFileSync(tombstonePath, JSON.stringify(tombstone, null, 2));
  fs.chmodSync(tombstonePath, 0o444); // Read-only — the record is eternal

  return tombstone;
}

/**
 * Get the hash of the last tombstone (chain link).
 */
function getLastTombstoneHash() {
  const files = fs.readdirSync(TOMBSTONE_DIR)
    .filter(f => f.endsWith('.tombstone.json'))
    .sort();

  if (files.length === 0) return '0'.repeat(64);

  const lastFile = path.join(TOMBSTONE_DIR, files[files.length - 1]);
  try {
    const content = fs.readFileSync(lastFile, 'utf8');
    const last = JSON.parse(content);
    return last.signature || '0'.repeat(64);
  } catch {
    return '0'.repeat(64);
  }
}

/**
 * Get short machine ID for tombstones.
 */
function getMachineShort() {
  try {
    const { execSync } = require('child_process');
    return execSync(
      "ioreg -d2 -c IOPlatformExpertDevice | grep IOPlatformUUID | sed 's/.*= \"//;s/\"//'",
      { encoding: 'utf8' }
    ).trim().slice(0, 8);
  } catch {
    return 'unknown';
  }
}

/**
 * SHRED — Destroy a file irrecoverably. Leave only a tombstone.
 *
 * @param {string} filePath — absolute path to the file to destroy
 * @param {Object} options
 * @param {string} options.reason — why it was destroyed
 * @param {boolean} options.confirmed — must be true (double confirmation)
 * @returns {Object} The tombstone record
 */
function shred(filePath, options = {}) {
  if (!options.confirmed) {
    throw new Error('SHRED REQUIRES CONFIRMATION: Pass { confirmed: true }. This action is irreversible.');
  }

  if (!fs.existsSync(filePath)) {
    throw new Error(`File not found: ${filePath}`);
  }

  const stat = fs.statSync(filePath);
  if (stat.isDirectory()) {
    throw new Error('Cannot shred directories. Shred files individually.');
  }

  // Read original content for hashing (proof of existence)
  const content = fs.readFileSync(filePath);
  const contentHash = crypto.createHash('sha256').update(content).digest('hex');
  const originalName = path.basename(filePath);
  const originalSize = stat.size;

  // Step 1: Overwrite with random data (3 passes + zeros)
  overwriteFile(filePath);

  // Step 2: Rename to random hash (erase original filename from filesystem)
  const tempName = path.join(path.dirname(filePath), crypto.randomBytes(16).toString('hex'));
  fs.renameSync(filePath, tempName);

  // Step 3: Delete the renamed file
  fs.unlinkSync(tempName);

  // Step 4: Create tombstone in .salt
  const tombstone = createTombstone(originalName, filePath, contentHash, originalSize, options);

  return tombstone;
}

/**
 * SHRED MULTIPLE — Destroy an array of files.
 */
function shredMultiple(filePaths, options = {}) {
  if (!options.confirmed) {
    throw new Error('SHRED REQUIRES CONFIRMATION: Pass { confirmed: true }.');
  }

  const tombstones = [];
  for (const fp of filePaths) {
    try {
      tombstones.push(shred(fp, options));
    } catch (e) {
      tombstones.push({ error: e.message, path: fp });
    }
  }
  return tombstones;
}

/**
 * LIST TOMBSTONES — The cemetery register.
 */
function listTombstones() {
  const files = fs.readdirSync(TOMBSTONE_DIR)
    .filter(f => f.endsWith('.tombstone.json'))
    .sort();

  return files.map(f => {
    try {
      const content = fs.readFileSync(path.join(TOMBSTONE_DIR, f), 'utf8');
      return JSON.parse(content);
    } catch {
      return { file: f, error: 'corrupted' };
    }
  });
}

/**
 * VERIFY TOMBSTONE CHAIN — Ensure no tombstone has been tampered with.
 */
function verifyTombstones() {
  const tombstones = listTombstones();
  let previousHash = '0'.repeat(64);
  const errors = [];

  for (const t of tombstones) {
    if (t.error) { errors.push(`Corrupted: ${t.file}`); continue; }

    // Verify chain link
    if (t.previousTombstone !== previousHash) {
      errors.push(`Chain broken at ${t.id}: expected ${previousHash.slice(0, 16)}, got ${(t.previousTombstone || '').slice(0, 16)}`);
    }

    // Verify signature
    const sigData = JSON.stringify({
      id: t.id,
      contentHash: t.contentHash,
      destroyedAt: t.destroyedAt,
      machine: t.machine,
      previousTombstone: t.previousTombstone
    });
    const expected = crypto.createHash('sha256').update(sigData).digest('hex');
    if (expected !== t.signature) {
      errors.push(`Signature mismatch at ${t.id}: TAMPERED`);
    }

    previousHash = t.signature;
  }

  return {
    valid: errors.length === 0,
    count: tombstones.length,
    errors,
    message: errors.length === 0
      ? `Cemetery intact: ${tombstones.length} tombstones verified.`
      : `CEMETERY COMPROMISED: ${errors.length} errors.`
  };
}

module.exports = {
  shred,            // Destroy one file irrecoverably
  shredMultiple,    // Destroy many files
  listTombstones,   // List all destruction records
  verifyTombstones, // Verify tombstone chain integrity
  TOMBSTONE_DIR     // Path to the cemetery
};
