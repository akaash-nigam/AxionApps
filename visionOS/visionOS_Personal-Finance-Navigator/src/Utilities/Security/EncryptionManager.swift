// EncryptionManager.swift
// Personal Finance Navigator
// AES-256 encryption for sensitive data

import Foundation
import CryptoKit
import OSLog

private let logger = Logger(subsystem: "com.pfn", category: "encryption")

/// Manages encryption and decryption of sensitive data using AES-256-GCM
actor EncryptionManager {
    // MARK: - Errors
    enum EncryptionError: LocalizedError {
        case keyNotAvailable
        case encryptionFailed
        case decryptionFailed
        case invalidData

        var errorDescription: String? {
            switch self {
            case .keyNotAvailable:
                return "Encryption key not available"
            case .encryptionFailed:
                return "Failed to encrypt data"
            case .decryptionFailed:
                return "Failed to decrypt data"
            case .invalidData:
                return "Invalid data format"
            }
        }
    }

    // MARK: - Properties
    private var symmetricKey: SymmetricKey?
    private let keychainManager = KeychainManager()

    // MARK: - Init
    init() {
        Task {
            do {
                self.symmetricKey = try await loadOrGenerateKey()
            } catch {
                logger.error("Failed to initialize encryption key: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Encrypt
    /// Encrypts a string using AES-256-GCM
    func encrypt(_ plaintext: String) throws -> Data {
        guard let key = symmetricKey else {
            throw EncryptionError.keyNotAvailable
        }

        guard let data = plaintext.data(using: .utf8) else {
            throw EncryptionError.invalidData
        }

        return try encrypt(data, using: key)
    }

    /// Encrypts data using AES-256-GCM
    func encrypt(_ data: Data, using key: SymmetricKey) throws -> Data {
        do {
            let sealedBox = try AES.GCM.seal(data, using: key)

            guard let combined = sealedBox.combined else {
                throw EncryptionError.encryptionFailed
            }

            logger.debug("Successfully encrypted data")
            return combined
        } catch {
            logger.error("Encryption failed: \(error.localizedDescription)")
            throw EncryptionError.encryptionFailed
        }
    }

    // MARK: - Decrypt
    /// Decrypts data back to a string
    func decrypt(_ ciphertext: Data) throws -> String {
        guard let key = symmetricKey else {
            throw EncryptionError.keyNotAvailable
        }

        let decryptedData = try decrypt(ciphertext, using: key)

        guard let plaintext = String(data: decryptedData, encoding: .utf8) else {
            throw EncryptionError.invalidData
        }

        return plaintext
    }

    /// Decrypts data using AES-256-GCM
    func decrypt(_ ciphertext: Data, using key: SymmetricKey) throws -> Data {
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: ciphertext)
            let decryptedData = try AES.GCM.open(sealedBox, using: key)

            logger.debug("Successfully decrypted data")
            return decryptedData
        } catch {
            logger.error("Decryption failed: \(error.localizedDescription)")
            throw EncryptionError.decryptionFailed
        }
    }

    // MARK: - Key Management
    /// Loads existing encryption key or generates a new one
    private func loadOrGenerateKey() async throws -> SymmetricKey {
        // Try to load existing key from keychain
        if let existingKey = try await loadKeyFromKeychain() {
            logger.info("Loaded existing encryption key")
            return existingKey
        }

        // Generate new key
        let newKey = SymmetricKey(size: .bits256)
        try await saveKeyToKeychain(newKey)

        logger.info("Generated new encryption key")
        return newKey
    }

    /// Loads encryption key from keychain
    private func loadKeyFromKeychain() async throws -> SymmetricKey? {
        guard let keyData = try await keychainManager.load(
            forKey: KeychainManager.Keys.encryptionKey
        ) else {
            return nil
        }

        return SymmetricKey(data: keyData)
    }

    /// Saves encryption key to keychain
    private func saveKeyToKeychain(_ key: SymmetricKey) async throws {
        let keyData = key.withUnsafeBytes { Data($0) }
        try await keychainManager.save(keyData, forKey: KeychainManager.Keys.encryptionKey)
    }

    // MARK: - Reset
    /// Deletes the encryption key (use with extreme caution!)
    func resetEncryptionKey() async throws {
        try await keychainManager.delete(forKey: KeychainManager.Keys.encryptionKey)
        self.symmetricKey = try await loadOrGenerateKey()

        logger.warning("Encryption key reset")
    }
}

// MARK: - Secure String
/// A string wrapper that zeros memory when deallocated
final class SecureString {
    private var buffer: UnsafeMutableBufferPointer<UInt8>
    private(set) var count: Int

    init(_ string: String) {
        let utf8 = Array(string.utf8)
        self.count = utf8.count

        self.buffer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: count)
        _ = buffer.initialize(from: utf8)
    }

    var string: String? {
        String(bytes: buffer, encoding: .utf8)
    }

    deinit {
        // Zero out memory before deallocation
        buffer.baseAddress?.initialize(repeating: 0, count: count)
        buffer.deallocate()
    }
}

// MARK: - Hashing Utilities
extension EncryptionManager {
    /// Creates a SHA-256 hash of a string
    static func hash(_ string: String) -> String {
        let data = Data(string.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }

    /// Creates a SHA-256 hash of data
    static func hash(_ data: Data) -> String {
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}
