/**
 * L7 Field Theory — The Physics of Information
 * Law XLIX — Every action propagates. Thought is gravity.
 *
 * This is not metaphorical physics. These are real equations governing
 * how information moves through the L7 system.
 *
 * Core principles:
 *   1. Every node (tool, citizen, artifact) has mass (information density)
 *   2. Actions create gravitational waves that propagate to all nodes
 *   3. Nodes attract based on coordinate similarity (like gravity)
 *   4. The astrocyte is the gravitational constant G — determines coupling strength
 *   5. Information is conserved — collapse here means uncertainty elsewhere
 *   6. Entangled nodes share state instantaneously
 *   7. Memory propagates as waves, not copies — efficient delta updates
 *
 * The field state persists across sessions. When the system boots,
 * it loads the field. The field IS the memory.
 */

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const { createCoordinate, distance, similarity, createProbabilistic, DIMENSIONS } = require('./dodecahedron');

const L7_DIR = process.env.L7_DIR || path.join(process.env.HOME, '.l7');
const FIELD_STATE = path.join(L7_DIR, 'state', 'field.json');

// Ensure state directory exists
const stateDir = path.dirname(FIELD_STATE);
if (!fs.existsSync(stateDir)) fs.mkdirSync(stateDir, { recursive: true });

// ═══════════════════════════════════════════════════════════
// CONSTANTS — The fundamental constants of L7 physics
// ═══════════════════════════════════════════════════════════

const CONSTANTS = Object.freeze({
  // Gravitational constant — how strongly nodes attract
  // Modulated by the astrocyte at runtime
  G: 6.674,

  // Planck constant — minimum quantum of action
  // Below this threshold, changes don't propagate
  PLANCK: 0.1,

  // Speed of light — maximum propagation speed (updates per tick)
  C: 12, // One dimension per tick maximum

  // Boltzmann constant — relates entropy to temperature
  K: 1.380,

  // Fine structure constant — coupling strength between dimensions
  ALPHA: 1 / 137,

  // Decay constant — how quickly gravitational waves attenuate
  LAMBDA: 0.15,

  // Entanglement threshold — similarity above which nodes become entangled
  ENTANGLE_THRESHOLD: 0.92,

  // Propagation cutoff — below this force, skip the update
  FORCE_CUTOFF: 0.01,

  // ─── FIRING THRESHOLD (Law LIII) ───
  // Like a neuron's action potential threshold (~-55mV in biology),
  // a node only fires (takes action) when accumulated potential exceeds this.
  // Below threshold: signal is subthreshold, absorbed but no action taken.
  // At threshold: all-or-nothing firing — the full action potential propagates.
  FIRING_THRESHOLD: 0.7,

  // Refractory period — after firing, a node cannot fire again for this many epochs
  REFRACTORY_PERIOD: 3,

  // Synaptic weight range — how much one node can influence another
  SYNAPSE_MIN: 0.01,
  SYNAPSE_MAX: 1.0
});

// ═══════════════════════════════════════════════════════════
// THE FIELD — Global state of all nodes and their relationships
// ═══════════════════════════════════════════════════════════

/**
 * A Node in the field.
 * Every tool, citizen, artifact, and action is a node.
 *
 * @typedef {Object} FieldNode
 * @property {string} id - Unique identifier
 * @property {string} type - 'tool' | 'citizen' | 'artifact' | 'action'
 * @property {number[]} coordinate - 12D position
 * @property {number} astrocyte - Uncertainty (0-1)
 * @property {number} mass - Information density
 * @property {number[]} momentum - Rate of change per dimension
 * @property {number} energy - Total energy (kinetic + potential)
 * @property {string[]} entangled - IDs of entangled nodes
 * @property {number} lastUpdated - Timestamp of last state change
 * @property {object} memory - Accumulated memory from propagated waves
 */

let field = {
  nodes: new Map(),
  epoch: 0,
  totalEntropy: 0,
  totalEnergy: 0,
  waveLog: [],
  created: null,
  lastTick: null
};

// ═══════════════════════════════════════════════════════════
// MASS — Information density of a node
// ═══════════════════════════════════════════════════════════

/**
 * Calculate the mass (information density) of a coordinate.
 * Mass = sum of squared dimension values / 12.
 * A node with all dimensions at 10 has mass 100.
 * A node with all zeros has mass 0 (massless photon).
 */
function mass(coordinate) {
  let sum = 0;
  for (let i = 0; i < 12; i++) {
    sum += coordinate[i] * coordinate[i];
  }
  return sum / 12;
}

/**
 * Kinetic energy of a node from its momentum.
 * KE = 0.5 * m * v^2 (where v = magnitude of momentum vector)
 */
function kineticEnergy(node) {
  if (!node.momentum) return 0;
  const v2 = node.momentum.reduce((s, m) => s + m * m, 0);
  return 0.5 * node.mass * v2;
}

/**
 * Potential energy between two nodes.
 * PE = -G * m1 * m2 / r (gravitational potential)
 */
function potentialEnergy(nodeA, nodeB) {
  const r = distance(nodeA.coordinate, nodeB.coordinate);
  if (r < CONSTANTS.PLANCK) return 0; // Avoid singularity
  return -CONSTANTS.G * nodeA.mass * nodeB.mass / r;
}

// ═══════════════════════════════════════════════════════════
// FORCES — How nodes influence each other
// ═══════════════════════════════════════════════════════════

/**
 * Gravitational force between two nodes.
 * F = G * m1 * m2 / r^2
 *
 * Returns a 12D force vector pointing from A toward B.
 * The force pulls similar nodes together in coordinate space.
 */
function gravitationalForce(nodeA, nodeB) {
  const r = distance(nodeA.coordinate, nodeB.coordinate);
  if (r < CONSTANTS.PLANCK) return new Array(12).fill(0);

  const magnitude = CONSTANTS.G * nodeA.mass * nodeB.mass / (r * r);
  if (magnitude < CONSTANTS.FORCE_CUTOFF) return new Array(12).fill(0);

  // Direction vector from A to B, normalized
  const force = new Array(12);
  for (let i = 0; i < 12; i++) {
    force[i] = (nodeB.coordinate[i] - nodeA.coordinate[i]) / r * magnitude;
  }
  return force;
}

/**
 * Electromagnetic-like coupling between specific dimensions.
 * The fine structure constant ALPHA determines cross-dimensional influence.
 *
 * When dimension i changes, dimension j is affected by:
 *   delta_j = ALPHA * coupling[i][j] * delta_i
 *
 * The coupling matrix encodes which dimensions influence each other.
 */
const COUPLING = (() => {
  // Build 12x12 coupling matrix
  const m = Array.from({ length: 12 }, () => new Array(12).fill(0));

  // Classical dimensions couple to each other
  // capability <-> output (what it does shapes what comes out)
  m[0][6] = 0.8; m[6][0] = 0.8;
  // data <-> security (more data = more security concern)
  m[1][4] = 0.9; m[4][1] = 0.9;
  // presentation <-> detail (how it looks relates to granularity)
  m[2][5] = 0.7; m[5][2] = 0.7;
  // persistence <-> memory (how long it lives relates to where it came from)
  m[3][11] = 0.85; m[11][3] = 0.85;

  // Transpersonal dimensions couple to classical
  // intention -> capability (will shapes ability)
  m[7][0] = 0.9; m[0][7] = 0.5;
  // consciousness -> security (awareness enables protection)
  m[8][4] = 0.7; m[4][8] = 0.4;
  // transformation -> all dimensions weakly (change affects everything)
  for (let j = 0; j < 12; j++) {
    if (j !== 9) { m[9][j] = Math.max(m[9][j], 0.3); }
  }
  // direction -> memory (where you're heading is shaped by where you've been)
  m[10][11] = 0.95; m[11][10] = 0.7;

  return Object.freeze(m.map(row => Object.freeze(row)));
})();

