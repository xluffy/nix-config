import AppKit

enum MenuBarIcon {
    // A monochrome template icon for the menu bar, drawn at 18x18 points.
    // This matches the standard menu bar height used by BetterDisplay and Clocker.
    static let image: NSImage = {
        let image = NSImage(size: NSSize(width: 18, height: 18), flipped: false) { _ in
            let center = NSPoint(x: 9, y: 9)
            let radius: CGFloat = 7.1
            let lineWidth: CGFloat = 2.6

            let track = NSBezierPath()
            track.appendArc(withCenter: center, radius: radius, startAngle: 0, endAngle: 360)
            track.lineWidth = lineWidth
            NSColor.black.withAlphaComponent(0.32).setStroke()
            track.stroke()

            let progress = NSBezierPath()
            progress.appendArc(withCenter: center, radius: radius, startAngle: 90, endAngle: -162, clockwise: true)
            progress.lineWidth = lineWidth
            progress.lineCapStyle = .round
            NSColor.black.setStroke()
            progress.stroke()

            let dot = NSBezierPath(ovalIn: NSRect(x: center.x - 1.8, y: center.y - 1.8, width: 3.6, height: 3.6))
            NSColor.black.setFill()
            dot.fill()

            return true
        }
        image.isTemplate = true
        return image
    }()
}
