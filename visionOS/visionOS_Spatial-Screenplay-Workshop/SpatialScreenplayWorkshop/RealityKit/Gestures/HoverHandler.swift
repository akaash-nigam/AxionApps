//
//  HoverHandler.swift
//  SpatialScreenplayWorkshop
//
//  Created on 2025-11-24
//

import RealityKit
import Foundation

/// Handles hover effects when user gazes at scene cards
@MainActor
final class HoverHandler {
    // MARK: - Properties

    weak var timelineContainer: TimelineContainerEntity?
    var onCardHoverBegin: ((Scene) -> Void)?
    var onCardHoverEnd: ((Scene) -> Void)?

    private var currentlyHoveredCard: SceneCardEntity?

    // Hover timer for delayed actions
    private var hoverTimer: Timer?
    private let hoverDelay: TimeInterval = 0.5  // 500ms hover shows tooltip

    // MARK: - Initialization

    init(timelineContainer: TimelineContainerEntity?) {
        self.timelineContainer = timelineContainer
    }

    // MARK: - Hover Handling

    func handleHoverBegin(on entity: Entity) {
        guard let card = findSceneCard(from: entity) else { return }

        // Skip if already hovering this card
        if currentlyHoveredCard?.scene.id == card.scene.id {
            return
        }

        // End previous hover if exists
        if let previousCard = currentlyHoveredCard {
            handleHoverEnd(card: previousCard)
        }

        // Start new hover
        currentlyHoveredCard = card

        // Visual feedback: highlight card
        card.updateAppearance(isHovered: true)

        // Notify timeline container
        timelineContainer?.setHoverState(for: card.scene.id, isHovered: true)

        // Callback
        onCardHoverBegin?(card.scene)

        // Start timer for delayed hover actions (like showing tooltip)
        startHoverTimer(for: card)
    }

    func handleHoverEnd() {
        guard let card = currentlyHoveredCard else { return }
        handleHoverEnd(card: card)
    }

    private func handleHoverEnd(card: SceneCardEntity) {
        // Clear hover state
        card.updateAppearance(isHovered: false)

        // Notify timeline container
        timelineContainer?.setHoverState(for: card.scene.id, isHovered: false)

        // Callback
        onCardHoverEnd?(card.scene)

        // Cancel hover timer
        hoverTimer?.invalidate()
        hoverTimer = nil

        currentlyHoveredCard = nil
    }

    func handleHoverUpdate(on entity: Entity) {
        guard let card = findSceneCard(from: entity) else {
            // Hovering outside cards, end current hover
            if currentlyHoveredCard != nil {
                handleHoverEnd()
            }
            return
        }

        // If hovering different card, switch hover
        if currentlyHoveredCard?.scene.id != card.scene.id {
            handleHoverBegin(on: entity)
        }
    }

    // MARK: - Hover Timer

    private func startHoverTimer(for card: SceneCardEntity) {
        hoverTimer?.invalidate()

        hoverTimer = Timer.scheduledTimer(withTimeInterval: hoverDelay, repeats: false) { [weak self] _ in
            self?.handleHoverTimeout(for: card)
        }
    }

    private func handleHoverTimeout(for card: SceneCardEntity) {
        // Show tooltip or additional info after hover delay
        // This would trigger a UI overlay with scene details
        print("Hover timeout for scene: \(card.scene.sceneNumber)")
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

    // MARK: - Configuration

    func setCallbacks(
        onBegin: @escaping (Scene) -> Void,
        onEnd: @escaping (Scene) -> Void
    ) {
        self.onCardHoverBegin = onBegin
        self.onCardHoverEnd = onEnd
    }

    // MARK: - Cleanup

    func cleanup() {
        hoverTimer?.invalidate()
        hoverTimer = nil
        currentlyHoveredCard = nil
    }
}
