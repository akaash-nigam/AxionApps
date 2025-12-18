//
//  LayerRepository.swift
//  Reality Annotation Platform
//
//  Repository for layer data access
//

import Foundation

/// Protocol for layer data operations
protocol LayerRepository: Repository where Entity == Layer {
    /// Fetch layers by owner
    func fetchByOwner(_ ownerID: String) async throws -> [Layer]

    /// Fetch default layer for user (create if doesn't exist)
    func getOrCreateDefaultLayer(for ownerID: String) async throws -> Layer

    /// Count layers for owner
    func count(for ownerID: String) async throws -> Int
}

// MARK: - Default Implementation

class DefaultLayerRepository: LayerRepository {
    private let localDataSource: LocalDataSource

    init(localDataSource: LocalDataSource) {
        self.localDataSource = localDataSource
    }

    // MARK: - Base Repository Methods

    func fetch(_ id: UUID) async throws -> Layer? {
        return try await localDataSource.fetchLayer(id)
    }

    func fetchAll() async throws -> [Layer] {
        return try await localDataSource.fetchAllLayers()
    }

    func save(_ entity: Layer) async throws {
        try await localDataSource.saveLayer(entity)
    }

    func delete(_ id: UUID) async throws {
        try await localDataSource.deleteLayer(id)
    }

    // MARK: - Layer-Specific Methods

    func fetchByOwner(_ ownerID: String) async throws -> [Layer] {
        let allLayers = try await fetchAll()
        return allLayers.filter { $0.ownerID == ownerID && !$0.isDeleted }
    }

    func getOrCreateDefaultLayer(for ownerID: String) async throws -> Layer {
        // Try to find existing default layer
        let existingLayers = try await fetchByOwner(ownerID)

        if let defaultLayer = existingLayers.first {
            return defaultLayer
        }

        // Create default layer
        let defaultLayer = Layer(
            name: "My Notes",
            icon: "note.text",
            color: .blue,
            ownerID: ownerID
        )

        try await save(defaultLayer)
        return defaultLayer
    }

    func count(for ownerID: String) async throws -> Int {
        let layers = try await fetchByOwner(ownerID)
        return layers.count
    }
}
