//
//  MockLayerRepository.swift
//  Reality Annotation Platform Tests
//
//  Mock layer repository for testing
//

import Foundation
@testable import RealityAnnotation

class MockLayerRepository: LayerRepository {
    var layers: [Layer] = []
    var shouldThrowError = false
    var errorToThrow: Error = RepositoryError.notFound

    // MARK: - Base Methods

    func fetch(_ id: UUID) async throws -> Layer? {
        if shouldThrowError {
            throw errorToThrow
        }
        return layers.first { $0.id == id }
    }

    func fetchAll() async throws -> [Layer] {
        if shouldThrowError {
            throw errorToThrow
        }
        return layers
    }

    func save(_ entity: Layer) async throws {
        if shouldThrowError {
            throw errorToThrow
        }

        // Update existing or add new
        if let index = layers.firstIndex(where: { $0.id == entity.id }) {
            layers[index] = entity
        } else {
            layers.append(entity)
        }
    }

    func delete(_ id: UUID) async throws {
        if shouldThrowError {
            throw errorToThrow
        }
        layers.removeAll { $0.id == id }
    }

    // MARK: - Layer-Specific Methods

    func fetchByOwner(_ ownerID: String) async throws -> [Layer] {
        if shouldThrowError {
            throw errorToThrow
        }
        return layers.filter { $0.ownerID == ownerID && !$0.isDeleted }
    }

    func getOrCreateDefaultLayer(for ownerID: String) async throws -> Layer {
        if shouldThrowError {
            throw errorToThrow
        }

        // Try to find existing
        if let existing = layers.first(where: { $0.ownerID == ownerID }) {
            return existing
        }

        // Create new
        let layer = Layer(
            name: "My Notes",
            icon: "note.text",
            color: .blue,
            ownerID: ownerID
        )
        try await save(layer)
        return layer
    }

    func count(for ownerID: String) async throws -> Int {
        if shouldThrowError {
            throw errorToThrow
        }
        return try await fetchByOwner(ownerID).count
    }
}
