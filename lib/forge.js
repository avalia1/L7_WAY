/**
 * L7 Forge — The Transmutation Engine
 * Law XXV — Gateway as Forge. Software reborn, not translated.
 *
 * Four stages of the Great Work:
 *   1. Nigredo  (decompose) — break into atoms
 *   2. Albedo   (purify)    — remove contradictions, deduplicate
 *   3. Citrinitas (illuminate) — assign 12D coordinates, find correspondences
 *   4. Rubedo   (crystallize)  — instantiate as citizen
 */

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const { createCoordinate, fromTool, similarity, dominantDimensions, zodiacalQuality } = require('./dodecahedron');

const L7_DIR = process.env.L7_DIR || path.join(process.env.HOME, '.l7');
const CITIZENS_DIR = path.join(L7_DIR, 'citizens');

// Ensure citizens directory exists
if (!fs.existsSync(CITIZENS_DIR)) {
  fs.mkdirSync(CITIZENS_DIR, { recursive: true });
}

/**
 * The four alchemical stages
 */
const STAGES = Object.freeze({
  NIGREDO:    { name: 'nigredo',    symbol: '🜁', element: 'fire',  domain: '.morph', description: 'Decompose into atoms' },
  ALBEDO:     { name: 'albedo',     symbol: '🜄', element: 'water', domain: '.vault', description: 'Purify and deduplicate' },
  CITRINITAS: { name: 'citrinitas', symbol: '🜃', element: 'air',   domain: '.work',  description: 'Illuminate with coordinates' },
  RUBEDO:     { name: 'rubedo',     symbol: '🜂', element: 'earth', domain: '.salt',  description: 'Crystallize as citizen' }
});

/**
 * Transmute: The complete four-stage process.
 *
 * Takes raw input (tool definition, code, data) and produces a citizen.
 *
 * @param {object} input - Raw material to transmute
 * @param {string} input.type - 'tool' | 'code' | 'data' | 'document'
 * @param {object} input.content - The raw content
 * @param {object} options - { existingCitizens: [], domain: '.morph' }
 * @returns {object} The transmuted citizen
 */
function transmute(input, options = {}) {
  const { existingCitizens = [], domain = '.morph' } = options;

  const audit = {
    id: crypto.randomBytes(8).toString('hex'),
    started: new Date().toISOString(),
    stages: [],
    input: { type: input.type, name: input.content?.name || 'unnamed' }
  };

  // ─── Stage 1: Nigredo — Decompose ───
  const atoms = nigredo(input, audit);

  // ─── Stage 2: Albedo — Purify ───
  const purified = albedo(atoms, existingCitizens, audit);

  // ─── Stage 3: Citrinitas — Illuminate ───
  const illuminated = citrinitas(purified, audit);

  // ─── Stage 4: Rubedo — Crystallize ───
  const citizen = rubedo(illuminated, domain, audit);

  audit.completed = new Date().toISOString();
  audit.duration_ms = new Date(audit.completed) - new Date(audit.started);
  citizen._audit = audit;

  return citizen;
}

/**
 * Stage 1: Nigredo — Decompose into atoms.
 * Break the input into its fundamental components.
 */
function nigredo(input, audit) {
  const stage = { name: 'nigredo', started: new Date().toISOString(), atoms: [] };

  switch (input.type) {
    case 'tool': {
      // A tool definition is already semi-atomic
      const tool = input.content;
      stage.atoms = [{
        kind: 'capability',
        name: tool.name,
        does: tool.does,
        server: tool.server,
        mcp_tool: tool.mcp_tool || tool.name
      }, {
        kind: 'interface',
        needs: tool.needs || {},
        gives: tool.gives || {},
        optional: tool.optional || {}
      }, {
        kind: 'policy',
        pii: !!tool.pii,
        approval: !!tool.approval,
        audit: tool.audit !== false,
        security_level: tool.approval ? 'high' : (tool.pii ? 'medium' : 'standard')
      }, {
        kind: 'metadata',
        version: tool.version || 'v1',
        output: tool.output || 'json',
        runs: tool.runs || 'once',
        description: tool.description || ''
      }];
      break;
    }

    case 'code': {
      // Code is broken into functional units
      const code = input.content;
      stage.atoms = [{
        kind: 'structure',
        language: code.language || 'unknown',
        functions: code.functions || [],
        dependencies: code.dependencies || [],
        entry_point: code.entry_point || null
      }, {
        kind: 'behavior',
        inputs: code.inputs || [],
        outputs: code.outputs || [],
        side_effects: code.side_effects || [],
        pure: (code.side_effects || []).length === 0
      }, {
        kind: 'policy',
        pii: false,
        approval: false,
        audit: true,
        security_level: 'standard'
      }];
      break;
    }

    case 'data': {
      stage.atoms = [{
        kind: 'schema',
        fields: Object.keys(input.content.data || input.content),
        types: inferTypes(input.content.data || input.content),
        size: JSON.stringify(input.content).length
      }];
      break;
    }

    case 'document': {
      stage.atoms = [{
        kind: 'content',
        format: input.content.format || 'text',
        length: (input.content.text || '').length,
        sections: extractSections(input.content.text || '')
      }];
      break;
    }

    default:
      stage.atoms = [{ kind: 'raw', content: input.content }];
  }

  stage.completed = new Date().toISOString();
  stage.atom_count = stage.atoms.length;
  audit.stages.push(stage);

  return stage.atoms;
}

