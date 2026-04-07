import Foundation
import Observation

@Observable
@MainActor
final class OnboardingViewModel {
    enum Step: Int, CaseIterable {
        case intro
        case consent
        case name
        case belief
        case gender
        case ageRange
        case goals
        case guidedSupport
        case practices
        case timeAvailable
        case productTour
        case socialProof
        case generatingPlan
        case premium

        var progressValue: Double {
            switch self {
            case .intro:
                return 0.08
            case .consent:
                return 0.16
            case .name:
                return 0.24
            case .belief:
                return 0.32
            case .gender:
                return 0.40
            case .ageRange:
                return 0.48
            case .goals:
                return 0.56
            case .guidedSupport:
                return 0.64
            case .practices:
                return 0.72
            case .timeAvailable:
                return 0.80
            case .productTour:
                return 0.88
            case .socialProof:
                return 0.94
            case .generatingPlan, .premium:
                return 1.0
            }
        }

        var showsHeader: Bool {
            self != .intro && self != .premium
        }

        var showsContinueButton: Bool {
            self != .intro && self != .generatingPlan && self != .premium
        }
    }

    enum SpiritualBelief: String, CaseIterable, Identifiable {
        case hinduism
        case buddhism
        case spiritualMeditative
        case mindful
        case exploring

        var id: String { rawValue }

        var title: String {
            switch self {
            case .hinduism:
                return "Hinduism"
            case .buddhism:
                return "Buddhism"
            case .spiritualMeditative:
                return "Spiritual / meditative"
            case .mindful:
                return "Not religious - just mindful"
            case .exploring:
                return "I'm exploring all paths"
            }
        }

        var detail: String {
            switch self {
            case .hinduism:
                return "Vedas, Gita, deity calendar"
            case .buddhism:
                return "Dhammapada, mindfulness"
            case .spiritualMeditative:
                return "Not religious, inner focus"
            case .mindful:
                return "Calm, clarity, no doctrine"
            case .exploring:
                return "Show me everything"
            }
        }
    }

    enum GenderIdentity: String, CaseIterable, Identifiable {
        case male
        case female
        case preferNotToSay

        var id: String { rawValue }

        var title: String {
            switch self {
            case .male:
                return "Male"
            case .female:
                return "Female"
            case .preferNotToSay:
                return "Prefer not to say"
            }
        }
    }

    enum AgeRange: String, CaseIterable, Identifiable {
        case under18
        case age18to24
        case age25to34
        case age35to44
        case age45to59
        case age60Plus

        var id: String { rawValue }

        var title: String {
            switch self {
            case .under18:
                return "Under 18"
            case .age18to24:
                return "18-24"
            case .age25to34:
                return "25-34"
            case .age35to44:
                return "35-44"
            case .age45to59:
                return "45-59"
            case .age60Plus:
                return "60+"
            }
        }
    }

    enum Goal: String, CaseIterable, Identifiable {
        case innerPeace
        case understandTexts
        case dailyPractice
        case findPath
        case deepenKnowledge
        case manageStress
        case reconnectRoots

        var id: String { rawValue }

        var title: String {
            switch self {
            case .innerPeace:
                return "Find inner peace and calm"
            case .understandTexts:
                return "Understand sacred texts"
            case .dailyPractice:
                return "Build a daily spiritual practice"
            case .findPath:
                return "Find my spiritual path"
            case .deepenKnowledge:
                return "Deepen my religious knowledge"
            case .manageStress:
                return "Manage stress and anxiety"
            case .reconnectRoots:
                return "Reconnect with my roots"
            }
        }

        var detail: String {
            switch self {
            case .innerPeace:
                return "Reduce anxiety, quiet the mind"
            case .understandTexts:
                return "Gita, Vedas, Dhammapada"
            case .dailyPractice:
                return "Consistency and routine"
            case .findPath:
                return "Still exploring, seeking clarity"
            case .deepenKnowledge:
                return "Go beyond the basics"
            case .manageStress:
                return "Tools for difficult moments"
            case .reconnectRoots:
                return "Return to a tradition you grew up with"
            }
        }
    }

    enum Practice: String, CaseIterable, Identifiable {
        case breathwork
        case guidedMeditation
        case chanting
        case prayerRituals
        case scriptureReading
        case journaling
        case silentSitting

        var id: String { rawValue }

        var title: String {
            switch self {
            case .breathwork:
                return "Breathwork"
            case .guidedMeditation:
                return "Guided meditation"
            case .chanting:
                return "Chanting / mantras"
            case .prayerRituals:
                return "Prayer / rituals"
            case .scriptureReading:
                return "Scripture reading"
            case .journaling:
                return "Journaling / reflection"
            case .silentSitting:
                return "Silent sitting"
            }
        }

