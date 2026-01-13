#!/usr/bin/env node

/**
 * L7 Migration Script - Convert .l7 files to .tool format
 *
 * Usage:
 *   node migrate.js preview           - Show what would be migrated
 *   node migrate.js run               - Perform migration
 *   node migrate.js run --dry-run     - Parse but don't write
 */

const fs = require('fs');
const path = require('path');
const yaml = require('js-yaml');
const { parseLegacyL7 } = require('./parser');

const L7_DIR = process.env.L7_DIR || path.join(process.env.HOME, '.l7');
const TOOLS_DIR = path.join(L7_DIR, 'tools');

// Map capability strings to simplified enum
const CAPABILITY_MAP = {
  'communicate': 'communicate',
  'data': 'fetch',
  'fetch': 'fetch',
  'analyze': 'analyze',
  'automate': 'automate',
  'render': 'render',
  'search': 'search',
  // Default fallback
  'other': 'automate'
};

/**
 * Extract MCP server name from entity_id
 * e.g., "dialpad.dialpad_send_sms" -> { server: "dialpad", tool: "dialpad_send_sms" }
 */
function parseEntityId(entityId) {
  if (!entityId) return { server: 'unknown', tool: 'unknown' };

  const parts = entityId.split('.');
  if (parts.length >= 2) {
    return {
      server: parts[0],
      tool: parts.slice(1).join('_')
    };
  }
  return { server: 'unknown', tool: entityId };
}

/**
 * Convert legacy L7 object to new tool format
 */
function convertToTool(legacy, filename) {
  const entityId = legacy.entity_id || path.basename(filename, '.l7');
  const { server, tool } = parseEntityId(entityId);
  const l7 = legacy.l7 || legacy.L7 || {};

  // Parse capability from various formats
  let capability = 'automate';
  if (l7.capability) {
    const capStr = Array.isArray(l7.capability) ? l7.capability[0] : l7.capability;
    capability = CAPABILITY_MAP[capStr.toLowerCase()] || 'automate';
  }

  // Parse data section for PII
  let pii = false;
  if (l7.data) {
    const dataStr = Array.isArray(l7.data) ? l7.data.join(',') : l7.data;
    pii = dataStr.toLowerCase().includes('pii');
  }

  // Parse policy for approval
  let approval = false;
  if (l7.policy_intent) {
    const policyStr = Array.isArray(l7.policy_intent) ? l7.policy_intent.join(',') : l7.policy_intent;
    approval = policyStr.toLowerCase().includes('approval') && !policyStr.includes('no_approval');
  }

  // Parse identity for audit
  let audit = true;
  if (l7.identity_security) {
    const secStr = Array.isArray(l7.identity_security) ? l7.identity_security.join(',') : l7.identity_security;
    audit = !secStr.toLowerCase().includes('audit_off');
  }

  // Build needs from docs.inputs if available
  const needs = {};
  const docs = legacy.docs || {};
  if (docs.inputs) {
    let inputsStr = docs.inputs;
    // Handle array or string
    if (Array.isArray(inputsStr)) {
      inputsStr = inputsStr.join(', ');
    }
    if (typeof inputsStr !== 'string') {
      inputsStr = String(inputsStr);
    }
    // Parse format like "entity_id, intent, payload(to, subject, html, text)"
    const inputParts = inputsStr.split(',').map(s => s.trim());
    for (const part of inputParts) {
      const match = part.match(/^([a-zA-Z_]+)(?:\(([^)]+)\))?$/);
      if (match) {
        const [, name, nested] = match;
        if (nested) {
          // It's a nested object
          needs[name] = 'object';
        } else {
          needs[name] = 'string';
        }
      }
    }
  }

  // Build gives from docs.outputs
  const gives = {};
  if (docs.outputs) {
    let outputsStr = docs.outputs;
    if (Array.isArray(outputsStr)) {
      outputsStr = outputsStr.join(', ');
    }
    if (typeof outputsStr !== 'string') {
      outputsStr = String(outputsStr);
    }
    const outputParts = outputsStr.split(',').map(s => s.trim());
    for (const part of outputParts) {
      if (part) gives[part] = 'string';
    }
  }

  // Build the new tool object
  const newTool = {
    name: tool.replace(/[.-]/g, '_'),
    description: docs.description || `${tool} tool`,
    does: capability,
    server: server,
    mcp_tool: tool
  };

  if (Object.keys(needs).length > 0) {
    newTool.needs = needs;
  }

  if (Object.keys(gives).length > 0) {
    newTool.gives = gives;
  }

  newTool.pii = pii;
  newTool.approval = approval;
  newTool.audit = audit;
  newTool.output = 'json';
  newTool.runs = 'once';
  newTool.version = 'v1';

  return newTool;
}

