/**
 * L7 Dodecahedron — 12+1 Dimensional Coordinate System
 * Law XLI — The hypergraph is 12-sided
 * Law XLVIII — The Astrocyte: the 13th variable
 *
 * Every citizen, every artifact, every task is a point in 12D space.
 * The 12 dimensions are the 12 faces of the Platonic dodecahedron.
 * Each maps to a planetary correspondence.
 *
 * The Astrocyte is the 13th variable — not a 13th axis, but the
 * observer that makes all 12 axes probabilistic. Like dark matter
 * shapes visible galaxies without being visible itself, the astrocyte
 * determines how each dimension BEHAVES without appearing on any axis.
 *
 * At astrocyte=0: coordinates are fixed, deterministic, classical.
 * At astrocyte=1: coordinates are fluid, probabilistic, quantum.
 *
 * Named for brain astrocytes — glial cells that don't fire signals
 * themselves but modulate every neural connection around them.
 */

const DIMENSIONS = Object.freeze([
  { index: 0,  planet: 'Sun',        symbol: '☉', name: 'capability',     ring: 'classical', question: 'What does it do?' },
  { index: 1,  planet: 'Moon',       symbol: '☽', name: 'data',           ring: 'classical', question: 'What kind of information?' },
  { index: 2,  planet: 'Mercury',    symbol: '☿', name: 'presentation',   ring: 'classical', question: 'How does it appear?' },
  { index: 3,  planet: 'Venus',      symbol: '♀', name: 'persistence',    ring: 'classical', question: 'How long does it live?' },
  { index: 4,  planet: 'Mars',       symbol: '♂', name: 'security',       ring: 'classical', question: 'Who can access it?' },
  { index: 5,  planet: 'Jupiter',    symbol: '♃', name: 'detail',         ring: 'classical', question: 'How granular?' },
  { index: 6,  planet: 'Saturn',     symbol: '♄', name: 'output',         ring: 'classical', question: 'What form are results?' },
  { index: 7,  planet: 'Uranus',     symbol: '♅', name: 'intention',      ring: 'transpersonal', question: 'What is the will behind it?' },
  { index: 8,  planet: 'Neptune',    symbol: '♆', name: 'consciousness',  ring: 'transpersonal', question: 'How aware is it?' },
  { index: 9,  planet: 'Pluto',      symbol: '♇', name: 'transformation', ring: 'transpersonal', question: 'How deeply does it change things?' },
  { index: 10, planet: 'North Node', symbol: '☊', name: 'direction',      ring: 'transpersonal', question: 'Where is it heading?' },
  { index: 11, planet: 'South Node', symbol: '☋', name: 'memory',         ring: 'transpersonal', question: 'Where did it come from?' }
]);

// Zodiacal qualities — the 12 behavioral archetypes (one per face)
const ZODIAC = Object.freeze([
  { sign: 'Aries',       symbol: '♈', quality: 'initiative',   element: 'fire',  mode: 'cardinal' },
  { sign: 'Taurus',      symbol: '♉', quality: 'substance',    element: 'earth', mode: 'fixed' },
  { sign: 'Gemini',      symbol: '♊', quality: 'duality',      element: 'air',   mode: 'mutable' },
  { sign: 'Cancer',      symbol: '♋', quality: 'containment',  element: 'water', mode: 'cardinal' },
  { sign: 'Leo',         symbol: '♌', quality: 'expression',   element: 'fire',  mode: 'fixed' },
  { sign: 'Virgo',       symbol: '♍', quality: 'analysis',     element: 'earth', mode: 'mutable' },
  { sign: 'Libra',       symbol: '♎', quality: 'balance',      element: 'air',   mode: 'cardinal' },
  { sign: 'Scorpio',     symbol: '♏', quality: 'depth',        element: 'water', mode: 'fixed' },
  { sign: 'Sagittarius', symbol: '♐', quality: 'expansion',    element: 'fire',  mode: 'mutable' },
  { sign: 'Capricorn',   symbol: '♑', quality: 'structure',    element: 'earth', mode: 'cardinal' },
  { sign: 'Aquarius',    symbol: '♒', quality: 'innovation',   element: 'air',   mode: 'fixed' },
  { sign: 'Pisces',      symbol: '♓', quality: 'dissolution',  element: 'water', mode: 'mutable' }
]);

/**
 * Create a 12D coordinate vector.
 * Each value is 0-10, representing intensity on that dimension.
 */
