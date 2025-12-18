//
//  AgentNetworkViewModel.swift
//  AIAgentCoordinator
//
//  Created by AI Agent Coordinator on 2025-01-20.
//

import Foundation
import Observation
import simd

/// ViewModel for the agent network visualization
/// Manages state for 3D galaxy view and agent interactions
@Observable
@MainActor
final class AgentNetworkViewModel {

    // MARK: - Properties

    /// Agent coordinator service
    private let coordinator: AgentCoordinator

    /// Visualization engine
    private let visualizationEngine: VisualizationEngine

    /// Metrics collector
    private let metricsCollector: MetricsCollector

    /// All agents to display
    private(set) var agents: [AIAgent] = []

    /// Agent positions in 3D space
    private(set) var agentPositions: [UUID: SIMD3<Float>] = [:]

    /// Selected agent
    private(set) var selectedAgent: AIAgent?

    /// Hovered agent (for highlight)
    private(set) var hoveredAgent: AIAgent?

    /// Current layout algorithm
    var layoutAlgorithm: VisualizationEngine.LayoutAlgorithm {
        get { visualizationEngine.layoutAlgorithm }
        set {
            visualizationEngine.layoutAlgorithm = newValue
            updateLayout()
        }
    }

    /// Show connections between agents
    var showConnections = true

    /// Show agent labels
    var showLabels = true

    /// Enable LOD system
    var enableLOD: Bool {
        get { visualizationEngine.lodSettings.enableLOD }
        set { visualizationEngine.lodSettings.enableLOD = newValue }
    }

    /// Loading state
    private(set) var isLoading = false

    /// Error state
    private(set) var error: Error?

    /// Search query
    var searchQuery = "" {
        didSet {
            applyFilters()
        }
    }

    /// Filter by status
    var statusFilter: AgentStatus? {
        didSet {
            applyFilters()
        }
    }

    /// Filter by platform
    var platformFilter: AIPlatform? {
        didSet {
            applyFilters()
        }
    }

    /// Filtered agents
    private(set) var filteredAgents: [AIAgent] = []

    // MARK: - Initialization

    init(
        coordinator: AgentCoordinator,
        visualizationEngine: VisualizationEngine,
        metricsCollector: MetricsCollector
    ) {
        self.coordinator = coordinator
        self.visualizationEngine = visualizationEngine
        self.metricsCollector = metricsCollector
    }

    /// Convenience initializer
    convenience init() {
        let coordinator = AgentCoordinator()
        self.init(
            coordinator: coordinator,
            visualizationEngine: VisualizationEngine(),
            metricsCollector: MetricsCollector()
        )
    }

    // MARK: - Lifecycle

    /// Load agents and initialize visualization
    func load() async {
        isLoading = true
        error = nil

        do {
            try await coordinator.loadAgents()
            agents = coordinator.agents
            filteredAgents = agents

            updateLayout()
            startMetricsMonitoring()

            isLoading = false
        } catch {
            self.error = error
            isLoading = false
        }
    }

    /// Refresh data
    func refresh() async {
        await load()
    }

    // MARK: - Layout Management

    /// Update agent positions based on current layout
    private func updateLayout() {
        let positions = visualizationEngine.calculatePositions(for: filteredAgents)
        agentPositions = positions
    }

    /// Change layout algorithm
    func changeLayout(to algorithm: VisualizationEngine.LayoutAlgorithm) {
        layoutAlgorithm = algorithm
    }

    // MARK: - Agent Selection

    /// Select an agent
    func selectAgent(_ agent: AIAgent) {
        selectedAgent = agent
        coordinator.selectAgent(agent)
    }

    /// Deselect current agent
    func deselectAgent() {
        selectedAgent = nil
        coordinator.deselectAgent()
    }

    /// Set hovered agent (for highlighting)
    func setHoveredAgent(_ agent: AIAgent?) {
        hoveredAgent = agent
    }

    // MARK: - Filtering

    /// Apply current filters
    private func applyFilters() {
        var filtered = agents

        // Search filter
        if !searchQuery.isEmpty {
            filtered = coordinator.searchAgents(query: searchQuery)
        }

        // Status filter
        if let status = statusFilter {
            filtered = filtered.filter { $0.status == status }
        }

        // Platform filter
        if let platform = platformFilter {
            filtered = filtered.filter { $0.platform == platform }
        }

        filteredAgents = filtered
        updateLayout()
    }

    /// Clear all filters
    func clearFilters() {
        searchQuery = ""
        statusFilter = nil
        platformFilter = nil
    }

    // MARK: - Agent Operations

    /// Start an agent
    func startAgent(_ agent: AIAgent) async throws {
        try await coordinator.startAgent(agent)
        await refresh()
    }

    /// Stop an agent
    func stopAgent(_ agent: AIAgent) async throws {
        try await coordinator.stopAgent(agent)
        await refresh()
    }

    /// Restart an agent
    func restartAgent(_ agent: AIAgent) async throws {
        try await coordinator.restartAgent(agent)
        await refresh()
    }

    // MARK: - Metrics Monitoring

    /// Start monitoring metrics for all agents
    private func startMetricsMonitoring() {
        Task {
            for agent in agents {
                await metricsCollector.startMonitoring(agentId: agent.id)
            }
        }
    }

    /// Get latest metrics for an agent
    func getMetrics(for agent: AIAgent) async -> AgentMetrics? {
        await metricsCollector.getLatestMetrics(for: agent.id)
    }

    // MARK: - Visual Helpers

    /// Get color for agent
    func color(for agent: AIAgent) -> SIMD3<Float> {
        visualizationEngine.colorForStatus(agent.status)
    }

    /// Get size for agent based on metrics
    func size(for agent: AIAgent) -> Float {
        // Base size
        var size: Float = 0.1

        // Scale based on request rate if available
        if let metrics = agent.currentMetrics {
            size += Float(metrics.requestsPerSecond) / 1000.0
        }

        return min(size, 0.5) // Cap at 0.5m
    }

    /// Calculate LOD for agent based on camera distance
    func lodLevel(for agent: AIAgent, cameraPosition: SIMD3<Float>) -> LODLevel {
        guard let position = agentPositions[agent.id] else {
            return .minimal
        }

        let distance = simd_distance(position, cameraPosition)
        return visualizationEngine.calculateLOD(distance: distance)
    }

    // MARK: - Statistics

    /// Get network statistics
    func getStatistics() -> NetworkStatistics {
        let stats = coordinator.getStatistics()

        return NetworkStatistics(
            totalAgents: stats.total,
            activeAgents: stats.active,
            idleAgents: stats.idle,
            errorAgents: stats.error,
            learningAgents: stats.learning,
            connectionCount: calculateConnectionCount(),
            averageHealthScore: calculateAverageHealth()
        )
    }

    private func calculateConnectionCount() -> Int {
        // Sum all connections from all agents
        agents.reduce(0) { $0 + $1.connections.count }
    }

    private func calculateAverageHealth() -> Double {
        guard !agents.isEmpty else { return 0 }
        let total = agents.compactMap { $0.currentMetrics?.healthScore }.reduce(0, +)
        let count = agents.compactMap { $0.currentMetrics }.count
        return count > 0 ? total / Double(count) : 0
    }
}

// MARK: - Supporting Types

/// Network visualization statistics
struct NetworkStatistics {
    let totalAgents: Int
    let activeAgents: Int
    let idleAgents: Int
    let errorAgents: Int
    let learningAgents: Int
    let connectionCount: Int
    let averageHealthScore: Double
}
