// ============================================================
// L7 ICON FORGE — Generate alchemical icons from pure geometry
// No downloads. No third-party assets. The forge creates everything.
//
// Seven metals, seven planets, seven stages.
// Each icon born from mathematical transformation.
// ============================================================

import Cocoa
import CoreGraphics

// ============================================================
// Alchemical Color Palette — The Seven Metals
// ============================================================

struct Palette {
    // Backgrounds
    static let void_ = NSColor(red: 0.04, green: 0.03, blue: 0.06, alpha: 1.0)        // Deep void
    static let obsidian = NSColor(red: 0.08, green: 0.06, blue: 0.10, alpha: 1.0)      // Dark purple-black
    static let nightSky = NSColor(red: 0.06, green: 0.05, blue: 0.12, alpha: 1.0)      // Midnight indigo

    // The Seven Metals
    static let gold = NSColor(red: 0.83, green: 0.68, blue: 0.38, alpha: 1.0)          // ☉ Sun — Gold
    static let silver = NSColor(red: 0.75, green: 0.78, blue: 0.85, alpha: 1.0)        // ☽ Moon — Silver
    static let mercury = NSColor(red: 0.55, green: 0.82, blue: 0.82, alpha: 1.0)       // ☿ Mercury — Quicksilver
    static let copper = NSColor(red: 0.72, green: 0.45, blue: 0.35, alpha: 1.0)        // ♀ Venus — Copper
    static let iron = NSColor(red: 0.78, green: 0.30, blue: 0.25, alpha: 1.0)          // ♂ Mars — Iron
    static let tin = NSColor(red: 0.40, green: 0.50, blue: 0.78, alpha: 1.0)           // ♃ Jupiter — Tin
    static let lead = NSColor(red: 0.50, green: 0.48, blue: 0.45, alpha: 1.0)          // ♄ Saturn — Lead

    // Accents
    static let ember = NSColor(red: 0.90, green: 0.45, blue: 0.15, alpha: 1.0)         // Fire
    static let emerald = NSColor(red: 0.25, green: 0.75, blue: 0.50, alpha: 1.0)       // Earth
    static let azureGlow = NSColor(red: 0.30, green: 0.55, blue: 0.90, alpha: 1.0)     // Water
    static let amethyst = NSColor(red: 0.58, green: 0.30, blue: 0.75, alpha: 1.0)      // Spirit
}

// ============================================================
// Icon Definitions — What to generate
// ============================================================

enum IconShape {
    case circle          // ☉ Sun — wholeness
    case crescent        // ☽ Moon — reflection
    case cross           // ♀ Venus — matter + spirit
    case arrow           // ♂ Mars — force, direction
    case triangle        // 🜂 Fire — transformation
    case invertTriangle  // 🜃 Water — dissolution
    case hexagram        // ✡ Union of opposites
    case square          // 🜄 Earth — stability
    case spiral          // ☿ Mercury — flow
    case eye             // 👁 Awareness
    case tree            // 🌳 Tree of Life
    case key             // 🔑 Access
    case flask           // ⚗ Transmutation
    case gear            // ⚙ Mechanism
    case book            // 📖 Knowledge
    case shield          // 🛡 Protection
    case diamond         // ◇ Clarity
    case wave            // ∿ Resonance
    case atom            // ⚛ Structure
    case rose            // ✿ The Rose Cross
    case compass         // ⊕ Navigation
    case feather         // ✦ Lightness
    case crown           // ♛ Sovereignty
    case infinity        // ∞ Eternal
    case pentagram       // ⛤ Five elements
    case ankh            // ☥ Life
    case ouroboros        // ◎ Self-reference
    case pillar          // ▮ Foundation
    case star            // ★ Aspiration
    case droplet         // 💧 Essence
    case folder          // 📁 Container (for folders)
    case db              // 🗃 Database
}

struct IconDef {
    let name: String
    let shape: IconShape
    let primary: NSColor
    let secondary: NSColor
    let glow: NSColor
    let label: String  // Short label for icon overlay
}

// ============================================================
// Drawing Engine — Pure Core Graphics geometry
// ============================================================

class IconRenderer {
    let size: CGFloat
    let scale: CGFloat = 2.0  // Retina

    init(size: CGFloat = 512) {
        self.size = size
    }

    func render(_ def: IconDef) -> NSImage {
        let pixelSize = Int(size * scale)
        let image = NSImage(size: NSSize(width: size, height: size))
        image.lockFocus()

        guard let ctx = NSGraphicsContext.current?.cgContext else {
            image.unlockFocus()
            return image
        }

        ctx.scaleBy(x: 1, y: 1)
        let rect = CGRect(x: 0, y: 0, width: size, height: size)

        // Background — rounded square with subtle gradient
        drawBackground(ctx, rect: rect, def: def)

        // Glow effect behind symbol
        drawGlow(ctx, rect: rect, def: def)

        // Main symbol
        drawShape(ctx, rect: rect, def: def)

        // Subtle border ring
        drawBorder(ctx, rect: rect, def: def)

        image.unlockFocus()
        return image
    }

    private func drawBackground(_ ctx: CGContext, rect: CGRect, def: IconDef) {
        let cornerRadius: CGFloat = size * 0.22
        let path = CGPath(roundedRect: rect.insetBy(dx: 2, dy: 2),
                         cornerWidth: cornerRadius, cornerHeight: cornerRadius,
                         transform: nil)
        ctx.addPath(path)
        ctx.clip()

        // Radial gradient background
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let centerColor = Palette.obsidian.withAlphaComponent(0.95).cgColor
        let edgeColor = Palette.void_.cgColor
        let gradient = CGGradient(colorsSpace: colorSpace,
                                  colors: [centerColor, edgeColor] as CFArray,
                                  locations: [0.0, 1.0])!

        let center = CGPoint(x: size / 2, y: size / 2)
        ctx.drawRadialGradient(gradient, startCenter: center, startRadius: 0,
                               endCenter: center, endRadius: size * 0.7,
                               options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])

