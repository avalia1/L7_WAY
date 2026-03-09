

/**
 * L7 Merkabah — The Vehicle of Traversal
 *
 * The Dodecahedron (12 faces, 12 dimensions) is the TERRITORY — what there IS.
 * The Merkabah is the VEHICLE — what MOVES through the territory.
 *
 * Merkabah = two interlocking tetrahedra (Star of David in 3D).
 *   Upper tetrahedron (△) — fire, spirit ascending, the Above
 *   Lower tetrahedron (▽) — water, spirit descending, the Below
 *   Intersection (◇) — the Mirror, where above meets below
 *
 * "As above, so below" — the two tetrahedra mirror each other.
 *
 * The Merkabah rotates through the dodecahedron space, visiting
 * faces/dimensions. Its rotation phase maps to the four stages
 * of the Great Work: Nigredo → Albedo → Citrinitas → Rubedo.
 *
 * The morph domain has 3 layers: Above (△), Mirror (◇), Below (▽).
 * These map directly to the Merkabah geometry:
 *   Above = upper tetrahedron vertices (highest-valued dimensions)
 *   Below = lower tetrahedron vertices (lowest-valued dimensions)
 *   Mirror = the intersection zone (middle-valued dimensions)
 *
 * See simulations/graphene-merkaba.html for the visual geometry.
 */

const {
  DIMENSIONS,
  createCoordinate,
  distance,
  similarity,
  dominantDimensions,
  createProbabilistic
} = require('./dodecahedron');

// ═══════════════════════════════════════════════════════════
// THE TWO TETRAHEDRA
// ═══════════════════════════════════════════════════════════

/**
 * A tetrahedron in 12D space is defined by 4 vertices.
 * In the Merkabah, the upper tetrahedron's vertices are the 4 dimensions
 * with the highest values in a coordinate (spirit ascending).
 * The lower tetrahedron's vertices are the 4 dimensions with the
 * lowest values (spirit grounding into matter).
 * The remaining 4 dimensions form the Mirror — the intersection.
 *
 * This partition is dynamic: it depends on the coordinate you inhabit.
 * Move through the dodecahedron and the Merkabah reconfigures itself.
 */

/**
 * The three morph layers — mapped from CLAUDE.md's dreamspace recursion.
 */
const LAYERS = Object.freeze({
  ABOVE:  { name: 'above',  symbol: '△', color: 'gold',   correspondence: 'Sun',  element: 'fire',  meaning: 'The sky. The idea. The seed.' },
  MIRROR: { name: 'mirror', symbol: '◇', color: 'silver', correspondence: 'Moon',  element: 'aether', meaning: 'The horizon. The fold. The pivot.' },
  BELOW:  { name: 'below',  symbol: '▽', color: 'copper', correspondence: 'Earth', element: 'water', meaning: 'The root. The reflection. The echo.' }
});

/**
 * The four forge stages mapped to rotation quadrants.
 * A full rotation of the Merkabah = one complete transmutation cycle.
 *   0°-90°   Nigredo    (decomposition — breaking apart)
 *   90°-180°  Albedo     (purification — removing dross)
 *   180°-270° Citrinitas (illumination — finding coordinates)
 *   270°-360° Rubedo     (crystallization — manifesting)
 */
const PHASE_MAP = Object.freeze([
  { phase: 'nigredo',    symbol: '🜁', range: [0, 90],    element: 'fire',  domain: '.morph', description: 'Decompose — the old form burns away' },
  { phase: 'albedo',     symbol: '🜄', range: [90, 180],  element: 'water', domain: '.vault', description: 'Purify — wash away contradictions' },
  { phase: 'citrinitas', symbol: '🜃', range: [180, 270], element: 'air',   domain: '.work',  description: 'Illuminate — coordinates revealed' },
  { phase: 'rubedo',     symbol: '🜂', range: [270, 360], element: 'earth', domain: '.salt',  description: 'Crystallize — spirit becomes stone' }
]);

// ═══════════════════════════════════════════════════════════
// MERKABAH CONSTRUCTION
// ═══════════════════════════════════════════════════════════

