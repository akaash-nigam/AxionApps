import Foundation
import simd

/// Core game components for ECS architecture
/// Each component represents a specific aspect of game entity behavior

// MARK: - Transform Component

/// Spatial position and orientation of an entity
struct TransformComponent: Component {
    var entityID: UUID

    var position: SIMD3<Float>
    var rotation: simd_quatf
    var scale: SIMD3<Float>

    init(entityID: UUID,
         position: SIMD3<Float> = .zero,
         rotation: simd_quatf = simd_quatf(angle: 0, axis: SIMD3(0, 1, 0)),
         scale: SIMD3<Float> = SIMD3(1, 1, 1)) {
        self.entityID = entityID
        self.position = position
        self.rotation = rotation
        self.scale = scale
    }

    var forward: SIMD3<Float> {
        return rotation.act(SIMD3<Float>(0, 0, -1))
    }

    var up: SIMD3<Float> {
        return rotation.act(SIMD3<Float>(0, 1, 0))
    }

    var right: SIMD3<Float> {
        return rotation.act(SIMD3<Float>(1, 0, 0))
    }
}

// MARK: - Combat Component

/// Health, armor, and combat-related state
struct CombatComponent: Component {
    var entityID: UUID

    var health: Float
    var maxHealth: Float
    var armor: Float
    var maxArmor: Float
    var team: Team
    var combatState: CombatState
    var isVulnerable: Bool
    var lastDamageTime: TimeInterval
    var lastDamageDealer: UUID?

    init(entityID: UUID,
         maxHealth: Float = 100,
         maxArmor: Float = 100,
         team: Team = .neutral) {
        self.entityID = entityID
        self.health = maxHealth
        self.maxHealth = maxHealth
        self.armor = maxArmor
        self.maxArmor = maxArmor
        self.team = team
        self.combatState = .alive
        self.isVulnerable = true
        self.lastDamageTime = 0
    }

    var isDead: Bool {
        return health <= 0 || combatState == .dead
    }

    var healthPercentage: Float {
        return health / maxHealth
    }

    var armorPercentage: Float {
        return armor / maxArmor
    }
}

enum Team: String, Codable {
    case blue
    case red
    case neutral
}

enum CombatState: String, Codable {
    case alive
    case injured
    case critical
    case dead
    case respawning
}

// MARK: - Weapon Component

/// Weapon state and properties
struct WeaponComponent: Component {
    var entityID: UUID

    var weaponDefinitionID: UUID
    var currentAmmo: Int
    var reserveAmmo: Int
    var isAiming: Bool
    var isFiring: Bool
    var lastFireTime: TimeInterval
    var recoilOffset: SIMD3<Float>
    var currentRecoilAccumulation: Float
    var burstShotCount: Int

    init(entityID: UUID, weaponDefinitionID: UUID, maxAmmo: Int = 30, reserveAmmo: Int = 90) {
        self.entityID = entityID
        self.weaponDefinitionID = weaponDefinitionID
        self.currentAmmo = maxAmmo
        self.reserveAmmo = reserveAmmo
        self.isAiming = false
        self.isFiring = false
        self.lastFireTime = 0
        self.recoilOffset = .zero
        self.currentRecoilAccumulation = 0
        self.burstShotCount = 0
    }

    var hasAmmo: Bool {
        return currentAmmo > 0
    }

    var canReload: Bool {
        return currentAmmo < 30 && reserveAmmo > 0  // TODO: Use weapon's max ammo
    }
}

// MARK: - Movement Component

/// Movement state and physics
struct MovementComponent: Component {
    var entityID: UUID

    var velocity: SIMD3<Float>
    var acceleration: SIMD3<Float>
    var moveSpeed: Float
    var sprintSpeed: Float
    var crouchSpeed: Float
    var stance: PlayerStance
    var isGrounded: Bool
    var stamina: Float
    var maxStamina: Float

    init(entityID: UUID,
         moveSpeed: Float = 5.0,
         sprintSpeed: Float = 7.0,
         crouchSpeed: Float = 3.0) {
        self.entityID = entityID
        self.velocity = .zero
        self.acceleration = .zero
        self.moveSpeed = moveSpeed
        self.sprintSpeed = sprintSpeed
        self.crouchSpeed = crouchSpeed
        self.stance = .standing
        self.isGrounded = true
        self.stamina = 100
        self.maxStamina = 100
    }

    var currentMaxSpeed: Float {
        switch stance {
        case .standing: return moveSpeed
        case .crouching: return crouchSpeed
        case .prone: return crouchSpeed * 0.5
        }
    }
}

enum PlayerStance: String, Codable {
    case standing
    case crouching
    case prone
}

// MARK: - Projectile Component

