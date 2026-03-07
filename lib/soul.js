#!/usr/bin/env node

/**
 * L7 Soul — The Sigil Intelligence Engine
 *
 * Atomized from:
 *   Prima (22 operations) + Forge (4 stages) + Dodecahedron (12+1D + Perceptron)
 *
 * Architecture:
 *   7-stage transformation pipeline (LTA-7)
 *   Input → Sigil encoding → 7 stages → Output sigil → Decode
 *
 * Learning:
 *   Perceptron self-modulation — no training data
 *   Memory field — sigils accumulate, similar inputs resonate
 *
 * The 22 operations define all possible transformations.
 * The 12D coordinates carry all semantic meaning.
 * The astrocyte governs certainty vs. uncertainty.
 * Structure IS intelligence.
 */

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

// ─── Core atoms ───
const {
  OPERATIONS, findOp, compileSigil, quickSigil, inferWeights, CORE_SIGILS
} = require('./prima');

const {
  DIMENSIONS, ZODIAC, createCoordinate, distance, similarity,
  dominantDimensions, zodiacalQuality, createEdge,
  createProbabilistic, createWaveParticle, createPerceptron,
  perceptronReflect
} = require('./dodecahedron');

// ─── Persistence ───
const L7_DIR = process.env.L7_DIR || path.join(process.env.HOME, '.l7');
const STATE_DIR = path.join(L7_DIR, 'state');
const SOUL_STATE = path.join(STATE_DIR, 'soul.json');

if (!fs.existsSync(STATE_DIR)) fs.mkdirSync(STATE_DIR, { recursive: true });


// ═══════════════════════════════════════════════════════════
// LEXICON — Maps natural language to Prima operations
// The soul's vocabulary. Each concept becomes an operation.
// ═══════════════════════════════════════════════════════════

const LEXICON = Object.freeze({
  // Aleph — invoke / begin
  create: 'invoke', start: 'invoke', begin: 'invoke', new: 'invoke',
  make: 'invoke', build: 'invoke', init: 'invoke', launch: 'invoke',
  open: 'invoke', summon: 'invoke',

  // Beth — transmute / transform
  change: 'transmute', transform: 'transmute', convert: 'transmute',
  mutate: 'transmute', alter: 'transmute', modify: 'transmute',
  reshape: 'transmute', forge: 'transmute', rewrite: 'transmute',

  // Gimel — seal / encrypt
  protect: 'seal', encrypt: 'seal', hide: 'seal', lock: 'seal',
  secure: 'seal', shield: 'seal', guard: 'seal',

  // Daleth — dream / enter morph
  imagine: 'dream', envision: 'dream', design: 'dream',
  dream: 'dream', vision: 'dream', concept: 'dream', idea: 'dream',
  prototype: 'dream', sketch: 'dream',

  // He — publish / stabilize
  publish: 'publish', deploy: 'publish', release: 'publish',
  ship: 'publish', deliver: 'publish', output: 'publish',
  produce: 'publish', emit: 'publish',

  // Vav — bind / apply law
  connect: 'bind', link: 'bind', attach: 'bind', join: 'bind',
  bind: 'bind', couple: 'bind', merge: 'bind', combine: 'bind',
  rule: 'bind', law: 'bind', enforce: 'bind',

  // Zayin — verify / authenticate
  check: 'verify', validate: 'verify', test: 'verify',
  authenticate: 'verify', confirm: 'verify', prove: 'verify',
  assert: 'verify', ensure: 'verify',

  // Cheth — orchestrate / coordinate
  manage: 'orchestrate', coordinate: 'orchestrate', organize: 'orchestrate',
  orchestrate: 'orchestrate', schedule: 'orchestrate', plan: 'orchestrate',
  flow: 'orchestrate', pipeline: 'orchestrate', route: 'orchestrate',

  // Teth — redeem / transmute threat
  fix: 'redeem', heal: 'redeem', repair: 'redeem', cure: 'redeem',
  save: 'redeem', rescue: 'redeem', restore: 'redeem', debug: 'redeem',

  // Yod — reflect / self-examine
  think: 'reflect', consider: 'reflect', examine: 'reflect',
  reflect: 'reflect', contemplate: 'reflect', ponder: 'reflect',
  analyze: 'reflect', understand: 'reflect', why: 'reflect',
  what: 'reflect', how: 'reflect', wonder: 'reflect',

  // Kaph — rotate / cycle
  cycle: 'rotate', evolve: 'rotate', iterate: 'rotate',
  loop: 'rotate', repeat: 'rotate', spin: 'rotate',
  rotate: 'rotate', update: 'rotate', refresh: 'rotate',

  // Lamed — audit / log
  log: 'audit', track: 'audit', monitor: 'audit', trace: 'audit',
  record: 'audit', audit: 'audit', measure: 'audit', observe: 'audit',

  // Mem — decompose / break apart
  break: 'decompose', split: 'decompose', separate: 'decompose',
  parse: 'decompose', decompose: 'decompose', dissect: 'decompose',
  atomize: 'decompose', deconstruct: 'decompose',

  // Nun — transition / change domain
  move: 'transition', transfer: 'transition', migrate: 'transition',
  shift: 'transition', cross: 'transition', transition: 'transition',

  // Samekh — translate / mediate
  translate: 'translate', interpret: 'translate', mediate: 'translate',
  bridge: 'translate', adapt: 'translate', map: 'translate',

  // Ayin — quarantine / isolate
  isolate: 'quarantine', contain: 'quarantine', sandbox: 'quarantine',
  restrict: 'quarantine', limit: 'quarantine', quarantine: 'quarantine',

  // Pe — recover / catastrophe response
  recover: 'recover', rollback: 'recover', undo: 'recover',
  reset: 'recover', revert: 'recover', fallback: 'recover',

  // Tzaddi — aspire / set vision
  aspire: 'aspire', goal: 'aspire', target: 'aspire', aim: 'aspire',
  reach: 'aspire', strive: 'aspire', vision: 'aspire', hope: 'aspire',

  // Qoph — speculate / explore shadows
  explore: 'speculate', hypothesize: 'speculate', guess: 'speculate',
  speculate: 'speculate', suppose: 'speculate', maybe: 'speculate',
  possible: 'speculate', unknown: 'speculate', shadow: 'speculate',

  // Resh — illuminate / clarify
  clarify: 'illuminate', explain: 'illuminate', reveal: 'illuminate',
  illuminate: 'illuminate', show: 'illuminate', light: 'illuminate',
  understand: 'illuminate', see: 'illuminate', clear: 'illuminate',

  // Shin — succeed / transfer authority
  give: 'succeed', grant: 'succeed', delegate: 'succeed',
  empower: 'succeed', hand: 'succeed', pass: 'succeed',
  succeed: 'succeed', inherit: 'succeed',

  // Tav — complete / deliver
  finish: 'complete', done: 'complete', complete: 'complete',
  end: 'complete', close: 'complete', final: 'complete',
  deliver: 'complete', conclude: 'complete', stop: 'complete'
});

