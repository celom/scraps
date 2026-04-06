import AppKit
import SwiftData
import SwiftUI

@MainActor
@Observable
final class WindowManager {
    private var panels: [PersistentIdentifier: NotePanel] = [:]
    private var observers: [PersistentIdentifier: [any NSObjectProtocol]] = [:]
    private let noteManager: NoteManager

    init(noteManager: NoteManager) {
        self.noteManager = noteManager
    }

    func restorePreviouslyOpenNotes() {
        let openNotes = noteManager.notes.filter { $0.isWindowOpen && !$0.isMainNote }
        for note in openNotes {
            openNote(note)
        }
    }

    func openNote(_ note: Note) {
        if let existing = panels[note.persistentModelID] {
            existing.makeKeyAndOrderFront(nil)
            return
        }

        let panel = NotePanel(note: note, noteManager: noteManager, windowManager: self)
        let noteID = note.persistentModelID
        panels[noteID] = panel

        let closeObserver = NotificationCenter.default.addObserver(
            forName: NSWindow.willCloseNotification,
            object: panel,
            queue: .main
        ) { [weak self] notification in
            guard let panel = notification.object as? NotePanel else { return }
            MainActor.assumeIsolated {
                self?.panelDidClose(panel, noteID: noteID)
            }
        }

        let moveObserver = NotificationCenter.default.addObserver(
            forName: NSWindow.didMoveNotification,
            object: panel,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.savePosition(for: noteID, frame: panel.frame)
            }
        }

        observers[noteID] = [closeObserver, moveObserver]

        note.isWindowOpen = true
        noteManager.save()
        NSApp.activate()
        panel.makeKeyAndOrderFront(nil)
        panel.focusEditor()
    }

    func closeNote(_ note: Note) {
        panels[note.persistentModelID]?.close()
    }

    func confirmDeleteNote(_ note: Note) {
        let alert = NSAlert()
        alert.messageText = "Delete \"\(note.displayTitle)\"?"
        alert.informativeText = "This cannot be undone."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Delete")
        alert.addButton(withTitle: "Cancel")

        if alert.runModal() == .alertFirstButtonReturn {
            closeNote(note)
            noteManager.deleteNote(note)
        }
    }

    func isOpen(_ note: Note) -> Bool {
        panels[note.persistentModelID] != nil
    }

    func updateWindowLevel(for note: Note) {
        guard let panel = panels[note.persistentModelID] else { return }
        panel.isFloatingPanel = !note.isPinned
        panel.level = note.isPinned ? .normal : .floating
    }

    private func savePosition(for noteID: PersistentIdentifier, frame: NSRect) {
        guard let note = noteManager.notes.first(where: { $0.persistentModelID == noteID }) else { return }
        note.positionX = frame.origin.x
        note.positionY = frame.origin.y
        note.hasCustomPosition = true
        noteManager.save()
    }

    private func panelDidClose(_ panel: NotePanel, noteID: PersistentIdentifier) {
        if let note = noteManager.notes.first(where: { $0.persistentModelID == noteID }) {
            note.positionX = panel.frame.origin.x
            note.positionY = panel.frame.origin.y
            note.hasCustomPosition = true
            note.isWindowOpen = false
            noteManager.save()
        }
        removeObservers(for: noteID)
        panels.removeValue(forKey: noteID)
    }

    private func removeObservers(for noteID: PersistentIdentifier) {
        if let noteObservers = observers.removeValue(forKey: noteID) {
            for observer in noteObservers {
                NotificationCenter.default.removeObserver(observer)
            }
        }
    }
}
