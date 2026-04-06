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
                let item = NSMenuItem(title: "", action: #selector(toggleNoteFromMenu(_:)), keyEquivalent: "")
                item.target = self
                item.representedObject = note

                let itemView = NoteMenuItemView(
                    title: note.displayTitle,
                    isOpen: windowManager.isOpen(note),
                    onToggle: { [weak self] in
                        self?.toggleNote(note)
                    },
                    onDelete: { [weak self] in
                        self?.confirmDeleteNote(note)
                    }
                )
                item.view = itemView
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

    @objc private func toggleNoteFromMenu(_ sender: NSMenuItem) {
        guard let note = sender.representedObject as? Note else { return }
        toggleNote(note)
    }

    private func toggleNote(_ note: Note) {
        if windowManager.isOpen(note) {
            windowManager.closeNote(note)
        } else {
            windowManager.openNote(note)
        }
        statusItem.menu?.cancelTracking()
    }

    @objc private func createNewNote() {
        let note = noteManager.createNote()
        windowManager.openNote(note)
    }

    private func confirmDeleteNote(_ note: Note) {
        statusItem.menu?.cancelTracking()
        windowManager.confirmDeleteNote(note)
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

// MARK: - Custom Menu Item View

private final class NoteMenuItemView: NSView {
    private let onToggle: () -> Void
    private let onDelete: () -> Void
    private let titleLabel: NSTextField
    private let iconView: NSImageView
    private let deleteButton: NSButton
    private var isHighlighted = false {
        didSet { needsDisplay = true; updateColors() }
    }

    init(title: String, isOpen: Bool, onToggle: @escaping () -> Void, onDelete: @escaping () -> Void) {
        self.onToggle = onToggle
        self.onDelete = onDelete

        let iconName = isOpen ? "checkmark" : "note.text"
        let icon = NSImage(systemSymbolName: iconName, accessibilityDescription: nil)!
        let iconImage = NSImageView(image: icon)
        iconImage.imageScaling = .scaleProportionallyDown
        iconImage.contentTintColor = .secondaryLabelColor
        iconImage.setContentHuggingPriority(.required, for: .horizontal)
        iconImage.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.iconView = iconImage

        titleLabel = NSTextField(labelWithString: title)
        titleLabel.font = .menuFont(ofSize: 13)
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.maximumNumberOfLines = 1
        titleLabel.cell?.truncatesLastVisibleLine = true

        deleteButton = NSButton(image: NSImage(systemSymbolName: "trash", accessibilityDescription: "Delete")!, target: nil, action: nil)
        deleteButton.bezelStyle = .inline
        deleteButton.isBordered = false
        deleteButton.imagePosition = .imageOnly
        deleteButton.contentTintColor = .secondaryLabelColor
        (deleteButton.cell as? NSButtonCell)?.highlightsBy = .contentsCellMask

        super.init(frame: NSRect(x: 0, y: 0, width: 250, height: 22))

        let trackingArea = NSTrackingArea(rect: .zero, options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect], owner: self, userInfo: nil)
        addTrackingArea(trackingArea)

        deleteButton.target = self
        deleteButton.action = #selector(deleteTapped)
        deleteButton.isHidden = true

        addSubview(iconView)
        addSubview(titleLabel)
        addSubview(deleteButton)

        iconView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        NSLayoutConstraint.activate([
            widthAnchor.constraint(lessThanOrEqualToConstant: 250),

            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 14),
            iconView.heightAnchor.constraint(equalToConstant: 14),

            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 4),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: deleteButton.leadingAnchor, constant: -4),

            deleteButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            deleteButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            deleteButton.widthAnchor.constraint(equalToConstant: 20),
            deleteButton.heightAnchor.constraint(equalToConstant: 20),

            heightAnchor.constraint(equalToConstant: 22),
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    private func updateColors() {
        let color: NSColor = isHighlighted ? .white : .labelColor
        titleLabel.textColor = color
        iconView.contentTintColor = isHighlighted ? .white : .secondaryLabelColor
        deleteButton.contentTintColor = isHighlighted ? .white : .secondaryLabelColor
    }

    override func draw(_ dirtyRect: NSRect) {
        if isHighlighted {
            NSColor.controlAccentColor.setFill()
            let path = NSBezierPath(roundedRect: bounds.insetBy(dx: 4, dy: 1), xRadius: 4, yRadius: 4)
            path.fill()
        }
        super.draw(dirtyRect)
    }

    override func mouseEntered(with event: NSEvent) {
        isHighlighted = true
        deleteButton.isHidden = false
    }

    override func mouseExited(with event: NSEvent) {
        isHighlighted = false
        deleteButton.isHidden = true
    }

    override func mouseUp(with event: NSEvent) {
        let loc = convert(event.locationInWindow, from: nil)
        if deleteButton.frame.contains(loc) { return }
        onToggle()
    }

    @objc private func deleteTapped() {
        onDelete()
    }
}
