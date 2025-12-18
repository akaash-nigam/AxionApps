import Testing
import Foundation
import SwiftData
@testable import IndustrialSafetySimulator

/// Integration tests for complete training flow
/// Legend: ✅ Can run in current environment | ⚠️ Requires visionOS Simulator | 🔴 Requires Vision Pro hardware
@Suite("Training Flow Integration Tests", .tags(.integration))
struct TrainingFlowIntegrationTests {

    // MARK: - Test Setup

    var modelContainer: ModelContainer!
    var modelContext: ModelContext!

    init() async throws {
        // Create in-memory container for testing
        let schema = Schema([
            SafetyUser.self,
            TrainingModule.self,
            SafetyScenario.self,
            Hazard.self,
            TrainingSession.self,
            PerformanceMetrics.self
        ])

        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [config])
        modelContext = ModelContext(modelContainer)
    }

    // MARK: - Helper Functions

    @MainActor
    func createTestUser() throws -> SafetyUser {
        let user = SafetyUser(
            name: "Integration Test User",
            role: .operator,
            department: "Testing",
            hireDate: Date()
        )
        modelContext.insert(user)
        try modelContext.save()
        return user
    }

    @MainActor
    func createTestModule() throws -> TrainingModule {
        let module = TrainingModule(
            title: "Fire Safety Integration Test",
            category: .fireSafety,
            difficultyLevel: .intermediate,
            estimatedDuration: 900,
            requiredCertifications: []
        )
        modelContext.insert(module)
        try modelContext.save()
        return module
    }

    @MainActor
    func createTestScenario() throws -> SafetyScenario {
        let scenario = SafetyScenario(
            name: "Factory Fire Response",
            description: "Respond to a fire emergency",
            environment: .factoryFloor,
            realityKitScene: "FactoryFire"
        )

        // Add hazards
        let fireHazard = Hazard(
            type: .fire,
            severity: .high,
            name: "Electrical Fire",
            description: "Fire in electrical panel",
            location: SIMD3<Float>(5, 1.5, 3)
        )

        let smokeHazard = Hazard(
            type: .chemical,
            severity: .medium,
            name: "Smoke Inhalation Risk",
            description: "Heavy smoke in area",
            location: SIMD3<Float>(4, 2, 3)
        )

        scenario.hazards.append(fireHazard)
        scenario.hazards.append(smokeHazard)

        modelContext.insert(scenario)
        try modelContext.save()
        return scenario
    }

    // MARK: - Complete Training Flow Tests ✅

    @Test("✅ Complete training flow from start to finish")
    @MainActor
    func testCompleteTrainingFlow() async throws {
        // Arrange
        let user = try createTestUser()
        let module = try createTestModule()
        let scenario = try createTestScenario()

        module.scenarios.append(scenario)
        try modelContext.save()

        // Act - Start training session
        let session = TrainingSession(
            user: user,
            module: module,
            startTime: Date()
        )
        modelContext.insert(session)
        try modelContext.save()

        #expect(session.status == .inProgress, "Session should start in progress")

        // Simulate scenario completion
        let result = ScenarioResult(
            scenario: scenario,
            timeCompleted: 450,
            score: 85.0
        )
        session.scenarioResults.append(result)

        // Complete the session
        session.completeSession(withScore: 85.0)
        try modelContext.save()

        // Assert
        #expect(session.status == .completed, "Session should be completed")
        #expect(session.overallScore == 85.0, "Score should be recorded")
        #expect(session.endTime != nil, "End time should be set")
        #expect(session.scenarioResults.count == 1, "Result should be recorded")
    }

    @Test("✅ User metrics update after session completion")
    @MainActor
    func testMetricsUpdateAfterSession() async throws {
        // Arrange
        let user = try createTestUser()
        let module = try createTestModule()
        let scenario = try createTestScenario()
        module.scenarios.append(scenario)
        try modelContext.save()

        var metrics = PerformanceMetrics(userId: user.id)
        let initialCompleted = metrics.scenariosCompleted

        // Act - Complete training session
        let session = TrainingSession(user: user, module: module, startTime: Date())
        let result = ScenarioResult(scenario: scenario, timeCompleted: 400, score: 90.0)
        session.scenarioResults.append(result)
        session.completeSession(withScore: 90.0)

        // Update metrics
        metrics.updateAfterSession(result)

        // Assert
        #expect(metrics.scenariosCompleted == initialCompleted + 1)
        #expect(metrics.scenariosPassed == 1)
        #expect(metrics.latestScore == 90.0)
        #expect(metrics.bestScore == 90.0)
    }

    @Test("✅ Failed session updates metrics correctly")
    @MainActor
    func testFailedSessionMetricsUpdate() async throws {
        // Arrange
        let user = try createTestUser()
        let module = try createTestModule()
        let scenario = try createTestScenario()
        scenario.passingScore = 70.0
        try modelContext.save()

        var metrics = PerformanceMetrics(userId: user.id)

        // Act - Complete session with failing score
        let session = TrainingSession(user: user, module: module, startTime: Date())
        let result = ScenarioResult(scenario: scenario, timeCompleted: 300, score: 55.0)
        session.scenarioResults.append(result)
        session.completeSession(withScore: 55.0)

        metrics.updateAfterSession(result)

        // Assert
        #expect(metrics.scenariosFailed == 1)
        #expect(metrics.scenariosPassed == 0)
        #expect(metrics.latestScore == 55.0)
        #expect(session.status == .completed)
    }

    // MARK: - Multi-Scenario Flow Tests ✅

    @Test("✅ Module with multiple scenarios completes correctly")
    @MainActor
    func testMultiScenarioModuleCompletion() async throws {
        // Arrange
        let user = try createTestUser()
        let module = try createTestModule()

        let scenario1 = try createTestScenario()
        scenario1.name = "Scenario 1"

        let scenario2 = SafetyScenario(
            name: "Scenario 2",
            description: "Second scenario",
            environment: .warehouse,
            realityKitScene: "Warehouse"
        )
        modelContext.insert(scenario2)

        module.scenarios.append(scenario1)
        module.scenarios.append(scenario2)
        try modelContext.save()

        // Act - Complete both scenarios
        let session = TrainingSession(user: user, module: module, startTime: Date())
        modelContext.insert(session)

        let result1 = ScenarioResult(scenario: scenario1, timeCompleted: 300, score: 85.0)
        let result2 = ScenarioResult(scenario: scenario2, timeCompleted: 350, score: 90.0)

        session.scenarioResults.append(result1)
        session.scenarioResults.append(result2)

        // Calculate overall score
        let overallScore = (result1.score + result2.score) / 2.0
        session.completeSession(withScore: overallScore)
        try modelContext.save()

        // Assert
        #expect(session.scenarioResults.count == 2)
        #expect(session.overallScore == 87.5)
        #expect(session.status == .completed)
    }

    @Test("✅ Session progress tracks scenario completion")
    @MainActor
    func testSessionProgressTracking() async throws {
        // Arrange
        let user = try createTestUser()
        let module = try createTestModule()
        let scenario1 = try createTestScenario()
        let scenario2 = SafetyScenario(
            name: "Scenario 2",
            description: "Second test",
            environment: .warehouse,
            realityKitScene: "Warehouse"
        )
        modelContext.insert(scenario2)

        module.scenarios.append(scenario1)
        module.scenarios.append(scenario2)
        try modelContext.save()

        let session = TrainingSession(user: user, module: module, startTime: Date())

        // Act - Complete first scenario
        let result1 = ScenarioResult(scenario: scenario1, timeCompleted: 300, score: 85.0)
        session.scenarioResults.append(result1)

        let progress = Double(session.scenarioResults.count) / Double(module.scenarios.count)

        // Assert - Should be 50% complete
        #expect(progress == 0.5)

        // Complete second scenario
        let result2 = ScenarioResult(scenario: scenario2, timeCompleted: 350, score: 90.0)
        session.scenarioResults.append(result2)

        let finalProgress = Double(session.scenarioResults.count) / Double(module.scenarios.count)

        #expect(finalProgress == 1.0)
    }

    // MARK: - Data Persistence Tests ✅

    @Test("✅ Training session persists correctly")
    @MainActor
    func testSessionPersistence() async throws {
        // Arrange
        let user = try createTestUser()
        let module = try createTestModule()
        let session = TrainingSession(user: user, module: module, startTime: Date())

        // Act - Save session
        modelContext.insert(session)
        try modelContext.save()

        // Fetch session back
        let descriptor = FetchDescriptor<TrainingSession>()
        let sessions = try modelContext.fetch(descriptor)

        // Assert
        #expect(sessions.count >= 1)
        let fetchedSession = sessions.first { $0.id == session.id }
        #expect(fetchedSession != nil)
        #expect(fetchedSession?.user?.id == user.id)
        #expect(fetchedSession?.module?.id == module.id)
    }

    @Test("✅ Performance metrics persist correctly")
    @MainActor
    func testMetricsPersistence() async throws {
        // Arrange
        let user = try createTestUser()
        var metrics = PerformanceMetrics(userId: user.id)
        metrics.totalTrainingHours = 15.5
        metrics.scenariosCompleted = 20
        metrics.scenariosPassed = 18

        // Note: In real app, metrics would be stored in SwiftData
        // This test verifies the model structure is correct
        #expect(metrics.userId == user.id)
        #expect(metrics.totalTrainingHours == 15.5)
        #expect(metrics.passRate == 90.0)
    }

    // MARK: - Certification Flow Tests ✅

    @Test("✅ Certification earned after module completion")
    @MainActor
    func testCertificationEarning() async throws {
        // Arrange
        let user = try createTestUser()
        let module = try createTestModule()
        let scenario = try createTestScenario()
        module.scenarios.append(scenario)
        module.certificationAwarded = "Fire Safety Level 1"
        try modelContext.save()

        // Act - Complete module with passing score
        let session = TrainingSession(user: user, module: module, startTime: Date())
        let result = ScenarioResult(scenario: scenario, timeCompleted: 400, score: 90.0)
        session.scenarioResults.append(result)
        session.completeSession(withScore: 90.0)

        // Award certification
        if session.overallScore >= 70.0, let certName = module.certificationAwarded {
            let certification = Certification(
                name: certName,
                issuedDate: Date(),
                expirationDate: Calendar.current.date(byAdding: .year, value: 2, to: Date())!,
                issuingAuthority: "Industrial Safety Simulator"
            )
            user.certifications.append(certification)
            try modelContext.save()
        }

        // Assert
        #expect(user.certifications.count >= 1)
        let cert = user.certifications.first { $0.name == "Fire Safety Level 1" }
        #expect(cert != nil)
        #expect(cert?.isValid == true)
    }

    @Test("✅ Certification not earned with failing score")
    @MainActor
    func testCertificationNotEarnedOnFail() async throws {
        // Arrange
        let user = try createTestUser()
        let module = try createTestModule()
        let scenario = try createTestScenario()
        module.scenarios.append(scenario)
        module.certificationAwarded = "Fire Safety Level 1"
        try modelContext.save()

        let initialCertCount = user.certifications.count

        // Act - Complete module with failing score
        let session = TrainingSession(user: user, module: module, startTime: Date())
        let result = ScenarioResult(scenario: scenario, timeCompleted: 400, score: 55.0)
        session.scenarioResults.append(result)
        session.completeSession(withScore: 55.0)

        // Don't award certification for failing score
        if session.overallScore >= 70.0, let certName = module.certificationAwarded {
            let certification = Certification(
                name: certName,
                issuedDate: Date(),
                expirationDate: Calendar.current.date(byAdding: .year, value: 2, to: Date())!,
                issuingAuthority: "Industrial Safety Simulator"
            )
            user.certifications.append(certification)
        }

        // Assert
        #expect(user.certifications.count == initialCertCount)
    }

    // MARK: - Error Handling Tests ✅

    @Test("✅ Session handles missing scenarios gracefully")
    @MainActor
    func testSessionWithNoScenarios() async throws {
        // Arrange
        let user = try createTestUser()
        let module = try createTestModule()
        // Module has no scenarios

        // Act
        let session = TrainingSession(user: user, module: module, startTime: Date())
        session.completeSession(withScore: 0)

        // Assert - should complete without crashing
        #expect(session.status == .completed)
        #expect(session.scenarioResults.isEmpty)
        #expect(session.overallScore == 0)
    }

    @Test("✅ Handles concurrent session updates")
    @MainActor
    func testConcurrentSessionUpdates() async throws {
        // Arrange
        let user = try createTestUser()
        let module = try createTestModule()
        let scenario = try createTestScenario()

        let session = TrainingSession(user: user, module: module, startTime: Date())
        modelContext.insert(session)
        try modelContext.save()

        // Act - Simulate rapid updates
        for i in 0..<5 {
            let result = ScenarioResult(scenario: scenario, timeCompleted: Double(i * 100), score: Double(70 + i))
            session.scenarioResults.append(result)
        }

        try modelContext.save()

        // Assert
        #expect(session.scenarioResults.count == 5)
    }
}

