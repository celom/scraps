import Testing
import Foundation
@testable import Scraps

@Suite("Markdown Renderer")
struct MarkdownRendererTests {

    @Test("Renders plain text")
    func plainText() {
        let result = MarkdownRenderer.render("Hello world", fontSize: 14)
        #expect(String(result.characters) .contains("Hello world"))
    }

    @Test("Renders heading")
    func heading() {
        let result = MarkdownRenderer.render("# Title", fontSize: 14)
        #expect(String(result.characters).contains("Title"))
    }

    @Test("Renders bold text")
    func boldText() {
        let result = MarkdownRenderer.render("**bold**", fontSize: 14)
        #expect(String(result.characters).contains("bold"))
    }

    @Test("Renders italic text")
    func italicText() {
        let result = MarkdownRenderer.render("*italic*", fontSize: 14)
        #expect(String(result.characters).contains("italic"))
    }

    @Test("Renders inline code")
    func inlineCode() {
        let result = MarkdownRenderer.render("`code`", fontSize: 14)
        #expect(String(result.characters).contains("code"))
    }

    @Test("Renders unordered list")
    func unorderedList() {
        let result = MarkdownRenderer.render("- item one\n- item two", fontSize: 14)
        let text = String(result.characters)
        #expect(text.contains("item one"))
        #expect(text.contains("item two"))
        #expect(text.contains("\u{2022}"))
    }

    @Test("Renders ordered list")
    func orderedList() {
        let result = MarkdownRenderer.render("1. first\n2. second", fontSize: 14)
        let text = String(result.characters)
        #expect(text.contains("1."))
        #expect(text.contains("first"))
    }

    @Test("Renders link text")
    func linkText() {
        let result = MarkdownRenderer.render("[click](https://example.com)", fontSize: 14)
        #expect(String(result.characters).contains("click"))
    }

    @Test("Empty string produces empty result")
    func emptyString() {
        let result = MarkdownRenderer.render("", fontSize: 14)
        #expect(String(result.characters).isEmpty)
    }
}
