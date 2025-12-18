import Foundation

/// Weapon types available in the game
public enum WeaponType: String, Codable, Sendable {
    case spatialRifle
    case pulseBlaster
    case gravityLauncher
    case energySword
}

/// Component for weapon handling
public struct WeaponComponent: Component {
    public let entityID: UUID
    public var weaponType: WeaponType
    public var damage: Float
    public var fireRate: TimeInterval
    public var ammo: Int
    public var maxAmmo: Int
    public var lastFireTime: TimeInterval

    public init(
        entityID: UUID,
        weaponType: WeaponType = .spatialRifle,
        damage: Float = 25,
        fireRate: TimeInterval = 0.1,
        ammo: Int = 30,
        maxAmmo: Int = 30,
        lastFireTime: TimeInterval = 0
    ) {
        self.entityID = entityID
        self.weaponType = weaponType
        self.damage = damage
        self.fireRate = fireRate
        self.ammo = ammo
        self.maxAmmo = maxAmmo
        self.lastFireTime = lastFireTime
    }

    public var canFire: Bool {
        return ammo > 0
    }

    public var needsReload: Bool {
        return ammo == 0
    }

    public mutating func fire(at currentTime: TimeInterval) -> Bool {
        guard canFire && (currentTime - lastFireTime) >= fireRate else {
            return false
        }

        ammo -= 1
        lastFireTime = currentTime
        return true
    }

    public mutating func reload() {
        ammo = maxAmmo
    }
}

/// Component for combat state
public struct CombatComponent: Component {
    public let entityID: UUID
    public var team: Int
    public var isInCombat: Bool
    public var lastAttacker: UUID?
    public var damageMultiplier: Float

    public init(
        entityID: UUID,
        team: Int = 0,
        isInCombat: Bool = false,
        lastAttacker: UUID? = nil,
        damageMultiplier: Float = 1.0
    ) {
        self.entityID = entityID
        self.team = team
        self.isInCombat = isInCombat
        self.lastAttacker = lastAttacker
        self.damageMultiplier = damageMultiplier
    }
}
