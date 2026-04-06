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
    var positionX: Double
    var positionY: Double
    var createdAt: Date
    var updatedAt: Date

    var displayTitle: String {
        content.components(separatedBy: .newlines).first(where: { !$0.isEmpty }) ?? "Untitled"
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
        self.positionX = 0
        self.positionY = 0
        self.createdAt = .now
        self.updatedAt = .now
    }
}