/**
 * Convert tool object to YAML string
 */
function toYaml(tool) {
  // Custom formatting for readability
  const lines = [];

  lines.push(`name: ${tool.name}`);
  if (tool.description) lines.push(`description: ${tool.description}`);
  lines.push(`does: ${tool.does}`);
  lines.push(`server: ${tool.server}`);
  if (tool.mcp_tool && tool.mcp_tool !== tool.name) {
    lines.push(`mcp_tool: ${tool.mcp_tool}`);
  }
  lines.push('');

  if (tool.needs && Object.keys(tool.needs).length > 0) {
    lines.push('needs:');
    for (const [k, v] of Object.entries(tool.needs)) {
      lines.push(`  ${k}: ${v}`);
    }
    lines.push('');
  }

  if (tool.gives && Object.keys(tool.gives).length > 0) {
    lines.push('gives:');
    for (const [k, v] of Object.entries(tool.gives)) {
      lines.push(`  ${k}: ${v}`);
    }
    lines.push('');
  }

  lines.push(`pii: ${tool.pii}`);
  lines.push(`approval: ${tool.approval}`);
  lines.push(`audit: ${tool.audit}`);
  lines.push(`output: ${tool.output}`);
  lines.push(`runs: ${tool.runs}`);
  lines.push(`version: ${tool.version}`);

  return lines.join('\n');
}

/**
 * Find all .l7 files in the root L7_DIR
 */
function findLegacyFiles() {
  if (!fs.existsSync(L7_DIR)) return [];

  return fs.readdirSync(L7_DIR)
    .filter(f => f.endsWith('.l7'))
    .map(f => path.join(L7_DIR, f));
}

/**
 * Preview migration
 */
function preview() {
  const files = findLegacyFiles();
  console.log(`Found ${files.length} legacy .l7 files\n`);

  for (const file of files.slice(0, 10)) {
    const content = fs.readFileSync(file, 'utf8');
    const legacy = parseLegacyL7(content);
    const tool = convertToTool(legacy, file);

    console.log(`${path.basename(file)} -> ${tool.name}.tool`);
    console.log(`  does: ${tool.does}, server: ${tool.server}, pii: ${tool.pii}`);
  }

  if (files.length > 10) {
    console.log(`\n... and ${files.length - 10} more`);
  }

  console.log(`\nRun 'node migrate.js run' to perform migration`);
}

/**
 * Run migration
 */
function run(dryRun = false) {
  const files = findLegacyFiles();

  if (!dryRun) {
    fs.mkdirSync(TOOLS_DIR, { recursive: true });
  }

  let success = 0;
  let failed = 0;

  for (const file of files) {
    try {
      const content = fs.readFileSync(file, 'utf8');
      const legacy = parseLegacyL7(content);
      const tool = convertToTool(legacy, file);
      const yamlContent = toYaml(tool);

      const outFile = path.join(TOOLS_DIR, `${tool.name}.tool`);

      if (dryRun) {
        console.log(`Would write: ${outFile}`);
      } else {
        fs.writeFileSync(outFile, yamlContent);
        console.log(`✓ ${path.basename(file)} -> ${tool.name}.tool`);
      }
      success++;
    } catch (err) {
      console.error(`✗ ${path.basename(file)}: ${err.message}`);
      failed++;
    }
  }

  console.log(`\nMigration ${dryRun ? '(dry run) ' : ''}complete: ${success} success, ${failed} failed`);
}

// CLI
function main() {
  const [,, command, flag] = process.argv;

  switch (command) {
    case 'preview':
      preview();
      break;
    case 'run':
      run(flag === '--dry-run');
      break;
    default:
      console.log('Usage:');
      console.log('  node migrate.js preview       - Show what would be migrated');
      console.log('  node migrate.js run           - Perform migration');
      console.log('  node migrate.js run --dry-run - Parse but don\'t write');
  }
}

module.exports = { convertToTool, toYaml };

if (require.main === module) {
  main();
}
