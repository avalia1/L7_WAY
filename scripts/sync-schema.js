#!/usr/bin/env node
/**
 * Keep generated schema artifacts identical to schema/v1/.
 *   node scripts/sync-schema.js
 *
 * Copies schema/v1/common-lingua.schema.json → L7_SCHEMA.json
 * Writes ENTITY_REGISTRY.json from host/tools and host/flows.
 */

const fs = require('fs');
const path = require('path');

const ROOT = path.resolve(__dirname, '..');
const SRC = path.join(ROOT, 'schema', 'v1', 'common-lingua.schema.json');
const DEST = path.join(ROOT, 'L7_SCHEMA.json');

fs.copyFileSync(SRC, DEST);
console.log(`sync-schema: wrote ${path.relative(ROOT, DEST)} from schema/v1/common-lingua.schema.json`);

const registry = require('../lib/registry');
const result = registry.produceRepo();
console.log(`sync-schema: wrote ENTITY_REGISTRY.json (${result.count} entities)`);
