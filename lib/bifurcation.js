/**
 * L7 Bifurcation — Superposition and State Splitting
 *
 * In quantum mechanics, a system can exist in superposition —
 * multiple states at once. When observed, it collapses to one.
 * In the Empire, bifurcation lets the forge HOLD multiple states
 * simultaneously during morph (dream) exploration, then on return
 * to baseline, each superimposed state crystallizes as its own
 * separate salt entity. Nothing is lost. Every path explored
 * is preserved.
 *
 * The metaphor:
 *   - SUPERPOSE:  fork the current state into N branches
 *   - EVOLVE:     each branch develops independently in morph
 *   - COLLAPSE:   return to baseline — all branches salt separately
 *   - INTERFERE:  before collapse, branches can influence each other
 *
 * Law XL  — Never Lose Memory
 * Law XVII — .morph .work .salt .vault boundaries
 *
 * Each bifurcation produces a unique branch ID (SHA-256 of parent + index).
 * Branches are stored in morph as temporary superposition artifacts.
 * On collapse, each branch becomes an independent salt crystal with
 * full lineage (parent state, branch index, interference history).
 */

'use strict';

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const L7_DIR = process.env.L7_DIR || path.join(process.env.HOME, '.l7');
const BIFURCATION_DIR = path.join(L7_DIR, 'morph', '.bifurcations');
const SALT_DIR = path.join(L7_DIR, 'salt');

// Ensure directories exist
if (!fs.existsSync(BIFURCATION_DIR)) fs.mkdirSync(BIFURCATION_DIR, { recursive: true });
if (!fs.existsSync(SALT_DIR)) fs.mkdirSync(SALT_DIR, { recursive: true });

// ═══════════════════════════════════════════════════════════
// STATE REPRESENTATION
// ═══════════════════════════════════════════════════════════

/**
 * Create a branch ID from parent state and branch index.
 * Deterministic — same parent + index always gives same branch.
 */
function branchId(parentId, index) {
  return crypto.createHash('sha256')
    .update(`${parentId}:branch:${index}`)
    .digest('hex').slice(0, 16);
}

/**
 * Create a superposition — fork the current state into N branches.
 *
 * Each branch starts as a copy of the parent state but with
 * its own identity. Branches exist in morph (.bifurcations/)
 * until collapse.
 *
 * @param {object} state - The current state to fork
 * @param {number} branches - Number of branches (default 2)
 * @param {object} [options] - Optional configuration
 * @param {string} [options.label] - Human label for this superposition
 * @param {string[]} [options.branchLabels] - Labels for each branch
 * @returns {object} {
 *   id: string,          — superposition ID
 *   parentState: object,  — the original state (frozen)
 *   branches: object[],   — array of branch descriptors
 *   created: string,      — ISO timestamp
 *   collapsed: false      — not yet collapsed
 * }
 */
function superpose(state, branches = 2, options = {}) {
  const superpositionId = crypto.createHash('sha256')
    .update(JSON.stringify(state) + ':' + Date.now())
    .digest('hex').slice(0, 16);

  const branchDescriptors = [];

  for (let i = 0; i < branches; i++) {
    const bid = branchId(superpositionId, i);
    const branch = {
      id: bid,
      index: i,
      superpositionId,
      label: (options.branchLabels && options.branchLabels[i]) || `branch_${i}`,
      state: JSON.parse(JSON.stringify(state)), // Deep copy — independent
      mutations: [],  // Track what changed in this branch
      interference: [], // Interactions with other branches
      created: new Date().toISOString()
    };

    // Checksum the initial branch state
    branch._checksum = crypto.createHash('sha256')
      .update(JSON.stringify(branch.state))
      .digest('hex');

    branchDescriptors.push(branch);

    // Persist to morph/.bifurcations/
    const branchPath = path.join(BIFURCATION_DIR, `${superpositionId}_${bid}.json`);
    fs.writeFileSync(branchPath, JSON.stringify(branch, null, 2));
  }

  const superposition = {
    id: superpositionId,
    label: options.label || 'unnamed superposition',
    parentState: Object.freeze(JSON.parse(JSON.stringify(state))),
    branches: branchDescriptors,
    branchCount: branches,
    created: new Date().toISOString(),
    collapsed: false
  };

  // Persist the superposition manifest
  const manifestPath = path.join(BIFURCATION_DIR, `${superpositionId}_manifest.json`);
  fs.writeFileSync(manifestPath, JSON.stringify(superposition, null, 2));

  return superposition;
}

