import XCTest
@testable import InnovationLaboratory

// MARK: - Data Models Unit Tests
final class DataModelsTests: XCTestCase {

    // MARK: - InnovationIdea Tests

    func testInnovationIdeaInitialization() {
        // Given
        let title = "AI Assistant"
        let description = "Smart AI-powered assistant"
        let category = IdeaCategory.technology

        // When
        let idea = InnovationIdea(
            title: title,
            description: description,
            category: category
        )

        // Then
        XCTAssertEqual(idea.title, title)
        XCTAssertEqual(idea.ideaDescription, description)
        XCTAssertEqual(idea.category, category)
        XCTAssertEqual(idea.status, .concept)
        XCTAssertEqual(idea.priority, 5)
        XCTAssertNotNil(idea.id)
        XCTAssertNotNil(idea.createdDate)
    }

    func testIdeaCategoryEnum() {
        // Test all category cases
        XCTAssertEqual(IdeaCategory.product.rawValue, "Product")
        XCTAssertEqual(IdeaCategory.service.rawValue, "Service")
        XCTAssertEqual(IdeaCategory.process.rawValue, "Process")
        XCTAssertEqual(IdeaCategory.technology.rawValue, "Technology")
        XCTAssertEqual(IdeaCategory.businessModel.rawValue, "Business Model")

        // Test icons exist
        XCTAssertFalse(IdeaCategory.product.icon.isEmpty)
        XCTAssertFalse(IdeaCategory.service.icon.isEmpty)
        XCTAssertFalse(IdeaCategory.technology.icon.isEmpty)
    }

    func testIdeaStatusEnum() {
        // Test status progression
        let statuses: [IdeaStatus] = [
            .concept, .prototyping, .testing, .validated, .inDevelopment, .launched
        ]

        XCTAssertEqual(statuses.count, 6)

        // Test each status has icon
        for status in IdeaStatus.allCases {
            XCTAssertFalse(status.icon.isEmpty, "Status \(status.rawValue) should have an icon")
        }
    }

    func testIdeaPriorityRange() {
        // Given
        let idea = InnovationIdea(
            title: "Test",
            description: "Test",
            category: .product,
            priority: 3
        )

        // Then
        XCTAssertGreaterThanOrEqual(idea.priority, 1)
        XCTAssertLessThanOrEqual(idea.priority, 10)
    }

    func testIdeaImpactScore() {
        // Given
        let highPriorityIdea = InnovationIdea(
            title: "High Impact",
            description: "Description",
            category: .product,
            priority: 10,
            estimatedImpact: 0.9
        )

        // Then
        XCTAssertEqual(highPriorityIdea.estimatedImpact, 0.9, accuracy: 0.01)
        XCTAssertGreaterThanOrEqual(highPriorityIdea.estimatedImpact, 0.0)
        XCTAssertLessThanOrEqual(highPriorityIdea.estimatedImpact, 1.0)
    }

    // MARK: - Prototype Tests

    func testPrototypeInitialization() {
        // Given
        let name = "Smart Package v1"
        let version = "1.0"
        let description = "Biodegradable packaging"

        // When
        let prototype = Prototype(
            name: name,
            version: version,
            description: description,
            status: .draft
        )

        // Then
        XCTAssertEqual(prototype.name, name)
        XCTAssertEqual(prototype.version, version)
        XCTAssertEqual(prototype.prototypeDescription, description)
        XCTAssertEqual(prototype.status, .draft)
        XCTAssertEqual(prototype.iterations, 1)
    }

    func testPrototypeStatusEnum() {
        // Test all statuses exist
        let statuses: [PrototypeStatus] = [.draft, .inProgress, .testing, .validated, .failed]
        XCTAssertEqual(statuses.count, 5)

        // Validate each has icon
        for status in PrototypeStatus.allCases {
            XCTAssertFalse(status.icon.isEmpty)
        }
    }

    // MARK: - User Tests

    func testUserInitialization() {
        // Given
        let name = "Sarah Chen"
        let email = "sarah@company.com"
        let role = UserRole.innovator

        // When
        let user = User(
            name: name,
            email: email,
            role: role,
            department: "R&D"
        )

        // Then
        XCTAssertEqual(user.name, name)
        XCTAssertEqual(user.email, email)
        XCTAssertEqual(user.role, role)
        XCTAssertEqual(user.department, "R&D")
    }

    func testUserRoleEnum() {
        // Test all roles
        XCTAssertEqual(UserRole.innovator.rawValue, "Innovator")
        XCTAssertEqual(UserRole.facilitator.rawValue, "Facilitator")
        XCTAssertEqual(UserRole.executive.rawValue, "Executive")
        XCTAssertEqual(UserRole.contributor.rawValue, "Contributor")

        // Test descriptions exist
        for role in UserRole.allCases {
            XCTAssertFalse(role.description.isEmpty)
        }
    }

    // MARK: - Team Tests