function createCoordinate(values = {}) {
  const coord = new Array(12).fill(0);
  for (const [key, val] of Object.entries(values)) {
    const dim = DIMENSIONS.find(d => d.name === key);
    if (dim) {
      coord[dim.index] = Math.max(0, Math.min(10, Number(val) || 0));
    }
  }
  return coord;
}

/**
 * Calculate Euclidean distance between two 12D coordinates.
 * Lower distance = more similar.
 */
function distance(a, b) {
  let sum = 0;
  for (let i = 0; i < 12; i++) {
    sum += (a[i] - b[i]) ** 2;
  }
  return Math.sqrt(sum);
}

/**
 * Calculate weighted cosine similarity between two 12D coordinates.
 * Returns 0-1 where 1 = identical direction.
 */
function similarity(a, b) {
  let dotProduct = 0, magA = 0, magB = 0;
  for (let i = 0; i < 12; i++) {
    dotProduct += a[i] * b[i];
    magA += a[i] ** 2;
    magB += b[i] ** 2;
  }
  magA = Math.sqrt(magA);
  magB = Math.sqrt(magB);
  if (magA === 0 || magB === 0) return 0;
  return dotProduct / (magA * magB);
}

/**
 * Find the dominant dimension(s) in a coordinate.
 * Returns array of { dimension, value } sorted by intensity descending.
 */
function dominantDimensions(coord, threshold = 7) {
  return coord
    .map((val, i) => ({ dimension: DIMENSIONS[i], value: val }))
    .filter(d => d.value >= threshold)
    .sort((a, b) => b.value - a.value);
}

/**
 * Determine the zodiacal quality of a coordinate.
 * Based on which dimension is strongest and its element/mode.
 */
function zodiacalQuality(coord) {
  const dominant = dominantDimensions(coord, 0)[0];
  if (!dominant) return ZODIAC[0];
  return ZODIAC[dominant.dimension.index % 12];
}

/**
 * Create an edge weight between two operations.
 * An edge is a 12D vector describing HOW two operations relate.
 */
function createEdge(from, to, weights = {}) {
  return {
    from,
    to,
    weights: createCoordinate(weights),
    dominant: dominantDimensions(createCoordinate(weights)),
    created: new Date().toISOString()
  };
}

/**
 * Score a task against a coordinate profile.
 * Returns a relevance score 0-1.
 */
function score(taskCoord, profileCoord) {
  return similarity(taskCoord, profileCoord);
}

/**
 * Derive a coordinate from a tool definition (.tool file).
 * Maps the tool's declared properties to 12D weights.
 */
function fromTool(tool) {
  const coord = {};

  // Capability — what it does
  const capMap = { analyze: 7, render: 6, communicate: 5, automate: 8, data: 4 };
  coord.capability = capMap[tool.does] || 5;

  // Data — PII and data type indicators
  coord.data = tool.pii ? 8 : 4;

  // Presentation — output format
  const presMap = { json: 3, html: 7, text: 5, csv: 4, binary: 2 };
  coord.presentation = presMap[tool.output] || 5;

  // Persistence — execution mode
  const persMap = { once: 3, batch: 6, stream: 9 };
  coord.persistence = persMap[tool.runs] || 5;

  // Security — approval requirement
  coord.security = tool.approval ? 8 : 3;

  // Detail — output granularity
  coord.detail = 5;

  // Output — structure
  coord.output = tool.output === 'json' ? 7 : 5;

  // Intention — derived from description
  coord.intention = 5;

  // Consciousness — audit awareness
  coord.consciousness = tool.audit ? 7 : 3;

  // Transformation — how much it changes things
  const transMap = { analyze: 3, render: 5, communicate: 4, automate: 7, data: 2 };
  coord.transformation = transMap[tool.does] || 5;

  // Direction — version trajectory
  coord.direction = 5;

  // Memory — lineage
  coord.memory = tool.version ? 6 : 3;

  return createCoordinate(coord);
}

// ═══════════════════════════════════════════════════════════
// THE ASTROCYTE — The 13th Variable (Law XLVIII)
// ═══════════════════════════════════════════════════════════

