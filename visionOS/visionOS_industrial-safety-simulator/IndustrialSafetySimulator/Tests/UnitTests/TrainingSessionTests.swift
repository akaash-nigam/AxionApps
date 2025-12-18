import Testing
import Foundation
@testable import IndustrialSafetySimulator

@Suite("TrainingSession Model Tests")
struct TrainingSessionTests {

    // MARK: - Helper Functions

    func createTestUser() -> SafetyUser {
        SafetyUser(
            name: "Test User",
            role: .operator,
            department: "Testing",
            hireDate: Date()
        )
    }

    func createTestModule() -> TrainingModule {
        TrainingModule(
            title: "Test Module",
            description: "Test training module",
            category: .hazardRecognition,
            difficultyLevel: .beginner,
            estimatedDuration: 1800 // 30 minutes
        )
    }

    func createTestScenario() -> SafetyScenario {
        SafetyScenario(
            name: "Test Scenario",
            description: "Test scenario",
            environment: .factoryFloor,
            realityKitScene: "TestScene",
            passingScore: 70.0
        )
    }

    // MARK: - Initialization Tests

    @Test("Training session initializes correctly")
    func testSessionInitialization() {
        // Arrange
        let user = createTestUser()
        let module = createTestModule()
        let startTime = Date()

        // Act
        let session = TrainingSession(
            user: user,
            module: module,
            startTime: startTime
        )

        // Assert
        #expect(session.user.name == user.name)
        #expect(session.module.title == module.title)
        #expect(session.startTime == startTime)
        #expect(session.endTime == nil, "Session should not have end time initially")
        #expect(session.status == .inProgress, "New session should be in progress")
        #expect(session.overallScore == nil, "Score should be nil initially")
    }

    // MARK: - Duration Tests

    @Test("Session duration calculates correctly when ongoing")
    func testOngoingSessionDuration() {
        // Arrange
        let startTime = Date().addingTimeInterval(-300) // 5 minutes ago
        let session = TrainingSession(
            user: createTestUser(),
            module: createTestModule(),
            startTime: startTime
        )

        // Act
        let duration = session.duration

        // Assert
        #expect(duration >= 300, "Duration should be at least 5 minutes")
        #expect(duration < 310, "Duration should be close to 5 minutes")
    }

    @Test("Session duration calculates correctly when completed")
    func testCompletedSessionDuration() {
        // Arrange
        let startTime = Date().addingTimeInterval(-600) // 10 minutes ago
        let endTime = Date().addingTimeInterval(-300)    // 5 minutes ago
        var session = TrainingSession(
            user: createTestUser(),
            module: createTestModule(),
            startTime: startTime
        )
        session.endTime = endTime

        // Act
        let duration = session.duration

        // Assert
        #expect(duration == 300, "Duration should be exactly 5 minutes (300 seconds)")
    }

    // MARK: - Completion Tests

    @Test("Session completes with passing score")
    func testSessionCompleteWithPassingScore() {
        // Arrange
        var session = TrainingSession(
            user: createTestUser(),
            module: createTestModule(),
            startTime: Date().addingTimeInterval(-1800)
        )
        let passingScore = 85.0

        // Act
        session.complete(withScore: passingScore)

        // Assert
        #expect(session.overallScore == passingScore)
        #expect(session.status == .completed, "Session should be completed with passing score")
        #expect(session.endTime != nil, "End time should be set")
    }

    @Test("Session completes with failing score")
    func testSessionCompleteWithFailingScore() {
        // Arrange
        var session = TrainingSession(
            user: createTestUser(),
            module: createTestModule(),
            startTime: Date().addingTimeInterval(-1800)
        )
        let failingScore = 65.0

        // Act
        session.complete(withScore: failingScore)

        // Assert
        #expect(session.overallScore == failingScore)
        #expect(session.status == .failed, "Session should be failed with score < 70")
        #expect(session.endTime != nil, "End time should be set")
    }

