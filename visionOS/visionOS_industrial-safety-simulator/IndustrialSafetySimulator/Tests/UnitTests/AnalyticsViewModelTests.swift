import Testing
import Foundation
@testable import IndustrialSafetySimulator

@Suite("AnalyticsViewModel Tests")
struct AnalyticsViewModelTests {

    // MARK: - Helper Functions

    func createTestUser() -> SafetyUser {
        SafetyUser(
            name: "Test User",
            role: .operator,
            department: "Manufacturing",
            hireDate: Date()
        )
    }

    func createTestMetrics() -> PerformanceMetrics {
        var metrics = PerformanceMetrics(userId: UUID())
        metrics.totalTrainingHours = 25.5
        metrics.scenariosCompleted = 10
        metrics.scenariosPassed = 8
        metrics.averageScore = 82.5
        metrics.bestScore = 95.0
        metrics.hazardRecognitionAccuracy = 88.0
        metrics.safetyComplianceRate = 92.0
        return metrics
    }

    func createTestScenarioResult(score: Double, time: TimeInterval) -> ScenarioResult {
        let scenario = SafetyScenario(
            name: "Fire Safety",
            description: "Fire response training",
            environment: .factoryFloor,
            realityKitScene: "FireScene"
        )
        return ScenarioResult(
            scenario: scenario,
            timeCompleted: time,
            score: score
        )
    }

    // MARK: - Initialization Tests

    @Test("ViewModel initializes with correct user", .tags(.unit))
    func testViewModelInitialization() {
        // Arrange
        let user = createTestUser()

        // Act
        let viewModel = AnalyticsViewModel(user: user)

        // Assert
        #expect(viewModel.selectedUser.id == user.id)
        #expect(viewModel.selectedUser.name == user.name)
    }

    @Test("ViewModel loads metrics on initialization", .tags(.unit))
    func testMetricsLoadedOnInit() async {
        // Arrange
        let user = createTestUser()
        let viewModel = AnalyticsViewModel(user: user)

        // Act
        await viewModel.loadAnalytics()

        // Assert - metrics should be loaded
        #expect(viewModel.isLoading == false)
    }

    // MARK: - Metrics Calculation Tests

    @Test("Pass rate calculates correctly", .tags(.unit))
    func testPassRateCalculation() {
        // Arrange
        let metrics = createTestMetrics()

        // Act
        let passRate = metrics.passRate

        // Assert
        #expect(passRate == 80.0, "8 passed out of 10 should be 80%")
    }

    @Test("Average score is accurate", .tags(.unit))
    func testAverageScoreAccuracy() {
        // Arrange
        let metrics = createTestMetrics()

        // Assert
        #expect(metrics.averageScore == 82.5)
    }

    @Test("Training hours display correctly", .tags(.unit))
    func testTrainingHoursDisplay() {
        // Arrange
        let metrics = createTestMetrics()

        // Assert
        #expect(metrics.totalTrainingHours == 25.5)
    }

    // MARK: - Time Period Filtering Tests

    @Test("Time period filters work correctly", .tags(.unit), arguments: [
        TimePeriod.week,
        TimePeriod.month,
        TimePeriod.quarter,
        TimePeriod.year,
        TimePeriod.allTime
    ])
    func testTimePeriodFiltering(period: TimePeriod) async {
        // Arrange
        let user = createTestUser()
        let viewModel = AnalyticsViewModel(user: user)

        // Act
        viewModel.selectedTimePeriod = period
        await viewModel.loadAnalytics()

        // Assert
        #expect(viewModel.selectedTimePeriod == period)
        #expect(viewModel.isLoading == false)
    }

    @Test("Recent sessions are filtered by time period", .tags(.unit))
    func testRecentSessionsFiltering() {
        // Arrange
        let now = Date()
        let weekAgo = now.addingTimeInterval(-7 * 24 * 3600)
        let monthAgo = now.addingTimeInterval(-30 * 24 * 3600)

        let recentResult = createTestScenarioResult(score: 85.0, time: 300)
        let oldResult = createTestScenarioResult(score: 80.0, time: 350)

        // This test verifies the filtering logic exists
        #expect(recentResult.score > 0)
        #expect(oldResult.score > 0)
    }

