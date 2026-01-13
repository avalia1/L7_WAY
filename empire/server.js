#!/usr/bin/env node

const http = require('http');
const fs = require('fs');
const path = require('path');
const url = require('url');

// Import L7 modules
const { parseFile, listFiles } = require('../lib/parser');
const { executeFlow, approve, reject, showStatus, listExecutions } = require('../lib/executor');
const gateway = require('../lib/gateway');
const stateManager = require('../lib/state');

const PORT = process.env.EMPIRE_PORT || 7377;
const L7_DIR = path.join(process.env.HOME || '', '.l7');
const EMP_DIR = path.join(process.env.HOME || '', '.emp');
const TOOLS_DIR = path.join(L7_DIR, 'tools');
const FLOWS_DIR = path.join(L7_DIR, 'flows');
const PUBLIC_DIR = path.join(__dirname, 'public');
const AUDIT_LOG = process.env.AVLI_AUDIT_LOG || path.join(process.env.HOME || '', '.l7', 'audit.log');
const TRANSITION_LOG = process.env.AVLI_TRANSITION_LOG || path.join(process.env.HOME || '', '.l7', 'transitions.log');

function sendJson(res, status, data) {
  const body = JSON.stringify(data, null, 2);
  res.writeHead(status, {
    'Content-Type': 'application/json',
    'Content-Length': Buffer.byteLength(body),
  });
  res.end(body);
}

function sendFile(res, filePath, contentType) {
  fs.readFile(filePath, (err, data) => {
    if (err) {
      res.writeHead(404, { 'Content-Type': 'text/plain' });
      res.end('Not found');
      return;
    }
    res.writeHead(200, { 'Content-Type': contentType });
    res.end(data);
  });
}

function isFileType(fileName, extension) {
  return fileName.endsWith(extension) && !fileName.includes('..') && !path.isAbsolute(fileName);
}

function listSidecarFiles(baseFilePath) {
  const sidecarDir = `${baseFilePath}.d`;
  try {
    const files = fs.readdirSync(sidecarDir);
    return files.filter((file) => !file.includes('..') && !path.isAbsolute(file));
  } catch {
    return [];
  }
}

function readSidecarFile(baseFilePath, fileName, res) {
  const sidecarDir = `${baseFilePath}.d`;
  const targetPath = path.join(sidecarDir, fileName);
  if (!targetPath.startsWith(sidecarDir)) {
    sendJson(res, 400, { error: 'Invalid file' });
    return;
  }
  fs.readFile(targetPath, 'utf8', (err, data) => {
    if (err) {
      sendJson(res, 404, { error: 'Not found' });
      return;
    }
    sendJson(res, 200, { file: fileName, content: data });
  });
}

function readLogFile(filePath, limit = 120) {
  try {
    const content = fs.readFileSync(filePath, 'utf8');
    const lines = content.split('\n').filter(Boolean);
    const tail = lines.slice(-limit);
    return tail.map((line) => {
      try {
        return JSON.parse(line);
      } catch {
        return { raw: line };
      }
    });
  } catch {
    return [];
  }
}

/**
 * Parse JSON body from request
 */
function parseBody(req) {
  return new Promise((resolve, reject) => {
    let body = '';
    req.on('data', (chunk) => { body += chunk; });
    req.on('end', () => {
      try {
        resolve(body ? JSON.parse(body) : {});
      } catch (err) {
        reject(new Error('Invalid JSON body'));
      }
    });
    req.on('error', reject);
  });
}

/**
 * List .tool files with parsed content
 */
function listToolFiles() {
  if (!fs.existsSync(TOOLS_DIR)) return [];
  return fs.readdirSync(TOOLS_DIR)
    .filter(f => f.endsWith('.tool'))
    .map(f => {
      const name = path.basename(f, '.tool');
      const toolPath = path.join(TOOLS_DIR, f);
      try {
        const tool = parseFile(toolPath);
        return { name, ...tool };
      } catch {
        return { name, error: 'parse error' };
      }
    });
}

/**
 * List .flow files with parsed content
 */
function listFlowFiles() {
  if (!fs.existsSync(FLOWS_DIR)) return [];
  return fs.readdirSync(FLOWS_DIR)
    .filter(f => f.endsWith('.flow'))
    .map(f => {
      const name = path.basename(f, '.flow');
      const flowPath = path.join(FLOWS_DIR, f);
      try {
        const flow = parseFile(flowPath);
        return { name, ...flow };
      } catch {
        return { name, error: 'parse error' };
      }
    });
}

