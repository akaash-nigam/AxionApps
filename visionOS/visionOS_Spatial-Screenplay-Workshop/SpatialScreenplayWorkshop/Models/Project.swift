//
//  Project.swift
//  SpatialScreenplayWorkshop
//
//  Created on 2025-11-24
//

import Foundation
import SwiftData

/// Top-level screenplay project
@Model
final class Project {
    @Attribute(.unique) var id: UUID
    var title: String
    var logline: String
    var type: ProjectType
    var author: String
    var metadata: ProjectMetadata
    var settings: ProjectSettings
    var createdAt: Date
    var modifiedAt: Date

    // Relationships
    @Relationship(deleteRule: .cascade, inverse: \Scene.project)
    var scenes: [Scene]?

    init(
        id: UUID = UUID(),
        title: String,
        logline: String = "",
        type: ProjectType = .featureFilm,
        author: String = "",
        metadata: ProjectMetadata? = nil,
        settings: ProjectSettings = ProjectSettings(),
        createdAt: Date = Date(),
        modifiedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.logline = logline
        self.type = type
        self.author = author
        self.settings = settings
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt

        // Initialize metadata with type-specific defaults
        if let metadata = metadata {
            self.metadata = metadata
        } else {
            self.metadata = ProjectMetadata(
                targetPageCount: type.targetPageCount,
                status: .outline
            )
        }
    }

    /// All characters across all scenes
    var allCharacters: [Character] {
        guard let scenes = scenes else { return [] }

        var characterSet = Set<UUID>()
        var characters: [Character] = []

        for scene in scenes {
            if let sceneCharacters = scene.characters {
                for character in sceneCharacters {
                    if !characterSet.contains(character.id) {
                        characterSet.insert(character.id)
                        characters.append(character)
                    }
                }
            }
        }

        return characters.sorted { $0.name < $1.name }
    }

    /// Unique location names
    var allLocations: [String] {
        guard let scenes = scenes else { return [] }
        let locations = Set(scenes.map { $0.slugLine.location })
        return Array(locations).sorted()
    }

    /// Current page count across all scenes
    var currentPageCount: Double {
        guard let scenes = scenes else { return 0 }
        return scenes.reduce(0) { $0 + $1.pageLength }
    }

    /// Total word count
    var totalWordCount: Int {
        guard let scenes = scenes else { return 0 }
        return scenes.reduce(0) { $0 + $1.wordCount }
    }

    /// Scenes by act
    func scenes(in act: Int) -> [Scene] {
        guard let scenes = scenes else { return [] }
        return scenes
            .filter { $0.position.act == act }
            .sorted { $0.sceneNumber < $1.sceneNumber }
    }

    /// Number of scenes in each act
    var actSceneCounts: [Int: Int] {
        guard let scenes = scenes else { return [:] }
        var counts: [Int: Int] = [:]
        for scene in scenes {
            counts[scene.position.act, default: 0] += 1
        }
        return counts
    }

    /// Progress percentage toward target page count
    var progressPercentage: Double {
        guard let target = metadata.targetPageCount, target > 0 else { return 0 }
        return min(currentPageCount / Double(target), 1.0) * 100
    }

    /// Update metadata counts
    func updateMetadata() {
        metadata.currentPageCount = currentPageCount
        metadata.wordCount = totalWordCount
        metadata.sceneCount = scenes?.count ?? 0
        metadata.characterCount = allCharacters.count
        modifiedAt = Date()
    }

    /// Update modified timestamp
    func touch() {
        modifiedAt = Date()
    }
}

// MARK: - Project Extensions

extension Project {
    /// Sample project for testing
    static func sample() -> Project {
        let project = Project(
            title: "The Writer's Dilemma",
            logline: "A struggling writer discovers their stories come to life, but with dangerous consequences.",
            type: .featureFilm,
            author: "John Smith"
        )

        return project
    }

    /// Blank project
    static func blank(title: String, type: ProjectType, author: String) -> Project {
        Project(
            title: title,
            logline: "",
            type: type,
            author: author
        )
    }
}

// MARK: - Display Helpers

extension Project {
    /// Display info for UI
    var displayInfo: String {
        let pageText = String(format: "%.1f", currentPageCount)
        let sceneCount = scenes?.count ?? 0
        return "\(pageText) pages • \(sceneCount) scenes • \(type.rawValue)"
    }

    /// Last modified date formatted
    var lastModifiedText: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: modifiedAt, relativeTo: Date())
    }

    /// Status badge text
    var statusBadge: String {
        metadata.status.rawValue.uppercased()
    }

    /// Color for status
    var statusColor: String {
        metadata.status.color
    }
}
