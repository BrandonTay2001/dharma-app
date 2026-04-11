import SwiftUI

struct DailyTask: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let duration: String
    let icon: String      // SF Symbol or emoji
    let color: Color
    var isCompleted: Bool
    let taskType: TaskType
    
    enum TaskType: Hashable {
        case dailyVerse
        case hinduVerse
        case buddhistVerse
        case meditation
        case mantra
        case journal
        case gratitude
        case sacredDates
    }
}

extension DailyTask.TaskType {
    var storageKey: String {
        switch self {
        case .dailyVerse:
            return "dailyVerse"
        case .hinduVerse:
            return "hinduVerse"
        case .buddhistVerse:
            return "buddhistVerse"
        case .meditation:
            return "meditation"
        case .mantra:
            return "mantra"
        case .journal:
            return "journal"
        case .gratitude:
            return "gratitude"
        case .sacredDates:
            return "sacredDates"
        }
    }

    var completionStorageKeys: Set<String> {
        switch self {
        case .dailyVerse:
            return [storageKey, DailyTask.TaskType.hinduVerse.storageKey, DailyTask.TaskType.buddhistVerse.storageKey]
        default:
            return [storageKey]
        }
    }

    var versePickerTitle: String {
        switch self {
        case .hinduVerse:
            return "Hindu"
        case .buddhistVerse:
            return "Buddhist"
        default:
            return "Daily Verse"
        }
    }

    var verseIcon: String {
        switch self {
        case .hinduVerse:
            return "🛕"
        case .buddhistVerse:
            return "🪷"
        default:
            return "📖"
        }
    }

    static var selectableVerseTypes: [Self] {
        [.hinduVerse, .buddhistVerse]
    }

    var verseTitle: String {
        switch self {
        case .dailyVerse:
            return "VERSE OF THE DAY"
        case .hinduVerse:
            return "VERSE OF THE DAY • GITA"
        case .buddhistVerse:
            return "VERSE OF THE DAY • DHAMMAPADA"
        default:
            return "VERSE OF THE DAY"
        }
    }

    var verseText: String {
        switch self {
        case .dailyVerse:
            return "Choose Hindu or Buddhist above to read today’s verse."
        case .hinduVerse:
            return "You have a right to perform your prescribed duties, but you are not entitled to the fruits of your actions. Never consider yourself to be the cause of the results of your activities, nor be attached to inaction.\n\n— Bhagavad Gita 2.47"
        case .buddhistVerse:
            return "All that we are is the result of what we have thought: it is founded on our thoughts, it is made up of our thoughts. If a man speaks or acts with a pure thought, happiness follows him, like a shadow that never leaves him.\n\n— Dhammapada 1.2"
        default:
            return "O Seeker of Truth, open your heart to the path of enlightenment. Embrace the wisdom that guides you towards inner peace and understanding."
        }
    }

    var verseExplanationPrompt: String {
        "Please explain this daily verse in simple language, share the spiritual meaning from its tradition, and suggest one practical way to apply it today:\n\n\(verseText)"
    }
}

extension DailyTask {
    static let sampleTasks: [DailyTask] = [
        DailyTask(
            title: "DAILY VERSE",
            subtitle: "A new sacred passage",
            duration: "1 MIN",
            icon: "📖",
            color: DharmaTheme.Colors.cardHindu,
            isCompleted: false,
            taskType: .dailyVerse
        ),
        DailyTask(
            title: "GUIDED\nMEDITATION",
            subtitle: "Mindfulness",
            duration: "3 MIN",
            icon: "🧘",
            color: DharmaTheme.Colors.cardMeditation,
            isCompleted: false,
            taskType: .meditation
        ),
        DailyTask(
            title: "DAILY MANTRA",
            subtitle: "Om Chanting",
            duration: "2 MIN",
            icon: "🕉️",
            color: DharmaTheme.Colors.cardMantra,
            isCompleted: false,
            taskType: .mantra
        ),
        DailyTask(
            title: "GRATITUDE\nJOURNAL",
            subtitle: "Reflect & Write",
            duration: "3 MIN",
            icon: "📝",
            color: DharmaTheme.Colors.cardGratitude,
            isCompleted: false,
            taskType: .gratitude
        ),
        DailyTask(
            title: "SACRED\nOBSERVANCE",
            subtitle: "Hindu & Buddhist",
            duration: "1 MIN",
            icon: "🪔",
            color: DharmaTheme.Colors.cardHindu,
            isCompleted: false,
            taskType: .sacredDates
        ),
    ]
}
