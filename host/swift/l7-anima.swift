// ══════════════════════════════════════════════════════════════
// ANIMA — The Living Desktop (♆ Neptune)
// The wallpaper breathes, moves, and speaks.
//
// Planet: Neptune ♆ — dreams, the unconscious, illusion
// Metal: Neptunium — deep, unseen, radiating
// Tarot: The World (XXI) — completion, the dance of life
// Color: Deep ocean, aurora, bioluminescent
//
// A desktop-level window that sits behind everything.
// Particles flow. Colors shift. Words appear and dissolve.
//
// Creator: Alberto Valido Delgado
// System: L7 Universal OS
// License: Proprietary (Law XXII)
// ══════════════════════════════════════════════════════════════

import Cocoa
import WebKit

let ANIMA_HTML: String = ###"""
<!DOCTYPE html>
<html><head>
<meta charset="utf-8">
<style>
*{margin:0;padding:0;border:0}
html,body{width:100vw;height:100vh;overflow:hidden;background:transparent;-webkit-user-select:none}
canvas{position:fixed;top:-1px;left:-1px;width:calc(100vw + 2px);height:calc(100vh + 2px)}
#words{position:fixed;top:0;left:0;width:100vw;height:100vh;pointer-events:none;z-index:2}
.word{position:absolute;font-family:system-ui,-apple-system,sans-serif;
  opacity:0;transition:opacity 2s ease;pointer-events:none;
  text-shadow:0 0 30px currentColor,0 0 60px currentColor}
</style>
</head><body>
<canvas id="c"></canvas>
<div id="words"></div>
<script>
const canvas = document.getElementById('c');
const ctx = canvas.getContext('2d');
const wordsDiv = document.getElementById('words');
let W, H, dpr;

function resize() {
  dpr = window.devicePixelRatio || 1;
  W = Math.max(window.innerWidth, screen.width) + 2;
  H = Math.max(window.innerHeight, screen.height) + 2;
  canvas.width = W * dpr;
  canvas.height = H * dpr;
  ctx.setTransform(1, 0, 0, 1, 0, 0);
  ctx.scale(dpr, dpr);
  initStars();
}
resize();
window.addEventListener('resize', resize);

// ─── Time & Color ───
function timeColor() {
  const h = new Date().getHours();
  // Shift palette by time of day
  if (h >= 5 && h < 8) return { // dawn
    bg: [8, 12, 25], colors: ['#ff6b4520','#ff994420','#ffd70020','#88ccff15'],
    accent: '#ff8855', textColor: '#ffcc88'
  };
  if (h >= 8 && h < 12) return { // morning
    bg: [6, 15, 20], colors: ['#2dd98c18','#33aaff15','#f2b32612','#88ffcc10'],
    accent: '#2dd98c', textColor: '#aaffcc'
  };
  if (h >= 12 && h < 17) return { // afternoon
    bg: [5, 10, 18], colors: ['#4488ff15','#22ddaa12','#ffaa3310','#ff665510'],
    accent: '#4488ff', textColor: '#88bbff'
  };
  if (h >= 17 && h < 20) return { // evening
    bg: [15, 8, 18], colors: ['#ff664418','#cc44ff15','#ff994412','#ffcc0010'],
    accent: '#ff7744', textColor: '#ffaa77'
  };
  // night
  return { bg: [4, 6, 16], colors: ['#4466ff12','#8844ff10','#00ccaa0a','#ffffff06'],
    accent: '#6688ff', textColor: '#8899cc'
  };
}

// ─── Particles ───
const particles = [];
const PARTICLE_COUNT = 120;

function createParticle() {
  const tc = timeColor();
  return {
    x: Math.random() * W,
    y: Math.random() * H,
    vx: (Math.random() - 0.5) * 0.3,
    vy: (Math.random() - 0.5) * 0.2 - 0.1,
    r: 1 + Math.random() * 3,
    color: tc.colors[Math.floor(Math.random() * tc.colors.length)],
    life: 0.5 + Math.random() * 0.5,
    phase: Math.random() * Math.PI * 2,
    freq: 0.002 + Math.random() * 0.005,
  };
}

for (let i = 0; i < PARTICLE_COUNT; i++) particles.push(createParticle());

// ─── Flow field ───
const FLOW_RES = 40;
let flowField = [];
let flowAngle = 0;

function updateFlow() {
  flowAngle += 0.003;
  flowField = [];
  const cols = Math.ceil(W / FLOW_RES) + 1;
  const rows = Math.ceil(H / FLOW_RES) + 1;
  for (let y = 0; y < rows; y++) {
    for (let x = 0; x < cols; x++) {
      const a = Math.sin(x * 0.08 + flowAngle) * Math.cos(y * 0.06 + flowAngle * 0.7) * Math.PI;
      flowField.push(a);
    }
  }
}

