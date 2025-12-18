//
//  GameEntity.swift
//  Reality Realms RPG
//
//  Base entity and component system
//

import Foundation
import RealityKit

// MARK: - Entity Protocol

/// Base protocol for all game entities
protocol GameEntity: AnyObject, Identifiable {
    var id: UUID { get }
    var components: [Component.Type: any Component] { get set }
    var transform: Transform { get set }
    var isActive: Bool { get set }

    func addComponent<T: Component>(_ component: T)
    func getComponent<T: Component>(_ type: T.Type) -> T?
    func removeComponent<T: Component>(_ type: T.Type)
    func hasComponent<T: Component>(_ type: T.Type) -> Bool
}

// MARK: - Component Protocol

/// Base protocol for all components
protocol Component: AnyObject {
    var entityID: UUID { get }
}

// MARK: - Base Entity Implementation

class Entity: GameEntity {
    let id: UUID
    var components: [Component.Type: any Component] = [:]
    var transform: Transform
    var isActive: Bool

    init(id: UUID = UUID(), transform: Transform = Transform(), isActive: Bool = true) {
        self.id = id
        self.transform = transform
        self.isActive = isActive
    }

    func addComponent<T: Component>(_ component: T) {
        components[T.self] = component
    }

    func getComponent<T: Component>(_ type: T.Type) -> T? {
        return components[type] as? T
    }

    func removeComponent<T: Component>(_ type: T.Type) {
        components.removeValue(forKey: type)
    }

    func hasComponent<T: Component>(_ type: T.Type) -> Bool {
        return components[type] != nil
    }
}

// MARK: - Common Components

/// Transform component for position, rotation, scale
class TransformComponent: Component {
    let entityID: UUID
    var position: SIMD3<Float>
    var rotation: simd_quatf
    var scale: SIMD3<Float>

    init(entityID: UUID, position: SIMD3<Float> = .zero, rotation: simd_quatf = simd_quatf(), scale: SIMD3<Float> = SIMD3<Float>(repeating: 1)) {
        self.entityID = entityID
        self.position = position
        self.rotation = rotation
        self.scale = scale
    }
}

/// Health component for entities with health
class HealthComponent: Component {
    let entityID: UUID
    var current: Int
    var maximum: Int
    var regenerationRate: Float
    var isDead: Bool

    init(entityID: UUID, maximum: Int) {
        self.entityID = entityID
        self.current = maximum
        self.maximum = maximum
        self.regenerationRate = 0
        self.isDead = false
    }

    func takeDamage(_ amount: Int) {
        current = max(0, current - amount)
        if current == 0 {
            isDead = true
        }
    }

    func heal(_ amount: Int) {
        current = min(maximum, current + amount)
        if current > 0 {
            isDead = false
        }
    }
}

/// Combat component for entities that can fight
class CombatComponent: Component {
    let entityID: UUID
    var damage: Int
    var attackSpeed: Float
    var attackRange: Float
    var lastAttackTime: Date?

    init(entityID: UUID, damage: Int, attackSpeed: Float, attackRange: Float) {
        self.entityID = entityID
        self.damage = damage
        self.attackSpeed = attackSpeed
        self.attackRange = attackRange
        self.lastAttackTime = nil
    }

    func canAttack() -> Bool {
        guard let lastAttack = lastAttackTime else { return true }
        let cooldown = 1.0 / Double(attackSpeed)
        return Date().timeIntervalSince(lastAttack) >= cooldown
    }

    func performAttack() {
        lastAttackTime = Date()
    }
}

/// AI component for NPCs and enemies
class AIComponent: Component {
    let entityID: UUID
    var currentState: AIState
    var perceptionRadius: Float
    var targetEntity: UUID?

    enum AIState {
        case idle
        case patrol
        case chase
        case attack
        case retreat
        case dead
    }

    init(entityID: UUID, perceptionRadius: Float = 10.0) {
        self.entityID = entityID
        self.currentState = .idle
        self.perceptionRadius = perceptionRadius
        self.targetEntity = nil
    }
}

// MARK: - Player Entity

class Player: Entity {
    var characterClass: CharacterClass
    var level: Int
    var experience: Int
    var skillPoints: Int
    var stats: CharacterStats
    var inventory: Inventory
    var equipment: Equipment

    init(characterClass: CharacterClass) {
        self.characterClass = characterClass
        self.level = 1
        self.experience = 0
        self.skillPoints = 0
        self.stats = CharacterStats(for: characterClass)
        self.inventory = Inventory()
        self.equipment = Equipment()

        super.init()

        // Add player-specific components
        addComponent(HealthComponent(entityID: id, maximum: stats.maxHealth))
        addComponent(CombatComponent(
            entityID: id,
            damage: stats.strength,
            attackSpeed: 1.5,
            attackRange: 1.0
        ))
    }
}

