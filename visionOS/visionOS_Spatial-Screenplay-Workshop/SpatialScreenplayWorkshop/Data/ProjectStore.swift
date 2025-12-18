//
//  ProjectStore.swift
//  SpatialScreenplayWorkshop
//
//  Created on 2025-11-24
//

import Foundation
import SwiftData

/// Actor for thread-safe data access operations
@ModelActor
actor ProjectStore {
    /// Save a project
    func save(_ project: Project) throws {
        project.updateMetadata()
        project.touch()
        modelContext.insert(project)
        try modelContext.save()
    }

    /// Fetch project by ID
    func fetch(id: UUID) throws -> Project? {
        let descriptor = FetchDescriptor<Project>(
            predicate: #Predicate { $0.id == id }
        )
        let projects = try modelContext.fetch(descriptor)
        return projects.first
    }

    /// Fetch all projects
    func fetchAll() throws -> [Project] {
        let descriptor = FetchDescriptor<Project>(
            sortBy: [SortDescriptor(\.modifiedAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    /// Delete project by ID
    func delete(id: UUID) throws {
        guard let project = try fetch(id: id) else {
            throw ProjectStoreError.projectNotFound(id)
        }
        modelContext.delete(project)
        try modelContext.save()
    }

    /// Update project
    func update(_ project: Project) throws {
        project.updateMetadata()
        project.touch()
        try modelContext.save()
    }

    /// Query projects with predicate
    func query(
        predicate: Predicate<Project>? = nil,
        sortBy: [SortDescriptor<Project>] = []
    ) throws -> [Project] {
        var descriptor = FetchDescriptor<Project>(predicate: predicate)
        descriptor.sortBy = sortBy
        return try modelContext.fetch(descriptor)
    }

    /// Search projects by title or logline
    func search(query: String) throws -> [Project] {
        let lowercaseQuery = query.lowercased()
        let descriptor = FetchDescriptor<Project>(
            predicate: #Predicate { project in
                project.title.localizedStandardContains(query) ||
                project.logline.localizedStandardContains(query) ||
                project.author.localizedStandardContains(query)
            },
            sortBy: [SortDescriptor(\.modifiedAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    /// Count total projects
    func count() throws -> Int {
        let descriptor = FetchDescriptor<Project>()
        return try modelContext.fetchCount(descriptor)
    }

    // MARK: - Scene Operations

    /// Add scene to project
    func addScene(_ scene: Scene, to project: Project) throws {
        if project.scenes == nil {
            project.scenes = []
        }
        project.scenes?.append(scene)
        scene.project = project
        project.updateMetadata()
        try modelContext.save()
    }

    /// Delete scene from project
    func deleteScene(_ scene: Scene, from project: Project) throws {
        project.scenes?.removeAll { $0.id == scene.id }
        modelContext.delete(scene)
        project.updateMetadata()
        try modelContext.save()
    }

    /// Reorder scenes in project
    func reorderScenes(in project: Project, from source: Int, to destination: Int) throws {
        guard var scenes = project.scenes else { return }

        let movedScene = scenes.remove(at: source)
        scenes.insert(movedScene, at: destination)

        // Update scene numbers
        for (index, scene) in scenes.enumerated() {
            scene.sceneNumber = index + 1
            scene.touch()
        }

        project.scenes = scenes
        project.updateMetadata()
        try modelContext.save()
    }

    /// Move scene to different act
    func moveScene(_ scene: Scene, toAct act: Int, in project: Project) throws {
        scene.position.act = act
        scene.touch()
        project.updateMetadata()
        try modelContext.save()
    }

    // MARK: - Character Operations

    /// Add character to scene
    func addCharacter(_ character: Character, to scene: Scene) throws {
        if scene.characters == nil {
            scene.characters = []
        }
        if !scene.characters!.contains(where: { $0.id == character.id }) {
            scene.characters?.append(character)
            scene.touch()
            try modelContext.save()
        }
    }

    /// Remove character from scene
    func removeCharacter(_ character: Character, from scene: Scene) throws {
        scene.characters?.removeAll { $0.id == character.id }
        scene.touch()
        try modelContext.save()
    }

    /// Delete character completely
    func deleteCharacter(_ character: Character) throws {
        // Remove from all scenes first
        if let scenes = character.scenes {
            for scene in scenes {
                scene.characters?.removeAll { $0.id == character.id }
            }
        }
        modelContext.delete(character)
        try modelContext.save()
    }

    /// Create character
    func createCharacter(_ character: Character) throws {
        modelContext.insert(character)
        try modelContext.save()
    }

    // MARK: - Batch Operations

    /// Save multiple projects
    func batchSave(_ projects: [Project]) throws {
        for project in projects {
            project.updateMetadata()
            project.touch()
            modelContext.insert(project)
        }
        try modelContext.save()
    }

    /// Delete multiple projects
    func batchDelete(ids: [UUID]) throws {
        for id in ids {
            if let project = try fetch(id: id) {
                modelContext.delete(project)
            }
        }
        try modelContext.save()
    }
}

// MARK: - Errors

enum ProjectStoreError: LocalizedError {
    case projectNotFound(UUID)
    case sceneNotFound(UUID)
    case characterNotFound(UUID)
    case saveFailed(Error)
    case deleteFailed(Error)
    case invalidData

    var errorDescription: String? {
        switch self {
        case .projectNotFound(let id):
            return "Project with ID \(id) not found"
        case .sceneNotFound(let id):
            return "Scene with ID \(id) not found"
        case .characterNotFound(let id):
            return "Character with ID \(id) not found"
        case .saveFailed(let error):
            return "Failed to save: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "Failed to delete: \(error.localizedDescription)"
        case .invalidData:
            return "Invalid data provided"
        }
    }
}

// MARK: - Helper Extensions

extension ProjectStore {
    /// Check if project exists
    func exists(id: UUID) throws -> Bool {
        try fetch(id: id) != nil
    }

    /// Get projects by type
    func projects(ofType type: ProjectType) throws -> [Project] {
        try query(
            predicate: #Predicate { $0.type == type },
            sortBy: [SortDescriptor(\.modifiedAt, order: .reverse)]
        )
    }

    /// Get projects by status
    func projects(withStatus status: ProjectStatus) throws -> [Project] {
        try query(
            predicate: #Predicate { $0.metadata.status == status },
            sortBy: [SortDescriptor(\.modifiedAt, order: .reverse)]
        )
    }

    /// Get recently modified projects
    func recentProjects(limit: Int = 10) throws -> [Project] {
        var descriptor = FetchDescriptor<Project>(
            sortBy: [SortDescriptor(\.modifiedAt, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        return try modelContext.fetch(descriptor)
    }
}
