/**
 * L7 State Manager - Persist and resume flow execution state
 */

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const L7_DIR = process.env.L7_DIR || path.join(process.env.HOME, '.l7');
const STATE_DIR = path.join(L7_DIR, 'state');
const AUDIT_LOG = path.join(L7_DIR, 'audit.log');

// Ensure directories exist
if (!fs.existsSync(STATE_DIR)) {
  fs.mkdirSync(STATE_DIR, { recursive: true });
}

/**
 * Generate a unique execution ID
 */
function generateId() {
  return crypto.randomBytes(6).toString('hex');
}

/**
 * Create a new execution state
 */
function create(flowName, inputs = {}) {
  const id = generateId();
  const state = {
    id,
    flow: flowName,
    status: 'pending',
    step: 0,
    inputs,
    results: {},
    started: new Date().toISOString(),
    updated: new Date().toISOString(),
    checkpoints: [],
    errors: []
  };

  save(state);
  return state;
}

/**
 * Save state to disk
 */
function save(state) {
  state.updated = new Date().toISOString();
  const filePath = path.join(STATE_DIR, `${state.flow}-${state.id}.state`);
  fs.writeFileSync(filePath, JSON.stringify(state, null, 2));
  return state;
}

/**
 * Load state from disk
 */
function load(flowName, id) {
  const filePath = path.join(STATE_DIR, `${flowName}-${id}.state`);
  if (!fs.existsSync(filePath)) {
    return null;
  }
  return JSON.parse(fs.readFileSync(filePath, 'utf8'));
}

/**
 * List all states for a flow (or all flows)
 */
function list(flowName = null) {
  if (!fs.existsSync(STATE_DIR)) return [];

  const files = fs.readdirSync(STATE_DIR).filter(f => f.endsWith('.state'));

  return files
    .map(f => {
      const content = fs.readFileSync(path.join(STATE_DIR, f), 'utf8');
      return JSON.parse(content);
    })
    .filter(s => !flowName || s.flow === flowName)
    .sort((a, b) => new Date(b.updated) - new Date(a.updated));
}

/**
 * Update state status
 */
function setStatus(state, status) {
  state.status = status;
  if (status === 'completed' || status === 'failed') {
    state.finished = new Date().toISOString();
  }
  return save(state);
}

/**
 * Store a step result
 */
function setResult(state, name, value) {
  state.results[name] = value;
  return save(state);
}

/**
 * Advance to next step
 */
function advance(state) {
  state.step += 1;
  return save(state);
}

/**
 * Record a checkpoint (wait step)
 */
function checkpoint(state, message, stepIndex) {
  state.status = 'waiting';
  state.checkpoints.push({
    step: stepIndex,
    message,
    created: new Date().toISOString(),
    resolved: null,
    decision: null
  });
  return save(state);
}

/**
 * Resolve a checkpoint (approve/reject)
 */
function resolveCheckpoint(state, decision) {
  const pending = state.checkpoints.find(c => !c.resolved);
  if (pending) {
    pending.resolved = new Date().toISOString();
    pending.decision = decision; // 'approve' or 'reject'
  }

  if (decision === 'approve') {
    state.status = 'running';
    state.step += 1; // Advance past the checkpoint
  } else {
    state.status = 'rejected';
  }

  return save(state);
}

/**
 * Record an error
 */
function addError(state, error, stepIndex) {
  state.errors.push({
    step: stepIndex,
    error: error.message || String(error),
    time: new Date().toISOString()
  });
  return save(state);
}

/**
 * Delete a state file
 */
function remove(flowName, id) {
  const filePath = path.join(STATE_DIR, `${flowName}-${id}.state`);
  if (fs.existsSync(filePath)) {
    fs.unlinkSync(filePath);
    return true;
  }
  return false;
}

/**
 * Append to audit log
 */
function audit(entry) {
  const line = JSON.stringify({
    ...entry,
    when: new Date().toISOString()
  }) + '\n';

  fs.appendFileSync(AUDIT_LOG, line);
}

module.exports = {
  generateId,
  create,
  save,
  load,
  list,
  setStatus,
  setResult,
  advance,
  checkpoint,
  resolveCheckpoint,
  addError,
  remove,
  audit
};
