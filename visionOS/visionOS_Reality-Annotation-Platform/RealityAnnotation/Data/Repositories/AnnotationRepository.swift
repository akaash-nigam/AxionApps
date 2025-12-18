//
//  AnnotationRepository.swift
//  Reality Annotation Platform
//
//  Repository for annotation data access
//

import Foundation

/// Protocol for annotation data operations
protocol AnnotationRepository: Repository where Entity == Annotation {
    /// Fetch annotations by layer
    func fetchByLayer(_ layerID: UUID) async throws -> [Annotation]

    /// Fetch annotations by owner
    func fetchByOwner(_ ownerID: String) async throws -> [Annotation]

    /// Fetch annotations pending sync
    func fetchPendingSync() async throws -> [Annotation]

    /// Mark annotation as synced
    func markSynced(_ annotation: Annotation) async throws

    /// Fetch nearby annotations within radius
    func fetchNearby(position: SIMD3<Float>, radius: Float) async throws -> [Annotation]

    /// Count annotations for owner
    func count(for ownerID: String) async throws -> Int
}

// MARK: - Default Implementation

class DefaultAnnotationRepository: AnnotationRepository {
    private let localDataSource: LocalDataSource

    init(localDataSource: LocalDataSource) {
        self.localDataSource = localDataSource
    }

    // MARK: - Base Repository Methods

    func fetch(_ id: UUID) async throws -> Annotation? {
        return try await localDataSource.fetchAnnotation(id)
    }

    func fetchAll() async throws -> [Annotation] {
        return try await localDataSource.fetchAllAnnotations()
    }

    func save(_ entity: Annotation) async throws {
        try await localDataSource.saveAnnotation(entity)
    }

    func delete(_ id: UUID) async throws {
        try await localDataSource.deleteAnnotation(id)
    }

    // MARK: - Annotation-Specific Methods

    func fetchByLayer(_ layerID: UUID) async throws -> [Annotation] {
        return try await localDataSource.fetchAnnotations(layerID: layerID)
    }

    func fetchByOwner(_ ownerID: String) async throws -> [Annotation] {
        return try await localDataSource.fetchAnnotations(ownerID: ownerID)
    }

    func fetchPendingSync() async throws -> [Annotation] {
        let allAnnotations = try await fetchAll()
        return allAnnotations.filter { $0.isPendingSync }
    }

    func markSynced(_ annotation: Annotation) async throws {
        var updated = annotation
        updated.syncStatus = "synced"
        updated.updatedAt = Date()
        try await save(updated)
    }

    func fetchNearby(position: SIMD3<Float>, radius: Float) async throws -> [Annotation] {
        let allAnnotations = try await fetchAll()

        return allAnnotations.filter { annotation in
            let distance = simd_distance(annotation.position, position)
            return distance <= radius && !annotation.isDeleted
        }
    }

    func count(for ownerID: String) async throws -> Int {
        let annotations = try await fetchByOwner(ownerID)
        return annotations.filter { !$0.isDeleted }.count
    }
}
