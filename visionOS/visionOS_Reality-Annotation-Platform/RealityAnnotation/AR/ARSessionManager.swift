//
//  ARSessionManager.swift
//  Reality Annotation Platform
//
//  Manages AR session lifecycle and state
//

import Foundation
import RealityKit
import ARKit

@MainActor
@Observable
class ARSessionManager {
    // Session state
    var state: ARSessionState = .stopped
    var trackingQuality: TrackingQuality = .unknown
    var errorMessage: String?

    // Scene reference
    private var rootEntity: Entity?
    private var isSessionRunning = false

    // MARK: - Session Lifecycle

    /// Start AR session
    func startSession() async {
        guard !isSessionRunning else {
            print("⚠️ AR session already running")
            return
        }

        print("▶️ Starting AR session")
        state = .starting

        // For visionOS, AR is automatically managed by the system
        // We just need to track our state
        isSessionRunning = true
        state = .running
        trackingQuality = .normal

        print("✅ AR session started")
    }

    /// Stop AR session
    func stopSession() {
        guard isSessionRunning else {
            print("⚠️ AR session not running")
            return
        }

        print("⏹️ Stopping AR session")
        state = .stopping

        isSessionRunning = false
        state = .stopped
        trackingQuality = .unknown

        print("✅ AR session stopped")
    }

    /// Pause AR session
    func pauseSession() {
        guard isSessionRunning else { return }

        print("⏸️ Pausing AR session")
        state = .paused
    }

    /// Resume AR session
    func resumeSession() {
        guard state == .paused else { return }

        print("▶️ Resuming AR session")
        state = .running
    }

    // MARK: - Scene Management

    /// Set the root entity for the scene
    func setRootEntity(_ entity: Entity) {
        self.rootEntity = entity
        print("🎬 Root entity set")
    }

    /// Get the root entity
    func getRootEntity() -> Entity? {
        return rootEntity
    }

    // MARK: - Error Handling

    func handleError(_ error: ARError) {
        print("❌ AR Error: \(error.localizedDescription)")
        errorMessage = error.localizedDescription
        state = .error(error)
    }

    func clearError() {
        errorMessage = nil
        if case .error = state {
            state = .stopped
        }
    }
}

// MARK: - AR Session State

enum ARSessionState {
    case stopped
    case starting
    case running
    case paused
    case stopping
    case error(Error)

    var isActive: Bool {
        if case .running = self {
            return true
        }
        return false
    }

    var displayName: String {
        switch self {
        case .stopped: return "Stopped"
        case .starting: return "Starting..."
        case .running: return "Running"
        case .paused: return "Paused"
        case .stopping: return "Stopping..."
        case .error: return "Error"
        }
    }
}

// MARK: - Tracking Quality

enum TrackingQuality {
    case unknown
    case poor
    case normal
    case excellent

    var displayName: String {
        switch self {
        case .unknown: return "Unknown"
        case .poor: return "Poor"
        case .normal: return "Normal"
        case .excellent: return "Excellent"
        }
    }

    var color: String {
        switch self {
        case .unknown: return "gray"
        case .poor: return "red"
        case .normal: return "yellow"
        case .excellent: return "green"
        }
    }
}

// MARK: - AR Error

enum ARError: LocalizedError {
    case sessionFailed
    case trackingLost
    case anchorCreationFailed
    case relocalizationFailed

    var errorDescription: String? {
        switch self {
        case .sessionFailed:
            return "Failed to start AR session"
        case .trackingLost:
            return "AR tracking lost. Try moving device slowly."
        case .anchorCreationFailed:
            return "Failed to create spatial anchor"
        case .relocalizationFailed:
            return "Could not relocalize in this space"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .trackingLost:
            return "Move your device slowly and ensure good lighting"
        case .relocalizationFailed:
            return "Make sure you're in the same physical location"
        default:
            return nil
        }
    }
}
