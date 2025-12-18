//
//  OAuthConfiguration.swift
//  SpatialCodeReviewer
//
//  Created by Claude on 2025-11-24.
//

import Foundation

struct OAuthConfiguration {
    let clientID: String
    let clientSecret: String
    let redirectURI: URL
    let scopes: [String]
    let authorizationEndpoint: URL
    let tokenEndpoint: URL
}

// MARK: - OAuth Providers

enum OAuthProvider {
    case github

    var configuration: OAuthConfiguration {
        switch self {
        case .github:
            return OAuthConfiguration(
                clientID: loadClientID(),
                clientSecret: loadClientSecret(),
                redirectURI: URL(string: "spatialcodereviewer://oauth/github")!,
                scopes: ["repo", "read:user", "read:org"],
                authorizationEndpoint: URL(string: "https://github.com/login/oauth/authorize")!,
                tokenEndpoint: URL(string: "https://github.com/login/oauth/access_token")!
            )
        }
    }

    private func loadClientID() -> String {
        // Priority 1: Environment variable (best for local development)
        if let clientID = ProcessInfo.processInfo.environment["GITHUB_CLIENT_ID"],
           !clientID.isEmpty, clientID != "YOUR_GITHUB_CLIENT_ID" {
            return clientID
        }

        // Priority 2: Info.plist (best for Xcode build configuration)
        if let clientID = Bundle.main.object(forInfoDictionaryKey: "GithubClientID") as? String,
           !clientID.isEmpty, !clientID.contains("$") {
            return clientID
        }

        // Priority 3: Keychain (most secure for production)
        if let clientID = try? KeychainService.shared.retrieveCredential(forKey: "github_client_id") {
            return clientID
        }

        // Development fallback - returns placeholder
        // In production, this would trigger setup instructions
        #if DEBUG
        print("⚠️ GitHub Client ID not configured. Using placeholder for development.")
        print("📖 See docs/OAUTH_SETUP.md for configuration instructions.")
        return "YOUR_GITHUB_CLIENT_ID"
        #else
        fatalError("GitHub Client ID not configured. See docs/OAUTH_SETUP.md")
        #endif
    }

    private func loadClientSecret() -> String {
        // Priority 1: Environment variable (best for local development)
        if let clientSecret = ProcessInfo.processInfo.environment["GITHUB_CLIENT_SECRET"],
           !clientSecret.isEmpty, clientSecret != "YOUR_GITHUB_CLIENT_SECRET" {
            return clientSecret
        }

        // Priority 2: Info.plist (best for Xcode build configuration)
        if let clientSecret = Bundle.main.object(forInfoDictionaryKey: "GithubClientSecret") as? String,
           !clientSecret.isEmpty, !clientSecret.contains("$") {
            return clientSecret
        }

        // Priority 3: Keychain (most secure for production)
        if let clientSecret = try? KeychainService.shared.retrieveCredential(forKey: "github_client_secret") {
            return clientSecret
        }

        // Development fallback - returns placeholder
        #if DEBUG
        print("⚠️ GitHub Client Secret not configured. Using placeholder for development.")
        print("📖 See docs/OAUTH_SETUP.md for configuration instructions.")
        return "YOUR_GITHUB_CLIENT_SECRET"
        #else
        fatalError("GitHub Client Secret not configured. See docs/OAUTH_SETUP.md")
        #endif
    }
}

// MARK: - PKCE Helper

struct PKCEHelper {
    /// Generate a cryptographically secure code verifier
    static func generateCodeVerifier() -> String {
        var buffer = [UInt8](repeating: 0, count: 32)
        let result = SecRandomCopyBytes(kSecRandomDefault, buffer.count, &buffer)

        guard result == errSecSuccess else {
            fatalError("Failed to generate random bytes for PKCE")
        }

        return Data(buffer)
            .base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
            .trimmingCharacters(in: .whitespaces)
    }

    /// Generate code challenge from verifier using SHA256
    static func generateCodeChallenge(from verifier: String) -> String {
        guard let data = verifier.data(using: .utf8) else {
            fatalError("Failed to convert verifier to data")
        }

        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }

        return Data(hash)
            .base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
            .trimmingCharacters(in: .whitespaces)
    }
}

// For SHA256, we need CommonCrypto
import CommonCrypto