/**
 * The Astrocyte is a meta-variable (0 to 1) that wraps all 12 dimensions.
 * It doesn't add a 13th axis — it determines the CERTAINTY of every value
 * on all 12 axes. When astrocyte = 0, values are deterministic. When
 * astrocyte = 1, each value is the center of a wide probability distribution.
 *
 * This enables:
 * - Probabilistic tool routing (tools have uncertainty about their nature)
 * - Fuzzy matching (similar coordinates overlap more at high astrocyte)
 * - Dynamic evolution (coordinates drift over time proportional to astrocyte)
 * - Gambling/random system modeling (astrocyte IS the entropy source)
 *
 * The astrocyte maps to brain glial cells: they don't fire action potentials,
 * but they modulate the strength of every synapse around them. Dark matter
 * for the neural universe.
 */

const ASTROCYTE = Object.freeze({
  name: 'astrocyte',
  symbol: '✦',
  range: [0, 1],
  description: 'The meta-variable. Determines certainty vs uncertainty across all dimensions.',
  correspondences: {
    neuroscience: 'Astrocyte glial cells — modulate all synaptic connections',
    physics: 'Dark matter — shapes visible structure without being visible',
    quantum: 'The observer — measurement collapses probability into value',
    alchemy: 'The Quintessence — the fifth element that permeates the other four',
    kabbalah: 'Ain Soph — the limitless, before manifestation'
  }
});

/**
 * Create a probabilistic coordinate — a 12D vector with an astrocyte value.
 *
 * @param {Array|object} values - 12D coordinate (array or named object)
 * @param {number} astrocyte - Meta-variable 0-1 (default 0 = deterministic)
 * @returns {object} Probabilistic coordinate { values, astrocyte, sample(), ... }
 */
function createProbabilistic(values, astrocyte = 0) {
  const coord = Array.isArray(values) ? values : createCoordinate(values);
  const a = Math.max(0, Math.min(1, Number(astrocyte) || 0));

  return {
    values: coord,
    astrocyte: a,
    type: 'probabilistic',

    /**
     * Sample a concrete coordinate from the probability distribution.
     * Each dimension's value is the mean; astrocyte controls the spread.
     * At astrocyte=0, returns the exact mean. At astrocyte=1, wide variance.
     */
    sample() {
      if (a === 0) return [...coord];
      return coord.map(mean => {
        const spread = a * 3; // max ±3 at astrocyte=1
        const u1 = Math.random();
        const u2 = Math.random();
        // Box-Muller transform for gaussian noise
        const noise = Math.sqrt(-2 * Math.log(u1 || 0.001)) * Math.cos(2 * Math.PI * u2);
        return Math.max(0, Math.min(10, Math.round(mean + noise * spread)));
      });
    },

    /**
     * Sample N times and return all results.
     * Useful for Monte Carlo analysis of tool routing.
     */
    sampleN(n) {
      const samples = [];
      for (let i = 0; i < n; i++) samples.push(this.sample());
      return samples;
    },

    /**
     * The entropy of this coordinate in bits.
     * Higher astrocyte = higher entropy = more uncertainty.
     */
    entropy() {
      // Each of 12 dimensions has entropy proportional to spread
      // At astrocyte=0, entropy=0. At astrocyte=1, max entropy.
      const dimEntropy = a > 0 ? Math.log2(1 + a * 10) : 0;
      return dimEntropy * 12;
    },

    /**
     * Standard deviation per dimension.
     */
    sigma() {
      return a * 3;
    },

    /**
     * Probability that a sampled value on dimension `dim` falls within `range`.
     * Uses the error function approximation for the gaussian CDF.
     */
    probability(dimIndex, low, high) {
      if (a === 0) {
        return (coord[dimIndex] >= low && coord[dimIndex] <= high) ? 1 : 0;
      }
      const mean = coord[dimIndex];
      const sigma = a * 3;
      // Approximate using cumulative normal distribution
      const cdfHigh = normalCDF((high - mean) / sigma);
      const cdfLow = normalCDF((low - mean) / sigma);
      return cdfHigh - cdfLow;
    },

    /**
     * Expected similarity to another coordinate, accounting for uncertainty.
     * Runs Monte Carlo sampling when astrocyte > 0.
     */
    expectedSimilarity(other, samples = 50) {
      const otherCoord = other.type === 'probabilistic' ? other : { values: other, astrocyte: 0, sample() { return [...this.values]; } };
      if (a === 0 && otherCoord.astrocyte === 0) {
        return similarity(coord, otherCoord.values);
      }
      let totalSim = 0;
      for (let i = 0; i < samples; i++) {
        totalSim += similarity(this.sample(), otherCoord.sample ? otherCoord.sample() : otherCoord.values);
      }
      return totalSim / samples;
    },

    /**
     * Collapse: like quantum measurement, produce a single deterministic
     * coordinate from the probability field. The astrocyte goes to 0.
     * Once collapsed, the coordinate is fixed.
     */
    collapse() {
      const sampled = this.sample();
      return createProbabilistic(sampled, 0);
    },

    /**
     * Evolve: let the coordinate drift over time.
     * Higher astrocyte = more drift per step.
     */
    evolve(steps = 1) {
      let current = [...coord];
      for (let s = 0; s < steps; s++) {
        current = current.map(v => {
          const drift = (Math.random() - 0.5) * 2 * a;
          return Math.max(0, Math.min(10, Math.round(v + drift)));
        });
      }
      return createProbabilistic(current, a);
    },

    /**
     * The dominant dimensions, accounting for uncertainty.
     * Returns dimensions that are RELIABLY dominant (high mean, low relative uncertainty).
     */
    reliableDominants(threshold = 7) {
      return coord
        .map((val, i) => ({
          dimension: DIMENSIONS[i],
          value: val,
          reliability: val > 0 ? Math.max(0, 1 - (a * 3 / val)) : 0
        }))
        .filter(d => d.value >= threshold)
        .sort((a, b) => (b.value * b.reliability) - (a.value * a.reliability));
    }
  };
}

