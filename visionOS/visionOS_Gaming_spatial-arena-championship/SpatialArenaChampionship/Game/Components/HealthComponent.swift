//
//  HealthComponent.swift
//  Spatial Arena Championship
//
//  Health and damage tracking component
//

import Foundation
import RealityKit

// MARK: - Health Component

struct HealthComponent: Component, Codable {
    var current: Float
    var maximum: Float
    var shields: Float
    var maxShields: Float

    var lastDamageTime: TimeInterval?
    var lastDamageSource: UUID?

    var isAlive: Bool {
        current > 0
    }

    var healthPercentage: Float {
        guard maximum > 0 else { return 0 }
        return current / maximum
    }

    var shieldPercentage: Float {
        guard maxShields > 0 else { return 0 }
        return shields / maxShields
    }

    init(
        health: Float = GameConstants.Combat.baseHealth,
        shields: Float = GameConstants.Combat.baseShields
    ) {
        self.current = health
        self.maximum = health
        self.shields = shields
        self.maxShields = shields
    }

    mutating func takeDamage(_ amount: Float, from source: UUID?, at time: TimeInterval) {
        // Apply to shields first
        if shields > 0 {
            let shieldDamage = min(amount, shields)
            shields -= shieldDamage
            let remainingDamage = amount - shieldDamage
            if remainingDamage > 0 {
                current -= remainingDamage
            }
        } else {
            current -= amount
        }

        current = max(0, current)
        lastDamageTime = time
        lastDamageSource = source
    }

    mutating func heal(_ amount: Float) {
        current = min(current + amount, maximum)
    }

    mutating func restoreShields(_ amount: Float) {
        shields = min(shields + amount, maxShields)
    }

    mutating func regenerateShields(deltaTime: TimeInterval) {
        guard let lastDamage = lastDamageTime else {
            // Never damaged, regenerate immediately
            shields = min(shields + GameConstants.Combat.shieldRegenRate * Float(deltaTime), maxShields)
            return
        }

        let timeSinceDamage = Date().timeIntervalSince1970 - lastDamage
        if timeSinceDamage >= GameConstants.Combat.shieldRegenDelay {
            shields = min(shields + GameConstants.Combat.shieldRegenRate * Float(deltaTime), maxShields)
        }
    }

    mutating func regenerateHealth(deltaTime: TimeInterval) {
        guard let lastDamage = lastDamageTime else {
            // Never damaged, regenerate immediately
            current = min(current + GameConstants.Combat.healthRegenRate * Float(deltaTime), maximum)
            return
        }

        let timeSinceDamage = Date().timeIntervalSince1970 - lastDamage
        if timeSinceDamage >= GameConstants.Combat.healthRegenDelay {
            current = min(current + GameConstants.Combat.healthRegenRate * Float(deltaTime), maximum)
        }
    }
}