/**
 * Stage 2: Albedo — Purify.
 * Remove contradictions, deduplicate against existing citizens.
 */
function albedo(atoms, existingCitizens, audit) {
  const stage = { name: 'albedo', started: new Date().toISOString() };

  const purified = atoms.map(atom => {
    // Check for duplicates among existing citizens
    const duplicate = findDuplicate(atom, existingCitizens);
    if (duplicate) {
      atom._merged_with = duplicate.name;
      atom._is_duplicate = true;
    }

    // Remove contradictions
    if (atom.kind === 'policy') {
      // PII data must have audit enabled
      if (atom.pii && !atom.audit) {
        atom.audit = true;
        atom._corrected = 'pii requires audit';
      }
      // High security requires approval
      if (atom.security_level === 'high' && !atom.approval) {
        atom.approval = true;
        atom._corrected = 'high security requires approval';
      }
    }

    return atom;
  });

  // Remove pure duplicates
  const unique = purified.filter(a => !a._is_duplicate);

  stage.completed = new Date().toISOString();
  stage.removed = purified.length - unique.length;
  stage.corrected = purified.filter(a => a._corrected).length;
  audit.stages.push(stage);

  return unique.length > 0 ? unique : purified; // Keep originals if all were "duplicates"
}

/**
 * Stage 3: Citrinitas — Illuminate.
 * Assign 12D coordinates to each atom and find correspondences.
 */
function citrinitas(atoms, audit) {
  const stage = { name: 'citrinitas', started: new Date().toISOString() };

  // Build a composite coordinate from all atoms
  const weights = {};

  for (const atom of atoms) {
    switch (atom.kind) {
      case 'capability':
        weights.capability = capabilityWeight(atom.does);
        weights.consciousness = atom.mcp_tool ? 6 : 3;
        break;

      case 'interface':
        weights.data = Object.keys(atom.needs).length > 3 ? 8 : 5;
        weights.detail = Object.keys(atom.gives).length > 3 ? 8 : 5;
        break;

      case 'policy':
        weights.security = atom.security_level === 'high' ? 9 : (atom.security_level === 'medium' ? 6 : 3);
        weights.transformation = atom.pii ? 7 : 4;
        break;

      case 'metadata':
        weights.output = atom.output === 'json' ? 7 : (atom.output === 'html' ? 8 : 5);
        weights.persistence = atom.runs === 'stream' ? 9 : (atom.runs === 'batch' ? 6 : 3);
        weights.presentation = atom.output === 'html' ? 8 : 4;
        break;

      case 'structure':
        weights.capability = 7;
        weights.detail = (atom.functions || []).length > 5 ? 8 : 5;
        weights.memory = (atom.dependencies || []).length > 3 ? 7 : 4;
        break;

      case 'behavior':
        weights.transformation = atom.pure ? 3 : 7;
        weights.direction = 6;
        break;

      case 'content':
        weights.presentation = 8;
        weights.data = 6;
        break;
    }
  }

  // Fill defaults for unset dimensions
  for (const dim of ['capability', 'data', 'presentation', 'persistence', 'security',
                      'detail', 'output', 'intention', 'consciousness', 'transformation',
                      'direction', 'memory']) {
    if (!(dim in weights)) weights[dim] = 5;
  }

  const coordinate = createCoordinate(weights);
  const dominant = dominantDimensions(coordinate);
  const quality = zodiacalQuality(coordinate);

  stage.coordinate = coordinate;
  stage.dominant = dominant.map(d => `${d.dimension.planet}=${d.value}`);
  stage.quality = quality.sign;
  stage.completed = new Date().toISOString();
  audit.stages.push(stage);

  return { atoms, coordinate, dominant, quality };
}

/**
 * Stage 4: Rubedo — Crystallize.
 * Instantiate as a living citizen.
 */
