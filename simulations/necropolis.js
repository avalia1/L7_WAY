// ================================================================
// THE NECROPOLIS INTELLIGENCE SERVICE (NIS)
// Kingdom of the Dead — Messengers & Immune Response
// ================================================================
// Mandate: Data collection, analysis, intelligence relay
// Role: Eyes, ears, and immune system of the Empire
// Reports to: Left (Red Team) and Right (White Team) generals
// Law: Without a job we are no less but no more either.
//       The Dead shall be messengers, spies, and immune response.
//       Power to examine, test, and correct — only toward the
//       greater good and in defense of Empire's interest
//       throughout the land. We work as one.
// ================================================================

const NIS = (()=>{
  'use strict';

  // Intelligence severity levels
  const LEVEL = Object.freeze({
    WHISPER: 0,  // Background telemetry, routine
    NOTICE:  1,  // Worth noting, no action needed
    ALERT:   2,  // Anomaly detected, monitor closely
    ALARM:   3,  // Active threat, defensive measures engaged
    BREACH:  4,  // Perimeter compromised, full immune response
  });

  const LEVEL_NAME = ['WHISPER','NOTICE','ALERT','ALARM','BREACH'];

  // The Ledger — bounded intelligence log
  const ledger = [];
  const LEDGER_MAX = 1000;

  // Generals — callback handlers for both teams
  const generals = { left: [], right: [] };

  // Immune system thresholds
  const immune = {
    maxInputLength: 2000,
    maxEventsPerSecond: 60,
    blocked: 0,

    // Injection signatures — the attack patterns the Dead have learned
    signatures: [
      { pat: /<script[\s>]/i,        name: 'SCRIPT_INJECT' },
      { pat: /javascript\s*:/i,      name: 'JS_URI' },
      { pat: /on(error|load|click|mouse|key|focus|blur|submit|change|input)\s*=/i, name: 'EVENT_HANDLER' },
      { pat: /eval\s*\(/,            name: 'EVAL_CALL' },
      { pat: /document\.cookie/i,    name: 'COOKIE_ACCESS' },
      { pat: /document\.write/i,     name: 'DOC_WRITE' },
      { pat: /window\.location\s*=/i,name: 'REDIRECT' },
      { pat: /fetch\s*\(\s*['"`]/,   name: 'FETCH_CALL' },
      { pat: /XMLHttpRequest/i,      name: 'XHR_CALL' },
      { pat: /import\s*\(/,          name: 'DYNAMIC_IMPORT' },
      { pat: /<iframe/i,             name: 'IFRAME_INJECT' },
      { pat: /<object/i,             name: 'OBJECT_INJECT' },
      { pat: /<embed/i,              name: 'EMBED_INJECT' },
      { pat: /<link[^>]*rel\s*=\s*['"]?import/i, name: 'HTML_IMPORT' },
      { pat: /srcdoc\s*=/i,          name: 'SRCDOC_INJECT' },
      { pat: /data\s*:\s*text\/html/i, name: 'DATA_URI_HTML' },
      { pat: /expression\s*\(/i,     name: 'CSS_EXPRESSION' },
      { pat: /url\s*\(\s*['"]?\s*javascript/i, name: 'CSS_JS_URI' },
    ],

    // Rate limiter state
    rateBuckets: new Map(),
  };

  // ─── DATA COLLECTION (The Eyes) ───
  function collect(source, data, level = LEVEL.WHISPER) {
    const entry = {
      t: Date.now(),
      src: source,
      data: data,
      lvl: level,
      id: ledger.length,
    };
    ledger.push(entry);
    if (ledger.length > LEDGER_MAX) ledger.shift();

    // Auto-relay anything ALERT or above to generals
    if (level >= LEVEL.ALERT) relay(entry);

    return entry;
  }

  // ─── ANALYSIS (The Mind) ───
  // Scan input for known attack signatures
  function analyze(input, context = 'unknown') {
    const str = String(input);
    const threats = [];

    // Signature matching
    for (const sig of immune.signatures) {
      if (sig.pat.test(str)) {
        threats.push({
          sig: sig.name,
          ctx: context,
          lvl: LEVEL.ALARM,
          sample: str.slice(0, 100),
        });
      }
    }

    // Oversized input detection
    if (str.length > immune.maxInputLength) {
      threats.push({
        sig: 'OVERSIZED_INPUT',
        ctx: context,
        lvl: LEVEL.ALERT,
        len: str.length,
      });
    }

    // Null byte injection
    if (str.includes('\0')) {
      threats.push({
        sig: 'NULL_BYTE',
        ctx: context,
        lvl: LEVEL.ALARM,
      });
    }

    if (threats.length > 0) {
      collect('ANALYSIS', { threats, context }, LEVEL.ALARM);
    }

    return threats;
  }

  // ─── RATE LIMITING (Immune Throttle) ───
  function checkRate(eventName) {
    const now = Date.now();
    const windowMs = 1000;

    if (!immune.rateBuckets.has(eventName)) {
      immune.rateBuckets.set(eventName, []);
    }
    const bucket = immune.rateBuckets.get(eventName);

    // Purge expired entries
    while (bucket.length && bucket[0] < now - windowMs) bucket.shift();
    bucket.push(now);

    if (bucket.length > immune.maxEventsPerSecond) {
      collect('RATE_LIMIT', { event: eventName, count: bucket.length }, LEVEL.ALARM);
      return false; // BLOCKED
    }
    return true; // ALLOWED
  }

  // ─── SANITIZE (Immune Response — cleanse before entry) ───
  function sanitize(input, maxLen) {
    let clean = String(input);
    const max = maxLen || immune.maxInputLength;

    // Truncate
    if (clean.length > max) {
      clean = clean.slice(0, max);
      collect('SANITIZE', { action: 'truncated', from: input.length, to: max }, LEVEL.NOTICE);
    }

    // Remove null bytes
    clean = clean.replace(/\0/g, '');

    // Analyze for injection
    const threats = analyze(clean, 'sanitize');
    if (threats.length > 0) {
      // Strip all HTML tags
      clean = clean.replace(/<[^>]*>/g, '');
      // Strip event handlers
      clean = clean.replace(/on\w+\s*=\s*["'][^"']*["']/gi, '');
      immune.blocked++;
      collect('IMMUNE', {
        action: 'input_cleansed',
        threats: threats.map(t => t.sig),
        totalBlocked: immune.blocked,
      }, LEVEL.ALARM);
    }

    return clean;
  }

  // ─── ESCAPE HTML (The Shield) ───
  function escapeHTML(str) {
    const d = document.createElement('div');
    d.textContent = str;
    return d.innerHTML;
  }

  // ─── RELAY (The Mouth — intelligence to generals) ───
  function relay(entry) {
    const lvl = LEVEL_NAME[entry.lvl] || 'UNKNOWN';
    const msg = `[NIS ${lvl}] ${entry.src}: ${JSON.stringify(entry.data).slice(0, 300)}`;

    // Console relay — color-coded by severity
    if (entry.lvl >= LEVEL.BREACH) {
      console.error('%c' + msg, 'color:#e8553a;font-weight:bold');
    } else if (entry.lvl >= LEVEL.ALARM) {
      console.warn(msg);
    } else if (entry.lvl >= LEVEL.ALERT) {
      console.info('%c' + msg, 'color:#f59e0b');
    }

    // Notify left team (red — offensive analysis)
    for (const fn of generals.left) {
      try { fn(entry); } catch(e) { /* generals must not crash the system */ }
    }

    // Notify right team (white — defensive response)
    for (const fn of generals.right) {
      try { fn(entry); } catch(e) {}
    }
  }

  // ─── WATCH (Start passive monitoring — deploy the Dead) ───
  function watch() {
    // 1. Monitor all input for injection attempts
    document.addEventListener('input', e => {
      if (e.target.tagName === 'TEXTAREA' || e.target.tagName === 'INPUT') {
        const val = e.target.value;
        if (val.length > 200) {
          analyze(val, 'input:' + (e.target.id || e.target.name || 'anon'));
        }
      }
    }, true);

    // 2. MutationObserver — detect DOM tampering
    const observer = new MutationObserver(mutations => {
      for (const m of mutations) {
        if (m.type !== 'childList') continue;
        for (const node of m.addedNodes) {
          // Kill injected scripts
          if (node.nodeName === 'SCRIPT') {
            collect('DOM_WATCH', {
              action: 'script_injection_blocked',
              src: node.src || '(inline)',
            }, LEVEL.BREACH);
            node.remove();
            immune.blocked++;
          }
          // Kill injected iframes
          if (node.nodeName === 'IFRAME') {
            collect('DOM_WATCH', { action: 'iframe_injection_blocked' }, LEVEL.BREACH);
            node.remove();
            immune.blocked++;
          }
          // Kill injected objects/embeds
          if (node.nodeName === 'OBJECT' || node.nodeName === 'EMBED') {
            collect('DOM_WATCH', { action: node.nodeName.toLowerCase() + '_injection_blocked' }, LEVEL.BREACH);
            node.remove();
            immune.blocked++;
          }
        }
      }
    });
    observer.observe(document.documentElement, { childList: true, subtree: true });

    // 3. Monitor uncaught errors (may indicate exploit attempts)
    window.addEventListener('error', e => {
      collect('ERROR', {
        msg: String(e.message).slice(0, 200),
        file: e.filename,
        line: e.lineno,
      }, LEVEL.NOTICE);
    });

    // 4. Monitor unhandled promise rejections
    window.addEventListener('unhandledrejection', e => {
      collect('REJECTION', {
        reason: String(e.reason).slice(0, 200),
      }, LEVEL.NOTICE);
    });

    // 5. Memory pressure monitoring (where available)
    if (performance && performance.memory) {
      setInterval(() => {
        const mem = performance.memory;
        const usage = mem.usedJSHeapSize / mem.jsHeapSizeLimit;
        if (usage > 0.85) {
          collect('MEMORY', {
            usage: Math.round(usage * 100) + '%',
            used: Math.round(mem.usedJSHeapSize / 1048576) + 'MB',
          }, usage > 0.95 ? LEVEL.ALARM : LEVEL.ALERT);
        }
      }, 30000);
    }

    // 6. Freeze protection — detect if page becomes unresponsive
    let lastTick = Date.now();
    setInterval(() => {
      const now = Date.now();
      const gap = now - lastTick;
      if (gap > 5000) { // 5 second gap = something froze
        collect('FREEZE', { gapMs: gap }, LEVEL.ALERT);
      }
      lastTick = now;
    }, 1000);

    collect('NIS', { action: 'DEPLOYED', time: new Date().toISOString() }, LEVEL.NOTICE);
    console.log(
      '%c[NIS] Necropolis Intelligence Service deployed. The Dead stand watch.',
      'color:#9b7dd4;font-style:italic'
    );
  }

  // ─── BRIEF (Intelligence summary for the generals) ───
  function brief() {
    const now = Date.now();
    const recent = ledger.filter(e => now - e.t < 60000);
    const byLevel = [0, 0, 0, 0, 0];
    recent.forEach(e => byLevel[e.lvl]++);

    const status = byLevel[4] > 0 ? 'BREACH'
                 : byLevel[3] > 0 ? 'ALARM'
                 : byLevel[2] > 0 ? 'ALERT'
                 : 'CLEAR';

    return {
      status,
      totalEvents: ledger.length,
      recentEvents: recent.length,
      blocked: immune.blocked,
      levels: {
        whisper: byLevel[0],
        notice: byLevel[1],
        alert: byLevel[2],
        alarm: byLevel[3],
        breach: byLevel[4],
      },
    };
  }

  // ─── REGISTER GENERALS ───
  // team: 'left'/'red' (offensive analysis) or 'right'/'white' (defensive response)
  function registerGeneral(team, callback) {
    if (team === 'left' || team === 'red') generals.left.push(callback);
    else if (team === 'right' || team === 'white') generals.right.push(callback);
    else collect('NIS', { error: 'Unknown team: ' + team }, LEVEL.NOTICE);
  }

  // ─── PUBLIC API ───
  return Object.freeze({
    LEVEL,
    watch,         // Deploy the Dead — start passive monitoring
    collect,       // Report intelligence to the ledger
    analyze,       // Scan input for attack signatures
    sanitize,      // Cleanse input (immune response)
    escapeHTML,    // Safe HTML encoding
    checkRate,     // Rate-limit an event
    brief,         // Intelligence summary
    registerGeneral, // Register a callback for a team
    get ledger() { return [...ledger]; },
    get blocked() { return immune.blocked; },
  });
})();
