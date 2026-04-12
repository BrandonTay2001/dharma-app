import Foundation

struct SacredObservance: Identifiable, Equatable, Hashable {
    enum Tradition: String {
        case buddhist
        case hindu
        case shared

        var label: String {
            switch self {
            case .buddhist:
                return "BUDDHIST"
            case .hindu:
                return "HINDU"
            case .shared:
                return "SHARED"
            }
        }

        var icon: String {
            switch self {
            case .buddhist:
                return "🪷"
            case .hindu:
                return "🪔"
            case .shared:
                return "☀️"
            }
        }
    }

    let id: String
    let date: Date
    let title: String
    let tradition: Tradition
    let summary: String
    let suggestedPractice: String
    let ritualSteps: [String]
    let whyItMatters: String
    let isMajorObservance: Bool
    
    init(
        id: String,
        date: Date,
        title: String,
        tradition: Tradition,
        summary: String,
        suggestedPractice: String,
        ritualSteps: [String],
        whyItMatters: String,
        isMajorObservance: Bool
    ) {
        self.id = id
        self.date = date
        self.title = title
        self.tradition = tradition
        self.summary = summary
        self.suggestedPractice = suggestedPractice
        self.ritualSteps = ritualSteps
        self.whyItMatters = whyItMatters
        self.isMajorObservance = isMajorObservance
    }

    init(
        date: Date,
        title: String,
        tradition: Tradition,
        summary: String,
        suggestedPractice: String,
        ritualSteps: [String],
        whyItMatters: String,
        isMajorObservance: Bool
    ) {
        self.date = date
        self.title = title
        self.tradition = tradition
        self.summary = summary
        self.suggestedPractice = suggestedPractice
        self.ritualSteps = ritualSteps
        self.whyItMatters = whyItMatters
        self.isMajorObservance = isMajorObservance
        self.id = Self.makeGeneratedID(date: date, title: title)
    }

    var weekdayLabel: String {
        Self.weekdayFormatter.string(from: date).uppercased()
    }

    var shortWeekdayLabel: String {
        Self.shortWeekdayFormatter.string(from: date).uppercased()
    }

    var dayNumber: String {
        Self.dayFormatter.string(from: date)
    }

    var monthDayLabel: String {
        Self.monthDayFormatter.string(from: date)
    }

    var relativeLabel: String {
        if Calendar.current.isDateInToday(date) {
            return "TODAY"
        }

        if Calendar.current.isDateInTomorrow(date) {
            return "TOMORROW"
        }

        return weekdayLabel
    }

    private static let weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEEE"
        return formatter
    }()

    private static let shortWeekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "E"
        return formatter
    }()

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "d"
        return formatter
    }()

    private static let monthDayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM d"
        return formatter
    }()

    private static let dayKeyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .autoupdatingCurrent
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private static func makeGeneratedID(date: Date, title: String) -> String {
        "\(dayKeyFormatter.string(from: date))-\(title)"
    }
}

enum SacredObservancePlanner {
    static func nextSevenDays(from startDate: Date = Date()) -> [SacredObservance] {
        let calendar = Calendar(identifier: .gregorian)
        let startOfDay = calendar.startOfDay(for: startDate)

        return (0..<7).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: startOfDay) else {
                return nil
            }

