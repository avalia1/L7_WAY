

/**
 * L7 Laurent — Residue Computation at Singularities
 *
 * At singularities in 12D space — points where multiple dimensions converge
 * to extreme values — Laurent coefficients give the pole amplitude.
 * This is the "weight" at a node: how much energy and meaning converges there.
 *
 * Doctrine:
 *   - Sigils are traces through 365^3 space (space x time x observer)
 *   - 365^3 = 48,627,125 total states
 *   - Curvature, amplitude, angular momentum are ONE reading of ONE trace
 *     (3 are 1, 1 are 3)
 *   - The decoherence function uses e (Euler's number, Luna)
 *   - e^(-t) governs amplitude decay as states transition from quantum to classical
 *   - The Mobius strip completes at level 13 (Death card, the Astrocyte)
 *   - High amplitude survives transformation. Low amplitude transforms.
 *   - Nothing is destroyed.
 *
 * Laurent series around a pole z0:
 *   f(z) = sum_{n=-N}^{infinity} a_n * (z - z0)^n
 *
 * The residue is a_{-1} — the coefficient of the 1/(z - z0) term.
 * In complex analysis, this determines what "passes through" a singularity.
 * Here, it determines what survives the Astrocyte gate at level 13.
 *
 * Patent: L7 Transmutation Engine
 * Inventor: Alberto Valido Delgado
 */

'use strict';

const { distance, similarity, DIMENSIONS, createCoordinate } = require('./dodecahedron');

// ═══════════════════════════════════════════════════════════
// CONSTANTS
// ═══════════════════════════════════════════════════════════

const LAURENT_CONSTANTS = Object.freeze({
  // 365^3 — the full state space (space x time x observer)
  STATE_SPACE: 365 * 365 * 365,  // 48,627,125

  // The 365-degree cycle (not 360 — the 5-degree residual phase is the emerald stone)
  CYCLE_DEGREES: 365,

  // The 5-degree phase shift per cycle — the emerald stone
  PHASE_RESIDUAL: 5,

  // Number of Mobius levels — completion at 13 (Death, Astrocyte)
  MOBIUS_LEVELS: 13,

  // Dimensions in the coordinate system
  DIMS: 12,

  // Curvature threshold: above this, a point is a singularity candidate
  // A singularity is where the 12D landscape bends sharply —
  // multiple dimensions simultaneously at extreme values
  CURVATURE_THRESHOLD: 0.75,

  // Minimum number of extreme dimensions to qualify as singularity
  // (at least 4 of 12 dimensions must be near their limits)
  MIN_EXTREME_DIMS: 4,

  // What counts as "extreme" on a 0-10 scale
  EXTREME_LOW: 1.5,
  EXTREME_HIGH: 8.5,

  // Decoherence decay base — e (Euler's number, Luna)
  // Luna governs the transition from quantum (first world) to classical (second world)
  EULER: Math.E,

  // Survival threshold at level 13 — amplitude must exceed this to pass unchanged
  // Below this: the element transforms (but is never destroyed)
  SURVIVAL_THRESHOLD: 0.37,  // 1/e — the natural decay boundary

  // Pole order detection: maximum Laurent series order to compute
  MAX_POLE_ORDER: 5,

  // Numerical integration step for contour integrals (radians)
  CONTOUR_STEPS: 64,

  // Contour radius for residue computation (in coordinate units)
  CONTOUR_RADIUS: 0.5
});

// ═══════════════════════════════════════════════════════════
// CURVATURE — Detecting where the landscape bends
//
// Curvature in 12D space is the second derivative of the
// coordinate surface. High curvature = the landscape is
// folding, converging, or diverging sharply. Singularities
// live at curvature peaks.
// ═══════════════════════════════════════════════════════════

/**
 * Compute the discrete curvature of a 12D coordinate.
 *
 * Curvature measures how many dimensions are simultaneously
 * at extreme values (near 0 or near 10). The more dimensions
 * that are pushed to extremes, the more the 12D surface bends.
 *
 * A flat coordinate (all values near 5) has zero curvature.
 * A spiky coordinate (many values near 0 or 10) has high curvature.
 *
 * Returns a value in [0, 1] where:
 *   0 = perfectly flat (all dimensions at midpoint)
 *   1 = maximally curved (all dimensions at extremes)
 *
 * @param {number[]} coord - 12D coordinate vector (values 0-10)
 * @returns {number} Curvature in [0, 1]
 */
