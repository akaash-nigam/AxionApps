import Foundation

// MARK: - API Client

actor APIClient {
    private let session: URLSession
    private let baseURL: URL
    private var authToken: String?

    init(baseURL: URL) {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60

        self.session = URLSession(configuration: configuration)
        self.baseURL = baseURL
    }

    // MARK: - HTTP Methods

    func get<T: Decodable>(endpoint: String) async throws -> T {
        try await request(endpoint: endpoint, method: .get)
    }

    func post<T: Decodable, B: Encodable>(endpoint: String, body: B) async throws -> T {
        try await request(endpoint: endpoint, method: .post, body: body)
    }

    func put<B: Encodable>(endpoint: String, body: B) async throws {
        let _: EmptyResponse = try await request(endpoint: endpoint, method: .put, body: body)
    }

    func delete(endpoint: String) async throws {
        let _: EmptyResponse = try await request(endpoint: endpoint, method: .delete)
    }

    // MARK: - Request Implementation

    private func request<T: Decodable, B: Encodable>(
        endpoint: String,
        method: HTTPMethod,
        body: B? = nil as EmptyBody?
    ) async throws -> T {
        let url = baseURL.appendingPathComponent(endpoint)
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        // Add headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Add body if present
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }

        // Perform request
        let (data, response) = try await session.data(for: request)

        // Validate response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }

        // Decode response
        if T.self == EmptyResponse.self {
            return EmptyResponse() as! T
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(T.self, from: data)
    }

    // MARK: - Authentication

    func setAuthToken(_ token: String) {
        self.authToken = token
    }

    func clearAuthToken() {
        self.authToken = nil
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
    case decodingError(Error)
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let statusCode):
            return "HTTP error: \(statusCode)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

struct EmptyResponse: Codable {}
struct EmptyBody: Codable {}

// MARK: - Configuration

struct Configuration {
    static var apiBaseURL: URL {
        #if DEBUG
        return URL(string: "https://dev-api.sustainability.com")!
        #else
        return URL(string: "https://api.sustainability.com")!
        #endif
    }
}
