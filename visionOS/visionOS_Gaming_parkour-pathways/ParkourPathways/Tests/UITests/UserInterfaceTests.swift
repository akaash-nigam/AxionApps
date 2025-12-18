//
//  UserInterfaceTests.swift
//  Parkour Pathways Tests
//
//  UI/UX component tests
//

import XCTest
import SwiftUI
@testable import ParkourPathways

final class UserInterfaceTests: XCTestCase {

    // MARK: - Game State Manager UI Tests

    func testGameStateManager_InitialState() {
        let stateManager = GameStateManager()

        XCTAssertEqual(stateManager.currentState, .initializing)
        XCTAssertNil(stateManager.playerData)
        XCTAssertNil(stateManager.courseData)
    }

    func testGameStateManager_StateTransitions() async throws {
        let stateManager = GameStateManager()

        // Valid transition: initializing -> menu
        try await stateManager.transition(to: .menu)
        XCTAssertEqual(stateManager.currentState, .menu)

        // Valid transition: menu -> roomScanning
        try await stateManager.transition(to: .roomScanning)
        XCTAssertEqual(stateManager.currentState, .roomScanning)

        // Valid transition: roomScanning -> courseSelection
        try await stateManager.transition(to: .courseSelection)
        XCTAssertEqual(stateManager.currentState, .courseSelection)
    }

    func testGameStateManager_InvalidTransition() async {
        let stateManager = GameStateManager()

        // Try invalid transition: initializing -> playing (must scan room first)
        do {
            try await stateManager.transition(to: .playing)
            XCTFail("Should have thrown invalid transition error")
        } catch {
            XCTAssertTrue(error is GameStateError)
        }
    }

    // MARK: - App Coordinator Tests

    func testAppCoordinator_InitialState() {
        let coordinator = AppCoordinator()

        XCTAssertEqual(coordinator.currentSpace, .window)
        XCTAssertFalse(coordinator.isImmersiveSpaceActive)
        XCTAssertNil(coordinator.selectedCourse)
    }

    @MainActor
    func testAppCoordinator_CourseSelection() async {
        let coordinator = AppCoordinator()
        let course = createTestCourse()

        // Note: In real environment, this would open immersive space
        // Here we just test the state management
        coordinator.selectedCourse = course

        XCTAssertEqual(coordinator.selectedCourse?.name, course.name)
    }

    // MARK: - Player Data Validation Tests

    func testPlayerData_Creation() {
        let player = PlayerData(
            username: "TestPlayer",
            skillLevel: .intermediate
        )

        XCTAssertEqual(player.username, "TestPlayer")
        XCTAssertEqual(player.skillLevel, .intermediate)
        XCTAssertNotNil(player.id)
        XCTAssertTrue(player.achievements.isEmpty)
    }

    func testPlayerData_UsernameValidation() {
        // Valid usernames
        XCTAssertTrue(isValidUsername("Player123"))
        XCTAssertTrue(isValidUsername("Cool_Player"))
        XCTAssertTrue(isValidUsername("Pro-Traceur"))

        // Invalid usernames
        XCTAssertFalse(isValidUsername("")) // Too short
        XCTAssertFalse(isValidUsername("ab")) // Too short
        XCTAssertFalse(isValidUsername("Player@123")) // Invalid character
        XCTAssertFalse(isValidUsername(String(repeating: "a", count: 21))) // Too long
    }

    func testPlayerData_SkillLevelProgression() {
        let player = PlayerData(
            username: "TestPlayer",
            skillLevel: .beginner
        )

        // Simulate skill progression
        player.statistics.totalPlayTime = 3600 * 10 // 10 hours
        player.statistics.coursesCompleted = 50
        player.statistics.averageScore = 0.85

        let suggestedLevel = calculateSuggestedSkillLevel(player)
        XCTAssertEqual(suggestedLevel, .intermediate)
    }

    // MARK: - Course Data Tests

    func testCourseData_Creation() {
        let course = CourseData(
            name: "Test Course",
            difficulty: .medium,
            obstacles: [],
            checkpoints: [],
            spaceRequirements: SpaceRequirements(),
            estimatedDuration: 180
        )

        XCTAssertEqual(course.name, "Test Course")
        XCTAssertEqual(course.difficulty, .medium)
        XCTAssertTrue(course.obstacles.isEmpty)
    }

