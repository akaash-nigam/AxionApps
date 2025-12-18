//
//  Scene.swift
//  SpatialScreenplayWorkshop
//
//  Created on 2025-11-24
//

import Foundation
import SwiftData

/// Individual scene in a screenplay
@Model
final class Scene {
    @Attribute(.unique) var id: UUID
    var sceneNumber: Int
    var slugLine: SlugLine
    var content: SceneContent
    var pageLength: Double
    var status: SceneStatus
    var position: ScenePosition
    var metadata: SceneMetadata
    var notes: [Note]
    var createdAt: Date
    var modifiedAt: Date

    // Relationships
    var characters: [Character]?
    var project: Project?

    init(
        id: UUID = UUID(),
        sceneNumber: Int,
        slugLine: SlugLine,
        content: SceneContent = SceneContent(),
        pageLength: Double = 0,
        status: SceneStatus = .draft,
        position: ScenePosition,
        metadata: SceneMetadata = SceneMetadata(),
        notes: [Note] = [],
        createdAt: Date = Date(),
        modifiedAt: Date = Date()
    ) {
        self.id = id
        self.sceneNumber = sceneNumber
        self.slugLine = slugLine
        self.content = content
        self.pageLength = pageLength
        self.status = status
        self.position = position
        self.metadata = metadata
        self.notes = notes
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
    }

    /// Formatted slug line for display
    var formattedSlugLine: String {
        "\(sceneNumber). \(slugLine.formatted)"
    }

    /// Character names in this scene (from dialogue and references)
    var characterNames: [String] {
        var names = Set<String>()

        // Add characters from dialogue
        for element in content.elements {
            if case .dialogue(let dialogue) = element {
                names.insert(dialogue.characterName)
            }
        }

        // Add linked characters
        if let linkedCharacters = characters {
            for character in linkedCharacters {
                names.insert(character.name)
            }
        }

        return Array(names).sorted()
    }

    /// Word count in scene
    var wordCount: Int {
        content.wordCount
    }

    /// Estimated duration in seconds (1 page ≈ 60 seconds)
    var estimatedDuration: TimeInterval {
        pageLength * 60
    }

    /// Color for this scene based on color coding mode
    func color(for mode: ColorCodingMode) -> String {
        switch mode {
        case .location:
            // Generate color from location name
            let hash = slugLine.location.hashValue
            let colors = [
                "#FF6B6B", "#4ECDC4", "#45B7D1", "#FFA07A",
                "#98D8C8", "#F7DC6F", "#BB8FCE", "#85C1E2"
            ]
            return colors[abs(hash) % colors.count]

        case .timeOfDay:
            return slugLine.timeOfDay.color

        case .character:
            // Use first character's color
            if let firstCharacter = characters?.first {
                return firstCharacter.color
            }
            return "#9E9E9E"

        case .storyThread:
            // Color based on story thread
            guard let thread = metadata.storyThread else { return "#9E9E9E" }
            let hash = thread.hashValue
            let colors = ["#E74C3C", "#3498DB", "#2ECC71", "#F39C12", "#9B59B6"]
            return colors[abs(hash) % colors.count]

        case .status:
            return status.color
        }
    }

    /// Update modified timestamp
    func touch() {
        modifiedAt = Date()
    }
}

// MARK: - Scene Extensions

extension Scene {
    /// Create a blank scene
    static func blank(number: Int, act: Int) -> Scene {
        Scene(
            sceneNumber: number,
            slugLine: SlugLine(
                setting: .INT,
                location: "LOCATION",
                timeOfDay: .day
            ),
            position: ScenePosition(act: act)
        )
    }

    /// Sample scenes for testing
    static func sampleScenes() -> [Scene] {
        [
            Scene(
                sceneNumber: 1,
                slugLine: SlugLine(setting: .INT, location: "COFFEE SHOP", timeOfDay: .day),
                content: SceneContent(elements: [
                    .action(ActionElement(
                        text: "ALEX sits across from SARAH, nervous. The morning crowd bustles around them.",
                        isCharacterIntro: true
                    )),
                    .dialogue(DialogueElement(
                        characterName: "ALEX",
                        parenthetical: "hesitant",
                        lines: ["I need to tell you something."]
                    )),
                    .dialogue(DialogueElement(
                        characterName: "SARAH",
                        lines: ["What is it?"]
                    ))
                ]),
                pageLength: 2.5,
                status: .locked,
                position: ScenePosition(act: 1),
                metadata: SceneMetadata(
                    summary: "Alex reveals secret to Sarah",
                    importance: .critical
                )
            ),
            Scene(
                sceneNumber: 2,
                slugLine: SlugLine(setting: .EXT, location: "PARKING LOT", timeOfDay: .day),
                content: SceneContent(elements: [
                    .action(ActionElement(
                        text: "Alex walks to their car, visibly shaken. Keys fumble in their hands."
                    ))
                ]),
                pageLength: 0.5,
                status: .revised,
                position: ScenePosition(act: 1),
                metadata: SceneMetadata(
                    summary: "Alex processes the conversation",
                    importance: .supporting
                )
            ),
            Scene(
                sceneNumber: 3,
                slugLine: SlugLine(setting: .INT, location: "ALEX'S APARTMENT", timeOfDay: .night),
                content: SceneContent(elements: [
                    .action(ActionElement(
                        text: "Dark. Silent. Alex enters and collapses onto the couch."
                    )),
                    .dialogue(DialogueElement(
                        characterName: "ALEX",
                        parenthetical: "to themselves",
                        lines: ["What have I done?"]
                    ))
                ]),
                pageLength: 1.0,
                status: .draft,
                position: ScenePosition(act: 1),
                metadata: SceneMetadata(
                    summary: "Alex alone with their thoughts",
                    mood: "somber",
                    importance: .important
                )
            )
        ]
    }
}