function getFlow(px, py) {
  const cols = Math.ceil(W / FLOW_RES) + 1;
  const gx = Math.floor(px / FLOW_RES);
  const gy = Math.floor(py / FLOW_RES);
  const idx = gy * cols + gx;
  return flowField[idx] || 0;
}

// ─── Nebula blobs ───
const blobs = [];
for (let i = 0; i < 5; i++) {
  blobs.push({
    x: Math.random() * W,
    y: Math.random() * H,
    r: 100 + Math.random() * 250,
    vx: (Math.random() - 0.5) * 0.15,
    vy: (Math.random() - 0.5) * 0.1,
    phase: Math.random() * Math.PI * 2,
  });
}

// ─── Words / Thoughts ───
const thoughts = [
  "the void breathes",
  "stillness is motion unseen",
  "what you seek is seeking you",
  "every ending is a door",
  "the river knows the way",
  "listen to the silence between",
  "form is emptiness, emptiness is form",
  "as above, so below",
  "the universe is a mirror",
  "you are the observer",
  "change is the only constant",
  "the map is not the territory",
  "all things return to the source",
  "the present is a gift",
  "between stimulus and response lies freedom",
  "what is real will never fade",
  "the stars remember",
  "dissolve and coagulate",
  "from lead to gold",
  "the stone is within",
  "solve et coagula",
  "the light behind the light",
  "mercury runs between worlds",
  "the seed contains the tree",
  "breathe in, breathe out, begin",
  "every atom sings",
  "the dreamer dreams the dream",
  "the wound is where the light enters",
  "nature does not hurry",
  "in the beginning was the word",
];

let lastWord = 0;
const WORD_INTERVAL = 12000 + Math.random() * 18000; // 12-30 seconds

function showWord() {
  const now = Date.now();
  if (now - lastWord < WORD_INTERVAL) return;
  lastWord = now;

  const tc = timeColor();
  const el = document.createElement('div');
  el.className = 'word';
  const text = thoughts[Math.floor(Math.random() * thoughts.length)];
  el.textContent = text;

  // Random position, biased toward center-ish
  const x = 10 + Math.random() * (W - 200);
  const y = H * 0.2 + Math.random() * H * 0.6;
  const size = 14 + Math.random() * 22;
  const weight = Math.random() > 0.5 ? '200' : '300';

  el.style.left = x + 'px';
  el.style.top = y + 'px';
  el.style.fontSize = size + 'px';
  el.style.fontWeight = weight;
  el.style.color = tc.textColor;
  el.style.letterSpacing = (1 + Math.random() * 3) + 'px';
  el.style.maxWidth = '500px';

  wordsDiv.appendChild(el);

  // Fade in
  requestAnimationFrame(() => { el.style.opacity = 0.25 + Math.random() * 0.35; });

  // Drift upward slowly
  let wy = y;
  const drift = setInterval(() => {
    wy -= 0.15;
    el.style.top = wy + 'px';
  }, 50);

  // Fade out and remove
  const duration = 6000 + Math.random() * 8000;
  setTimeout(() => {
    el.style.opacity = '0';
    setTimeout(() => { clearInterval(drift); el.remove(); }, 2500);
  }, duration);
}

// ─── Stars (persistent, for the top menu bar zone + scattered) ───
const stars = [];
const STAR_COUNT = 200;
function initStars() {
  stars.length = 0;
  for (let i = 0; i < STAR_COUNT; i++) {
    // Bias toward the top — 60% in top quarter, rest scattered
    const inTop = Math.random() < 0.6;
    stars.push({
      x: Math.random() * W,
      y: inTop ? Math.random() * H * 0.25 : Math.random() * H,
      r: 0.3 + Math.random() * 1.8,
      brightness: 0.3 + Math.random() * 0.7,
      twinkleSpeed: 0.01 + Math.random() * 0.04,
      twinklePhase: Math.random() * Math.PI * 2,
    });
  }
}
initStars();

// ─── Render ───
let frame = 0;
var _paused = false;

