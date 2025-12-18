//
//  AgentCoordinator.swift
//  AIAgentCoordinator
//
//  Created by AI Agent Coordinator on 2025-01-20.
//

import Foundation
import SwiftData
import Observation

// MARK: - Agent Coordinator Actor (Thread-Safe Operations)

/// Thread-safe actor for performing agent operations
/// Handles all async operations that need isolation
actor AgentCoordinatorActor {

    /// Repository for agent data access
    private let repository: AgentRepository

    /// Metrics collection service
    let metricsCollector: MetricsCollector

    /// Event bus for broadcasting state changes
    let eventBus: EventBus

    init(repository: AgentRepository, metricsCollector: MetricsCollector, eventBus: EventBus) {
        self.repository = repository
        self.metricsCollector = metricsCollector
        self.eventBus = eventBus
    }

    // MARK: - Repository Operations

    func fetchAllAgents() async throws -> [AIAgent] {
        try await repository.fetchAll()
    }

    func saveAgent(_ agent: AIAgent) async throws {
        try await repository.save(agent)
    }

    func updateAgent(_ agent: AIAgent) async throws {
        try await repository.update(agent)
    }

    func deleteAgent(_ agent: AIAgent) async throws {
        try await repository.delete(agent)
    }

    func searchAgents(query: String) async throws -> [AIAgent] {
        try await repository.search(query: query)
    }

    func filterAgents(by status: AgentStatus) async throws -> [AIAgent] {
        try await repository.filter(by: status)
    }
}

// MARK: - Agent Coordinator (Observable State)

/// Main orchestration service for managing AI agents
/// Coordinates agent lifecycle, monitoring, and state management
///
/// This class separates observable state (for UI) from thread-safe operations (via actor)
@Observable
@MainActor
final class AgentCoordinator {

    // MARK: - Properties

    /// Thread-safe actor for async operations
    private let actor: AgentCoordinatorActor

    /// Currently loaded agents
    private(set) var agents: [AIAgent] = []

    /// Active agents (running state)
    var activeAgents: [AIAgent] {
        agents.filter { $0.status == .active }
    }

    /// Error agents
    var errorAgents: [AIAgent] {
        agents.filter { $0.status == .error }
    }

    /// Selected agent for detail view
    private(set) var selectedAgent: AIAgent?

    /// Loading state
    private(set) var isLoading = false

    /// Error state
    private(set) var error: CoordinatorError?

    // MARK: - Initialization

    init(repository: AgentRepository, metricsCollector: MetricsCollector, eventBus: EventBus) {
        self.actor = AgentCoordinatorActor(
            repository: repository,
            metricsCollector: metricsCollector,
            eventBus: eventBus
        )
    }

    /// Convenience initializer for testing/development
    convenience init() {
        self.init(
            repository: InMemoryAgentRepository(),
            metricsCollector: MetricsCollector(),
            eventBus: EventBus()
        )
    }

    // MARK: - Agent Lifecycle Management

    /// Load all agents from repository with automatic retry on failure
    func loadAgents() async throws {
        isLoading = true
        error = nil

        do {
            // Use retry utility for resilient loading
            agents = try await RetryUtility.withNetworkRetry(maxAttempts: 3) { [actor] in
                try await actor.fetchAllAgents()
            }
            await actor.eventBus.publish(.agentsLoaded(count: agents.count))
            isLoading = false
        } catch let retryError as RetryExhaustedError {
            self.error = .loadFailed(retryError.lastError)
            isLoading = false
            throw retryError
        } catch {
            self.error = .loadFailed(error)
            isLoading = false
            throw error
        }
    }

    /// Create a new agent with retry support
    func createAgent(_ agent: AIAgent) async throws {
        try await RetryUtility.withRetry(
            configuration: .conservative,
            operation: { [actor] in
                try await actor.saveAgent(agent)
            }
        )
        agents.append(agent)
        await actor.eventBus.publish(.agentCreated(agent))
    }

    /// Update an existing agent with retry support
    func updateAgent(_ agent: AIAgent) async throws {
        try await RetryUtility.withRetry(
            configuration: .conservative,
            operation: { [actor] in
                try await actor.updateAgent(agent)
            }
        )

        if let index = agents.firstIndex(where: { $0.id == agent.id }) {
            agents[index] = agent
        }

        await actor.eventBus.publish(.agentUpdated(agent))
    }

    /// Delete an agent with retry support
    func deleteAgent(_ agent: AIAgent) async throws {
        try await RetryUtility.withRetry(
            configuration: .conservative,
            operation: { [actor] in
                try await actor.deleteAgent(agent)
            }
        )
        agents.removeAll { $0.id == agent.id }

        if selectedAgent?.id == agent.id {
            selectedAgent = nil
        }

        await actor.eventBus.publish(.agentDeleted(agent.id))
    }

    /// Start an agent
    func startAgent(_ agent: AIAgent) async throws {
        var updatedAgent = agent
        updatedAgent.status = .active
        updatedAgent.lastActiveAt = Date()

        try await updateAgent(updatedAgent)
        await actor.metricsCollector.startMonitoring(agentId: agent.id)
        await actor.eventBus.publish(.agentStarted(agent.id))
    }

    /// Stop an agent
    func stopAgent(_ agent: AIAgent) async throws {
        var updatedAgent = agent
        updatedAgent.status = .idle

        try await updateAgent(updatedAgent)
        await actor.metricsCollector.stopMonitoring(agentId: agent.id)
        await actor.eventBus.publish(.agentStopped(agent.id))
    }

