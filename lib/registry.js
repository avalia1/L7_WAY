/**
 * Entity registry produced from *.tool and *.flow.
 * Markdown registries are documentation, not the live source of truth.
 * Empty { entities: [] } while catalog files exist is a bug.
 */

const fs = require('fs');
const path = require('path');
const catalog = require('./catalog');
const { hasDeclaration } = require('./declaration');

const DEFAULT_OWNER = 'Alberto Valido Delgado';
const DEFAULT_BIRTH = '2026-08-28';

function asDateString(value) {
  if (!value) return DEFAULT_BIRTH;
  if (value instanceof Date && !Number.isNaN(value.getTime())) {
    return value.toISOString().slice(0, 10);
  }
  return String(value);
}

function statusFrom(obj) {
  if (obj && obj.deprecated) return 'deprecated';
  const lifecycle = obj && obj.l7 && obj.l7.timeVersioning && obj.l7.timeVersioning.lifecycle;
  if (lifecycle === 'deprecated') return 'deprecated';
  if (obj && obj.status === 'archived') return 'archived';
  if (obj && obj.status === 'deprecated') return 'deprecated';
  return 'active';
}

function toEntity(obj, entry, entityType) {
  const name = (obj && obj.name) || entry.name;
  const declared = hasDeclaration(obj);
  return {
    entity_id: `${entityType}:${name}`,
    entity_type: entityType,
    birth_date: asDateString(obj && obj.birth_date),
    owner: (obj && obj.owner) || DEFAULT_OWNER,
    status: statusFrom(obj),
    lineage: (obj && (obj.lineage || obj.mcp_tool)) || entry.source,
    source: entry.source,
    declared,
    l7_declaration: declared ? obj.l7 : null,
  };
}

function loadParsed(entry) {
  const { parseFile } = require('./parser');
  try {
    return parseFile(entry.path) || {};
  } catch {
    return { name: entry.name };
  }
}

function build() {
  const entities = [];
  for (const entry of catalog.listTools()) {
    const obj = loadParsed(entry);
    entities.push(toEntity(obj, entry, 'tool'));
  }
  for (const entry of catalog.listFlows()) {
    const obj = loadParsed(entry);
    entities.push(toEntity(obj, entry, 'workflow'));
  }
  entities.sort((a, b) => a.entity_id.localeCompare(b.entity_id));
  return {
    schema: 'v1',
    generated_from: catalog.roots().map((root) => catalog.rootLabel(root)),
    entities,
  };
}

function produce(dest) {
  const doc = build();
  const out = dest || path.join(catalog.prefixDir(), 'state', 'ENTITY_REGISTRY.json');
  fs.mkdirSync(path.dirname(out), { recursive: true });
  fs.writeFileSync(out, `${JSON.stringify(doc, null, 2)}\n`);
  return { path: out, count: doc.entities.length, doc };
}

function produceRepo() {
  return produce(path.join(catalog.REPO_ROOT, 'ENTITY_REGISTRY.json'));
}

module.exports = {
  build,
  produce,
  produceRepo,
  DEFAULT_BIRTH,
  DEFAULT_OWNER,
};