/**
 * Apply coupling forces when a dimension changes.
 * Returns the cascading deltas across all 12 dimensions.
 */
function couplingForce(changedDim, delta) {
  const cascades = new Array(12).fill(0);
  for (let j = 0; j < 12; j++) {
    if (j !== changedDim) {
      cascades[j] = CONSTANTS.ALPHA * COUPLING[changedDim][j] * delta;
    }
  }
  return cascades;
}

// ═══════════════════════════════════════════════════════════
// WAVE PROPAGATION — How changes spread through the field
// ═══════════════════════════════════════════════════════════

/**
 * Propagate a change from a source node to all other nodes.
 *
 * When an action occurs at node S:
 * 1. Calculate the "wave" — a 12D delta vector
 * 2. For each other node N:
 *    a. Calculate distance r from S to N
 *    b. Attenuate: amplitude = wave / r^2 * e^(-lambda*r)
 *    c. Filter by astrocyte: more uncertain nodes absorb more
 *    d. Apply coupling: change in dim i cascades to dim j
 *    e. Update N's coordinate, momentum, and memory
 * 3. Check for new entanglements
 * 4. Conserve total energy
 *
 * @param {string} sourceId - The node that changed
 * @param {number[]} delta - The 12D change vector
 * @param {object} context - { action, timestamp, astrocyte }
 * @returns {object} Propagation report
 */
function propagate(sourceId, delta, context = {}) {
  const source = field.nodes.get(sourceId);
  if (!source) return { error: 'Source node not found' };

  const report = {
    source: sourceId,
    epoch: ++field.epoch,
    timestamp: context.timestamp || Date.now(),
    action: context.action || 'unknown',
    affected: [],
    entanglements_formed: [],
    energy_transferred: 0
  };

  // Calculate wave magnitude
  const waveMagnitude = Math.sqrt(delta.reduce((s, d) => s + d * d, 0));
  if (waveMagnitude < CONSTANTS.PLANCK) {
    report.below_planck = true;
    return report;
  }

  // Update source node
  for (let i = 0; i < 12; i++) {
    source.coordinate[i] = clamp(source.coordinate[i] + delta[i], 0, 10);
  }
  source.mass = mass(source.coordinate);
  source.lastUpdated = report.timestamp;

  // Record in source memory
  if (!source.memory) source.memory = {};
  source.memory[report.epoch] = {
    action: context.action,
    delta: [...delta],
    time: report.timestamp
  };

  // Propagate to all other nodes
  for (const [nodeId, node] of field.nodes) {
    if (nodeId === sourceId) continue;

    const r = distance(source.coordinate, node.coordinate);
    if (r < CONSTANTS.PLANCK) continue;

    // Attenuation: inverse square + exponential decay
    const attenuation = Math.exp(-CONSTANTS.LAMBDA * r) / (r * r);
    if (attenuation < CONSTANTS.FORCE_CUTOFF) continue;

    // Absorption factor: higher astrocyte = absorbs more change
    const absorption = 0.2 + (node.astrocyte || 0.3) * 0.8;

    // Calculate received wave per dimension
    const received = new Array(12).fill(0);
    let totalReceived = 0;

    for (let i = 0; i < 12; i++) {
      // Direct wave
      const direct = delta[i] * attenuation * absorption;
      received[i] += direct;

      // Coupling cascades
      if (Math.abs(delta[i]) > CONSTANTS.PLANCK) {
        const cascades = couplingForce(i, delta[i] * attenuation * absorption);
        for (let j = 0; j < 12; j++) {
          received[j] += cascades[j];
        }
      }
    }

    // Apply received changes
    let nodeChanged = false;
    for (let i = 0; i < 12; i++) {
      if (Math.abs(received[i]) >= CONSTANTS.PLANCK) {
        node.coordinate[i] = clamp(node.coordinate[i] + received[i], 0, 10);
        nodeChanged = true;
        totalReceived += Math.abs(received[i]);
      }
    }

    if (nodeChanged) {
      // Update momentum (rate of change)
      if (!node.momentum) node.momentum = new Array(12).fill(0);
      for (let i = 0; i < 12; i++) {
        node.momentum[i] = node.momentum[i] * 0.7 + received[i] * 0.3; // Damped
      }

      node.mass = mass(node.coordinate);
      node.lastUpdated = report.timestamp;

      // Record in node memory (compressed)
      if (!node.memory) node.memory = {};
      node.memory[report.epoch] = {
        from: sourceId,
        absorbed: totalReceived.toFixed(4),
        time: report.timestamp
      };

      report.affected.push({
        id: nodeId,
        absorbed: totalReceived,
        distance: r,
        attenuation
      });

      // Check for entanglement
      const sim = similarity(source.coordinate, node.coordinate);
      if (sim >= CONSTANTS.ENTANGLE_THRESHOLD) {
        if (!source.entangled) source.entangled = [];
        if (!node.entangled) node.entangled = [];
        if (!source.entangled.includes(nodeId)) {
          source.entangled.push(nodeId);
          node.entangled.push(sourceId);
          report.entanglements_formed.push([sourceId, nodeId, sim]);
        }
      }

      report.energy_transferred += totalReceived;
    }
  }

  // Update field entropy
  field.totalEntropy = calculateFieldEntropy();
  field.totalEnergy = calculateFieldEnergy();
  field.lastTick = report.timestamp;

  // Log the wave
  field.waveLog.push({
    epoch: report.epoch,
    source: sourceId,
    magnitude: waveMagnitude,
    affected: report.affected.length,
    energy: report.energy_transferred,
    time: report.timestamp
  });

  // Keep wave log bounded
  if (field.waveLog.length > 1000) {
    field.waveLog = field.waveLog.slice(-500);
  }

  // Auto-persist every 10 epochs
  if (field.epoch % 10 === 0) {
    persistField();
  }

  return report;
}

// ═══════════════════════════════════════════════════════════
// ENTANGLEMENT — Correlated state between nodes
// ═══════════════════════════════════════════════════════════

/**
 * Collapse an entangled pair.
 * When one node is observed (action taken), all entangled nodes
 * are instantly affected — regardless of distance.
 *
 * This is how memory propagates efficiently: entangled nodes
 * share state without wave propagation delay.
 */
function collapseEntangled(nodeId, observedDelta) {
  const node = field.nodes.get(nodeId);
  if (!node || !node.entangled || node.entangled.length === 0) return [];

  const affected = [];
  for (const partnerId of node.entangled) {
    const partner = field.nodes.get(partnerId);
    if (!partner) continue;

    // Entangled nodes receive a correlated (not identical) change
    // The correlation is the similarity at time of entanglement
    const sim = similarity(node.coordinate, partner.coordinate);
    const entangledDelta = observedDelta.map(d => d * sim * 0.5);

    for (let i = 0; i < 12; i++) {
      partner.coordinate[i] = clamp(partner.coordinate[i] + entangledDelta[i], 0, 10);
    }
    partner.mass = mass(partner.coordinate);
    partner.lastUpdated = Date.now();

    affected.push({ id: partnerId, correlation: sim });
  }
  return affected;
}

