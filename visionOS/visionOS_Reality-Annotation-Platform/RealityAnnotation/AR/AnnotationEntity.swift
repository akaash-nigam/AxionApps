//
//  AnnotationEntity.swift
//  Reality Annotation Platform
//
//  RealityKit entity for rendering annotations in 3D space
//

import Foundation
import RealityKit
import SwiftUI

@MainActor
class AnnotationEntity: Entity {
    // Annotation data
    let annotationID: UUID
    var annotation: Annotation

    // Visual components
    private var cardEntity: ModelEntity?
    private var iconEntity: ModelEntity?

    // Configuration
    private let cardWidth: Float = 0.3
    private let cardHeight: Float = 0.2
    private let cardDepth: Float = 0.01

    // MARK: - Initialization

    init(annotation: Annotation) {
        self.annotationID = annotation.id
        self.annotation = annotation
        super.init()

        self.name = "annotation-\(annotation.id.uuidString)"

        // Set position and scale
        self.position = annotation.position
        self.scale = SIMD3(repeating: annotation.scale)

        // Build visual representation
        setupAppearance()
    }

    required init() {
        fatalError("Use init(annotation:) instead")
    }

    // MARK: - Visual Setup

    private func setupAppearance() {
        // Create card background
        createCard()

        // Create type icon
        createIcon()

        // Set up collision for interaction
        setupCollision()

        print("✨ Created annotation entity: \(annotationID)")
    }

    private func createCard() {
        // Create plane mesh for card
        let mesh = MeshResource.generatePlane(
            width: cardWidth,
            height: cardHeight,
            cornerRadius: 0.02
        )

        // Create material with layer color
        var material = UnlitMaterial()

        // Get layer color or default to blue
        let layerColor = annotation.layer?.color ?? .blue
        let uiColor = layerColor.swiftUIColor

        // Convert SwiftUI Color to UIColor (approximate)
        #if os(visionOS)
        material.color = .init(tint: .init(white: 0.9, alpha: 0.95))
        #endif

        // Add subtle shadow/border
        material.blending = .transparent

        // Create entity
        let card = ModelEntity(mesh: mesh, materials: [material])
        card.name = "card"

        // Add depth (make it slightly 3D)
        card.scale.z = cardDepth

        addChild(card)
        self.cardEntity = card

        // Add text overlay (simplified - in real implementation would use attachments)
        addTextOverlay()
    }

    private func addTextOverlay() {
        // In a real implementation, this would use a ViewAttachmentEntity
        // or a texture-based approach for rendering text
        // For now, we'll use a placeholder

        // Create a small sphere to represent text presence
        let textMesh = MeshResource.generateSphere(radius: 0.02)
        var textMaterial = UnlitMaterial()
        textMaterial.color = .init(tint: .black)

        let textIndicator = ModelEntity(mesh: textMesh, materials: [textMaterial])
        textIndicator.position = SIMD3(-0.12, 0.08, 0.01)
        textIndicator.name = "text-indicator"

        cardEntity?.addChild(textIndicator)
    }

    private func createIcon() {
        // Create small sphere for icon (simplified)
        let iconMesh = MeshResource.generateSphere(radius: 0.03)

        var iconMaterial = UnlitMaterial()
        let layerColor = annotation.layer?.color ?? .blue
        // Approximate color conversion
        #if os(visionOS)
        iconMaterial.color = .init(tint: .blue)
        #endif

        let icon = ModelEntity(mesh: iconMesh, materials: [iconMaterial])
        icon.position = SIMD3(-0.12, 0.06, 0.015)
        icon.name = "icon"

        addChild(icon)
        self.iconEntity = icon
    }

    private func setupCollision() {
        // Add collision shape for tap detection
        let collisionShape = ShapeResource.generateBox(
            width: cardWidth,
            height: cardHeight,
            depth: 0.05
        )

        let collision = CollisionComponent(shapes: [collisionShape])
        cardEntity?.components.set(collision)

        // Make it interactive
        cardEntity?.components.set(InputTargetComponent())
    }

    // MARK: - Billboard Behavior

    /// Update orientation to face the camera
    func updateBillboard(cameraPosition: SIMD3<Float>) {
        let entityPosition = position(relativeTo: nil)
        let direction = normalize(cameraPosition - entityPosition)

        // Calculate rotation to face camera
        let up = SIMD3<Float>(0, 1, 0)
        let right = normalize(cross(up, direction))
        let trueUp = cross(direction, right)

        let rotationMatrix = simd_float3x3(right, trueUp, direction)
        let targetRotation = simd_quatf(rotationMatrix)

        // Smooth interpolation (slerp)
        let currentRotation = orientation
        orientation = simd_slerp(currentRotation, targetRotation, 0.1)
    }

    // MARK: - LOD (Level of Detail)

    /// Update level of detail based on distance from camera
    func updateLOD(distance: Float) {
        let lod = calculateLOD(distance: distance)

        switch lod {
        case .full:
            showFullDetail()
        case .simplified:
            showSimplified()
        case .icon:
            showIconOnly()
        case .hidden:
            isEnabled = false
        }
    }

    private func calculateLOD(distance: Float) -> LODLevel {
        switch distance {
        case 0..<2: return .full
        case 2..<5: return .simplified
        case 5..<10: return .icon
        default: return .hidden
        }
    }

    private func showFullDetail() {
        isEnabled = true
        cardEntity?.isEnabled = true
        iconEntity?.isEnabled = true
        scale = SIMD3(repeating: annotation.scale)
    }

    private func showSimplified() {
        isEnabled = true
        cardEntity?.isEnabled = true
        iconEntity?.isEnabled = true
        scale = SIMD3(repeating: annotation.scale * 0.7)
    }

    private func showIconOnly() {
        isEnabled = true
        cardEntity?.isEnabled = false
        iconEntity?.isEnabled = true
        scale = SIMD3(repeating: annotation.scale * 0.5)
    }

    // MARK: - Animation

    /// Animate appearance when first created
    func animateAppearance() {
        // Start small and transparent
        scale = SIMD3(repeating: 0.01)

        // Animate to full size
        let animation = FromToByAnimation(
            to: Transform(scale: SIMD3(repeating: annotation.scale)),
            duration: 0.3,
            timing: .easeOut,
            bindTarget: .transform
        )

        playAnimation(animation)
    }

    /// Animate removal
    func animateRemoval() async {
        let animation = FromToByAnimation(
            to: Transform(scale: SIMD3(repeating: 0.01)),
            duration: 0.2,
            timing: .easeIn,
            bindTarget: .transform
        )

        playAnimation(animation)

        // Wait for animation to complete
        try? await Task.sleep(for: .milliseconds(200))
    }

    // MARK: - Update

    /// Update annotation data and refresh visuals
    func updateAnnotation(_ newAnnotation: Annotation) {
        self.annotation = newAnnotation
        self.position = newAnnotation.position
        self.scale = SIMD3(repeating: newAnnotation.scale)

        // Refresh appearance if needed
        // In a full implementation, would update text, colors, etc.
    }
}

// MARK: - LOD Level

enum LODLevel {
    case full       // Full detail with text
    case simplified // Simplified view
    case icon       // Icon only
    case hidden     // Not rendered
}
