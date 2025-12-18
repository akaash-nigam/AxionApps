//
//  AnalyticsServiceTests.swift
//  Surgical Training Universe Tests
//
//  Unit tests for AnalyticsService
//

import XCTest
@testable import SurgicalTrainingUniverse

final class AnalyticsServiceTests: XCTestCase {

    var analyticsService: AnalyticsService!
    var testSurgeon: SurgeonProfile!
    var testSessions: [ProcedureSession]!

    override func setUpWithError() throws {
        analyticsService = AnalyticsService()

        testSurgeon = SurgeonProfile(
            name: "Dr. Test",
            email: "test@example.com"
        )

        // Create test sessions with varying scores
        testSessions = [
            createSession(accuracy: 85, efficiency: 80, safety: 90),
            createSession(accuracy: 90, efficiency: 85, safety: 95),
            createSession(accuracy: 88, efficiency: 82, safety: 92)
        ]
    }

    override func tearDownWithError() throws {
        analyticsService = nil
        testSurgeon = nil
        testSessions = nil
    }

    // MARK: - Helper Methods

    func createSession(accuracy: Double, efficiency: Double, safety: Double) -> ProcedureSession {
        let session = ProcedureSession(procedureType: .appendectomy, surgeon: testSurgeon)
        session.accuracyScore = accuracy
        session.efficiencyScore = efficiency
        session.safetyScore = safety
        return session
    }

    // MARK: - Average Score Tests

    func testCalculateAverageScores() {
        let (accuracy, efficiency, safety) = analyticsService.calculateAverageScores(
            sessions: testSessions
        )

        XCTAssertEqual(accuracy, (85 + 90 + 88) / 3, accuracy: 0.01)
        XCTAssertEqual(efficiency, (80 + 85 + 82) / 3, accuracy: 0.01)
        XCTAssertEqual(safety, (90 + 95 + 92) / 3, accuracy: 0.01)
    }

    func testCalculateAverageScoresEmptySessions() {
        let (accuracy, efficiency, safety) = analyticsService.calculateAverageScores(
            sessions: []
        )

        XCTAssertEqual(accuracy, 0.0)
        XCTAssertEqual(efficiency, 0.0)
        XCTAssertEqual(safety, 0.0)
    }

    // MARK: - Skill Progression Tests

    func testCalculateSkillProgression() {
        let progression = analyticsService.calculateSkillProgression(sessions: testSessions)

        XCTAssertEqual(progression.count, testSessions.count)
        XCTAssertEqual(progression[0].score, testSessions[0].overallScore)
    }

    // MARK: - Procedure Distribution Tests

    func testAnalyzeProcedureDistribution() {
        let mixedSessions = [
            createSession(accuracy: 85, efficiency: 80, safety: 90),  // appendectomy
            createSession(accuracy: 90, efficiency: 85, safety: 95),  // appendectomy
        ]
        mixedSessions[0].procedureType = .appendectomy
        mixedSessions[1].procedureType = .appendectomy

        let cholecystectomy = createSession(accuracy: 88, efficiency: 82, safety: 92)
        cholecystectomy.procedureType = .cholecystectomy
        mixedSessions.append(cholecystectomy)

        let distribution = analyticsService.analyzeProcedureDistribution(sessions: mixedSessions)

        XCTAssertEqual(distribution[.appendectomy], 2)
        XCTAssertEqual(distribution[.cholecystectomy], 1)
    }

    // MARK: - Learning Curve Tests

    func testCalculateLearningCurve() {
        let sessions = [
            createSession(accuracy: 60, efficiency: 55, safety: 65),
            createSession(accuracy: 70, efficiency: 68, safety: 75),
            createSession(accuracy: 80, efficiency: 78, safety: 85),
            createSession(accuracy: 90, efficiency: 88, safety: 95)
        ]

        let metrics = analyticsService.calculateLearningCurve(
            sessions: sessions,
            procedureType: .appendectomy
        )

        XCTAssertEqual(metrics.totalAttempts, 4)
        XCTAssertGreaterThan(metrics.currentScore, metrics.initialScore)
        XCTAssertGreaterThan(metrics.totalImprovement, 0)
        XCTAssertEqual(metrics.masteryLevel, .expert)
    }

    func testCalculateLearningCurveEmptySessions() {
        let metrics = analyticsService.calculateLearningCurve(
            sessions: [],
            procedureType: .appendectomy
        )

        XCTAssertEqual(metrics.totalAttempts, 0)
        XCTAssertEqual(metrics.masteryLevel, .beginner)
    }

    // MARK: - Mastery Level Tests

    func testMasteryLevelProgression() {
        // Test beginner level
        let beginnerSession = createSession(accuracy: 50, efficiency: 50, safety: 50)
        let beginnerMetrics = analyticsService.calculateLearningCurve(
            sessions: [beginnerSession],
            procedureType: .appendectomy
        )
        XCTAssertEqual(beginnerMetrics.masteryLevel, .beginner)

        // Test intermediate level
        let intermediateSession = createSession(accuracy: 70, efficiency: 70, safety: 70)
        let intermediateMetrics = analyticsService.calculateLearningCurve(
            sessions: [intermediateSession],
            procedureType: .appendectomy
        )
        XCTAssertEqual(intermediateMetrics.masteryLevel, .intermediate)

        // Test advanced level
        let advancedSession = createSession(accuracy: 82, efficiency: 82, safety: 82)
        let advancedMetrics = analyticsService.calculateLearningCurve(
            sessions: [advancedSession],
            procedureType: .appendectomy
        )
        XCTAssertEqual(advancedMetrics.masteryLevel, .advanced)

        // Test expert level
        let expertSession = createSession(accuracy: 95, efficiency: 95, safety: 95)
        let expertMetrics = analyticsService.calculateLearningCurve(
            sessions: [expertSession],
            procedureType: .appendectomy
        )
        XCTAssertEqual(expertMetrics.masteryLevel, .expert)
    }

    // MARK: - Performance Summary Tests

    func testGeneratePerformanceReport() {
        testSurgeon.sessions = testSessions

        let summary = analyticsService.generatePerformanceReport(for: testSurgeon)

        XCTAssertEqual(summary.totalSessions, testSessions.count)
        XCTAssertGreaterThan(summary.averageAccuracy, 0)
        XCTAssertGreaterThan(summary.averageEfficiency, 0)
        XCTAssertGreaterThan(summary.averageSafety, 0)
        XCTAssertGreaterThan(summary.overallScore, 0)
    }

    // MARK: - Performance Tests

    func testAverageScoreCalculationPerformance() {
        // Create 1000 sessions
        var largeSessions: [ProcedureSession] = []
        for _ in 0..<1000 {
            largeSessions.append(createSession(accuracy: 85, efficiency: 80, safety: 90))
        }

        measure {
            _ = analyticsService.calculateAverageScores(sessions: largeSessions)
        }
    }
}
