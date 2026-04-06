import AppKit
import SwiftUI

final class NotePanel: NSPanel {
    init(note: Note, noteManager: NoteManager) {
        super.init(
            contentRect: NSRect(x: note.positionX, y: note.positionY, width: 300, height: 200),
            styleMask: [.titled, .closable, .resizable, .nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        isFloatingPanel = true
        level = .floating
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        isMovableByWindowBackground = true
        isOpaque = false
        backgroundColor = .clear
        hasShadow = true

        let hostingView = NSHostingView(
            rootView: NoteEditorView(note: note) {
                noteManager.save()
            }
            .frame(minWidth: 200, minHeight: 100)
            .background(.ultraThinMaterial)
        )
        contentView = hostingView

        if note.positionX != 0 || note.positionY != 0 {
            setFrameOrigin(NSPoint(x: note.positionX, y: note.positionY))
        } else {
            center()
        }
    }
}
