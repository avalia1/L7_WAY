/**
 * 7D declaration — public contract helpers.
 *
 * toPublicTool: advertised GET /v1/tools shape.
 * deriveDeclaration: heuristic shim. Off unless L7_SHIM_DERIVE=1.
 * GET /v1/tools does not synthesize 7D when the flag is off.
 */

const fs = require('fs');
const path = require('path');
const Ajv = require('ajv');
const catalog = require('./catalog');

const V1_DIR = path.join(__dirname, '..', 'schema', 'v1');
const LINGUA_ID = 'https://l7.way/schema/v1/common-lingua.schema.json';

const commonLingua = JSON.parse(
  fs.readFileSync(path.join(V1_DIR, 'common-lingua.schema.json'), 'utf8'),
);

const ajv = new Ajv({ allErrors: true, strict: false });
const validateLingua = ajv.compile(commonLingua);

const CAPABILITY_ENUM = commonLingua.$defs.capability.enum;
const CAPABILITY_ALIASES = Object.freeze({
  fetch: 'data',
  read: 'data',
  generate: 'render',
  orchestrate: 'automate',
});

function shimEnabled(opts = {}) {
  if (typeof opts.shim === 'boolean') return opts.shim;
  return process.env.L7_SHIM_DERIVE === '1';
}

function hasDeclaration(tool) {
  return Boolean(tool && tool.l7 && typeof tool.l7 === 'object');
}

function validateDeclared(tool) {
  if (!hasDeclaration(tool)) {
    return {
      valid: false,
      errors: [{
        path: '/l7',
        message: 'l7 declaration required (7D must be declared, not inferred)',
      }],
    };
  }
  const ok = validateLingua(tool.l7);
  if (!ok) {
    return {
      valid: false,
      errors: (validateLingua.errors || []).map((err) => ({
        path: `/l7${err.instancePath || ''}`,
        message: err.message,
        params: err.params,
      })),
    };
  }
  return { valid: true, errors: [] };
}

function mapCapability(does) {
  if (CAPABILITY_ENUM.includes(does)) return does;
  if (CAPABILITY_ALIASES[does]) return CAPABILITY_ALIASES[does];
  return 'data';
}

function mapOutput(output) {
  if (output === 'html' || output === 'json' || output === 'file') return output;
  if (output === 'text' || output === 'markdown') return 'markdown';
  if (output === 'binary') return 'file';
  return 'json';
}

function mapVersion(version) {
  if (version === 'v2' || version === 'v3') return version;
  return 'v1';
}

/**
 * Heuristic 7D from YAML fields. One-release shim — not the public contract.
 */
function deriveDeclaration(tool) {
  const t = tool || {};
  return {
    capability: mapCapability(t.does),
    data: {
      pii: t.pii ? 'pii' : 'non_pii',
      source: 'internal',
      shape: 'record',
      freshness: 'live',
    },
    policyIntent: {
      mode: 'live',
      risk: t.approval ? 'high' : 'low',
      requireApproval: Boolean(t.approval),
      compliance: 'standard',
    },
    presentation: {
      ui: 'card',
      output: mapOutput(t.output),
      density: 'standard',
    },
    orchestration: {
      flow: t.runs === 'batch' ? 'sequence' : t.runs === 'stream' ? 'parallel' : 'single',
      trigger: 'manual',
      retry: 'none',
    },
    timeVersioning: {
      toolVersion: mapVersion(t.version),
      schemaVersion: 'v1',
      lifecycle: t.deprecated ? 'deprecated' : 'active',
    },
    identitySecurity: {
      role: 'operator',
      auth: 'token',
      audit: t.audit === false ? 'off' : 'on',
    },
  };
}

function toPublicTool(tool, opts = {}) {
  const t = tool || {};
  const name = t.name || opts.name || 'unknown';
  const declared = hasDeclaration(t);
  const useShim = shimEnabled(opts);
  const publicTool = {
    tool: name,
    version: t.version || 'v1',
    description: t.description || '',
    parameters: {
      required: t.needs || {},
      optional: t.optional || {},
    },
    returns: t.gives || {},
    entity_id: `tool:${name}`,
    server: t.server || null,
    declared,
  };
  if (opts.source) publicTool.source = opts.source;

  if (declared) {
    publicTool.l7 = t.l7;
  } else if (useShim) {
    publicTool.l7 = deriveDeclaration(t);
    publicTool.shim = true;
  }

  return publicTool;
}

function listPublicTools(opts = {}) {
  const { parseFile } = require('./parser');
  const shim = shimEnabled(opts);
  const tools = catalog.listTools().map((entry) => {
    let obj;
    try {
      obj = parseFile(entry.path) || {};
    } catch {
      obj = { name: entry.name };
    }
    if (!obj.name) obj.name = entry.name;
    return toPublicTool(obj, { shim, source: entry.source, name: entry.name });
  });
  return {
    schema: LINGUA_ID,
    contract: 'declared-7d',
    shim,
    tools,
  };
}

module.exports = {
  LINGUA_ID,
  CAPABILITY_ENUM,
  hasDeclaration,
  validateDeclared,
  deriveDeclaration,
  toPublicTool,
  listPublicTools,
  shimEnabled,
  commonLingua,
};
