import Foundation

/// Local file-based storage using JSON encoding
actor LocalStorage {

    // MARK: - Types

    enum StorageError: Error {
        case encodingFailed
        case decodingFailed
        case fileNotFound
        case writeError
        case readError
    }

    // MARK: - Private Properties

    private let fileManager = FileManager.default
    private let storageDirectory: URL

    // MARK: - Initialization

    init() {
        // Use app's documents directory
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.storageDirectory = documentsPath.appendingPathComponent("MeditationData", isDirectory: true)

        // Create directory if needed
        try? fileManager.createDirectory(at: storageDirectory, withIntermediateDirectories: true)
    }

    // MARK: - Save/Load Methods

    func save<T: Codable>(_ object: T, key: String) async throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted

        do {
            let data = try encoder.encode(object)
            let fileURL = storageDirectory.appendingPathComponent("\(key).json")

            try data.write(to: fileURL, options: [.atomic])

        } catch {
            throw StorageError.writeError
        }
    }

    func load<T: Codable>(key: String) async throws -> T {
        let fileURL = storageDirectory.appendingPathComponent("\(key).json")

        guard fileManager.fileExists(atPath: fileURL.path) else {
            throw StorageError.fileNotFound
        }

        do {
            let data = try Data(contentsOf: fileURL)

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            return try decoder.decode(T.self, from: data)

        } catch {
            throw StorageError.decodingFailed
        }
    }

    func delete(key: String) async throws {
        let fileURL = storageDirectory.appendingPathComponent("\(key).json")

        guard fileManager.fileExists(atPath: fileURL.path) else {
            throw StorageError.fileNotFound
        }

        try fileManager.removeItem(at: fileURL)
    }

    func exists(key: String) -> Bool {
        let fileURL = storageDirectory.appendingPathComponent("\(key).json")
        return fileManager.fileExists(atPath: fileURL.path)
    }

    // MARK: - Batch Operations

    func saveAll<T: Codable>(_ objects: [T], prefix: String) async throws {
        for (index, object) in objects.enumerated() {
            try await save(object, key: "\(prefix)_\(index)")
        }
    }

    func loadAll<T: Codable>(prefix: String) async throws -> [T] {
        let contents = try fileManager.contentsOfDirectory(
            at: storageDirectory,
            includingPropertiesForKeys: nil
        )

        let matchingFiles = contents.filter {
            $0.lastPathComponent.hasPrefix(prefix) && $0.pathExtension == "json"
        }

        var results: [T] = []

        for fileURL in matchingFiles {
            if let data = try? Data(contentsOf: fileURL),
               let decoded = try? JSONDecoder().decode(T.self, from: data) {
                results.append(decoded)
            }
        }

        return results
    }

    func deleteAll(prefix: String) async throws {
        let contents = try fileManager.contentsOfDirectory(
            at: storageDirectory,
            includingPropertiesForKeys: nil
        )

        let matchingFiles = contents.filter {
            $0.lastPathComponent.hasPrefix(prefix) && $0.pathExtension == "json"
        }

        for fileURL in matchingFiles {
            try? fileManager.removeItem(at: fileURL)
        }
    }

    // MARK: - Storage Info

    func getTotalSize() async -> Int64 {
        guard let contents = try? fileManager.contentsOfDirectory(
            at: storageDirectory,
            includingPropertiesForKeys: [.fileSizeKey]
        ) else {
            return 0
        }

        var totalSize: Int64 = 0

        for fileURL in contents {
            if let attributes = try? fileManager.attributesOfItem(atPath: fileURL.path),
               let fileSize = attributes[.size] as? Int64 {
                totalSize += fileSize
            }
        }

        return totalSize
    }

    func getFileCount() async -> Int {
        guard let contents = try? fileManager.contentsOfDirectory(
            at: storageDirectory,
            includingPropertiesForKeys: nil
        ) else {
            return 0
        }

        return contents.filter { $0.pathExtension == "json" }.count
    }

    func clearAll() async throws {
        try fileManager.removeItem(at: storageDirectory)
        try fileManager.createDirectory(at: storageDirectory, withIntermediateDirectories: true)
    }
}
