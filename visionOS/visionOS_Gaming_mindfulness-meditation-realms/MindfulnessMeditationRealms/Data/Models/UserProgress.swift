import Foundation

/// User's meditation progress and achievements
struct UserProgress: Codable {

    // MARK: - Properties

    let userID: UUID
    var totalSessions: Int
    var totalDuration: TimeInterval
    var currentStreak: Int
    var longestStreak: Int
    var lastPracticeDate: Date?
    var achievements: [Achievement]
    var unlockedEnvironments: Set<String>
    var experiencePoints: Int
    var level: Int

    // MARK: - Computed Properties

    var averageSessionDuration: TimeInterval {
        guard totalSessions > 0 else { return 0 }
        return totalDuration / Double(totalSessions)
    }

    var totalHours: Double {
        return totalDuration / 3600.0
    }

    var nextLevelXP: Int {
        return AppConfiguration.Progress.experienceForLevel(level + 1)
    }

    var currentLevelProgress: Double {
        let currentLevelXP = AppConfiguration.Progress.experienceForLevel(level)
        let xpIntoLevel = experiencePoints - currentLevelXP
        let xpNeededForLevel = nextLevelXP - currentLevelXP
        return Double(xpIntoLevel) / Double(xpNeededForLevel)
    }

    // MARK: - Initialization

    init(
        userID: UUID,
        totalSessions: Int = 0,
        totalDuration: TimeInterval = 0,
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        lastPracticeDate: Date? = nil,
        achievements: [Achievement] = [],
        unlockedEnvironments: Set<String> = Set(["ZenGarden", "ForestGrove", "OceanDepths"]),
        experiencePoints: Int = 0,
        level: Int = 1
    ) {
        self.userID = userID
        self.totalSessions = totalSessions
        self.totalDuration = totalDuration
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.lastPracticeDate = lastPracticeDate
        self.achievements = achievements
        self.unlockedEnvironments = unlockedEnvironments
        self.experiencePoints = experiencePoints
        self.level = level
    }

    // MARK: - Progression Methods

    mutating func addExperience(_ xp: Int) {
        experiencePoints += xp

        // Check for level up
        while experiencePoints >= nextLevelXP {
            levelUp()
        }
    }

    mutating func recordSession(_ session: MeditationSession) {
        totalSessions += 1
        totalDuration += session.duration

        // Update streak
        updateStreak(sessionDate: session.startTime)

        // Award XP
        let xpEarned = calculateXP(for: session)
        addExperience(xpEarned)

        // Check for achievements
        checkAchievements()
    }

    mutating func unlockEnvironment(_ environmentID: String) {
        unlockedEnvironments.insert(environmentID)
    }

    mutating func unlockAchievement(_ achievement: Achievement) {
        guard !achievements.contains(where: { $0.id == achievement.id }) else { return }

        var newAchievement = achievement
        newAchievement.unlockedAt = Date()
        achievements.append(newAchievement)

        // Award XP
        addExperience(achievement.experienceReward)
    }

    // MARK: - Private Methods

    private mutating func levelUp() {
        level += 1

        // Unlock environment at certain levels
        let unlockableEnvironments = [
            3: "MountainPeak",
            5: "DesertOasis",
            8: "CosmicNebula",
            12: "UnderwaterTemple",
            15: "NorthernLights"
        ]

        if let environmentID = unlockableEnvironments[level] {
            unlockEnvironment(environmentID)
        }
    }

    private mutating func updateStreak(sessionDate: Date) {
        guard let lastDate = lastPracticeDate else {
            // First session ever
            currentStreak = 1
            longestStreak = 1
            lastPracticeDate = sessionDate
            return
        }

        let calendar = Calendar.current
        let daysSinceLastSession = calendar.dateComponents([.day], from: lastDate, to: sessionDate).day ?? 0

        if daysSinceLastSession == 0 {
            // Same day - don't change streak
            return
        } else if daysSinceLastSession == 1 {
            // Next day - increment streak
            currentStreak += 1
            if currentStreak > longestStreak {
                longestStreak = currentStreak
            }
        } else {
            // Streak broken
            currentStreak = 1
        }

        lastPracticeDate = sessionDate
    }

    private func calculateXP(for session: MeditationSession) -> Int {
        var xp = 0

        // Base XP from duration (10 XP per minute)
        xp += Int(session.duration / 60.0) * 10

        // Bonus for completion
        if session.completionPercentage >= 1.0 {
            xp += 50
        }

        // Quality bonus
        if let qualityScore = session.focusScore, qualityScore >= 0.8 {
            xp += 25
        }

        return xp
    }

    private mutating func checkAchievements() {
        // Check for milestone achievements
        if totalSessions == 1 && !hasAchievement("first_session") {
            unlockAchievement(.firstSession)
        }

        if totalSessions >= 10 && !hasAchievement("ten_sessions") {
            unlockAchievement(.tenSessions)
        }

        if totalSessions >= 100 && !hasAchievement("centurion") {
            unlockAchievement(.centurion)
        }

        if currentStreak >= 7 && !hasAchievement("week_streak") {
            unlockAchievement(.weekStreak)
        }

        if currentStreak >= 30 && !hasAchievement("month_streak") {
            unlockAchievement(.monthStreak)
        }
    }

    private func hasAchievement(_ id: String) -> Bool {
        achievements.contains(where: { $0.id == id })
    }

    // MARK: - Factory

    static func initial(userID: UUID) -> UserProgress {
        return UserProgress(userID: userID)
    }
}

// MARK: - Achievement

struct Achievement: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let iconName: String
    let experienceReward: Int
    var unlockedAt: Date?

    var isUnlocked: Bool {
        return unlockedAt != nil
    }

    // Predefined achievements
    static let firstSession = Achievement(
        id: "first_session",
        name: "First Step",
        description: "Complete your first meditation session",
        iconName: "leaf.fill",
        experienceReward: 100
    )

    static let tenSessions = Achievement(
        id: "ten_sessions",
        name: "Committed",
        description: "Complete 10 meditation sessions",
        iconName: "flame.fill",
        experienceReward: 200
    )

    static let centurion = Achievement(
        id: "centurion",
        name: "Centurion",
        description: "Complete 100 meditation sessions",
        iconName: "star.fill",
        experienceReward: 1000
    )

    static let weekStreak = Achievement(
        id: "week_streak",
        name: "Seven Days",
        description: "Maintain a 7-day meditation streak",
        iconName: "calendar",
        experienceReward: 300
    )

    static let monthStreak = Achievement(
        id: "month_streak",
        name: "Monthly Practice",
        description: "Maintain a 30-day meditation streak",
        iconName: "calendar.badge.plus",
        experienceReward: 1500
    )

    static let allAchievements: [Achievement] = [
        .firstSession,
        .tenSessions,
        .centurion,
        .weekStreak,
        .monthStreak
    ]
}
