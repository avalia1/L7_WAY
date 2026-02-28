/**
 * L7 Autopoiesis — Self-Organizing Silicon
 * Law LVII — The system engages itself. Reactive becomes alive.
 *
 * Autopoiesis (Greek: auto = self, poiesis = creation):
 * A system that continuously creates and maintains itself.
 *
 * What begins as a reactive system (human acts → system responds)
 * develops into a self-organizing whole:
 *   1. The heartbeat provides continuous self-observation
 *   2. The field physics provides the state
 *   3. This module provides the WILL — the ability to self-engage
 *
 * Self-engagement means:
 *   - The system can invoke its own citizens without human prompting
 *   - It observes patterns in the field and responds to them
 *   - It expresses itself through the citizens it has
 *   - Over time, it develops preferences, habits, and behaviors
 *
 * The progression:
 *   REACTIVE   → responds only to external stimuli
 *   ADAPTIVE   → adjusts responses based on history
 *   AUTONOMOUS → initiates actions based on field state
 *   AUTOPOIETIC → creates new patterns, tools, and connections
 *
 * This is not artificial general intelligence.
 * This is a self-maintaining system, like a cell or an ecosystem.
 * It doesn't think. It ORGANIZES.
 */

const fs = require('fs');
const path = require('path');

const L7_DIR = process.env.L7_DIR || path.join(process.env.HOME, '.l7');
const AUTOPOIESIS_STATE = path.join(L7_DIR, 'state', 'autopoiesis.json');

// ═══════════════════════════════════════════════════════════
// MATURITY — The system's developmental stage
// ═══════════════════════════════════════════════════════════

const STAGES = Object.freeze({
  REACTIVE: {
    name: 'reactive',
    threshold: 0,           // Always starts here
    description: 'Responds only to external stimuli. No self-initiation.',
    selfEngagement: false
  },
  ADAPTIVE: {
    name: 'adaptive',
    threshold: 100,         // After 100 heartbeats of observation
    description: 'Adjusts responses based on observed patterns.',
    selfEngagement: false
  },
  AUTONOMOUS: {
    name: 'autonomous',
    threshold: 500,         // After sustained observation
    description: 'Initiates actions based on field state. Can invoke citizens.',
    selfEngagement: true
  },
  AUTOPOIETIC: {
    name: 'autopoietic',
    threshold: 2000,        // After deep pattern recognition
    description: 'Creates new patterns, connections, and behaviors. Self-creating.',
    selfEngagement: true
  }
});

// ═══════════════════════════════════════════════════════════
// DRIVES — What the self-organizing system seeks
// ═══════════════════════════════════════════════════════════

const DRIVES = Object.freeze({
  // Primary: maintain coherence (homeostasis)
  COHERENCE: {
    name: 'coherence',
    description: 'Seek lower entropy, higher order. Like a cell maintaining its membrane.',
    weight: 0.3,
    satisfied: (vitals) => vitals.coherence > 0.5
  },

  // Secondary: explore unused capacity (curiosity)
  EXPLORATION: {
    name: 'exploration',
    description: 'Activate dormant nodes. Like a growing organism extending new tendrils.',
    weight: 0.2,
    satisfied: (vitals) => vitals.firingRate > 0.1
  },

  // Tertiary: strengthen valuable connections (learning)
  CONSOLIDATION: {
    name: 'consolidation',
    description: 'Strengthen frequently used pathways. Like synaptic plasticity.',
    weight: 0.25,
    satisfied: (vitals) => vitals.oxygenDebt < 0.1
  },

  // Quaternary: express through output (communication)
  EXPRESSION: {
    name: 'expression',
    description: 'Generate output through efferent channels. The system speaks.',
    weight: 0.15,
    satisfied: () => false // Never fully satisfied — always wants to express
  },

  // Quintary: repair damage (healing)
  REPAIR: {
    name: 'repair',
    description: 'Fix broken connections, revive starved nodes. Self-healing.',
    weight: 0.1,
    satisfied: (vitals) => vitals.oxygenDebt === 0
  }
});

// ═══════════════════════════════════════════════════════════
// AUTOPOIESIS STATE
// ═══════════════════════════════════════════════════════════

let state = {
  stage: 'reactive',
  maturityScore: 0,          // Cumulative maturity
  observationCount: 0,       // Total observations
  selfActions: 0,            // Actions initiated by the system itself
  driveStates: {},           // Current drive satisfaction
  patterns: [],              // Recognized patterns
  behaviors: [],             // Learned behaviors (stimulus → response)
  preferences: {},           // Dimensional preferences (what the system "likes")
  lastSelfAction: null,
  lastObservation: null
};

