const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('fs');
const path = require('path');

const ROOT = path.join(__dirname, '..');

function read(rel) {
  return fs.readFileSync(path.join(ROOT, rel), 'utf8');
}

test('package.json start remains node serve.js', () => {
  const pkg = JSON.parse(read('package.json'));
  assert.equal(pkg.scripts.start, 'node serve.js');
  assert.equal(pkg.main, 'serve.js');
});

test('operator scripts split gateway from founder-loop', () => {
  const gateway = read('scripts/run-gateway.sh');
  const loop = read('scripts/run-founder-loop.sh');
  const start = read('start.sh');
  const smoke = read('scripts/founder-loop-smoke.sh');

  assert.match(gateway, /npm start|node serve\.js/);
  assert.equal(/tailscale serve/.test(gateway), false);
  assert.equal(/ssh -N/.test(gateway), false);

  assert.match(loop, /tailscale serve/);
  assert.match(loop, /avli_cloud\/workers\/start\.sh/);
  assert.match(loop, /not the gateway/);
  assert.equal(/exec npm start|exec node serve\.js/.test(loop), false);
  assert.equal(/tailscale serve --bg 18792/.test(loop), false);
  assert.equal(/tailscale serve --bg 18798/.test(loop), false);
  assert.equal(/tailscale serve --bg 7378/.test(loop), false);

  assert.match(start, /run-gateway\.sh/);
  assert.match(start, /run-founder-loop\.sh/);
  assert.match(start, /not the architecture/);

  assert.match(smoke, /founder-loop/);
});

test('serve.js does not grow tunnel, n8n, or Tailscale', () => {
  const serve = read('serve.js');
  assert.equal(/tailscale/i.test(serve), false);
  assert.equal(/\bn8n\b/i.test(serve), false);
  assert.equal(/ssh\s+-R/.test(serve), false);
  assert.equal(/docker-compose/.test(serve), false);
});
