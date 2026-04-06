import SwiftUI
import SwiftData

@main
struct ScrapsApp: App {
    var body: some Scene {
        MenuBarExtra("Scraps", systemImage: "note.text") {
            Text("Scraps")
        }
        .modelContainer(for: Note.self)
    }
}
