import Foundation

/// Repository for meditation session data access
actor SessionRepository {

    // MARK: - Private Properties

    private let localStorage: LocalStorage
    private var cache: [UUID: MeditationSession] = [:]
    private let cacheLimit = 100

    // MARK: - Initialization

    init(localStorage: LocalStorage = LocalStorage()) {
        self.localStorage = localStorage
    }

    // MARK: - Save Methods

    func save(_ session: MeditationSession) async throws {
        // Save to local storage
        let key = "session_\(session.id.uuidString)"
        try await localStorage.save(session, key: key)

        // Update cache
        cache[session.id] = session

        // Limit cache size
        if cache.count > cacheLimit {
            // Remove oldest sessions
            let sorted = cache.sorted { $0.value.startTime < $1.value.startTime }
            for (id, _) in sorted.prefix(cache.count - cacheLimit) {
                cache.removeValue(forKey: id)
            }
        }

        // Also save to user index for quick lookup
        try await addToUserIndex(session)
    }

    func saveAll(_ sessions: [MeditationSession]) async throws {
        for session in sessions {
            try await save(session)
        }
    }

    // MARK: - Load Methods

    func load(sessionID: UUID) async throws -> MeditationSession {
        // Check cache first
        if let cached = cache[sessionID] {
            return cached
        }

        // Load from storage
        let key = "session_\(sessionID.uuidString)"
        let session: MeditationSession = try await localStorage.load(key: key)

        // Update cache
        cache[sessionID] = session

        return session
    }

    func loadAll(userID: UUID, limit: Int? = nil) async throws -> [MeditationSession] {
        // Load user's session index
        guard let sessionIDs = try? await loadUserIndex(userID) else {
            return []
        }

        var sessions: [MeditationSession] = []

        for id in sessionIDs {
            if let session = try? await load(sessionID: id) {
                sessions.append(session)
            }
        }

        // Sort by start time (newest first)
        sessions.sort { $0.startTime > $1.startTime }

        // Apply limit if specified
        if let limit = limit {
            return Array(sessions.prefix(limit))
        }

        return sessions
    }

    func loadRecent(userID: UUID, days: Int = 30) async throws -> [MeditationSession] {
        let allSessions = try await loadAll(userID: userID)

        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date())!

        return allSessions.filter { $0.startTime >= cutoffDate }
    }

    func loadByDateRange(userID: UUID, start: Date, end: Date) async throws -> [MeditationSession] {
        let allSessions = try await loadAll(userID: userID)

        return allSessions.filter { session in
            session.startTime >= start && session.startTime <= end
        }
    }

    // MARK: - Query Methods

    func findByEnvironment(userID: UUID, environmentID: String) async throws -> [MeditationSession] {
        let allSessions = try await loadAll(userID: userID)
        return allSessions.filter { $0.environmentID == environmentID }
    }

    func findByTechnique(userID: UUID, technique: MeditationTechnique) async throws -> [MeditationSession] {
        let allSessions = try await loadAll(userID: userID)
        return allSessions.filter { $0.technique == technique }
    }

    func findHighQuality(userID: UUID, minQuality: Float = 0.7) async throws -> [MeditationSession] {
        let allSessions = try await loadAll(userID: userID)
        return allSessions.filter { ($0.qualityScore ?? 0) >= minQuality }
    }

    func findByDuration(userID: UUID, minDuration: TimeInterval, maxDuration: TimeInterval) async throws -> [MeditationSession] {
        let allSessions = try await loadAll(userID: userID)
        return allSessions.filter { session in
            session.duration >= minDuration && session.duration <= maxDuration
        }
    }

    // MARK: - Delete Methods

    func delete(sessionID: UUID) async throws {
        let key = "session_\(sessionID.uuidString)"
        try await localStorage.delete(key: key)

        // Remove from cache
        cache.removeValue(forKey: sessionID)

        // Note: Also need to remove from user index
        // Would need to load session first to get userID
        if let session = cache.values.first(where: { $0.id == sessionID }) {
            try await removeFromUserIndex(session)
        }
    }

    func deleteAll(userID: UUID) async throws {
        let sessionIDs = try await loadUserIndex(userID)

        for id in sessionIDs {
            try? await delete(sessionID: id)
        }

        // Clear user index
        let indexKey = "user_sessions_\(userID.uuidString)"
        try? await localStorage.delete(key: indexKey)
    }

    // MARK: - Statistics

    func getCount(userID: UUID) async -> Int {
        guard let sessionIDs = try? await loadUserIndex(userID) else {
            return 0
        }
        return sessionIDs.count
    }

    func getTotalDuration(userID: UUID) async -> TimeInterval {
        guard let sessions = try? await loadAll(userID: userID) else {
            return 0
        }
        return sessions.reduce(0) { $0 + $1.duration }
    }

    func getAverageQuality(userID: UUID) async -> Float? {
        guard let sessions = try? await loadAll(userID: userID) else {
            return nil
        }

        let qualitySessions = sessions.compactMap { $0.qualityScore }
        guard !qualitySessions.isEmpty else { return nil }

        return qualitySessions.reduce(0, +) / Float(qualitySessions.count)
    }

    // MARK: - Private Index Management

    private func addToUserIndex(_ session: MeditationSession) async throws {
        let indexKey = "user_sessions_\(session.userID.uuidString)"

        var sessionIDs: [UUID]
        if let existing: [UUID] = try? await localStorage.load(key: indexKey) {
            sessionIDs = existing
        } else {
            sessionIDs = []
        }

        // Add if not already present
        if !sessionIDs.contains(session.id) {
            sessionIDs.append(session.id)
            try await localStorage.save(sessionIDs, key: indexKey)
        }
    }

    private func removeFromUserIndex(_ session: MeditationSession) async throws {
        let indexKey = "user_sessions_\(session.userID.uuidString)"

        guard var sessionIDs: [UUID] = try? await localStorage.load(key: indexKey) else {
            return
        }

        sessionIDs.removeAll { $0 == session.id }
        try await localStorage.save(sessionIDs, key: indexKey)
    }

    private func loadUserIndex(_ userID: UUID) async throws -> [UUID] {
        let indexKey = "user_sessions_\(userID.uuidString)"
        return try await localStorage.load(key: indexKey)
    }

    // MARK: - Cache Management

    func clearCache() {
        cache.removeAll()
    }

    func getCacheSize() -> Int {
        return cache.count
    }
}