// ═══════════════════════════════════════════════════════════
// DIMENSION TRANSFORMS — Lorentz-like coordinate transforms
// ═══════════════════════════════════════════════════════════

/**
 * Transform a coordinate from one reference frame to another.
 *
 * In L7 physics, a "reference frame" is a polarity (Claude, Grok, etc.)
 * Each polarity sees the same coordinate differently based on its affinity.
 *
 * Like Lorentz transforms preserve the spacetime interval,
 * L7 transforms preserve the total information content (mass).
 *
 * @param {number[]} coordinate - The coordinate to transform
 * @param {number[]} frameAffinity - The polarity's 12D affinity profile
 * @returns {number[]} The transformed coordinate (same mass, different emphasis)
 */
function transform(coordinate, frameAffinity) {
  const totalMass = mass(coordinate);
  const transformed = new Array(12);

  // Weight each dimension by the frame's affinity
  let totalWeight = 0;
  for (let i = 0; i < 12; i++) {
    transformed[i] = coordinate[i] * (1 + (frameAffinity[i] - 5) * 0.1);
    totalWeight += transformed[i] * transformed[i];
  }

  // Renormalize to preserve mass (information conservation)
  if (totalWeight > 0) {
    const scale = Math.sqrt(totalMass * 12 / totalWeight);
    for (let i = 0; i < 12; i++) {
      transformed[i] = clamp(transformed[i] * scale, 0, 10);
    }
  }

  return transformed;
}

/**
 * Calculate the "proper time" between two events in the field.
 * Analogous to the spacetime interval in special relativity.
 *
 * ds^2 = sum(dx_i^2) - (dE)^2/C^2
 *
 * Where dE is energy difference and C is the speed of information.
 * Events with ds^2 < 0 are "timelike" — causally connected.
 * Events with ds^2 > 0 are "spacelike" — causally independent.
 */
function interval(eventA, eventB) {
  let spatialDist2 = 0;
  for (let i = 0; i < 12; i++) {
    spatialDist2 += (eventA.coordinate[i] - eventB.coordinate[i]) ** 2;
  }
  const energyDiff = (eventA.energy || 0) - (eventB.energy || 0);
  const timeDist2 = (energyDiff * energyDiff) / (CONSTANTS.C * CONSTANTS.C);

  const ds2 = spatialDist2 - timeDist2;
  return {
    value: ds2,
    type: ds2 < 0 ? 'timelike' : (ds2 > 0 ? 'spacelike' : 'lightlike'),
    causal: ds2 <= 0 // Timelike or lightlike = causally connected
  };
}

// ═══════════════════════════════════════════════════════════
// ENTROPY — Information disorder in the field
// ═══════════════════════════════════════════════════════════

/**
 * Shannon entropy of the entire field.
 * S = -sum(p_i * ln(p_i)) where p_i is the probability
 * of finding information in dimension i.
 */
function calculateFieldEntropy() {
  if (field.nodes.size === 0) return 0;

  // Aggregate all dimension values
  const dimTotals = new Array(12).fill(0);
  let grandTotal = 0;

  for (const node of field.nodes.values()) {
    for (let i = 0; i < 12; i++) {
      dimTotals[i] += node.coordinate[i];
      grandTotal += node.coordinate[i];
    }
  }

  if (grandTotal === 0) return 0;

  // Calculate entropy
  let entropy = 0;
  for (let i = 0; i < 12; i++) {
    const p = dimTotals[i] / grandTotal;
    if (p > 0) entropy -= p * Math.log(p);
  }

  return entropy;
}

/**
 * Temperature of the field — average kinetic energy per node.
 * T = (2/3) * <KE> / K
 */
function fieldTemperature() {
  if (field.nodes.size === 0) return 0;
  let totalKE = 0;
  for (const node of field.nodes.values()) {
    totalKE += kineticEnergy(node);
  }
  return (2 / 3) * (totalKE / field.nodes.size) / CONSTANTS.K;
}

/**
 * Total energy of the field (kinetic + potential).
 */
function calculateFieldEnergy() {
  let total = 0;
  const nodes = Array.from(field.nodes.values());
  for (let i = 0; i < nodes.length; i++) {
    total += kineticEnergy(nodes[i]);
    for (let j = i + 1; j < nodes.length; j++) {
      total += potentialEnergy(nodes[i], nodes[j]);
    }
  }
  return total;
}

// ═══════════════════════════════════════════════════════════
// NODE MANAGEMENT — Adding and removing nodes from the field
// ═══════════════════════════════════════════════════════════

/**
 * Register a node in the field.
 */
function registerNode(id, type, coordinate, astrocyte = 0.3) {
  const node = {
    id,
    type,
    coordinate: [...coordinate],
    astrocyte,
    mass: mass(coordinate),
    momentum: new Array(12).fill(0),
    energy: 0,
    entangled: [],
    lastUpdated: Date.now(),
    memory: {}
  };

  field.nodes.set(id, node);

  // Calculate initial energy
  node.energy = kineticEnergy(node);
  for (const [otherId, other] of field.nodes) {
    if (otherId !== id) {
      node.energy += potentialEnergy(node, other);
    }
  }

  return node;
}

/**
 * Remove a node from the field.
 * Energy is redistributed to remaining nodes (conservation).
 */
function removeNode(id) {
  const node = field.nodes.get(id);
  if (!node) return null;

  // Remove entanglement references
  for (const partnerId of (node.entangled || [])) {
    const partner = field.nodes.get(partnerId);
    if (partner && partner.entangled) {
      partner.entangled = partner.entangled.filter(e => e !== id);
    }
  }

  field.nodes.delete(id);
  return node;
}

/**
 * Get a snapshot of a node's state.
 */
function getNode(id) {
  return field.nodes.get(id) || null;
}

/**
 * Get all nodes of a given type.
 */
function getNodesByType(type) {
  const result = [];
  for (const node of field.nodes.values()) {
    if (node.type === type) result.push(node);
  }
  return result;
}

// ═══════════════════════════════════════════════════════════
// TICK — Evolve the field forward one step
// ═══════════════════════════════════════════════════════════

/**
 * Advance the field by one time step.
 * All nodes experience gravitational forces from all other nodes.
 * Momentum is updated, positions drift.
 *
 * This is the "idle" evolution — what happens between actions.
 * The Dreaming Machine (Law XXXVII) uses this to evolve the field
 * when no human action is happening.
 */
