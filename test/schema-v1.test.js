const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('fs');
const os = require('os');
const path = require('path');

const ROOT = path.join(__dirname, '..');
const V1 = path.join(ROOT, 'schema', 'v1');

test('root L7_SCHEMA.json is identical to schema/v1/common-lingua.schema.json', () => {
  const root = fs.readFileSync(path.join(ROOT, 'L7_SCHEMA.json'), 'utf8');
  const v1 = fs.readFileSync(path.join(V1, 'common-lingua.schema.json'), 'utf8');
  assert.equal(root, v1);
  const parsed = JSON.parse(v1);
  assert.deepEqual(
    parsed.required,
    ['capability', 'data', 'policyIntent', 'presentation', 'orchestration', 'timeVersioning', 'identitySecurity'],
  );
});

test('tool `does` enum matches 7D capability (no fork)', () => {
  const lingua = JSON.parse(fs.readFileSync(path.join(V1, 'common-lingua.schema.json'), 'utf8'));
  const tool = JSON.parse(fs.readFileSync(path.join(V1, 'tool.schema.json'), 'utf8'));
  assert.equal(
    tool.properties.does.$ref,
    'https://l7.way/schema/v1/common-lingua.schema.json#/$defs/capability',
  );
  assert.deepEqual(lingua.$defs.capability.enum, [
    'communicate', 'data', 'analyze', 'automate', 'render', 'search',
  ]);
  assert.deepEqual(lingua.$defs.lifecycle.enum, ['active', 'deprecated', 'preview']);
});

test('12D internal_projection does not grant identity or domain', () => {
  const dodecahedron = require('../lib/dodecahedron');
  const names = dodecahedron.DIMENSIONS.map((d) => d.name);
  assert.equal(names.includes('identity'), false);
  assert.equal(names.includes('domain'), false);
  assert.equal(dodecahedron.DIMENSIONS.length, 12);
  const coord = dodecahedron.fromTool({ does: 'analyze', pii: false, output: 'json' });
  assert.equal(coord.length, 12);
});

test('host/tools samples declare valid 7D', () => {
  const parser = require('../lib/parser');
  const declaration = require('../lib/declaration');
  for (const name of ['echo', 'gateway_doctor', 'herald_cast']) {
    const file = path.join(ROOT, 'host', 'tools', `${name}.tool`);
    const obj = parser.parseFile(file);
    const yamlOk = parser.validate(obj, 'tool');
    assert.equal(yamlOk.valid, true, `${name} yaml: ${JSON.stringify(yamlOk.errors)}`);
    const declared = declaration.validateDeclared(obj);
    assert.equal(declared.valid, true, `${name} l7: ${JSON.stringify(declared.errors)}`);
  }
});

test('committed ENTITY_REGISTRY.json is generated and not empty', () => {
  const doc = JSON.parse(fs.readFileSync(path.join(ROOT, 'ENTITY_REGISTRY.json'), 'utf8'));
  assert.equal(doc.schema, 'v1');
  assert.ok(doc.entities.length > 0, 'empty { entities: [] } is a bug');
  assert.ok(doc.entities.some((e) => e.entity_id === 'tool:echo' && e.declared));
});
