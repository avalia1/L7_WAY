/**
 * Prima — The Language of the Forge
 * Law XLV — 22 operations. 5 human verbs. Sigils as weighted hypergraphs.
 *
 * A sigil is not a symbol. It is a compressed weighted hypergraph.
 * The nodes are operations. The edges carry 12-dimensional weights.
 * The complexity lives in the edges, not the nodes.
 */

const { createCoordinate, createEdge, dominantDimensions, zodiacalQuality } = require('./dodecahedron');

// ─── The 22 Operations ───
// Mapped to Hebrew letters, Tarot Major Arcana, and Rose Cross positions.

const OPERATIONS = Object.freeze([
  { index: 0,  letter: 'א', name: 'Aleph',  arcanum: 'The Fool',          op: 'invoke',      ring: 'mother',  description: 'Begin from nothing' },
  { index: 1,  letter: 'ב', name: 'Beth',   arcanum: 'The Magician',      op: 'transmute',   ring: 'double',  description: 'Pass through forge' },
  { index: 2,  letter: 'ג', name: 'Gimel',  arcanum: 'High Priestess',    op: 'seal',        ring: 'double',  description: 'Encrypt, make invisible' },
  { index: 3,  letter: 'ד', name: 'Daleth', arcanum: 'The Empress',       op: 'dream',       ring: 'double',  description: 'Enter .morph' },
  { index: 4,  letter: 'ה', name: 'He',     arcanum: 'The Emperor',       op: 'publish',     ring: 'simple',  description: 'Stabilize in .work' },
  { index: 5,  letter: 'ו', name: 'Vav',    arcanum: 'Hierophant',        op: 'bind',        ring: 'simple',  description: 'Apply law' },
  { index: 6,  letter: 'ז', name: 'Zayin',  arcanum: 'The Lovers',        op: 'verify',      ring: 'simple',  description: 'Authenticate' },
  { index: 7,  letter: 'ח', name: 'Cheth',  arcanum: 'The Chariot',       op: 'orchestrate', ring: 'simple',  description: 'Coordinate flows' },
  { index: 8,  letter: 'ט', name: 'Teth',   arcanum: 'Strength',          op: 'redeem',      ring: 'simple',  description: 'Transmute threat' },
  { index: 9,  letter: 'י', name: 'Yod',    arcanum: 'The Hermit',        op: 'reflect',     ring: 'simple',  description: 'Self-examine' },
  { index: 10, letter: 'כ', name: 'Kaph',   arcanum: 'Wheel of Fortune',  op: 'rotate',      ring: 'double',  description: 'Cycle, evolve' },
  { index: 11, letter: 'ל', name: 'Lamed',  arcanum: 'Justice',           op: 'audit',       ring: 'simple',  description: 'Log and trace' },
  { index: 12, letter: 'מ', name: 'Mem',    arcanum: 'The Hanged Man',    op: 'decompose',   ring: 'mother',  description: 'Break into atoms' },
  { index: 13, letter: 'נ', name: 'Nun',    arcanum: 'Death',             op: 'transition',  ring: 'simple',  description: 'Change domain' },
  { index: 14, letter: 'ס', name: 'Samekh', arcanum: 'Temperance',        op: 'translate',   ring: 'simple',  description: 'Mediate between systems' },
  { index: 15, letter: 'ע', name: 'Ayin',   arcanum: 'The Devil',         op: 'quarantine',  ring: 'simple',  description: 'Isolate threat' },
  { index: 16, letter: 'פ', name: 'Pe',     arcanum: 'The Tower',         op: 'recover',     ring: 'double',  description: 'Catastrophe response' },
  { index: 17, letter: 'צ', name: 'Tzaddi', arcanum: 'The Star',          op: 'aspire',      ring: 'simple',  description: 'Set highest vision' },
  { index: 18, letter: 'ק', name: 'Qoph',   arcanum: 'The Moon',          op: 'speculate',   ring: 'simple',  description: 'Explore shadows' },
  { index: 19, letter: 'ר', name: 'Resh',   arcanum: 'The Sun',           op: 'illuminate',  ring: 'double',  description: 'Clarify' },
  { index: 20, letter: 'ש', name: 'Shin',   arcanum: 'Judgement',         op: 'succeed',     ring: 'mother',  description: 'Transfer authority' },
  { index: 21, letter: 'ת', name: 'Tav',    arcanum: 'The World',         op: 'complete',    ring: 'double',  description: 'Deliver' }
]);

