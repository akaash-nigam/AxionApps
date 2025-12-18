//
//  LeaderboardManager.swift
//  Parkour Pathways
//
//  CloudKit-based leaderboard system
//

import Foundation
import CloudKit
import Combine

/// Manages leaderboard data using CloudKit
class LeaderboardManager: ObservableObject {

    // MARK: - Published Properties

    @Published var isLoading: Bool = false
    @Published var lastError: Error?

    // MARK: - Properties

    private let container: CKContainer
    private let publicDatabase: CKDatabase
    private let privateDatabase: CKDatabase

    // Cache
    private var leaderboardCache: [UUID: [LeaderboardScore]] = [:]
    private var cacheTimestamps: [UUID: Date] = [:]
    private let cacheValidityDuration: TimeInterval = 300 // 5 minutes

    // MARK: - Initialization

    init() {
        self.container = CKContainer(identifier: "iCloud.com.parkourpathways.app")
        self.publicDatabase = container.publicCloudDatabase
        self.privateDatabase = container.privateCloudDatabase
    }

    // MARK: - Public API - Submitting Scores

    /// Submit a score to the leaderboard
    func submitScore(
        courseId: UUID,
        score: Int,
        time: TimeInterval,
        movementRecording: MovementRecording? = nil
    ) async throws {
        isLoading = true
        defer { isLoading = false }

        // Get current user ID
        let userRecordID = try await container.userRecordID()

        // Create score record
        let recordID = CKRecord.ID(recordName: UUID().uuidString)
        let record = CKRecord(recordType: "CourseScore", recordID: recordID)

        record["courseId"] = courseId.uuidString as CKRecordValue
        record["playerId"] = userRecordID
        record["score"] = score as CKRecordValue
        record["time"] = time as CKRecordValue
        record["submittedAt"] = Date() as CKRecordValue

        // Store movement recording if provided
        if let recording = movementRecording {
            let recordingData = try JSONEncoder().encode(recording)
            record["movementRecording"] = recordingData as CKRecordValue
        }

        // Save to CloudKit
        do {
            _ = try await publicDatabase.save(record)

            // Invalidate cache for this course
            leaderboardCache.removeValue(forKey: courseId)
            cacheTimestamps.removeValue(forKey: courseId)

        } catch {
            lastError = error
            throw LeaderboardError.submissionFailed(error)
        }
    }

    // MARK: - Public API - Fetching Scores

    /// Fetch top scores for a course
    func fetchTopScores(
        courseId: UUID,
        limit: Int = 100,
        forceRefresh: Bool = false
    ) async throws -> [LeaderboardScore] {
        // Check cache
        if !forceRefresh, let cached = getCachedScores(courseId) {
            return cached
        }

        isLoading = true
        defer { isLoading = false }

        // Query CloudKit
        let predicate = NSPredicate(format: "courseId == %@", courseId.uuidString)
        let query = CKQuery(recordType: "CourseScore", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "score", ascending: false)]

