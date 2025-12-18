//
//  LocalDataSource.swift
//  Reality Annotation Platform
//
//  Local data source protocol and SwiftData implementation
//

import Foundation
import SwiftData

/// Protocol for local data operations
protocol LocalDataSource {
    // Annotations
    func fetchAnnotation(_ id: UUID) async throws -> Annotation?
    func fetchAllAnnotations() async throws -> [Annotation]
    func fetchAnnotations(layerID: UUID) async throws -> [Annotation]
    func fetchAnnotations(ownerID: String) async throws -> [Annotation]
    func saveAnnotation(_ annotation: Annotation) async throws
    func deleteAnnotation(_ id: UUID) async throws

    // Layers
    func fetchLayer(_ id: UUID) async throws -> Layer?
    func fetchAllLayers() async throws -> [Layer]
    func saveLayer(_ layer: Layer) async throws
    func deleteLayer(_ id: UUID) async throws

    // Users
    func fetchUser(_ id: String) async throws -> User?
    func saveUser(_ user: User) async throws
}

// MARK: - SwiftData Implementation

@ModelActor
actor SwiftDataSource: LocalDataSource {
    // MARK: - Annotations

    func fetchAnnotation(_ id: UUID) async throws -> Annotation? {
        let descriptor = FetchDescriptor<Annotation>(
            predicate: #Predicate { $0.id == id }
        )

        let annotations = try modelContext.fetch(descriptor)
        return annotations.first
    }

    func fetchAllAnnotations() async throws -> [Annotation] {
        let descriptor = FetchDescriptor<Annotation>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )

        return try modelContext.fetch(descriptor)
    }

    func fetchAnnotations(layerID: UUID) async throws -> [Annotation] {
        let descriptor = FetchDescriptor<Annotation>(
            predicate: #Predicate { annotation in
                annotation.layerID == layerID && !annotation.isDeleted
            },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )

        return try modelContext.fetch(descriptor)
    }

    func fetchAnnotations(ownerID: String) async throws -> [Annotation] {
        let descriptor = FetchDescriptor<Annotation>(
            predicate: #Predicate { annotation in
                annotation.ownerID == ownerID && !annotation.isDeleted
            },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )

        return try modelContext.fetch(descriptor)
    }

    func saveAnnotation(_ annotation: Annotation) async throws {
        // Check if annotation already exists
        if let existing = try await fetchAnnotation(annotation.id) {
            // Update existing
            existing.contentText = annotation.contentText
            existing.title = annotation.title
            existing.positionX = annotation.positionX
            existing.positionY = annotation.positionY
            existing.positionZ = annotation.positionZ
            existing.updatedAt = Date()
            existing.syncStatus = annotation.syncStatus
        } else {
            // Insert new
            modelContext.insert(annotation)
        }

        try modelContext.save()
    }

    func deleteAnnotation(_ id: UUID) async throws {
        // Soft delete
        if let annotation = try await fetchAnnotation(id) {
            annotation.isDeleted = true
            annotation.deletedAt = Date()
            annotation.updatedAt = Date()
            try modelContext.save()
        }
    }

    // MARK: - Layers

    func fetchLayer(_ id: UUID) async throws -> Layer? {
        let descriptor = FetchDescriptor<Layer>(
            predicate: #Predicate { $0.id == id }
        )

        let layers = try modelContext.fetch(descriptor)
        return layers.first
    }

    func fetchAllLayers() async throws -> [Layer] {
        let descriptor = FetchDescriptor<Layer>(
            predicate: #Predicate { !$0.isDeleted },
            sortBy: [SortDescriptor(\.name)]
        )

        return try modelContext.fetch(descriptor)
    }

    func saveLayer(_ layer: Layer) async throws {
        // Check if layer already exists
        if let existing = try await fetchLayer(layer.id) {
            // Update existing
            existing.name = layer.name
            existing.icon = layer.icon
            existing.colorHex = layer.colorHex
            existing.isVisible = layer.isVisible
            existing.updatedAt = Date()
        } else {
            // Insert new
            modelContext.insert(layer)
        }

        try modelContext.save()
    }

    func deleteLayer(_ id: UUID) async throws {
        // Soft delete
        if let layer = try await fetchLayer(id) {
            layer.isDeleted = true
            layer.updatedAt = Date()
            try modelContext.save()
        }
    }

    // MARK: - Users

    func fetchUser(_ id: String) async throws -> User? {
        let descriptor = FetchDescriptor<User>(
            predicate: #Predicate { $0.id == id }
        )

        let users = try modelContext.fetch(descriptor)
        return users.first
    }

    func saveUser(_ user: User) async throws {
        // Check if user already exists
        if let existing = try await fetchUser(user.id) {
            // Update existing
            existing.displayName = user.displayName
            existing.email = user.email
            existing.lastActiveAt = Date()
        } else {
            // Insert new
            modelContext.insert(user)
        }

        try modelContext.save()
    }
}
