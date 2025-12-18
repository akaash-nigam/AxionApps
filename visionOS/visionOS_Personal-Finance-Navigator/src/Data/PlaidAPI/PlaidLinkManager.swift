// PlaidLinkManager.swift
// Personal Finance Navigator
// Manager for Plaid Link UI integration

import Foundation
import SwiftUI
import OSLog

private let logger = Logger(subsystem: "com.pfn", category: "plaid-link")

/// Manages Plaid Link integration for visionOS
@MainActor
@Observable
class PlaidLinkManager {
    // MARK: - State

    private(set) var isPresented = false
    private(set) var linkToken: String?
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    // Callbacks
    var onSuccess: ((String) -> Void)?
    var onExit: (() -> Void)?

    // MARK: - Dependencies

    private let plaidService: PlaidService

    // MARK: - Init

    init(plaidService: PlaidService) {
        self.plaidService = plaidService
    }

    // MARK: - Public Methods

    /// Prepares and presents Plaid Link
    func present(userId: String) async {
        isLoading = true
        errorMessage = nil

        do {
            // Create link token
            linkToken = try await plaidService.createLinkToken(userId: userId)
            isPresented = true
            logger.info("Plaid Link prepared successfully")
        } catch {
            errorMessage = "Failed to initialize bank connection: \(error.localizedDescription)"
            logger.error("Failed to create link token: \(error.localizedDescription)")
        }

        isLoading = false
    }

    /// Dismisses Plaid Link
    func dismiss() {
        isPresented = false
        linkToken = nil
        onExit?()
    }

    /// Handles successful connection
    func handleSuccess(publicToken: String, metadata: LinkSuccessMetadata?) {
        logger.info("Plaid Link success")
        onSuccess?(publicToken)
        dismiss()
    }

    /// Handles Link exit
    func handleExit(error: LinkError?) {
        if let error = error {
            logger.warning("Plaid Link exited with error: \(error.message)")
            errorMessage = error.message
        }
        dismiss()
    }
}

// MARK: - Metadata Models

struct LinkSuccessMetadata {
    let institutionName: String?
    let institutionId: String?
    let accountIds: [String]
    let linkSessionId: String?
}

struct LinkError {
    let code: String
    let message: String
    let displayMessage: String?
}

// MARK: - Configuration

struct PlaidLinkConfiguration {
    let linkToken: String
    let onSuccess: (String, LinkSuccessMetadata?) -> Void
    let onExit: (LinkError?) -> Void
}

/// Note: Plaid Link for visionOS integration requires the official Plaid Link SDK.
/// This is a placeholder structure for when the SDK is integrated.
///
/// To integrate:
/// 1. Add Plaid SDK to Swift Package Manager or via CocoaPods
/// 2. Import LinkKit
/// 3. Use PLKPlaidLinkConfiguration to configure the SDK
/// 4. Present LinkKit handler
///
/// Example integration code (when SDK is available):
/// ```swift
/// import LinkKit
///
/// let config = PLKLinkConfiguration(
///     linkToken: linkToken,
///     onSuccess: { publicToken, metadata in
///         handleSuccess(publicToken: publicToken, metadata: metadata)
///     },
///     onExit: { error in
///         handleExit(error: error)
///     }
/// )
///
/// let handler = PLKPlaidLinkHandler(configuration: config)
/// handler.present(from: viewController)
/// ```
///
/// For now, this manager provides the architecture for when the SDK is integrated.
