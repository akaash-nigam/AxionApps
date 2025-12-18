import Testing
import Foundation
@testable import IndustrialSafetySimulator

@Suite("DashboardViewModel Tests")
struct DashboardViewModelTests {

    // MARK: - Initialization Tests

    @Test("ViewModel initializes with correct defaults")
    func testViewModelInitialization() {
        // Act
        let viewModel = DashboardViewModel()

        // Assert
        #expect(viewModel.completedToday == 2, "Should have default completed count")
        #expect(viewModel.totalAssigned == 5, "Should have default total assigned")
        #expect(viewModel.recentAchievements.count > 0, "Should have some achievements")
    }

    // MARK: - Completion Percentage Tests

    @Test("Completion percentage calculates correctly", arguments: [
        (2, 5, 40.0),    // 2 out of 5 = 40%
        (5, 5, 100.0),   // All completed = 100%
        (0, 5, 0.0),     // None completed = 0%
        (3, 10, 30.0),   // 3 out of 10 = 30%
        (7, 8, 87.5),    // 7 out of 8 = 87.5%
    ])
    func testCompletionPercentage(completed: Int, total: Int, expectedPercentage: Double) {
        // Arrange
        var viewModel = DashboardViewModel()
        viewModel.completedToday = completed
        viewModel.totalAssigned = total

        // Act
        let percentage = viewModel.completionPercentage

        // Assert
        #expect(percentage == expectedPercentage)
    }

    @Test("Completion percentage with zero assignments")
    func testCompletionPercentageZeroAssignments() {
        // Arrange
        var viewModel = DashboardViewModel()
        viewModel.completedToday = 0
        viewModel.totalAssigned = 0

        // Act
        let percentage = viewModel.completionPercentage

        // Assert
        #expect(percentage == 0, "Should return 0% when no assignments")
    }

    // MARK: - Achievements Tests

    @Test("Recent achievements are populated")
    func testRecentAchievements() {
        // Arrange
        let viewModel = DashboardViewModel()

        // Assert
        #expect(viewModel.recentAchievements.count >= 2, "Should have at least 2 achievements")

        // Check first achievement
        if let firstAchievement = viewModel.recentAchievements.first {
            #expect(firstAchievement.title.isEmpty == false, "Achievement should have a title")
            #expect(firstAchievement.icon.isEmpty == false, "Achievement should have an icon")
            #expect(firstAchievement.color.isEmpty == false, "Achievement should have a color")
        }
    }

    @Test("Achievement time ago is calculated")
    func testAchievementTimeAgo() {
        // Arrange
        let pastDate = Date().addingTimeInterval(-2 * 24 * 3600) // 2 days ago
        let achievement = Achievement(
            title: "Test Achievement",
            icon: "star.fill",
            earnedDate: pastDate,
            color: "yellow"
        )

        // Assert
        #expect(achievement.timeAgo.isEmpty == false, "Time ago should be calculated")
        // Note: Exact string depends on system locale, so we just check it's not empty
    }

    // MARK: - Data Refresh Tests

    @Test("Dashboard data can be refreshed")
    func testRefreshData() {
        // Arrange
        var viewModel = DashboardViewModel()
        let initialAchievements = viewModel.recentAchievements.count

        // Act
        viewModel.refreshData()

        // Assert
        // After refresh, achievements should still be present
        #expect(viewModel.recentAchievements.count == initialAchievements)
    }

    // MARK: - Edge Cases

    @Test("Completion percentage handles more completed than assigned")
    func testCompletionPercentageOverage() {
        // Arrange
        var viewModel = DashboardViewModel()
        viewModel.completedToday = 10
        viewModel.totalAssigned = 5

        // Act
        let percentage = viewModel.completionPercentage

        // Assert
        #expect(percentage == 200.0, "Should allow percentage > 100%")
    }

    @Test("ViewModel handles negative values gracefully")
    func testNegativeValues() {
        // Arrange
        var viewModel = DashboardViewModel()
        viewModel.completedToday = -1
        viewModel.totalAssigned = 5

        // Act
        let percentage = viewModel.completionPercentage

        // Assert
        #expect(percentage == -20.0, "Should calculate with negative values")
        // Note: In production, you might want to add validation to prevent negative values
    }
}

@Suite("Achievement Model Tests")
struct AchievementTests {

    @Test("Achievement initializes correctly")
    func testAchievementInitialization() {
        // Arrange
        let title = "Perfect Score"
        let icon = "star.fill"
        let earnedDate = Date()
        let color = "gold"

        // Act
        let achievement = Achievement(
            title: title,
            icon: icon,
            earnedDate: earnedDate,
            color: color
        )

        // Assert
        #expect(achievement.title == title)
        #expect(achievement.icon == icon)
        #expect(achievement.earnedDate == earnedDate)
        #expect(achievement.color == color)
        #expect(achievement.id != achievement.id, "Each achievement should have unique ID")
    }

    @Test("Achievement timeAgo for recent date")
    func testRecentAchievementTimeAgo() {
        // Arrange
        let recentDate = Date().addingTimeInterval(-3600) // 1 hour ago
        let achievement = Achievement(
            title: "Recent",
            icon: "clock",
            earnedDate: recentDate,
            color: "blue"
        )

        // Act
        let timeAgo = achievement.timeAgo

        // Assert
        #expect(timeAgo.contains("hour") || timeAgo.contains("minute"), "Should mention hours or minutes for recent achievement")
    }

    @Test("Achievement timeAgo for old date")
    func testOldAchievementTimeAgo() {
        // Arrange
        let oldDate = Date().addingTimeInterval(-30 * 24 * 3600) // 30 days ago
        let achievement = Achievement(
            title: "Old",
            icon: "calendar",
            earnedDate: oldDate,
            color: "gray"
        )

        // Act
        let timeAgo = achievement.timeAgo

        // Assert
        #expect(timeAgo.contains("month") || timeAgo.contains("day"), "Should mention months or days for old achievement")
    }

    @Test("Multiple achievements have unique IDs")
    func testUniqueAchievementIDs() {
        // Arrange & Act
        let achievement1 = Achievement(title: "A1", icon: "1", earnedDate: Date(), color: "red")
        let achievement2 = Achievement(title: "A2", icon: "2", earnedDate: Date(), color: "blue")
        let achievement3 = Achievement(title: "A3", icon: "3", earnedDate: Date(), color: "green")

        let ids = [achievement1.id, achievement2.id, achievement3.id]

        // Assert
        let uniqueIds = Set(ids)
        #expect(uniqueIds.count == 3, "All achievements should have unique IDs")
    }
}
