# Reality Realms RPG - Internal API Documentation

## Table of Contents

- [Overview](#overview)
- [EventBus API](#eventbus-api)
- [GameStateManager API](#gamestatemanager-api)
- [Entity-Component System API](#entity-component-system-api)
- [Component Types](#component-types)
- [System APIs](#system-apis)
- [Performance Monitor API](#performance-monitor-api)
- [Spatial Systems API](#spatial-systems-api)
- [Utility APIs](#utility-apis)
- [Code Examples](#code-examples)

---

## Overview

This document provides a comprehensive reference for all internal APIs in Reality Realms RPG. The game is built on several core systems:

- **EventBus**: Publish-subscribe event system for decoupled communication
- **GameStateManager**: Hierarchical state machine for game flow
- **ECS (Entity-Component-System)**: Modular game object architecture
- **PerformanceMonitor**: Real-time performance tracking and quality scaling
- **Spatial Systems**: Room mapping, furniture detection, anchor management

### Architecture Pattern

The game follows these architectural principles:

1. **Event-Driven**: Components communicate via events, not direct references
2. **Data-Oriented**: Components are pure data, systems contain logic
3. **MainActor-Isolated**: UI and game state on main thread for safety
4. **Async/Await**: Modern Swift concurrency for spatial operations

### API Conventions

- All public APIs are documented with Swift DocC comments
- MainActor-isolated APIs clearly marked with `@MainActor`
- Async operations use `async throws` for error handling
- Type-safe event system using generics

---

## EventBus API

### Overview

`EventBus` is a centralized publish-subscribe event system that enables decoupled communication between game systems.

**Location**: `RealityRealms/Utils/EventBus.swift`

**Thread Safety**: MainActor-isolated, thread-safe queue for subscriptions

### Class Definition

```swift
@MainActor
class EventBus {
    static let shared = EventBus()
}
```

### Methods

#### subscribe

Subscribe to events of a specific type.

```swift
func subscribe<T>(_ eventType: T.Type, handler: @escaping (T) -> Void)
```

**Parameters**:
- `eventType`: The type of event to subscribe to (e.g., `DamageDealtEvent.self`)
- `handler`: Closure called when event is published

**Returns**: None (subscription is maintained internally)

**Thread Safety**: Safe to call from any thread, handler executed on MainActor

**Example**:
```swift
EventBus.shared.subscribe(DamageDealtEvent.self) { event in
    print("Damage dealt: \(event.damage) to \(event.targetID)")
    updateHealthBar(for: event.targetID, damage: event.damage)
}
```

**Notes**:
- Multiple handlers can subscribe to the same event type
- Handlers are stored with weak references to prevent retain cycles
- Subscriptions persist until `clear()` is called or EventBus is deallocated

#### publish

Publish an event to all subscribers.

```swift
func publish<T>(_ event: T)
```

**Parameters**:
- `event`: The event instance to publish

**Returns**: None

**Thread Safety**: Safe to call from any thread, handlers executed on MainActor

**Example**:
```swift
EventBus.shared.publish(DamageDealtEvent(
    attackerID: player.id,
    targetID: enemy.id,
    damage: 25,
    damageType: .physical,
    isCritical: false
))
```

**Performance**:
- O(n) where n is the number of subscribers for that event type
- Asynchronous delivery (does not block publisher)
- Handlers executed in subscription order

#### clear

Clear all subscriptions (primarily for testing).

```swift
func clear()
```

**Parameters**: None

**Returns**: None

**Example**:
```swift
override func tearDown() {
    EventBus.shared.clear()
    super.tearDown()
}
```

**Warning**: Only use in tests or complete app reset scenarios

### Event Types

All events conform to the `GameEvent` protocol:

```swift
protocol GameEvent {}
```

#### StateChangeEvent

Published when game state transitions.

```swift
struct StateChangeEvent: GameEvent {
    let from: GameState
    let to: GameState
    let timestamp: Date
}
```

**Published By**: `GameStateManager`
**Use Case**: React to state transitions (e.g., pause music when paused)

#### DamageDealtEvent

Published when damage is dealt to an entity.

```swift
struct DamageDealtEvent: GameEvent {
    let attackerID: UUID
    let targetID: UUID
    let damage: Int
    let damageType: DamageType
    let isCritical: Bool
}
```

**Published By**: Combat system
**Use Case**: Update UI, trigger effects, track combat stats

#### EntityDefeatedEvent

Published when an entity's health reaches zero.

```swift
struct EntityDefeatedEvent: GameEvent {
    let entityID: UUID
    let killerID: UUID
    let experience: Int
}
```

**Published By**: Health system
**Use Case**: Award experience, drop loot, update quest progress

#### LevelUpEvent

Published when player gains a level.

```swift
struct LevelUpEvent: GameEvent {
    let playerID: UUID
    let newLevel: Int
    let skillPointsGained: Int
}
```

**Published By**: Progression system
**Use Case**: Show level-up animation, update stats UI

#### QuestAcceptedEvent

Published when player accepts a quest.

```swift
struct QuestAcceptedEvent: GameEvent {
    let questID: UUID
    let questName: String
}
```

**Published By**: Quest system
**Use Case**: Add quest to UI, trigger quest markers

#### QuestCompletedEvent

Published when player completes a quest.

```swift
struct QuestCompletedEvent: GameEvent {
    let questID: UUID
    let rewards: [Reward]
}
```

**Published By**: Quest system
**Use Case**: Grant rewards, update UI, trigger celebration

#### MultiplayerSyncEvent

Published for multiplayer state synchronization.

```swift
struct MultiplayerSyncEvent: GameEvent {
    let playerID: String
    let action: PlayerAction
    let timestamp: Date
}
```

**Published By**: Multiplayer system
**Use Case**: Sync player actions across devices

#### RoomMappingCompleteEvent

Published when room scanning completes.

```swift
struct RoomMappingCompleteEvent: GameEvent {
    let roomLayout: RoomLayout?
}
```

**Published By**: Spatial mapping system
**Use Case**: Transition from scanning to gameplay, generate game world

#### ShowNotificationEvent

Published to display user notifications.

```swift
struct ShowNotificationEvent: GameEvent {
    let title: String
    let message: String
    let duration: TimeInterval
}
```

**Published By**: Any system
**Use Case**: Show toast notifications to user

### Best Practices

1. **Event Naming**: Use past tense (e.g., `DamageDealt`, not `DealDamage`)
2. **Event Data**: Include all relevant data in event struct
3. **Immutability**: Events should be immutable (use `let`)
4. **Timestamps**: Add timestamps for debugging and logging
5. **Clean Up**: Call `clear()` in test tearDown methods

---

## GameStateManager API

### Overview

`GameStateManager` manages the game's high-level state machine and transitions.

**Location**: `RealityRealms/Game/GameState/GameStateManager.swift`

**Pattern**: Singleton with ObservableObject for SwiftUI reactivity

### Class Definition

```swift
@MainActor
class GameStateManager: ObservableObject {
    static let shared = GameStateManager()

    @Published private(set) var currentState: GameState
    @Published var isGameActive: Bool
}
```

### States

#### GameState

High-level game states.

```swift
enum GameState: Equatable {
    case initialization
    case roomScanning
    case tutorial
    case gameplay(GameplayState)
    case paused
    case loading(String)
    case error(String)
}
```

**States Explained**:
- `initialization`: App starting up, loading core systems
- `roomScanning`: ARKit scanning room for spatial mapping
- `tutorial`: Teaching player game mechanics
- `gameplay`: Active gameplay (see GameplayState)
- `paused`: Game paused by user
- `loading`: Loading assets or data (with context string)
- `error`: Error occurred (with error message)

#### GameplayState

Sub-states during active gameplay.

```swift
enum GameplayState: Equatable {
    case exploration
    case combat(enemyCount: Int)
    case dialogue(npcID: UUID)
    case inventory
    case multiplayer(sessionID: String)
    case questManagement
}
```

**States Explained**:
- `exploration`: Free roaming, no active combat
- `combat`: Fighting enemies (tracks enemy count)
- `dialogue`: Talking to NPC (tracks which NPC)
- `inventory`: Inventory screen open
- `multiplayer`: In multiplayer session
- `questManagement`: Quest log open

### Methods

#### transition

Transition to a new game state.

```swift
func transition(to newState: GameState)
```

**Parameters**:
- `newState`: The state to transition to

**Returns**: None

**Side Effects**:
- Updates `currentState` (publishes to SwiftUI)
- Updates state history
- Publishes `StateChangeEvent`
- Executes state entry logic

**Example**:
```swift
GameStateManager.shared.transition(to: .gameplay(.exploration))
```

**Validation**:
- Checks if transition is valid using `canTransition(from:to:)`
- Logs warning and returns early if invalid

**State History**:
- Maintains last 10 states for debugging
- Used for "go back" functionality (e.g., from pause)

#### startGame

Start the game (transition to gameplay exploration).

```swift
func startGame()
```

**Parameters**: None

**Returns**: None

**Example**:
```swift
GameStateManager.shared.startGame()
```

**Equivalent to**:
```swift
transition(to: .gameplay(.exploration))
```

#### pauseGame

Pause or unpause the game.

```swift
func pauseGame(_ pause: Bool)
```

**Parameters**:
- `pause`: `true` to pause, `false` to resume

**Returns**: None

**Example**:
```swift
// Pause
GameStateManager.shared.pauseGame(true)

// Resume
GameStateManager.shared.pauseGame(false)
```

**Behavior**:
- When pausing: Transitions from `gameplay` to `paused`
- When resuming: Returns to last gameplay state from history

#### enterCombat

Enter combat state with specified number of enemies.

```swift
func enterCombat(enemyCount: Int)
```

**Parameters**:
- `enemyCount`: Number of enemies in combat

**Returns**: None

**Example**:
```swift
GameStateManager.shared.enterCombat(enemyCount: 3)
```

**State Change**: `gameplay(.exploration)` → `gameplay(.combat(enemyCount: 3))`

#### exitCombat

Exit combat and return to exploration.

```swift
func exitCombat()
```

**Parameters**: None

**Returns**: None

**Example**:
```swift
GameStateManager.shared.exitCombat()
```

**State Change**: `gameplay(.combat(...))` → `gameplay(.exploration)`

#### showInventory / closeInventory

Open and close inventory.

```swift
func showInventory()
func closeInventory()
```

**Parameters**: None

**Returns**: None

**Example**:
```swift
// Open inventory
GameStateManager.shared.showInventory()

// Close inventory
GameStateManager.shared.closeInventory()
```

#### reportError

Report a game error.

```swift
func reportError(_ error: GameError)
```

**Parameters**:
- `error`: The error that occurred

**Returns**: None

**Example**:
```swift
GameStateManager.shared.reportError(.roomMappingFailed)
```

**State Change**: Any state → `error(error.localizedDescription)`

### Game Errors

```swift
enum GameError: Error, LocalizedError {
    case roomMappingFailed
    case spatialTrackingLost
    case saveDataCorrupted
    case multiplayerConnectionFailed
    case insufficientSpace

    var errorDescription: String? {
        // Localized error messages
    }
}
```

### Event Subscriptions

`GameStateManager` automatically subscribes to:

1. **RoomMappingCompleteEvent**: Transitions from `roomScanning` to `tutorial`
2. **EntityDefeatedEvent**: Updates combat enemy count, exits combat when zero

### Best Practices

1. **Use State Checks**: Check current state before actions
   ```swift
   if case .gameplay = GameStateManager.shared.currentState {
       // Safe to perform gameplay action
   }
   ```

2. **Observe State Changes**: Use `@ObservedObject` in SwiftUI
   ```swift
   @ObservedObject var stateManager = GameStateManager.shared

   var body: some View {
       if case .gameplay = stateManager.currentState {
           GameplayView()
       }
   }
   ```

3. **Handle All States**: Use exhaustive switches
   ```swift
   switch currentState {
   case .initialization: // ...
   case .roomScanning: // ...
   case .tutorial: // ...
   case .gameplay(let state): // ...
   case .paused: // ...
   case .loading: // ...
   case .error: // ...
   }
   ```

---

## Entity-Component-System API

### Overview

Reality Realms uses an Entity-Component-System (ECS) architecture for game objects.

**Location**: `RealityRealms/Game/Entities/GameEntity.swift`

**Benefits**:
- **Composition over inheritance**: Build complex entities from simple components
- **Performance**: Data-oriented design, cache-friendly
- **Flexibility**: Add/remove components at runtime

### Core Protocols

#### GameEntity Protocol

Base protocol for all game entities.

```swift
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
```

**Properties**:
- `id`: Unique identifier (UUID)
- `components`: Dictionary of component types to instances
- `transform`: Position, rotation, scale in world space
- `isActive`: Whether entity is active (inactive entities not processed)

**Methods**:
- `addComponent`: Add a component to the entity
- `getComponent`: Retrieve a component by type
- `removeComponent`: Remove a component by type
- `hasComponent`: Check if entity has a component

#### Component Protocol

Base protocol for all components.

```swift
protocol Component: AnyObject {
    var entityID: UUID { get }
}
```

**Properties**:
- `entityID`: Reference to owning entity

**Note**: Components are reference types (class) for performance

### Base Entity Implementation

#### Entity Class

Generic entity implementation.

```swift
class Entity: GameEntity {
    let id: UUID
    var components: [Component.Type: any Component]
    var transform: Transform
    var isActive: Bool

    init(
        id: UUID = UUID(),
        transform: Transform = Transform(),
        isActive: Bool = true
    )
}
```

**Usage**:
```swift
let entity = Entity()
entity.addComponent(HealthComponent(entityID: entity.id, maximum: 100))
entity.addComponent(CombatComponent(entityID: entity.id, damage: 10, attackSpeed: 1.5, attackRange: 1.0))
```

### Specialized Entities

#### Player

Player character entity.

```swift
class Player: Entity {
    var characterClass: CharacterClass
    var level: Int
    var experience: Int
    var skillPoints: Int
    var stats: CharacterStats
    var inventory: Inventory
    var equipment: Equipment

    init(characterClass: CharacterClass)
}
```

**Character Classes**:
```swift
enum CharacterClass {
    case warrior  // High health, melee focused
    case mage     // High mana, spell casting
    case rogue    // High dexterity, critical hits
    case ranger   // Balanced, ranged attacks
}
```

**Example**:
```swift
let player = Player(characterClass: .warrior)
print(player.stats.maxHealth)  // 120 for warrior
```

#### Enemy

Enemy entity.

```swift
class Enemy: Entity {
    var enemyType: EnemyType
    var lootTable: [LootEntry]

    init(enemyType: EnemyType)
}
```

**Enemy Types**:
```swift
enum EnemyType {
    case goblin    // Weak, fast
    case skeleton  // Medium, undead
    case orc       // Strong, slow
    case wolf      // Fast, pack tactics
    case bat       // Weak, flying
}
```

**Example**:
```swift
let goblin = Enemy(enemyType: .goblin)
// Automatically has HealthComponent, CombatComponent, AIComponent
```

---

## Component Types

### HealthComponent

Manages entity health and damage.

```swift
class HealthComponent: Component {
    let entityID: UUID
    var current: Int
    var maximum: Int
    var regenerationRate: Float
    var isDead: Bool

    init(entityID: UUID, maximum: Int)
    func takeDamage(_ amount: Int)
    func heal(_ amount: Int)
}
```

**Methods**:

##### takeDamage

Reduce health by damage amount.

```swift
func takeDamage(_ amount: Int)
```

**Example**:
```swift
if let health = entity.getComponent(HealthComponent.self) {
    health.takeDamage(25)
    if health.isDead {
        handleEntityDeath(entity)
    }
}
```

##### heal

Restore health (capped at maximum).

```swift
func heal(_ amount: Int)
```

**Example**:
```swift
health.heal(50)
// If current was 70/100, now 100/100 (capped)
```

### CombatComponent

Combat capabilities and stats.

```swift
class CombatComponent: Component {
    let entityID: UUID
    var damage: Int
    var attackSpeed: Float        // Attacks per second
    var attackRange: Float         // Meters
    var lastAttackTime: Date?

    init(entityID: UUID, damage: Int, attackSpeed: Float, attackRange: Float)
    func canAttack() -> Bool
    func performAttack()
}
```

**Methods**:

##### canAttack

Check if entity can attack (respects cooldown).

```swift
func canAttack() -> Bool
```

**Returns**: `true` if attack is off cooldown

**Example**:
```swift
if let combat = entity.getComponent(CombatComponent.self),
   combat.canAttack() {
    performAttackAnimation()
    combat.performAttack()
}
```

##### performAttack

Mark that attack was performed (starts cooldown).

```swift
func performAttack()
```

**Example**:
```swift
combat.performAttack()
// canAttack() will return false until cooldown expires
```

### AIComponent

AI state and behavior.

```swift
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

    init(entityID: UUID, perceptionRadius: Float = 10.0)
}
```

**AI States**:
- `idle`: Standing still, scanning for targets
- `patrol`: Following patrol path
- `chase`: Moving toward target
- `attack`: Attacking target
- `retreat`: Moving away (low health)
- `dead`: Entity defeated

**Example**:
```swift
if let ai = enemy.getComponent(AIComponent.self) {
    switch ai.currentState {
    case .idle:
        ai.currentState = .patrol
    case .chase:
        if distanceToTarget < attackRange {
            ai.currentState = .attack
        }
    // ...
    }
}
```

### TransformComponent

Position, rotation, and scale.

```swift
class TransformComponent: Component {
    let entityID: UUID
    var position: SIMD3<Float>
    var rotation: simd_quatf
    var scale: SIMD3<Float>

    init(
        entityID: UUID,
        position: SIMD3<Float> = .zero,
        rotation: simd_quatf = simd_quatf(),
        scale: SIMD3<Float> = SIMD3<Float>(repeating: 1)
    )
}
```

**Example**:
```swift
let transform = TransformComponent(
    entityID: entity.id,
    position: SIMD3<Float>(0, 1, 0),  // 1 meter above origin
    rotation: simd_quatf(angle: .pi, axis: SIMD3<Float>(0, 1, 0)),  // 180° around Y
    scale: SIMD3<Float>(repeating: 1.5)  // 1.5x scale
)
entity.addComponent(transform)
```

### Custom Component Example

Creating a custom component:

```swift
class SpellCastingComponent: Component {
    let entityID: UUID
    var knownSpells: [Spell] = []
    var currentMana: Int
    var maxMana: Int
    var manaRegenRate: Float

    init(entityID: UUID, maxMana: Int) {
        self.entityID = entityID
        self.currentMana = maxMana
        self.maxMana = maxMana
        self.manaRegenRate = 1.0  // 1 mana per second
    }

    func castSpell(_ spell: Spell) -> Bool {
        guard currentMana >= spell.manaCost else {
            return false
        }

        currentMana -= spell.manaCost
        // Trigger spell effects
        return true
    }
}

// Usage
let spellCasting = SpellCastingComponent(entityID: player.id, maxMana: 100)
player.addComponent(spellCasting)
```

---

## System APIs

### System Pattern

Systems process entities with specific components.

```swift
protocol System {
    func update(entities: [GameEntity], deltaTime: TimeInterval)
}
```

### Combat System Example

```swift
class CombatSystem: System {
    func update(entities: [GameEntity], deltaTime: TimeInterval) {
        let combatEntities = entities.filter { entity in
            entity.hasComponent(CombatComponent.self) &&
            entity.hasComponent(HealthComponent.self) &&
            entity.isActive
        }

        for entity in combatEntities {
            guard let combat = entity.getComponent(CombatComponent.self),
                  let ai = entity.getComponent(AIComponent.self),
                  ai.currentState == .attack,
                  let targetID = ai.targetEntity,
                  let target = findEntity(targetID, in: entities),
                  combat.canAttack() else {
                continue
            }

            performAttack(attacker: entity, target: target, combat: combat)
        }
    }

    private func performAttack(
        attacker: GameEntity,
        target: GameEntity,
        combat: CombatComponent
    ) {
        guard let targetHealth = target.getComponent(HealthComponent.self) else {
            return
        }

        // Calculate and apply damage
        let damage = combat.damage
        targetHealth.takeDamage(damage)

        // Record attack
        combat.performAttack()

        // Publish event
        EventBus.shared.publish(DamageDealtEvent(
            attackerID: attacker.id,
            targetID: target.id,
            damage: damage,
            damageType: .physical,
            isCritical: false
        ))

        // Check if target defeated
        if targetHealth.isDead {
            EventBus.shared.publish(EntityDefeatedEvent(
                entityID: target.id,
                killerID: attacker.id,
                experience: 10
            ))
        }
    }
}
```

---

## Performance Monitor API

### Overview

`PerformanceMonitor` tracks game performance and automatically adjusts quality.

**Location**: `RealityRealms/Utils/PerformanceMonitor.swift`

### Class Definition

```swift
@MainActor
class PerformanceMonitor: ObservableObject {
    static let shared = PerformanceMonitor()

    @Published private(set) var currentFPS: Double
    @Published private(set) var averageFPS: Double
    @Published private(set) var frameTime: TimeInterval
    @Published private(set) var memoryUsage: UInt64
    @Published private(set) var resolutionScale: Float
    @Published private(set) var qualityLevel: QualityLevel
}
```

### Quality Levels

```swift
enum QualityLevel: String {
    case ultra       // 1.0x resolution
    case high        // 0.9x resolution
    case medium      // 0.8x resolution
    case low         // 0.7x resolution
    case performance // 0.6x resolution
}
```

### Methods

#### recordFrame

Record frame timing (call every frame).

```swift
func recordFrame(deltaTime: TimeInterval)
```

**Parameters**:
- `deltaTime`: Time since last frame (seconds)

**Example**:
```swift
let frameStart = Date()
// ... render frame ...
let deltaTime = Date().timeIntervalSince(frameStart)
PerformanceMonitor.shared.recordFrame(deltaTime: deltaTime)
```

#### setQualityLevel

Manually set quality level.

```swift
func setQualityLevel(_ level: QualityLevel)
```

**Parameters**:
- `level`: Desired quality level

**Side Effects**:
- Updates `qualityLevel` and `resolutionScale`
- Posts `qualityLevelChanged` notification

**Example**:
```swift
PerformanceMonitor.shared.setQualityLevel(.high)
```

#### getMemoryUsageMB

Get current memory usage in megabytes.

```swift
func getMemoryUsageMB() -> Double
```

**Returns**: Memory usage in MB

**Example**:
```swift
let memoryMB = PerformanceMonitor.shared.getMemoryUsageMB()
print("Memory: \(String(format: "%.1f", memoryMB))MB")
```

#### logPerformanceStats

Log current performance statistics.

```swift
func logPerformanceStats()
```

**Example Output**:
```
📊 Performance Stats:
   FPS: 87.3 (avg: 88.9)
   Frame Time: 11.46ms
   Memory: 1,234.5MB
   Quality: High (90%)
```

### Automatic Quality Adjustment

The monitor automatically adjusts quality based on FPS:

- **FPS < 85**: Downgrade quality (target: 90 FPS)
- **FPS > 90**: Upgrade quality (if not at max)
- **Check frequency**: Every 90 frames (~1 second)

To disable auto-adjustment:
```swift
// Currently automatic - would need to add API to disable
```

---

## Spatial Systems API

### Room Mapping

```swift
struct RoomLayout {
    let roomID: UUID
    let bounds: AxisAlignedBoundingBox
    let safePlayArea: AxisAlignedBoundingBox
    let furniture: [FurnitureObject]
    var spatialAnchors: [UUID: SpatialAnchorData]

    struct AxisAlignedBoundingBox {
        let center: SIMD3<Float>
        let extents: SIMD3<Float>
        var volume: Float { extents.x * extents.y * extents.z }
    }
}
```

### Furniture Detection

```swift
struct FurnitureObject {
    let id: UUID
    let type: FurnitureType
    let transform: Transform
    let bounds: RoomLayout.AxisAlignedBoundingBox
}

enum FurnitureType {
    case couch, table, chair, bed, shelf, desk, tv, other
}
```

### Spatial Anchors

```swift
struct SpatialAnchorData {
    let anchorID: UUID
    let worldTransform: simd_float4x4
    let entityID: UUID
}
```

---

## Utility APIs

### Character Stats

```swift
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

    init(for characterClass: CharacterClass)
}
```

### Inventory System

```swift
class Inventory {
    var items: [InventoryItem]
    var maxSlots: Int

    func add(_ item: InventoryItem) -> Bool
    func remove(at index: Int)
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
```

---

## Code Examples

### Complete Combat Example

```swift
// Create player and enemy
let player = Player(characterClass: .warrior)
let goblin = Enemy(enemyType: .goblin)

// Subscribe to damage events
EventBus.shared.subscribe(DamageDealtEvent.self) { event in
    print("💥 \(event.damage) damage dealt!")

    // Update UI
    if event.isCritical {
        showCriticalHitEffect()
    }
}

// Subscribe to defeat events
EventBus.shared.subscribe(EntityDefeatedEvent.self) { event in
    print("☠️ Enemy defeated!")

    // Award experience
    if let playerHealth = player.getComponent(HealthComponent.self),
       !playerHealth.isDead {
        EventBus.shared.publish(ExperienceGainedEvent(
            playerID: player.id,
            amount: event.experience,
            source: "combat"
        ))
    }
}

// Combat loop
let combatSystem = CombatSystem()
let entities = [player, goblin]

// Enter combat state
GameStateManager.shared.enterCombat(enemyCount: 1)

// Game loop (called at 90 FPS)
func gameUpdate(deltaTime: TimeInterval) {
    PerformanceMonitor.shared.recordFrame(deltaTime: deltaTime)
    combatSystem.update(entities: entities, deltaTime: deltaTime)
}
```

### State Management Example

```swift
// Observe state changes in SwiftUI
struct GameView: View {
    @ObservedObject var stateManager = GameStateManager.shared

    var body: some View {
        switch stateManager.currentState {
        case .initialization:
            LoadingView()

        case .roomScanning:
            RoomScanningView()

        case .tutorial:
            TutorialView()

        case .gameplay(let gameplayState):
            switch gameplayState {
            case .exploration:
                ExplorationView()
            case .combat(let enemyCount):
                CombatView(enemyCount: enemyCount)
            case .inventory:
                InventoryView()
            default:
                GameplayView()
            }

        case .paused:
            PauseMenuView()

        case .error(let message):
            ErrorView(message: message)

        default:
            EmptyView()
        }
    }
}
```

### Custom System Example

```swift
class ManaRegenerationSystem: System {
    func update(entities: [GameEntity], deltaTime: TimeInterval) {
        for entity in entities where entity.isActive {
            guard let spellCasting = entity.getComponent(SpellCastingComponent.self) else {
                continue
            }

            // Regenerate mana
            let regenAmount = Int(spellCasting.manaRegenRate * Float(deltaTime))
            let newMana = min(
                spellCasting.currentMana + regenAmount,
                spellCasting.maxMana
            )

            if newMana != spellCasting.currentMana {
                spellCasting.currentMana = newMana

                // Publish event for UI update
                EventBus.shared.publish(ManaChangedEvent(
                    entityID: entity.id,
                    currentMana: newMana,
                    maxMana: spellCasting.maxMana
                ))
            }
        }
    }
}

// Register system
let manaSystem = ManaRegenerationSystem()

// Update in game loop
manaSystem.update(entities: allEntities, deltaTime: deltaTime)
```

---

**API Version**: 1.0
**Last Updated**: 2025-11-19
**Maintained By**: Reality Realms Development Team
