'use strict';

const ALLOWED_HOSTS = new Set([
  '127.0.0.1',
  'localhost',
  '::1',
  '::ffff:127.0.0.1',
  '::ffff:7f00:1',
]);
const TIMEOUT_MS = 10000;

function isHttpUrl(server) {
  return typeof server === 'string' && /^https?:\/\//i.test(server.trim());
}

function normalizeHost(hostname) {
  let host = String(hostname || '').toLowerCase();
  if (host.startsWith('[') && host.endsWith(']')) host = host.slice(1, -1);
  return host;
}

function assertLoopbackUrl(server) {
  let url;
  try {
    url = new URL(typeof server === 'string' ? server.trim() : server);
  } catch {
    throw new Error(`Invalid loopback HTTP URL: ${server}`);
  }
  const protocol = url.protocol.toLowerCase();
  if (protocol !== 'http:' && protocol !== 'https:') {
    throw new Error(`Loopback HTTP refused: protocol ${url.protocol} is not http(s) (file: and others are blocked)`);
  }
  const host = normalizeHost(url.hostname);
  if (!ALLOWED_HOSTS.has(host)) {
    throw new Error(`Loopback HTTP refused: host ${url.hostname} is not 127.0.0.1, localhost, or ::1`);
  }
  if (!url.pathname) url.pathname = '/';
  return url;
}

async function postJson(url, payload) {
  const headers = { 'Content-Type': 'application/json' };
  if (process.env.L7_TOKEN) headers.Authorization = `Bearer ${process.env.L7_TOKEN}`;
  const res = await fetch(url.href, {
    method: 'POST',
    headers,
    body: JSON.stringify(payload),
    signal: AbortSignal.timeout(TIMEOUT_MS),
  });
  const text = await res.text();
  try {
    return JSON.parse(text);
  } catch {
    throw new Error(`Loopback HTTP ${url.href} returned non-JSON (${res.status})`);
  }
}

module.exports = { isHttpUrl, assertLoopbackUrl, postJson, ALLOWED_HOSTS, TIMEOUT_MS };
