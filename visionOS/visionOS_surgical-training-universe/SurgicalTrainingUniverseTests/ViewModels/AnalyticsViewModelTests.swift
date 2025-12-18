//
//  AnalyticsViewModelTests.swift
//  SurgicalTrainingUniverseTests
//
//  Unit tests for AnalyticsViewModel
//

import XCTest
import SwiftData
@testable import SurgicalTrainingUniverse

final class AnalyticsViewModelTests: XCTestCase {

    var viewModel: AnalyticsViewModel!
    var analyticsService: AnalyticsService!
    var procedureService: ProcedureService!
    var modelContext: ModelContext!
    var testSurgeon: SurgeonProfile!

    override func setUp() async throws {
        let schema = Schema([
            SurgeonProfile.self,
            ProcedureSession.self,
            SurgicalMovement.self,
            Complication.self,
            Certification.self
        ])

        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])
        modelContext = ModelContext(container)

        testSurgeon = SurgeonProfile(
            name: "Dr. Analytics Test",
            email: "analytics@hospital.edu",
            specialization: .generalSurgery,
            level: .resident3,
            institution: "Analytics Hospital"
        )
        modelContext.insert(testSurgeon)
        try modelContext.save()

        analyticsService = AnalyticsService(modelContext: modelContext)
        procedureService = ProcedureService(modelContext: modelContext)

        viewModel = AnalyticsViewModel(
            analyticsService: analyticsService,
            procedureService: procedureService,
            modelContext: modelContext,
            currentUser: testSurgeon
        )
    }

    override func tearDown() {
        viewModel = nil
        analyticsService = nil
        procedureService = nil
        modelContext = nil
        testSurgeon = nil
    }

    // MARK: - Initialization Tests

    func testViewModelInitialization() {
        XCTAssertNotNil(viewModel)
        XCTAssertEqual(viewModel.currentUser?.name, "Dr. Analytics Test")
        XCTAssertTrue(viewModel.sessions.isEmpty)
        XCTAssertEqual(viewModel.selectedTimeRange, .last30Days)
        XCTAssertNil(viewModel.selectedProcedureType)
        XCTAssertFalse(viewModel.isLoading)
    }

    // MARK: - Computed Properties Tests

    func testHasData() {
        XCTAssertFalse(viewModel.hasData)

        viewModel.sessions = [createTestSession()]
        XCTAssertTrue(viewModel.hasData)
    }

    func testTotalSessions() {
        XCTAssertEqual(viewModel.totalSessions, 0)

        viewModel.sessions = [createTestSession(), createTestSession()]
        XCTAssertEqual(viewModel.totalSessions, 2)
    }

    func testAverageScoresCalculation() {
        viewModel.sessions = [
            createTestSession(accuracy: 80.0, efficiency: 85.0, safety: 90.0),
            createTestSession(accuracy: 90.0, efficiency: 95.0, safety: 88.0),
            createTestSession(accuracy: 85.0, efficiency: 80.0, safety: 92.0)
        ]

        XCTAssertEqual(viewModel.averageAccuracy, (80 + 90 + 85) / 3.0, accuracy: 0.01)
        XCTAssertEqual(viewModel.averageEfficiency, (85 + 95 + 80) / 3.0, accuracy: 0.01)
        XCTAssertEqual(viewModel.averageSafety, (90 + 88 + 92) / 3.0, accuracy: 0.01)
    }

    func testAverageScoresWithNoData() {
        XCTAssertEqual(viewModel.averageAccuracy, 0)
        XCTAssertEqual(viewModel.averageEfficiency, 0)
        XCTAssertEqual(viewModel.averageSafety, 0)
    }

    func testOverallScore() {
        viewModel.sessions = [
            createTestSession(accuracy: 80.0, efficiency: 90.0, safety: 85.0)
        ]

        let expected = (80.0 + 90.0 + 85.0) / 3.0
        XCTAssertEqual(viewModel.overallScore, expected, accuracy: 0.01)
    }

    func testFormattedScores() {
        viewModel.sessions = [
            createTestSession(accuracy: 85.5, efficiency: 90.2, safety: 92.8)
        ]

        XCTAssertEqual(viewModel.formattedAccuracy, "85.5%")
        XCTAssertEqual(viewModel.formattedEfficiency, "90.2%")
        XCTAssertEqual(viewModel.formattedSafety, "92.8%")
        XCTAssertTrue(viewModel.formattedOverallScore.contains("%"))
    }

    func testMasteryLevelText() {
        // Test different mastery levels based on score and session count
        viewModel.sessions = Array(repeating: createTestSession(accuracy: 95.0, efficiency: 95.0, safety: 95.0), count: 100)

        let masteryText = viewModel.masteryLevelText
        XCTAssertFalse(masteryText.isEmpty)
        XCTAssertTrue(["Novice", "Beginner", "Competent", "Proficient", "Expert"].contains(masteryText))
    }

    func testMasteryLevelColor() {
        let color = viewModel.masteryLevelColor
        XCTAssertFalse(color.isEmpty)
        XCTAssertTrue(["gray", "blue", "green", "orange", "purple"].contains(color))
    }

    // MARK: - Data Loading Tests

    @MainActor
    func testLoadAnalytics() async {
        let session1 = createTestSession(accuracy: 85.0)
        let session2 = createTestSession(accuracy: 90.0)

        modelContext.insert(session1)
        modelContext.insert(session2)
        try? modelContext.save()

        await viewModel.loadAnalytics()

        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.sessions.count, 2)
    }

    @MainActor
    func testLoadAnalyticsWithoutUser() async {
        viewModel.currentUser = nil

        await viewModel.loadAnalytics()

        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, "No user logged in")
    }

    @MainActor
    func testRefresh() async {
        let session = createTestSession()
        modelContext.insert(session)
        try? modelContext.save()

        await viewModel.refresh()

        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.sessions.isEmpty)
    }

    // MARK: - Time Range Tests

    @MainActor
    func testChangeTimeRange() async {
        await viewModel.changeTimeRange(.last7Days)

        XCTAssertEqual(viewModel.selectedTimeRange, .last7Days)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testFormatTimeRange() {
        viewModel.selectedTimeRange = .last7Days
        XCTAssertEqual(viewModel.formatTimeRange(), "Last 7 Days")

        viewModel.selectedTimeRange = .last30Days
        XCTAssertEqual(viewModel.formatTimeRange(), "Last 30 Days")

        viewModel.selectedTimeRange = .last90Days
        XCTAssertEqual(viewModel.formatTimeRange(), "Last 90 Days")

        viewModel.selectedTimeRange = .lastYear
        XCTAssertEqual(viewModel.formatTimeRange(), "Last Year")

        viewModel.selectedTimeRange = .allTime
        XCTAssertEqual(viewModel.formatTimeRange(), "All Time")
    }

    // MARK: - Procedure Filtering Tests

    @MainActor
    func testFilterByProcedure() async {
        await viewModel.filterByProcedure(.appendectomy)

        XCTAssertEqual(viewModel.selectedProcedureType, .appendectomy)
        XCTAssertFalse(viewModel.isLoading)
    }

    @MainActor
    func testFilterByProcedureNil() async {
        viewModel.selectedProcedureType = .appendectomy
        await viewModel.filterByProcedure(nil)

        XCTAssertNil(viewModel.selectedProcedureType)
    }

    // MARK: - Report Generation Tests

    @MainActor
    func testGenerateReport() async {
        viewModel.sessions = [createTestSession()]

        await viewModel.generateReport()

        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.performanceReport)
    }

    // MARK: - Export Tests

    func testExportData() {
        let session1 = createTestSession(accuracy: 85.0, efficiency: 90.0, safety: 92.0)
        let session2 = createTestSession(accuracy: 88.0, efficiency: 92.0, safety: 95.0)
        viewModel.sessions = [session1, session2]

        let csvData = viewModel.exportData()

        XCTAssertTrue(csvData.contains("Date,Procedure,Accuracy,Efficiency,Safety,Overall"))
        XCTAssertTrue(csvData.contains("85.0"))
        XCTAssertTrue(csvData.contains("90.0"))
        XCTAssertTrue(csvData.contains("92.0"))
    }

    func testExportDataEmpty() {
        let csvData = viewModel.exportData()

        XCTAssertEqual(csvData, "Date,Procedure,Accuracy,Efficiency,Safety,Overall\n")
    }

    // MARK: - Trend Tests

    func testGetTrendImproving() {
        viewModel.sessions = [
            createTestSession(accuracy: 70.0), // Older
            createTestSession(accuracy: 75.0),
            createTestSession(accuracy: 80.0),
            createTestSession(accuracy: 85.0),
            createTestSession(accuracy: 90.0)  // Recent
        ]

        let trend = viewModel.getTrend(for: .accuracy)
        XCTAssertEqual(trend, .improving)
    }

    func testGetTrendStable() {
        viewModel.sessions = [
            createTestSession(accuracy: 85.0),
            createTestSession(accuracy: 86.0),
            createTestSession(accuracy: 85.5),
            createTestSession(accuracy: 85.2),
            createTestSession(accuracy: 85.8)
        ]

        let trend = viewModel.getTrend(for: .accuracy)
        XCTAssertEqual(trend, .stable)
    }

    func testGetTrendWithInsufficientData() {
        viewModel.sessions = [createTestSession()]

        let trend = viewModel.getTrend(for: .accuracy)
        XCTAssertEqual(trend, .stable)
    }

    // MARK: - TimeRange Tests

    func testTimeRangeStartDates() {
        let now = Date()

        let last7Days = TimeRange.last7Days.startDate
        XCTAssertLessThan(last7Days, now)

        let last30Days = TimeRange.last30Days.startDate
        XCTAssertLessThan(last30Days, now)

        let last90Days = TimeRange.last90Days.startDate
        XCTAssertLessThan(last90Days, now)

        let lastYear = TimeRange.lastYear.startDate
        XCTAssertLessThan(lastYear, now)

        let allTime = TimeRange.allTime.startDate
        XCTAssertLessThan(allTime, now)
    }

    // MARK: - TrendDirection Tests

    func testTrendDirectionProperties() {
        XCTAssertEqual(TrendDirection.improving.icon, "arrow.up.right")
        XCTAssertEqual(TrendDirection.stable.icon, "arrow.right")
        XCTAssertEqual(TrendDirection.declining.icon, "arrow.down.right")

        XCTAssertEqual(TrendDirection.improving.color, "green")
        XCTAssertEqual(TrendDirection.stable.color, "gray")
        XCTAssertEqual(TrendDirection.declining.color, "red")
    }

    // MARK: - Helper Methods

    private func createTestSession(
        accuracy: Double = 85.0,
        efficiency: Double = 90.0,
        safety: Double = 92.0
    ) -> ProcedureSession {
        let session = ProcedureSession(
            procedureType: .appendectomy,
            surgeon: testSurgeon
        )
        session.accuracyScore = accuracy
        session.efficiencyScore = efficiency
        session.safetyScore = safety
        session.startTime = Date()
        session.endTime = Date()
        return session
    }
}