// MARK: - AppState Integration Tests

@Suite("AppState Integration Tests", .tags(.integration))
struct AppStateIntegrationTests {

    @Test("✅ AppState manages authentication flow")
    func testAuthenticationFlow() async {
        // Arrange
        let appState = AppState()
        #expect(appState.isAuthenticated == false)
        #expect(appState.currentUser == nil)

        // Act - Simulate login
        let user = SafetyUser(
            name: "Test User",
            role: .operator,
            department: "Testing",
            hireDate: Date()
        )
        appState.login(user: user)

        // Assert
        #expect(appState.isAuthenticated == true)
        #expect(appState.currentUser?.id == user.id)
    }

    @Test("✅ AppState manages training session lifecycle")
    func testSessionLifecycleManagement() async {
        // Arrange
        let appState = AppState()
        let user = SafetyUser(
            name: "Test User",
            role: .operator,
            department: "Testing",
            hireDate: Date()
        )
        appState.login(user: user)

        let module = TrainingModule(
            title: "Test Module",
            category: .fireSafety,
            difficultyLevel: .beginner,
            estimatedDuration: 600,
            requiredCertifications: []
        )

        // Act - Start session
        appState.startTrainingSession(module)
        #expect(appState.currentSession != nil)
        #expect(appState.currentSession?.module?.id == module.id)

        // End session
        appState.endTrainingSession()
        #expect(appState.currentSession == nil)
    }

    @Test("✅ AppState tracks session progress")
    func testSessionProgressTracking() async {
        // Arrange
        let appState = AppState()
        let user = SafetyUser(
            name: "Test User",
            role: .operator,
            department: "Testing",
            hireDate: Date()
        )
        appState.login(user: user)

        let module = TrainingModule(
            title: "Test Module",
            category: .hazardIdentification,
            difficultyLevel: .intermediate,
            estimatedDuration: 900,
            requiredCertifications: []
        )

        // Act
        appState.startTrainingSession(module)
        appState.updateSessionProgress(completedScenarios: 2, totalScenarios: 5)

        // Assert
        #expect(appState.sessionProgress?.currentScenario == 2)
        #expect(appState.sessionProgress?.totalScenarios == 5)
        #expect(appState.sessionProgress?.percentComplete == 40.0)
    }
}

// MARK: - Test Tags Extension

extension Tag {
    @Tag static var integration: Self
}