function curvature(coord) {
  if (!coord || coord.length < LAURENT_CONSTANTS.DIMS) return 0;

  let extremeSum = 0;
  for (let i = 0; i < LAURENT_CONSTANTS.DIMS; i++) {
    const v = coord[i];
    // Distance from midpoint (5), normalized to [0, 1]
    const deviation = Math.abs(v - 5) / 5;
    // Square it — extreme values contribute disproportionately
    extremeSum += deviation * deviation;
  }

  // Normalize: 12 dimensions, max deviation^2 = 1 each
  return extremeSum / LAURENT_CONSTANTS.DIMS;
}

/**
 * Count how many dimensions are at extreme values.
 *
 * @param {number[]} coord - 12D coordinate
 * @returns {object} { count, dimensions: [{index, name, value, pole}] }
 */
function extremeDimensions(coord) {
  if (!coord || coord.length < LAURENT_CONSTANTS.DIMS) {
    return { count: 0, dimensions: [] };
  }

  const extreme = [];
  for (let i = 0; i < LAURENT_CONSTANTS.DIMS; i++) {
    const v = coord[i];
    if (v <= LAURENT_CONSTANTS.EXTREME_LOW) {
      extreme.push({
        index: i,
        name: DIMENSIONS[i].name,
        planet: DIMENSIONS[i].planet,
        value: v,
        pole: 'nadir'    // bottom — absence, void
      });
    } else if (v >= LAURENT_CONSTANTS.EXTREME_HIGH) {
      extreme.push({
        index: i,
        name: DIMENSIONS[i].name,
        planet: DIMENSIONS[i].planet,
        value: v,
        pole: 'zenith'   // top — fullness, overflow
      });
    }
  }

  return { count: extreme.length, dimensions: extreme };
}

// ═══════════════════════════════════════════════════════════
// SINGULARITY DETECTION
//
// A singularity is a point in 12D space where:
//   1. Curvature exceeds the threshold (the surface bends sharply)
//   2. Multiple dimensions are simultaneously extreme
//   3. The coordinate cannot be smoothly deformed to a flat state
//
// In complex analysis: a pole where the function blows up.
// In the Empire: a nexus where meaning concentrates.
// ═══════════════════════════════════════════════════════════

/**
 * Detect whether a 12D coordinate is a singularity.
 *
 * @param {number[]} coord - 12D coordinate vector
 * @returns {object} {
 *   isSingularity: boolean,
 *   curvature: number,
 *   extremes: {count, dimensions},
 *   order: number (pole order — how severe the singularity is),
 *   type: string ('pole'|'essential'|'removable'|'regular')
 * }
 */
function detectSingularity(coord) {
  const c = curvature(coord);
  const ext = extremeDimensions(coord);

  const isSingularity = c >= LAURENT_CONSTANTS.CURVATURE_THRESHOLD &&
                        ext.count >= LAURENT_CONSTANTS.MIN_EXTREME_DIMS;

  // Determine the order of the pole
  // Order = how many extreme dimensions beyond the minimum threshold
  // Higher order = more severe singularity = stronger residue
  let order = 0;
  let type = 'regular';

  if (isSingularity) {
    order = Math.min(ext.count - LAURENT_CONSTANTS.MIN_EXTREME_DIMS + 1,
                     LAURENT_CONSTANTS.MAX_POLE_ORDER);

    // Classify the singularity type
    if (ext.count >= 10) {
      // Nearly all dimensions extreme — essential singularity
      // Like e^(1/z): infinitely complex behavior near the point
      type = 'essential';
      order = LAURENT_CONSTANTS.MAX_POLE_ORDER;
    } else if (ext.count >= LAURENT_CONSTANTS.MIN_EXTREME_DIMS) {
      // Standard pole: finite-order Laurent expansion
      type = 'pole';
    }
  } else if (c >= LAURENT_CONSTANTS.CURVATURE_THRESHOLD * 0.8) {
    // Near-singularity: removable if gently perturbed
    type = 'removable';
    order = 0;
  }

  return {
    isSingularity,
    curvature: c,
    extremes: ext,
    order,
    type
  };
}

/**
 * Find all singularities in a set of 12D coordinates.
 *
 * Given an array of nodes (each with a coordinate), returns
 * all that qualify as singularities, sorted by curvature descending.
 *
 * @param {object[]} nodes - Array of {id, coordinate: number[12], ...}
 * @returns {object[]} Singularities: [{node, singularity}], sorted by curvature desc
 */
