import SwiftUI

extension Text {
    public struct MarkdownConfiguration {
        public init(
            headerFonts: [Font] = [.largeTitle, .title, .title2, .title3],
            headerColors: [Color] = [.primary, .primary, .primary, .primary],
            listNumberFont: Font = Font.system(.body, design: .monospaced),
            listNumberColor: Color = Color.secondary,
            listBulletFont: Font = Font.system(.caption, design: .monospaced),
            listBulletColor: Color = Color.secondary,
            listBullet1: String = "●",
            listBullet2: String = "■",
            quoteBulletFont: Font = Font.system(.headline, design: .monospaced),
            quoteBulletColor: Color = Color.primary,
            quoteBullet: String = "|",
            quoteFont: Font = Font.headline,
            quoteColor: Color = Color.secondary,
            codeFont: Font = Font.system(.body, design: .monospaced),
            codeColor: Color = Color.secondary,
            bodyFont: Font = Font.body,
            bodyColor: Color = Color.primary
        ) {
            self.headerFonts = headerFonts
            self.headerColors = headerColors
            self.listNumberFont = listNumberFont
            self.listNumberColor = listNumberColor
            self.listBulletFont = listBulletFont
            self.listBulletColor = listBulletColor
            self.listBullet1 = listBullet1
            self.listBullet2 = listBullet2
            self.quoteBulletFont = quoteBulletFont
            self.quoteBulletColor = quoteBulletColor
            self.quoteBullet = quoteBullet
            self.quoteFont = quoteFont
            self.quoteColor = quoteColor
            self.codeFont = codeFont
            self.codeColor = codeColor
            self.bodyFont = bodyFont
            self.bodyColor = bodyColor
        }

        let headerFonts: [Font]
        let headerColors: [Color]

        let listNumberFont: Font
        let listNumberColor: Color
        let listBulletFont: Font
        let listBulletColor: Color
        let listBullet1: String
        let listBullet2: String

        let quoteBulletFont: Font
        let quoteBulletColor: Color
        let quoteBullet: String
        let quoteFont: Font
        let quoteColor: Color

        let codeFont: Font
        let codeColor: Color

        let bodyFont: Font
        let bodyColor: Color
    }

    // MARK: Text initializers

    public init(markdown: String, ifError: String = "", configuration: MarkdownConfiguration? = nil) {
        self.init("")
        self = Text.makeMarkdownText(markdown, ifError: ifError, configuration: configuration)
    }

    public init(markdown: Data, ifError: String = "", configuration: MarkdownConfiguration? = nil) {
        self.init("")
        self = Text.makeMarkdownText(markdown, ifError: ifError, configuration: configuration)
    }

    public init(markdownURL: URL, ifError: String = "", configuration: MarkdownConfiguration? = nil) {
        self.init("")
        self = Text.makeMarkdownText(contentsOf: markdownURL, ifError: ifError, configuration: configuration)
    }

    public init(
        markdownResource name: String,
        withExtension ext: String? = nil,
        subdirectory subpath: String? = nil,
        ifError: String = "",
        configuration: MarkdownConfiguration? = nil
    ) {
        self.init("")

        if let url = Bundle.main.url(forResource: name, withExtension: ext, subdirectory: subpath) {
            if let contents = try? String(contentsOf: url) {
                self = Text.makeMarkdownText(contents, ifError: ifError, configuration: configuration)
                return
            }
        }

        self = Text(ifError)
    }

    // MARK: Helpers

    public static func makeMarkdownText(_ markdown: String, ifError: String, configuration: MarkdownConfiguration? = nil) -> Text {
        guard let attributedString = try? AttributedString(markdown: markdown) else { return Text(ifError) }
        return makeMarkdownText(attributedString, configuration: configuration ?? .init())
    }

    public static func makeMarkdownText(_ markdown: Data, ifError: String, configuration: MarkdownConfiguration? = nil) -> Text {
        guard let attributedString = try? AttributedString(markdown: markdown) else { return Text(ifError) }
        return makeMarkdownText(attributedString, configuration: configuration ?? .init())
    }

    public static func makeMarkdownText(contentsOf url: URL, ifError: String, configuration: MarkdownConfiguration? = nil) -> Text {
        guard let attributedString = try? AttributedString(contentsOf: url) else { return Text(ifError) }
        return makeMarkdownText(attributedString, configuration: configuration ?? .init())
    }

    // MARK: Main

