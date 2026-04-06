import SwiftUI
import SwiftData

@main
struct ScrapsApp: App {
    private let modelContainer: ModelContainer
    @State private var noteManager: NoteManager
    @State private var windowManager: WindowManager

    init() {
        let container = try! ModelContainer(for: Note.self)
        self.modelContainer = container
        let nm = NoteManager(modelContext: container.mainContext)
        self._noteManager = State(initialValue: nm)
        self._windowManager = State(initialValue: WindowManager(noteManager: nm))
    }

    var body: some Scene {
        MenuBarExtra("Scraps", systemImage: "note.text") {
            MenuBarView()
                .environment(noteManager)
                .environment(windowManager)
        }
        .menuBarExtraStyle(.window)
        .modelContainer(modelContainer)
    }
}
