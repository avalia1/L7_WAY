const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('fs');
const os = require('os');
const path = require('path');

const FIXTURE_DIR = fs.mkdtempSync(path.join(os.tmpdir(), 'l7-v1-tools-'));
process.env.L7_DIR = FIXTURE_DIR;
process.env.L7_HOST_ROOT = FIXTURE_DIR;
process.env.L7_PORT = '0';
process.env.L7_BIND = '127.0.0.1';
process.env.L7_MODE = 'mock';
delete process.env.L7_SHIM_DERIVE;

const TOOLS_DIR = path.join(FIXTURE_DIR, 'tools');
fs.mkdirSync(TOOLS_DIR, { recursive: true });
fs.writeFileSync(path.join(TOOLS_DIR, 'echo.tool'), [
  'name: echo',
  'does: communicate',
  'server: l7-gateway',
  'description: ping',
  'version: v1',
  'needs:',
  '  message: string',
  'gives:',
  '  message: string',
  'l7:',
  '  capability: communicate',
  '  data: { pii: non_pii, source: internal, shape: record, freshness: live }',
  '  policyIntent: { mode: test, risk: low, requireApproval: false, compliance: standard }',
  '  presentation: { ui: card, output: json, density: compact }',
  '  orchestration: { flow: single, trigger: manual, retry: none }',
  '  timeVersioning: { toolVersion: v1, schemaVersion: v1, lifecycle: active }',
  '  identitySecurity: { role: operator, auth: token, audit: on }',
  '',
].join('\n'));
fs.writeFileSync(path.join(TOOLS_DIR, 'plain.tool'), [
  'name: plain',
  'does: analyze',
  'server: test-server',
  'description: undeclared',
  '',
].join('\n'));

const fakeGateway = {
  async boot() {
    return { tools_count: 2, citizens_count: 0, flows_count: 0 };
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
  listTools() { return [{ name: 'echo' }, { name: 'plain' }]; },
  listCitizens() { return []; },
  FOUNDER: { legal_name: 'Alberto Valido Delgado' },
  self: { report() { return { ok: true }; } },
  async execute() { return { ok: true }; },
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

test('GET /v1/tools returns declared 7D and does not synthesize undeclared tools', async () => {
  const res = await fetch(`http://127.0.0.1:${started.port}/v1/tools`);
  assert.equal(res.status, 200);
  const body = await res.json();
  assert.equal(body.contract, 'declared-7d');
  assert.equal(body.shim, false);
  const echo = body.tools.find((t) => t.tool === 'echo');
  const plain = body.tools.find((t) => t.tool === 'plain');
  assert.equal(echo.declared, true);
  assert.equal(echo.l7.capability, 'communicate');
  assert.equal(plain.declared, false);
  assert.equal('l7' in plain, false);
});

test('GET /api/tools is marked deprecated and still answers', async () => {
  const res = await fetch(`http://127.0.0.1:${started.port}/api/tools`);
  assert.equal(res.status, 200);
  assert.equal(res.headers.get('deprecation'), 'true');
  const body = await res.json();
  assert.ok(Array.isArray(body.tools));
});
