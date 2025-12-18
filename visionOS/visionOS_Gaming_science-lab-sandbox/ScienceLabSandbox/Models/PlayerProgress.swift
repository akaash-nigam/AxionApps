//
//  PlayerProgress.swift
//  Science Lab Sandbox
//
//  Tracks player progression, achievements, and statistics
//

import Foundation

// MARK: - Player Progress

struct PlayerProgress: Codable {
    var id: UUID
    var createdDate: Date
    var lastModified: Date

    var completedExperiments: Set<UUID>
    var masteredConcepts: Set<String>
    var skillLevels: [ScientificDiscipline: SkillLevel]
    var achievements: [Achievement]

    var totalLabTime: TimeInterval
    var totalExperiments: Int
    var safetyViolations: Int
    var currentStreak: Int  // Days of continuous use
    var longestStreak: Int

    // Experience and leveling
    var totalXP: Int
    var currentLevel: Int

    // Statistics
    var totalMeasurements: Int
    var totalObservations: Int
    var hypothesesFormed: Int
    var correctHypotheses: Int

    init() {
        self.id = UUID()
        self.createdDate = Date()
        self.lastModified = Date()
        self.completedExperiments = []
        self.masteredConcepts = []
        self.skillLevels = [:]
        self.achievements = []
        self.totalLabTime = 0
        self.totalExperiments = 0
        self.safetyViolations = 0
        self.currentStreak = 0
        self.longestStreak = 0
        self.totalXP = 0
        self.currentLevel = 1
        self.totalMeasurements = 0
        self.totalObservations = 0
        self.hypothesesFormed = 0
        self.correctHypotheses = 0
    }

    // MARK: - Level Management

    mutating func addExperience(_ xp: Int) {
        totalXP += xp

        // Check for level up
        let newLevel = calculateLevel(from: totalXP)
        if newLevel > currentLevel {
            currentLevel = newLevel
            print("🎉 Level Up! Now level \(currentLevel)")
        }

        lastModified = Date()
    }

    private func calculateLevel(from xp: Int) -> Int {
        // XP thresholds: 0, 500, 1500, 3500, 7500, 15000...
        // Formula: XP needed for level n = 500 * 2^(n-1) - 500

        var level = 1
        var xpNeeded = 0

        while xp >= xpNeeded {
            level += 1
            xpNeeded += 500 * (1 << (level - 2))
        }

        return level - 1
    }

    func xpForNextLevel() -> Int {
        let nextLevel = currentLevel + 1
        return 500 * (1 << (nextLevel - 2))
    }

    func xpProgressInCurrentLevel() -> (current: Int, needed: Int) {
        let previousLevelXP = totalXP - (totalXP % xpForNextLevel())
        let currentXP = totalXP - previousLevelXP
        return (currentXP, xpForNextLevel())
    }

    // MARK: - Skill Levels

    mutating func updateSkillLevel(for discipline: ScientificDiscipline, level: SkillLevel) {
        skillLevels[discipline] = level
        lastModified = Date()
    }

    func getSkillLevel(for discipline: ScientificDiscipline) -> SkillLevel {
        return skillLevels[discipline] ?? .beginner
    }

    // MARK: - Statistics

    mutating func recordExperimentCompletion() {
        totalExperiments += 1
        lastModified = Date()
    }

    mutating func recordMeasurement() {
        totalMeasurements += 1
    }

    mutating func recordObservation() {
        totalObservations += 1
    }

    mutating func recordHypothesis(correct: Bool) {
        hypothesesFormed += 1
        if correct {
            correctHypotheses += 1
        }
    }

    mutating func recordLabTime(_ duration: TimeInterval) {
        totalLabTime += duration
        lastModified = Date()
    }

    mutating func recordSafetyViolation() {
        safetyViolations += 1
    }

    // MARK: - Achievements

    mutating func awardAchievement(_ achievement: Achievement) {
        guard !achievements.contains(where: { $0.id == achievement.id }) else {
            return
        }
        achievements.append(achievement)
        lastModified = Date()
    }

    func hasAchievement(_ achievementID: UUID) -> Bool {
        achievements.contains(where: { $0.id == achievementID })
    }
}

// MARK: - Skill Level

struct SkillLevel: Codable, Comparable {
    let level: Int  // 1-5
    let name: String
    let xp: Int

    static let beginner = SkillLevel(level: 1, name: "Beginner", xp: 0)
    static let intermediate = SkillLevel(level: 2, name: "Intermediate", xp: 500)
    static let advanced = SkillLevel(level: 3, name: "Advanced", xp: 1500)
    static let expert = SkillLevel(level: 4, name: "Expert", xp: 3500)
    static let master = SkillLevel(level: 5, name: "Master", xp: 7500)

    static func < (lhs: SkillLevel, rhs: SkillLevel) -> Bool {
        lhs.level < rhs.level
    }
}

// MARK: - Achievement

struct Achievement: Codable, Identifiable {
    let id: UUID
    let name: String
    let description: String
    let iconName: String
    let category: AchievementCategory
    let xpReward: Int
    let rarity: AchievementRarity

    var dateEarned: Date?

    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        iconName: String,
        category: AchievementCategory,
        xpReward: Int,
        rarity: AchievementRarity
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.iconName = iconName
        self.category = category
        self.xpReward = xpReward
        self.rarity = rarity
        self.dateEarned = nil
    }

    // Predefined achievements
    static let chemistryNovice = Achievement(
        name: "Chemistry Novice",
        description: "Complete 10 chemistry experiments",
        iconName: "flask.fill",
        category: .skill,
        xpReward: 100,
        rarity: .common
    )

    static let perfectSafetyRecord = Achievement(
        name: "Perfect Safety Record",
        description: "Complete 100 experiments with zero safety violations",
        iconName: "shield.checkered",
        category: .safety,
        xpReward: 500,
        rarity: .legendary
    )

    static let hypothesisHero = Achievement(
        name: "Hypothesis Hero",
        description: "Form 25 correct hypotheses",
        iconName: "lightbulb.fill",
        category: .discovery,
        xpReward: 200,
        rarity: .rare
    )

    static let dataMaster = Achievement(
        name: "Data Master",
        description: "Collect 1000 precise measurements",
        iconName: "chart.bar.fill",
        category: .skill,
        xpReward: 300,
        rarity: .epic
    )

    static let teamPlayer = Achievement(
        name: "Team Player",
        description: "Complete 10 collaborative experiments",
        iconName: "person.3.fill",
        category: .social,
        xpReward: 150,
        rarity: .rare
    )
}

enum AchievementCategory: String, Codable {
    case skill
    case discovery
    case safety
    case social
    case special
}

enum AchievementRarity: String, Codable, Comparable {
    case common
    case rare
    case epic
    case legendary

    static func < (lhs: AchievementRarity, rhs: AchievementRarity) -> Bool {
        let order: [AchievementRarity] = [.common, .rare, .epic, .legendary]
        return order.firstIndex(of: lhs)! < order.firstIndex(of: rhs)!
    }

    var displayName: String {
        rawValue.capitalized
    }

    var color: String {
        switch self {
        case .common: return "gray"
        case .rare: return "blue"
        case .epic: return "purple"
        case .legendary: return "orange"
        }
    }
}
