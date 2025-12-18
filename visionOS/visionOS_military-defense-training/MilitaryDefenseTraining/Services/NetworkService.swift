//
//  NetworkService.swift
//  MilitaryDefenseTraining
//
//  Created by Claude Code
//

import Foundation

actor NetworkService {
    private let session: URLSession
    private let baseURL: String = "https://api.militarytraining.mil"
    private var offlineQueue: [PendingOperation] = []
    private var isOnline: Bool = true

    init() {
        let configuration = URLSessionConfiguration.default
        configuration.tlsMinimumSupportedProtocolVersion = .TLSv13
        configuration.waitsForConnectivity = true
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 300

        self.session = URLSession(configuration: configuration)

        // Load pending operations from storage
        Task {
            await loadPendingOperations()
        }
    }

    // MARK: - Scenario Operations

    func fetchScenarios(clearanceLevel: ClassificationLevel) async throws -> [Scenario] {
        let endpoint = "\(baseURL)/v1/scenarios?clearance=\(clearanceLevel.rawValue)"

        guard let url = URL(string: endpoint) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(await getAuthToken())", forHTTPHeaderField: "Authorization")
        request.setValue(clearanceLevel.displayName, forHTTPHeaderField: "X-Classification")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        return try decoder.decode([Scenario].self, from: data)
    }

    func downloadScenario(id: UUID) async throws -> ScenarioPackage {
        let endpoint = "\(baseURL)/v1/scenarios/\(id.uuidString)/download"

        guard let url = URL(string: endpoint) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(await getAuthToken())", forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }

        let decoder = JSONDecoder()
        return try decoder.decode(ScenarioPackage.self, from: data)
    }

    // MARK: - Session Upload

    func uploadTrainingSession(_ session: TrainingSession) async throws {
        let endpoint = "\(baseURL)/v1/sessions"

        guard let url = URL(string: endpoint) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(await getAuthToken())", forHTTPHeaderField: "Authorization")
        request.setValue(session.classificationLevel.displayName, forHTTPHeaderField: "X-Classification")

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        // Create uploadable session data
        let uploadData = SessionUploadData(
            id: session.id,
            missionType: session.missionType,
            scenarioID: session.scenarioID,
            warriorID: session.warriorID,
            startTime: session.startTime,
            endTime: session.endTime,
            score: session.score,
            isCompleted: session.isCompleted,
            classificationLevel: session.classificationLevel
        )

        request.httpBody = try encoder.encode(uploadData)

        do {
            let (_, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.invalidResponse
            }
        } catch {
            // If upload fails, queue for later
            await queueOperation(.sessionUpload(session))
            throw error
        }
    }

    // MARK: - Analytics

    func getWarriorAnalytics(id: UUID) async throws -> WarriorAnalytics {
        let endpoint = "\(baseURL)/v1/analytics/warrior/\(id.uuidString)"

        guard let url = URL(string: endpoint) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(await getAuthToken())", forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }

        let decoder = JSONDecoder()
        return try decoder.decode(WarriorAnalytics.self, from: data)
    }

    // MARK: - AI Models

    func downloadLatestAIModel() async throws -> AIModelPackage {
        let endpoint = "\(baseURL)/v1/ai/opfor/latest"

        guard let url = URL(string: endpoint) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(await getAuthToken())", forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }

        let decoder = JSONDecoder()
        return try decoder.decode(AIModelPackage.self, from: data)
    }

    // MARK: - Leaderboard

    func submitScore(_ score: CompetitionScore) async throws {
        let endpoint = "\(baseURL)/v1/leaderboard/submit"

        guard let url = URL(string: endpoint) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(await getAuthToken())", forHTTPHeaderField: "Authorization")

        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(score)

        let (_, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
    }

    func getUnitRankings(unitID: String) async throws -> [Ranking] {
        let endpoint = "\(baseURL)/v1/leaderboard/unit/\(unitID)"

        guard let url = URL(string: endpoint) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(await getAuthToken())", forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }

        let decoder = JSONDecoder()
        return try decoder.decode([Ranking].self, from: data)
    }

    // MARK: - Offline Queue Management

    private func queueOperation(_ operation: PendingOperation) {
        offlineQueue.append(operation)
        Task {
            await savePendingOperations()
        }
    }

    func processPendingOperations() async {
        guard isOnline else { return }

        var processedOperations: [UUID] = []

        for operation in offlineQueue {
            do {
                try await processOperation(operation)
                processedOperations.append(operation.id)
            } catch {
                print("Failed to process queued operation: \(error)")
                // Keep in queue for retry
            }
        }

        // Remove successfully processed operations
        offlineQueue.removeAll { processedOperations.contains($0.id) }
        await savePendingOperations()
    }

    private func processOperation(_ operation: PendingOperation) async throws {
        switch operation.type {
        case .sessionUpload(let session):
            try await uploadTrainingSession(session)

        case .scoreSubmission(let score):
            try await submitScore(score)

        case .analyticsSync(let warriorID):
            _ = try await getWarriorAnalytics(id: warriorID)
        }
    }

    private func savePendingOperations() async {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(offlineQueue) {
            UserDefaults.standard.set(data, forKey: "networkPendingOperations")
        }
    }

    private func loadPendingOperations() async {
        guard let data = UserDefaults.standard.data(forKey: "networkPendingOperations") else {
            return
        }

        let decoder = JSONDecoder()
        if let operations = try? decoder.decode([PendingOperation].self, from: data) {
            offlineQueue = operations
        }
    }

    // MARK: - Network Status

    func updateOnlineStatus(_ online: Bool) {
        isOnline = online

        if online {
            Task {
                await processPendingOperations()
            }
        }
    }

    func getQueuedOperationCount() -> Int {
        return offlineQueue.count
    }

    // MARK: - Authentication

    private func getAuthToken() async -> String {
        // In real implementation, would retrieve from secure storage
        // For now, return placeholder
        return "PLACEHOLDER_AUTH_TOKEN"
    }

    // MARK: - Retry Logic

    private func performRequestWithRetry<T: Decodable>(
        request: URLRequest,
        retries: Int = 3
    ) async throws -> T {
        var lastError: Error?
        var delay: TimeInterval = 1.0

        for attempt in 0..<retries {
            do {
                let (data, response) = try await session.data(for: request)

                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }

                guard (200...299).contains(httpResponse.statusCode) else {
                    throw NetworkError.httpError(statusCode: httpResponse.statusCode)
                }

                let decoder = JSONDecoder()
                return try decoder.decode(T.self, from: data)

            } catch {
                lastError = error
                print("Request failed (attempt \(attempt + 1)/\(retries)): \(error)")

                if attempt < retries - 1 {
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    delay *= 2 // Exponential backoff
                }
            }
        }

        throw lastError ?? NetworkError.maxRetriesExceeded
    }
}

