import Foundation

/// Network client for API communication
actor NetworkClient {
    private let session: URLSession
    private let configuration: NetworkConfiguration
    private var authToken: String?

    init(configuration: NetworkConfiguration) {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = configuration.timeout
        sessionConfig.timeoutIntervalForResource = 300
        sessionConfig.waitsForConnectivity = true

        self.session = URLSession(configuration: sessionConfig)
        self.configuration = configuration
    }

    func configure() async throws {
        // Perform initial configuration (auth, etc.)
    }

    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        let request = try buildRequest(endpoint)
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601

        return try decoder.decode(T.self, from: data)
    }

    private func buildRequest(_ endpoint: APIEndpoint) throws -> URLRequest {
        let url = configuration.baseURL.appendingPathComponent(endpoint.path)
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method

        // Add headers
        for (key, value) in configuration.headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Add body for POST/PUT requests
        if let body = endpoint.body {
            request.httpBody = try JSONEncoder().encode(body)
        }

        return request
    }

    func setAuthToken(_ token: String) {
        authToken = token
    }
}

enum NetworkError: Error {
    case invalidResponse
    case httpError(Int)
    case decodingError
    case encodingError
    case noData
}