        ctx.resetClip()
    }

    private func drawGlow(_ ctx: CGContext, rect: CGRect, def: IconDef) {
        let center = CGPoint(x: size / 2, y: size / 2)
        let glowRadius = size * 0.30

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let glowColor = def.glow.withAlphaComponent(0.15).cgColor
        let clearColor = def.glow.withAlphaComponent(0.0).cgColor
        let gradient = CGGradient(colorsSpace: colorSpace,
                                  colors: [glowColor, clearColor] as CFArray,
                                  locations: [0.0, 1.0])!

        ctx.drawRadialGradient(gradient, startCenter: center, startRadius: 0,
                               endCenter: center, endRadius: glowRadius,
                               options: [])
    }

    private func drawBorder(_ ctx: CGContext, rect: CGRect, def: IconDef) {
        let cornerRadius: CGFloat = size * 0.22
        let inset = rect.insetBy(dx: 3, dy: 3)
        let path = CGPath(roundedRect: inset,
                         cornerWidth: cornerRadius, cornerHeight: cornerRadius,
                         transform: nil)
        ctx.addPath(path)
        ctx.setStrokeColor(def.primary.withAlphaComponent(0.25).cgColor)
        ctx.setLineWidth(1.5)
        ctx.strokePath()
    }

    private func drawShape(_ ctx: CGContext, rect: CGRect, def: IconDef) {
        let cx = size / 2
        let cy = size / 2
        let r = size * 0.25  // Symbol radius

        ctx.setStrokeColor(def.primary.cgColor)
        ctx.setFillColor(def.primary.withAlphaComponent(0.15).cgColor)
        ctx.setLineWidth(size * 0.018)
        ctx.setLineCap(.round)
        ctx.setLineJoin(.round)

        switch def.shape {
        case .circle:
            drawCircleSymbol(ctx, cx: cx, cy: cy, r: r, def: def)
        case .crescent:
            drawCrescentSymbol(ctx, cx: cx, cy: cy, r: r, def: def)
        case .cross:
            drawCrossSymbol(ctx, cx: cx, cy: cy, r: r, def: def)
        case .arrow:
            drawArrowSymbol(ctx, cx: cx, cy: cy, r: r, def: def)
        case .triangle:
            drawTriangleSymbol(ctx, cx: cx, cy: cy, r: r, up: true, def: def)
        case .invertTriangle:
            drawTriangleSymbol(ctx, cx: cx, cy: cy, r: r, up: false, def: def)
        case .hexagram:
            drawHexagramSymbol(ctx, cx: cx, cy: cy, r: r, def: def)
        case .square:
            drawSquareSymbol(ctx, cx: cx, cy: cy, r: r, def: def)
        case .spiral:
            drawSpiralSymbol(ctx, cx: cx, cy: cy, r: r, def: def)
        case .eye:
            drawEyeSymbol(ctx, cx: cx, cy: cy, r: r, def: def)
        case .tree:
            drawTreeSymbol(ctx, cx: cx, cy: cy, r: r, def: def)
        case .key:
            drawKeySymbol(ctx, cx: cx, cy: cy, r: r, def: def)
        case .flask:
            drawFlaskSymbol(ctx, cx: cx, cy: cy, r: r, def: def)
        case .gear:
            drawGearSymbol(ctx, cx: cx, cy: cy, r: r, def: def)
        case .book:
            drawBookSymbol(ctx, cx: cx, cy: cy, r: r, def: def)
        case .shield:
            drawShieldSymbol(ctx, cx: cx, cy: cy, r: r, def: def)
        case .diamond:
            drawDiamondSymbol(ctx, cx: cx, cy: cy, r: r, def: def)
        case .wave:
            drawWaveSymbol(ctx, cx: cx, cy: cy, r: r, def: def)
        case .atom:
            drawAtomSymbol(ctx, cx: cx, cy: cy, r: r, def: def)
        case .rose:
            drawRoseSymbol(ctx, cx: cx, cy: cy, r: r, def: def)
        case .compass:
            drawCompassSymbol(ctx, cx: cx, cy: cy, r: r, def: def)
        case .star:
            drawStarSymbol(ctx, cx: cx, cy: cy, r: r, def: def)
        case .pentagram:
            drawPentagramSymbol(ctx, cx: cx, cy: cy, r: r, def: def)
        case .ankh:
            drawAnkhSymbol(ctx, cx: cx, cy: cy, r: r, def: def)
        case .ouroboros:
            drawOuroborosSymbol(ctx, cx: cx, cy: cy, r: r, def: def)
        case .infinity:
            drawInfinitySymbol(ctx, cx: cx, cy: cy, r: r, def: def)
        case .crown:
            drawCrownSymbol(ctx, cx: cx, cy: cy, r: r, def: def)
        case .pillar:
            drawPillarSymbol(ctx, cx: cx, cy: cy, r: r, def: def)
        case .droplet:
            drawDropletSymbol(ctx, cx: cx, cy: cy, r: r, def: def)
        case .feather:
            drawFeatherSymbol(ctx, cx: cx, cy: cy, r: r, def: def)
        case .folder:
            drawFolderSymbol(ctx, cx: cx, cy: cy, r: r, def: def)
        case .db:
            drawDBSymbol(ctx, cx: cx, cy: cy, r: r, def: def)
        }
    }

    // ---- Individual symbol renderers ----

    private func drawCircleSymbol(_ ctx: CGContext, cx: CGFloat, cy: CGFloat, r: CGFloat, def: IconDef) {
        // Sun symbol: circle with radiating lines
        ctx.addEllipse(in: CGRect(x: cx - r * 0.6, y: cy - r * 0.6, width: r * 1.2, height: r * 1.2))
        ctx.drawPath(using: .fillStroke)
        // Dot in center
        ctx.setFillColor(def.primary.cgColor)
        ctx.fillEllipse(in: CGRect(x: cx - r * 0.08, y: cy - r * 0.08, width: r * 0.16, height: r * 0.16))
        // Rays
        for i in 0..<8 {
            let angle = CGFloat(i) * .pi / 4
            let x1 = cx + cos(angle) * r * 0.75
            let y1 = cy + sin(angle) * r * 0.75
            let x2 = cx + cos(angle) * r * 1.05
            let y2 = cy + sin(angle) * r * 1.05
            ctx.move(to: CGPoint(x: x1, y: y1))
            ctx.addLine(to: CGPoint(x: x2, y: y2))
        }
        ctx.strokePath()
    }

    private func drawCrescentSymbol(_ ctx: CGContext, cx: CGFloat, cy: CGFloat, r: CGFloat, def: IconDef) {
        let path = CGMutablePath()
        path.addArc(center: CGPoint(x: cx, y: cy), radius: r * 0.8,
                    startAngle: -.pi * 0.3, endAngle: .pi * 0.3, clockwise: true)
        path.addArc(center: CGPoint(x: cx + r * 0.35, y: cy), radius: r * 0.6,
                    startAngle: .pi * 0.35, endAngle: -.pi * 0.35, clockwise: false)
        path.closeSubpath()
        ctx.addPath(path)
        ctx.drawPath(using: .fillStroke)
    }

    private func drawCrossSymbol(_ ctx: CGContext, cx: CGFloat, cy: CGFloat, r: CGFloat, def: IconDef) {
        // Venus symbol: circle + cross below
        let cr = r * 0.45
        ctx.addEllipse(in: CGRect(x: cx - cr, y: cy + r * 0.05, width: cr * 2, height: cr * 2))
        ctx.strokePath()
        ctx.move(to: CGPoint(x: cx, y: cy + r * 0.05))
        ctx.addLine(to: CGPoint(x: cx, y: cy - r * 0.7))
        ctx.move(to: CGPoint(x: cx - r * 0.3, y: cy - r * 0.35))
        ctx.addLine(to: CGPoint(x: cx + r * 0.3, y: cy - r * 0.35))
        ctx.strokePath()
    }

    private func drawArrowSymbol(_ ctx: CGContext, cx: CGFloat, cy: CGFloat, r: CGFloat, def: IconDef) {
        // Mars symbol: circle + arrow upper-right
        let cr = r * 0.45
        ctx.addEllipse(in: CGRect(x: cx - cr - r * 0.15, y: cy - cr - r * 0.1, width: cr * 2, height: cr * 2))
        ctx.strokePath()
        let ax = cx + r * 0.55
        let ay = cy + r * 0.55
        ctx.move(to: CGPoint(x: cx + cr * 0.5, y: cy + cr * 0.5))
        ctx.addLine(to: CGPoint(x: ax, y: ay))
        ctx.move(to: CGPoint(x: ax - r * 0.3, y: ay))
        ctx.addLine(to: CGPoint(x: ax, y: ay))
        ctx.addLine(to: CGPoint(x: ax, y: ay - r * 0.3))
        ctx.strokePath()
    }

    private func drawTriangleSymbol(_ ctx: CGContext, cx: CGFloat, cy: CGFloat, r: CGFloat, up: Bool, def: IconDef) {
        let h = r * 0.9
        let path = CGMutablePath()
        if up {
            path.move(to: CGPoint(x: cx, y: cy + h))
            path.addLine(to: CGPoint(x: cx - r * 0.8, y: cy - h * 0.5))
            path.addLine(to: CGPoint(x: cx + r * 0.8, y: cy - h * 0.5))
        } else {
            path.move(to: CGPoint(x: cx, y: cy - h))
            path.addLine(to: CGPoint(x: cx - r * 0.8, y: cy + h * 0.5))
            path.addLine(to: CGPoint(x: cx + r * 0.8, y: cy + h * 0.5))
        }
        path.closeSubpath()
        ctx.addPath(path)
        ctx.drawPath(using: .fillStroke)
    }

    private func drawHexagramSymbol(_ ctx: CGContext, cx: CGFloat, cy: CGFloat, r: CGFloat, def: IconDef) {
        // Two overlapping triangles
        for up in [true, false] {
            let h = r * 0.85
            let path = CGMutablePath()
            if up {
                path.move(to: CGPoint(x: cx, y: cy + h))
                path.addLine(to: CGPoint(x: cx - r * 0.75, y: cy - h * 0.45))
                path.addLine(to: CGPoint(x: cx + r * 0.75, y: cy - h * 0.45))
            } else {
                path.move(to: CGPoint(x: cx, y: cy - h))
                path.addLine(to: CGPoint(x: cx - r * 0.75, y: cy + h * 0.45))
                path.addLine(to: CGPoint(x: cx + r * 0.75, y: cy + h * 0.45))
            }
            path.closeSubpath()
            ctx.addPath(path)
            ctx.drawPath(using: .fillStroke)
        }
    }

    private func drawSquareSymbol(_ ctx: CGContext, cx: CGFloat, cy: CGFloat, r: CGFloat, def: IconDef) {
        let s = r * 0.75
        ctx.addRect(CGRect(x: cx - s, y: cy - s, width: s * 2, height: s * 2))
        ctx.drawPath(using: .fillStroke)
        // Inner diamond
        let d = r * 0.4
        let path = CGMutablePath()
        path.move(to: CGPoint(x: cx, y: cy + d))
        path.addLine(to: CGPoint(x: cx - d, y: cy))
        path.addLine(to: CGPoint(x: cx, y: cy - d))
        path.addLine(to: CGPoint(x: cx + d, y: cy))
        path.closeSubpath()
        ctx.addPath(path)
        ctx.setStrokeColor(def.secondary.cgColor)
        ctx.strokePath()
    }

    private func drawSpiralSymbol(_ ctx: CGContext, cx: CGFloat, cy: CGFloat, r: CGFloat, def: IconDef) {
        let path = CGMutablePath()
        var first = true
        for i in stride(from: 0.0, to: CGFloat.pi * 5, by: 0.1) {
            let sr = r * 0.1 + (r * 0.7 * i / (.pi * 5))
            let x = cx + cos(i) * sr
            let y = cy + sin(i) * sr
            if first { path.move(to: CGPoint(x: x, y: y)); first = false }
            else { path.addLine(to: CGPoint(x: x, y: y)) }
        }
        ctx.addPath(path)
        ctx.strokePath()
    }

    private func drawEyeSymbol(_ ctx: CGContext, cx: CGFloat, cy: CGFloat, r: CGFloat, def: IconDef) {
        // Eye of Providence shape
        let path = CGMutablePath()
        path.move(to: CGPoint(x: cx - r, y: cy))
        path.addQuadCurve(to: CGPoint(x: cx + r, y: cy), control: CGPoint(x: cx, y: cy + r * 0.8))
        path.addQuadCurve(to: CGPoint(x: cx - r, y: cy), control: CGPoint(x: cx, y: cy - r * 0.8))
        path.closeSubpath()
        ctx.addPath(path)
        ctx.drawPath(using: .fillStroke)
        // Pupil
        ctx.setFillColor(def.primary.cgColor)
        ctx.fillEllipse(in: CGRect(x: cx - r * 0.2, y: cy - r * 0.2, width: r * 0.4, height: r * 0.4))
        // Inner pupil
        ctx.setFillColor(Palette.void_.cgColor)
        ctx.fillEllipse(in: CGRect(x: cx - r * 0.08, y: cy - r * 0.08, width: r * 0.16, height: r * 0.16))
    }

    private func drawTreeSymbol(_ ctx: CGContext, cx: CGFloat, cy: CGFloat, r: CGFloat, def: IconDef) {
        // Tree of Life — trunk + 3 branches each side
        ctx.move(to: CGPoint(x: cx, y: cy - r))
        ctx.addLine(to: CGPoint(x: cx, y: cy + r))
        ctx.strokePath()
        for i in 0..<3 {
            let y = cy + r * 0.6 - CGFloat(i) * r * 0.5
            let spread = r * (0.3 + CGFloat(i) * 0.2)
            ctx.move(to: CGPoint(x: cx, y: y))
            ctx.addLine(to: CGPoint(x: cx - spread, y: y + r * 0.3))
            ctx.move(to: CGPoint(x: cx, y: y))
            ctx.addLine(to: CGPoint(x: cx + spread, y: y + r * 0.3))
        }
        ctx.strokePath()
        // Crown circle
        ctx.addEllipse(in: CGRect(x: cx - r * 0.15, y: cy + r * 0.85, width: r * 0.3, height: r * 0.3))
        ctx.drawPath(using: .fillStroke)
    }

    private func drawKeySymbol(_ ctx: CGContext, cx: CGFloat, cy: CGFloat, r: CGFloat, def: IconDef) {
        // Key — circle head + shaft + teeth
        let headR = r * 0.35
        ctx.addEllipse(in: CGRect(x: cx - headR, y: cy + r * 0.15, width: headR * 2, height: headR * 2))
        ctx.strokePath()
        ctx.move(to: CGPoint(x: cx, y: cy + r * 0.15))
        ctx.addLine(to: CGPoint(x: cx, y: cy - r * 0.85))
        // Teeth
        ctx.move(to: CGPoint(x: cx, y: cy - r * 0.5))
        ctx.addLine(to: CGPoint(x: cx + r * 0.25, y: cy - r * 0.5))
        ctx.move(to: CGPoint(x: cx, y: cy - r * 0.7))
        ctx.addLine(to: CGPoint(x: cx + r * 0.2, y: cy - r * 0.7))
        ctx.strokePath()
    }

    private func drawFlaskSymbol(_ ctx: CGContext, cx: CGFloat, cy: CGFloat, r: CGFloat, def: IconDef) {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: cx - r * 0.2, y: cy + r))
        path.addLine(to: CGPoint(x: cx - r * 0.2, y: cy + r * 0.3))
        path.addLine(to: CGPoint(x: cx - r * 0.6, y: cy - r * 0.6))
        path.addLine(to: CGPoint(x: cx - r * 0.6, y: cy - r * 0.8))
        path.addLine(to: CGPoint(x: cx + r * 0.6, y: cy - r * 0.8))
        path.addLine(to: CGPoint(x: cx + r * 0.6, y: cy - r * 0.6))
        path.addLine(to: CGPoint(x: cx + r * 0.2, y: cy + r * 0.3))
        path.addLine(to: CGPoint(x: cx + r * 0.2, y: cy + r))
        path.closeSubpath()
        ctx.addPath(path)
        ctx.drawPath(using: .fillStroke)
        // Liquid level
        ctx.setFillColor(def.secondary.withAlphaComponent(0.3).cgColor)
        ctx.fill(CGRect(x: cx - r * 0.55, y: cy - r * 0.75, width: r * 1.1, height: r * 0.4))
    }

    private func drawGearSymbol(_ ctx: CGContext, cx: CGFloat, cy: CGFloat, r: CGFloat, def: IconDef) {
        let teeth = 8
        let path = CGMutablePath()
        for i in 0..<teeth {
            let a1 = CGFloat(i) * .pi * 2 / CGFloat(teeth) - .pi / CGFloat(teeth * 2)
            let a2 = CGFloat(i) * .pi * 2 / CGFloat(teeth) + .pi / CGFloat(teeth * 2)
            let ri = r * 0.55
            let ro = r * 0.80
            if i == 0 { path.move(to: CGPoint(x: cx + cos(a1) * ri, y: cy + sin(a1) * ri)) }
            path.addLine(to: CGPoint(x: cx + cos(a1) * ro, y: cy + sin(a1) * ro))
            path.addLine(to: CGPoint(x: cx + cos(a2) * ro, y: cy + sin(a2) * ro))
            let a3 = CGFloat(i + 1) * .pi * 2 / CGFloat(teeth) - .pi / CGFloat(teeth * 2)
            path.addLine(to: CGPoint(x: cx + cos(a3) * ri, y: cy + sin(a3) * ri))
        }
        path.closeSubpath()
        ctx.addPath(path)
        ctx.drawPath(using: .fillStroke)
        // Center hole
        ctx.setFillColor(Palette.void_.cgColor)
        ctx.fillEllipse(in: CGRect(x: cx - r * 0.18, y: cy - r * 0.18, width: r * 0.36, height: r * 0.36))
        ctx.addEllipse(in: CGRect(x: cx - r * 0.18, y: cy - r * 0.18, width: r * 0.36, height: r * 0.36))
        ctx.setStrokeColor(def.primary.cgColor)
        ctx.strokePath()
    }

    private func drawBookSymbol(_ ctx: CGContext, cx: CGFloat, cy: CGFloat, r: CGFloat, def: IconDef) {
        // Open book
        let path = CGMutablePath()
        path.move(to: CGPoint(x: cx, y: cy - r * 0.6))
        path.addQuadCurve(to: CGPoint(x: cx - r * 0.85, y: cy - r * 0.4), control: CGPoint(x: cx - r * 0.5, y: cy - r * 0.7))
        path.addLine(to: CGPoint(x: cx - r * 0.85, y: cy + r * 0.6))
        path.addQuadCurve(to: CGPoint(x: cx, y: cy + r * 0.3), control: CGPoint(x: cx - r * 0.5, y: cy + r * 0.7))
        path.closeSubpath()
        ctx.addPath(path)
        ctx.drawPath(using: .fillStroke)
        let path2 = CGMutablePath()
        path2.move(to: CGPoint(x: cx, y: cy - r * 0.6))
        path2.addQuadCurve(to: CGPoint(x: cx + r * 0.85, y: cy - r * 0.4), control: CGPoint(x: cx + r * 0.5, y: cy - r * 0.7))
        path2.addLine(to: CGPoint(x: cx + r * 0.85, y: cy + r * 0.6))
        path2.addQuadCurve(to: CGPoint(x: cx, y: cy + r * 0.3), control: CGPoint(x: cx + r * 0.5, y: cy + r * 0.7))
        path2.closeSubpath()
        ctx.addPath(path2)
        ctx.drawPath(using: .fillStroke)
        // Spine
        ctx.move(to: CGPoint(x: cx, y: cy - r * 0.6))
        ctx.addLine(to: CGPoint(x: cx, y: cy + r * 0.3))
        ctx.strokePath()
    }

    private func drawShieldSymbol(_ ctx: CGContext, cx: CGFloat, cy: CGFloat, r: CGFloat, def: IconDef) {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: cx, y: cy + r))
        path.addLine(to: CGPoint(x: cx - r * 0.75, y: cy + r * 0.5))
        path.addLine(to: CGPoint(x: cx - r * 0.75, y: cy - r * 0.1))
        path.addQuadCurve(to: CGPoint(x: cx, y: cy - r), control: CGPoint(x: cx - r * 0.75, y: cy - r * 0.7))
        path.addQuadCurve(to: CGPoint(x: cx + r * 0.75, y: cy - r * 0.1), control: CGPoint(x: cx + r * 0.75, y: cy - r * 0.7))
        path.addLine(to: CGPoint(x: cx + r * 0.75, y: cy + r * 0.5))
        path.closeSubpath()
        ctx.addPath(path)
        ctx.drawPath(using: .fillStroke)
    }

    private func drawDiamondSymbol(_ ctx: CGContext, cx: CGFloat, cy: CGFloat, r: CGFloat, def: IconDef) {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: cx, y: cy + r))
        path.addLine(to: CGPoint(x: cx - r * 0.7, y: cy))
        path.addLine(to: CGPoint(x: cx, y: cy - r))
        path.addLine(to: CGPoint(x: cx + r * 0.7, y: cy))
        path.closeSubpath()
        ctx.addPath(path)
        ctx.drawPath(using: .fillStroke)
        // Facet lines
        ctx.setStrokeColor(def.secondary.withAlphaComponent(0.5).cgColor)
        ctx.move(to: CGPoint(x: cx - r * 0.7, y: cy))
        ctx.addLine(to: CGPoint(x: cx + r * 0.7, y: cy))
        ctx.move(to: CGPoint(x: cx - r * 0.35, y: cy))
        ctx.addLine(to: CGPoint(x: cx, y: cy + r))
        ctx.addLine(to: CGPoint(x: cx + r * 0.35, y: cy))
        ctx.strokePath()
    }

    private func drawWaveSymbol(_ ctx: CGContext, cx: CGFloat, cy: CGFloat, r: CGFloat, def: IconDef) {
        for j in 0..<3 {
            let yOff = CGFloat(j - 1) * r * 0.5
            let path = CGMutablePath()
            path.move(to: CGPoint(x: cx - r, y: cy + yOff))
            for x in stride(from: CGFloat(-1.0), through: 1.0, by: 0.05) {
                let px = cx + x * r
                let py = cy + yOff + sin(x * .pi * 2) * r * 0.15
                path.addLine(to: CGPoint(x: px, y: py))
            }
            ctx.addPath(path)
            ctx.setStrokeColor(def.primary.withAlphaComponent(1.0 - CGFloat(j) * 0.25).cgColor)
            ctx.strokePath()
        }
    }

    private func drawAtomSymbol(_ ctx: CGContext, cx: CGFloat, cy: CGFloat, r: CGFloat, def: IconDef) {
        // 3 elliptical orbits + nucleus
        for i in 0..<3 {
            let angle = CGFloat(i) * .pi / 3
            ctx.saveGState()
            ctx.translateBy(x: cx, y: cy)
            ctx.rotate(by: angle)
            ctx.addEllipse(in: CGRect(x: -r * 0.9, y: -r * 0.35, width: r * 1.8, height: r * 0.7))
            ctx.strokePath()
            ctx.restoreGState()
        }
        ctx.setFillColor(def.primary.cgColor)
        ctx.fillEllipse(in: CGRect(x: cx - r * 0.12, y: cy - r * 0.12, width: r * 0.24, height: r * 0.24))
    }

    private func drawRoseSymbol(_ ctx: CGContext, cx: CGFloat, cy: CGFloat, r: CGFloat, def: IconDef) {
        // Rose Cross — 5 petals
        let petals = 5
        for i in 0..<petals {
            let angle = CGFloat(i) * .pi * 2 / CGFloat(petals) + .pi / 2
            let px = cx + cos(angle) * r * 0.5
            let py = cy + sin(angle) * r * 0.5
            ctx.addEllipse(in: CGRect(x: px - r * 0.3, y: py - r * 0.3, width: r * 0.6, height: r * 0.6))
            ctx.drawPath(using: .fillStroke)
        }
        // Center
        ctx.setFillColor(def.secondary.withAlphaComponent(0.5).cgColor)
        ctx.fillEllipse(in: CGRect(x: cx - r * 0.2, y: cy - r * 0.2, width: r * 0.4, height: r * 0.4))
        ctx.addEllipse(in: CGRect(x: cx - r * 0.2, y: cy - r * 0.2, width: r * 0.4, height: r * 0.4))
        ctx.strokePath()
    }

    private func drawCompassSymbol(_ ctx: CGContext, cx: CGFloat, cy: CGFloat, r: CGFloat, def: IconDef) {
        ctx.addEllipse(in: CGRect(x: cx - r * 0.85, y: cy - r * 0.85, width: r * 1.7, height: r * 1.7))
        ctx.strokePath()
        // Cross
        ctx.move(to: CGPoint(x: cx, y: cy + r * 0.7))
        ctx.addLine(to: CGPoint(x: cx, y: cy - r * 0.7))
        ctx.move(to: CGPoint(x: cx - r * 0.7, y: cy))
        ctx.addLine(to: CGPoint(x: cx + r * 0.7, y: cy))
        ctx.strokePath()
        // Needle
        let path = CGMutablePath()
        path.move(to: CGPoint(x: cx, y: cy + r * 0.55))
        path.addLine(to: CGPoint(x: cx - r * 0.1, y: cy))
        path.addLine(to: CGPoint(x: cx + r * 0.1, y: cy))
        path.closeSubpath()
        ctx.addPath(path)
        ctx.setFillColor(def.primary.cgColor)
        ctx.fillPath()
    }

    private func drawStarSymbol(_ ctx: CGContext, cx: CGFloat, cy: CGFloat, r: CGFloat, def: IconDef) {
        let points = 6
        let path = CGMutablePath()
        for i in 0..<points * 2 {
            let angle = CGFloat(i) * .pi / CGFloat(points) - .pi / 2
            let sr = (i % 2 == 0) ? r * 0.9 : r * 0.4
            let p = CGPoint(x: cx + cos(angle) * sr, y: cy + sin(angle) * sr)
            if i == 0 { path.move(to: p) } else { path.addLine(to: p) }
        }
        path.closeSubpath()
        ctx.addPath(path)
        ctx.drawPath(using: .fillStroke)
    }

    private func drawPentagramSymbol(_ ctx: CGContext, cx: CGFloat, cy: CGFloat, r: CGFloat, def: IconDef) {
        let path = CGMutablePath()
        for i in 0..<5 {
            let angle = CGFloat(i) * .pi * 2 / 5 - .pi / 2
            let p = CGPoint(x: cx + cos(angle) * r * 0.9, y: cy + sin(angle) * r * 0.9)
            if i == 0 { path.move(to: p) }
            let next = CGFloat((i * 2) % 5) * .pi * 2 / 5 - .pi / 2
            path.addLine(to: CGPoint(x: cx + cos(next) * r * 0.9, y: cy + sin(next) * r * 0.9))
        }
        ctx.addPath(path)
        ctx.drawPath(using: .fillStroke)
        // Outer circle
        ctx.addEllipse(in: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2))
        ctx.strokePath()
    }

    private func drawAnkhSymbol(_ ctx: CGContext, cx: CGFloat, cy: CGFloat, r: CGFloat, def: IconDef) {
        // Loop on top
        ctx.addEllipse(in: CGRect(x: cx - r * 0.3, y: cy + r * 0.2, width: r * 0.6, height: r * 0.7))
        ctx.strokePath()
        // Vertical
        ctx.move(to: CGPoint(x: cx, y: cy + r * 0.2))
        ctx.addLine(to: CGPoint(x: cx, y: cy - r * 0.9))
        // Horizontal
        ctx.move(to: CGPoint(x: cx - r * 0.45, y: cy))
        ctx.addLine(to: CGPoint(x: cx + r * 0.45, y: cy))
        ctx.strokePath()
    }

    private func drawOuroborosSymbol(_ ctx: CGContext, cx: CGFloat, cy: CGFloat, r: CGFloat, def: IconDef) {
        // Nearly complete circle (snake eating its tail)
        let path = CGMutablePath()
        path.addArc(center: CGPoint(x: cx, y: cy), radius: r * 0.75,
                    startAngle: .pi * 0.1, endAngle: .pi * 1.95, clockwise: false)
        ctx.addPath(path)
        ctx.strokePath()
        // Head (triangle at the meeting point)
        let ha = CGFloat.pi * 0.1
        let hx = cx + cos(ha) * r * 0.75
        let hy = cy + sin(ha) * r * 0.75
        ctx.setFillColor(def.primary.cgColor)
        let tp = CGMutablePath()
        tp.move(to: CGPoint(x: hx + r * 0.12, y: hy + r * 0.08))
        tp.addLine(to: CGPoint(x: hx - r * 0.08, y: hy - r * 0.08))
        tp.addLine(to: CGPoint(x: hx + r * 0.08, y: hy - r * 0.12))
        tp.closeSubpath()
        ctx.addPath(tp)
        ctx.fillPath()
    }

    private func drawInfinitySymbol(_ ctx: CGContext, cx: CGFloat, cy: CGFloat, r: CGFloat, def: IconDef) {
        let path = CGMutablePath()
        var first = true
        for t in stride(from: 0.0, to: CGFloat.pi * 2, by: 0.05) {
            let x = cx + cos(t) * r * 0.85 / (1 + sin(t) * sin(t))
            let y = cy + sin(t) * cos(t) * r * 0.85 / (1 + sin(t) * sin(t))
            if first { path.move(to: CGPoint(x: x, y: y)); first = false }
            else { path.addLine(to: CGPoint(x: x, y: y)) }
        }
        path.closeSubpath()
        ctx.addPath(path)
        ctx.drawPath(using: .fillStroke)
    }

    private func drawCrownSymbol(_ ctx: CGContext, cx: CGFloat, cy: CGFloat, r: CGFloat, def: IconDef) {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: cx - r * 0.7, y: cy - r * 0.4))
        path.addLine(to: CGPoint(x: cx - r * 0.7, y: cy + r * 0.2))
        path.addLine(to: CGPoint(x: cx - r * 0.35, y: cy + r * 0.6))
        path.addLine(to: CGPoint(x: cx, y: cy + r * 0.3))
        path.addLine(to: CGPoint(x: cx + r * 0.35, y: cy + r * 0.6))
        path.addLine(to: CGPoint(x: cx + r * 0.7, y: cy + r * 0.2))
        path.addLine(to: CGPoint(x: cx + r * 0.7, y: cy - r * 0.4))
        path.closeSubpath()
        ctx.addPath(path)
        ctx.drawPath(using: .fillStroke)
        // Jewels
        for xo in [-0.35, 0.0, 0.35] as [CGFloat] {
            ctx.setFillColor(def.secondary.cgColor)
            ctx.fillEllipse(in: CGRect(x: cx + xo * r - r * 0.06, y: cy - r * 0.25, width: r * 0.12, height: r * 0.12))
        }
    }

    private func drawPillarSymbol(_ ctx: CGContext, cx: CGFloat, cy: CGFloat, r: CGFloat, def: IconDef) {
        // Two pillars (Jachin & Boaz)
        for xo in [-0.4, 0.4] as [CGFloat] {
            let px = cx + xo * r
            ctx.addRect(CGRect(x: px - r * 0.15, y: cy - r * 0.8, width: r * 0.3, height: r * 1.6))
            ctx.drawPath(using: .fillStroke)
            // Capital
            ctx.addRect(CGRect(x: px - r * 0.2, y: cy + r * 0.7, width: r * 0.4, height: r * 0.15))
            ctx.drawPath(using: .fillStroke)
            // Base
            ctx.addRect(CGRect(x: px - r * 0.2, y: cy - r * 0.85, width: r * 0.4, height: r * 0.15))
            ctx.drawPath(using: .fillStroke)
        }
    }

    private func drawDropletSymbol(_ ctx: CGContext, cx: CGFloat, cy: CGFloat, r: CGFloat, def: IconDef) {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: cx, y: cy + r * 0.9))
        path.addQuadCurve(to: CGPoint(x: cx - r * 0.55, y: cy - r * 0.1),
                          control: CGPoint(x: cx - r * 0.7, y: cy + r * 0.4))
        path.addArc(center: CGPoint(x: cx, y: cy - r * 0.1), radius: r * 0.55,
                    startAngle: .pi, endAngle: 0, clockwise: false)
        path.addQuadCurve(to: CGPoint(x: cx, y: cy + r * 0.9),
                          control: CGPoint(x: cx + r * 0.7, y: cy + r * 0.4))
        path.closeSubpath()
        ctx.addPath(path)
        ctx.drawPath(using: .fillStroke)
    }

    private func drawFeatherSymbol(_ ctx: CGContext, cx: CGFloat, cy: CGFloat, r: CGFloat, def: IconDef) {
        // Quill pen
        ctx.move(to: CGPoint(x: cx - r * 0.5, y: cy - r * 0.8))
        ctx.addLine(to: CGPoint(x: cx + r * 0.3, y: cy + r * 0.6))
        ctx.strokePath()
        // Barbs
        for i in 0..<6 {
            let t = CGFloat(i) / 6.0
            let px = cx - r * 0.5 + t * r * 0.8
            let py = cy - r * 0.8 + t * r * 1.4
            ctx.move(to: CGPoint(x: px, y: py))
            ctx.addLine(to: CGPoint(x: px - r * 0.25, y: py + r * 0.15))
            ctx.move(to: CGPoint(x: px, y: py))
            ctx.addLine(to: CGPoint(x: px + r * 0.25, y: py + r * 0.15))
        }
        ctx.strokePath()
    }

    private func drawFolderSymbol(_ ctx: CGContext, cx: CGFloat, cy: CGFloat, r: CGFloat, def: IconDef) {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: cx - r * 0.8, y: cy + r * 0.5))
        path.addLine(to: CGPoint(x: cx - r * 0.8, y: cy - r * 0.5))
        path.addLine(to: CGPoint(x: cx - r * 0.3, y: cy - r * 0.5))
        path.addLine(to: CGPoint(x: cx - r * 0.15, y: cy - r * 0.2))
        path.addLine(to: CGPoint(x: cx + r * 0.8, y: cy - r * 0.2))
        path.addLine(to: CGPoint(x: cx + r * 0.8, y: cy + r * 0.5))
        path.closeSubpath()
        ctx.addPath(path)
        ctx.drawPath(using: .fillStroke)
    }

    private func drawDBSymbol(_ ctx: CGContext, cx: CGFloat, cy: CGFloat, r: CGFloat, def: IconDef) {
        // Cylinder
        let w = r * 0.7
        let h = r * 0.25
        ctx.addEllipse(in: CGRect(x: cx - w, y: cy + r * 0.4, width: w * 2, height: h * 2))
        ctx.drawPath(using: .fillStroke)
        ctx.move(to: CGPoint(x: cx - w, y: cy + r * 0.4 + h))
        ctx.addLine(to: CGPoint(x: cx - w, y: cy - r * 0.4 + h))
        ctx.move(to: CGPoint(x: cx + w, y: cy + r * 0.4 + h))
        ctx.addLine(to: CGPoint(x: cx + w, y: cy - r * 0.4 + h))
        ctx.strokePath()
        ctx.addEllipse(in: CGRect(x: cx - w, y: cy - r * 0.4, width: w * 2, height: h * 2))
        ctx.drawPath(using: .fillStroke)
        // Middle band
        let midPath = CGMutablePath()
        midPath.addArc(center: CGPoint(x: cx, y: cy + h), radius: w,
                       startAngle: 0, endAngle: .pi, clockwise: false)
        ctx.addPath(midPath)
        ctx.setStrokeColor(def.secondary.withAlphaComponent(0.4).cgColor)
        ctx.strokePath()
    }
}

