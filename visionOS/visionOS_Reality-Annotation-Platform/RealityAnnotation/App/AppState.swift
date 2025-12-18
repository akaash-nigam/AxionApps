//
//  AppState.swift
//  Reality Annotation Platform
//
//  Global application state
//

import SwiftUI
import CloudKit

@MainActor
@Observable
class AppState {
    // Singleton
    static let shared = AppState()

    // Authentication
    var currentUser: User?
    var isAuthenticated = false

    // AR Session
    var isImmersiveSpaceActive = false
    var arSessionState: ARSessionState = .stopped

    // Layer Management
    var activeLayers: Set<UUID> = []
    var allLayers: [Layer] = []

    // UI State
    var selectedAnnotation: Annotation?
    var isShowingCreatePanel = false
    var isShowingSettings = false

    // Network & Sync
    var isOnline = true
    var isSyncing = false
    var lastSyncTime: Date?
    var syncStatus: SyncStatus = .idle

    // Sync Coordinator (lazy loaded)
    private var _syncCoordinator: SyncCoordinator?
    var syncCoordinator: SyncCoordinator {
        if _syncCoordinator == nil {
            _syncCoordinator = ServiceContainer.shared.syncCoordinator
            // Observe sync status
            Task {
                await startObservingSyncStatus()
            }
        }
        return _syncCoordinator!
    }

    private init() {
        print("📱 AppState initialized")
    }

    // MARK: - Actions

    func toggleLayer(_ layerID: UUID) {
        if activeLayers.contains(layerID) {
            activeLayers.remove(layerID)
        } else {
            activeLayers.insert(layerID)
        }
    }

    func selectAnnotation(_ annotation: Annotation?) {
        selectedAnnotation = annotation
    }

    func updateSyncStatus(syncing: Bool) {
        isSyncing = syncing
        if !syncing {
            lastSyncTime = Date()
        }
    }

    // MARK: - Sync Actions

    func startSync() async {
        await syncCoordinator.startSync()
    }

    func stopSync() {
        syncCoordinator.stopSync()
    }

    func syncNow() async {
        do {
            try await syncCoordinator.syncNow()
        } catch {
            print("❌ Manual sync failed: \(error)")
        }
    }

    private func startObservingSyncStatus() async {
        // Poll sync status periodically
        while true {
            let coordinator = syncCoordinator as? DefaultSyncCoordinator
            syncStatus = coordinator?.syncStatus ?? .idle
            isSyncing = (syncStatus == .syncing)
            lastSyncTime = coordinator?.lastSyncTime

            try? await Task.sleep(for: .milliseconds(500))
        }
    }
}

// MARK: - AR Session State

enum ARSessionState {
    case stopped
    case starting
    case running
    case paused
    case error(Error)

    var isActive: Bool {
        if case .running = self {
            return true
        }
        return false
    }
}
