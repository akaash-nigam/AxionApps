//
//  DashboardViewModelTests.swift
//  SurgicalTrainingUniverseTests
//
//  Unit tests for DashboardViewModel
//

import XCTest
import SwiftData
@testable import SurgicalTrainingUniverse

final class DashboardViewModelTests: XCTestCase {

    var viewModel: DashboardViewModel!
    var procedureService: ProcedureService!
    var analyticsService: AnalyticsService!
    var modelContext: ModelContext!
    var testSurgeon: SurgeonProfile!

    override func setUp() async throws {
        // Create in-memory model container
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

        // Create test surgeon
        testSurgeon = SurgeonProfile(
            name: "Dr. Test Surgeon",
            email: "test@hospital.edu",
            specialization: .generalSurgery,
            level: .resident2,
            institution: "Test Hospital"
        )
        modelContext.insert(testSurgeon)
        try modelContext.save()

        // Initialize services
        procedureService = ProcedureService(modelContext: modelContext)
        analyticsService = AnalyticsService(modelContext: modelContext)

        // Initialize view model
        viewModel = DashboardViewModel(
            procedureService: procedureService,
            analyticsService: analyticsService,
            modelContext: modelContext,
            currentUser: testSurgeon
        )
    }

    override func tearDown() {
        viewModel = nil
        procedureService = nil
        analyticsService = nil
        modelContext = nil
        testSurgeon = nil
    }

    // MARK: - Initialization Tests

    func testViewModelInitialization() {
        XCTAssertNotNil(viewModel)
        XCTAssertEqual(viewModel.currentUser?.name, "Dr. Test Surgeon")
        XCTAssertTrue(viewModel.recentSessions.isEmpty)
        XCTAssertNil(viewModel.performanceMetrics)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testAvailableProcedures() {
        XCTAssertEqual(viewModel.availableProcedures.count, 5)
        XCTAssertTrue(viewModel.availableProcedures.contains { $0.type == .appendectomy })
        XCTAssertTrue(viewModel.availableProcedures.contains { $0.type == .cholecystectomy })
    }

    // MARK: - Computed Properties Tests

    func testHasRecentActivity() {
        XCTAssertFalse(viewModel.hasRecentActivity)

        viewModel.recentSessions = [createTestSession()]
        XCTAssertTrue(viewModel.hasRecentActivity)
    }

    func testCanStartProcedure() {
        XCTAssertTrue(viewModel.canStartProcedure)

        viewModel.isLoading = true
        XCTAssertFalse(viewModel.canStartProcedure)

        viewModel.isLoading = false
        viewModel.currentUser = nil
        XCTAssertFalse(viewModel.canStartProcedure)
    }

    func testFormattedMetrics() {
        // Without metrics
        XCTAssertEqual(viewModel.formattedAccuracy, "--")
        XCTAssertEqual(viewModel.formattedEfficiency, "--")
        XCTAssertEqual(viewModel.formattedSafety, "--")

        // With metrics
        viewModel.performanceMetrics = PerformanceMetrics(
            averageAccuracy: 85.5,
            averageEfficiency: 90.2,
            averageSafety: 92.8,
            totalSessions: 10
        )

        XCTAssertEqual(viewModel.formattedAccuracy, "85.5%")
        XCTAssertEqual(viewModel.formattedEfficiency, "90.2%")
        XCTAssertEqual(viewModel.formattedSafety, "92.8%")
    }

    func testTotalProceduresText() {
        XCTAssertEqual(viewModel.totalProceduresText, "0")

        testSurgeon.totalProcedures = 25
        XCTAssertEqual(viewModel.totalProceduresText, "25")
    }

    // MARK: - Data Loading Tests

    @MainActor
    func testLoadDashboardData() async {
        // Create test sessions
        let session1 = createTestSession(accuracyScore: 85.0)
        let session2 = createTestSession(accuracyScore: 90.0)

        modelContext.insert(session1)
        modelContext.insert(session2)
        try? modelContext.save()

        await viewModel.loadDashboardData()

        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.recentSessions.count, 2)
        XCTAssertNotNil(viewModel.performanceMetrics)
    }

    @MainActor
    func testLoadDashboardDataWithoutUser() async {
        viewModel.currentUser = nil

        await viewModel.loadDashboardData()

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
        XCTAssertFalse(viewModel.recentSessions.isEmpty)
    }

    // MARK: - Procedure Management Tests

