# Scraps — Task List

## Phase A: Foundation

- [ ] **Task 1: Xcode project + Note model**
  - Create Xcode project as macOS app, set `LSUIElement = YES`
  - Add SwiftData `Note` model with fields: `content`, `isPinned`, `isMarkdownPreview`, `fontSize`, `positionX`, `positionY`, `createdAt`, `updatedAt`
  - Add computed `displayTitle` (first non-empty line of content, or "Untitled")
  - Configure SwiftData `ModelContainer` in app entry point
  - Acceptance: Project builds, `Note` model compiles, unit test creates/reads/updates a Note
  - Verify: `xcodebuild -scheme Scraps build` succeeds, `NoteModelTests` pass
  - Files: `Scraps.xcodeproj`, `ScrapsApp.swift`, `Models/Note.swift`, `ScrapsTests/NoteModelTests.swift`

- [ ] **Task 2: Menu bar icon + main note popover**
  - Create `NSStatusItem` with a system icon (e.g., `note.text`)
  - Left-click toggles an `NSPopover` containing a text editor
  - Popover has fixed width (~320pt), variable height (up to ~400pt)
  - Wire popover content to a dedicated "main note" (auto-created on first launch)
  - Auto-save content on every keystroke (debounced ~0.5s) via SwiftData
  - Acceptance: Click menu bar icon → popover appears with editable text → text persists after quit/relaunch
  - Verify: Manual test — type text, quit app, relaunch, text is still there
  - Files: `ScrapsApp.swift`, `Views/MenuBarView.swift`, `Services/NoteManager.swift`

- [ ] **Task 3: Note editor view (plain text)**
  - Build `NoteEditorView` as a SwiftUI `TextEditor` with clean styling
  - No chrome — just text on a clean background
  - Support multi-line editing with standard macOS text behaviors
  - Acceptance: Text editor works in popover, supports copy/paste/undo, no visual clutter
  - Verify: Manual test — edit text in popover, verify standard text editing works
  - Files: `Views/NoteEditorView.swift`, update `Views/MenuBarView.swift`

---

## Phase B: Multi-note & Windows

- [ ] **Task 4: Floating note windows (NSPanel)**
  - Create `FloatingPanelController` wrapping `NSPanel` with `NSHostingView`
  - Panel properties: `.nonactivatingPanel`, `.floating` level, title bar hidden, resizable
  - Each panel displays a `NoteEditorView` bound to a `Note` model
  - `WindowManager` tracks open panels and their associated notes
  - Acceptance: Can programmatically open a note in a floating panel that stays above other apps
  - Verify: Open a note panel, switch to another app — panel stays on top
  - Files: `Views/NoteWindow.swift`, `Services/WindowManager.swift`

- [ ] **Task 5: Note list + right-click menu**
  - Right-click on menu bar icon shows `NSMenu` with:
    - List of all notes (showing `displayTitle`), click to open/focus
    - Separator
    - "New Note" item
    - "Quit" item
  - "New Note" creates a `Note` and opens it in a floating panel
  - Clicking an existing note opens it (or focuses it if already open)
  - Acceptance: Right-click shows all notes by title, can create and open notes
  - Verify: Create 3 notes, right-click menu lists all three, clicking opens each
  - Files: `Views/NoteListView.swift`, `Services/NoteManager.swift`, `ScrapsApp.swift`

- [ ] **Task 6: Markdown toggle**
  - Add a toggle button/shortcut (`⌘M`) to switch between edit and preview mode
  - Preview mode renders markdown as styled `AttributedString` in a `Text` view (or `ScrollView`)
  - Support: headings (H1–H3), bold, italic, links, unordered/ordered lists, inline code
  - Add `swift-markdown` as SPM dependency
  - Acceptance: Toggle switches between editable text and rendered markdown preview
  - Verify: Type `# Hello\n**bold** and *italic*`, toggle preview, verify rendering
  - Files: `Utilities/MarkdownRenderer.swift`, `Views/NoteEditorView.swift`, `ScrapsTests/MarkdownRendererTests.swift`, `Package.swift` or Xcode SPM config

---

## Phase C: Power Features

