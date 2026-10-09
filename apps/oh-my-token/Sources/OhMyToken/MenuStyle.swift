import AppKit
import SwiftUI

struct MenuMaterial: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = BackdropView()
        view.material = .popover
        view.blendingMode = .behindWindow
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}

    private final class BackdropView: NSVisualEffectView {
        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            window?.isOpaque = false
            window?.backgroundColor = .clear
        }
    }
}

struct HoverSurface: ViewModifier {
    var cornerRadius: CGFloat = 8
    var restingOpacity: Double = 0
    var isPressed = false
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isHovered = false

    func body(content: Content) -> some View {
        let highlighted = (isHovered || isPressed) && isEnabled
        let fill = isPressed ? 0.16 : highlighted ? 0.09 : restingOpacity
        let border = isPressed ? 0.22 : highlighted ? 0.16 : restingOpacity > 0 ? 0.10 : 0
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        content
            .background(shape.fill(Color.primary.opacity(fill)))
            .overlay(shape.strokeBorder(Color.primary.opacity(border), lineWidth: 0.5))
            .animation(reduceMotion ? nil : .easeOut(duration: 0.12), value: highlighted)
            .onHover { isHovered = $0 }
    }
}

struct MenuActionStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.caption)
            .padding(.horizontal, 9)
            .padding(.vertical, 7)
            .frame(maxWidth: .infinity)
            .modifier(HoverSurface(cornerRadius: 7, restingOpacity: 0.06, isPressed: configuration.isPressed))
            .opacity(isEnabled ? 1 : 0.4)
    }
}
