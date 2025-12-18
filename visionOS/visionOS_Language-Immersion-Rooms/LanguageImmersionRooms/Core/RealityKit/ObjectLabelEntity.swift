//
//  ObjectLabelEntity.swift
//  Language Immersion Rooms
//
//  3D label entity for vocabulary words
//

import RealityKit
import SwiftUI

class ObjectLabelEntity: Entity {
    let word: VocabularyWord
    private var textEntity: ModelEntity?

    required init(word: VocabularyWord, position: SIMD3<Float>) {
        self.word = word
        super.init()

        self.name = "Label_\(word.word)"
        self.position = position

        setupLabel()
    }

    @MainActor required init() {
        fatalError("Use init(word:position:) instead")
    }

    private func setupLabel() {
        // Create 3D text mesh
        let textMesh = MeshResource.generateText(
            word.word,
            extrusionDepth: 0.01,
            font: .systemFont(ofSize: 0.05),
            containerFrame: .zero,
            alignment: .center,
            lineBreakMode: .byWordWrapping
        )

        // Create material
        var material = UnlitMaterial()
        material.color = .init(tint: .white)

        // Create text entity
        textEntity = ModelEntity(mesh: textMesh, materials: [material])

        // Add to self
        if let textEntity = textEntity {
            addChild(textEntity)
        }

        // Add collision for tap interactions
        let bounds = textMesh.bounds
        let shape = ShapeResource.generateBox(size: bounds.extents)
        components.set(CollisionComponent(shapes: [shape]))

        // Add component for identification
        components.set(LabelComponent(
            word: word.word,
            translation: word.translation,
            audioURL: word.audioURL
        ))

        print("🏷️ Created label: \(word.word)")
    }

    // MARK: - Animations

    func showWithAnimation() {
        // Start small
        self.scale = [0.01, 0.01, 0.01]

        // Animate to full size
        var transform = self.transform
        transform.scale = [1.0, 1.0, 1.0]

        self.move(
            to: transform,
            relativeTo: self.parent,
            duration: 0.3,
            timingFunction: .easeOut
        )
    }

    func hideWithAnimation() async {
        var transform = self.transform
        transform.scale = [0.01, 0.01, 0.01]

        self.move(
            to: transform,
            relativeTo: self.parent,
            duration: 0.2,
            timingFunction: .easeIn
        )

        // Wait for animation
        try? await Task.sleep(nanoseconds: 200_000_000)
    }

    func pulse() {
        // Attention-grabbing pulse animation
        let originalScale = self.scale

        // Scale up
        var scaleUp = self.transform
        scaleUp.scale = originalScale * 1.2

        self.move(to: scaleUp, relativeTo: self.parent, duration: 0.2)

        // Scale back
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            var scaleNormal = self.transform
            scaleNormal.scale = originalScale

            self.move(to: scaleNormal, relativeTo: self.parent, duration: 0.2)
        }
    }

    func lookAt(camera: Entity) {
        // Make label always face the camera
        look(at: camera.position(relativeTo: self.parent), from: self.position, relativeTo: self.parent)
    }
}

// MARK: - Label Component

struct LabelComponent: Component {
    let word: String
    let translation: String
    let audioURL: String?
}

// MARK: - Label Factory

class LabelFactory {
    static func createLabel(
        for word: VocabularyWord,
        at position: SIMD3<Float>,
        size: LabelSize = .medium
    ) -> ObjectLabelEntity {
        let label = ObjectLabelEntity(word: word, position: position)
        label.showWithAnimation()
        return label
    }

    static func createMultipleLabels(
        for objects: [DetectedObject],
        vocabulary: [String: VocabularyWord]
    ) -> [ObjectLabelEntity] {
        var labels: [ObjectLabelEntity] = []

        for object in objects {
            guard let word = vocabulary[object.label.lowercased()],
                  let position = object.position else {
                continue
            }

            // Offset label above object
            let labelPosition = SIMD3<Float>(
                position.x,
                position.y + 0.2, // 20cm above
                position.z
            )

            let label = createLabel(for: word, at: labelPosition)
            labels.append(label)
        }

        return labels
    }
}