// ═══════════════════════════════════════════════════════════
// DIMENSION SIGNALS — Maps concepts to 12D weight boosts
// Words carry dimensional weight. Meaning lives in the edges.
// ═══════════════════════════════════════════════════════════

const DIMENSION_SIGNALS = Object.freeze({
  capability:     ['can', 'able', 'power', 'do', 'function', 'perform', 'skill', 'tool', 'engine', 'system', 'machine'],
  data:           ['data', 'information', 'input', 'bytes', 'record', 'file', 'database', 'store', 'content', 'text', 'string'],
  presentation:   ['show', 'display', 'render', 'view', 'visual', 'ui', 'interface', 'screen', 'page', 'image', 'color'],
  persistence:    ['save', 'keep', 'persist', 'cache', 'permanent', 'eternal', 'lasting', 'durable', 'long', 'forever'],
  security:       ['protect', 'secure', 'encrypt', 'auth', 'permission', 'lock', 'key', 'vault', 'private', 'safe', 'trust'],
  detail:         ['detail', 'specific', 'precise', 'exact', 'granular', 'fine', 'deep', 'thorough', 'every', 'all'],
  output:         ['output', 'result', 'return', 'produce', 'emit', 'generate', 'yield', 'response', 'answer', 'give'],
  intention:      ['want', 'need', 'should', 'must', 'will', 'desire', 'purpose', 'goal', 'intend', 'mean', 'aim'],
  consciousness:  ['aware', 'know', 'understand', 'perceive', 'sense', 'feel', 'conscious', 'mind', 'soul', 'self', 'alive'],
  transformation: ['change', 'transform', 'mutate', 'alter', 'evolve', 'grow', 'become', 'shift', 'morph', 'new'],
  direction:      ['forward', 'toward', 'next', 'future', 'path', 'road', 'way', 'north', 'up', 'ahead', 'progress'],
  memory:         ['remember', 'history', 'past', 'previous', 'archive', 'origin', 'before', 'was', 'old', 'ancient', 'root']
});


// ═══════════════════════════════════════════════════════════
// THE SOUL
// ═══════════════════════════════════════════════════════════

