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
  for (const name of ['echo', 'ollama', 'image', 'ffmpeg', 'gateway_doctor', 'herald_cast']) {
    const file = path.join(ROOT, 'host', 'tools', `${name}.tool`);
    const obj = parser.parseFile(file);
    const yamlOk = parser.validate(obj, 'tool');
    assert.equal(yamlOk.valid, true, `${name} yaml: ${JSON.stringify(yamlOk.errors)}`);
    const declared = declaration.validateDeclared(obj);
    assert.equal(declared.valid, true, `${name} l7: ${JSON.stringify(declared.errors)}`);
  }
  const echo = parser.parseFile(path.join(ROOT, 'host', 'tools', 'echo.tool'));
  assert.equal(echo.server, 'http://127.0.0.1:18792/');
  assert.match(echo.description, /loopback echo worker/i);
  const ollama = parser.parseFile(path.join(ROOT, 'host', 'tools', 'ollama.tool'));
  assert.equal(ollama.server, 'http://127.0.0.1:18798/');
  assert.equal(ollama.mcp_tool, 'text.generate');
  assert.equal(ollama.needs.prompt, 'string');
  assert.match(ollama.description, /loopback ollama worker/i);
  const image = parser.parseFile(path.join(ROOT, 'host', 'tools', 'image.tool'));
  assert.equal(image.server, 'http://127.0.0.1:18794/');
  assert.equal(image.mcp_tool, 'image.generate');
  assert.equal(image.does, 'render');
  assert.equal(image.needs.prompt, 'string');
  assert.equal(image.gives.path, 'string');
  assert.match(image.description, /loopback ComfyUI image worker/i);
  assert.notEqual(image.server, 'http://127.0.0.1:8188/');
  assert.notEqual(image.server, 'l7-media');
  const ffmpeg = parser.parseFile(path.join(ROOT, 'host', 'tools', 'ffmpeg.tool'));
  assert.equal(ffmpeg.server, 'http://127.0.0.1:18795/');
  assert.equal(ffmpeg.mcp_tool, 'ffmpeg.assemble');
  assert.equal(ffmpeg.needs.images, 'array');
  assert.equal(ffmpeg.needs.output, 'string');
  assert.match(ffmpeg.description, /loopback ffmpeg assemble worker/i);
});

test('host/flows/echo_once.flow is a valid one-step composition of echo', () => {
  const parser = require('../lib/parser');
  const file = path.join(ROOT, 'host', 'flows', 'echo_once.flow');
  const obj = parser.parseFile(file);
  const yamlOk = parser.validate(obj, 'flow');
  assert.equal(yamlOk.valid, true, `echo_once yaml: ${JSON.stringify(yamlOk.errors)}`);
  assert.equal(obj.steps.length, 1);
  assert.equal(obj.steps[0].do, 'echo');
  assert.equal(obj.steps[0].as, 'out');
  assert.equal(obj.steps[0].with.message, 'hello');
});

test('host/flows/ollama_once.flow is a valid one-step composition of ollama', () => {
  const parser = require('../lib/parser');
  const file = path.join(ROOT, 'host', 'flows', 'ollama_once.flow');
  const obj = parser.parseFile(file);
  const yamlOk = parser.validate(obj, 'flow');
  assert.equal(yamlOk.valid, true, `ollama_once yaml: ${JSON.stringify(yamlOk.errors)}`);
  assert.equal(obj.steps.length, 1);
  assert.equal(obj.steps[0].do, 'ollama');
  assert.equal(obj.steps[0].as, 'out');
  assert.equal(obj.steps[0].with.prompt, 'hello');
});

test('host/flows/echo_then_ollama.flow interpolates $a.message from echo into ollama', () => {
  const parser = require('../lib/parser');
  const file = path.join(ROOT, 'host', 'flows', 'echo_then_ollama.flow');
  const obj = parser.parseFile(file);
  const yamlOk = parser.validate(obj, 'flow');
  assert.equal(yamlOk.valid, true, `echo_then_ollama yaml: ${JSON.stringify(yamlOk.errors)}`);
  assert.equal(obj.steps.length, 2);
  assert.equal(obj.steps[0].do, 'echo');
  assert.equal(obj.steps[0].as, 'a');
  assert.equal(obj.steps[0].with.message, 'hello');
  assert.equal(obj.steps[1].do, 'ollama');
  assert.equal(obj.steps[1].as, 'out');
  assert.equal(obj.steps[1].with.prompt, '$a.message');
});

test('host/flows/image_once.flow is a valid one-step composition of image', () => {
  const parser = require('../lib/parser');
  const file = path.join(ROOT, 'host', 'flows', 'image_once.flow');
  const obj = parser.parseFile(file);
  const yamlOk = parser.validate(obj, 'flow');
  assert.equal(yamlOk.valid, true, `image_once yaml: ${JSON.stringify(yamlOk.errors)}`);
  assert.equal(obj.steps.length, 1);
  assert.equal(obj.steps[0].do, 'image');
  assert.equal(obj.steps[0].as, 'out');
  assert.equal(obj.steps[0].with.prompt, 'hello');
});

test('host/flows/prompt_then_image.flow interpolates $a.text from ollama into image', () => {
  const parser = require('../lib/parser');
  const file = path.join(ROOT, 'host', 'flows', 'prompt_then_image.flow');
  const obj = parser.parseFile(file);
  const yamlOk = parser.validate(obj, 'flow');
  assert.equal(yamlOk.valid, true, `prompt_then_image yaml: ${JSON.stringify(yamlOk.errors)}`);
  assert.equal(obj.steps.length, 2);
  assert.equal(obj.steps[0].do, 'ollama');
  assert.equal(obj.steps[0].as, 'a');
  assert.equal(obj.steps[0].with.prompt, 'a short image-prompt request');
  assert.equal(obj.steps[1].do, 'image');
  assert.equal(obj.steps[1].as, 'out');
  assert.equal(obj.steps[1].with.prompt, '$a.text');
});

test('committed ENTITY_REGISTRY.json is generated and not empty', () => {
  const doc = JSON.parse(fs.readFileSync(path.join(ROOT, 'ENTITY_REGISTRY.json'), 'utf8'));
  assert.equal(doc.schema, 'v1');
  assert.ok(doc.entities.length > 0, 'empty { entities: [] } is a bug');
  assert.ok(doc.entities.some((e) => e.entity_id === 'tool:echo' && e.declared));
  assert.ok(doc.entities.some((e) => e.entity_id === 'workflow:echo_once'));
  assert.ok(doc.entities.some((e) => e.entity_id === 'tool:ollama' && e.declared));
  assert.ok(doc.entities.some((e) => e.entity_id === 'workflow:ollama_once'));
  assert.ok(doc.entities.some((e) => e.entity_id === 'workflow:echo_then_ollama'));
  assert.ok(doc.entities.some((e) => e.entity_id === 'tool:image' && e.declared));
  assert.ok(doc.entities.some((e) => e.entity_id === 'workflow:image_once'));
  assert.ok(doc.entities.some((e) => e.entity_id === 'workflow:prompt_then_image'));
  assert.ok(doc.entities.some((e) => e.entity_id === 'tool:ffmpeg' && e.declared));
});
