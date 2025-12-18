import Foundation
import RealityKit

actor SeekingMechanicsSystem {
    private var activeAbilities: [UUID: SeekingAbilityState] = [:]
    private var generatedClues: [UUID: [Clue]] = [:]

    struct SeekingAbilityState {
        var ability: Ability
        var activatedAt: Date
        var lastUsed: Date
        var isOnCooldown: Bool {
            Date().timeIntervalSince(lastUsed) < ability.cooldownDuration
        }
    }

    struct Clue {
        let id: UUID
        let type: ClueType
        let position: SIMD3<Float>
        let createdAt: Date
        let playerId: UUID  // Which hider left this clue
        var lifetime: TimeInterval = 30.0

        var isExpired: Bool {
            Date().timeIntervalSince(createdAt) > lifetime
        }

        enum ClueType {
            case footprint
            case disturbance
            case soundIndicator
        }
    }

    // MARK: - Thermal Vision

    func activateThermalVision(
        for seekerId: UUID,
        range: Float = 5.0
    ) async throws {
        let ability = Ability.thermalVision(range: range)

        // Check cooldown
        if let state = activeAbilities[seekerId], state.isOnCooldown {
            throw SeekingError.abilityOnCooldown(remainingTime: ability.cooldownDuration - Date().timeIntervalSince(state.lastUsed))
        }

        // Activate ability
        activeAbilities[seekerId] = SeekingAbilityState(
            ability: ability,
            activatedAt: Date(),
            lastUsed: Date()
        )

        // Auto-deactivate after 10 seconds
        Task {
            try? await Task.sleep(for: .seconds(10))
            await self.deactivateThermalVision(for: seekerId)
        }
    }

    func deactivateThermalVision(for seekerId: UUID) async {
        activeAbilities.removeValue(forKey: seekerId)
    }

    func findHidersInThermalRange(
        from seekerPosition: SIMD3<Float>,
        range: Float,
        hiders: [Player]
    ) async -> [Player] {
        return hiders.filter { hider in
            let distance = length(hider.position - seekerPosition)
            return distance <= range
        }
    }

    // MARK: - Clue Detection

    func activateClueDetection(
        for seekerId: UUID,
        sensitivity: Float = 1.0
    ) async throws {
        let ability = Ability.clueDetection(sensitivity: sensitivity)

        // Check cooldown
        if let state = activeAbilities[seekerId], state.isOnCooldown {
            throw SeekingError.abilityOnCooldown(remainingTime: ability.cooldownDuration - Date().timeIntervalSince(state.lastUsed))
        }

        // Activate ability
        activeAbilities[seekerId] = SeekingAbilityState(
            ability: ability,
            activatedAt: Date(),
            lastUsed: Date()
        )
    }

    func deactivateClueDetection(for seekerId: UUID) async {
        activeAbilities.removeValue(forKey: seekerId)
    }

    // MARK: - Clue Generation

    func generateFootprint(
        at position: SIMD3<Float>,
        for playerId: UUID
    ) async -> Clue {
        let clue = Clue(
            id: UUID(),
            type: .footprint,
            position: position,
            createdAt: Date(),
            playerId: playerId,
            lifetime: 30.0
        )

        // Store clue
        if generatedClues[playerId] == nil {
            generatedClues[playerId] = []
        }
        generatedClues[playerId]?.append(clue)

        // Clean up expired clues
        await cleanupExpiredClues(for: playerId)

        return clue
    }

    func generateDisturbance(
        at position: SIMD3<Float>,
        for playerId: UUID
    ) async -> Clue {
        let clue = Clue(
            id: UUID(),
            type: .disturbance,
            position: position,
            createdAt: Date(),
            playerId: playerId,
            lifetime: 45.0
        )

        if generatedClues[playerId] == nil {
            generatedClues[playerId] = []
        }
        generatedClues[playerId]?.append(clue)

        return clue
    }

    func getVisibleClues(
        for seekerId: UUID,
        from position: SIMD3<Float>,
        maxDistance: Float = 3.0
    ) async -> [Clue] {
        var visibleClues: [Clue] = []

        // Check all players' clues
        for (_, clues) in generatedClues {
            let nearbyClues = clues.filter { clue in
                !clue.isExpired &&
                length(clue.position - position) <= maxDistance
            }
            visibleClues.append(contentsOf: nearbyClues)
        }

        // If clue detection is active, increase range
        if let state = activeAbilities[seekerId],
           case .clueDetection(let sensitivity) = state.ability {
            let enhancedDistance = maxDistance * sensitivity

            for (_, clues) in generatedClues {
                let enhancedClues = clues.filter { clue in
                    !clue.isExpired &&
                    length(clue.position - position) <= enhancedDistance &&
                    !visibleClues.contains(where: { $0.id == clue.id })
                }
                visibleClues.append(contentsOf: enhancedClues)
            }
        }

        return visibleClues
    }

    private func cleanupExpiredClues(for playerId: UUID) async {
        generatedClues[playerId]?.removeAll { $0.isExpired }
    }

    // MARK: - Ability Status

    func getActiveAbility(for seekerId: UUID) -> Ability? {
        return activeAbilities[seekerId]?.ability
    }

    func getCooldownRemaining(for seekerId: UUID) -> TimeInterval {
        guard let state = activeAbilities[seekerId] else { return 0 }
        let elapsed = Date().timeIntervalSince(state.lastUsed)
        return max(0, state.ability.cooldownDuration - elapsed)
    }

    func getTotalCluesGenerated(for playerId: UUID) -> Int {
        return generatedClues[playerId]?.count ?? 0
    }

    func getActiveCluesCount(for playerId: UUID) -> Int {
        return generatedClues[playerId]?.filter { !$0.isExpired }.count ?? 0
    }
}

// MARK: - Errors

enum SeekingError: Error {
    case abilityOnCooldown(remainingTime: TimeInterval)
    case noHidersInRange
}
