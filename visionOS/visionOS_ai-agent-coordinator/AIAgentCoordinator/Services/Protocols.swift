//
//  Protocols.swift
//  AIAgentCoordinator
//
//  Protocol definitions for service abstraction and testability
//  Created by AI Agent Coordinator on 2025-01-20.
//

import Foundation
import simd

// MARK: - Visualization Engine Protocol

/// Protocol for visualization engine operations
/// Enables mocking for unit tests and supports alternative implementations
protocol VisualizationEngineProtocol: AnyObject {
    /// Current layout algorithm
    var layoutAlgorithm: VisualizationEngine.LayoutAlgorithm { get set }

    /// Level of detail settings
    var lodSettings: LODSettings { get set }

    /// Maximum agents to render
    var maxAgents: Int { get set }

    /// Calculate positions for agents based on current layout
    func calculatePositions(for agents: [AIAgent]) -> [UUID: SIMD3<Float>]

    /// Calculate level of detail for an agent based on distance
    func calculateLOD(distance: Float) -> LODLevel

    /// Get visual representation parameters for LOD level
    func visualParameters(for lod: LODLevel) -> VisualParameters

    /// Get color for agent based on status
    func colorForStatus(_ status: AgentStatus) -> SIMD3<Float>

    /// Get color for platform
    func colorForPlatform(_ platform: AIPlatform) -> SIMD3<Float>
}

// Default implementation conformance
extension VisualizationEngine: VisualizationEngineProtocol {}

// MARK: - Collaboration Manager Protocol

/// Protocol for collaboration manager operations
/// Enables mocking for unit tests and supports alternative implementations
protocol CollaborationManagerProtocol: AnyObject {
    /// Current participants in the session
    var participants: [Participant] { get }

    /// Whether currently in a collaboration session
    var isCollaborating: Bool { get }

    /// Local participant reference
    var localParticipant: Participant? { get }

    /// Start a new collaboration session
    func startSession() async throws

    /// Leave the current session
    func leaveSession()

    /// Send agent selection to all participants
    func broadcastAgentSelection(_ agentId: UUID) async throws

    /// Send view change to all participants
    func broadcastViewChange(_ viewState: ViewState) async throws

    /// Send spatial annotation
    func broadcastAnnotation(_ annotation: SpatialAnnotation) async throws

    /// Send cursor position for presence
    func broadcastCursorPosition(_ position: SIMD3<Float>) async throws

    /// Stream collaboration events
    func events() -> AsyncStream<CollaborationEvent>

    /// Add a spatial annotation
    func addAnnotation(text: String, position: SIMD3<Float>, agentId: UUID?) async throws

    /// Remove a spatial annotation
    func removeAnnotation(_ id: UUID) async throws
}

// Default implementation conformance
extension CollaborationManager: CollaborationManagerProtocol {}

// MARK: - Metrics Collector Protocol

/// Protocol for metrics collection operations
/// Enables mocking for unit tests and supports alternative implementations
protocol MetricsCollectorProtocol: Actor {
    /// Start monitoring an agent
    func startMonitoring(agentId: UUID)

    /// Stop monitoring an agent
    func stopMonitoring(agentId: UUID)

    /// Stop all monitoring
    func stopAllMonitoring()

    /// Get latest metrics for an agent
    func getLatestMetrics(for agentId: UUID) -> AgentMetrics?

    /// Get metrics history for an agent within a time duration
    func getMetricsHistory(for agentId: UUID, last duration: TimeInterval) -> [TimestampedMetrics]

    /// Get all cached metrics
    func getAllMetrics() -> [UUID: AgentMetrics]

    /// Get aggregate metrics across all agents
    func getAggregateMetrics() -> AggregateMetrics

    /// Clear history for an agent
    func clearHistory(for agentId: UUID)

    /// Clear all history
    func clearAllHistory()

    /// Stream metrics updates
    func metricsStream() -> AsyncStream<MetricsUpdate>
}

// Default implementation conformance
extension MetricsCollector: MetricsCollectorProtocol {}

// MARK: - Agent Coordinator Protocol

/// Protocol for agent coordinator operations
/// Enables mocking for unit tests
@MainActor
protocol AgentCoordinatorProtocol: AnyObject {
    /// Currently loaded agents
    var agents: [AIAgent] { get }

    /// Active agents
    var activeAgents: [AIAgent] { get }

    /// Error agents
    var errorAgents: [AIAgent] { get }

    /// Selected agent for detail view
    var selectedAgent: AIAgent? { get }

    /// Loading state
    var isLoading: Bool { get }

    /// Load all agents from repository
    func loadAgents() async throws

    /// Create a new agent
    func createAgent(_ agent: AIAgent) async throws

    /// Update an existing agent
    func updateAgent(_ agent: AIAgent) async throws