function render() {
  if (_paused) return;
  frame++;
  const tc = timeColor();

  // Clear — pure black base
  ctx.fillStyle = '#000000';
  ctx.fillRect(0, 0, W, H);

  // Menu bar zone: solid black top band (extra dark, no nebula bleed)
  const menuH = 60; // covers macOS menu bar + some breathing room
  ctx.fillStyle = '#000000';
  ctx.fillRect(0, 0, W, menuH);

  // Gradient transition from pure black (top) into the scene color
  const topGrad = ctx.createLinearGradient(0, menuH, 0, menuH + 120);
  topGrad.addColorStop(0, '#000000');
  topGrad.addColorStop(1, `rgb(${tc.bg[0]},${tc.bg[1]},${tc.bg[2]})`);
  ctx.fillStyle = topGrad;
  ctx.fillRect(0, menuH, W, 120);

  // Fill the rest with scene background
  ctx.fillStyle = `rgb(${tc.bg[0]},${tc.bg[1]},${tc.bg[2]})`;
  ctx.fillRect(0, menuH + 120, W, H - menuH - 120);

  // ─── Stars: twinkling white dots ───
  for (const s of stars) {
    const twinkle = s.brightness * (0.5 + 0.5 * Math.sin(frame * s.twinkleSpeed + s.twinklePhase));
    ctx.beginPath();
    ctx.arc(s.x, s.y, s.r, 0, Math.PI * 2);
    ctx.fillStyle = `rgba(255,255,255,${twinkle})`;
    ctx.fill();
    // Glow on brighter stars
    if (s.r > 1.2 && twinkle > 0.5) {
      ctx.beginPath();
      ctx.arc(s.x, s.y, s.r * 3, 0, Math.PI * 2);
      ctx.fillStyle = `rgba(200,220,255,${twinkle * 0.08})`;
      ctx.fill();
    }
  }

  // Update flow field every 3 frames
  if (frame % 3 === 0) updateFlow();

  // Nebula blobs
  for (const b of blobs) {
    b.x += b.vx + Math.sin(frame * 0.005 + b.phase) * 0.3;
    b.y += b.vy + Math.cos(frame * 0.004 + b.phase) * 0.2;
    b.phase += 0.001;

    // Wrap
    if (b.x < -b.r) b.x = W + b.r;
    if (b.x > W + b.r) b.x = -b.r;
    if (b.y < -b.r) b.y = H + b.r;
    if (b.y > H + b.r) b.y = -b.r;

    const pulse = 1 + Math.sin(frame * 0.008 + b.phase) * 0.2;
    const grad = ctx.createRadialGradient(b.x, b.y, 0, b.x, b.y, b.r * pulse);
    const ci = Math.floor(b.phase * 2) % tc.colors.length;
    grad.addColorStop(0, tc.colors[ci]);
    grad.addColorStop(1, 'transparent');
    ctx.fillStyle = grad;
    ctx.fillRect(b.x - b.r * pulse, b.y - b.r * pulse, b.r * 2 * pulse, b.r * 2 * pulse);
  }

  // Particles
  for (let i = 0; i < particles.length; i++) {
    const p = particles[i];
    const flow = getFlow(p.x, p.y);
    p.vx += Math.cos(flow) * 0.02;
    p.vy += Math.sin(flow) * 0.02;
    p.vx *= 0.98;
    p.vy *= 0.98;
    p.x += p.vx;
    p.y += p.vy;
    p.phase += p.freq;

    // Wrap
    if (p.x < 0) p.x = W;
    if (p.x > W) p.x = 0;
    if (p.y < 0) p.y = H;
    if (p.y > H) p.y = 0;

    const alpha = p.life * (0.3 + Math.sin(p.phase) * 0.2);
    const sz = p.r * (1 + Math.sin(p.phase * 0.5) * 0.3);

    ctx.beginPath();
    ctx.arc(p.x, p.y, sz, 0, Math.PI * 2);
    ctx.fillStyle = p.color.replace(/[\d.]+\)$/, alpha + ')');
    ctx.fill();

    // Refresh color periodically
    if (frame % 300 === 0) {
      p.color = tc.colors[Math.floor(Math.random() * tc.colors.length)];
    }
  }

  // Connections between nearby particles
  ctx.lineWidth = 0.5;
  for (let i = 0; i < particles.length; i++) {
    for (let j = i + 1; j < particles.length; j++) {
      const dx = particles[i].x - particles[j].x;
      const dy = particles[i].y - particles[j].y;
      const d = dx * dx + dy * dy;
      if (d < 6000) {
        const a = (1 - d / 6000) * 0.06;
        ctx.beginPath();
        ctx.moveTo(particles[i].x, particles[i].y);
        ctx.lineTo(particles[j].x, particles[j].y);
        ctx.strokeStyle = tc.accent.replace(')', ',' + a + ')').replace('rgb', 'rgba');
        ctx.stroke();
      }
    }
  }

  // Occasional aurora bands
  if (Math.sin(frame * 0.002) > 0.7) {
    const ay = H * (0.15 + Math.sin(frame * 0.001) * 0.15);
    const grad = ctx.createLinearGradient(0, ay - 60, 0, ay + 60);
    grad.addColorStop(0, 'transparent');
    grad.addColorStop(0.5, tc.colors[0]);
    grad.addColorStop(1, 'transparent');
    ctx.fillStyle = grad;
    ctx.fillRect(0, ay - 60, W, 120);
  }

  // Words
  showWord();

  requestAnimationFrame(render);
}

