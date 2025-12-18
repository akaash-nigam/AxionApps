// KeychainManager.swift
// Personal Finance Navigator
// Secure keychain storage for sensitive data

import Foundation
import Security
import OSLog

private let logger = Logger(subsystem: "com.pfn", category: "keychain")

/// Manages secure storage in the system keychain
actor KeychainManager {
    // MARK: - Errors
    enum KeychainError: LocalizedError {
        case saveFailed(OSStatus)
        case loadFailed(OSStatus)
        case deleteFailed(OSStatus)
        case itemNotFound
        case invalidData

        var errorDescription: String? {
            switch self {
            case .saveFailed(let status):
                return "Failed to save to keychain: \(status)"
            case .loadFailed(let status):
                return "Failed to load from keychain: \(status)"
            case .deleteFailed(let status):
                return "Failed to delete from keychain: \(status)"
            case .itemNotFound:
                return "Item not found in keychain"
            case .invalidData:
                return "Invalid data format"
            }
        }
    }

    // MARK: - Save
    /// Saves a string value to the keychain
    func save(_ value: String, forKey key: String) throws {
        guard let data = value.data(using: .utf8) else {
            throw KeychainError.invalidData
        }

        try save(data, forKey: key)
    }

    /// Saves data to the keychain
    func save(_ data: Data, forKey key: String) throws {
        // Delete existing item first
        try? delete(forKey: key)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            kSecAttrSynchronizable as String: false // Don't sync to iCloud Keychain
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            logger.error("Failed to save to keychain: \(status)")
            throw KeychainError.saveFailed(status)
        }

        logger.info("Successfully saved item to keychain: \(key)")
    }

    // MARK: - Load
    /// Loads a string value from the keychain
    func loadString(forKey key: String) throws -> String? {
        guard let data = try load(forKey: key) else {
            return nil
        }

        guard let string = String(data: data, encoding: .utf8) else {
            throw KeychainError.invalidData
        }

        return string
    }

    /// Loads data from the keychain
    func load(forKey key: String) throws -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecItemNotFound {
            return nil
        }

        guard status == errSecSuccess else {
            logger.error("Failed to load from keychain: \(status)")
            throw KeychainError.loadFailed(status)
        }

        guard let data = result as? Data else {
            throw KeychainError.invalidData
        }

        logger.info("Successfully loaded item from keychain: \(key)")
        return data
    }

    // MARK: - Delete
    /// Deletes an item from the keychain
    func delete(forKey key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            logger.error("Failed to delete from keychain: \(status)")
            throw KeychainError.deleteFailed(status)
        }

        logger.info("Successfully deleted item from keychain: \(key)")
    }

    // MARK: - Check Existence
    /// Checks if a key exists in the keychain
    func exists(forKey key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: false
        ]

        let status = SecItemCopyMatching(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    // MARK: - Clear All
    /// Deletes all items saved by this app (use with caution!)
    func clearAll() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            logger.error("Failed to clear keychain: \(status)")
            throw KeychainError.deleteFailed(status)
        }

        logger.warning("Cleared all keychain items")
    }
}

// MARK: - Keychain Keys
/// Standard keychain keys used throughout the app
extension KeychainManager {
    enum Keys {
        static let plaidAccessToken = "plaid_access_token_"
        static let encryptionKey = "encryption_key"
        static let userPin = "user_pin"
    }
}