/**
 * Partition a 12D coordinate into the three layers of the Merkabah.
 *
 * Sorts all 12 dimensions by their value in the coordinate, then:
 *   - Top 4 dimensions → upper tetrahedron (Above)
 *   - Middle 4 dimensions → Mirror (intersection)
 *   - Bottom 4 dimensions → lower tetrahedron (Below)
 *
 * Returns the three tetrahedra with their dimension indices and values.
 *
 * @param {number[]} coord - 12D coordinate vector
 * @returns {object} { above, mirror, below, center }
 */
function partition(coord) {
  const c = Array.isArray(coord) ? coord : createCoordinate(coord);

  // Rank all 12 dimensions by value (descending)
  const ranked = DIMENSIONS.map((dim, i) => ({
    index: i,
    dimension: dim,
    value: c[i]
  })).sort((a, b) => b.value - a.value);

  const above = ranked.slice(0, 4);
  const mirror = ranked.slice(4, 8);
  const below = ranked.slice(8, 12);

  // The center of the Merkabah: the mean of all 12 values
  const center = c.reduce((sum, v) => sum + v, 0) / 12;

  return {
    above: {
      layer: LAYERS.ABOVE,
      vertices: above,
      energy: above.reduce((s, v) => s + v.value, 0),
      mean: above.reduce((s, v) => s + v.value, 0) / 4
    },
    mirror: {
      layer: LAYERS.MIRROR,
      vertices: mirror,
      energy: mirror.reduce((s, v) => s + v.value, 0),
      mean: mirror.reduce((s, v) => s + v.value, 0) / 4
    },
    below: {
      layer: LAYERS.BELOW,
      vertices: below,
      energy: below.reduce((s, v) => s + v.value, 0),
      mean: below.reduce((s, v) => s + v.value, 0) / 4
    },
    center,
    coordinate: c
  };
}

/**
 * Compute the polarity of a Merkabah partition.
 *
 * Polarity = ratio of ascending energy to descending energy.
 *   polarity > 1: spirit dominates matter (more imaginary than real)
 *   polarity = 1: perfect balance (hermetic equilibrium)
 *   polarity < 1: matter dominates spirit (more manifest than potential)
 *
 * @param {object} merkabah - Result from partition()
 * @returns {number} polarity ratio
 */
function polarity(merkabah) {
  const aboveEnergy = merkabah.above.energy || 0.001;
  const belowEnergy = merkabah.below.energy || 0.001;
  return aboveEnergy / belowEnergy;
}

// ═══════════════════════════════════════════════════════════
// TRAVERSAL — Moving through the Dodecahedron
// ═══════════════════════════════════════════════════════════

/**
 * Traverse from one 12D coordinate to another.
 *
 * The Merkabah does not teleport — it traces a path through the
 * dodecahedron. The path is computed as a series of intermediate
 * coordinates, each one step closer to the destination.
 *
 * At each step, the Merkabah reconfigures: its tetrahedra shift
 * as different dimensions gain or lose intensity. The path records
 * which forge phase each step falls in (based on rotation angle).
 *
 * @param {number[]} from12D - Starting 12D coordinate
 * @param {number[]} to12D   - Destination 12D coordinate
 * @param {number} steps     - Number of intermediate steps (default 12, one per face)
 * @returns {object} { path, totalDistance, phases, departure, arrival }
 */
function traverse(from12D, to12D, steps = 12) {
  const from = Array.isArray(from12D) ? from12D : createCoordinate(from12D);
  const to = Array.isArray(to12D) ? to12D : createCoordinate(to12D);

  const totalDist = distance(from, to);
  const path = [];

  for (let i = 0; i <= steps; i++) {
    const t = i / steps;

    // Linear interpolation through 12D space
    const point = new Array(12);
    for (let d = 0; d < 12; d++) {
      point[d] = from[d] + (to[d] - from[d]) * t;
    }

    // The rotation angle advances proportionally to progress
    // A full traversal = one full rotation = one transmutation cycle
    const angle = t * 360;

    const step = {
      index: i,
      t,
      coordinate: point,
      merkabah: partition(point),
      angle,
      phase: phaseFromAngle(angle),
      distanceFromOrigin: distance(from, point),
      distanceToDestination: distance(point, to),
      similarity: similarity(point, to)
    };

    path.push(step);
  }

  return {
    path,
    totalDistance: totalDist,
    steps,
    phases: path.map(s => s.phase.phase),
    departure: partition(from),
    arrival: partition(to),
    // The dominant shift: which dimensions changed the most
    dominantShift: computeDominantShift(from, to)
  };
}

