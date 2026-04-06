# Scraps

A lightweight macOS menu bar app for quick notes. Lives in your status bar, always one click away.

## Features

- **Quick scrap** — a persistent note accessible from the menu bar popover (click the status bar icon)
- **Floating note panels** — create additional notes that float as borderless, draggable panels on your desktop
- **Markdown preview** — toggle between editing and rendered markdown with `Cmd+M`
- **Pin notes** — keep note panels above other windows, or let them fall behind
- **Window state persistence** — open notes and their positions are restored on relaunch
- **Launch at login** — optional, configurable from the right-click menu

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Cmd+Shift+S` | Toggle main popover |
| `Cmd+Shift+N` | Create new note |
| `Cmd+M` | Toggle markdown preview |
| `Cmd+W` | Close current note panel |
| `Cmd+Plus` | Increase font size |
| `Cmd+Minus` | Decrease font size |
| `Cmd+0` | Reset font size |

## Context Menu

Right-click the status bar icon to access:

- **Note list** — click a note to toggle its visibility; hover to reveal a delete button
- **New Note** — create and open a new floating note
- **Launch at Login** — toggle auto-start
- **Quit Scraps**

## Building

Open `Scraps.xcodeproj` in Xcode and build the `Scraps` scheme. Requires macOS 15+.

## Architecture

```
Scraps/
├── Models/
│   └── Note.swift              # SwiftData model
├── Services/
│   ├── NoteManager.swift       # CRUD + persistence
│   ├── WindowManager.swift     # Panel lifecycle + position tracking
│   ├── StatusBarController.swift # Menu bar icon, popover, context menu
│   └── HotkeyService.swift     # Global hotkeys via Carbon events
├── Views/
│   ├── MenuBarView.swift       # Popover content (quick scrap)
│   ├── NoteEditorView.swift    # Shared editor/preview + toolbar
│   └── NotePanel.swift         # Borderless floating NSPanel
├── Utilities/
│   └── MarkdownRenderer.swift  # Markdown → AttributedString
└── ScrapsApp.swift             # App entry point + AppDelegate
```
