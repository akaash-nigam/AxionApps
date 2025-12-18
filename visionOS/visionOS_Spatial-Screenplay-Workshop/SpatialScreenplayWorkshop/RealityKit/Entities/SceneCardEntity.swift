//
//  SceneCardEntity.swift
//  SpatialScreenplayWorkshop
//
//  Created on 2025-11-24
//

import RealityKit
import SwiftUI

/// 3D entity representing a screenplay scene card in spatial timeline
final class SceneCardEntity: Entity {
    // MARK: - Properties

    let scene: Scene
    private var cardModel: ModelEntity?
    private var textEntity: Entity?

    // Card dimensions (in meters)
    static let cardWidth: Float = 0.3      // 30cm wide
    static let cardHeight: Float = 0.4     // 40cm tall
    static let cardDepth: Float = 0.01     // 1cm deep
    static let cornerRadius: Float = 0.02   // 2cm corner radius

    // MARK: - Initialization

    init(scene: Scene) {
        self.scene = scene
        super.init()

        setupCard()
        setupComponents()
    }

    required init() {
        fatalError("Use init(scene:) instead")
    }

    // MARK: - Setup

    private func setupCard() {
        // Create rounded card mesh
        let mesh = createCardMesh()

        // Create material with scene info
        let material = createCardMaterial()

        // Create model entity
        cardModel = ModelEntity(mesh: mesh, materials: [material])
        addChild(cardModel!)

        // Add text overlay
        // TODO: Render SwiftUI view to texture for rich content
    }

    private func setupComponents() {
        // Add collision component for interactions
        let shape = ShapeResource.generateBox(
            width: Self.cardWidth,
            height: Self.cardHeight,
            depth: Self.cardDepth
        )

        components.set(CollisionComponent(shapes: [shape]))

        // Add input target component for gestures
        components.set(InputTargetComponent(allowedInputTypes: .all))

        // Add hover effect component
        components.set(HoverEffectComponent())
    }

    // MARK: - Mesh Generation

    private func createCardMesh() -> MeshResource {
        // Create rounded rectangle mesh
        // For simplicity, using a box. In production, would generate custom rounded mesh
        return .generateBox(
            width: Self.cardWidth,
            height: Self.cardHeight,
            depth: Self.cardDepth,
            cornerRadius: Self.cornerRadius
        )
    }

    // MARK: - Material

    private func createCardMaterial() -> Material {
        // Create material based on scene status
        var material = SimpleMaterial()

        // Color coding by scene status
        let color = colorForStatus(scene.status)
        material.color = .init(tint: color.withAlphaComponent(0.95))

        // Add slight metallic look
        material.metallic = .float(0.1)
        material.roughness = .float(0.7)

        return material
    }

    private func colorForStatus(_ status: SceneStatus) -> UIColor {
        switch status {
        case .draft:
            return UIColor(Color(hex: "FFE5B4"))  // Light peach
        case .revision:
            return UIColor(Color(hex: "FFD700"))  // Gold
        case .locked:
            return UIColor(Color(hex: "90EE90"))  // Light green
        case .final:
            return UIColor(Color(hex: "87CEEB"))  // Sky blue
        }
    }

    // MARK: - Update

    func updateAppearance(isSelected: Bool = false, isHovered: Bool = false) {
        guard let cardModel = cardModel else { return }

        var material = SimpleMaterial()
        var color = colorForStatus(scene.status)

        // Highlight when selected or hovered
        if isSelected {
            color = UIColor(Color.accentColor.opacity(0.9))
            material.metallic = .float(0.3)
        } else if isHovered {
            color = color.withAlphaComponent(1.0)
            material.metallic = .float(0.2)
        }

        material.color = .init(tint: color)
        material.roughness = .float(0.7)

        cardModel.model?.materials = [material]
    }

    // MARK: - Animation

    func animateSelection() {
        // Pulse animation when selected
        let originalTransform = transform

        // Scale up slightly
        var scaleUp = originalTransform
        scaleUp.scale = SIMD3<Float>(1.1, 1.1, 1.1)

        // Animate
        move(
            to: scaleUp,
            relativeTo: parent,
            duration: 0.15,
            timingFunction: .easeOut
        )

        // Return to normal
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            self?.move(
                to: originalTransform,
                relativeTo: self?.parent,
                duration: 0.15,
                timingFunction: .easeIn
            )
        }
    }

    func animateDrag(to position: SIMD3<Float>) {
        // Smooth move animation
        var newTransform = transform
        newTransform.translation = position

        move(
            to: newTransform,
            relativeTo: parent,
            duration: 0.3,
            timingFunction: .easeInOut
        )
    }
}

// MARK: - Hover Effect Component

struct HoverEffectComponent: Component {
    var isHovering: Bool = false
}
