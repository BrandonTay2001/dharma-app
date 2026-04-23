import SwiftUI
import WidgetKit

struct DailyVerseWidgetEntry: TimelineEntry {
    let date: Date
    let verse: DailyVerseWidgetVerse
}

struct DailyVerseWidgetTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> DailyVerseWidgetEntry {
        DailyVerseWidgetEntry(date: Date(), verse: .widgetPreview)
    }

    func getSnapshot(in context: Context, completion: @escaping (DailyVerseWidgetEntry) -> Void) {
        completion(currentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DailyVerseWidgetEntry>) -> Void) {
        let entry = currentEntry()
        let refreshDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date().addingTimeInterval(3600)
        completion(Timeline(entries: [entry], policy: .after(refreshDate)))
    }

    private func currentEntry() -> DailyVerseWidgetEntry {
        let store = DailyVerseWidgetStore()
        if let entryData = store.loadEntryData() {
            return DailyVerseWidgetEntry(date: Date(), verse: entryData.verse)
        }

        return DailyVerseWidgetEntry(date: Date(), verse: .widgetPreview)
    }
}

struct DailyVerseWidgetEntryView: View {
    var entry: DailyVerseWidgetTimelineProvider.Entry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.white, DailyVerseWidgetPalette.surface],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .firstTextBaseline) {
                    Text(entry.verse.traditionIcon)
                        .font(.system(size: family == .systemSmall ? 20 : 24))

                    Spacer(minLength: 8)

                    Text("Daily Verse")
                        .font(.system(size: 11, weight: .semibold, design: .default))
                        .foregroundColor(DailyVerseWidgetPalette.saffron)
                        .tracking(1.2)
                }

                Text(entry.verse.englishText)
                    .font(.custom("Georgia", size: family == .systemSmall ? 15 : 17))
                    .foregroundColor(DailyVerseWidgetPalette.onSurface)
                    .lineLimit(family == .systemSmall ? 5 : 6)
                    .multilineTextAlignment(.leading)

                Spacer(minLength: 6)

                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.verse.referenceText)
                        .font(.system(size: 13, weight: .semibold, design: .default))
                        .foregroundColor(DailyVerseWidgetPalette.onSurface)

                    Text(entry.verse.traditionLabel)
                        .font(.system(size: 11, weight: .medium, design: .default))
                        .foregroundColor(DailyVerseWidgetPalette.secondaryText)
                }
            }
            .padding(family == .systemSmall ? 16 : 18)
        }
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [Color.white, DailyVerseWidgetPalette.surface],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

struct DailyVerseWidget: Widget {
    let kind: String = DailyVerseWidgetConfiguration.kind

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DailyVerseWidgetTimelineProvider()) { entry in
            DailyVerseWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Daily Verse")
        .description("Keep today’s verse from Dharma on your Home Screen.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

private struct DailyVerseWidgetStore {
    private let userDefaults = UserDefaults(suiteName: DailyVerseWidgetConfiguration.appGroupIdentifier) ?? .standard

    func loadEntryData() -> DailyVerseWidgetEntryData? {
        guard let data = userDefaults.data(forKey: DailyVerseWidgetConfiguration.storageKey),
              let payload = try? JSONDecoder().decode(DailyVerseWidgetEntryData.self, from: data) else {
            return nil
        }

        return payload
    }
}

private struct DailyVerseWidgetConfiguration {
    static let kind = "DailyVerseWidget"
    static let appGroupIdentifier = "group.xyz.618263.dharma"
    static let storageKey = "dailyVerse.widget.cached"
}

private struct DailyVerseWidgetPalette {
    static let saffron = Color(red: 1.0, green: 119.0 / 255.0, blue: 34.0 / 255.0)
    static let surface = Color(red: 249.0 / 255.0, green: 249.0 / 255.0, blue: 249.0 / 255.0)
    static let onSurface = Color(red: 26.0 / 255.0, green: 28.0 / 255.0, blue: 28.0 / 255.0)
    static let secondaryText = Color(red: 102.0 / 255.0, green: 102.0 / 255.0, blue: 102.0 / 255.0)
}

struct DailyVerseWidgetEntryData: Codable, Equatable {
    let dayKey: String
    let verse: DailyVerseWidgetVerse
}

struct DailyVerseWidgetVerse: Codable, Equatable {
    let scriptureTitle: String
    let tradition: String
    let chapterNumber: Int
    let verseNumber: Int
    let englishText: String
    let traditionalText: String?

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
}

private extension DailyVerseWidgetVerse {
    static let widgetPreview = DailyVerseWidgetVerse(
        scriptureTitle: "Bhagavad Gita",
        tradition: "Hindu",
        chapterNumber: 2,
        verseNumber: 47,
        englishText: "You have a right to perform your actions, but never to the fruits of those actions.",
        traditionalText: "karmaṇy-evādhikāras te mā phaleṣu kadācana"
    )
}

#Preview(as: .systemSmall) {
    DailyVerseWidget()
} timeline: {
    DailyVerseWidgetEntry(date: .now, verse: .widgetPreview)
}

#Preview(as: .systemMedium) {
    DailyVerseWidget()
} timeline: {
    DailyVerseWidgetEntry(date: .now, verse: .widgetPreview)
}