// Rose Cross ring positions (for sigil tracing)
const ROSE_CROSS = Object.freeze({
  mother: OPERATIONS.filter(o => o.ring === 'mother'),  // 3: א מ ש
  double: OPERATIONS.filter(o => o.ring === 'double'),  // 7: ב ג ד כ פ ר ת
  simple: OPERATIONS.filter(o => o.ring === 'simple')   // 12: ה ו ז ח ט י ל נ ס ע צ ק
});

/**
 * Look up an operation by its name, letter, or op code.
 */
function findOp(query) {
  const q = query.toLowerCase();
  return OPERATIONS.find(o =>
    o.letter === query ||
    o.name.toLowerCase() === q ||
    o.op === q
  );
}

/**
 * A Sigil — a compiled Prima program.
 *
 * A sigil is a sequence of operations with weighted edges between them.
 * The edges carry 12-dimensional weights that encode HOW the operations relate.
 *
 * @param {string} name - Name of the sigil
 * @param {Array<{op: string, weights: object}>} steps - Sequence of operations with edge weights
 * @returns {object} The compiled sigil
 */
function compileSigil(name, steps) {
  if (steps.length < 2) {
    throw new Error('A sigil requires at least two operations');
  }

  const operations = steps.map(s => {
    const op = findOp(s.op);
    if (!op) throw new Error(`Unknown operation: ${s.op}`);
    return op;
  });

  // Build edges between consecutive operations
  const edges = [];
  for (let i = 0; i < operations.length - 1; i++) {
    const from = operations[i];
    const to = operations[i + 1];
    const weights = steps[i + 1].weights || {};

    edges.push(createEdge(from.op, to.op, weights));
  }

  // Calculate aggregate properties
  const allWeights = edges.map(e => e.weights);
  const avgCoord = averageCoordinates(allWeights);
  const dominant = dominantDimensions(avgCoord);
  const quality = zodiacalQuality(avgCoord);

  // Determine alchemical arc
  const arc = determineArc(edges);

  return {
    name,
    type: 'sigil',
    sequence: operations.map(o => o.letter).join(''),
    operations: operations.map(o => o.op),
    edges,
    coordinate: avgCoord,
    dominant: dominant.map(d => `${d.dimension.planet}=${d.value}`),
    quality: quality.sign,
    arc,
    compiled: new Date().toISOString(),

    // Human-readable expansion (Layer 3)
    readable: operations.map(o => `${o.op} (${o.description})`).join(' → ')
  };
}

/**
 * Create a sigil from a simple operation sequence (no explicit weights).
 * Weights are inferred from the operation types and their positions.
 */
function quickSigil(name, ops) {
  const steps = ops.map((op, i) => ({
    op,
    weights: inferWeights(op, ops[i + 1] || null, i, ops.length)
  }));
  return compileSigil(name, steps);
}

/**
 * Infer edge weights from operation types and context.
 * This is the default behavior — explicit weights override these.
 */
function inferWeights(fromOp, toOp, position, totalOps) {
  if (!toOp) return {};

  const weights = {};
  const from = findOp(fromOp);
  const to = findOp(toOp);
  if (!from || !to) return {};

  // Position in program affects some weights
  const progress = position / totalOps;

  // Security operations increase Mars weight
  if (['verify', 'seal', 'quarantine'].includes(to.op)) {
    weights.security = 8;
  }

  // Transformation operations increase Pluto weight
  if (['transmute', 'decompose', 'redeem', 'transition'].includes(to.op)) {
    weights.transformation = 7 + Math.floor(progress * 3);
  }

  // Creative operations increase Neptune weight
  if (['dream', 'speculate', 'aspire'].includes(to.op)) {
    weights.consciousness = 8;
  }

  // Output operations increase Saturn weight
  if (['publish', 'complete', 'illuminate'].includes(to.op)) {
    weights.output = 7;
    weights.presentation = 6;
  }

  // Orchestration increases capability
  if (['orchestrate', 'bind'].includes(to.op)) {
    weights.capability = 8;
  }

  // Audit always high detail
  if (to.op === 'audit') {
    weights.detail = 9;
    weights.memory = 8;
  }

  // Invoke always high intention and direction
  if (from.op === 'invoke') {
    weights.intention = 9;
    weights.direction = 8;
  }

  // Ring crossing adds transformation weight
  if (from.ring !== to.ring) {
    weights.transformation = (weights.transformation || 5) + 2;
  }

  return weights;
}

