import Foundation

struct LearnArticle: Identifiable, Codable {
    let id: String
    let title: String
    let subtitle: String?
    let imageURLString: String?
    let tags: [String]
    let estimatedReadMins: Int?
    let content: String?
    let createdAt: String

    var imageURL: URL? {
        guard let imageURLString else { return nil }
        return URL(string: imageURLString)
    }

    var markdownContent: AttributedString? {
        guard let content, !content.isEmpty else { return nil }
        return try? AttributedString(
            markdown: content,
            options: AttributedString.MarkdownParsingOptions(
                interpretedSyntax: .full,
                failurePolicy: .returnPartiallyParsedIfPossible
            )
        )
    }

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case subtitle
        case imageURLString = "image_url"
        case tags
        case estimatedReadMins = "estimated_read_mins"
        case content
        case createdAt = "created_at"
    }
}

struct LearnArticlesResponse: Codable {
    let articles: [LearnArticle]
}