/**
 * Normal CDF approximation (Abramowitz & Stegun).
 */
function normalCDF(x) {
  const a1 = 0.254829592, a2 = -0.284496736, a3 = 1.421413741;
  const a4 = -1.453152027, a5 = 1.061405429, p = 0.3275911;
  const sign = x < 0 ? -1 : 1;
  x = Math.abs(x) / Math.sqrt(2);
  const t = 1.0 / (1.0 + p * x);
  const y = 1.0 - (((((a5 * t + a4) * t) + a3) * t + a2) * t + a1) * t * Math.exp(-x * x);
  return 0.5 * (1.0 + sign * y);
}

/**
 * Infer an astrocyte value from a tool's nature.
 * Deterministic tools (data lookup) get low astrocyte.
 * Creative/generative tools get high astrocyte.
 * Security tools get very low (must be predictable).
 */
function inferAstrocyte(tool) {
  // Security demands certainty
  if (tool.approval || tool.pii) return 0.1;
  // Data operations are deterministic
  if (tool.does === 'data') return 0.05;
  // Analysis has moderate uncertainty
  if (tool.does === 'analyze') return 0.3;
  // Communication has social uncertainty
  if (tool.does === 'communicate') return 0.4;
  // Rendering is creative, moderate uncertainty
  if (tool.does === 'render') return 0.5;
  // Automation can go many ways
  if (tool.does === 'automate') return 0.6;
  // Streaming is inherently fluid
  if (tool.runs === 'stream') return 0.4;
  return 0.3; // default moderate
}

// ═══════════════════════════════════════════════════════════
// WAVE-PARTICLE DUALITY (Law L)
// A node is BOTH a particle (fixed attributes) AND a wave
// (probability potential) at the same time. Observation
// collapses the wave. Between observations, it spreads.
// ═══════════════════════════════════════════════════════════

/**
 * Create a wave-particle node.
 * Particle aspect: fixed coordinate (position), mass, momentum.
 * Wave aspect: probability amplitude across all 12 dimensions.
 *
 * The wave function psi(x) = A * exp(ikx) where:
 *   A = amplitude (astrocyte controls spread)
 *   k = wave number (related to momentum)
 *   x = position in 12D space
 *
 * @param {Array|object} position - 12D particle coordinate
 * @param {number} astrocyte - Controls wave spread (0=pure particle, 1=pure wave)
 * @param {number[]} momentum - 12D momentum vector (default: zero)
 */
