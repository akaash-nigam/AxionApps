# Reality Realms RPG - Component Hierarchy Documentation

## Table of Contents
- [ECS Architecture Overview](#ecs-architecture-overview)
- [Component Dependency Tree](#component-dependency-tree)
- [System Execution Order](#system-execution-order)
- [Component Composition Examples](#component-composition-examples)
- [Component Categories](#component-categories)
- [Best Practices](#best-practices)
- [Performance Considerations](#performance-considerations)
- [Component Reference](#component-reference)

---

## ECS Architecture Overview

Reality Realms RPG uses a pure Entity-Component-System (ECS) architecture for maximum flexibility, performance, and code reusability.

### Core Principles

```mermaid
graph TB
    subgraph "Entity"
        E[Entity<br/>UUID + Component List]
    end

    subgraph "Components (Data)"
        C1[Transform Component]
        C2[Health Component]
        C3[Render Component]
        C4[Physics Component]
    end

    subgraph "Systems (Logic)"
        S1[Movement System]
        S2[Combat System]
        S3[Render System]
        S4[Physics System]
    end

    E --> C1
    E --> C2
    E --> C3
    E --> C4

    S1 -.Processes.-> C1
    S2 -.Processes.-> C2
    S3 -.Processes.-> C3
    S4 -.Processes.-> C4

    style E fill:#FFD700
    style C1 fill:#4A90E2
    style C2 fill:#4A90E2
    style C3 fill:#4A90E2
    style C4 fill:#4A90E2
    style S1 fill:#50C878
    style S2 fill:#50C878
    style S3 fill:#50C878
    style S4 fill:#50C878
```

### Entity-Component Relationship

```mermaid
classDiagram
    class Entity {
        +UUID id
        +String name
        +Map~Type, Component~ components
        +Bool isActive
        +addComponent(Component)
        +removeComponent(Type)
        +getComponent(Type) Component
        +hasComponent(Type) Bool
    }

    class Component {
        <<interface>>
        +UUID id
        +Entity owner
        +Bool enabled
        +init()
        +update(deltaTime)
        +cleanup()
    }

    class System {
        <<interface>>
        +Set~Type~ requiredComponents
        +update(deltaTime)
        +processEntity(Entity)
    }

    Entity "1" *-- "many" Component
    System ..> Component : processes
    System ..> Entity : queries
```

---

## Component Dependency Tree

### Core Component Dependencies

```mermaid
graph TB
    subgraph "Foundation Components"
        TRANS[TransformComponent<br/>position, rotation, scale]
    end

    subgraph "Rendering Components"
        RENDER[RenderComponent<br/>model, material]
        ANIM[AnimationComponent<br/>animations, state]
        VFX[VFXComponent<br/>particle effects]
    end

    subgraph "Physics Components"
        PHYS[PhysicsComponent<br/>velocity, mass]
        COLL[ColliderComponent<br/>shape, bounds]
        RB[RigidBodyComponent<br/>dynamics]
    end

    subgraph "Gameplay Components"
        HEALTH[HealthComponent<br/>HP, defense]
        COMBAT[CombatComponent<br/>attack, damage]
        AI[AIComponent<br/>behavior, state]
        INV[InventoryComponent<br/>items, capacity]
    end

    subgraph "Spatial Components"
        ANCHOR[AnchorComponent<br/>world anchor]
        NAV[NavigationComponent<br/>pathfinding]
        TRIGGER[TriggerComponent<br/>detection zone]
    end

    RENDER --> TRANS
    ANIM --> TRANS
    VFX --> TRANS
    PHYS --> TRANS
    COLL --> TRANS
    RB --> TRANS
    RB --> PHYS
    RB --> COLL
    COMBAT --> HEALTH
    AI --> NAV
    NAV --> TRANS
    TRIGGER --> COLL
    ANCHOR --> TRANS

    style TRANS fill:#E94B3C,stroke:#333,stroke-width:4px
    style HEALTH fill:#FFD700
    style COMBAT fill:#FF6B6B
    style AI fill:#4ECDC4
```

### Detailed Dependency Graph

```mermaid
graph LR
    subgraph "Level 0 - Foundation"
        L0_1[Transform]
        L0_2[Identifier]
        L0_3[Tag]
    end

    subgraph "Level 1 - Basic"
        L1_1[Render]
        L1_2[Physics]
        L1_3[Collider]
        L1_4[Audio]
        L1_5[Anchor]
    end

    subgraph "Level 2 - Intermediate"
        L2_1[Health]
        L2_2[Animation]
        L2_3[RigidBody]
        L2_4[Navigation]
        L2_5[Trigger]
    end

    subgraph "Level 3 - Advanced"
        L3_1[Combat]
        L3_2[AI]
        L3_3[Inventory]
        L3_4[Quest]
        L3_5[Dialogue]
    end

    subgraph "Level 4 - Specialized"
        L4_1[Player]
        L4_2[Enemy]
        L4_3[NPC]
        L4_4[Item]
        L4_5[Boss]
    end

    L1_1 --> L0_1
    L1_2 --> L0_1
    L1_3 --> L0_1
    L1_4 --> L0_1
    L1_5 --> L0_1

    L2_1 --> L0_1
    L2_2 --> L0_1
    L2_2 --> L1_1
    L2_3 --> L1_2
    L2_3 --> L1_3
    L2_4 --> L0_1
    L2_5 --> L1_3

    L3_1 --> L2_1
    L3_2 --> L2_4
    L3_3 --> L0_1
    L3_4 --> L0_1
    L3_5 --> L0_1

    L4_1 --> L3_1
    L4_1 --> L3_3
    L4_1 --> L0_1

    L4_2 --> L3_1
    L4_2 --> L3_2
    L4_2 --> L2_1

    L4_3 --> L3_5
    L4_3 --> L3_4
    L4_3 --> L0_1

    L4_4 --> L3_3
    L4_4 --> L1_1
    L4_4 --> L0_1

    L4_5 --> L4_2
    L4_5 --> L3_1
```

---

## System Execution Order

### Frame Update Pipeline

```mermaid
graph TB
    START([Frame Start]) --> FIXED{Fixed Update?}

    FIXED -->|Yes| INPUT[Input System<br/>0.5ms budget]
    FIXED -->|No| RENDER_ONLY[Render Only]

    INPUT --> PHYSICS[Physics System<br/>2.0ms budget]
    PHYSICS --> AI[AI System<br/>1.5ms budget]
    AI --> COMBAT[Combat System<br/>1.0ms budget]
    COMBAT --> MOVEMENT[Movement System<br/>0.5ms budget]
    MOVEMENT --> ANIMATION[Animation System<br/>1.0ms budget]
    ANIMATION --> SPATIAL[Spatial Anchor System<br/>0.5ms budget]
    SPATIAL --> AUDIO[Audio System<br/>0.5ms budget]
    AUDIO --> VFX[VFX System<br/>0.5ms budget]

    VFX --> RENDER[Render System<br/>3.0ms budget]
    RENDER_ONLY --> RENDER

    RENDER --> UI[UI System<br/>0.5ms budget]
    UI --> SAVE[Save System<br/>0.1ms budget]
    SAVE --> END([Frame End])

    style START fill:#90EE90
    style END fill:#FFB6C1
    style PHYSICS fill:#E94B3C
    style RENDER fill:#4A90E2
```

### System Priority Levels

```mermaid
graph LR
    subgraph "Critical Priority (Every Frame)"
        P1_1[Input System]
        P1_2[Physics System]
        P1_3[Render System]
    end

    subgraph "High Priority (Every Frame)"
        P2_1[Combat System]
        P2_2[Animation System]
        P2_3[Audio System]
    end

    subgraph "Medium Priority (Variable)"
        P3_1[AI System]
        P3_2[Navigation System]
        P3_3[VFX System]
    end

    subgraph "Low Priority (Async)"
        P4_1[Save System]
        P4_2[Analytics System]
        P4_3[Network Sync System]
    end

    P1_1 --> P1_2
    P1_2 --> P1_3

    P2_1 --> P2_2
    P2_2 --> P2_3

    P3_1 --> P3_2
    P3_2 --> P3_3

    style P1_1 fill:#E94B3C
    style P1_2 fill:#E94B3C
    style P1_3 fill:#E94B3C
    style P2_1 fill:#FFA500
    style P2_2 fill:#FFA500
    style P2_3 fill:#FFA500
```

### System Communication Flow

```mermaid
sequenceDiagram
    participant Input
    participant Physics
    participant Combat
    participant Animation
    participant Render
    participant EventBus

    Note over Input: Frame N Start

    Input->>EventBus: PlayerInputEvent
    EventBus->>Physics: Process Input
    Physics->>Physics: Update Velocities
    Physics->>EventBus: CollisionEvent

    EventBus->>Combat: Process Collision
    Combat->>Combat: Calculate Damage
    Combat->>EventBus: DamageEvent

    EventBus->>Animation: Trigger Hit Animation
    Animation->>Animation: Update Blend Tree
    Animation->>EventBus: AnimationStateChange

    EventBus->>Render: Update Visuals
    Render->>Render: Draw Frame

    Note over Render: Frame N Complete
```

---

## Component Composition Examples

### Player Entity Composition

```mermaid
graph TB
    PLAYER[Player Entity]

    subgraph "Core Components"
        PLAYER --> TRANS[TransformComponent]
        PLAYER --> ID[IdentifierComponent]
        PLAYER --> TAG[TagComponent: 'Player']
    end

    subgraph "Visual Components"
        PLAYER --> RENDER[RenderComponent<br/>Model: PlayerModel<br/>Material: PlayerMaterial]
        PLAYER --> ANIM[AnimationComponent<br/>Controller: PlayerAnimator<br/>State: Idle]
        PLAYER --> VFX_P[VFXComponent<br/>Trail Effect<br/>Spell Auras]
    end

    subgraph "Physics Components"
        PLAYER --> PHYS[PhysicsComponent<br/>Mass: 70kg<br/>Drag: 0.1]
        PLAYER --> COLL[ColliderComponent<br/>Capsule: 0.5m radius]
        PLAYER --> RB[RigidBodyComponent<br/>Type: Dynamic]
    end

    subgraph "Gameplay Components"
        PLAYER --> HEALTH[HealthComponent<br/>Max: 100<br/>Current: 100<br/>Regen: 1/sec]
        PLAYER --> COMBAT_P[CombatComponent<br/>Attack: 25<br/>Defense: 15<br/>Crit: 10%]
        PLAYER --> INV[InventoryComponent<br/>Slots: 50<br/>Weight: 200kg max]
        PLAYER --> EQUIP[EquipmentComponent<br/>Weapon<br/>Armor<br/>Accessories]
    end

    subgraph "Input Components"
        PLAYER --> INPUT[InputComponent<br/>Gesture Recognition<br/>Eye Tracking<br/>Voice Commands]
        PLAYER --> CAMERA[CameraComponent<br/>Follow Camera<br/>Field of View: 90°]
    end

    subgraph "Stats Components"
        PLAYER --> STATS[StatsComponent<br/>Strength: 10<br/>Intelligence: 8<br/>Dexterity: 12]
        PLAYER --> EXP[ExperienceComponent<br/>Level: 1<br/>XP: 0/100]
    end

    subgraph "Spatial Components"
        PLAYER --> ANCHOR_P[AnchorComponent<br/>Persistent World Anchor]
        PLAYER --> NAV_P[NavigationComponent<br/>NavMesh Agent]
    end

    style PLAYER fill:#FFD700,stroke:#333,stroke-width:4px
```

### Enemy Entity Composition

```mermaid
graph TB
    ENEMY[Enemy Entity]

    subgraph "Core Components"
        ENEMY --> E_TRANS[TransformComponent]
        ENEMY --> E_ID[IdentifierComponent]
        ENEMY --> E_TAG[TagComponent: 'Enemy']
    end

    subgraph "Visual Components"
        ENEMY --> E_RENDER[RenderComponent<br/>Model: GoblinModel]
        ENEMY --> E_ANIM[AnimationComponent<br/>State Machine]
        ENEMY --> E_VFX[VFXComponent<br/>Hit Effects]
    end

    subgraph "Physics Components"
        ENEMY --> E_PHYS[PhysicsComponent<br/>Mass: 50kg]
        ENEMY --> E_COLL[ColliderComponent<br/>Capsule Collider]
        ENEMY --> E_RB[RigidBodyComponent<br/>Type: Dynamic]
    end

    subgraph "Gameplay Components"
        ENEMY --> E_HEALTH[HealthComponent<br/>Max: 50<br/>Current: 50]
        ENEMY --> E_COMBAT[CombatComponent<br/>Attack: 15<br/>Defense: 5]
        ENEMY --> E_AI[AIComponent<br/>Behavior Tree<br/>State: Patrol]
        ENEMY --> E_LOOT[LootComponent<br/>Drop Table<br/>Gold: 10-20]
    end

    subgraph "AI Components"
        ENEMY --> E_SENSE[SensingComponent<br/>Sight Range: 10m<br/>Hearing: 5m]
        ENEMY --> E_NAV[NavigationComponent<br/>Pathfinding<br/>Speed: 3m/s]
        ENEMY --> E_TARGET[TargetingComponent<br/>Current Target<br/>Threat List]
    end

    subgraph "Audio Components"
        ENEMY --> E_AUDIO[AudioComponent<br/>Growl Sound<br/>Attack Sound<br/>Death Sound]
    end

    style ENEMY fill:#FF6B6B,stroke:#333,stroke-width:4px
```

### NPC Entity Composition

```mermaid
graph TB
    NPC[NPC Entity]

    subgraph "Core Components"
        NPC --> N_TRANS[TransformComponent]
        NPC --> N_ID[IdentifierComponent]
        NPC --> N_TAG[TagComponent: 'NPC']
    end

    subgraph "Visual Components"
        NPC --> N_RENDER[RenderComponent<br/>Model: MerchantModel]
        NPC --> N_ANIM[AnimationComponent<br/>Idle Animations]
    end

    subgraph "Interaction Components"
        NPC --> N_DIALOGUE[DialogueComponent<br/>Dialogue Trees<br/>Voice Lines]
        NPC --> N_QUEST[QuestComponent<br/>Available Quests<br/>Rewards]
        NPC --> N_MERCHANT[MerchantComponent<br/>Shop Inventory<br/>Prices]
        NPC --> N_INTERACT[InteractionComponent<br/>Interaction Radius: 2m<br/>Prompt: "Talk"]
    end

    subgraph "AI Components"
        NPC --> N_SCHEDULE[ScheduleComponent<br/>Daily Routine<br/>Waypoints]
        NPC --> N_NAV[NavigationComponent<br/>Pathfinding]
    end

    subgraph "Audio Components"
        NPC --> N_AUDIO[AudioComponent<br/>Greeting Sounds<br/>Ambient Dialogue]
    end

    subgraph "Spatial Components"
        NPC --> N_ANCHOR[AnchorComponent<br/>Fixed Location]
    end

    style NPC fill:#4ECDC4,stroke:#333,stroke-width:4px
```

### Interactive Object Composition

```mermaid
graph TB
    CHEST[Chest Entity]

    subgraph "Core Components"
        CHEST --> C_TRANS[TransformComponent]
        CHEST --> C_ID[IdentifierComponent]
        CHEST --> C_TAG[TagComponent: 'Interactive']
    end

    subgraph "Visual Components"
        CHEST --> C_RENDER[RenderComponent<br/>Model: ChestModel<br/>State: Closed]
        CHEST --> C_ANIM[AnimationComponent<br/>Open Animation<br/>Close Animation]
    end

    subgraph "Interaction Components"
        CHEST --> C_STORAGE[StorageComponent<br/>Item Slots<br/>Contents]
        CHEST --> C_INTERACT[InteractionComponent<br/>Type: Container<br/>Radius: 1m]
        CHEST --> C_LOCK[LockComponent<br/>Locked: true<br/>Key Required: GoldKey]
    end

    subgraph "Physics Components"
        CHEST --> C_COLL[ColliderComponent<br/>Box Collider<br/>Static]
    end

    subgraph "Spatial Components"
        CHEST --> C_ANCHOR[AnchorComponent<br/>World Anchor<br/>Persistent]
    end

    subgraph "Audio Components"
        CHEST --> C_AUDIO[AudioComponent<br/>Open Sound<br/>Close Sound<br/>Lock Sound]
    end

    subgraph "State Components"
        CHEST --> C_STATE[StateComponent<br/>Current: Closed<br/>Looted: false]
    end

    style CHEST fill:#95E1D3,stroke:#333,stroke-width:4px
```

### Projectile Entity Composition

```mermaid
graph TB
    PROJ[Projectile Entity<br/>(Fireball)]

    subgraph "Core Components"
        PROJ --> P_TRANS[TransformComponent]
        PROJ --> P_ID[IdentifierComponent]
        PROJ --> P_TAG[TagComponent: 'Projectile']
    end

    subgraph "Visual Components"
        PROJ --> P_RENDER[RenderComponent<br/>Model: FireballModel]
        PROJ --> P_VFX[VFXComponent<br/>Fire Trail<br/>Particles]
        PROJ --> P_LIGHT[LightComponent<br/>Color: Orange<br/>Intensity: 2.0]
    end

    subgraph "Physics Components"
        PROJ --> P_PHYS[PhysicsComponent<br/>Velocity: 20m/s<br/>Mass: 0.1kg]
        PROJ --> P_COLL[ColliderComponent<br/>Sphere: 0.2m<br/>Trigger: true]
        PROJ --> P_RB[RigidBodyComponent<br/>Type: Dynamic<br/>Gravity: false]
    end

    subgraph "Gameplay Components"
        PROJ --> P_DAMAGE[DamageComponent<br/>Amount: 50<br/>Type: Fire<br/>AOE: 2m]
        PROJ --> P_LIFETIME[LifetimeComponent<br/>Duration: 5s<br/>Destroy on Contact]
    end

    subgraph "Audio Components"
        PROJ --> P_AUDIO[AudioComponent<br/>Whoosh Sound<br/>Impact Sound]
    end

    style PROJ fill:#FF9A76,stroke:#333,stroke-width:4px
```

---

## Component Categories

### Transform & Spatial Components

```mermaid
classDiagram
    class TransformComponent {
        +Vector3 position
        +Quaternion rotation
        +Vector3 scale
        +Matrix4x4 worldMatrix
        +Transform parent
        +List~Transform~ children
        +setPosition(Vector3)
        +setRotation(Quaternion)
        +lookAt(Vector3)
        +translate(Vector3)
        +rotate(Quaternion)
    }

    class AnchorComponent {
        +WorldAnchor anchor
        +UUID anchorID
        +Bool isPersistent
        +createAnchor()
        +updateAnchor()
        +destroyAnchor()
    }

    class NavigationComponent {
        +NavMeshAgent agent
        +Vector3 destination
        +List~Vector3~ path
        +Float speed
        +Float stoppingDistance
        +setDestination(Vector3)
        +updatePath()
        +isPathValid() Bool
    }

    TransformComponent <|-- AnchorComponent
    TransformComponent <|-- NavigationComponent
```

### Rendering Components

```mermaid
classDiagram
    class RenderComponent {
        +ModelEntity model
        +Material material
        +Bool visible
        +Bool castsShadow
        +Float opacity
        +setModel(ModelEntity)
        +setMaterial(Material)
        +setVisibility(Bool)
    }

    class AnimationComponent {
        +AnimationController controller
        +Dictionary~String,Animation~ animations
        +String currentState
        +Float blendTime
        +play(String animationName)
        +stop()
        +setSpeed(Float)
        +crossfade(String, Float)
    }

    class VFXComponent {
        +List~ParticleEmitter~ emitters
        +Bool isPlaying
        +Float intensity
        +play()
        +stop()
        +setIntensity(Float)
        +spawnEffect(String effectName)
    }

    class LightComponent {
        +LightType type
        +Color color
        +Float intensity
        +Float range
        +Bool castsShadows
        +setColor(Color)
        +setIntensity(Float)
    }

    RenderComponent <|-- AnimationComponent
    RenderComponent <|-- VFXComponent
    RenderComponent <|-- LightComponent
```

### Physics Components

```mermaid
classDiagram
    class PhysicsComponent {
        +Vector3 velocity
        +Vector3 acceleration
        +Float mass
        +Float drag
        +Bool useGravity
        +applyForce(Vector3)
        +applyImpulse(Vector3)
        +setVelocity(Vector3)
    }

    class ColliderComponent {
        +ColliderShape shape
        +Vector3 center
        +Vector3 size
        +Bool isTrigger
        +PhysicsMaterial material
        +onCollisionEnter(Collision)
        +onCollisionExit(Collision)
        +onTriggerEnter(Collider)
        +onTriggerExit(Collider)
    }

    class RigidBodyComponent {
        +RigidBodyType type
        +Float mass
        +Float drag
        +Float angularDrag
        +Bool useGravity
        +List~Constraint~ constraints
        +addForce(Vector3)
        +addTorque(Vector3)
        +setKinematic(Bool)
    }

    PhysicsComponent <|-- RigidBodyComponent
    ColliderComponent --* RigidBodyComponent
```

### Gameplay Components

```mermaid
classDiagram
    class HealthComponent {
        +Int currentHealth
        +Int maxHealth
        +Float regenerationRate
        +Bool isDead
        +List~DamageModifier~ modifiers
        +takeDamage(Int amount, DamageType)
        +heal(Int amount)
        +kill()
        +resurrect()
    }

    class CombatComponent {
        +Weapon currentWeapon
        +Int baseAttackPower
        +Float attackSpeed
        +Float criticalChance
        +Float criticalMultiplier
        +attack(Entity target)
        +defend()
        +dodge()
    }

    class InventoryComponent {
        +Int maxSlots
        +Float maxWeight
        +List~Item~ items
        +Currency gold
        +addItem(Item) Bool
        +removeItem(Item) Bool
        +hasItem(ItemID) Bool
        +getItemCount(ItemID) Int
    }

    class AIComponent {
        +BehaviorTree behaviorTree
        +AIState currentState
        +Entity target
        +Float detectionRange
        +Float attackRange
        +updateAI(Float deltaTime)
        +setTarget(Entity)
        +clearTarget()
    }

    HealthComponent <|-- CombatComponent
```

---

## Best Practices

### Component Design Principles

1. **Single Responsibility**
   - Each component should have ONE clear purpose
   - Avoid "god components" with too much functionality
   - Example: `HealthComponent` only manages health, not damage calculation

2. **Data-Oriented Design**
   - Components store DATA, systems contain LOGIC
   - Keep components as simple data containers
   - Minimize component-to-component dependencies

3. **Composition Over Inheritance**
   - Build complex entities by combining simple components
   - Avoid deep component inheritance hierarchies
   - Use interfaces for common functionality

4. **Performance Optimization**
   - Keep components small and cache-friendly
   - Use value types when possible
   - Avoid references to other components when possible

### Component Communication Patterns

```mermaid
graph TB
    subgraph "Good: Event-Based Communication"
        C1[Component A]
        C2[Component B]
        EB[Event Bus]

        C1 -->|Publishes Event| EB
        EB -->|Subscribes| C2
    end

    subgraph "Bad: Direct Component References"
        C3[Component C]
        C4[Component D]

        C3 -->|Direct Reference| C4
    end

    style C1 fill:#90EE90
    style C2 fill:#90EE90
    style EB fill:#FFD700
    style C3 fill:#FFB6C1
    style C4 fill:#FFB6C1
```

### Component Lifecycle

```mermaid
stateDiagram-v2
    [*] --> Created: Component Created
    Created --> Initialized: init() called
    Initialized --> Active: Entity Added to Scene
    Active --> Disabled: enabled = false
    Disabled --> Active: enabled = true
    Active --> Updating: update() called each frame
    Updating --> Active: Continue
    Active --> Removed: Component Removed
    Removed --> Destroyed: cleanup() called
    Destroyed --> [*]

    note right of Initialized
        Setup resources
        Register event listeners
        Initialize state
    end note

    note right of Updating
        Update logic
        Process events
        Modify state
    end note

    note right of Destroyed
        Release resources
        Unregister listeners
        Save state if needed
    end note
```

---

## Performance Considerations

### Component Pooling

```mermaid
graph TB
    POOL[Component Pool]

    subgraph "Active Components"
        ACTIVE1[Component Instance 1]
        ACTIVE2[Component Instance 2]
        ACTIVE3[Component Instance 3]
    end

    subgraph "Inactive Components"
        INACTIVE1[Component Instance 4]
        INACTIVE2[Component Instance 5]
        INACTIVE3[Component Instance 6]
    end

    REQUEST[Component Request] --> POOL
    POOL -->|Get from Pool| INACTIVE1
    INACTIVE1 --> ACTIVE1

    ACTIVE3 -->|Return to Pool| POOL
    POOL --> INACTIVE3

    style POOL fill:#FFD700
    style ACTIVE1 fill:#90EE90
    style INACTIVE1 fill:#D3D3D3
```

### System Query Optimization

```mermaid
graph LR
    subgraph "Unoptimized"
        U1[Check ALL Entities] --> U2[Filter by Components] --> U3[Process Match]
    end

    subgraph "Optimized"
        O1[Query Pre-Filtered Set] --> O2[Process Directly]
    end

    style U1 fill:#FFB6C1
    style U2 fill:#FFB6C1
    style U3 fill:#FFB6C1
    style O1 fill:#90EE90
    style O2 fill:#90EE90
```

### Memory Layout Optimization

```swift
// Bad: Random access, cache misses
class BadComponent {
    var someData: String        // 8 bytes pointer
    var moreData: [Int]         // 8 bytes pointer
    var evenMore: Dictionary    // 8 bytes pointer
}

// Good: Contiguous memory, cache-friendly
struct GoodComponent {
    var position: SIMD3<Float>  // 12 bytes inline
    var health: Int32           // 4 bytes inline
    var damage: Int32           // 4 bytes inline
    // Total: 20 bytes contiguous
}
```

---

## Component Reference

### Complete Component List

| Component | Dependencies | Systems | Purpose |
|-----------|--------------|---------|---------|
| TransformComponent | None | All | Position, rotation, scale |
| RenderComponent | Transform | Render | Visual representation |
| AnimationComponent | Transform, Render | Animation | Animated models |
| PhysicsComponent | Transform | Physics | Movement physics |
| ColliderComponent | Transform | Physics | Collision detection |
| RigidBodyComponent | Physics, Collider | Physics | Full physics simulation |
| HealthComponent | None | Combat | HP management |
| CombatComponent | Health | Combat | Attack/defense |
| AIComponent | Navigation | AI | NPC behavior |
| NavigationComponent | Transform | AI, Movement | Pathfinding |
| InventoryComponent | None | Inventory | Item storage |
| EquipmentComponent | Inventory | Equipment | Worn items |
| AudioComponent | Transform | Audio | 3D sound |
| VFXComponent | Transform | VFX | Particle effects |
| AnchorComponent | Transform | Spatial | World anchors |
| DialogueComponent | None | Dialogue | NPC conversations |
| QuestComponent | None | Quest | Quest management |
| LootComponent | None | Loot | Item drops |
| InputComponent | None | Input | Player input |
| CameraComponent | Transform | Camera | Camera control |
| LightComponent | Transform | Render | Scene lighting |

---

## Conclusion

The ECS architecture in Reality Realms RPG provides:

### Advantages

1. **Flexibility**: Easy to add/remove components at runtime
2. **Performance**: Cache-friendly data layout
3. **Reusability**: Components work with any entity
4. **Maintainability**: Clear separation of data and logic
5. **Testability**: Systems can be tested independently

### Key Takeaways

- **Components** are pure data containers
- **Systems** contain all game logic
- **Entities** are just component containers
- **Event Bus** handles component communication
- **Dependencies** should be minimized

### Development Workflow

1. Identify entity behavior needed
2. Find existing components that provide features
3. Compose entity from components
4. Create new components only if needed
5. Implement system to process components
6. Test in isolation before integration

This component hierarchy forms the foundation of Reality Realms RPG's flexible and performant architecture.
