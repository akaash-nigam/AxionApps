import Testing
import Foundation
@testable import IndustrialSafetySimulator

@Suite("PerformanceMetrics Model Tests")
struct PerformanceMetricsTests {

    // MARK: - Helper Functions

    func createTestMetrics() -> PerformanceMetrics {
        PerformanceMetrics(userId: UUID())
    }

    func createTestScenarioResult(passed: Bool, score: Double, hazardAccuracy: Double) -> ScenarioResult {
        let scenario = SafetyScenario(
            name: "Test",
            description: "Test",
            environment: .factoryFloor,
            realityKitScene: "Test"
        )

        let result = ScenarioResult(
            scenario: scenario,
            timeCompleted: 300,
            score: score
        )

        // Set hazard accuracy
        result.detectedHazards = Array(repeating: Hazard(
            type: .electrical,
            severity: .medium,
            name: "H",
            description: "D",
            location: SIMD3<Float>(0, 0, 0)
        ), count: Int(hazardAccuracy))

        result.missedHazards = Array(repeating: Hazard(
            type: .chemical,
            severity: .low,
            name: "M",
            description: "D",
            location: SIMD3<Float>(1, 0, 0)
        ), count: Int(100 - hazardAccuracy))

        return result
    }

    // MARK: - Initialization Tests

    @Test("Performance metrics initialize with default values")
    func testMetricsInitialization() {
        // Arrange
        let userId = UUID()

        // Act
        let metrics = PerformanceMetrics(userId: userId)

        // Assert
        #expect(metrics.userId == userId)
        #expect(metrics.totalTrainingHours == 0)
        #expect(metrics.scenariosCompleted == 0)
        #expect(metrics.scenariosPassed == 0)
        #expect(metrics.scenariosFailed == 0)
        #expect(metrics.averageScore == 0)
        #expect(metrics.bestScore == 0)
        #expect(metrics.latestScore == 0)
        #expect(metrics.hazardRecognitionAccuracy == 0)
        #expect(metrics.safetyComplianceRate == 0)
        #expect(metrics.riskScore == 0)
    }

    @Test("Metrics last updated is set")
    func testLastUpdatedIsSet() {
        // Arrange
        let beforeCreation = Date()
        let metrics = createTestMetrics()
        let afterCreation = Date()

        // Assert
        #expect(metrics.lastUpdated >= beforeCreation)
        #expect(metrics.lastUpdated <= afterCreation)
    }

    // MARK: - Pass Rate Tests

    @Test("Pass rate calculates correctly", arguments: [
        (10, 8, 80.0),   // 8 passed out of 10 = 80%
        (5, 5, 100.0),   // All passed = 100%
        (10, 0, 0.0),    // None passed = 0%
        (1, 1, 100.0),   // Single pass = 100%
    ])
    func testPassRateCalculation(completed: Int, passed: Int, expectedRate: Double) {
        // Arrange
        var metrics = createTestMetrics()
        metrics.scenariosCompleted = completed
        metrics.scenariosPassed = passed

        // Act
        let passRate = metrics.passRate

        // Assert
        #expect(passRate == expectedRate)
    }

    @Test("Pass rate with zero scenarios completed")
    func testPassRateWithZeroScenarios() {
        // Arrange
        let metrics = createTestMetrics()

        // Act
        let passRate = metrics.passRate

        // Assert
        #expect(passRate == 0, "Pass rate should be 0 when no scenarios completed")
    }

    // MARK: - Session Update Tests

    @Test("Metrics update after passing session")
    func testUpdateAfterPassingSession() {
        // Arrange
        var metrics = createTestMetrics()
        let passingResult = createTestScenarioResult(passed: true, score: 85.0, hazardAccuracy: 90.0)

        // Act
        metrics.updateAfterSession(passingResult)

        // Assert
        #expect(metrics.scenariosCompleted == 1)
        #expect(metrics.scenariosPassed == 1)
        #expect(metrics.scenariosFailed == 0)
        #expect(metrics.averageScore == 85.0)
        #expect(metrics.bestScore == 85.0)
        #expect(metrics.latestScore == 85.0)
    }

