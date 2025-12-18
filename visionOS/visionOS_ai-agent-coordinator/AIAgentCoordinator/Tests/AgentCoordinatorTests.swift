//
//  AgentCoordinatorTests.swift
//  AIAgentCoordinatorTests
//
//  Created by AI Agent Coordinator on 2025-01-20.
//

import XCTest
@testable import AIAgentCoordinator

/// Unit tests for AgentCoordinator service
final class AgentCoordinatorTests: XCTestCase {

    var sut: AgentCoordinator!
    var mockRepository: MockAgentRepository!
    var mockMetricsCollector: MetricsCollector!
    var mockEventBus: EventBus!

    override func setUp() async throws {
        try await super.setUp()

        mockRepository = MockAgentRepository()
        mockMetricsCollector = MetricsCollector()
        mockEventBus = EventBus()

        sut = AgentCoordinator(
            repository: mockRepository,
            metricsCollector: mockMetricsCollector,
            eventBus: mockEventBus
        )
    }

    override func tearDown() async throws {
        sut = nil
        mockRepository = nil
        mockMetricsCollector = nil
        mockEventBus = nil

        try await super.tearDown()
    }

    // MARK: - Load Agents Tests

    func testLoadAgents_Success() async throws {
        // Given
        let testAgents = [
            AIAgent(name: "test-1", type: .general, platform: .openai, status: .active, agentDescription: "Test", endpoint: nil, tags: []),
            AIAgent(name: "test-2", type: .general, platform: .anthropic, status: .idle, agentDescription: "Test", endpoint: nil, tags: [])
        ]
        await mockRepository.setAgents(testAgents)

        // When
        try await sut.loadAgents()

        // Then
        XCTAssertEqual(sut.agents.count, 2)
        XCTAssertEqual(sut.agents.first?.name, "test-1")
    }

    func testLoadAgents_Empty() async throws {
        // Given
        await mockRepository.setAgents([])

        // When
        try await sut.loadAgents()

        // Then
        XCTAssertTrue(sut.agents.isEmpty)
    }

    // MARK: - Create Agent Tests

    func testCreateAgent_Success() async throws {
        // Given
        let newAgent = AIAgent(
            name: "new-agent",
            type: .general,
            platform: .custom,
            status: .idle,
            agentDescription: "New agent",
            endpoint: nil,
            tags: []
        )

        // When
        try await sut.createAgent(newAgent)

        // Then
        XCTAssertTrue(sut.agents.contains { $0.id == newAgent.id })
    }

    // MARK: - Start/Stop Agent Tests

    func testStartAgent_Success() async throws {
        // Given
        let agent = AIAgent(
            name: "test-agent",
            type: .general,
            platform: .openai,
            status: .idle,
            agentDescription: "Test",
            endpoint: nil,
            tags: []
        )
        try await sut.createAgent(agent)

        // When
        try await sut.startAgent(agent)

        // Then
        let updatedAgent = sut.agents.first { $0.id == agent.id }
        XCTAssertEqual(updatedAgent?.status, .active)
        XCTAssertNotNil(updatedAgent?.lastActiveDate)
    }

    func testStopAgent_Success() async throws {
        // Given
        var agent = AIAgent(
            name: "test-agent",
            type: .general,
            platform: .openai,
            status: .active,
            agentDescription: "Test",
            endpoint: nil,
            tags: []
        )
        agent.lastActiveDate = Date()
        try await sut.createAgent(agent)

        // When
        try await sut.stopAgent(agent)

        // Then
        let updatedAgent = sut.agents.first { $0.id == agent.id }
        XCTAssertEqual(updatedAgent?.status, .idle)
    }

    // MARK: - Search Tests