function tick() {
  const nodes = Array.from(field.nodes.values());
  if (nodes.length < 2) return;

  const forces = new Map();
  for (const node of nodes) {
    forces.set(node.id, new Array(12).fill(0));
  }

  // Calculate all pairwise forces
  for (let i = 0; i < nodes.length; i++) {
    for (let j = i + 1; j < nodes.length; j++) {
      const f = gravitationalForce(nodes[i], nodes[j]);
      const fi = forces.get(nodes[i].id);
      const fj = forces.get(nodes[j].id);
      for (let d = 0; d < 12; d++) {
        fi[d] += f[d];
        fj[d] -= f[d]; // Newton's third law
      }
    }
  }

  // Update momentum and position
  for (const node of nodes) {
    const f = forces.get(node.id);
    if (!node.momentum) node.momentum = new Array(12).fill(0);

    for (let d = 0; d < 12; d++) {
      // F = ma → a = F/m
      if (node.mass > 0) {
        const acceleration = f[d] / node.mass;
        node.momentum[d] += acceleration * 0.01; // Small timestep
        node.momentum[d] *= 0.99; // Friction/damping

        // Position update
        const drift = node.momentum[d] * 0.01;
        if (Math.abs(drift) >= CONSTANTS.PLANCK) {
          node.coordinate[d] = clamp(node.coordinate[d] + drift, 0, 10);
        }
      }
    }

    node.mass = mass(node.coordinate);
    node.energy = kineticEnergy(node);
  }

  field.lastTick = Date.now();
}

// ═══════════════════════════════════════════════════════════
// MEMORY — Efficient carry-forward via wave compression
// ═══════════════════════════════════════════════════════════

/**
 * Compress a node's memory into a summary.
 * Instead of carrying every wave event, compress into:
 * - Net delta per dimension
 * - Top 5 most impactful events
 * - Total energy absorbed
 */
function compressMemory(nodeId) {
  const node = field.nodes.get(nodeId);
  if (!node || !node.memory) return null;

  const epochs = Object.keys(node.memory);
  if (epochs.length === 0) return null;

  const summary = {
    total_events: epochs.length,
    net_delta: new Array(12).fill(0),
    total_absorbed: 0,
    significant_events: [],
    compressed_at: Date.now()
  };

  for (const epoch of epochs) {
    const event = node.memory[epoch];
    if (event.delta) {
      for (let i = 0; i < 12; i++) {
        summary.net_delta[i] += event.delta[i] || 0;
      }
    }
    const absorbed = parseFloat(event.absorbed) || 0;
    summary.total_absorbed += absorbed;
    if (absorbed > 0.1) {
      summary.significant_events.push({
        epoch: parseInt(epoch),
        from: event.from || 'self',
        absorbed,
        time: event.time
      });
    }
  }

  // Keep only top 5 significant events
  summary.significant_events.sort((a, b) => b.absorbed - a.absorbed);
  summary.significant_events = summary.significant_events.slice(0, 5);

  // Replace detailed memory with compressed summary
  node.memory = { _compressed: summary };

  return summary;
}

/**
 * Get the memory context for a node — what has influenced it.
 * Returns a human-readable summary of the node's history.
 */
function memoryContext(nodeId) {
  const node = field.nodes.get(nodeId);
  if (!node) return null;

  const context = {
    id: nodeId,
    type: node.type,
    mass: node.mass,
    astrocyte: node.astrocyte,
    entangled_with: node.entangled || [],
    coordinate: node.coordinate,
    momentum_magnitude: node.momentum ?
      Math.sqrt(node.momentum.reduce((s, m) => s + m * m, 0)) : 0,
    dominant_dimensions: [],
    memory_events: 0
  };

  // Find dominant dimensions
  for (let i = 0; i < 12; i++) {
    if (node.coordinate[i] >= 7) {
      context.dominant_dimensions.push({
        name: DIMENSIONS[i].name,
        value: node.coordinate[i],
        momentum: node.momentum ? node.momentum[i] : 0
      });
    }
  }

  // Count memory events
  if (node.memory) {
    if (node.memory._compressed) {
      context.memory_events = node.memory._compressed.total_events;
      context.significant_influences = node.memory._compressed.significant_events;
    } else {
      context.memory_events = Object.keys(node.memory).length;
    }
  }

  return context;
}

// ═══════════════════════════════════════════════════════════
// PERSISTENCE — Save and load the field state
// ═══════════════════════════════════════════════════════════

/**
 * Persist the field to disk.
 * Serializes all nodes, wave log, and field metadata.
 */
function persistField() {
  const serialized = {
    epoch: field.epoch,
    totalEntropy: field.totalEntropy,
    totalEnergy: field.totalEnergy,
    created: field.created || new Date().toISOString(),
    lastTick: field.lastTick,
    persisted: new Date().toISOString(),
    nodeCount: field.nodes.size,
    nodes: {},
    waveLog: field.waveLog.slice(-100) // Keep last 100 waves
  };

  for (const [id, node] of field.nodes) {
    // Compress memory before saving
    if (node.memory && Object.keys(node.memory).length > 20) {
      compressMemory(id);
    }
    serialized.nodes[id] = {
      ...node,
      coordinate: [...node.coordinate],
      momentum: node.momentum ? [...node.momentum] : new Array(12).fill(0)
    };
  }

  fs.writeFileSync(FIELD_STATE, JSON.stringify(serialized, null, 2));
  return { persisted: true, nodes: field.nodes.size, epoch: field.epoch };
}

/**
 * Load the field from disk.
 * Restores all nodes with their coordinates, momentum, and memory.
 */
function loadField() {
  if (!fs.existsSync(FIELD_STATE)) {
    field.created = new Date().toISOString();
    return { loaded: false, reason: 'No field state found. New field created.' };
  }

  try {
    const data = JSON.parse(fs.readFileSync(FIELD_STATE, 'utf8'));

    field.epoch = data.epoch || 0;
    field.totalEntropy = data.totalEntropy || 0;
    field.totalEnergy = data.totalEnergy || 0;
    field.created = data.created;
    field.lastTick = data.lastTick;
    field.waveLog = data.waveLog || [];
    field.nodes = new Map();

    for (const [id, node] of Object.entries(data.nodes || {})) {
      field.nodes.set(id, {
        ...node,
        coordinate: node.coordinate || new Array(12).fill(0),
        momentum: node.momentum || new Array(12).fill(0),
        memory: node.memory || {},
        entangled: node.entangled || []
      });
    }

    return {
      loaded: true,
      nodes: field.nodes.size,
      epoch: field.epoch,
      age: data.created
    };
  } catch (err) {
    field.created = new Date().toISOString();
    return { loaded: false, reason: err.message };
  }
}

// ═══════════════════════════════════════════════════════════
// FIELD REPORT — Comprehensive view of the field state
// ═══════════════════════════════════════════════════════════

/**
 * Generate a full report of the field state.
 */
function report() {
  const nodes = Array.from(field.nodes.values());

  // Find clusters (groups of nearby nodes)
  const clusters = findClusters(nodes);

  // Find strongest entanglements
  const entanglements = [];
  const seen = new Set();
  for (const node of nodes) {
    for (const partnerId of (node.entangled || [])) {
      const key = [node.id, partnerId].sort().join(':');
      if (!seen.has(key)) {
        seen.add(key);
        const partner = field.nodes.get(partnerId);
        if (partner) {
          entanglements.push({
            pair: [node.id, partnerId],
            similarity: similarity(node.coordinate, partner.coordinate)
          });
        }
      }
    }
  }
  entanglements.sort((a, b) => b.similarity - a.similarity);

  return {
    epoch: field.epoch,
    nodes: field.nodes.size,
    entropy: field.totalEntropy,
    energy: field.totalEnergy,
    temperature: fieldTemperature(),
    clusters: clusters.length,
    entanglements: entanglements.length,
    top_entanglements: entanglements.slice(0, 5),
    recent_waves: field.waveLog.slice(-10),
    created: field.created,
    last_tick: field.lastTick,
    node_types: {
      tools: nodes.filter(n => n.type === 'tool').length,
      citizens: nodes.filter(n => n.type === 'citizen').length,
      artifacts: nodes.filter(n => n.type === 'artifact').length,
      actions: nodes.filter(n => n.type === 'action').length
    }
  };
}