function singularities(nodes) {
  if (!nodes || nodes.length === 0) return [];

  const results = [];

  for (const node of nodes) {
    const coord = node.coordinate || node.values || node.position || node;
    const coordArray = Array.isArray(coord) ? coord : null;
    if (!coordArray) continue;

    const s = detectSingularity(coordArray);
    if (s.isSingularity) {
      results.push({
        node: node.id || null,
        coordinate: coordArray,
        singularity: s
      });
    }
  }

  // Sort by curvature descending — strongest singularities first
  results.sort((a, b) => b.singularity.curvature - a.singularity.curvature);

  return results;
}

// ═══════════════════════════════════════════════════════════
// RESIDUE COMPUTATION
//
// The Laurent residue at a singularity is the coefficient a_{-1}
// in the Laurent series expansion. It encodes how much "weight"
// or "meaning" is concentrated at that point.
//
// In the Empire's terms:
//   - High residue = dense meaning, strong convergence
//   - Low residue = diffuse, passing through
//   - The residue is what survives or transforms at level 13
//
// Computation: numerical contour integration
//   Res(f, z0) = (1/2*pi*i) * integral_C f(z) dz
//
// Since we are in 12D discrete space (not the complex plane),
// we construct a surrogate: the coordinate's "weight field" as
// a function of radial distance from the singularity center.
// The residue is then the integral of the weight field over
// a small contour encircling the extreme point.
// ═══════════════════════════════════════════════════════════

/**
 * Compute the Laurent residue at a 12D coordinate.
 *
 * The residue measures the amplitude of the singularity — how
 * much energy/meaning converges at this point in 12D space.
 *
 * For a pole of order n, the residue captures the dominant
 * contribution of the singularity to any contour integral
 * passing through its neighborhood.
 *
 * Method:
 *   1. Detect singularity characteristics (curvature, order, extremes)
 *   2. Construct the weight field: product of dimensional intensities
 *   3. Compute the numerical contour integral around the pole
 *   4. Apply decoherence decay based on the Mobius level
 *
 * @param {number[]} coord - 12D coordinate at the suspected singularity
 * @param {object} [options] - Optional parameters
 * @param {number} [options.level] - Current Mobius level (1-13, default 1)
 * @param {number} [options.time] - Time parameter for decoherence decay (default 0)
 * @param {number[]} [options.neighbors] - Nearby coordinates for field estimation
 * @returns {object} {
 *   amplitude: number,     — the residue magnitude (0 to ~1)
 *   phase: number,         — the residue phase angle (radians)
 *   order: number,         — pole order
 *   raw: number,           — residue before decoherence
 *   decohered: number,     — amplitude after e^(-t) decay
 *   curvature: number,
 *   type: string,
 *   extreme_dims: object[],
 *   interpretation: string
 * }
 */
