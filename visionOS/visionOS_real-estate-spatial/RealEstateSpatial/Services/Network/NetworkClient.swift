//
//  NetworkClient.swift
//  RealEstateSpatial
//
//  Network client for API requests
//

import Foundation

// MARK: - API Endpoint Protocol

protocol APIEndpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String] { get }
    var body: Data? { get }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

// MARK: - Network Client

actor NetworkClient {
    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private var authToken: String?

    init(baseURL: URL) {
        self.baseURL = baseURL

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 300
        config.waitsForConnectivity = true
        config.httpAdditionalHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]

        self.session = URLSession(configuration: config)
        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()

        // Configure date encoding/decoding
        decoder.dateDecodingStrategy = .iso8601
        encoder.dateEncodingStrategy = .iso8601
    }

    func setAuthToken(_ token: String) {
        authToken = token
    }

    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        let url = baseURL.appendingPathComponent(endpoint.path)
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body

        // Add headers
        for (key, value) in endpoint.headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        // Add auth token
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200...299:
            return try decoder.decode(T.self, from: data)
        case 401:
            throw NetworkError.unauthorized
        case 404:
            throw NetworkError.notFound
        case 500...599:
            throw NetworkError.serverError
        default:
            throw NetworkError.unknown(httpResponse.statusCode)
        }
    }

    func upload(data: Data, to endpoint: APIEndpoint) async throws -> Data {
        let url = baseURL.appendingPathComponent(endpoint.path)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        // Add auth token
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (responseData, response) = try await session.upload(for: request, from: data)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.uploadFailed
        }

        return responseData
    }

    func download(from url: URL) async throws -> URL {
        let (tempURL, response) = try await session.download(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.downloadFailed
        }

        return tempURL
    }
}

// MARK: - Network Errors

enum NetworkError: Error, LocalizedError {
    case invalidResponse
    case unauthorized
    case notFound
    case serverError
    case unknown(Int)
    case uploadFailed
    case downloadFailed
    case noConnection

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .unauthorized:
            return "Unauthorized. Please sign in again."
        case .notFound:
            return "Resource not found"
        case .serverError:
            return "Server error. Please try again later."
        case .unknown(let code):
            return "Unknown error (code: \(code))"
        case .uploadFailed:
            return "Upload failed"
        case .downloadFailed:
            return "Download failed"
        case .noConnection:
            return "No internet connection"
        }
    }
}

// MARK: - Property Endpoints

enum PropertyEndpoint: APIEndpoint {
    case search(SearchQuery)
    case detail(UUID)
    case nearby(GeographicCoordinate, radius: Double)
    case trending(String)
    case create(Property)
    case update(UUID, Property)
    case delete(UUID)

    var path: String {
        switch self {
        case .search:
            return "/api/v1/properties/search"
        case .detail(let id):
            return "/api/v1/properties/\(id)"
        case .nearby:
            return "/api/v1/properties/nearby"
        case .trending:
            return "/api/v1/properties/trending"
        case .create:
            return "/api/v1/properties"
        case .update(let id, _):
            return "/api/v1/properties/\(id)"
        case .delete(let id):
            return "/api/v1/properties/\(id)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .search, .detail, .nearby, .trending:
            return .get
        case .create:
            return .post
        case .update:
            return .put
        case .delete:
            return .delete
        }
    }

    var headers: [String: String] {
        ["Content-Type": "application/json"]
    }

    var body: Data? {
        switch self {
        case .create(let property), .update(_, let property):
            return try? JSONEncoder().encode(property)
        case .search(let query):
            return try? JSONEncoder().encode(query)
        default:
            return nil
        }
    }
}

// MARK: - Mock Network Client for Testing

final class MockNetworkClient: NetworkClient {
    var mockProperties: [Property] = []
    var shouldFail: Bool = false

    init() {
        super.init(baseURL: URL(string: "https://mock.api.com")!)
    }

    override func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        if shouldFail {
            throw NetworkError.serverError
        }

        // Return mock data
        if T.self == [Property].self {
            return mockProperties as! T
        }

        throw NetworkError.invalidResponse
    }
}
