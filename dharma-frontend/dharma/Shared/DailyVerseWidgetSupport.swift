import Foundation

enum DharmaAppGroup {
    static let identifier = "group.xyz.618263.dharma"

    static var userDefaults: UserDefaults {
        UserDefaults(suiteName: identifier) ?? .standard
    }
}

enum DailyVerseWidgetConstants {
    static let kind = "DailyVerseWidget"
}

struct DailyVerseWidgetEntryData: Codable, Equatable {
    let dayKey: String
    let verse: DailyVerse
}
