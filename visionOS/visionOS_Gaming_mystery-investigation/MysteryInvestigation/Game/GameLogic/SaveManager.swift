import Foundation
import CloudKit

/// Manages game progress saving and loading
@MainActor
class SaveManager {
    // MARK: - Properties

    private let fileManager = FileManager.default
    private let saveDirectory: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    // MARK: - Initialization

    init() {
        // Get documents directory
        guard let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("Could not access documents directory")
        }

        saveDirectory = documentsPath.appendingPathComponent("MysteryInvestigation/Saves")

        // Create saves directory if it doesn't exist
        try? fileManager.createDirectory(at: saveDirectory, withIntermediateDirectories: true)

        // Configure JSON encoder/decoder
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    // MARK: - Player Progress

    func savePlayerProgress(_ progress: PlayerProgress) async throws {
        let fileURL = saveDirectory.appendingPathComponent("player_progress.json")

        let data = try encoder.encode(progress)
        try data.write(to: fileURL)

        print("Player progress saved")

        // Also sync to iCloud
        #if !targetEnvironment(simulator)
        await syncToiCloud(progress)
        #endif
    }

    func loadPlayerProgress() async throws -> PlayerProgress? {
        let fileURL = saveDirectory.appendingPathComponent("player_progress.json")

        guard fileManager.fileExists(atPath: fileURL.path) else {
            // Try loading from iCloud
            #if !targetEnvironment(simulator)
            return await loadFromiCloud()
            #else
            return nil
            #endif
        }

        let data = try Data(contentsOf: fileURL)
        return try decoder.decode(PlayerProgress.self, from: data)
    }

    // MARK: - Investigation State

    func saveInvestigationProgress(_ state: InvestigationState) async throws {
        guard let currentCase = state.currentCase else {
            throw SaveError.noActiveCase
        }

        let fileURL = saveDirectory.appendingPathComponent("investigation_\(currentCase.id.uuidString).json")

        let data = try encoder.encode(state)
        try data.write(to: fileURL)

        print("Investigation state saved for case: \(currentCase.title)")
    }

    func loadInvestigationProgress(caseID: UUID) async throws -> InvestigationState? {
        let fileURL = saveDirectory.appendingPathComponent("investigation_\(caseID.uuidString).json")

        guard fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }

        let data = try Data(contentsOf: fileURL)
        return try decoder.decode(InvestigationState.self, from: data)
    }

    func deleteInvestigationProgress(caseID: UUID) throws {
        let fileURL = saveDirectory.appendingPathComponent("investigation_\(caseID.uuidString).json")

        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
            print("Investigation state deleted for case: \(caseID)")
        }
    }

    // MARK: - Spatial Anchors

    func saveSpatialAnchors(_ anchors: [UUID: Data]) throws {
        let fileURL = saveDirectory.appendingPathComponent("spatial_anchors.json")

        let data = try encoder.encode(anchors)
        try data.write(to: fileURL)

        print("Spatial anchors saved")
    }

    func loadSpatialAnchors() throws -> [UUID: Data]? {
        let fileURL = saveDirectory.appendingPathComponent("spatial_anchors.json")

        guard fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }

        let data = try Data(contentsOf: fileURL)
        return try decoder.decode([UUID: Data].self, from: data)
    }

    // MARK: - Case Library

    func saveCustomCase(_ case: Case) async throws {
        let casesDirectory = saveDirectory.appendingPathComponent("CustomCases")
        try? fileManager.createDirectory(at: casesDirectory, withIntermediateDirectories: true)

        let fileURL = casesDirectory.appendingPathComponent("\(case.id.uuidString).json")

        let data = try encoder.encode(case)
        try data.write(to: fileURL)

        print("Custom case saved: \(case.title)")
    }

    func loadCustomCases() async throws -> [Case] {
        let casesDirectory = saveDirectory.appendingPathComponent("CustomCases")

        guard fileManager.fileExists(atPath: casesDirectory.path) else {
            return []
        }

        let fileURLs = try fileManager.contentsOfDirectory(
            at: casesDirectory,
            includingPropertiesForKeys: nil
        ).filter { $0.pathExtension == "json" }

        var cases: [Case] = []

        for fileURL in fileURLs {
            do {
                let data = try Data(contentsOf: fileURL)
                let case = try decoder.decode(Case.self, from: data)
                cases.append(case)
            } catch {
                print("Failed to load case from \(fileURL): \(error)")
            }
        }

        return cases
    }

    // MARK: - iCloud Sync

    #if !targetEnvironment(simulator)
    private func syncToiCloud(_ progress: PlayerProgress) async {
        let container = CKContainer.default()
        let database = container.privateCloudDatabase

        let record = CKRecord(recordType: "PlayerProgress")

        // Convert progress to data
        if let data = try? encoder.encode(progress) {
            record["progressData"] = data as CKRecordValue
            record["lastUpdated"] = Date() as CKRecordValue

            do {
                _ = try await database.save(record)
                print("Synced to iCloud")
            } catch {
                print("iCloud sync failed: \(error)")
            }
        }
    }

    private func loadFromiCloud() async -> PlayerProgress? {
        let container = CKContainer.default()
        let database = container.privateCloudDatabase

        let query = CKQuery(recordType: "PlayerProgress", predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "lastUpdated", ascending: false)]

        do {
            let results = try await database.records(matching: query, resultsLimit: 1)

            if let (_, result) = results.matchResults.first,
               let record = try? result.get(),
               let data = record["progressData"] as? Data {
                return try decoder.decode(PlayerProgress.self, from: data)
            }
        } catch {
            print("Failed to load from iCloud: \(error)")
        }

        return nil
    }
    #endif

    // MARK: - Utility

    func getAllSavedInvestigations() -> [UUID] {
        do {
            let fileURLs = try fileManager.contentsOfDirectory(
                at: saveDirectory,
                includingPropertiesForKeys: nil
            )

            return fileURLs
                .filter { $0.lastPathComponent.hasPrefix("investigation_") }
                .compactMap { url in
                    let filename = url.deletingPathExtension().lastPathComponent
                    let uuidString = filename.replacingOccurrences(of: "investigation_", with: "")
                    return UUID(uuidString: uuidString)
                }
        } catch {
            print("Failed to get saved investigations: \(error)")
            return []
        }
    }

    func clearAllData() throws {
        let contents = try fileManager.contentsOfDirectory(
            at: saveDirectory,
            includingPropertiesForKeys: nil
        )

        for fileURL in contents {
            try fileManager.removeItem(at: fileURL)
        }

        print("All save data cleared")
    }
}

// MARK: - Errors

enum SaveError: Error {
    case noActiveCase
    case encodingFailed
    case decodingFailed
    case fileNotFound
    case iCloudUnavailable
}