// MARK: - Supporting Types

struct PendingOperation: Codable {
    var id: UUID = UUID()
    var type: OperationType
    var timestamp: Date = Date()

    enum OperationType: Codable {
        case sessionUpload(TrainingSession)
        case scoreSubmission(CompetitionScore)
        case analyticsSync(warriorID: UUID)
    }
}

struct SessionUploadData: Codable {
    var id: UUID
    var missionType: MissionType
    var scenarioID: UUID
    var warriorID: UUID
    var startTime: Date
    var endTime: Date?
    var score: Int
    var isCompleted: Bool
    var classificationLevel: ClassificationLevel
}

struct ScenarioPackage: Codable {
    var scenario: Scenario
    var terrainData: Data
    var assetURLs: [String: URL]
    var checksum: String
}

struct AIModelPackage: Codable {
    var version: String
    var modelData: Data
    var releaseDate: Date
    var improvements: String
}

struct WarriorAnalytics: Codable {
    var warriorID: UUID
    var totalSessions: Int
    var averageScore: Double
    var strengthAreas: [String]
    var improvementAreas: [String]
    var trend: PerformanceTrend

    enum PerformanceTrend: String, Codable {
        case improving = "Improving"
        case stable = "Stable"
        case declining = "Declining"
    }
}

struct CompetitionScore: Codable {
    var warriorID: UUID
    var scenarioID: UUID
    var score: Int
    var difficulty: DifficultyLevel
    var timestamp: Date
}

struct Ranking: Codable {
    var position: Int
    var warriorID: UUID
    var name: String
    var rank: MilitaryRank
    var score: Int
    var unit: String
}

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError
    case encodingError
    case unauthorized
    case forbidden
    case notFound
    case serverError
    case networkUnavailable
    case maxRetriesExceeded

    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid server response"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .decodingError:
            return "Failed to decode response"
        case .encodingError:
            return "Failed to encode request"
        case .unauthorized:
            return "Unauthorized - check authentication"
        case .forbidden:
            return "Forbidden - insufficient clearance"
        case .notFound:
            return "Resource not found"
        case .serverError:
            return "Server error"
        case .networkUnavailable:
            return "Network unavailable"
        case .maxRetriesExceeded:
            return "Maximum retry attempts exceeded"
        }
    }
}
