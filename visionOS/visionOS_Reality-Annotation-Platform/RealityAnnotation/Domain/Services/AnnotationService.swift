//
//  AnnotationService.swift
//  Reality Annotation Platform
//
//  Service for managing annotations (business logic)
//

import Foundation

/// Protocol for annotation business logic
protocol AnnotationService {
    /// Create a new annotation
    func createAnnotation(
        content: String,
        title: String?,
        type: AnnotationType,
        position: SIMD3<Float>,
        layerID: UUID
    ) async throws -> Annotation

    /// Fetch all annotations
    func fetchAnnotations() async throws -> [Annotation]

    /// Fetch annotations in a layer
    func fetchAnnotations(in layerID: UUID) async throws -> [Annotation]

    /// Fetch annotation by ID
    func fetchAnnotation(id: UUID) async throws -> Annotation?

    /// Update annotation
    func updateAnnotation(_ annotation: Annotation) async throws

    /// Delete annotation
    func deleteAnnotation(id: UUID) async throws

    /// Fetch nearby annotations
    func fetchNearby(position: SIMD3<Float>, radius: Float) async throws -> [Annotation]
}

// MARK: - Default Implementation

class DefaultAnnotationService: AnnotationService {
    private let repository: AnnotationRepository
    private let currentUserID: String

    init(repository: AnnotationRepository, currentUserID: String = "current-user") {
        self.repository = repository
        self.currentUserID = currentUserID
    }

    // MARK: - Create

    func createAnnotation(
        content: String,
        title: String?,
        type: AnnotationType,
        position: SIMD3<Float>,
        layerID: UUID
    ) async throws -> Annotation {
        // Validate content
        guard !content.isEmpty else {
            throw AnnotationError.emptyContent
        }

        // Create annotation
        let annotation = Annotation(
            type: type,
            title: title,
            contentText: content,
            position: position,
            layerID: layerID,
            ownerID: currentUserID
        )

        // Validate
        try annotation.validate()

        // Save
        try await repository.save(annotation)

        print("✅ Created annotation: \(annotation.id)")
        return annotation
    }

    // MARK: - Read

    func fetchAnnotations() async throws -> [Annotation] {
        let annotations = try await repository.fetchAll()
        return annotations.filter { !$0.isDeleted }
    }

    func fetchAnnotations(in layerID: UUID) async throws -> [Annotation] {
        return try await repository.fetchByLayer(layerID)
    }

    func fetchAnnotation(id: UUID) async throws -> Annotation? {
        return try await repository.fetch(id)
    }

    func fetchNearby(position: SIMD3<Float>, radius: Float) async throws -> [Annotation] {
        return try await repository.fetchNearby(position: position, radius: radius)
    }

    // MARK: - Update

    func updateAnnotation(_ annotation: Annotation) async throws {
        // Validate ownership
        guard annotation.ownerID == currentUserID else {
            throw AnnotationError.notOwner
        }

        // Update timestamp
        annotation.updatedAt = Date()
        annotation.syncStatus = "pending"

        // Validate
        try annotation.validate()

        // Save
        try await repository.save(annotation)

        print("✅ Updated annotation: \(annotation.id)")
    }

    // MARK: - Delete

    func deleteAnnotation(id: UUID) async throws {
        guard let annotation = try await repository.fetch(id) else {
            throw AnnotationError.notFound
        }

        // Validate ownership
        guard annotation.ownerID == currentUserID else {
            throw AnnotationError.notOwner
        }

        // Soft delete
        annotation.isDeleted = true
        annotation.deletedAt = Date()
        annotation.updatedAt = Date()
        annotation.syncStatus = "pending"

        try await repository.save(annotation)

        print("✅ Deleted annotation: \(id)")
    }
}

// MARK: - Annotation Errors

enum AnnotationError: LocalizedError {
    case emptyContent
    case notFound
    case notOwner
    case invalidData

    var errorDescription: String? {
        switch self {
        case .emptyContent:
            return "Annotation content cannot be empty"
        case .notFound:
            return "Annotation not found"
        case .notOwner:
            return "You don't have permission to modify this annotation"
        case .invalidData:
            return "Invalid annotation data"
        }
    }
}