    @MainActor
    func testStartProcedure() async {
        await viewModel.startProcedure(.appendectomy)

        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.selectedProcedure, .appendectomy)
        XCTAssertNil(viewModel.errorMessage)
    }

    @MainActor
    func testStartProcedureWithoutUser() async {
        viewModel.currentUser = nil

        await viewModel.startProcedure(.appendectomy)

        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, "No user logged in")
        XCTAssertNil(viewModel.selectedProcedure)
    }

    // MARK: - Helper Method Tests

    func testGetProcedureInfo() {
        let info = viewModel.getProcedureInfo(for: .appendectomy)

        XCTAssertNotNil(info)
        XCTAssertEqual(info?.type, .appendectomy)
        XCTAssertEqual(info?.name, "Appendectomy")
        XCTAssertEqual(info?.difficulty, .beginner)
    }

    func testFormatDuration() {
        XCTAssertEqual(viewModel.formatDuration(65), "1:05")
        XCTAssertEqual(viewModel.formatDuration(3661), "61:01")
        XCTAssertEqual(viewModel.formatDuration(0), "0:00")
    }

    func testFormatDate() {
        let date = Date()
        let formatted = viewModel.formatDate(date)

        XCTAssertFalse(formatted.isEmpty)
        // Date formatting is locale-dependent, just verify it returns something
    }

    func testRelativeTime() {
        let oneHourAgo = Date().addingTimeInterval(-3600)
        let relative = viewModel.relativeTime(from: oneHourAgo)

        XCTAssertFalse(relative.isEmpty)
        XCTAssertTrue(relative.contains("ago") || relative.contains("hour"))
    }

    // MARK: - Procedure Info Tests

    func testProcedureInfoProperties() {
        let info = ProcedureInfo(
            type: .appendectomy,
            name: "Appendectomy",
            description: "Removal of the appendix",
            difficulty: .beginner,
            estimatedDuration: 45
        )

        XCTAssertEqual(info.difficultyText, "Beginner")
        XCTAssertEqual(info.difficultyColor, "green")
    }

    func testProcedureInfoDifficultyColors() {
        let beginner = ProcedureInfo(type: .appendectomy, name: "", description: "", difficulty: .beginner, estimatedDuration: 0)
        XCTAssertEqual(beginner.difficultyColor, "green")

        let intermediate = ProcedureInfo(type: .cholecystectomy, name: "", description: "", difficulty: .intermediate, estimatedDuration: 0)
        XCTAssertEqual(intermediate.difficultyColor, "orange")

        let advanced = ProcedureInfo(type: .laparoscopicSurgery, name: "", description: "", difficulty: .advanced, estimatedDuration: 0)
        XCTAssertEqual(advanced.difficultyColor, "red")

        let expert = ProcedureInfo(type: .laparoscopicSurgery, name: "", description: "", difficulty: .expert, estimatedDuration: 0)
        XCTAssertEqual(expert.difficultyColor, "purple")
    }

    // MARK: - Performance Metrics Tests

    func testPerformanceMetricsOverallScore() {
        let metrics = PerformanceMetrics(
            averageAccuracy: 80.0,
            averageEfficiency: 90.0,
            averageSafety: 85.0,
            totalSessions: 5
        )

        let expectedOverall = (80.0 + 90.0 + 85.0) / 3.0
        XCTAssertEqual(metrics.overallScore, expectedOverall, accuracy: 0.01)
    }

    func testPerformanceMetricsGrading() {
        let excellentMetrics = PerformanceMetrics(averageAccuracy: 92.0, averageEfficiency: 91.0, averageSafety: 90.0, totalSessions: 1)
        XCTAssertEqual(excellentMetrics.performanceGrade, "A")

        let goodMetrics = PerformanceMetrics(averageAccuracy: 82.0, averageEfficiency: 88.0, averageSafety: 85.0, totalSessions: 1)
        XCTAssertEqual(goodMetrics.performanceGrade, "B")

        let averageMetrics = PerformanceMetrics(averageAccuracy: 72.0, averageEfficiency: 78.0, averageSafety: 75.0, totalSessions: 1)
        XCTAssertEqual(averageMetrics.performanceGrade, "C")

        let belowAverageMetrics = PerformanceMetrics(averageAccuracy: 62.0, averageEfficiency: 68.0, averageSafety: 65.0, totalSessions: 1)
        XCTAssertEqual(belowAverageMetrics.performanceGrade, "D")

        let poorMetrics = PerformanceMetrics(averageAccuracy: 52.0, averageEfficiency: 58.0, averageSafety: 55.0, totalSessions: 1)
        XCTAssertEqual(poorMetrics.performanceGrade, "F")
    }

    // MARK: - Helper Methods

    private func createTestSession(
        accuracyScore: Double = 85.0,
        efficiencyScore: Double = 90.0,
        safetyScore: Double = 92.0
    ) -> ProcedureSession {
        let session = ProcedureSession(
            procedureType: .appendectomy,
            surgeon: testSurgeon
        )
        session.accuracyScore = accuracyScore
        session.efficiencyScore = efficiencyScore
        session.safetyScore = safetyScore
        session.endTime = Date()
        return session
    }
}
