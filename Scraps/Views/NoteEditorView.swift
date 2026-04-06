import SwiftUI

struct NoteEditorView: View {
    @Bindable var note: Note
    var onSave: () -> Void = {}
    var onPinToggle: (() -> Void)?
    var showPinButton: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            toolbar
            Divider()
            if note.isMarkdownPreview {
                markdownPreview
            } else {
                editor
            }
        }
    }

    private var toolbar: some View {
        HStack(spacing: 8) {
            if showPinButton {
                Button(action: {
                    note.isPinned.toggle()
                    onSave()
                    onPinToggle?()
                }) {
                    Image(systemName: note.isPinned ? "pin.fill" : "pin")
                        .font(.system(size: 12))
                        .foregroundStyle(note.isPinned ? .primary : .secondary)
                }
                .buttonStyle(.plain)
                .help(note.isPinned ? "Unpin from Desktop" : "Pin to Desktop")
            }

            Spacer()

            Button(action: decreaseFontSize) {
                Image(systemName: "textformat.size.smaller")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .keyboardShortcut("-", modifiers: .control)
            .help("Decrease font size")

            Text("\(Int(note.fontSize))")
                .font(.system(size: 10))
                .foregroundStyle(.tertiary)
                .monospacedDigit()

            Button(action: increaseFontSize) {
                Image(systemName: "textformat.size.larger")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .keyboardShortcut("+", modifiers: .control)
            .help("Increase font size")

            Button(action: {
                note.isMarkdownPreview.toggle()
                onSave()
            }) {
                Image(systemName: note.isMarkdownPreview ? "pencil" : "eye")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .help(note.isMarkdownPreview ? "Edit" : "Preview Markdown")
            .keyboardShortcut("m", modifiers: .command)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }

    private var editor: some View {
        TextEditor(text: $note.content)
            .font(.system(size: note.fontSize))
            .scrollContentBackground(.hidden)
            .padding(8)
            .onChange(of: note.content) {
                note.updatedAt = .now
                onSave()
            }
    }

    private var markdownPreview: some View {
        ScrollView {
            Text(MarkdownRenderer.render(note.content, fontSize: note.fontSize))
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(8)
        }
    }

    private func increaseFontSize() {
        note.fontSize = min(note.fontSize + 2, 32)
        onSave()
    }

    private func decreaseFontSize() {
        note.fontSize = max(note.fontSize - 2, 10)
        onSave()
    }
}