/**
 * Compute which dimensions shifted most during traversal.
 * Returns sorted array of { dimension, delta, direction }.
 */
function computeDominantShift(from, to) {
  return DIMENSIONS.map((dim, i) => ({
    dimension: dim,
    delta: Math.abs(to[i] - from[i]),
    direction: to[i] > from[i] ? 'ascending' : (to[i] < from[i] ? 'descending' : 'stable'),
    from: from[i],
    to: to[i]
  })).sort((a, b) => b.delta - a.delta);
}

// ═══════════════════════════════════════════════════════════
// ROTATION — Changing Perspective
// ═══════════════════════════════════════════════════════════

/**
 * Rotate the Merkabah around a 12D coordinate.
 *
 * Rotation does not change the data — it changes your PERSPECTIVE on it.
 * Different rotation angles illuminate different relationships between
 * dimensions. This is analogous to the Berry phase in quantum mechanics:
 * after a full rotation, you return to the same state but with a phase shift.
 *
 * The rotation is implemented as a cyclic permutation of dimension weights.
 * At angle=0, dimensions are in their natural order.
 * At angle=30 (360/12), each dimension takes the value of the next.
 * After 12 rotations of 30 degrees, you return to the original — but
 * having visited every possible perspective.
 *
 * @param {number[]} coord - 12D coordinate
 * @param {number} angle   - Rotation angle in degrees (0-360)
 * @returns {object} { coordinate, merkabah, angle, phase, perspective }
 */
function rotate(coord, angle) {
  const c = Array.isArray(coord) ? coord : createCoordinate(coord);
  const normalizedAngle = ((angle % 360) + 360) % 360;

  // Cyclic shift: how many dimensions to shift by
  const shift = Math.floor(normalizedAngle / 30) % 12;
  // Fractional interpolation between discrete shifts
  const fraction = (normalizedAngle % 30) / 30;

  const rotated = new Array(12);
  for (let i = 0; i < 12; i++) {
    const sourceA = (i + shift) % 12;
    const sourceB = (i + shift + 1) % 12;
    // Smooth interpolation between two cyclic positions
    rotated[i] = c[sourceA] * (1 - fraction) + c[sourceB] * fraction;
    // Clamp to valid range
    rotated[i] = Math.max(0, Math.min(10, rotated[i]));
  }

  return {
    coordinate: rotated,
    original: c,
    merkabah: partition(rotated),
    angle: normalizedAngle,
    shift,
    phase: phaseFromAngle(normalizedAngle),
    perspective: DIMENSIONS[shift]
  };
}

// ═══════════════════════════════════════════════════════════
// ASCEND / DESCEND — Vertical Movement
// ═══════════════════════════════════════════════════════════

/**
 * Ascend: move the coordinate toward the upper tetrahedron.
 *
 * Increases the values of dimensions currently in the Above layer
 * while decreasing those in the Below layer. The Mirror stays anchored.
 * This makes the coordinate more "spiritual" — more imaginary, potential,
 * transpersonal.
 *
 * The intensity parameter controls how strongly to ascend (0-1).
 * At intensity=1, Above dimensions max at 10 and Below dimensions drop to 0.
 *
 * @param {number[]} coord     - 12D coordinate
 * @param {number} intensity   - How strongly to ascend (0-1, default 0.3)
 * @returns {object} { coordinate, merkabah, delta, polarity }
 */
