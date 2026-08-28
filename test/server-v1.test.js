const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('fs');
const os = require('os');
const path = require('path');

// serve.js (and parser/executor/state) read env at load time. Point L7_DIR
// at a throwaway dir and bind an ephemeral port *before* requiring serve.
const FIXTURE_DIR = fs.mkdtempSync(path.join(os.tmpdir(), 'l7-server-v1-'));
process.env.L7_DIR = FIXTURE_DIR;
process.env.L7_HOST_ROOT = FIXTURE_DIR;
process.env.L7_PORT = '0';
process.env.L7_BIND = '127.0.0.1';
process.env.L7_MODE = 'mock';

const fakeGateway = {
  async boot() {
    return { tools_count: 0, citizens_count: 0, flows_count: 0 };
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
  listTools() { return []; },
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
});

function healthText(body) {
  return JSON.stringify(body);
}

test('serve.start listens on one loopback port and /health answers', async () => {
  const { port, bind, server } = started;
  assert.equal(bind, '127.0.0.1');
  assert.equal(typeof port, 'number');
  assert.ok(port > 0);
  assert.equal(server.listening, true);

  const res = await fetch(`http://127.0.0.1:${port}/health`);
  assert.equal(res.status, 200);
  const body = await res.json();
  assert.equal(body.alive, true);
  assert.equal(body.principal.kind, 'local');
  assert.equal(body.principal.loopback, true);
  assert.equal(body.founder, undefined);
});

test('GET /health does not leak founder legal_name or email', async () => {
  const res = await fetch(`http://127.0.0.1:${started.port}/health`);
  assert.equal(res.status, 200);
  const raw = await res.text();
  const body = JSON.parse(raw);
  assert.equal(body.founder, undefined);
  assert.equal('founder' in body, false);
  assert.match(raw, /"kind": "local"/);
  assert.doesNotMatch(raw, /legal_name/);
  assert.doesNotMatch(raw, /Alberto Valido Delgado/);
  assert.doesNotMatch(raw, /avalia@avli\.cloud/);
  assert.equal(healthText(body).includes('avalia@avli.cloud'), false);
});

test('GET /health with a matching bearer reports kind bearer and stays 200', async () => {
  const prev = process.env.L7_TOKEN;
  process.env.L7_TOKEN = 'phase6-http-secret';
  try {
    const res = await fetch(`http://127.0.0.1:${started.port}/health`, {
      headers: { Authorization: 'Bearer phase6-http-secret' },
    });
    assert.equal(res.status, 200);
    const raw = await res.text();
    const body = JSON.parse(raw);
    assert.equal(body.principal.kind, 'bearer');
    assert.equal(body.principal.loopback, true);
    assert.doesNotMatch(raw, /Alberto Valido Delgado/);
    assert.doesNotMatch(raw, /avalia@avli\.cloud/);
  } finally {
    if (prev === undefined) delete process.env.L7_TOKEN;
    else process.env.L7_TOKEN = prev;
  }
});

test('GET /health with a wrong token stays local (loopback remains open)', async () => {
  const prev = process.env.L7_TOKEN;
  process.env.L7_TOKEN = 'phase6-http-secret';
  try {
    const res = await fetch(`http://127.0.0.1:${started.port}/health`, {
      headers: { Authorization: 'Bearer wrong-token' },
    });
    assert.equal(res.status, 200);
    const body = await res.json();
    assert.equal(body.principal.kind, 'local');
    assert.equal(body.principal.loopback, true);
  } finally {
    if (prev === undefined) delete process.env.L7_TOKEN;
    else process.env.L7_TOKEN = prev;
  }
});
