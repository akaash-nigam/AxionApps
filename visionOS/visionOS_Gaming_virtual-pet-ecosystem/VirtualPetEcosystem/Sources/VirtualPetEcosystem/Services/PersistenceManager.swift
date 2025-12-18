import Foundation

/// Manages persistence of pets to disk
public actor PersistenceManager {
    private let fileManager = FileManager.default
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    /// Directory where pet data is stored
    private var saveDirectory: URL {
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsDirectory.appendingPathComponent("VirtualPetEcosystem", isDirectory: true)
    }

    public init() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    /// Save a pet to disk
    /// - Parameter pet: The pet to save
    /// - Throws: PersistenceError if save fails
    public func save(_ pet: Pet) throws {
        try createSaveDirectoryIfNeeded()

        let fileURL = saveDirectory.appendingPathComponent("\(pet.id.uuidString).json")
        let data = try encoder.encode(pet)
        try data.write(to: fileURL, options: .atomic)
    }

    /// Save multiple pets to disk
    /// - Parameter pets: Array of pets to save
    /// - Throws: PersistenceError if save fails
    public func save(_ pets: [Pet]) throws {
        for pet in pets {
            try save(pet)
        }
    }

    /// Load a specific pet by ID
    /// - Parameter id: UUID of the pet to load
    /// - Returns: The loaded pet
    /// - Throws: PersistenceError if load fails or pet not found
    public func loadPet(id: UUID) throws -> Pet {
        let fileURL = saveDirectory.appendingPathComponent("\(id.uuidString).json")

        guard fileManager.fileExists(atPath: fileURL.path) else {
            throw PersistenceError.petNotFound(id)
        }

        let data = try Data(contentsOf: fileURL)
        let pet = try decoder.decode(Pet.self, from: data)

        return pet
    }

    /// Load all pets from disk
    /// - Returns: Array of all saved pets
    /// - Throws: PersistenceError if load fails
    public func loadAllPets() throws -> [Pet] {
        guard fileManager.fileExists(atPath: saveDirectory.path) else {
            return []
        }

        let files = try fileManager.contentsOfDirectory(
            at: saveDirectory,
            includingPropertiesForKeys: nil
        )

        let pets = try files.compactMap { url -> Pet? in
            guard url.pathExtension == "json" else { return nil }

            let data = try Data(contentsOf: url)
            return try decoder.decode(Pet.self, from: data)
        }

        return pets
    }

    /// Delete a pet from disk
    /// - Parameter id: UUID of the pet to delete
    /// - Throws: PersistenceError if deletion fails
    public func deletePet(id: UUID) throws {
        let fileURL = saveDirectory.appendingPathComponent("\(id.uuidString).json")

        guard fileManager.fileExists(atPath: fileURL.path) else {
            throw PersistenceError.petNotFound(id)
        }

        try fileManager.removeItem(at: fileURL)
    }

    /// Delete all pets from disk
    /// - Throws: PersistenceError if deletion fails
    public func deleteAllPets() throws {
        guard fileManager.fileExists(atPath: saveDirectory.path) else {
            return
        }

        let files = try fileManager.contentsOfDirectory(
            at: saveDirectory,
            includingPropertiesForKeys: nil
        )

        for file in files where file.pathExtension == "json" {
            try fileManager.removeItem(at: file)
        }
    }

    /// Check if a pet exists on disk
    /// - Parameter id: UUID of the pet to check
    /// - Returns: True if the pet exists
    public func petExists(id: UUID) -> Bool {
        let fileURL = saveDirectory.appendingPathComponent("\(id.uuidString).json")
        return fileManager.fileExists(atPath: fileURL.path)
    }

    /// Get count of saved pets
    /// - Returns: Number of pets saved to disk
    public func getSavedPetCount() throws -> Int {
        guard fileManager.fileExists(atPath: saveDirectory.path) else {
            return 0
        }

        let files = try fileManager.contentsOfDirectory(
            at: saveDirectory,
            includingPropertiesForKeys: nil
        )

        return files.filter { $0.pathExtension == "json" }.count
    }

    /// Create save directory if it doesn't exist
    private func createSaveDirectoryIfNeeded() throws {
        if !fileManager.fileExists(atPath: saveDirectory.path) {
            try fileManager.createDirectory(
                at: saveDirectory,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }
    }
}

/// Errors that can occur during persistence operations
public enum PersistenceError: Error, LocalizedError {
    case petNotFound(UUID)
    case saveDirectoryCreationFailed
    case encodingFailed
    case decodingFailed
    case fileSystemError(Error)

    public var errorDescription: String? {
        switch self {
        case .petNotFound(let id):
            return "Pet with ID \(id) not found"
        case .saveDirectoryCreationFailed:
            return "Failed to create save directory"
        case .encodingFailed:
            return "Failed to encode pet data"
        case .decodingFailed:
            return "Failed to decode pet data"
        case .fileSystemError(let error):
            return "File system error: \(error.localizedDescription)"
        }
    }
}