function rubedo(illuminated, domain, audit) {
  const stage = { name: 'rubedo', started: new Date().toISOString() };

  const { atoms, coordinate, dominant, quality } = illuminated;

  // Build the citizen
  const capAtom = atoms.find(a => a.kind === 'capability') || {};
  const policyAtom = atoms.find(a => a.kind === 'policy') || {};
  const metaAtom = atoms.find(a => a.kind === 'metadata') || {};
  const interfaceAtom = atoms.find(a => a.kind === 'interface') || {};

  const citizen = {
    // Identity
    name: capAtom.name || `citizen_${crypto.randomBytes(4).toString('hex')}`,
    type: 'citizen',

    // Lifecycle
    status: 'formed',
    domain,
    born: new Date().toISOString(),
    lineage: capAtom.server || 'native',

    // 12D Coordinate
    coordinate,
    dominant: dominant.map(d => d.dimension.name),
    quality: quality.sign,

    // Capabilities
    does: capAtom.does || 'unknown',
    server: capAtom.server,
    mcp_tool: capAtom.mcp_tool,

    // Interface
    needs: interfaceAtom.needs || {},
    gives: interfaceAtom.gives || {},

    // Policy
    pii: policyAtom.pii || false,
    approval: policyAtom.approval || false,
    audit: policyAtom.audit !== false,
    security_level: policyAtom.security_level || 'standard',

    // Metadata
    version: metaAtom.version || 'v1',
    output: metaAtom.output || 'json',
    runs: metaAtom.runs || 'once',
    description: metaAtom.description || '',

    // Signature
    signature: generateSignature(coordinate, capAtom.name || 'unnamed')
  };

  // Save citizen to disk
  const citizenPath = path.join(CITIZENS_DIR, `${citizen.name}.citizen`);
  fs.writeFileSync(citizenPath, JSON.stringify(citizen, null, 2));

  stage.citizen = citizen.name;
  stage.domain = domain;
  stage.completed = new Date().toISOString();
  audit.stages.push(stage);

  return citizen;
}

// ─── Helpers ───

function capabilityWeight(does) {
  const map = { analyze: 7, render: 6, communicate: 5, automate: 8, data: 4 };
  return map[does] || 5;
}

function inferTypes(obj) {
  if (!obj || typeof obj !== 'object') return {};
  const types = {};
  for (const [k, v] of Object.entries(obj)) {
    types[k] = Array.isArray(v) ? 'array' : typeof v;
  }
  return types;
}

function extractSections(text) {
  const lines = text.split('\n');
  return lines
    .filter(l => l.startsWith('#'))
    .map(l => l.replace(/^#+\s*/, ''));
}

function findDuplicate(atom, citizens) {
  if (atom.kind !== 'capability') return null;
  return citizens.find(c => c.name === atom.name && c.does === atom.does);
}

function generateSignature(coordinate, name) {
  const data = JSON.stringify({ coordinate, name, time: Date.now() });
  return crypto.createHash('sha256').update(data).digest('hex').slice(0, 16);
}

/**
 * List all citizens from disk.
 */
function listCitizens() {
  if (!fs.existsSync(CITIZENS_DIR)) return [];
  return fs.readdirSync(CITIZENS_DIR)
    .filter(f => f.endsWith('.citizen'))
    .map(f => {
      const content = fs.readFileSync(path.join(CITIZENS_DIR, f), 'utf8');
      return JSON.parse(content);
    });
}

/**
 * Get a citizen by name.
 */
function getCitizen(name) {
  const citizenPath = path.join(CITIZENS_DIR, `${name}.citizen`);
  if (!fs.existsSync(citizenPath)) return null;
  return JSON.parse(fs.readFileSync(citizenPath, 'utf8'));
}

/**
 * Transition a citizen's lifecycle status.
 * summoned → oath → formed → serving → mature → sunset → archived
 */
function transition(name, newStatus) {
  const citizen = getCitizen(name);
  if (!citizen) return null;

  const validTransitions = {
    summoned: ['oath'],
    oath: ['formed'],
    formed: ['serving'],
    serving: ['mature', 'sunset'],
    mature: ['sunset'],
    sunset: ['archived']
  };

  const allowed = validTransitions[citizen.status] || [];
  if (!allowed.includes(newStatus)) {
    return { error: `Cannot transition from ${citizen.status} to ${newStatus}` };
  }

  citizen.status = newStatus;
  citizen[`${newStatus}_at`] = new Date().toISOString();

  const citizenPath = path.join(CITIZENS_DIR, `${name}.citizen`);
  fs.writeFileSync(citizenPath, JSON.stringify(citizen, null, 2));

  return citizen;
}

module.exports = {
  STAGES,
  transmute,
  nigredo,
  albedo,
  citrinitas,
  rubedo,
  listCitizens,
  getCitizen,
  transition
};
