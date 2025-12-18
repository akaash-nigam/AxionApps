//
//  GestureManager.swift
//  SpatialCodeReviewer
//
//  Created by Claude on 2025-11-24.
//  Story 0.7: Basic Gestures
//

import RealityKit
import SwiftUI

/// Manages all gesture interactions for code windows in 3D space
@MainActor
class GestureManager: ObservableObject {

    // MARK: - Published State

    @Published var selectedEntity: Entity?
    @Published var isDragging = false
    @Published var isScaling = false
    @Published var scrollOffset: Int = 0

    // MARK: - Private State

    private var initialScale: SIMD3<Float> = [1, 1, 1]
    private var initialPosition: SIMD3<Float> = [0, 0, 0]
    private var dragStartPosition: SIMD3<Float>?

    // MARK: - Configuration

    struct GestureConfiguration {
        var minScale: Float = 0.3
        var maxScale: Float = 2.0
        var dragSensitivity: Float = 0.001
        var scrollSensitivity: Int = 1
    }

    private let config = GestureConfiguration()

    // MARK: - Gesture Handlers

    /// Handles tap gesture for selection
    func handleTap(on entity: Entity) {
        // Deselect previous
        if let previous = selectedEntity {
            updateBorderColor(entity: previous, focused: false)
        }

        // Select new
        selectedEntity = entity
        updateBorderColor(entity: entity, focused: true)

        // Reset scroll offset for new selection
        scrollOffset = 0

        print("📍 Selected: \(entity.name)")
    }

    /// Handles drag start
    func handleDragStart(on entity: Entity, at location: SIMD3<Float>) {
        guard let selectedEntity = selectedEntity, selectedEntity == entity else {
            return
        }

        isDragging = true
        initialPosition = entity.position
        dragStartPosition = location

        print("🖐️ Drag started on: \(entity.name)")
    }

    /// Handles drag changed
    func handleDragChanged(translation: SIMD3<Float>) {
        guard let entity = selectedEntity, isDragging else { return }

        // Apply translation with sensitivity
        let delta = translation * config.dragSensitivity
        entity.position = initialPosition + delta

        print("↔️ Dragging: \(entity.position)")
    }

    /// Handles drag ended
    func handleDragEnded() {
        isDragging = false
        dragStartPosition = nil

        if let entity = selectedEntity {
            print("✋ Drag ended at: \(entity.position)")
        }
    }

    /// Handles pinch gesture for scaling
    func handlePinchStart(on entity: Entity) {
        guard let selectedEntity = selectedEntity, selectedEntity == entity else {
            return
        }

        isScaling = true
        initialScale = entity.scale

        print("🤏 Pinch started on: \(entity.name)")
    }

    /// Handles pinch changed
    func handlePinchChanged(scale: Float) {
        guard let entity = selectedEntity, isScaling else { return }

        // Apply scale with limits
        let newScale = initialScale * SIMD3<Float>(repeating: scale)
        let clampedScale = clamp(newScale, min: config.minScale, max: config.maxScale)

        entity.scale = clampedScale

        print("🔍 Scaling: \(entity.scale.x)")
    }

    /// Handles pinch ended
    func handlePinchEnded() {
        isScaling = false

        if let entity = selectedEntity {
            print("👌 Pinch ended at scale: \(entity.scale.x)")
        }
    }

    /// Handles scroll gesture for code windows
    func handleScroll(delta: Int) {
        guard let entity = selectedEntity else { return }

        // Check if entity has code window component
        guard var codeWindow = entity.components[CodeWindowComponent.self] else {
            return
        }

        // Update scroll offset
        let newOffset = scrollOffset + (delta * config.scrollSensitivity)
        let maxOffset = max(0, codeWindow.lineCount - 40) // 40 visible lines

        scrollOffset = max(0, min(newOffset, maxOffset))

        print("📜 Scrolling: offset = \(scrollOffset)/\(maxOffset)")

        // TODO: Re-render code texture with new offset (Story 0.6 integration)
        // For now, just update the component
        codeWindow.scrollOffset = Float(scrollOffset)
        entity.components[CodeWindowComponent.self] = codeWindow
    }

    /// Resets entity to original transform
    func resetTransform(for entity: Entity) {
        entity.scale = [1, 1, 1]
        scrollOffset = 0

        print("🔄 Reset transform for: \(entity.name)")
    }

    // MARK: - Helper Methods

    private func updateBorderColor(entity: Entity, focused: Bool) {
        // Find border child entity
        guard let border = entity.children.first(where: { $0.name == "Border" }),
              var model = border.components[ModelComponent.self] else {
            return
        }

        var material = model.materials.first as? UnlitMaterial ?? UnlitMaterial()
        let color = focused ? UIColor.systemBlue : UIColor.systemGray
        material.color = .init(tint: color.withAlphaComponent(focused ? 0.8 : 0.3))

        model.materials = [material]
        border.components[ModelComponent.self] = model
    }

    private func clamp(_ value: SIMD3<Float>, min: Float, max: Float) -> SIMD3<Float> {
        return SIMD3<Float>(
            Swift.max(min, Swift.min(max, value.x)),
            Swift.max(min, Swift.min(max, value.y)),
            Swift.max(min, Swift.min(max, value.z))
        )
    }
}

// MARK: - Gesture Types

/// Represents a 3D drag gesture
struct DragGesture3D {
    let startPosition: SIMD3<Float>
    let currentPosition: SIMD3<Float>

    var translation: SIMD3<Float> {
        return currentPosition - startPosition
    }

    var distance: Float {
        return length(translation)
    }
}

/// Represents a pinch gesture with scale factor
struct PinchGesture3D {
    let initialScale: SIMD3<Float>
    let scaleFactor: Float

    var newScale: SIMD3<Float> {
        return initialScale * SIMD3<Float>(repeating: scaleFactor)
    }
}

// MARK: - Gesture Extension for RealityKit

extension Entity {
    /// Animates entity to target position
    func animateToPosition(
        _ position: SIMD3<Float>,
        duration: TimeInterval = 0.3
    ) {
        let animation = FromToByAnimation(
            from: Transform(translation: self.position),
            to: Transform(translation: position),
            duration: duration,
            timing: .easeInOut,
            bindTarget: .transform
        )

        self.playAnimation(animation.repeat())
    }

    /// Animates entity to target scale
    func animateToScale(
        _ scale: SIMD3<Float>,
        duration: TimeInterval = 0.3
    ) {
        let animation = FromToByAnimation(
            from: Transform(scale: self.scale),
            to: Transform(scale: scale),
            duration: duration,
            timing: .easeInOut,
            bindTarget: .transform
        )

        self.playAnimation(animation.repeat())
    }

    /// Pulses entity (for feedback)
    func pulse(intensity: Float = 1.1, duration: TimeInterval = 0.2) {
        let originalScale = self.scale
        let pulseScale = originalScale * SIMD3<Float>(repeating: intensity)

        let pulseOut = FromToByAnimation(
            from: Transform(scale: originalScale),
            to: Transform(scale: pulseScale),
            duration: duration / 2,
            timing: .easeOut,
            bindTarget: .transform
        )

        let pulseIn = FromToByAnimation(
            from: Transform(scale: pulseScale),
            to: Transform(scale: originalScale),
            duration: duration / 2,
            timing: .easeIn,
            bindTarget: .transform
        )

        self.playAnimation(pulseOut.repeat(), startsPaused: false)

        DispatchQueue.main.asyncAfter(deadline: .now() + duration / 2) {
            self.playAnimation(pulseIn.repeat(), startsPaused: false)
        }
    }
}
