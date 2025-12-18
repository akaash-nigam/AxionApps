import Foundation
import CoreData
import CloudKit

class DataPersistenceManager {
    static let shared = DataPersistenceManager()

    // MARK: - CoreData Stack
    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "SpatialMusicStudio")

        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }

        // Enable automatic merging
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        return container
    }()

    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    private init() {}

    // MARK: - Composition Management

    func saveComposition(_ composition: Composition) async throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(composition)

        // Save to file system
        let fileURL = compositionFileURL(for: composition.id)
        try data.write(to: fileURL)

        // Sync to CloudKit
        if FeatureFlags.enableCloudSync {
            try await syncToCloud(composition)
        }
    }

    func loadComposition(_ id: UUID) async throws -> Composition {
        let fileURL = compositionFileURL(for: id)
        let data = try Data(contentsOf: fileURL)

        let decoder = JSONDecoder()
        return try decoder.decode(Composition.self, from: data)
    }

    func loadCompositions() async throws -> [Composition] {
        let compositionsDirectory = compositionsDirectoryURL()

        let fileManager = FileManager.default
        let fileURLs = try fileManager.contentsOfDirectory(
            at: compositionsDirectory,
            includingPropertiesForKeys: [.creationDateKey],
            options: [.skipsHiddenFiles]
        )

        var compositions: [Composition] = []

        for fileURL in fileURLs where fileURL.pathExtension == "json" {
            do {
                let data = try Data(contentsOf: fileURL)
                let composition = try JSONDecoder().decode(Composition.self, from: data)
                compositions.append(composition)
            } catch {
                print("Failed to load composition at \(fileURL): \(error)")
            }
        }

        return compositions.sorted { $0.modified > $1.modified }
    }

    func deleteComposition(_ id: UUID) async throws {
        let fileURL = compositionFileURL(for: id)
        try FileManager.default.removeItem(at: fileURL)

        // Delete from CloudKit
        if FeatureFlags.enableCloudSync {
            try await deleteFromCloud(id)
        }
    }

    // MARK: - User Progress

    func saveUserProgress(_ progress: UserProgress) async throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(progress)

        let fileURL = userProgressFileURL()
        try data.write(to: fileURL)
    }

    func loadUserProgress() async throws -> UserProgress? {
        let fileURL = userProgressFileURL()

        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }

        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        return try decoder.decode(UserProgress.self, from: data)
    }

    // MARK: - CloudKit Sync

    private func syncToCloud(_ composition: Composition) async throws {
        let container = CKContainer.default()
        let privateDB = container.privateCloudDatabase

        // Create CKRecord
        let record = CKRecord(recordType: "Composition")
        record["title"] = composition.title as NSString
        record["tempo"] = composition.tempo as NSNumber
        record["created"] = composition.created as NSDate
        record["modified"] = composition.modified as NSDate

        // Encode composition data
        let encoder = JSONEncoder()
        let data = try encoder.encode(composition)
        record["data"] = data as NSData

        // Save to CloudKit
        try await privateDB.save(record)
    }

    private func deleteFromCloud(_ id: UUID) async throws {
        let container = CKContainer.default()
        let privateDB = container.privateCloudDatabase

        let recordID = CKRecord.ID(recordName: id.uuidString)
        try await privateDB.deleteRecord(withID: recordID)
    }

    // MARK: - File URLs

    private func compositionsDirectoryURL() -> URL {
        let documentsURL = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]

        let compositionsURL = documentsURL.appendingPathComponent("Compositions")

        // Create directory if it doesn't exist
        try? FileManager.default.createDirectory(
            at: compositionsURL,
            withIntermediateDirectories: true
        )

        return compositionsURL
    }

    private func compositionFileURL(for id: UUID) -> URL {
        compositionsDirectoryURL()
            .appendingPathComponent(id.uuidString)
            .appendingPathExtension("json")
    }

    private func userProgressFileURL() -> URL {
        let documentsURL = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]

        return documentsURL
            .appendingPathComponent("UserProgress")
            .appendingPathExtension("json")
    }
}
