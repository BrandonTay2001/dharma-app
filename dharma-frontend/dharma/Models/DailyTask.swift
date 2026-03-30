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
    
    enum TaskType {
        case hinduVerse
        case buddhistVerse
        case meditation
        case mantra
        case journal
        case gratitude
    }
}

extension DailyTask.TaskType {
    var storageKey: String {
        switch self {
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
        }
    }

    var verseTitle: String {
        switch self {
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
            title: "DAILY HINDU\nVERSE",
            subtitle: "Bhagavad Gita",
            duration: "1 MIN",
            icon: "🛕",
            color: DharmaTheme.Colors.cardHindu,
            isCompleted: false,
            taskType: .hinduVerse
        ),
        DailyTask(
            title: "DAILY BUDDHIST\nVERSE",
            subtitle: "Dhammapada",
            duration: "1 MIN",
            icon: "🪷",
            color: DharmaTheme.Colors.cardBuddhist,
            isCompleted: false,
            taskType: .buddhistVerse
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
    ]
}
