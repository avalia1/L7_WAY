const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('fs');
const path = require('path');

const ROOT = path.join(__dirname, '..');

function read(rel) {
  return fs.readFileSync(path.join(ROOT, rel), 'utf8');
}

test('host/l7 compiles Swift from HOST/swift and runs Node as gateway', () => {
  const src = read('host/l7');

  assert.match(src, /run-gateway\.sh/);
  assert.match(src, /HOST\/swift/);
  assert.match(src, /egress\|claw/);

  const gatewayCase = src.match(/gateway\|gate\|gw\)[\s\S]*?;;/);
  assert.ok(gatewayCase, 'gateway|gate|gw case missing');
  assert.match(gatewayCase[0], /run-gateway\.sh/);
  assert.equal(
    /\$L7_DIR\/l7-gateway\.swift/.test(gatewayCase[0]),
    false,
    'l7 gateway must not compile $L7_DIR/l7-gateway.swift',
  );
  assert.equal(
    /SOURCE="\$L7_DIR\/l7-gateway\.swift"/.test(src),
    false,
    'dispatcher must not compile gateway from $L7_DIR/l7-gateway.swift',
  );
});
