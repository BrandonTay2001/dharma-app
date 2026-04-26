import AppIntents
import SwiftUI
import WidgetKit

struct DailyVerseWidgetEntry: TimelineEntry {
    let date: Date
    let selectedTradition: DailyVerseWidgetTradition
    let verse: DailyVerseWidgetVerse
}

struct DailyVerseWidgetTimelineProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> DailyVerseWidgetEntry {
        DailyVerseWidgetEntry(
            date: Date(),
            selectedTradition: .hindu,
            verse: .widgetPreview(for: .hindu)
        )
    }

    func snapshot(for configuration: DailyVerseWidgetIntent, in context: Context) async -> DailyVerseWidgetEntry {
        currentEntry(for: configuration.selectedTradition)
    }

    func timeline(for configuration: DailyVerseWidgetIntent, in context: Context) async -> Timeline<DailyVerseWidgetEntry> {
        let entry = currentEntry(for: configuration.selectedTradition)
        let refreshDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date().addingTimeInterval(3600)
        return Timeline(entries: [entry], policy: .after(refreshDate))
    }

    private func currentEntry(for tradition: DailyVerseWidgetTradition) -> DailyVerseWidgetEntry {
        let store = DailyVerseWidgetStore()
        if let entryData = store.loadEntryData(for: tradition) {
            return DailyVerseWidgetEntry(date: Date(), selectedTradition: tradition, verse: entryData.verse)
        }

        return DailyVerseWidgetEntry(
            date: Date(),
            selectedTradition: tradition,
            verse: .widgetPreview(for: tradition)
        )
    }
}

struct DailyVerseWidgetEntryView: View {
    var entry: DailyVerseWidgetTimelineProvider.Entry

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
                        .font(.system(size: 24))

                    Spacer(minLength: 8)

                    Text("Daily Verse")
                        .font(.system(size: 11, weight: .semibold, design: .default))
                        .foregroundColor(DailyVerseWidgetPalette.saffron)
                        .tracking(1.2)
                }

                Text(entry.verse.englishText)
                    .font(.custom("Georgia", size: 17))
                    .foregroundColor(DailyVerseWidgetPalette.onSurface)
                    .lineLimit(6)
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
            .padding(18)
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
        AppIntentConfiguration(kind: kind, intent: DailyVerseWidgetIntent.self, provider: DailyVerseWidgetTimelineProvider()) { entry in
            DailyVerseWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Daily Verse")
        .description("Keep today's verse from Dharma on your Home Screen and choose a tradition for each widget.")
        .supportedFamilies([.systemMedium])
    }
}

enum DailyVerseWidgetTradition: String, AppEnum {
    case hindu
    case buddhist

    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Tradition")

    static let caseDisplayRepresentations: [DailyVerseWidgetTradition: DisplayRepresentation] = [
        .hindu: DisplayRepresentation(title: "Hindu"),
        .buddhist: DisplayRepresentation(title: "Buddhist")
    ]

    var verseTradition: String {
        switch self {
        case .hindu:
            return "Hindu"
        case .buddhist:
            return "Buddhist"
        }
    }

    var storageKey: String {
        switch self {
        case .hindu:
            return "dailyVerse.cached.hindu"
        case .buddhist:
            return "dailyVerse.cached.buddhist"
        }
    }
}

struct DailyVerseWidgetIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Daily Verse"
    static let description = IntentDescription("Choose which tradition this widget should display.")

    @Parameter(title: "Tradition", default: .hindu)
    var tradition: DailyVerseWidgetTradition?

    var selectedTradition: DailyVerseWidgetTradition {
        tradition ?? .hindu
    }

    init() {
        tradition = .hindu
    }

    init(tradition: DailyVerseWidgetTradition) {
        self.tradition = tradition
    }
}

private struct DailyVerseWidgetStore {
    private let userDefaults = UserDefaults(suiteName: DailyVerseWidgetConfiguration.appGroupIdentifier) ?? .standard

    func loadEntryData(for tradition: DailyVerseWidgetTradition) -> DailyVerseWidgetEntryData? {
        if let payload = loadPayload(forKey: tradition.storageKey), payload.verse.tradition == tradition.verseTradition {
            return payload
        }

        guard let fallbackPayload = loadPayload(forKey: DailyVerseWidgetConfiguration.legacyStorageKey),
              fallbackPayload.verse.tradition == tradition.verseTradition else {
            return nil
        }

        return fallbackPayload
    }

    private func loadPayload(forKey key: String) -> DailyVerseWidgetEntryData? {
        guard let data = userDefaults.data(forKey: key),
              let payload = try? JSONDecoder().decode(DailyVerseWidgetEntryData.self, from: data) else {
            return nil
        }

        return payload
    }
}

private struct DailyVerseWidgetConfiguration {
    static let kind = "DailyVerseWidget"
    static let appGroupIdentifier = "group.xyz.618263.dharma"
    static let legacyStorageKey = "dailyVerse.widget.cached"
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
    static func widgetPreview(for tradition: DailyVerseWidgetTradition) -> DailyVerseWidgetVerse {
        switch tradition {
        case .hindu:
            return DailyVerseWidgetVerse(
                scriptureTitle: "Bhagavad Gita",
                tradition: "Hindu",
                chapterNumber: 2,
                verseNumber: 47,
                englishText: "You have a right to perform your actions, but never to the fruits of those actions.",
                traditionalText: "karmaṇy-evādhikāras te mā phaleṣu kadācana"
            )
        case .buddhist:
            return DailyVerseWidgetVerse(
                scriptureTitle: "Dhammapada",
                tradition: "Buddhist",
                chapterNumber: 1,
                verseNumber: 5,
                englishText: "For hatred does not cease by hatred at any time: hatred ceases by love. This is an old rule.",
                traditionalText: nil
            )
        }
    }
}

#Preview(as: .systemMedium) {
    DailyVerseWidget()
} timeline: {
    DailyVerseWidgetEntry(date: .now, selectedTradition: .hindu, verse: .widgetPreview(for: .hindu))
}