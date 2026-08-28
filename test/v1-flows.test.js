const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('fs');
const os = require('os');
const path = require('path');

// serve.js / executor / state read L7_DIR at load time. Point at a throwaway
// prefix, bind an ephemeral port, and keep execute() in mock mode *before*
// requiring serve. Stub gateway so boot() does not start a pulse timer;
// execute() still records calls with the same envelope as executeViaMock.
const FIXTURE_DIR = fs.mkdtempSync(path.join(os.tmpdir(), 'l7-v1-flows-'));
process.env.L7_DIR = FIXTURE_DIR;
process.env.L7_HOST_ROOT = FIXTURE_DIR;
process.env.L7_PORT = '0';
process.env.L7_BIND = '127.0.0.1';
process.env.L7_MODE = 'mock';
delete process.env.L7_SHIM_DERIVE;

const SRC = path.join(__dirname, 'fixtures');
fs.mkdirSync(path.join(FIXTURE_DIR, 'tools'), { recursive: true });
fs.mkdirSync(path.join(FIXTURE_DIR, 'flows'), { recursive: true });
fs.copyFileSync(path.join(SRC, 'tools', 'alpha.tool'), path.join(FIXTURE_DIR, 'tools', 'alpha.tool'));
fs.copyFileSync(path.join(SRC, 'tools', 'beta.tool'), path.join(FIXTURE_DIR, 'tools', 'beta.tool'));
fs.copyFileSync(path.join(SRC, 'flows', 'pipe_ab.flow'), path.join(FIXTURE_DIR, 'flows', 'pipe_ab.flow'));

const fakeGateway = {
  calls: [],
  async boot() {
    return { tools_count: 2, citizens_count: 0, flows_count: 1 };
  },
  async shutdown() {},
  async checkHealth() {
    return { tools: [], citizens: [], polarities: [] };
  },
  heart: {
    status() {
      return { id: 'test', incarnation: 1, totalBeats: 0, age_human: '0s', alive: true };
    },
    awareness() { return {}; },
    trend() { return {}; },
  },
  fieldReport() {
    return { nodes: 0, epoch: 0, entropy: 0, energy: 0 };
  },
  fieldVitals() { return {}; },
  listTools() { return [{ name: 'alpha' }, { name: 'beta' }]; },
  listCitizens() { return []; },
  FOUNDER: { legal_name: 'Alberto Valido Delgado' },
  self: { report() { return { ok: true }; } },
  async execute(toolName, params) {
    fakeGateway.calls.push({ toolName, params });
    return { ok: true, mock: true, tool: toolName, params };
  },
  transmute() { return {}; },
  async invokeCouncil() { return {}; },
  writeToDomain() { return {}; },
  readFromDomain() { return {}; },
  transitionDomain() { return {}; },
  compileSigil() { return {}; },
};

const gatewayPath = require.resolve('../lib/gateway');
require.cache[gatewayPath] = {
  id: gatewayPath,
  filename: gatewayPath,
  loaded: true,
  exports: fakeGateway,
};

const origLog = console.log;
console.log = () => {};

const serve = require('../serve');

let started;

test.before(async () => {
  started = await serve.start();
});

test.after(async () => {
  console.log = origLog;
  await serve.stop();
  fs.rmSync(FIXTURE_DIR, { recursive: true, force: true });
});

test('POST /v1/flows/pipe_ab/run pipes alpha → beta (declared composition, not a ReAct loop)', async () => {
  fakeGateway.calls = [];
  const res = await fetch(`http://127.0.0.1:${started.port}/v1/flows/pipe_ab/run`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({}),
  });
  assert.equal(res.status, 200);
  const raw = await res.text();
  const body = JSON.parse(raw);

  assert.equal(body.flow, 'pipe_ab');
  assert.equal(body.status, 'completed');
  assert.ok(body.id);
  assert.ok(body.results.a, 'step `as: a` is stored — A ran');
  assert.equal(body.results.a.tool, 'alpha');
  assert.ok(body.results.b, 'step `as: b` is stored — B ran');
  assert.equal(body.results.b.tool, 'beta');

  const beta = fakeGateway.calls.find((c) => c.toolName === 'beta');
  assert.ok(beta, 'beta was invoked');
  assert.equal(beta.params.from, 'alpha', 'beta.with.from interpolated from $a.tool');
  assert.equal(fakeGateway.calls.map((c) => c.toolName).join(','), 'alpha,beta');

  assert.equal(body.principal.kind, 'local');
  assert.equal(body.principal.loopback, true);
  assert.equal('legal_name' in body, false);
  assert.equal('founder' in body, false);
  assert.doesNotMatch(raw, /legal_name/);
  assert.doesNotMatch(raw, /Alberto Valido Delgado/);
  assert.doesNotMatch(raw, /avalia@avli\.cloud/);
});

test('POST /v1/flows/run with body.flow is an alias for /v1/flows/:name/run', async () => {
  fakeGateway.calls = [];
  const res = await fetch(`http://127.0.0.1:${started.port}/v1/flows/run`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ flow: 'pipe_ab' }),
  });
  assert.equal(res.status, 200);
  const body = await res.json();
  assert.equal(body.flow, 'pipe_ab');
  assert.equal(body.status, 'completed');
  assert.ok(body.results.a);
  assert.equal(body.principal.kind, 'local');
});

test('POST /v1/flows/run without a name is 400', async () => {
  const res = await fetch(`http://127.0.0.1:${started.port}/v1/flows/run`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({}),
  });
  assert.equal(res.status, 400);
  const body = await res.json();
  assert.match(body.error, /Flow name required/);
});

test('POST /v1/flows/unknown_flow/run is 404', async () => {
  const res = await fetch(`http://127.0.0.1:${started.port}/v1/flows/unknown_flow/run`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({}),
  });
  assert.equal(res.status, 404);
  const body = await res.json();
  assert.match(body.error, /Flow not found/);
});

test('POST /api/execute still runs and points Sunset/Link at /v1/flows/:name/run', async () => {
  fakeGateway.calls = [];
  const res = await fetch(`http://127.0.0.1:${started.port}/api/execute`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ flow: 'pipe_ab' }),
  });
  assert.equal(res.status, 200);
  assert.equal(res.headers.get('deprecation'), 'true');
  assert.match(res.headers.get('link') || '', /\/v1\/flows\/pipe_ab\/run/);
  const body = await res.json();
  assert.equal(body.flow, 'pipe_ab');
  assert.equal(body.status, 'completed');
  assert.ok(body.results.a);
  assert.equal(body.principal, undefined, 'legacy /api/execute body is unchanged');
});
