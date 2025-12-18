import Foundation

// MARK: - API Client
actor APIClient {
    // MARK: - Properties
    private let session: URLSession
    private let baseURL: URL
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private var authToken: String?

    // MARK: - Initialization
    init(baseURL: URL) {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 300
        config.waitsForConnectivity = true
        config.requestCachePolicy = .reloadIgnoringLocalCacheData

        self.session = URLSession(configuration: config)
        self.baseURL = baseURL
        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()

        // Configure date decoding
        decoder.dateDecodingStrategy = .iso8601
        encoder.dateEncodingStrategy = .iso8601
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
        body: Data? = nil,
        queryItems: [URLQueryItem]? = nil
    ) async throws -> T {
        var urlComponents = URLComponents(url: baseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = queryItems

        guard let url = urlComponents?.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body

        // Add headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw APIError.httpError(statusCode: httpResponse.statusCode, data: data)
            }

            return try decoder.decode(T.self, from: data)
        } catch let error as DecodingError {
            throw APIError.decodingError(error)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }

    // MARK: - Specialized Methods
    func get<T: Decodable>(_ endpoint: APIEndpoint, queryItems: [URLQueryItem]? = nil) async throws -> T {
        try await request(endpoint, method: .get, queryItems: queryItems)
    }

    func post<T: Decodable, U: Encodable>(_ endpoint: APIEndpoint, body: U) async throws -> T {
        let data = try encoder.encode(body)
        return try await request(endpoint, method: .post, body: data)
    }

    func put<T: Decodable, U: Encodable>(_ endpoint: APIEndpoint, body: U) async throws -> T {
        let data = try encoder.encode(body)
        return try await request(endpoint, method: .put, body: data)
    }

    func delete<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        try await request(endpoint, method: .delete)
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
    case employees(filter: EmployeeFilter?)
    case employee(id: UUID)
    case createEmployee
    case updateEmployee(id: UUID)
    case deleteEmployee(id: UUID)

    case departments
    case department(id: UUID)

    case teams
    case team(id: UUID)

    case analytics
    case predictions(type: PredictionType)

    case search(query: String)

    var path: String {
        switch self {
        case .employees:
            return "/employees"
        case .employee(let id):
            return "/employees/\(id.uuidString)"
        case .createEmployee:
            return "/employees"
        case .updateEmployee(let id):
            return "/employees/\(id.uuidString)"
        case .deleteEmployee(let id):
            return "/employees/\(id.uuidString)"

        case .departments:
            return "/departments"
        case .department(let id):
            return "/departments/\(id.uuidString)"

        case .teams:
            return "/teams"
        case .team(let id):
            return "/teams/\(id.uuidString)"

        case .analytics:
            return "/analytics"
        case .predictions(let type):
            return "/predictions/\(type.rawValue)"

        case .search:
            return "/search"
        }
    }
}

// MARK: - API Error
enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int, data: Data?)
    case networkError(Error)
    case decodingError(DecodingError)
    case encodingError(EncodingError)
    case unauthorized
    case notFound
    case serverError
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid server response"
        case .httpError(let code, _):
            return "HTTP error: \(code)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .encodingError(let error):
            return "Encoding error: \(error.localizedDescription)"
        case .unauthorized:
            return "Unauthorized access"
        case .notFound:
            return "Resource not found"
        case .serverError:
            return "Server error"
        case .unknown:
            return "Unknown error"
        }
    }
}

// MARK: - Employee Filter
struct EmployeeFilter: Codable {
    var departmentId: UUID?
    var teamId: UUID?
    var searchQuery: String?
    var level: JobLevel?
    var location: String?
    var isActive: Bool?

    func asQueryItems() -> [URLQueryItem] {
        var items: [URLQueryItem] = []

        if let departmentId = departmentId {
            items.append(URLQueryItem(name: "department", value: departmentId.uuidString))
        }
        if let teamId = teamId {
            items.append(URLQueryItem(name: "team", value: teamId.uuidString))
        }
        if let searchQuery = searchQuery {
            items.append(URLQueryItem(name: "q", value: searchQuery))
        }
        if let level = level {
            items.append(URLQueryItem(name: "level", value: level.rawValue))
        }
        if let location = location {
            items.append(URLQueryItem(name: "location", value: location))
        }
        if let isActive = isActive {
            items.append(URLQueryItem(name: "active", value: String(isActive)))
        }

        return items
    }
}

// MARK: - Prediction Type
enum PredictionType: String, Codable {
    case attrition = "attrition"
    case performance = "performance"
    case promotion = "promotion"
    case talentGaps = "talent-gaps"
}

// MARK: - Network Client (for advanced features)
actor NetworkClient {
    private let monitor = NetworkMonitor.shared

    func isConnected() -> Bool {
        monitor.isConnected
    }

    func connectionType() -> ConnectionType? {
        monitor.connectionType
    }
}

// MARK: - Network Monitor
@Observable
final class NetworkMonitor {
    static let shared = NetworkMonitor()

    var isConnected: Bool = true
    var connectionType: ConnectionType? = .wifi

    private init() {
        // In a real app, use NWPathMonitor from Network framework
        // For now, assume connected
    }
}

// MARK: - Connection Type
enum ConnectionType {
    case wifi
    case cellular
    case wired
    case other
}
