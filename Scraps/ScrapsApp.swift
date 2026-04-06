import SwiftUI
import SwiftData

@main
struct ScrapsApp: App {
    private let modelContainer: ModelContainer
    @State private var noteManager: NoteManager

    init() {
        let container = try! ModelContainer(for: Note.self)
        self.modelContainer = container
        self._noteManager = State(initialValue: NoteManager(modelContext: container.mainContext))
    }

    var body: some Scene {
        MenuBarExtra("Scraps", systemImage: "note.text") {
            MenuBarView()
                .environment(noteManager)
        }
        .menuBarExtraStyle(.window)
        .modelContainer(modelContainer)
    }
}