    func testCourseData_DifficultyScaling() {
        let easyCourse = createCourseWithDifficulty(.easy)
        let mediumCourse = createCourseWithDifficulty(.medium)
        let hardCourse = createCourseWithDifficulty(.hard)

        // Easy courses should have fewer obstacles
        XCTAssertLessThan(easyCourse.obstacles.count, mediumCourse.obstacles.count)
        XCTAssertLessThan(mediumCourse.obstacles.count, hardCourse.obstacles.count)

        // Easy courses should have longer durations (more time to complete)
        XCTAssertGreaterThan(easyCourse.estimatedDuration, mediumCourse.estimatedDuration)
    }

    // MARK: - Achievement System Tests

    func testAchievement_Unlock() {
        let achievement = Achievement(
            id: "first_course",
            name: "First Steps",
            description: "Complete your first course",
            requirement: .coursesCompleted(1)
        )

        let player = PlayerData(username: "TestPlayer", skillLevel: .beginner)
        player.statistics.coursesCompleted = 1

        XCTAssertTrue(achievement.isUnlocked(for: player))
    }

    func testAchievement_NotUnlocked() {
        let achievement = Achievement(
            id: "speed_demon",
            name: "Speed Demon",
            description: "Complete a course in under 60 seconds",
            requirement: .fastestTime(60.0)
        )

        let player = PlayerData(username: "TestPlayer", skillLevel: .beginner)
        player.statistics.fastestCourseTime = 75.0

        XCTAssertFalse(achievement.isUnlocked(for: player))
    }

    func testAchievement_ProgressTracking() {
        let achievement = Achievement(
            id: "marathon",
            name: "Marathon Runner",
            description: "Complete 100 courses",
            requirement: .coursesCompleted(100)
        )

        let player = PlayerData(username: "TestPlayer", skillLevel: .intermediate)
        player.statistics.coursesCompleted = 45

        let progress = achievement.calculateProgress(for: player)
        XCTAssertEqual(progress, 0.45, accuracy: 0.01)
    }

    // MARK: - Leaderboard Tests

    func testLeaderboard_Ranking() {
        let scores = [
            LeaderboardEntry(username: "Player1", score: 1000, rank: 0),
            LeaderboardEntry(username: "Player2", score: 850, rank: 0),
            LeaderboardEntry(username: "Player3", score: 920, rank: 0),
            LeaderboardEntry(username: "Player4", score: 750, rank: 0)
        ]

        let rankedScores = rankLeaderboardEntries(scores)

        XCTAssertEqual(rankedScores[0].username, "Player1") // Highest score
        XCTAssertEqual(rankedScores[0].rank, 1)
        XCTAssertEqual(rankedScores[1].username, "Player3")
        XCTAssertEqual(rankedScores[1].rank, 2)
        XCTAssertEqual(rankedScores[2].username, "Player2")
        XCTAssertEqual(rankedScores[2].rank, 3)
        XCTAssertEqual(rankedScores[3].username, "Player4")
        XCTAssertEqual(rankedScores[3].rank, 4)
    }

    func testLeaderboard_Filtering() {
        let entries = [
            LeaderboardEntry(username: "Player1", score: 1000, rank: 1, difficulty: .easy),
            LeaderboardEntry(username: "Player2", score: 900, rank: 2, difficulty: .medium),
            LeaderboardEntry(username: "Player3", score: 950, rank: 3, difficulty: .easy),
            LeaderboardEntry(username: "Player4", score: 800, rank: 4, difficulty: .hard)
        ]

        let easyEntries = entries.filter { $0.difficulty == .easy }
        XCTAssertEqual(easyEntries.count, 2)

        let hardEntries = entries.filter { $0.difficulty == .hard }
        XCTAssertEqual(hardEntries.count, 1)
    }

    // MARK: - Settings & Preferences Tests

    func testSettings_DefaultValues() {
        let settings = GameSettings()

        XCTAssertTrue(settings.musicEnabled)
        XCTAssertTrue(settings.soundEffectsEnabled)
        XCTAssertTrue(settings.hapticsEnabled)
        XCTAssertEqual(settings.difficulty, .medium)
        XCTAssertEqual(settings.controlScheme, .standard)
    }

    func testSettings_Persistence() {
        let settings = GameSettings()
        settings.musicEnabled = false
        settings.difficulty = .hard

        // Simulate save
        let savedData = settings.toDictionary()

        // Simulate load
        let loadedSettings = GameSettings(from: savedData)

        XCTAssertFalse(loadedSettings.musicEnabled)
        XCTAssertEqual(loadedSettings.difficulty, .hard)
    }

