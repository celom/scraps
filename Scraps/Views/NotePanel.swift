import AppKit
import SwiftUI

final class NotePanel: NSPanel {
    init(note: Note, noteManager: NoteManager, windowManager: WindowManager) {
        super.init(
            contentRect: NSRect(x: note.positionX, y: note.positionY, width: 300, height: 200),
            styleMask: [.borderless, .resizable, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        isFloatingPanel = !note.isPinned
        level = note.isPinned ? .normal : .floating
        isMovableByWindowBackground = true
        isOpaque = false
        backgroundColor = .clear
        hasShadow = true

        let hostingView = NSHostingView(
            rootView: NoteEditorView(
                note: note,
                onSave: { noteManager.save() },
                onPinToggle: { windowManager.updateWindowLevel(for: note) },
                showPinButton: true,
                floatingToolbar: true
            )
            .frame(minWidth: 200, minHeight: 100)
        )
        contentView = hostingView

        if note.hasCustomPosition {
            setFrameOrigin(NSPoint(x: note.positionX, y: note.positionY))
        } else {
            center()
        }
    }

    override var canBecomeKey: Bool { true }
}
