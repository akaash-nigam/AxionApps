//
//  AppState.swift
//  FieldServiceAR
//
//  Application-wide state management
//

import Foundation
import Observation

@Observable
class AppState {
    // Current user
    var currentUser: Technician?

    // Selected job
    var selectedJob: ServiceJob?

    // Active collaboration session
    var activeSession: CollaborationSession?

    // Network status
    var networkStatus: NetworkStatus = .unknown

    // Sync status
    var syncStatus: SyncStatus = .idle

    // AR session active
    var isARActive: Bool = false

    // Error state
    var currentError: Error?

    // Loading state
    var isLoading: Bool = false

    init() {
        // Initialize with default values
    }

    func reset() {
        selectedJob = nil
        activeSession = nil
        isARActive = false
        currentError = nil
        isLoading = false
    }
}

// Network Status
enum NetworkStatus: String {
    case unknown
    case offline
    case online
    case limited
}

// Sync Status
enum SyncStatus: String {
    case idle
    case syncing
    case completed
    case failed
}
