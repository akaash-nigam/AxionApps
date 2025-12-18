//
//  APIClient.swift
//  Financial Operations Platform
//
//  Network API client for backend communication
//

import Foundation

// MARK: - API Client

actor APIClient {
    // MARK: - Singleton

    static let shared = APIClient()

    // MARK: - Properties

    private let baseURL: URL
    private let session: URLSession
    private var authToken: String?

    // MARK: - Initialization

    private init(
        baseURL: String = "https://api.finops.example.com",
        configuration: URLSessionConfiguration = .default
    ) {
        self.baseURL = URL(string: baseURL)!

        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 300
        configuration.waitsForConnectivity = true

        self.session = URLSession(configuration: configuration)
    }

    // MARK: - Authentication

    func setAuthToken(_ token: String) {
        self.authToken = token
    }

    func clearAuthToken() {
        self.authToken = nil
    }

    // MARK: - Request Methods

    func request<T: Decodable>(
        _ endpoint: APIEndpoint,
        method: HTTPMethod = .get,
        body: (any Encodable)? = nil
    ) async throws -> T {
        var request = URLRequest(url: baseURL.appendingPathComponent(endpoint.path))
        request.httpMethod = method.rawValue

        // Add headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

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
            throw APIError.httpError(statusCode: httpResponse.statusCode, data: data)
        }

        // Decode response
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }

    // MARK: - Upload

    func upload<T: Decodable>(
        _ endpoint: APIEndpoint,
        data: Data,
        fileName: String,
        mimeType: String
    ) async throws -> T {
        var request = URLRequest(url: baseURL.appendingPathComponent(endpoint.path))
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Create multipart body
        var body = Data()

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        let (responseData, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(statusCode: httpResponse.statusCode, data: responseData)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(T.self, from: responseData)
    }

    // MARK: - Download

    func download(_ endpoint: APIEndpoint) async throws -> Data {
        var request = URLRequest(url: baseURL.appendingPathComponent(endpoint.path))

        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(statusCode: httpResponse.statusCode, data: data)
        }

        return data
    }
}

// MARK: - HTTP Method

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

// MARK: - API Endpoint

enum APIEndpoint {
    case transactions(dateRange: DateInterval, accounts: [String]?)
    case postTransaction(FinancialTransaction)
    case cashPosition(region: String?)
    case forecast(period: DateInterval)
    case kpis(category: KPICategory?)
    case risks
    case closeTasks(period: ClosePeriod)

    var path: String {
        switch self {
        case .transactions(let dateRange, let accounts):
            var path = "/api/v1/transactions?"
            path += "start=\(dateRange.start.ISO8601Format())"
            path += "&end=\(dateRange.end.ISO8601Format())"
            if let accounts = accounts, !accounts.isEmpty {
                path += "&accounts=\(accounts.joined(separator: ","))"
            }
            return path

        case .postTransaction:
            return "/api/v1/transactions"

        case .cashPosition(let region):
            var path = "/api/v1/treasury/cash-position"
            if let region = region {
                path += "?region=\(region)"
            }
            return path

        case .forecast(let period):
            return "/api/v1/treasury/forecast?start=\(period.start.ISO8601Format())&end=\(period.end.ISO8601Format())"

        case .kpis(let category):
            var path = "/api/v1/kpis"
            if let category = category {
                path += "?category=\(category.rawValue)"
            }
            return path

        case .risks:
            return "/api/v1/risks"

        case .closeTasks(let period):
            return "/api/v1/close/\(period.year)/\(period.month)/tasks"
        }
    }
}

// MARK: - API Error

enum APIError: LocalizedError {
    case invalidResponse
    case httpError(statusCode: Int, data: Data?)
    case decodingError(Error)
    case encodingError(Error)
    case networkError(Error)
    case unauthorized
    case serverError

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let statusCode, _):
            return "HTTP error: \(statusCode)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .encodingError(let error):
            return "Failed to encode request: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .unauthorized:
            return "Unauthorized - please log in"
        case .serverError:
            return "Server error - please try again later"
        }
    }
}

// MARK: - Mock API Client

actor MockAPIClient {
    func request<T: Decodable>(
        _ endpoint: APIEndpoint,
        method: HTTPMethod = .get,
        body: (any Encodable)? = nil
    ) async throws -> T {
        // Return mock data for testing
        // This would be replaced with actual mock implementations
        throw APIError.serverError
    }
}
