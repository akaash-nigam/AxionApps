import Foundation

// MARK: - Game Event Definition
enum GameEvent {
    case stateChanged(from: GameState, to: GameState)
    case playerHidden(Player)
    case playerFound(Player, foundBy: Player)
    case abilityActivated(Ability, by: Player)
    case boundaryViolation(Player, location: SIMD3<Float>)
    case achievementUnlocked(Achievement, for: Player)
}

// MARK: - Event Bus
actor EventBus {
    private var subscribers: [UUID: (GameEvent) async -> Void] = [:]

    func subscribe(_ handler: @escaping (GameEvent) async -> Void) -> UUID {
        let id = UUID()
        subscribers[id] = handler
        return id
    }

    func unsubscribe(_ id: UUID) {
        subscribers.removeValue(forKey: id)
    }

    func emit(_ event: GameEvent) async {
        for handler in subscribers.values {
            await handler(event)
        }
    }

    func emitSync(_ event: GameEvent) {
        Task {
            await emit(event)
        }
    }
}