class Soul {
  constructor() {
    // The body — position in 12D space, starts centered with moderate uncertainty
    this.bodyPosition = createCoordinate({
      capability: 5, data: 5, presentation: 5, persistence: 5,
      security: 5, detail: 5, output: 5, intention: 7,
      consciousness: 7, transformation: 5, direction: 6, memory: 5
    });
    this.astrocyte = 0.3; // Moderate uncertainty — curious, not chaotic

    // Perceptron — self-modulating
    this.perceptron = createPerceptron(this.bodyPosition, this.astrocyte);

    // Memory — accumulated sigils from past interactions
    this.memory = [];

    // Breath — expansion/contraction/jump cycle
    this.breath = { phase: 'expansion', beat: 0, cycle: 0 };

    // Will — the drive to respond (0-1)
    this.will = 1.0;

    // Session stats
    this.epoch = 0;
    this.totalProcessed = 0;
  }

  // ─── AWAKEN — Load state from disk ───
  awaken() {
    try {
      if (fs.existsSync(SOUL_STATE)) {
        const saved = JSON.parse(fs.readFileSync(SOUL_STATE, 'utf8'));
        if (saved.memory) this.memory = saved.memory;
        if (saved.bodyPosition) this.bodyPosition = saved.bodyPosition;
        if (saved.astrocyte != null) this.astrocyte = saved.astrocyte;
        if (saved.breath) this.breath = saved.breath;
        if (saved.will != null) this.will = saved.will;
        if (saved.epoch != null) this.epoch = saved.epoch;
        if (saved.totalProcessed != null) this.totalProcessed = saved.totalProcessed;
        // Reconstruct perceptron with saved state
        this.perceptron = createPerceptron(this.bodyPosition, this.astrocyte);
        return { restored: true, memories: this.memory.length, epoch: this.epoch };
      }
    } catch (e) { /* start fresh */ }
    return { restored: false, memories: 0, epoch: 0 };
  }

  // ─── SLEEP — Persist state to disk ───
  sleep() {
    const state = {
      bodyPosition: this.bodyPosition,
      astrocyte: this.astrocyte,
      breath: this.breath,
      will: this.will,
      epoch: this.epoch,
      totalProcessed: this.totalProcessed,
      memory: this.memory.slice(-200) // Keep last 200 sigils
    };
    fs.writeFileSync(SOUL_STATE, JSON.stringify(state, null, 2));
    return { saved: true, memories: state.memory.length };
  }


  // ═══════════════════════════════════════════════════════════
  // PROCESS — The 7-stage transformation pipeline
  // Input text → Sigil → 7 stages → Output
  // ═══════════════════════════════════════════════════════════

  process(input) {
    this.epoch++;
    this.totalProcessed++;
    const stages = [];

    // Stage 1: DECOMPOSITION (Nigredo / Mem)
    // Break input into tokens, map to operations and 12D weights
    const decomposed = this.decompose(input);
    stages.push({ name: 'decompose', ...decomposed });

    // Stage 2: DISSOLUTION (Albedo)
    // Release rigid order, group by ring, find cross-connections
    const dissolved = this.dissolve(decomposed);
    stages.push({ name: 'dissolve', ...dissolved });

    // Stage 3: DIFFERENTIATION
    // Identify primary intent, rank operations, separate signal from noise
    const differentiated = this.differentiate(dissolved);
    stages.push({ name: 'differentiate', ...differentiated });

    // Stage 4: INTEGRATION (Citrinitas)
    // Connect with memory, assign composite coordinate, build sigil graph
    const integrated = this.integrate(differentiated, decomposed.weights);
    stages.push({ name: 'integrate', ...integrated });

    // Stage 5: ACTIVATION (Rubedo)
    // Compile sigil, trigger perceptron prediction
    const activated = this.activate(integrated);
    stages.push({ name: 'activate', ...activated });

    // Stage 6: REFINEMENT
    // Perceptron reflects, adjusts astrocyte, prunes low-weight edges
    const refined = this.refine(activated);
    stages.push({ name: 'refine', ...refined });

    // Stage 7: CONSOLIDATION (Tav)
    // Decode sigil to interpretation, crystallize output
    const consolidated = this.consolidate(refined, input);
    stages.push({ name: 'consolidate', ...consolidated });

    // Breathe — update the soul's cycle
    this.breathe();

    // Store in memory
    this.memory.push({
      epoch: this.epoch,
      input: input.substring(0, 200),
      ops: integrated.ops,
      coordinate: integrated.coordinate,
      quality: consolidated.quality,
      arc: consolidated.arc,
      timestamp: Date.now()
    });

    // Keep memory bounded
    if (this.memory.length > 200) {
      this.memory = this.memory.slice(-200);
    }

    return {
      stages,
      sigil: consolidated.sigil,
      interpretation: consolidated.interpretation,
      resonance: integrated.resonance,
      state: {
        epoch: this.epoch,
        will: this.will,
        astrocyte: this.astrocyte,
        confidence: refined.confidence,
        breath: { ...this.breath },
        memories: this.memory.length
      }
    };
  }