    @Test("Session can be abandoned")
    func testSessionAbandon() {
        // Arrange
        var session = TrainingSession(
            user: createTestUser(),
            module: createTestModule(),
            startTime: Date().addingTimeInterval(-600)
        )

        // Act
        session.abandon()

        // Assert
        #expect(session.status == .abandoned, "Session should be marked as abandoned")
        #expect(session.endTime != nil, "End time should be set when abandoned")
        #expect(session.overallScore == nil, "Score should remain nil when abandoned")
    }

    // MARK: - Session Status Tests

    @Test("Session status colors are correct", arguments: [
        (SessionStatus.scheduled, "blue"),
        (SessionStatus.inProgress, "orange"),
        (SessionStatus.paused, "yellow"),
        (SessionStatus.completed, "green"),
        (SessionStatus.failed, "red"),
        (SessionStatus.abandoned, "gray")
    ])
    func testSessionStatusColors(status: SessionStatus, expectedColor: String) {
        #expect(status.color == expectedColor)
    }

    // MARK: - Scenario Result Tests

    @Test("Scenario result initializes correctly")
    func testScenarioResultInitialization() {
        // Arrange
        let scenario = createTestScenario()
        let timeCompleted: TimeInterval = 450 // 7.5 minutes
        let score = 92.5

        // Act
        let result = ScenarioResult(
            scenario: scenario,
            timeCompleted: timeCompleted,
            score: score
        )

        // Assert
        #expect(result.scenario.name == scenario.name)
        #expect(result.timeCompleted == timeCompleted)
        #expect(result.score == score)
        #expect(result.isPassed == true, "Score of 92.5% should pass (>= 70%)")
        #expect(result.timestamp != Date(timeIntervalSince1970: 0), "Timestamp should be set")
    }

    @Test("Scenario result passing threshold", arguments: [
        (70.0, true),
        (69.9, false),
        (100.0, true),
        (0.0, false),
        (85.0, true)
    ])
    func testScenarioResultPassingThreshold(score: Double, shouldPass: Bool) {
        // Arrange
        let scenario = createTestScenario()
        let result = ScenarioResult(
            scenario: scenario,
            timeCompleted: 300,
            score: score
        )

        // Assert
        #expect(result.isPassed == shouldPass)
    }

    // MARK: - Performance Metrics Tests

    @Test("Hazard detection accuracy calculates correctly")
    func testHazardDetectionAccuracy() {
        // Arrange
        let scenario = createTestScenario()
        let result = ScenarioResult(scenario: scenario, timeCompleted: 300, score: 80)

        let hazard1 = Hazard(type: .electrical, severity: .high, name: "H1", description: "D1", location: SIMD3<Float>(0, 0, 0))
        let hazard2 = Hazard(type: .chemical, severity: .medium, name: "H2", description: "D2", location: SIMD3<Float>(1, 0, 0))
        let hazard3 = Hazard(type: .fire, severity: .critical, name: "H3", description: "D3", location: SIMD3<Float>(2, 0, 0))

        result.detectedHazards = [hazard1, hazard2] // 2 detected
        result.missedHazards = [hazard3]            // 1 missed

        // Act
        let accuracy = result.hazardDetectionAccuracy

        // Assert
        #expect(accuracy == 66.66666666666667, "2 out of 3 hazards = 66.67%")
    }

    @Test("Hazard detection accuracy with no hazards")
    func testHazardDetectionAccuracyNoHazards() {
        // Arrange
        let scenario = createTestScenario()
        let result = ScenarioResult(scenario: scenario, timeCompleted: 300, score: 100)

        // Act
        let accuracy = result.hazardDetectionAccuracy

        // Assert
        #expect(accuracy == 0, "No hazards should return 0% accuracy")
    }

    @Test("Procedure compliance rate calculates correctly")
    func testProcedureComplianceRate() {
        // Arrange
        let scenario = createTestScenario()
        let result = ScenarioResult(scenario: scenario, timeCompleted: 300, score: 85)

        result.proceduresFollowed = ["Step 1", "Step 2", "Step 3", "Step 4"] // 4 followed
        result.proceduresViolated = ["Step 5"]                               // 1 violated

        // Act
        let compliance = result.procedureComplianceRate

        // Assert
        #expect(compliance == 80.0, "4 out of 5 procedures = 80%")
    }

