import Foundation
import Combine

/// Central persistence manager coordinating local storage and cloud sync
actor PersistenceManager {

    // MARK: - Types

    enum PersistenceError: Error, LocalizedError {
        case saveFailed(String)
        case loadFailed(String)
        case deleteFailed(String)
        case syncFailed(String)
        case notFound
        case invalidData

        var errorDescription: String? {
            switch self {
            case .saveFailed(let detail):
                return "Failed to save: \(detail)"
            case .loadFailed(let detail):
                return "Failed to load: \(detail)"
            case .deleteFailed(let detail):
                return "Failed to delete: \(detail)"
            case .syncFailed(let detail):
                return "Sync failed: \(detail)"
            case .notFound:
                return "Data not found"
            case .invalidData:
                return "Invalid or corrupted data"
            }
        }
    }

    // MARK: - Private Properties

    private let localStorage: LocalStorage
    private let cloudSync: CloudKitSync?
    private let sessionRepository: SessionRepository
    private let progressRepository: ProgressRepository

    private var syncEnabled: Bool = true
    private var pendingSyncOperations: Set<String> = []

    // MARK: - Initialization

    init(
        localStorage: LocalStorage = LocalStorage(),
        cloudSync: CloudKitSync? = CloudKitSync(),
        sessionRepository: SessionRepository = SessionRepository(),
        progressRepository: ProgressRepository = ProgressRepository()
    ) {
        self.localStorage = localStorage
        self.cloudSync = cloudSync
        self.sessionRepository = sessionRepository
        self.progressRepository = progressRepository
    }

    // MARK: - User Profile

    func saveProfile(_ profile: UserProfile) async throws {
        do {
            // Save locally
            try await localStorage.save(profile, key: "profile_\(profile.id.uuidString)")

            // Sync to cloud if enabled
            if syncEnabled, let cloudSync = cloudSync {
                pendingSyncOperations.insert("profile_\(profile.id.uuidString)")
                try await cloudSync.syncProfile(profile)
                pendingSyncOperations.remove("profile_\(profile.id.uuidString)")
            }

        } catch {
            throw PersistenceError.saveFailed("Profile: \(error.localizedDescription)")
        }
    }

    func loadProfile(for userID: UUID) async throws -> UserProfile {
        do {
            // Try local first
            if let profile: UserProfile = try? await localStorage.load(key: "profile_\(userID.uuidString)") {
                return profile
            }

            // Try cloud if local not found
            if let cloudSync = cloudSync,
               let profile = try? await cloudSync.fetchProfile(userID: userID) {
                // Cache locally
                try? await localStorage.save(profile, key: "profile_\(userID.uuidString)")
                return profile
            }

            throw PersistenceError.notFound

        } catch {
            throw PersistenceError.loadFailed("Profile: \(error.localizedDescription)")
        }
    }

    // MARK: - User Progress

    func saveProgress(_ progress: UserProgress) async throws {
        do {
            try await progressRepository.save(progress)

            if syncEnabled, let cloudSync = cloudSync {
                pendingSyncOperations.insert("progress_\(progress.userID.uuidString)")
                try await cloudSync.syncProgress(progress)
                pendingSyncOperations.remove("progress_\(progress.userID.uuidString)")
            }

        } catch {
            throw PersistenceError.saveFailed("Progress: \(error.localizedDescription)")
        }
    }

    func loadProgress(for userID: UUID) async throws -> UserProgress {
        do {
            return try await progressRepository.load(userID: userID)
        } catch {
            throw PersistenceError.loadFailed("Progress: \(error.localizedDescription)")
        }
    }

    // MARK: - Meditation Sessions

    func saveSession(_ session: MeditationSession) async throws {
        do {
            try await sessionRepository.save(session)

            if syncEnabled, let cloudSync = cloudSync {
                pendingSyncOperations.insert("session_\(session.id.uuidString)")
                try await cloudSync.syncSession(session)
                pendingSyncOperations.remove("session_\(session.id.uuidString)")
            }

        } catch {
            throw PersistenceError.saveFailed("Session: \(error.localizedDescription)")
        }
    }

    func loadSessions(for userID: UUID, limit: Int? = nil) async throws -> [MeditationSession] {
        do {
            return try await sessionRepository.loadAll(userID: userID, limit: limit)
        } catch {
            throw PersistenceError.loadFailed("Sessions: \(error.localizedDescription)")
        }
    }

    func loadSession(id: UUID) async throws -> MeditationSession {
        do {
            return try await sessionRepository.load(sessionID: id)
        } catch {
            throw PersistenceError.loadFailed("Session: \(error.localizedDescription)")
        }
    }

    func deleteSession(id: UUID) async throws {
        do {
            try await sessionRepository.delete(sessionID: id)

            if let cloudSync = cloudSync {
                try? await cloudSync.deleteSession(id: id)
            }

        } catch {
            throw PersistenceError.deleteFailed("Session: \(error.localizedDescription)")
        }
    }

    // MARK: - Batch Operations

    func saveSessions(_ sessions: [MeditationSession]) async throws {
        for session in sessions {
            try await saveSession(session)
        }
    }

    func loadRecentSessions(for userID: UUID, days: Int = 30) async throws -> [MeditationSession] {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date())!

        let allSessions = try await loadSessions(for: userID)
        return allSessions.filter { $0.startTime >= cutoffDate }
    }

    // MARK: - Sync Management

    func enableSync(_ enabled: Bool) {
        syncEnabled = enabled
    }

    func forceSyncAll(for userID: UUID) async throws {
        guard let cloudSync = cloudSync else {
            throw PersistenceError.syncFailed("Cloud sync not available")
        }

        do {
            // Sync profile
            if let profile = try? await loadProfile(for: userID) {
                try await cloudSync.syncProfile(profile)
            }

            // Sync progress
            if let progress = try? await loadProgress(for: userID) {
                try await cloudSync.syncProgress(progress)
            }

            // Sync all sessions
            let sessions = try await loadSessions(for: userID)
            for session in sessions {
                try await cloudSync.syncSession(session)
            }

        } catch {
            throw PersistenceError.syncFailed(error.localizedDescription)
        }
    }

    func hasPendingSync() -> Bool {
        return !pendingSyncOperations.isEmpty
    }

    func getPendingSyncCount() -> Int {
        return pendingSyncOperations.count
    }

    // MARK: - Data Export

    func exportAllData(for userID: UUID) async throws -> Data {
        struct ExportData: Codable {
            let profile: UserProfile
            let progress: UserProgress
            let sessions: [MeditationSession]
            let exportDate: Date
        }

        do {
            let profile = try await loadProfile(for: userID)
            let progress = try await loadProgress(for: userID)
            let sessions = try await loadSessions(for: userID)

            let exportData = ExportData(
                profile: profile,
                progress: progress,
                sessions: sessions,
                exportDate: Date()
            )

            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

            return try encoder.encode(exportData)

        } catch {
            throw PersistenceError.saveFailed("Export: \(error.localizedDescription)")
        }
    }

    // MARK: - Data Import

    func importData(_ data: Data, for userID: UUID) async throws {
        struct ImportData: Codable {
            let profile: UserProfile
            let progress: UserProgress
            let sessions: [MeditationSession]
            let exportDate: Date
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            let importData = try decoder.decode(ImportData.self, from: data)

            // Verify user ID matches
            guard importData.profile.id == userID else {
                throw PersistenceError.invalidData
            }

            // Import data
            try await saveProfile(importData.profile)
            try await saveProgress(importData.progress)
            try await saveSessions(importData.sessions)

        } catch {
            throw PersistenceError.loadFailed("Import: \(error.localizedDescription)")
        }
    }

    // MARK: - Data Deletion

    func deleteAllData(for userID: UUID) async throws {
        do {
            // Delete sessions
            let sessions = try await loadSessions(for: userID)
            for session in sessions {
                try await deleteSession(id: session.id)
            }

            // Delete progress
            try await progressRepository.delete(userID: userID)

            // Delete profile
            try await localStorage.delete(key: "profile_\(userID.uuidString)")

            // Delete from cloud
            if let cloudSync = cloudSync {
                try? await cloudSync.deleteAllData(for: userID)
            }

        } catch {
            throw PersistenceError.deleteFailed("All data: \(error.localizedDescription)")
        }
    }

    // MARK: - Statistics

    func getStorageSize(for userID: UUID) async throws -> Int64 {
        // Estimate storage size in bytes
        let profile = try? await loadProfile(for: userID)
        let progress = try? await loadProgress(for: userID)
        let sessions = try? await loadSessions(for: userID)

        var totalSize: Int64 = 0

        if let profile = profile {
            let data = try? JSONEncoder().encode(profile)
            totalSize += Int64(data?.count ?? 0)
        }

        if let progress = progress {
            let data = try? JSONEncoder().encode(progress)
            totalSize += Int64(data?.count ?? 0)
        }

        if let sessions = sessions {
            for session in sessions {
                let data = try? JSONEncoder().encode(session)
                totalSize += Int64(data?.count ?? 0)
            }
        }

        return totalSize
    }
}