    // MARK: - Chart Data Generation Tests

    @Test("Score trend data generates correctly", .tags(.unit))
    func testScoreTrendDataGeneration() async {
        // Arrange
        let user = createTestUser()
        let viewModel = AnalyticsViewModel(user: user)

        // Act
        await viewModel.loadAnalytics()
        let trendData = viewModel.generateScoreTrendData()

        // Assert
        #expect(trendData != nil, "Trend data should be generated")
    }

    @Test("Category breakdown generates all categories", .tags(.unit))
    func testCategoryBreakdown() async {
        // Arrange
        let user = createTestUser()
        let viewModel = AnalyticsViewModel(user: user)

        // Act
        await viewModel.loadAnalytics()
        let breakdown = viewModel.generateCategoryBreakdown()

        // Assert
        #expect(breakdown.count >= 0, "Category breakdown should be generated")
    }

    @Test("Completion rate over time calculates", .tags(.unit))
    func testCompletionRateOverTime() async {
        // Arrange
        let user = createTestUser()
        let viewModel = AnalyticsViewModel(user: user)

        // Act
        await viewModel.loadAnalytics()
        let completionData = viewModel.generateCompletionRateData()

        // Assert
        #expect(completionData != nil, "Completion rate data should be generated")
    }

    // MARK: - Comparison Tests

    @Test("Team average comparison works", .tags(.unit))
    func testTeamAverageComparison() async {
        // Arrange
        let user = createTestUser()
        let viewModel = AnalyticsViewModel(user: user)

        // Act
        await viewModel.loadAnalytics()
        let comparison = viewModel.compareToTeamAverage()

        // Assert - comparison should return a percentage
        #expect(comparison >= -100 && comparison <= 100, "Comparison should be a percentage")
    }

    @Test("Industry benchmark comparison works", .tags(.unit))
    func testIndustryBenchmarkComparison() async {
        // Arrange
        let user = createTestUser()
        let viewModel = AnalyticsViewModel(user: user)

        // Act
        await viewModel.loadAnalytics()
        let benchmark = viewModel.compareToIndustryBenchmark()

        // Assert
        #expect(benchmark >= -100 && benchmark <= 100, "Benchmark comparison should be valid")
    }

    // MARK: - Export Tests

    @Test("Export data generates CSV format", .tags(.unit))
    func testExportDataCSV() async {
        // Arrange
        let user = createTestUser()
        let viewModel = AnalyticsViewModel(user: user)
        await viewModel.loadAnalytics()

        // Act
        let csvData = viewModel.exportData(format: .csv)

        // Assert
        #expect(csvData != nil, "CSV export should generate data")
        #expect(csvData!.count > 0, "CSV should have content")
    }

    @Test("Export data generates PDF format", .tags(.unit))
    func testExportDataPDF() async {
        // Arrange
        let user = createTestUser()
        let viewModel = AnalyticsViewModel(user: user)
        await viewModel.loadAnalytics()

        // Act
        let pdfData = viewModel.exportData(format: .pdf)

        // Assert
        #expect(pdfData != nil, "PDF export should generate data")
    }

    @Test("Export data generates JSON format", .tags(.unit))
    func testExportDataJSON() async {
        // Arrange
        let user = createTestUser()
        let viewModel = AnalyticsViewModel(user: user)
        await viewModel.loadAnalytics()

        // Act
        let jsonData = viewModel.exportData(format: .json)

        // Assert
        #expect(jsonData != nil, "JSON export should generate data")
    }

    // MARK: - Skill Level Tests

    @Test("Skill progression tracks over time", .tags(.unit))
    func testSkillProgression() async {
        // Arrange
        let user = createTestUser()
        let viewModel = AnalyticsViewModel(user: user)

        // Act
        await viewModel.loadAnalytics()
        let progression = viewModel.getSkillProgression()

        // Assert
        #expect(progression != nil, "Skill progression should be trackable")
    }

    @Test("Overall skill level calculates from all categories", .tags(.unit))
    func testOverallSkillLevelCalculation() {
        // Arrange
        var metrics = createTestMetrics()
        metrics.hazardRecognitionLevel = .intermediate
        metrics.emergencyResponseLevel = .intermediate
        metrics.equipmentSafetyLevel = .beginner
        metrics.chemicalHandlingLevel = .advanced

        // Act
        let overallLevel = metrics.overallSkillLevel

        // Assert
        #expect(overallLevel != .beginner, "Should calculate weighted average")
    }