// ═══════════════════════════════════════════════════════════
// BRANCH EVOLUTION — Each branch develops independently
// ═══════════════════════════════════════════════════════════

/**
 * Evolve a branch — apply a mutation to one branch's state.
 *
 * Mutations are functions that transform the branch state.
 * Each mutation is logged so the full history of divergence
 * from the parent is traceable.
 *
 * @param {string} superpositionId - The superposition this branch belongs to
 * @param {string} branchIdStr - The branch to mutate
 * @param {string} description - What this mutation does
 * @param {function} mutator - Function(state) → mutated state
 * @returns {object} Updated branch descriptor
 */
function evolve(superpositionId, branchIdStr, description, mutator) {
  const branchPath = path.join(BIFURCATION_DIR, `${superpositionId}_${branchIdStr}.json`);

  if (!fs.existsSync(branchPath)) {
    throw new Error(`Branch not found: ${branchIdStr} in superposition ${superpositionId}`);
  }

  const branch = JSON.parse(fs.readFileSync(branchPath, 'utf8'));

  // Apply mutation
  const previousState = JSON.parse(JSON.stringify(branch.state));
  const mutatedState = mutator(branch.state);

  branch.state = mutatedState;
  branch.mutations.push({
    index: branch.mutations.length,
    description,
    timestamp: new Date().toISOString(),
    previousChecksum: branch._checksum
  });

  // Update checksum
  branch._checksum = crypto.createHash('sha256')
    .update(JSON.stringify(branch.state))
    .digest('hex');

  // Persist
  fs.writeFileSync(branchPath, JSON.stringify(branch, null, 2));

  return branch;
}

// ═══════════════════════════════════════════════════════════
// INTERFERENCE — Branches influence each other before collapse
// ═══════════════════════════════════════════════════════════

/**
 * Interfere — let one branch influence another.
 *
 * In quantum mechanics, interference is how superposed states
 * affect each other's amplitudes. Here, it's how one branch's
 * discoveries can partially influence another branch before
 * collapse. The influence is logged in both branches.
 *
 * @param {string} superpositionId - The superposition
 * @param {string} sourceBranchId - The influencing branch
 * @param {string} targetBranchId - The influenced branch
 * @param {string} description - What is being transferred
 * @param {function} influencer - Function(sourceState, targetState) → modified targetState
 * @returns {object} Updated target branch
 */
function interfere(superpositionId, sourceBranchId, targetBranchId, description, influencer) {
  const sourcePath = path.join(BIFURCATION_DIR, `${superpositionId}_${sourceBranchId}.json`);
  const targetPath = path.join(BIFURCATION_DIR, `${superpositionId}_${targetBranchId}.json`);

  if (!fs.existsSync(sourcePath) || !fs.existsSync(targetPath)) {
    throw new Error('One or both branches not found');
  }

  const source = JSON.parse(fs.readFileSync(sourcePath, 'utf8'));
  const target = JSON.parse(fs.readFileSync(targetPath, 'utf8'));

  // Apply interference
  const modifiedTargetState = influencer(source.state, target.state);
  target.state = modifiedTargetState;

  const interferenceRecord = {
    from: sourceBranchId,
    to: targetBranchId,
    description,
    timestamp: new Date().toISOString()
  };

  // Log in both branches
  source.interference.push({ ...interferenceRecord, role: 'source' });
  target.interference.push({ ...interferenceRecord, role: 'target' });

  // Update checksums
  target._checksum = crypto.createHash('sha256')
    .update(JSON.stringify(target.state))
    .digest('hex');

  // Persist both
  fs.writeFileSync(sourcePath, JSON.stringify(source, null, 2));
  fs.writeFileSync(targetPath, JSON.stringify(target, null, 2));

  return target;
}

