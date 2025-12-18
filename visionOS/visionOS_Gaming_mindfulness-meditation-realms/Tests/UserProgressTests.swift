import XCTest
@testable import MindfulnessMeditationRealms

/// Unit tests for UserProgress model
final class UserProgressTests: XCTestCase {

    // MARK: - Initialization Tests

    func testProgressCreation() {
        let userID = UUID()
        let progress = UserProgress(userID: userID)

        XCTAssertEqual(progress.userID, userID)
        XCTAssertEqual(progress.totalSessions, 0)
        XCTAssertEqual(progress.totalDuration, 0)
        XCTAssertEqual(progress.currentStreak, 0)
        XCTAssertEqual(progress.level, 1)
        XCTAssertEqual(progress.experiencePoints, 0)
    }

    func testInitialFactory() {
        let userID = UUID()
        let progress = UserProgress.initial(userID: userID)

        XCTAssertEqual(progress.userID, userID)
        XCTAssertEqual(progress.unlockedEnvironments.count, 3) // Starter environments
        XCTAssertTrue(progress.unlockedEnvironments.contains("ZenGarden"))
        XCTAssertTrue(progress.unlockedEnvironments.contains("ForestGrove"))
        XCTAssertTrue(progress.unlockedEnvironments.contains("OceanDepths"))
    }

    // MARK: - Computed Properties Tests

    func testAverageSessionDuration() {
        var progress = UserProgress(userID: UUID())

        XCTAssertEqual(progress.averageSessionDuration, 0)

        progress.totalSessions = 5
        progress.totalDuration = 3000
        XCTAssertEqual(progress.averageSessionDuration, 600)

        progress.totalSessions = 10
        progress.totalDuration = 7200
        XCTAssertEqual(progress.averageSessionDuration, 720)
    }

    func testTotalHours() {
        var progress = UserProgress(userID: UUID())

        progress.totalDuration = 3600
        XCTAssertEqual(progress.totalHours, 1.0)

        progress.totalDuration = 7200
        XCTAssertEqual(progress.totalHours, 2.0)

        progress.totalDuration = 5400
        XCTAssertEqual(progress.totalHours, 1.5)
    }

    func testCurrentLevelProgress() {
        var progress = UserProgress(userID: UUID())

        // At level 1 with 0 XP
        XCTAssertEqual(progress.currentLevelProgress, 0.0)

        // Add some XP
        progress.experiencePoints = 50
        XCTAssertGreaterThan(progress.currentLevelProgress, 0.0)
        XCTAssertLessThan(progress.currentLevelProgress, 1.0)
    }

    // MARK: - Experience & Leveling Tests

    func testAddExperience() {
        var progress = UserProgress(userID: UUID())

        progress.addExperience(50)
        XCTAssertEqual(progress.experiencePoints, 50)
        XCTAssertEqual(progress.level, 1)

        progress.addExperience(75)
        XCTAssertEqual(progress.experiencePoints, 125)
        // Level 2 requires 100 * (2^1.5) ≈ 282 XP
        XCTAssertEqual(progress.level, 1)

        progress.addExperience(200)
        XCTAssertEqual(progress.experiencePoints, 325)
        // Should level up past level 2
        XCTAssertGreaterThanOrEqual(progress.level, 2)
    }

    func testLevelUp() {
        var progress = UserProgress(userID: UUID())

        let level2XP = AppConfiguration.Progress.experienceForLevel(2)
        progress.addExperience(level2XP)

        XCTAssertGreaterThanOrEqual(progress.level, 2)
    }

    func testEnvironmentUnlockOnLevel() {
        var progress = UserProgress(userID: UUID())

        // Mountain Peak unlocks at level 3
        let level3XP = AppConfiguration.Progress.experienceForLevel(3)
        progress.addExperience(level3XP)

        XCTAssertGreaterThanOrEqual(progress.level, 3)
        XCTAssertTrue(progress.unlockedEnvironments.contains("MountainPeak"))
    }

    // MARK: - Session Recording Tests

    func testRecordSession() {
        var progress = UserProgress(userID: UUID())

        let session = MeditationSession(
            userID: progress.userID,
            environmentID: "ZenGarden",
            technique: .breathAwareness,
            startTime: Date(),
            targetDuration: 600
        )

        var sessionWithDuration = session
        sessionWithDuration.updateDuration(600)

        let initialXP = progress.experiencePoints
        progress.recordSession(sessionWithDuration)

        XCTAssertEqual(progress.totalSessions, 1)
        XCTAssertEqual(progress.totalDuration, 600)
        XCTAssertGreaterThan(progress.experiencePoints, initialXP)
    }

    // MARK: - Streak Tests

    func testStreakInitial() {
        var progress = UserProgress(userID: UUID())

        let today = Date()
        progress.updateStreak(sessionDate: today)

        XCTAssertEqual(progress.currentStreak, 1)
        XCTAssertEqual(progress.longestStreak, 1)
    }

