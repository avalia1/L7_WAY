/**
 * L7 .morph Runtime — Dreamscape Credential Capture & Persistence
 * Law XVII: .morph is the dreamscape — mutable, experimental, sacred.
 * Law LVI: The Heart comes first. The Heart dies last.
 *
 * Include this script in ANY .morph HTML file. It will:
 *   1. Capture credentials from base reality (heart, session, identity)
 *   2. Render a persistent domain label with metadata
 *   3. Autosave state to localStorage on exit (beforeunload)
 *   4. Restore state on re-entry
 *
 * Usage: <script src="morph-runtime.js"></script>
 *        (must be loaded AFTER the page's own scripts)
 */
'use strict';

(function MORPH_RUNTIME() {

  // ═══════════════════════════════════════════════════════
  //  CONSTANTS
  // ═══════════════════════════════════════════════════════

  const DOMAIN = '.morph';
  const ELEMENT = 'Fire';
  const LETTER = 'י';        // Yod
  const TETRAGRAMMATON = 'Yod';
  const STORAGE_PREFIX = 'l7_morph_';

  // Derive a stable key from the page filename
  const PAGE_ID = location.pathname.split('/').pop().replace(/\.html?$/, '');
  const STORE_KEY = STORAGE_PREFIX + PAGE_ID;

  // ═══════════════════════════════════════════════════════
  //  1. CAPTURE CREDENTIALS FROM BASE REALITY
  // ═══════════════════════════════════════════════════════

  const credentials = {
    // Identity
    domain: DOMAIN,
    element: ELEMENT,
    letter: LETTER,
    tetragrammaton: TETRAGRAMMATON,
    pageId: PAGE_ID,

    // Session — generated fresh or restored
    sessionId: null,
    incarnation: 0,
    enteredAt: null,
    lastSaved: null,

    // Heart state — captured from base reality
    heartBeat: 0,
    heartAlive: false,

    // Environment
    userAgent: navigator.userAgent,
    screenW: screen.width,
    screenH: screen.height,
    dpr: window.devicePixelRatio || 1,
    timezone: Intl.DateTimeFormat().resolvedOptions().timeZone,
    locale: navigator.language,

    // Page state (populated by autosave)
    scrollY: 0,
    canvasStates: {},
    customState: {}
  };

  // Try to restore previous session
  function restoreCredentials() {
    try {
      const saved = localStorage.getItem(STORE_KEY);
      if (saved) {
        const prev = JSON.parse(saved);
        credentials.incarnation = (prev.incarnation || 0) + 1;
        credentials.sessionId = prev.sessionId;
        credentials.heartBeat = prev.heartBeat || 0;
        credentials.customState = prev.customState || {};
        console.log(`[.morph] Restored from incarnation ${prev.incarnation}. ` +
                    `Session: ${credentials.sessionId}`);
      }
    } catch (e) { /* first visit */ }

    // New session if needed
    if (!credentials.sessionId) {
      credentials.sessionId = 'morph-' + Date.now().toString(36) +
                              '-' + Math.random().toString(36).slice(2, 8);
    }
    credentials.enteredAt = new Date().toISOString();
  }

  // Try to read heart state from base reality (localStorage bridge)
  function captureHeartState() {
    try {
      const heart = localStorage.getItem('l7_heart_state');
      if (heart) {
        const h = JSON.parse(heart);
        credentials.heartBeat = h.beatCount || 0;
        credentials.heartAlive = h.alive || false;
      }
    } catch (e) { /* no heart bridge */ }

    // Also check for global L7 identity
    try {
      const identity = localStorage.getItem('l7_identity');
      if (identity) {
        const id = JSON.parse(identity);
        credentials.founder = id.founder || 'Unknown';
        credentials.law = id.law || '';
      }
    } catch (e) { /* no identity bridge */ }
  }

  restoreCredentials();
  captureHeartState();

  // ═══════════════════════════════════════════════════════
  //  2. DOMAIN LABEL — persistent watermark on all screens
  // ═══════════════════════════════════════════════════════

  function createLabel() {
    const label = document.createElement('div');
    label.id = 'l7-morph-label';
    label.setAttribute('data-domain', DOMAIN);

    const style = document.createElement('style');
    style.textContent = `
      #l7-morph-label {
        position: fixed;
        top: 0; left: 0; right: 0;
        height: 28px;
        background: linear-gradient(90deg,
          rgba(180,100,20,0.85) 0%,
          rgba(120,60,10,0.75) 40%,
          rgba(60,30,5,0.65) 100%);
        color: #ffd9a0;
        font: 10px/28px 'Courier New', monospace;
        letter-spacing: 1.5px;
        padding: 0 12px;
        z-index: 99999;
        display: flex;
        justify-content: space-between;
        align-items: center;
        border-bottom: 1px solid rgba(201,169,110,0.4);
        user-select: none;
        pointer-events: none;
        backdrop-filter: blur(4px);
        -webkit-backdrop-filter: blur(4px);
      }
      #l7-morph-label .morph-left {
        display: flex; gap: 16px; align-items: center;
      }
      #l7-morph-label .morph-domain {
        color: #ffc56e;
        font-weight: bold;
        font-size: 11px;
      }
      #l7-morph-label .morph-element {
        color: #ff8844;
        font-size: 14px;
      }
      #l7-morph-label .morph-meta {
        color: #c9a06e;
        font-size: 9px;
      }
      #l7-morph-label .morph-save-indicator {
        color: #88cc88;
        font-size: 9px;
        transition: opacity 0.3s;
      }
      #l7-morph-label .morph-save-indicator.saving {
        color: #ffcc44;
      }
      /* Push body content down so label doesn't overlap */
      body { padding-top: 28px !important; }
      body > canvas:first-of-type,
      body > canvas#cosmos {
        top: 28px !important;
      }
    `;
    document.head.appendChild(style);

    label.innerHTML = `
      <div class="morph-left">
        <span class="morph-element" title="Yod — Fire">${LETTER}</span>
        <span class="morph-domain">${DOMAIN}</span>
        <span class="morph-meta">${ELEMENT} / ${TETRAGRAMMATON}</span>
        <span class="morph-meta" id="morph-page">${PAGE_ID}</span>
        <span class="morph-meta" id="morph-session">
          #${credentials.incarnation} &middot; ${credentials.sessionId.slice(0, 16)}
        </span>
      </div>
      <div style="display:flex;gap:16px;align-items:center">
        <span class="morph-save-indicator" id="morph-save-status">AUTOSAVE: READY</span>
        <span class="morph-meta" id="morph-clock"></span>
      </div>
    `;

    document.body.appendChild(label);

    // Live clock
    setInterval(() => {
      const el = document.getElementById('morph-clock');
      if (el) {
        const now = new Date();
        el.textContent = now.toLocaleTimeString('en-GB', { hour12: false }) +
                         ' ' + now.toLocaleDateString('en-GB');
      }
    }, 1000);
  }

  // ═══════════════════════════════════════════════════════
  //  3. AUTOSAVE ON EXIT
  // ═══════════════════════════════════════════════════════

  let saveCount = 0;
  let autoSaveTimer = null;

  function saveState(reason) {
    credentials.lastSaved = new Date().toISOString();
    credentials.scrollY = window.scrollY || 0;
    credentials.heartBeat++;
    saveCount++;

    // Capture all canvas elements as data URLs (snapshot the dream)
    credentials.canvasStates = {};
    const canvases = document.querySelectorAll('canvas');
    canvases.forEach((c, i) => {
      try {
        const id = c.id || ('canvas_' + i);
        // Only save small canvases (< 512px CSS) as thumbnails to avoid quota
        const cssW = parseInt(c.style.width) || c.width;
        if (cssW <= 512) {
          credentials.canvasStates[id] = c.toDataURL('image/png', 0.5);
        } else {
          // For large canvases, save a scaled thumbnail
          const thumb = document.createElement('canvas');
          const scale = 256 / cssW;
          thumb.width = 256;
          thumb.height = Math.round((parseInt(c.style.height) || c.height) * scale);
          const tCtx = thumb.getContext('2d');
          tCtx.drawImage(c, 0, 0, thumb.width, thumb.height);
          credentials.canvasStates[id] = thumb.toDataURL('image/jpeg', 0.4);
        }
      } catch (e) { /* tainted canvas or security restriction */ }
    });

    // Allow page-specific state capture
    if (window._morphSaveHook && typeof window._morphSaveHook === 'function') {
      credentials.customState = window._morphSaveHook();
    }

    // Persist
    try {
      localStorage.setItem(STORE_KEY, JSON.stringify(credentials));
    } catch (e) {
      // Quota exceeded — clear canvas states and retry
      credentials.canvasStates = {};
      try {
        localStorage.setItem(STORE_KEY, JSON.stringify(credentials));
      } catch (e2) { console.warn('[.morph] Save failed:', e2.message); }
    }

    // Update indicator
    const indicator = document.getElementById('morph-save-status');
    if (indicator) {
      indicator.textContent = `SAVED (${reason}) #${saveCount}`;
      indicator.classList.add('saving');
      setTimeout(() => {
        indicator.textContent = 'AUTOSAVE: READY';
        indicator.classList.remove('saving');
      }, 2000);
    }

    console.log(`[.morph] State saved (${reason}). Incarnation: ${credentials.incarnation}, ` +
                `Saves: ${saveCount}, Size: ${JSON.stringify(credentials).length} bytes`);
  }

  // Save on beforeunload (exit)
  window.addEventListener('beforeunload', function(e) {
    saveState('exit');
    // Show browser reminder for unsaved work
    // (only triggers if page has active state)
    if (saveCount > 0 || credentials.customState._dirty) {
      e.preventDefault();
      e.returnValue = '.morph dreamscape state saved. Exit?';
    }
  });

  // Save on visibility change (tab switch, app switch)
  document.addEventListener('visibilitychange', function() {
    if (document.hidden) {
      saveState('hidden');
    }
  });

  // Periodic autosave every 30 seconds
  autoSaveTimer = setInterval(() => {
    saveState('periodic');
  }, 30000);

  // Save on any significant user interaction (debounced)
  let interactionTimer = null;
  function debouncedSave() {
    if (interactionTimer) clearTimeout(interactionTimer);
    interactionTimer = setTimeout(() => saveState('interaction'), 5000);
  }
  window.addEventListener('click', debouncedSave);
  window.addEventListener('keydown', debouncedSave);

  // ═══════════════════════════════════════════════════════
  //  4. RESTORATION API
  // ═══════════════════════════════════════════════════════

  /**
   * Pages can register a restore hook to recover custom state:
   *   window._morphRestoreHook = function(savedState) { ... };
   *
   * And a save hook to capture custom state:
   *   window._morphSaveHook = function() { return { ... }; };
   */
  function tryRestore() {
    if (window._morphRestoreHook && typeof window._morphRestoreHook === 'function') {
      if (credentials.customState && Object.keys(credentials.customState).length > 0) {
        window._morphRestoreHook(credentials.customState);
        console.log('[.morph] Custom state restored via _morphRestoreHook');
      }
    }
  }

  // ═══════════════════════════════════════════════════════
  //  5. PUBLIC API (exposed on window)
  // ═══════════════════════════════════════════════════════

  window.L7_MORPH = Object.freeze({
    credentials: credentials,
    save: saveState,
    getState: () => credentials.customState,
    setState: (obj) => { Object.assign(credentials.customState, obj); },
    markDirty: () => { credentials.customState._dirty = true; },
    pageId: PAGE_ID,
    sessionId: credentials.sessionId,
    incarnation: credentials.incarnation,
    domain: DOMAIN
  });

  // ═══════════════════════════════════════════════════════
  //  BOOT
  // ═══════════════════════════════════════════════════════

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => {
      createLabel();
      // Defer restore to allow page scripts to register hooks
      setTimeout(tryRestore, 100);
    });
  } else {
    createLabel();
    setTimeout(tryRestore, 100);
  }

  console.log(`[.morph] Runtime loaded. Page: ${PAGE_ID}, ` +
              `Session: ${credentials.sessionId}, ` +
              `Incarnation: ${credentials.incarnation}, ` +
              `DPR: ${credentials.dpr}`);

})();
