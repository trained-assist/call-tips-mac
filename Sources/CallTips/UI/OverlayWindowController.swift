import AppKit
import SwiftUI

// Manages the floating overlay NSWindow shown during a call.
@MainActor
final class OverlayWindowController {
    private var window: NSWindow?

    func show(session: CallSession, onKeywordSubmit: @escaping (String) -> Void, onStop: @escaping () -> Void) {
        guard window == nil else { return }

        let w = NSWindow(
            contentRect: .zero,
            styleMask: [.titled, .resizable, .fullSizeContentView, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        w.titlebarAppearsTransparent = true
        w.titleVisibility = .hidden
        w.title = ""
        w.level = .floating
        w.isOpaque = false
        w.backgroundColor = .clear
        w.hasShadow = false
        w.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        w.isMovableByWindowBackground = true
        w.minSize = NSSize(width: 300, height: 180)

        // Initial size: 380px wide, ~80% of screen height
        let width: CGFloat = 380
        if let screen = NSScreen.main {
            let height = (screen.visibleFrame.height * 0.8).rounded()
            let sx = (screen.visibleFrame.midX - width / 2).rounded()
            let sy = (screen.visibleFrame.maxY - height - 8).rounded()
            w.setFrame(NSRect(x: sx, y: sy, width: width, height: height), display: false)
        } else {
            w.setContentSize(NSSize(width: width, height: 600))
        }

        w.contentView = NSHostingView(rootView:
            OverlayView(session: session, onKeywordSubmit: onKeywordSubmit, onStop: onStop)
        )

        w.orderFrontRegardless()
        window = w
    }

    func close() {
        // Explicitly remove SwiftUI hosting view before closing to prevent
        // EXC_BAD_ACCESS in objc_release during autorelease pool drain.
        window?.contentView = nil
        window?.close()
        window = nil
    }
}