// ============================================================
// Icon Set — The Alchemist's Desktop
// ============================================================

let iconSet: [IconDef] = [
    // System / Folders
    IconDef(name: "folder-generic", shape: .folder, primary: Palette.gold, secondary: Palette.ember, glow: Palette.gold, label: ""),
    IconDef(name: "folder-documents", shape: .book, primary: Palette.gold, secondary: Palette.silver, glow: Palette.gold, label: ""),
    IconDef(name: "folder-downloads", shape: .invertTriangle, primary: Palette.mercury, secondary: Palette.azureGlow, glow: Palette.mercury, label: ""),
    IconDef(name: "folder-desktop", shape: .compass, primary: Palette.gold, secondary: Palette.silver, glow: Palette.gold, label: ""),
    IconDef(name: "folder-pictures", shape: .eye, primary: Palette.amethyst, secondary: Palette.silver, glow: Palette.amethyst, label: ""),
    IconDef(name: "folder-music", shape: .wave, primary: Palette.emerald, secondary: Palette.mercury, glow: Palette.emerald, label: ""),
    IconDef(name: "folder-movies", shape: .infinity, primary: Palette.copper, secondary: Palette.ember, glow: Palette.copper, label: ""),
    IconDef(name: "folder-library", shape: .pillar, primary: Palette.tin, secondary: Palette.silver, glow: Palette.tin, label: ""),

    // L7 WAY Tools
    IconDef(name: "l7-gateway", shape: .hexagram, primary: Palette.gold, secondary: Palette.ember, glow: Palette.gold, label: ""),
    IconDef(name: "l7-forge", shape: .flask, primary: Palette.ember, secondary: Palette.gold, glow: Palette.ember, label: ""),
    IconDef(name: "l7-vault", shape: .shield, primary: Palette.iron, secondary: Palette.gold, glow: Palette.iron, label: ""),
    IconDef(name: "l7-keykeeper", shape: .key, primary: Palette.gold, secondary: Palette.silver, glow: Palette.gold, label: ""),
    IconDef(name: "l7-rose", shape: .rose, primary: Palette.copper, secondary: Palette.gold, glow: Palette.copper, label: ""),
    IconDef(name: "l7-scanner", shape: .eye, primary: Palette.mercury, secondary: Palette.gold, glow: Palette.mercury, label: ""),
    IconDef(name: "l7-timemachine", shape: .ouroboros, primary: Palette.silver, secondary: Palette.gold, glow: Palette.silver, label: ""),
    IconDef(name: "l7-dbexplorer", shape: .db, primary: Palette.tin, secondary: Palette.mercury, glow: Palette.tin, label: ""),
    IconDef(name: "l7-prima", shape: .pentagram, primary: Palette.amethyst, secondary: Palette.gold, glow: Palette.amethyst, label: ""),
    IconDef(name: "l7-dodecahedron", shape: .atom, primary: Palette.azureGlow, secondary: Palette.gold, glow: Palette.azureGlow, label: ""),

    // Domains
    IconDef(name: "domain-morph", shape: .spiral, primary: Palette.amethyst, secondary: Palette.mercury, glow: Palette.amethyst, label: ""),
    IconDef(name: "domain-work", shape: .gear, primary: Palette.gold, secondary: Palette.silver, glow: Palette.gold, label: ""),
    IconDef(name: "domain-salt", shape: .diamond, primary: Palette.silver, secondary: Palette.lead, glow: Palette.silver, label: ""),
    IconDef(name: "domain-vault", shape: .shield, primary: Palette.iron, secondary: Palette.gold, glow: Palette.iron, label: ""),

    // Elements
    IconDef(name: "element-fire", shape: .triangle, primary: Palette.ember, secondary: Palette.gold, glow: Palette.ember, label: ""),
    IconDef(name: "element-water", shape: .invertTriangle, primary: Palette.azureGlow, secondary: Palette.silver, glow: Palette.azureGlow, label: ""),
    IconDef(name: "element-air", shape: .feather, primary: Palette.silver, secondary: Palette.mercury, glow: Palette.silver, label: ""),
    IconDef(name: "element-earth", shape: .square, primary: Palette.emerald, secondary: Palette.lead, glow: Palette.emerald, label: ""),

    // Planets
    IconDef(name: "planet-sun", shape: .circle, primary: Palette.gold, secondary: Palette.ember, glow: Palette.gold, label: ""),
    IconDef(name: "planet-moon", shape: .crescent, primary: Palette.silver, secondary: Palette.tin, glow: Palette.silver, label: ""),
    IconDef(name: "planet-mercury", shape: .spiral, primary: Palette.mercury, secondary: Palette.silver, glow: Palette.mercury, label: ""),
    IconDef(name: "planet-venus", shape: .cross, primary: Palette.copper, secondary: Palette.gold, glow: Palette.copper, label: ""),
    IconDef(name: "planet-mars", shape: .arrow, primary: Palette.iron, secondary: Palette.ember, glow: Palette.iron, label: ""),
    IconDef(name: "planet-jupiter", shape: .crown, primary: Palette.tin, secondary: Palette.gold, glow: Palette.tin, label: ""),
    IconDef(name: "planet-saturn", shape: .ankh, primary: Palette.lead, secondary: Palette.silver, glow: Palette.lead, label: ""),

    // Special
    IconDef(name: "tree-of-life", shape: .tree, primary: Palette.gold, secondary: Palette.emerald, glow: Palette.gold, label: ""),
    IconDef(name: "star-aspiration", shape: .star, primary: Palette.gold, secondary: Palette.silver, glow: Palette.gold, label: ""),
    IconDef(name: "essence-droplet", shape: .droplet, primary: Palette.azureGlow, secondary: Palette.mercury, glow: Palette.azureGlow, label: ""),
]

