const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('fs');
const path = require('path');

const ROOT = path.join(__dirname, '..');
const SKIP_DIRS = new Set(['node_modules', 'archive', 'test', '.git', 'salt']);

function walkJs(dir, acc = []) {
  for (const ent of fs.readdirSync(dir, { withFileTypes: true })) {
    if (ent.name.startsWith('.') && ent.name !== '.') continue;
    if (SKIP_DIRS.has(ent.name)) continue;
    const p = path.join(dir, ent.name);
    if (ent.isDirectory()) walkJs(p, acc);
    else if (ent.name.endsWith('.js')) acc.push(p);
  }
  return acc;
}

function withoutComments(source) {
  return source
    .replace(/\/\*[\s\S]*?\*\//g, '')
    .replace(/^\s*\/\/.*$/gm, '');
}

function countCreateServer(source) {
  return [...withoutComments(source).matchAll(/http\.createServer\s*\(/g)].length;
}

function hasRequire(source, specifier) {
  const escaped = specifier.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  return new RegExp(`require\\((['"\`])[^'"\`]*${escaped}[^'"\`]*\\1\\)`).test(withoutComments(source));
}

test('package.json start/main describe the control plane, not the DSL or Empire', () => {
  const pkg = JSON.parse(fs.readFileSync(path.join(ROOT, 'package.json'), 'utf8'));
  assert.equal(pkg.main, 'serve.js');
  assert.equal(pkg.scripts.start, 'node serve.js');
  assert.equal(pkg.scripts.test, 'node --test test/*.test.js');
  assert.ok(!pkg.scripts.empire, 'empire npm script must not boot a second server');
});

test('product has exactly one http.createServer used as a server', () => {
  const serveSrc = fs.readFileSync(path.join(ROOT, 'serve.js'), 'utf8');
  const launcherSrc = fs.readFileSync(path.join(ROOT, 'serve-gateway.js'), 'utf8');

  assert.equal(countCreateServer(serveSrc), 1);
  assert.match(serveSrc, /18793/);
  assert.equal(hasRequire(serveSrc, 'empire/server'), false);
  assert.match(serveSrc, /module\.exports\s*=\s*\{[^}]*start/);

  assert.equal(countCreateServer(launcherSrc), 0);
  assert.match(launcherSrc, /require\('\.\/serve'\)\.start\(\)/);

  const productJs = walkJs(ROOT);
  const listeners = productJs.filter((file) => countCreateServer(fs.readFileSync(file, 'utf8')) > 0);
  assert.deepEqual(
    listeners.map((file) => path.relative(ROOT, file)).sort(),
    ['serve.js'],
    'only serve.js may call http.createServer on the product start path'
  );
});

test('archived Empire server is not imported by the start path', () => {
  const serveSrc = fs.readFileSync(path.join(ROOT, 'serve.js'), 'utf8');
  const launcherSrc = fs.readFileSync(path.join(ROOT, 'serve-gateway.js'), 'utf8');
  const stubSrc = fs.readFileSync(path.join(ROOT, 'empire/server.js'), 'utf8');

  assert.equal(hasRequire(serveSrc, 'archive/empire'), false);
  assert.equal(hasRequire(launcherSrc, 'archive/empire'), false);
  assert.equal(countCreateServer(stubSrc), 0);
  assert.match(stubSrc, /process\.exit\(1\)/);
  assert.ok(fs.existsSync(path.join(ROOT, 'archive/empire/server.js')));
});
