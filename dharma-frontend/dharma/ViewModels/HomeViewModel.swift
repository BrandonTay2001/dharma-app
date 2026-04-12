import Foundation
import Observation
import PostgREST
import Supabase

@Observable
@MainActor
final class HomeViewModel {
    var tasks: [DailyTask] = DailyTask.sampleTasks
    var streakCount: Int = 0
    var completedDates: Set<String> = []
    var upcomingSacredDates: [SacredObservance] = []
    var isLoadingSacredDates = false
    var sacredDatesErrorMessage: String?

    private let progressStore: DailyTaskProgressStore
    private let streakService: UserStreakService
    private var currentUserId: UUID?

    init(
        progressStore: DailyTaskProgressStore = DailyTaskProgressStore(),
        streakService: UserStreakService = UserStreakService()
    ) {
        self.progressStore = progressStore
        self.streakService = streakService

        Task {
            await refreshForCurrentContext()
        }
    }
    
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

    func refreshForCurrentContext() async {
        await loadCurrentUser()
        applyStoredProgress()
        await loadStreakCount()
        await loadCompletedDates()
        await loadUpcomingSacredDates()
        await syncCompletedDayIfNeeded()
    }
    
    func toggleTask(_ task: DailyTask) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
            _ = progressStore.setTask(tasks[index].taskType, completed: tasks[index].isCompleted, for: currentUserId)

            Task {
                await syncCompletedDayIfNeeded()
            }
        }
    }
    
    func markTaskCompleted(_ task: DailyTask) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            guard !tasks[index].isCompleted else { return }
            tasks[index].isCompleted = true
            _ = progressStore.setTask(tasks[index].taskType, completed: true, for: currentUserId)

            Task {
                await syncCompletedDayIfNeeded()
            }
        }
    }
    
    // Current week dates
    var weekDates: [(dayLabel: String, dateNumber: Int, isToday: Bool, isCompleted: Bool)] {
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
            let dateKey = Self.dayFormatter.string(from: date)
            let isCompleted = completedDates.contains(dateKey)
            return (dayLabels[i], day, isToday, isCompleted)
        }
    }

    private func loadCurrentUser() async {
        do {
            let session = try await supabase.auth.session
            currentUserId = session.user.id
        } catch {
            currentUserId = nil
            streakCount = 0
        }
    }

    private func applyStoredProgress() {
        let state = progressStore.loadState(for: currentUserId)

        tasks = DailyTask.sampleTasks.map { task in
            var updatedTask = task
            updatedTask.isCompleted = !state.completedTaskKeys.isDisjoint(with: task.taskType.completionStorageKeys)
            return updatedTask
        }
    }

    private func loadStreakCount() async {
        guard let currentUserId else {
            streakCount = 0
            return
        }

        do {
            streakCount = try await streakService.loadCurrentStreak(for: currentUserId)
        } catch {
            streakCount = 0
        }
    }

    private func loadCompletedDates() async {
        guard let currentUserId else {
            completedDates = []
            return
        }

        let calendar = Calendar.current
        let today = Date()
        guard let sevenDaysAgo = calendar.date(byAdding: .day, value: -6, to: today) else { return }
        let fromDate = Self.dayFormatter.string(from: sevenDaysAgo)

        do {
            let records: [DailyCompletionRecord] = try await supabase
                .from("daily_completions")
                .select("completed_date")
                .eq("user_id", value: currentUserId.uuidString.lowercased())
                .gte("completed_date", value: fromDate)
                .execute()
                .value
            completedDates = Set(records.map(\.completedDate))
        } catch {
            completedDates = []
        }
    }

    private func syncCompletedDayIfNeeded() async {
        guard progressPercentage >= 1 else { return }
        guard let currentUserId else { return }

        let state = progressStore.loadState(for: currentUserId)
        guard !state.didSyncStreakCompletion else { return }

        do {
            streakCount = try await streakService.completeDay(for: currentUserId, dayKey: state.dayKey)

            try await supabase
                .from("daily_completions")
                .upsert(
                    DailyCompletionInsert(userId: currentUserId, completedDate: state.dayKey),
                    onConflict: "user_id,completed_date"
                )
                .execute()
            completedDates.insert(state.dayKey)

            progressStore.markStreakCompletionSynced(for: currentUserId)
        } catch {
            return
        }
    }

    private func loadUpcomingSacredDates() async {
        guard !isLoadingSacredDates else { return }

        let today = Date()
        guard let sixDaysAhead = Calendar(identifier: .gregorian).date(byAdding: .day, value: 6, to: today) else {
            return
        }

        isLoadingSacredDates = true
        sacredDatesErrorMessage = nil
        defer { isLoadingSacredDates = false }

        let startDate = Self.dayFormatter.string(from: today)
        let endDate = Self.dayFormatter.string(from: sixDaysAhead)

        do {
            let records: [SacredObservanceRecord] = try await supabase
                .from("observances")
                .select("id, observance_date, title, tradition, summary, suggested_practice, ritual_steps, why_it_matters, is_major_observance")
                .gte("observance_date", value: startDate)
                .lte("observance_date", value: endDate)
                .order("observance_date", ascending: true)
                .order("title", ascending: true)
                .execute()
                .value

            upcomingSacredDates = records.compactMap(\.observance)

            if upcomingSacredDates.isEmpty {
                sacredDatesErrorMessage = nil
            }
        } catch is CancellationError {
            return
        } catch {
            sacredDatesErrorMessage = "Could not load sacred observances right now."
            upcomingSacredDates = []
        }
    }

    static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .autoupdatingCurrent
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

