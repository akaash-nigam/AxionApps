//
//  SaveGameManager.swift
//  Mystery Investigation
//
//  Manages save/load functionality and cloud sync
//

import Foundation

class SaveGameManager {
    // MARK: - File URLs
    private let fileManager = FileManager.default
    private let documentsDirectory: URL
    private let playerProgressFile = "player_progress.json"
    private let settingsFile = "settings.json"
    private let caseProgressPrefix = "case_progress_"

    // MARK: - Initialization
    init() {
        documentsDirectory = fileManager.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!
    }

    // MARK: - Player Progress
    func savePlayerProgress(_ progress: PlayerProgress) {
        let url = documentsDirectory.appendingPathComponent(playerProgressFile)
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(progress)
            try data.write(to: url)
            print("Player progress saved")
        } catch {
            print("Failed to save player progress: \(error)")
        }
    }

    func loadPlayerProgress() -> PlayerProgress? {
        let url = documentsDirectory.appendingPathComponent(playerProgressFile)
        guard fileManager.fileExists(atPath: url.path) else {
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let progress = try decoder.decode(PlayerProgress.self, from: data)
            print("Player progress loaded")
            return progress
        } catch {
            print("Failed to load player progress: \(error)")
            return nil
        }
    }

    // MARK: - Settings
    func saveSettings(_ settings: GameSettings) {
        let url = documentsDirectory.appendingPathComponent(settingsFile)
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(settings)
            try data.write(to: url)
            print("Settings saved")
        } catch {
            print("Failed to save settings: \(error)")
        }
    }

    func loadSettings() -> GameSettings? {
        let url = documentsDirectory.appendingPathComponent(settingsFile)
        guard fileManager.fileExists(atPath: url.path) else {
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let settings = try decoder.decode(GameSettings.self, from: data)
            print("Settings loaded")
            return settings
        } catch {
            print("Failed to load settings: \(error)")
            return nil
        }
    }

    // MARK: - Case Progress
    func saveCaseProgress(_ progress: InvestigationProgress) {
        let filename = "\(caseProgressPrefix)\(progress.caseID.uuidString).json"
        let url = documentsDirectory.appendingPathComponent(filename)

        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(progress)
            try data.write(to: url)
            print("Case progress saved for case: \(progress.caseID)")
        } catch {
            print("Failed to save case progress: \(error)")
        }
    }

    func loadCaseProgress(caseID: UUID) -> InvestigationProgress? {
        let filename = "\(caseProgressPrefix)\(caseID.uuidString).json"
        let url = documentsDirectory.appendingPathComponent(filename)

        guard fileManager.fileExists(atPath: url.path) else {
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let progress = try decoder.decode(InvestigationProgress.self, from: data)
            print("Case progress loaded for case: \(caseID)")
            return progress
        } catch {
            print("Failed to load case progress: \(error)")
            return nil
        }
    }

    func deleteCaseProgress(caseID: UUID) {
        let filename = "\(caseProgressPrefix)\(caseID.uuidString).json"
        let url = documentsDirectory.appendingPathComponent(filename)

        if fileManager.fileExists(atPath: url.path) {
            try? fileManager.removeItem(at: url)
            print("Case progress deleted for case: \(caseID)")
        }
    }

    // MARK: - Cloud Sync (Future Implementation)
    func syncToiCloud() async {
        // TODO: Implement iCloud sync using CloudKit
        // Sync player progress, settings, and case progress
    }

    func syncFromiCloud() async {
        // TODO: Implement iCloud sync download
    }

    // MARK: - Data Management
    func deleteAllData() {
        // Delete all save files
        let urls = [
            documentsDirectory.appendingPathComponent(playerProgressFile),
            documentsDirectory.appendingPathComponent(settingsFile)
        ]

        for url in urls {
            try? fileManager.removeItem(at: url)
        }

        // Delete all case progress files
        if let files = try? fileManager.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil) {
            for file in files where file.lastPathComponent.hasPrefix(caseProgressPrefix) {
                try? fileManager.removeItem(at: file)
            }
        }

        print("All save data deleted")
    }
}
