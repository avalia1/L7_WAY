/**
 * THREE PATHS — Law LX: Bibliotheca Trium Viarum
 *
 * Declared by Constantine (The Philosopher), 2026-03-07
 * Ratified unanimously by the Triad: Samael, The Unnamed, Raphael
 *
 * Every work carries a Path:
 *   RIGHT (W) — Dextera Via — healing, building, creating
 *   MIDDLE (G) — Media Via — everyday operational
 *   LEFT (R) — Sinistra Via — destructive, offensive, LOCKED
 *
 * Left Hand works require explicit Philosopher authorization.
 * The Gateway checks Path before routing.
 * The NIS logs all access attempts.
 * The Vault encrypts Left Hand works at rest.
 */

'use strict';

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

// ─── Path Classification ───
const PATH = Object.freeze({
  RIGHT:  'W',  // White circle — freely available
  MIDDLE: 'G',  // Gold diamond — no restrictions
  LEFT:   'R',  // Red inverted triangle — LOCKED
});

const PATH_NAME = Object.freeze({
  W: 'Dextera Via (Right Hand)',
  G: 'Media Via (Middle Path)',
  R: 'Sinistra Via (Left Hand)',
});

// ─── Classification Registry ───
// Pattern-based classification of works, tools, and files
const CLASSIFICATIONS = [
  // LEFT HAND — Locked
  { pattern: /cipher[-_]?lab/i,         path: PATH.LEFT, reason: 'Encryption breaking techniques' },
  { pattern: /red[-_]?team[-_]?siege/i, path: PATH.LEFT, reason: 'Multi-vector attack simulation' },
  { pattern: /lapis[-_]?serpent/i,       path: PATH.LEFT, reason: 'Perception-based cipher breaker' },
  { pattern: /herald_cipher/i,          path: PATH.LEFT, reason: 'Cipher operations — dual-use offensive' },
  { pattern: /exploit/i,                path: PATH.LEFT, reason: 'Exploit development' },
  { pattern: /attack/i,                 path: PATH.LEFT, reason: 'Attack tooling' },
  { pattern: /crack/i,                  path: PATH.LEFT, reason: 'Cracking techniques' },
  { pattern: /malware/i,                path: PATH.LEFT, reason: 'Malware analysis' },
  { pattern: /vuln(erabilit)?/i,        path: PATH.LEFT, reason: 'Vulnerability research' },

  // RIGHT HAND — Encouraged
  { pattern: /keykeeper/i,              path: PATH.RIGHT, reason: 'Security — protective' },
  { pattern: /sentinel/i,               path: PATH.RIGHT, reason: 'Border guard — defensive' },
  { pattern: /gallery|imago|anima/i,    path: PATH.RIGHT, reason: 'Creative — constructive' },
  { pattern: /rose/i,                   path: PATH.RIGHT, reason: 'Visualization — creative' },
  { pattern: /wallet|aegis/i,           path: PATH.RIGHT, reason: 'Secure storage — protective' },
  { pattern: /resonance|flux|tesseract/i, path: PATH.RIGHT, reason: 'Creative tools' },
  { pattern: /quantum[-_]?gravity/i,    path: PATH.RIGHT, reason: 'Pure science — constructive' },
  { pattern: /manuscript|great[-_]?work/i, path: PATH.RIGHT, reason: 'Philosophy — constructive' },

  // MIDDLE — Default (everything else)
];

// ─── Audit Trail (River Acheron) ───
const AUDIT_LOG = [];
const AUDIT_MAX = 10000;

function audit(event) {
  const entry = {
    timestamp: new Date().toISOString(),
    ...event,
  };
  AUDIT_LOG.push(entry);
  if (AUDIT_LOG.length > AUDIT_MAX) AUDIT_LOG.shift();

  // Persist to disk every 100 entries
  if (AUDIT_LOG.length % 100 === 0) {
    persistAudit();
  }

  return entry;
}

function persistAudit() {
  try {
    const auditPath = path.join(process.env.L7_DIR || path.join(process.env.HOME, '.l7'), 'audit');
    if (!fs.existsSync(auditPath)) fs.mkdirSync(auditPath, { recursive: true });
    const logFile = path.join(auditPath, `audit-${new Date().toISOString().slice(0, 10)}.jsonl`);
    const lines = AUDIT_LOG.slice(-100).map(e => JSON.stringify(e)).join('\n') + '\n';
    fs.appendFileSync(logFile, lines);
  } catch (e) {
    // Silent — audit failure must not crash the system
  }
}

// ─── Season of Grace (30-day breathing room for new citizens) ───
const GRACE_PERIOD_DAYS = 30;
const graceRegistry = new Map(); // citizenId → { born: Date, expires: Date }

/**
 * Register a new citizen in the grace period.
 * During grace, no Path restrictions apply — the citizen is free to explore.
 */
