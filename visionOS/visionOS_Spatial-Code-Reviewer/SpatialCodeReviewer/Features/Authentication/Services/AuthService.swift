//
//  AuthService.swift
//  SpatialCodeReviewer
//
//  Created by Claude on 2025-11-24.
//

import Foundation
import Security
import AuthenticationServices

@MainActor
class AuthService: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentToken: Token?

    private let keychainService = KeychainService.shared
    private var currentAuthSession: ASWebAuthenticationSession?

    // MARK: - Initialization

    init() {
        // Try to restore previous session on init
        Task {
            await restoreSession()
        }
    }

    // MARK: - Authentication

    func authenticate(provider: AuthProvider) async throws {
        // Only GitHub is supported in MVP
        guard provider == .github else {
            throw AuthError.unsupportedProvider
        }

        let config = OAuthProvider.github.configuration

        // Generate PKCE parameters
        let state = UUID().uuidString
        let codeVerifier = PKCEHelper.generateCodeVerifier()
        let codeChallenge = PKCEHelper.generateCodeChallenge(from: codeVerifier)

        // Store code verifier for later
        keychainService.storeCodeVerifier(codeVerifier, for: state)

        // Build authorization URL
        var components = URLComponents(url: config.authorizationEndpoint, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: config.clientID),
            URLQueryItem(name: "redirect_uri", value: config.redirectURI.absoluteString),
            URLQueryItem(name: "scope", value: config.scopes.joined(separator: " ")),
            URLQueryItem(name: "state", value: state),
            URLQueryItem(name: "code_challenge", value: codeChallenge),
            URLQueryItem(name: "code_challenge_method", value: "S256")
        ]

        guard let authURL = components.url else {
            throw AuthError.invalidAuthorizationURL
        }

        // Start OAuth flow with ASWebAuthenticationSession
        let authCode = try await performWebAuthentication(
            url: authURL,
            callbackURLScheme: "spatialcodereviewer"
        )

        // Extract code and state from callback
        guard let callbackComponents = URLComponents(url: authCode, resolvingAgainstBaseURL: false),
              let code = callbackComponents.queryItems?.first(where: { $0.name == "code" })?.value,
              let returnedState = callbackComponents.queryItems?.first(where: { $0.name == "state" })?.value,
              returnedState == state else {
            throw AuthError.invalidCallback
        }

        // Retrieve code verifier
        guard let storedVerifier = keychainService.retrieveCodeVerifier(for: state) else {
            throw AuthError.missingCodeVerifier
        }

        // Exchange code for token
        let token = try await exchangeCodeForToken(
            code: code,
            codeVerifier: storedVerifier,
            config: config
        )

        // Store token securely
        try await storeToken(token, for: provider)

        // Clean up code verifier
        keychainService.deleteCodeVerifier(for: state)

        // Update state
        currentToken = token
        isAuthenticated = true
    }

    private func performWebAuthentication(url: URL, callbackURLScheme: String) async throws -> URL {
        return try await withCheckedThrowingContinuation { continuation in
            let session = ASWebAuthenticationSession(
                url: url,
                callbackURLScheme: callbackURLScheme
            ) { callbackURL, error in
                if let error = error {
                    continuation.resume(throwing: AuthError.authenticationCancelled(error.localizedDescription))
                    return
                }

                guard let callbackURL = callbackURL else {
                    continuation.resume(throwing: AuthError.invalidCallback)
                    return
                }

                continuation.resume(returning: callbackURL)
            }

            session.prefersEphemeralWebBrowserSession = true
            self.currentAuthSession = session
            session.start()
        }
    }

    private func exchangeCodeForToken(
        code: String,
        codeVerifier: String,
        config: OAuthConfiguration
    ) async throws -> Token {
        var request = URLRequest(url: config.tokenEndpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let bodyParameters = [
            "client_id": config.clientID,
            "client_secret": config.clientSecret,
            "code": code,
            "redirect_uri": config.redirectURI.absoluteString,
            "code_verifier": codeVerifier
        ]

        let bodyString = bodyParameters
            .map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? $0.value)" }
            .joined(separator: "&")

        request.httpBody = bodyString.data(using: .utf8)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw AuthError.tokenExchangeFailed(statusCode: httpResponse.statusCode)
        }

        // Parse token response
        struct TokenResponse: Codable {
            let access_token: String
            let token_type: String
            let scope: String?
            let refresh_token: String?
            let expires_in: Int?
        }

        let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)

        let expiresAt: Date
        if let expiresIn = tokenResponse.expires_in {
            expiresAt = Date().addingTimeInterval(TimeInterval(expiresIn))
        } else {
            // GitHub tokens don't expire by default, set to 1 year
            expiresAt = Date().addingTimeInterval(365 * 24 * 60 * 60)
        }

        return Token(
            accessToken: tokenResponse.access_token,
            refreshToken: tokenResponse.refresh_token,
            expiresAt: expiresAt,
            tokenType: tokenResponse.token_type,
            scope: tokenResponse.scope
        )
    }

    func retrieveStoredToken() async throws -> Token {
        return try keychainService.retrieveToken(for: AuthProvider.github.rawValue)
    }

    func storeToken(_ token: Token, for provider: AuthProvider) async throws {
        try keychainService.storeToken(token, for: provider.rawValue)
        currentToken = token
        isAuthenticated = true
    }

    func clearToken() async throws {
        try keychainService.deleteToken(for: AuthProvider.github.rawValue)
        currentToken = nil
        isAuthenticated = false
    }

    func refreshToken() async throws -> Token {
        guard let token = currentToken else {
            throw AuthError.noTokenFound
        }

        guard let refreshToken = token.refreshToken else {
            // GitHub doesn't use refresh tokens, return current token
            return token
        }

        let config = OAuthProvider.github.configuration

        var request = URLRequest(url: config.tokenEndpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let bodyParameters = [
            "client_id": config.clientID,
            "client_secret": config.clientSecret,
            "refresh_token": refreshToken,
            "grant_type": "refresh_token"
        ]

        let bodyString = bodyParameters
            .map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? $0.value)" }
            .joined(separator: "&")

        request.httpBody = bodyString.data(using: .utf8)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw AuthError.tokenRefreshFailed
        }

        struct TokenResponse: Codable {
            let access_token: String
            let token_type: String
            let scope: String?
            let refresh_token: String?
            let expires_in: Int?
        }

        let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)

        let expiresAt: Date
        if let expiresIn = tokenResponse.expires_in {
            expiresAt = Date().addingTimeInterval(TimeInterval(expiresIn))
        } else {
            expiresAt = Date().addingTimeInterval(365 * 24 * 60 * 60)
        }

        let newToken = Token(
            accessToken: tokenResponse.access_token,
            refreshToken: tokenResponse.refresh_token ?? refreshToken,
            expiresAt: expiresAt,
            tokenType: tokenResponse.token_type,
            scope: tokenResponse.scope
        )

        // Store refreshed token
        try await storeToken(newToken, for: .github)

        return newToken
    }

    // MARK: - Session Management

    private func restoreSession() async {
        do {
            let token = try await retrieveStoredToken()

            // Check if token is expired
            if token.isExpired {
                // Try to refresh
                let refreshedToken = try await refreshToken()
                currentToken = refreshedToken
                isAuthenticated = true
            } else {
                currentToken = token
                isAuthenticated = true
            }
        } catch {
            // No stored token or restoration failed
            isAuthenticated = false
            currentToken = nil
        }
    }

    func validateToken() async throws -> Bool {
        guard let token = currentToken else {
            return false
        }

        // Make a test API call to GitHub
        var request = URLRequest(url: URL(string: "https://api.github.com/user")!)
        request.setValue("Bearer \(token.accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            return false
        }

        return httpResponse.statusCode == 200
    }
}

