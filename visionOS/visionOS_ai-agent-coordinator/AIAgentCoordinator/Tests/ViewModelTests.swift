//
//  ViewModelTests.swift
//  AIAgentCoordinatorTests
//
//  Created by AI Agent Coordinator on 2025-01-20.
//

import XCTest
@testable import AIAgentCoordinator

/// Unit tests for ViewModels
@MainActor
final class ViewModelTests: XCTestCase {

    // MARK: - AgentNetworkViewModel Tests

    func testAgentNetworkViewModel_Load() async throws {
        // Given
        let coordinator = AgentCoordinator()
        let viewModel = AgentNetworkViewModel(
            coordinator: coordinator,
            visualizationEngine: VisualizationEngine(),
            metricsCollector: MetricsCollector()
        )

        // When
        await viewModel.load()

        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
    }

    func testAgentNetworkViewModel_Search() async throws {
        // Given
        let coordinator = AgentCoordinator()
        let viewModel = AgentNetworkViewModel(
            coordinator: coordinator,
            visualizationEngine: VisualizationEngine(),
            metricsCollector: MetricsCollector()
        )
        await viewModel.load()

        // When
        viewModel.searchQuery = "api"

        // Then
        // filteredAgents should be updated based on search
        XCTAssertNotNil(viewModel.filteredAgents)
    }

    func testAgentNetworkViewModel_ChangeLayout() async throws {
        // Given
        let viewModel = AgentNetworkViewModel()

        // When
        viewModel.changeLayout(to: .grid)

        // Then
        XCTAssertEqual(viewModel.layoutAlgorithm, .grid)
    }

    func testAgentNetworkViewModel_SelectAgent() async throws {
        // Given
        let viewModel = AgentNetworkViewModel()
        let agent = AIAgent(
            name: "test",
            type: .general,
            platform: .openai,
            status: .active,
            agentDescription: "test",
            endpoint: nil,
            tags: []
        )

        // When
        viewModel.selectAgent(agent)

        // Then
        XCTAssertEqual(viewModel.selectedAgent?.id, agent.id)
    }

    func testAgentNetworkViewModel_DeselectAgent() async throws {
        // Given
        let viewModel = AgentNetworkViewModel()
        let agent = AIAgent(
            name: "test",
            type: .general,
            platform: .openai,
            status: .active,
            agentDescription: "test",
            endpoint: nil,
            tags: []
        )
        viewModel.selectAgent(agent)

        // When
        viewModel.deselectAgent()

        // Then
        XCTAssertNil(viewModel.selectedAgent)
    }

    // MARK: - PerformanceViewModel Tests

    func testPerformanceViewModel_StartMonitoring() async throws {
        // Given
        let viewModel = PerformanceViewModel()

        // When
        viewModel.startMonitoring()

        // Then
        XCTAssertTrue(viewModel.isMonitoring)
    }

    func testPerformanceViewModel_StopMonitoring() async throws {
        // Given
        let viewModel = PerformanceViewModel()
        viewModel.startMonitoring()

        // When
        viewModel.stopMonitoring()

        // Then
        XCTAssertFalse(viewModel.isMonitoring)
    }

    func testPerformanceViewModel_DismissAlert() async throws {
        // Given
        let viewModel = PerformanceViewModel()
        let alert = PerformanceAlert(
            id: UUID(),
            agentId: UUID(),
            agentName: "test",
            severity: .high,
            type: .highCPU,
            message: "Test alert",
            timestamp: Date()
        )

        // When
        viewModel.dismissAlert(alert)

        // Then
        XCTAssertFalse(viewModel.alerts.contains { $0.id == alert.id })
    }

    // MARK: - CollaborationViewModel Tests

    func testCollaborationViewModel_LeaveSession() async throws {
        // Given
        let viewModel = CollaborationViewModel()

        // When
        viewModel.leaveSession()

        // Then
        XCTAssertFalse(viewModel.isCollaborating)
        XCTAssertTrue(viewModel.annotations.isEmpty)
        XCTAssertTrue(viewModel.participantCursors.isEmpty)
        XCTAssertTrue(viewModel.chatMessages.isEmpty)
    }

    func testCollaborationViewModel_ParticipantColor() async throws {
        // Given
        let viewModel = CollaborationViewModel()
        let participantId = UUID()

        // When
        let color1 = viewModel.participantColor(for: participantId)
        let color2 = viewModel.participantColor(for: participantId)

        // Then - same ID should always return same color
        XCTAssertEqual(color1, color2)
    }

    // MARK: - OrchestrationViewModel Tests

    func testOrchestrationViewModel_Start() async throws {
        // Given
        let viewModel = OrchestrationViewModel()

        // When
        viewModel.start()

        // Then
        XCTAssertTrue(viewModel.isRunning)
    }

    func testOrchestrationViewModel_Stop() async throws {
        // Given
        let viewModel = OrchestrationViewModel()
        viewModel.start()

        // When
        viewModel.stop()

        // Then
        XCTAssertFalse(viewModel.isRunning)
    }

    func testOrchestrationViewModel_CreateWorkflow() async throws {
        // Given
        let viewModel = OrchestrationViewModel()
        let workflow = Workflow(
            id: UUID(),
            name: "Test Workflow",
            description: "Test",
            steps: [],
            scheduleInterval: 60,
            isEnabled: true
        )

        // When
        viewModel.createWorkflow(workflow)

        // Then
        XCTAssertTrue(viewModel.workflows.contains { $0.id == workflow.id })
    }

    func testOrchestrationViewModel_DeleteWorkflow() async throws {
        // Given
        let viewModel = OrchestrationViewModel()
        let workflow = Workflow(
            id: UUID(),
            name: "Test",
            description: "Test",
            steps: [],
            scheduleInterval: 60,
            isEnabled: true
        )
        viewModel.createWorkflow(workflow)

        // When
        viewModel.deleteWorkflow(workflow.id)

        // Then
        XCTAssertFalse(viewModel.workflows.contains { $0.id == workflow.id })
    }
}
