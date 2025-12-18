//
//  KeychainService.swift
//  SpatialCodeReviewer
//
//  Created by Claude on 2025-11-24.
//

import Foundation
import Security

class KeychainService {
    static let shared = KeychainService()

    private let service = "com.spatialcodereviewer.auth"

    private init() {}

    // MARK: - Token Storage

    func storeToken(_ token: Token, for provider: String) throws {
        let data = try JSONEncoder().encode(token)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "\(provider)_token",
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            kSecAttrSynchronizable as String: false // Don't sync to iCloud
        ]

        // Delete existing item first
        SecItemDelete(query as CFDictionary)

        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw KeychainError.storeFailed(status: status)
        }
    }

    func retrieveToken(for provider: String) throws -> Token {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "\(provider)_token",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess else {
            throw KeychainError.retrieveFailed(status: status)
        }

        guard let data = result as? Data else {
            throw KeychainError.invalidData
        }

        let token = try JSONDecoder().decode(Token.self, from: data)
        return token
    }

    func deleteToken(for provider: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "\(provider)_token"
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status: status)
        }
    }

    // MARK: - PKCE Storage (Temporary)

    func storeCodeVerifier(_ verifier: String, for state: String) {
        UserDefaults.standard.set(verifier, forKey: "pkce_verifier_\(state)")
    }

    func retrieveCodeVerifier(for state: String) -> String? {
        return UserDefaults.standard.string(forKey: "pkce_verifier_\(state)")
    }

    func deleteCodeVerifier(for state: String) {
        UserDefaults.standard.removeObject(forKey: "pkce_verifier_\(state)")
    }

    // MARK: - Credential Storage

    func storeCredential(_ credential: String, forKey key: String) throws {
        let data = credential.data(using: .utf8)!

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            kSecAttrSynchronizable as String: false
        ]

        // Delete existing item first
        SecItemDelete(query as CFDictionary)

        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw KeychainError.storeFailed(status: status)
        }
    }

    func retrieveCredential(forKey key: String) throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess else {
            throw KeychainError.retrieveFailed(status: status)
        }

        guard let data = result as? Data,
              let credential = String(data: data, encoding: .utf8) else {
            throw KeychainError.invalidData
        }

        return credential
    }

    func deleteCredential(forKey key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status: status)
        }
    }
}

// MARK: - Keychain Errors

enum KeychainError: LocalizedError {
    case storeFailed(status: OSStatus)
    case retrieveFailed(status: OSStatus)
    case deleteFailed(status: OSStatus)
    case invalidData

    var errorDescription: String? {
        switch self {
        case .storeFailed(let status):
            return "Failed to store in Keychain: \(status)"
        case .retrieveFailed(let status):
            if status == errSecItemNotFound {
                return "No stored credentials found"
            }
            return "Failed to retrieve from Keychain: \(status)"
        case .deleteFailed(let status):
            return "Failed to delete from Keychain: \(status)"
        case .invalidData:
            return "Invalid data in Keychain"
        }
    }
}