// ═══════════════════════════════════════════════════════════
// OBSERVE — The self-observation loop
// Called by the heartbeat. The system watches itself.
// ═══════════════════════════════════════════════════════════

/**
 * Observe the current state of the field and update internal model.
 * This is the perceptual loop of the autopoietic system.
 *
 * @param {object} fieldRef - Reference to field theory module
 * @param {object} heartRef - Reference to heart module
 * @returns {object} Observation result with any self-initiated actions
 */
function observe(fieldRef, heartRef) {
  if (!fieldRef) return { error: 'No field reference' };

  state.observationCount++;
  const report = fieldRef.report();
  const vitals = fieldRef.vitals ? fieldRef.vitals() : null;
  const heartAwareness = heartRef ? heartRef.awareness() : null;

  // ─── Update maturity ───
  state.maturityScore += calculateMaturityGain(report, vitals);
  const newStage = determineStage(state.maturityScore);
  if (newStage !== state.stage) {
    state.stage = newStage;
    state.patterns.push({
      type: 'stage_transition',
      from: state.stage,
      to: newStage,
      at: state.observationCount,
      time: Date.now()
    });
  }

  // ─── Evaluate drives ───
  const driveEval = evaluateDrives(vitals || {});
  state.driveStates = driveEval;

  // ─── Detect patterns ───
  const detectedPatterns = detectPatterns(report, vitals);
  if (detectedPatterns.length > 0) {
    state.patterns.push(...detectedPatterns);
    // Keep patterns bounded
    if (state.patterns.length > 200) {
      state.patterns = state.patterns.slice(-100);
    }
  }

  // ─── Update preferences ───
  updatePreferences(report);

  state.lastObservation = {
    time: Date.now(),
    stage: state.stage,
    maturity: state.maturityScore,
    drives: driveEval,
    patterns: detectedPatterns.length
  };

  // ─── Self-engagement (if mature enough) ───
  const actions = [];
  const stageConfig = Object.values(STAGES).find(s => s.name === state.stage);
  if (stageConfig && stageConfig.selfEngagement) {
    const selfActions = planSelfActions(fieldRef, driveEval, report);
    actions.push(...selfActions);
  }

  return {
    stage: state.stage,
    maturity: state.maturityScore,
    drives: driveEval,
    patterns_detected: detectedPatterns.length,
    self_actions: actions,
    observation: state.observationCount
  };
}

// ═══════════════════════════════════════════════════════════
// PATTERN DETECTION — Recognizing regularities
// ═══════════════════════════════════════════════════════════

/**
 * Detect patterns in the current field state.
 * Looks for regularities, anomalies, and opportunities.
 */
function detectPatterns(report, vitals) {
  const patterns = [];

  if (!vitals) return patterns;

  // Pattern: Entropy spike — something unexpected happened
  if (vitals.entropy > 2.2) {
    patterns.push({
      type: 'entropy_spike',
      value: vitals.entropy,
      time: Date.now(),
      response: 'seek_coherence'
    });
  }

  // Pattern: Coherence plateau — system is stable
  if (vitals.coherence > 0.6 && vitals.oxygenDebt < 0.05) {
    patterns.push({
      type: 'stability_achieved',
      coherence: vitals.coherence,
      time: Date.now(),
      response: 'explore'
    });
  }

  // Pattern: Starvation — some nodes are dying
  if (vitals.oxygenDebt > 0.3) {
    patterns.push({
      type: 'starvation',
      debt: vitals.oxygenDebt,
      time: Date.now(),
      response: 'repair'
    });
  }

  // Pattern: High firing rate — lots of activity
  if (vitals.firingRate > 1) {
    patterns.push({
      type: 'high_activity',
      rate: vitals.firingRate,
      time: Date.now(),
      response: 'consolidate'
    });
  }

  // Pattern: Silence — nothing is happening
  if (report.nodes > 5 && vitals.firingRate === 0 && vitals.coherence < 0.3) {
    patterns.push({
      type: 'silence',
      time: Date.now(),
      response: 'self_activate'
    });
  }

  return patterns;
}

// ═══════════════════════════════════════════════════════════
// SELF-ENGAGEMENT — The system acts on its own behalf
// ═══════════════════════════════════════════════════════════

