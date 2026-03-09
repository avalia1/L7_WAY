/**
 * L7 Context Menu — Probability-Driven Contextual Operations
 *
 * Surfaces context-relevant operations throughout the OS based on
 * the probability functions of neighboring nodes in the dodecahedron.
 *
 * The idea: at any point in the 12D coordinate space, some operations
 * are more relevant than others. A node deep in security dimensions
 * should surface seal/verify/quarantine. A node in creative space
 * should surface dream/transmute/invoke. The menu is ALIVE —
 * it changes with the coordinate landscape.
 *
 * The probability of each operation appearing in the context menu
 * is computed from:
 *   1. The current node's 12D coordinate
 *   2. The Astrocyte (13th meta-variable) — uncertainty level
 *   3. The coordinates of neighboring nodes (influence field)
 *   4. The current morph layer (Above/Mirror/Below)
 *   5. The current forge phase (Nigredo/Albedo/Citrinitas/Rubedo)
 *
 * Higher probability = more prominent in the menu.
 * Operations below a threshold are hidden — decluttering.
 */

'use strict';

const { DIMENSIONS, similarity, createProbabilistic } = require('./dodecahedron');
const { OPERATIONS, findOp } = require('./prima');
const { PHASE_MAP, partition, phase: merkabahPhase } = require('./merkabah');

// ═══════════════════════════════════════════════════════════
// OPERATION AFFINITY — How well each op matches a coordinate
// ═══════════════════════════════════════════════════════════

/**
 * Dimension-to-operation affinity map.
 * Each dimension has natural operations that resonate with it.
 * These are the operations that "want" to be invoked when
 * that dimension is dominant.
 */
const DIMENSION_AFFINITY = Object.freeze({
  // Sun (0) — capability, creation
  0: ['invoke', 'orchestrate', 'illuminate', 'succeed'],
  // Moon (1) — data, reflection
  1: ['reflect', 'dream', 'speculate', 'audit'],
  // Mercury (2) — presentation, translation
  2: ['translate', 'publish', 'transition', 'complete'],
  // Venus (3) — persistence, binding
  3: ['bind', 'seal', 'recover', 'complete'],
  // Mars (4) — security, verification
  4: ['verify', 'seal', 'quarantine', 'redeem'],
  // Jupiter (5) — detail, decomposition
  5: ['decompose', 'audit', 'orchestrate', 'aspire'],
  // Saturn (6) — output, completion
  6: ['publish', 'complete', 'illuminate', 'succeed'],
  // Uranus (7) — intention, aspiration
  7: ['aspire', 'invoke', 'dream', 'transmute'],
  // Neptune (8) — consciousness, transformation
  8: ['transmute', 'dream', 'reflect', 'speculate'],
  // Pluto (9) — transformation, transition
  9: ['transmute', 'transition', 'redeem', 'rotate'],
  // North Node (10) — direction, succession
  10: ['succeed', 'aspire', 'transition', 'invoke'],
  // South Node (11) — memory, reflection
  11: ['reflect', 'audit', 'recover', 'rotate']
});

/**
 * Domain-specific operations — what each domain naturally surfaces.
 */
const DOMAIN_OPS = Object.freeze({
  morph: ['dream', 'transmute', 'invoke', 'speculate', 'reflect'],
  work:  ['orchestrate', 'translate', 'publish', 'bind', 'complete'],
  salt:  ['seal', 'audit', 'verify', 'complete', 'illuminate'],
  vault: ['verify', 'seal', 'quarantine', 'redeem', 'recover']
});

/**
 * Phase-specific operations — what each forge stage surfaces.
 */
const PHASE_OPS = Object.freeze({
  nigredo:    ['decompose', 'reflect', 'rotate', 'dream'],
  albedo:     ['verify', 'audit', 'translate', 'bind'],
  citrinitas: ['illuminate', 'aspire', 'invoke', 'speculate'],
  rubedo:     ['complete', 'seal', 'publish', 'succeed']
});

// ═══════════════════════════════════════════════════════════
// PROBABILITY COMPUTATION
// ═══════════════════════════════════════════════════════════

/**
 * Compute the probability of each Prima operation appearing
 * in the context menu for a given 12D coordinate.
 *
 * The probability is a weighted combination of:
 *   - Dimensional affinity (which dimensions are dominant)
 *   - Neighbor influence (what nearby nodes suggest)
 *   - Phase alignment (current forge stage)
 *   - Astrocyte modulation (uncertainty/creativity factor)
 *
 * @param {number[]} coord - Current 12D coordinate
 * @param {object} [options] - Configuration
 * @param {number[][]} [options.neighbors] - Neighbor coordinates
 * @param {number} [options.astrocyte] - Uncertainty level (0-1, default 0.3)
 * @param {string} [options.domain] - Current domain (morph/work/salt/vault)
 * @returns {object[]} Sorted array of { op, probability, sources }
 */