function ascend(coord, intensity = 0.3) {
  const c = Array.isArray(coord) ? [...coord] : [...createCoordinate(coord)];
  const merk = partition(c);
  const t = Math.max(0, Math.min(1, intensity));

  const ascended = [...c];

  // Raise the Above
  for (const v of merk.above.vertices) {
    const boost = (10 - c[v.index]) * t;
    ascended[v.index] = Math.min(10, c[v.index] + boost);
  }

  // Lower the Below
  for (const v of merk.below.vertices) {
    const drop = c[v.index] * t;
    ascended[v.index] = Math.max(0, c[v.index] - drop);
  }

  // Mirror stays anchored (no change)

  const newMerk = partition(ascended);

  return {
    coordinate: ascended,
    original: c,
    merkabah: newMerk,
    delta: distance(c, ascended),
    polarity: polarity(newMerk),
    direction: 'ascending',
    layer: LAYERS.ABOVE
  };
}

/**
 * Descend: move the coordinate toward the lower tetrahedron.
 *
 * Increases the values of dimensions currently in the Below layer
 * while decreasing those in the Above layer. The Mirror stays anchored.
 * This makes the coordinate more "material" — more real, manifested,
 * classical.
 *
 * The intensity parameter controls how strongly to descend (0-1).
 *
 * @param {number[]} coord     - 12D coordinate
 * @param {number} intensity   - How strongly to descend (0-1, default 0.3)
 * @returns {object} { coordinate, merkabah, delta, polarity }
 */
function descend(coord, intensity = 0.3) {
  const c = Array.isArray(coord) ? [...coord] : [...createCoordinate(coord)];
  const merk = partition(c);
  const t = Math.max(0, Math.min(1, intensity));

  const descended = [...c];

  // Raise the Below
  for (const v of merk.below.vertices) {
    const boost = (10 - c[v.index]) * t;
    descended[v.index] = Math.min(10, c[v.index] + boost);
  }

  // Lower the Above
  for (const v of merk.above.vertices) {
    const drop = c[v.index] * t;
    descended[v.index] = Math.max(0, c[v.index] - drop);
  }

  // Mirror stays anchored (no change)

  const newMerk = partition(descended);

  return {
    coordinate: descended,
    original: c,
    merkabah: newMerk,
    delta: distance(c, descended),
    polarity: polarity(newMerk),
    direction: 'descending',
    layer: LAYERS.BELOW
  };
}

// ═══════════════════════════════════════════════════════════
// MIRROR — As Above, So Below
// ═══════════════════════════════════════════════════════════

/**
 * Mirror: reflect the coordinate through the Merkabah center.
 *
 * Every dimension's value is reflected around the center point (mean).
 * Dimensions that were high become low, and low become high.
 * "As above, so below" — the upper tetrahedron becomes the lower,
 * and the lower becomes the upper.
 *
 * This is a perfect inversion. The Merkabah flips.
 * The total energy (sum of all values) is preserved.
 *
 * @param {number[]} coord - 12D coordinate
 * @returns {object} { coordinate, merkabah, center, polarity }
 */
function mirror(coord) {
  const c = Array.isArray(coord) ? coord : createCoordinate(coord);
  const merk = partition(c);
  const center = merk.center;

  // Reflect each dimension around the center
  const mirrored = c.map(v => {
    const reflected = 2 * center - v;
    return Math.max(0, Math.min(10, reflected));
  });

  const newMerk = partition(mirrored);

  return {
    coordinate: mirrored,
    original: c,
    merkabah: newMerk,
    center,
    polarity: polarity(newMerk),
    // The mirrored polarity should be the reciprocal of the original
    originalPolarity: polarity(merk),
    symmetry: similarity(c, mirrored)
  };
}

// ═══════════════════════════════════════════════════════════
// PHASE — Forge Stage from Merkabah Rotation
// ═══════════════════════════════════════════════════════════