        do {
            let results = try await publicDatabase.records(matching: query, resultsLimit: limit)

            var scores: [LeaderboardScore] = []

            for (index, result) in results.matchResults.enumerated() {
                switch result {
                case .success(let record):
                    if let score = parseScore(from: record.0, rank: index + 1) {
                        scores.append(score)
                    }
                case .failure(let error):
                    print("Failed to fetch record: \(error)")
                }
            }

            // Cache results
            leaderboardCache[courseId] = scores
            cacheTimestamps[courseId] = Date()

            return scores

        } catch {
            lastError = error
            throw LeaderboardError.fetchFailed(error)
        }
    }

    /// Fetch friend scores for a course
    func fetchFriendScores(courseId: UUID) async throws -> [LeaderboardScore] {
        // Note: This requires CloudKit sharing and friend relationships
        // Simplified implementation

        isLoading = true
        defer { isLoading = false }

        // Get user's friends (would come from a friends system)
        let friendIds = try await fetchFriendIds()

        // Query for friends' scores
        let predicate = NSPredicate(
            format: "courseId == %@ AND playerId IN %@",
            courseId.uuidString,
            friendIds
        )

        let query = CKQuery(recordType: "CourseScore", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "score", ascending: false)]

        do {
            let results = try await publicDatabase.records(matching: query, resultsLimit: 50)

            var scores: [LeaderboardScore] = []

            for (index, result) in results.matchResults.enumerated() {
                switch result {
                case .success(let record):
                    if let score = parseScore(from: record.0, rank: index + 1) {
                        scores.append(score)
                    }
                case .failure(let error):
                    print("Failed to fetch friend record: \(error)")
                }
            }

            return scores

        } catch {
            lastError = error
            throw LeaderboardError.fetchFailed(error)
        }
    }

    /// Get player's rank on a specific course
    func getPlayerRank(courseId: UUID, playerId: UUID) async throws -> Int {
        let scores = try await fetchTopScores(courseId: courseId, limit: 1000)

        guard let playerScore = scores.first(where: { $0.playerId == playerId }) else {
            throw LeaderboardError.playerNotFound
        }

        return playerScore.rank
    }

    /// Get player's best score for a course
    func getPlayerBestScore(courseId: UUID, playerId: UUID) async throws -> LeaderboardScore? {
        isLoading = true
        defer { isLoading = false }

        let predicate = NSPredicate(
            format: "courseId == %@ AND playerId == %@",
            courseId.uuidString,
            playerId.uuidString
        )

        let query = CKQuery(recordType: "CourseScore", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "score", ascending: false)]

        do {
            let results = try await publicDatabase.records(matching: query, resultsLimit: 1)

            guard let firstResult = results.matchResults.first else {
                return nil
            }

            switch firstResult {
            case .success(let record):
                return parseScore(from: record.0, rank: 0) // Rank will be determined later

            case .failure(let error):
                throw LeaderboardError.fetchFailed(error)
            }

        } catch {
            lastError = error
            throw LeaderboardError.fetchFailed(error)
        }
    }

    // MARK: - Public API - Time-based Leaderboards

    /// Fetch weekly leaderboard
    func fetchWeeklyLeaderboard(courseId: UUID) async throws -> [LeaderboardScore] {
        let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!

        let predicate = NSPredicate(
            format: "courseId == %@ AND submittedAt >= %@",
            courseId.uuidString,
            oneWeekAgo as NSDate
        )

        return try await fetchScores(predicate: predicate, limit: 50)
    }

    /// Fetch daily leaderboard
    func fetchDailyLeaderboard(courseId: UUID) async throws -> [LeaderboardScore] {
        let oneDayAgo = Calendar.current.date(byAdding: .day, value: -1, to: Date())!

        let predicate = NSPredicate(
            format: "courseId == %@ AND submittedAt >= %@",
            courseId.uuidString,
            oneDayAgo as NSDate
        )

        return try await fetchScores(predicate: predicate, limit: 30)
    }

    // MARK: - Public API - Course Statistics

    /// Get aggregate statistics for a course
    func getCourseStatistics(courseId: UUID) async throws -> CourseStatistics {
        let scores = try await fetchTopScores(courseId: courseId, limit: 1000)

        guard !scores.isEmpty else {
            return CourseStatistics(
                totalAttempts: 0,
                averageScore: 0,
                averageTime: 0,
                bestScore: 0,
                bestTime: 0
            )
        }

        let totalAttempts = scores.count
        let averageScore = scores.map { Float($0.score) }.reduce(0, +) / Float(totalAttempts)
        let averageTime = scores.map { $0.time }.reduce(0, +) / Double(totalAttempts)
        let bestScore = scores.first?.score ?? 0
        let bestTime = scores.min(by: { $0.time < $1.time })?.time ?? 0

        return CourseStatistics(
            totalAttempts: totalAttempts,
            averageScore: averageScore,
            averageTime: averageTime,
            bestScore: bestScore,
            bestTime: bestTime
        )
    }

    // MARK: - Private Helpers

    private func fetchScores(predicate: NSPredicate, limit: Int) async throws -> [LeaderboardScore] {
        let query = CKQuery(recordType: "CourseScore", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "score", ascending: false)]

        let results = try await publicDatabase.records(matching: query, resultsLimit: limit)

        var scores: [LeaderboardScore] = []

        for (index, result) in results.matchResults.enumerated() {
            switch result {
            case .success(let record):
                if let score = parseScore(from: record.0, rank: index + 1) {
                    scores.append(score)
                }
            case .failure:
                continue
            }
        }

        return scores
    }

    private func parseScore(from record: CKRecord, rank: Int) -> LeaderboardScore? {
        guard
            let courseIdString = record["courseId"] as? String,
            let courseId = UUID(uuidString: courseIdString),
            let playerIdRecord = record["playerId"] as? CKRecord.Reference,
            let score = record["score"] as? Int,
            let time = record["time"] as? Double,
            let submittedAt = record["submittedAt"] as? Date
        else {
            return nil
        }

        // Extract player ID from reference
        let playerId = UUID(uuidString: playerIdRecord.recordID.recordName) ?? UUID()

        // Extract movement recording if available
        var movementRecording: MovementRecording?
        if let recordingData = record["movementRecording"] as? Data {
            movementRecording = try? JSONDecoder().decode(MovementRecording.self, from: recordingData)
        }

        return LeaderboardScore(
            id: record.recordID.recordName,
            courseId: courseId,
            playerId: playerId,
            username: "Player", // Would fetch from user profile
            score: score,
            time: time,
            submittedAt: submittedAt,
            rank: rank,
            movementRecording: movementRecording
        )
    }

    private func getCachedScores(_ courseId: UUID) -> [LeaderboardScore]? {
        guard let cached = leaderboardCache[courseId],
              let timestamp = cacheTimestamps[courseId],
              Date().timeIntervalSince(timestamp) < cacheValidityDuration else {
            return nil
        }

        return cached
    }

    private func fetchFriendIds() async throws -> [String] {
        // Simplified - would integrate with social/friends system
        return []
    }
}

// MARK: - Supporting Types

struct LeaderboardScore: Identifiable {
    let id: String
    let courseId: UUID
    let playerId: UUID
    let username: String
    let score: Int
    let time: TimeInterval
    let submittedAt: Date
    let rank: Int
    let movementRecording: MovementRecording?
}

struct CourseStatistics {
    let totalAttempts: Int
    let averageScore: Float
    let averageTime: TimeInterval
    let bestScore: Int
    let bestTime: TimeInterval
}

enum LeaderboardError: Error {
    case submissionFailed(Error)
    case fetchFailed(Error)
    case playerNotFound
    case notAuthenticated
}
