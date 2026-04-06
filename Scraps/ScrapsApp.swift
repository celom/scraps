import SwiftUI
import SwiftData

@main
struct ScrapsApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusBarController: StatusBarController?
    private var modelContainer: ModelContainer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        let container = try! ModelContainer(for: Note.self)
        self.modelContainer = container
        let noteManager = NoteManager(modelContext: container.mainContext)
        let windowManager = WindowManager(noteManager: noteManager)
        statusBarController = StatusBarController(noteManager: noteManager, windowManager: windowManager)
    }
}
