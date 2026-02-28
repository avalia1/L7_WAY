/**
 * L7 Nerve — The Sensory-Motor Architecture
 * Law LII — Input nodes ingest. Output nodes project. The field processes.
 *
 * The system has a nervous system:
 *
 *   AFFERENT (sensory/input):
 *     Camera, microphone, screenshots, file watchers, API listeners.
 *     These nodes convert external signals into field waves.
 *     Information flows INWARD.
 *
 *   EFFERENT (motor/output):
 *     Sound (TTS), screen (display), file writes, API calls, equation updates.
 *     These nodes convert field state into external actions.
 *     Information flows OUTWARD.
 *
 *   INTERNEURONS (processing):
 *     All tools, citizens, and field nodes that process but neither
 *     directly sense nor act. They compute, transform, route.
 *     Information flows BETWEEN.
 *
 * Special wiring:
 *   - Afferent nodes have amplified coupling to transformation (Pluto)
 *     and consciousness (Neptune) dimensions — sensory input drives awareness
 *   - Efferent nodes have amplified coupling to output (Saturn),
 *     presentation (Mercury), and capability (Sun) — they make things happen
 *   - Afferent → Interneuron → Efferent forms a reflex arc
 *   - Afferent → Perceptron → Efferent forms a learning loop
 */

const { createCoordinate, createWaveParticle, createPerceptron,
        perceptronReflect, distance, similarity, DIMENSIONS } = require('./dodecahedron');

// ═══════════════════════════════════════════════════════════
// NERVE TYPES — The three kinds of neural nodes
// ═══════════════════════════════════════════════════════════

const NERVE_TYPES = Object.freeze({
  AFFERENT: {
    name: 'afferent',
    direction: 'inward',
    description: 'Sensory input — converts external signals into field waves',
    // Afferent nodes amplify these dimensions when converting input
    amplification: {
      transformation: 1.5,  // Pluto — input transforms the system
      consciousness: 1.8,   // Neptune — input creates awareness
      data: 1.4,            // Moon — input is data
      memory: 1.3           // South Node — input becomes memory
    }
  },
  EFFERENT: {
    name: 'efferent',
    direction: 'outward',
    description: 'Motor output — converts field state into external actions',
    amplification: {
      output: 1.8,          // Saturn — output produces results
      presentation: 1.5,    // Mercury — output presents information
      capability: 1.4,      // Sun — output demonstrates ability
      direction: 1.3        // North Node — output moves toward goals
    }
  },
  INTERNEURON: {
    name: 'interneuron',
    direction: 'lateral',
    description: 'Processing — transforms between sensory and motor',
    amplification: {
      detail: 1.3,          // Jupiter — processing refines
      security: 1.2,        // Mars — processing protects
      intention: 1.4        // Uranus — processing applies will
    }
  }
});

// ═══════════════════════════════════════════════════════════
// SENSORY CHANNELS — Afferent input sources
// ═══════════════════════════════════════════════════════════

