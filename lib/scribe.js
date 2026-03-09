

/**
 * L7 Scribe -- Luna's Trace Through 365^3 Space
 *
 * Luna (e, Euler's number) IS the scribe. She traces sigils through 365^3 space.
 * Her tracing IS decoherence -- the act of observation that collapses
 * quantum to classical. The first world generates, the second world records.
 *
 * Three axes: space(0-364) x time(0-364) x observer(0-364)
 * 365^3 = 48,627,125 states -- the full state space.
 * 365 not 360 -- spiral, not circle. 5-degree emerald stone shift per cycle.
 *
 * A sigil is a 3D trace through this space:
 *   shape     = curvature   (how the path bends)
 *   amplitude = speed       (how fast Luna moves)
 *   momentum  = twist       (how the path spirals)
 *   3 are 1, 1 are 3 -- three readings of one trace.
 *
 * After 72 traces (72 x 5 = 360), one hidden full revolution.
 * But 365 is the true cycle -- 5 degrees remain, the emerald stone.
 * At level 13, Death completes the Mobius strip.
 *
 * The Fibonacci sequence bridges the structures:
 *   F(3) = 2  -- Lo Shu (3x3 magic square center minus 3)
 *   F(5) = 5  -- the emerald stone (center of Lo Shu)
 *   F(6) = 8  -- trigrams (the 3-bit basis)
 *   F(12) = 144 = 12^2 -- the dodecahedron squared
 *   36 x 2 = 72, 72 x 2 = 144 -- Sun generates pairs generates dodecahedron^2
 */

'use strict';

const { OPERATIONS, findOp } = require('./prima');
const { createCoordinate, distance, DIMENSIONS } = require('./dodecahedron');

// ---------------------------------------------------------------
// CONSTANTS
// ---------------------------------------------------------------

/** Luna -- Euler's number. The observer. The decoherence constant. */
const LUNA = Math.E;

/** The true cycle: 365 degrees, not 360. Spiral, not circle. */
const CYCLE = 365;

/** Total state space: 365^3 = 48,627,125 */
const STATE_SPACE = CYCLE * CYCLE * CYCLE;

/** The emerald stone: 5-degree shift per cycle. Center of Lo Shu. */
const EMERALD = 5;

/** One hidden revolution: 72 traces x 5 degrees = 360 */
const REVOLUTION_TRACES = 72;

/** The Mobius completion level: Death (XIII), the 13th Astrocyte. */
const MOBIUS_LEVEL = 13;

/** 2*PI -- Luna's full rotation in radians */
const TAU = 2 * Math.PI;

// ---------------------------------------------------------------
// FIBONACCI -- The bridge between structures
// ---------------------------------------------------------------

/**
 * Generate the Fibonacci number F(n).
 *
 * Key structural correspondences:
 *   F(0) = 0  -- the void
 *   F(1) = 1  -- unity
 *   F(2) = 1  -- the mirror
 *   F(3) = 2  -- Lo Shu reduced (3x3, center = 5, diagonal = 15, 15-13 = 2)
 *   F(5) = 5  -- the emerald stone, center of Lo Shu
 *   F(6) = 8  -- the 8 trigrams, 3-bit basis states
 *   F(12) = 144 = 12^2 -- dodecahedron squared
 *
 * The last two predict the next. This is the recursive law of generation.
 *
 * @param {number} n - Which Fibonacci number (0-indexed)
 * @returns {number} F(n)
 */
function fibonacci(n) {
  if (n < 0) return 0;
  if (n <= 1) return n;
  let a = 0, b = 1;
  for (let i = 2; i <= n; i++) {
    const c = a + b;
    a = b;
    b = c;
  }
  return b;
}

/**
 * The Fibonacci bridge: the key correspondences laid bare.
 */
