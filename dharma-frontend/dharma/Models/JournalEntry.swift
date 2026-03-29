import Foundation

struct JournalEntry: Decodable, Identifiable, Hashable {
    let id: UUID
    let date: String
    let content: String
    let createdAt: String?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case date
        case content
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    var displayDate: String {
        guard let parsedDate = Self.storageFormatter.date(from: date) else {
            return date
        }

        return Self.displayFormatter.string(from: parsedDate)
    }

    private static let storageFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private static let displayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMMM d"
        return formatter
    }()
}