    func testTeamInitialization() {
        // Given
        let teamName = "Innovation Squad"
        let description = "Cross-functional team"

        // When
        let team = Team(name: teamName, description: description)

        // Then
        XCTAssertEqual(team.name, teamName)
        XCTAssertEqual(team.teamDescription, description)
        XCTAssertTrue(team.members.isEmpty)
        XCTAssertTrue(team.projects.isEmpty)
    }

    // MARK: - Analytics Tests

    func testIdeaAnalyticsInitialization() {
        // Given
        let analytics = IdeaAnalytics(
            successProbability: 0.75,
            marketPotential: 0.85,
            technicalFeasibility: 0.90
        )

        // Then
        XCTAssertEqual(analytics.successProbability, 0.75, accuracy: 0.01)
        XCTAssertEqual(analytics.marketPotential, 0.85, accuracy: 0.01)
        XCTAssertEqual(analytics.technicalFeasibility, 0.90, accuracy: 0.01)
        XCTAssertEqual(analytics.viewCount, 0)
        XCTAssertEqual(analytics.iterationCount, 0)
    }

    func testAnalyticsScoreRange() {
        // Given
        let analytics = IdeaAnalytics()

        // Then - All scores should be between 0 and 1
        XCTAssertGreaterThanOrEqual(analytics.successProbability, 0.0)
        XCTAssertLessThanOrEqual(analytics.successProbability, 1.0)
        XCTAssertGreaterThanOrEqual(analytics.marketPotential, 0.0)
        XCTAssertLessThanOrEqual(analytics.marketPotential, 1.0)
    }

    // MARK: - Test Result Tests

    func testTestResultCodable() throws {
        // Given
        let testResult = TestResult(
            testName: "Physics Simulation",
            passed: true,
            score: 0.87,
            notes: "All tests passed"
        )

        // When - Encode
        let encoder = JSONEncoder()
        let data = try encoder.encode(testResult)

        // Then - Decode
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(TestResult.self, from: data)

        XCTAssertEqual(decoded.testName, testResult.testName)
        XCTAssertEqual(decoded.passed, testResult.passed)
        XCTAssertEqual(decoded.score, testResult.score, accuracy: 0.01)
        XCTAssertEqual(decoded.notes, testResult.notes)
    }

    // MARK: - Simulation Data Tests

    func testSimulationDataCodable() throws {
        // Given
        let simulationData = SimulationData(
            simulationType: "Physics Test",
            parameters: ["mass": 1.5, "friction": 0.3],
            results: ["durability": 0.85, "efficiency": 0.92],
            successScore: 0.88
        )

        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(simulationData)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(SimulationData.self, from: data)

        // Then
        XCTAssertEqual(decoded.simulationType, simulationData.simulationType)
        XCTAssertEqual(decoded.successScore, simulationData.successScore, accuracy: 0.01)
        XCTAssertEqual(decoded.parameters.count, 2)
        XCTAssertEqual(decoded.results.count, 2)
    }

    // MARK: - Filter Tests

    func testIdeaFilterEmpty() {
        // Given
        let filter = IdeaFilter()

        // Then
        XCTAssertTrue(filter.isEmpty)
        XCTAssertNil(filter.category)
        XCTAssertNil(filter.status)
        XCTAssertNil(filter.minPriority)
    }

    func testIdeaFilterWithValues() {
        // Given
        let filter = IdeaFilter(
            category: .product,
            status: .prototyping,
            minPriority: 7,
            searchQuery: "AI"
        )

        // Then
        XCTAssertFalse(filter.isEmpty)
        XCTAssertEqual(filter.category, .product)
        XCTAssertEqual(filter.status, .prototyping)
        XCTAssertEqual(filter.minPriority, 7)
        XCTAssertEqual(filter.searchQuery, "AI")
    }

    // MARK: - Collaboration Session Tests

    func testCollaborationSessionCodable() throws {
        // Given
        let teamID = UUID()
        var session = CollaborationSession(teamID: teamID)
        session.participants = [UUID(), UUID()]

        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(session)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(CollaborationSession.self, from: data)

        // Then
        XCTAssertEqual(decoded.teamID, session.teamID)
        XCTAssertEqual(decoded.participants.count, 2)
        XCTAssertTrue(decoded.isActive)
    }
}

// MARK: - Test Helpers
extension DataModelsTests {

    func createSampleIdea() -> InnovationIdea {
        return InnovationIdea(
            title: "Sample Idea",
            description: "This is a test idea",
            category: .product,
            priority: 5
        )
    }

    func createSamplePrototype() -> Prototype {
        return Prototype(
            name: "Sample Prototype",
            version: "1.0",
            description: "Test prototype",
            status: .draft
        )
    }

    func createSampleUser() -> User {
        return User(
            name: "Test User",
            email: "test@example.com",
            role: .innovator,
            department: "R&D"
        )
    }
}