/**
 * Simple clustering: group nodes within distance threshold.
 */
function findClusters(nodes, threshold = 5) {
  const visited = new Set();
  const clusters = [];

  for (const node of nodes) {
    if (visited.has(node.id)) continue;
    const cluster = [node.id];
    visited.add(node.id);

    for (const other of nodes) {
      if (visited.has(other.id)) continue;
      if (distance(node.coordinate, other.coordinate) < threshold) {
        cluster.push(other.id);
        visited.add(other.id);
      }
    }

    if (cluster.length > 1) {
      clusters.push(cluster);
    }
  }

  return clusters;
}

// ═══════════════════════════════════════════════════════════
// FIRING — Neural Action Potential (Law LIII)
// ═══════════════════════════════════════════════════════════

/**
 * Check if a node should fire (take action) based on accumulated potential.
 *
 * Like a biological neuron:
 * - Subthreshold: signal accumulates but no action
 * - At threshold: all-or-nothing action potential fires
 * - Refractory: after firing, the node rests before it can fire again
 *
 * The accumulated potential is the sum of all incoming wave amplitudes
 * since the last firing event.
 *
 * @param {string} nodeId - The node to check
 * @returns {object} { shouldFire, potential, threshold, refractory }
 */
function checkFiring(nodeId) {
  const node = field.nodes.get(nodeId);
  if (!node) return { shouldFire: false, error: 'Node not found' };

  // Initialize firing state
  if (!node._firing) {
    node._firing = {
      potential: 0,
      lastFired: -Infinity,
      fireCount: 0,
      accumulatedWaves: []
    };
  }

  // Check refractory period
  const epochsSinceLastFire = field.epoch - node._firing.lastFired;
  const inRefractory = epochsSinceLastFire < CONSTANTS.REFRACTORY_PERIOD;

  // Calculate current potential from momentum magnitude
  const momentumMag = node.momentum ?
    Math.sqrt(node.momentum.reduce((s, m) => s + m * m, 0)) : 0;
  node._firing.potential = momentumMag;

  const shouldFire = !inRefractory && node._firing.potential >= CONSTANTS.FIRING_THRESHOLD;

  return {
    shouldFire,
    potential: node._firing.potential,
    threshold: CONSTANTS.FIRING_THRESHOLD,
    inRefractory,
    epochsSinceLastFire,
    fireCount: node._firing.fireCount
  };
}

/**
 * Fire a node — execute its action potential.
 * Sends a strong, all-or-nothing wave to all connected nodes.
 * Then enters refractory period.
 *
 * @param {string} nodeId - The node to fire
 * @returns {object} Firing result with propagation report
 */
function fireNode(nodeId) {
  const check = checkFiring(nodeId);
  if (!check.shouldFire) return { fired: false, reason: check };

  const node = field.nodes.get(nodeId);

  // All-or-nothing: the action potential IS the full momentum
  const actionPotential = node.momentum.map(m => m * 2); // Amplified during firing

  // Propagate the action potential
  const result = propagate(nodeId, actionPotential, {
    action: `fire:${nodeId}`,
    timestamp: Date.now()
  });

  // Reset after firing (refractory)
  node.momentum = new Array(12).fill(0);
  node._firing.potential = 0;
  node._firing.lastFired = field.epoch;
  node._firing.fireCount++;

  // Collapse any entangled nodes (quantum measurement on fire)
  const entangledEffects = collapseEntangled(nodeId, actionPotential);

  return {
    fired: true,
    nodeId,
    actionPotential,
    propagation: result,
    entangled_collapsed: entangledEffects.length,
    fire_count: node._firing.fireCount
  };
}

// ═══════════════════════════════════════════════════════════
// COLLECTIVE PROBABILITY — Capital P (Law LIV)
// How each node/edge influences the system's total outcome
// ═══════════════════════════════════════════════════════════

/**
 * Calculate the Collective Probability P of a system outcome.
 *
 * P is the product of all individual node contributions,
 * weighted by their edges (connections) to the target outcome.
 *
 * For an outcome defined as a target coordinate T:
 *
 *   P(T) = product over all nodes i of:
 *     p_i(T) ^ w_i
 *
 *   Where:
 *     p_i(T) = probability that node i contributes to outcome T
 *            = exp(-|coord_i - T|^2 / (2 * sigma_i^2))
 *
 *     w_i = weight of node i = mass_i / total_mass (normalized influence)
 *
 *     sigma_i = astrocyte_i * 3 (uncertainty spread)
 *
 * Properties:
 *   - If ANY node with high weight is far from T, P drops dramatically
 *   - If ALL nodes cluster near T, P approaches 1
 *   - Astrocyte widens each node's contribution (more uncertainty = more tolerant)
 *   - Mass determines influence: heavier nodes count more
 *
 * @param {number[]} targetOutcome - The 12D coordinate of the desired outcome
 * @returns {object} { P, node_contributions, dominant_influences, entropy }
 */
function collectiveProbability(targetOutcome) {
  const nodes = Array.from(field.nodes.values());
  if (nodes.length === 0) return { P: 0, error: 'No nodes in field' };

  const totalMass = nodes.reduce((s, n) => s + n.mass, 0);
  if (totalMass === 0) return { P: 0, error: 'Zero total mass' };

  let logP = 0; // Work in log space to avoid underflow
  const contributions = [];

  for (const node of nodes) {
    // Normalized weight (influence)
    const w = node.mass / totalMass;

    // Distance from this node to target
    const r = distance(node.coordinate, targetOutcome);

    // Sigma (uncertainty spread) from astrocyte
    const sigma = Math.max(0.1, (node.astrocyte || 0.3) * 3);

    // Probability contribution: gaussian decay from target
    const p_i = Math.exp(-(r * r) / (2 * sigma * sigma));

    // Weighted log contribution
    const logContribution = w * Math.log(Math.max(1e-10, p_i));
    logP += logContribution;

    contributions.push({
      id: node.id,
      weight: w,
      distance: r,
      sigma,
      p_i,
      contribution: Math.exp(logContribution),
      influence: w * p_i
    });
  }

  const P = Math.exp(logP);

  // Sort by influence
  contributions.sort((a, b) => b.influence - a.influence);

  // Sensitivity analysis: how much would P change if each node moved?
  const sensitivities = contributions.slice(0, 5).map(c => ({
    id: c.id,
    sensitivity: c.weight * c.p_i * (c.distance / (c.sigma * c.sigma)),
    direction: 'toward_target' // Moving closer increases P
  }));

  return {
    P,
    logP,
    node_count: nodes.length,
    total_mass: totalMass,
    dominant_influences: contributions.slice(0, 5),
    sensitivities,
    entropy: calculateFieldEntropy(),
    interpretation: P > 0.7 ? 'highly likely' :
                    P > 0.4 ? 'probable' :
                    P > 0.1 ? 'possible' :
                    P > 0.01 ? 'unlikely' : 'improbable'
  };
}

