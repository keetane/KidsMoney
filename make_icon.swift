import AppKit

let size = NSSize(width: 1024, height: 1024)
let image = NSImage(size: size)

func drawCenteredText(_ text: String, in rect: NSRect, font: NSFont, color: NSColor, kern: Double = 0) {
    let style = NSMutableParagraphStyle()
    style.alignment = .center
    let attrs: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: color,
        .paragraphStyle: style,
        .kern: kern
    ]
    let textSize = text.size(withAttributes: attrs)
    let textRect = NSRect(x: rect.midX - textSize.width / 2, y: rect.midY - textSize.height / 2, width: textSize.width, height: textSize.height)
    text.draw(in: textRect, withAttributes: attrs)
}

image.lockFocus()
let canvas = NSRect(origin: .zero, size: size)

NSColor(calibratedRed: 0.08, green: 0.10, blue: 0.14, alpha: 1.0).setFill()
canvas.fill()

let coinRect = NSRect(x: 80, y: 80, width: 864, height: 864)
let coinPath = NSBezierPath(ovalIn: coinRect)
let metal = NSGradient(colors: [
    NSColor(calibratedWhite: 0.97, alpha: 1),
    NSColor(calibratedWhite: 0.78, alpha: 1),
    NSColor(calibratedWhite: 0.93, alpha: 1)
])!
metal.draw(in: coinPath, angle: -50)

let innerRect = coinRect.insetBy(dx: 70, dy: 70)
let innerPath = NSBezierPath(ovalIn: innerRect)
let innerGrad = NSGradient(colors: [
    NSColor(calibratedWhite: 0.92, alpha: 1),
    NSColor(calibratedWhite: 0.70, alpha: 1)
])!
innerGrad.draw(in: innerPath, angle: -20)

NSColor.white.withAlphaComponent(0.45).setStroke()
let rim = NSBezierPath(ovalIn: coinRect.insetBy(dx: 12, dy: 12))
rim.lineWidth = 10
rim.stroke()

NSColor(calibratedWhite: 0.25, alpha: 0.28).setStroke()
let engraveRing = NSBezierPath(ovalIn: innerRect.insetBy(dx: 26, dy: 26))
engraveRing.lineWidth = 6
engraveRing.stroke()

let shine = NSBezierPath(ovalIn: NSRect(x: 180, y: 650, width: 560, height: 220))
NSColor.white.withAlphaComponent(0.15).setFill()
shine.fill()

drawCenteredText("100", in: NSRect(x: 0, y: 430, width: 1024, height: 230), font: NSFont.systemFont(ofSize: 300, weight: .black), color: NSColor(calibratedWhite: 0.18, alpha: 1), kern: 2.2)
drawCenteredText("円", in: NSRect(x: 0, y: 300, width: 1024, height: 130), font: NSFont.systemFont(ofSize: 128, weight: .bold), color: NSColor(calibratedWhite: 0.22, alpha: 1))

drawCenteredText("JAPAN", in: NSRect(x: 0, y: 210, width: 1024, height: 70), font: NSFont.systemFont(ofSize: 44, weight: .semibold), color: NSColor(calibratedWhite: 0.30, alpha: 1), kern: 3.2)

image.unlockFocus()

let rep = NSBitmapImageRep(data: image.tiffRepresentation!)!
let pngData = rep.representation(using: .png, properties: [:])!
let outputURL = URL(fileURLWithPath: "/Users/keetane/Documents/apps/allowance/Allowance/Resources/Assets.xcassets/AppIcon.appiconset/icon-1024.png")
try pngData.write(to: outputURL)
print("wrote", outputURL.path)