    @Test("Metrics update after failing session")
    func testUpdateAfterFailingSession() {
        // Arrange
        var metrics = createTestMetrics()
        let failingResult = createTestScenarioResult(passed: false, score: 65.0, hazardAccuracy: 70.0)

        // Act
        metrics.updateAfterSession(failingResult)

        // Assert
        #expect(metrics.scenariosCompleted == 1)
        #expect(metrics.scenariosPassed == 0)
        #expect(metrics.scenariosFailed == 1)
        #expect(metrics.averageScore == 65.0)
        #expect(metrics.bestScore == 65.0)
        #expect(metrics.latestScore == 65.0)
    }

    @Test("Average score updates correctly over multiple sessions")
    func testAverageScoreMultipleSessions() {
        // Arrange
        var metrics = createTestMetrics()

        // Act
        metrics.updateAfterSession(createTestScenarioResult(passed: true, score: 80.0, hazardAccuracy: 85.0))
        metrics.updateAfterSession(createTestScenarioResult(passed: true, score: 90.0, hazardAccuracy: 95.0))
        metrics.updateAfterSession(createTestScenarioResult(passed: true, score: 70.0, hazardAccuracy: 75.0))

        // Assert
        #expect(metrics.scenariosCompleted == 3)
        #expect(metrics.averageScore == 80.0, "Average of 80, 90, 70 should be 80")
    }

    @Test("Best score updates only when score is higher")
    func testBestScoreUpdates() {
        // Arrange
        var metrics = createTestMetrics()

        // Act
        metrics.updateAfterSession(createTestScenarioResult(passed: true, score: 85.0, hazardAccuracy: 80.0))
        #expect(metrics.bestScore == 85.0)

        metrics.updateAfterSession(createTestScenarioResult(passed: true, score: 90.0, hazardAccuracy: 85.0))
        #expect(metrics.bestScore == 90.0, "Best score should update to 90")

        metrics.updateAfterSession(createTestScenarioResult(passed: true, score: 80.0, hazardAccuracy: 75.0))
        #expect(metrics.bestScore == 90.0, "Best score should remain 90")
    }

    @Test("Latest score always updates")
    func testLatestScoreAlwaysUpdates() {
        // Arrange
        var metrics = createTestMetrics()

        // Act
        metrics.updateAfterSession(createTestScenarioResult(passed: true, score: 80.0, hazardAccuracy: 80.0))
        #expect(metrics.latestScore == 80.0)

        metrics.updateAfterSession(createTestScenarioResult(passed: true, score: 70.0, hazardAccuracy: 70.0))
        #expect(metrics.latestScore == 70.0)

        metrics.updateAfterSession(createTestScenarioResult(passed: true, score: 95.0, hazardAccuracy: 95.0))
        #expect(metrics.latestScore == 95.0)
    }

    // MARK: - Skill Level Tests

    @Test("Overall skill level calculates correctly")
    func testOverallSkillLevel() {
        // Arrange
        var metrics = createTestMetrics()

        // Test all beginners
        metrics.hazardRecognitionLevel = .beginner
        metrics.emergencyResponseLevel = .beginner
        metrics.equipmentSafetyLevel = .beginner
        metrics.chemicalHandlingLevel = .beginner
        #expect(metrics.overallSkillLevel == .beginner)

        // Test mixed levels averaging to intermediate
        metrics.hazardRecognitionLevel = .intermediate
        metrics.emergencyResponseLevel = .intermediate
        metrics.equipmentSafetyLevel = .beginner
        metrics.chemicalHandlingLevel = .intermediate
        #expect(metrics.overallSkillLevel == .intermediate)

        // Test all experts
        metrics.hazardRecognitionLevel = .expert
        metrics.emergencyResponseLevel = .expert
        metrics.equipmentSafetyLevel = .expert
        metrics.chemicalHandlingLevel = .expert
        #expect(metrics.overallSkillLevel == .expert)
    }

