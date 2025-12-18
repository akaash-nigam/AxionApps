// SessionManager.swift
// Personal Finance Navigator
// Manages user session state and auto-lock functionality

import Foundation
import SwiftUI
import OSLog

private let logger = Logger(subsystem: "com.pfn", category: "security")

/// Manages authentication state and auto-lock behavior
@MainActor
@Observable
class SessionManager {
    // MARK: - Published State

    /// Whether the user is currently authenticated
    private(set) var isAuthenticated = false

    /// Whether biometric authentication is required
    var requiresBiometric = true

    /// Auto-lock timeout in seconds (default: 5 minutes)
    var autoLockTimeout: TimeInterval = 300

    /// Whether auto-lock is enabled
    var autoLockEnabled = true

    // MARK: - Private State

    private var lastActiveDate: Date?
    private var backgroundDate: Date?
    private let biometricAuthManager: BiometricAuthManager

    // MARK: - Init

    init(biometricAuthManager: BiometricAuthManager = BiometricAuthManager()) {
        self.biometricAuthManager = biometricAuthManager
        loadSettings()
    }

    // MARK: - Authentication

    /// Authenticate the user with biometrics
    func authenticate() async throws {
        guard requiresBiometric else {
            // If biometric not required, just mark as authenticated
            isAuthenticated = true
            updateLastActiveDate()
            logger.info("Session started (no biometric required)")
            return
        }

        do {
            try await biometricAuthManager.authenticate()
            isAuthenticated = true
            updateLastActiveDate()
            logger.info("Session started with biometric authentication")
        } catch {
            logger.error("Authentication failed: \(error.localizedDescription)")
            throw error
        }
    }

    /// Lock the session (require re-authentication)
    func lock() {
        isAuthenticated = false
        lastActiveDate = nil
        logger.info("Session locked")
    }

    /// Manually unlock without biometric (for testing or fallback)
    func unlockManually() {
        isAuthenticated = true
        updateLastActiveDate()
        logger.warning("Session unlocked manually (bypassing biometric)")
    }

    // MARK: - Session Lifecycle

    /// Called when app enters foreground
    func didBecomeActive() {
        logger.debug("App became active")

        // Check if we need to re-authenticate
        if autoLockEnabled, let backgroundDate = backgroundDate {
            let elapsed = Date().timeIntervalSince(backgroundDate)

            if elapsed >= autoLockTimeout {
                lock()
                logger.info("Auto-lock triggered after \(elapsed)s in background")
            } else {
                logger.debug("No auto-lock needed (elapsed: \(elapsed)s)")
            }
        }

        backgroundDate = nil
        updateLastActiveDate()
    }

    /// Called when app enters background
    func didEnterBackground() {
        backgroundDate = Date()
        logger.debug("App entered background at \(backgroundDate!)")
    }

    /// Called when app becomes inactive (e.g., during transition)
    func didBecomeInactive() {
        logger.debug("App became inactive")
        // Don't lock immediately, just track the time
    }

    /// Check if session should be locked due to inactivity
    func checkInactivityTimeout() {
        guard autoLockEnabled, isAuthenticated else { return }
        guard let lastActive = lastActiveDate else { return }

        let elapsed = Date().timeIntervalSince(lastActive)
        if elapsed >= autoLockTimeout {
            lock()
            logger.info("Session locked due to inactivity (\(elapsed)s)")
        }
    }

    // MARK: - Settings

    /// Load settings from UserDefaults
    private func loadSettings() {
        requiresBiometric = UserDefaults.standard.object(forKey: "requiresBiometric") as? Bool ?? true
        autoLockTimeout = UserDefaults.standard.object(forKey: "autoLockTimeout") as? TimeInterval ?? 300
        autoLockEnabled = UserDefaults.standard.object(forKey: "autoLockEnabled") as? Bool ?? true

        logger.debug("Loaded settings - biometric: \(requiresBiometric), timeout: \(autoLockTimeout)s, enabled: \(autoLockEnabled)")
    }

    /// Save settings to UserDefaults
    func saveSettings() {
        UserDefaults.standard.set(requiresBiometric, forKey: "requiresBiometric")
        UserDefaults.standard.set(autoLockTimeout, forKey: "autoLockTimeout")
        UserDefaults.standard.set(autoLockEnabled, forKey: "autoLockEnabled")

        logger.info("Saved security settings")
    }

    /// Update the last active timestamp
    private func updateLastActiveDate() {
        lastActiveDate = Date()
    }

    // MARK: - Helper Methods

    /// Check if biometric authentication is available
    func checkBiometricAvailability() async -> (available: Bool, biometricType: String?) {
        let context = await biometricAuthManager.context
        var error: NSError?

        let available = await context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)

        if available {
            let type = await context.biometryType
            let biometricName: String
            switch type {
            case .faceID:
                biometricName = "Face ID"
            case .touchID:
                biometricName = "Touch ID"
            case .opticID:
                biometricName = "Optic ID"
            default:
                biometricName = "Biometric"
            }
            return (true, biometricName)
        } else {
            logger.warning("Biometric not available: \(error?.localizedDescription ?? "unknown error")")
            return (false, nil)
        }
    }
}