function computeProbabilities(coord, options = {}) {
  const astrocyte = Math.max(0, Math.min(1, options.astrocyte || 0.3));
  const neighbors = options.neighbors || [];
  const domain = options.domain || null;

  // Score accumulator for each operation
  const scores = {};
  for (const op of OPERATIONS) {
    scores[op.op] = { base: 0, neighbor: 0, phase: 0, domain: 0, sources: [] };
  }

  // 1. Dimensional affinity — dominant dimensions boost their natural operations
  const ranked = coord.map((v, i) => ({ index: i, value: v }))
    .sort((a, b) => b.value - a.value);

  for (let rank = 0; rank < ranked.length; rank++) {
    const dim = ranked[rank];
    const affinityOps = DIMENSION_AFFINITY[dim.index] || [];
    // Weight by both dimension value and rank position
    const weight = (dim.value / 10) * (1 - rank / 24); // top dims get more weight

    for (const opName of affinityOps) {
      if (scores[opName]) {
        scores[opName].base += weight;
        scores[opName].sources.push(`dim:${DIMENSIONS[dim.index].name}(${dim.value.toFixed(1)})`);
      }
    }
  }

  // 2. Neighbor influence — nearby coordinates pull toward their operations
  if (neighbors.length > 0) {
    for (const neighborCoord of neighbors) {
      const sim = similarity(coord, neighborCoord);
      if (sim < 0.3) continue; // Too distant — no influence

      // The neighbor's dominant dimensions influence our menu
      const nRanked = neighborCoord.map((v, i) => ({ index: i, value: v }))
        .sort((a, b) => b.value - a.value)
        .slice(0, 4); // Top 4 dims of neighbor

      for (const dim of nRanked) {
        const affinityOps = DIMENSION_AFFINITY[dim.index] || [];
        const weight = sim * (dim.value / 10) * 0.5; // Scaled by similarity

        for (const opName of affinityOps) {
          if (scores[opName]) {
            scores[opName].neighbor += weight;
          }
        }
      }
    }
  }

  // 3. Phase alignment — current forge phase boosts related operations
  const currentPhase = merkabahPhase(coord);
  const phaseOps = PHASE_OPS[currentPhase.phase] || [];
  for (const opName of phaseOps) {
    if (scores[opName]) {
      scores[opName].phase += 0.4 * currentPhase.progress;
      scores[opName].sources.push(`phase:${currentPhase.phase}`);
    }
  }

  // 4. Domain boost — if we know the domain, boost its natural operations
  if (domain && DOMAIN_OPS[domain]) {
    for (const opName of DOMAIN_OPS[domain]) {
      if (scores[opName]) {
        scores[opName].domain += 0.5;
        scores[opName].sources.push(`domain:${domain}`);
      }
    }
  }

  // 5. Combine scores and apply Astrocyte modulation
  const results = [];

  for (const op of OPERATIONS) {
    const s = scores[op.op];
    const rawScore = s.base + s.neighbor + s.phase + s.domain;

    // Astrocyte modulates: high astrocyte → more randomness → flatter distribution
    // Low astrocyte → deterministic → sharp peaks
    const noise = astrocyte * (Math.random() - 0.5) * 0.3;
    const modulatedScore = rawScore * (1 - astrocyte * 0.3) + noise;

    // Normalize to probability (0-1)
    const probability = Math.max(0, Math.min(1, modulatedScore / 3));

    results.push({
      op: op.op,
      letter: op.letter,
      ring: op.ring,
      tarot: op.tarot,
      probability,
      score: rawScore,
      sources: s.sources
    });
  }

  // Sort by probability descending
  results.sort((a, b) => b.probability - a.probability);

  return results;
}

// ═══════════════════════════════════════════════════════════
// CONTEXT MENU GENERATION
// ═══════════════════════════════════════════════════════════

/**
 * Generate a context menu — the top N most relevant operations.
 *
 * @param {number[]} coord - Current 12D coordinate
 * @param {object} [options] - Configuration
 * @param {number} [options.maxItems] - Maximum menu items (default 7)
 * @param {number} [options.threshold] - Minimum probability to show (default 0.1)
 * @param {number[][]} [options.neighbors] - Neighbor coordinates
 * @param {number} [options.astrocyte] - Uncertainty level
 * @param {string} [options.domain] - Current domain
 * @returns {object} { items, coordinate, phase, domain, astrocyte }
 */
function contextMenu(coord, options = {}) {
  const maxItems = options.maxItems || 7;
  const threshold = options.threshold || 0.1;

  const probabilities = computeProbabilities(coord, options);
  const currentPhase = merkabahPhase(coord);
  const merk = partition(coord);

  // Filter by threshold and take top N
  const items = probabilities
    .filter(p => p.probability >= threshold)
    .slice(0, maxItems)
    .map((p, i) => ({
      rank: i + 1,
      op: p.op,
      letter: p.letter,
      tarot: p.tarot,
      probability: Math.round(p.probability * 100) / 100,
      sources: p.sources.slice(0, 3) // Top 3 reasons
    }));

  return {
    items,
    total_candidates: probabilities.filter(p => p.probability >= threshold).length,
    coordinate: coord,
    phase: currentPhase.phase,
    layer: merk.above.layer.name,
    domain: options.domain || 'auto',
    astrocyte: options.astrocyte || 0.3
  };
}

/**
 * Suggest the single best operation for the current context.
 * The "what should I do next?" answer.
 *
 * @param {number[]} coord - Current 12D coordinate
 * @param {object} [options] - Same as contextMenu options
 * @returns {object} { op, letter, tarot, probability, why }
 */
function suggest(coord, options = {}) {
  const probs = computeProbabilities(coord, options);
  const best = probs[0];

  if (!best || best.probability < 0.05) {
    return { op: null, suggestion: 'The landscape is flat — no strong operation calls.' };
  }

  return {
    op: best.op,
    letter: best.letter,
    tarot: best.tarot,
    probability: Math.round(best.probability * 100) / 100,
    why: best.sources.slice(0, 3),
    alternatives: probs.slice(1, 4).map(p => ({
      op: p.op,
      probability: Math.round(p.probability * 100) / 100
    }))
  };
}

// ═══════════════════════════════════════════════════════════
// EXPORTS
// ═══════════════════════════════════════════════════════════

module.exports = {
  contextMenu,            // Generate context menu for a coordinate
  suggest,                // Suggest best single operation
  computeProbabilities,   // Raw probability computation

  // Constants (for inspection)
  DIMENSION_AFFINITY,
  DOMAIN_OPS,
  PHASE_OPS
};
