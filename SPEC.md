# Spec: Scraps

## Objective

Scraps is a lightweight macOS menu bar application for quick note-taking. Notes can float on top of other windows (with transparency) or pin to the desktop. The primary interface is a menu bar icon that gives access to a persistent main note and a list of all notes.

### User Stories

- As a user, I can click the menu bar icon to instantly open/close my main scratchpad note.
- As a user, I can create multiple notes that float above other applications.
- As a user, I can pin a note to the desktop so it stays behind all windows.
- As a user, I can toggle any note between plain text editing and rendered markdown preview.
- As a user, I can resize text with `⌃+` / `⌃-` and the note window auto-sizes to fit.
- As a user, I can right-click the menu bar icon to see all notes and create new ones.
- As a user, I can reposition notes and have their positions remembered across app restarts.
- As a user, I can use a global hotkey to create a new note or toggle the menu bar note.

### Success Criteria

- [ ] Menu bar icon opens/closes main note on left-click
- [ ] Right-click menu bar icon shows note list + "New Note" option
- [ ] Notes float above all windows by default (always-on-top)
- [ ] Notes can be pinned to desktop level (behind all windows)
- [ ] Notes have a glass/translucent appearance with vibrancy
- [ ] Text size adjustable via `⌃+` / `⌃-`, note auto-resizes to content
- [ ] Markdown toggle: edit mode (plain text) ↔ preview mode (rendered)
- [ ] Note positions, sizes, and text size persist across restarts
- [ ] Global hotkeys: `⌘⇧N` (new note), `⌘⇧S` (toggle main note)
- [ ] App launches at login (optional, configurable)
- [ ] Direct distribution via DMG (no App Store sandboxing initially)

## Tech Stack

- **Language:** Swift (latest)
- **UI:** SwiftUI + AppKit (NSPanel for floating windows, NSStatusItem for menu bar)
- **Minimum target:** macOS 26 (Tahoe)
- **Persistence:** SwiftData (local, no cloud sync)
- **Markdown rendering:** swift-markdown + AttributedString (basic: headings, bold, italic, links, lists, code)
- **Hotkeys:** Carbon/CGEvent global hotkey registration (or HotKey package)
- **Build:** Xcode project, Swift Package Manager for dependencies
- **Distribution:** DMG via create-dmg, notarized with Developer ID

## Commands

```
Build:    xcodebuild -scheme Scraps -configuration Release build
Test:     xcodebuild -scheme Scraps test
Run:      open build/Release/Scraps.app
Archive:  xcodebuild -scheme Scraps -archivePath build/Scraps.xcarchive archive
DMG:      create-dmg build/Release/Scraps.app build/
```

## Project Structure

```
Scraps/
├── SPEC.md
├── Scraps.xcodeproj/
├── Scraps/
│   ├── ScrapsApp.swift           → App entry point, menu bar setup
│   ├── Models/
│   │   └── Note.swift            → SwiftData model
│   ├── Views/
│   │   ├── NoteWindow.swift      → Floating/pinned note window (NSPanel wrapper)
│   │   ├── NoteEditorView.swift  → Text editor with markdown toggle
│   │   ├── MenuBarView.swift     → Status item + popover for main note
│   │   └── NoteListView.swift    → Right-click menu note list
│   ├── Services/
│   │   ├── NoteManager.swift     → CRUD, window lifecycle management
│   │   ├── HotkeyService.swift   → Global hotkey registration
│   │   └── WindowManager.swift   → Window positioning, levels, transparency
│   ├── Utilities/
│   │   └── MarkdownRenderer.swift → Markdown → AttributedString
│   ├── Resources/
│   │   └── Assets.xcassets        → Menu bar icon, app icon
│   └── Info.plist
├── ScrapsTests/
│   ├── NoteModelTests.swift
│   ├── MarkdownRendererTests.swift
│   └── NoteManagerTests.swift
└── Package.swift                  → SPM dependencies (if hybrid approach)
```

## Code Style

SwiftUI-first with AppKit bridging where SwiftUI falls short (floating panels, window levels).

```swift
// Prefer: short, focused types
// Naming: PascalCase types, camelCase properties/methods
// No force unwraps except IBOutlet-style patterns
// Use @Observable macro (Swift 5.9+) over ObservableObject where possible

import SwiftUI
import SwiftData

@Model
final class Note {
    var content: String
    var isPinned: Bool          // pinned to desktop vs floating
    var isMarkdownPreview: Bool
    var fontSize: CGFloat
    var positionX: Double
    var positionY: Double
    var createdAt: Date
    var updatedAt: Date

    var displayTitle: String {
        content.components(separatedBy: .newlines).first(where: { !$0.isEmpty }) ?? "Untitled"
    }

    init(content: String = "") {
        self.content = content
        self.isPinned = false
        self.isMarkdownPreview = false
        self.fontSize = 14
        self.positionX = 0
        self.positionY = 0
        self.createdAt = .now
        self.updatedAt = .now
    }
}
```

## Testing Strategy

- **Framework:** XCTest (built-in)
- **Location:** `ScrapsTests/`
- **Unit tests:** Model logic, markdown rendering, note manager CRUD
- **UI tests:** Deferred — menu bar apps are hard to UI-test; manual verification initially
- **Coverage target:** 70%+ on model and service layers

## Boundaries

### Always
- Persist note content on every edit (auto-save, no explicit save action)
- Respect system appearance (light/dark mode)
- Use NSPanel (not NSWindow) for floating notes — panels don't appear in Mission Control or ⌘Tab
- Keep note windows non-activating where possible (don't steal focus from other apps)
- Notarize builds for distribution

### Ask First
- Adding dependencies beyond swift-markdown
- Changing the data model schema
- Adding menu bar popover vs panel behavior changes
- Any network functionality

### Never
- Cloud sync or network calls (local-only app)
- Commit signing keys or developer certificates
- Access files outside the app's container without user intent
- Force unwrap optionals in non-UI code

## Architecture Decisions

### Why NSPanel over NSWindow
NSPanel doesn't appear in Mission Control, ⌘Tab, or window lists. This is correct behavior for sticky notes — they should be ambient, not treated as full application windows.

### Why SwiftData over Core Data
SwiftData is the modern replacement, integrates naturally with SwiftUI, and is simpler for a local-only app. Since we target macOS 14+, it's available.

### Why menu bar app (LSUIElement)
No dock icon. The app lives in the menu bar. Notes are panels. This keeps the app unobtrusive. Set `LSUIElement = YES` in Info.plist.

### Window Levels
- **Floating notes:** `NSWindow.Level.floating` (above normal windows)
- **Desktop-pinned notes:** `CGWindowLevelForKey(.desktopWindow) + 1` (just above desktop)
- **Transparency:** NSVisualEffectView with `.hudWindow` material for glass aesthetic

## Resolved Decisions

1. **Main note** — Popover attached to the menu bar icon.
2. **Note titles** — Auto-derived from first line of content. No explicit title field.
3. **Delete** — Confirmation dialog required before deleting a note.
4. **Max notes** — Unlimited simultaneous visible notes.
