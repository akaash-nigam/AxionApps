//
//  OutfitRepository.swift
//  WardrobeConsultant
//
//  Created by Claude Code
//  Copyright © 2025 Wardrobe Consultant. All rights reserved.
//

import Foundation

/// Protocol for outfit data access
protocol OutfitRepository {
    // MARK: - CRUD Operations
    func fetch(id: UUID) async throws -> Outfit
    func fetchAll() async throws -> [Outfit]
    func create(_ outfit: Outfit) async throws -> Outfit
    func update(_ outfit: Outfit) async throws -> Outfit
    func delete(id: UUID) async throws

    // MARK: - Query Operations
    func fetchByOccasion(_ occasion: OccasionType) async throws -> [Outfit]
    func fetchFavorites() async throws -> [Outfit]
    func fetchRecent(limit: Int) async throws -> [Outfit]
    func fetchByWeather(min: Int16, max: Int16) async throws -> [Outfit]

    // MARK: - Statistics
    func count() async throws -> Int
    func getMostWorn(limit: Int) async throws -> [Outfit]
}

/// Errors that can occur during outfit repository operations
enum OutfitRepositoryError: Error {
    case outfitNotFound(UUID)
    case invalidOutfit
    case saveFailed(Error)
    case deleteFailed(Error)
    case fetchFailed(Error)

    var localizedDescription: String {
        switch self {
        case .outfitNotFound(let id):
            return "Outfit with ID \(id) not found"
        case .invalidOutfit:
            return "Invalid outfit"
        case .saveFailed(let error):
            return "Failed to save outfit: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "Failed to delete outfit: \(error.localizedDescription)"
        case .fetchFailed(let error):
            return "Failed to fetch outfits: \(error.localizedDescription)"
        }
    }
}