/// Projectile physics and damage
struct ProjectileComponent: Component {
    var entityID: UUID

    var velocity: SIMD3<Float>
    var damage: Float
    var ownerID: UUID
    var teamID: Team
    var spawnTime: TimeInterval
    var maxDistance: Float
    var traveledDistance: Float
    var penetrationPower: Float

    init(entityID: UUID,
         velocity: SIMD3<Float>,
         damage: Float,
         ownerID: UUID,
         teamID: Team) {
        self.entityID = entityID
        self.velocity = velocity
        self.damage = damage
        self.ownerID = ownerID
        self.teamID = teamID
        self.spawnTime = CACurrentMediaTime()
        self.maxDistance = 1000.0
        self.traveledDistance = 0
        self.penetrationPower = 1.0
    }
}

// MARK: - AI Component

/// AI behavior and state
struct AIComponent: Component {
    var entityID: UUID

    var aiType: AIType
    var behaviorState: AIBehaviorState
    var targetEntity: UUID?
    var tacticalRole: TacticalRole
    var squad: UUID?
    var awarenessLevel: Float
    var lastKnownEnemyPosition: SIMD3<Float>?
    var patrolPoints: [SIMD3<Float>]
    var currentPatrolIndex: Int

    init(entityID: UUID,
         aiType: AIType = .soldier,
         tacticalRole: TacticalRole = .assault) {
        self.entityID = entityID
        self.aiType = aiType
        self.behaviorState = .idle
        self.tacticalRole = tacticalRole
        self.awarenessLevel = 0.5
        self.patrolPoints = []
        self.currentPatrolIndex = 0
    }
}

enum AIType: String, Codable {
    case soldier
    case sniper
    case support
    case commander
}

enum AIBehaviorState: String, Codable {
    case idle
    case patrol
    case investigate
    case engage
    case takeCover
    case retreat
    case dead
}

enum TacticalRole: String, Codable {
    case entry
    case assault
    case support
    case sniper
    case commander
}

// MARK: - Spatial Component

/// VisionOS spatial data
struct SpatialComponent: Component {
    var entityID: UUID

    var spatialPosition: SIMD3<Float>
    var spatialRotation: simd_quatf
    var boundingBox: BoundingBox
    var isGrounded: Bool
    var distanceToPlayer: Float

    init(entityID: UUID, position: SIMD3<Float> = .zero) {
        self.entityID = entityID
        self.spatialPosition = position
        self.spatialRotation = simd_quatf(angle: 0, axis: SIMD3(0, 1, 0))
        self.boundingBox = BoundingBox(min: position - 0.5, max: position + 0.5)
        self.isGrounded = false
        self.distanceToPlayer = 0
    }
}

struct BoundingBox: Codable {
    var min: SIMD3<Float>
    var max: SIMD3<Float>

    var center: SIMD3<Float> {
        return (min + max) / 2
    }

    var size: SIMD3<Float> {
        return max - min
    }

    func contains(_ point: SIMD3<Float>) -> Bool {
        return point.x >= min.x && point.x <= max.x &&
               point.y >= min.y && point.y <= max.y &&
               point.z >= min.z && point.z <= max.z
    }

    func intersects(_ other: BoundingBox) -> Bool {
        return !(max.x < other.min.x || min.x > other.max.x ||
                max.y < other.min.y || min.y > other.max.y ||
                max.z < other.min.z || min.z > other.max.z)
    }
}

// MARK: - Player Component

/// Player-specific data
struct PlayerComponent: Component {
    var entityID: UUID

    var playerID: UUID
    var username: String
    var isLocalPlayer: Bool
    var kills: Int
    var deaths: Int
    var assists: Int
    var score: Int
    var money: Int

    init(entityID: UUID,
         playerID: UUID,
         username: String,
         isLocalPlayer: Bool = false) {
        self.entityID = entityID
        self.playerID = playerID
        self.username = username
        self.isLocalPlayer = isLocalPlayer
        self.kills = 0
        self.deaths = 0
        self.assists = 0
        self.score = 0
        self.money = 800  // Starting money
    }
}

// MARK: - Audio Component

/// Spatial audio emitter
struct AudioComponent: Component {
    var entityID: UUID

    var soundName: String
    var isPlaying: Bool
    var volume: Float
    var spatialBlend: Float
    var maxDistance: Float
    var loop: Bool

    init(entityID: UUID,
         soundName: String,
         volume: Float = 1.0,
         spatialBlend: Float = 1.0,
         maxDistance: Float = 100.0,
         loop: Bool = false) {
        self.entityID = entityID
        self.soundName = soundName
        self.isPlaying = false
        self.volume = volume
        self.spatialBlend = spatialBlend
        self.maxDistance = maxDistance
        self.loop = loop
    }
}