    public static func makeMarkdownText(_ attributedString: AttributedString, configuration cfg: MarkdownConfiguration) -> Text {
        var result = Text("")
        var lastParagraphId = 0
        var lastListItemId = 0
        var lastQuoteBlockId = 0
        var quoteBlockCount = 0

        for r in attributedString.runs {
            var string = String(attributedString[r.range].characters)
            //            dbg("\"" + string + "\"")

            var indentationLevel = 1

            var header = false
            var headerLevel = 1

            var listItem = false
            var orderedList = false
            var listItemNumber = 1

            var codeBlock = false
            var quoteBlock = false
            var newParagraph = false

            if let pi = r.presentationIntent {
                indentationLevel = max(1, pi.indentationLevel)
                loop: for c in pi.components {
                    //                    dbg(c)
                    let id = c.identity
                    var paragraph = false

                    switch c.kind {
                    case .paragraph:
                        paragraph = true

                    case .header(let level):
                        headerLevel = max(1, min(4, level))
                        header = true
                        paragraph = true

                    case .codeBlock(languageHint: _):
                        string = string.trimmingCharacters(in: .newlines)
                        codeBlock = true
                        paragraph = true

                    case .thematicBreak:
                        paragraph = true

                    case .blockQuote:
                        quoteBlockCount = lastQuoteBlockId != id ? 1 : quoteBlockCount + 1
                        lastQuoteBlockId = id
                        quoteBlock = true
                        break loop

                    case .listItem(let ordinal):
                        listItemNumber = ordinal
                        if lastListItemId != id {
                            listItem = true
                        }
                        lastListItemId = id

                    // Because presentationIntent.components contains also records
                    // for parent list (if list is nested) we need to break loop.
                    case .orderedList:
                        orderedList = true
                        break loop
                    case .unorderedList:
                        orderedList = false
                        break loop

                    default:
                        break loop
                    }

                    if paragraph {
                        if lastParagraphId != id && lastParagraphId > 0 {
                            newParagraph = true
                        }
                        lastParagraphId = id
                    }
                }
            }

            var text = Text(string)
            let indentationText = Text(String(repeating: " ", count: (indentationLevel - 1) * 3)).font(cfg.bodyFont).foregroundColor(cfg.bodyColor)

            if let ipi = r.inlinePresentationIntent {
                //                dbg(ipi)
                if ipi.contains(.emphasized) {
                    text = text.italic()
                }
                if ipi.contains(.stronglyEmphasized) {
                    text = text.fontWeight(.bold)
                }
                if ipi == .code {
                    text = text.font(cfg.codeFont)
                }
                if ipi == .strikethrough {
                    text = text.strikethrough()
                }
                if ipi.isSubset(of: [.softBreak, .lineBreak]) {
                    text = text + Text("\n").font(cfg.bodyFont) + indentationText
                    if quoteBlock {
                        text =
                            text
                            + Text(String(repeating: " ", count: cfg.quoteBullet.count + 1)).font(cfg.quoteBulletFont).foregroundColor(cfg.quoteBulletColor)
                    }
                }
            }

            if header {
                let headerFont = headerLevel >= 1 && headerLevel <= 4 ? cfg.headerFonts[headerLevel - 1] : cfg.bodyFont
                let headerColor = headerLevel >= 1 && headerLevel <= 4 ? cfg.headerColors[headerLevel - 1] : cfg.bodyColor
                text = text.font(headerFont).foregroundColor(headerColor)
            }

            if quoteBlock {
                if quoteBlockCount == 1 {
                    text = indentationText + Text(cfg.quoteBullet + " ").font(cfg.quoteBulletFont).foregroundColor(cfg.quoteBulletColor) + text
                }
                text = text.font(cfg.quoteFont).foregroundColor(cfg.quoteColor)
            }

            if codeBlock {
                text = text.font(cfg.codeFont).foregroundColor(cfg.codeColor)
            }

            if listItem {
                let bulletText =
                    orderedList
                    ? Text(String(listItemNumber) + ".").font(cfg.listNumberFont).foregroundColor(cfg.listNumberColor) + Text(" ").font(cfg.bodyFont)
                    : Text((indentationLevel % 2 != 0 ? cfg.listBullet1 : cfg.listBullet2) + " ").font(cfg.listBulletFont).foregroundColor(cfg.listBulletColor)

                text =
                    indentationText
                    + bulletText
                    + text.font(cfg.bodyFont).foregroundColor(cfg.bodyColor)
            }

            if newParagraph {
                let newLine = listItem && (listItemNumber > 1 || indentationLevel > 1) ? "\n" : "\n\n"
                text = Text(newLine).font(cfg.bodyFont) + text
            }

            result = result + text.font(cfg.bodyFont).foregroundColor(cfg.bodyColor)
            quoteBlockCount = quoteBlock ? quoteBlockCount : 0
        }

        return result
    }
}