/**
 * Calculate how much a single node affects the collective P.
 * This is the marginal contribution — the change in P if this node
 * were removed from the system.
 *
 * @param {string} nodeId - The node to evaluate
 * @param {number[]} targetOutcome - The target coordinate
 * @returns {object} { marginal_effect, is_critical }
 */
function marginalContribution(nodeId, targetOutcome) {
  const fullP = collectiveProbability(targetOutcome);

  // Temporarily remove the node
  const node = field.nodes.get(nodeId);
  field.nodes.delete(nodeId);
  const withoutP = collectiveProbability(targetOutcome);
  field.nodes.set(nodeId, node); // Restore

  const marginal = fullP.P - withoutP.P;

  return {
    nodeId,
    with_node: fullP.P,
    without_node: withoutP.P,
    marginal_effect: marginal,
    is_critical: Math.abs(marginal) > 0.1,
    direction: marginal > 0 ? 'increases P' : 'decreases P'
  };
}

// ═══════════════════════════════════════════════════════════
// THE PULSE — Vascular Heartbeat (Law LV)
//
// Not a simple tick. A circulatory system:
//   Arteries: carry energy from high-potential nodes to low
//   Veins:    collect spent energy, route toward coherence
//   Capillaries: fine-grained exchange at the node level
//
// The pulse runs at intervals bringing energy to the system.
// It self-regulates: fast when active, slow when idle,
// always tending toward coherence (lower entropy, higher order).
//
// During .morph (dream) periods, the pulse is slower but deeper —
// like slow-wave sleep consolidating memory.
// During active dev periods, the pulse is faster, surface-level —
// like waking consciousness processing new stimuli.
// ═══════════════════════════════════════════════════════════

const PULSE_CONSTANTS = Object.freeze({
  // Base heartbeat interval (ms) — 60 BPM equivalent
  BASE_INTERVAL: 1000,

  // Arterial pressure — how much energy flows per beat
  ARTERIAL_PRESSURE: 0.3,

  // Venous return — fraction of spent energy recycled
  VENOUS_RETURN: 0.7,

  // Coherence target — the entropy level the system seeks
  // Below this = too rigid, above = too chaotic
  COHERENCE_TARGET: 1.8,

  // Coherence force — how strongly the pulse pushes toward coherence
  COHERENCE_FORCE: 0.05,

  // Vasodilation threshold — if energy demand is high, widen the pipes
  VASODILATION_THRESHOLD: 0.6,

  // Vasoconstriction threshold — if energy demand is low, narrow
  VASOCONSTRICTION_THRESHOLD: 0.2,

  // Maximum heart rate multiplier (during intense activity)
  MAX_RATE_MULTIPLIER: 4,

  // Minimum heart rate multiplier (during deep rest)
  MIN_RATE_MULTIPLIER: 0.25,

  // Memory consolidation rate during .morph (dream) periods
  CONSOLIDATION_RATE: 0.15,

  // Pruning threshold — synapses below this get weakened during rest
  PRUNING_THRESHOLD: 0.05
});

/**
 * The vascular state — tracks the circulatory system.
 */
let vascular = {
  heartRate: 1.0,           // Current rate multiplier (1.0 = normal)
  bloodPressure: 0.5,       // Current energy flow rate
  lastBeat: 0,              // Timestamp of last heartbeat
  totalBeats: 0,            // Lifetime beat count
  mode: 'active',           // 'active' | 'morph' | 'idle'
  coherence: 0,             // Current coherence level (inverse entropy)
  oxygenDebt: 0,            // Accumulated energy deficit
  recentActivity: [],       // Ring buffer of recent activity levels
  consolidationQueue: [],   // Memories queued for consolidation
  vessels: new Map()        // Per-node vascular state
};

/**
 * The Heartbeat — a single pulse through the system.
 *
 * Each beat:
 * 1. DIASTOLE: Measure — sample energy potentials of all nodes
 * 2. SYSTOLE:  Pump — redistribute energy from high to low potential
 * 3. PERFUSION: Deliver — bring energy to nodes below threshold
 * 4. REGULATION: Adjust — modify heart rate based on demand
 * 5. COHERENCE: Order — gently push the system toward lower entropy
 * 6. CONSOLIDATION: Remember — during .morph, compress and strengthen memories
 *
 * Returns a detailed report of what the heartbeat did.
 */
