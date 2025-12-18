//
//  IntegrationTests.swift
//  AIAgentCoordinatorTests
//
//  Created by AI Agent Coordinator on 2025-01-20.
//

import XCTest
@testable import AIAgentCoordinator

/// Integration tests for complete workflows
final class IntegrationTests: XCTestCase {

    // MARK: - End-to-End Agent Lifecycle

    func testCompleteAgentLifecycle() async throws {
        // Given - Full system setup
        let coordinator = AgentCoordinator()
        let metricsCollector = MetricsCollector()

        // Create agent
        let agent = AIAgent(
            name: "integration-test-agent",
            type: .general,
            platform: .openai,
            status: .idle,
            agentDescription: "Integration test agent",
            endpoint: "https://api.example.com/test",
            tags: ["test", "integration"]
        )

        // When - Execute full lifecycle
        try await coordinator.createAgent(agent)
        try await coordinator.startAgent(agent)
        await metricsCollector.startMonitoring(agentId: agent.id)

        // Wait for metrics to collect
        try await Task.sleep(for: .milliseconds(200))

        // Get metrics
        let metrics = await metricsCollector.getLatestMetrics(for: agent.id)

        // Stop agent
        try await coordinator.stopAgent(agent)
        await metricsCollector.stopMonitoring(agentId: agent.id)

        // Delete agent
        try await coordinator.deleteAgent(agent)

        // Then - Verify lifecycle
        XCTAssertNotNil(metrics, "Metrics should be collected during lifecycle")
        XCTAssertFalse(coordinator.agents.contains { $0.id == agent.id }, "Agent should be deleted")
    }

    // MARK: - Metrics to Visualization Pipeline

    func testMetricsToVisualizationPipeline() async throws {
        // Given
        let coordinator = AgentCoordinator()
        let metricsCollector = MetricsCollector()
        let visualizationEngine = VisualizationEngine()

        // Create multiple agents
        let agents = (0..<5).map { i in
            AIAgent(
                name: "agent-\(i)",
                type: .general,
                platform: .openai,
                status: .active,
                agentDescription: "Agent \(i)",
                endpoint: nil,
                tags: []
            )
        }

        for agent in agents {
            try await coordinator.createAgent(agent)
            await metricsCollector.startMonitoring(agentId: agent.id)
        }

        try await Task.sleep(for: .milliseconds(200))

        // When - Generate visualization
        let positions = visualizationEngine.calculatePositions(for: agents)

        // Then
        XCTAssertEqual(positions.count, agents.count)

        // Verify each agent has valid metrics and position
        for agent in agents {
            let metrics = await metricsCollector.getLatestMetrics(for: agent.id)
            let position = positions[agent.id]

            XCTAssertNotNil(metrics, "Agent \(agent.name) should have metrics")
            XCTAssertNotNil(position, "Agent \(agent.name) should have position")
        }

        // Cleanup
        for agent in agents {
            await metricsCollector.stopMonitoring(agentId: agent.id)
        }
    }

    // MARK: - Search and Filter Integration

    func testSearchAndFilterIntegration() async throws {
        // Given
        let coordinator = AgentCoordinator()

        let agents = [
            AIAgent(name: "api-gateway-prod", type: .apiGateway, platform: .openai, status: .active, agentDescription: "", endpoint: nil, tags: ["production"]),
            AIAgent(name: "api-gateway-staging", type: .apiGateway, platform: .openai, status: .idle, agentDescription: "", endpoint: nil, tags: ["staging"]),
            AIAgent(name: "ml-trainer-gpu", type: .mlTraining, platform: .aws, status: .learning, agentDescription: "", endpoint: nil, tags: ["ml"]),
            AIAgent(name: "data-processor", type: .dataProcessing, platform: .azure, status: .active, agentDescription: "", endpoint: nil, tags: ["data"])
        ]

        for agent in agents {
            try await coordinator.createAgent(agent)
        }

        // When - Search for "api"
        let searchResults = coordinator.searchAgents(query: "api")

        // Then
        XCTAssertEqual(searchResults.count, 2)
        XCTAssertTrue(searchResults.allSatisfy { $0.name.contains("api") })

        // When - Filter by status
        let activeAgents = coordinator.filterAgents(by: .active)

        // Then
        XCTAssertEqual(activeAgents.count, 2)
        XCTAssertTrue(activeAgents.allSatisfy { $0.status == .active })

        // When - Filter by platform
        let awsAgents = coordinator.filterAgents(by: .aws)

        // Then
        XCTAssertEqual(awsAgents.count, 1)
        XCTAssertEqual(awsAgents.first?.name, "ml-trainer-gpu")
    }

    // MARK: - Batch Operations Integration

    func testBatchOperationsIntegration() async throws {
        // Given
        let coordinator = AgentCoordinator()

        let agents = (0..<5).map { i in
            AIAgent(
                name: "batch-agent-\(i)",
                type: .general,
                platform: .openai,
                status: .idle,
                agentDescription: "Batch test \(i)",
                endpoint: nil,
                tags: []
            )
        }

        for agent in agents {
            try await coordinator.createAgent(agent)
        }

        // When - Start all agents in batch
        try await coordinator.startAgents(agents)

        // Then
        let stats = coordinator.getStatistics()
        XCTAssertEqual(stats.active, agents.count)

        // When - Stop all agents in batch
        try await coordinator.stopAgents(agents)

        // Then
        let statsAfterStop = coordinator.getStatistics()
        XCTAssertEqual(statsAfterStop.idle, agents.count)
    }

    // MARK: - Performance Under Load

    func testPerformanceUnderLoad() async throws {
        // Given
        let coordinator = AgentCoordinator()
        let metricsCollector = MetricsCollector()
        let visualizationEngine = VisualizationEngine()

        // Create 100 agents
        let agentCount = 100
        let agents = (0..<agentCount).map { i in
            AIAgent(
                name: "load-test-\(i)",
                type: .general,
                platform: .openai,
                status: .active,
                agentDescription: "Load test \(i)",
                endpoint: nil,
                tags: []
            )
        }

        // When - Create all agents
        let startTime = Date()

        for agent in agents {
            try await coordinator.createAgent(agent)
            await metricsCollector.startMonitoring(agentId: agent.id)
        }

        let creationTime = Date().timeIntervalSince(startTime)

        // Generate visualization
        let vizStart = Date()
        let positions = visualizationEngine.calculatePositions(for: agents)
        let vizTime = Date().timeIntervalSince(vizStart)

        // Wait for metrics
        try await Task.sleep(for: .milliseconds(500))

        // Get aggregate metrics
        let metricsStart = Date()
        let aggregate = await metricsCollector.getAggregateMetrics()
        let metricsTime = Date().timeIntervalSince(metricsStart)

        // Then - Verify performance
        XCTAssertLessThan(creationTime, 5.0, "Creating 100 agents should take < 5s")
        XCTAssertLessThan(vizTime, 1.0, "Visualization should take < 1s")
        XCTAssertLessThan(metricsTime, 0.5, "Aggregate metrics should take < 0.5s")

        XCTAssertEqual(positions.count, agentCount)
        XCTAssertEqual(aggregate.activeAgents, agentCount)

        // Cleanup
        for agent in agents {
            await metricsCollector.stopMonitoring(agentId: agent.id)
        }
    }
}
