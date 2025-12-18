//
//  SceneCoordinator.swift
//  Language Immersion Rooms
//
//  Coordinates RealityKit scene setup and entity management
//

import RealityKit
import SwiftUI

@MainActor
class SceneCoordinator {
    // Root entity for scene hierarchy
    private var rootEntity: Entity?

    // Entity collections
    private var labelEntities: [UUID: ObjectLabelEntity] = [:]
    private var characterEntity: AICharacterEntity?

    // Services
    private let vocabularyService: VocabularyService

    init(vocabularyService: VocabularyService = VocabularyService()) {
        self.vocabularyService = vocabularyService
        print("🎬 SceneCoordinator initialized")
    }

    // MARK: - Scene Setup

    func setupScene(content: RealityViewContent) async {
        // Create root entity
        let root = Entity()
        root.name = "SceneRoot"
        content.add(root)
        self.rootEntity = root

        print("✅ Scene root created")
    }

    // MARK: - Label Management

    func createLabels(for objects: [DetectedObject]) async {
        guard let root = rootEntity else {
            print("❌ No root entity")
            return
        }

        // Clear existing labels
        clearLabels()

        print("🏷️ Creating \(objects.count) labels...")

        // Create vocabulary lookup dictionary
        let allWords = vocabularyService.getAllWords()
        var vocabulary: [String: VocabularyWord] = [:]
        for word in allWords {
            vocabulary[word.translation.lowercased()] = word
        }

        // Create labels for each detected object
        for object in objects {
            guard let word = vocabulary[object.label.lowercased()],
                  let position = object.position else {
                continue
            }

            // Position label above object
            let labelPosition = SIMD3<Float>(
                position.x,
                position.y + 0.2, // 20cm above
                position.z
            )

            let label = ObjectLabelEntity(word: word, position: labelPosition)
            root.addChild(label)
            labelEntities[label.id] = label

            // Animate in
            label.showWithAnimation()

            print("  📍 Label created: \(word.word) at \(labelPosition)")
        }

        print("✅ Created \(labelEntities.count) labels")
    }

    func clearLabels() {
        for (_, label) in labelEntities {
            label.removeFromParent()
        }
        labelEntities.removeAll()
        print("🧹 Cleared all labels")
    }

    func toggleLabelsVisibility(visible: Bool) {
        for (_, label) in labelEntities {
            if visible {
                label.showWithAnimation()
            } else {
                Task {
                    await label.hideWithAnimation()
                }
            }
        }
    }

    // MARK: - Character Management

    func addCharacter(_ character: AICharacter, at position: SIMD3<Float> = [0, 1.5, -1.5]) {
        guard let root = rootEntity else {
            print("❌ No root entity")
            return
        }

        // Remove existing character
        removeCharacter()

        // Create new character
        let characterEntity = AICharacterEntity(character: character, position: position)
        root.addChild(characterEntity)
        self.characterEntity = characterEntity

        print("👤 Character added: \(character.name)")
    }

    func removeCharacter() {
        characterEntity?.removeFromParent()
        characterEntity = nil
    }

    func getCharacterEntity() -> AICharacterEntity? {
        return characterEntity
    }

    // MARK: - Interaction Handling

    func handleTap(on entity: Entity) -> VocabularyWord? {
        // Check if tapped entity is a label
        if let labelEntity = entity as? ObjectLabelEntity {
            print("👆 Tapped label: \(labelEntity.word.word)")
            labelEntity.pulse()
            return labelEntity.word
        }

        // Check parent entities
        var current: Entity? = entity
        while let parent = current?.parent {
            if let labelEntity = parent as? ObjectLabelEntity {
                print("👆 Tapped label (via child): \(labelEntity.word.word)")
                labelEntity.pulse()
                return labelEntity.word
            }
            current = parent
        }

        return nil
    }

    // MARK: - Cleanup

    func cleanup() {
        clearLabels()
        removeCharacter()
        rootEntity = nil
        print("🧹 Scene cleaned up")
    }
}