    /// Restart an agent
    func restartAgent(_ agent: AIAgent) async throws {
        try await stopAgent(agent)
        try await Task.sleep(for: .seconds(0.5))
        try await startAgent(agent)
        await actor.eventBus.publish(.agentRestarted(agent.id))
    }

    // MARK: - Agent Selection

    /// Select an agent for detail view
    func selectAgent(_ agent: AIAgent) {
        selectedAgent = agent
        Task {
            await actor.eventBus.publish(.agentSelected(agent.id))
        }
    }

    /// Deselect current agent
    func deselectAgent() {
        selectedAgent = nil
    }

    // MARK: - Search and Filter

    /// Search agents by name, tags, or description
    func searchAgents(query: String) -> [AIAgent] {
        guard !query.isEmpty else { return agents }

        let lowercasedQuery = query.lowercased()
        return agents.filter { agent in
            agent.name.lowercased().contains(lowercasedQuery) ||
            agent.tags.contains { $0.lowercased().contains(lowercasedQuery) } ||
            agent.agentDescription.lowercased().contains(lowercasedQuery)
        }
    }

    /// Filter agents by status
    func filterAgents(by status: AgentStatus) -> [AIAgent] {
        agents.filter { $0.status == status }
    }

    /// Filter agents by type
    func filterAgents(by type: AgentType) -> [AIAgent] {
        agents.filter { $0.type == type }
    }

    /// Filter agents by platform
    func filterAgents(by platform: AIPlatform) -> [AIAgent] {
        agents.filter { $0.platform == platform }
    }

    // MARK: - Batch Operations

    /// Start multiple agents with controlled concurrency
    func startAgents(_ agents: [AIAgent]) async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            for agent in agents {
                group.addTask {
                    try await self.startAgent(agent)
                }
            }

            try await group.waitForAll()
        }
    }

    /// Stop multiple agents with controlled concurrency
    func stopAgents(_ agents: [AIAgent]) async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            for agent in agents {
                group.addTask {
                    try await self.stopAgent(agent)
                }
            }

            try await group.waitForAll()
        }
    }

    // MARK: - Real-time Updates

    /// Start monitoring for real-time updates
    func startRealTimeMonitoring() async {
        // Subscribe to metrics updates
        for await event in await actor.eventBus.events() {
            await handleEvent(event)
        }
    }

    /// Handle event bus events
    @MainActor
    private func handleEvent(_ event: CoordinatorEvent) {
        switch event {
        case .metricsUpdated(let agentId, let metrics):
            if let index = agents.firstIndex(where: { $0.id == agentId }) {
                agents[index].currentMetrics = metrics
            }
        case .agentStatusChanged(let agentId, let status):
            if let index = agents.firstIndex(where: { $0.id == agentId }) {
                agents[index].status = status
            }
        default:
            break
        }
    }

    // MARK: - Statistics

    /// Get agent statistics
    func getStatistics() -> AgentStatistics {
        AgentStatistics(
            total: agents.count,
            active: activeAgents.count,
            idle: agents.filter { $0.status == .idle }.count,
            error: errorAgents.count,
            learning: agents.filter { $0.status == .learning }.count,
            byType: Dictionary(grouping: agents, by: \.type)
                .mapValues { $0.count },
            byPlatform: Dictionary(grouping: agents, by: \.platform)
                .mapValues { $0.count }
        )
    }
}

// MARK: - Supporting Types

/// Agent statistics
struct AgentStatistics {
    let total: Int
    let active: Int
    let idle: Int
    let error: Int
    let learning: Int
    let byType: [AgentType: Int]
    let byPlatform: [AIPlatform: Int]
}

/// Coordinator errors
enum CoordinatorError: Error, LocalizedError {
    case loadFailed(Error)
    case saveFailed(Error)
    case agentNotFound(UUID)
    case invalidOperation(String)

    var errorDescription: String? {
        switch self {
        case .loadFailed(let error):
            return "Failed to load agents: \(error.localizedDescription)"
        case .saveFailed(let error):
            return "Failed to save agent: \(error.localizedDescription)"
        case .agentNotFound(let id):
            return "Agent not found: \(id)"
        case .invalidOperation(let message):
            return "Invalid operation: \(message)"
        }
    }
}

/// Coordinator events for event bus
enum CoordinatorEvent: Sendable {
    case agentsLoaded(count: Int)
    case agentCreated(AIAgent)
    case agentUpdated(AIAgent)
    case agentDeleted(UUID)
    case agentStarted(UUID)
    case agentStopped(UUID)
    case agentRestarted(UUID)
    case agentSelected(UUID)
    case metricsUpdated(UUID, AgentMetrics)
    case agentStatusChanged(UUID, AgentStatus)
}

/// Event bus for broadcasting events
actor EventBus {
    private var continuations: [UUID: AsyncStream<CoordinatorEvent>.Continuation] = [:]

    func publish(_ event: CoordinatorEvent) {
        for continuation in continuations.values {
            continuation.yield(event)
        }
    }

    func events() -> AsyncStream<CoordinatorEvent> {
        AsyncStream { continuation in
            let id = UUID()
            continuations[id] = continuation

            continuation.onTermination = { [weak self] _ in
                Task {
                    await self?.removeContinuation(id)
                }
            }
        }
    }

    private func removeContinuation(_ id: UUID) {
        continuations.removeValue(forKey: id)
    }
}