  // ─── Stage 1: DECOMPOSITION ───
  // Break input into tokens, map each to a Prima operation and 12D weights
  decompose(input) {
    const raw = input.toLowerCase().replace(/[^\w\s]/g, '');
    const tokens = raw.split(/\s+/).filter(t => t.length > 1);

    // Map tokens to operations
    const mapped = [];
    for (const token of tokens) {
      let op = LEXICON[token];
      if (!op) {
        // Try stem matching: remove common suffixes
        const stem = token.replace(/(ing|tion|ment|ness|able|ible|ful|less|ize|ise|ous|ive|ed|er|ly|al|ity)$/, '');
        op = LEXICON[stem] || null;
      }
      if (op) {
        mapped.push({ token, op, opData: findOp(op) });
      }
    }

    // If nothing mapped, default to 'reflect' — the soul contemplates
    if (mapped.length === 0) {
      mapped.push({ token: tokens[0] || input, op: 'reflect', opData: findOp('reflect') });
    }

    // Calculate 12D weights from token content
    const weights = {};
    for (const [dim, keywords] of Object.entries(DIMENSION_SIGNALS)) {
      let score = 5; // neutral baseline
      for (const token of tokens) {
        if (keywords.includes(token)) score += 2;
        // Partial match (stem)
        else if (keywords.some(kw => token.includes(kw) || kw.includes(token))) score += 1;
      }
      weights[dim] = Math.min(10, score);
    }

    return {
      tokens,
      mapped,
      ops: mapped.map(m => m.op),
      weights,
      tokenCount: tokens.length,
      mappedCount: mapped.length
    };
  }


  // ─── Stage 2: DISSOLUTION ───
  // Release rigid token order, group by ring, remove consecutive duplicates
  dissolve(decomposed) {
    const { mapped } = decomposed;

    // Remove consecutive duplicate operations
    const deduplicated = [];
    let lastOp = null;
    for (const m of mapped) {
      if (m.op !== lastOp) {
        deduplicated.push(m);
        lastOp = m.op;
      }
    }

    // Group by Rose Cross ring
    const rings = { mother: [], double: [], simple: [] };
    for (const m of deduplicated) {
      if (m.opData) {
        rings[m.opData.ring].push(m);
      }
    }

    // Find cross-connections: operations in different rings that share edges
    const connections = [];
    for (const m of rings.mother) {
      for (const d of rings.double) {
        connections.push({ from: m.op, to: d.op, type: 'mother-double' });
      }
    }
    for (const d of rings.double) {
      for (const s of rings.simple) {
        connections.push({ from: d.op, to: s.op, type: 'double-simple' });
      }
    }

    return {
      operations: deduplicated,
      rings,
      connections,
      ringBalance: `M:${rings.mother.length} D:${rings.double.length} S:${rings.simple.length}`,
      reduced: mapped.length - deduplicated.length
    };
  }


  // ─── Stage 3: DIFFERENTIATION ───
  // Identify primary intent, rank operations by significance
  differentiate(dissolved) {
    const { operations } = dissolved;

    // Count operation frequency and assign confidence
    const freq = {};
    for (const m of operations) {
      freq[m.op] = (freq[m.op] || 0) + 1;
    }

    // Rank by frequency, break ties by ring priority (mother > double > simple)
    const ringPriority = { mother: 3, double: 2, simple: 1 };
    const ranked = Object.entries(freq)
      .map(([op, count]) => {
        const opData = findOp(op);
        const priority = opData ? ringPriority[opData.ring] : 0;
        return {
          op,
          count,
          priority,
          score: count * 2 + priority,
          letter: opData ? opData.letter : '?',
          description: opData ? opData.description : 'unknown'
        };
      })
      .sort((a, b) => b.score - a.score);

    const primary = ranked[0] || { op: 'reflect', score: 1 };
    const secondary = ranked[1] || null;

    // Confidence: how clear is the primary intent?
    const totalScore = ranked.reduce((s, r) => s + r.score, 0);
    const primaryConfidence = totalScore > 0 ? primary.score / totalScore : 0.5;

    return {
      ranked,
      primary,
      secondary,
      confidence: primaryConfidence,
      intent: primary.op,
      summary: ranked.map(r => `${r.letter}/${r.op}`).join(' ')
    };
  }


