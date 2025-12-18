//
//  PlayerProfile.swift
//  RhythmFlow
//
//  Player profile and statistics
//

import Foundation

struct PlayerProfile: Codable {
    let id: UUID
    var username: String
    var displayName: String

    // Progression
    var level: Int
    var experience: Int
    var totalScore: Int
    var totalSongsPlayed: Int

    // Statistics
    var statistics: PlayerStatistics
    var achievements: [String] // Achievement IDs

    // Preferences
    var preferences: GamePreferences

    init(
        id: UUID = UUID(),
        username: String,
        displayName: String,
        level: Int = 1,
        experience: Int = 0
    ) {
        self.id = id
        self.username = username
        self.displayName = displayName
        self.level = level
        self.experience = experience
        self.totalScore = 0
        self.totalSongsPlayed = 0
        self.statistics = PlayerStatistics()
        self.achievements = []
        self.preferences = GamePreferences()
    }

    mutating func updateStatistics(from session: GameSession) {
        totalScore += session.score
        totalSongsPlayed += 1

        statistics.perfectHits += session.perfectHits
        statistics.greatHits += session.greatHits
        statistics.goodHits += session.goodHits
        statistics.missedHits += session.missedHits
        statistics.maxCombo = max(statistics.maxCombo, session.maxCombo)

        // Add experience
        let earnedXP = calculateXP(from: session)
        addExperience(earnedXP)
    }

    private func calculateXP(from session: GameSession) -> Int {
        var xp = 100 // Base XP for completing a song

        // Accuracy bonus
        let accuracy = session.calculateAccuracy()
        xp += Int(accuracy * 100)

        // Difficulty multiplier
        switch session.difficulty {
        case .easy: xp = Int(Double(xp) * 1.0)
        case .normal: xp = Int(Double(xp) * 1.5)
        case .hard: xp = Int(Double(xp) * 2.0)
        case .expert: xp = Int(Double(xp) * 3.0)
        case .expertPlus: xp = Int(Double(xp) * 4.0)
        }

        return xp
    }

    private mutating func addExperience(_ xp: Int) {
        experience += xp

        // Check for level up
        let requiredXP = calculateRequiredXP(for: level + 1)
        if experience >= requiredXP {
            level += 1
            print("🎉 Level up! Now level \(level)")
        }
    }

    private func calculateRequiredXP(for level: Int) -> Int {
        return Int(1000.0 * pow(Double(level), 1.5))
    }

    static var `default`: PlayerProfile {
        PlayerProfile(
            username: "Player",
            displayName: "Rhythm Master"
        )
    }
}

// MARK: - Player Statistics

struct PlayerStatistics: Codable {
    var perfectHits: Int = 0
    var greatHits: Int = 0
    var goodHits: Int = 0
    var missedHits: Int = 0
    var maxCombo: Int = 0

    var totalHits: Int {
        perfectHits + greatHits + goodHits + missedHits
    }

    var averageAccuracy: Double {
        guard totalHits > 0 else { return 0 }
        let weightedScore = Double(
            perfectHits * 100 +
            greatHits * 85 +
            goodHits * 70
        )
        return weightedScore / (Double(totalHits) * 100.0)
    }
}

// MARK: - Game Preferences

struct GamePreferences: Codable {
    var preferredDifficulty: Difficulty = .normal
    var visualTheme: String = "Neon Cyberpunk"
    var masterVolume: Float = 0.8
    var musicVolume: Float = 1.0
    var sfxVolume: Float = 0.7
    var hapticFeedback: Bool = true
    var showCombo: Bool = true
    var showAccuracy: Bool = true
    var fullImmersion: Bool = false
    var reducedMotion: Bool = false
    var colorBlindMode: String? = nil
}
