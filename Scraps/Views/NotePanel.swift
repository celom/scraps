import AppKit
import SwiftUI

final class NotePanel: NSPanel {
    init(note: Note, noteManager: NoteManager, windowManager: WindowManager) {
        super.init(
            contentRect: NSRect(x: note.positionX, y: note.positionY, width: 300, height: 200),
            styleMask: [.titled, .closable, .resizable, .fullSizeContentView, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        isFloatingPanel = true
        level = note.isPinned
            ? NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopWindow)) + 1)
            : .floating
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        isMovableByWindowBackground = true
        isOpaque = false
        backgroundColor = .clear
        hasShadow = true
        hidesOnDeactivate = false
        acceptsMouseMovedEvents = true
        collectionBehavior = [.canJoinAllSpaces, .stationary]

        let hostingView = NSHostingView(
            rootView: NoteEditorView(
                note: note,
                onSave: { noteManager.save() },
                onPinToggle: { windowManager.updateWindowLevel(for: note) },
                showPinButton: true
            )
            .frame(minWidth: 200, minHeight: 100)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        )
        contentView = hostingView

        if note.positionX != 0 || note.positionY != 0 {
            setFrameOrigin(NSPoint(x: note.positionX, y: note.positionY))
        } else {
            center()
        }
    }

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }

    override func sendEvent(_ event: NSEvent) {
        // Ensure clicks on the panel activate it even at desktop level
        if event.type == .leftMouseDown {
            makeKey()
        }
        super.sendEvent(event)
    }
}
