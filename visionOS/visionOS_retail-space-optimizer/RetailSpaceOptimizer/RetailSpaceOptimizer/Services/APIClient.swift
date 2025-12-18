import Foundation

actor APIClient {
    private let baseURL: URL
    private let session: URLSession

    init(baseURL: URL) {
        self.baseURL = baseURL

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 300
        config.waitsForConnectivity = true

        self.session = URLSession(configuration: config)
    }

    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let url = baseURL.appendingPathComponent(endpoint.path)
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body

        for (key, value) in endpoint.headers {
            request.addValue(value, forHTTPHeaderField: key)
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(httpResponse.statusCode)
        }

        return try JSONDecoder().decode(T.self, from: data)
    }

    func upload<T: Decodable>(
        _ endpoint: Endpoint,
        data: Data
    ) async throws -> T {
        let url = baseURL.appendingPathComponent(endpoint.path)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        for (key, value) in endpoint.headers {
            request.addValue(value, forHTTPHeaderField: key)
        }

        let (responseData, response) = try await session.upload(for: request, from: data)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(httpResponse.statusCode)
        }

        return try JSONDecoder().decode(T.self, from: responseData)
    }
}

// MARK: - Endpoint

enum Endpoint {
    case stores
    case store(id: UUID)
    case createStore(Store)
    case updateStore(UUID, Store)
    case deleteStore(UUID)
    case layouts(storeId: UUID)
    case fixtures
    case products(category: String?)
    case analytics(storeId: UUID, dateRange: DateInterval)
    case simulation(layoutId: UUID, params: SimulationParams)

    var path: String {
        switch self {
        case .stores:
            return "/api/v1/stores"
        case .store(let id):
            return "/api/v1/stores/\(id.uuidString)"
        case .createStore:
            return "/api/v1/stores"
        case .updateStore(let id, _):
            return "/api/v1/stores/\(id.uuidString)"
        case .deleteStore(let id):
            return "/api/v1/stores/\(id.uuidString)"
        case .layouts(let storeId):
            return "/api/v1/stores/\(storeId.uuidString)/layouts"
        case .fixtures:
            return "/api/v1/fixtures"
        case .products(let category):
            if let category = category {
                return "/api/v1/products?category=\(category)"
            }
            return "/api/v1/products"
        case .analytics(let storeId, _):
            return "/api/v1/stores/\(storeId.uuidString)/analytics"
        case .simulation(let layoutId, _):
            return "/api/v1/layouts/\(layoutId.uuidString)/simulate"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .stores, .store, .layouts, .fixtures, .products, .analytics:
            return .get
        case .createStore, .simulation:
            return .post
        case .updateStore:
            return .put
        case .deleteStore:
            return .delete
        }
    }

    var headers: [String: String] {
        var headers = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]

        // Add authorization header if needed
        // headers["Authorization"] = "Bearer \(token)"

        return headers
    }

    var body: Data? {
        switch self {
        case .createStore(let store), .updateStore(_, let store):
            return try? JSONEncoder().encode(store)
        case .simulation(_, let params):
            return try? JSONEncoder().encode(params)
        default:
            return nil
        }
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

// MARK: - API Error

enum APIError: LocalizedError {
    case invalidResponse
    case httpError(Int)
    case decodingError
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .decodingError:
            return "Failed to decode response"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

// MARK: - Simulation Params

struct SimulationParams: Codable {
    var duration: TimeInterval
    var customerCount: Int
    var personas: [CustomerPersona]
}