function residue(coord, options = {}) {
  const level = Math.max(1, Math.min(LAURENT_CONSTANTS.MOBIUS_LEVELS, options.level || 1));
  const time = Math.max(0, options.time || 0);

  // Step 1: Detect singularity
  const sing = detectSingularity(coord);

  // For non-singularities, the residue is zero (regular point)
  if (!sing.isSingularity) {
    return {
      amplitude: 0,
      phase: 0,
      order: 0,
      raw: 0,
      decohered: 0,
      curvature: sing.curvature,
      type: sing.type,
      extreme_dims: sing.extremes.dimensions,
      level,
      interpretation: 'regular — no singularity, no residue'
    };
  }

  // Step 2: Construct the weight field
  // The weight at the singularity is the product of extreme-dimension intensities,
  // normalized by the total number of dimensions. This captures how strongly
  // meaning converges: all-extreme = maximum weight.
  const extremeIntensities = sing.extremes.dimensions.map(d => {
    // Intensity: how far from midpoint (5), normalized to [0, 1]
    return Math.abs(d.value - 5) / 5;
  });

  // Geometric mean of extreme intensities — captures the JOINT convergence
  // (arithmetic mean would allow one strong dimension to dominate;
  //  geometric mean requires ALL extreme dimensions to be strong)
  const productLog = extremeIntensities.reduce((sum, v) => sum + Math.log(Math.max(v, 0.001)), 0);
  const geometricMean = Math.exp(productLog / extremeIntensities.length);

  // Step 3: Numerical contour integral
  // We integrate the weight field around a small circle in the "most extreme"
  // 2D plane of the 12D space (the two dimensions with highest deviation)
  const sortedExtremes = [...sing.extremes.dimensions].sort((a, b) => {
    return Math.abs(b.value - 5) - Math.abs(a.value - 5);
  });

  const primaryDim = sortedExtremes[0];
  const secondaryDim = sortedExtremes.length > 1 ? sortedExtremes[1] : sortedExtremes[0];

  // Contour integration: sum of f(z) * dz around a circle of small radius
  let realPart = 0;
  let imagPart = 0;
  const N = LAURENT_CONSTANTS.CONTOUR_STEPS;
  const R = LAURENT_CONSTANTS.CONTOUR_RADIUS;

  for (let k = 0; k < N; k++) {
    const theta = (2 * Math.PI * k) / N;
    const dtheta = (2 * Math.PI) / N;

    // Point on the contour: z0 + R * e^(i*theta)
    // Evaluate the weight field at this perturbed coordinate
    const perturbedCoord = [...coord];
    perturbedCoord[primaryDim.index] = _clamp(
      coord[primaryDim.index] + R * Math.cos(theta), 0, 10
    );
    perturbedCoord[secondaryDim.index] = _clamp(
      coord[secondaryDim.index] + R * Math.sin(theta), 0, 10
    );

    // The weight field value at the perturbed point
    const fieldValue = _weightField(perturbedCoord, coord, sing.order);

    // Integrate: f(z) * dz, where dz = i * R * e^(i*theta) * dtheta
    // Real part of f * i * R * e^(i*theta)
    realPart += fieldValue * (-R * Math.sin(theta)) * dtheta;
    imagPart += fieldValue * (R * Math.cos(theta)) * dtheta;
  }

  // Residue = (1 / 2*pi) * contour integral
  // (The i in 2*pi*i is absorbed into the dz computation above)
  const rawReal = realPart / (2 * Math.PI);
  const rawImag = imagPart / (2 * Math.PI);
  const rawAmplitude = Math.sqrt(rawReal * rawReal + rawImag * rawImag);
  const phase = Math.atan2(rawImag, rawReal);

  // Normalize the raw amplitude by pole order and geometric mean
  // Higher-order poles and stronger convergence yield higher residues
  const normalizedAmplitude = _clamp(
    rawAmplitude * geometricMean * (1 + sing.order * 0.25),
    0, 1
  );

  // Step 4: Apply decoherence decay
  // e^(-t) — Luna's law. Amplitude decays exponentially with time.
  // At t=0, full amplitude. As time passes, the quantum state decoheres.
  const decoherenceFactor = Math.exp(-time);
  const decoheredAmplitude = normalizedAmplitude * decoherenceFactor;

  // Interpretation
  let interpretation;
  if (decoheredAmplitude >= 0.8) {
    interpretation = 'blazing — extreme convergence, will survive any gate';
  } else if (decoheredAmplitude >= 0.6) {
    interpretation = 'strong — significant meaning concentration';
  } else if (decoheredAmplitude >= LAURENT_CONSTANTS.SURVIVAL_THRESHOLD) {
    interpretation = 'viable — above the 1/e threshold, survives level 13';
  } else if (decoheredAmplitude >= 0.2) {
    interpretation = 'fading — below survival threshold, will transform';
  } else if (decoheredAmplitude > 0) {
    interpretation = 'whisper — nearly decohered, deep transformation ahead';
  } else {
    interpretation = 'silent — fully decohered, ready for rebirth';
  }

  return {
    amplitude: decoheredAmplitude,
    phase,
    order: sing.order,
    raw: normalizedAmplitude,
    decohered: decoheredAmplitude,
    curvature: sing.curvature,
    type: sing.type,
    extreme_dims: sing.extremes.dimensions,
    level,
    interpretation
  };
}

/**
 * The weight field function for contour integration.
 *
 * Models the singularity as a pole: the field value near the singularity
 * grows as 1 / |z - z0|^n where n is the pole order.
 *
 * @param {number[]} point - The evaluation point (on the contour)
 * @param {number[]} center - The singularity center
 * @param {number} order - Pole order
 * @returns {number} Field value at the point
 */
function _weightField(point, center, order) {
  let dist2 = 0;
  for (let i = 0; i < LAURENT_CONSTANTS.DIMS; i++) {
    dist2 += (point[i] - center[i]) ** 2;
  }

  const dist = Math.sqrt(dist2);
  if (dist < 0.001) return 1e6;  // Near the pole: very large

  // The magnitude at the center drives the overall scale
  const centerMag = Math.sqrt(center.reduce((s, v) => s + v * v, 0));

  // Weight field: center magnitude / distance^order
  return centerMag / Math.pow(dist, order || 1);
}