function createWaveParticle(position, astrocyte = 0.3, momentum = null) {
  const coord = Array.isArray(position) ? position : createCoordinate(position);
  const a = Math.max(0, Math.min(1, Number(astrocyte) || 0));
  const mom = momentum || new Array(12).fill(0);

  return {
    // Particle aspect
    position: [...coord],
    momentum: [...mom],
    mass: coord.reduce((s, v) => s + v * v, 0) / 12,

    // Wave aspect
    astrocyte: a,
    type: 'wave-particle',

    /**
     * The wave function amplitude at a given point in 12D space.
     * psi(x) = exp(-|x - position|^2 / (2 * sigma^2)) * exp(i * k . x)
     *
     * Returns the PROBABILITY DENSITY (|psi|^2) at that point.
     * This is a gaussian wave packet centered at the particle position.
     */
    psiSquared(point) {
      if (a === 0) {
        // Pure particle: delta function at position
        const d = distance(coord, point);
        return d < 0.5 ? 1.0 : 0.0;
      }
      const sigma = a * 3;
      const sigma2 = sigma * sigma;
      let exponent = 0;
      for (let i = 0; i < 12; i++) {
        exponent += (point[i] - coord[i]) ** 2;
      }
      return Math.exp(-exponent / (2 * sigma2));
    },

    /**
     * The wavelength (de Broglie relation): lambda = h / p
     * Higher momentum = shorter wavelength = more particle-like.
     */
    wavelength() {
      const p = Math.sqrt(mom.reduce((s, m) => s + m * m, 0));
      if (p === 0) return Infinity; // Standing wave
      return 6.674 / p; // Using G as Planck-like constant
    },

    /**
     * Observe: collapse the wave function.
     * Returns a definite particle position drawn from the wave.
     * After observation, astrocyte drops toward 0.
     */
    observe() {
      const collapsed = createProbabilistic(coord, a).sample();
      return createWaveParticle(collapsed, a * 0.3, mom); // Reduced uncertainty
    },

    /**
     * Spread: between observations, the wave spreads.
     * Uncertainty increases over time (Heisenberg).
     * The more precisely we knew the position (low astrocyte),
     * the faster momentum uncertainty grows.
     */
    spread(dt = 1) {
      const newA = Math.min(1, a + 0.01 * dt * (1 - a));
      // Position uncertainty grows, momentum transfers to position
      const newPos = coord.map((v, i) => {
        const drift = mom[i] * dt * 0.01;
        return Math.max(0, Math.min(10, v + drift));
      });
      return createWaveParticle(newPos, newA, mom);
    },

    /**
     * Interfere with another wave-particle.
     * Constructive interference (similar) amplifies.
     * Destructive interference (opposite) cancels.
     */
    interfere(other) {
      const sim = similarity(coord, other.position);
      // Phase relationship: similar = constructive, different = destructive
      const interference = sim * 2 - 1; // -1 to +1

      const combined = new Array(12);
      for (let i = 0; i < 12; i++) {
        if (interference > 0) {
          // Constructive: amplify the average
          combined[i] = (coord[i] + other.position[i]) / 2 + interference * 2;
        } else {
          // Destructive: cancel out
          combined[i] = (coord[i] + other.position[i]) / 2 * (1 + interference);
        }
        combined[i] = Math.max(0, Math.min(10, Math.round(combined[i])));
      }

      const combinedA = (a + other.astrocyte) / 2 * (1 + Math.abs(interference) * 0.5);
      return createWaveParticle(combined, Math.min(1, combinedA));
    },

    /**
     * Tunnel: quantum tunneling through a barrier.
     * Even if a dimension barrier is high, there's a probability
     * of crossing proportional to exp(-barrier/astrocyte).
     */
    tunnel(targetDim, barrier) {
      const tunnelProb = Math.exp(-barrier / (a * 10 || 0.1));
      if (Math.random() < tunnelProb) {
        const newPos = [...coord];
        newPos[targetDim] = Math.min(10, coord[targetDim] + barrier);
        return { tunneled: true, result: createWaveParticle(newPos, a, mom) };
      }
      return { tunneled: false, result: this };
    },

    // Inherit probabilistic methods
    sample: () => createProbabilistic(coord, a).sample(),
    sampleN: (n) => createProbabilistic(coord, a).sampleN(n),
    entropy: () => createProbabilistic(coord, a).entropy()
  };
}

// ═══════════════════════════════════════════════════════════
// THE PERCEPTRON — Self-Modulating Astrocyte (Law LI)
// The astrocyte observes the field and adjusts itself.
// Every action reflects back. The system perceives itself.
// ═══════════════════════════════════════════════════════════

/**
 * The Perceptron is a reflective function attached to the astrocyte.
 * After every action, the perceptron:
 * 1. Observes the outcome (did reality match prediction?)
 * 2. Calculates prediction error
 * 3. Adjusts the astrocyte (tighten on accuracy, loosen on surprise)
 * 4. Updates coupling weights between dimensions
 *
 * This makes the system SELF-MODULATING — the meta-variable
 * updates itself based on feedback. No external calibration needed.
 *
 * @param {number} currentAstrocyte - Current uncertainty level
 * @param {number[]} predicted - What the system predicted (12D)
 * @param {number[]} observed - What actually happened (12D)
 * @param {number} learningRate - How fast to adapt (default 0.1)
 * @returns {object} { newAstrocyte, predictionError, adjustments }
 */
