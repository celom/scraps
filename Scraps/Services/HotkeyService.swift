import Carbon
import AppKit
import os

@MainActor
final class HotkeyService {
    nonisolated(unsafe) private var newNoteHotkeyRef: EventHotKeyRef?
    nonisolated(unsafe) private var toggleMainHotkeyRef: EventHotKeyRef?
    nonisolated(unsafe) private var eventHandlerRef: EventHandlerRef?

    private let onNewNote: () -> Void
    private let onToggleMain: () -> Void

    private static let newNoteHotkeyID = EventHotKeyID(signature: fourCharCode("ScN1"), id: 1)
    private static let toggleMainHotkeyID = EventHotKeyID(signature: fourCharCode("ScN2"), id: 2)

    private static let logger = Logger(subsystem: "com.celom.scraps", category: "HotkeyService")

    // The Carbon callback needs a way to reach instance methods.
    // We store a pointer to self as the userData parameter.
    nonisolated(unsafe) private static var shared: HotkeyService?

    init(onNewNote: @escaping () -> Void, onToggleMain: @escaping () -> Void) {
        self.onNewNote = onNewNote
        self.onToggleMain = onToggleMain
        HotkeyService.shared = self
        registerHotkeys()
    }

    private func registerHotkeys() {
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        var handlerRef: EventHandlerRef?
        let status = InstallEventHandler(
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
                    guard let service = HotkeyService.shared else { return }
                    switch hotKeyID.id {
                    case 1: service.onNewNote()
                    case 2: service.onToggleMain()
                    default: break
                    }
                }
                return noErr
            },
            1,
            &eventType,
            nil,
            &handlerRef
        )

        if status == noErr {
            eventHandlerRef = handlerRef
        } else {
            Self.logger.error("Failed to install event handler: \(status)")
        }

        // ⌘⇧N — New note
        var newNoteRef: EventHotKeyRef?
        let s1 = RegisterEventHotKey(
            UInt32(kVK_ANSI_N),
            UInt32(cmdKey | shiftKey),
            HotkeyService.newNoteHotkeyID,
            GetApplicationEventTarget(),
            0,
            &newNoteRef
        )
        if s1 == noErr {
            newNoteHotkeyRef = newNoteRef
        } else {
            Self.logger.warning("Failed to register ⌘⇧N hotkey: \(s1)")
        }

        // ⌘⇧S — Toggle main note
        var toggleRef: EventHotKeyRef?
        let s2 = RegisterEventHotKey(
            UInt32(kVK_ANSI_S),
            UInt32(cmdKey | shiftKey),
            HotkeyService.toggleMainHotkeyID,
            GetApplicationEventTarget(),
            0,
            &toggleRef
        )
        if s2 == noErr {
            toggleMainHotkeyRef = toggleRef
        } else {
            Self.logger.warning("Failed to register ⌘⇧S hotkey: \(s2)")
        }
    }

    deinit {
        if let ref = newNoteHotkeyRef { UnregisterEventHotKey(ref) }
        if let ref = toggleMainHotkeyRef { UnregisterEventHotKey(ref) }
        if let ref = eventHandlerRef { RemoveEventHandler(ref) }
        HotkeyService.shared = nil
    }
}

private func fourCharCode(_ string: String) -> OSType {
    var result: OSType = 0
    for char in string.utf8.prefix(4) {
        result = result << 8 + OSType(char)
    }
    return result
}
