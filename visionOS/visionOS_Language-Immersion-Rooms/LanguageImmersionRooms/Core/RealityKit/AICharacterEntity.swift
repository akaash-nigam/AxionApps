//
//  AICharacterEntity.swift
//  Language Immersion Rooms
//
//  AI character entity for conversations
//

import RealityKit
import SwiftUI

class AICharacterEntity: Entity {
    let character: AICharacter
    private var isAnimating = false

    required init(character: AICharacter, position: SIMD3<Float>) {
        self.character = character
        super.init()

        self.name = "Character_\(character.name)"
        self.position = position

        setupCharacter()
    }

    @MainActor required init() {
        fatalError("Use init(character:position:) instead")
    }

    private func setupCharacter() {
        // For MVP, use a simple placeholder sphere
        // In production, this would load a 3D character model

        let mesh = MeshResource.generateSphere(radius: 0.3)
        var material = SimpleMaterial()
        material.color = .init(tint: .init(red: 0.8, green: 0.6, blue: 0.5, alpha: 1.0))

        let modelEntity = ModelEntity(mesh: mesh, materials: [material])
        addChild(modelEntity)

        // Add name label above character
        addNameLabel()

        // Add component for identification
        components.set(CharacterComponent(
            characterID: character.id,
            name: character.name,
            voiceID: character.voiceID
        ))

        print("👤 Created character: \(character.name)")
    }

    private func addNameLabel() {
        // Create floating name label
        let textMesh = MeshResource.generateText(
            character.name,
            extrusionDepth: 0.005,
            font: .systemFont(ofSize: 0.03),
            containerFrame: .zero,
            alignment: .center,
            lineBreakMode: .byWordWrapping
        )

        var material = UnlitMaterial()
        material.color = .init(tint: .white)

        let nameEntity = ModelEntity(mesh: textMesh, materials: [material])
        nameEntity.position = [0, 0.4, 0] // Above character

        addChild(nameEntity)
    }

    // MARK: - Animations

    func playIdleAnimation() {
        guard !isAnimating else { return }
        isAnimating = true

        // Simple bob animation
        let originalY = position.y
        let bobHeight: Float = 0.05

        var moveUp = transform
        moveUp.translation.y = originalY + bobHeight

        var moveDown = transform
        moveDown.translation.y = originalY

        // Animate up
        move(to: moveUp, relativeTo: parent, duration: 1.5, timingFunction: .easeInOut)

        // Schedule animation down
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }
            self.move(to: moveDown, relativeTo: self.parent, duration: 1.5, timingFunction: .easeInOut)

            // Repeat
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                self?.isAnimating = false
                self?.playIdleAnimation()
            }
        }
    }

    func playSpeakingAnimation() {
        // Simple pulsing animation when speaking
        let originalScale = scale

        var scaleUp = transform
        scaleUp.scale = originalScale * 1.1

        move(to: scaleUp, relativeTo: parent, duration: 0.3, timingFunction: .easeInOut)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            var scaleNormal = self.transform
            scaleNormal.scale = originalScale
            self.move(to: scaleNormal, relativeTo: self.parent, duration: 0.3, timingFunction: .easeInOut)
        }
    }

    func showWithAnimation() {
        // Start invisible
        self.scale = [0.01, 0.01, 0.01]

        // Fade in
        var transform = self.transform
        transform.scale = [1.0, 1.0, 1.0]

        move(to: transform, relativeTo: parent, duration: 0.5, timingFunction: .easeOut)

        // Start idle after appearing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.playIdleAnimation()
        }
    }

    func hideWithAnimation() async {
        var transform = self.transform
        transform.scale = [0.01, 0.01, 0.01]

        move(to: transform, relativeTo: parent, duration: 0.3, timingFunction: .easeIn)

        try? await Task.sleep(nanoseconds: 300_000_000)
    }

    // MARK: - Look at Camera

    func lookAtCamera(_ cameraPosition: SIMD3<Float>) {
        // Make character face the camera
        look(at: cameraPosition, from: position, relativeTo: parent)
    }
}

// MARK: - Character Component

struct CharacterComponent: Component {
    let characterID: String
    let name: String
    let voiceID: String
}

// MARK: - Character Factory

class CharacterFactory {
    static func createCharacter(
        _ character: AICharacter,
        at position: SIMD3<Float> = [0, 0, -1.5] // 1.5m in front of user
    ) -> AICharacterEntity {
        let entity = AICharacterEntity(character: character, position: position)
        entity.showWithAnimation()
        return entity
    }
}
