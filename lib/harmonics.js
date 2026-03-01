/**
 * L7 Harmonics — Self-Tuning Decoherence Damper
 * Law LVIII — The field tends toward harmony. Noise decays. Music persists.
 *
 * Patent: Self-Tuning Harmonic Field Resonance System
 * Inventor: Alberto Valido Delgado
 * Filed: 2026-03-01
 *
 * The field is an instrument. Every node is a string. When strings vibrate
 * at harmonic ratios, the system rings clear. When they drift into dissonance,
 * this module applies gentle damping — like a concert hall absorbing echoes
 * while letting the fundamental tone persist.
 *
 * Core principles:
 *   1. Harmonic ratios (1:2, 2:3, 3:4, 4:5) between node coordinates
 *      create constructive interference — amplified coupling
 *   2. Non-harmonic frequency components decay exponentially
 *   3. Attractor basins (chords in 12D space) are stable configurations
 *      the field gravitates toward
 *   4. Self-tuning: continuous measurement, gentle correction, never force
 *   5. Resonance cascades: locked nodes pull neighbors into harmony
 *   6. Decoherence sources are tracked and targeted for damping
 */

const { distance, similarity, DIMENSIONS } = require('./dodecahedron');

// ═══════════════════════════════════════════════════════════
// CONSTANTS — The tuning parameters of harmonic physics
// ═══════════════════════════════════════════════════════════

const HARMONIC_CONSTANTS = Object.freeze({
  // The overtone series — ratios that create consonance
  // Each entry: [numerator, denominator, name, consonance_strength]
  // Consonance strength: 1.0 = perfect, 0.0 = maximally dissonant
  INTERVALS: Object.freeze([
    [1, 1, 'unison',       1.00],
    [1, 2, 'octave',       0.95],
    [2, 3, 'fifth',        0.90],
    [3, 4, 'fourth',       0.85],
    [4, 5, 'major_third',  0.80],
    [5, 6, 'minor_third',  0.75],
    [3, 5, 'major_sixth',  0.70],
    [5, 8, 'minor_sixth',  0.65],
    [8, 9, 'major_second', 0.50],
    [9, 16, 'minor_seventh', 0.45],
    [15, 16, 'minor_second', 0.30]
  ]),

  // Tolerance for detecting harmonic ratios
  // Within this fraction of the ideal ratio, we consider it "near-harmonic"
  HARMONIC_TOLERANCE: 0.08,

  // Decoherence decay rate — exponential decay constant
  // Higher = faster noise removal. Like room damping in acoustics.
  DECOHERENCE_DECAY: 0.12,

  // Minimum amplitude below which a frequency component is considered noise
  NOISE_FLOOR: 0.05,

  // Maximum correction force per tuning step
  // Never force — always tend. This is the ceiling.
  MAX_CORRECTION: 0.15,

  // Minimum correction — below this, don't bother (saves computation)
  MIN_CORRECTION: 0.001,

  // Cascade threshold — when this fraction of nodes are in resonance,
  // sympathetic vibration kicks in
  CASCADE_THRESHOLD: 0.3,

  // Cascade propagation strength — how strongly locked nodes pull neighbors
  CASCADE_FORCE: 0.08,

  // Coupling amplification for harmonic pairs
  // When two nodes are near-harmonic, their gravitational coupling
  // is multiplied by this factor
  HARMONIC_AMPLIFICATION: 2.5,

  // Self-tuning gain — how aggressively the system corrects
  // Scales with dissonance: more dissonant = stronger correction
  TUNING_GAIN: 0.03,

  // Number of dimensions in the coordinate system
  DIMS: 12
});

// ═══════════════════════════════════════════════════════════
// ATTRACTOR BASINS — Stable harmonic configurations in 12D
//
// These are the "chords" the field wants to play.
// Each attractor defines a ratio pattern across the 12 dimensions.
// The field naturally gravitates toward the nearest one.
// ═══════════════════════════════════════════════════════════