    @Test("Skill levels are comparable", arguments: [
        (SkillLevel.beginner, SkillLevel.intermediate, true),
        (SkillLevel.intermediate, SkillLevel.advanced, true),
        (SkillLevel.advanced, SkillLevel.expert, true),
        (SkillLevel.expert, SkillLevel.beginner, false),
    ])
    func testSkillLevelComparison(level1: SkillLevel, level2: SkillLevel, level1ShouldBeLess: Bool) {
        #expect((level1 < level2) == level1ShouldBeLess)
    }

    @Test("All skill levels have display names")
    func testSkillLevelDisplayNames() {
        #expect(SkillLevel.beginner.displayName == "Beginner")
        #expect(SkillLevel.intermediate.displayName == "Intermediate")
        #expect(SkillLevel.advanced.displayName == "Advanced")
        #expect(SkillLevel.expert.displayName == "Expert")
    }

    @Test("All skill levels have colors")
    func testSkillLevelColors() {
        let levels: [SkillLevel] = [.beginner, .intermediate, .advanced, .expert]

        for level in levels {
            #expect(level.color.isEmpty == false, "Skill level \(level) should have a color")
        }
    }

    // MARK: - Risk Score Tests

    @Test("Risk score calculates from recent results")
    func testRiskScoreCalculation() {
        // Arrange
        var metrics = createTestMetrics()

        // Create results with various failure patterns
        let goodResult = createTestScenarioResult(passed: true, score: 90.0, hazardAccuracy: 95.0)
        let poorResult = createTestScenarioResult(passed: false, score: 60.0, hazardAccuracy: 50.0)

        // Act
        let riskWithGoodResults = metrics.calculateRiskScore(based: [goodResult, goodResult, goodResult])
        let riskWithPoorResults = metrics.calculateRiskScore(based: [poorResult, poorResult, poorResult])
        let riskWithMixed = metrics.calculateRiskScore(based: [goodResult, poorResult, goodResult])

        // Assert
        #expect(riskWithGoodResults < riskWithPoorResults, "Risk should be lower with good results")
        #expect(riskWithMixed > riskWithGoodResults, "Risk should be higher with mixed results than all good")
        #expect(riskWithMixed < riskWithPoorResults, "Risk should be lower with mixed than all poor")
    }

    @Test("Risk score with no results")
    func testRiskScoreNoResults() {
        // Arrange
        let metrics = createTestMetrics()

        // Act
        let risk = metrics.calculateRiskScore(based: [])

        // Assert
        #expect(risk == 50.0, "Risk should be 50% (neutral) with no data")
    }

    @Test("Risk score is between 0 and 100")
    func testRiskScoreBounds() {
        // Arrange
        var metrics = createTestMetrics()

        let perfectResult = createTestScenarioResult(passed: true, score: 100.0, hazardAccuracy: 100.0)
        let worstResult = createTestScenarioResult(passed: false, score: 0.0, hazardAccuracy: 0.0)

        // Act
        let minRisk = metrics.calculateRiskScore(based: [perfectResult, perfectResult])
        let maxRisk = metrics.calculateRiskScore(based: [worstResult, worstResult])

        // Assert
        #expect(minRisk >= 0, "Risk should not be negative")
        #expect(maxRisk <= 100, "Risk should not exceed 100")
    }

    // MARK: - Edge Cases

    @Test("Metrics with maximum values")
    func testMaximumValues() {
        // Arrange
        var metrics = createTestMetrics()
        metrics.totalTrainingHours = 10000
        metrics.scenariosCompleted = 1000
        metrics.scenariosPassed = 1000
        metrics.averageScore = 100.0
        metrics.bestScore = 100.0

        // Act
        let passRate = metrics.passRate

        // Assert
        #expect(passRate == 100.0)
        #expect(metrics.averageScore == 100.0)
    }

    @Test("Metrics handle fractional hours")
    func testFractionalHours() {
        // Arrange
        var metrics = createTestMetrics()
        metrics.totalTrainingHours = 12.5 // 12.5 hours

        // Assert
        #expect(metrics.totalTrainingHours == 12.5)
    }

