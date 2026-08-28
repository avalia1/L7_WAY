#!/usr/bin/env node
/**
 * L7 public control plane — the product HTTP gateway.
 *
 * One listen port, one Node process, one meaning of "gateway":
 *   npm start  →  node serve.js  →  127.0.0.1:18793 (L7_PORT / L7_BIND)
 *
 * `l7 gateway` means this process. It is not:
 *   - archive/host/gateway-server.swift (stale; 18789 is OpenClaw)
 *   - ~/.l7/l7-gateway (Mac egress valve; Phase 3, not this repo)
 *   - archive/empire/server.js (former second listener; frozen)
 *
 * Law I — All flows through the Gateway. No exceptions.
 *
 * Created by: Alberto Valido Delgado / Claude (AI-generated)
 */

const http = require('http');
const path = require('path');
const url = require('url');

// Import L7 modules
const { parseFile } = require('./lib/parser');
const { executeFlow, approve, reject } = require('./lib/executor');
const gateway = require('./lib/gateway');
const stateManager = require('./lib/state');
const declaration = require('./lib/declaration');
const registry = require('./lib/registry');
const catalog = require('./lib/catalog');
const { principal } = require('./lib/principal');

const PORT = parseInt(process.env.L7_PORT || '18793', 10);
const BIND = process.env.L7_BIND || '127.0.0.1';

// ═══════════════════════════════════════════════════════════
// HTTP HELPERS
// ═══════════════════════════════════════════════════════════

function setCorsHeaders(res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
}

function sendJson(res, status, data) {
  const body = JSON.stringify(data, null, 2);
  setCorsHeaders(res);
  res.writeHead(status, {
    'Content-Type': 'application/json',
    'Content-Length': Buffer.byteLength(body),
  });
  res.end(body);
}

function parseBody(req) {
  return new Promise((resolve, reject) => {
    let body = '';
    req.on('data', (chunk) => { body += chunk; });
    req.on('end', () => {
      try { resolve(body ? JSON.parse(body) : {}); }
      catch (err) { reject(new Error('Invalid JSON body')); }
    });
    req.on('error', reject);
  });
}

function publicPrincipal(who) {
  return { kind: who.kind, loopback: who.loopback };
}

function flowRunMatch(pathname) {
  if (pathname === '/v1/flows/run') return { alias: true, name: null };
  const m = typeof pathname === 'string' && pathname.match(/^\/v1\/flows\/([^/]+)\/run$/);
  if (m) return { alias: false, name: decodeURIComponent(m[1]) };
  return null;
}

async function runDeclaredFlow(res, who, flowName, body) {
  if (!flowName) {
    sendJson(res, 400, { error: 'Flow name required' });
    return;
  }
  if (!catalog.findFlow(flowName)) {
    sendJson(res, 404, { error: `Flow not found: ${flowName}` });
    return;
  }
  const execState = await executeFlow(flowName, body.inputs || {}, {
    dryRun: body.dryRun || false,
    principal: who,
  });
  sendJson(res, 200, {
    id: execState.id,
    flow: execState.flow,
    status: execState.status,
    step: execState.step,
    results: execState.results,
    principal: publicPrincipal(who),
  });
}

// ═══════════════════════════════════════════════════════════
// REQUEST HANDLER
// ═══════════════════════════════════════════════════════════

