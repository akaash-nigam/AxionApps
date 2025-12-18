//
//  MockAnnotationRepository.swift
//  Reality Annotation Platform Tests
//
//  Mock repository for testing
//

import Foundation
@testable import RealityAnnotation

class MockAnnotationRepository: AnnotationRepository {
    var annotations: [Annotation] = []
    var shouldThrowError = false
    var errorToThrow: Error = RepositoryError.notFound

    // MARK: - Base Methods

    func fetch(_ id: UUID) async throws -> Annotation? {
        if shouldThrowError {
            throw errorToThrow
        }
        return annotations.first { $0.id == id }
    }

    func fetchAll() async throws -> [Annotation] {
        if shouldThrowError {
            throw errorToThrow
        }
        return annotations
    }

    func save(_ entity: Annotation) async throws {
        if shouldThrowError {
            throw errorToThrow
        }

        // Update existing or add new
        if let index = annotations.firstIndex(where: { $0.id == entity.id }) {
            annotations[index] = entity
        } else {
            annotations.append(entity)
        }
    }

    func delete(_ id: UUID) async throws {
        if shouldThrowError {
            throw errorToThrow
        }
        annotations.removeAll { $0.id == id }
    }

    // MARK: - Annotation-Specific Methods

    func fetchByLayer(_ layerID: UUID) async throws -> [Annotation] {
        if shouldThrowError {
            throw errorToThrow
        }
        return annotations.filter { $0.layerID == layerID && !$0.isDeleted }
    }

    func fetchByOwner(_ ownerID: String) async throws -> [Annotation] {
        if shouldThrowError {
            throw errorToThrow
        }
        return annotations.filter { $0.ownerID == ownerID && !$0.isDeleted }
    }

    func fetchPendingSync() async throws -> [Annotation] {
        if shouldThrowError {
            throw errorToThrow
        }
        return annotations.filter { $0.isPendingSync }
    }

    func markSynced(_ annotation: Annotation) async throws {
        if shouldThrowError {
            throw errorToThrow
        }
        annotation.syncStatus = "synced"
        try await save(annotation)
    }

    func fetchNearby(position: SIMD3<Float>, radius: Float) async throws -> [Annotation] {
        if shouldThrowError {
            throw errorToThrow
        }
        return annotations.filter { annotation in
            let distance = simd_distance(annotation.position, position)
            return distance <= radius && !annotation.isDeleted
        }
    }

    func count(for ownerID: String) async throws -> Int {
        if shouldThrowError {
            throw errorToThrow
        }
        return try await fetchByOwner(ownerID).count
    }
}
