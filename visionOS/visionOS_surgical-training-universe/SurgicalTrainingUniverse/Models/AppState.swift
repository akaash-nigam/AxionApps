//
//  AppState.swift
//  Surgical Training Universe
//
//  Application-wide state management
//

import SwiftUI
import Observation

/// Application-level state management using Swift's Observation framework
@Observable
class AppState {

    // MARK: - User State

    /// Currently authenticated user
    var currentUser: SurgeonProfile?

    /// Authentication status
    var isAuthenticated: Bool = false

    // MARK: - Session State

    /// Currently active surgical procedure session
    var activeProcedure: ProcedureSession?

    /// Whether user is currently in immersive mode
    var isInImmersiveMode: Bool = false

    /// Currently selected anatomical model for exploration
    var selectedAnatomyModel: AnatomicalModel?

    /// Currently selected surgical instrument
    var selectedInstrument: SurgicalInstrument?

    // MARK: - UI State

    /// Navigation path for window-based navigation
    var navigationPath: [Route] = []

    /// Whether settings window is visible
    var showingSettings: Bool = false

    /// Whether analytics window is visible
    var showingAnalytics: Bool = false

    /// Current error message to display
    var errorMessage: String?

    /// Whether a loading operation is in progress
    var isLoading: Bool = false

    // MARK: - Collaboration State

    /// Active collaboration session
    var collaborationSession: CollaborationSession?

    /// Connected peer users
    var connectedPeers: [SurgeonProfile] = []

    /// Whether collaboration is active
    var isCollaborating: Bool = false

    // MARK: - Initialization

    init() {
        // Initialize with default state
        // In production, load saved state from UserDefaults or similar
        print("✅ AppState initialized")
    }

    // MARK: - Methods

    /// Set the current user and mark as authenticated
    func signIn(user: SurgeonProfile) {
        self.currentUser = user
        self.isAuthenticated = true
        print("✅ User signed in: \(user.name)")
    }

    /// Clear current user and sign out
    func signOut() {
        self.currentUser = nil
        self.isAuthenticated = false
        self.activeProcedure = nil
        self.collaborationSession = nil
        self.connectedPeers = []
        print("✅ User signed out")
    }

    /// Start a new procedure session
    func startProcedure(_ session: ProcedureSession) {
        self.activeProcedure = session
        print("✅ Started procedure: \(session.procedureType)")
    }

    /// End the current procedure session
    func endProcedure() {
        self.activeProcedure = nil
        print("✅ Ended procedure")
    }

    /// Enter immersive mode
    func enterImmersiveMode() {
        self.isInImmersiveMode = true
        print("✅ Entered immersive mode")
    }

    /// Exit immersive mode
    func exitImmersiveMode() {
        self.isInImmersiveMode = false
        print("✅ Exited immersive mode")
    }

    /// Display an error message
    func showError(_ message: String) {
        self.errorMessage = message
        print("⚠️ Error: \(message)")
    }

    /// Clear the current error message
    func clearError() {
        self.errorMessage = nil
    }
}

/// Navigation routes for the app
enum Route: Hashable {
    case dashboard
    case procedureLibrary
    case procedureDetail(ProcedureType)
    case analytics
    case settings
    case profile
}