    // MARK: - Tutorial System Tests

    func testTutorial_Progression() {
        let tutorial = TutorialManager()

        XCTAssertEqual(tutorial.currentStep, 0)
        XCTAssertFalse(tutorial.isCompleted)

        tutorial.advanceToNextStep()
        XCTAssertEqual(tutorial.currentStep, 1)

        // Complete all steps
        for _ in 0..<tutorial.totalSteps {
            tutorial.advanceToNextStep()
        }

        XCTAssertTrue(tutorial.isCompleted)
    }

    func testTutorial_SkipOption() {
        let tutorial = TutorialManager()

        tutorial.skip()

        XCTAssertTrue(tutorial.isCompleted)
        XCTAssertTrue(tutorial.wasSkipped)
    }

    // MARK: - Notification System Tests

    func testNotification_Creation() {
        let notification = GameNotification(
            type: .achievement,
            title: "Achievement Unlocked!",
            message: "You completed your first course",
            duration: 3.0
        )

        XCTAssertEqual(notification.type, .achievement)
        XCTAssertEqual(notification.title, "Achievement Unlocked!")
        XCTAssertEqual(notification.duration, 3.0)
    }

    func testNotification_Queue() {
        let notificationManager = NotificationManager()

        let notification1 = GameNotification(type: .info, title: "Info", message: "Message 1")
        let notification2 = GameNotification(type: .warning, title: "Warning", message: "Message 2")

        notificationManager.enqueue(notification1)
        notificationManager.enqueue(notification2)

        XCTAssertEqual(notificationManager.queueCount, 2)

        let next = notificationManager.dequeue()
        XCTAssertEqual(next?.title, "Info")
        XCTAssertEqual(notificationManager.queueCount, 1)
    }

    // MARK: - Session Metrics Tests

    func testSessionMetrics_Tracking() {
        let session = SessionMetrics(
            courseId: UUID(),
            playerId: UUID(),
            startTime: Date()
        )

        // Simulate gameplay
        session.recordJump(score: 0.95)
        session.recordJump(score: 0.87)
        session.recordVault(type: .speedVault, score: 0.92)

        XCTAssertEqual(session.totalJumps, 2)
        XCTAssertEqual(session.totalVaults, 1)

        let averageScore = session.calculateAverageScore()
        XCTAssertGreaterThan(averageScore, 0.85)
    }

    func testSessionMetrics_TimeTracking() {
        let session = SessionMetrics(
            courseId: UUID(),
            playerId: UUID(),
            startTime: Date()
        )

        // Simulate 2-second session
        Thread.sleep(forTimeInterval: 0.1) // Small delay for test
        session.endTime = Date(timeIntervalSinceNow: 2.0)

        let duration = session.duration
        XCTAssertGreaterThan(duration, 0)
    }

    // MARK: - Helper Methods

    private func createTestCourse() -> CourseData {
        return CourseData(
            name: "Test Course",
            difficulty: .medium,
            obstacles: [
                Obstacle(
                    type: .precisionTarget,
                    position: SIMD3<Float>(0, 0.5, 0),
                    scale: SIMD3<Float>(0.3, 0.05, 0.3)
                )
            ],
            checkpoints: [],
            spaceRequirements: SpaceRequirements(),
            estimatedDuration: 180
        )
    }

    private func createCourseWithDifficulty(_ difficulty: DifficultyLevel) -> CourseData {
        let obstacleCount = difficulty == .easy ? 5 : (difficulty == .medium ? 10 : 15)
        let duration = difficulty == .easy ? 300 : (difficulty == .medium ? 240 : 180)

        let obstacles = (0..<obstacleCount).map { i in
            Obstacle(
                type: .precisionTarget,
                position: SIMD3<Float>(Float(i) * 0.5, 0.5, 0),
                scale: SIMD3<Float>(0.3, 0.05, 0.3)
            )
        }

        return CourseData(
            name: "Test Course",
            difficulty: difficulty,
            obstacles: obstacles,
            checkpoints: [],
            spaceRequirements: SpaceRequirements(),
            estimatedDuration: duration
        )
    }

    private func isValidUsername(_ username: String) -> Bool {
        let minLength = 3
        let maxLength = 20
        let allowedCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_-"))

        guard username.count >= minLength && username.count <= maxLength else {
            return false
        }

        return username.unicodeScalars.allSatisfy { allowedCharacters.contains($0) }
    }