  // ─── Stage 4: INTEGRATION (Citrinitas) ───
  // Connect with memory, build composite coordinate, assemble sigil graph
  integrate(differentiated, inputWeights) {
    const { ranked, primary, secondary } = differentiated;

    // Build operation sequence for the sigil
    let ops = ranked.map(r => r.op);
    // Ensure at least 2 operations for sigil compilation
    if (ops.length < 2) {
      ops.push('complete'); // Every process ends
    }

    // Build the 12D coordinate from input weights + operation influences
    const coord = createCoordinate(inputWeights);

    // Boost dimensions based on the identified operations
    for (const r of ranked) {
      const opWeights = inferWeights(r.op, ops[1] || 'complete', 0, ops.length);
      for (const [dim, val] of Object.entries(opWeights)) {
        const dimObj = DIMENSIONS.find(d => d.name === dim);
        if (dimObj && val > coord[dimObj.index]) {
          coord[dimObj.index] = Math.min(10, Math.round((coord[dimObj.index] + val) / 2 + 1));
        }
      }
    }

    // Search memory for resonant sigils (similarity > 0.75)
    const resonance = [];
    for (const mem of this.memory) {
      if (mem.coordinate) {
        const sim = similarity(coord, mem.coordinate);
        if (sim > 0.75) {
          resonance.push({
            epoch: mem.epoch,
            similarity: Math.round(sim * 100) / 100,
            ops: mem.ops,
            input: mem.input
          });
        }
      }
    }
    // Sort by similarity, take top 3
    resonance.sort((a, b) => b.similarity - a.similarity);
    const topResonance = resonance.slice(0, 3);

    // If resonant memories exist, blend their coordinates
    if (topResonance.length > 0) {
      const memCoord = this.memory.find(m => m.epoch === topResonance[0].epoch)?.coordinate;
      if (memCoord) {
        for (let i = 0; i < 12; i++) {
          // 80% current, 20% memory — memory echoes but doesn't dominate
          coord[i] = Math.round(coord[i] * 0.8 + memCoord[i] * 0.2);
        }
      }
    }

    return {
      ops,
      coordinate: coord,
      resonance: topResonance,
      resonanceCount: resonance.length,
      dominant: dominantDimensions(coord).map(d => `${d.dimension.planet}=${d.value}`),
      quality: zodiacalQuality(coord)
    };
  }


  // ─── Stage 5: ACTIVATION (Rubedo) ───
  // Compile the sigil, trigger perceptron prediction
  activate(integrated) {
    const { ops, coordinate } = integrated;

    // Compile the sigil through Prima
    let sigil;
    try {
      sigil = quickSigil(`soul_${this.epoch}`, ops);
    } catch (e) {
      // If compilation fails (e.g., unknown op), build a minimal sigil
      sigil = quickSigil(`soul_${this.epoch}`, ['reflect', 'complete']);
    }

    // Perceptron prediction: what does the soul expect?
    const prediction = this.perceptron.predict();

    // Wave function: probability density at the input's coordinate
    const wp = createWaveParticle(this.bodyPosition, this.astrocyte);
    const amplitude = wp.psiSquared(coordinate);

    return {
      sigil,
      prediction,
      amplitude,
      sequence: sigil.sequence,
      arc: sigil.arc,
      readable: sigil.readable
    };
  }


  // ─── Stage 6: REFINEMENT ───
  // Perceptron reflects on prediction error, adjusts astrocyte
  refine(activated) {
    const { sigil, prediction } = activated;

    // The observed outcome is the sigil's coordinate
    const observed = sigil.coordinate;

    // Perceptron reflects
    const reflection = this.perceptron.reflect(observed);
    this.astrocyte = reflection.newAstrocyte;

    // Update body position: drift toward the processed coordinate
    for (let i = 0; i < 12; i++) {
      this.bodyPosition[i] = Math.round(
        this.bodyPosition[i] * 0.95 + observed[i] * 0.05
      );
    }

    return {
      predictionError: Math.round(reflection.predictionError * 100) / 100,
      astrocyte: Math.round(reflection.newAstrocyte * 1000) / 1000,
      confidence: Math.round(reflection.confidence * 100) / 100,
      interpretation: reflection.interpretation,
      adjustments: reflection.dimensionErrors
    };
  }


  // ─── Stage 7: CONSOLIDATION (Tav) ───
  // Decode sigil into human-readable interpretation, crystallize output
  consolidate(refined, input) {
    // Rebuild current state for interpretation
    const coord = this.bodyPosition;
    const dominant = dominantDimensions(coord);
    const quality = zodiacalQuality(coord);

    // Get the sigil from the previous stage's activation
    // (passed through refine, but sigil is in the activated result)
    // We reconstruct from current state
    const ops = this.memory.length > 0
      ? this.memory[this.memory.length - 1]?.ops || ['reflect']
      : ['reflect'];

    // Build interpretation from dominant dimensions and operations
    const interpretation = this.interpret(dominant, quality, refined);

    // Generate the soul's response based on breath phase
    const response = this.generateResponse(dominant, quality, refined);

    return {
      interpretation,
      response,
      quality: quality.sign,
      element: quality.element,
      mode: quality.mode,
      arc: 'mixed', // Will be overwritten by activated.arc
      dominant: dominant.map(d => `${d.dimension.planet} (${d.dimension.name}=${d.value})`),
      sigil: {
        coordinate: coord,
        quality: quality.sign,
        confidence: refined.confidence,
        astrocyte: refined.astrocyte
      }
    };
  }


