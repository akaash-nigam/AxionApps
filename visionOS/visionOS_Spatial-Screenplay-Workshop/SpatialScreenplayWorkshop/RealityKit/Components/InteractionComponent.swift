//
//  InteractionComponent.swift
//  SpatialScreenplayWorkshop
//
//  Created on 2025-11-24
//

import RealityKit

/// Component for managing entity interaction state
struct InteractionComponent: Component {
    // MARK: - Properties

    var isInteractive: Bool = true
    var isDraggable: Bool = true
    var isSelectable: Bool = true
    var isHoverable: Bool = true

    // Current interaction state
    var isBeingDragged: Bool = false
    var isDragCandidate: Bool = false  // User has pressed but not moved yet

    // Gesture configuration
    var dragThreshold: Float = 0.05  // 5cm to start drag
    var doubleTapThreshold: TimeInterval = 0.3  // 300ms for double-tap

    // Visual feedback
    var highlightOnHover: Bool = true
    var scaleOnSelect: Float = 1.1
    var liftOnDrag: Float = 0.05  // 5cm lift when dragging

    // MARK: - State Queries

    func canReceiveTap() -> Bool {
        return isInteractive && isSelectable && !isBeingDragged
    }

    func canBeginDrag() -> Bool {
        return isInteractive && isDraggable
    }

    func canReceiveHover() -> Bool {
        return isInteractive && isHoverable
    }

    // MARK: - Factory Methods

    static func fullInteraction() -> InteractionComponent {
        return InteractionComponent(
            isInteractive: true,
            isDraggable: true,
            isSelectable: true,
            isHoverable: true
        )
    }

    static func selectOnly() -> InteractionComponent {
        return InteractionComponent(
            isInteractive: true,
            isDraggable: false,
            isSelectable: true,
            isHoverable: true
        )
    }

    static func viewOnly() -> InteractionComponent {
        return InteractionComponent(
            isInteractive: true,
            isDraggable: false,
            isSelectable: false,
            isHoverable: true
        )
    }

    static func disabled() -> InteractionComponent {
        return InteractionComponent(
            isInteractive: false,
            isDraggable: false,
            isSelectable: false,
            isHoverable: false
        )
    }
}

// MARK: - Entity Extension

extension Entity {
    /// Get or create interaction component
    var interaction: InteractionComponent {
        get {
            components[InteractionComponent.self] ?? .fullInteraction()
        }
        set {
            components[InteractionComponent.self] = newValue
        }
    }

    /// Check if entity can be interacted with
    var isInteractive: Bool {
        interaction.isInteractive
    }

    /// Enable/disable all interactions
    func setInteractive(_ enabled: Bool) {
        var component = interaction
        component.isInteractive = enabled
        components[InteractionComponent.self] = component
    }
}
