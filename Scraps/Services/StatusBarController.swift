import AppKit
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
            button.image = NSImage(systemSymbolName: "note.text", accessibilityDescription: "Scraps")
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
                menu.addItem(item)
            }
            menu.addItem(.separator())
        }

        let newItem = NSMenuItem(title: "New Note", action: #selector(createNewNote), keyEquivalent: "n")
        newItem.target = self
        menu.addItem(newItem)

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

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
}
