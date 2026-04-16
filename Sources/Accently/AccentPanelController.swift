import AppKit
import SwiftUI

@MainActor
final class AccentPanelController {
    private let panel: NSPanel
    private let hostingController: NSHostingController<AccentPickerView>
    private var activeSession: AccentSession?

    init() {
        let placeholder = AccentSession(baseLetter: "e", options: ["é", "è", "ê", "ë"])
        hostingController = NSHostingController(rootView: AccentPickerView(session: placeholder))

        panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 320, height: 92),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        panel.isReleasedWhenClosed = false
        panel.hasShadow = false
        panel.level = .statusBar
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .transient, .ignoresCycle]
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hidesOnDeactivate = false
        panel.ignoresMouseEvents = true
        panel.contentViewController = hostingController
    }

    func show(session: AccentSession, mode: PickerPositionMode) {
        activeSession = session
        hostingController.rootView = AccentPickerView(session: session)
        updateFrame(for: session, mode: mode)
        panel.orderFrontRegardless()
    }

    func reposition(mode: PickerPositionMode) {
        guard let activeSession else {
            return
        }

        updateFrame(for: activeSession, mode: mode)
    }

    func hide() {
        activeSession = nil
        panel.orderOut(nil)
    }

    private func updateFrame(for session: AccentSession, mode: PickerPositionMode) {
        let size = panelSize(for: session)
        let origin = origin(for: size, mode: mode)
        panel.setFrame(NSRect(origin: origin, size: size), display: true)
    }

    private func panelSize(for session: AccentSession) -> CGSize {
        let itemWidth = CGFloat(session.options.count) * 56
        let width = max(200, itemWidth + 36)
        return CGSize(width: min(440, width), height: 102)
    }

    private func origin(for size: CGSize, mode: PickerPositionMode) -> CGPoint {
        switch mode {
        case .centerScreen:
            guard let screen = NSScreen.main else {
                return CGPoint(x: 240, y: 240)
            }

            let frame = screen.visibleFrame
            return CGPoint(
                x: frame.midX - (size.width / 2),
                y: frame.midY - (size.height / 2)
            )

        case .nearMouse:
            let pointer = NSEvent.mouseLocation
            return clampedOrigin(near: CGPoint(x: pointer.x, y: pointer.y + 18), size: size)
        }
    }

    private func clampedOrigin(near anchor: CGPoint, size: CGSize) -> CGPoint {
        let screen = NSScreen.screens.first(where: { NSMouseInRect(anchor, $0.frame, false) }) ?? NSScreen.main
        let frame = screen?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1280, height: 800)

        let proposedX = anchor.x - (size.width / 2)
        let proposedY = anchor.y

        let minX = frame.minX + 12
        let maxX = frame.maxX - size.width - 12
        let minY = frame.minY + 12
        let maxY = frame.maxY - size.height - 12

        return CGPoint(
            x: min(max(proposedX, minX), maxX),
            y: min(max(proposedY, minY), maxY)
        )
    }
}