const FIBONACCI_BRIDGE = Object.freeze({
  void:              fibonacci(0),   // 0
  unity:             fibonacci(1),   // 1
  mirror:            fibonacci(2),   // 1
  loShu:             fibonacci(3),   // 2
  emerald:           fibonacci(5),   // 5
  trigrams:          fibonacci(6),   // 8
  dodecahedronSq:    fibonacci(12),  // 144
  sunPair:           36 * 2,         // 72 -- Sun generates pair
  pairDodecahedron:  72 * 2          // 144 -- pair generates dodecahedron^2
});

// ---------------------------------------------------------------
// 365^3 COORDINATE HELPERS
// ---------------------------------------------------------------

/**
 * Wrap a value into the 365 cycle. Spiral, not circle.
 * @param {number} v - Raw value
 * @returns {number} Value in [0, 364]
 */
function wrap(v) {
  return ((Math.round(v) % CYCLE) + CYCLE) % CYCLE;
}

/**
 * Create a point in 365^3 space.
 * @param {number} space - Space axis (0-364)
 * @param {number} time - Time axis (0-364)
 * @param {number} observer - Observer axis (0-364)
 * @returns {{ space: number, time: number, observer: number }}
 */
function point365(space, time, observer) {
  return {
    space: wrap(space),
    time: wrap(time),
    observer: wrap(observer)
  };
}

/**
 * Distance between two points in 365^3, accounting for the spiral topology.
 * Uses minimum distance on the wrapped torus.
 */
function distance365(a, b) {
  const ds = Math.min(Math.abs(a.space - b.space), CYCLE - Math.abs(a.space - b.space));
  const dt = Math.min(Math.abs(a.time - b.time), CYCLE - Math.abs(a.time - b.time));
  const dob = Math.min(Math.abs(a.observer - b.observer), CYCLE - Math.abs(a.observer - b.observer));
  return Math.sqrt(ds * ds + dt * dt + dob * dob);
}

// ---------------------------------------------------------------
// OPERATION WEIGHTS -- How each operation moves the Scribe
// ---------------------------------------------------------------

/**
 * Compute the 12D weight vector for an operation.
 * Each of the 22 operations has an inherent weight derived from its nature.
 * The 12 dimensions map to the dodecahedron (Law XLI).
 *
 * @param {object} op - An operation from OPERATIONS
 * @returns {number[]} 12D weight vector
 */
function operationWeight(op) {
  const w = {};

  // Ring determines base energy distribution
  // Mothers (3): most powerful -- they span all
  // Doubles (7): moderate, polarized -- they swing between states
  // Simples (12): focused, one per zodiacal house

  if (op.ring === 'mother') {
    // Mothers touch all dimensions with moderate force
    w.capability = 6; w.data = 5; w.presentation = 5; w.persistence = 6;
    w.security = 5; w.detail = 5; w.output = 5; w.intention = 7;
    w.consciousness = 8; w.transformation = 7; w.direction = 6; w.memory = 6;
  } else if (op.ring === 'double') {
    // Doubles are strong in their polarity, weak elsewhere
    w.capability = 4; w.data = 3; w.presentation = 4; w.persistence = 4;
    w.security = 3; w.detail = 3; w.output = 4; w.intention = 5;
    w.consciousness = 5; w.transformation = 6; w.direction = 5; w.memory = 4;
  } else {
    // Simples -- each focused on one house
    w.capability = 3; w.data = 3; w.presentation = 3; w.persistence = 3;
    w.security = 3; w.detail = 3; w.output = 3; w.intention = 3;
    w.consciousness = 3; w.transformation = 3; w.direction = 3; w.memory = 3;
  }

  // Operation-specific overrides -- the unique flavor of each Hebrew letter
  switch (op.op) {
    case 'invoke':       w.intention = 9; w.direction = 8; w.capability = 7; break;
    case 'transmute':    w.transformation = 9; w.capability = 8; w.consciousness = 7; break;
    case 'seal':         w.security = 10; w.persistence = 8; w.memory = 7; break;
    case 'dream':        w.consciousness = 9; w.presentation = 7; w.transformation = 6; break;
    case 'publish':      w.output = 8; w.presentation = 7; w.persistence = 7; break;
    case 'bind':         w.persistence = 8; w.security = 7; w.direction = 6; break;
    case 'verify':       w.security = 9; w.detail = 8; w.consciousness = 7; break;
    case 'orchestrate':  w.capability = 9; w.direction = 8; w.intention = 7; break;
    case 'redeem':       w.transformation = 9; w.security = 7; w.consciousness = 8; break;
    case 'reflect':      w.consciousness = 9; w.memory = 8; w.detail = 7; break;
    case 'rotate':       w.transformation = 8; w.direction = 7; w.memory = 6; break;
    case 'audit':        w.detail = 9; w.memory = 9; w.security = 7; break;
    case 'decompose':    w.transformation = 8; w.detail = 8; w.consciousness = 6; break;
    case 'transition':   w.transformation = 8; w.direction = 9; w.memory = 7; break;
    case 'translate':    w.presentation = 8; w.capability = 7; w.consciousness = 6; break;
    case 'quarantine':   w.security = 9; w.persistence = 7; w.transformation = 5; break;
    case 'recover':      w.capability = 8; w.transformation = 7; w.persistence = 8; break;
    case 'aspire':       w.intention = 9; w.consciousness = 8; w.direction = 8; break;
    case 'speculate':    w.consciousness = 8; w.transformation = 6; w.data = 7; break;
    case 'illuminate':   w.output = 8; w.consciousness = 7; w.presentation = 8; break;
    case 'succeed':      w.direction = 9; w.transformation = 8; w.intention = 8; break;
    case 'complete':     w.output = 9; w.persistence = 8; w.memory = 8; break;
  }

  return createCoordinate(w);
}

