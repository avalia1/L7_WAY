/**
 * Tool/flow catalog. host/tools wins over ~/.l7/tools.
 *
 * Roots (first match wins per name):
 *   1. L7_HOST_ROOT  (default: <repo>/host) — skipped when set to empty string
 *   2. L7_DIR        (default: ~/.l7)
 */

const fs = require('fs');
const path = require('path');

const REPO_ROOT = path.resolve(__dirname, '..');

function prefixDir() {
  return process.env.L7_DIR || path.join(process.env.HOME || '', '.l7');
}

function hostRoot() {
  if (process.env.L7_HOST_ROOT === '') return null;
  if (process.env.L7_HOST_ROOT) return process.env.L7_HOST_ROOT;
  return path.join(REPO_ROOT, 'host');
}

function roots() {
  const out = [];
  const seen = new Set();
  const add = (dir) => {
    if (!dir) return;
    const resolved = path.resolve(dir);
    if (seen.has(resolved)) return;
    if (!fs.existsSync(resolved)) return;
    seen.add(resolved);
    out.push(resolved);
  };
  add(hostRoot());
  add(prefixDir());
  return out;
}

function rootLabel(root) {
  const rel = path.relative(REPO_ROOT, root);
  if (rel && !rel.startsWith('..') && !path.isAbsolute(rel)) {
    return rel.split(path.sep).join('/') || '.';
  }
  const host = hostRoot();
  if (host && path.resolve(root) === path.resolve(host)) return 'host';
  return 'prefix';
}

function sourceLabel(root, subdir, filename) {
  const full = path.join(root, subdir, filename);
  const rel = path.relative(REPO_ROOT, full);
  if (rel && !rel.startsWith('..') && !path.isAbsolute(rel)) {
    return rel.split(path.sep).join('/');
  }
  const host = hostRoot();
  if (host && path.resolve(root) === path.resolve(host)) {
    return `host/${subdir}/${filename}`;
  }
  return `${subdir}/${filename}`;
}

function findFile(subdir, name, ext) {
  const base = name.endsWith(ext) ? path.basename(name, ext) : name;
  const filename = `${base}${ext}`;
  for (const root of roots()) {
    const filePath = path.join(root, subdir, filename);
    if (fs.existsSync(filePath)) {
      return {
        name: base,
        path: filePath,
        root,
        source: sourceLabel(root, subdir, filename),
        legacy: false,
      };
    }
  }
  return null;
}

function listByExt(subdir, ext) {
  const byName = new Map();
  for (const root of roots()) {
    const dir = path.join(root, subdir);
    if (!fs.existsSync(dir)) continue;
    let names;
    try {
      names = fs.readdirSync(dir);
    } catch {
      continue;
    }
    for (const f of names) {
      if (!f.endsWith(ext)) continue;
      const name = path.basename(f, ext);
      if (byName.has(name)) continue;
      byName.set(name, {
        name,
        path: path.join(dir, f),
        root,
        source: sourceLabel(root, subdir, f),
        legacy: false,
      });
    }
  }
  return [...byName.values()].sort((a, b) => a.name.localeCompare(b.name));
}

function listTools() {
  return listByExt('tools', '.tool');
}

function listFlows() {
  return listByExt('flows', '.flow');
}

function findTool(name) {
  return findFile('tools', name, '.tool');
}

function findFlow(name) {
  return findFile('flows', name, '.flow');
}

module.exports = {
  REPO_ROOT,
  prefixDir,
  hostRoot,
  roots,
  rootLabel,
  listTools,
  listFlows,
  findTool,
  findFlow,
};