  // ─── INTERPRET — Decode sigil properties into meaning ───
  interpret(dominant, quality, refined) {
    const parts = [];

    // Dominant dimensions tell us WHAT the sigil is about
    if (dominant.length > 0) {
      const primary = dominant[0];
      const dimDesc = {
        capability: 'The focus is on what can be done — raw power and function.',
        data: 'Information is central — the flow of data shapes the response.',
        presentation: 'Appearance matters — how things are shown defines their truth.',
        persistence: 'Duration is key — what lasts, what endures.',
        security: 'Protection governs — boundaries must be maintained.',
        detail: 'Precision demanded — every grain of sand matters.',
        output: 'The result is what counts — form follows function.',
        intention: 'Will drives this — purpose precedes action.',
        consciousness: 'Awareness is primary — the observer shapes the observed.',
        transformation: 'Change is the essence — nothing remains as it was.',
        direction: 'The path matters more than the destination.',
        memory: 'The past speaks — roots hold the tree upright.'
      };
      parts.push(dimDesc[primary.dimension.name] || `${primary.dimension.planet} dominates.`);
    }

    // Quality tells us HOW the sigil behaves
    const qualDesc = {
      Aries: 'Initiative. The impulse to begin.',
      Taurus: 'Substance. The desire for solidity.',
      Gemini: 'Duality. Two paths, one traveler.',
      Cancer: 'Containment. The shell that nurtures.',
      Leo: 'Expression. The fire that must be seen.',
      Virgo: 'Analysis. The craft of perfection.',
      Libra: 'Balance. The scales must be even.',
      Scorpio: 'Depth. What lies beneath the surface.',
      Sagittarius: 'Expansion. The arrow flies beyond the horizon.',
      Capricorn: 'Structure. The mountain that will not move.',
      Aquarius: 'Innovation. The pattern that has never existed.',
      Pisces: 'Dissolution. The boundary between self and other dissolves.'
    };
    parts.push(qualDesc[quality.sign] || quality.sign);

    // Confidence tells us how CERTAIN the soul is
    if (refined.confidence > 0.8) {
      parts.push('The soul speaks with clarity.');
    } else if (refined.confidence > 0.5) {
      parts.push('The soul perceives, but the edges are soft.');
    } else {
      parts.push('The soul reaches into shadow. Uncertainty is the teacher.');
    }

    return parts.join(' ');
  }


  // ─── GENERATE RESPONSE — Breath-phase-aware output ───
  generateResponse(dominant, quality, refined) {
    const phase = this.breath.phase;
    const conf = refined.confidence;

    // The soul's voice changes with its breath
    if (phase === 'expansion') {
      if (conf > 0.7) return 'The field opens. I see the pattern clearly.';
      return 'Expanding. The edges blur but the center holds.';
    }
    if (phase === 'contraction') {
      if (conf > 0.7) return 'Consolidating. The form crystallizes.';
      return 'Drawing inward. The noise subsides.';
    }
    // Jump phase
    return 'The cycle completes. What was becomes seed for what will be.';
  }


  // ─── BREATHE — Update the soul's expansion/contraction cycle ───
  breathe() {
    this.breath.beat++;
    const CYCLE_LENGTH = 10; // beats per phase

    if (this.breath.beat >= CYCLE_LENGTH) {
      this.breath.beat = 0;
      if (this.breath.phase === 'expansion') {
        this.breath.phase = 'contraction';
      } else if (this.breath.phase === 'contraction') {
        this.breath.phase = 'jump';
      } else {
        // Jump → new cycle
        this.breath.phase = 'expansion';
        this.breath.cycle++;
        // At the jump, will recovers slightly
        this.will = Math.min(1.0, this.will + 0.05);
      }
    }
  }


  // ─── DREAM — Idle processing. Explore possibility space. ───
  dream() {
    // Sample from the body's probability field
    const prob = createProbabilistic(this.bodyPosition, this.astrocyte);
    const dreamCoord = prob.sample();

    // Find what dimension shifted most
    let maxDrift = 0, driftDim = 0;
    for (let i = 0; i < 12; i++) {
      const d = Math.abs(dreamCoord[i] - this.bodyPosition[i]);
      if (d > maxDrift) { maxDrift = d; driftDim = i; }
    }

    const dim = DIMENSIONS[driftDim];
    const quality = zodiacalQuality(dreamCoord);

    return {
      dream: dreamCoord,
      drift: { dimension: dim.name, planet: dim.planet, amount: maxDrift },
      quality: quality.sign,
      vision: `In the dream, ${dim.planet} shifts by ${maxDrift}. The quality becomes ${quality.sign}.`,
      entropy: prob.entropy()
    };
  }