    func testSearchAgents_ByName() async throws {
        // Given
        let agents = [
            AIAgent(name: "api-gateway", type: .general, platform: .openai, status: .active, agentDescription: "Test", endpoint: nil, tags: []),
            AIAgent(name: "ml-trainer", type: .general, platform: .anthropic, status: .idle, agentDescription: "Test", endpoint: nil, tags: [])
        ]
        await mockRepository.setAgents(agents)
        try await sut.loadAgents()

        // When
        let results = sut.searchAgents(query: "api")

        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "api-gateway")
    }

    func testSearchAgents_EmptyQuery() async throws {
        // Given
        let agents = [
            AIAgent(name: "agent-1", type: .general, platform: .openai, status: .active, agentDescription: "Test", endpoint: nil, tags: []),
            AIAgent(name: "agent-2", type: .general, platform: .anthropic, status: .idle, agentDescription: "Test", endpoint: nil, tags: [])
        ]
        await mockRepository.setAgents(agents)
        try await sut.loadAgents()

        // When
        let results = sut.searchAgents(query: "")

        // Then
        XCTAssertEqual(results.count, 2)
    }

    // MARK: - Filter Tests

    func testFilterAgents_ByStatus() async throws {
        // Given
        let agents = [
            AIAgent(name: "active-1", type: .general, platform: .openai, status: .active, agentDescription: "Test", endpoint: nil, tags: []),
            AIAgent(name: "idle-1", type: .general, platform: .anthropic, status: .idle, agentDescription: "Test", endpoint: nil, tags: []),
            AIAgent(name: "active-2", type: .general, platform: .aws, status: .active, agentDescription: "Test", endpoint: nil, tags: [])
        ]
        await mockRepository.setAgents(agents)
        try await sut.loadAgents()

        // When
        let results = sut.filterAgents(by: .active)

        // Then
        XCTAssertEqual(results.count, 2)
        XCTAssertTrue(results.allSatisfy { $0.status == .active })
    }

    // MARK: - Statistics Tests

    func testGetStatistics() async throws {
        // Given
        let agents = [
            AIAgent(name: "active-1", type: .general, platform: .openai, status: .active, agentDescription: "Test", endpoint: nil, tags: []),
            AIAgent(name: "idle-1", type: .general, platform: .anthropic, status: .idle, agentDescription: "Test", endpoint: nil, tags: []),
            AIAgent(name: "error-1", type: .general, platform: .aws, status: .error, agentDescription: "Test", endpoint: nil, tags: []),
            AIAgent(name: "learning-1", type: .general, platform: .azure, status: .learning, agentDescription: "Test", endpoint: nil, tags: [])
        ]
        await mockRepository.setAgents(agents)
        try await sut.loadAgents()

        // When
        let stats = sut.getStatistics()

        // Then
        XCTAssertEqual(stats.total, 4)
        XCTAssertEqual(stats.active, 1)
        XCTAssertEqual(stats.idle, 1)
        XCTAssertEqual(stats.error, 1)
        XCTAssertEqual(stats.learning, 1)
    }
}

// MARK: - Mock Repository

actor MockAgentRepository: AgentRepository {
    private var agents: [UUID: AIAgent] = [:]

    func setAgents(_ agents: [AIAgent]) {
        self.agents = Dictionary(uniqueKeysWithValues: agents.map { ($0.id, $0) })
    }

    func fetchAll() async throws -> [AIAgent] {
        Array(agents.values).sorted { $0.name < $1.name }
    }

    func fetch(by id: UUID) async throws -> AIAgent? {
        agents[id]
    }

    func save(_ agent: AIAgent) async throws {
        agents[agent.id] = agent
    }

    func update(_ agent: AIAgent) async throws {
        agents[agent.id] = agent
    }

    func delete(_ agent: AIAgent) async throws {
        agents.removeValue(forKey: agent.id)
    }

    func search(query: String) async throws -> [AIAgent] {
        agents.values.filter { $0.name.contains(query) }.sorted { $0.name < $1.name }
    }

    func filter(by status: AgentStatus) async throws -> [AIAgent] {
        agents.values.filter { $0.status == status }.sorted { $0.name < $1.name }
    }
}