        var detail: String {
            switch self {
            case .breathwork:
                return "Pranayama and breathing exercises"
            case .guidedMeditation:
                return "Audio-led sessions"
            case .chanting:
                return "Om, Gayatri, affirmations"
            case .prayerRituals:
                return "Puja, offerings, lighting lamps"
            case .scriptureReading:
                return "Verses, sutras, sacred text"
            case .journaling:
                return "Prompted daily writing"
            case .silentSitting:
                return "No guidance, just stillness"
            }
        }
    }

    enum DailyTime: String, CaseIterable, Identifiable {
        case fiveMinutes
        case tenToFifteen
        case twentyToThirty
        case thirtyPlus

        var id: String { rawValue }

        var title: String {
            switch self {
            case .fiveMinutes:
                return "5 minutes"
            case .tenToFifteen:
                return "10-15 minutes"
            case .twentyToThirty:
                return "20-30 minutes"
            case .thirtyPlus:
                return "30+ minutes"
            }
        }

        var detail: String {
            switch self {
            case .fiveMinutes:
                return "A morning verse and one breath exercise"
            case .tenToFifteen:
                return "Verse plus a short meditation or mantra"
            case .twentyToThirty:
                return "A full practice with ritual"
            case .thirtyPlus:
                return "Deep daily sadhana"
            }
        }
    }

    struct ProductPanel: Identifiable {
        let id: Int
        let symbol: String
        let title: String
        let body: String
    }

    private enum StorageKey {
        static let name = "onboarding.name"
        static let beliefs = "onboarding.beliefs"
        static let gender = "onboarding.gender"
        static let ageRange = "onboarding.ageRange"
        static let goals = "onboarding.goals"
        static let practices = "onboarding.practices"
        static let dailyTime = "onboarding.dailyTime"
    }

    var currentStep: Step = .intro
    var name = ""
    var selectedBeliefs: Set<SpiritualBelief> = []
    var gender: GenderIdentity?
    var ageRange: AgeRange?
    var selectedGoals: [Goal] = []
    var selectedPractices: Set<Practice> = []
    var dailyTime: DailyTime?
    var currentProductPanel = 0
    var loadingMessageIndex = 0
    var isGeneratingPlan = false
    var showSignInAlert = false

    let productPanels: [ProductPanel] = [
        ProductPanel(
            id: 0,
            symbol: "sunrise.fill",
            title: "Your daily verse, delivered at dawn.",
            body: "A new verse from the Bhagavad Gita, Dhammapada, or Tao Te Ching every morning, explained in plain language by your AI mentor."
        ),
        ProductPanel(
            id: 1,
            symbol: "bubble.left.and.text.bubble.right.fill",
            title: "Ask anything. Get wisdom rooted in the Vedas.",
            body: "Your AI spiritual mentor answers questions about life, purpose, and practice with guidance shaped by sacred texts."
        ),
        ProductPanel(
            id: 2,
            symbol: "sparkles.rectangle.stack.fill",
            title: "Your daily dharmic task, always personalised.",
            body: "Each morning Dharma tells you exactly what to do, from meditation and mantra to ritual and fasting aligned with the calendar."
        )
    ]

    init() {
        restoreProgress()
    }

    var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var primaryGoalSummary: String {
        selectedGoals.first?.title ?? "a steadier spiritual rhythm"
    }

    var secondaryGoalSummary: String? {
        guard selectedGoals.count > 1 else {
            return nil
        }

        return selectedGoals[1].title.lowercased()
    }

    var selectedTraditionsSummary: String {
        if selectedBeliefs.isEmpty {
            return "Hindu and Buddhist wisdom"
        }

        return selectedBeliefs
            .map(\.title)
            .sorted()
            .joined(separator: " • ")
    }

    var selectedPracticeSummary: String {
        let titles = selectedPractices.map(\.title).sorted()

        if titles.isEmpty {
            return "reflection, stillness, and sacred reading"
        }

        return titles.prefix(3).joined(separator: " • ")
    }

    var loadingMessages: [String] {
        [
            "Gathering wisdom...",
            alignmentMessage,
            "Building your plan..."
        ]
    }

    var canContinue: Bool {
        switch currentStep {
        case .intro, .consent, .gender, .ageRange, .guidedSupport, .productTour, .socialProof, .premium:
            return true
        case .name:
            return !trimmedName.isEmpty
        case .belief:
            return !selectedBeliefs.isEmpty
        case .goals:
            return !selectedGoals.isEmpty
        case .practices:
            return true
        case .timeAvailable:
            return dailyTime != nil
        case .generatingPlan:
            return false
        }
    }

    func advance() {
        guard canContinue else {
            return
        }

        persistProgress()

        switch currentStep {
        case .intro:
            currentStep = .consent
        case .consent:
            currentStep = .name
        case .name:
            currentStep = .belief
        case .belief:
            currentStep = .gender
        case .gender:
            currentStep = .ageRange
        case .ageRange:
            currentStep = .goals
        case .goals:
            currentStep = .guidedSupport
        case .guidedSupport:
            currentStep = .practices
        case .practices:
            currentStep = .timeAvailable
        case .timeAvailable:
            currentStep = .productTour
        case .productTour:
            currentStep = .socialProof
        case .socialProof:
            currentStep = .generatingPlan
        case .generatingPlan, .premium:
            break
        }
    }