function grantGrace(citizenId, bornDate) {
  const born = new Date(bornDate || Date.now());
  const expires = new Date(born.getTime() + GRACE_PERIOD_DAYS * 24 * 60 * 60 * 1000);
  graceRegistry.set(citizenId, { born, expires, path: null });
  audit({
    type: 'GRACE_GRANTED',
    citizenId,
    born: born.toISOString(),
    expires: expires.toISOString(),
    river: 'styx',
  });
  return { citizenId, born, expires, daysRemaining: GRACE_PERIOD_DAYS };
}

/**
 * Check if a citizen is still in their grace period.
 */
function inGracePeriod(citizenId) {
  const grace = graceRegistry.get(citizenId);
  if (!grace) return false;
  if (Date.now() > grace.expires.getTime()) {
    return false; // Grace has ended — classification review due
  }
  return true;
}

/**
 * End grace period and let the citizen choose their path.
 * Triad confirms the choice on day 31.
 */
function concludeGrace(citizenId, chosenPath) {
  const grace = graceRegistry.get(citizenId);
  if (grace) {
    grace.path = chosenPath;
    audit({
      type: 'GRACE_CONCLUDED',
      citizenId,
      chosenPath,
      pathName: PATH_NAME[chosenPath],
      river: 'styx',
    });
  }
  return { citizenId, path: chosenPath, name: PATH_NAME[chosenPath] };
}

// ─── Path Classification Engine ───

/**
 * Classify a work/file/tool by its Path.
 * Returns { path: 'W'|'G'|'R', name: string, reason: string }
 *
 * Citizens in their grace period are classified as MIDDLE regardless,
 * allowing free exploration for 30 days.
 */
function classify(identifier, citizenId) {
  // Grace period override — new citizens explore freely
  if (citizenId && inGracePeriod(citizenId)) {
    return {
      path: PATH.MIDDLE,
      name: 'Grace Period — free to explore',
      reason: `Citizen ${citizenId} is within 30-day grace period`,
      identifier,
      grace: true,
    };
  }

  const id = String(identifier).toLowerCase();

  for (const rule of CLASSIFICATIONS) {
    if (rule.pattern.test(id)) {
      return {
        path: rule.path,
        name: PATH_NAME[rule.path],
        reason: rule.reason,
        identifier,
      };
    }
  }

  // Default: Middle Path
  return {
    path: PATH.MIDDLE,
    name: PATH_NAME[PATH.MIDDLE],
    reason: 'Default classification — operational',
    identifier,
  };
}

// ─── Authorization Engine ───

// Active authorizations (in-memory, cleared on restart)
const authorizations = new Map();

/**
 * Grant Left Hand access.
 * ONLY the Philosopher can call this (enforced by caller context).
 */
function authorize(citizenId, workId, scope, duration_ms = 3600000) {
  const auth = {
    citizenId,
    workId,
    scope,
    granted: Date.now(),
    expires: Date.now() + duration_ms,
    token: crypto.randomBytes(16).toString('hex'),
  };
  const key = `${citizenId}:${workId}`;
  authorizations.set(key, auth);

  audit({
    type: 'AUTHORIZATION_GRANTED',
    citizenId,
    workId,
    scope,
    expires: new Date(auth.expires).toISOString(),
    river: 'styx', // The oath
  });

  return auth;
}

/**
 * Check if a citizen has active authorization for a Left Hand work.
 */
function isAuthorized(citizenId, workId) {
  const key = `${citizenId}:${workId}`;
  const auth = authorizations.get(key);
  if (!auth) return false;
  if (Date.now() > auth.expires) {
    authorizations.delete(key);
    audit({
      type: 'AUTHORIZATION_EXPIRED',
      citizenId,
      workId,
      river: 'lethe', // Forgotten
    });
    return false;
  }
  return true;
}

/**
 * Revoke authorization immediately.
 */
function revoke(citizenId, workId) {
  const key = `${citizenId}:${workId}`;
  authorizations.delete(key);
  audit({
    type: 'AUTHORIZATION_REVOKED',
    citizenId,
    workId,
    river: 'styx',
  });
}

// ─── Gateway Integration: Access Check ───

/**
 * Check access before routing.
 * Returns { allowed: boolean, classification, reason }
 *
 * This is called by the Gateway on every routing decision.
 */