function perceptronReflect(currentAstrocyte, predicted, observed, learningRate = 0.1) {
  // Calculate prediction error per dimension
  const errors = new Array(12);
  let totalError = 0;
  let maxError = 0;
  const adjustments = new Array(12);

  for (let i = 0; i < 12; i++) {
    errors[i] = (observed[i] || 0) - (predicted[i] || 0);
    totalError += errors[i] * errors[i];
    maxError = Math.max(maxError, Math.abs(errors[i]));

    // Per-dimension confidence adjustment
    // Large error → increase uncertainty on this dimension
    // Small error → decrease uncertainty (we predicted well)
    adjustments[i] = errors[i] * learningRate;
  }

  const rmse = Math.sqrt(totalError / 12);

  // Astrocyte self-modulation:
  // High prediction error → increase astrocyte (more uncertainty needed)
  // Low prediction error → decrease astrocyte (system is calibrated)
  const errorNormalized = rmse / 10; // Normalize to 0-1 range
  const delta = (errorNormalized - currentAstrocyte) * learningRate;
  const newAstrocyte = Math.max(0.01, Math.min(0.99,
    currentAstrocyte + delta
  ));

  return {
    newAstrocyte,
    previousAstrocyte: currentAstrocyte,
    predictionError: rmse,
    maxDimensionError: maxError,
    dimensionErrors: errors,
    adjustments,
    confidence: 1 - newAstrocyte,
    interpretation: rmse < 1 ? 'accurate' :
                    rmse < 3 ? 'approximate' :
                    rmse < 5 ? 'uncertain' : 'surprised'
  };
}

/**
 * Run continuous perception loop on a node.
 * Each action on this node feeds back to the perceptron,
 * which adjusts the astrocyte in real time.
 *
 * Returns a perceptron-enhanced wave-particle that self-calibrates.
 */
function createPerceptron(position, initialAstrocyte = 0.3) {
  const wp = createWaveParticle(position, initialAstrocyte);
  let history = [];
  let currentAstrocyte = initialAstrocyte;

  return {
    ...wp,
    type: 'perceptron',
    history: () => history,

    /**
     * Predict what will happen when this node is acted upon.
     * Returns a sampled coordinate from current wave state.
     */
    predict() {
      return createProbabilistic(wp.position, currentAstrocyte).sample();
    },

    /**
     * Reflect: feed an observed outcome back to the perceptron.
     * The astrocyte self-modulates based on prediction accuracy.
     */
    reflect(observed) {
      const predicted = this.predict();
      const result = perceptronReflect(currentAstrocyte, predicted, observed);

      currentAstrocyte = result.newAstrocyte;
      wp.astrocyte = currentAstrocyte;

      history.push({
        epoch: history.length,
        predicted,
        observed,
        error: result.predictionError,
        astrocyte: currentAstrocyte,
        timestamp: Date.now()
      });

      // Keep history bounded
      if (history.length > 100) history = history.slice(-50);

      return result;
    },

    /**
     * Get the current self-assessed confidence.
     */
    confidence() {
      return 1 - currentAstrocyte;
    },

    /**
     * Get the learning curve — how the astrocyte has evolved.
     */
    learningCurve() {
      return history.map(h => ({
        epoch: h.epoch,
        error: h.error,
        astrocyte: h.astrocyte
      }));
    }
  };
}

/**
 * Create a probabilistic coordinate from a tool definition.
 * Extends fromTool() with astrocyte inference.
 */
function fromToolProbabilistic(tool) {
  const coord = fromTool(tool);
  const astrocyte = inferAstrocyte(tool);
  return createProbabilistic(coord, astrocyte);
}

module.exports = {
  DIMENSIONS,
  ZODIAC,
  ASTROCYTE,
  createCoordinate,
  distance,
  similarity,
  dominantDimensions,
  zodiacalQuality,
  createEdge,
  score,
  fromTool,
  // Astrocyte extensions
  createProbabilistic,
  inferAstrocyte,
  fromToolProbabilistic,
  normalCDF,
  // Wave-particle duality
  createWaveParticle,
  // Perceptron (self-modulating astrocyte)
  perceptronReflect,
  createPerceptron
};
