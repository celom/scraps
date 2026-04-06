import Foundation
import SwiftData
import SwiftUI

@MainActor
@Observable
final class NoteManager {
    private let modelContext: ModelContext

    private(set) var mainNote: Note?
    private(set) var notes: [Note] = []

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadNotes()
        ensureMainNote()
    }

    func loadNotes() {
        let descriptor = FetchDescriptor<Note>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        notes = (try? modelContext.fetch(descriptor)) ?? []
    }

    func ensureMainNote() {
        if let existing = notes.first(where: { $0.isMainNote }) {
            mainNote = existing
        } else {
            let note = Note(isMainNote: true)
            modelContext.insert(note)
            try? modelContext.save()
            mainNote = note
            loadNotes()
        }
    }

    func createNote(content: String = "") -> Note {
        let note = Note(content: content)
        modelContext.insert(note)
        try? modelContext.save()
        loadNotes()
        return note
    }

    func save() {
        try? modelContext.save()
    }
}
