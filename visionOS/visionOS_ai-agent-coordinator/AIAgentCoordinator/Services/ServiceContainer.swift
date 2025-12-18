//
//  ServiceContainer.swift
//  AIAgentCoordinator
//
//  Dependency injection container for managing service instances
//  Created by AI Agent Coordinator on 2025-01-20.
//

import Foundation
import SwiftData
import SwiftUI

// MARK: - Service Container

/// Central dependency injection container for managing service instances
/// Provides singleton access to shared services and supports both production and testing configurations
@MainActor
final class ServiceContainer {

    // MARK: - Shared Instance

    /// Shared singleton instance for production use
    nonisolated(unsafe) static let shared = ServiceContainer()

    // MARK: - Configuration

    /// Configuration for the service container
    struct Configuration {
        let useInMemoryRepository: Bool
        let metricsUpdateFrequency: Int
        let maxMetricsHistory: Int

        static let production = Configuration(
            useInMemoryRepository: false,
            metricsUpdateFrequency: 100,
            maxMetricsHistory: 60_000
        )

        static let testing = Configuration(
            useInMemoryRepository: true,
            metricsUpdateFrequency: 10,
            maxMetricsHistory: 1_000
        )

        static let development = Configuration(
            useInMemoryRepository: true,
            metricsUpdateFrequency: 50,
            maxMetricsHistory: 10_000
        )
    }

    // MARK: - Properties

    private let configuration: Configuration
    nonisolated(unsafe) private var _modelContext: ModelContext?

    // MARK: - Lazy Service Instances

    /// Event bus for broadcasting coordinator events
    private(set) lazy var eventBus: EventBus = EventBus()

    /// Metrics collector for monitoring agent performance
    private(set) lazy var metricsCollector: MetricsCollector = MetricsCollector()

    /// Visualization engine for 3D layouts
    private(set) lazy var visualizationEngine: VisualizationEngine = VisualizationEngine()

    /// Collaboration manager for SharePlay integration
    private(set) lazy var collaborationManager: CollaborationManager = CollaborationManager()

    /// Agent repository for data access
    private(set) lazy var agentRepository: AgentRepository = {
        if configuration.useInMemoryRepository {
            return InMemoryAgentRepository()
        } else if let context = _modelContext {
            return SwiftDataAgentRepository(modelContext: context)
        } else {
            // Fallback to in-memory if no context is set
            return InMemoryAgentRepository()
        }
    }()

    /// Agent coordinator for orchestrating agent operations
    private(set) lazy var agentCoordinator: AgentCoordinator = {
        AgentCoordinator(
            repository: agentRepository,
            metricsCollector: metricsCollector,
            eventBus: eventBus
        )
    }()

    // MARK: - Initialization

    /// Initialize with default production configuration
    nonisolated private init() {
        self.configuration = .production
    }

    /// Initialize with custom configuration (for testing)
    nonisolated init(configuration: Configuration) {
        self.configuration = configuration
    }

    // MARK: - Configuration Methods

    /// Configure the container with a SwiftData model context
    /// Must be called before accessing SwiftData-dependent services
    func configure(with modelContext: ModelContext) {
        self._modelContext = modelContext
    }

    // MARK: - Factory Methods

    /// Create a new agent network view model
    func makeAgentNetworkViewModel() -> AgentNetworkViewModel {
        AgentNetworkViewModel(
            coordinator: agentCoordinator,
            visualizationEngine: visualizationEngine,
            metricsCollector: metricsCollector
        )
    }

    // MARK: - Testing Support

    /// Create a container configured for testing
    static func forTesting() -> ServiceContainer {
        ServiceContainer(configuration: .testing)
    }

    /// Create a container configured for development
    static func forDevelopment() -> ServiceContainer {
        ServiceContainer(configuration: .development)
    }

    /// Reset all services (useful for testing)
    func reset() async {
        await metricsCollector.stopAllMonitoring()
        await metricsCollector.clearAllHistory()
    }
}

// MARK: - Service Container Key

/// Environment key for accessing the service container
struct ServiceContainerKey: EnvironmentKey {
    nonisolated(unsafe) static let defaultValue: ServiceContainer = .shared
}

extension EnvironmentValues {
    var serviceContainer: ServiceContainer {
        get { self[ServiceContainerKey.self] }
        set { self[ServiceContainerKey.self] = newValue }
    }
}

// MARK: - Protocol for Injectable Services

/// Protocol for services that can be injected
protocol Injectable {
    init()
}

/// Protocol for services that require async initialization
protocol AsyncInitializable {
    func initialize() async throws
}
