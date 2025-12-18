//
//  APIClient.swift
//  Construction Site Manager
//
//  HTTP API client for backend communication
//

import Foundation

/// HTTP API client with retry logic and error handling
final class APIClient: Sendable {
    private let baseURL: URL
    private let session: URLSession

    init(baseURL: String = "https://api.constructionsitemanager.com") {
        self.baseURL = URL(string: baseURL)!

        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 300
        configuration.waitsForConnectivity = true
        configuration.allowsCellularAccess = true

        // Request caching
        configuration.urlCache = URLCache(
            memoryCapacity: 50_000_000,    // 50 MB
            diskCapacity: 500_000_000       // 500 MB
        )
        configuration.requestCachePolicy = .returnCacheDataElseLoad

        self.session = URLSession(configuration: configuration)
    }

    /// Perform GET request
    func get<T: Decodable>(_ endpoint: String) async throws -> T {
        try await request(endpoint, method: .get)
    }

    /// Perform POST request
    func post<T: Decodable, B: Encodable>(_ endpoint: String, body: B) async throws -> T {
        try await request(endpoint, method: .post, body: body)
    }

    /// Perform PUT request
    func put<T: Decodable, B: Encodable>(_ endpoint: String, body: B) async throws -> T {
        try await request(endpoint, method: .put, body: body)
    }

    /// Perform DELETE request
    func delete(_ endpoint: String) async throws {
        let _: EmptyResponse = try await request(endpoint, method: .delete)
    }

    // MARK: - Private Methods

    private func request<T: Decodable, B: Encodable>(
        _ endpoint: String,
        method: HTTPMethod,
        body: B? = nil as EmptyBody?
    ) async throws -> T {
        let url = baseURL.appendingPathComponent(endpoint)

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("gzip, deflate", forHTTPHeaderField: "Accept-Encoding")

        // Add body if provided
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }

        // Retry logic: up to 3 attempts with exponential backoff
        var lastError: Error?
        for attempt in 1...3 {
            do {
                let (data, response) = try await session.data(for: request)

                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }

                // Check status code
                switch httpResponse.statusCode {
                case 200...299:
                    // Success
                    if T.self == EmptyResponse.self {
                        return EmptyResponse() as! T
                    }
                    return try JSONDecoder().decode(T.self, from: data)

                case 400:
                    throw APIError.badRequest
                case 401:
                    throw APIError.unauthorized
                case 403:
                    throw APIError.forbidden
                case 404:
                    throw APIError.notFound
                case 500...599:
                    throw APIError.serverError
                default:
                    throw APIError.unknownError(statusCode: httpResponse.statusCode)
                }

            } catch {
                lastError = error

                // Only retry on network errors
                if isNetworkError(error) && attempt < 3 {
                    let delay = pow(2.0, Double(attempt)) // Exponential backoff: 2s, 4s
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    continue
                } else {
                    throw error
                }
            }
        }

        throw lastError ?? APIError.unknownError(statusCode: 0)
    }

    private func isNetworkError(_ error: Error) -> Bool {
        if let urlError = error as? URLError {
            return [.networkConnectionLost, .notConnectedToInternet, .timedOut].contains(urlError.code)
        }
        return false
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

enum APIError: Error, LocalizedError {
    case invalidResponse
    case badRequest
    case unauthorized
    case forbidden
    case notFound
    case serverError
    case unknownError(statusCode: Int)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .badRequest:
            return "Bad request"
        case .unauthorized:
            return "Unauthorized - please log in"
        case .forbidden:
            return "Access forbidden"
        case .notFound:
            return "Resource not found"
        case .serverError:
            return "Server error - please try again later"
        case .unknownError(let statusCode):
            return "Unknown error (status code: \(statusCode))"
        }
    }
}

struct EmptyBody: Encodable {}
struct EmptyResponse: Decodable {}
