import XCTest
import SwiftData
@testable import InnovationLaboratory

// MARK: - Services Unit Tests
final class ServicesTests: XCTestCase {

    var modelContainer: ModelContainer!
    var modelContext: ModelContext!

    override func setUp() async throws {
        try await super.setUp()

        // Create in-memory model container for testing
        let schema = Schema([
            InnovationIdea.self,
            Prototype.self,
            User.self,
            Team.self,
            IdeaAnalytics.self
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )

        modelContainer = try ModelContainer(
            for: schema,
            configurations: configuration
        )

        modelContext = ModelContext(modelContainer)
    }

    override func tearDown() async throws {
        modelContext = nil
        modelContainer = nil
        try await super.tearDown()
    }

    // MARK: - Innovation Service Tests

    func testCreateIdea() async throws {
        // Given
        let service = InnovationService(modelContext: modelContext)
        let idea = InnovationIdea(
            title: "Test Idea",
            description: "Test Description",
            category: .product
        )

        // When
        let createdIdea = try await service.createIdea(idea)

        // Then
        XCTAssertNotNil(createdIdea.id)
        XCTAssertEqual(createdIdea.title, "Test Idea")
        XCTAssertNotNil(createdIdea.analytics)
    }

    func testUpdateIdea() async throws {
        // Given
        let service = InnovationService(modelContext: modelContext)
        let idea = InnovationIdea(
            title: "Original Title",
            description: "Description",
            category: .product
        )
        _ = try await service.createIdea(idea)

        // When
        let originalModifiedDate = idea.lastModified
        try await Task.sleep(for: .milliseconds(10))
        idea.title = "Updated Title"
        try await service.updateIdea(idea)

        // Then
        XCTAssertEqual(idea.title, "Updated Title")
        XCTAssertGreaterThan(idea.lastModified, originalModifiedDate)
    }

    func testFetchIdeas() async throws {
        // Given
        let service = InnovationService(modelContext: modelContext)

        // Create multiple ideas
        for i in 1...5 {
            let idea = InnovationIdea(
                title: "Idea \(i)",
                description: "Description \(i)",
                category: .product,
                priority: i
            )
            _ = try await service.createIdea(idea)
        }

        // When
        let ideas = try await service.fetchIdeas(filter: nil)

        // Then
        XCTAssertEqual(ideas.count, 5)
        XCTAssertEqual(ideas.first?.title, "Idea 5") // Most recent first
    }

    func testFetchIdeasWithFilter() async throws {
        // Given
        let service = InnovationService(modelContext: modelContext)

        // Create ideas with different categories
        let productIdea = InnovationIdea(
            title: "Product Idea",
            description: "Description",
            category: .product
        )
        let serviceIdea = InnovationIdea(
            title: "Service Idea",
            description: "Description",
            category: .service
        )

        _ = try await service.createIdea(productIdea)
        _ = try await service.createIdea(serviceIdea)

        // When
        let filter = IdeaFilter(category: .product)
        let filteredIdeas = try await service.fetchIdeas(filter: filter)

        // Then
        XCTAssertEqual(filteredIdeas.count, 1)
        XCTAssertEqual(filteredIdeas.first?.category, .product)
    }

    func testSearchIdeas() async throws {
        // Given
        let service = InnovationService(modelContext: modelContext)

        let idea1 = InnovationIdea(
            title: "AI Assistant",
            description: "Smart AI helper",
            category: .technology
        )
        let idea2 = InnovationIdea(
            title: "Package Design",
            description: "Sustainable packaging",
            category: .product
        )

        _ = try await service.createIdea(idea1)
        _ = try await service.createIdea(idea2)

        // When
        let results = try await service.searchIdeas(query: "AI")

        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertTrue(results.first?.title.contains("AI") ?? false)
    }

    func testDeleteIdea() async throws {
        // Given
        let service = InnovationService(modelContext: modelContext)
        let idea = InnovationIdea(
            title: "To Delete",
            description: "Description",
            category: .product
        )
        let created = try await service.createIdea(idea)

        // When
        try await service.deleteIdea(created.id)

        // Then
        let ideas = try await service.fetchIdeas(filter: nil)
        XCTAssertTrue(ideas.isEmpty)
    }

    // MARK: - Prototype Service Tests

    func testCreatePrototype() async throws {
        // Given
        let service = PrototypeService(modelContext: modelContext)
        let idea = InnovationIdea(
            title: "Test Idea",
            description: "Description",
            category: .product
        )
        modelContext.insert(idea)
        try modelContext.save()

        // When
        let prototype = try await service.createPrototype(
            for: idea,
            name: "Test Prototype"
        )

        // Then
        XCTAssertEqual(prototype.name, "Test Prototype")
        XCTAssertEqual(prototype.status, .draft)
        XCTAssertEqual(prototype.iterations, 1)
        XCTAssertNotNil(prototype.idea)
    }

    func testUpdatePrototype() async throws {
        // Given
        let service = PrototypeService(modelContext: modelContext)
        let idea = InnovationIdea(
            title: "Test Idea",
            description: "Description",
            category: .product
        )
        let prototype = try await service.createPrototype(
            for: idea,
            name: "Test Prototype"
        )
        let originalIterations = prototype.iterations

        // When
        try await service.updatePrototype(prototype)

        // Then
        XCTAssertEqual(prototype.iterations, originalIterations + 1)
    }

    func testRunSimulation() async throws {
        // Given
        let service = PrototypeService(modelContext: modelContext)
        let idea = InnovationIdea(
            title: "Test Idea",
            description: "Description",
            category: .product
        )
        let prototype = try await service.createPrototype(
            for: idea,
            name: "Test Prototype"
        )

        // When
        let simulation = try await service.runSimulation(on: prototype)

        // Then
        XCTAssertNotNil(simulation)
        XCTAssertEqual(simulation.simulationType, "Physics Test")
        XCTAssertFalse(simulation.parameters.isEmpty)
        XCTAssertFalse(simulation.results.isEmpty)
        XCTAssertGreaterThan(simulation.successScore, 0.0)
        XCTAssertLessThan(simulation.successScore, 1.0)
    }

    func testOptimizePrototype() async throws {
        // Given
        let service = PrototypeService(modelContext: modelContext)
        let idea = InnovationIdea(
            title: "Test Idea",
            description: "Description",
            category: .product
        )
        let prototype = try await service.createPrototype(
            for: idea,
            name: "Test Prototype"
        )

        // Run simulation first to get data
        _ = try await service.runSimulation(on: prototype)

        // When
        let suggestions = try await service.optimizePrototype(prototype)

        // Then
        XCTAssertFalse(suggestions.isEmpty)
        XCTAssertTrue(suggestions.first?.contains("material") ?? false ||
                     suggestions.first?.contains("design") ?? false ||
                     suggestions.first?.contains("performance") ?? false)
    }

    // MARK: - Analytics Service Tests

    func testTrackEvent() async {
        // Given
        let ideaID = UUID()

        // When
        await AnalyticsService.shared.trackEvent(.ideaCreated(ideaID: ideaID))

        // Then
        let metrics = await AnalyticsService.shared.getMetrics()
        XCTAssertEqual(metrics.totalIdeas, 1)
    }

    func testMultipleEvents() async {
        // Given
        let ideaID1 = UUID()
        let ideaID2 = UUID()
        let prototypeID = UUID()

        // When
        await AnalyticsService.shared.trackEvent(.ideaCreated(ideaID: ideaID1))
        await AnalyticsService.shared.trackEvent(.ideaCreated(ideaID: ideaID2))
        await AnalyticsService.shared.trackEvent(.prototypeCreated(prototypeID: prototypeID))

        // Then
        let metrics = await AnalyticsService.shared.getMetrics()
        XCTAssertEqual(metrics.totalIdeas, 2)
        XCTAssertEqual(metrics.totalPrototypes, 1)
    }

    func testCollaborationTracking() async {
        // Given
        let sessionID = UUID()

        // When
        await AnalyticsService.shared.trackEvent(.collaborationStarted(sessionID: sessionID))

        // Then
        let metrics = await AnalyticsService.shared.getMetrics()
        XCTAssertEqual(metrics.activeCollaborations, 1)

        // When - End collaboration
        await AnalyticsService.shared.trackEvent(.collaborationEnded(sessionID: sessionID))

        // Then
        let updatedMetrics = await AnalyticsService.shared.getMetrics()
        XCTAssertEqual(updatedMetrics.activeCollaborations, 0)
    }

    // MARK: - Collaboration Service Tests

    func testStartSession() async throws {
        // Given
        let service = CollaborationService()
        let teamID = UUID()

        // When
        let session = try await service.startSession(teamID: teamID)

        // Then
        XCTAssertEqual(session.teamID, teamID)
        XCTAssertTrue(session.isActive)
        XCTAssertNotNil(service.activeSessions[session.id])
    }

    func testEndSession() async throws {
        // Given
        let service = CollaborationService()
        let teamID = UUID()
        let session = try await service.startSession(teamID: teamID)

        // When
        try await service.endSession(session.id)

        // Then
        XCTAssertNil(service.activeSessions[session.id])
    }

    func testInviteUser() async throws {
        // Given
        let service = CollaborationService()
        let teamID = UUID()
        let session = try await service.startSession(teamID: teamID)
        let userID = UUID()

        // When
        try await service.inviteUser(userID, to: session.id)

        // Then
        let updatedSession = service.activeSessions[session.id]
        XCTAssertTrue(updatedSession?.participants.contains(userID) ?? false)
    }

    // MARK: - Error Handling Tests

    func testDeleteNonExistentIdea() async {
        // Given
        let service = InnovationService(modelContext: modelContext)
        let nonExistentID = UUID()

        // When/Then
        do {
            try await service.deleteIdea(nonExistentID)
            XCTFail("Should throw error for non-existent idea")
        } catch {
            XCTAssertTrue(error is ServiceError)
        }
    }

    func testEndNonExistentSession() async {
        // Given
        let service = CollaborationService()
        let nonExistentID = UUID()

        // When/Then
        do {
            try await service.endSession(nonExistentID)
            XCTFail("Should throw error for non-existent session")
        } catch {
            XCTAssertTrue(error is ServiceError)
        }
    }
}

// MARK: - Performance Tests
extension ServicesTests {

