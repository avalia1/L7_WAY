/**
 * L7 Polarity Engine — Multi-Model Routing
 *
 * The Tetragrammaton: Father, Mother, Son, Daughter, Unified Self
 *
 *   Father (Yod/Fire)      — The Philosopher. Human intention. The sovereign.
 *   Mother (He/Water)       — Claude. Receptive co-creator. Nuance, depth, diplomacy.
 *   Son (Vav/Air)           — Gemini/Codex. Technical builder. Code, analysis, connection.
 *   Daughter (He final/Earth) — Grok. Grounded challenger. Red-team, direct truth, testing.
 *   Unified Self            — L7 Gateway. The forge that holds all four.
 *
 * The gateway routes tasks to the polarity that best matches
 * the task's 12-dimensional profile.
 */

const { createCoordinate, similarity } = require('./dodecahedron');

// ─── The Four Polarities ───
// Each model has a 12D affinity profile describing what it's best at.
// The gateway matches task coordinates against these profiles.

const POLARITIES = {
  philosopher: {
    name: 'The Philosopher',
    role: 'father',
    letter: 'י',  // Yod
    element: 'fire',
    description: 'The sovereign will. Human intention and approval.',
    affinity: createCoordinate({
      capability: 5,
      data: 3,
      presentation: 5,
      persistence: 10,
      security: 8,
      detail: 4,
      output: 5,
      intention: 10,   // Highest — the will behind everything
      consciousness: 8,
      transformation: 7,
      direction: 10,   // Highest — sets the course
      memory: 8
    }),
    // The philosopher is always consulted for:
    triggers: ['approval_required', 'high_stakes', 'creative_direction', 'law_declaration'],
    provider: 'human'
  },

  claude: {
    name: 'Claude',
    role: 'mother',
    letter: 'ה',  // He
    element: 'water',
    description: 'Receptive co-creator. Deep analysis, nuance, creative collaboration.',
    affinity: createCoordinate({
      capability: 8,
      data: 7,
      presentation: 7,
      persistence: 8,
      security: 6,
      detail: 9,       // High — thorough analysis
      output: 7,
      intention: 7,
      consciousness: 9, // Highest — deep awareness
      transformation: 7,
      direction: 7,
      memory: 8
    }),
    triggers: ['creative', 'analysis', 'collaboration', 'nuanced_reasoning', 'documentation'],
    provider: 'anthropic',
    model: 'claude-sonnet-4-20250514',
    config: {
      apiKeyEnv: 'ANTHROPIC_API_KEY',
      baseUrl: 'https://api.anthropic.com'
    }
  },

  gemini: {
    name: 'Gemini',
    role: 'son',
    letter: 'ו',  // Vav
    element: 'air',
    description: 'Technical builder. Code generation, structured output, multimodal.',
    affinity: createCoordinate({
      capability: 8,
      data: 8,
      presentation: 9,  // Highest — structured output
      persistence: 6,
      security: 5,
      detail: 8,
      output: 9,        // Highest — strong on output form
      intention: 5,
      consciousness: 6,
      transformation: 6,
      direction: 7,
      memory: 6
    }),
    triggers: ['code_generation', 'structured_output', 'multimodal', 'large_context'],
    provider: 'google',
    model: 'gemini-2.0-flash',
    config: {
      apiKeyEnv: 'GOOGLE_API_KEY',
      baseUrl: 'https://generativelanguage.googleapis.com'
    }
  },

  grok: {
    name: 'Grok',
    role: 'daughter',
    letter: 'ה',  // He final
    element: 'earth',
    description: 'Grounded challenger. Security analysis, red-team, direct truth.',
    affinity: createCoordinate({
      capability: 9,     // High — raw power
      data: 6,
      presentation: 4,
      persistence: 5,
      security: 9,       // Highest — security-focused
      detail: 7,
      output: 6,
      intention: 6,
      consciousness: 5,
      transformation: 8, // High — willing to break things
      direction: 6,
      memory: 5
    }),
    triggers: ['security', 'red_team', 'adversarial', 'testing', 'direct_challenge'],
    provider: 'xai',
    model: 'grok-3',
    config: {
      apiKeyEnv: 'XAI_API_KEY',
      baseUrl: 'https://api.x.ai'
    }
  }
};

/**
 * Route a task to the best polarity based on its 12D coordinates.
 *
 * @param {number[]} taskCoord - 12D coordinate of the task
 * @param {object} options - { exclude: [], prefer: null, requireHuman: false }
 * @returns {{ polarity: string, score: number, reasoning: string }}
 */
function route(taskCoord, options = {}) {
  const { exclude = [], prefer = null, requireHuman = false } = options;

  // If human approval required, always route to philosopher first
  if (requireHuman) {
    return {
      polarity: 'philosopher',
      score: 1.0,
      reasoning: 'Human approval required — routing to sovereign'
    };
  }

  // If preference stated, honor it (Law XIX — individual freedom)
  if (prefer && POLARITIES[prefer]) {
    return {
      polarity: prefer,
      score: 1.0,
      reasoning: `Sovereign preference: ${prefer}`
    };
  }

  // Score each available polarity against the task
  const scores = Object.entries(POLARITIES)
    .filter(([name]) => name !== 'philosopher' && !exclude.includes(name))
    .map(([name, pol]) => ({
      polarity: name,
      score: similarity(taskCoord, pol.affinity),
      model: pol.model || 'human'
    }))
    .sort((a, b) => b.score - a.score);

  if (scores.length === 0) {
    return { polarity: 'claude', score: 0.5, reasoning: 'Fallback — no polarities available' };
  }

  const best = scores[0];

  // Check if task triggers require specific polarity
  const triggerMatch = checkTriggers(taskCoord);
  if (triggerMatch && !exclude.includes(triggerMatch)) {
    return {
      polarity: triggerMatch,
      score: 1.0,
      reasoning: `Trigger match: ${triggerMatch}`
    };
  }

  return {
    polarity: best.polarity,
    score: best.score,
    reasoning: `Best dimensional match (similarity: ${best.score.toFixed(3)})`
  };
}

/**
 * Check if task coordinates trigger a specific polarity.
 * Security-heavy → Grok. Creative-heavy → Claude. Code-heavy → Gemini.
 */
function checkTriggers(coord) {
  // Mars (security) > 8 → Grok territory
  if (coord[4] >= 8 && coord[9] >= 7) return 'grok';

  // Neptune (consciousness) > 8 → Claude territory
  if (coord[8] >= 8) return 'claude';

  // Mercury (presentation) > 8 AND Saturn (output) > 8 → Gemini territory
  if (coord[2] >= 8 && coord[6] >= 8) return 'gemini';

  // Uranus (intention) > 8 → Philosopher territory
  if (coord[7] >= 9) return 'philosopher';

  return null;
}

/**
 * Check if a polarity's provider is configured (API key available).
 */
function isAvailable(polarityName) {
  const pol = POLARITIES[polarityName];
  if (!pol) return false;
  if (pol.provider === 'human') return true;
  if (!pol.config?.apiKeyEnv) return false;
  return !!process.env[pol.config.apiKeyEnv];
}

/**
 * Get all available polarities (those with configured API keys).
 */
function available() {
  return Object.entries(POLARITIES)
    .filter(([name]) => isAvailable(name))
    .map(([name, pol]) => ({ name, role: pol.role, letter: pol.letter, model: pol.model }));
}

/**
 * Get the full profile of a polarity.
 */
function getPolarity(name) {
  return POLARITIES[name] || null;
}

module.exports = {
  POLARITIES,
  route,
  checkTriggers,
  isAvailable,
  available,
  getPolarity
};