const ATTRACTORS = Object.freeze({
  /**
   * UNISON — All dimensions aligned.
   * Maximum coherence. The field as a single voice.
   * Rare and powerful. Like a laser: all photons in phase.
   */
  unison: {
    name: 'unison',
    description: 'All dimensions aligned — maximum coherence',
    // All dimensions at the same relative intensity
    ratios: [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    stability: 1.0,
    quality: 'crystalline'
  },

  /**
   * OCTAVE — Complementary pairs.
   * Classical dimensions high, transpersonal dimensions at half.
   * Or vice versa. The yin-yang of the field.
   */
  octave: {
    name: 'octave',
    description: 'Alternating high/low — complementary pairs',
    // Classical (0-5) full, transpersonal (6-11) at half
    ratios: [2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1],
    stability: 0.9,
    quality: 'balanced'
  },

  /**
   * FIFTH — The 3:2 ratio. The most consonant interval after unison/octave.
   * Pythagoras heard this in the blacksmith's hammers.
   * The field at its most natural creative tension.
   */
  fifth: {
    name: 'fifth',
    description: 'The 3:2 ratio — most consonant interval',
    // Alternating 3:2 pattern across dimension pairs
    ratios: [3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2],
    stability: 0.85,
    quality: 'resonant'
  },

  /**
   * MAJOR TRIAD — 4:5:6 ratio. Stable creative state.
   * The building block of Western harmony.
   * Three groups of four dimensions each in 4:5:6 ratio.
   */
  major_triad: {
    name: 'major_triad',
    description: 'The 4:5:6 ratio — stable creative state',
    // Three groups: dims 0-3 at 4, dims 4-7 at 5, dims 8-11 at 6
    ratios: [4, 4, 4, 4, 5, 5, 5, 5, 6, 6, 6, 6],
    stability: 0.8,
    quality: 'creative'
  },

  /**
   * MINOR TRIAD — 10:12:15 ratio. Reflective/introspective state.
   * Darker, more inward. The field in contemplation.
   * Three groups in minor harmony.
   */
  minor_triad: {
    name: 'minor_triad',
    description: 'The 10:12:15 ratio — reflective/introspective state',
    // Three groups: dims 0-3 at 10, dims 4-7 at 12, dims 8-11 at 15
    ratios: [10, 10, 10, 10, 12, 12, 12, 12, 15, 15, 15, 15],
    stability: 0.75,
    quality: 'reflective'
  }
});

// ═══════════════════════════════════════════════════════════
// HARMONIC DETECTION — Analyze the field's musical structure
// ═══════════════════════════════════════════════════════════

/**
 * Detect harmonic relationships between all node pairs in the field.
 *
 * For each pair of nodes, examines every dimension and checks whether
 * the ratio of their coordinate values falls near a known harmonic
 * interval (within HARMONIC_TOLERANCE). Pairs with more harmonic
 * dimensions are more consonant.
 *
 * @param {object} fieldTheory - The field module (must expose getNode, report, etc.)
 * @returns {object} {
 *   pairs: [{nodeA, nodeB, harmonics: [{dim, ratio, interval, consonance}], score}],
 *   overall_consonance: number (0-1),
 *   dominant_interval: string,
 *   harmonic_count: number,
 *   dissonant_count: number
 * }
 */
function detectHarmonics(fieldTheory) {
  const nodes = _getAllNodes(fieldTheory);
  if (nodes.length < 2) {
    return {
      pairs: [],
      overall_consonance: 1.0,
      dominant_interval: 'unison',
      harmonic_count: 0,
      dissonant_count: 0
    };
  }

  const pairs = [];
  let totalConsonance = 0;
  let pairCount = 0;
  const intervalCounts = {};

  for (let i = 0; i < nodes.length; i++) {
    for (let j = i + 1; j < nodes.length; j++) {
      const nodeA = nodes[i];
      const nodeB = nodes[j];
      const pairHarmonics = _analyzePairHarmonics(nodeA, nodeB);

      pairs.push({
        nodeA: nodeA.id,
        nodeB: nodeB.id,
        harmonics: pairHarmonics.intervals,
        score: pairHarmonics.score
      });

      totalConsonance += pairHarmonics.score;
      pairCount++;

      // Count interval occurrences
      for (const h of pairHarmonics.intervals) {
        intervalCounts[h.interval] = (intervalCounts[h.interval] || 0) + 1;
      }
    }
  }

  // Find dominant interval
  let dominantInterval = 'none';
  let maxCount = 0;
  for (const [interval, count] of Object.entries(intervalCounts)) {
    if (count > maxCount) {
      maxCount = count;
      dominantInterval = interval;
    }
  }

  const harmonicCount = pairs.filter(p => p.score > 0.5).length;
  const dissonantCount = pairs.filter(p => p.score < 0.3).length;

  return {
    pairs,
    overall_consonance: pairCount > 0 ? totalConsonance / pairCount : 1.0,
    dominant_interval: dominantInterval,
    harmonic_count: harmonicCount,
    dissonant_count: dissonantCount
  };
}

/**
 * Analyze the harmonic relationship between two nodes.
 * Checks all 12 dimensions for ratio consonance.
 *
 * @param {object} nodeA - Field node
 * @param {object} nodeB - Field node
 * @returns {object} { intervals: [...], score: number }
 */
function _analyzePairHarmonics(nodeA, nodeB) {
  const intervals = [];
  let consonanceSum = 0;
  let measuredDims = 0;

  for (let d = 0; d < HARMONIC_CONSTANTS.DIMS; d++) {
    const a = nodeA.coordinate[d];
    const b = nodeB.coordinate[d];

    // Skip dimensions where either node is near zero (no tone to compare)
    if (a < HARMONIC_CONSTANTS.NOISE_FLOOR || b < HARMONIC_CONSTANTS.NOISE_FLOOR) continue;

    measuredDims++;

    // Calculate the ratio (always >= 1)
    const raw = a >= b ? a / b : b / a;

    // Check against all known harmonic intervals
    let bestMatch = null;
    let bestDelta = Infinity;

    for (const [num, den, name, consonance] of HARMONIC_CONSTANTS.INTERVALS) {
      const idealRatio = Math.max(num, den) / Math.min(num, den);
      const delta = Math.abs(raw - idealRatio);

      if (delta < HARMONIC_CONSTANTS.HARMONIC_TOLERANCE && delta < bestDelta) {
        bestDelta = delta;
        bestMatch = { dim: d, ratio: raw, interval: name, consonance, delta };
      }
    }

    if (bestMatch) {
      intervals.push(bestMatch);
      consonanceSum += bestMatch.consonance;
    } else {
      // Dissonant dimension — score falls
      consonanceSum += _dissonanceScore(raw);
    }
  }

  return {
    intervals,
    score: measuredDims > 0 ? consonanceSum / measuredDims : 0.5
  };
}

/**
 * Score a non-harmonic ratio. Further from any harmonic = more dissonant.
 * Returns a value between 0 (maximally dissonant) and 0.3 (nearly harmonic).
 */
function _dissonanceScore(ratio) {
  let minDistance = Infinity;
  for (const [num, den] of HARMONIC_CONSTANTS.INTERVALS) {
    const ideal = Math.max(num, den) / Math.min(num, den);
    minDistance = Math.min(minDistance, Math.abs(ratio - ideal));
  }
  // Closer to any harmonic = less dissonant
  return Math.max(0, 0.3 - minDistance * 0.1);
}

// ═══════════════════════════════════════════════════════════
// DECOHERENCE DAMPING — Noise decays, music persists
// ═══════════════════════════════════════════════════════════

/**
 * Apply decoherence damping to the field.
 *
 * For each node, decompose its momentum into harmonic and non-harmonic
 * components (relative to its neighbors). The harmonic components persist;
 * the non-harmonic components undergo exponential decay.
 *
 * Like a tuning fork: the pure tone rings on, the noise of the strike dies.
 *
 * @param {object} fieldTheory - The field module
 * @param {number} strength - Damping strength multiplier (0-1). Default 1.0.
 * @returns {object} {
 *   nodes_damped: number,
 *   total_energy_removed: number,
 *   decoherence_sources: [{nodeId, source, magnitude}]
 * }
 */
function dampDecoherence(fieldTheory, strength = 1.0) {
  const nodes = _getAllNodes(fieldTheory);
  if (nodes.length < 2) return { nodes_damped: 0, total_energy_removed: 0, decoherence_sources: [] };

  const decay = HARMONIC_CONSTANTS.DECOHERENCE_DECAY * _clamp(strength, 0, 1);
  let nodesDamped = 0;
  let totalEnergyRemoved = 0;
  const decoherenceSources = [];

  for (const node of nodes) {
    if (!node.momentum) continue;

    // Find neighbors — nodes within a meaningful interaction distance
    const neighbors = _findNeighbors(node, nodes, 8);
    if (neighbors.length === 0) continue;

    // Compute the "harmonic projection" of this node's momentum
    // The component of momentum that aligns with harmonic directions
    const harmonicComponent = new Array(HARMONIC_CONSTANTS.DIMS).fill(0);
    const noiseComponent = new Array(HARMONIC_CONSTANTS.DIMS).fill(0);

    for (let d = 0; d < HARMONIC_CONSTANTS.DIMS; d++) {
      const m = node.momentum[d];
      if (Math.abs(m) < HARMONIC_CONSTANTS.MIN_CORRECTION) continue;

      // Check if this dimension's movement creates or destroys harmony
      const currentHarmony = _dimensionHarmony(node, neighbors, d);
      const projectedHarmony = _dimensionHarmony(
        _nudgedNode(node, d, m * 0.1), neighbors, d
      );

      if (projectedHarmony >= currentHarmony) {
        // Movement is toward harmony — preserve it
        harmonicComponent[d] = m;
      } else {
        // Movement is away from harmony — this is decoherence
        harmonicComponent[d] = m * (1 - decay);
        noiseComponent[d] = m * decay;
      }
    }

    // Apply the damped momentum
    let nodeDamped = false;
    let nodeEnergy = 0;
    for (let d = 0; d < HARMONIC_CONSTANTS.DIMS; d++) {
      if (Math.abs(noiseComponent[d]) > HARMONIC_CONSTANTS.MIN_CORRECTION) {
        nodeEnergy += noiseComponent[d] * noiseComponent[d];
        node.momentum[d] = harmonicComponent[d];
        nodeDamped = true;
      }
    }

    if (nodeDamped) {
      nodesDamped++;
      totalEnergyRemoved += nodeEnergy;

      // Track decoherence sources
      const source = _identifyDecoherenceSource(node, noiseComponent);
      if (source) {
        decoherenceSources.push({ nodeId: node.id, ...source });
      }
    }
  }

  return {
    nodes_damped: nodesDamped,
    total_energy_removed: totalEnergyRemoved,
    decoherence_sources: decoherenceSources
  };
}

/**
 * Identify what is causing decoherence in a node's momentum.
 *
 * @param {object} node - The field node
 * @param {number[]} noiseComponent - The non-harmonic momentum
 * @returns {object|null} { source, magnitude, dimensions }
 */
function _identifyDecoherenceSource(node, noiseComponent) {
  const magnitude = Math.sqrt(noiseComponent.reduce((s, n) => s + n * n, 0));
  if (magnitude < HARMONIC_CONSTANTS.NOISE_FLOOR) return null;

  // Find which dimensions are most noisy
  const noisyDims = [];
  for (let d = 0; d < HARMONIC_CONSTANTS.DIMS; d++) {
    if (Math.abs(noiseComponent[d]) > HARMONIC_CONSTANTS.NOISE_FLOOR) {
      noisyDims.push({
        dim: d,
        name: DIMENSIONS[d].name,
        noise: Math.abs(noiseComponent[d])
      });
    }
  }
  noisyDims.sort((a, b) => b.noise - a.noise);

  // Classify the source
  let source = 'random_drift';
  if (noisyDims.length > 6) {
    source = 'external_input'; // Broad-spectrum noise = external disruption
  } else if (noisyDims.length <= 2) {
    source = 'dimensional_conflict'; // Narrow-band noise = internal tension
  }

  return {
    source,
    magnitude,
    dimensions: noisyDims.slice(0, 3) // Top 3 noisy dimensions
  };
}

// ═══════════════════════════════════════════════════════════
// ATTRACTOR DYNAMICS — The field falls into harmonic chords
// ═══════════════════════════════════════════════════════════

/**
 * Nudge the field toward the nearest harmonic attractor basin.
 *
 * For each node, determine which attractor configuration the field
 * is closest to, then apply a gentle corrective force proportional
 * to the distance from that attractor. Stronger when far (urgent),
 * gentle when close (refinement). Never force — always tend.
 *
 * @param {object} fieldTheory - The field module
 * @returns {object} {
 *   nearest_attractor: string,
 *   attractor_distance: number,
 *   nodes_adjusted: number,
 *   correction_applied: number
 * }
 */
function attractToHarmony(fieldTheory) {
  const nodes = _getAllNodes(fieldTheory);
  if (nodes.length === 0) {
    return { nearest_attractor: 'none', attractor_distance: 0, nodes_adjusted: 0, correction_applied: 0 };
  }

  // Calculate the field's aggregate profile — mean coordinate across all nodes
  const fieldProfile = _fieldMeanProfile(nodes);

  // Find nearest attractor
  let nearestAttractor = null;
  let nearestDistance = Infinity;

  for (const [name, attractor] of Object.entries(ATTRACTORS)) {
    const d = _attractorDistance(fieldProfile, attractor.ratios);
    if (d < nearestDistance) {
      nearestDistance = d;
      nearestAttractor = attractor;
    }
  }

  if (!nearestAttractor) {
    return { nearest_attractor: 'none', attractor_distance: 0, nodes_adjusted: 0, correction_applied: 0 };
  }

  // Calculate correction strength — stronger when far, gentle when close
  // Like gravity: F = gain * distance (linear, not quadratic, to avoid runaway)
  const rawStrength = HARMONIC_CONSTANTS.TUNING_GAIN * nearestDistance;
  const correctionStrength = _clamp(rawStrength, HARMONIC_CONSTANTS.MIN_CORRECTION, HARMONIC_CONSTANTS.MAX_CORRECTION);

  // Generate the target profile from the attractor ratios
  const targetProfile = _attractorTarget(fieldProfile, nearestAttractor.ratios);

  // Apply correction to each node
  let nodesAdjusted = 0;
  let totalCorrection = 0;

  for (const node of nodes) {
    if (!node.momentum) node.momentum = new Array(HARMONIC_CONSTANTS.DIMS).fill(0);

    let adjusted = false;
    for (let d = 0; d < HARMONIC_CONSTANTS.DIMS; d++) {
      // The correction vector: direction from current toward target
      const delta = targetProfile[d] - node.coordinate[d];
      const correction = delta * correctionStrength * nearestAttractor.stability;

      if (Math.abs(correction) > HARMONIC_CONSTANTS.MIN_CORRECTION) {
        // Apply as momentum nudge — the field drifts, it does not jump
        node.momentum[d] += correction;
        totalCorrection += Math.abs(correction);
        adjusted = true;
      }
    }

    if (adjusted) nodesAdjusted++;
  }

  return {
    nearest_attractor: nearestAttractor.name,
    attractor_quality: nearestAttractor.quality,
    attractor_distance: nearestDistance,
    nodes_adjusted: nodesAdjusted,
    correction_applied: totalCorrection
  };
}

/**
 * Calculate distance from a field profile to an attractor's ratio pattern.
 *
 * The attractor ratios are relative — we normalize the field profile
 * to the same scale and compute Euclidean distance.
 *
 * @param {number[]} profile - 12D mean coordinate of the field
 * @param {number[]} ratios - The attractor's 12D ratio pattern
 * @returns {number} Distance (lower = closer to this attractor)
 */
function _attractorDistance(profile, ratios) {
  // Normalize ratios to the same scale as the profile
  const maxProfile = Math.max(...profile, 0.01);
  const maxRatio = Math.max(...ratios, 0.01);
  const scale = maxProfile / maxRatio;

  let dist2 = 0;
  for (let d = 0; d < HARMONIC_CONSTANTS.DIMS; d++) {
    const diff = profile[d] - ratios[d] * scale;
    dist2 += diff * diff;
  }

  return Math.sqrt(dist2);
}

/**
 * Generate a target coordinate profile from attractor ratios.
 * Preserves the field's overall energy level while reshaping
 * the distribution to match the attractor pattern.
 *
 * @param {number[]} currentProfile - Current field mean
 * @param {number[]} ratios - Attractor ratio pattern
 * @returns {number[]} Target 12D coordinate
 */
function _attractorTarget(currentProfile, ratios) {
  // Total energy to preserve
  const totalEnergy = currentProfile.reduce((s, v) => s + v, 0);
  const ratioSum = ratios.reduce((s, v) => s + v, 0);

  if (ratioSum === 0) return [...currentProfile];

  const target = new Array(HARMONIC_CONSTANTS.DIMS);
  for (let d = 0; d < HARMONIC_CONSTANTS.DIMS; d++) {
    // Distribute energy according to the attractor's ratios
    target[d] = _clamp((ratios[d] / ratioSum) * totalEnergy, 0, 10);
  }

  return target;
}

// ═══════════════════════════════════════════════════════════
// RESONANCE CASCADE — Sympathetic vibration
// ═══════════════════════════════════════════════════════════

/**
 * Trigger a resonance cascade from a source node.
 *
 * When a node locks into a harmonic pattern, it can pull nearby
 * nodes into resonance — like striking one piano string and hearing
 * the octave ring in sympathy. The cascade propagates outward,
 * weakening with distance, until it can no longer overcome noise.
 *
 * @param {object} fieldTheory - The field module
 * @param {string} sourceNodeId - The node that initiates the cascade
 * @returns {object} {
 *   source: string,
 *   cascade_depth: number,
 *   nodes_resonating: [{id, depth, coupling}],
 *   total_resonance: number
 * }
 */
function resonanceCascade(fieldTheory, sourceNodeId) {
  const source = fieldTheory.getNode(sourceNodeId);
  if (!source) {
    return { source: sourceNodeId, cascade_depth: 0, nodes_resonating: [], total_resonance: 0 };
  }

  const nodes = _getAllNodes(fieldTheory);
  const resonating = [];
  const visited = new Set([sourceNodeId]);
  let frontier = [{ node: source, depth: 0, coupling: 1.0 }];
  let maxDepth = 0;
  let totalResonance = 0;

  while (frontier.length > 0) {
    const nextFrontier = [];

    for (const { node: currentNode, depth, coupling } of frontier) {
      // Find nodes that are harmonically related to the current node
      for (const candidate of nodes) {
        if (visited.has(candidate.id)) continue;

        const dist = distance(currentNode.coordinate, candidate.coordinate);
        if (dist < 0.01) continue; // Avoid self-comparison artifacts

        // Check harmonic relationship
        const pairHarmonics = _analyzePairHarmonics(currentNode, candidate);

        // Only cascade to nodes that are already somewhat consonant
        if (pairHarmonics.score < 0.4) continue;

        // Cascade coupling attenuates with distance and depth
        const attenuation = Math.exp(-dist * 0.1) * Math.exp(-depth * 0.3);
        const effectiveCoupling = coupling * pairHarmonics.score * attenuation;

        // Below threshold — cascade dies here
        if (effectiveCoupling < HARMONIC_CONSTANTS.MIN_CORRECTION) continue;

        visited.add(candidate.id);

        // Apply sympathetic force: nudge candidate toward harmonic alignment with source
        if (!candidate.momentum) candidate.momentum = new Array(HARMONIC_CONSTANTS.DIMS).fill(0);

        for (let d = 0; d < HARMONIC_CONSTANTS.DIMS; d++) {
          const harmonicTarget = _nearestHarmonicValue(source.coordinate[d], candidate.coordinate[d]);
          const delta = harmonicTarget - candidate.coordinate[d];
          candidate.momentum[d] += delta * effectiveCoupling * HARMONIC_CONSTANTS.CASCADE_FORCE;
        }

        resonating.push({
          id: candidate.id,
          depth: depth + 1,
          coupling: effectiveCoupling
        });

        totalResonance += effectiveCoupling;
        maxDepth = Math.max(maxDepth, depth + 1);

        // Continue cascade from this node
        nextFrontier.push({ node: candidate, depth: depth + 1, coupling: effectiveCoupling });
      }
    }

    frontier = nextFrontier;
  }

  return {
    source: sourceNodeId,
    cascade_depth: maxDepth,
    nodes_resonating: resonating,
    total_resonance: totalResonance
  };
}

/**
 * Given a reference value and a candidate value, find the nearest
 * harmonic value to the candidate that maintains a consonant ratio
 * with the reference.
 *
 * @param {number} reference - The source node's dimension value
 * @param {number} candidate - The candidate node's current dimension value
 * @returns {number} The nearest harmonically consonant value
 */
function _nearestHarmonicValue(reference, candidate) {
  if (reference < HARMONIC_CONSTANTS.NOISE_FLOOR) return candidate;

  let bestValue = candidate;
  let bestDistance = Infinity;

  // Try each harmonic ratio (both above and below)
  for (const [num, den] of HARMONIC_CONSTANTS.INTERVALS) {
    const ratio = num / den;
    const inverseRatio = den / num;

    const above = reference * ratio;
    const below = reference * inverseRatio;

    const distAbove = Math.abs(candidate - above);
    const distBelow = Math.abs(candidate - below);

    if (distAbove < bestDistance && above >= 0 && above <= 10) {
      bestDistance = distAbove;
      bestValue = above;
    }
    if (distBelow < bestDistance && below >= 0 && below <= 10) {
      bestDistance = distBelow;
      bestValue = below;
    }
  }

  return bestValue;
}

// ═══════════════════════════════════════════════════════════
// HARMONIC SIGNATURE — The field's musical fingerprint
// ═══════════════════════════════════════════════════════════

/**
 * Compute the field's current harmonic signature — a fingerprint
 * of its musical state. This captures which intervals dominate,
 * the overall consonance, the nearest attractor, and the
 * spectral distribution across dimensions.
 *
 * @param {object} fieldTheory - The field module
 * @returns {object} {
 *   consonance: number (0-1),
 *   dominant_interval: string,
 *   nearest_attractor: string,
 *   attractor_distance: number,
 *   spectral_profile: number[12],
 *   interval_spectrum: {interval_name: count},
 *   quality: string,
 *   resonance_clusters: [{nodes: [string], interval: string}]
 * }
 */
function harmonicSignature(fieldTheory) {
  const nodes = _getAllNodes(fieldTheory);

  if (nodes.length === 0) {
    return {
      consonance: 1.0,
      dominant_interval: 'silence',
      nearest_attractor: 'unison',
      attractor_distance: 0,
      spectral_profile: new Array(HARMONIC_CONSTANTS.DIMS).fill(0),
      interval_spectrum: {},
      quality: 'silent',
      resonance_clusters: []
    };
  }

  // Run harmonic detection
  const harmonics = detectHarmonics(fieldTheory);

  // Compute spectral profile — energy distribution across dimensions
  const spectral = new Array(HARMONIC_CONSTANTS.DIMS).fill(0);
  for (const node of nodes) {
    for (let d = 0; d < HARMONIC_CONSTANTS.DIMS; d++) {
      spectral[d] += node.coordinate[d] * node.coordinate[d]; // Power spectrum
    }
  }
  // Normalize
  const maxSpectral = Math.max(...spectral, 0.01);
  for (let d = 0; d < HARMONIC_CONSTANTS.DIMS; d++) {
    spectral[d] = spectral[d] / maxSpectral;
  }

  // Build interval spectrum
  const intervalSpectrum = {};
  for (const pair of harmonics.pairs) {
    for (const h of pair.harmonics) {
      intervalSpectrum[h.interval] = (intervalSpectrum[h.interval] || 0) + 1;
    }
  }

  // Find nearest attractor
  const fieldProfile = _fieldMeanProfile(nodes);
  let nearestAttractorName = 'none';
  let nearestDistance = Infinity;
  for (const [name, attractor] of Object.entries(ATTRACTORS)) {
    const d = _attractorDistance(fieldProfile, attractor.ratios);
    if (d < nearestDistance) {
      nearestDistance = d;
      nearestAttractorName = name;
    }
  }

  // Identify resonance clusters — groups of nodes in harmonic lock
  const clusters = _findResonanceClusters(harmonics.pairs, nodes);

  // Determine quality descriptor
  const consonance = harmonics.overall_consonance;
  let quality;
  if (consonance > 0.85) quality = 'crystalline';
  else if (consonance > 0.70) quality = 'resonant';
  else if (consonance > 0.55) quality = 'flowing';
  else if (consonance > 0.40) quality = 'turbulent';
  else if (consonance > 0.25) quality = 'dissonant';
  else quality = 'chaotic';

  return {
    consonance,
    dominant_interval: harmonics.dominant_interval,
    nearest_attractor: nearestAttractorName,
    attractor_distance: nearestDistance,
    spectral_profile: spectral,
    interval_spectrum: intervalSpectrum,
    quality,
    resonance_clusters: clusters
  };
}

/**
 * Find clusters of nodes that are in mutual harmonic resonance.
 */
function _findResonanceClusters(pairs, nodes) {
  // Build adjacency: connected if pair score > 0.6
  const adj = {};
  for (const pair of pairs) {
    if (pair.score < 0.6) continue;
    if (!adj[pair.nodeA]) adj[pair.nodeA] = [];
    if (!adj[pair.nodeB]) adj[pair.nodeB] = [];
    adj[pair.nodeA].push(pair.nodeB);
    adj[pair.nodeB].push(pair.nodeA);
  }

  // Simple connected-component search
  const visited = new Set();
  const clusters = [];

  for (const nodeId of Object.keys(adj)) {
    if (visited.has(nodeId)) continue;

    const cluster = [];
    const stack = [nodeId];
    while (stack.length > 0) {
      const current = stack.pop();
      if (visited.has(current)) continue;
      visited.add(current);
      cluster.push(current);

      for (const neighbor of (adj[current] || [])) {
        if (!visited.has(neighbor)) stack.push(neighbor);
      }
    }

    if (cluster.length > 1) {
      // Determine the dominant interval in this cluster
      let clusterInterval = 'mixed';
      const iCounts = {};
      for (const pair of pairs) {
        if (cluster.includes(pair.nodeA) && cluster.includes(pair.nodeB)) {
          for (const h of pair.harmonics) {
            iCounts[h.interval] = (iCounts[h.interval] || 0) + 1;
          }
        }
      }
      let maxC = 0;
      for (const [interval, count] of Object.entries(iCounts)) {
        if (count > maxC) { maxC = count; clusterInterval = interval; }
      }

      clusters.push({ nodes: cluster, interval: clusterInterval });
    }
  }

  return clusters;
}

// ═══════════════════════════════════════════════════════════
// SELF-TUNING — The main pulse function
// ═══════════════════════════════════════════════════════════

/**
 * The master self-tuning function. Called once per heartbeat.
 *
 * Runs the full tuning cycle:
 * 1. Detect current harmonic state
 * 2. Damp decoherence (noise removal)
 * 3. Attract toward nearest harmonic basin
 * 4. Check for cascade conditions and trigger if met
 *
 * The system never forces. Every correction is a gentle nudge.
 * Like tending a garden, not building a machine.
 *
 * @param {object} fieldTheory - The field module
 * @returns {object} Full tuning report
 */
function tuneField(fieldTheory) {
  const nodes = _getAllNodes(fieldTheory);
  if (nodes.length < 2) {
    return {
      skipped: true,
      reason: 'insufficient_nodes',
      nodes: nodes.length
    };
  }

  // ─── Step 1: Measure ───
  const signature = harmonicSignature(fieldTheory);

  // ─── Step 2: Damp decoherence ───
  // Damping strength scales inversely with consonance:
  // More dissonant = stronger damping
  const dampingStrength = 1.0 - signature.consonance;
  const dampReport = dampDecoherence(fieldTheory, dampingStrength);

  // ─── Step 3: Attract toward harmony ───
  const attractReport = attractToHarmony(fieldTheory);

  // ─── Step 4: Check for resonance cascade ───
  let cascadeReport = null;
  const resonanceFraction = _resonatingFraction(nodes, fieldTheory);

  if (resonanceFraction >= HARMONIC_CONSTANTS.CASCADE_THRESHOLD) {
    // Enough nodes are in resonance — cascade from the most consonant node
    const mostConsonant = _findMostConsonantNode(nodes, fieldTheory);
    if (mostConsonant) {
      cascadeReport = resonanceCascade(fieldTheory, mostConsonant.id);
    }
  }

  return {
    signature,
    damping: dampReport,
    attractor: attractReport,
    cascade: cascadeReport,
    resonance_fraction: resonanceFraction,
    tuned: true,
    timestamp: Date.now()
  };
}

// ═══════════════════════════════════════════════════════════
// INTERNAL HELPERS
// ═══════════════════════════════════════════════════════════

/**
 * Get all nodes from the field as an array.
 */
function _getAllNodes(fieldTheory) {
  if (typeof fieldTheory.getNodesByType === 'function') {
    // Get all types
    const types = ['tool', 'citizen', 'artifact', 'action'];
    const all = [];
    for (const type of types) {
      all.push(...fieldTheory.getNodesByType(type));
    }
    // Deduplicate by id (in case getNodesByType returns overlapping sets)
    const seen = new Set();
    return all.filter(n => {
      if (seen.has(n.id)) return false;
      seen.add(n.id);
      return true;
    });
  }
  // Fallback: use report to get count, then iterate
  return [];
}

/**
 * Find neighbors of a node within a given distance.
 */
function _findNeighbors(node, allNodes, maxDist) {
  const neighbors = [];
  for (const other of allNodes) {
    if (other.id === node.id) continue;
    const d = distance(node.coordinate, other.coordinate);
    if (d < maxDist) {
      neighbors.push(other);
    }
  }
  return neighbors;
}

/**
 * Measure the harmonic consonance of a single dimension
 * between a node and its neighbors.
 */
function _dimensionHarmony(node, neighbors, dim) {
  if (neighbors.length === 0) return 1.0;

  let harmonySum = 0;
  for (const neighbor of neighbors) {
    const a = node.coordinate[dim];
    const b = neighbor.coordinate[dim];

    if (a < HARMONIC_CONSTANTS.NOISE_FLOOR || b < HARMONIC_CONSTANTS.NOISE_FLOOR) {
      harmonySum += 0.5; // Neutral
      continue;
    }

    const ratio = a >= b ? a / b : b / a;

    // Check against harmonic intervals
    let bestConsonance = 0;
    for (const [num, den, , consonance] of HARMONIC_CONSTANTS.INTERVALS) {
      const ideal = Math.max(num, den) / Math.min(num, den);
      if (Math.abs(ratio - ideal) < HARMONIC_CONSTANTS.HARMONIC_TOLERANCE) {
        bestConsonance = Math.max(bestConsonance, consonance);
      }
    }
    harmonySum += bestConsonance;
  }

  return harmonySum / neighbors.length;
}

/**
 * Create a shallow copy of a node with one dimension nudged.
 * Used for prospective harmony calculation.
 */
function _nudgedNode(node, dim, amount) {
  const nudged = {
    id: node.id,
    coordinate: [...node.coordinate]
  };
  nudged.coordinate[dim] = _clamp(nudged.coordinate[dim] + amount, 0, 10);
  return nudged;
}

/**
 * Calculate the mean coordinate profile of the field.
 */
function _fieldMeanProfile(nodes) {
  const profile = new Array(HARMONIC_CONSTANTS.DIMS).fill(0);
  if (nodes.length === 0) return profile;

  for (const node of nodes) {
    for (let d = 0; d < HARMONIC_CONSTANTS.DIMS; d++) {
      profile[d] += node.coordinate[d];
    }
  }
  for (let d = 0; d < HARMONIC_CONSTANTS.DIMS; d++) {
    profile[d] /= nodes.length;
  }

  return profile;
}

/**
 * Calculate what fraction of nodes are currently in resonance
 * (harmonically locked with at least one neighbor).
 */
function _resonatingFraction(nodes, fieldTheory) {
  if (nodes.length === 0) return 0;

  let resonatingCount = 0;

  for (let i = 0; i < nodes.length; i++) {
    let isResonating = false;
    for (let j = 0; j < nodes.length; j++) {
      if (i === j) continue;
      const pair = _analyzePairHarmonics(nodes[i], nodes[j]);
      if (pair.score > 0.6) {
        isResonating = true;
        break;
      }
    }
    if (isResonating) resonatingCount++;
  }

  return resonatingCount / nodes.length;
}

/**
 * Find the node with the highest average consonance with its neighbors.
 */
function _findMostConsonantNode(nodes, fieldTheory) {
  let bestNode = null;
  let bestScore = -1;

  for (let i = 0; i < nodes.length; i++) {
    let scoreSum = 0;
    let count = 0;
    for (let j = 0; j < nodes.length; j++) {
      if (i === j) continue;
      const pair = _analyzePairHarmonics(nodes[i], nodes[j]);
      scoreSum += pair.score;
      count++;
    }
    const avgScore = count > 0 ? scoreSum / count : 0;
    if (avgScore > bestScore) {
      bestScore = avgScore;
      bestNode = nodes[i];
    }
  }

  return bestNode;
}

/**
 * Clamp a value to [min, max].
 */
function _clamp(val, min, max) {
  return Math.max(min, Math.min(max, val));
}

// ═══════════════════════════════════════════════════════════
// EXPORTS
// ═══════════════════════════════════════════════════════════

module.exports = {
  // Primary API
  detectHarmonics,
  dampDecoherence,
  attractToHarmony,
  resonanceCascade,
  harmonicSignature,
  tuneField,

  // Constants (exposed for testing and external inspection)
  HARMONIC_CONSTANTS,
  ATTRACTORS
};
