//
//  NetworkService.swift
//  SupplyChainControlTower
//
//  Service for fetching and managing network data
//

import Foundation

/// Service for managing supply chain network data
@Observable
class NetworkService {

    // MARK: - Properties

    private let apiClient: APIClient
    private let cacheManager: CacheManager

    // MARK: - Initialization

    init(apiClient: APIClient = APIClient(), cacheManager: CacheManager = CacheManager()) {
        self.apiClient = apiClient
        self.cacheManager = cacheManager
    }

    // MARK: - Public Methods

    /// Fetch the complete supply chain network
    func fetchNetwork() async throws -> SupplyChainNetwork {
        // Try to get from cache first
        if let cached: SupplyChainNetwork = await cacheManager.get(forKey: "network") {
            return cached
        }

        // Fetch from API
        let network: SupplyChainNetwork = try await apiClient.fetch(endpoint: .getNetwork)

        // Cache for 1 hour
        await cacheManager.set(network, forKey: "network", ttl: 3600)

        return network
    }

    /// Fetch active shipments
    func fetchShipments() async throws -> [Flow] {
        try await apiClient.fetch(endpoint: .getShipments)
    }

    /// Fetch active disruptions
    func fetchDisruptions() async throws -> [Disruption] {
        try await apiClient.fetch(endpoint: .getDisruptions)
    }

    /// Update a shipment status
    func updateShipment(_ shipmentId: String, status: FlowStatus) async throws {
        try await apiClient.update(endpoint: .updateShipment(shipmentId), data: ["status": status.rawValue])
    }
}

// MARK: - API Client

/// Client for making API requests
class APIClient {

    private let baseURL = URL(string: "https://api.supplychain.example.com")!
    private let session: URLSession

    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: configuration)
    }

    func fetch<T: Decodable>(endpoint: Endpoint) async throws -> T {
        let request = try buildRequest(endpoint)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }

    func update(endpoint: Endpoint, data: [String: Any]) async throws {
        var request = try buildRequest(endpoint)
        request.httpMethod = "PUT"
        request.httpBody = try JSONSerialization.data(withJSONObject: data)

        let (_, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }
    }

    private func buildRequest(_ endpoint: Endpoint) throws -> URLRequest {
        let url = baseURL.appendingPathComponent(endpoint.path)
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // TODO: Add authentication headers

        return request
    }
}

// MARK: - Endpoint

enum Endpoint {
    case getNetwork
    case getShipments
    case getDisruptions
    case updateShipment(String)

    var path: String {
        switch self {
        case .getNetwork: return "/api/v1/network"
        case .getShipments: return "/api/v1/shipments"
        case .getDisruptions: return "/api/v1/disruptions"
        case .updateShipment(let id): return "/api/v1/shipments/\(id)"
        }
    }

    var method: String {
        switch self {
        case .getNetwork, .getShipments, .getDisruptions: return "GET"
        case .updateShipment: return "PUT"
        }
    }
}

// MARK: - API Error

enum APIError: Error, LocalizedError {
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

// MARK: - Cache Manager

actor CacheManager {
    private var cache: [String: CacheEntry] = [:]

    func set<T: Codable>(_ value: T, forKey key: String, ttl: TimeInterval) {
        cache[key] = CacheEntry(value: value, expiresAt: Date().addingTimeInterval(ttl))
    }

    func get<T: Codable>(forKey key: String) -> T? {
        guard let entry = cache[key],
              entry.expiresAt > Date(),
              let value = entry.value as? T else {
            return nil
        }
        return value
    }

    func invalidate(key: String) {
        cache.removeValue(forKey: key)
    }

    func invalidateAll() {
        cache.removeAll()
    }
}

struct CacheEntry {
    let value: Any
    let expiresAt: Date
}