    func goBack() {
        switch currentStep {
        case .intro:
            break
        case .consent:
            currentStep = .intro
        case .name:
            currentStep = .consent
        case .belief:
            currentStep = .name
        case .gender:
            currentStep = .belief
        case .ageRange:
            currentStep = .gender
        case .goals:
            currentStep = .ageRange
        case .guidedSupport:
            currentStep = .goals
        case .practices:
            currentStep = .guidedSupport
        case .timeAvailable:
            currentStep = .practices
        case .productTour:
            currentStep = .timeAvailable
        case .socialProof:
            currentStep = .productTour
        case .generatingPlan:
            currentStep = .socialProof
        case .premium:
            currentStep = .socialProof
        }
    }

    func toggleBelief(_ belief: SpiritualBelief) {
        if selectedBeliefs.contains(belief) {
            selectedBeliefs.remove(belief)
        } else {
            selectedBeliefs.insert(belief)
        }
    }

    func toggleGoal(_ goal: Goal) {
        if let existingIndex = selectedGoals.firstIndex(of: goal) {
            selectedGoals.remove(at: existingIndex)
            return
        }

        guard selectedGoals.count < 2 else {
            selectedGoals.removeFirst()
            selectedGoals.append(goal)
            return
        }

        selectedGoals.append(goal)
    }

    func togglePractice(_ practice: Practice) {
        if selectedPractices.contains(practice) {
            selectedPractices.remove(practice)
        } else {
            selectedPractices.insert(practice)
        }
    }

    func handleSignInTap(superwallViewModel: SuperwallViewModel, authViewModel: AuthViewModel) {
        authViewModel.displayName = trimmedName

        if superwallViewModel.unlockAuthFlowForExistingSubscriber() {
            return
        }

        showSignInAlert = true
    }

    func beginPlanGenerationIfNeeded() async {
        guard currentStep == .generatingPlan, !isGeneratingPlan else {
            return
        }

        isGeneratingPlan = true
        loadingMessageIndex = 0

        for index in loadingMessages.indices {
            loadingMessageIndex = index
            try? await Task.sleep(nanoseconds: 1_500_000_000)
        }

        try? await Task.sleep(nanoseconds: 1_500_000_000)
        currentStep = .premium
        isGeneratingPlan = false
        persistProgress()
    }

    func prepareAuth(_ authViewModel: AuthViewModel) {
        authViewModel.displayName = trimmedName
    }

    private var alignmentMessage: String {
        if selectedBeliefs.contains(.hinduism) && selectedBeliefs.count == 1 {
            return "Aligning with Hinduism..."
        }

        if selectedBeliefs.contains(.buddhism) && selectedBeliefs.count == 1 {
            return "Aligning with Buddhism..."
        }

        return "Aligning your path..."
    }

    private func restoreProgress() {
        let defaults = UserDefaults.standard

        name = defaults.string(forKey: StorageKey.name) ?? ""

        if let storedBeliefs = defaults.stringArray(forKey: StorageKey.beliefs) {
            selectedBeliefs = Set(storedBeliefs.compactMap(SpiritualBelief.init(rawValue:)))
        }

        if let rawGender = defaults.string(forKey: StorageKey.gender) {
            gender = GenderIdentity(rawValue: rawGender)
        }

        if let rawAgeRange = defaults.string(forKey: StorageKey.ageRange) {
            ageRange = AgeRange(rawValue: rawAgeRange)
        }

        if let storedGoals = defaults.stringArray(forKey: StorageKey.goals) {
            selectedGoals = storedGoals.compactMap(Goal.init(rawValue:))
        }

        if let storedPractices = defaults.stringArray(forKey: StorageKey.practices) {
            selectedPractices = Set(storedPractices.compactMap(Practice.init(rawValue:)))
        }

        if let rawDailyTime = defaults.string(forKey: StorageKey.dailyTime) {
            dailyTime = DailyTime(rawValue: rawDailyTime)
        }
    }

    private func persistProgress() {
        let defaults = UserDefaults.standard

        defaults.set(trimmedName, forKey: StorageKey.name)
        defaults.set(selectedBeliefs.map(\.rawValue), forKey: StorageKey.beliefs)
        defaults.set(gender?.rawValue, forKey: StorageKey.gender)
        defaults.set(ageRange?.rawValue, forKey: StorageKey.ageRange)
        defaults.set(selectedGoals.map(\.rawValue), forKey: StorageKey.goals)
        defaults.set(selectedPractices.map(\.rawValue), forKey: StorageKey.practices)
        defaults.set(dailyTime?.rawValue, forKey: StorageKey.dailyTime)
    }
}