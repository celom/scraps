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
    private var hotkeyService: HotkeyService?
    private var modelContainer: ModelContainer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        let container: ModelContainer
        do {
            container = try ModelContainer(for: Note.self)
        } catch {
            let alert = NSAlert()
            alert.messageText = "Scraps failed to start"
            alert.informativeText = "Could not open the data store: \(error.localizedDescription)"
            alert.alertStyle = .critical
            alert.runModal()
            NSApp.terminate(nil)
            return
        }
        self.modelContainer = container
        let noteManager = NoteManager(modelContext: container.mainContext)
        let windowManager = WindowManager(noteManager: noteManager)
        let sbc = StatusBarController(noteManager: noteManager, windowManager: windowManager)
        statusBarController = sbc

        windowManager.restorePreviouslyOpenNotes()

        hotkeyService = HotkeyService(
            onNewNote: {
                let note = noteManager.createNote()
                windowManager.openNote(note)
            },
            onToggleMain: {
                sbc.togglePopover()
            }
        )
    }
}
