//
//  SaveManager.swift
//  Science Lab Sandbox
//
//  Handles data persistence for progress and experiment sessions
//

import Foundation

actor SaveManager {

    // MARK: - File URLs

    private var progressURL: URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsPath.appendingPathComponent("player_progress.json")
    }

    private var experimentsDirectory: URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let experimentsPath = documentsPath.appendingPathComponent("Experiments")

        // Create directory if it doesn't exist
        try? FileManager.default.createDirectory(at: experimentsPath, withIntermediateDirectories: true)

        return experimentsPath
    }

    // MARK: - JSON Coders

    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    // MARK: - Progress Management

    func saveProgress(_ progress: PlayerProgress) async throws {
        let data = try encoder.encode(progress)
        try data.write(to: progressURL, options: .atomic)

        print("💾 Progress saved")
    }

    func loadProgress() async throws -> PlayerProgress {
        let data = try Data(contentsOf: progressURL)
        let progress = try decoder.decode(PlayerProgress.self, from: data)

        print("📂 Progress loaded")
        return progress
    }

    func deleteProgress() async throws {
        try FileManager.default.removeItem(at: progressURL)
        print("🗑️ Progress deleted")
    }

    // MARK: - Experiment Sessions

    func saveExperiment(_ session: ExperimentSession) async throws {
        let filename = "experiment_\(session.id.uuidString).json"
        let fileURL = experimentsDirectory.appendingPathComponent(filename)

        let data = try encoder.encode(session)
        try data.write(to: fileURL, options: .atomic)

        print("💾 Experiment session saved: \(session.experimentID)")
    }

    func loadExperiment(id: UUID) async throws -> ExperimentSession {
        let filename = "experiment_\(id.uuidString).json"
        let fileURL = experimentsDirectory.appendingPathComponent(filename)

        let data = try Data(contentsOf: fileURL)
        let session = try decoder.decode(ExperimentSession.self, from: data)

        return session
    }

    func loadAllExperiments() async throws -> [ExperimentSession] {
        let fileURLs = try FileManager.default.contentsOfDirectory(
            at: experimentsDirectory,
            includingPropertiesForKeys: nil
        )

        var sessions: [ExperimentSession] = []

        for fileURL in fileURLs where fileURL.pathExtension == "json" {
            do {
                let data = try Data(contentsOf: fileURL)
                let session = try decoder.decode(ExperimentSession.self, from: data)
                sessions.append(session)
            } catch {
                print("Error loading experiment from \(fileURL): \(error)")
            }
        }

        return sessions
    }

    func deleteExperiment(id: UUID) async throws {
        let filename = "experiment_\(id.uuidString).json"
        let fileURL = experimentsDirectory.appendingPathComponent(filename)

        try FileManager.default.removeItem(at: fileURL)
        print("🗑️ Experiment session deleted: \(id)")
    }

    // MARK: - Cloud Sync (Optional)

    func syncToCloud(_ progress: PlayerProgress) async throws {
        // CloudKit integration would go here
        // For now, this is a placeholder

        print("☁️ Cloud sync initiated (not implemented)")
    }

    func fetchFromCloud() async throws -> PlayerProgress? {
        // CloudKit fetch would go here
        // For now, this is a placeholder

        print("☁️ Cloud fetch initiated (not implemented)")
        return nil
    }

    // MARK: - Data Export

    func exportExperimentAsJSON(_ session: ExperimentSession) async throws -> Data {
        return try encoder.encode(session)
    }

    func exportProgressReport(_ progress: PlayerProgress) async throws -> String {
        // Generate a human-readable progress report
        var report = """
        Science Lab Sandbox - Progress Report
        =====================================

        Player ID: \(progress.id)
        Created: \(progress.createdDate)
        Last Modified: \(progress.lastModified)

        Statistics
        ----------
        Level: \(progress.currentLevel)
        Total XP: \(progress.totalXP)
        Experiments Completed: \(progress.totalExperiments)
        Total Lab Time: \(formatDuration(progress.totalLabTime))
        Safety Violations: \(progress.safetyViolations)

        Discipline Skill Levels
        ----------------------
        """

        for (discipline, skillLevel) in progress.skillLevels.sorted(by: { $0.key.rawValue < $1.key.rawValue }) {
            report += "\n\(discipline.displayName): \(skillLevel.name)"
        }

        report += "\n\nAchievements (\(progress.achievements.count))"
        report += "\n-------------"

        for achievement in progress.achievements.sorted(by: { $0.dateEarned ?? Date() > $1.dateEarned ?? Date() }) {
            report += "\n- \(achievement.name): \(achievement.description)"
            if let date = achievement.dateEarned {
                report += " (Earned: \(date))"
            }
        }

        return report
    }

    // MARK: - Helpers

    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    // MARK: - Storage Info

    func getStorageInfo() async -> StorageInfo {
        var totalSize: Int64 = 0
        var fileCount = 0

        // Calculate progress file size
        if let progressSize = try? FileManager.default.attributesOfItem(atPath: progressURL.path)[.size] as? Int64 {
            totalSize += progressSize
            fileCount += 1
        }

        // Calculate experiments directory size
        if let fileURLs = try? FileManager.default.contentsOfDirectory(at: experimentsDirectory, includingPropertiesForKeys: [.fileSizeKey]) {
            for fileURL in fileURLs {
                if let fileSize = try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                    totalSize += Int64(fileSize)
                    fileCount += 1
                }
            }
        }

        return StorageInfo(
            totalSizeBytes: totalSize,
            fileCount: fileCount
        )
    }
}

// MARK: - Storage Info

struct StorageInfo {
    let totalSizeBytes: Int64
    let fileCount: Int

    var totalSizeMB: Double {
        Double(totalSizeBytes) / 1_048_576.0  // Convert bytes to MB
    }

    var formattedSize: String {
        if totalSizeMB < 1.0 {
            return String(format: "%.2f KB", Double(totalSizeBytes) / 1024.0)
        } else {
            return String(format: "%.2f MB", totalSizeMB)
        }
    }
}
