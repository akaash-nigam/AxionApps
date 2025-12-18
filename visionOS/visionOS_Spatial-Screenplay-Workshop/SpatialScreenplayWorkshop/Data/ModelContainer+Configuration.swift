//
//  ModelContainer+Configuration.swift
//  SpatialScreenplayWorkshop
//
//  Created on 2025-11-24
//

import Foundation
import SwiftData

extension ModelContainer {
    /// Shared model container for the app
    static var shared: ModelContainer = {
        let schema = Schema([
            Project.self,
            Scene.self,
            Character.self
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )

        do {
            let container = try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
            return container
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()

    /// In-memory container for testing
    static var preview: ModelContainer = {
        let schema = Schema([
            Project.self,
            Scene.self,
            Character.self
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )

        do {
            let container = try ModelContainer(
                for: schema,
                configurations: [configuration]
            )

            // Add sample data for previews
            Task { @MainActor in
                let context = container.mainContext
                let sampleProject = Project.sample()
                context.insert(sampleProject)

                // Add sample scenes
                let scenes = Scene.sampleScenes()
                for scene in scenes {
                    scene.project = sampleProject
                    context.insert(scene)
                }

                // Add sample characters
                let characters = Character.sampleCharacters()
                for character in characters {
                    context.insert(character)

                    // Link characters to first scene
                    if let firstScene = scenes.first {
                        firstScene.characters = characters
                    }
                }

                sampleProject.updateMetadata()

                try? context.save()
            }

            return container
        } catch {
            fatalError("Failed to create preview ModelContainer: \(error)")
        }
    }()
}

// MARK: - Migration Support

extension ModelContainer {
    /// Migration configuration for schema version updates
    static func migratedContainer() throws -> ModelContainer {
        let schema = Schema([
            Project.self,
            Scene.self,
            Character.self
        ])

        var configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        // Set up migration options
        configuration.allowsSave = true

        return try ModelContainer(
            for: schema,
            configurations: [configuration]
        )
    }
}

// MARK: - Utility Extensions

extension ModelContext {
    /// Convenience method to save with error handling
    func safeSave() throws {
        if hasChanges {
            try save()
        }
    }

    /// Delete all objects of a type
    func deleteAll<T: PersistentModel>(_ type: T.Type) throws {
        let descriptor = FetchDescriptor<T>()
        let objects = try fetch(descriptor)
        for object in objects {
            delete(object)
        }
        try save()
    }

    /// Count objects of a type
    func count<T: PersistentModel>(_ type: T.Type) throws -> Int {
        let descriptor = FetchDescriptor<T>()
        return try fetchCount(descriptor)
    }
}