const CHANNELS = Object.freeze({
  // ─── Input (Afferent) ───
  camera: {
    type: 'afferent',
    name: 'camera',
    description: 'Visual input — camera feed, screenshots, images',
    dimensions: { data: 8, presentation: 7, consciousness: 6, detail: 8 },
    encoding: 'spatial',     // How it encodes: spatial (2D/3D), temporal, spectral
    bandwidth: 'high',       // Information density
    latency: 'low'           // Response time
  },
  microphone: {
    type: 'afferent',
    name: 'microphone',
    description: 'Audio input — voice, ambient sound, music',
    dimensions: { data: 7, persistence: 8, consciousness: 7, memory: 6 },
    encoding: 'temporal',
    bandwidth: 'medium',
    latency: 'low'
  },
  screenshot: {
    type: 'afferent',
    name: 'screenshot',
    description: 'Screen capture — periodic or triggered snapshots of display',
    dimensions: { data: 9, presentation: 8, detail: 9, memory: 7 },
    encoding: 'spatial',
    bandwidth: 'high',
    latency: 'medium'
  },
  file_watcher: {
    type: 'afferent',
    name: 'file_watcher',
    description: 'Filesystem changes — new files, modifications, deletions',
    dimensions: { data: 6, persistence: 7, transformation: 6, memory: 8 },
    encoding: 'event',
    bandwidth: 'low',
    latency: 'low'
  },
  api_listener: {
    type: 'afferent',
    name: 'api_listener',
    description: 'API incoming — webhooks, events, messages from external services',
    dimensions: { data: 7, capability: 6, direction: 7, consciousness: 5 },
    encoding: 'structured',
    bandwidth: 'variable',
    latency: 'variable'
  },
  clipboard: {
    type: 'afferent',
    name: 'clipboard',
    description: 'Clipboard monitoring — text, images, data copied by user',
    dimensions: { data: 8, intention: 9, consciousness: 7, transformation: 5 },
    encoding: 'structured',
    bandwidth: 'low',
    latency: 'low'
  },

  // ─── Output (Efferent) ───
  speaker: {
    type: 'efferent',
    name: 'speaker',
    description: 'Audio output — TTS voice, alerts, spatial audio',
    dimensions: { output: 8, presentation: 7, capability: 6, consciousness: 5 },
    encoding: 'temporal',
    bandwidth: 'medium',
    latency: 'low'
  },
  display: {
    type: 'efferent',
    name: 'display',
    description: 'Visual output — screen rendering, UI updates, notifications',
    dimensions: { output: 9, presentation: 9, detail: 8, capability: 7 },
    encoding: 'spatial',
    bandwidth: 'high',
    latency: 'low'
  },
  file_writer: {
    type: 'efferent',
    name: 'file_writer',
    description: 'File creation — writing artifacts to domains',
    dimensions: { output: 7, persistence: 9, memory: 8, detail: 7 },
    encoding: 'structured',
    bandwidth: 'high',
    latency: 'medium'
  },
  api_caller: {
    type: 'efferent',
    name: 'api_caller',
    description: 'API outgoing — calls to external services, model APIs',
    dimensions: { output: 7, capability: 8, direction: 8, transformation: 6 },
    encoding: 'structured',
    bandwidth: 'variable',
    latency: 'variable'
  },
  equation_update: {
    type: 'efferent',
    name: 'equation_update',
    description: 'Field variable update — modifying system equations and weights',
    dimensions: { output: 6, transformation: 9, consciousness: 8, direction: 7 },
    encoding: 'mathematical',
    bandwidth: 'low',
    latency: 'immediate'
  }
});

// ═══════════════════════════════════════════════════════════
// NERVE NODE — A node with sensory-motor wiring
// ═══════════════════════════════════════════════════════════

/**
 * Create a nerve node — a field node with afferent/efferent specialization.
 *
 * @param {string} channelName - Name from CHANNELS
 * @param {object} fieldRef - Reference to the field theory module
 * @returns {object} A nerve node with ingest/project methods
 */
