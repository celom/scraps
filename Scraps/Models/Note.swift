import Foundation
import SwiftData

@Model
final class Note {
    var content: String
    var isPinned: Bool
    var isMarkdownPreview: Bool
    var isMainNote: Bool
    var isWindowOpen: Bool
    var fontSize: CGFloat
    var hasCustomPosition: Bool
    var positionX: Double
    var positionY: Double
    var popoverWidth: Double = 320
    var popoverHeight: Double = 300
    var createdAt: Date
    var updatedAt: Date

    var displayTitle: String {
        content.components(separatedBy: .newlines)
            .first(where: { !$0.trimmingCharacters(in: .whitespaces).isEmpty })?
            .trimmingCharacters(in: .whitespaces) ?? "Untitled"
    }

    init(
        content: String = "",
        isMainNote: Bool = false
    ) {
        self.content = content
        self.isPinned = false
        self.isMarkdownPreview = false
        self.isMainNote = isMainNote
        self.isWindowOpen = false
        self.fontSize = 14
        self.hasCustomPosition = false
        self.positionX = 0
        self.positionY = 0
        self.popoverWidth = 320
        self.popoverHeight = 300
        self.createdAt = .now
        self.updatedAt = .now
    }
}
