// ============================================================
// L7 Wallpaper Forge — Generate the Magisterium wallpaper
// Dark void with golden geometric patterns
// Pure Swift + CoreGraphics, no third-party
// ============================================================

import Cocoa
import CoreGraphics

func generateWallpaper(outputPath: String) {
    guard let screen = NSScreen.main else {
        print("No screen detected, using 2560x1600")
        return
    }
    let w = Int(screen.frame.width * screen.backingScaleFactor)
    let h = Int(screen.frame.height * screen.backingScaleFactor)

    let colorSpace = CGColorSpaceCreateDeviceRGB()
    guard let ctx = CGContext(data: nil, width: w, height: h,
                              bitsPerComponent: 8, bytesPerRow: w * 4,
                              space: colorSpace,
                              bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
        print("Failed to create bitmap context")
        return
    }

    let cw = CGFloat(w)
    let ch = CGFloat(h)
    let cx = cw / 2
    let cy = ch / 2

    // ---- Deep void background ----
    ctx.setFillColor(red: 0.030, green: 0.020, blue: 0.050, alpha: 1.0)
    ctx.fill(CGRect(x: 0, y: 0, width: w, height: h))

    // ---- Subtle warm radial glow from center ----
    let gradient = CGGradient(colorsSpace: colorSpace,
                              colors: [
                                  CGColor(red: 0.12, green: 0.08, blue: 0.04, alpha: 0.15),
                                  CGColor(red: 0.05, green: 0.03, blue: 0.02, alpha: 0.0)
                              ] as CFArray,
                              locations: [0.0, 1.0])!
    ctx.drawRadialGradient(gradient, startCenter: CGPoint(x: cx, y: cy), startRadius: 0,
                            endCenter: CGPoint(x: cx, y: cy), endRadius: min(cw, ch) * 0.6,
                            options: [])

    // ---- Field of faint golden particles ----
    srand48(42)
    for _ in 0..<500 {
        let x = CGFloat(drand48()) * cw
        let y = CGFloat(drand48()) * ch
        let r = CGFloat(drand48()) * 2.0 + 0.5
        let alpha = CGFloat(drand48()) * 0.04 + 0.01
        ctx.setFillColor(red: 0.83, green: 0.68, blue: 0.38, alpha: alpha)
        ctx.fillEllipse(in: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2))
    }

    // ---- Faint constellation lines ----
    ctx.setLineWidth(0.8)
    srand48(777)
    for _ in 0..<40 {
        let x1 = CGFloat(drand48()) * cw
        let y1 = CGFloat(drand48()) * ch
        let x2 = x1 + CGFloat(drand48() - 0.5) * 300
        let y2 = y1 + CGFloat(drand48() - 0.5) * 300
        ctx.setStrokeColor(red: 0.83, green: 0.68, blue: 0.38, alpha: 0.015)
        ctx.move(to: CGPoint(x: x1, y: y1))
        ctx.addLine(to: CGPoint(x: x2, y: y2))
        ctx.strokePath()
    }

    // ---- Central hexagram (Star of David / seal of Solomon) ----
    let sr = min(cw, ch) * 0.22
    ctx.setStrokeColor(red: 0.83, green: 0.68, blue: 0.38, alpha: 0.06)
    ctx.setLineWidth(2.5)

    // Two overlapping triangles
    for flip in [1.0, -1.0] as [CGFloat] {
        ctx.move(to: CGPoint(x: cx, y: cy + sr * flip))
        ctx.addLine(to: CGPoint(x: cx - sr * 0.866, y: cy - sr * 0.5 * flip))
        ctx.addLine(to: CGPoint(x: cx + sr * 0.866, y: cy - sr * 0.5 * flip))
        ctx.closePath()
        ctx.strokePath()
    }

    // Outer circle
    ctx.addEllipse(in: CGRect(x: cx - sr * 1.1, y: cy - sr * 1.1, width: sr * 2.2, height: sr * 2.2))
    ctx.strokePath()

    // Inner circle
    ctx.addEllipse(in: CGRect(x: cx - sr * 0.45, y: cy - sr * 0.45, width: sr * 0.9, height: sr * 0.9))
    ctx.strokePath()

    // ---- Secondary rings — dodecahedron vertices ----
    ctx.setStrokeColor(red: 0.83, green: 0.68, blue: 0.38, alpha: 0.025)
    ctx.setLineWidth(1.5)
    for i in 0..<12 {
        let angle = CGFloat(i) * .pi * 2 / 12
        let vx = cx + cos(angle) * sr * 1.1
        let vy = cy + sin(angle) * sr * 1.1
        // Small circle at each vertex
        ctx.addEllipse(in: CGRect(x: vx - 6, y: vy - 6, width: 12, height: 12))
        ctx.strokePath()
        // Connect to next
        let nextAngle = CGFloat(i + 1) * .pi * 2 / 12
        let nvx = cx + cos(nextAngle) * sr * 1.1
        let nvy = cy + sin(nextAngle) * sr * 1.1
        ctx.move(to: CGPoint(x: vx, y: vy))
        ctx.addLine(to: CGPoint(x: nvx, y: nvy))
        ctx.strokePath()
    }

    // ---- Concentric meditation circles ----
    ctx.setLineWidth(0.8)
    for ring in [1.8, 2.5, 3.2] as [CGFloat] {
        let rr = sr * ring
        ctx.setStrokeColor(red: 0.83, green: 0.68, blue: 0.38, alpha: 0.012)
        ctx.addEllipse(in: CGRect(x: cx - rr, y: cy - rr, width: rr * 2, height: rr * 2))
        ctx.strokePath()
    }

    // ---- Corner symbols: four elements ----
    let cornerR: CGFloat = 30
    let margin: CGFloat = 80
    ctx.setStrokeColor(red: 0.83, green: 0.68, blue: 0.38, alpha: 0.04)
    ctx.setLineWidth(1.5)

    // Fire (top-left) — triangle up
    let fl = CGPoint(x: margin, y: ch - margin)
    ctx.move(to: CGPoint(x: fl.x, y: fl.y + cornerR))
    ctx.addLine(to: CGPoint(x: fl.x - cornerR * 0.8, y: fl.y - cornerR * 0.5))
    ctx.addLine(to: CGPoint(x: fl.x + cornerR * 0.8, y: fl.y - cornerR * 0.5))
    ctx.closePath()
    ctx.strokePath()

    // Water (top-right) — triangle down
    let wr = CGPoint(x: cw - margin, y: ch - margin)
    ctx.move(to: CGPoint(x: wr.x, y: wr.y - cornerR))
    ctx.addLine(to: CGPoint(x: wr.x - cornerR * 0.8, y: wr.y + cornerR * 0.5))
    ctx.addLine(to: CGPoint(x: wr.x + cornerR * 0.8, y: wr.y + cornerR * 0.5))
    ctx.closePath()
    ctx.strokePath()

    // Earth (bottom-right) — square
    let er = CGPoint(x: cw - margin, y: margin)
    ctx.addRect(CGRect(x: er.x - cornerR * 0.6, y: er.y - cornerR * 0.6,
                       width: cornerR * 1.2, height: cornerR * 1.2))
    ctx.strokePath()

    // Air (bottom-left) — circle
    let al = CGPoint(x: margin, y: margin)
    ctx.addEllipse(in: CGRect(x: al.x - cornerR * 0.6, y: al.y - cornerR * 0.6,
                              width: cornerR * 1.2, height: cornerR * 1.2))
    ctx.strokePath()

    // ---- Export as PNG ----
    guard let cgImage = ctx.makeImage() else {
        print("Failed to create image")
        return
    }

    let url = URL(fileURLWithPath: outputPath) as CFURL
    guard let dest = CGImageDestinationCreateWithURL(url, "public.png" as CFString, 1, nil) else {
        print("Failed to create destination")
        return
    }
    CGImageDestinationAddImage(dest, cgImage, nil)
    CGImageDestinationFinalize(dest)
    print("Wallpaper forged: \(outputPath) (\(w)x\(h))")
}

let outputPath = NSString(string: "~/.l7/icons/wallpaper-magisterium.png").expandingTildeInPath
generateWallpaper(outputPath: outputPath)