    @Test("Achievements can be added")
    func testAchievements() {
        // Arrange
        var metrics = createTestMetrics()

        let achievements = [
            "Perfect Score",
            "Quick Learner",
            "Safety Champion"
        ]

        // Act
        metrics.achievementsUnlocked = achievements

        // Assert
        #expect(metrics.achievementsUnlocked.count == 3)
        #expect(metrics.achievementsUnlocked.contains("Safety Champion"))
    }

    @Test("Certifications can be tracked")
    func testCertifications() {
        // Arrange
        var metrics = createTestMetrics()

        let certifications = [
            "Basic Safety",
            "Fire Response",
            "Lockout/Tagout"
        ]

        // Act
        metrics.certificationsEarned = certifications

        // Assert
        #expect(metrics.certificationsEarned.count == 3)
        #expect(metrics.certificationsEarned.contains("Lockout/Tagout"))
    }

    @Test("Improvement trend can be positive or negative")
    func testImprovementTrend() {
        // Arrange
        var metrics = createTestMetrics()

        // Act - Positive trend
        metrics.improvementTrend = 15.5
        #expect(metrics.improvementTrend > 0, "Positive trend should be > 0")

        // Act - Negative trend
        metrics.improvementTrend = -12.3
        #expect(metrics.improvementTrend < 0, "Negative trend should be < 0")

        // Act - Stable
        metrics.improvementTrend = 0.0
        #expect(metrics.improvementTrend == 0, "Stable trend should be 0")
    }

    @Test("Consistency score is between 0 and 100")
    func testConsistencyScore() {
        // Arrange
        var metrics = createTestMetrics()

        // Act
        metrics.consistencyScore = 85.0

        // Assert
        #expect(metrics.consistencyScore >= 0)
        #expect(metrics.consistencyScore <= 100)
    }
}

@Suite("TrendData Tests")
struct TrendDataTests {

    @Test("Trend data encodes and decodes correctly")
    func testTrendDataCodable() throws {
        // Arrange
        let trendData = TrendData(
            weeklyScores: [80, 85, 90, 88, 92],
            monthlyScores: [82, 88, 91],
            direction: .improving
        )

        // Act - Encode
        let encoder = JSONEncoder()
        let data = try encoder.encode(trendData)

        // Act - Decode
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(TrendData.self, from: data)

        // Assert
        #expect(decoded.weeklyScores == trendData.weeklyScores)
        #expect(decoded.monthlyScores == trendData.monthlyScores)
        #expect(decoded.direction == trendData.direction)
    }

    @Test("All trend directions exist")
    func testTrendDirections() {
        let improving = TrendData.TrendDirection.improving
        let stable = TrendData.TrendDirection.stable
        let declining = TrendData.TrendDirection.declining

        #expect(improving.rawValue == "Improving")
        #expect(stable.rawValue == "Stable")
        #expect(declining.rawValue == "Declining")
    }
}

@Suite("CertificationStatus Tests")
struct CertificationStatusTests {

    @Test("Certification status with expiration")
    func testCertificationStatus() {
        // Arrange
        let futureDate = Date().addingTimeInterval(365 * 24 * 3600) // 1 year from now
        let status = CertificationStatus(
            name: "Fire Safety",
            isValid: true,
            expirationDate: futureDate,
            renewalRequired: false
        )

        // Assert
        #expect(status.name == "Fire Safety")
        #expect(status.isValid == true)
        #expect(status.expirationDate == futureDate)
        #expect(status.renewalRequired == false)
    }

    @Test("Certification status requiring renewal")
    func testRenewalRequired() {
        // Arrange
        let soonExpiring = Date().addingTimeInterval(30 * 24 * 3600) // 30 days from now
        let status = CertificationStatus(
            name: "HAZMAT",
            isValid: true,
            expirationDate: soonExpiring,
            renewalRequired: true
        )

        // Assert
        #expect(status.renewalRequired == true)
    }
}