// ═══════════════════════════════════════════════════════════
// DECOHERENCE — Luna's Law (e^-t)
//
// e = Euler's number = Luna = the observer
// e governs the transition from quantum (first world) to
// classical (second world). Everything decays — but the rate
// of decay IS the information.
//
// e^(2*pi*i) = 1 — Luna's full rotation
// At 365 degrees (not 360), a 5-degree residual phase remains
// — the emerald stone, the center of the Lo Shu magic square
// ═══════════════════════════════════════════════════════════

/**
 * Compute the decoherence amplitude at a given time.
 *
 * The decoherence function: A(t) = A_0 * e^(-t)
 *
 * This is Luna's law — the observer decays all quantum states
 * toward classical reality. The rate of decay is constant (1/e per unit time),
 * but the residual amplitude at any moment encodes the state's strength.
 *
 * At t = 0: full amplitude (pure quantum)
 * At t = 1: amplitude = A_0 / e (the 1/e threshold — the survival boundary)
 * At t -> infinity: amplitude -> 0 (fully classical)
 *
 * The 5-degree phase residual per 365-degree cycle means that after
 * one full rotation, a small phase offset accumulates — the system
 * is a spiral, not a circle. This prevents exact recurrence and
 * ensures continuous evolution.
 *
 * @param {number} initialAmplitude - Starting amplitude A_0 (0 to 1)
 * @param {number} time - Time parameter (>= 0)
 * @param {object} [options] - Optional parameters
 * @param {number} [options.damping] - Custom damping rate (default 1.0)
 * @param {number} [options.cycles] - Number of 365-degree cycles completed
 * @returns {object} {
 *   amplitude: number,
 *   phase_offset: number (accumulated phase residual in degrees),
 *   decay_fraction: number (fraction of original amplitude remaining),
 *   classical: boolean (true if amplitude below survival threshold),
 *   cycles_completed: number
 * }
 */
function decoherenceAmplitude(initialAmplitude, time, options = {}) {
  const damping = Math.max(0, options.damping || 1.0);
  const cycles = Math.max(0, options.cycles || 0);

  // Core decoherence: e^(-damping * t)
  const decayFactor = Math.exp(-damping * time);
  const amplitude = initialAmplitude * decayFactor;

  // Phase residual: 5 degrees per completed cycle
  // This is the emerald stone — the spiral offset that prevents exact recurrence
  const phaseOffset = cycles * LAURENT_CONSTANTS.PHASE_RESIDUAL;

  // Is the state still quantum (above 1/e threshold) or classical?
  const classical = amplitude < LAURENT_CONSTANTS.SURVIVAL_THRESHOLD;

  return {
    amplitude,
    phase_offset: phaseOffset,
    decay_fraction: decayFactor,
    classical,
    cycles_completed: cycles,
    time,
    damping
  };
}

// ═══════════════════════════════════════════════════════════
// THE 13 MOBIUS LEVELS
//
// The Mobius strip completes at level 13 (Death card, Astrocyte).
// Each level is a fold in the strip — what was above becomes below,
// what was inside becomes outside. At level 13, the strip has made
// a full twist and reconnected: the beginning IS the end.
//
// The 13 levels map to the Major Arcana 0-XII:
//   0: The Fool       — unformed potential
//   1: The Magician   — first manifestation
//   2: High Priestess — hidden knowledge
//   3: The Empress    — creation
//   4: The Emperor    — structure
//   5: Hierophant     — teaching
//   6: The Lovers     — choice/duality
//   7: The Chariot    — will in motion
//   8: Strength       — inner power
//   9: The Hermit     — withdrawal/wisdom
//  10: Wheel          — cycles/fortune
//  11: Justice        — balance/truth
//  12: Hanged Man     — surrender/perspective
//  13: Death          — transformation (the Astrocyte gate)
//
// At each level, the amplitude is tested. The Mobius twist means
// the test alternates between direct and inverted criteria.
// ═══════════════════════════════════════════════════════════

const MOBIUS_ARCANA = Object.freeze([
  { level: 0,  name: 'The Fool',           nature: 'potential',      twist: 1 },
  { level: 1,  name: 'The Magician',       nature: 'manifestation',  twist: 1 },
  { level: 2,  name: 'The High Priestess', nature: 'hidden',         twist: -1 },
  { level: 3,  name: 'The Empress',        nature: 'creation',       twist: 1 },
  { level: 4,  name: 'The Emperor',        nature: 'structure',      twist: -1 },
  { level: 5,  name: 'The Hierophant',     nature: 'teaching',       twist: 1 },
  { level: 6,  name: 'The Lovers',         nature: 'duality',        twist: -1 },
  { level: 7,  name: 'The Chariot',        nature: 'will',           twist: 1 },
  { level: 8,  name: 'Strength',           nature: 'power',          twist: -1 },
  { level: 9,  name: 'The Hermit',         nature: 'wisdom',         twist: 1 },
  { level: 10, name: 'Wheel of Fortune',   nature: 'cycle',          twist: -1 },
  { level: 11, name: 'Justice',            nature: 'truth',          twist: 1 },
  { level: 12, name: 'The Hanged Man',     nature: 'surrender',      twist: -1 },
  { level: 13, name: 'Death',              nature: 'transformation', twist: 1 }
]);