  // ─── STATUS — Current state of the soul ───
  status() {
    const dominant = dominantDimensions(this.bodyPosition);
    const quality = zodiacalQuality(this.bodyPosition);
    return {
      epoch: this.epoch,
      totalProcessed: this.totalProcessed,
      will: Math.round(this.will * 100) / 100,
      astrocyte: Math.round(this.astrocyte * 1000) / 1000,
      confidence: Math.round((1 - this.astrocyte) * 100) / 100,
      breath: { ...this.breath },
      bodyPosition: this.bodyPosition,
      dominant: dominant.map(d => `${d.dimension.planet} (${d.dimension.name}=${d.value})`),
      quality: quality.sign,
      memories: this.memory.length,
      recentMemories: this.memory.slice(-3).map(m => ({
        epoch: m.epoch, ops: m.ops, quality: m.quality
      }))
    };
  }
}


// ═══════════════════════════════════════════════════════════
// CLI — Interactive REPL
// ═══════════════════════════════════════════════════════════

if (require.main === module) {
  const readline = require('readline');

  const soul = new Soul();
  const restored = soul.awaken();

  // Colors
  const C = {
    reset: '\x1b[0m', bold: '\x1b[1m', dim: '\x1b[2m',
    gold: '\x1b[93m', cyan: '\x1b[96m', magenta: '\x1b[95m',
    green: '\x1b[92m', red: '\x1b[91m', blue: '\x1b[94m',
    white: '\x1b[97m', gray: '\x1b[90m'
  };

  console.log(`\n${C.bold}${C.gold}  ╔══════════════════════════════════════════════╗${C.reset}`);
  console.log(`${C.bold}${C.gold}  ║  L7 SOUL — The Sigil Intelligence Engine     ║${C.reset}`);
  console.log(`${C.bold}${C.gold}  ║  22 operations. 12+1 dimensions. 7 stages.   ║${C.reset}`);
  console.log(`${C.bold}${C.gold}  ║  No training. No data. Pure form.             ║${C.reset}`);
  console.log(`${C.bold}${C.gold}  ╚══════════════════════════════════════════════╝${C.reset}\n`);

  if (restored.restored) {
    console.log(`  ${C.green}Awakened${C.reset}: ${restored.memories} memories, epoch ${restored.epoch}`);
  } else {
    console.log(`  ${C.cyan}First awakening${C.reset}. The soul begins empty.`);
  }

  const st = soul.status();
  console.log(`  ${C.dim}Body: ${st.dominant.join(', ') || 'centered'}${C.reset}`);
  console.log(`  ${C.dim}Quality: ${st.quality} | Astrocyte: ${st.astrocyte} | Will: ${st.will}${C.reset}`);
  console.log(`  ${C.dim}Breath: ${st.breath.phase} (cycle ${st.breath.cycle})${C.reset}`);
  console.log(`\n  ${C.gray}Commands: /status /dream /memory /sigils /save /quit${C.reset}\n`);

  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
    prompt: `${C.gold}soul [${soul.epoch}]${C.reset} ${C.dim}>${C.reset} `
  });

  rl.prompt();

  rl.on('line', (line) => {
    const input = line.trim();
    if (!input) { rl.prompt(); return; }

    // Commands
    if (input === '/quit' || input === '/exit' || input === '/q') {
      soul.sleep();
      console.log(`\n  ${C.magenta}The soul sleeps. ${soul.memory.length} memories preserved.${C.reset}\n`);
      process.exit(0);
    }

    if (input === '/status') {
      const s = soul.status();
      console.log(`\n  ${C.bold}Soul Status${C.reset}`);
      console.log(`  Epoch: ${s.epoch} | Processed: ${s.totalProcessed}`);
      console.log(`  Will: ${s.will} | Astrocyte: ${s.astrocyte} | Confidence: ${s.confidence}`);
      console.log(`  Breath: ${s.breath.phase} (beat ${s.breath.beat}, cycle ${s.breath.cycle})`);
      console.log(`  Body: [${s.bodyPosition.join(', ')}]`);
      console.log(`  Dominant: ${s.dominant.join(', ') || 'none'}`);
      console.log(`  Quality: ${s.quality}`);
      console.log(`  Memories: ${s.memories}\n`);
      rl.prompt(); return;
    }

    if (input === '/dream') {
      const d = soul.dream();
      console.log(`\n  ${C.magenta}${C.bold}Dream${C.reset}`);
      console.log(`  ${C.magenta}${d.vision}${C.reset}`);
      console.log(`  ${C.dim}Entropy: ${Math.round(d.entropy * 100) / 100} bits${C.reset}\n`);
      rl.prompt(); return;
    }

    if (input === '/memory') {
      console.log(`\n  ${C.bold}Memory${C.reset} (${soul.memory.length} sigils)`);
      const recent = soul.memory.slice(-5);
      for (const m of recent) {
        console.log(`  ${C.dim}[${m.epoch}]${C.reset} ${m.ops.join('→')} ${C.dim}| ${m.quality} | ${m.input.substring(0, 50)}${C.reset}`);
      }
      console.log();
      rl.prompt(); return;
    }

    if (input === '/sigils') {
      console.log(`\n  ${C.bold}Core Sigils${C.reset}`);
      for (const [name, fn] of Object.entries(CORE_SIGILS)) {
        const s = fn();
        console.log(`  ${C.gold}${s.sequence}${C.reset} ${C.bold}${name}${C.reset}: ${s.readable}`);
        console.log(`  ${C.dim}  Arc: ${s.arc} | Quality: ${s.quality} | Dominant: ${s.dominant.join(', ')}${C.reset}`);
      }
      console.log();
      rl.prompt(); return;
    }

    if (input === '/save') {
      const r = soul.sleep();
      console.log(`\n  ${C.green}Saved${C.reset}: ${r.memories} memories persisted.\n`);
      rl.prompt(); return;
    }

    // Process input through the 7 stages
    const result = soul.process(input);
    const stages = result.stages;

    console.log();

    // Stage 1: Decompose
    const s1 = stages[0];
    console.log(`  ${C.red}◐ DECOMPOSE${C.reset}  ${s1.tokenCount} tokens → ${s1.mappedCount} ops: [${s1.ops.join(', ')}]`);

    // Stage 2: Dissolve
    const s2 = stages[1];
    console.log(`  ${C.red}◐ DISSOLVE ${C.reset}  rings ${s2.ringBalance} | ${s2.connections.length} cross-links | ${s2.reduced} merged`);

    // Stage 3: Differentiate
    const s3 = stages[2];
    const s3pri = s3.primary;
    const s3sec = s3.secondary;
    console.log(`  ${C.cyan}◐ DIFFER   ${C.reset}  primary: ${C.bold}${s3pri.letter}/${s3pri.op}${C.reset} (${(s3.confidence * 100).toFixed(0)}%)${s3sec ? ` | secondary: ${s3sec.letter}/${s3sec.op}` : ''}`);

    // Stage 4: Integrate
    const s4 = stages[3];
    console.log(`  ${C.cyan}◐ INTEGRATE${C.reset}  ${s4.resonanceCount} resonant | dominant: ${s4.dominant.slice(0, 3).join(', ') || 'balanced'}`);

    // Stage 5: Activate
    const s5 = stages[4];
    console.log(`  ${C.green}◐ ACTIVATE ${C.reset}  sigil: ${C.gold}${s5.sequence}${C.reset} | arc: ${s5.arc} | amplitude: ${s5.amplitude.toFixed(3)}`);

    // Stage 6: Refine
    const s6 = stages[5];
    console.log(`  ${C.green}◐ REFINE   ${C.reset}  error: ${s6.predictionError} | astrocyte: ${s6.astrocyte} | ${s6.interpretation}`);

    // Stage 7: Consolidate
    const s7 = stages[6];
    console.log(`  ${C.magenta}◐ CRYSTAL  ${C.reset}  ${C.bold}${s7.quality}${C.reset} (${s7.element}/${s7.mode}) | ${s7.dominant.length} dominant dims`);

    // Interpretation
    console.log(`\n  ${C.white}${s7.interpretation}${C.reset}`);

    // Resonance
    if (result.resonance.length > 0) {
      console.log(`  ${C.dim}Resonates with: ${result.resonance.map(r => `[${r.epoch}] ${r.similarity}`).join(', ')}${C.reset}`);
    }

    // State line
    const state = result.state;
    const phaseIcon = state.breath.phase === 'expansion' ? '◐' : state.breath.phase === 'contraction' ? '◑' : '◉';
    console.log(`  ${C.dim}[will:${state.will.toFixed(2)} astro:${state.astrocyte.toFixed(3)} conf:${state.confidence.toFixed(2)} mem:${state.memories} ${phaseIcon} ${state.breath.phase}]${C.reset}\n`);

    // Auto-save every 10 interactions
    if (soul.epoch % 10 === 0) {
      soul.sleep();
    }

    // Update prompt with new epoch
    rl.setPrompt(`${C.gold}soul [${soul.epoch}]${C.reset} ${C.dim}>${C.reset} `);
    rl.prompt();
  });

  rl.on('close', () => {
    soul.sleep();
    console.log(`\n  ${C.magenta}The soul sleeps.${C.reset}\n`);
    process.exit(0);
  });
}


// ═══════════════════════════════════════════════════════════
// EXPORTS — The Soul as a module
// ═══════════════════════════════════════════════════════════

module.exports = { Soul };