// ═══════════════════════════════════════════════════════════
// COLLAPSE — Return to baseline, salt all branches
// ═══════════════════════════════════════════════════════════

/**
 * Collapse a superposition — return to baseline.
 *
 * On collapse:
 *   1. Each branch's final state becomes an independent salt crystal
 *   2. The parent state is preserved as the "baseline" salt
 *   3. Full lineage is recorded: parent → branch → mutations → salt
 *   4. Bifurcation files in morph are cleaned up
 *   5. The superposition is marked as collapsed
 *
 * Nothing is lost. Every explored path is preserved in salt.
 *
 * @param {string} superpositionId - The superposition to collapse
 * @param {object} [options] - Optional configuration
 * @param {boolean} [options.keepBaseline] - Also salt the parent state (default true)
 * @returns {object} {
 *   collapsed: true,
 *   saltedBranches: string[],  — names of salt files created
 *   baselineSalted: boolean,
 *   lineage: object
 * }
 */
function collapse(superpositionId, options = {}) {
  const keepBaseline = options.keepBaseline !== false;
  const manifestPath = path.join(BIFURCATION_DIR, `${superpositionId}_manifest.json`);

  if (!fs.existsSync(manifestPath)) {
    throw new Error(`Superposition not found: ${superpositionId}`);
  }

  const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));

  if (manifest.collapsed) {
    throw new Error(`Superposition ${superpositionId} already collapsed`);
  }

  const saltedBranches = [];
  const now = new Date().toISOString();

  // Salt each branch
  for (const branchDesc of manifest.branches) {
    const branchPath = path.join(BIFURCATION_DIR, `${superpositionId}_${branchDesc.id}.json`);
    if (!fs.existsSync(branchPath)) continue;

    const branch = JSON.parse(fs.readFileSync(branchPath, 'utf8'));

    const saltName = `bifurcation_${superpositionId}_${branch.label}.salt.json`;
    const saltPath = path.join(SALT_DIR, saltName);

    const contentStr = JSON.stringify(branch.state);
    const crystal = {
      _checksum: crypto.createHash('sha256').update(contentStr).digest('hex'),
      name: saltName,
      domain: 'salt',
      content: branch.state,
      metadata: {
        type: 'bifurcation_branch',
        superpositionId,
        branchId: branch.id,
        branchIndex: branch.index,
        branchLabel: branch.label,
        mutations: branch.mutations.length,
        interferences: branch.interference.length,
        mutationLog: branch.mutations,
        interferenceLog: branch.interference,
        parentChecksum: crypto.createHash('sha256')
          .update(JSON.stringify(manifest.parentState))
          .digest('hex'),
        crystallized_at: now,
        lineage: `superpose(${manifest.label}) → branch(${branch.label}) → ${branch.mutations.length} mutations → salt`
      }
    };

    fs.writeFileSync(saltPath, JSON.stringify(crystal, null, 2));
    fs.chmodSync(saltPath, 0o444); // Immutable
    saltedBranches.push(saltName);

    // Clean up morph bifurcation file
    fs.unlinkSync(branchPath);
  }

  // Salt the baseline (parent state) if requested
  let baselineSalted = false;
  if (keepBaseline) {
    const baselineName = `bifurcation_${superpositionId}_baseline.salt.json`;
    const baselinePath = path.join(SALT_DIR, baselineName);
    const baselineStr = JSON.stringify(manifest.parentState);

    const baselineCrystal = {
      _checksum: crypto.createHash('sha256').update(baselineStr).digest('hex'),
      name: baselineName,
      domain: 'salt',
      content: manifest.parentState,
      metadata: {
        type: 'bifurcation_baseline',
        superpositionId,
        branchCount: manifest.branchCount,
        crystallized_at: now,
        lineage: `superpose(${manifest.label}) → baseline (pre-bifurcation state)`
      }
    };

    fs.writeFileSync(baselinePath, JSON.stringify(baselineCrystal, null, 2));
    fs.chmodSync(baselinePath, 0o444);
    baselineSalted = true;
    saltedBranches.push(baselineName);
  }

  // Mark manifest as collapsed and clean up
  manifest.collapsed = true;
  manifest.collapsed_at = now;
  manifest.salted = saltedBranches;

  // Move manifest to salt as the lineage record
  const lineageName = `bifurcation_${superpositionId}_lineage.salt.json`;
  const lineagePath = path.join(SALT_DIR, lineageName);
  const lineageStr = JSON.stringify(manifest);
  const lineageCrystal = {
    _checksum: crypto.createHash('sha256').update(lineageStr).digest('hex'),
    name: lineageName,
    domain: 'salt',
    content: manifest,
    metadata: {
      type: 'bifurcation_lineage',
      superpositionId,
      crystallized_at: now
    }
  };
  fs.writeFileSync(lineagePath, JSON.stringify(lineageCrystal, null, 2));
  fs.chmodSync(lineagePath, 0o444);

  // Clean up morph manifest
  if (fs.existsSync(manifestPath)) fs.unlinkSync(manifestPath);

  return {
    collapsed: true,
    superpositionId,
    saltedBranches,
    baselineSalted,
    lineageFile: lineageName,
    totalSalted: saltedBranches.length + 1 // +1 for lineage
  };
}

