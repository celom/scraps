import SwiftUI

struct MenuBarView: View {
    @Environment(NoteManager.self) private var noteManager
    @Environment(WindowManager.self) private var windowManager

    var body: some View {
        if let mainNote = noteManager.mainNote {
            VStack(spacing: 0) {
                NoteEditorView(note: mainNote) {
                    noteManager.save()
                }

                Divider()

                HStack {
                    Button("New Note") {
                        let note = noteManager.createNote()
                        windowManager.openNote(note)
                    }
                    .buttonStyle(.plain)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)

                    Spacer()

                    Text("\(noteManager.notes.count - 1) notes")
                        .font(.system(size: 10))
                        .foregroundStyle(.tertiary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
            }
            .frame(minWidth: 320, maxWidth: 320, minHeight: 240, maxHeight: 420)
        }
    }
}
