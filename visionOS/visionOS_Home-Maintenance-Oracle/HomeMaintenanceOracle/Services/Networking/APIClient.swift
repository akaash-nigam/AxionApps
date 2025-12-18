//
//  APIClient.swift
//  HomeMaintenanceOracle
//
//  Created on 2025-11-24.
//

import Foundation

protocol APIClient {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}

class URLSessionAPIClient: APIClient {
    private let baseURL: URL
    private let session: URLSession

    init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        // TODO: Implement API request
        throw APIError.notImplemented
    }
}

enum Endpoint {
    case manualSearch(brand: String, model: String)
}

enum APIError: Error {
    case notImplemented
    case networkError(Error)
    case invalidResponse
}