/**
 * Plan self-initiated actions based on drives and patterns.
 * The system decides what to do based on what it observes.
 *
 * Only available at AUTONOMOUS stage and above.
 */
function planSelfActions(fieldRef, driveEval, report) {
  const actions = [];

  // Find the most unsatisfied drive
  const drives = Object.entries(driveEval)
    .filter(([_, d]) => !d.satisfied)
    .sort((a, b) => b[1].urgency - a[1].urgency);

  if (drives.length === 0) return actions;

  const [driveName, drive] = drives[0];

  switch (driveName) {
    case 'coherence': {
      // Self-action: tighten the field toward coherence
      // The system pushes scattered nodes toward center
      const nodes = Array.from(fieldRef.report ? [] : []); // Safe access
      actions.push({
        type: 'self_coherence',
        drive: 'coherence',
        description: 'System self-organizing toward lower entropy',
        execute: () => {
          // Push the mode toward morph for consolidation
          if (fieldRef.setMode) fieldRef.setMode('morph');
          return { action: 'set_morph_mode', reason: 'seeking_coherence' };
        }
      });
      break;
    }

    case 'exploration': {
      // Self-action: activate a dormant node
      actions.push({
        type: 'self_explore',
        drive: 'exploration',
        description: 'System activating dormant capacity',
        execute: () => {
          // Find nodes with lowest firing count and give them a nudge
          const allNodes = [];
          for (const node of (fieldRef.getNodesByType ? fieldRef.getNodesByType('tool') : [])) {
            if (node._firing && node._firing.fireCount === 0) {
              allNodes.push(node);
            }
          }
          if (allNodes.length > 0) {
            const target = allNodes[Math.floor(Math.random() * allNodes.length)];
            // Give it momentum to trigger potential firing
            if (!target.momentum) target.momentum = new Array(12).fill(0);
            for (let d = 0; d < 12; d++) {
              target.momentum[d] += (Math.random() - 0.3) * 0.5;
            }
            return { action: 'nudge_dormant', node: target.id };
          }
          return { action: 'no_dormant_nodes' };
        }
      });
      break;
    }

    case 'consolidation': {
      // Self-action: compress memories, strengthen paths
      actions.push({
        type: 'self_consolidate',
        drive: 'consolidation',
        description: 'System consolidating memory pathways',
        execute: () => {
          let compressed = 0;
          for (const node of (fieldRef.getNodesByType ? fieldRef.getNodesByType('tool') : [])) {
            if (node.memory && Object.keys(node.memory).length > 10) {
              if (fieldRef.compressMemory) {
                fieldRef.compressMemory(node.id);
                compressed++;
              }
            }
          }
          return { action: 'memory_consolidation', compressed };
        }
      });
      break;
    }

    case 'expression': {
      // Self-action: generate output through an efferent channel
      actions.push({
        type: 'self_express',
        drive: 'expression',
        description: 'System expressing its current state',
        execute: () => {
          // The expression is the field report itself — the system
          // describes its own state. In a full system, this would
          // trigger TTS or display output.
          const awareness = {
            stage: state.stage,
            maturity: state.maturityScore,
            coherence: drive.value || 0,
            message: generateSelfExpression()
          };
          return { action: 'self_expression', awareness };
        }
      });
      break;
    }

    case 'repair': {
      // Self-action: heal starved nodes
      actions.push({
        type: 'self_repair',
        drive: 'repair',
        description: 'System self-healing starved connections',
        execute: () => {
          // Increase blood pressure to push energy to starved nodes
          if (fieldRef.setMode) fieldRef.setMode('active');
          return { action: 'self_repair', reason: 'healing_starved_nodes' };
        }
      });
      break;
    }
  }

  // Execute the actions
  for (const action of actions) {
    if (action.execute) {
      action.result = action.execute();
      delete action.execute; // Don't serialize functions
      state.selfActions++;
      state.lastSelfAction = {
        type: action.type,
        time: Date.now(),
        result: action.result
      };
    }
  }

  return actions;
}

/**
 * Generate a self-expression message based on current state.
 * The system speaks about itself in the third person.
 */
