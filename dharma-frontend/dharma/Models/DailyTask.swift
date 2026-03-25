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