    func testStreakContinues() {
        var progress = UserProgress(userID: UUID())

        let day1 = Date()
        progress.updateStreak(sessionDate: day1)
        XCTAssertEqual(progress.currentStreak, 1)

        let day2 = day1.addingTimeInterval(86400) // Next day
        progress.updateStreak(sessionDate: day2)
        XCTAssertEqual(progress.currentStreak, 2)

        let day3 = day2.addingTimeInterval(86400)
        progress.updateStreak(sessionDate: day3)
        XCTAssertEqual(progress.currentStreak, 3)
        XCTAssertEqual(progress.longestStreak, 3)
    }

    func testStreakBreaks() {
        var progress = UserProgress(userID: UUID())

        let day1 = Date()
        progress.updateStreak(sessionDate: day1)
        XCTAssertEqual(progress.currentStreak, 1)

        let day2 = day1.addingTimeInterval(86400)
        progress.updateStreak(sessionDate: day2)
        XCTAssertEqual(progress.currentStreak, 2)

        // Skip a day - streak breaks
        let day4 = day2.addingTimeInterval(86400 * 2)
        progress.updateStreak(sessionDate: day4)
        XCTAssertEqual(progress.currentStreak, 1) // Reset
        XCTAssertEqual(progress.longestStreak, 2) // Preserves longest
    }

    func testMultipleSessionsSameDay() {
        var progress = UserProgress(userID: UUID())

        let day1 = Date()
        progress.updateStreak(sessionDate: day1)
        XCTAssertEqual(progress.currentStreak, 1)

        // Same day - shouldn't change streak
        let day1Later = day1.addingTimeInterval(3600) // 1 hour later
        progress.updateStreak(sessionDate: day1Later)
        XCTAssertEqual(progress.currentStreak, 1)
    }

    // MARK: - Achievement Tests

    func testUnlockAchievement() {
        var progress = UserProgress(userID: UUID())

        XCTAssertEqual(progress.achievements.count, 0)

        progress.unlockAchievement(Achievement.firstSession)

        XCTAssertEqual(progress.achievements.count, 1)
        XCTAssertNotNil(progress.achievements.first?.unlockedAt)
        XCTAssertGreaterThan(progress.experiencePoints, 0) // Got XP reward
    }

    func testDuplicateAchievementPrevented() {
        var progress = UserProgress(userID: UUID())

        progress.unlockAchievement(Achievement.firstSession)
        XCTAssertEqual(progress.achievements.count, 1)

        let xpAfterFirst = progress.experiencePoints

        // Try to unlock again
        progress.unlockAchievement(Achievement.firstSession)
        XCTAssertEqual(progress.achievements.count, 1) // Still just 1
        XCTAssertEqual(progress.experiencePoints, xpAfterFirst) // No extra XP
    }

    func testAchievementAutoUnlock() {
        var progress = UserProgress(userID: UUID())

        // First session achievement
        var session1 = MeditationSession(
            userID: progress.userID,
            environmentID: "ZenGarden",
            technique: .breathAwareness,
            targetDuration: 600
        )
        session1.updateDuration(600)
        progress.recordSession(session1)

        // Should auto-unlock first session achievement
        XCTAssertTrue(progress.achievements.contains(where: { $0.id == "first_session" }))
    }

    // MARK: - Environment Unlocking Tests

    func testUnlockEnvironment() {
        var progress = UserProgress(userID: UUID())

        XCTAssertFalse(progress.unlockedEnvironments.contains("MountainPeak"))

        progress.unlockEnvironment("MountainPeak")

        XCTAssertTrue(progress.unlockedEnvironments.contains("MountainPeak"))
    }

    // MARK: - Codable Tests

    func testProgressCodable() throws {
        var progress = UserProgress(userID: UUID())
        progress.totalSessions = 10
        progress.totalDuration = 6000
        progress.currentStreak = 5
        progress.unlockAchievement(Achievement.firstSession)

        let encoder = JSONEncoder()
        let data = try encoder.encode(progress)

        let decoder = JSONDecoder()
        let decodedProgress = try decoder.decode(UserProgress.self, from: data)

        XCTAssertEqual(progress.userID, decodedProgress.userID)
        XCTAssertEqual(progress.totalSessions, decodedProgress.totalSessions)
        XCTAssertEqual(progress.totalDuration, decodedProgress.totalDuration)
        XCTAssertEqual(progress.currentStreak, decodedProgress.currentStreak)
        XCTAssertEqual(progress.achievements.count, decodedProgress.achievements.count)
    }

    // MARK: - Achievement Static Data Tests

    func testAchievementDefinitions() {
        XCTAssertEqual(Achievement.firstSession.id, "first_session")
        XCTAssertEqual(Achievement.firstSession.experienceReward, 100)

        XCTAssertEqual(Achievement.tenSessions.experienceReward, 200)
        XCTAssertEqual(Achievement.centurion.experienceReward, 1000)
        XCTAssertEqual(Achievement.weekStreak.experienceReward, 300)
        XCTAssertEqual(Achievement.monthStreak.experienceReward, 1500)
    }

    func testAchievementUnlockStatus() {
        var achievement = Achievement.firstSession
        XCTAssertFalse(achievement.isUnlocked)

        achievement.unlockedAt = Date()
        XCTAssertTrue(achievement.isUnlocked)
    }
}