const server = http.createServer((req, res) => {
  const parsed = url.parse(req.url, true);

  if (parsed.pathname === '/api/citizens') {
    fs.readdir(L7_DIR, (err, files) => {
      if (err) {
        sendJson(res, 200, { citizens: [] });
        return;
      }
      const citizens = files
        .filter((file) => isFileType(file, '.l7'))
        .map((file) => ({
          id: path.basename(file, '.l7'),
          file,
        }))
        .sort((a, b) => a.id.localeCompare(b.id));
      sendJson(res, 200, { citizens });
    });
    return;
  }

  if (parsed.pathname === '/api/citizen' || parsed.pathname === '/api/legion') {
    const file = parsed.query.file;
    const extension = parsed.pathname === '/api/legion' ? '.lg' : '.l7';
    if (!file || !isFileType(file, extension)) {
      sendJson(res, 400, { error: 'Invalid file' });
      return;
    }
    const filePath = path.join(L7_DIR, file);
    fs.readFile(filePath, 'utf8', (err, data) => {
      if (err) {
        sendJson(res, 404, { error: 'Not found' });
        return;
      }
      const sidecar = extension === '.l7' ? listSidecarFiles(filePath) : [];
      sendJson(res, 200, { file, content: data, sidecar });
    });
    return;
  }

  if (parsed.pathname === '/api/legions') {
    fs.readdir(L7_DIR, (err, files) => {
      if (err) {
        sendJson(res, 200, { legions: [] });
        return;
      }
      const legions = files
        .filter((file) => isFileType(file, '.lg'))
        .map((file) => ({
          id: path.basename(file, '.lg'),
          file,
        }))
        .sort((a, b) => a.id.localeCompare(b.id));
      sendJson(res, 200, { legions });
    });
    return;
  }

  if (parsed.pathname === '/api/launchers') {
    fs.readdir(EMP_DIR, (err, files) => {
      if (err) {
        sendJson(res, 200, { launchers: [] });
        return;
      }
      const launchers = files
        .filter((file) => isFileType(file, '.emp'))
        .map((file) => ({
          id: path.basename(file, '.emp'),
          file,
        }))
        .sort((a, b) => a.id.localeCompare(b.id));
      sendJson(res, 200, { launchers });
    });
    return;
  }

  if (parsed.pathname === '/api/launcher') {
    const file = parsed.query.file;
    if (!file || !isFileType(file, '.emp')) {
      sendJson(res, 400, { error: 'Invalid file' });
      return;
    }
    const filePath = path.join(EMP_DIR, file);
    fs.readFile(filePath, 'utf8', (err, data) => {
      if (err) {
        sendJson(res, 404, { error: 'Not found' });
        return;
      }
      sendJson(res, 200, { file, content: data });
    });
    return;
  }

  if (parsed.pathname === '/api/sidecar') {
    const file = parsed.query.file;
    const item = parsed.query.item;
    if (!file || !isFileType(file, '.l7') || !item) {
      sendJson(res, 400, { error: 'Invalid request' });
      return;
    }
    const filePath = path.join(L7_DIR, file);
    readSidecarFile(filePath, item, res);
    return;
  }

  if (parsed.pathname === '/api/audit') {
    const limit = Number.parseInt(parsed.query.limit || '120', 10) || 120;
    sendJson(res, 200, { entries: readLogFile(AUDIT_LOG, limit) });
    return;
  }

  if (parsed.pathname === '/api/transitions') {
    const limit = Number.parseInt(parsed.query.limit || '120', 10) || 120;
    sendJson(res, 200, { entries: readLogFile(TRANSITION_LOG, limit) });
    return;
  }

  if (parsed.pathname === '/' || parsed.pathname === '/index.html') {
    sendFile(res, path.join(PUBLIC_DIR, 'index.html'), 'text/html');
    return;
  }

  if (parsed.pathname === '/styles.css') {
    sendFile(res, path.join(PUBLIC_DIR, 'styles.css'), 'text/css');
    return;
  }

  if (parsed.pathname === '/app.js') {
    sendFile(res, path.join(PUBLIC_DIR, 'app.js'), 'application/javascript');
    return;
  }

  // ============================================
  // L7 Flow System API
  // ============================================

  // List all tools (.tool files)
  if (parsed.pathname === '/api/tools') {
    const tools = listToolFiles();
    sendJson(res, 200, { tools });
    return;
  }

  // List all flows (.flow files)
  if (parsed.pathname === '/api/flows') {
    const flows = listFlowFiles();
    sendJson(res, 200, { flows });
    return;
  }

  // Get a single flow by name
  if (parsed.pathname === '/api/flow') {
    const name = parsed.query.name;
    if (!name) {
      sendJson(res, 400, { error: 'Flow name required' });
      return;
    }
    const flowPath = path.join(FLOWS_DIR, `${name}.flow`);
    if (!fs.existsSync(flowPath)) {
      sendJson(res, 404, { error: 'Flow not found' });
      return;
    }
    try {
      const flow = parseFile(flowPath);
      sendJson(res, 200, { flow });
    } catch (err) {
      sendJson(res, 500, { error: err.message });
    }
    return;
  }

  // Execute a flow (POST)
  if (parsed.pathname === '/api/execute' && req.method === 'POST') {
    parseBody(req).then(async (body) => {
      const { flow, inputs = {}, dryRun = false } = body;

      if (!flow) {
        sendJson(res, 400, { error: 'Flow name required' });
        return;
      }

      try {
        const execState = await executeFlow(flow, inputs, { dryRun });
        sendJson(res, 200, {
          id: execState.id,
          flow: execState.flow,
          status: execState.status,
          step: execState.step,
          results: execState.results
        });
      } catch (err) {
        sendJson(res, 500, { error: err.message });
      }
    }).catch((err) => {
      sendJson(res, 400, { error: err.message });
    });
    return;
  }

  // Execute a single tool (POST)
  if (parsed.pathname === '/api/call' && req.method === 'POST') {
    parseBody(req).then(async (body) => {
      const { tool, arguments: args = {} } = body;

      if (!tool) {
        sendJson(res, 400, { error: 'Tool name required' });
        return;
      }

      try {
        const result = await gateway.execute(tool, args);
        sendJson(res, 200, result);
      } catch (err) {
        sendJson(res, 500, { error: err.message });
      }
    }).catch((err) => {
      sendJson(res, 400, { error: err.message });
    });
    return;
  }

  // Approve a checkpoint (POST)
  if (parsed.pathname === '/api/approve' && req.method === 'POST') {
    parseBody(req).then((body) => {
      const { flow, id } = body;

      if (!flow || !id) {
        sendJson(res, 400, { error: 'Flow name and id required' });
        return;
      }

      try {
        const execState = approve(flow, id);
        sendJson(res, 200, {
          id: execState.id,
          flow: execState.flow,
          status: execState.status,
          message: 'Checkpoint approved'
        });
      } catch (err) {
        sendJson(res, 500, { error: err.message });
      }
    }).catch((err) => {
      sendJson(res, 400, { error: err.message });
    });
    return;
  }

  // Reject a checkpoint (POST)
  if (parsed.pathname === '/api/reject' && req.method === 'POST') {
    parseBody(req).then((body) => {
      const { flow, id } = body;

      if (!flow || !id) {
        sendJson(res, 400, { error: 'Flow name and id required' });
        return;
      }

      try {
        const execState = reject(flow, id);
        sendJson(res, 200, {
          id: execState.id,
          flow: execState.flow,
          status: execState.status,
          message: 'Checkpoint rejected'
        });
      } catch (err) {
        sendJson(res, 500, { error: err.message });
      }
    }).catch((err) => {
      sendJson(res, 400, { error: err.message });
    });
    return;
  }

  // Resume execution after checkpoint approval (POST)
  if (parsed.pathname === '/api/resume' && req.method === 'POST') {
    parseBody(req).then(async (body) => {
      const { flow, id } = body;

      if (!flow || !id) {
        sendJson(res, 400, { error: 'Flow name and id required' });
        return;
      }

      try {
        const execState = await executeFlow(flow, {}, { resume: id });
        sendJson(res, 200, {
          id: execState.id,
          flow: execState.flow,
          status: execState.status,
          step: execState.step,
          results: execState.results
        });
      } catch (err) {
        sendJson(res, 500, { error: err.message });
      }
    }).catch((err) => {
      sendJson(res, 400, { error: err.message });
    });
    return;
  }

  // Get execution status
  if (parsed.pathname === '/api/status') {
    const flow = parsed.query.flow;
    const id = parsed.query.id;

    if (!flow || !id) {
      sendJson(res, 400, { error: 'Flow name and id required' });
      return;
    }

    const execState = stateManager.load(flow, id);
    if (!execState) {
      sendJson(res, 404, { error: 'Execution not found' });
      return;
    }

    sendJson(res, 200, execState);
    return;
  }

  // List executions
  if (parsed.pathname === '/api/executions') {
    const flow = parsed.query.flow || null;
    const executions = stateManager.list(flow);
    sendJson(res, 200, { executions });
    return;
  }

  // Gateway health check
  if (parsed.pathname === '/api/gateway/health') {
    gateway.checkHealth().then((healthy) => {
      sendJson(res, 200, {
        gateway: healthy ? 'ok' : 'unavailable',
        mode: gateway.config.mode,
        url: gateway.config.gatewayUrl
      });
    });
    return;
  }

  res.writeHead(404, { 'Content-Type': 'text/plain' });
  res.end('Not found');
});

server.listen(PORT, () => {
  console.log(`Empire server running at http://localhost:${PORT}`);
});
