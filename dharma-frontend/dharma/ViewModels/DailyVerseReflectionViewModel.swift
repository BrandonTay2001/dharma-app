import Foundation
import Observation

@Observable
@MainActor
final class DailyVerseReflectionViewModel {
    var reflectionText = "" {
        didSet {
            guard hasLoaded else { return }
            persistReflection()
        }
    }

    private(set) var verseType: DailyTask.TaskType

    var characterCount: Int {
        reflectionText.count
    }

    var hasReflection: Bool {
        !reflectionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var storageHint: String {
        "Saved on this device."
    }

    private let store: DailyVerseReflectionStore
    private var hasLoaded = false

    init(verseType: DailyTask.TaskType, store: DailyVerseReflectionStore = DailyVerseReflectionStore()) {
        self.verseType = verseType
        self.store = store
        loadReflection()
    }

    func selectVerseType(_ verseType: DailyTask.TaskType) {
        guard self.verseType != verseType else { return }
        self.verseType = verseType
        loadReflection()
    }

    func loadReflection() {
        hasLoaded = false
        reflectionText = store.loadReflection(for: verseType) ?? ""
        hasLoaded = true
    }

    func clearReflection() {
        guard hasReflection else { return }
        hasLoaded = false
        reflectionText = ""
        store.clearReflection(for: verseType)
        hasLoaded = true
    }

    private func persistReflection() {
        if hasReflection {
            store.saveReflection(reflectionText, for: verseType)
        } else {
            store.clearReflection(for: verseType)
        }
    }
}

struct DailyVerseReflectionStore {
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func loadReflection(for verseType: DailyTask.TaskType) -> String? {
        let storageKey = key(for: verseType)

        guard let data = userDefaults.data(forKey: storageKey),
              let payload = try? JSONDecoder().decode(ReflectionPayload.self, from: data) else {
            return nil
        }

        guard payload.dayKey == Self.currentDayKey else {
            userDefaults.removeObject(forKey: storageKey)
            return nil
        }

        return payload.text
    }

    func saveReflection(_ text: String, for verseType: DailyTask.TaskType) {
        let payload = ReflectionPayload(dayKey: Self.currentDayKey, text: text)
        guard let data = try? JSONEncoder().encode(payload) else { return }
        userDefaults.set(data, forKey: key(for: verseType))
    }

    func clearReflection(for verseType: DailyTask.TaskType) {
        userDefaults.removeObject(forKey: key(for: verseType))
    }

    private func key(for verseType: DailyTask.TaskType) -> String {
        "dailyVerseReflection.\(storageKeyComponent(for: verseType))"
    }

    private func storageKeyComponent(for verseType: DailyTask.TaskType) -> String {
        switch verseType {
        case .dailyVerse:
            return "daily"
        case .hinduVerse:
            return "hindu"
        case .buddhistVerse:
            return "buddhist"
        case .meditation:
            return "meditation"
        case .mantra:
            return "mantra"
        case .journal:
            return "journal"
        case .gratitude:
            return "gratitude"
        }
    }

    private struct ReflectionPayload: Codable {
        let dayKey: String
        let text: String
    }

    private static var currentDayKey: String {
        dayFormatter.string(from: Date())
    }

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .autoupdatingCurrent
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
