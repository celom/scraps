import SwiftUI

struct NoteEditorView: View {
    @Bindable var note: Note
    var onSave: () -> Void = {}
    var onPinToggle: (() -> Void)?
    var showPinButton: Bool = false
    var floatingToolbar: Bool = false

    @State private var isHovering = false
    @State private var saveTask: Task<Void, Never>?

    var body: some View {
        if floatingToolbar {
            ZStack(alignment: .topTrailing) {
                content
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.top, 36)

                if isHovering {
                    toolbar
                        .background(.ultraThinMaterial.opacity(0.6), in: RoundedRectangle(cornerRadius: 6))
                        .padding(.trailing, 0)
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.15), value: isHovering)
            .onHover { hovering in
                isHovering = hovering
            }
        } else {
            VStack(spacing: 0) {
                toolbar
                Divider()
                content
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if note.isMarkdownPreview {
            markdownPreview
        } else {
            editor
        }
    }

    private var toolbar: some View {
        HStack(spacing: 2) {
            Button(action: {
                note.isMarkdownPreview.toggle()
                onSave()
            }) {
                Image(systemName: note.isMarkdownPreview ? "pencil" : "eye")
                    .font(.system(size: 11))
                    .frame(width: 22, height: 22, alignment: .center)
                    .contentShape(Rectangle())
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .help(note.isMarkdownPreview ? "Edit" : "Preview Markdown")
            .keyboardShortcut("m", modifiers: .command)

            if showPinButton {
                Button(action: {
                    note.isPinned.toggle()
                    onSave()
                    onPinToggle?()
                }) {
                    Image(systemName: note.isPinned ? "square.stack.3d.down.right" : "square.stack.3d.up")
                        .font(.system(size: 11))
                        .frame(width: 22, height: 22, alignment: .trailing)
                        .contentShape(Rectangle())
                        .foregroundStyle(note.isPinned ? .secondary : .primary)
                }
                .buttonStyle(.plain)
                .help(note.isPinned ? "Float Above Windows" : "Stay Behind Windows")
            }

            Button(action: decreaseFontSize) { EmptyView() }
                .keyboardShortcut("-", modifiers: .command)
                .frame(width: 0, height: 0)
                .hidden()

            Button(action: increaseFontSize) { EmptyView() }
                .keyboardShortcut("+", modifiers: .command)
                .frame(width: 0, height: 0)
                .hidden()

            Button(action: resetFontSize) { EmptyView() }
                .keyboardShortcut("0", modifiers: .command)
                .frame(width: 0, height: 0)
                .hidden()
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
    }

    private var editor: some View {
        TextEditor(text: $note.content)
            .font(.system(size: note.fontSize))
            .scrollContentBackground(.hidden)
            .padding(12)
            .onChange(of: note.content) {
                note.updatedAt = .now
                debouncedSave()
            }
    }

    private var markdownPreview: some View {
        ScrollView {
            Text(MarkdownRenderer.render(note.content, fontSize: note.fontSize))
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
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

    private func resetFontSize() {
        note.fontSize = 14
        onSave()
    }

    private func debouncedSave() {
        saveTask?.cancel()
        saveTask = Task {
            try? await Task.sleep(for: .milliseconds(500))
            guard !Task.isCancelled else { return }
            onSave()
        }
    }
}
