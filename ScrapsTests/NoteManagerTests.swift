import Testing
import Foundation
import SwiftData
@testable import Scraps

@Suite("Note Manager", .serialized)
struct NoteManagerTests {

    @MainActor
    private func makeManager() throws -> NoteManager {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Note.self, configurations: config)
        return NoteManager(modelContext: container.mainContext)
    }

    @Test("Creates main note on init")
    func ensuresMainNote() async throws {
        let manager = try await MainActor.run { try makeManager() }
        await MainActor.run {
            #expect(manager.mainNote != nil)
            #expect(manager.mainNote?.isMainNote == true)
            #expect(manager.notes.count == 1)
        }
    }

    @Test("createNote adds a new note")
    func createNote() async throws {
        let manager = try await MainActor.run { try makeManager() }
        await MainActor.run {
            let note = manager.createNote(content: "Test")
            #expect(note.content == "Test")
            #expect(note.isMainNote == false)
            #expect(manager.notes.count == 2)
        }
    }

    @Test("deleteNote removes the note")
    func deleteNote() async throws {
        let manager = try await MainActor.run { try makeManager() }
        await MainActor.run {
            let note = manager.createNote(content: "To Delete")
            #expect(manager.notes.count == 2)
            manager.deleteNote(note)
            #expect(manager.notes.count == 1)
            #expect(manager.notes.first?.isMainNote == true)
        }
    }

    @Test("loadNotes refreshes the list")
    func loadNotes() async throws {
        let manager = try await MainActor.run { try makeManager() }
        await MainActor.run {
            _ = manager.createNote(content: "A")
            _ = manager.createNote(content: "B")
            manager.loadNotes()
            #expect(manager.notes.count == 3)
        }
    }

    @Test("Main note is not duplicated on reload")
    func mainNoteNotDuplicated() async throws {
        let manager = try await MainActor.run { try makeManager() }
        await MainActor.run {
            manager.ensureMainNote()
            manager.ensureMainNote()
            let mainNotes = manager.notes.filter { $0.isMainNote }
            #expect(mainNotes.count == 1)
        }
    }
}
