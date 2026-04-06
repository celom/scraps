import SwiftUI

struct MenuBarView: View {
    @Environment(NoteManager.self) private var noteManager
    @Environment(WindowManager.self) private var windowManager
    weak var popover: NSPopover?

    var body: some View {
        if let mainNote = noteManager.mainNote {
            VStack(spacing: 0) {
                NoteEditorView(note: mainNote) {
                    noteManager.save()
                }

                ResizeHandle { delta in
                    var width = (popover?.contentSize.width ?? 320)
                    var height = (popover?.contentSize.height ?? 300)
                    width = max(280, min(600, width + delta.width * 2))
                    height = max(200, min(800, height + delta.height))
                    popover?.contentSize = NSSize(width: width, height: height)
                    mainNote.popoverWidth = width
                    mainNote.popoverHeight = height
                    noteManager.save()
                }
            }
            .onAppear {
                popover?.contentSize = NSSize(width: mainNote.popoverWidth, height: mainNote.popoverHeight)
            }
        }
    }
}

private struct ResizeHandle: View {
    let onDrag: (_ delta: CGSize) -> Void

    @State private var lastLocation: CGPoint?

    var body: some View {
        Rectangle()
            .fill(Color.clear)
            .frame(height: 10)
            .frame(maxWidth: .infinity)
            .overlay {
                Capsule()
                    .fill(.quaternary)
                    .frame(width: 36, height: 4)
            }
            .contentShape(Rectangle())
            .cursor(.resizeUpDown)
            .gesture(
                DragGesture(coordinateSpace: .global)
                    .onChanged { value in
                        if let last = lastLocation {
                            let dx = value.location.x - last.x
                            let dy = value.location.y - last.y
                            onDrag(CGSize(width: dx, height: dy))
                        }
                        lastLocation = value.location
                    }
                    .onEnded { _ in
                        lastLocation = nil
                    }
            )
    }
}

private extension View {
    func cursor(_ cursor: NSCursor) -> some View {
        onHover { inside in
            if inside { cursor.push() } else { NSCursor.pop() }
        }
    }
}
