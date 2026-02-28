// ============================================================
// The Living Rose — Native macOS Desktop Sigil Interface
// Law XLVII — Prima Language Visual Interface
//
// No browser. No window. The rose IS the desktop.
// ============================================================

import Cocoa
import WebKit

// ============================================================
// App Delegate — invisible app, desktop-level window
// ============================================================

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var webView: WKWebView!

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Get full screen size
        guard let screen = NSScreen.main else { return }
        let frame = screen.frame

        // Create borderless, transparent window
        window = NSWindow(
            contentRect: frame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )

        // Desktop level — behind all windows, above wallpaper
        window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopWindow)) + 1)
        window.backgroundColor = .clear
        window.isOpaque = false
        window.hasShadow = false
        window.ignoresMouseEvents = false
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        window.isReleasedWhenClosed = false

        // WebView with transparent background
        let config = WKWebViewConfiguration()
        config.preferences.setValue(true, forKey: "developerExtrasEnabled")
        webView = WKWebView(frame: frame, configuration: config)
        webView.setValue(false, forKey: "drawsBackground")

        // Load the rose
        let rosePath = findRosePath()
        if let url = URL(string: "file://\(rosePath)") {
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }

        window.contentView = webView
        window.makeKeyAndOrderFront(nil)

        // Hotkey: Ctrl+Shift+R to toggle visibility
        NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            // Ctrl+Shift+R
            if event.modifierFlags.contains([.control, .shift]) && event.keyCode == 15 {
                self?.toggleVisibility()
            }
        }
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.modifierFlags.contains([.control, .shift]) && event.keyCode == 15 {
                self?.toggleVisibility()
                return nil
            }
            return event
        }

        // Click-through toggle: Ctrl+Shift+T
        NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.modifierFlags.contains([.control, .shift]) && event.keyCode == 17 {
                self?.toggleInteraction()
            }
        }
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.modifierFlags.contains([.control, .shift]) && event.keyCode == 17 {
                self?.toggleInteraction()
                return nil
            }
            return event
        }
    }

    func findRosePath() -> String {
        // Check multiple locations
        let candidates = [
            "/tmp/l7os/rose.html",
            NSHomeDirectory() + "/Backup/L7_WAY/rose/rose.html",
            NSHomeDirectory() + "/.l7/rose/rose.html",
        ]
        for path in candidates {
            if FileManager.default.fileExists(atPath: path) {
                return path
            }
        }
        return candidates[0] // fallback
    }

    func toggleVisibility() {
        if window.isVisible {
            window.orderOut(nil)
        } else {
            window.makeKeyAndOrderFront(nil)
        }
    }

    func toggleInteraction() {
        window.ignoresMouseEvents = !window.ignoresMouseEvents
        // Visual feedback — briefly flash the border
        if window.ignoresMouseEvents {
            webView.evaluateJavaScript("document.title = 'PASS-THROUGH'", completionHandler: nil)
        } else {
            webView.evaluateJavaScript("document.title = 'INTERACTIVE'", completionHandler: nil)
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
}

// ============================================================
// Main — boot the rose
// ============================================================

let app = NSApplication.shared
app.setActivationPolicy(.accessory) // No dock icon, no menu bar
let delegate = AppDelegate()
app.delegate = delegate
app.run()
