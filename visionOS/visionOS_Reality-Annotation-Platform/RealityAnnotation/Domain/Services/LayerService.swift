//
//  LayerService.swift
//  Reality Annotation Platform
//
//  Service for managing layers (business logic)
//

import Foundation

/// Protocol for layer business logic
protocol LayerService {
    /// Create a new layer
    func createLayer(name: String, icon: String, color: LayerColor) async throws -> Layer

    /// Fetch all layers for current user
    func fetchLayers() async throws -> [Layer]

    /// Fetch layer by ID
    func fetchLayer(id: UUID) async throws -> Layer?

    /// Update layer
    func updateLayer(_ layer: Layer) async throws

    /// Delete layer
    func deleteLayer(id: UUID) async throws

    /// Get or create default layer
    func getDefaultLayer() async throws -> Layer

    /// Toggle layer visibility
    func setLayerVisible(_ layerID: UUID, visible: Bool) async throws
}

// MARK: - Default Implementation

class DefaultLayerService: LayerService {
    private let repository: LayerRepository
    private let annotationRepository: AnnotationRepository
    private let currentUserID: String

    init(
        repository: LayerRepository,
        annotationRepository: AnnotationRepository,
        currentUserID: String = "current-user"
    ) {
        self.repository = repository
        self.annotationRepository = annotationRepository
        self.currentUserID = currentUserID
    }

    // MARK: - Create

    func createLayer(name: String, icon: String, color: LayerColor) async throws -> Layer {
        // Validate name
        guard !name.isEmpty else {
            throw LayerError.emptyName
        }

        guard name.count <= 50 else {
            throw LayerError.nameTooLong
        }

        // For MVP: Free tier gets 1 layer only
        // Check if user already has a layer
        let existingLayers = try await repository.fetchByOwner(currentUserID)
        if !existingLayers.isEmpty {
            throw LayerError.limitExceeded(limit: 1)
        }

        // Create layer
        let layer = Layer(
            name: name,
            icon: icon,
            color: color,
            ownerID: currentUserID
        )

        try await repository.save(layer)

        print("✅ Created layer: \(layer.id)")
        return layer
    }

    // MARK: - Read

    func fetchLayers() async throws -> [Layer] {
        return try await repository.fetchByOwner(currentUserID)
    }

    func fetchLayer(id: UUID) async throws -> Layer? {
        return try await repository.fetch(id)
    }

    func getDefaultLayer() async throws -> Layer {
        return try await repository.getOrCreateDefaultLayer(for: currentUserID)
    }

    // MARK: - Update

    func updateLayer(_ layer: Layer) async throws {
        // Validate ownership
        guard layer.ownerID == currentUserID else {
            throw LayerError.notOwner
        }

        // Update timestamp
        layer.updatedAt = Date()

        try await repository.save(layer)

        print("✅ Updated layer: \(layer.id)")
    }

    func setLayerVisible(_ layerID: UUID, visible: Bool) async throws {
        guard let layer = try await repository.fetch(layerID) else {
            throw LayerError.notFound
        }

        layer.isVisible = visible
        try await updateLayer(layer)
    }

    // MARK: - Delete

    func deleteLayer(id: UUID) async throws {
        guard let layer = try await repository.fetch(id) else {
            throw LayerError.notFound
        }

        // Validate ownership
        guard layer.ownerID == currentUserID else {
            throw LayerError.notOwner
        }

        // For MVP: Don't allow deleting the only layer
        // Instead, we'll just mark it as deleted in the future when multi-layer is supported
        throw LayerError.cannotDeleteDefaultLayer

        // Future implementation: Move annotations to default layer before deleting
        /*
        let annotations = try await annotationRepository.fetchByLayer(id)
        let defaultLayer = try await getDefaultLayer()

        for annotation in annotations {
            annotation.layerID = defaultLayer.id
            try await annotationRepository.save(annotation)
        }

        try await repository.delete(id)
        */
    }
}

// MARK: - Layer Errors

enum LayerError: LocalizedError {
    case emptyName
    case nameTooLong
    case notFound
    case notOwner
    case limitExceeded(limit: Int)
    case cannotDeleteDefaultLayer

    var errorDescription: String? {
        switch self {
        case .emptyName:
            return "Layer name cannot be empty"
        case .nameTooLong:
            return "Layer name must be 50 characters or less"
        case .notFound:
            return "Layer not found"
        case .notOwner:
            return "You don't have permission to modify this layer"
        case .limitExceeded(let limit):
            return "Free tier is limited to \(limit) layer. Upgrade to create more."
        case .cannotDeleteDefaultLayer:
            return "Cannot delete your only layer. Upgrade to create multiple layers."
        }
    }
}
