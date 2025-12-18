//
//  AuthenticationManager.swift
//  CultureArchitectureSystem
//
//  Created on 2025-01-20
//

import Foundation
import AuthenticationServices

actor AuthenticationManager {
    private var accessToken: String?
    private var refreshToken: String?
    private var tokenExpiry: Date?

    // MARK: - Public Methods

    func authenticate() async throws -> String {
        // OAuth 2.0 flow with PKCE
        // In production, use ASWebAuthenticationSession

        // For MVP/development, return mock token
        let token = "dev_token_\(UUID().uuidString)"
        self.accessToken = token
        self.tokenExpiry = Date().addingTimeInterval(3600) // 1 hour

        return token
    }

    func getAccessToken() async throws -> String {
        // Check if we have a valid token
        if let token = accessToken,
           let expiry = tokenExpiry,
           expiry > Date() {
            return token
        }

        // Refresh or re-authenticate
        return try await authenticate()
    }

    func logout() {
        accessToken = nil
        refreshToken = nil
        tokenExpiry = nil
    }

    var isAuthenticated: Bool {
        guard let expiry = tokenExpiry else { return false }
        return accessToken != nil && expiry > Date()
    }
}

// MARK: - Authentication Errors

enum AuthError: Error {
    case authenticationFailed
    case tokenExpired
    case refreshFailed
}
