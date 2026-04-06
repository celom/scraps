import AppKit
import SwiftData
import SwiftUI

@MainActor
@Observable
final class WindowManager {
    private var panels: [PersistentIdentifier: NotePanel] = [:]
    private let noteManager: NoteManager

    init(noteManager: NoteManager) {
        self.noteManager = noteManager
    }

    func openNote(_ note: Note) {
        if let existing = panels[note.persistentModelID] {
            existing.makeKeyAndOrderFront(nil)
            return
        }

        let panel = NotePanel(note: note, noteManager: noteManager)
        let noteID = note.persistentModelID
        panels[noteID] = panel

        NotificationCenter.default.addObserver(
            forName: NSWindow.willCloseNotification,
            object: panel,
            queue: .main
        ) { [weak self] notification in
            guard let panel = notification.object as? NotePanel else { return }
            MainActor.assumeIsolated {
                self?.panelDidClose(panel, noteID: noteID)
            }
        }

        NotificationCenter.default.addObserver(
            forName: NSWindow.didMoveNotification,
            object: panel,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.savePosition(for: noteID, frame: panel.frame)
            }
        }

        note.isWindowOpen = true
        noteManager.save()
        panel.makeKeyAndOrderFront(nil)
    }

    func closeNote(_ note: Note) {
        panels[note.persistentModelID]?.close()
    }

    func isOpen(_ note: Note) -> Bool {
        panels[note.persistentModelID] != nil
    }

    private func savePosition(for noteID: PersistentIdentifier, frame: NSRect) {
        guard let note = noteManager.notes.first(where: { $0.persistentModelID == noteID }) else { return }
        note.positionX = frame.origin.x
        note.positionY = frame.origin.y
        noteManager.save()
    }

    private func panelDidClose(_ panel: NotePanel, noteID: PersistentIdentifier) {
        if let note = noteManager.notes.first(where: { $0.persistentModelID == noteID }) {
            note.positionX = panel.frame.origin.x
            note.positionY = panel.frame.origin.y
            note.isWindowOpen = false
            noteManager.save()
        }
        panels.removeValue(forKey: noteID)
    }
}