private struct SacredObservanceRecord: Decodable {
    let id: String
    let observanceDate: String
    let title: String
    let tradition: String
    let summary: String
    let suggestedPractice: String
    let ritualSteps: [String]
    let whyItMatters: String
    let isMajorObservance: Bool

    var observance: SacredObservance? {
        guard let date = HomeViewModel.dayFormatter.date(from: observanceDate),
              let parsedTradition = SacredObservance.Tradition(rawValue: tradition) else {
            return nil
        }

        return SacredObservance(
            id: id,
            date: date,
            title: title,
            tradition: parsedTradition,
            summary: summary,
            suggestedPractice: suggestedPractice,
            ritualSteps: ritualSteps,
            whyItMatters: whyItMatters,
            isMajorObservance: isMajorObservance
        )
    }

    enum CodingKeys: String, CodingKey {
        case id, title, tradition, summary
        case observanceDate = "observance_date"
        case suggestedPractice = "suggested_practice"
        case ritualSteps = "ritual_steps"
        case whyItMatters = "why_it_matters"
        case isMajorObservance = "is_major_observance"
    }
}

private struct DailyCompletionRecord: Decodable {
    let completedDate: String

    enum CodingKeys: String, CodingKey {
        case completedDate = "completed_date"
    }
}

private struct DailyCompletionInsert: Encodable {
    let userId: UUID
    let completedDate: String

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case completedDate = "completed_date"
    }
}

private struct UserStreakRecord: Decodable {
    let userId: UUID
    let currentStreak: Int
    let longestStreak: Int
    let lastActiveDate: String?

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case currentStreak = "current_streak"
        case longestStreak = "longest_streak"
        case lastActiveDate = "last_active_date"
    }
}

private struct UserStreakUpsert: Encodable {
    let userId: UUID
    let currentStreak: Int
    let longestStreak: Int
    let lastActiveDate: String

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case currentStreak = "current_streak"
        case longestStreak = "longest_streak"
        case lastActiveDate = "last_active_date"
    }
}

struct UserStreakService {
    func loadCurrentStreak(for userId: UUID) async throws -> Int {
        let records = try await loadRecords(for: userId)
        return displayedStreak(for: records.first)
    }

    func completeDay(for userId: UUID, dayKey: String) async throws -> Int {
        let record = try await loadRecords(for: userId).first

        if record?.lastActiveDate == dayKey {
            return record?.currentStreak ?? 1
        }

        let nextCurrentStreak = nextStreakAfterCompleting(record, on: dayKey)
        let nextLongestStreak = max(record?.longestStreak ?? 0, nextCurrentStreak)
        let payload = UserStreakUpsert(
            userId: userId,
            currentStreak: nextCurrentStreak,
            longestStreak: nextLongestStreak,
            lastActiveDate: dayKey
        )

        try await supabase
            .from("user_streaks")
            .upsert(payload, onConflict: "user_id")
            .execute()

        return nextCurrentStreak
    }

    private func loadRecords(for userId: UUID) async throws -> [UserStreakRecord] {
        try await supabase
            .from("user_streaks")
            .select()
            .eq("user_id", value: userId.uuidString.lowercased())
            .limit(1)
            .execute()
            .value
    }

    private func displayedStreak(for record: UserStreakRecord?) -> Int {
        guard let record else { return 0 }

        let todayKey = Self.dayFormatter.string(from: Date())

        guard record.lastActiveDate == todayKey || isPreviousDay(record.lastActiveDate, before: todayKey) else {
            return 0
        }

        return record.currentStreak
    }

    private func nextStreakAfterCompleting(_ record: UserStreakRecord?, on dayKey: String) -> Int {
        guard isPreviousDay(record?.lastActiveDate, before: dayKey) else {
            return 1
        }

        return (record?.currentStreak ?? 0) + 1
    }

    private func isPreviousDay(_ previousDayKey: String?, before currentDayKey: String) -> Bool {
        guard let previousDayKey,
              let previousDate = Self.dayFormatter.date(from: previousDayKey),
              let currentDate = Self.dayFormatter.date(from: currentDayKey),
              let expectedDate = Calendar(identifier: .gregorian).date(byAdding: .day, value: 1, to: previousDate) else {
            return false
        }

        return Calendar(identifier: .gregorian).isDate(expectedDate, inSameDayAs: currentDate)
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


