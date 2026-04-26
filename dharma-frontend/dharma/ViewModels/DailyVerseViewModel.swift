import Foundation
import Observation
import Supabase
#if canImport(WidgetKit)
import WidgetKit
#endif

@Observable
@MainActor
final class DailyVerseViewModel {
    enum TraditionFilter: String, CaseIterable, Identifiable {
        case hindu = "Hindu"
        case buddhist = "Buddhist"

        var id: String { rawValue }

        var title: String {
            switch self {
            case .hindu:
                return "Hindu"
            case .buddhist:
                return "Buddhist"
            }
        }

        var icon: String {
            switch self {
            case .hindu:
                return "🛕"
            case .buddhist:
                return "🪷"
            }
        }

        var taskType: DailyTask.TaskType {
            switch self {
            case .hindu:
                return .hinduVerse
            case .buddhist:
                return .buddhistVerse
            }
        }
    }

    var verse: DailyVerse?
    var isLoading = false
    var errorMessage: String?
    var isShowingTraditionalText = false
    var selectedTradition: TraditionFilter = .hindu

    private let store: DailyVerseStore
    private var loadedDayKeysByTradition: [TraditionFilter: String] = [:]

    init(store: DailyVerseStore = DailyVerseStore()) {
        self.store = store
    }

    func loadVerse(forceReload: Bool = false) async {
        guard !isLoading else { return }

        let currentDayKey = store.currentDayKey
        if !forceReload,
           loadedDayKeysByTradition[selectedTradition] == currentDayKey,
           verse?.tradition == selectedTradition.rawValue,
           verse != nil {
            return
        }

        if !forceReload,
           let cachedVerse = store.loadVerse(for: selectedTradition) {
            verse = cachedVerse
            errorMessage = nil
            loadedDayKeysByTradition[selectedTradition] = currentDayKey
            isShowingTraditionalText = false
            await prewarmWidgetTraditionsIfNeeded(currentDayKey: currentDayKey, forceReload: forceReload)
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            guard let selectedVerse = try await fetchVerse(for: selectedTradition, currentDayKey: currentDayKey) else {
                verse = nil
                errorMessage = "No daily verse is available right now."
                loadedDayKeysByTradition[selectedTradition] = currentDayKey
                return
            }

            verse = selectedVerse
            loadedDayKeysByTradition[selectedTradition] = currentDayKey
            isShowingTraditionalText = false
            store.saveVerse(selectedVerse, for: selectedTradition)
            await prewarmWidgetTraditionsIfNeeded(currentDayKey: currentDayKey, forceReload: forceReload)
        } catch is CancellationError {
            return
        } catch {
            if let cachedVerse = store.loadVerse(for: selectedTradition, allowExpiredFallback: true) {
                verse = cachedVerse
            }

            errorMessage = "Could not load today’s verse. Please try again."
        }
    }

    func selectTradition(_ tradition: TraditionFilter) async {
        guard selectedTradition != tradition else { return }
        selectedTradition = tradition
        await loadVerse()
    }

    func toggleCardFace() {
        isShowingTraditionalText.toggle()
    }

    private static func stableIndex(for dayKey: String, count: Int) -> Int {
        guard count > 0 else { return 0 }

        var hash: UInt64 = 1469598103934665603
        for byte in dayKey.utf8 {
            hash ^= UInt64(byte)
            hash &*= 1099511628211
        }

        return Int(hash % UInt64(count))
    }

    private func fetchVerse(for tradition: TraditionFilter, currentDayKey: String) async throws -> DailyVerse? {
        let records: [DailyVerseRecord] = try await supabase
            .from("scriptures")
            .select("title, tradition, chapter_number, verse_number, text, traditional_text")
            .eq("tradition", value: tradition.rawValue)
            .order("title", ascending: true)
            .order("chapter_number", ascending: true)
            .order("verse_number", ascending: true)
            .limit(10000)
            .execute()
            .value

        guard !records.isEmpty else { return nil }

        let index = Self.stableIndex(for: "\(tradition.rawValue)-\(currentDayKey)", count: records.count)
        return records[index].asDailyVerse
    }

    private func prewarmWidgetTraditionsIfNeeded(currentDayKey: String, forceReload: Bool) async {
        for tradition in TraditionFilter.allCases where tradition != selectedTradition {
            if !forceReload, store.loadVerse(for: tradition) != nil {
                loadedDayKeysByTradition[tradition] = currentDayKey
                continue
            }

            do {
                guard let verse = try await fetchVerse(for: tradition, currentDayKey: currentDayKey) else {
                    loadedDayKeysByTradition[tradition] = currentDayKey
                    continue
                }

                store.saveVerse(verse, for: tradition)
                loadedDayKeysByTradition[tradition] = currentDayKey
            } catch is CancellationError {
                return
            } catch {
                continue
            }
        }
    }
}

struct DailyVerseStore {
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = DharmaAppGroup.userDefaults) {
        self.userDefaults = userDefaults
    }

    var currentDayKey: String {
        Self.dayFormatter.string(from: Date())
    }

    func loadVerse(for tradition: DailyVerseViewModel.TraditionFilter, allowExpiredFallback: Bool = false) -> DailyVerse? {
        let storageKey = key(for: tradition)
        guard let data = userDefaults.data(forKey: storageKey),
              let payload = try? JSONDecoder().decode(DailyVersePayload.self, from: data) else {
            return nil
        }

        guard allowExpiredFallback || payload.dayKey == currentDayKey else {
            userDefaults.removeObject(forKey: storageKey)
            return nil
        }

        return payload.verse
    }

    func saveVerse(_ verse: DailyVerse, for tradition: DailyVerseViewModel.TraditionFilter) {
        let storageKey = key(for: tradition)
        let payload = DailyVersePayload(dayKey: currentDayKey, verse: verse)
        guard let data = try? JSONEncoder().encode(payload) else { return }
        userDefaults.set(data, forKey: storageKey)
        userDefaults.set(data, forKey: Self.widgetStorageKey)

#if canImport(WidgetKit)
        WidgetCenter.shared.reloadAllTimelines()
#endif
    }

    private func key(for tradition: DailyVerseViewModel.TraditionFilter) -> String {
        "dailyVerse.cached.\(tradition.rawValue.lowercased())"
    }

    private struct DailyVersePayload: Codable {
        let dayKey: String
        let verse: DailyVerse
    }

    private static let widgetStorageKey = "dailyVerse.widget.cached"

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .autoupdatingCurrent
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

private struct DailyVerseRecord: Decodable {
    let title: String
    let tradition: String
    let chapterNumber: Int
    let verseNumber: Int
    let text: String
    let traditionalText: String?

    var asDailyVerse: DailyVerse {
        DailyVerse(
            scriptureTitle: title,
            tradition: tradition,
            chapterNumber: chapterNumber,
            verseNumber: verseNumber,
            englishText: text,
            traditionalText: traditionalText
        )
    }

    enum CodingKeys: String, CodingKey {
        case title, tradition, text
        case chapterNumber = "chapter_number"
        case verseNumber = "verse_number"
        case traditionalText = "traditional_text"
    }
}