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
                onClose: { [weak self] in self?.close() },
                onDelete: { windowManager.confirmDeleteNote(note) },
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

    func focusEditor() {
        DispatchQueue.main.async { [weak self] in
            guard let self, let contentView = self.contentView else { return }
            self.makeFirstResponder(self.findTextView(in: contentView) ?? contentView)
        }
    }

    private func findTextView(in view: NSView) -> NSView? {
        if view is NSTextView { return view }
        for subview in view.subviews {
            if let found = findTextView(in: subview) { return found }
        }
        return nil
    }
}