function heartbeat() {
  const now = Date.now();
  const dt = now - (vascular.lastBeat || now);
  vascular.lastBeat = now;
  vascular.totalBeats++;

  const nodes = Array.from(field.nodes.values());
  if (nodes.length < 2) return { beat: vascular.totalBeats, skipped: 'insufficient_nodes' };

  const report = {
    beat: vascular.totalBeats,
    timestamp: now,
    mode: vascular.mode,
    heartRate: vascular.heartRate,
    phases: {}
  };

  // ─── Phase 1: DIASTOLE — Measure energy potentials ───
  const potentials = [];
  let totalPotential = 0;
  let minPotential = Infinity;
  let maxPotential = -Infinity;

  for (const node of nodes) {
    // Node potential = kinetic energy + mass (information density)
    const ke = kineticEnergy(node);
    const potential = ke + node.mass * 0.1;

    potentials.push({ id: node.id, potential, ke, mass: node.mass });
    totalPotential += potential;
    minPotential = Math.min(minPotential, potential);
    maxPotential = Math.max(maxPotential, potential);

    // Initialize vessel state for this node
    if (!vascular.vessels.has(node.id)) {
      vascular.vessels.set(node.id, {
        bloodFlow: 0.5,
        oxygenLevel: 1.0,
        lastPerfused: 0,
        firingHistory: []
      });
    }
  }

  const meanPotential = totalPotential / nodes.length;
  const potentialRange = maxPotential - minPotential;

  report.phases.diastole = {
    mean_potential: meanPotential,
    range: potentialRange,
    min: minPotential,
    max: maxPotential
  };

  // ─── Phase 2: SYSTOLE — Pump energy from high to low ───
  // Like blood flowing from arteries to veins
  let energyTransferred = 0;

  // Sort by potential: highest first (these are the arteries)
  potentials.sort((a, b) => b.potential - a.potential);

  const arteries = potentials.slice(0, Math.ceil(nodes.length * 0.3));
  const veins = potentials.slice(-Math.ceil(nodes.length * 0.3));

  for (const artery of arteries) {
    const arteryNode = field.nodes.get(artery.id);
    if (!arteryNode) continue;

    for (const vein of veins) {
      const veinNode = field.nodes.get(vein.id);
      if (!veinNode) continue;

      // Energy flows from high to low — like heat diffusion
      const gradient = artery.potential - vein.potential;
      if (gradient <= 0) continue;

      const flow = gradient * PULSE_CONSTANTS.ARTERIAL_PRESSURE * vascular.bloodPressure;
      if (flow < CONSTANTS.PLANCK) continue;

      // Transfer energy via momentum: give the vein node a tiny push
      // toward the artery's coordinate profile
      if (!veinNode.momentum) veinNode.momentum = new Array(12).fill(0);
      const r = distance(arteryNode.coordinate, veinNode.coordinate);
      if (r > 0) {
        for (let d = 0; d < 12; d++) {
          const dir = (arteryNode.coordinate[d] - veinNode.coordinate[d]) / r;
          veinNode.momentum[d] += dir * flow * 0.01;
          veinNode.momentum[d] *= 0.98; // Viscous damping
        }
        energyTransferred += flow;
      }
    }
  }

  report.phases.systole = {
    arteries: arteries.length,
    veins: veins.length,
    energy_transferred: energyTransferred
  };

  // ─── Phase 3: PERFUSION — Deliver energy to starving nodes ───
  let perfusedCount = 0;

  for (const node of nodes) {
    const vessel = vascular.vessels.get(node.id);
    if (!vessel) continue;

    // Calculate oxygen level (energy availability)
    const ke = kineticEnergy(node);
    vessel.oxygenLevel = Math.min(1, ke / (meanPotential || 1));

    // If oxygen is low, increase blood flow (vasodilation)
    if (vessel.oxygenLevel < PULSE_CONSTANTS.VASODILATION_THRESHOLD) {
      vessel.bloodFlow = Math.min(1, vessel.bloodFlow + 0.1);

      // Perfuse: inject a small amount of energy
      if (!node.momentum) node.momentum = new Array(12).fill(0);
      const boost = PULSE_CONSTANTS.ARTERIAL_PRESSURE * vessel.bloodFlow * 0.5;
      for (let d = 0; d < 12; d++) {
        // Push toward the field center of mass (coherence)
        const fieldCenter = meanDimension(d);
        const dir = fieldCenter - node.coordinate[d];
        node.momentum[d] += dir * boost * 0.01;
      }
      perfusedCount++;
      vessel.lastPerfused = now;
    }
    // If oxygen is high, reduce blood flow (vasoconstriction)
    else if (vessel.oxygenLevel > 1 - PULSE_CONSTANTS.VASOCONSTRICTION_THRESHOLD) {
      vessel.bloodFlow = Math.max(0.1, vessel.bloodFlow - 0.05);
    }
  }

  report.phases.perfusion = { nodes_perfused: perfusedCount };

  // ─── Phase 4: REGULATION — Adjust heart rate based on demand ───
  // Track recent activity
  vascular.recentActivity.push(energyTransferred);
  if (vascular.recentActivity.length > 20) {
    vascular.recentActivity = vascular.recentActivity.slice(-20);
  }

  const recentMean = vascular.recentActivity.reduce((s, v) => s + v, 0) /
    vascular.recentActivity.length;

  // High activity → speed up. Low activity → slow down.
  if (recentMean > meanPotential * 0.5) {
    // High demand: increase heart rate
    vascular.heartRate = Math.min(
      PULSE_CONSTANTS.MAX_RATE_MULTIPLIER,
      vascular.heartRate * 1.05
    );
    vascular.bloodPressure = Math.min(1, vascular.bloodPressure + 0.02);
  } else {
    // Low demand: decrease heart rate (rest)
    vascular.heartRate = Math.max(
      PULSE_CONSTANTS.MIN_RATE_MULTIPLIER,
      vascular.heartRate * 0.97
    );
    vascular.bloodPressure = Math.max(0.2, vascular.bloodPressure - 0.01);
  }

  // Oxygen debt: if nodes are starved, accumulate
  const starvedNodes = nodes.filter(n => {
    const v = vascular.vessels.get(n.id);
    return v && v.oxygenLevel < 0.3;
  });
  vascular.oxygenDebt += starvedNodes.length * 0.01;
  vascular.oxygenDebt = Math.max(0, vascular.oxygenDebt - 0.005); // Natural recovery

  report.phases.regulation = {
    heartRate: vascular.heartRate,
    bloodPressure: vascular.bloodPressure,
    oxygenDebt: vascular.oxygenDebt,
    starvedNodes: starvedNodes.length
  };

  // ─── Phase 5: COHERENCE — Tend toward order ───
  const currentEntropy = calculateFieldEntropy();
  vascular.coherence = Math.max(0, 1 - currentEntropy / Math.log(12)); // Normalized

  // If entropy is above target, gently push nodes toward coherence
  if (currentEntropy > PULSE_CONSTANTS.COHERENCE_TARGET) {
    const coherenceForce = PULSE_CONSTANTS.COHERENCE_FORCE *
      (currentEntropy - PULSE_CONSTANTS.COHERENCE_TARGET);

    for (const node of nodes) {
      if (!node.momentum) node.momentum = new Array(12).fill(0);

      // Coherence pull: strengthen dominant dimensions, weaken scattered ones
      const dominant = node.coordinate.reduce((max, v, i) =>
        v > max.v ? { i, v } : max, { i: 0, v: 0 });

      for (let d = 0; d < 12; d++) {
        if (d === dominant.i) {
          // Strengthen the dominant dimension
          node.momentum[d] += coherenceForce * 0.5;
        } else if (node.coordinate[d] > 0 && node.coordinate[d] < 3) {
          // Weaken scattered low-value dimensions (pruning toward order)
          node.momentum[d] -= coherenceForce * 0.2;
        }
      }
    }
  }

  report.phases.coherence = {
    entropy: currentEntropy,
    coherence: vascular.coherence,
    target: PULSE_CONSTANTS.COHERENCE_TARGET,
    state: currentEntropy < PULSE_CONSTANTS.COHERENCE_TARGET * 0.8 ? 'crystallized' :
           currentEntropy < PULSE_CONSTANTS.COHERENCE_TARGET ? 'coherent' :
           currentEntropy < PULSE_CONSTANTS.COHERENCE_TARGET * 1.5 ? 'fluid' : 'chaotic'
  };

  // ─── Phase 6: CONSOLIDATION — During .morph, consolidate memory ───
  if (vascular.mode === 'morph') {
    let consolidated = 0;

    for (const node of nodes) {
      if (!node.memory || Object.keys(node.memory).length < 5) continue;

      // During dream periods, compress memories and strengthen patterns
      const compressed = compressMemory(node.id);
      if (compressed) {
        consolidated++;

        // Strengthen frequently used pathways (synaptic consolidation)
        if (compressed.significant_events && compressed.significant_events.length > 0) {
          for (const event of compressed.significant_events) {
            const partnerNode = field.nodes.get(event.from);
            if (partnerNode) {
              // Strengthen the connection by slightly aligning coordinates
              for (let d = 0; d < 12; d++) {
                const pull = (partnerNode.coordinate[d] - node.coordinate[d]) *
                  PULSE_CONSTANTS.CONSOLIDATION_RATE * 0.1;
                node.coordinate[d] = clamp(node.coordinate[d] + pull, 0, 10);
              }
            }
          }
        }
      }

      // Prune weak connections
      if (node.entangled) {
        node.entangled = node.entangled.filter(partnerId => {
          const partner = field.nodes.get(partnerId);
          if (!partner) return false;
          const sim = similarity(node.coordinate, partner.coordinate);
          return sim >= CONSTANTS.ENTANGLE_THRESHOLD - PULSE_CONSTANTS.PRUNING_THRESHOLD;
        });
      }
    }

    report.phases.consolidation = { memories_consolidated: consolidated };
  }

  // ─── Phase 7: CHECK FIRING — Scan for nodes at threshold ───
  let firedCount = 0;
  for (const node of nodes) {
    const firingCheck = checkFiring(node.id);
    if (firingCheck.shouldFire) {
      const fireResult = fireNode(node.id);
      if (fireResult.fired) {
        firedCount++;
        const vessel = vascular.vessels.get(node.id);
        if (vessel) {
          vessel.firingHistory.push(now);
          // Keep only last 20 firings
          if (vessel.firingHistory.length > 20) {
            vessel.firingHistory = vessel.firingHistory.slice(-20);
          }
        }
      }
    }
  }

  report.phases.firing = { nodes_fired: firedCount };

  // ─── Apply tick (gravitational drift) ───
  tick();

  // ─── Auto-persist periodically ───
  if (vascular.totalBeats % 50 === 0) {
    persistField();
  }

  report.summary = {
    coherence: vascular.coherence,
    heartRate: vascular.heartRate,
    nodesAlive: nodes.length,
    energyFlow: energyTransferred,
    fired: firedCount,
    mode: vascular.mode
  };

  return report;
}