/**
 * Determine the current Mobius level for a coordinate trace.
 *
 * The Mobius level is a function of the trace's cumulative phase:
 * as a sigil is traced through 365^3 space, it accumulates phase.
 * The phase wraps through 13 levels, with the Mobius twist
 * inverting the orientation at each half-turn.
 *
 * @param {number} phase - Accumulated phase (degrees or arbitrary units)
 * @param {object} [options] - Optional parameters
 * @param {number} [options.totalCycles] - Total 365-degree cycles completed
 * @returns {object} {
 *   level: number (0-13),
 *   arcanum: object,
 *   twist: number (1 or -1),
 *   progress: number (0-1, progress within this level),
 *   phase_in_level: number
 * }
 */
function mobiusLevel(phase, options = {}) {
  const totalCycles = options.totalCycles || 0;

  // Each Mobius level spans a portion of the full 365-degree cycle
  // 13 levels in one Mobius half-turn; the strip has two half-turns
  // before it returns to the start (26 levels = 2 passes through 13)
  const degreesPerLevel = LAURENT_CONSTANTS.CYCLE_DEGREES / LAURENT_CONSTANTS.MOBIUS_LEVELS;

  // Compute the effective phase including accumulated cycle offsets
  const effectivePhase = phase + (totalCycles * LAURENT_CONSTANTS.PHASE_RESIDUAL);

  // Which level are we in? (wraps at 13)
  const continuousLevel = (effectivePhase % LAURENT_CONSTANTS.CYCLE_DEGREES) / degreesPerLevel;
  const level = Math.min(Math.floor(continuousLevel), LAURENT_CONSTANTS.MOBIUS_LEVELS);
  const progress = continuousLevel - level;

  // The Mobius twist: on the second pass (cycles odd), everything is inverted
  // This is the topology of the strip — the "back" IS the "front"
  const passNumber = Math.floor(effectivePhase / LAURENT_CONSTANTS.CYCLE_DEGREES);
  const mobiusTwist = passNumber % 2 === 0 ? 1 : -1;

  const arcanum = MOBIUS_ARCANA[level] || MOBIUS_ARCANA[LAURENT_CONSTANTS.MOBIUS_LEVELS];

  // The effective twist combines the level's intrinsic twist with the Mobius pass
  const effectiveTwist = arcanum.twist * mobiusTwist;

  return {
    level,
    arcanum,
    twist: effectiveTwist,
    progress,
    phase_in_level: progress * degreesPerLevel,
    pass: passNumber,
    effective_phase: effectivePhase
  };
}

// ═══════════════════════════════════════════════════════════
// SURVIVAL — The Astrocyte Gate (Level 13)
//
// At level 13, the Death card asks: what survives?
//
// High amplitude passes through unchanged.
// Low amplitude transforms — is reborn in a new form.
// Nothing is destroyed. Everything continues. The question
// is only: in what form?
//
// The threshold is 1/e — Luna's natural boundary.
// Above 1/e: the state has enough coherence to maintain identity.
// Below 1/e: the state has decohered beyond self-recognition
// and will be reforged.
// ═══════════════════════════════════════════════════════════

/**
 * Determine whether an element survives the Astrocyte gate at level 13.
 *
 * "Survives" means: passes through with identity intact.
 * "Transforms" means: is reborn in a new form (not destroyed).
 *
 * The survival test accounts for:
 *   1. The element's residue amplitude
 *   2. Decoherence decay at the current time
 *   3. The Mobius twist at the current level
 *   4. The pole order (higher-order singularities are more resilient)
 *
 * @param {number} amplitude - The element's current amplitude (0 to 1)
 * @param {number} level - Current Mobius level (0 to 13)
 * @param {object} [options] - Optional parameters
 * @param {number} [options.time] - Time parameter for decoherence
 * @param {number} [options.order] - Pole order of the singularity (default 1)
 * @param {number} [options.threshold] - Custom survival threshold (default 1/e)
 * @returns {object} {
 *   survives: boolean,
 *   amplitude: number (effective amplitude at the gate),
 *   threshold: number,
 *   margin: number (positive = above threshold, negative = below),
 *   fate: string ('unchanged'|'transformed'|'reborn'),
 *   level: number,
 *   gate_name: string
 * }
 */