// MARK: - Auth Errors

enum AuthError: LocalizedError {
    case noTokenFound
    case invalidToken
    case authenticationFailed(String)
    case tokenExpired
    case unsupportedProvider
    case invalidAuthorizationURL
    case authenticationCancelled(String)
    case invalidCallback
    case missingCodeVerifier
    case tokenExchangeFailed(statusCode: Int)
    case invalidResponse
    case tokenRefreshFailed

    var errorDescription: String? {
        switch self {
        case .noTokenFound:
            return "No authentication token found"
        case .invalidToken:
            return "The authentication token is invalid"
        case .authenticationFailed(let message):
            return "Authentication failed: \(message)"
        case .tokenExpired:
            return "Authentication token has expired"
        case .unsupportedProvider:
            return "This authentication provider is not supported yet"
        case .invalidAuthorizationURL:
            return "Failed to create authorization URL"
        case .authenticationCancelled(let message):
            return "Authentication was cancelled: \(message)"
        case .invalidCallback:
            return "Invalid callback from authentication provider"
        case .missingCodeVerifier:
            return "Security verification failed: missing code verifier"
        case .tokenExchangeFailed(let statusCode):
            return "Failed to exchange authorization code for token (HTTP \(statusCode))"
        case .invalidResponse:
            return "Invalid response from authentication server"
        case .tokenRefreshFailed:
            return "Failed to refresh authentication token"
        }
    }
}
