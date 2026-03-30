import Foundation

struct DailyTaskProgressState {
    let dayKey: String
    var completedTaskKeys: Set<String>
    var didSyncStreakCompletion: Bool

    static func empty(for dayKey: String) -> DailyTaskProgressState {
        DailyTaskProgressState(
            dayKey: dayKey,
            completedTaskKeys: [],
            didSyncStreakCompletion: false
        )
    }
}

struct DailyTaskProgressStore {
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func loadState(for userId: UUID?) -> DailyTaskProgressState {
        let dayKey = Self.currentDayKey
        let storageKey = key(for: userId)

        guard let data = userDefaults.data(forKey: storageKey),
              let payload = try? JSONDecoder().decode(Payload.self, from: data) else {
            return .empty(for: dayKey)
        }

        guard payload.dayKey == dayKey else {
            userDefaults.removeObject(forKey: storageKey)
            return .empty(for: dayKey)
        }

        return DailyTaskProgressState(
            dayKey: payload.dayKey,
            completedTaskKeys: Set(payload.completedTaskKeys),
            didSyncStreakCompletion: payload.didSyncStreakCompletion
        )
    }

    @discardableResult
    func setTask(_ taskType: DailyTask.TaskType, completed: Bool, for userId: UUID?) -> DailyTaskProgressState {
        var state = loadState(for: userId)

        if completed {
            state.completedTaskKeys.insert(taskType.storageKey)
        } else {
            state.completedTaskKeys.remove(taskType.storageKey)
        }

        saveState(state, for: userId)
        return state
    }

    func markStreakCompletionSynced(for userId: UUID?) {
        var state = loadState(for: userId)
        guard !state.didSyncStreakCompletion else { return }
        state.didSyncStreakCompletion = true
        saveState(state, for: userId)
    }

    private func saveState(_ state: DailyTaskProgressState, for userId: UUID?) {
        let payload = Payload(
            dayKey: state.dayKey,
            completedTaskKeys: state.completedTaskKeys.sorted(),
            didSyncStreakCompletion: state.didSyncStreakCompletion
        )

        guard let data = try? JSONEncoder().encode(payload) else { return }
        userDefaults.set(data, forKey: key(for: userId))
    }

    private func key(for userId: UUID?) -> String {
        let scope = userId?.uuidString.lowercased() ?? "anonymous"
        return "dailyTaskProgress.\(scope)"
    }

    private struct Payload: Codable {
        let dayKey: String
        let completedTaskKeys: [String]
        let didSyncStreakCompletion: Bool
    }

    static var currentDayKey: String {
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