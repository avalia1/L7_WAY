const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('fs');
const os = require('os');
const path = require('path');

const { principal } = require('../lib/principal');

const ORIG_TOKEN = process.env.L7_TOKEN;
const ORIG_DIR = process.env.L7_DIR;

function req(remoteAddress, authorization) {
  const headers = {};
  if (authorization !== undefined) headers.authorization = authorization;
  return { headers, socket: { remoteAddress } };
}

function restoreEnv() {
  if (ORIG_TOKEN === undefined) delete process.env.L7_TOKEN;
  else process.env.L7_TOKEN = ORIG_TOKEN;
  if (ORIG_DIR === undefined) delete process.env.L7_DIR;
  else process.env.L7_DIR = ORIG_DIR;
}

test.afterEach(() => {
  restoreEnv();
});

test.after(() => {
  restoreEnv();
});

test('loopback without a token is kind local', () => {
  delete process.env.L7_TOKEN;
  process.env.L7_DIR = fs.mkdtempSync(path.join(os.tmpdir(), 'l7-principal-none-'));
  for (const addr of ['127.0.0.1', '::1', '::ffff:127.0.0.1']) {
    const who = principal(req(addr));
    assert.deepEqual(who, { id: 'local', kind: 'local', loopback: true });
  }
});

test('bearer matching L7_TOKEN is kind bearer (token wins on loopback)', () => {
  process.env.L7_TOKEN = 'phase6-secret';
  process.env.L7_DIR = fs.mkdtempSync(path.join(os.tmpdir(), 'l7-principal-env-'));
  const who = principal(req('127.0.0.1', 'Bearer phase6-secret'));
  assert.equal(who.kind, 'bearer');
  assert.equal(who.id, 'operator');
  assert.equal(who.loopback, true);
});

test('bearer matching $L7_DIR/secrets/token is kind bearer', () => {
  delete process.env.L7_TOKEN;
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'l7-principal-file-'));
  fs.mkdirSync(path.join(dir, 'secrets'));
  fs.writeFileSync(path.join(dir, 'secrets', 'token'), '  file-secret\n');
  process.env.L7_DIR = dir;
  const who = principal(req('127.0.0.1', 'Bearer file-secret'));
  assert.equal(who.kind, 'bearer');
  assert.equal(who.id, 'operator');
  assert.equal(who.loopback, true);
});

test('wrong token on loopback stays local', () => {
  process.env.L7_TOKEN = 'phase6-secret';
  process.env.L7_DIR = fs.mkdtempSync(path.join(os.tmpdir(), 'l7-principal-wrong-'));
  const who = principal(req('127.0.0.1', 'Bearer definitely-not-it'));
  assert.equal(who.kind, 'local');
  assert.equal(who.id, 'local');
  assert.equal(who.loopback, true);
});

test('wrong token on a remote address stays anonymous', () => {
  process.env.L7_TOKEN = 'phase6-secret';
  process.env.L7_DIR = fs.mkdtempSync(path.join(os.tmpdir(), 'l7-principal-anon-'));
  const who = principal(req('203.0.113.8', 'Bearer definitely-not-it'));
  assert.equal(who.kind, 'anonymous');
  assert.equal(who.id, 'anonymous');
  assert.equal(who.loopback, false);
});

test('valid bearer from a remote address is operator, not loopback', () => {
  process.env.L7_TOKEN = 'phase6-secret';
  const who = principal(req('203.0.113.8', 'Bearer phase6-secret'));
  assert.deepEqual(who, { id: 'operator', kind: 'bearer', loopback: false });
});

test('missing token file does not throw', () => {
  delete process.env.L7_TOKEN;
  process.env.L7_DIR = path.join(os.tmpdir(), 'l7-principal-missing-' + process.pid);
  assert.doesNotThrow(() => principal(req('127.0.0.1')));
  const who = principal(req('127.0.0.1', 'Bearer anything'));
  assert.equal(who.kind, 'local');
});

test('principal never carries FOUNDER, legal_name, email, or rights', () => {
  process.env.L7_TOKEN = 'phase6-secret';
  const who = principal(req('127.0.0.1', 'Bearer phase6-secret'));
  assert.equal('legal_name' in who, false);
  assert.equal('email' in who, false);
  assert.equal('rights' in who, false);
  assert.equal('FOUNDER' in who, false);
  assert.equal(who.legal_name, undefined);
  assert.deepEqual(Object.keys(who).sort(), ['id', 'kind', 'loopback']);
});
