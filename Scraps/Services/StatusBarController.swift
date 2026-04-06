import AppKit
import ServiceManagement
import SwiftUI

@MainActor
final class StatusBarController {
    private let statusItem: NSStatusItem
    private let popover: NSPopover
    private let noteManager: NoteManager
    private let windowManager: WindowManager
    private var eventMonitor: Any?

    init(noteManager: NoteManager, windowManager: WindowManager) {
        self.noteManager = noteManager
        self.windowManager = windowManager

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        popover = NSPopover()
        popover.behavior = .transient
        popover.contentSize = NSSize(width: 320, height: 300)
        popover.contentViewController = NSHostingController(
            rootView: MenuBarView()
                .environment(noteManager)
                .environment(windowManager)
        )

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "brain.head.profile", accessibilityDescription: "Scraps")
            button.action = #selector(handleClick(_:))
            button.target = self
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    }

    @objc private func handleClick(_ sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else { return }

        if event.type == .rightMouseUp {
            showMenu()
        } else {
            togglePopover()
        }
    }

    func togglePopover() {
        if popover.isShown {
            popover.performClose(nil)
        } else if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }

    private func showMenu() {
        let menu = NSMenu()

        noteManager.loadNotes()
        let nonMainNotes = noteManager.notes.filter { !$0.isMainNote }

        if !nonMainNotes.isEmpty {
            for note in nonMainNotes {
                let title = note.displayTitle
                let item = NSMenuItem(title: title, action: #selector(openNoteFromMenu(_:)), keyEquivalent: "")
                item.target = self
                item.representedObject = note
                if windowManager.isOpen(note) {
                    item.state = .on
                }

                let submenu = NSMenu()
                let openItem = NSMenuItem(title: "Open", action: #selector(openNoteFromMenu(_:)), keyEquivalent: "")
                openItem.target = self
                openItem.representedObject = note
                submenu.addItem(openItem)

                submenu.addItem(.separator())

                let deleteItem = NSMenuItem(title: "Delete…", action: #selector(deleteNoteFromMenu(_:)), keyEquivalent: "")
                deleteItem.target = self
                deleteItem.representedObject = note
                submenu.addItem(deleteItem)

                item.submenu = submenu
                menu.addItem(item)
            }
            menu.addItem(.separator())
        }

        let newItem = NSMenuItem(title: "New Note", action: #selector(createNewNote), keyEquivalent: "n")
        newItem.target = self
        menu.addItem(newItem)

        menu.addItem(.separator())

        let launchItem = NSMenuItem(title: "Launch at Login", action: #selector(toggleLaunchAtLogin(_:)), keyEquivalent: "")
        launchItem.target = self
        launchItem.state = SMAppService.mainApp.status == .enabled ? .on : .off
        menu.addItem(launchItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "Quit Scraps", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil // Reset so left-click works again
    }

    @objc private func openNoteFromMenu(_ sender: NSMenuItem) {
        guard let note = sender.representedObject as? Note else { return }
        windowManager.openNote(note)
    }

    @objc private func createNewNote() {
        let note = noteManager.createNote()
        windowManager.openNote(note)
    }

    @objc private func deleteNoteFromMenu(_ sender: NSMenuItem) {
        guard let note = sender.representedObject as? Note else { return }

        let alert = NSAlert()
        alert.messageText = "Delete \"\(note.displayTitle)\"?"
        alert.informativeText = "This cannot be undone."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Delete")
        alert.addButton(withTitle: "Cancel")

        if alert.runModal() == .alertFirstButtonReturn {
            windowManager.closeNote(note)
            noteManager.deleteNote(note)
        }
    }

    @objc private func toggleLaunchAtLogin(_ sender: NSMenuItem) {
        do {
            if SMAppService.mainApp.status == .enabled {
                try SMAppService.mainApp.unregister()
            } else {
                try SMAppService.mainApp.register()
            }
        } catch {
            NSLog("Failed to toggle launch at login: \(error)")
        }
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
}
