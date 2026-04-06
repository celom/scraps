import Testing
import Foundation
@testable import Scraps

@Suite("Note Model")
struct NoteModelTests {

    @Test("Default note has expected initial values")
    func defaultInit() {
        let note = Note()
        #expect(note.content == "")
        #expect(note.isPinned == false)
        #expect(note.isMarkdownPreview == false)
        #expect(note.isMainNote == false)
        #expect(note.isWindowOpen == false)
        #expect(note.fontSize == 14)
        #expect(note.positionX == 0)
        #expect(note.positionY == 0)
    }

    @Test("Main note flag is set correctly")
    func mainNoteInit() {
        let note = Note(isMainNote: true)
        #expect(note.isMainNote == true)
    }

    @Test("displayTitle returns first non-empty line")
    func displayTitleFirstLine() {
        let note = Note(content: "Shopping List\nMilk\nEggs")
        #expect(note.displayTitle == "Shopping List")
    }

    @Test("displayTitle skips leading empty lines")
    func displayTitleSkipsEmpty() {
        let note = Note(content: "\n\nActual Title\nBody")
        #expect(note.displayTitle == "Actual Title")
    }

    @Test("displayTitle returns Untitled for empty content")
    func displayTitleEmpty() {
        let note = Note()
        #expect(note.displayTitle == "Untitled")
    }

    @Test("displayTitle returns Untitled for whitespace-only lines")
    func displayTitleWhitespaceOnly() {
        let note = Note(content: "\n\n\n")
        #expect(note.displayTitle == "Untitled")
    }

    @Test("Content can be updated")
    func updateContent() {
        let note = Note(content: "Initial")
        note.content = "Updated"
        #expect(note.content == "Updated")
        #expect(note.displayTitle == "Updated")
    }
}
