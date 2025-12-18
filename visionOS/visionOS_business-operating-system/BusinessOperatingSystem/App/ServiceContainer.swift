//
//  ServiceContainer.swift
//  BusinessOperatingSystem
//
//  Created by BOS Team on 2025-01-20.
//

import Foundation
import Observation

/// Dependency injection container for all services
@Observable
final class ServiceContainer: @unchecked Sendable {
    // MARK: - Services

    let auth: any AuthenticationService
    let repository: any BusinessDataRepository
    let sync: any SyncService
    let ai: any AIService
    let collaboration: any CollaborationService
    let network: any NetworkService
    let analytics: any AnalyticsService

    // MARK: - Infrastructure

    let connectivity: ConnectivityMonitor

    // MARK: - Initialization

    init() {
        // Initialize connectivity monitor first (no dependencies)
        self.connectivity = ConnectivityMonitor()

        // Initialize all services
        self.auth = AuthenticationServiceImpl()
        self.repository = BusinessDataRepositoryImpl()
        self.sync = SyncServiceImpl()
        self.ai = AIServiceImpl()
        self.collaboration = CollaborationServiceImpl()
        self.network = NetworkServiceImpl()
        self.analytics = AnalyticsServiceImpl()
    }

    // MARK: - Methods

    nonisolated func initializeAll() async throws {
        // Start connectivity monitoring first
        await MainActor.run {
            connectivity.startMonitoring()
        }

        // Capture services in local variables to avoid self capture
        let auth = self.auth
        let repository = self.repository
        let sync = self.sync
        let ai = self.ai
        let collaboration = self.collaboration
        let network = self.network
        let analytics = self.analytics

        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask { try await auth.initialize() }
            group.addTask { try await repository.initialize() }
            group.addTask { try await sync.initialize() }
            group.addTask { try await ai.initialize() }
            group.addTask { try await collaboration.initialize() }
            group.addTask { try await network.initialize() }
            group.addTask { try await analytics.initialize() }

            try await group.waitForAll()
        }
    }

    nonisolated func shutdownAll() async {
        // Stop connectivity monitoring
        await MainActor.run {
            connectivity.stopMonitoring()
        }

        // Capture services in local variables to avoid self capture
        let auth = self.auth
        let repository = self.repository
        let sync = self.sync
        let ai = self.ai
        let collaboration = self.collaboration
        let network = self.network
        let analytics = self.analytics

        await withTaskGroup(of: Void.self) { group in
            group.addTask { await auth.shutdown() }
            group.addTask { await repository.shutdown() }
            group.addTask { await sync.shutdown() }
            group.addTask { await ai.shutdown() }
            group.addTask { await collaboration.shutdown() }
            group.addTask { await network.shutdown() }
            group.addTask { await analytics.shutdown() }
        }
    }

    /// Check if network is available
    var isOnline: Bool {
        connectivity.isConnected
    }
}