    func testIdeaCreationPerformance() async throws {
        // Given
        let service = InnovationService(modelContext: modelContext)

        // Measure
        measure {
            let expectation = self.expectation(description: "Create idea")

            Task {
                do {
                    let idea = InnovationIdea(
                        title: "Performance Test",
                        description: "Testing performance",
                        category: .product
                    )
                    _ = try await service.createIdea(idea)
                    expectation.fulfill()
                } catch {
                    XCTFail("Failed to create idea: \(error)")
                }
            }

            wait(for: [expectation], timeout: 1.0)
        }
    }

    func testBulkIdeaFetchPerformance() async throws {
        // Given
        let service = InnovationService(modelContext: modelContext)

        // Create 100 ideas
        for i in 1...100 {
            let idea = InnovationIdea(
                title: "Idea \(i)",
                description: "Description",
                category: .product
            )
            _ = try await service.createIdea(idea)
        }

        // Measure fetch performance
        measure {
            let expectation = self.expectation(description: "Fetch ideas")

            Task {
                do {
                    _ = try await service.fetchIdeas(filter: nil)
                    expectation.fulfill()
                } catch {
                    XCTFail("Failed to fetch ideas: \(error)")
                }
            }

            wait(for: [expectation], timeout: 2.0)
        }
    }
}
