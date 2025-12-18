//
//  System.swift
//  HolographicBoardGames
//
//  Entity-Component-System: System protocol
//

import Foundation

/// Protocol that all systems must conform to
///
/// Systems can be implemented in two ways:
/// 1. Inherit from `BaseSystem` for convenience (provides `isActive` storage)
/// 2. Implement `System` directly and provide your own `isActive` property
protocol System: AnyObject {
    /// Priority determines update order (higher = earlier)
    var priority: Int { get }

    /// Whether this system is currently active
    /// Note: Must provide storage (inherit from BaseSystem or implement yourself)
    var isActive: Bool { get set }

    /// Called once when system is added
    func initialize()

    /// Called every frame
    func update(entities: [Entity], deltaTime: TimeInterval)

    /// Called when system is removed
    func shutdown()
}

// MARK: - Default Implementations

extension System {
    var priority: Int { 0 }

    func initialize() {
        // Default implementation does nothing
    }

    func shutdown() {
        // Default implementation does nothing
    }
}

// MARK: - Base System Implementation

/// Base class for systems that provides default isActive storage
/// Concrete systems can inherit from this or implement System directly
class BaseSystem: System {
    var isActive: Bool = true

    func update(entities: [Entity], deltaTime: TimeInterval) {
        // Override in subclasses
    }
}

// MARK: - System Comparison

extension System {
    /// Compare systems by priority for sorting
    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.priority < rhs.priority
    }
}
