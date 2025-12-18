//
//  APIClient.swift
//  CultureArchitectureSystem
//
//  Created on 2025-01-20
//

import Foundation

// MARK: - Data Transfer Objects (DTOs)

struct OrganizationDTO: Codable {
    let id: UUID
    let name: String
    let culturalValues: [CulturalValueDTO]
    let departments: [DepartmentDTO]
    let cultureHealthScore: Double
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, name
        case culturalValues = "cultural_values"
        case departments
        case cultureHealthScore = "culture_health_score"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct CulturalValueDTO: Codable {
    let id: UUID
    let name: String
    let description: String
    let iconName: String
    let colorHex: String
    let alignmentScore: Double
    let behaviors: [String]

    enum CodingKeys: String, CodingKey {
        case id, name, description
        case iconName = "icon_name"
        case colorHex = "color_hex"
        case alignmentScore = "alignment_score"
        case behaviors
    }
}

struct DepartmentDTO: Codable {
    let id: UUID
    let name: String
    let teamCount: Int
    let employeeCount: Int
    let healthScore: Double

    enum CodingKeys: String, CodingKey {
        case id, name
        case teamCount = "team_count"
        case employeeCount = "employee_count"
        case healthScore = "health_score"
    }
}

struct BehaviorEventDTO: Codable {
    let id: UUID
    let anonymousEmployeeId: UUID
    let teamId: UUID
    let eventType: String
    let valueId: UUID
    let timestamp: Date
    let impact: Double
    let isSynced: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case anonymousEmployeeId = "anonymous_employee_id"
        case teamId = "team_id"
        case eventType = "event_type"
        case valueId = "value_id"
        case timestamp, impact
        case isSynced = "is_synced"
    }
}

struct RecognitionDTO: Codable {
    let id: UUID
    let giverAnonymousId: UUID
    let receiverAnonymousId: UUID
    let valueId: UUID
    let message: String
    let timestamp: Date
    let visibility: String
    let isSynced: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case giverAnonymousId = "giver_anonymous_id"
        case receiverAnonymousId = "receiver_anonymous_id"
        case valueId = "value_id"
        case message, timestamp, visibility
        case isSynced = "is_synced"
    }
}

actor APIClient {
    private let baseURL = URL(string: "https://api.culturearchitecture.com/v1")!
    private let session: URLSession
    private let authManager: AuthenticationManager

    init(authManager: AuthenticationManager) {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 300
        config.waitsForConnectivity = true

        self.session = URLSession(configuration: config)
        self.authManager = authManager
    }

    // MARK: - Organization Endpoints

    func fetchOrganization(id: UUID) async throws -> OrganizationDTO {
        let endpoint = baseURL.appendingPathComponent("organizations/\(id.uuidString)")

        var request = URLRequest(url: endpoint)
        request.httpMethod = "GET"
        request.addValue("Bearer \(try await authManager.getAccessToken())", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601

        return try decoder.decode(OrganizationDTO.self, from: data)
    }

    // MARK: - Behavior Endpoints

    func uploadBehaviorEvent(_ event: BehaviorEvent) async throws {
        let endpoint = baseURL.appendingPathComponent("behaviors/events")

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.addValue("Bearer \(try await authManager.getAccessToken())", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601

        // Convert to DTO
        let dto = BehaviorEventDTO(
            id: event.id,
            anonymousEmployeeId: event.anonymousEmployeeId,
            teamId: event.teamId,
            eventType: event.eventType.rawValue,
            valueId: event.valueId,
            timestamp: event.timestamp,
            impact: event.impact,
            isSynced: event.isSynced
        )

        request.httpBody = try encoder.encode(dto)

        let (_, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.uploadFailed
        }
    }

    // MARK: - Recognition Endpoints

    func createRecognition(_ recognition: Recognition) async throws {
        let endpoint = baseURL.appendingPathComponent("recognition")

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.addValue("Bearer \(try await authManager.getAccessToken())", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601

        // Convert to DTO
        let dto = RecognitionDTO(
            id: recognition.id,
            giverAnonymousId: recognition.giverAnonymousId,
            receiverAnonymousId: recognition.receiverAnonymousId,
            valueId: recognition.valueId,
            message: recognition.message,
            timestamp: recognition.timestamp,
            visibility: recognition.visibility.rawValue,
            isSynced: recognition.isSynced
        )

        request.httpBody = try encoder.encode(dto)

        let (_, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.uploadFailed
        }
    }
}

// MARK: - API Errors

enum APIError: Error {
    case invalidResponse
    case uploadFailed
    case authenticationRequired
    case networkUnavailable
    case decodingFailed
}
