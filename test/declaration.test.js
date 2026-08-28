const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('fs');
const os = require('os');
const path = require('path');

const FIXTURE_DIR = fs.mkdtempSync(path.join(os.tmpdir(), 'l7-declaration-'));
process.env.L7_DIR = FIXTURE_DIR;
process.env.L7_HOST_ROOT = FIXTURE_DIR;
delete process.env.L7_SHIM_DERIVE;
delete process.env.L7_REQUIRE_DECLARED;

const parser = require('../lib/parser');
const declaration = require('../lib/declaration');
const registry = require('../lib/registry');

const TOOLS_DIR = path.join(FIXTURE_DIR, 'tools');
const FLOWS_DIR = path.join(FIXTURE_DIR, 'flows');
fs.mkdirSync(TOOLS_DIR, { recursive: true });
fs.mkdirSync(FLOWS_DIR, { recursive: true });

fs.writeFileSync(path.join(TOOLS_DIR, 'echo.tool'), [
  'name: echo',
  'does: communicate',
  'server: l7-gateway',
  'description: ping',
  'version: v1',
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

fs.writeFileSync(path.join(TOOLS_DIR, 'shim_only.tool'), [
  'name: shim_only',
  'does: analyze',
  'server: test-server',
  'description: no l7 block',
  '',
].join('\n'));

fs.writeFileSync(path.join(FLOWS_DIR, 'sample.flow'), [
  'name: sample',
  'owner: tester',
  'steps:',
  '  - do: echo',
  '    as: out',
  '',
].join('\n'));

test('parser accepts a tool without l7 (shim-only YAML)', () => {
  const obj = parser.parseFile(path.join(TOOLS_DIR, 'shim_only.tool'));
  const result = parser.validate(obj, 'tool');
  assert.equal(result.valid, true);
  assert.equal(declaration.hasDeclaration(obj), false);
});

test('a tool without l7 fails validateDeclared (not public 7D)', () => {
  const obj = parser.parseFile(path.join(TOOLS_DIR, 'shim_only.tool'));
  const result = declaration.validateDeclared(obj);
  assert.equal(result.valid, false);
  assert.match(result.errors[0].message, /declared/i);
});

test('L7_REQUIRE_DECLARED makes parser.validate fail without l7', () => {
  const obj = parser.parseFile(path.join(TOOLS_DIR, 'shim_only.tool'));
  process.env.L7_REQUIRE_DECLARED = '1';
  try {
    const result = parser.validate(obj, 'tool');
    assert.equal(result.valid, false);
    assert.match(result.errors[0].message, /l7 declaration required/);
  } finally {
    delete process.env.L7_REQUIRE_DECLARED;
  }
});

test('toPublicTool returns declared 7D and does not synthesize without the shim flag', () => {
  const echo = parser.parseFile(path.join(TOOLS_DIR, 'echo.tool'));
  const shimOnly = parser.parseFile(path.join(TOOLS_DIR, 'shim_only.tool'));

  const published = declaration.toPublicTool(echo, { shim: false });
  assert.equal(published.declared, true);
  assert.equal(published.tool, 'echo');
  assert.equal(published.l7.capability, 'communicate');
  assert.equal(published.shim, undefined);

  const undeclared = declaration.toPublicTool(shimOnly, { shim: false });
  assert.equal(undeclared.declared, false);
  assert.equal('l7' in undeclared, false);
  assert.equal(undeclared.shim, undefined);
});

test('deriveDeclaration is shim-only — public list includes it only when flagged', () => {
  const shimOnly = parser.parseFile(path.join(TOOLS_DIR, 'shim_only.tool'));
  const derived = declaration.deriveDeclaration(shimOnly);
  assert.equal(derived.capability, 'analyze');
  const check = declaration.validateDeclared({ l7: derived });
  assert.equal(check.valid, true, JSON.stringify(check.errors));

  const withoutFlag = declaration.toPublicTool(shimOnly, { shim: false });
  assert.equal('l7' in withoutFlag, false);

  const withFlag = declaration.toPublicTool(shimOnly, { shim: true });
  assert.equal(withFlag.shim, true);
  assert.equal(withFlag.declared, false);
  assert.deepEqual(withFlag.l7.capability, 'analyze');
});

test('listPublicTools default contract is declared-7d, not synthesized', () => {
  const listing = declaration.listPublicTools({ shim: false });
  assert.equal(listing.contract, 'declared-7d');
  assert.equal(listing.shim, false);
  const echo = listing.tools.find((t) => t.tool === 'echo');
  const shimOnly = listing.tools.find((t) => t.tool === 'shim_only');
  assert.ok(echo);
  assert.equal(echo.declared, true);
  assert.equal(echo.l7.capability, 'communicate');
  assert.ok(shimOnly);
  assert.equal(shimOnly.declared, false);
  assert.equal('l7' in shimOnly, false);
});

test('ENTITY_REGISTRY produced from tools and flows is not empty', () => {
  const doc = registry.build();
  assert.ok(doc.entities.length >= 3, `expected tools+flows, got ${doc.entities.length}`);
  const ids = doc.entities.map((e) => e.entity_id).sort();
  assert.deepEqual(ids, ['tool:echo', 'tool:shim_only', 'workflow:sample']);
  const echo = doc.entities.find((e) => e.entity_id === 'tool:echo');
  assert.equal(echo.declared, true);
  assert.equal(echo.l7_declaration.capability, 'communicate');
  const shim = doc.entities.find((e) => e.entity_id === 'tool:shim_only');
  assert.equal(shim.declared, false);
  assert.equal(shim.l7_declaration, null);

  const produced = registry.produce();
  assert.ok(produced.count >= 3);
  const onDisk = JSON.parse(fs.readFileSync(produced.path, 'utf8'));
  assert.ok(onDisk.entities.length >= 3);
});

test.after(() => {
  fs.rmSync(FIXTURE_DIR, { recursive: true, force: true });
});