            return observance(for: date)
        }
    }

    private static func observance(for date: Date) -> SacredObservance {
        if let lunarObservance = lunarObservance(for: date) {
            return lunarObservance
        }

        return weekdayObservance(for: date)
    }

    private static func lunarObservance(for date: Date) -> SacredObservance? {
        let age = lunarAge(for: date)

        if age < 1.2 || age > synodicMonth - 1.2 {
            return SacredObservance(
                date: date,
                title: "Amavasya Reflection",
                tradition: .shared,
                summary: "The dark moon invites a simpler rhythm, quiet remembrance, and a clear reset of intention.",
                suggestedPractice: "Light a single lamp at dusk, remember your teachers or ancestors, and let go of one draining habit.",
                ritualSteps: [
                    "Keep the evening uncluttered and light a small lamp or candle.",
                    "Offer a short prayer of gratitude to your teachers, family line, or spiritual guides.",
                    "Write down one pattern you are ready to release before tomorrow begins."
                ],
                whyItMatters: "New-moon observances across Hindu and Buddhist practice are often used for restraint, remembrance, and beginning again with a steadier mind.",
                isMajorObservance: true
            )
        }

        if abs(age - 14.77) < 1.1 {
            return SacredObservance(
                date: date,
                title: "Purnima / Full Moon Uposatha",
                tradition: .shared,
                summary: "A bright-moon observance suited for generosity, scripture study, and a calmer evening practice.",
                suggestedPractice: "Light a lamp, offer flowers or water, and read one sacred verse before sitting in silence for ten minutes.",
                ritualSteps: [
                    "Place a lamp, candle, or diya in a clean corner of your home.",
                    "Offer water, fruit, or flowers with a brief moment of gratitude.",
                    "Read a verse from the Gita or Dhammapada, then sit quietly and let one line stay with you."
                ],
                whyItMatters: "Full-moon days are traditionally used to renew discipline and soften the heart through contemplation, ethical restraint, and devotion.",
                isMajorObservance: true
            )
        }

        if abs(age - 7.38) < 0.9 || abs(age - 22.15) < 0.9 {
            return SacredObservance(
                date: date,
                title: "Uposatha Day",
                tradition: .buddhist,
                summary: "A moon-observance day for extra mindfulness, careful speech, and a little more silence than usual.",
                suggestedPractice: "Keep one meal simple, speak gently, and sit for a longer meditation than you usually do.",
                ritualSteps: [
                    "Begin the day with three conscious breaths before checking your phone.",
                    "Choose one form of restraint today: simpler food, gentler speech, or less distraction.",
                    "Close the day with ten to fifteen minutes of seated mindfulness."
                ],
                whyItMatters: "In Buddhist traditions, Uposatha days mark a return to clarity through ethical care, meditation, and recollection of the teachings.",
                isMajorObservance: true
            )
        }

        if abs(age - 10.83) < 0.75 || abs(age - 25.6) < 0.75 {
            return SacredObservance(
                date: date,
                title: "Ekadashi",
                tradition: .hindu,
                summary: "A classic devotional fast day that favors simplicity, mantra, and lighter attachment to routine cravings.",
                suggestedPractice: "If your health allows, eat lightly, light a lamp in the evening, and chant your mantra with steadier attention.",
                ritualSteps: [
                    "Simplify one meal or avoid snacking as an offering of discipline.",
                    "Light a lamp near sunset and sit upright for a few quiet breaths.",
                    "Repeat a chosen mantra 108 times or read a short Gita passage slowly."
                ],
                whyItMatters: "Ekadashi is widely observed as a day to reduce heaviness, turn inward, and let devotion become more intentional.",
                isMajorObservance: true
            )
        }

        return nil
    }

    private static func weekdayObservance(for date: Date) -> SacredObservance {
        switch Calendar(identifier: .gregorian).component(.weekday, from: date) {
        case 1:
            return SacredObservance(
                date: date,
                title: "Surya Gratitude Morning",
                tradition: .hindu,
                summary: "Sunday is a strong day for light, vitality, and beginning the week with reverence.",
                suggestedPractice: "Face the morning light, offer water or folded hands, and name one intention for the week ahead.",
                ritualSteps: [
                    "Step into morning sunlight or stand by a bright window.",
                    "Offer a glass of water mentally to the sun, or simply bow with gratitude.",
                    "Speak one sentence about how you want to carry yourself this week."
                ],
                whyItMatters: "A sun-centered ritual creates steadiness and warmth before the week becomes noisy.",
                isMajorObservance: false
            )
        case 2:
            return SacredObservance(
                date: date,
                title: "Somvar Lamp Offering",
                tradition: .hindu,
                summary: "Monday carries a devotional Shiva rhythm and pairs well with calm, uncluttered practice.",
                suggestedPractice: "Light a lamp in the evening, offer water, and let your mantra be slower than usual.",
                ritualSteps: [
                    "Place a lamp or candle in a quiet corner before dinner or at dusk.",
                    "Offer a little water or a flower with a brief bow.",
                    "Repeat 'Om Namah Shivaya' or your chosen mantra for a few minutes."
                ],
                whyItMatters: "Somvar observance is traditionally linked with steadiness, surrender, and inner cooling.",
                isMajorObservance: false
            )
        case 3:
            return SacredObservance(
                date: date,
                title: "Metta Practice Day",
                tradition: .buddhist,
                summary: "A simple loving-kindness day softens irritation and brings your practice into ordinary relationships.",
                suggestedPractice: "Pause midday and offer three rounds of loving-kindness to yourself, a friend, and someone difficult.",
                ritualSteps: [
                    "Take one quiet minute before lunch or in the afternoon.",
                    "Repeat: 'May I be peaceful. May you be peaceful. May all beings be peaceful.'",
                    "Send one kind message or do one unannounced helpful act."
                ],
                whyItMatters: "Compassion practice turns spiritual effort outward and keeps discipline from becoming rigid.",
                isMajorObservance: false
            )
        case 4:
            return SacredObservance(
                date: date,
                title: "Study and Clarity Day",
                tradition: .shared,
                summary: "Midweek is well suited to learning, chanting, and returning your mind to a clean line of teaching.",
                suggestedPractice: "Read one page of scripture slowly and write down a single sentence you want to remember.",
                ritualSteps: [
                    "Open a sacred text or saved teaching for five focused minutes.",
                    "Underline or note one line that feels precise and alive.",
                    "Carry that line with you and return to it once before sleep."
                ],
                whyItMatters: "A study ritual gives the week a center and keeps insight close to lived behavior.",
                isMajorObservance: false
            )
        case 5:
            return SacredObservance(
                date: date,
                title: "Guruvar Blessing",
                tradition: .shared,
                summary: "Thursday traditionally honors wisdom, teachers, and the humility required to keep learning.",
                suggestedPractice: "Light a lamp, remember the people who shaped your path, and study one verse with full attention.",
                ritualSteps: [
                    "Light a lamp or sit upright for a few still breaths before beginning.",
                    "Name one teacher, elder, or lineage that helped you see more clearly.",
                    "Read one verse or teaching and ask what it changes in today's conduct."
                ],
                whyItMatters: "Teacher-centered observances interrupt self-importance and return practice to gratitude and lineage.",
                isMajorObservance: false
            )
        case 6:
            return SacredObservance(
                date: date,
                title: "Lakshmi and Gratitude Friday",
                tradition: .hindu,
                summary: "Friday carries a gentle devotional quality suited to beauty, abundance, and heartfelt thanks.",
                suggestedPractice: "Tidy one small space, light a lamp, and offer thanks for the support already present in your life.",
                ritualSteps: [
                    "Clean a shelf, altar, or bedside table so the space feels cared for.",
                    "Light a lamp or place fresh flowers nearby.",
                    "Speak or write three specific thank-yous before the evening ends."
                ],
                whyItMatters: "This observance keeps abundance rooted in care, beauty, and gratitude rather than grasping.",
                isMajorObservance: false
            )
        default:
            return SacredObservance(
                date: date,
                title: "Quiet Seva Saturday",
                tradition: .shared,
                summary: "Saturday works well for humble service, reduced noise, and a little more patience with the world around you.",
                suggestedPractice: "Do one practical act of service without announcing it, then end the day with five silent breaths.",
                ritualSteps: [
                    "Choose one helpful task: clean, cook, call someone, or support a family member.",
                    "Do it with less hurry than usual and without seeking recognition.",
                    "Before bed, sit still for five breaths and notice how service changed your mind."
                ],
                whyItMatters: "Service-based practice grounds devotion and meditation in everyday responsibility.",
                isMajorObservance: false
            )
        }
    }

    private static func lunarAge(for date: Date) -> Double {
        let referenceDate = Date(timeIntervalSince1970: 947182440)
        let daysSinceReference = date.timeIntervalSince(referenceDate) / 86_400
        let normalizedAge = daysSinceReference.truncatingRemainder(dividingBy: synodicMonth)
        return normalizedAge >= 0 ? normalizedAge : normalizedAge + synodicMonth
    }

    private static let synodicMonth = 29.53058867
}