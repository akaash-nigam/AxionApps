//
//  GameComponents.swift
//  Reality Minecraft
//
//  Game component definitions
//

import Foundation
import RealityKit
import simd

// MARK: - Player Component

/// Player-specific component
class PlayerComponent: Component {
    var isActive: Bool = true
    weak var entity: GameEntity?

    var health: Float = 20.0
    var maxHealth: Float = 20.0
    var hunger: Float = 20.0
    var maxHunger: Float = 20.0
    var experience: Int = 0
    var level: Int = 0

    var inventory: Inventory
    var selectedHotbarSlot: Int = 0

    init() {
        self.inventory = Inventory(maxSlots: 36)
    }

    override func update(deltaTime: TimeInterval) {
        // Update hunger
        updateHunger(deltaTime: deltaTime)

        // Health regeneration
        if hunger >= 18.0 && health < maxHealth {
            health = min(health + Float(deltaTime) * 0.5, maxHealth)
        }

        // Starvation damage
        if hunger == 0 {
            let starveInterval: TimeInterval = 4.0
            // Apply damage every 4 seconds (simplified)
            health -= Float(deltaTime) / Float(starveInterval)
        }
    }

    private func updateHunger(deltaTime: TimeInterval) {
        // Hunger depletion rate (simplified)
        let depletionRate: Float = 0.01
        hunger = max(hunger - Float(deltaTime) * depletionRate, 0.0)
    }

    func takeDamage(_ amount: Float) {
        health = max(health - amount, 0)
        if health == 0 {
            die()
        }
    }

    func heal(_ amount: Float) {
        health = min(health + amount, maxHealth)
    }

    func addFood(_ foodValue: Float) {
        hunger = min(hunger + foodValue, maxHunger)
    }

    private func die() {
        // Player death logic
        print("💀 Player died")
    }
}

// MARK: - Mob Component

/// Mob-specific component
class MobComponent: Component {
    var isActive: Bool = true
    weak var entity: GameEntity?

    let mobType: MobType
    var health: Float
    var maxHealth: Float
    var damage: Float
    var speed: Float
    var detectionRange: Float
    var attackRange: Float

    init(type: MobType) {
        self.mobType = type

        // Set stats based on mob type
        switch type {
        case .zombie:
            self.health = 20.0
            self.maxHealth = 20.0
            self.damage = 5.0
            self.speed = 0.23
            self.detectionRange = 16.0
            self.attackRange = 1.0

        case .skeleton:
            self.health = 20.0
            self.maxHealth = 20.0
            self.damage = 4.0
            self.speed = 0.25
            self.detectionRange = 16.0
            self.attackRange = 15.0

        case .creeper:
            self.health = 20.0
            self.maxHealth = 20.0
            self.damage = 49.0 // Explosion damage
            self.speed = 0.25
            self.detectionRange = 16.0
            self.attackRange = 3.0

        case .spider:
            self.health = 16.0
            self.maxHealth = 16.0
            self.damage = 3.0
            self.speed = 0.30
            self.detectionRange = 16.0
            self.attackRange = 1.0

        case .cow, .pig, .sheep, .chicken:
            self.health = 10.0
            self.maxHealth = 10.0
            self.damage = 0.0
            self.speed = 0.25
            self.detectionRange = 10.0
            self.attackRange = 0.0
        }
    }

    func takeDamage(_ amount: Float) {
        health = max(health - amount, 0)
        if health == 0 {
            die()
        }
    }

    private func die() {
        print("☠️ Mob died: \(mobType)")
        // Drop items, play death animation, etc.
    }
}

enum MobType: String, Codable {
    case zombie, skeleton, creeper, spider, enderman
    case cow, pig, sheep, chicken
}

// MARK: - Mob AI Component

/// AI behavior component for mobs
class MobAIComponent: Component {
    var isActive: Bool = true
    weak var entity: GameEntity?

    var currentState: AIState = .idle
    var target: GameEntity?
    var pathfindingAgent: PathfindingAgent?

    private var stateTimer: TimeInterval = 0
    private var wanderTimer: TimeInterval = 0

    override func update(deltaTime: TimeInterval) {
        stateTimer += deltaTime

        switch currentState {
        case .idle:
            updateIdle(deltaTime: deltaTime)

        case .wandering:
            updateWandering(deltaTime: deltaTime)

        case .chasing(let target):
            updateChasing(target: target, deltaTime: deltaTime)

        case .attacking(let target):
            updateAttacking(target: target, deltaTime: deltaTime)

        case .fleeing(let threat):
            updateFleeing(from: threat, deltaTime: deltaTime)
        }
    }