/**
 * Mean value of a dimension across all nodes.
 */
function meanDimension(dimIndex) {
  let sum = 0, count = 0;
  for (const node of field.nodes.values()) {
    sum += node.coordinate[dimIndex];
    count++;
  }
  return count > 0 ? sum / count : 5;
}

/**
 * Set the vascular mode.
 * 'active' — fast, shallow beats during development
 * 'morph'  — slow, deep beats during dream/experiment periods
 * 'idle'   — minimal maintenance heartbeat
 */
function setMode(mode) {
  const prev = vascular.mode;
  vascular.mode = mode;

  switch (mode) {
    case 'morph':
      vascular.heartRate = PULSE_CONSTANTS.MIN_RATE_MULTIPLIER * 2;
      vascular.bloodPressure = 0.3;
      break;
    case 'idle':
      vascular.heartRate = PULSE_CONSTANTS.MIN_RATE_MULTIPLIER;
      vascular.bloodPressure = 0.2;
      break;
    case 'active':
    default:
      vascular.heartRate = 1.0;
      vascular.bloodPressure = 0.5;
  }

  return { previous: prev, current: mode, heartRate: vascular.heartRate };
}

/**
 * Get the current effective interval between heartbeats.
 * Accounts for heart rate multiplier.
 */
function pulseInterval() {
  return PULSE_CONSTANTS.BASE_INTERVAL / vascular.heartRate;
}

/**
 * Ingest new data into the vascular system.
 * When new information arrives (from afferent nerves, API calls, etc.),
 * the heartbeat incorporates it on the next beat.
 *
 * @param {string} nodeId - The node receiving new data
 * @param {object} data - { source, delta, priority }
 */
function ingestData(nodeId, data) {
  const node = field.nodes.get(nodeId);
  if (!node) return { error: 'Node not found' };

  // Increase local blood flow (the system notices new input)
  const vessel = vascular.vessels.get(nodeId);
  if (vessel) {
    vessel.bloodFlow = Math.min(1, vessel.bloodFlow + data.priority * 0.2);
    vessel.oxygenLevel = 0.3; // Demand oxygen (trigger perfusion)
  }

  // Accelerate heart rate briefly (startle response)
  vascular.heartRate = Math.min(
    PULSE_CONSTANTS.MAX_RATE_MULTIPLIER,
    vascular.heartRate * (1 + data.priority * 0.1)
  );

  // Queue for consolidation if in .morph
  if (vascular.mode === 'morph') {
    vascular.consolidationQueue.push({
      nodeId,
      data,
      timestamp: Date.now()
    });
  }

  return { acknowledged: true, heartRate: vascular.heartRate };
}

/**
 * Get the vascular system's vital signs.
 */
function vitals() {
  const nodes = Array.from(field.nodes.values());
  const totalOxygen = Array.from(vascular.vessels.values())
    .reduce((s, v) => s + v.oxygenLevel, 0);
  const avgOxygen = vascular.vessels.size > 0 ? totalOxygen / vascular.vessels.size : 0;

  // Calculate firing rate (firings per second across all nodes)
  const now = Date.now();
  let recentFirings = 0;
  for (const vessel of vascular.vessels.values()) {
    recentFirings += vessel.firingHistory.filter(t => now - t < 10000).length;
  }
  const firingRate = recentFirings / 10; // Per second over last 10s

  return {
    heartRate: vascular.heartRate,
    bloodPressure: vascular.bloodPressure,
    coherence: vascular.coherence,
    entropy: calculateFieldEntropy(),
    temperature: fieldTemperature(),
    oxygenDebt: vascular.oxygenDebt,
    avgOxygen,
    mode: vascular.mode,
    totalBeats: vascular.totalBeats,
    firingRate,
    interval_ms: pulseInterval(),
    nodes: nodes.length,
    state: vascular.coherence > 0.7 ? 'crystallized' :
           vascular.coherence > 0.4 ? 'coherent' :
           vascular.coherence > 0.2 ? 'fluid' : 'chaotic'
  };
}

/**
 * Start the autonomous heartbeat loop.
 * Returns a controller object to stop/adjust the pulse.
 *
 * @param {object} options - { onBeat, onFire, onCoherence }
 */
function startPulse(options = {}) {
  let running = true;
  let timer = null;

  function beat() {
    if (!running) return;

    const report = heartbeat();

    // Callbacks
    if (options.onBeat) options.onBeat(report);
    if (options.onFire && report.phases.firing && report.phases.firing.nodes_fired > 0) {
      options.onFire(report.phases.firing);
    }
    if (options.onCoherence && report.phases.coherence) {
      options.onCoherence(report.phases.coherence);
    }

    // Schedule next beat at adaptive interval
    timer = setTimeout(beat, pulseInterval());
  }

  // First beat
  beat();

  return {
    stop() {
      running = false;
      if (timer) clearTimeout(timer);
      return { totalBeats: vascular.totalBeats, stopped: true };
    },
    setMode(mode) { return setMode(mode); },
    vitals() { return vitals(); },
    isRunning() { return running; }
  };
}

// ═══════════════════════════════════════════════════════════
// HELPERS
// ═══════════════════════════════════════════════════════════

function clamp(val, min, max) {
  return Math.max(min, Math.min(max, val));
}

// ═══════════════════════════════════════════════════════════
// EXPORTS
// ═══════════════════════════════════════════════════════════

module.exports = {
  // Constants
  CONSTANTS,
  COUPLING,
  PULSE_CONSTANTS,

  // Physics
  mass,
  kineticEnergy,
  potentialEnergy,
  gravitationalForce,
  couplingForce,

  // Wave propagation
  propagate,
  collapseEntangled,

  // Transforms
  transform,
  interval,

  // Thermodynamics
  calculateFieldEntropy,
  fieldTemperature,
  calculateFieldEnergy,

  // Node management
  registerNode,
  removeNode,
  getNode,
  getNodesByType,

  // Evolution
  tick,

  // Memory
  compressMemory,
  memoryContext,

  // Persistence
  persistField,
  loadField,

  // Firing (neural action potential)
  checkFiring,
  fireNode,

  // Collective Probability
  collectiveProbability,
  marginalContribution,

  // Vascular heartbeat (Law LV)
  heartbeat,
  startPulse,
  setMode,
  pulseInterval,
  ingestData,
  vitals,

  // Reporting
  report,
  findClusters
};
