import SwiftUI

struct NoteEditorView: View {
    @Bindable var note: Note
    var onSave: () -> Void = {}

    var body: some View {
        TextEditor(text: $note.content)
            .font(.system(size: note.fontSize))
            .scrollContentBackground(.hidden)
            .padding(8)
            .onChange(of: note.content) {
                note.updatedAt = .now
                onSave()
            }
    }
}