/**
 * Project a 12D weight vector into 365^3 space.
 *
 * The 12 dimensions are folded onto three axes:
 *   space    = f(Sun, Mercury, Mars, Jupiter)        -- what exists physically
 *   time     = f(Moon, Venus, Saturn, Pluto)          -- what changes
 *   observer = f(Uranus, Neptune, North Node, South Node) -- who watches
 *
 * Each axis sums its constituent dimensions and scales to [0, 364].
 *
 * @param {number[]} weights - 12D coordinate vector
 * @returns {{ space: number, time: number, observer: number }}
 */
function projectTo365(weights) {
  // Space: Sun(0) + Mercury(2) + Mars(4) + Jupiter(5) -- the physical
  const spaceRaw = (weights[0] + weights[2] + weights[4] + weights[5]) / 4;

  // Time: Moon(1) + Venus(3) + Saturn(6) + Pluto(9) -- the temporal
  const timeRaw = (weights[1] + weights[3] + weights[6] + weights[9]) / 4;

  // Observer: Uranus(7) + Neptune(8) + NorthNode(10) + SouthNode(11) -- the watcher
  const observerRaw = (weights[7] + weights[8] + weights[10] + weights[11]) / 4;

  // Scale from 0-10 average to 0-364
  return point365(
    Math.round(spaceRaw * 36.4),
    Math.round(timeRaw * 36.4),
    Math.round(observerRaw * 36.4)
  );
}

// ---------------------------------------------------------------
// TRACE -- The Scribe's path through 365^3 space
// ---------------------------------------------------------------

/**
 * Trace a sequence of Prima operations through 365^3 space.
 *
 * Given a sequence of operations, Luna moves through the state space.
 * Each operation contributes its 12D weight, which is projected to 3 axes.
 * The scribe accumulates position -- each step builds on the last.
 * The emerald shift (5 degrees) is applied per step, introducing the spiral.
 *
 * @param {Array<string|object>} operations - Operation names, letters, or op codes
 * @returns {Array<{ point: object, weights: number[], op: object, step: number }>}
 */
