import SwiftUI

struct LearnArticleDetailView: View {
    let article: LearnArticle
    @State private var speech = SpeechSynthesizer()

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    heroImage

                    VStack(alignment: .leading, spacing: DharmaTheme.Spacing.xl) {
                        // Meta: tags + read time
                        HStack(spacing: DharmaTheme.Spacing.sm) {
                            ForEach(Array(article.tags.prefix(3)), id: \.self) { tag in
                                Text(tag.uppercased())
                                    .font(DharmaTheme.Typography.uiLabel(11))
                                    .foregroundColor(DharmaTheme.Colors.saffron)
                                    .tracking(1)
                            }

                            Spacer(minLength: 0)

                            if let estimatedReadMins = article.estimatedReadMins {
                                Label("\(estimatedReadMins) min read", systemImage: "clock")
                                    .font(DharmaTheme.Typography.uiCaption(12))
                                    .foregroundColor(DharmaTheme.Colors.secondaryText)
                            }
                        }

                        // Title + subtitle
                        VStack(alignment: .leading, spacing: DharmaTheme.Spacing.sm) {
                            Text(article.title)
                                .font(DharmaTheme.Typography.scriptureHeadline(28))
                                .foregroundColor(DharmaTheme.Colors.onSurface)
                                .lineSpacing(4)

                            if let subtitle = article.subtitle, !subtitle.isEmpty {
                                Text(subtitle)
                                    .font(DharmaTheme.Typography.uiBody(16))
                                    .foregroundColor(DharmaTheme.Colors.secondaryText)
                                    .lineSpacing(4)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }

                        // Divider
                        Rectangle()
                            .fill(DharmaTheme.Colors.surfaceContainerLow)
                            .frame(height: 1)

                        contentBlock
                    }
                    .padding(.horizontal, DharmaTheme.Spacing.xl)
                    .padding(.top, DharmaTheme.Spacing.xl)
                    .padding(.bottom, 100)
                }
            }

            if speech.state != .idle || article.content != nil {
                audioBar
            }
        }
        .background(Color.white)
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear { speech.stop() }
    }

    @ViewBuilder
    private var heroImage: some View {
        AsyncImage(url: article.imageURL) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            case .failure:
                fallbackImage
            case .empty:
                Rectangle()
                    .fill(DharmaTheme.Colors.surfaceContainerLow)
                    .overlay {
                        ProgressView()
                            .tint(DharmaTheme.Colors.saffron)
                    }
            @unknown default:
                fallbackImage
            }
        }
        .frame(height: 280)
        .frame(maxWidth: .infinity)
        .clipped()
    }

    @ViewBuilder
    private var contentBlock: some View {
        if let content = article.content, !content.isEmpty {
            let blocks = Self.parseContentBlocks(content)

            VStack(alignment: .leading, spacing: DharmaTheme.Spacing.md) {
                ForEach(Array(blocks.enumerated()), id: \.offset) { index, block in
                    if let md = try? AttributedString(
                        markdown: block.text,
                        options: AttributedString.MarkdownParsingOptions(
                            interpretedSyntax: .inlineOnlyPreservingWhitespace,
                            failurePolicy: .returnPartiallyParsedIfPossible
                        )
                    ) {
                        Text(md)
                            .font(DharmaTheme.Typography.uiBody(17))
                            .foregroundColor(DharmaTheme.Colors.onSurface)
                            .lineSpacing(8)
                            .textSelection(.enabled)
                            .padding(.top, block.isBoldHeader && index > 0 ? DharmaTheme.Spacing.xl : 0)
                    }
                }
            }
        } else {
            Text("This article does not have published content yet.")
                .font(DharmaTheme.Typography.uiBody(16))
                .foregroundColor(DharmaTheme.Colors.secondaryText)
        }
    }

    private struct ContentBlock {
        let text: String
        let isBoldHeader: Bool
    }

    private static func parseContentBlocks(_ content: String) -> [ContentBlock] {
        var blocks: [ContentBlock] = []
        let paragraphs = content.components(separatedBy: "\n\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        for paragraph in paragraphs {
            // Check if paragraph starts with a bold-only line like **Header**\nBody text
            if paragraph.hasPrefix("**"),
               let newlineIndex = paragraph.firstIndex(of: "\n") {
                let headerLine = String(paragraph[paragraph.startIndex..<newlineIndex])
                    .trimmingCharacters(in: .whitespaces)
                if headerLine.hasSuffix("**") {
                    blocks.append(ContentBlock(text: headerLine, isBoldHeader: true))
                    let body = String(paragraph[paragraph.index(after: newlineIndex)...])
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    if !body.isEmpty {
                        blocks.append(ContentBlock(text: body, isBoldHeader: false))
                    }
                    continue
                }
            }
            // Standalone bold line or regular paragraph
            let isBold = paragraph.hasPrefix("**") && paragraph.hasSuffix("**")
            blocks.append(ContentBlock(text: paragraph, isBoldHeader: isBold))
        }
        return blocks
    }

    private var audioBar: some View {
        HStack(spacing: DharmaTheme.Spacing.lg) {
            Button {
                if speech.state == .idle {
                    speech.speak(articlePlainText)
                } else {
                    speech.togglePlayPause()
                }
            } label: {
                Image(systemName: speech.state == .speaking ? "pause.fill" : "play.fill")
                    .font(.system(size: 22))
                    .foregroundColor(DharmaTheme.Colors.saffron)
            }

            Text(speech.state == .idle ? "Listen to article" : (speech.state == .speaking ? "Playing..." : "Paused"))
                .font(DharmaTheme.Typography.uiCaption())
                .foregroundColor(DharmaTheme.Colors.secondaryText)

            Spacer()

            if speech.state != .idle {
                Button {
                    speech.stop()
                } label: {
                    Image(systemName: "stop.fill")
                        .font(.system(size: 16))
                        .foregroundColor(DharmaTheme.Colors.secondaryText)
                }
            }
        }
        .padding(.horizontal, DharmaTheme.Spacing.xl)
        .padding(.vertical, DharmaTheme.Spacing.lg)
        .background(
            Color.white.opacity(0.9)
                .background(.ultraThinMaterial)
        )
        .shadow(color: .black.opacity(0.04), radius: 16, x: 0, y: -4)
    }

    private var articlePlainText: String {
        if let content = article.content, !content.isEmpty {
            return content
                .replacingOccurrences(of: "#+ ", with: "", options: .regularExpression)
                .replacingOccurrences(of: "\\*+", with: "", options: .regularExpression)
        }
        return article.title
    }

    private var fallbackImage: some View {
        DharmaTheme.Colors.surface
            .overlay {
                Image(systemName: "book.pages.fill")
                    .font(.system(size: 36))
                    .foregroundColor(DharmaTheme.Colors.saffron)
            }
    }
}

#Preview {
    LearnArticleDetailView(
        article: LearnArticle(
            id: "preview",
            title: "The Upanishads: A Gentle Introduction",
            subtitle: "Atman, Brahman, and ultimate reality",
            imageURLString: "https://picsum.photos/seed/learn-upanishads/1200/800",
            tags: ["hinduism", "spirituality"],
            estimatedReadMins: 9,
            content: "# A heading\n\nThis is **markdown** content with a paragraph.",
            createdAt: "2026-03-29T00:00:00Z"
        )
    )
}