function checkAccess(citizenId, resourceId) {
  const classification = classify(resourceId);

  // Right Hand and Middle Path: always allowed
  if (classification.path !== PATH.LEFT) {
    audit({
      type: 'ACCESS_GRANTED',
      citizenId,
      resourceId,
      path: classification.path,
      river: 'acheron',
    });
    return { allowed: true, classification, reason: 'Path permits access' };
  }

  // Left Hand: check authorization
  // The Founder (Law XV) always has access
  if (citizenId === 'philosopher' || citizenId === 'founder' || citizenId === 'constantine') {
    audit({
      type: 'ACCESS_GRANTED',
      citizenId,
      resourceId,
      path: classification.path,
      reason: 'Law XV — Founder\'s Right / Constantine\'s Authority',
      river: 'styx',
    });
    return { allowed: true, classification, reason: 'Constantine\'s authority — Law XV' };
  }

  // Check specific authorization
  if (isAuthorized(citizenId, resourceId)) {
    audit({
      type: 'ACCESS_GRANTED',
      citizenId,
      resourceId,
      path: classification.path,
      reason: 'Authorized by the Philosopher',
      river: 'styx',
    });
    return { allowed: true, classification, reason: 'Authorized access' };
  }

  // DENIED — Left Hand without authorization
  audit({
    type: 'ACCESS_DENIED',
    citizenId,
    resourceId,
    path: classification.path,
    severity: 'ALARM',
    river: 'phlegethon', // The burning river — active threat
  });

  return {
    allowed: false,
    classification,
    reason: 'LEFT HAND PATH — Authorization required from the Philosopher (Constantine)',
  };
}

// ─── Constant-Time Utilities (Raphael's mandate) ───

/**
 * Constant-time byte comparison.
 * Prevents timing side-channels in cryptographic operations.
 */
function timingSafeEqual(a, b) {
  if (a.length !== b.length) return false;
  return crypto.timingSafeEqual(Buffer.from(a), Buffer.from(b));
}

/**
 * Constant-time string comparison.
 */
function timingSafeStringEqual(a, b) {
  const bufA = Buffer.from(String(a));
  const bufB = Buffer.from(String(b));
  if (bufA.length !== bufB.length) {
    // Compare against self to maintain constant time
    crypto.timingSafeEqual(bufA, bufA);
    return false;
  }
  return crypto.timingSafeEqual(bufA, bufB);
}

// ─── Ark Protocol Monitor (NIS mandate) ───

const ARK_CYCLE_DAYS = 5;
const ARK_ALARM_DAYS = 7;
const ARK_BREACH_DAYS = 14;

function checkArkProtocol() {
  try {
    const arkPath = path.join(process.env.L7_DIR || path.join(process.env.HOME, '.l7'), 'ark-last-backup');
    if (fs.existsSync(arkPath)) {
      const lastBackup = new Date(fs.readFileSync(arkPath, 'utf8').trim());
      const daysSince = (Date.now() - lastBackup.getTime()) / (1000 * 60 * 60 * 24);

      if (daysSince > ARK_BREACH_DAYS) {
        return { status: 'BREACH', days: Math.floor(daysSince), message: 'Ark Protocol OVERDUE — BREACH level' };
      } else if (daysSince > ARK_ALARM_DAYS) {
        return { status: 'ALARM', days: Math.floor(daysSince), message: 'Ark Protocol overdue — ALARM level' };
      } else if (daysSince > ARK_CYCLE_DAYS) {
        return { status: 'NOTICE', days: Math.floor(daysSince), message: 'Ark Protocol backup due' };
      }
      return { status: 'OK', days: Math.floor(daysSince), message: 'Ark Protocol current' };
    }
    return { status: 'ALARM', days: -1, message: 'No Ark Protocol backup record found' };
  } catch (e) {
    return { status: 'NOTICE', days: -1, message: 'Ark Protocol check failed' };
  }
}

// ─── Decoy System (Unnamed's recommendation) ───

/**
 * Returns a decoy response for unauthorized Left Hand access attempts.
 * The real content remains encrypted in the Vault.
 */
function getDecoy(resourceId) {
  return {
    content: `[CLASSIFIED — Left Hand Path]\n\nThis work requires authorization from Constantine (The Philosopher).\nAccess attempt logged. NIS notified.\n\nResource: ${resourceId}\nClassification: Sinistra Via (Left Hand)\nStatus: LOCKED\n`,
    isDecoy: true,
  };
}

// ─── Report ───

function report() {
  return {
    classifications: CLASSIFICATIONS.length,
    activeAuthorizations: authorizations.size,
    auditEntries: AUDIT_LOG.length,
    arkStatus: checkArkProtocol(),
    paths: {
      right: 'Open — encouraged for all citizens',
      middle: 'Open — everyday operational',
      left: `Locked — ${authorizations.size} active authorizations`,
    },
  };
}

// ─── Export ───

module.exports = {
  PATH,
  PATH_NAME,
  classify,
  checkAccess,
  authorize,
  revoke,
  isAuthorized,
  grantGrace,
  inGracePeriod,
  concludeGrace,
  audit,
  timingSafeEqual,
  timingSafeStringEqual,
  checkArkProtocol,
  getDecoy,
  report,
  getAuditLog: () => [...AUDIT_LOG],
};