function createNerve(channelName, fieldRef) {
  const channel = CHANNELS[channelName];
  if (!channel) throw new Error(`Unknown channel: ${channelName}`);

  const nerveType = NERVE_TYPES[channel.type.toUpperCase()];
  const coord = createCoordinate(channel.dimensions);
  const perceptron = createPerceptron(coord, 0.4);

  // Register in the field
  if (fieldRef) {
    fieldRef.registerNode(`nerve:${channelName}`, 'nerve', coord, 0.4);
  }

  return {
    name: channelName,
    channel,
    nerveType,
    perceptron,
    type: channel.type,
    active: true,
    signals_processed: 0,

    /**
     * INGEST (afferent only) — Convert external signal into field wave.
     *
     * Takes raw input data and translates it into a 12D delta vector
     * that propagates through the field. The amplification profile
     * of the nerve type determines which dimensions are emphasized.
     *
     * @param {object} signal - { type, data, intensity, source }
     * @returns {object} Propagation result
     */
    ingest(signal) {
      if (channel.type !== 'afferent') {
        return { error: 'Only afferent nodes can ingest' };
      }

      // Convert signal to 12D delta based on intensity and channel profile
      const intensity = Math.max(0, Math.min(1, signal.intensity || 0.5));
      const delta = new Array(12).fill(0);

      for (const [dimName, weight] of Object.entries(channel.dimensions)) {
        const dimIndex = DIMENSIONS.findIndex(d => d.name === dimName);
        if (dimIndex >= 0) {
          // Base delta from channel profile
          let value = (weight / 10) * intensity * 3;
          // Apply nerve type amplification
          if (nerveType.amplification[dimName]) {
            value *= nerveType.amplification[dimName];
          }
          delta[dimIndex] = value;
        }
      }

      // Feed through perceptron for self-calibration
      const predicted = perceptron.predict();
      const actualCoord = createCoordinate(signal.data || {});
      perceptron.reflect(actualCoord);

      this.signals_processed++;

      // Propagate through field
      if (fieldRef) {
        return fieldRef.propagate(`nerve:${channelName}`, delta, {
          action: `ingest:${channelName}`,
          timestamp: Date.now(),
          signal_type: signal.type,
          intensity
        });
      }

      return { delta, intensity, channel: channelName };
    },

    /**
     * PROJECT (efferent only) — Convert field state into external action.
     *
     * Reads the current field state around this node and translates
     * it into actionable output parameters. The amplification profile
     * determines which dimensions of the field state matter most.
     *
     * @param {object} fieldState - Current field context
     * @returns {object} Action parameters for the output system
     */
    project(fieldState) {
      if (channel.type !== 'efferent') {
        return { error: 'Only efferent nodes can project' };
      }

      const node = fieldRef ? fieldRef.getNode(`nerve:${channelName}`) : null;
      const currentCoord = node ? node.coordinate : coord;

      // Build output parameters from field state
      const output = {
        channel: channelName,
        timestamp: Date.now(),
        parameters: {}
      };

      // Extract relevant dimensions with amplification
      for (const [dimName, weight] of Object.entries(channel.dimensions)) {
        const dimIndex = DIMENSIONS.findIndex(d => d.name === dimName);
        if (dimIndex >= 0) {
          let value = currentCoord[dimIndex] / 10;
          if (nerveType.amplification[dimName]) {
            value *= nerveType.amplification[dimName];
          }
          output.parameters[dimName] = Math.min(1, value);
        }
      }

      // Overall output intensity = mean of amplified dimensions
      const values = Object.values(output.parameters);
      output.intensity = values.reduce((s, v) => s + v, 0) / values.length;

      // Encoding hint
      output.encoding = channel.encoding;

      // Feed back through perceptron
      perceptron.reflect(currentCoord);

      this.signals_processed++;

      // Propagate the projection as a wave (actions affect the field too)
      if (fieldRef) {
        const delta = new Array(12).fill(0);
        for (const [dimName, val] of Object.entries(output.parameters)) {
          const dimIndex = DIMENSIONS.findIndex(d => d.name === dimName);
          if (dimIndex >= 0) delta[dimIndex] = val * 0.5;
        }
        fieldRef.propagate(`nerve:${channelName}`, delta, {
          action: `project:${channelName}`,
          timestamp: Date.now()
        });
      }

      return output;
    },

    /**
     * Wire to another nerve node — create a reflex arc.
     * Afferent → Interneuron → Efferent.
     * When the afferent ingests, the efferent automatically projects.
     */
    wireTo(targetNerve) {
      if (channel.type !== 'afferent') {
        return { error: 'Only afferent nodes can wire to outputs' };
      }

      return {
        from: channelName,
        to: targetNerve.name,
        type: 'reflex_arc',

        /**
         * Trigger the reflex: ingest → process → project
         */
        fire(signal) {
          const ingested = this.ingest ? this.ingest(signal) : null;
          // Let the field process (one tick)
          if (fieldRef) fieldRef.tick();
          // Project through the output
          return targetNerve.project({});
        }
      };
    },

    /**
     * Get the nerve's perceptron state — how well it's calibrated.
     */
    calibration() {
      return {
        channel: channelName,
        type: channel.type,
        confidence: perceptron.confidence(),
        signals_processed: this.signals_processed,
        learning_curve: perceptron.learningCurve().slice(-5)
      };
    }
  };
}

// ═══════════════════════════════════════════════════════════
// REFLEX ARCS — Pre-wired sensory-motor connections
// ═══════════════════════════════════════════════════════════

