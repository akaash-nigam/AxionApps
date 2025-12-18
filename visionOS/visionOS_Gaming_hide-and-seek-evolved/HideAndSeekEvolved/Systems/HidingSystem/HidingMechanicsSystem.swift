import Foundation
import RealityKit

actor HidingMechanicsSystem {
    private var activeAbilities: [UUID: AbilityState] = [:]

    struct AbilityState {
        var ability: Ability
        var activatedAt: Date
        var lastUsed: Date
        var isOnCooldown: Bool {
            Date().timeIntervalSince(lastUsed) < ability.cooldownDuration
        }
    }

    // MARK: - Camouflage

    func activateCamouflage(
        for playerId: UUID,
        entity: Entity,
        targetOpacity: Float = 0.1
    ) async throws {
        let ability = Ability.camouflage(opacity: targetOpacity)

        // Check cooldown
        if let state = activeAbilities[playerId], state.isOnCooldown {
            throw HidingError.abilityOnCooldown(remainingTime: ability.cooldownDuration - Date().timeIntervalSince(state.lastUsed))
        }

        // Activate ability
        activeAbilities[playerId] = AbilityState(
            ability: ability,
            activatedAt: Date(),
            lastUsed: Date()
        )

        // Apply opacity change to entity
        await applyOpacityChange(to: entity, targetOpacity: targetOpacity, duration: 2.0)
    }

    func deactivateCamouflage(for playerId: UUID, entity: Entity) async {
        guard activeAbilities[playerId] != nil else { return }

        // Remove ability
        activeAbilities.removeValue(forKey: playerId)

        // Restore full opacity
        await applyOpacityChange(to: entity, targetOpacity: 1.0, duration: 1.5)
    }

    private func applyOpacityChange(to entity: Entity, targetOpacity: Float, duration: TimeInterval) async {
        // In a real implementation, this would animate the material opacity
        // For now, we'll simulate the completion
        try? await Task.sleep(for: .seconds(duration))
    }

    // MARK: - Size Manipulation

    func manipulateSize(
        for playerId: UUID,
        entity: Entity,
        targetScale: Float
    ) async throws {
        // Validate scale
        guard targetScale >= 0.3 && targetScale <= 2.0 else {
            throw HidingError.invalidScale
        }

        // Check if player is moving
        // In real implementation, would check velocity
        // For now, assume player is stationary

        // Check cooldown
        if let state = activeAbilities[playerId], state.isOnCooldown {
            let ability = Ability.sizeManipulation(scale: targetScale)
            throw HidingError.abilityOnCooldown(remainingTime: ability.cooldownDuration - Date().timeIntervalSince(state.lastUsed))
        }

        // Check space availability
        let hasSpace = await checkSpaceAvailable(at: entity.position, for: targetScale)
        guard hasSpace else {
            throw HidingError.insufficientSpace
        }

        // Activate ability
        let ability = Ability.sizeManipulation(scale: targetScale)
        activeAbilities[playerId] = AbilityState(
            ability: ability,
            activatedAt: Date(),
            lastUsed: Date()
        )

        // Apply scale change
        await applyScaleChange(to: entity, targetScale: targetScale, duration: 1.5)
    }

    private func checkSpaceAvailable(at position: SIMD3<Float>, for scale: Float) async -> Bool {
        // In real implementation, would check collision with room bounds and furniture
        // For now, always return true
        return true
    }

    private func applyScaleChange(to entity: Entity, targetScale: Float, duration: TimeInterval) async {
        // Animate scale change
        try? await Task.sleep(for: .seconds(duration))
    }

    // MARK: - Sound Masking

    func activateSoundMasking(
        for playerId: UUID,
        effectiveness: Float = 0.8
    ) async throws {
        let ability = Ability.soundMasking(effectiveness: effectiveness)

        // Check cooldown
        if let state = activeAbilities[playerId], state.isOnCooldown {
            throw HidingError.abilityOnCooldown(remainingTime: ability.cooldownDuration - Date().timeIntervalSince(state.lastUsed))
        }

        // Activate ability
        activeAbilities[playerId] = AbilityState(
            ability: ability,
            activatedAt: Date(),
            lastUsed: Date()
        )
    }

    func deactivateSoundMasking(for playerId: UUID) async {
        activeAbilities.removeValue(forKey: playerId)
    }

    // MARK: - Ability Status

    func getActiveAbility(for playerId: UUID) -> Ability? {
        return activeAbilities[playerId]?.ability
    }

    func getCooldownRemaining(for playerId: UUID) -> TimeInterval {
        guard let state = activeAbilities[playerId] else { return 0 }
        let elapsed = Date().timeIntervalSince(state.lastUsed)
        return max(0, state.ability.cooldownDuration - elapsed)
    }

    func isAbilityActive(for playerId: UUID) -> Bool {
        return activeAbilities[playerId] != nil
    }
}

// MARK: - Errors

enum HidingError: Error {
    case invalidScale
    case cannotScaleWhileMoving
    case insufficientSpace
    case abilityOnCooldown(remainingTime: TimeInterval)
}
