import XCTest
@testable import MindfulnessMeditationRealms

/// Unit tests for UserProfile model
final class UserProfileTests: XCTestCase {

    // MARK: - Initialization Tests

    func testUserProfileCreation() {
        let profile = UserProfile(
            name: "Test User",
            experienceLevel: .beginner,
            preferences: MeditationPreferences()
        )

        XCTAssertNotNil(profile.id)
        XCTAssertEqual(profile.name, "Test User")
        XCTAssertEqual(profile.experienceLevel, .beginner)
        XCTAssertNotNil(profile.createdAt)
        XCTAssertNil(profile.lastSessionDate)
    }

    func testCreateNewUserProfile() {
        let profile = UserProfile.createNew()

        XCTAssertEqual(profile.name, "Meditator")
        XCTAssertEqual(profile.experienceLevel, .beginner)
        XCTAssertEqual(profile.preferences.preferredDuration, 600)
    }

    // MARK: - Experience Level Tests

    func testExperienceLevelMinutes() {
        XCTAssertEqual(UserProfile.ExperienceLevel.beginner.meditationMinutes, 100)
        XCTAssertEqual(UserProfile.ExperienceLevel.intermediate.meditationMinutes, 500)
        XCTAssertEqual(UserProfile.ExperienceLevel.advanced.meditationMinutes, 2000)
        XCTAssertEqual(UserProfile.ExperienceLevel.expert.meditationMinutes, 10000)
    }

    // MARK: - Preferences Tests

    func testDefaultMeditationPreferences() {
        let prefs = MeditationPreferences()

        XCTAssertEqual(prefs.preferredDuration, 600)
        XCTAssertEqual(prefs.guidanceStyle, .gentle)
        XCTAssertTrue(prefs.musicEnabled)
        XCTAssertTrue(prefs.biometricAdaptationEnabled)
        XCTAssertEqual(prefs.voiceGuidance, .moderate)
        XCTAssertFalse(prefs.reminderEnabled)
    }

    // MARK: - Wellness Goals Tests

    func testWellnessGoalCreation() {
        let goal = WellnessGoal(
            type: .dailyPractice,
            target: 30,
            progress: 15
        )

        XCTAssertEqual(goal.type, .dailyPractice)
        XCTAssertEqual(goal.target, 30)
        XCTAssertEqual(goal.progress, 15)
        XCTAssertFalse(goal.isCompleted)
        XCTAssertEqual(goal.progressPercentage, 0.5)
    }

    func testWellnessGoalCompletion() {
        var goal = WellnessGoal(
            type: .streakDays,
            target: 7,
            progress: 5
        )

        XCTAssertFalse(goal.isCompleted)

        goal.progress = 7
        XCTAssertTrue(goal.isCompleted)

        goal.progress = 10
        XCTAssertTrue(goal.isCompleted)
    }

    func testWellnessGoalProgressPercentage() {
        let goal = WellnessGoal(
            type: .weeklyMinutes,
            target: 100,
            progress: 75
        )

        XCTAssertEqual(goal.progressPercentage, 0.75)
    }

    // MARK: - Codable Tests

    func testUserProfileCodable() throws {
        let profile = UserProfile(
            name: "Test User",
            experienceLevel: .intermediate,
            preferences: MeditationPreferences(),
            goals: [
                WellnessGoal(type: .dailyPractice, target: 30)
            ]
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(profile)

        let decoder = JSONDecoder()
        let decodedProfile = try decoder.decode(UserProfile.self, from: data)

        XCTAssertEqual(profile.id, decodedProfile.id)
        XCTAssertEqual(profile.name, decodedProfile.name)
        XCTAssertEqual(profile.experienceLevel, decodedProfile.experienceLevel)
        XCTAssertEqual(profile.goals.count, decodedProfile.goals.count)
    }
}
