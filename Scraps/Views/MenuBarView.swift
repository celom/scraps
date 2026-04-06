import SwiftUI

struct MenuBarView: View {
    @Environment(NoteManager.self) private var noteManager

    var body: some View {
        if let mainNote = noteManager.mainNote {
            NoteEditorView(note: mainNote) {
                noteManager.save()
            }
            .frame(minWidth: 320, maxWidth: 320, minHeight: 200, maxHeight: 400)
        }
    }
}