    @Test("Procedure compliance rate with no procedures")
    func testProcedureComplianceRateNoProcedures() {
        // Arrange
        let scenario = createTestScenario()
        let result = ScenarioResult(scenario: scenario, timeCompleted: 300, score: 90)

        // Act
        let compliance = result.procedureComplianceRate

        // Assert
        #expect(compliance == 0, "No procedures should return 0% compliance")
    }

    // MARK: - Edge Cases

    @Test("Session with zero duration")
    func testZeroDurationSession() {
        // Arrange
        let now = Date()
        var session = TrainingSession(
            user: createTestUser(),
            module: createTestModule(),
            startTime: now
        )
        session.endTime = now

        // Act
        let duration = session.duration

        // Assert
        #expect(duration == 0, "Session ending immediately should have 0 duration")
    }

    @Test("Session with very long duration")
    func testLongDurationSession() {
        // Arrange
        let startTime = Date().addingTimeInterval(-86400) // 24 hours ago
        let session = TrainingSession(
            user: createTestUser(),
            module: createTestModule(),
            startTime: startTime
        )

        // Act
        let duration = session.duration

        // Assert
        #expect(duration >= 86400, "Duration should be at least 24 hours")
    }

    @Test("Multiple scenario results in session")
    func testMultipleScenarioResults() {
        // Arrange
        var session = TrainingSession(
            user: createTestUser(),
            module: createTestModule(),
            startTime: Date()
        )

        let scenario1 = createTestScenario()
        let scenario2 = createTestScenario()
        let scenario3 = createTestScenario()

        let result1 = ScenarioResult(scenario: scenario1, timeCompleted: 300, score: 80)
        let result2 = ScenarioResult(scenario: scenario2, timeCompleted: 450, score: 90)
        let result3 = ScenarioResult(scenario: scenario3, timeCompleted: 600, score: 75)

        // Act
        session.scenarioResults = [result1, result2, result3]

        // Assert
        #expect(session.scenarioResults.count == 3)
        #expect(session.scenarioResults.allSatisfy { $0.isPassed }, "All results should be passing")
    }

    @Test("AI coaching notes can be added")
    func testAICoachingNotes() {
        // Arrange
        var session = TrainingSession(
            user: createTestUser(),
            module: createTestModule(),
            startTime: Date()
        )

        let notes = [
            "Good hazard recognition",
            "Slow on emergency response",
            "Excellent PPE compliance"
        ]

        // Act
        session.aiCoachingNotes = notes

        // Assert
        #expect(session.aiCoachingNotes.count == 3)
        #expect(session.aiCoachingNotes.contains("Good hazard recognition"))
    }
}

@Suite("User Decision Tests")
struct UserDecisionTests {

    @Test("User decision codable encoding and decoding")
    func testUserDecisionCodable() throws {
        // Arrange
        let decision = UserDecision(
            timestamp: 45.5,
            decision: "Identified electrical hazard",
            wasCorrect: true,
            feedback: "Great job! You correctly identified the exposed wire."
        )

        // Act - Encode
        let encoder = JSONEncoder()
        let data = try encoder.encode(decision)

        // Act - Decode
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(UserDecision.self, from: data)

        // Assert
        #expect(decoded.timestamp == decision.timestamp)
        #expect(decoded.decision == decision.decision)
        #expect(decoded.wasCorrect == decision.wasCorrect)
        #expect(decoded.feedback == decision.feedback)
    }

    @Test("User decision without feedback")
    func testUserDecisionWithoutFeedback() {
        // Arrange
        let decision = UserDecision(
            timestamp: 120.0,
            decision: "Started evacuation",
            wasCorrect: true,
            feedback: nil
        )

        // Assert
        #expect(decision.feedback == nil)
        #expect(decision.wasCorrect == true)
    }
}
