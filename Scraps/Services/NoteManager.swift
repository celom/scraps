import Foundation
import SwiftData
import SwiftUI
import os

@MainActor
@Observable
final class NoteManager {
    private let modelContext: ModelContext
    private static let logger = Logger(subsystem: "com.celom.scraps", category: "NoteManager")

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
        do {
            notes = try modelContext.fetch(descriptor)
        } catch {
            Self.logger.error("Failed to fetch notes: \(error)")
            notes = []
        }
    }

    func ensureMainNote() {
        if let existing = notes.first(where: { $0.isMainNote }) {
            mainNote = existing
        } else {
            let note = Note(isMainNote: true)
            modelContext.insert(note)
            persistOrLog("create main note")
            mainNote = note
            loadNotes()
        }
    }

    func createNote(content: String = "") -> Note {
        let note = Note(content: content)
        modelContext.insert(note)
        persistOrLog("create note")
        loadNotes()
        return note
    }

    func deleteNote(_ note: Note) {
        modelContext.delete(note)
        persistOrLog("delete note")
        loadNotes()
    }

    func save() {
        persistOrLog("save")
    }

    private func persistOrLog(_ operation: String) {
        do {
            try modelContext.save()
        } catch {
            Self.logger.error("Failed to \(operation): \(error)")
        }
    }
}