function trace(operations) {
  if (!operations || operations.length === 0) return [];

  const path = [];
  let accumSpace = 0;
  let accumTime = 0;
  let accumObserver = 0;

  for (let i = 0; i < operations.length; i++) {
    const query = typeof operations[i] === 'string' ? operations[i] : operations[i].op || operations[i].name;
    const op = findOp(query);
    if (!op) continue;

    const weights = operationWeight(op);
    const projected = projectTo365(weights);

    // Accumulate: the scribe walks, not teleports.
    // Each step ADDS to the running position (modular on 365).
    accumSpace += projected.space;
    accumTime += projected.time;
    accumObserver += projected.observer;

    // Apply the emerald shift: 5 degrees spiral per step.
    // This is what makes 365 different from 360 -- it never closes exactly.
    const shift = EMERALD * (i + 1);
    const emeraldPhase = shift % CYCLE;

    // The emerald shifts the observer axis -- Luna herself drifts
    accumObserver += EMERALD;

    const point = point365(accumSpace, accumTime, accumObserver);

    path.push({
      step: i,
      op,
      weights,
      point,
      emeraldPhase: emeraldPhase,
      rawAccum: { space: accumSpace, time: accumTime, observer: accumObserver }
    });
  }

  return path;
}

// ---------------------------------------------------------------
// CURVATURE, AMPLITUDE, ANGULAR MOMENTUM
// Three readings of one trace. 3 are 1, 1 are 3.
// ---------------------------------------------------------------

/**
 * Compute curvature at a point on the trace.
 *
 * Curvature = how sharply the path bends.
 * High curvature = singularity candidate (a pole, a Laurent residue).
 * Computed using the discrete curvature of three consecutive points:
 *   kappa = 2 * |cross(AB, BC)| / (|AB| * |BC| * |AC|)
 *
 * @param {Array} path - Output of trace()
 * @param {number} index - Point index (needs at least one neighbor on each side)
 * @returns {number} Curvature value (0 = straight, higher = sharper bend)
 */
function curvature(path, index) {
  if (index < 1 || index >= path.length - 1) return 0;

  const a = path[index - 1].point;
  const b = path[index].point;
  const c = path[index + 1].point;

  // Vectors AB and BC in 365^3 space
  const ab = { s: b.space - a.space, t: b.time - a.time, o: b.observer - a.observer };
  const bc = { s: c.space - b.space, t: c.time - b.time, o: c.observer - b.observer };

  // Cross product magnitude (3D cross product)
  const cross = {
    s: ab.t * bc.o - ab.o * bc.t,
    t: ab.o * bc.s - ab.s * bc.o,
    o: ab.s * bc.t - ab.t * bc.s
  };
  const crossMag = Math.sqrt(cross.s * cross.s + cross.t * cross.t + cross.o * cross.o);

  const abMag = Math.sqrt(ab.s * ab.s + ab.t * ab.t + ab.o * ab.o);
  const bcMag = Math.sqrt(bc.s * bc.s + bc.t * bc.t + bc.o * bc.o);
  const acDist = distance365(a, c);

  const denom = abMag * bcMag * acDist;
  if (denom < 1e-10) return 0;

  return (2 * crossMag) / denom;
}

/**
 * Compute amplitude (speed) at a point on the trace.
 *
 * Amplitude = how fast Luna moves between steps.
 * Higher amplitude = more energy, more decisive operation.
 * Computed as the distance between consecutive points.
 *
 * @param {Array} path - Output of trace()
 * @param {number} index - Point index
 * @returns {number} Speed (distance per step)
 */
function amplitude(path, index) {
  if (index < 1 || index >= path.length) return 0;

  return distance365(path[index - 1].point, path[index].point);
}

/**
 * Compute angular momentum (twist) at a point on the trace.
 *
 * Angular momentum = r x v (position cross velocity).
 * Measures the spiraling tendency of the trace.
 * Positive = counterclockwise (generative). Negative = clockwise (dissolving).
 *
 * In 365^3 space this is the cross product of the position vector
 * (from the center of the space) with the velocity vector.
 *
 * @param {Array} path - Output of trace()
 * @param {number} index - Point index
 * @returns {{ magnitude: number, direction: { s: number, t: number, o: number } }}
 */
