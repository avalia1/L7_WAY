#!/usr/bin/env node

const http = require('http');
const fs = require('fs');
const path = require('path');
const url = require('url');

const PORT = process.env.EMPIRE_PORT || 7377;
const L7_DIR = path.join(process.env.HOME || '', '.l7');
const EMP_DIR = path.join(process.env.HOME || '', '.emp');
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

  res.writeHead(404, { 'Content-Type': 'text/plain' });
  res.end('Not found');
});

server.listen(PORT, () => {
  console.log(`Empire server running at http://localhost:${PORT}`);
});
