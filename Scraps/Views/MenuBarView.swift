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

            }
            .frame(minWidth: 320, maxWidth: 320, minHeight: 240, maxHeight: 420)
        }
    }
}
