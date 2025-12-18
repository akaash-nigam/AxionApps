import Foundation

/// User profile containing meditation preferences and account information
struct UserProfile: Codable, Identifiable {

    // MARK: - Properties

    let id: UUID
    var name: String
    var experienceLevel: ExperienceLevel
    var preferences: MeditationPreferences
    var goals: [WellnessGoal]
    let createdAt: Date
    var lastSessionDate: Date?

    // MARK: - Experience Level

    enum ExperienceLevel: String, Codable, CaseIterable {
        case beginner = "Beginner"
        case intermediate = "Intermediate"
        case advanced = "Advanced"
        case expert = "Expert"

        var meditationMinutes: Int {
            switch self {
            case .beginner: return 100
            case .intermediate: return 500
            case .advanced: return 2000
            case .expert: return 10000
            }
        }
    }

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        name: String,
        experienceLevel: ExperienceLevel,
        preferences: MeditationPreferences = MeditationPreferences(),
        goals: [WellnessGoal] = [],
        createdAt: Date = Date(),
        lastSessionDate: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.experienceLevel = experienceLevel
        self.preferences = preferences
        self.goals = goals
        self.createdAt = createdAt
        self.lastSessionDate = lastSessionDate
    }

    // MARK: - Factory Methods

    static func createNew() -> UserProfile {
        return UserProfile(
            name: "Meditator",
            experienceLevel: .beginner,
            preferences: MeditationPreferences()
        )
    }
}

// MARK: - Meditation Preferences

struct MeditationPreferences: Codable {
    var preferredDuration: TimeInterval = 600 // 10 minutes
    var guidanceStyle: GuidanceStyle = .gentle
    var musicEnabled: Bool = true
    var biometricAdaptationEnabled: Bool = true
    var voiceGuidance: VoiceGuidance = .moderate
    var environmentCategory: EnvironmentCategory?
    var reminderTime: Date?
    var reminderEnabled: Bool = false

    enum GuidanceStyle: String, Codable {
        case minimal = "Minimal"
        case gentle = "Gentle"
        case active = "Active"
        case intensive = "Intensive"
    }

    enum VoiceGuidance: String, Codable {
        case none = "None"
        case minimal = "Minimal"
        case moderate = "Moderate"
        case extensive = "Extensive"
    }
}

// MARK: - Wellness Goals

struct WellnessGoal: Codable, Identifiable {
    let id: UUID
    let type: GoalType
    let target: Int
    var progress: Int
    let startDate: Date
    var completionDate: Date?

    enum GoalType: String, Codable {
        case dailyPractice = "Daily Practice"
        case weeklyMinutes = "Weekly Minutes"
        case streakDays = "Streak Days"
        case masterTechnique = "Master Technique"
        case exploreEnvironments = "Explore Environments"
        case stressReduction = "Stress Reduction"
    }

    var isCompleted: Bool {
        return progress >= target
    }

    var progressPercentage: Double {
        return min(Double(progress) / Double(target), 1.0)
    }

    init(
        id: UUID = UUID(),
        type: GoalType,
        target: Int,
        progress: Int = 0,
        startDate: Date = Date(),
        completionDate: Date? = nil
    ) {
        self.id = id
        self.type = type
        self.target = target
        self.progress = progress
        self.startDate = startDate
        self.completionDate = completionDate
    }
}

// MARK: - Environment Category

enum EnvironmentCategory: String, Codable, CaseIterable {
    case nature = "Nature"
    case cosmic = "Cosmic"
    case abstract = "Abstract"
    case sacred = "Sacred"
    case underwater = "Underwater"

    var description: String {
        switch self {
        case .nature:
            return "Natural environments like forests, mountains, gardens"
        case .cosmic:
            return "Celestial spaces with stars, nebulae, and cosmic beauty"
        case .abstract:
            return "Abstract visualizations of consciousness and energy"
        case .sacred:
            return "Traditional meditation halls and temples"
        case .underwater:
            return "Peaceful underwater scenes with marine life"
        }
    }
}
