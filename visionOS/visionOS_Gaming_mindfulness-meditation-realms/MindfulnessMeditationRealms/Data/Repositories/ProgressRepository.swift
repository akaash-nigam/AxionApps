import Foundation

/// Repository for user progress data access
actor ProgressRepository {

    // MARK: - Private Properties

    private let localStorage: LocalStorage
    private var cache: [UUID: UserProgress] = [:]

    // MARK: - Initialization

    init(localStorage: LocalStorage = LocalStorage()) {
        self.localStorage = localStorage
    }

    // MARK: - Save/Load Methods

    func save(_ progress: UserProgress) async throws {
        let key = "progress_\(progress.userID.uuidString)"
        try await localStorage.save(progress, key: key)

        // Update cache
        cache[progress.userID] = progress

        // Also save a timestamped snapshot for history
        try await saveSnapshot(progress)
    }

    func load(userID: UUID) async throws -> UserProgress {
        // Check cache first
        if let cached = cache[userID] {
            return cached
        }

        // Load from storage
        let key = "progress_\(userID.uuidString)"
        let progress: UserProgress = try await localStorage.load(key: key)

        // Update cache
        cache[userID] = progress

        return progress
    }

    // MARK: - Delete Methods

    func delete(userID: UUID) async throws {
        let key = "progress_\(userID.uuidString)"
        try await localStorage.delete(key: key)

        // Remove from cache
        cache.removeValue(forKey: userID)

        // Also delete snapshots
        try await deleteSnapshots(userID: userID)
    }

    // MARK: - Progress History (Snapshots)

    private func saveSnapshot(_ progress: UserProgress) async throws {
        let key = "progress_snapshot_\(progress.userID.uuidString)_\(Date().timeIntervalSince1970)"
        try await localStorage.save(progress, key: key)
    }

    func loadSnapshots(userID: UUID, limit: Int = 30) async throws -> [UserProgress] {
        let prefix = "progress_snapshot_\(userID.uuidString)"
        let snapshots: [UserProgress] = try await localStorage.loadAll(prefix: prefix)

        // Sort by date (newest first) and limit
        return Array(snapshots.suffix(limit))
    }

    private func deleteSnapshots(userID: UUID) async throws {
        let prefix = "progress_snapshot_\(userID.uuidString)"
        try await localStorage.deleteAll(prefix: prefix)
    }

    // MARK: - Statistics Queries

    func getLevel(userID: UUID) async -> Int {
        guard let progress = try? await load(userID: userID) else {
            return 1
        }
        return progress.level
    }

    func getExperiencePoints(userID: UUID) async -> Int {
        guard let progress = try? await load(userID: userID) else {
            return 0
        }
        return progress.experiencePoints
    }

    func getCurrentStreak(userID: UUID) async -> Int {
        guard let progress = try? await load(userID: userID) else {
            return 0
        }
        return progress.currentStreak
    }

    func getTotalSessions(userID: UUID) async -> Int {
        guard let progress = try? await load(userID: userID) else {
            return 0
        }
        return progress.totalSessions
    }

    func getTotalDuration(userID: UUID) async -> TimeInterval {
        guard let progress = try? await load(userID: userID) else {
            return 0
        }
        return progress.totalDuration
    }

    func getAchievements(userID: UUID) async -> [Achievement] {
        guard let progress = try? await load(userID: userID) else {
            return []
        }
        return progress.achievements
    }

    func getUnlockedEnvironments(userID: UUID) async -> Set<String> {
        guard let progress = try? await load(userID: userID) else {
            return []
        }
        return progress.unlockedEnvironments
    }

    // MARK: - Progress Comparison

    func getProgressChange(userID: UUID, days: Int) async throws -> ProgressChange {
        let current = try await load(userID: userID)

        // Find snapshot from N days ago
        let targetDate = Date().addingTimeInterval(-Double(days) * 86400)
        let snapshots = try await loadSnapshots(userID: userID, limit: 100)

        // Find closest snapshot to target date
        let previous = snapshots.min(by: { snapshot1, snapshot2 in
            let diff1 = abs(snapshot1.lastSessionDate?.timeIntervalSince(targetDate) ?? Double.infinity)
            let diff2 = abs(snapshot2.lastSessionDate?.timeIntervalSince(targetDate) ?? Double.infinity)
            return diff1 < diff2
        })

        guard let previous = previous else {
            // No historical data
            return ProgressChange(
                levelGain: 0,
                xpGain: 0,
                sessionsAdded: 0,
                hoursAdded: 0,
                achievementsUnlocked: 0
            )
        }

        return ProgressChange(
            levelGain: current.level - previous.level,
            xpGain: current.experiencePoints - previous.experiencePoints,
            sessionsAdded: current.totalSessions - previous.totalSessions,
            hoursAdded: (current.totalDuration - previous.totalDuration) / 3600.0,
            achievementsUnlocked: current.achievements.count - previous.achievements.count
        )
    }

    struct ProgressChange {
        let levelGain: Int
        let xpGain: Int
        let sessionsAdded: Int
        let hoursAdded: Double
        let achievementsUnlocked: Int
    }

    // MARK: - Leaderboard Support (Local Only)

    func getAllProgressRecords() async -> [(userID: UUID, progress: UserProgress)] {
        // In a multi-user scenario (family sharing), get all progress records
        // For now, just return cached records

        return cache.map { (userID: $0.key, progress: $0.value) }
    }

    func getTopByLevel(limit: Int = 10) async -> [UserProgress] {
        let allRecords = await getAllProgressRecords()
        return allRecords
            .map { $0.progress }
            .sorted { $0.level > $1.level }
            .prefix(limit)
            .map { $0 }
    }

    func getTopByTotalHours(limit: Int = 10) async -> [UserProgress] {
        let allRecords = await getAllProgressRecords()
        return allRecords
            .map { $0.progress }
            .sorted { $0.totalDuration > $1.totalDuration }
            .prefix(limit)
            .map { $0 }
    }

    func getTopByStreak(limit: Int = 10) async -> [UserProgress] {
        let allRecords = await getAllProgressRecords()
        return allRecords
            .map { $0.progress }
            .sorted { $0.currentStreak > $1.currentStreak }
            .prefix(limit)
            .map { $0 }
    }

    // MARK: - Backup & Restore

    func backup(userID: UUID) async throws -> Data {
        let progress = try await load(userID: userID)
        let snapshots = try await loadSnapshots(userID: userID, limit: 100)

        struct Backup: Codable {
            let current: UserProgress
            let history: [UserProgress]
            let backupDate: Date
        }

        let backup = Backup(
            current: progress,
            history: snapshots,
            backupDate: Date()
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted

        return try encoder.encode(backup)
    }

    func restore(from data: Data, userID: UUID) async throws {
        struct Backup: Codable {
            let current: UserProgress
            let history: [UserProgress]
            let backupDate: Date
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let backup = try decoder.decode(Backup.self, from: data)

        // Verify userID matches
        guard backup.current.userID == userID else {
            throw NSError(domain: "ProgressRepository", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "Backup userID does not match"
            ])
        }

        // Restore current progress
        try await save(backup.current)

        // Restore history snapshots
        for snapshot in backup.history {
            try await saveSnapshot(snapshot)
        }
    }

    // MARK: - Cache Management

    func clearCache() {
        cache.removeAll()
    }

    func getCacheSize() -> Int {
        return cache.count
    }

    func preloadCache(userIDs: [UUID]) async {
        for userID in userIDs {
            if let progress = try? await load(userID: userID) {
                cache[userID] = progress
            }
        }
    }
}
