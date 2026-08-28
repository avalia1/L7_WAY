const test = require('node:test');
const assert = require('node:assert/strict');
const http = require('http');
const fs = require('fs');
const os = require('os');
const path = require('path');

// Isolated prefix so catalog/gateway never touch the real ~/.l7 or host/.
const FIXTURE_DIR = fs.mkdtempSync(path.join(os.tmpdir(), 'l7-loopback-http-'));
process.env.L7_DIR = FIXTURE_DIR;
process.env.L7_HOST_ROOT = FIXTURE_DIR;
process.env.L7_MODE = 'mcp';
delete process.env.L7_TOKEN;

const TOOLS_DIR = path.join(FIXTURE_DIR, 'tools');
fs.mkdirSync(TOOLS_DIR, { recursive: true });

const gateway = require('../lib/gateway');
const loopbackHttp = require('../lib/loopback-http');

const origLog = console.log;
console.log = () => {};

function writeTool(name, body) {
  fs.writeFileSync(path.join(TOOLS_DIR, `${name}.tool`), body);
}

function startEchoServer() {
  const received = [];
  const server = http.createServer((req, res) => {
    const chunks = [];
    req.on('data', (c) => chunks.push(c));
    req.on('end', () => {
      const raw = Buffer.concat(chunks).toString('utf8');
      let body = {};
      try { body = JSON.parse(raw || '{}'); } catch { body = { raw }; }
      received.push({
        method: req.method,
        url: req.url,
        contentType: req.headers['content-type'],
        authorization: req.headers.authorization,
        body,
      });
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(raw || '{}');
    });
  });
  return new Promise((resolve) => {
    server.listen(0, '127.0.0.1', () => {
      const { port } = server.address();
      resolve({
        server,
        port,
        received,
        url: `http://127.0.0.1:${port}/`,
      });
    });
  });
}

test('assertLoopbackUrl allows 127.0.0.1, localhost, ::1, and IPv4-mapped ::ffff:127.0.0.1', () => {
  assert.equal(loopbackHttp.assertLoopbackUrl('http://127.0.0.1:18792/').hostname, '127.0.0.1');
  assert.equal(loopbackHttp.assertLoopbackUrl('http://localhost/run').pathname, '/run');
  assert.doesNotThrow(() => loopbackHttp.assertLoopbackUrl('http://[::1]/'));
  assert.doesNotThrow(() => loopbackHttp.assertLoopbackUrl('http://[::ffff:127.0.0.1]/'));
});

test('assertLoopbackUrl rejects public hosts, 0.0.0.0, and file:', () => {
  assert.throws(() => loopbackHttp.assertLoopbackUrl('http://example.com/'), /Loopback HTTP refused/);
  assert.throws(() => loopbackHttp.assertLoopbackUrl('http://8.8.8.8/'), /Loopback HTTP refused/);
  assert.throws(() => loopbackHttp.assertLoopbackUrl('http://0.0.0.0/'), /Loopback HTTP refused/);
  assert.throws(() => loopbackHttp.assertLoopbackUrl('file:///etc/passwd'), /Loopback HTTP refused|not http/);
});

test('gateway.execute POSTs JSON to a loopback HTTP tool and returns the echo', async (t) => {
  const { server, url, received } = await startEchoServer();
  t.after(() => new Promise((resolve, reject) => {
    server.close((err) => (err ? reject(err) : resolve()));
  }));

  writeTool(
    'loop_echo',
    [
      'name: loop_echo',
      'does: communicate',
      `server: "${url}"`,
      'mcp_tool: echo',
      '',
    ].join('\n'),
  );

  const params = { message: 'ping from test' };
  const out = await gateway.execute('loop_echo', params, { mode: 'mcp' });

  assert.equal(out.ok, true);
  assert.equal(out.name, 'echo');
  assert.deepEqual(out.arguments, params);
  assert.equal(received.length, 1, 'the local server received exactly one POST');
  assert.equal(received[0].method, 'POST');
  assert.equal(received[0].url, '/');
  assert.match(received[0].contentType || '', /application\/json/);
  assert.deepEqual(received[0].body, { name: 'echo', arguments: params });
});

test('gateway.execute in mock mode does not POST to a loopback HTTP tool', async (t) => {
  const { server, url, received } = await startEchoServer();
  t.after(() => new Promise((resolve, reject) => {
    server.close((err) => (err ? reject(err) : resolve()));
  }));

  writeTool(
    'loop_mock',
    [
      'name: loop_mock',
      'does: communicate',
      `server: "${url}"`,
      '',
    ].join('\n'),
  );

  const out = await gateway.execute('loop_mock', { message: 'nope' }, { mode: 'mock' });
  assert.equal(out.mock, true);
  assert.equal(out.tool, 'loop_mock');
  assert.equal(received.length, 0, 'mock mode must not hit the worker');
});

async function assertNoFetch(toolName, server, pattern) {
  let fetched = 0;
  const origFetch = globalThis.fetch;
  globalThis.fetch = async (href) => {
    fetched += 1;
    throw new Error(`unexpected fetch: ${href}`);
  };
  try {
    writeTool(toolName, `name: ${toolName}\ndoes: communicate\nserver: "${server}"\n`);
    await assert.rejects(
      () => gateway.execute(toolName, { x: 1 }, { mode: 'mcp' }),
      pattern,
    );
    assert.equal(fetched, 0, `must not fetch ${server}`);
  } finally {
    globalThis.fetch = origFetch;
  }
}

test('gateway.execute refuses http://example.com/ and does not fetch', async () => {
  await assertNoFetch('remote_example', 'http://example.com/', /Loopback HTTP refused/);
});

test('gateway.execute refuses http://8.8.8.8/ and does not fetch', async () => {
  await assertNoFetch('remote_dns', 'http://8.8.8.8/', /Loopback HTTP refused/);
});

test.after(() => {
  console.log = origLog;
  fs.rmSync(FIXTURE_DIR, { recursive: true, force: true });
});
