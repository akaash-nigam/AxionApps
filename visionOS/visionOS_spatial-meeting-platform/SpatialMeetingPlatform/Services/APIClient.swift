//
//  APIClient.swift
//  SpatialMeetingPlatform
//
//  REST API client for backend communication
//

import Foundation

class APIClient {

    // MARK: - Properties

    private let baseURL: URL
    private let session: URLSession
    private var authToken: String?

    // MARK: - Initialization

    init(baseURL: URL) {
        self.baseURL = baseURL

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 300

        self.session = URLSession(configuration: config)
    }

    // MARK: - Authentication

    func setAuthToken(_ token: String) {
        self.authToken = token
    }

    func clearAuthToken() {
        self.authToken = nil
    }

    // MARK: - Generic Request

    func request<T: Codable, R: Codable>(
        _ endpoint: String,
        method: HTTPMethod,
        body: T? = nil
    ) async throws -> R {
        var url = baseURL.appendingPathComponent(endpoint)

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }

        let decoded = try JSONDecoder().decode(R.self, from: data)
        return decoded
    }

    // MARK: - Specific Endpoints (Examples)

    func login(email: String, password: String) async throws -> AuthResponse {
        struct LoginRequest: Codable {
            let email: String
            let password: String
        }

        let request = LoginRequest(email: email, password: password)
        let response: AuthResponse = try await self.request("/auth/login", method: .post, body: request)

        // Store auth token
        self.authToken = response.token

        return response
    }

    func fetchMeetings() async throws -> [Meeting] {
        return try await request("/meetings", method: .get)
    }
}

// MARK: - Supporting Types

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

enum APIError: LocalizedError {
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .decodingError:
            return "Failed to decode response"
        }
    }
}

struct AuthResponse: Codable {
    let token: String
    let user: UserDTO
}

struct UserDTO: Codable {
    let id: UUID
    let email: String
    let displayName: String
}