const server = http.createServer(async (req, res) => {
  const parsed = url.parse(req.url, true);
  const who = principal(req);

  if (req.method === 'OPTIONS') {
    setCorsHeaders(res);
    res.writeHead(204);
    res.end();
    return;
  }

  try {
    // ── Health & Status ──
    if (parsed.pathname === '/' || parsed.pathname === '/health') {
      const health = await gateway.checkHealth();
      const heartStatus = gateway.heart.status();
      const fieldReport = gateway.fieldReport();
      sendJson(res, 200, {
        alive: true,
        port: PORT,
        heart: {
          id: heartStatus.id,
          incarnation: heartStatus.incarnation,
          totalBeats: heartStatus.totalBeats,
          age: heartStatus.age_human,
          alive: heartStatus.alive
        },
        field: {
          nodes: fieldReport.nodes,
          epoch: fieldReport.epoch,
          entropy: fieldReport.entropy,
          energy: fieldReport.energy
        },
        tools: health.tools,
        citizens: health.citizens,
        polarities: health.polarities,
        principal: { kind: who.kind, loopback: who.loopback }
      });
      return;
    }

    // ── Heart ──
    if (parsed.pathname === '/api/heart') {
      sendJson(res, 200, gateway.heart.status());
      return;
    }

    if (parsed.pathname === '/api/heart/awareness') {
      sendJson(res, 200, gateway.heart.awareness());
      return;
    }

    if (parsed.pathname === '/api/heart/trend') {
      sendJson(res, 200, gateway.heart.trend());
      return;
    }

    // ── Field ──
    if (parsed.pathname === '/api/field') {
      sendJson(res, 200, gateway.fieldReport());
      return;
    }

    if (parsed.pathname === '/api/field/vitals') {
      sendJson(res, 200, gateway.fieldVitals());
      return;
    }

    // ── Tools ──
    // GET /v1/tools — public contract. Declared 7D when present; never synthesized.
    if (parsed.pathname === '/v1/tools') {
      sendJson(res, 200, declaration.listPublicTools());
      return;
    }

    // GET /api/tools — old shape (name/does/server/coordinate).
    // Removal target: 2026-09-28. Successor: GET /v1/tools.
    if (parsed.pathname === '/api/tools') {
      res.setHeader('Deprecation', 'true');
      res.setHeader('Sunset', 'Wed, 28 Sep 2026 00:00:00 GMT');
      res.setHeader('Link', '</v1/tools>; rel="successor-version"');
      sendJson(res, 200, { tools: gateway.listTools() });
      return;
    }

    // ── Citizens ──
    if (parsed.pathname === '/api/citizens') {
      sendJson(res, 200, { citizens: gateway.listCitizens() });
      return;
    }

    // ── Execute tool (POST) ──
    if (parsed.pathname === '/api/call' && req.method === 'POST') {
      const body = await parseBody(req);
      if (!body.tool) {
        sendJson(res, 400, { error: 'Tool name required' });
        return;
      }
      const result = await gateway.execute(body.tool, body.arguments || {}, body.options || {});
      sendJson(res, 200, result);
      return;
    }

    // ── Transmute (POST) ──
    if (parsed.pathname === '/api/transmute' && req.method === 'POST') {
      const body = await parseBody(req);
      const citizen = gateway.transmute(body.input || body, body.options || {});
      sendJson(res, 200, citizen);
      return;
    }

    // ── Council (POST) ──
    if (parsed.pathname === '/api/council' && req.method === 'POST') {
      const body = await parseBody(req);
      if (!body.question) {
        sendJson(res, 400, { error: 'Question required' });
        return;
      }
      const report = await gateway.invokeCouncil(body.question, body.context || {});
      sendJson(res, 200, report);
      return;
    }

    // ── Domains ──
    if (parsed.pathname === '/api/domain/write' && req.method === 'POST') {
      const body = await parseBody(req);
      const result = gateway.writeToDomain(body.domain, body.name, body.content, body.metadata);
      sendJson(res, 200, result);
      return;
    }

    if (parsed.pathname === '/api/domain/read') {
      const result = gateway.readFromDomain(parsed.query.domain, parsed.query.name);
      sendJson(res, 200, result);
      return;
    }

    if (parsed.pathname === '/api/domain/transition' && req.method === 'POST') {
      const body = await parseBody(req);
      const result = gateway.transitionDomain(body.from, body.to, body.name, body.options);
      sendJson(res, 200, result);
      return;
    }

    // ── Flows ──
    if (parsed.pathname === '/api/flows') {
      const flows = catalog.listFlows().map((entry) => {
        try { return { name: entry.name, ...parseFile(entry.path) }; }
        catch { return { name: entry.name, error: 'parse error' }; }
      });
      sendJson(res, 200, { flows });
      return;
    }

    // POST /v1/flows/:name/run — public contract. The flow file is the orchestrator.
    // POST /v1/flows/run with body.flow is an alias (name still required).
    if (req.method === 'POST') {
      const run = flowRunMatch(parsed.pathname);
      if (run) {
        const body = await parseBody(req);
        const flowName = run.alias ? body.flow : run.name;
        await runDeclaredFlow(res, who, flowName, body || {});
        return;
      }
    }

    // POST /api/execute — old shape. Removal target: 2026-09-28.
    // Successor: POST /v1/flows/:name/run
    if (parsed.pathname === '/api/execute' && req.method === 'POST') {
      const body = await parseBody(req);
      if (!body.flow) { sendJson(res, 400, { error: 'Flow name required' }); return; }
      res.setHeader('Deprecation', 'true');
      res.setHeader('Sunset', 'Wed, 28 Sep 2026 00:00:00 GMT');
      res.setHeader('Link', `</v1/flows/${encodeURIComponent(body.flow)}/run>; rel="successor-version"`);
      const execState = await executeFlow(body.flow, body.inputs || {}, {
        dryRun: body.dryRun || false,
        principal: who,
      });
      sendJson(res, 200, { id: execState.id, flow: execState.flow, status: execState.status, step: execState.step, results: execState.results });
      return;
    }

    // ── Sigils ──
    if (parsed.pathname === '/api/sigil' && req.method === 'POST') {
      const body = await parseBody(req);
      const sigil = gateway.compileSigil(body.name || 'unnamed', body.steps || []);
      sendJson(res, 200, sigil);
      return;
    }

    // ── Self ──
    if (parsed.pathname === '/api/self') {
      sendJson(res, 200, gateway.self.report());
      return;
    }

    // ── 404 ──
    sendJson(res, 404, { error: 'Not found', path: parsed.pathname });

  } catch (err) {
    sendJson(res, 500, { error: err.message });
  }
});

