// BiometricAuthManager.swift
// Personal Finance Navigator
// Biometric authentication (Face ID / Optic ID) management

import Foundation
import LocalAuthentication
import OSLog

private let logger = Logger(subsystem: "com.pfn", category: "biometric")

/// Manages biometric authentication (Face ID for visionOS)
actor BiometricAuthManager {
    // MARK: - Errors
    enum AuthenticationError: LocalizedError {
        case notAvailable
        case failed(Error)
        case userCancelled
        case biometryLockout
        case passcodeNotSet

        var errorDescription: String? {
            switch self {
            case .notAvailable:
                return "Biometric authentication is not available on this device"
            case .failed(let error):
                return "Authentication failed: \(error.localizedDescription)"
            case .userCancelled:
                return "Authentication was cancelled"
            case .biometryLockout:
                return "Too many failed attempts. Please try again later."
            case .passcodeNotSet:
                return "Device passcode is not set"
            }
        }
    }

    // MARK: - State
    private var isAuthenticated = false
    private var lastAuthenticationDate: Date?
    private let authenticationTimeout: TimeInterval

    // MARK: - Init
    init(authenticationTimeout: TimeInterval = 300) { // 5 minutes default
        self.authenticationTimeout = authenticationTimeout
    }

    // MARK: - Biometric Availability
    /// Checks if biometric authentication is available
    func isBiometricAvailable() -> Bool {
        let context = LAContext()
        var error: NSError?

        let isAvailable = context.canEvaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            error: &error
        )

        if let error = error {
            logger.error("Biometric check failed: \(error.localizedDescription)")
        }

        return isAvailable
    }

    /// Gets the type of biometric authentication available
    func getBiometricType() -> LABiometryType {
        let context = LAContext()
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        return context.biometryType
    }

    /// Gets a user-friendly name for the biometric type
    var biometricTypeName: String {
        switch getBiometricType() {
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        case .opticID:
            return "Optic ID" // For Vision Pro
        case .none:
            return "None"
        @unknown default:
            return "Biometric"
        }
    }

    // MARK: - Authentication
    /// Authenticates the user using biometrics
    func authenticate() async throws {
        // Check if recent authentication is still valid
        if let lastAuth = lastAuthenticationDate,
           Date().timeIntervalSince(lastAuth) < authenticationTimeout {
            logger.debug("Using cached authentication")
            return
        }

        let context = LAContext()
        context.localizedCancelTitle = "Cancel"

        var error: NSError?

        // Check if biometric authentication is available
        guard context.canEvaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            error: &error
        ) else {
            if let error = error {
                logger.error("Biometric not available: \(error.localizedDescription)")

                switch error.code {
                case LAError.biometryNotAvailable.rawValue:
                    throw AuthenticationError.notAvailable
                case LAError.passcodeNotSet.rawValue:
                    throw AuthenticationError.passcodeNotSet
                default:
                    throw AuthenticationError.failed(error)
                }
            }

            // Fallback to passcode
            try await authenticateWithPasscode(context: context)
            return
        }

        let reason = "Unlock your financial data"

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )

            if success {
                isAuthenticated = true
                lastAuthenticationDate = Date()
                logger.info("Biometric authentication succeeded")
            }
        } catch let error as LAError {
            logger.error("Biometric authentication failed: \(error.localizedDescription)")

            switch error.code {
            case .biometryLockout:
                // Too many failed attempts, require passcode
                throw AuthenticationError.biometryLockout

            case .userFallback:
                // User chose to use passcode
                try await authenticateWithPasscode(context: context)

            case .userCancel:
                throw AuthenticationError.userCancelled

            case .authenticationFailed:
                // Biometric didn't match, allow retry
                throw AuthenticationError.failed(error)

            default:
                throw AuthenticationError.failed(error)
            }
        }
    }

    /// Authenticates using device passcode
    private func authenticateWithPasscode(context: LAContext) async throws {
        let reason = "Enter your device passcode"

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthentication,
                localizedReason: reason
            )

            if success {
                isAuthenticated = true
                lastAuthenticationDate = Date()
                logger.info("Passcode authentication succeeded")
            }
        } catch {
            logger.error("Passcode authentication failed: \(error.localizedDescription)")
            throw AuthenticationError.failed(error)
        }
    }

    // MARK: - Session Management
    /// Invalidates the current authentication session
    func invalidateAuthentication() {
        isAuthenticated = false
        lastAuthenticationDate = nil
        logger.info("Authentication invalidated")
    }

    /// Checks if re-authentication is required
    var requiresAuthentication: Bool {
        guard let lastAuth = lastAuthenticationDate else {
            return true
        }

        return Date().timeIntervalSince(lastAuth) >= authenticationTimeout
    }

    /// Gets the time until authentication expires
    var timeUntilExpiration: TimeInterval? {
        guard let lastAuth = lastAuthenticationDate else {
            return nil
        }

        let elapsed = Date().timeIntervalSince(lastAuth)
        let remaining = authenticationTimeout - elapsed

        return remaining > 0 ? remaining : nil
    }

    // MARK: - Settings
    /// Updates the authentication timeout
    func updateTimeout(_ timeout: TimeInterval) {
        // Timeout must be between 1 minute and 30 minutes
        let validTimeout = max(60, min(1800, timeout))

        // If new timeout is shorter and would expire current session, invalidate
        if let lastAuth = lastAuthenticationDate,
           Date().timeIntervalSince(lastAuth) >= validTimeout {
            invalidateAuthentication()
        }

        logger.info("Authentication timeout updated to \(validTimeout)s")
    }
}
