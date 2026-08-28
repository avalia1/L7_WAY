/**
 * Request principal — identity plumbing (Phase 6).
 *
 * ADR 0001: 12D is an internal projection. It does not grant identity.
 * FOUNDER (Law XV) stays a gateway constant; it is never attached here.
 *
 * Token sources (one tree, no second secret):
 *   - process.env.L7_TOKEN
 *   - $L7_DIR/secrets/token  (L7_DIR default ~/.l7; missing file is fine)
 */

const crypto = require('crypto');
const fs = require('fs');
const path = require('path');

const LOOPBACK = new Set(['127.0.0.1', '::1', '::ffff:127.0.0.1']);

function prefixDir() {
  return process.env.L7_DIR || path.join(process.env.HOME || '', '.l7');
}

function remoteAddress(req) {
  if (!req) return '';
  if (req.socket && req.socket.remoteAddress) return req.socket.remoteAddress;
  if (req.connection && req.connection.remoteAddress) return req.connection.remoteAddress;
  return '';
}

function isLoopback(addr) {
  if (!addr) return false;
  const normalized = String(addr).replace(/^\[|\]$/g, '').toLowerCase();
  return LOOPBACK.has(normalized);
}

function timingSafeEqualString(a, b) {
  const bufA = Buffer.from(String(a));
  const bufB = Buffer.from(String(b));
  if (bufA.length !== bufB.length) {
    crypto.timingSafeEqual(bufA, bufA);
    return false;
  }
  return crypto.timingSafeEqual(bufA, bufB);
}

function readFileToken() {
  const tokenPath = path.join(prefixDir(), 'secrets', 'token');
  try {
    return fs.readFileSync(tokenPath, 'utf8').trim();
  } catch {
    return '';
  }
}

function configuredTokens() {
  const tokens = [];
  const fromEnv = typeof process.env.L7_TOKEN === 'string' ? process.env.L7_TOKEN.trim() : '';
  if (fromEnv) tokens.push(fromEnv);
  const fromFile = readFileToken();
  if (fromFile) tokens.push(fromFile);
  return tokens;
}

function presentedBearer(req) {
  const header = req && req.headers && (req.headers.authorization || req.headers.Authorization);
  if (typeof header !== 'string') return '';
  const match = header.match(/^Bearer\s+(.+)$/i);
  if (!match) return '';
  return match[1].trim();
}

function bearerMatches(presented) {
  if (!presented) return false;
  const expected = configuredTokens();
  let matched = false;
  for (const token of expected) {
    if (timingSafeEqualString(presented, token)) matched = true;
  }
  return matched;
}

function principal(req) {
  const loopback = isLoopback(remoteAddress(req));
  if (bearerMatches(presentedBearer(req))) {
    return Object.freeze({ id: 'operator', kind: 'bearer', loopback });
  }
  if (loopback) {
    return Object.freeze({ id: 'local', kind: 'local', loopback: true });
  }
  return Object.freeze({ id: 'anonymous', kind: 'anonymous', loopback: false });
}

module.exports = { principal };
