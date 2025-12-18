//
//  TapHandler.swift
//  SpatialScreenplayWorkshop
//
//  Created on 2025-11-24
//

import RealityKit
import Foundation

/// Handles tap gestures on scene cards in timeline
@MainActor
final class TapHandler {
    // MARK: - Properties

    weak var timelineContainer: TimelineContainerEntity?
    var onCardTapped: ((Scene) -> Void)?
    var onCardDoubleTapped: ((Scene) -> Void)?

    private var lastTapTime: Date?
    private var lastTappedCardId: UUID?

    /// Double-tap threshold (300ms)
    private let doubleTapThreshold: TimeInterval = 0.3

    // MARK: - Initialization

    init(timelineContainer: TimelineContainerEntity?) {
        self.timelineContainer = timelineContainer
    }

    // MARK: - Tap Handling

    func handleTap(on entity: Entity) {
        guard let card = findSceneCard(from: entity) else { return }

        let now = Date()

        // Check for double-tap
        if let lastTap = lastTapTime,
           let lastCardId = lastTappedCardId,
           lastCardId == card.scene.id,
           now.timeIntervalSince(lastTap) < doubleTapThreshold {
            // Double-tap detected
            handleDoubleTap(card: card)
            lastTapTime = nil
            lastTappedCardId = nil
        } else {
            // Single tap
            handleSingleTap(card: card)
            lastTapTime = now
            lastTappedCardId = card.scene.id
        }
    }

    private func handleSingleTap(card: SceneCardEntity) {
        // Select card
        timelineContainer?.selectCard(for: card.scene.id)

        // Trigger selection animation
        card.animateSelection()

        // Notify callback
        onCardTapped?(card.scene)
    }

    private func handleDoubleTap(card: SceneCardEntity) {
        // Open editor for scene
        onCardDoubleTapped?(card.scene)

        // Play feedback
        #if os(visionOS)
        // Spatial audio feedback
        playTapFeedback()
        #endif
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

    #if os(visionOS)
    private func playTapFeedback() {
        // Play spatial audio feedback for tap
        // Using AVFoundation for spatial audio
        // Implementation would use AVAudioEngine with spatial positioning
    }
    #endif

    // MARK: - Configuration

    func setCallbacks(
        onTap: @escaping (Scene) -> Void,
        onDoubleTap: @escaping (Scene) -> Void
    ) {
        self.onCardTapped = onTap
        self.onCardDoubleTapped = onDoubleTap
    }
}