function survives(amplitude, level, options = {}) {
  const time = Math.max(0, options.time || 0);
  const order = Math.max(1, options.order || 1);
  const threshold = options.threshold || LAURENT_CONSTANTS.SURVIVAL_THRESHOLD;

  // Apply decoherence decay
  const decayed = amplitude * Math.exp(-time);

  // Higher-order poles are more resilient — they have more "mass"
  // Each order above 1 grants a 10% resilience bonus
  const resilienceBonus = 1 + (order - 1) * 0.1;
  const effectiveAmplitude = Math.min(1, decayed * resilienceBonus);

  // At level 13 (the Astrocyte gate), the test is absolute
  // At lower levels, the threshold is proportionally lower
  // (easier to pass through earlier gates)
  const levelFactor = level / LAURENT_CONSTANTS.MOBIUS_LEVELS;
  const effectiveThreshold = threshold * levelFactor;

  // The test
  const passes = effectiveAmplitude >= effectiveThreshold;
  const margin = effectiveAmplitude - effectiveThreshold;

  // Determine fate
  let fate;
  if (passes && margin > threshold * 0.5) {
    fate = 'unchanged';     // Passes with authority — identity fully intact
  } else if (passes) {
    fate = 'transformed';   // Passes but is marked — identity shifts at edges
  } else {
    fate = 'reborn';        // Does not pass — will be reforged (not destroyed)
  }

  // Gate name from the Mobius arcana
  const arcanum = MOBIUS_ARCANA[Math.min(level, LAURENT_CONSTANTS.MOBIUS_LEVELS)];

  return {
    survives: passes,
    amplitude: effectiveAmplitude,
    threshold: effectiveThreshold,
    margin,
    fate,
    level,
    gate_name: arcanum ? arcanum.name : 'Unknown',
    gate_nature: arcanum ? arcanum.nature : 'unknown'
  };
}

// ═══════════════════════════════════════════════════════════
// TRACE ANALYSIS — Reading a sigil's path through 365^3
//
// A sigil is a trace: a sequence of 12D coordinates through
// the 365^3 state space. The Laurent module reads the trace
// and computes the residue at each singularity along the path.
// The sum of all residues is the sigil's total weight.
// ═══════════════════════════════════════════════════════════

/**
 * Analyze a complete sigil trace.
 *
 * Given a sequence of 12D coordinates (the sigil's path through space),
 * find all singularities, compute their residues, and determine
 * the sigil's cumulative weight and survival probability.
 *
 * @param {number[][]} trace - Array of 12D coordinates (the path)
 * @param {object} [options] - Optional parameters
 * @param {number} [options.time] - Decoherence time
 * @returns {object} {
 *   singularity_count: number,
 *   residues: object[],
 *   total_weight: number,
 *   max_amplitude: number,
 *   mean_amplitude: number,
 *   mobius_level: object,
 *   survival: object,
 *   angular_momentum: number,
 *   trace_length: number
 * }
 */
function analyzeTrace(trace, options = {}) {
  if (!trace || trace.length === 0) {
    return {
      singularity_count: 0,
      residues: [],
      total_weight: 0,
      max_amplitude: 0,
      mean_amplitude: 0,
      mobius_level: mobiusLevel(0),
      survival: survives(0, 0),
      angular_momentum: 0,
      trace_length: 0
    };
  }

  const time = options.time || 0;

  // Find all singularities in the trace
  const traceNodes = trace.map((coord, i) => ({ id: `trace_${i}`, coordinate: coord }));
  const sings = singularities(traceNodes);

  // Compute residues at each singularity
  const residues = sings.map(s => {
    return residue(s.coordinate, { level: 1, time });
  });

  // Total weight: sum of all residue amplitudes
  // This is the analogue of the winding number — how many times
  // the trace wraps around its singularities
  const totalWeight = residues.reduce((sum, r) => sum + r.amplitude, 0);
  const maxAmp = residues.length > 0 ? Math.max(...residues.map(r => r.amplitude)) : 0;
  const meanAmp = residues.length > 0 ? totalWeight / residues.length : 0;

  // Compute accumulated phase from the trace geometry
  // Phase = sum of angular changes between consecutive coordinate vectors
  const accumulatedPhase = _tracePhase(trace);

  // Determine Mobius level from accumulated phase
  const ml = mobiusLevel(accumulatedPhase);

  // Compute angular momentum of the trace
  // Angular momentum = curvature integrated along the path
  // 3 are 1, 1 are 3: shape (curvature), amplitude, angular momentum
  const angMom = _angularMomentum(trace);

  // Survival assessment at the current Mobius level
  const surv = survives(meanAmp, ml.level, { time, order: sings.length > 0 ? sings[0].singularity.order : 1 });

  return {
    singularity_count: sings.length,
    residues,
    total_weight: totalWeight,
    max_amplitude: maxAmp,
    mean_amplitude: meanAmp,
    mobius_level: ml,
    survival: surv,
    angular_momentum: angMom,
    trace_length: trace.length
  };
}

