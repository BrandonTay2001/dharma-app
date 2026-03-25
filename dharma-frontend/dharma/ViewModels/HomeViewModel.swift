import SwiftUI

@Observable
class HomeViewModel {
    var tasks: [DailyTask] = DailyTask.sampleTasks
    var streakCount: Int = 1
    
    var completedCount: Int {
        tasks.filter(\.isCompleted).count
    }
    
    var progressPercentage: Double {
        guard !tasks.isEmpty else { return 0 }
        return Double(completedCount) / Double(tasks.count)
    }
    
    var progressText: String {
        "\(Int(progressPercentage * 100))%"
    }
    
    func toggleTask(_ task: DailyTask) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
        }
    }
    
    func markTaskCompleted(_ task: DailyTask) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted = true
        }
    }
    
    // Current week dates
    var weekDates: [(dayLabel: String, dateNumber: Int, isToday: Bool)] {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        // Start from Monday
        let mondayOffset = weekday == 1 ? -6 : 2 - weekday
        
        let dayLabels = ["M", "T", "W", "T", "F", "S", "S"]
        
        return (0..<7).map { i in
            let date = calendar.date(byAdding: .day, value: mondayOffset + i, to: today)!
            let day = calendar.component(.day, from: date)
            let isToday = calendar.isDateInToday(date)
            return (dayLabels[i], day, isToday)
        }
    }
}
