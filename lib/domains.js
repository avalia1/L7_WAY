

/**
 * L7 Domains — The Four Sacred Boundaries
 * Law XVII — .morph .work .salt .vault
 *
 * Each domain has rules. Boundaries are inviolable.
 *
 * .morph  — dream (Yod/Fire)    — mutable, never shared, sacred
 * .work   — produce (Vav/Air)   — stable, versioned, shareable
 * .salt   — preserve (He/Earth) — sealed, immutable, archived
 * .vault  — protect (He/Water)  — encrypted, biometric, quantum-resistant
 */

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const L7_DIR = process.env.L7_DIR || path.join(process.env.HOME, '.l7');

const DOMAIN_PATHS = {
  morph: path.join(L7_DIR, 'morph'),
  work:  path.join(L7_DIR, 'work'),
  salt:  path.join(L7_DIR, 'salt'),
  vault: path.join(L7_DIR, 'vault')
};

// Ensure all domain directories exist
for (const dir of Object.values(DOMAIN_PATHS)) {
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
}

const DOMAIN_RULES = Object.freeze({
  morph: {
    mutable: true,
    shareable: false,
    exportable: false,
    deletable: true,
    maxDepth: 3,  // 3 recursive layers — as above, so below
    description: 'The dreamscape. 3 layers: Above → Mirror → Below. Recursive, not cascading.',
    tetragrammaton: 'Yod',
    element: 'Fire',
    letter: 'י'
  },
  work: {
    mutable: true,  // Until published
    shareable: true,
    exportable: true,
    deletable: false, // Archived to .salt instead
    description: 'The workshop. Stable, shareable, versioned. Proof of work.',
    tetragrammaton: 'Vav',
    element: 'Air',
    letter: 'ו'
  },
  salt: {
    mutable: false,
    shareable: true,  // Read-only
    exportable: true,
    deletable: false,
    description: 'The archive. Sealed, immutable. What has been proven is preserved.',
    tetragrammaton: 'He (final)',
    element: 'Earth',
    letter: 'ה'
  },
  vault: {
    mutable: true,
    shareable: false,
    exportable: false, // Must go through gateway translation
    deletable: true,   // With 72hr grace (Law XLII)
    description: 'The vault. Encrypted, biometric, quantum-resistant.',
    tetragrammaton: 'He',
    element: 'Water',
    letter: 'ה'
  }
});

/**
 * Valid transitions between domains.
 * morph → work (publish), work → salt (archive), work → vault (protect)
 * vault → work (declassify), salt → work (unseal — sovereign only)
 */
const VALID_TRANSITIONS = Object.freeze({
  morph: ['work'],          // Dream → Produce
  work:  ['salt', 'vault'], // Produce → Archive or Protect
  salt:  ['work'],          // Unseal (sovereign only)
  vault: ['work']           // Declassify (sovereign only, biometric)
});

// ═══ MORPH LAYERS — As Above, So Below ═══
// 3 recursive layers, each a reflection of the pattern:
//   Layer 1: ABOVE  — the sky, the idea, the seed        (Gold/Yellow)
//   Layer 2: MIRROR — the horizon, the fold, the pivot   (Silver/White)
//   Layer 3: BELOW  — the root, the reflection, the echo (Copper/Red)
// Layer 3 mirrors Layer 1. Layer 2 is the gate between them.
// Beyond 3 = violation. The recursion folds, it does not cascade.

let morphDepth = 0;
const MORPH_MAX_DEPTH = 3;

const MORPH_LAYERS = Object.freeze([
  { name: 'ABOVE',  color: '\x1b[93m', label: '△ ABOVE',  symbol: '☉', desc: 'The sky. The idea. The seed.' },
  { name: 'MIRROR', color: '\x1b[97m', label: '◇ MIRROR', symbol: '☽', desc: 'The horizon. The fold. The pivot.' },
  { name: 'BELOW',  color: '\x1b[91m', label: '▽ BELOW',  symbol: '⊕', desc: 'The root. The reflection. The echo.' }
]);

/**
 * Get current morph layer info (0-indexed from morphDepth).
 */
function currentMorphLayer() {
  if (morphDepth === 0) return null;
  return MORPH_LAYERS[morphDepth - 1] || null;
}

/**
 * Format a morph layer title with color.
 */
function morphTitle(depth) {
  const layer = MORPH_LAYERS[depth - 1];
  if (!layer) return '';
  const reset = '\x1b[0m';
  return `${layer.color}${layer.symbol} .morph [${layer.label}] — ${layer.desc}${reset}`;
}

/**
 * Write an artifact to a domain.
 */
function write(domain, name, content, metadata = {}) {
  const rules = DOMAIN_RULES[domain];
  if (!rules) throw new Error(`Unknown domain: ${domain}`);

  // MORPH DEPTH — 3 recursive layers, as above so below
  if (domain === 'morph') {
    if (morphDepth >= MORPH_MAX_DEPTH) {
      throw new Error(
        `RECURSION LIMIT: morph depth ${morphDepth + 1} exceeds ${MORPH_MAX_DEPTH}. ` +
        'As above, so below — but not beyond. The recursion folds, it does not cascade.'
      );
    }
    morphDepth++;
    const layer = MORPH_LAYERS[morphDepth - 1];
    // Tag artifact with its layer
    metadata._morphLayer = morphDepth;
    metadata._morphName = layer.name;
    // Log the layer entry
    process.stdout.write(morphTitle(morphDepth) + '\n');
  }

  const domainPath = DOMAIN_PATHS[domain];
  const artifactPath = path.join(domainPath, name);

  // Salt is immutable — cannot overwrite
  if (domain === 'salt' && fs.existsSync(artifactPath)) {
    throw new Error(`Cannot overwrite sealed artifact: ${name} in .salt`);
  }

  const artifact = {
    name,
    domain,
    content,
    metadata: {
      ...metadata,
      created: new Date().toISOString(),
      signature: crypto.createHash('sha256')
        .update(JSON.stringify({ name, domain, content, time: Date.now() }))
        .digest('hex').slice(0, 16)
    }
  };

  fs.writeFileSync(artifactPath, JSON.stringify(artifact, null, 2));
  return artifact;
}

