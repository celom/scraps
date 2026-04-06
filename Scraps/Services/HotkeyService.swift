import Carbon
import AppKit

@MainActor
final class HotkeyService {
    nonisolated(unsafe) private var newNoteHotkeyRef: EventHotKeyRef?
    nonisolated(unsafe) private var toggleMainHotkeyRef: EventHotKeyRef?
    private static var onNewNote: (() -> Void)?
    private static var onToggleMain: (() -> Void)?

    private static let newNoteHotkeyID = EventHotKeyID(signature: fourCharCode("ScN1"), id: 1)
    private static let toggleMainHotkeyID = EventHotKeyID(signature: fourCharCode("ScN2"), id: 2)

    init(onNewNote: @escaping () -> Void, onToggleMain: @escaping () -> Void) {
        HotkeyService.onNewNote = onNewNote
        HotkeyService.onToggleMain = onToggleMain
        registerHotkeys()
    }

    private func registerHotkeys() {
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))

        InstallEventHandler(
            GetApplicationEventTarget(),
            { (_, event, _) -> OSStatus in
                var hotKeyID = EventHotKeyID()
                GetEventParameter(
                    event,
                    EventParamName(kEventParamDirectObject),
                    EventParamType(typeEventHotKeyID),
                    nil,
                    MemoryLayout<EventHotKeyID>.size,
                    nil,
                    &hotKeyID
                )

                DispatchQueue.main.async {
                    switch hotKeyID.id {
                    case 1: HotkeyService.onNewNote?()
                    case 2: HotkeyService.onToggleMain?()
                    default: break
                    }
                }
                return noErr
            },
            1,
            &eventType,
            nil,
            nil
        )

        // ⌘⇧N — New note
        var newNoteRef: EventHotKeyRef?
        RegisterEventHotKey(
            UInt32(kVK_ANSI_N),
            UInt32(cmdKey | shiftKey),
            HotkeyService.newNoteHotkeyID,
            GetApplicationEventTarget(),
            0,
            &newNoteRef
        )
        newNoteHotkeyRef = newNoteRef

        // ⌘⇧S — Toggle main note
        var toggleRef: EventHotKeyRef?
        RegisterEventHotKey(
            UInt32(kVK_ANSI_S),
            UInt32(cmdKey | shiftKey),
            HotkeyService.toggleMainHotkeyID,
            GetApplicationEventTarget(),
            0,
            &toggleRef
        )
        toggleMainHotkeyRef = toggleRef
    }

    deinit {
        if let ref = newNoteHotkeyRef {
            UnregisterEventHotKey(ref)
        }
        if let ref = toggleMainHotkeyRef {
            UnregisterEventHotKey(ref)
        }
    }
}

private func fourCharCode(_ string: String) -> OSType {
    var result: OSType = 0
    for char in string.utf8.prefix(4) {
        result = result << 8 + OSType(char)
    }
    return result
}
