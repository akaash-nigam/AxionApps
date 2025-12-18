//
//  WardrobeRepository.swift
//  WardrobeConsultant
//
//  Created by Claude Code
//  Copyright © 2025 Wardrobe Consultant. All rights reserved.
//

import Foundation

/// Protocol for wardrobe item data access
protocol WardrobeRepository {
    // MARK: - CRUD Operations
    func fetch(id: UUID) async throws -> WardrobeItem
    func fetchAll() async throws -> [WardrobeItem]
    func create(_ item: WardrobeItem) async throws -> WardrobeItem
    func update(_ item: WardrobeItem) async throws -> WardrobeItem
    func delete(id: UUID) async throws

    // MARK: - Query Operations
    func fetchByCategory(_ category: ClothingCategory) async throws -> [WardrobeItem]
    func fetchBySeason(_ season: Season) async throws -> [WardrobeItem]
    func fetchByColor(_ color: String) async throws -> [WardrobeItem]
    func fetchFavorites() async throws -> [WardrobeItem]
    func search(query: String) async throws -> [WardrobeItem]

    // MARK: - Statistics
    func count() async throws -> Int
    func getRecentlyAdded(limit: Int) async throws -> [WardrobeItem]
    func getMostWorn(limit: Int) async throws -> [WardrobeItem]
    func getLeastWorn(limit: Int) async throws -> [WardrobeItem]
}

/// Errors that can occur during wardrobe repository operations
enum WardrobeRepositoryError: Error {
    case itemNotFound(UUID)
    case invalidItem
    case saveFailed(Error)
    case deleteFailed(Error)
    case fetchFailed(Error)

    var localizedDescription: String {
        switch self {
        case .itemNotFound(let id):
            return "Wardrobe item with ID \(id) not found"
        case .invalidItem:
            return "Invalid wardrobe item"
        case .saveFailed(let error):
            return "Failed to save wardrobe item: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "Failed to delete wardrobe item: \(error.localizedDescription)"
        case .fetchFailed(let error):
            return "Failed to fetch wardrobe items: \(error.localizedDescription)"
        }
    }
}