    /// Delete an agent
    func deleteAgent(_ agent: AIAgent) async throws

    /// Start an agent
    func startAgent(_ agent: AIAgent) async throws

    /// Stop an agent
    func stopAgent(_ agent: AIAgent) async throws

    /// Restart an agent
    func restartAgent(_ agent: AIAgent) async throws

    /// Select an agent for detail view
    func selectAgent(_ agent: AIAgent)

    /// Deselect current agent
    func deselectAgent()

    /// Search agents by query
    func searchAgents(query: String) -> [AIAgent]

    /// Filter agents by status
    func filterAgents(by status: AgentStatus) -> [AIAgent]

    /// Filter agents by type
    func filterAgents(by type: AgentType) -> [AIAgent]

    /// Filter agents by platform
    func filterAgents(by platform: AIPlatform) -> [AIAgent]

    /// Get agent statistics
    func getStatistics() -> AgentStatistics
}

// Default implementation conformance
extension AgentCoordinator: AgentCoordinatorProtocol {}

// MARK: - Mock Implementations for Testing

/// Mock visualization engine for testing
final class MockVisualizationEngine: VisualizationEngineProtocol {
    var layoutAlgorithm: VisualizationEngine.LayoutAlgorithm = .galaxy
    var lodSettings = LODSettings()
    var maxAgents = 50_000

    var calculatePositionsCallCount = 0
    var calculatePositionsResult: [UUID: SIMD3<Float>] = [:]

    func calculatePositions(for agents: [AIAgent]) -> [UUID: SIMD3<Float>] {
        calculatePositionsCallCount += 1
        return calculatePositionsResult
    }

    func calculateLOD(distance: Float) -> LODLevel {
        switch distance {
        case 0..<2: return .high
        case 2..<10: return .medium
        case 10..<50: return .low
        default: return .minimal
        }
    }

    func visualParameters(for lod: LODLevel) -> VisualParameters {
        VisualParameters(
            sphereSegments: 8,
            showLabels: false,
            showMetrics: false,
            showConnections: false,
            particleCount: 0
        )
    }

    func colorForStatus(_ status: AgentStatus) -> SIMD3<Float> {
        SIMD3(0.5, 0.5, 0.5)
    }

    func colorForPlatform(_ platform: AIPlatform) -> SIMD3<Float> {
        SIMD3(0.5, 0.5, 0.5)
    }
}

/// Mock collaboration manager for testing
final class MockCollaborationManager: CollaborationManagerProtocol {
    var participants: [Participant] = []
    var isCollaborating: Bool = false
    var localParticipant: Participant?

    var startSessionCallCount = 0
    var leaveSessionCallCount = 0
    var broadcastAgentSelectionCallCount = 0
    var lastBroadcastedAgentId: UUID?

    func startSession() async throws {
        startSessionCallCount += 1
        isCollaborating = true
    }

    func leaveSession() {
        leaveSessionCallCount += 1
        isCollaborating = false
    }

    func broadcastAgentSelection(_ agentId: UUID) async throws {
        broadcastAgentSelectionCallCount += 1
        lastBroadcastedAgentId = agentId
    }

    func broadcastViewChange(_ viewState: ViewState) async throws {}
    func broadcastAnnotation(_ annotation: SpatialAnnotation) async throws {}
    func broadcastCursorPosition(_ position: SIMD3<Float>) async throws {}

    func events() -> AsyncStream<CollaborationEvent> {
        AsyncStream { _ in }
    }

    func addAnnotation(text: String, position: SIMD3<Float>, agentId: UUID?) async throws {}
    func removeAnnotation(_ id: UUID) async throws {}
}

/// Mock metrics collector for testing
actor MockMetricsCollector: MetricsCollectorProtocol {
    var startMonitoringCallCount = 0
    var stopMonitoringCallCount = 0
    var metricsToReturn: [UUID: AgentMetrics] = [:]

    func startMonitoring(agentId: UUID) {
        startMonitoringCallCount += 1
    }

    func stopMonitoring(agentId: UUID) {
        stopMonitoringCallCount += 1
    }

    func stopAllMonitoring() {
        stopMonitoringCallCount += 1
    }

    func getLatestMetrics(for agentId: UUID) -> AgentMetrics? {
        metricsToReturn[agentId]
    }

    func getMetricsHistory(for agentId: UUID, last duration: TimeInterval) -> [TimestampedMetrics] {
        []
    }

    func getAllMetrics() -> [UUID: AgentMetrics] {
        metricsToReturn
    }

    func getAggregateMetrics() -> AggregateMetrics {
        .zero
    }

    func clearHistory(for agentId: UUID) {}
    func clearAllHistory() {}

    func metricsStream() -> AsyncStream<MetricsUpdate> {
        AsyncStream { _ in }
    }
}
