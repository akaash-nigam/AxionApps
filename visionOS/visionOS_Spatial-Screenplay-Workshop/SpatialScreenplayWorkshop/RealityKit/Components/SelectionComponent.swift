//
//  SelectionComponent.swift
//  SpatialScreenplayWorkshop
//
//  Created on 2025-11-24
//

import RealityKit
import Foundation

/// Component for managing entity selection state
struct SelectionComponent: Component {
    // MARK: - Properties

    var isSelected: Bool = false
    var selectionTime: Date?

    // Visual configuration
    var selectedColor: UIColor?
    var selectedScale: Float = 1.1
    var selectionAnimationDuration: TimeInterval = 0.15

    // Selection group (for multi-select)
    var selectionGroup: String?

    // MARK: - Selection Management

    mutating func select() {
        isSelected = true
        selectionTime = Date()
    }

    mutating func deselect() {
        isSelected = false
        selectionTime = nil
    }

    mutating func toggle() {
        if isSelected {
            deselect()
        } else {
            select()
        }
    }

    // MARK: - Queries

    var wasRecentlySelected: Bool {
        guard let time = selectionTime else { return false }
        return Date().timeIntervalSince(time) < 1.0  // Within last second
    }

    var selectionDuration: TimeInterval {
        guard let time = selectionTime else { return 0 }
        return Date().timeIntervalSince(time)
    }

    // MARK: - Factory Methods

    static func defaultSelection() -> SelectionComponent {
        return SelectionComponent(
            isSelected: false,
            selectedScale: 1.1,
            selectionAnimationDuration: 0.15
        )
    }

    static func customSelection(
        scale: Float,
        duration: TimeInterval,
        color: UIColor? = nil
    ) -> SelectionComponent {
        return SelectionComponent(
            isSelected: false,
            selectedColor: color,
            selectedScale: scale,
            selectionAnimationDuration: duration
        )
    }
}

// MARK: - Entity Extension

extension Entity {
    /// Get or create selection component
    var selection: SelectionComponent {
        get {
            components[SelectionComponent.self] ?? .defaultSelection()
        }
        set {
            components[SelectionComponent.self] = newValue
        }
    }

    /// Check if entity is currently selected
    var isSelected: Bool {
        get {
            selection.isSelected
        }
        set {
            var component = selection
            if newValue {
                component.select()
            } else {
                component.deselect()
            }
            components[SelectionComponent.self] = component
        }
    }

    /// Toggle selection state
    func toggleSelection() {
        var component = selection
        component.toggle()
        components[SelectionComponent.self] = component
    }
}

// MARK: - Selection System

/// System that manages selection behavior across entities
@MainActor
final class SelectionSystem {
    private var selectedEntities: Set<ObjectIdentifier> = []
    private let multiSelectEnabled: Bool

    init(multiSelectEnabled: Bool = false) {
        self.multiSelectEnabled = multiSelectEnabled
    }

    func select(_ entity: Entity) {
        // If multi-select disabled, deselect all others
        if !multiSelectEnabled {
            deselectAll()
        }

        entity.isSelected = true
        selectedEntities.insert(ObjectIdentifier(entity))
    }

    func deselect(_ entity: Entity) {
        entity.isSelected = false
        selectedEntities.remove(ObjectIdentifier(entity))
    }

    func deselectAll() {
        selectedEntities.removeAll()
    }

    func toggle(_ entity: Entity) {
        if selectedEntities.contains(ObjectIdentifier(entity)) {
            deselect(entity)
        } else {
            select(entity)
        }
    }

    var hasSelection: Bool {
        !selectedEntities.isEmpty
    }

    var selectionCount: Int {
        selectedEntities.count
    }
}