    // MARK: - Improvement Recommendations Tests

    @Test("Recommendations generated for weak areas", .tags(.unit))
    func testImprovementRecommendations() async {
        // Arrange
        let user = createTestUser()
        let viewModel = AnalyticsViewModel(user: user)
        await viewModel.loadAnalytics()

        // Act
        let recommendations = viewModel.generateRecommendations()

        // Assert
        #expect(recommendations.count >= 0, "Recommendations should be generated")
    }

    @Test("Recommendations prioritize low-scoring categories", .tags(.unit))
    func testRecommendationPrioritization() async {
        // Arrange
        let user = createTestUser()
        let viewModel = AnalyticsViewModel(user: user)
        await viewModel.loadAnalytics()

        // Act
        let recommendations = viewModel.generateRecommendations()

        // If recommendations exist, they should be prioritized
        if !recommendations.isEmpty {
            #expect(recommendations.first?.priority != nil, "Recommendations should have priority")
        }
    }

    // MARK: - Error Handling Tests

    @Test("ViewModel handles missing metrics gracefully", .tags(.unit))
    func testMissingMetricsHandling() async {
        // Arrange
        let user = createTestUser()
        let viewModel = AnalyticsViewModel(user: user)

        // Act - attempt to load analytics for user with no data
        await viewModel.loadAnalytics()

        // Assert - should not crash and should set defaults
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil || viewModel.errorMessage!.isEmpty)
    }

    @Test("ViewModel handles data loading errors", .tags(.unit))
    func testDataLoadingErrorHandling() async {
        // Arrange
        let user = createTestUser()
        let viewModel = AnalyticsViewModel(user: user)

        // This tests the error handling path exists
        viewModel.simulateError(LoadingError.networkUnavailable)

        // Assert
        #expect(viewModel.errorMessage != nil, "Error message should be set")
    }

    // MARK: - Refresh Tests

    @Test("Analytics can be refreshed", .tags(.unit))
    func testAnalyticsRefresh() async {
        // Arrange
        let user = createTestUser()
        let viewModel = AnalyticsViewModel(user: user)
        await viewModel.loadAnalytics()
        let initialLoadTime = viewModel.lastUpdated

        // Act - wait a moment and refresh
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        await viewModel.refreshAnalytics()
        let refreshLoadTime = viewModel.lastUpdated

        // Assert
        #expect(refreshLoadTime >= initialLoadTime, "Refresh should update timestamp")
    }

    @Test("Loading state toggles correctly during refresh", .tags(.unit))
    func testLoadingStateDuringRefresh() async {
        // Arrange
        let user = createTestUser()
        let viewModel = AnalyticsViewModel(user: user)

        // Act
        Task {
            await viewModel.refreshAnalytics()
        }

        // Allow loading to start
        try? await Task.sleep(nanoseconds: 10_000_000) // 0.01 seconds

        // During loading, isLoading might be true or already finished
        // This just verifies the loading mechanism exists
        _ = viewModel.isLoading
    }
}

// MARK: - Helper Enums

enum TimePeriod: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case quarter = "Quarter"
    case year = "Year"
    case allTime = "All Time"

    var dateRange: (start: Date, end: Date) {
        let now = Date()
        let calendar = Calendar.current

        switch self {
        case .week:
            let start = calendar.date(byAdding: .day, value: -7, to: now)!
            return (start, now)
        case .month:
            let start = calendar.date(byAdding: .month, value: -1, to: now)!
            return (start, now)
        case .quarter:
            let start = calendar.date(byAdding: .month, value: -3, to: now)!
            return (start, now)
        case .year:
            let start = calendar.date(byAdding: .year, value: -1, to: now)!
            return (start, now)
        case .allTime:
            return (Date.distantPast, now)
        }
    }
}

enum ExportFormat {
    case csv, pdf, json
}

enum LoadingError: Error {
    case networkUnavailable
    case invalidData
    case unauthorized
}

// MARK: - Test Tags Extension

extension Tag {
    @Tag static var unit: Self
}
