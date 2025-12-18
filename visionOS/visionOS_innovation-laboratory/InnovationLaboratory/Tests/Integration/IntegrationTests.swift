import XCTest
import SwiftData
@testable import InnovationLaboratory

// MARK: - Integration Tests
// Tests the integration between different components and services

final class IntegrationTests: XCTestCase {

    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    var innovationService: InnovationService!
    var prototypeService: PrototypeService!
    var collaborationService: CollaborationService!

    override func setUp() async throws {
        try await super.setUp()

        let schema = Schema([
            InnovationIdea.self,
            Prototype.self,
            User.self,
            Team.self,
            IdeaAnalytics.self,
            Comment.self,
            Attachment.self
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
        innovationService = InnovationService(modelContext: modelContext)
        prototypeService = PrototypeService(modelContext: modelContext)
        collaborationService = CollaborationService()
    }

    override func tearDown() async throws {
        modelContext = nil
        modelContainer = nil
        innovationService = nil
        prototypeService = nil
        collaborationService = nil
        try await super.tearDown()
    }

    // MARK: - End-to-End Workflow Tests

    func testCompleteInnovationWorkflow() async throws {
        // 1. Create an idea
        let idea = InnovationIdea(
            title: "Smart Packaging",
            description: "Biodegradable packaging with sensors",
            category: .product,
            priority: 8
        )
        let createdIdea = try await innovationService.createIdea(idea)

        XCTAssertNotNil(createdIdea.id)
        XCTAssertNotNil(createdIdea.analytics)

        // 2. Create a prototype for the idea
        let prototype = try await prototypeService.createPrototype(
            for: createdIdea,
            name: "Smart Package v1"
        )

        XCTAssertEqual(prototype.idea?.id, createdIdea.id)
        XCTAssertEqual(prototype.status, .draft)

        // 3. Run simulation on prototype
        let simulation = try await prototypeService.runSimulation(on: prototype)

        XCTAssertGreaterThan(simulation.successScore, 0.0)
        XCTAssertFalse(prototype.testResults.isEmpty)

        // 4. Get optimization suggestions
        let suggestions = try await prototypeService.optimizePrototype(prototype)

        XCTAssertFalse(suggestions.isEmpty)

        // 5. Update prototype based on suggestions
        prototype.status = .inProgress
        try await prototypeService.updatePrototype(prototype)

        XCTAssertEqual(prototype.status, .inProgress)
        XCTAssertGreaterThan(prototype.iterations, 1)

        // 6. Update idea status
        createdIdea.status = .prototyping
        try await innovationService.updateIdea(createdIdea)

        XCTAssertEqual(createdIdea.status, .prototyping)

        // 7. Verify analytics tracking
        let metrics = await AnalyticsService.shared.getMetrics()
        XCTAssertGreaterThan(metrics.totalIdeas, 0)
        XCTAssertGreaterThan(metrics.totalPrototypes, 0)
    }

    func testMultiUserCollaborationWorkflow() async throws {
        // 1. Create users
        let user1 = User(
            name: "Alice Johnson",
            email: "alice@company.com",
            role: .innovator,
            department: "R&D"
        )
        let user2 = User(
            name: "Bob Smith",
            email: "bob@company.com",
            role: .facilitator,
            department: "Innovation"
        )

        modelContext.insert(user1)
        modelContext.insert(user2)
        try modelContext.save()

        // 2. Create team
        let team = Team(
            name: "Innovation Squad",
            description: "Cross-functional innovation team"
        )
        team.members.append(user1)
        team.members.append(user2)

        modelContext.insert(team)
        try modelContext.save()

        // 3. Start collaboration session
        let session = try await collaborationService.startSession(teamID: team.id)

        XCTAssertEqual(session.teamID, team.id)
        XCTAssertTrue(session.isActive)

        // 4. Add users to session
        try await collaborationService.inviteUser(user1.id, to: session.id)
        try await collaborationService.inviteUser(user2.id, to: session.id)

        let activeSession = collaborationService.activeSessions[session.id]
        XCTAssertEqual(activeSession?.participants.count, 2)

        // 5. Create idea in collaboration
        let collaborativeIdea = InnovationIdea(
            title: "Collaborative Innovation",
            description: "Created during team session",
            category: .technology
        )
        collaborativeIdea.creator = user1
        collaborativeIdea.team = team

        _ = try await innovationService.createIdea(collaborativeIdea)

        XCTAssertEqual(collaborativeIdea.creator?.id, user1.id)
        XCTAssertEqual(collaborativeIdea.team?.id, team.id)

        // 6. End collaboration
        try await collaborationService.endSession(session.id)

        XCTAssertNil(collaborationService.activeSessions[session.id])
    }

    func testIdeaPipelineProgression() async throws {
        // Test idea moving through all status stages

        // 1. Create idea (Concept)
        let idea = InnovationIdea(
            title: "Pipeline Test Idea",
            description: "Testing status progression",
            category: .service
        )
        let createdIdea = try await innovationService.createIdea(idea)

        XCTAssertEqual(createdIdea.status, .concept)

        // 2. Move to Prototyping
        let prototype = try await prototypeService.createPrototype(
            for: createdIdea,
            name: "Test Prototype"
        )
        createdIdea.status = .prototyping
        try await innovationService.updateIdea(createdIdea)

        XCTAssertEqual(createdIdea.status, .prototyping)
        XCTAssertEqual(createdIdea.prototypes.count, 1)

        // 3. Run tests (Testing)
        let simulation = try await prototypeService.runSimulation(on: prototype)
        createdIdea.status = .testing
        try await innovationService.updateIdea(createdIdea)

        XCTAssertEqual(createdIdea.status, .testing)
        XCTAssertGreaterThan(simulation.successScore, 0.0)

        // 4. Validate (if successful)
        if simulation.successScore > 0.7 {
            prototype.status = .validated
            createdIdea.status = .validated
            try await prototypeService.updatePrototype(prototype)
            try await innovationService.updateIdea(createdIdea)

            XCTAssertEqual(createdIdea.status, .validated)
            XCTAssertEqual(prototype.status, .validated)
        }

        // 5. Development phase
        createdIdea.status = .inDevelopment
        try await innovationService.updateIdea(createdIdea)

        XCTAssertEqual(createdIdea.status, .inDevelopment)

        // 6. Launch
        createdIdea.status = .launched
        try await innovationService.updateIdea(createdIdea)

        XCTAssertEqual(createdIdea.status, .launched)
    }

    // MARK: - Data Persistence Integration Tests

    func testDataPersistenceAcrossContexts() async throws {
        // Create idea in one context
        let idea = InnovationIdea(
            title: "Persistence Test",
            description: "Testing data persistence",
            category: .product
        )
        let createdIdea = try await innovationService.createIdea(idea)
        let ideaID = createdIdea.id

        // Create new context (simulating app restart)
        let newContext = ModelContext(modelContainer)
        let newService = InnovationService(modelContext: newContext)

        // Fetch idea from new context
        let fetchedIdea = try await newService.fetchIdea(id: ideaID)

        XCTAssertNotNil(fetchedIdea)
        XCTAssertEqual(fetchedIdea?.title, "Persistence Test")
        XCTAssertEqual(fetchedIdea?.category, .product)
    }

    func testRelationshipPersistence() async throws {
        // Create user, team, and idea with relationships
        let user = User(
            name: "Test User",
            email: "test@example.com",
            role: .innovator
        )
        modelContext.insert(user)

        let team = Team(name: "Test Team")
        team.members.append(user)
        modelContext.insert(team)

        let idea = InnovationIdea(
            title: "Relationship Test",
            description: "Testing relationships",
            category: .product
        )
        idea.creator = user
        idea.team = team
        user.ideas.append(idea)
        team.projects.append(idea)

        modelContext.insert(idea)
        try modelContext.save()

        // Verify relationships
        XCTAssertEqual(idea.creator?.id, user.id)
        XCTAssertEqual(idea.team?.id, team.id)
        XCTAssertTrue(user.ideas.contains { $0.id == idea.id })
        XCTAssertTrue(team.projects.contains { $0.id == idea.id })
    }

    // MARK: - Analytics Integration Tests

    func testAnalyticsAcrossServices() async throws {
        // Track events from multiple services

        // 1. Innovation service events
        let idea = InnovationIdea(
            title: "Analytics Test",
            description: "Testing analytics",
            category: .technology
        )
        _ = try await innovationService.createIdea(idea)

        // 2. Prototype service events
        let prototype = try await prototypeService.createPrototype(
            for: idea,
            name: "Test Prototype"
        )

        // 3. Simulation events
        _ = try await prototypeService.runSimulation(on: prototype)

        // 4. Collaboration events
        let session = try await collaborationService.startSession(teamID: UUID())
        try await collaborationService.endSession(session.id)

        // Verify all events tracked
        let metrics = await AnalyticsService.shared.getMetrics()
        XCTAssertGreaterThan(metrics.totalIdeas, 0)
        XCTAssertGreaterThan(metrics.totalPrototypes, 0)
        XCTAssertGreaterThanOrEqual(metrics.activeCollaborations, 0)
    }

    // MARK: - Error Recovery Tests

    func testRollbackOnError() async throws {
        // Create idea
        let idea = InnovationIdea(
            title: "Rollback Test",
            description: "Testing error rollback",
            category: .product
        )
        _ = try await innovationService.createIdea(idea)

        // Count ideas before error
        let ideasBefore = try await innovationService.fetchIdeas(filter: nil)
        let countBefore = ideasBefore.count

        // Attempt invalid operation (should fail)
        do {
            try await innovationService.deleteIdea(UUID()) // Non-existent ID
            XCTFail("Should have thrown error")
        } catch {
            // Error expected
        }

        // Verify no data corruption
        let ideasAfter = try await innovationService.fetchIdeas(filter: nil)
        XCTAssertEqual(ideasAfter.count, countBefore)
    }

    // MARK: - Concurrent Operations Tests

    func testConcurrentIdeaCreation() async throws {
        // Create multiple ideas concurrently
        await withTaskGroup(of: Result<InnovationIdea, Error>.self) { group in
            for i in 1...10 {
                group.addTask {
                    do {
                        let idea = InnovationIdea(
                            title: "Concurrent Idea \(i)",
                            description: "Testing concurrency",
                            category: .product
                        )
                        let created = try await self.innovationService.createIdea(idea)
                        return .success(created)
                    } catch {
                        return .failure(error)
                    }
                }
            }

            var successCount = 0
            for await result in group {
                if case .success = result {
                    successCount += 1
                }
            }

            XCTAssertEqual(successCount, 10, "All concurrent operations should succeed")
        }

        // Verify all ideas created
        let ideas = try await innovationService.fetchIdeas(filter: nil)
        XCTAssertGreaterThanOrEqual(ideas.count, 10)
    }

    func testConcurrentPrototypeSimulations() async throws {
        // Create idea
        let idea = InnovationIdea(
            title: "Concurrent Sim Test",
            description: "Testing concurrent simulations",
            category: .product
        )
        _ = try await innovationService.createIdea(idea)

        // Create prototypes
        var prototypes: [Prototype] = []
        for i in 1...5 {
            let prototype = try await prototypeService.createPrototype(
                for: idea,
                name: "Prototype \(i)"
            )
            prototypes.append(prototype)
        }

        // Run simulations concurrently
        await withTaskGroup(of: Result<SimulationData, Error>.self) { group in
            for prototype in prototypes {
                group.addTask {
                    do {
                        let simulation = try await self.prototypeService.runSimulation(on: prototype)
                        return .success(simulation)
                    } catch {
                        return .failure(error)
                    }
                }
            }

            var successCount = 0
            for await result in group {
                if case .success = result {
                    successCount += 1
                }
            }

            XCTAssertEqual(successCount, 5, "All simulations should complete")
        }
    }

    // MARK: - Search and Filter Integration Tests

    func testComplexFiltering() async throws {
        // Create diverse ideas
        let ideas = [
            InnovationIdea(title: "AI Product", description: "AI-powered product", category: .product, priority: 8),
            InnovationIdea(title: "AI Service", description: "AI service offering", category: .service, priority: 7),
            InnovationIdea(title: "Green Product", description: "Sustainable product", category: .product, priority: 9),
            InnovationIdea(title: "Process Improvement", description: "Better process", category: .process, priority: 6)
        ]

        for idea in ideas {
            _ = try await innovationService.createIdea(idea)
        }

        // Test category filter
        let productFilter = IdeaFilter(category: .product)
        let productIdeas = try await innovationService.fetchIdeas(filter: productFilter)
        XCTAssertEqual(productIdeas.count, 2)
        XCTAssertTrue(productIdeas.allSatisfy { $0.category == .product })

        // Test priority filter
        let highPriorityFilter = IdeaFilter(minPriority: 8)
        let highPriorityIdeas = try await innovationService.fetchIdeas(filter: highPriorityFilter)
        XCTAssertGreaterThanOrEqual(highPriorityIdeas.count, 2)
        XCTAssertTrue(highPriorityIdeas.allSatisfy { $0.priority >= 8 })

        // Test search
        let aiIdeas = try await innovationService.searchIdeas(query: "AI")
        XCTAssertEqual(aiIdeas.count, 2)
        XCTAssertTrue(aiIdeas.allSatisfy { $0.title.contains("AI") || $0.ideaDescription.contains("AI") })
    }
}

// MARK: - Performance Integration Tests
extension IntegrationTests {

    func testEndToEndPerformance() async throws {
        measure {
            let expectation = self.expectation(description: "End-to-end workflow")

            Task {
                do {
                    // Complete workflow
                    let idea = InnovationIdea(
                        title: "Performance Test",
                        description: "Testing performance",
                        category: .product
                    )
                    let created = try await self.innovationService.createIdea(idea)
                    let prototype = try await self.prototypeService.createPrototype(
                        for: created,
                        name: "Perf Prototype"
                    )
                    _ = try await self.prototypeService.runSimulation(on: prototype)

                    expectation.fulfill()
                } catch {
                    XCTFail("Performance test failed: \(error)")
                }
            }

            wait(for: [expectation], timeout: 5.0)
        }
    }
}