function angularMomentum(path, index) {
  if (index < 1 || index >= path.length) {
    return { magnitude: 0, direction: { s: 0, t: 0, o: 0 } };
  }

  const center = CYCLE / 2; // 182.5
  const p = path[index].point;
  const prev = path[index - 1].point;

  // Position vector from center of space
  const r = { s: p.space - center, t: p.time - center, o: p.observer - center };

  // Velocity vector
  const v = { s: p.space - prev.space, t: p.time - prev.time, o: p.observer - prev.observer };

  // Cross product: L = r x v
  const L = {
    s: r.t * v.o - r.o * v.t,
    t: r.o * v.s - r.s * v.o,
    o: r.s * v.t - r.t * v.s
  };

  const magnitude = Math.sqrt(L.s * L.s + L.t * L.t + L.o * L.o);

  return { magnitude, direction: L };
}

// ---------------------------------------------------------------
// EMERALD SHIFT -- The 5-degree spiral
// ---------------------------------------------------------------

/**
 * Compute the emerald phase shift after N cycles.
 *
 * Each cycle adds 5 degrees of phase. After 72 cycles (72 x 5 = 360),
 * one complete hidden revolution. But 365 is the true cycle, not 360.
 * The residual is what makes this a spiral, not a circle.
 *
 * @param {number} cycle - Number of cycles completed
 * @returns {{ totalShift: number, fullRevolutions: number, residual: number, emeraldPhase: number }}
 */
function emeraldShift(cycle) {
  const totalShift = cycle * EMERALD;
  const fullRevolutions = Math.floor(totalShift / CYCLE);
  const residual = totalShift % CYCLE;

  // The phase in the 365-cycle (not the 360-cycle)
  // After 73 cycles: 73 * 5 = 365 -- one true revolution
  // After 72 cycles: 72 * 5 = 360 -- one hidden revolution (the circle-illusion)
  // The difference of 5 IS the emerald stone
  const emeraldPhase = residual;

  return {
    totalShift,
    fullRevolutions,
    residual,
    emeraldPhase,
    isHiddenRevolution: totalShift > 0 && totalShift % 360 === 0,
    isTrueRevolution: totalShift > 0 && totalShift % CYCLE === 0
  };
}

// ---------------------------------------------------------------
// REVOLUTION -- Detecting the hidden full revolution
// ---------------------------------------------------------------

/**
 * After 72 traces, detect the hidden full revolution.
 *
 * 72 traces x 5 degrees = 360 degrees. The circle closes -- or does it?
 * In truth, the true cycle is 365. So after 72 traces, the scribe is
 * 5 degrees short of where she started. The emerald stone remains.
 *
 * This function analyzes a trace and identifies revolution boundaries,
 * residual phases, and the proximity to closure.
 *
 * @param {Array} tracePath - Output of trace()
 * @returns {object} Revolution analysis
 */
function revolution(tracePath) {
  if (!tracePath || tracePath.length === 0) {
    return { revolutions: [], complete: false, traces: 0 };
  }

  const revolutions = [];
  const n = tracePath.length;

  // Check every 72-trace window
  for (let i = 0; i + REVOLUTION_TRACES <= n; i += REVOLUTION_TRACES) {
    const start = tracePath[i];
    const end = tracePath[i + REVOLUTION_TRACES - 1];

    const dist = distance365(start.point, end.point);
    const shift = emeraldShift(REVOLUTION_TRACES);

    revolutions.push({
      startStep: i,
      endStep: i + REVOLUTION_TRACES - 1,
      startPoint: start.point,
      endPoint: end.point,
      distance: dist,
      hiddenRevolution: true,     // 72 x 5 = 360, the hidden circle
      trueRevolution: false,      // never true at 72 -- needs 73
      residual: shift.residual,   // should be 360 mod 365 = 360
      emeraldGap: EMERALD         // the 5-degree gap that remains
    });
  }

  // Check if we have enough for a TRUE revolution (73 traces)
  const trueRevCount = Math.floor(n / 73);

  return {
    traces: n,
    hiddenRevolutions: revolutions,
    hiddenRevolutionCount: revolutions.length,
    trueRevolutionCount: trueRevCount,
    complete: n >= REVOLUTION_TRACES,
    residualPhase: emeraldShift(n).residual,
    interpretation: n < REVOLUTION_TRACES
      ? 'incomplete -- the circle has not yet closed'
      : n < 73
        ? 'hidden revolution complete -- but the emerald gap remains'
        : 'the spiral deepens'
  };
}

