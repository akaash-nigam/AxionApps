//
//  DragHandler.swift
//  SpatialScreenplayWorkshop
//
//  Created on 2025-11-24
//

import RealityKit
import Foundation

/// Handles drag gestures for scene card reordering
@MainActor
final class DragHandler {
    // MARK: - Properties

    weak var timelineContainer: TimelineContainerEntity?
    var onSceneReordered: ((Scene, Int) -> Void)?

    private var draggedCard: SceneCardEntity?
    private var originalPosition: SIMD3<Float>?
    private var dropTargetIndex: Int?

    // Drag threshold (5cm movement to start drag)
    private let dragThreshold: Float = 0.05

    // MARK: - Initialization

    init(timelineContainer: TimelineContainerEntity?) {
        self.timelineContainer = timelineContainer
    }

    // MARK: - Drag Lifecycle

    func beginDrag(on entity: Entity, at position: SIMD3<Float>) {
        guard let card = findSceneCard(from: entity) else { return }

        draggedCard = card
        originalPosition = card.position(relativeTo: nil)

        // Visual feedback: lift card slightly and increase scale
        var transform = card.transform
        transform.scale = SIMD3<Float>(1.1, 1.1, 1.1)
        transform.translation.z += 0.05  // Lift 5cm forward

        card.move(
            to: transform,
            relativeTo: card.parent,
            duration: 0.2,
            timingFunction: .easeOut
        )

        // Increase opacity to show it's being dragged
        card.updateAppearance(isSelected: true)
    }

    func updateDrag(to position: SIMD3<Float>) {
        guard let card = draggedCard else { return }

        // Move card to follow drag position
        card.animateDrag(to: position)

        // Determine drop target based on position
        calculateDropTarget(for: position)
    }

    func endDrag() {
        guard let card = draggedCard,
              let originalPos = originalPosition else {
            cleanupDrag()
            return
        }

        // If valid drop target, reorder scenes
        if let targetIndex = dropTargetIndex {
            onSceneReordered?(card.scene, targetIndex)
        } else {
            // Return to original position
            card.animateDrag(to: originalPos)
        }

        // Reset visual feedback
        var transform = card.transform
        transform.scale = SIMD3<Float>(1.0, 1.0, 1.0)
        transform.translation.z = originalPos.z

        card.move(
            to: transform,
            relativeTo: card.parent,
            duration: 0.2,
            timingFunction: .easeIn
        )

        card.updateAppearance(isSelected: false)

        cleanupDrag()
    }

    func cancelDrag() {
        guard let card = draggedCard,
              let originalPos = originalPosition else {
            cleanupDrag()
            return
        }

        // Return to original position
        card.animateDrag(to: originalPos)

        var transform = card.transform
        transform.scale = SIMD3<Float>(1.0, 1.0, 1.0)
        card.move(
            to: transform,
            relativeTo: card.parent,
            duration: 0.2,
            timingFunction: .easeIn
        )

        card.updateAppearance(isSelected: false)

        cleanupDrag()
    }

    // MARK: - Drop Target Calculation

    private func calculateDropTarget(for position: SIMD3<Float>) {
        // Find closest card position to determine insertion point
        guard let container = timelineContainer else { return }

        // This would iterate through all card positions and find the closest one
        // For now, simplified version
        dropTargetIndex = nil  // TODO: Implement proper drop target calculation
    }

    // MARK: - Helper Methods

    private func findSceneCard(from entity: Entity) -> SceneCardEntity? {
        var current: Entity? = entity

        while let entity = current {
            if let card = entity as? SceneCardEntity {
                return card
            }
            current = entity.parent
        }

        return nil
    }

    private func cleanupDrag() {
        draggedCard = nil
        originalPosition = nil
        dropTargetIndex = nil
    }

    // MARK: - Configuration

    func setReorderCallback(_ callback: @escaping (Scene, Int) -> Void) {
        self.onSceneReordered = callback
    }
}