/**
 * Read an artifact from a domain.
 */
function read(domain, name) {
  const domainPath = DOMAIN_PATHS[domain];
  const artifactPath = path.join(domainPath, name);

  if (!fs.existsSync(artifactPath)) return null;

  try {
    return JSON.parse(fs.readFileSync(artifactPath, 'utf8'));
  } catch {
    // Raw file — wrap it
    return {
      name,
      domain,
      content: fs.readFileSync(artifactPath, 'utf8'),
      metadata: { raw: true }
    };
  }
}

/**
 * Transition an artifact between domains.
 * Returns the artifact in its new domain.
 */
function transition(fromDomain, toDomain, name, options = {}) {
  const allowed = VALID_TRANSITIONS[fromDomain] || [];
  if (!allowed.includes(toDomain)) {
    throw new Error(`Cannot transition from .${fromDomain} to .${toDomain}. Allowed: ${allowed.join(', ')}`);
  }

  const artifact = read(fromDomain, name);
  if (!artifact) {
    throw new Error(`Artifact not found: ${name} in .${fromDomain}`);
  }

  // Write to new domain
  const transitioned = write(toDomain, name, artifact.content, {
    ...artifact.metadata,
    transitioned_from: fromDomain,
    transitioned_at: new Date().toISOString(),
    ...options
  });

  // Handle source domain cleanup
  if (fromDomain === 'morph') {
    // Delete from morph (it was a dream, now it's real)
    const oldPath = path.join(DOMAIN_PATHS.morph, name);
    if (fs.existsSync(oldPath)) fs.unlinkSync(oldPath);
    morphDepth = Math.max(0, morphDepth - 1); // Release dream layer
  }
  // Salt and vault don't get deleted on transition (they keep the original)

  return transitioned;
}

/**
 * Delete an artifact. Respects domain rules.
 * Law XLII — 72hr grace period for vault.
 */
function remove(domain, name) {
  const rules = DOMAIN_RULES[domain];
  if (!rules.deletable) {
    throw new Error(`Cannot delete from .${domain} — domain is immutable`);
  }

  const domainPath = DOMAIN_PATHS[domain];
  const artifactPath = path.join(domainPath, name);

  if (!fs.existsSync(artifactPath)) return false;

  if (domain === 'vault') {
    // Law XLII — mark for deletion with 72hr grace
    const artifact = read(domain, name);
    artifact.metadata = artifact.metadata || {};
    artifact.metadata.marked_for_deletion = new Date().toISOString();
    artifact.metadata.deletion_after = new Date(Date.now() + 72 * 60 * 60 * 1000).toISOString();
    fs.writeFileSync(artifactPath, JSON.stringify(artifact, null, 2));
    return { scheduled: true, deletion_after: artifact.metadata.deletion_after };
  }

  // Morph — immediate deletion
  fs.unlinkSync(artifactPath);
  if (domain === 'morph') morphDepth = Math.max(0, morphDepth - 1);
  return { deleted: true };
}

/**
 * List all artifacts in a domain.
 */
function list(domain) {
  const domainPath = DOMAIN_PATHS[domain];
  if (!fs.existsSync(domainPath)) return [];

  return fs.readdirSync(domainPath)
    .filter(f => !f.startsWith('.'))
    .map(f => {
      const artifact = read(domain, f);
      return {
        name: f,
        domain,
        created: artifact?.metadata?.created,
        signature: artifact?.metadata?.signature
      };
    });
}

/**
 * Check which domain an artifact should live in based on its coordinate.
 * Security-heavy → vault. Experimental → morph. Stable → work. Archived → salt.
 */
function suggestDomain(coordinate) {
  // Mars (security, index 4) dominant → vault
  if (coordinate[4] >= 8) return 'vault';

  // Venus (persistence, index 3) high + Saturn (output, index 6) high → salt
  if (coordinate[3] >= 8 && coordinate[6] >= 7) return 'salt';

  // Neptune (consciousness, index 8) high OR Pluto (transformation, index 9) high → morph
  if (coordinate[8] >= 8 || coordinate[9] >= 8) return 'morph';

  // Default → work
  return 'work';
}

module.exports = {
  DOMAIN_RULES,
  DOMAIN_PATHS,
  VALID_TRANSITIONS,
  MORPH_LAYERS,
  write,
  read,
  transition,
  remove,
  list,
  suggestDomain,
  currentMorphLayer,
  morphTitle,
  get morphDepth() { return morphDepth; }
};

// L7:PROVENANCE
// Creator: Alberto Valido Delgado | System: L7 WAY | License: Proprietary — Framework free, products licensed (Law XXII)
// File: lib/domains.js | Body-Hash: SHA-256:44c9ffc9fd9af403500b17d8f8cc615290e980d922f29542fd9129726420b326
// Chain-Hash: SHA-256:a78662b48674c31c35b9053de386cb4cd22e1fcd2f4fbfac57bf5d17c59558ca | Signed: 2026-03-01T15:09:50.016438+00:00
// This work is the intellectual property of Alberto Valido Delgado.
// Chain: 17 works. Verify: python3 provenance.py verify lib/domains.js
// L7:PROVENANCE