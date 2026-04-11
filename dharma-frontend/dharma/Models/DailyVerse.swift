import Foundation

struct DailyVerse: Codable, Equatable, Identifiable {
    let scriptureTitle: String
    let tradition: String
    let chapterNumber: Int
    let verseNumber: Int
    let englishText: String
    let traditionalText: String?

    var id: String {
        "\(scriptureTitle)-\(chapterNumber)-\(verseNumber)"
    }

    var traditionIcon: String {
        switch tradition {
        case "Hindu":
            return "🛕"
        case "Buddhist":
            return "🪷"
        default:
            return "📖"
        }
    }

    var traditionLabel: String {
        tradition.uppercased()
    }

    var referenceText: String {
        "\(scriptureTitle) \(chapterNumber).\(verseNumber)"
    }

    var hasTraditionalText: Bool {
        guard let traditionalText else { return false }
        return !traditionalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var displayedTraditionalText: String {
        if hasTraditionalText {
            return traditionalText ?? ""
        }

        return "Traditional text is not available for this verse yet."
    }

    var explanationPrompt: String {
        var sections = [
            "Please explain this daily verse in simple language, share the spiritual meaning from its tradition, and suggest one practical way to apply it today.",
            "Reference: \(referenceText)",
            "English:\n\(englishText)"
        ]

        if hasTraditionalText {
            sections.append("Traditional:\n\(displayedTraditionalText)")
        }

        return sections.joined(separator: "\n\n")
    }
}