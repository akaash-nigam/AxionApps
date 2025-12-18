//
//  ManualService.swift
//  HomeMaintenanceOracle
//
//  Created on 2025-11-24.
//

import Foundation

protocol ManualServiceProtocol {
    func searchManuals(brand: String, model: String) async throws -> [Manual]
    func downloadManual(_ manual: Manual) async throws -> URL
}

class ManualService: ManualServiceProtocol {
    private let apiClient: APIClient
    private let cacheManager: CacheManager

    init(apiClient: APIClient, cacheManager: CacheManager) {
        self.apiClient = apiClient
        self.cacheManager = cacheManager
    }

    func searchManuals(brand: String, model: String) async throws -> [Manual] {
        // TODO: Implement API call
        return []
    }

    func downloadManual(_ manual: Manual) async throws -> URL {
        // TODO: Implement download
        throw NSError(domain: "ManualService", code: -1, userInfo: nil)
    }
}

class MockManualService: ManualServiceProtocol {
    func searchManuals(brand: String, model: String) async throws -> [Manual] {
        return []
    }

    func downloadManual(_ manual: Manual) async throws -> URL {
        return URL(fileURLWithPath: "/tmp/manual.pdf")
    }
}

struct Manual: Identifiable {
    let id: String
    let title: String
    let downloadURL: URL
}
