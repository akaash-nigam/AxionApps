//
//  PersistenceService.swift
//  MilitaryDefenseTraining
//
//  Created by Claude Code
//

import Foundation

actor PersistenceService {
    private let fileManager = FileManager.default
    private lazy var documentsDirectory: URL = {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }()

    private lazy var cacheDirectory: URL = {
        fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    }()

    // MARK: - File Storage

    func saveFile(_ data: Data, name: String, directory: StorageDirectory = .documents) throws -> URL {
        let baseDir = directory == .documents ? documentsDirectory : cacheDirectory
        let fileURL = baseDir.appendingPathComponent(name)

        try data.write(to: fileURL)
        return fileURL
    }

    func loadFile(name: String, directory: StorageDirectory = .documents) throws -> Data {
        let baseDir = directory == .documents ? documentsDirectory : cacheDirectory
        let fileURL = baseDir.appendingPathComponent(name)

        return try Data(contentsOf: fileURL)
    }

    func deleteFile(name: String, directory: StorageDirectory = .documents) throws {
        let baseDir = directory == .documents ? documentsDirectory : cacheDirectory
        let fileURL = baseDir.appendingPathComponent(name)

        try fileManager.removeItem(at: fileURL)
    }

    func fileExists(name: String, directory: StorageDirectory = .documents) -> Bool {
        let baseDir = directory == .documents ? documentsDirectory : cacheDirectory
        let fileURL = baseDir.appendingPathComponent(name)

        return fileManager.fileExists(atPath: fileURL.path)
    }

    // MARK: - Scenario Caching

    func cacheScenario(_ scenario: Scenario) async throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(scenario)

        let filename = "scenario_\(scenario.id.uuidString).json"
        _ = try saveFile(data, name: filename, directory: .cache)
    }

    func loadCachedScenario(id: UUID) async throws -> Scenario {
        let filename = "scenario_\(id.uuidString).json"
        let data = try loadFile(name: filename, directory: .cache)

        let decoder = JSONDecoder()
        return try decoder.decode(Scenario.self, from: data)
    }

    func getCachedScenarios() async throws -> [Scenario] {
        let cacheURL = cacheDirectory
        let files = try fileManager.contentsOfDirectory(at: cacheURL, includingPropertiesForKeys: nil)

        var scenarios: [Scenario] = []
        let decoder = JSONDecoder()

        for file in files where file.lastPathComponent.hasPrefix("scenario_") {
            let data = try Data(contentsOf: file)
            let scenario = try decoder.decode(Scenario.self, from: data)
            scenarios.append(scenario)
        }

        return scenarios
    }

    // MARK: - Asset Management

    func downloadAsset(from url: URL, name: String) async throws -> URL {
        let (tempURL, _) = try await URLSession.shared.download(from: url)

        let destinationURL = cacheDirectory.appendingPathComponent("Assets").appendingPathComponent(name)

        // Create Assets directory if needed
        let assetsDir = cacheDirectory.appendingPathComponent("Assets")
        if !fileManager.fileExists(atPath: assetsDir.path) {
            try fileManager.createDirectory(at: assetsDir, withIntermediateDirectories: true)
        }

        // Move downloaded file
        try fileManager.moveItem(at: tempURL, to: destinationURL)

        return destinationURL
    }

    func getAssetURL(name: String) -> URL {
        return cacheDirectory.appendingPathComponent("Assets").appendingPathComponent(name)
    }

    // MARK: - Cache Management

    func clearCache() throws {
        let cacheURL = cacheDirectory
        let files = try fileManager.contentsOfDirectory(at: cacheURL, includingPropertiesForKeys: nil)

        for file in files {
            try fileManager.removeItem(at: file)
        }
    }

    func getCacheSize() throws -> UInt64 {
        let cacheURL = cacheDirectory
        let files = try fileManager.contentsOfDirectory(at: cacheURL, includingPropertiesForKeys: [.fileSizeKey])

        var totalSize: UInt64 = 0
        for file in files {
            let resourceValues = try file.resourceValues(forKeys: [.fileSizeKey])
            totalSize += UInt64(resourceValues.fileSize ?? 0)
        }

        return totalSize
    }

    // MARK: - Encrypted Storage

    func saveEncrypted(_ data: Data, name: String, key: SymmetricKey) throws -> URL {
        let encrypted = try encryptData(data, with: key)
        return try saveFile(encrypted, name: name, directory: .documents)
    }

    func loadEncrypted(name: String, key: SymmetricKey) throws -> Data {
        let encryptedData = try loadFile(name: name, directory: .documents)
        return try decryptData(encryptedData, with: key)
    }

    private func encryptData(_ data: Data, with key: SymmetricKey) throws -> Data {
        // Simplified - in real implementation would use CryptoKit
        // For now, just return the data (would use AES-GCM in production)
        return data
    }

    private func decryptData(_ data: Data, with key: SymmetricKey) throws -> Data {
        // Simplified - in real implementation would use CryptoKit
        return data
    }

    // MARK: - Export

    func exportData(to url: URL, classification: ClassificationLevel) async throws {
        // Export training data with proper classification markings

        let exportData = ExportPackage(
            classification: classification,
            exportDate: Date(),
            files: []
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(exportData)

        try data.write(to: url)
    }
}

// MARK: - Supporting Types

enum StorageDirectory {
    case documents
    case cache
}

struct SymmetricKey {
    let data: Data

    init(size: KeySize) {
        // Generate random key
        var bytes = [UInt8](repeating: 0, count: size.bitCount / 8)
        _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        self.data = Data(bytes)
    }

    enum KeySize {
        case bits128
        case bits192
        case bits256

        var bitCount: Int {
            switch self {
            case .bits128: return 128
            case .bits192: return 192
            case .bits256: return 256
            }
        }
    }
}

struct ExportPackage: Codable {
    var classification: ClassificationLevel
    var exportDate: Date
    var files: [ExportFile]

    struct ExportFile: Codable {
        var name: String
        var path: String
        var size: Int
        var checksum: String
    }
}

enum PersistenceError: Error {
    case fileNotFound
    case encryptionFailed
    case decryptionFailed
    case invalidData
    case insufficientSpace

    var localizedDescription: String {
        switch self {
        case .fileNotFound: return "File not found"
        case .encryptionFailed: return "Failed to encrypt data"
        case .decryptionFailed: return "Failed to decrypt data"
        case .invalidData: return "Invalid data format"
        case .insufficientSpace: return "Insufficient storage space"
        }
    }
}