/**
 * Determine the current phase of the Merkabah rotation.
 *
 * The phase maps to the four stages of the Great Work:
 *   - Nigredo (0-90°): high entropy, things are being broken apart
 *   - Albedo (90-180°): purification, contradictions resolving
 *   - Citrinitas (180-270°): illumination, coordinates becoming clear
 *   - Rubedo (270-360°): crystallization, the final form emerges
 *
 * The phase is determined by the POLARITY of the Merkabah:
 *   - Very high polarity (spirit >> matter) → early stages (Nigredo/Albedo)
 *   - Balanced polarity (spirit ≈ matter) → middle stages (Albedo/Citrinitas)
 *   - Very low polarity (matter >> spirit) → late stages (Citrinitas/Rubedo)
 *
 * This means: things start as pure idea (fire) and end as pure matter (earth).
 * The Merkabah rotation IS the transmutation.
 *
 * @param {number[]} coord - 12D coordinate
 * @returns {object} { phase, angle, progress, layer, forge }
 */
function phase(coord) {
  const c = Array.isArray(coord) ? coord : createCoordinate(coord);
  const merk = partition(c);
  const pol = polarity(merk);

  // Map polarity to angle:
  // pol >> 1 → 0° (pure spirit, beginning of Nigredo)
  // pol ≈ 1 → 180° (balance, Citrinitas begins)
  // pol << 1 → 360° (pure matter, end of Rubedo)
  //
  // Use atan to map the ratio smoothly to 0-360
  // atan(pol - 1) ranges from -pi/2 to +pi/2
  // Normalize to 0-360
  const atan = Math.atan2(pol - 1, 1); // -pi/4 to pi/4 for reasonable ratios
  const normalizedAngle = ((1 - (atan / (Math.PI / 2))) / 2) * 360;
  const angle = Math.max(0, Math.min(360, normalizedAngle));

  const forgePhase = phaseFromAngle(angle);

  // Progress within the current phase (0-1)
  const phaseStart = forgePhase.range[0];
  const phaseEnd = forgePhase.range[1];
  const progress = (angle - phaseStart) / (phaseEnd - phaseStart);

  // Which morph layer are we closest to?
  let layer;
  if (pol > 1.5) layer = LAYERS.ABOVE;
  else if (pol < 0.67) layer = LAYERS.BELOW;
  else layer = LAYERS.MIRROR;

  return {
    phase: forgePhase.phase,
    symbol: forgePhase.symbol,
    element: forgePhase.element,
    domain: forgePhase.domain,
    description: forgePhase.description,
    angle,
    progress,
    polarity: pol,
    layer,
    merkabah: merk
  };
}

/**
 * Get the forge phase for a given angle.
 */
function phaseFromAngle(angle) {
  const a = ((angle % 360) + 360) % 360;
  for (const p of PHASE_MAP) {
    if (a >= p.range[0] && a < p.range[1]) return p;
  }
  // Edge case: exactly 360 wraps to Nigredo
  return PHASE_MAP[0];
}

// ═══════════════════════════════════════════════════════════
// COMPOSITE OPERATIONS
// ═══════════════════════════════════════════════════════════

/**
 * Spin the Merkabah: apply a continuous rotation and return snapshots.
 *
 * Like the spinning Merkabah in the simulation, this rotates through
 * all 12 perspectives (one per face of the dodecahedron) and returns
 * the phase at each position. Useful for analyzing a coordinate from
 * every angle.
 *
 * @param {number[]} coord - 12D coordinate
 * @param {number} snapshots - Number of snapshots (default 12)
 * @returns {object[]} Array of rotation snapshots
 */
function spin(coord, snapshots = 12) {
  const c = Array.isArray(coord) ? coord : createCoordinate(coord);
  const results = [];

  for (let i = 0; i < snapshots; i++) {
    const angle = (i / snapshots) * 360;
    const rotated = rotate(c, angle);
    const p = phase(rotated.coordinate);

    results.push({
      index: i,
      angle,
      perspective: rotated.perspective,
      phase: p.phase,
      polarity: p.polarity,
      layer: p.layer,
      coordinate: rotated.coordinate
    });
  }

  return results;
}

