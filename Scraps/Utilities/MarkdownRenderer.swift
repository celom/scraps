import Foundation
import Markdown
import AppKit

struct MarkdownRenderer {
    static func render(_ source: String, fontSize: CGFloat) -> AttributedString {
        let document = Document(parsing: source)
        var visitor = AttributedStringVisitor(fontSize: fontSize)
        return visitor.visit(document)
    }
}

private struct AttributedStringVisitor: MarkupVisitor {
    let fontSize: CGFloat

    typealias Result = AttributedString

    private var baseAttributes: AttributeContainer {
        var attrs = AttributeContainer()
        attrs.appKit.font = .systemFont(ofSize: fontSize)
        attrs.appKit.foregroundColor = .labelColor
        return attrs
    }

    mutating func defaultVisit(_ markup: any Markup) -> AttributedString {
        var result = AttributedString()
        for child in markup.children {
            result.append(visit(child))
        }
        return result
    }

    mutating func visitDocument(_ document: Document) -> AttributedString {
        var result = AttributedString()
        for (index, child) in document.children.enumerated() {
            result.append(visit(child))
            if index < document.childCount - 1 {
                result.append(AttributedString("\n"))
            }
        }
        return result
    }

    mutating func visitHeading(_ heading: Heading) -> AttributedString {
        var result = defaultVisit(heading)
        let size: CGFloat = switch heading.level {
        case 1: fontSize * 1.8
        case 2: fontSize * 1.5
        case 3: fontSize * 1.3
        default: fontSize * 1.1
        }
        result.appKit.font = .systemFont(ofSize: size, weight: .bold)
        result.append(AttributedString("\n"))
        return result
    }

    mutating func visitParagraph(_ paragraph: Paragraph) -> AttributedString {
        var result = defaultVisit(paragraph)
        result.mergeAttributes(baseAttributes, mergePolicy: .keepCurrent)
        result.append(AttributedString("\n"))
        return result
    }

    mutating func visitText(_ text: Text) -> AttributedString {
        var str = AttributedString(text.string)
        str.mergeAttributes(baseAttributes, mergePolicy: .keepCurrent)
        return str
    }

    mutating func visitStrong(_ strong: Strong) -> AttributedString {
        var result = defaultVisit(strong)
        result.appKit.font = .systemFont(ofSize: fontSize, weight: .bold)
        return result
    }

    mutating func visitEmphasis(_ emphasis: Emphasis) -> AttributedString {
        var result = defaultVisit(emphasis)
        result.appKit.font = NSFont.systemFont(ofSize: fontSize).with(traits: .italicFontMask)
        return result
    }

    mutating func visitInlineCode(_ inlineCode: InlineCode) -> AttributedString {
        var str = AttributedString(inlineCode.code)
        str.appKit.font = .monospacedSystemFont(ofSize: fontSize * 0.9, weight: .regular)
        str.appKit.backgroundColor = .quaternaryLabelColor
        str.appKit.foregroundColor = .labelColor
        return str
    }

    mutating func visitCodeBlock(_ codeBlock: CodeBlock) -> AttributedString {
        var str = AttributedString(codeBlock.code)
        str.appKit.font = .monospacedSystemFont(ofSize: fontSize * 0.9, weight: .regular)
        str.appKit.backgroundColor = .quaternaryLabelColor
        str.appKit.foregroundColor = .labelColor
        str.append(AttributedString("\n"))
        return str
    }

    mutating func visitLink(_ link: Markdown.Link) -> AttributedString {
        var result = defaultVisit(link)
        if let dest = link.destination, let url = URL(string: dest) {
            result.link = url
            result.appKit.foregroundColor = .linkColor
        }
        return result
    }

    mutating func visitListItem(_ listItem: ListItem) -> AttributedString {
        let bullet: String
        if let orderedList = listItem.parent as? OrderedList {
            let index = orderedList.children.enumerated().first(where: {
                $0.element.range == listItem.range
            })?.offset ?? 0
            bullet = "\(orderedList.startIndex + UInt(index)). "
        } else {
            bullet = "\u{2022} "
        }
        var prefix = AttributedString(bullet)
        prefix.mergeAttributes(baseAttributes, mergePolicy: .keepCurrent)
        var content = defaultVisit(listItem)
        if content.characters.last == "\n" {
            content.characters.removeLast()
        }
        var result = prefix
        result.append(content)
        result.append(AttributedString("\n"))
        return result
    }

    mutating func visitSoftBreak(_ softBreak: SoftBreak) -> AttributedString {
        AttributedString(" ")
    }

    mutating func visitLineBreak(_ lineBreak: LineBreak) -> AttributedString {
        AttributedString("\n")
    }

    mutating func visitThematicBreak(_ thematicBreak: ThematicBreak) -> AttributedString {
        var str = AttributedString("———————————\n")
        str.appKit.foregroundColor = .separatorColor
        return str
    }
}

private extension NSFont {
    func with(traits: NSFontTraitMask) -> NSFont {
        NSFontManager.shared.convert(self, toHaveTrait: traits)
    }
}
