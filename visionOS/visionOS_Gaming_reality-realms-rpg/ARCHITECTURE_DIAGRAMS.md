# Reality Realms RPG - Architecture Diagrams

## Table of Contents
- [System Architecture Overview](#system-architecture-overview)
- [Component Relationships](#component-relationships)
- [Event Flow Diagrams](#event-flow-diagrams)
- [State Machine Diagrams](#state-machine-diagrams)
- [Data Flow Architecture](#data-flow-architecture)
- [RealityKit Component Hierarchy](#realitykit-component-hierarchy)
- [Network Architecture](#network-architecture)
- [Spatial Computing Architecture](#spatial-computing-architecture)
- [Performance Optimization Pipeline](#performance-optimization-pipeline)

---

## System Architecture Overview

### High-Level System Architecture

```mermaid
graph TB
    subgraph "Presentation Layer"
        A[SwiftUI Views]
        B[RealityKit Rendering]
        C[Spatial UI Components]
        D[HUD System]
    end

    subgraph "Application Layer"
        E[Game State Manager]
        F[Scene Manager]
        G[Input Manager]
        H[Audio Manager]
    end

    subgraph "Game Logic Layer"
        I[ECS Systems]
        J[Combat System]
        K[AI System]
        L[Quest System]
        M[Inventory System]
    end

    subgraph "Spatial Layer"
        N[ARKit Session]
        O[Room Mapper]
        P[Anchor Manager]
        Q[Collision Detection]
    end

    subgraph "Data Layer"
        R[CloudKit Sync]
        S[SwiftData Persistence]
        T[Asset Streaming]
        U[Cache Manager]
    end

    subgraph "Platform Services"
        V[SharePlay Integration]
        W[Game Center]
        X[Notifications]
        Y[Analytics]
    end

    A --> E
    B --> F
    C --> G
    D --> E

    E --> I
    F --> I
    G --> J
    H --> K

    I --> N
    J --> O
    K --> P
    L --> Q
    M --> R

    N --> R
    O --> S
    P --> T
    Q --> U

    R --> V
    S --> W
    T --> X
    U --> Y
```

### Layer Dependency Matrix

```mermaid
graph LR
    subgraph "Dependency Flow"
        L1[Presentation Layer] --> L2[Application Layer]
        L2 --> L3[Game Logic Layer]
        L3 --> L4[Spatial Layer]
        L4 --> L5[Data Layer]
        L5 -.-> L6[Platform Services]
        L6 -.-> L3
    end

    style L1 fill:#ff9999
    style L2 fill:#99ccff
    style L3 fill:#99ff99
    style L4 fill:#ffcc99
    style L5 fill:#cc99ff
    style L6 fill:#ffff99
```

### Module Architecture

```mermaid
graph TB
    subgraph "Core Modules"
        CORE[Core Game Engine]
        ECS[Entity Component System]
        EVENT[Event Bus]
        STATE[State Machine]
    end

    subgraph "Gameplay Modules"
        COMBAT[Combat Module]
        AI[AI Module]
        QUEST[Quest Module]
        INV[Inventory Module]
        CHAR[Character Module]
    end

    subgraph "Spatial Modules"
        ROOM[Room Mapping]
        ANCHOR[Anchor System]
        PHYSICS[Physics Engine]
        NAV[Navigation Mesh]
    end

    subgraph "Network Modules"
        MULTI[Multiplayer]
        SYNC[State Sync]
        SHARE[SharePlay]
        CLOUD[CloudKit]
    end

    subgraph "Rendering Modules"
        RENDER[RealityKit Renderer]
        VFX[Visual Effects]
        ANIM[Animation System]
        MATERIAL[Material System]
    end

    CORE --> ECS
    CORE --> EVENT
    CORE --> STATE

    ECS --> COMBAT
    ECS --> AI
    ECS --> QUEST
    ECS --> INV
    ECS --> CHAR

    ROOM --> ANCHOR
    ROOM --> PHYSICS
    ROOM --> NAV

    MULTI --> SYNC
    MULTI --> SHARE
    SYNC --> CLOUD

    RENDER --> VFX
    RENDER --> ANIM
    RENDER --> MATERIAL

    ECS -.-> RENDER
    SPATIAL -.-> PHYSICS
    EVENT -.-> SYNC
```

---

## Component Relationships

### Entity Component System Architecture

```mermaid
classDiagram
    class Entity {
        +UUID id
        +String name
        +Transform transform
        +List~Component~ components
        +bool isActive
        +addComponent(Component)
        +removeComponent(Component)
        +getComponent(Type) Component
        +update(deltaTime)
    }

    class Component {
        <<interface>>
        +UUID id
        +Entity owner
        +bool enabled
        +setup()
        +update(deltaTime)
        +teardown()
    }

    class TransformComponent {
        +Vector3 position
        +Quaternion rotation
        +Vector3 scale
        +Matrix4x4 worldMatrix
        +setPosition(Vector3)
        +setRotation(Quaternion)
        +lookAt(Vector3)
    }

    class HealthComponent {
        +int currentHealth
        +int maxHealth
        +float regenerationRate
        +bool isDead
        +takeDamage(int)
        +heal(int)
        +kill()
    }

    class CombatComponent {
        +Weapon weapon
        +int attackPower
        +float attackSpeed
        +float criticalChance
        +attack(Entity)
        +defend()
        +dodge()
    }

    class AIComponent {
        +AIState currentState
        +BehaviorTree behaviorTree
        +Entity target
        +float detectionRange
        +updateAI(deltaTime)
        +setTarget(Entity)
    }

    class PhysicsComponent {
        +Vector3 velocity
        +Vector3 acceleration
        +float mass
        +bool useGravity
        +applyForce(Vector3)
        +applyImpulse(Vector3)
    }

    class RenderComponent {
        +ModelEntity model
        +Material material
        +bool castsShadow
        +float opacity
        +setModel(ModelEntity)
        +setMaterial(Material)
    }

    class AudioComponent {
        +AudioResource sound
        +float volume
        +bool isLooping
        +bool is3D
        +play()
        +stop()
        +pause()
    }

    Entity "1" *-- "many" Component
    Component <|-- TransformComponent
    Component <|-- HealthComponent
    Component <|-- CombatComponent
    Component <|-- AIComponent
    Component <|-- PhysicsComponent
    Component <|-- RenderComponent
    Component <|-- AudioComponent
```

### System Execution Order

```mermaid
graph TB
    START([Game Loop Start]) --> INPUT[Input System]
    INPUT --> AI[AI System]
    AI --> COMBAT[Combat System]
    COMBAT --> PHYSICS[Physics System]
    PHYSICS --> ANIM[Animation System]
    ANIM --> SPATIAL[Spatial Anchor System]
    SPATIAL --> AUDIO[Audio System]
    AUDIO --> RENDER[Render System]
    RENDER --> UI[UI System]
    UI --> SAVE[Save System]
    SAVE --> END([Frame Complete])

    style START fill:#90EE90
    style END fill:#FFB6C1
    style INPUT fill:#87CEEB
    style PHYSICS fill:#DDA0DD
    style RENDER fill:#F0E68C
```

### Component Dependency Graph

```mermaid
graph LR
    subgraph "Core Components"
        TRANS[Transform]
        RENDER[Render]
        PHYS[Physics]
    end

    subgraph "Gameplay Components"
        HEALTH[Health]
        COMBAT[Combat]
        INV[Inventory]
        QUEST[Quest]
    end

    subgraph "AI Components"
        AI[AI Brain]
        NAV[Navigation]
        SENSE[Sensing]
    end

    subgraph "Spatial Components"
        ANCHOR[Anchor]
        COLLIDER[Collider]
        TRIGGER[Trigger]
    end

    RENDER --> TRANS
    PHYS --> TRANS
    COMBAT --> HEALTH
    COMBAT --> TRANS
    AI --> NAV
    AI --> SENSE
    NAV --> TRANS
    COLLIDER --> TRANS
    ANCHOR --> TRANS
    TRIGGER --> COLLIDER

    style TRANS fill:#ff6b6b
    style HEALTH fill:#4ecdc4
    style AI fill:#ffe66d
```

---

## Event Flow Diagrams

### Event Bus Architecture

```mermaid
graph TB
    subgraph "Event Publishers"
        P1[Input System]
        P2[Combat System]
        P3[AI System]
        P4[Network System]
        P5[UI System]
    end

    BUS[Event Bus<br/>Central Message Router]

    subgraph "Event Subscribers"
        S1[Audio Manager]
        S2[VFX Manager]
        S3[UI Manager]
        S4[Analytics]
        S5[Save System]
        S6[Achievement System]
    end

    P1 -->|PlayerInputEvent| BUS
    P2 -->|CombatEvent| BUS
    P3 -->|AIStateChangeEvent| BUS
    P4 -->|NetworkEvent| BUS
    P5 -->|UIEvent| BUS

    BUS -->|Subscribe| S1
    BUS -->|Subscribe| S2
    BUS -->|Subscribe| S3
    BUS -->|Subscribe| S4
    BUS -->|Subscribe| S5
    BUS -->|Subscribe| S6

    style BUS fill:#ffd700,stroke:#333,stroke-width:4px
```

### Combat Event Flow

```mermaid
sequenceDiagram
    participant Player
    participant InputSystem
    participant EventBus
    participant CombatSystem
    participant Enemy
    participant AudioManager
    participant VFXManager
    participant UIManager

    Player->>InputSystem: Swing Gesture Detected
    InputSystem->>EventBus: Publish(AttackInputEvent)
    EventBus->>CombatSystem: Dispatch Event

    CombatSystem->>CombatSystem: Validate Attack
    CombatSystem->>Enemy: Calculate Damage
    Enemy->>Enemy: Apply Damage

    CombatSystem->>EventBus: Publish(DamageDealtEvent)

    EventBus->>AudioManager: Dispatch Event
    AudioManager->>AudioManager: Play Hit Sound

    EventBus->>VFXManager: Dispatch Event
    VFXManager->>VFXManager: Spawn Impact VFX

    EventBus->>UIManager: Dispatch Event
    UIManager->>UIManager: Update Health Bar

    alt Enemy Defeated
        Enemy->>EventBus: Publish(EnemyDefeatedEvent)
        EventBus->>Player: Grant Experience
        EventBus->>UIManager: Show Victory UI
    end
```

### Multiplayer Event Synchronization

```mermaid
sequenceDiagram
    participant P1 as Player 1 (Local)
    participant LocalEvent as Local Event Bus
    participant Network as Network Layer
    participant CloudKit as CloudKit
    participant RemoteEvent as Remote Event Bus
    participant P2 as Player 2 (Remote)

    P1->>LocalEvent: Cast Spell
    LocalEvent->>Network: Serialize Event
    Network->>CloudKit: Send State Update
    CloudKit->>Network: Acknowledge
    Network->>LocalEvent: Confirm Sent

    CloudKit->>RemoteEvent: Push Event
    RemoteEvent->>P2: Spawn Spell VFX
    P2->>RemoteEvent: Process Effect

    RemoteEvent->>CloudKit: Send Response
    CloudKit->>LocalEvent: Deliver Response
    LocalEvent->>P1: Update UI
```

### Quest Event Chain

```mermaid
graph TB
    START([Player Enters Room]) --> TRIGGER{Trigger Zone<br/>Activated?}
    TRIGGER -->|Yes| QUEST[Quest System<br/>Check Conditions]
    TRIGGER -->|No| END1([Continue Game])

    QUEST --> VALID{Valid Quest<br/>Trigger?}
    VALID -->|Yes| SPAWN[Spawn Quest NPC]
    VALID -->|No| END1

    SPAWN --> DIALOGUE[Initiate Dialogue]
    DIALOGUE --> ACCEPT{Player Accepts<br/>Quest?}

    ACCEPT -->|Yes| OBJECTIVE[Add Quest Objectives]
    ACCEPT -->|No| END2([Quest Declined])

    OBJECTIVE --> TRACK[Track Progress]
    TRACK --> COMPLETE{Objectives<br/>Complete?}

    COMPLETE -->|Yes| REWARD[Grant Rewards]
    COMPLETE -->|No| TRACK

    REWARD --> NOTIFY[Notify UI]
    NOTIFY --> SAVE[Save Progress]
    SAVE --> ACHIEVE[Check Achievements]
    ACHIEVE --> END3([Quest Complete])

    style START fill:#90EE90
    style END1 fill:#FFB6C1
    style END2 fill:#FFB6C1
    style END3 fill:#FFD700
```

---

## State Machine Diagrams

### Game State Machine

```mermaid
stateDiagram-v2
    [*] --> Initialization

    Initialization --> RoomScanning: App Launched
    RoomScanning --> Tutorial: First Time User
    RoomScanning --> MainMenu: Returning User

    Tutorial --> MainMenu: Tutorial Complete

    MainMenu --> CharacterSelection: Start Game
    MainMenu --> Settings: Open Settings
    MainMenu --> Multiplayer: Join Session

    Settings --> MainMenu: Back

    CharacterSelection --> Loading: Character Selected

    Loading --> Gameplay: Assets Loaded
    Loading --> Error: Load Failed

    Gameplay --> Combat: Enemy Encountered
    Gameplay --> Exploration: Free Roam
    Gameplay --> Dialogue: NPC Interaction
    Gameplay --> Inventory: Open Inventory
    Gameplay --> Paused: Menu Button

    Combat --> Gameplay: Combat Won
    Combat --> GameOver: Player Defeated

    Exploration --> Gameplay: Action Complete
    Dialogue --> Gameplay: Dialogue End
    Inventory --> Gameplay: Inventory Closed

    Paused --> Gameplay: Resume
    Paused --> MainMenu: Quit
    Paused --> Settings: Open Settings

    Multiplayer --> MultiplayerLobby: Connected
    MultiplayerLobby --> Gameplay: Session Started
    MultiplayerLobby --> MainMenu: Disconnected

    GameOver --> MainMenu: Respawn/Quit

    Error --> MainMenu: Retry
    Error --> [*]: Force Quit

    note right of Gameplay
        Main game loop runs here
        90 FPS target
        All systems active
    end note

    note right of RoomScanning
        ARKit scans environment
        Creates spatial anchors
        Generates navigation mesh
    end note
```

### Combat State Machine

```mermaid
stateDiagram-v2
    [*] --> Idle

    Idle --> Detecting: Enemy in Range
    Detecting --> Engaging: Enemy Confirmed
    Detecting --> Idle: False Alarm

    Engaging --> Attacking: Attack Input
    Engaging --> Defending: Defend Input
    Engaging --> Dodging: Dodge Input
    Engaging --> Casting: Spell Gesture

    Attacking --> Recovery: Attack Complete
    Defending --> Engaging: Block Success
    Defending --> Stunned: Block Broken
    Dodging --> Engaging: Dodge Success
    Dodging --> Hit: Dodge Failed
    Casting --> Recovery: Spell Cast
    Casting --> Interrupted: Cast Interrupted

    Recovery --> Engaging: Ready
    Stunned --> Engaging: Recovered
    Hit --> Engaging: Damage Applied
    Interrupted --> Engaging: Reset

    Engaging --> Victory: Enemy Defeated
    Engaging --> Defeated: Health Zero

    Victory --> [*]: Combat End
    Defeated --> [*]: Player Respawn

    note right of Attacking
        Damage calculation
        Gesture quality check
        Animation playback
    end note

    note right of Casting
        Mana consumption
        Gesture validation
        Spell effect application
    end note
```

### AI State Machine

```mermaid
stateDiagram-v2
    [*] --> Patrol

    Patrol --> Investigate: Noise Detected
    Patrol --> Alert: Player Spotted

    Investigate --> Patrol: Nothing Found
    Investigate --> Alert: Player Found

    Alert --> Combat: Engage Target
    Alert --> Search: Lost Visual

    Combat --> Attack: In Range
    Combat --> Chase: Out of Range
    Combat --> Flee: Low Health
    Combat --> Dead: Health Zero

    Attack --> Combat: Attack Complete
    Chase --> Combat: Target Reached
    Chase --> Search: Target Lost

    Flee --> Hide: Safe Distance
    Hide --> Patrol: Recovered
    Hide --> Dead: Caught

    Search --> Patrol: Give Up
    Search --> Alert: Target Found

    Dead --> [*]: Remove Entity

    note right of Patrol
        Follow waypoints
        Random idle animations
        Low alert level
    end note

    note right of Combat
        Behavior tree execution
        Tactical positioning
        Ability usage
    end note
```

### Player State Machine

```mermaid
stateDiagram-v2
    [*] --> Spawning

    Spawning --> Idle: Spawn Complete

    Idle --> Walking: Movement Input
    Idle --> Jumping: Jump Input
    Idle --> Attacking: Attack Input
    Idle --> Casting: Spell Input
    Idle --> Interacting: Interact Input

    Walking --> Running: Sprint Input
    Walking --> Idle: Stop Input
    Walking --> Jumping: Jump Input

    Running --> Walking: Release Sprint
    Running --> Sliding: Slide Input

    Jumping --> Falling: Apex Reached
    Falling --> Idle: Ground Contact
    Falling --> Dead: Fall Damage Fatal

    Attacking --> Idle: Attack Complete
    Casting --> Idle: Cast Complete
    Interacting --> Idle: Interaction End

    Sliding --> Idle: Slide End

    Idle --> Hit: Damage Taken
    Walking --> Hit: Damage Taken
    Running --> Hit: Damage Taken

    Hit --> Idle: Damage Applied
    Hit --> Dead: Health Zero

    Dead --> Respawning: Respawn Timer
    Respawning --> Spawning: Respawn Location Set

    note right of Idle
        Default state
        Idle animations
        Full movement control
    end note

    note right of Dead
        Death animation
        Drop items
        Update statistics
    end note
```

---

## Data Flow Architecture

### Save/Load Data Flow

```mermaid
graph TB
    subgraph "Game Session"
        PLAY[Active Gameplay]
        STATE[Game State]
        ENTITIES[Entity Data]
        PROGRESS[Player Progress]
    end

    subgraph "Serialization Layer"
        SERIAL[Data Serializer]
        COMPRESS[Compression]
        ENCRYPT[Encryption]
    end

    subgraph "Local Storage"
        SWIFTDATA[SwiftData]
        CACHE[File Cache]
        PREFS[UserDefaults]
    end

    subgraph "Cloud Storage"
        CLOUDKIT[CloudKit]
        ICLOUD[iCloud Drive]
        ASSETS[Asset Streaming]
    end

    subgraph "Sync Engine"
        CONFLICT[Conflict Resolution]
        MERGE[State Merging]
        VALIDATE[Validation]
    end

    PLAY --> STATE
    STATE --> ENTITIES
    ENTITIES --> PROGRESS

    PROGRESS --> SERIAL
    SERIAL --> COMPRESS
    COMPRESS --> ENCRYPT

    ENCRYPT --> SWIFTDATA
    ENCRYPT --> CLOUDKIT

    SWIFTDATA --> CACHE
    CLOUDKIT --> ICLOUD

    CLOUDKIT --> CONFLICT
    SWIFTDATA --> CONFLICT
    CONFLICT --> MERGE
    MERGE --> VALIDATE
    VALIDATE --> STATE

    style CLOUDKIT fill:#4A90E2
    style SWIFTDATA fill:#50C878
    style CONFLICT fill:#FFD700
```

### Asset Loading Pipeline

```mermaid
graph LR
    subgraph "Asset Sources"
        BUNDLE[App Bundle]
        REMOTE[Remote Server]
        CACHE[Asset Cache]
    end

    subgraph "Asset Manager"
        LOADER[Asset Loader]
        QUEUE[Load Queue]
        PRIORITY[Priority System]
    end

    subgraph "Processing"
        DECOMPRESS[Decompression]
        OPTIMIZE[Optimization]
        CONVERT[Format Conversion]
    end

    subgraph "RealityKit"
        MATERIAL[Material System]
        MESH[Mesh Renderer]
        TEXTURE[Texture Manager]
        AUDIO[Audio Engine]
    end

    BUNDLE --> LOADER
    REMOTE --> LOADER
    CACHE --> LOADER

    LOADER --> QUEUE
    QUEUE --> PRIORITY

    PRIORITY --> DECOMPRESS
    DECOMPRESS --> OPTIMIZE
    OPTIMIZE --> CONVERT

    CONVERT --> MATERIAL
    CONVERT --> MESH
    CONVERT --> TEXTURE
    CONVERT --> AUDIO

    MATERIAL -.Cache.-> CACHE
    MESH -.Cache.-> CACHE
    TEXTURE -.Cache.-> CACHE
    AUDIO -.Cache.-> CACHE
```

### Network Data Flow

```mermaid
sequenceDiagram
    participant Client
    participant LocalState
    participant Network
    participant CloudKit
    participant Server
    participant RemoteClient

    Client->>LocalState: Update Game State
    LocalState->>LocalState: Apply Changes
    LocalState->>Network: Serialize Delta

    Network->>Network: Compress Data
    Network->>CloudKit: Upload State

    CloudKit->>Server: Sync to Server
    Server->>Server: Validate State
    Server->>Server: Apply Rules

    Server->>CloudKit: Broadcast Update
    CloudKit->>Network: Push to Clients

    Network->>RemoteClient: Deliver State
    RemoteClient->>RemoteClient: Apply Update
    RemoteClient->>RemoteClient: Interpolate

    alt Conflict Detected
        Server->>CloudKit: Resolve Conflict
        CloudKit->>Network: Send Resolution
        Network->>Client: Update State
    end
```

---

## RealityKit Component Hierarchy

### Entity Hierarchy Structure

```mermaid
graph TB
    ROOT[Scene Root Entity]

    ROOT --> ENV[Environment Entity]
    ROOT --> GAME[Game World Entity]
    ROOT --> UI[UI Root Entity]

    ENV --> LIGHT[Lighting System]
    ENV --> SKY[Skybox]
    ENV --> AUDIO_ENV[Ambient Audio]

    GAME --> PLAYER[Player Entity]
    GAME --> NPCS[NPC Container]
    GAME --> ENEMIES[Enemy Container]
    GAME --> ITEMS[Item Container]
    GAME --> FX[VFX Container]

    PLAYER --> PLAYER_MODEL[Player Model]
    PLAYER --> PLAYER_WEAPON[Equipped Weapon]
    PLAYER --> PLAYER_FX[Player Effects]

    NPCS --> NPC1[Quest Giver NPC]
    NPCS --> NPC2[Merchant NPC]
    NPCS --> NPC3[Companion NPC]

    ENEMIES --> ENEMY1[Goblin]
    ENEMIES --> ENEMY2[Dragon]
    ENEMIES --> ENEMY3[Boss]

    ITEMS --> PICKUP1[Health Potion]
    ITEMS --> PICKUP2[Weapon Drop]
    ITEMS --> PICKUP3[Quest Item]

    UI --> HUD[HUD Elements]
    UI --> MENU[Menu Panels]
    UI --> TOOLTIP[Tooltips]

    style ROOT fill:#ff6b6b
    style GAME fill:#4ecdc4
    style PLAYER fill:#ffe66d
    style UI fill:#95e1d3
```

### Component Composition Examples

```mermaid
graph TB
    subgraph "Player Entity Composition"
        P[Player Entity]
        P --> TC1[Transform Component]
        P --> MC[Model Component]
        P --> PC[Physics Component]
        P --> HC[Health Component]
        P --> CC[Combat Component]
        P --> IC[Inventory Component]
        P --> AC[Animation Component]
        P --> AUC[Audio Component]
    end

    subgraph "Enemy Entity Composition"
        E[Enemy Entity]
        E --> TC2[Transform Component]
        E --> MC2[Model Component]
        E --> PC2[Physics Component]
        E --> HC2[Health Component]
        E --> CC2[Combat Component]
        E --> AIC[AI Component]
        E --> AC2[Animation Component]
        E --> LC[Loot Component]
    end

    subgraph "Interactive Object Composition"
        I[Chest Entity]
        I --> TC3[Transform Component]
        I --> MC3[Model Component]
        I --> IC2[Interaction Component]
        I --> STC[Storage Component]
        I --> ANC[Anchor Component]
        I --> AC3[Animation Component]
    end

    style P fill:#ffe66d
    style E fill:#ff6b6b
    style I fill:#4ecdc4
```

### RealityKit System Integration

```mermaid
graph TB
    subgraph "RealityKit Core"
        SCENE[RealityKit Scene]
        RENDER[Render Loop]
        PHYSICS_ENGINE[Physics Engine]
    end

    subgraph "Custom Systems"
        UPDATE[Update System]
        COMBAT_SYS[Combat System]
        AI_SYS[AI System]
        ANIM_SYS[Animation System]
    end

    subgraph "Component Processors"
        TRANS_PROC[Transform Processor]
        PHYS_PROC[Physics Processor]
        ANIM_PROC[Animation Processor]
        AUDIO_PROC[Audio Processor]
    end

    SCENE --> RENDER
    SCENE --> PHYSICS_ENGINE

    UPDATE --> COMBAT_SYS
    UPDATE --> AI_SYS
    UPDATE --> ANIM_SYS

    COMBAT_SYS --> TRANS_PROC
    AI_SYS --> TRANS_PROC
    ANIM_SYS --> ANIM_PROC

    TRANS_PROC --> PHYSICS_ENGINE
    PHYS_PROC --> PHYSICS_ENGINE
    ANIM_PROC --> RENDER
    AUDIO_PROC --> RENDER

    PHYSICS_ENGINE --> RENDER
```

---

## Network Architecture

### Multiplayer Architecture

```mermaid
graph TB
    subgraph "Client Layer"
        C1[Client 1]
        C2[Client 2]
        C3[Client 3]
        C4[Client 4]
    end

    subgraph "Network Layer"
        SP[SharePlay Session]
        GC[Game Center]
        NM[Network Manager]
    end

    subgraph "Sync Layer"
        STATE_SYNC[State Synchronization]
        PRED[Client Prediction]
        RECON[Server Reconciliation]
        INTERP[Interpolation]
    end

    subgraph "Server Layer"
        AUTH[Authority Server]
        LOBBY[Lobby Manager]
        MATCH[Matchmaking]
    end

    subgraph "Cloud Services"
        CK[CloudKit]
        RELAY[Network Relay]
        STORE[Persistent Storage]
    end

    C1 --> SP
    C2 --> SP
    C3 --> SP
    C4 --> SP

    SP --> NM
    GC --> NM

    NM --> STATE_SYNC
    STATE_SYNC --> PRED
    STATE_SYNC --> RECON
    STATE_SYNC --> INTERP

    PRED --> AUTH
    RECON --> AUTH

    AUTH --> LOBBY
    LOBBY --> MATCH

    AUTH --> CK
    MATCH --> RELAY
    CK --> STORE

    style SP fill:#4A90E2
    style AUTH fill:#E94B3C
    style CK fill:#50C878
```

### State Synchronization Flow

```mermaid
sequenceDiagram
    participant C1 as Client 1
    participant Pred as Prediction
    participant Net as Network
    participant Auth as Authority
    participant C2 as Client 2

    C1->>Pred: Player Input
    Pred->>Pred: Predict Movement
    Pred->>C1: Update Local State

    C1->>Net: Send Input + Sequence
    Net->>Auth: Deliver Input

    Auth->>Auth: Process Input
    Auth->>Auth: Simulate Physics
    Auth->>Auth: Validate State

    Auth->>Net: Broadcast State + Sequence

    Net->>C1: Authoritative State
    C1->>C1: Reconcile Prediction

    Net->>C2: Remote Player State
    C2->>C2: Interpolate Movement
    C2->>C2: Update Display
```

### Lobby and Matchmaking

```mermaid
stateDiagram-v2
    [*] --> MainMenu

    MainMenu --> CreateLobby: Host Game
    MainMenu --> JoinLobby: Join Game
    MainMenu --> QuickMatch: Quick Match

    CreateLobby --> LobbyWaiting: Lobby Created
    JoinLobby --> LobbyList: Search Lobbies
    QuickMatch --> Matchmaking: Enter Queue

    LobbyList --> LobbyWaiting: Join Selected

    Matchmaking --> MatchFound: Players Found
    MatchFound --> LobbyWaiting: Join Match

    LobbyWaiting --> Ready: All Ready
    LobbyWaiting --> MainMenu: Leave

    Ready --> Loading: Start Game
    Loading --> InGame: Load Complete

    InGame --> Results: Game End
    Results --> MainMenu: Return

    note right of Matchmaking
        Skill-based matching
        Latency optimization
        Region filtering
    end note
```

---

## Spatial Computing Architecture

### Room Mapping Pipeline

```mermaid
graph TB
    START[Start AR Session] --> INIT[Initialize ARKit]
    INIT --> TRACK[World Tracking]
    TRACK --> SCAN[Scene Reconstruction]

    SCAN --> MESH[Generate Mesh Anchors]
    MESH --> PLANE[Detect Planes]
    PLANE --> FURNITURE[Identify Furniture]

    FURNITURE --> BOUNDS[Calculate Room Bounds]
    BOUNDS --> SAFE[Define Safe Play Area]
    SAFE --> NAV[Generate NavMesh]

    NAV --> SPAWN[Set Spawn Points]
    SPAWN --> ANCHOR[Create World Anchors]
    ANCHOR --> PERSIST[Persist to CloudKit]

    PERSIST --> COMPLETE[Mapping Complete]

    style START fill:#90EE90
    style COMPLETE fill:#FFD700
```

### Spatial Anchor System

```mermaid
graph TB
    subgraph "Anchor Types"
        WORLD[World Anchor]
        IMAGE[Image Anchor]
        PLANE_A[Plane Anchor]
        MESH_A[Mesh Anchor]
    end

    subgraph "Anchor Manager"
        CREATE[Create Anchor]
        UPDATE[Update Anchor]
        REMOVE[Remove Anchor]
        QUERY[Query Anchors]
    end

    subgraph "Persistence"
        LOCAL[Local Storage]
        CLOUD[CloudKit Sync]
        RESTORE[Anchor Restoration]
    end

    subgraph "Game Objects"
        NPC_ANCHOR[NPC Spawn Point]
        ITEM_ANCHOR[Item Location]
        PORTAL_ANCHOR[Portal Anchor]
        DEFENSE_ANCHOR[Defense Structure]
    end

    WORLD --> CREATE
    IMAGE --> CREATE
    PLANE_A --> CREATE
    MESH_A --> CREATE

    CREATE --> UPDATE
    UPDATE --> REMOVE
    UPDATE --> QUERY

    CREATE --> LOCAL
    LOCAL --> CLOUD
    CLOUD --> RESTORE

    RESTORE --> NPC_ANCHOR
    RESTORE --> ITEM_ANCHOR
    RESTORE --> PORTAL_ANCHOR
    RESTORE --> DEFENSE_ANCHOR
```

### Hand Tracking Integration

```mermaid
graph TB
    subgraph "Input Sources"
        HAND_L[Left Hand]
        HAND_R[Right Hand]
        EYE[Eye Tracking]
        HEAD[Head Pose]
    end

    subgraph "Gesture Recognition"
        POSE[Pose Detection]
        GESTURE[Gesture Analysis]
        PINCH[Pinch Detection]
        SWING[Swing Detection]
    end

    subgraph "Action Mapping"
        ATTACK[Attack Action]
        CAST[Spell Casting]
        INTERACT[Interaction]
        NAVIGATE[Navigation]
    end

    subgraph "Game Systems"
        COMBAT[Combat System]
        MAGIC[Magic System]
        UI_SYS[UI System]
        MOVEMENT[Movement System]
    end

    HAND_L --> POSE
    HAND_R --> POSE
    EYE --> GESTURE
    HEAD --> GESTURE

    POSE --> PINCH
    POSE --> SWING
    GESTURE --> PINCH
    GESTURE --> SWING

    SWING --> ATTACK
    PINCH --> CAST
    GESTURE --> INTERACT
    HEAD --> NAVIGATE

    ATTACK --> COMBAT
    CAST --> MAGIC
    INTERACT --> UI_SYS
    NAVIGATE --> MOVEMENT
```

---

## Performance Optimization Pipeline

### Rendering Optimization

```mermaid
graph TB
    subgraph "Visibility Culling"
        FRUSTUM[Frustum Culling]
        OCCLUSION[Occlusion Culling]
        DISTANCE[Distance Culling]
    end

    subgraph "LOD System"
        LOD0[LOD 0 - High Detail]
        LOD1[LOD 1 - Medium Detail]
        LOD2[LOD 2 - Low Detail]
        LOD3[LOD 3 - Billboard]
    end

    subgraph "Batching"
        STATIC[Static Batching]
        DYNAMIC[Dynamic Batching]
        INSTANCING[GPU Instancing]
    end

    subgraph "Quality Scaling"
        TEXTURE_Q[Texture Quality]
        SHADOW_Q[Shadow Quality]
        EFFECT_Q[Effect Quality]
        FPS_TARGET[FPS Monitoring]
    end

    FRUSTUM --> LOD0
    OCCLUSION --> LOD1
    DISTANCE --> LOD2
    DISTANCE --> LOD3

    LOD0 --> STATIC
    LOD1 --> DYNAMIC
    LOD2 --> INSTANCING

    STATIC --> TEXTURE_Q
    DYNAMIC --> SHADOW_Q
    INSTANCING --> EFFECT_Q

    FPS_TARGET --> TEXTURE_Q
    FPS_TARGET --> SHADOW_Q
    FPS_TARGET --> EFFECT_Q

    style FPS_TARGET fill:#E94B3C
    style LOD0 fill:#4A90E2
```

### Memory Management

```mermaid
graph TB
    subgraph "Memory Pools"
        ENTITY_POOL[Entity Pool]
        COMPONENT_POOL[Component Pool]
        PARTICLE_POOL[Particle Pool]
        AUDIO_POOL[Audio Pool]
    end

    subgraph "Asset Streaming"
        PRIORITY[Priority Queue]
        LOAD[Async Loading]
        UNLOAD[Auto Unload]
    end

    subgraph "Cache Management"
        TEXTURE_CACHE[Texture Cache]
        MESH_CACHE[Mesh Cache]
        AUDIO_CACHE[Audio Cache]
        LRU[LRU Eviction]
    end

    subgraph "Memory Monitoring"
        BUDGET[Memory Budget]
        WARNING[Warning Threshold]
        CRITICAL[Critical Threshold]
        CLEANUP[Emergency Cleanup]
    end

    ENTITY_POOL --> PRIORITY
    COMPONENT_POOL --> PRIORITY
    PARTICLE_POOL --> PRIORITY
    AUDIO_POOL --> PRIORITY

    PRIORITY --> LOAD
    LOAD --> UNLOAD

    LOAD --> TEXTURE_CACHE
    LOAD --> MESH_CACHE
    LOAD --> AUDIO_CACHE

    TEXTURE_CACHE --> LRU
    MESH_CACHE --> LRU
    AUDIO_CACHE --> LRU

    LRU --> BUDGET
    BUDGET --> WARNING
    WARNING --> CRITICAL
    CRITICAL --> CLEANUP

    style CRITICAL fill:#E94B3C
    style BUDGET fill:#50C878
```

### Frame Time Budget

```mermaid
graph LR
    FRAME[Frame Start<br/>11.1ms @ 90 FPS]

    INPUT[Input Processing<br/>0.5ms]
    PHYSICS[Physics Simulation<br/>2.0ms]
    GAME_LOGIC[Game Logic<br/>2.0ms]
    AI[AI Update<br/>1.5ms]
    ANIMATION[Animation<br/>1.0ms]
    RENDER[Rendering<br/>3.0ms]
    AUDIO[Audio<br/>0.5ms]
    OVERHEAD[System Overhead<br/>0.6ms]

    FRAME --> INPUT
    INPUT --> PHYSICS
    PHYSICS --> GAME_LOGIC
    GAME_LOGIC --> AI
    AI --> ANIMATION
    ANIMATION --> RENDER
    RENDER --> AUDIO
    AUDIO --> OVERHEAD
    OVERHEAD --> FRAME

    style FRAME fill:#FFD700
    style RENDER fill:#4A90E2
```

---

## Conclusion

These architecture diagrams provide a comprehensive visual reference for the Reality Realms RPG system design. Each diagram illustrates critical relationships, data flows, and system interactions that enable the game to function as a cohesive spatial computing experience.

### Key Architectural Principles

1. **Modularity**: Clear separation of concerns across layers
2. **Event-Driven**: Loose coupling through central event bus
3. **Spatial-First**: ARKit and RealityKit as foundational systems
4. **Performance-Focused**: 90 FPS target with dynamic scaling
5. **Persistence**: CloudKit sync for seamless cross-session experience
6. **Scalability**: Systems designed for future content expansion

### System Interdependencies

The architecture is designed to minimize tight coupling while maintaining efficient communication:

- **Presentation** depends on **Application** layer
- **Application** orchestrates **Game Logic**
- **Game Logic** utilizes **Spatial** capabilities
- **Spatial** persists through **Data** layer
- **Platform Services** integrate horizontally

### Performance Considerations

Every architectural decision prioritizes:
- **90 FPS** rendering on Vision Pro
- **<4GB** memory footprint
- **<2 second** scene load times
- **<100ms** network latency for multiplayer
- **Automatic quality scaling** to maintain performance

These diagrams serve as the blueprint for implementing, maintaining, and extending Reality Realms RPG's technical foundation.