// MARK: - Enemy Entity

class Enemy: Entity {
    var enemyType: EnemyType
    var lootTable: [LootEntry]

    struct LootEntry {
        let itemID: UUID
        let dropChance: Float
    }

    init(enemyType: EnemyType) {
        self.enemyType = enemyType
        self.lootTable = []

        super.init()

        // Add enemy-specific components
        let enemyStats = enemyType.stats
        addComponent(HealthComponent(entityID: id, maximum: enemyStats.health))
        addComponent(CombatComponent(
            entityID: id,
            damage: enemyStats.damage,
            attackSpeed: enemyStats.attackSpeed,
            attackRange: enemyStats.range
        ))
        addComponent(AIComponent(entityID: id, perceptionRadius: 10.0))
    }
}

// MARK: - Supporting Types

enum CharacterClass {
    case warrior
    case mage
    case rogue
    case ranger
}

struct CharacterStats {
    var maxHealth: Int
    var currentHealth: Int
    var maxMana: Int
    var currentMana: Int
    var strength: Int
    var intelligence: Int
    var dexterity: Int
    var defense: Int
    var critChance: Float
    var critDamage: Float

    init(for characterClass: CharacterClass) {
        switch characterClass {
        case .warrior:
            maxHealth = 120
            maxMana = 50
            strength = 15
            intelligence = 5
            dexterity = 8
            defense = 12
        case .mage:
            maxHealth = 80
            maxMana = 150
            strength = 5
            intelligence = 18
            dexterity = 7
            defense = 6
        case .rogue:
            maxHealth = 90
            maxMana = 80
            strength = 8
            intelligence = 10
            dexterity = 16
            defense = 7
        case .ranger:
            maxHealth = 100
            maxMana = 100
            strength = 10
            intelligence = 12
            dexterity = 14
            defense = 9
        }

        currentHealth = maxHealth
        currentMana = maxMana
        critChance = 0.05
        critDamage = 2.0
    }
}

enum EnemyType {
    case goblin
    case skeleton
    case orc
    case wolf
    case bat

    var stats: EnemyStats {
        switch self {
        case .goblin:
            return EnemyStats(health: 30, damage: 5, defense: 2, attackSpeed: 1.2, range: 0.8)
        case .skeleton:
            return EnemyStats(health: 40, damage: 8, defense: 1, attackSpeed: 1.0, range: 0.8)
        case .orc:
            return EnemyStats(health: 60, damage: 12, defense: 5, attackSpeed: 0.8, range: 1.0)
        case .wolf:
            return EnemyStats(health: 25, damage: 7, defense: 1, attackSpeed: 1.5, range: 0.6)
        case .bat:
            return EnemyStats(health: 15, damage: 3, defense: 0, attackSpeed: 2.0, range: 0.5)
        }
    }
}

struct EnemyStats {
    let health: Int
    let damage: Int
    let defense: Int
    let attackSpeed: Float
    let range: Float
}

class Inventory {
    var items: [InventoryItem] = []
    var maxSlots: Int = 50

    func add(_ item: InventoryItem) -> Bool {
        guard items.count < maxSlots else { return false }
        items.append(item)
        return true
    }

    func remove(at index: Int) {
        guard index < items.count else { return }
        items.remove(at: index)
    }
}

struct InventoryItem {
    let id: UUID
    let name: String
    let description: String
    let rarity: ItemRarity
    let stackable: Bool
    var quantity: Int

    enum ItemRarity {
        case common, uncommon, rare, epic, legendary
    }
}

class Equipment {
    var weapon: InventoryItem?
    var offhand: InventoryItem?
    var helmet: InventoryItem?
    var chest: InventoryItem?
    var gloves: InventoryItem?
    var legs: InventoryItem?
    var boots: InventoryItem?
    var accessory1: InventoryItem?
    var accessory2: InventoryItem?
}

// MARK: - Room Layout

struct RoomLayout {
    let roomID: UUID
    let bounds: AxisAlignedBoundingBox
    let safePlayArea: AxisAlignedBoundingBox
    let furniture: [FurnitureObject]
    var spatialAnchors: [UUID: SpatialAnchorData]

    struct AxisAlignedBoundingBox {
        let center: SIMD3<Float>
        let extents: SIMD3<Float>

        var volume: Float {
            extents.x * extents.y * extents.z
        }
    }
}

struct FurnitureObject {
    let id: UUID
    let type: FurnitureType
    let transform: Transform
    let bounds: RoomLayout.AxisAlignedBoundingBox
}

struct SpatialAnchorData {
    let anchorID: UUID
    let worldTransform: simd_float4x4
    let entityID: UUID
}