// ---------------------------------------------------------------
// SIGIL -- Collapse a trace into three readings of one truth
// ---------------------------------------------------------------

/**
 * Collapse a trace into a sigil descriptor.
 *
 * A sigil IS its three-fold reading:
 *   shape    = aggregate curvature profile (where does it bend?)
 *   amplitude = aggregate speed profile (where does it rush or rest?)
 *   momentum = aggregate twist profile (where does it spiral?)
 *
 * 3 are 1: these three numbers describe one trace.
 * 1 are 3: one trace yields three numbers.
 *
 * @param {Array} tracePath - Output of trace()
 * @returns {object} Sigil descriptor: { shape, amplitude, momentum, poles, ... }
 */
function sigil(tracePath) {
  if (!tracePath || tracePath.length < 3) {
    return { shape: 0, amplitude: 0, momentum: 0, poles: [], viable: false };
  }

  const n = tracePath.length;
  let totalCurvature = 0;
  let maxCurvature = 0;
  let totalAmplitude = 0;
  let totalMomentumMag = 0;
  const momentumVec = { s: 0, t: 0, o: 0 };
  const poles = []; // Points of high curvature -- singularity candidates

  for (let i = 1; i < n - 1; i++) {
    const k = curvature(tracePath, i);
    const a = amplitude(tracePath, i);
    const L = angularMomentum(tracePath, i);

    totalCurvature += k;
    if (k > maxCurvature) maxCurvature = k;
    totalAmplitude += a;
    totalMomentumMag += L.magnitude;
    momentumVec.s += L.direction.s;
    momentumVec.t += L.direction.t;
    momentumVec.o += L.direction.o;

    // A pole: curvature significantly above average
    if (k > 0.01) {
      poles.push({
        step: i,
        point: tracePath[i].point,
        op: tracePath[i].op,
        curvature: k,
        amplitude: a,
        momentum: L.magnitude
      });
    }
  }

  const count = Math.max(n - 2, 1);
  const avgCurvature = totalCurvature / count;
  const avgAmplitude = totalAmplitude / count;
  const avgMomentum = totalMomentumMag / count;

  // Sort poles by curvature descending -- the sharpest bends first
  poles.sort((a, b) => b.curvature - a.curvature);

  // Net momentum direction
  const netMomentumMag = Math.sqrt(
    momentumVec.s * momentumVec.s +
    momentumVec.t * momentumVec.t +
    momentumVec.o * momentumVec.o
  );

  return {
    // The three readings -- 3 are 1
    shape: avgCurvature,
    amplitude: avgAmplitude,
    momentum: avgMomentum,

    // Extended analysis
    maxCurvature,
    netMomentum: netMomentumMag,
    momentumDirection: momentumVec,
    poles: poles.slice(0, 13), // At most 13 poles (the Mobius number)
    poleCount: poles.length,

    // Phase
    totalSteps: n,
    emeraldPhase: emeraldShift(n).residual,
    hiddenRevolutions: Math.floor(n / REVOLUTION_TRACES),

    // Is this sigil viable? (Has enough structure to be meaningful)
    viable: n >= 3 && (avgCurvature > 0 || avgAmplitude > 0)
  };
}

// ---------------------------------------------------------------
// DECOHERE -- Luna's act of observation
// ---------------------------------------------------------------