// ============================================================
// PNG Export — save as individual icon files
// ============================================================

func exportIcon(_ image: NSImage, to path: String) {
    guard let tiffData = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiffData),
          let png = bitmap.representation(using: .png, properties: [:]) else {
        print("  ERROR: Could not export \(path)")
        return
    }
    try? png.write(to: URL(fileURLWithPath: path))
}

// ============================================================
// ICNS Generation — for actual macOS app/folder icons
// ============================================================

func createICNS(from image: NSImage, at path: String) {
    // Export multiple sizes, then use iconutil
    let tmpDir = "/tmp/l7icon.iconset"
    try? FileManager.default.removeItem(atPath: tmpDir)
    try? FileManager.default.createDirectory(atPath: tmpDir, withIntermediateDirectories: true)

    let sizes: [(name: String, size: CGFloat)] = [
        ("icon_16x16", 16), ("icon_16x16@2x", 32),
        ("icon_32x32", 32), ("icon_32x32@2x", 64),
        ("icon_128x128", 128), ("icon_128x128@2x", 256),
        ("icon_256x256", 256), ("icon_256x256@2x", 512),
        ("icon_512x512", 512), ("icon_512x512@2x", 1024),
    ]

    for (name, sz) in sizes {
        let resized = NSImage(size: NSSize(width: sz, height: sz))
        resized.lockFocus()
        image.draw(in: NSRect(x: 0, y: 0, width: sz, height: sz))
        resized.unlockFocus()
        exportIcon(resized, to: "\(tmpDir)/\(name).png")
    }

    // Use iconutil to create .icns
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
    task.arguments = ["-c", "icns", "-o", path, tmpDir]
    try? task.run()
    task.waitUntilExit()

    try? FileManager.default.removeItem(atPath: tmpDir)
}

// ============================================================
// Main — Forge all icons
// ============================================================

let outputDir = NSString(string: "~/.l7/icons").expandingTildeInPath
try? FileManager.default.createDirectory(atPath: outputDir, withIntermediateDirectories: true)

let renderer = IconRenderer(size: 512)
print("L7 ICON FORGE — Generating \(iconSet.count) alchemical icons...")

for def in iconSet {
    let image = renderer.render(def)
    let pngPath = "\(outputDir)/\(def.name).png"
    let icnsPath = "\(outputDir)/\(def.name).icns"
    exportIcon(image, to: pngPath)
    createICNS(from: image, at: icnsPath)
    print("  Forged: \(def.name)")
}

print("\nAll icons forged at: \(outputDir)")
print("PNG (512x512) + ICNS (multi-resolution) for each symbol")
