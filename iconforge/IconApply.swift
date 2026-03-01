// ============================================================
// L7 Icon Apply — Set custom icons on files/folders + wallpaper
// Pure Swift, no Python, no third-party
// ============================================================

import Cocoa

let args = CommandLine.arguments

if args.count < 2 {
    print("Usage:")
    print("  IconApply icon <icns_path> <target_path>   — set icon on file/folder")
    print("  IconApply wallpaper <image_path>            — set desktop wallpaper")
    print("  IconApply darkmode                          — enable dark mode")
    exit(1)
}

switch args[1] {
case "icon":
    guard args.count >= 4 else {
        print("Usage: IconApply icon <icns_path> <target_path>")
        exit(1)
    }
    let icnsPath = args[2]
    let targetPath = args[3]

    guard let image = NSImage(contentsOfFile: icnsPath) else {
        print("ERROR: Could not load icon from \(icnsPath)")
        exit(1)
    }

    let success = NSWorkspace.shared.setIcon(image, forFile: targetPath, options: [])
    if success {
        print("Applied: \(icnsPath.components(separatedBy: "/").last ?? icnsPath) → \(targetPath)")
    } else {
        print("FAILED: Could not set icon on \(targetPath)")
        exit(1)
    }

case "wallpaper":
    guard args.count >= 3 else {
        print("Usage: IconApply wallpaper <image_path>")
        exit(1)
    }
    let imagePath = args[2]
    let url = URL(fileURLWithPath: imagePath)

    guard let screen = NSScreen.main else {
        print("ERROR: No main screen")
        exit(1)
    }

    do {
        try NSWorkspace.shared.setDesktopImageURL(url, for: screen, options: [:])
        print("Wallpaper set: \(imagePath)")
    } catch {
        print("ERROR: \(error.localizedDescription)")
        exit(1)
    }

case "darkmode":
    // Use AppleScript to toggle dark mode
    let script = NSAppleScript(source: """
        tell application "System Events"
            tell appearance preferences
                set dark mode to true
            end tell
        end tell
    """)
    var error: NSDictionary?
    script?.executeAndReturnError(&error)
    if let err = error {
        print("Dark mode: \(err)")
    } else {
        print("Dark mode enabled")
    }

default:
    print("Unknown command: \(args[1])")
    exit(1)
}
