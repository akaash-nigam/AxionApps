import Foundation

/// Component representing health and damage state
public struct HealthComponent: Component {
    public let entityID: UUID
    public var current: Float
    public let maximum: Float
    public var regenerationRate: Float
    public var lastDamageTime: TimeInterval

    public init(
        entityID: UUID,
        current: Float,
        maximum: Float,
        regenerationRate: Float = 0,
        lastDamageTime: TimeInterval = 0
    ) {
        self.entityID = entityID
        self.current = current
        self.maximum = maximum
        self.regenerationRate = regenerationRate
        self.lastDamageTime = lastDamageTime
    }

    /// Whether the entity is alive
    public var isAlive: Bool {
        return current > 0
    }

    /// Health as a percentage (0-1)
    public var healthPercentage: Float {
        return current / maximum
    }

    /// Apply damage to this health component
    public mutating func takeDamage(_ amount: Float, at time: TimeInterval) {
        current = max(0, current - amount)
        lastDamageTime = time
    }

    /// Heal this health component
    public mutating func heal(_ amount: Float) {
        current = min(maximum, current + amount)
    }
}