/**
 * Balance the Merkabah: adjust a coordinate toward hermetic equilibrium.
 *
 * Moves all dimensions toward the mean, reducing the gap between
 * Above and Below. At full intensity, all dimensions become equal
 * (perfect Mirror — pure potential, no manifestation).
 *
 * @param {number[]} coord   - 12D coordinate
 * @param {number} intensity - How strongly to balance (0-1, default 0.5)
 * @returns {object} { coordinate, merkabah, polarity }
 */
function balance(coord, intensity = 0.5) {
  const c = Array.isArray(coord) ? coord : createCoordinate(coord);
  const mean = c.reduce((s, v) => s + v, 0) / 12;
  const t = Math.max(0, Math.min(1, intensity));

  const balanced = c.map(v => {
    return v + (mean - v) * t;
  });

  const newMerk = partition(balanced);

  return {
    coordinate: balanced,
    original: c,
    merkabah: newMerk,
    polarity: polarity(newMerk),
    equilibrium: 1 - Math.abs(polarity(newMerk) - 1)
  };
}

/**
 * Transmute via Merkabah: a full rotation that transforms a coordinate
 * through all four forge stages.
 *
 * Unlike traverse() which moves between two points, transmute() stays
 * at one point but rotates the Merkabah around it — changing the
 * perspective through Nigredo, Albedo, Citrinitas, Rubedo.
 *
 * The final coordinate is the original transformed by the full cycle:
 * dimensions that survived all four phases are strengthened;
 * dimensions that contradicted the rotation are weakened.
 *
 * @param {number[]} coord - 12D coordinate to transmute
 * @returns {object} { stages, result, delta }
 */
function merkabahTransmute(coord) {
  const c = Array.isArray(coord) ? [...coord] : [...createCoordinate(coord)];
  const stages = [];

  // Stage 1: Nigredo (0-90°) — decompose via mirroring
  // The mirror reveals what is hidden. What was above falls below.
  const nigredoResult = mirror(c);
  stages.push({
    name: 'nigredo',
    symbol: '🜁',
    operation: 'mirror',
    coordinate: nigredoResult.coordinate,
    insight: 'The hidden is revealed. Above becomes below.'
  });

  // Stage 2: Albedo (90-180°) — purify via balancing
  // Remove extremes, find the center. Contradictions dissolve.
  const albedoResult = balance(nigredoResult.coordinate, 0.5);
  stages.push({
    name: 'albedo',
    symbol: '🜄',
    operation: 'balance',
    coordinate: albedoResult.coordinate,
    insight: 'Extremes dissolve. The center holds.'
  });

  // Stage 3: Citrinitas (180-270°) — illuminate via ascending
  // The purified rises. Coordinates become clear.
  const citrinitasResult = ascend(albedoResult.coordinate, 0.4);
  stages.push({
    name: 'citrinitas',
    symbol: '🜃',
    operation: 'ascend',
    coordinate: citrinitasResult.coordinate,
    insight: 'The purified rises. Pattern emerges from noise.'
  });

  // Stage 4: Rubedo (270-360°) — crystallize via descending
  // Spirit becomes matter. The idea takes form.
  const rubedoResult = descend(citrinitasResult.coordinate, 0.3);
  stages.push({
    name: 'rubedo',
    symbol: '🜂',
    operation: 'descend',
    coordinate: rubedoResult.coordinate,
    insight: 'Spirit becomes stone. The form is fixed.'
  });

  return {
    stages,
    original: c,
    result: rubedoResult.coordinate,
    delta: distance(c, rubedoResult.coordinate),
    finalMerkabah: partition(rubedoResult.coordinate),
    finalPolarity: polarity(partition(rubedoResult.coordinate)),
    finalPhase: phase(rubedoResult.coordinate)
  };
}

// ═══════════════════════════════════════════════════════════
// EXPORTS
// ═══════════════════════════════════════════════════════════

module.exports = {
  // Constants
  LAYERS,
  PHASE_MAP,
  // Core geometry
  partition,
  polarity,
  // Traversal
  traverse,
  // Rotation
  rotate,
  spin,
  // Vertical movement
  ascend,
  descend,
  // Reflection
  mirror,
  // Phase detection
  phase,
  phaseFromAngle,
  // Composite
  balance,
  merkabahTransmute
};