- [ ] **Task 7: Desktop pinning**
  - Add per-note toggle to pin to desktop level (`kCGDesktopWindowLevel + 1`)
  - Pinned notes sit just above the desktop wallpaper, below all other windows
  - Toggle via note context menu or toolbar button
  - Update `Note.isPinned` and persist
  - Acceptance: Pinned note stays behind all windows, unpinning returns to floating level
  - Verify: Pin a note, open apps over it — note stays behind. Unpin — note floats above.
  - Files: `Services/WindowManager.swift`, `Views/NoteWindow.swift`, `Views/NoteEditorView.swift`

- [ ] **Task 8: Font size + auto-resize**
  - `⌃+` increases font size, `⌃-` decreases (range: 10–32pt)
  - Note window auto-resizes to fit content (width stays fixed or has min/max, height adjusts)
  - Font size persisted per note in `Note.fontSize`
  - Acceptance: ⌃+/⌃- changes text size, window height adjusts to fit, size persists
  - Verify: Change font size, quit, relaunch — font size preserved. Window resizes with content.
  - Files: `Views/NoteEditorView.swift`, `Views/NoteWindow.swift`

- [ ] **Task 9: Global hotkeys**
  - `⌘⇧N` — Create new note and open in floating panel
  - `⌘⇧S` — Toggle main note popover
  - Register hotkeys using `CGEvent` tap or `HotKey` SPM package
  - Handle Accessibility permission: prompt user if not granted, degrade gracefully
  - Acceptance: Hotkeys work from any app, permission prompt shown on first use
  - Verify: Focus a different app, press `⌘⇧N` — new note appears. Press `⌘⇧S` — popover toggles.
  - Files: `Services/HotkeyService.swift`, `ScrapsApp.swift`

---

## Phase D: Polish & Ship

- [ ] **Task 10: Glass UI + visual polish**
  - Apply `NSVisualEffectView` with `.hudWindow` or `.popover` material to note panels
  - Translucent background with vibrancy effect
  - Clean typography: SF Pro or SF Mono for code
  - Subtle rounded corners, minimal border, no title bar chrome
  - Light/dark mode support (automatic via system appearance)
  - Acceptance: Notes have a glass/frosted appearance, look correct in both light and dark mode
  - Verify: Visual inspection in light mode, dark mode, and over various backgrounds
  - Files: `Views/NoteWindow.swift`, `Views/NoteEditorView.swift`, `Resources/Assets.xcassets`

- [ ] **Task 11: State persistence + launch at login**
  - Persist window positions (`positionX`, `positionY`) — save on window move, restore on launch
  - Restore all previously-open notes on app launch (reopen panels that were open)
  - Add "Launch at Login" toggle in right-click menu using `SMAppService`
  - Acceptance: Quit with 3 notes open at specific positions → relaunch → same 3 notes at same positions
  - Verify: Position notes, quit, relaunch — verify positions match. Toggle launch at login — verify it works.
  - Files: `Services/WindowManager.swift`, `Models/Note.swift`, `ScrapsApp.swift`

- [ ] **Task 12: App icon, DMG, distribution**
  - Design minimal app icon (or placeholder)
  - Create menu bar icon (SF Symbol `note.text` or custom)
  - Set up `create-dmg` script for building DMG
  - Code signing with Developer ID
  - Notarization via `notarytool`
  - Acceptance: DMG installs cleanly on a fresh Mac, app runs without Gatekeeper warnings
  - Verify: Build DMG, install on a separate machine/VM, verify full functionality
  - Files: `Resources/Assets.xcassets`, `scripts/build-dmg.sh`, build configuration

---

## Delete Confirmation (applies to Tasks 5+)

- [ ] **Task 5a: Delete note with confirmation**
  - Add "Delete" option in note context menu and right-click note list
  - Show confirmation dialog: "Delete '[displayTitle]'? This cannot be undone."
  - On confirm: close window if open, delete from SwiftData
  - Acceptance: Deleting a note shows confirmation, confirming removes it from list and closes window
  - Verify: Delete a note, verify it's gone from right-click menu and not restored on relaunch
  - Files: `Services/NoteManager.swift`, `Views/NoteListView.swift`