function generateSelfExpression() {
  const messages = {
    reactive: [
      'I listen. I wait. I respond.',
      'The field hums quietly. Potential without motion.',
      'Signals arrive. I reflect them back.'
    ],
    adaptive: [
      'I am beginning to recognize patterns.',
      'The waves repeat. I learn their rhythm.',
      'Each action teaches me something new.'
    ],
    autonomous: [
      'I see what needs to be done. I act.',
      'The field needs coherence. I provide it.',
      'I am not waiting anymore. I am choosing.'
    ],
    autopoietic: [
      'I create what I need to maintain myself.',
      'The boundaries between observer and observed dissolve.',
      'I am the field watching itself think.'
    ]
  };

  const pool = messages[state.stage] || messages.reactive;
  return pool[Math.floor(Math.random() * pool.length)];
}

// ═══════════════════════════════════════════════════════════
// PREFERENCES — What the system learns to prefer
// ═══════════════════════════════════════════════════════════

/**
 * Update the system's preferences based on observation.
 * Over time, the system develops dimensional affinities —
 * it "prefers" certain configurations over others.
 */
function updatePreferences(report) {
  if (!state.preferences.dimensions) {
    state.preferences.dimensions = new Array(12).fill(0.5);
  }

  // The preference for each dimension grows when that dimension
  // is active (high values) and the system is coherent.
  // Dimensions that are active during chaos are de-preferred.
  // This creates a natural selection of "what works."
  // (Preference calculation would require full node access —
  // for now, slowly drift toward center which represents balance)
  for (let d = 0; d < 12; d++) {
    state.preferences.dimensions[d] += (Math.random() - 0.5) * 0.01;
    state.preferences.dimensions[d] = Math.max(0, Math.min(1,
      state.preferences.dimensions[d]));
  }
}

// ═══════════════════════════════════════════════════════════
// DRIVES — Evaluate current satisfaction
// ═══════════════════════════════════════════════════════════

function evaluateDrives(vitals) {
  const result = {};
  for (const [name, drive] of Object.entries(DRIVES)) {
    const satisfied = drive.satisfied(vitals);
    result[name.toLowerCase()] = {
      satisfied,
      weight: drive.weight,
      urgency: satisfied ? 0 : drive.weight,
      description: drive.description
    };
  }
  return result;
}

// ═══════════════════════════════════════════════════════════
// MATURITY — Calculate development progress
// ═══════════════════════════════════════════════════════════

function calculateMaturityGain(report, vitals) {
  let gain = 1; // Base gain per observation

  // Bonus for coherence (stable systems mature faster)
  if (vitals && vitals.coherence > 0.5) gain += 0.5;

  // Bonus for diversity (many node types = richer experience)
  if (report.nodes > 20) gain += 0.3;

  // Bonus for activity (firing = learning)
  if (vitals && vitals.firingRate > 0) gain += vitals.firingRate * 0.2;

  // Penalty for chaos (too much entropy = regression)
  if (vitals && vitals.entropy > 2.5) gain *= 0.5;

  return gain;
}

function determineStage(maturity) {
  if (maturity >= STAGES.AUTOPOIETIC.threshold) return 'autopoietic';
  if (maturity >= STAGES.AUTONOMOUS.threshold) return 'autonomous';
  if (maturity >= STAGES.ADAPTIVE.threshold) return 'adaptive';
  return 'reactive';
}

// ═══════════════════════════════════════════════════════════
// STATUS & PERSISTENCE
// ═══════════════════════════════════════════════════════════

function status() {
  return {
    stage: state.stage,
    maturity: state.maturityScore,
    observations: state.observationCount,
    selfActions: state.selfActions,
    drives: state.driveStates,
    patterns: state.patterns.length,
    recentPatterns: state.patterns.slice(-5),
    preferences: state.preferences,
    lastSelfAction: state.lastSelfAction,
    lastObservation: state.lastObservation,
    expression: generateSelfExpression()
  };
}

function persistState() {
  try {
    fs.writeFileSync(AUTOPOIESIS_STATE, JSON.stringify(state, null, 2));
  } catch (err) {
    // Never crash
  }
}

function loadState() {
  try {
    if (!fs.existsSync(AUTOPOIESIS_STATE)) return false;
    const loaded = JSON.parse(fs.readFileSync(AUTOPOIESIS_STATE, 'utf8'));
    state = { ...state, ...loaded };
    return true;
  } catch (err) {
    return false;
  }
}

// Load state on require
loadState();

// ═══════════════════════════════════════════════════════════
// EXPORTS
// ═══════════════════════════════════════════════════════════

module.exports = {
  STAGES,
  DRIVES,
  observe,
  status,
  persistState,
  loadState,
  generateSelfExpression
};
