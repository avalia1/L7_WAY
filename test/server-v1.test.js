const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('fs');
const os = require('os');
const path = require('path');

// serve.js (and parser/executor/state) read env at load time. Point L7_DIR
// at a throwaway dir and bind an ephemeral port *before* requiring serve.
const FIXTURE_DIR = fs.mkdtempSync(path.join(os.tmpdir(), 'l7-server-v1-'));
process.env.L7_DIR = FIXTURE_DIR;
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

test.after(async () => {
  console.log = origLog;
  await serve.stop();
});

test('serve.start listens on one loopback port and /health answers', async () => {
  const { port, bind, server } = await serve.start();
  assert.equal(bind, '127.0.0.1');
  assert.equal(typeof port, 'number');
  assert.ok(port > 0);
  assert.equal(server.listening, true);

  const res = await fetch(`http://127.0.0.1:${port}/health`);
  assert.equal(res.status, 200);
  const body = await res.json();
  assert.equal(body.alive, true);
  assert.equal(body.founder, 'Alberto Valido Delgado');
});