// ═══════════════════════════════════════════════════════════
// BOOT SEQUENCE — listen only from start()
// ═══════════════════════════════════════════════════════════

function attachSignals() {
  const shutdown = async () => {
    await stop();
    process.exit(0);
  };
  process.on('SIGTERM', shutdown);
  process.on('SIGINT', shutdown);
}

async function start() {
  registry.produce();
  const report = await gateway.boot();
  await new Promise((resolve, reject) => {
    const onError = (err) => reject(err);
    server.once('error', onError);
    server.listen(PORT, BIND, () => {
      server.removeListener('error', onError);
      const addr = server.address();
      const port = typeof addr === 'object' && addr ? addr.port : PORT;
      console.log(`━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`);
      console.log(`  L7 Gateway — ONLINE`);
      console.log(`  http://${BIND}:${port}`);
      console.log(`  Tools: ${report.tools_count} | Citizens: ${report.citizens_count} | Flows: ${report.flows_count}`);
      console.log(`━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`);
      resolve();
    });
  });

  const entry = require.main && path.basename(require.main.filename);
  if (entry === 'serve.js' || entry === 'serve-gateway.js') {
    attachSignals();
  }

  const addr = server.address();
  return { server, port: typeof addr === 'object' && addr ? addr.port : PORT, bind: BIND };
}

async function stop() {
  await gateway.shutdown();
  await new Promise((resolve, reject) => {
    if (!server.listening) {
      resolve();
      return;
    }
    server.close((err) => (err ? reject(err) : resolve()));
  });
}

if (require.main === module) {
  start().catch((err) => {
    console.error('FATAL:', err.message);
    console.error(err.stack);
    process.exit(1);
  });
}

module.exports = { start, stop, PORT, BIND };

// L7:PROVENANCE
// Creator: Alberto Valido Delgado | System: L7 WAY | License: Proprietary — Framework free, products licensed (Law XXII)
// File: serve.js | Body-Hash: SHA-256:ae5a29c4e93b2520e1fecd54b33c1fdaa45a67f5a1626c8edbfdc4b503e1438a
// Chain-Hash: SHA-256:a782b44e1ffd235b3bb293f6cc4426914a78ec5dd1b668f8c93b5a44b3200035 | Signed: 2026-03-01T15:09:50.006072+00:00
// This work is the intellectual property of Alberto Valido Delgado.
// Chain: 5 works. Verify: python3 provenance.py verify serve.js
// L7:PROVENANCE