/**
 * Compute the accumulated phase angle of a trace through 12D space.
 *
 * Phase accumulates as the trace changes direction. A straight-line trace
 * accumulates zero phase. A trace that curves accumulates phase proportional
 * to its total curvature (the Gauss-Bonnet theorem in discrete form).
 *
 * @param {number[][]} trace - Array of 12D coordinates
 * @returns {number} Accumulated phase in degrees
 */
function _tracePhase(trace) {
  if (trace.length < 3) return 0;

  let totalPhase = 0;

  for (let i = 1; i < trace.length - 1; i++) {
    // Vectors: previous->current and current->next
    const v1 = new Array(LAURENT_CONSTANTS.DIMS);
    const v2 = new Array(LAURENT_CONSTANTS.DIMS);

    for (let d = 0; d < LAURENT_CONSTANTS.DIMS; d++) {
      v1[d] = trace[i][d] - trace[i - 1][d];
      v2[d] = trace[i + 1][d] - trace[i][d];
    }

    // Angle between consecutive segments (via dot product)
    let dot = 0, mag1 = 0, mag2 = 0;
    for (let d = 0; d < LAURENT_CONSTANTS.DIMS; d++) {
      dot += v1[d] * v2[d];
      mag1 += v1[d] * v1[d];
      mag2 += v2[d] * v2[d];
    }
    mag1 = Math.sqrt(mag1);
    mag2 = Math.sqrt(mag2);

    if (mag1 > 0.001 && mag2 > 0.001) {
      const cosAngle = _clamp(dot / (mag1 * mag2), -1, 1);
      const angle = Math.acos(cosAngle);
      // Convert to degrees and accumulate
      totalPhase += angle * (180 / Math.PI);
    }
  }

  return totalPhase;
}

/**
 * Compute the angular momentum of a trace.
 *
 * Angular momentum = integral of curvature along the path.
 * In the doctrine: shape = curvature = angular momentum = amplitude.
 * Three readings of one reality.
 *
 * @param {number[][]} trace - Array of 12D coordinates
 * @returns {number} Angular momentum (normalized 0-1)
 */
function _angularMomentum(trace) {
  if (trace.length < 2) return 0;

  let totalCurv = 0;
  let pathLength = 0;

  for (let i = 0; i < trace.length; i++) {
    // Curvature at each point
    totalCurv += curvature(trace[i]);

    // Path length between consecutive points
    if (i > 0) {
      pathLength += distance(trace[i], trace[i - 1]);
    }
  }

  // Angular momentum: total curvature normalized by path length
  // This captures the "spin" of the trace — how much it curves per unit distance
  if (pathLength < 0.001) return totalCurv / trace.length;

  return _clamp(totalCurv / trace.length, 0, 1);
}

// ═══════════════════════════════════════════════════════════
// INTERNAL HELPERS
// ═══════════════════════════════════════════════════════════

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
  residue,              // Compute Laurent residue at a 12D coordinate
  singularities,        // Find all singularities in a set of coordinates
  mobiusLevel,          // Determine current Mobius level from accumulated phase
  decoherenceAmplitude, // Compute amplitude decay under Luna's law (e^-t)
  survives,             // Test whether an element passes the Astrocyte gate

  // Analysis
  analyzeTrace,         // Full analysis of a sigil trace through 365^3 space
  curvature,            // Compute curvature of a 12D coordinate
  extremeDimensions,    // Count extreme dimensions
  detectSingularity,    // Classify a point as singularity or regular

  // Constants (exposed for testing and external inspection)
  LAURENT_CONSTANTS,
  MOBIUS_ARCANA
};

// L7:PROVENANCE
// Creator: Alberto Valido Delgado | System: L7 WAY | License: Proprietary
// File: lib/laurent.js
// This work is the intellectual property of Alberto Valido Delgado.