render();
</script>
</body></html>
"""###

// ─────────────────────────────────────────
// MARK: - App Delegate
// ─────────────────────────────────────────

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var webView: WKWebView!
    var keepAlive: NSObjectProtocol!
    var heartbeat: Timer!

    func applicationDidFinishLaunching(_ n: Notification) {
        NSApp.setActivationPolicy(.accessory)  // No dock icon

        // ─── ANTI-DECAY: Prevent App Nap and system suspension ───
        keepAlive = ProcessInfo.processInfo.beginActivity(
            options: [.userInitiatedAllowingIdleSystemSleep, .latencyCritical],
            reason: "L7 Anima — living desktop must not sleep"
        )

        guard let screen = NSScreen.main else { return }
        // Full screen: use frame (includes menu bar area)
        let frame = screen.frame

        window = NSWindow(
            contentRect: frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.setFrame(frame, display: true)

        // Desktop level — behind everything
        window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopWindow)) + 1)
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = false
        window.ignoresMouseEvents = true  // Click-through
        window.isMovable = false

        let cfg = WKWebViewConfiguration()
        cfg.preferences.setValue(true, forKey: "developerExtrasEnabled")
        cfg.defaultWebpagePreferences.allowsContentJavaScript = true
        // Prevent WebKit from freezing the page
        cfg.preferences.setValue(true, forKey: "pageVisibilityBasedProcessSuppressionEnabled")

        webView = WKWebView(frame: NSRect(origin: .zero, size: frame.size), configuration: cfg)
        webView.autoresizingMask = [.width, .height]
        webView.setValue(false, forKey: "drawsBackground")  // Transparent WKWebView

        webView.loadHTMLString(ANIMA_HTML, baseURL: nil)
        window.contentView?.addSubview(webView)
        window.orderFront(nil)

        // ─── HEARTBEAT: Poke WebView every 30s to prevent suspension ───
        heartbeat = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.webView.evaluateJavaScript("typeof render === 'function' ? 'alive' : 'dead'", completionHandler: nil)
        }
        RunLoop.current.add(heartbeat, forMode: .common)

        // Listen for screen changes — re-fill on resolution/display change
        NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil, queue: .main
        ) { [weak self] _ in
            if let scr = NSScreen.main {
                self?.window.setFrame(scr.frame, display: true)
                self?.webView.frame = NSRect(origin: .zero, size: scr.frame.size)
                self?.webView.evaluateJavaScript("resize()", completionHandler: nil)
            }
        }

        // Also handle wake from sleep
        NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didWakeNotification,
            object: nil, queue: .main
        ) { [weak self] _ in
            self?.webView.evaluateJavaScript("_paused = false; resize(); render();", completionHandler: nil)
        }

        setupKeys()

        // ─── ANTI-DECAY: Re-wake WebView when window becomes occluded ───
        NotificationCenter.default.addObserver(
            forName: NSWindow.didChangeOcclusionStateNotification,
            object: window, queue: .main
        ) { [weak self] _ in
            // Always keep running regardless of occlusion
            self?.webView.evaluateJavaScript("1", completionHandler: nil)
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ s: NSApplication) -> Bool { true }

    // ─── Keyboard: local monitor (works when app has focus via Cmd-Tab) ───
    func setupKeys() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self = self else { return event }
            let cmd = event.modifierFlags.contains(.command)

            if cmd {
                switch event.charactersIgnoringModifiers {
                case "q":
                    NSApp.terminate(nil)
                    return nil
                case "p":
                    // Pause/resume animation
                    self.webView.evaluateJavaScript("""
                        if (typeof _paused === 'undefined') _paused = false;
                        _paused = !_paused;
                        if (!_paused && typeof render === 'function') render();
                    """, completionHandler: nil)
                    return nil
                case "n":
                    // Force show a new word now
                    self.webView.evaluateJavaScript("lastWord = 0; showWord();", completionHandler: nil)
                    return nil
                case "r":
                    // Reload/regenerate
                    self.webView.loadHTMLString(ANIMA_HTML, baseURL: nil)
                    return nil
                default:
                    break
                }
            }
            return event
        }
    }
}

// ─────────────────────────────────────────
// MARK: - Entry
// ─────────────────────────────────────────

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