    private func calculateSuggestedSkillLevel(_ player: PlayerData) -> SkillLevel {
        let hoursPlayed = player.statistics.totalPlayTime / 3600
        let coursesCompleted = player.statistics.coursesCompleted
        let averageScore = player.statistics.averageScore

        if hoursPlayed >= 20 && coursesCompleted >= 100 && averageScore >= 0.9 {
            return .expert
        } else if hoursPlayed >= 10 && coursesCompleted >= 50 && averageScore >= 0.8 {
            return .advanced
        } else if hoursPlayed >= 5 && coursesCompleted >= 20 && averageScore >= 0.7 {
            return .intermediate
        } else {
            return .beginner
        }
    }

    private func rankLeaderboardEntries(_ entries: [LeaderboardEntry]) -> [LeaderboardEntry] {
        let sorted = entries.sorted { $0.score > $1.score }
        return sorted.enumerated().map { index, entry in
            var rankedEntry = entry
            rankedEntry.rank = index + 1
            return rankedEntry
        }
    }
}

// MARK: - Supporting Types

struct LeaderboardEntry {
    let username: String
    let score: Int
    var rank: Int
    var difficulty: DifficultyLevel = .medium
}

struct GameSettings {
    var musicEnabled: Bool = true
    var soundEffectsEnabled: Bool = true
    var hapticsEnabled: Bool = true
    var difficulty: DifficultyLevel = .medium
    var controlScheme: ControlScheme = .standard

    enum ControlScheme {
        case standard
        case advanced
        case custom
    }

    func toDictionary() -> [String: Any] {
        return [
            "musicEnabled": musicEnabled,
            "soundEffectsEnabled": soundEffectsEnabled,
            "hapticsEnabled": hapticsEnabled,
            "difficulty": difficulty.rawValue,
            "controlScheme": String(describing: controlScheme)
        ]
    }

    init() {}

    init(from dictionary: [String: Any]) {
        self.musicEnabled = dictionary["musicEnabled"] as? Bool ?? true
        self.soundEffectsEnabled = dictionary["soundEffectsEnabled"] as? Bool ?? true
        self.hapticsEnabled = dictionary["hapticsEnabled"] as? Bool ?? true

        if let difficultyRaw = dictionary["difficulty"] as? String {
            self.difficulty = DifficultyLevel(rawValue: difficultyRaw) ?? .medium
        }

        // Control scheme parsing would go here
    }
}

class TutorialManager {
    var currentStep: Int = 0
    var totalSteps: Int = 5
    var isCompleted: Bool = false
    var wasSkipped: Bool = false

    func advanceToNextStep() {
        if currentStep < totalSteps {
            currentStep += 1
        }
        if currentStep >= totalSteps {
            isCompleted = true
        }
    }

    func skip() {
        isCompleted = true
        wasSkipped = true
        currentStep = totalSteps
    }
}

struct GameNotification {
    enum NotificationType {
        case achievement
        case info
        case warning
        case error
    }

    let type: NotificationType
    let title: String
    let message: String
    var duration: TimeInterval = 3.0
}

class NotificationManager {
    private var queue: [GameNotification] = []

    var queueCount: Int {
        return queue.count
    }

    func enqueue(_ notification: GameNotification) {
        queue.append(notification)
    }

    func dequeue() -> GameNotification? {
        guard !queue.isEmpty else { return nil }
        return queue.removeFirst()
    }
}

class SessionMetrics {
    let courseId: UUID
    let playerId: UUID
    let startTime: Date
    var endTime: Date?

    var totalJumps: Int = 0
    var totalVaults: Int = 0
    private var scores: [Float] = []

    var duration: TimeInterval {
        let end = endTime ?? Date()
        return end.timeIntervalSince(startTime)
    }

    init(courseId: UUID, playerId: UUID, startTime: Date) {
        self.courseId = courseId
        self.playerId = playerId
        self.startTime = startTime
    }

    func recordJump(score: Float) {
        totalJumps += 1
        scores.append(score)
    }

    func recordVault(type: VaultMechanic.VaultType, score: Float) {
        totalVaults += 1
        scores.append(score)
    }

    func calculateAverageScore() -> Float {
        guard !scores.isEmpty else { return 0 }
        return scores.reduce(0, +) / Float(scores.count)
    }
}