// ═══════════════════════════════════════════════════════════
// INSPECTION — View active superpositions
// ═══════════════════════════════════════════════════════════

/**
 * List all active (uncollapsed) superpositions in morph.
 */
function listActive() {
  if (!fs.existsSync(BIFURCATION_DIR)) return [];

  return fs.readdirSync(BIFURCATION_DIR)
    .filter(f => f.endsWith('_manifest.json'))
    .map(f => {
      try {
        const manifest = JSON.parse(fs.readFileSync(path.join(BIFURCATION_DIR, f), 'utf8'));
        return {
          id: manifest.id,
          label: manifest.label,
          branches: manifest.branchCount,
          created: manifest.created,
          collapsed: manifest.collapsed
        };
      } catch {
        return null;
      }
    })
    .filter(Boolean)
    .filter(s => !s.collapsed);
}

/**
 * Read a specific branch's current state.
 */
function readBranch(superpositionId, branchIdStr) {
  const branchPath = path.join(BIFURCATION_DIR, `${superpositionId}_${branchIdStr}.json`);
  if (!fs.existsSync(branchPath)) return null;

  const branch = JSON.parse(fs.readFileSync(branchPath, 'utf8'));

  // Verify checksum on read
  const actualChecksum = crypto.createHash('sha256')
    .update(JSON.stringify(branch.state))
    .digest('hex');

  if (branch._checksum && actualChecksum !== branch._checksum) {
    throw new Error(`INTEGRITY VIOLATION: Branch ${branchIdStr} checksum mismatch — tampered`);
  }

  branch._verified = true;
  return branch;
}

// ═══════════════════════════════════════════════════════════
// EXPORTS
// ═══════════════════════════════════════════════════════════

module.exports = {
  // Core operations
  superpose,     // Fork state into N branches
  evolve,        // Mutate one branch
  interfere,     // Let branches influence each other
  collapse,      // Return to baseline — salt all branches

  // Inspection
  listActive,    // List uncollapsed superpositions
  readBranch,    // Read a branch's current state

  // Utility
  branchId       // Compute branch ID from parent + index
};
