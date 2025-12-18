//
//  TimelineContainerEntity.swift
//  SpatialScreenplayWorkshop
//
//  Created on 2025-11-24
//

import RealityKit
import SwiftUI

/// Root entity that contains all scene cards in spatial timeline
final class TimelineContainerEntity: Entity {
    // MARK: - Properties

    private var sceneCards: [UUID: SceneCardEntity] = [:]
    private var layoutEngine: SpatialLayoutEngine

    // Container dimensions
    static let containerWidth: Float = 4.0   // 4 meters wide
    static let containerHeight: Float = 2.0  // 2 meters tall
    static let containerDepth: Float = 2.0   // 2 meters deep

    // MARK: - Initialization

    init(project: Project) {
        self.layoutEngine = SpatialLayoutEngine()
        super.init()

        loadScenes(from: project)
    }

    required init() {
        self.layoutEngine = SpatialLayoutEngine()
        super.init()
    }

    // MARK: - Scene Management

    func loadScenes(from project: Project) {
        // Clear existing cards
        sceneCards.values.forEach { $0.removeFromParent() }
        sceneCards.removeAll()

        guard let scenes = project.scenes else { return }

        // Create card for each scene
        for scene in scenes {
            let card = SceneCardEntity(scene: scene)
            sceneCards[scene.id] = card
            addChild(card)
        }

        // Layout cards in space
        layoutCards(scenes: scenes)
    }

    func updateScene(_ scene: Scene) {
        guard let card = sceneCards[scene.id] else { return }

        // Update card appearance (scene may have changed status)
        card.updateAppearance()
    }

    func removeScene(_ sceneId: UUID) {
        guard let card = sceneCards[sceneId] else { return }

        // Animate removal
        card.removeFromParent()
        sceneCards.removeValue(forKey: sceneId)

        // Re-layout remaining cards
        let remainingScenes = sceneCards.values.map { $0.scene }
        layoutCards(scenes: remainingScenes)
    }

    // MARK: - Layout

    private func layoutCards(scenes: [Scene]) {
        // Calculate positions using layout engine
        let positions = layoutEngine.calculatePositions(
            for: scenes,
            in: CGSize(
                width: CGFloat(Self.containerWidth),
                height: CGFloat(Self.containerHeight)
            )
        )

        // Position each card
        for (scene, position) in positions {
            guard let card = sceneCards[scene.id] else { continue }

            var transform = Transform.identity
            transform.translation = position

            // Animate to position
            card.move(
                to: transform,
                relativeTo: self,
                duration: 0.5,
                timingFunction: .easeInOut
            )
        }
    }

    // MARK: - Selection

    func selectCard(for sceneId: UUID) {
        // Deselect all cards
        sceneCards.values.forEach { $0.updateAppearance(isSelected: false) }

        // Select specified card
        if let card = sceneCards[sceneId] {
            card.updateAppearance(isSelected: true)
            card.animateSelection()
        }
    }

    func deselectAll() {
        sceneCards.values.forEach { $0.updateAppearance(isSelected: false) }
    }

    // MARK: - Reordering

    func moveCard(from sourceId: UUID, to targetIndex: Int, in scenes: inout [Scene]) {
        guard let sourceIndex = scenes.firstIndex(where: { $0.id == sourceId }) else {
            return
        }

        // Update scene order
        let scene = scenes.remove(at: sourceIndex)
        scenes.insert(scene, at: targetIndex)

        // Update scene numbers
        for (index, scene) in scenes.enumerated() {
            scene.sceneNumber = index + 1
        }

        // Re-layout with animation
        layoutCards(scenes: scenes)
    }

    // MARK: - Hover

    func setHoverState(for sceneId: UUID, isHovered: Bool) {
        guard let card = sceneCards[sceneId] else { return }
        card.updateAppearance(isSelected: false, isHovered: isHovered)
    }

    // MARK: - Hit Testing

    func findCard(at worldPosition: SIMD3<Float>) -> SceneCardEntity? {
        // Find closest card to the position
        var closestCard: SceneCardEntity?
        var closestDistance: Float = .infinity

        for card in sceneCards.values {
            let distance = simd_distance(card.position(relativeTo: nil), worldPosition)
            if distance < closestDistance {
                closestDistance = distance
                closestCard = card
            }
        }

        // Return card if within reasonable distance (50cm)
        return closestDistance < 0.5 ? closestCard : nil
    }
}
