/**
 * Sofia's Gate — The Doorway Between Worlds
 *
 * All data passing through Sofia is ATOMIZED:
 * 1. Split into 12 shards (one per planetary dimension)
 * 2. Each shard encrypted with a dimension-specific key
 * 3. Shards scattered — alone they are meaningless noise
 * 4. Reassembly requires ALL 12 shards + the astrocyte (threshold)
 *
 * This is nuclear fission applied to information:
 * - The atom (data) is split along astrological fault lines
 * - Each fragment carries energy but no meaning alone
 * - Only fusion (reassembly with the constellation key) restores form
 *
 * Sofia IS the gate. She does not store. She transmutes.
 * What passes through her is unknowable in transit.
 *
 * Caput Draconis (dim 10) = entry gate — data enters, gets atomized
 * Cauda Draconis (dim 11) = exit gate — shards fuse back into form
 */

const crypto = require('crypto');

// The 12 planetary dimensions — each holds one shard
const DIMENSIONS = [
  'Sun', 'Moon', 'Mercury', 'Venus', 'Mars', 'Jupiter',
  'Saturn', 'Uranus', 'Neptune', 'Pluto',
  'Caput Draconis', 'Cauda Draconis'
];

// Machine UUID derived key (same method as doctrine tool)
function machineKey() {
  const { execSync } = require('child_process');
  try {
    const uuid = execSync(
      "ioreg -d2 -c IOPlatformExpertDevice | grep IOPlatformUUID | sed 's/.*= \"//;s/\"//'",
      { encoding: 'utf8' }
    ).trim();
    return crypto.createHash('sha256')
      .update(uuid + ':SOFIA_GATE_42')
      .digest();
  } catch {
    throw new Error('DENIED: Cannot derive machine key. Wrong machine.');
  }
}

/**
 * Derive a dimension-specific key from the master key.
 * Each planet gets its own encryption key — nuclear division.
 */
function dimensionKey(masterKey, dimensionIndex) {
  return crypto.createHash('sha256')
    .update(Buffer.concat([
      masterKey,
      Buffer.from([dimensionIndex]),
      Buffer.from(DIMENSIONS[dimensionIndex])
    ]))
    .digest();
}

/**
 * ATOMIZE — Split data into 12 encrypted shards.
 * Caput Draconis (entry gate) performs the fission.
 *
 * Each shard is:
 * - A slice of the data (round-robin byte distribution)
 * - Encrypted with dimension-specific AES-256-GCM key
 * - Tagged with its dimension index (but content is unknowable)
 * - Salted with random IV (no two atomizations produce same output)
 *
 * Returns: array of 12 shard objects, each opaque without the others.
 */
function atomize(data) {
  const master = machineKey();
  const input = Buffer.isBuffer(data) ? data : Buffer.from(JSON.stringify(data), 'utf8');

  // Nuclear fission — distribute bytes across 12 dimensions
  const buckets = Array.from({ length: 12 }, () => []);
  for (let i = 0; i < input.length; i++) {
    buckets[i % 12].push(input[i]);
  }

  // Encrypt each shard with its planetary key
  const shards = buckets.map((bytes, dim) => {
    const key = dimensionKey(master, dim);
    const iv = crypto.randomBytes(16);
    const cipher = crypto.createCipheriv('aes-256-gcm', key, iv);

    const payload = Buffer.from(bytes);
    const encrypted = Buffer.concat([cipher.update(payload), cipher.final()]);
    const tag = cipher.getAuthTag();

    return {
      dimension: dim,
      planet: DIMENSIONS[dim],
      iv: iv.toString('hex'),
      tag: tag.toString('hex'),
      shard: encrypted.toString('hex'),
      size: bytes.length
    };
  });

  // Metadata for reassembly (does NOT contain any data — just the constellation map)
  const constellation = {
    totalBytes: input.length,
    shardCount: 12,
    timestamp: Date.now(),
    gate: 'Caput Draconis',
    integrity: crypto.createHash('sha256').update(input).digest('hex').slice(0, 16)
  };

  return { shards, constellation };
}

/**
 * FUSE — Reassemble 12 shards back into original data.
 * Cauda Draconis (exit gate) performs the fusion.
 *
 * Requires ALL 12 shards. Missing even one = total failure.
 * This is the nuclear fusion — bringing the fragments back together.
 */
function fuse(atomized) {
  const { shards, constellation } = atomized;
  const master = machineKey();

  if (!shards || shards.length !== 12) {
    throw new Error('FUSION FAILURE: All 12 dimensional shards required. The constellation is incomplete.');
  }

  // Decrypt each shard with its planetary key
  const buckets = new Array(12);
  for (const shard of shards) {
    const key = dimensionKey(master, shard.dimension);
    const iv = Buffer.from(shard.iv, 'hex');
    const tag = Buffer.from(shard.tag, 'hex');
    const encrypted = Buffer.from(shard.shard, 'hex');

    const decipher = crypto.createDecipheriv('aes-256-gcm', key, iv);
    decipher.setAuthTag(tag);

    try {
      const decrypted = Buffer.concat([decipher.update(encrypted), decipher.final()]);
      buckets[shard.dimension] = decrypted;
    } catch (e) {
      throw new Error(`SHARD CORRUPTION: ${shard.planet} (dim ${shard.dimension}) — tampered or wrong key`);
    }
  }

  // Reassemble — reverse the round-robin distribution
  const total = constellation.totalBytes;
  const output = Buffer.alloc(total);
  const positions = new Array(12).fill(0);

  for (let i = 0; i < total; i++) {
    const dim = i % 12;
    output[i] = buckets[dim][positions[dim]++];
  }

  // Integrity check
  const check = crypto.createHash('sha256').update(output).digest('hex').slice(0, 16);
  if (check !== constellation.integrity) {
    throw new Error('INTEGRITY FAILURE: Fused data does not match original. The constellation has shifted.');
  }

  return output;
}

/**
 * TRANSIT — Full round-trip through Sofia's gate.
 * Data enters Caput, gets atomized, passes as 12 unknowable shards,
 * fuses back through Cauda. The transit itself IS the protection.
 */
function transit(data) {
  const atomized = atomize(data);
  const restored = fuse(atomized);
  return JSON.parse(restored.toString('utf8'));
}

/**
 * SCATTER — Atomize and distribute shards to separate storage locations.
 * Each shard goes to its planetary domain. No single location holds meaning.
 */
function scatter(data, storageCallback) {
  const atomized = atomize(data);
  const locations = {};

  for (const shard of atomized.shards) {
    const location = storageCallback
      ? storageCallback(shard)
      : `shard_${shard.dimension}_${shard.planet}`;
    locations[shard.planet] = location;
  }

  return {
    constellation: atomized.constellation,
    locations,
    // The constellation map is needed to fuse — but it contains NO data
    // It only says: how many bytes, how many shards, integrity hash
  };
}

module.exports = {
  atomize,      // Caput Draconis — entry, fission, split into 12
  fuse,         // Cauda Draconis — exit, fusion, reassemble from 12
  transit,      // Full round-trip through the gate
  scatter,      // Distribute shards to separate locations
  DIMENSIONS    // The 12 planetary names
};
