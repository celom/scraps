# Scraps — Implementation Plan

## Dependency Graph

```
                    ┌─────────────────┐
                    │  1. Xcode Setup  │
                    │  + Note Model    │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │  2. Menu Bar     │
                    │  + Main Popover  │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │  3. Note Editor  │
                    │  (plain text)    │
                    └────────┬────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
     ┌────────▼───────┐ ┌───▼────────┐ ┌───▼──────────┐
     │ 4. Floating    │ │ 5. Note    │ │ 6. Markdown  │
     │ Note Windows   │ │ List +     │ │ Toggle       │
     │ (NSPanel)      │ │ Right-click│ │              │
     └────────┬───────┘ └───┬────────┘ └───┬──────────┘
              │              │              │
              └──────────────┼──────────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
     ┌────────▼───────┐ ┌───▼────────┐ ┌───▼──────────┐
     │ 7. Desktop     │ │ 8. Font    │ │ 9. Global    │
     │ Pinning        │ │ Size +     │ │ Hotkeys      │
     │                │ │ Auto-resize│ │              │
     └────────┬───────┘ └───┬────────┘ └───┬──────────┘
              │              │              │
              └──────────────┼──────────────┘
                             │
                    ┌────────▼────────┐
                    │ 10. Glass UI +  │
                    │ Polish          │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │ 11. Persistence │
                    │ + Launch at     │
                    │ Login           │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │ 12. DMG +       │
                    │ Distribution    │
                    └─────────────────┘
```

## Build Order & Rationale

### Phase A: Foundation (Tasks 1–3)
Build the minimum app shell — a menu bar icon that opens a popover where you can type text. This validates the core architecture (LSUIElement app, SwiftData, menu bar integration) before adding complexity.

**Checkpoint:** App shows in menu bar, clicking opens a popover with an editable text area. Content persists across restarts.

### Phase B: Multi-note & Windows (Tasks 4–6)
Add the ability to create multiple notes as floating NSPanel windows, list them in the right-click menu, and toggle markdown preview. This is the core feature set.

**Checkpoint:** User can create multiple floating notes, see them listed in right-click menu, and toggle markdown rendering on each.

### Phase C: Power Features (Tasks 7–9)
Desktop pinning, font sizing with auto-resize, and global hotkeys. These are independent of each other and can be built in parallel.

**Checkpoint:** Notes can be pinned to desktop, resized with ⌃+/⌃-, and created/toggled via global hotkeys.

### Phase D: Polish & Ship (Tasks 10–12)
Glass/vibrancy aesthetic, persistence of all state, launch-at-login, and DMG packaging.

**Checkpoint:** App looks polished, remembers everything, and can be distributed as a notarized DMG.

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| NSPanel + SwiftUI bridging complexity | High | Start with NSPanel early (Task 4), validate before building on top |
| Global hotkeys need Accessibility permission | Medium | Add permission request flow in Task 9, graceful degradation if denied |
| SwiftData + macOS 26 may have API changes | Medium | Use stable SwiftData patterns, test on Tahoe beta |
| Menu bar popover sizing with dynamic content | Low | Use fixed-width, variable-height popover with max height |
| Auto-resize window to content | Medium | Use NSHostingView's intrinsicContentSize, test with long content |