    private func updateIdle(deltaTime: TimeInterval) {
        // Randomly start wandering
        if stateTimer > 3.0 && Bool.random() {
            currentState = .wandering
            stateTimer = 0
        }
    }

    private func updateWandering(deltaTime: TimeInterval) {
        // Simple wandering behavior
        wanderTimer += deltaTime
        if wanderTimer > 5.0 {
            currentState = .idle
            wanderTimer = 0
            stateTimer = 0
        }
    }

    private func updateChasing(target: GameEntity, deltaTime: TimeInterval) {
        // Move towards target
    }

    private func updateAttacking(target: GameEntity, deltaTime: TimeInterval) {
        // Attack target
    }

    private func updateFleeing(from threat: GameEntity, deltaTime: TimeInterval) {
        // Run away from threat
    }
}

enum AIState {
    case idle
    case wandering
    case chasing(target: GameEntity)
    case attacking(target: GameEntity)
    case fleeing(from: GameEntity)
}

// MARK: - Block Component

/// Block-specific component (for placed blocks in world)
class BlockComponent: Component {
    var isActive: Bool = true
    weak var entity: GameEntity?

    var blockType: BlockType
    var health: Float
    var isBeingMined: Bool = false
    var miningProgress: Float = 0.0

    init(blockType: BlockType) {
        self.blockType = blockType
        self.health = blockType.hardness
    }

    override func update(deltaTime: TimeInterval) {
        if isBeingMined {
            miningProgress += Float(deltaTime)

            if miningProgress >= health {
                // Block broken
                breakBlock()
            }
        }
    }

    func startMining() {
        isBeingMined = true
        miningProgress = 0.0
    }

    func stopMining() {
        isBeingMined = false
        miningProgress = 0.0
    }

    private func breakBlock() {
        print("💥 Block broken: \(blockType)")
        // Drop items, remove entity, etc.
    }
}

// MARK: - Item Drop Component

/// Component for dropped items in the world
class ItemDropComponent: Component {
    var isActive: Bool = true
    weak var entity: GameEntity?

    let itemType: String
    var quantity: Int
    var pickupDelay: TimeInterval
    let spawnTime: Date

    private var age: TimeInterval = 0

    init(itemType: String, quantity: Int, pickupDelay: TimeInterval = 0.5) {
        self.itemType = itemType
        self.quantity = quantity
        self.pickupDelay = pickupDelay
        self.spawnTime = Date()
    }

    override func update(deltaTime: TimeInterval) {
        age += deltaTime

        // Items despawn after 5 minutes
        if age > 300.0 {
            // Despawn item
            print("💨 Item despawned: \(itemType)")
        }
    }

    func canPickup() -> Bool {
        return age >= pickupDelay
    }
}

// MARK: - Health Component

/// Generic health component
class HealthComponent: Component {
    var isActive: Bool = true
    weak var entity: GameEntity?

    var currentHealth: Float
    var maxHealth: Float

    init(maxHealth: Float) {
        self.maxHealth = maxHealth
        self.currentHealth = maxHealth
    }

    func takeDamage(_ amount: Float) {
        currentHealth = max(currentHealth - amount, 0)

        if currentHealth == 0 {
            die()
        }
    }

    func heal(_ amount: Float) {
        currentHealth = min(currentHealth + amount, maxHealth)
    }

    func isDead() -> Bool {
        return currentHealth == 0
    }

    private func die() {
        // Death logic
    }
}

// MARK: - Velocity Component

/// Physics velocity component
class VelocityComponent: Component {
    var isActive: Bool = true
    weak var entity: GameEntity?

    var velocity: SIMD3<Float> = .zero
    var acceleration: SIMD3<Float> = .zero

    override func update(deltaTime: TimeInterval) {
        // Update velocity based on acceleration
        velocity += acceleration * Float(deltaTime)

        // Update position
        if let entity = entity {
            entity.transform.translation += velocity * Float(deltaTime)
        }

        // Reset acceleration each frame
        acceleration = .zero
    }

    func applyForce(_ force: SIMD3<Float>, mass: Float = 1.0) {
        acceleration += force / mass
    }
}

// MARK: - Pathfinding Agent

/// Simple pathfinding agent
class PathfindingAgent {
    var currentPath: [SIMD3<Float>] = []
    var currentWaypoint: Int = 0

    func setPath(_ path: [SIMD3<Float>]) {
        self.currentPath = path
        self.currentWaypoint = 0
    }

    func getNextWaypoint() -> SIMD3<Float>? {
        guard currentWaypoint < currentPath.count else { return nil }
        return currentPath[currentWaypoint]
    }

    func advanceWaypoint() {
        currentWaypoint += 1
    }

    func hasPath() -> Bool {
        return currentWaypoint < currentPath.count
    }
}
