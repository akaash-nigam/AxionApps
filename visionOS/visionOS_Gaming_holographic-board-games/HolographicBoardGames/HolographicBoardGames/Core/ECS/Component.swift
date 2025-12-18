//
//  Component.swift
//  HolographicBoardGames
//
//  Entity-Component-System: Component protocol
//

import Foundation

/// Protocol that all components must conform to
protocol Component: AnyObject {
    /// The entity this component is attached to
    var entity: Entity? { get set }

    /// Called when component is added to an entity
    func onAdded()

    /// Called when component is removed from an entity
    func onRemoved()
}

// MARK: - Default Implementations

extension Component {
    func onAdded() {
        // Default implementation does nothing
    }

    func onRemoved() {
        // Default implementation does nothing
    }
}
