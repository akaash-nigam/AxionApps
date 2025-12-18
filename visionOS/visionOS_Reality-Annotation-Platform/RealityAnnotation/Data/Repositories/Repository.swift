//
//  Repository.swift
//  Reality Annotation Platform
//
//  Base repository protocol
//

import Foundation

/// Base protocol for all repositories
protocol Repository {
    associatedtype Entity: Identifiable

    /// Fetch entity by ID
    func fetch(_ id: Entity.ID) async throws -> Entity?

    /// Fetch all entities
    func fetchAll() async throws -> [Entity]

    /// Save entity (insert or update)
    func save(_ entity: Entity) async throws

    /// Delete entity by ID
    func delete(_ id: Entity.ID) async throws
}

// MARK: - Repository Errors

enum RepositoryError: LocalizedError {
    case notFound
    case saveFailed(Error)
    case deleteFailed(Error)
    case fetchFailed(Error)

    var errorDescription: String? {
        switch self {
        case .notFound:
            return "Item not found"
        case .saveFailed(let error):
            return "Failed to save: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "Failed to delete: \(error.localizedDescription)"
        case .fetchFailed(let error):
            return "Failed to fetch: \(error.localizedDescription)"
        }
    }
}