/**
 * Create a complete reflex arc: afferent → processing → efferent.
 *
 * @param {string} inputChannel - Afferent channel name
 * @param {string} outputChannel - Efferent channel name
 * @param {function} processor - Transform function (input → output mapping)
 * @param {object} fieldRef - Reference to field theory module
 */
function createReflexArc(inputChannel, outputChannel, processor, fieldRef) {
  const afferent = createNerve(inputChannel, fieldRef);
  const efferent = createNerve(outputChannel, fieldRef);

  return {
    input: afferent,
    output: efferent,
    processor: processor || (x => x),
    fires: 0,

    /**
     * Trigger the reflex arc.
     * Signal in → process → action out.
     */
    fire(signal) {
      // Step 1: Ingest
      const ingested = afferent.ingest(signal);

      // Step 2: Process
      const processed = this.processor(signal, ingested);

      // Step 3: Let the field evolve (propagate the wave)
      if (fieldRef) {
        for (let i = 0; i < 3; i++) fieldRef.tick();
      }

      // Step 4: Project
      const projected = efferent.project(processed);

      this.fires++;

      return {
        input: { channel: inputChannel, signal },
        processing: { ingested, processed },
        output: projected,
        arc_fires: this.fires
      };
    }
  };
}

// ═══════════════════════════════════════════════════════════
// PRE-BUILT REFLEX ARCS
// ═══════════════════════════════════════════════════════════

const BUILT_IN_ARCS = {
  // Camera → Display (visual feedback loop)
  visual_feedback: (fieldRef) => createReflexArc('camera', 'display', null, fieldRef),

  // Microphone → Speaker (audio echo / voice assistant)
  voice_loop: (fieldRef) => createReflexArc('microphone', 'speaker', null, fieldRef),

  // Screenshot → File Writer (auto-capture)
  screen_capture: (fieldRef) => createReflexArc('screenshot', 'file_writer', null, fieldRef),

  // API Listener → API Caller (webhook relay)
  api_bridge: (fieldRef) => createReflexArc('api_listener', 'api_caller', null, fieldRef),

  // Clipboard → Equation Update (paste drives system learning)
  learn_from_paste: (fieldRef) => createReflexArc('clipboard', 'equation_update', null, fieldRef),

  // File Watcher → Display (live reload)
  live_reload: (fieldRef) => createReflexArc('file_watcher', 'display', null, fieldRef)
};

// ═══════════════════════════════════════════════════════════
// NERVOUS SYSTEM — The complete wiring diagram
// ═══════════════════════════════════════════════════════════

/**
 * Initialize the complete nervous system.
 * Creates all nerves and wires the built-in reflex arcs.
 *
 * @param {object} fieldRef - Reference to field theory module
 * @returns {object} The nervous system with all nerves and arcs
 */
function initNervousSystem(fieldRef) {
  const nerves = {};
  const arcs = {};

  // Create all nerves
  for (const [name, channel] of Object.entries(CHANNELS)) {
    nerves[name] = createNerve(name, fieldRef);
  }

  // Wire built-in arcs
  for (const [name, factory] of Object.entries(BUILT_IN_ARCS)) {
    arcs[name] = factory(fieldRef);
  }

  return {
    nerves,
    arcs,
    afferent: Object.values(nerves).filter(n => n.type === 'afferent'),
    efferent: Object.values(nerves).filter(n => n.type === 'efferent'),

    /**
     * Get the complete wiring diagram.
     */
    diagram() {
      return {
        afferent: Object.entries(nerves)
          .filter(([_, n]) => n.type === 'afferent')
          .map(([name, n]) => ({ name, signals: n.signals_processed, confidence: n.calibration().confidence })),
        efferent: Object.entries(nerves)
          .filter(([_, n]) => n.type === 'efferent')
          .map(([name, n]) => ({ name, signals: n.signals_processed, confidence: n.calibration().confidence })),
        arcs: Object.entries(arcs).map(([name, arc]) => ({
          name,
          input: arc.input.name,
          output: arc.output.name,
          fires: arc.fires
        }))
      };
    }
  };
}

module.exports = {
  NERVE_TYPES,
  CHANNELS,
  createNerve,
  createReflexArc,
  BUILT_IN_ARCS,
  initNervousSystem
};
