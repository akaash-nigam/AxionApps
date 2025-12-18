//
//  NetworkClient.swift
//  CorporateUniversity
//
//  Created by Claude AI on 2025-01-20.
//  Copyright © 2025 Corporate University Platform. All rights reserved.
//

import Foundation

/// HTTP network client for API communication
class NetworkClient {
    // MARK: - Properties

    private let baseURL: URL
    private let session: URLSession
    private var authToken: String?

    // MARK: - Initialization

    init(baseURL: String = "https://api.corporateuniversity.com/v1") {
        self.baseURL = URL(string: baseURL)!

        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 300
        configuration.waitsForConnectivity = true

        self.session = URLSession(configuration: configuration)
    }

    // MARK: - Public Methods

    /// Make a network request
    func request<T: Decodable>(
        endpoint: APIEndpoint,
        method: HTTPMethod = .get,
        body: Encodable? = nil,
        responseType: T.Type
    ) async throws -> T {
        let request = try buildRequest(endpoint, method: method, body: body)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(T.self, from: data)
    }

    /// Make a request without expecting a response body
    func request(
        endpoint: APIEndpoint,
        method: HTTPMethod = .get,
        body: Encodable? = nil
    ) async throws {
        let request = try buildRequest(endpoint, method: method, body: body)

        let (_, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }
    }

    /// Set authentication token
    func setAuthToken(_ token: String?) {
        self.authToken = token
    }

    // MARK: - Private Methods

    private func buildRequest(
        _ endpoint: APIEndpoint,
        method: HTTPMethod,
        body: Encodable?
    ) throws -> URLRequest {
        let url = baseURL.appendingPathComponent(endpoint.path)

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Add auth token if available
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Add request body if present
        if let body = body {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            request.httpBody = try encoder.encode(body)
        }

        return request
    }
}

// MARK: - HTTP Method

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

// MARK: - API Endpoints

enum APIEndpoint {
    case login
    case logout
    case courses(filter: CourseFilter?)
    case courseDetail(id: UUID)
    case enroll(learnerId: UUID, courseId: UUID)
    case userProgress(userId: UUID)
    case enrollments(userId: UUID)
    case updateProgress(enrollmentId: UUID, lessonId: UUID, completed: Bool)
    case assessments(courseId: UUID)
    case submitAssessment(assessmentId: UUID)
    case analytics(userId: UUID)

    var path: String {
        switch self {
        case .login:
            return "/auth/login"
        case .logout:
            return "/auth/logout"
        case .courses:
            return "/courses"
        case .courseDetail(let id):
            return "/courses/\(id.uuidString)"
        case .enroll:
            return "/enrollments"
        case .userProgress(let userId):
            return "/users/\(userId.uuidString)/progress"
        case .enrollments(let userId):
            return "/users/\(userId.uuidString)/enrollments"
        case .updateProgress(let enrollmentId, _, _):
            return "/enrollments/\(enrollmentId.uuidString)/progress"
        case .assessments(let courseId):
            return "/courses/\(courseId.uuidString)/assessments"
        case .submitAssessment(let assessmentId):
            return "/assessments/\(assessmentId.uuidString)/submit"
        case .analytics(let userId):
            return "/analytics/learner/\(userId.uuidString)"
        }
    }
}

// MARK: - Course Filter

enum CourseFilter: Sendable {
    case all
    case category(CourseCategory)
    case difficulty(DifficultyLevel)
    case recommended(userId: UUID)
}

// MARK: - Network Errors

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
    case encodingError(Error)
    case networkUnavailable

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid server response"
        case .httpError(let statusCode):
            return "HTTP error: \(statusCode)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .encodingError(let error):
            return "Failed to encode request: \(error.localizedDescription)"
        case .networkUnavailable:
            return "Network unavailable. Please check your connection."
        }
    }
}