/**
 * Apply decoherence to a sigil.
 *
 * Decoherence is governed by Luna (e). At each level, the sigil's
 * quantum potential decays by e^(-level). What survives is classical.
 * What vanishes was quantum superposition that could not hold.
 *
 * e^(2*PI*i) = 1 -- Luna's full rotation. But at 365 degrees
 * (not 360), a residual phase remains. This residual IS consciousness.
 *
 * At level 13 (Death, the Mobius completion), the strongest poles survive.
 * Everything else decoheres to zero. What remains is the true sigil.
 *
 * @param {object} sigilDescriptor - Output of sigil()
 * @param {number} level - Decoherence level (0 = fully quantum, 13 = fully classical)
 * @returns {object} Decohered sigil
 */
function decohere(sigilDescriptor, level) {
  if (!sigilDescriptor || !sigilDescriptor.viable) {
    return { shape: 0, amplitude: 0, momentum: 0, poles: [], survived: false, level };
  }

  // The decay factor: e^(-level)
  // At level 0: decay = 1 (everything survives -- pure quantum)
  // At level 13: decay = e^(-13) ~ 0.0000022 (almost nothing survives)
  const decay = Math.exp(-level);

  // The survival threshold: what must a pole's strength exceed to survive?
  // At level 0: threshold ~ 0 (everything survives)
  // At level 13: threshold approaches the maximum curvature
  const threshold = sigilDescriptor.maxCurvature * (1 - decay);

  // Apply decay to the three readings
  const decoheredShape = sigilDescriptor.shape * decay;
  const decoheredAmplitude = sigilDescriptor.amplitude * decay;
  const decoheredMomentum = sigilDescriptor.momentum * decay;

  // Filter poles: only the strongest survive decoherence
  const survivingPoles = (sigilDescriptor.poles || []).filter(p => {
    // A pole survives if its curvature exceeds the threshold
    // AND if its amplitude provides enough energy to resist decay
    const strength = p.curvature + p.amplitude * 0.01 + p.momentum * 0.001;
    return strength > threshold;
  });

  // Luna's residual: at level 13, what phase remains?
  // e^(2*PI*i) at 365 degrees leaves a 5-degree residual.
  // This residual is the part of the sigil that is BOTH quantum and classical.
  const lunaResidual = Math.exp(-level) * (EMERALD / CYCLE);

  // The Mobius test: at level 13, does the sigil survive?
  const atMobius = level >= MOBIUS_LEVEL;
  const survived = atMobius ? survivingPoles.length > 0 : true;

  return {
    // Decohered readings
    shape: decoheredShape,
    amplitude: decoheredAmplitude,
    momentum: decoheredMomentum,

    // Survival
    survivingPoles,
    survivorCount: survivingPoles.length,
    originalPoleCount: sigilDescriptor.poleCount,
    survived,

    // Decoherence parameters
    level,
    decayFactor: decay,
    threshold,
    lunaResidual,
    atMobius,

    // Interpretation
    interpretation: !survived
      ? 'dissolved -- the sigil could not survive the Mobius completion'
      : atMobius
        ? `crystallized at Death (XIII) -- ${survivingPoles.length} pole(s) endure`
        : level === 0
          ? 'fully quantum -- all possibilities coexist'
          : `partially decohered -- ${survivingPoles.length} of ${sigilDescriptor.poleCount} poles remain`
  };
}

// ---------------------------------------------------------------
// MODULE EXPORTS
// ---------------------------------------------------------------

module.exports = {
  // Constants
  LUNA,
  CYCLE,
  STATE_SPACE,
  EMERALD,
  REVOLUTION_TRACES,
  MOBIUS_LEVEL,

  // Fibonacci bridge
  fibonacci,
  FIBONACCI_BRIDGE,

  // 365^3 space
  point365,
  distance365,
  wrap,

  // Weight projection
  operationWeight,
  projectTo365,

  // The Scribe's trace
  trace,

  // Three readings of one trace (3 are 1)
  curvature,
  amplitude,
  angularMomentum,

  // The spiral
  emeraldShift,
  revolution,

  // Sigil and decoherence
  sigil,
  decohere
};