/**
 * Determine the alchemical arc of a sigil.
 * How does transformation evolve across the edges?
 */
function determineArc(edges) {
  if (edges.length === 0) return 'none';

  const transformWeights = edges.map(e => e.weights[9]); // Pluto = index 9
  const first = transformWeights[0] || 0;
  const last = transformWeights[transformWeights.length - 1] || 0;
  const max = Math.max(...transformWeights);

  if (max <= 3) return 'stable'; // Low transformation throughout
  if (first < 5 && last >= 7) return 'nigredo_to_rubedo'; // Full Great Work
  if (first >= 5 && last >= 7) return 'citrinitas_to_rubedo'; // Late-stage completion
  if (first >= 7 && last < 5) return 'rubedo_to_nigredo'; // Deconstruction (testing)
  return 'mixed';
}

/**
 * Average multiple 12D coordinate vectors.
 */
function averageCoordinates(coords) {
  const avg = new Array(12).fill(0);
  if (coords.length === 0) return avg;
  for (const c of coords) {
    for (let i = 0; i < 12; i++) avg[i] += c[i];
  }
  for (let i = 0; i < 12; i++) avg[i] = Math.round(avg[i] / coords.length);
  return avg;
}

// ─── Pre-compiled Core Sigils ───

const CORE_SIGILS = {
  // The Redemption Sigil — transmuting threats into citizens
  redemption: () => compileSigil('redemption', [
    { op: 'invoke',     weights: { capability: 8, security: 7, transformation: 4, direction: 8 } },
    { op: 'decompose',  weights: { security: 9, detail: 9, transformation: 9, consciousness: 8 } },
    { op: 'verify',     weights: { security: 10, intention: 6, consciousness: 7, transformation: 5 } },
    { op: 'redeem',     weights: { capability: 9, transformation: 8, direction: 7, memory: 5 } },
    { op: 'quarantine', weights: { security: 5, presentation: 7, output: 6 } },
    { op: 'publish',    weights: { detail: 8, output: 8, memory: 9 } },
    { op: 'audit',      weights: { capability: 5, direction: 9, consciousness: 9 } },
    { op: 'complete',   weights: {} }
  ]),

  // The Creation Sigil — bringing something from dream to reality
  creation: () => quickSigil('creation', ['invoke', 'dream', 'transmute', 'publish', 'complete']),

  // The Dreaming Machine Sigil — active idle behavior
  dreaming: () => quickSigil('dreaming', ['dream', 'reflect', 'speculate', 'illuminate', 'transmute', 'publish']),

  // The Self-Initialization Sigil — boot sequence
  boot: () => quickSigil('boot', ['invoke', 'reflect', 'decompose', 'translate', 'dream', 'illuminate', 'bind', 'complete']),

  // The Security Sigil — authentication and protection
  sentinel: () => compileSigil('sentinel', [
    { op: 'invoke',     weights: { security: 9, intention: 8, direction: 9 } },
    { op: 'verify',     weights: { security: 10, detail: 9, consciousness: 8 } },
    { op: 'seal',       weights: { security: 10, transformation: 7, persistence: 9 } },
    { op: 'audit',      weights: { detail: 10, memory: 10, output: 8 } },
    { op: 'complete',   weights: {} }
  ])
};

module.exports = {
  OPERATIONS,
  ROSE_CROSS,
  findOp,
  compileSigil,
  quickSigil,
  inferWeights,
  CORE_SIGILS
};
