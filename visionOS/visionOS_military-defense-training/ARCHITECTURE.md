# Technical Architecture: Military Defense Training for visionOS

## 1. System Architecture Overview

### 1.1 High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    Apple Vision Pro Device                      │
├─────────────────────────────────────────────────────────────────┤
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              Presentation Layer (SwiftUI)                 │  │
│  │  ┌────────────┬──────────────┬────────────────────────┐  │  │
│  │  │  Windows   │   Volumes    │   Immersive Spaces     │  │  │
│  │  │  (2D UI)   │  (3D Bounded)│   (Full Immersion)     │  │  │
│  │  └────────────┴──────────────┴────────────────────────┘  │  │
│  └──────────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              ViewModel Layer (@Observable)                │  │
│  │  ┌─────────────┬────────────────┬──────────────────────┐  │  │
│  │  │ Training VM │ Scenario VM    │  Performance VM      │  │  │
│  │  │ Combat VM   │ Command VM     │  Analytics VM        │  │  │
│  │  └─────────────┴────────────────┴──────────────────────┘  │  │
│  └──────────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                  Service Layer                            │  │
│  │  ┌────────────┬───────────────┬──────────────────────┐   │  │
│  │  │ Combat Svc │ AI Enemy Svc  │  Physics Engine      │   │  │
│  │  │ Network    │ Analytics Svc │  Audio/Haptics       │   │  │
│  │  └────────────┴───────────────┴──────────────────────┘   │  │
│  └──────────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              RealityKit Scene Graph                       │  │
│  │  ┌────────────┬───────────────┬──────────────────────┐   │  │
│  │  │ Terrain    │ Units/Weapons │  Effects/Particles   │   │  │
│  │  │ Buildings  │ Vehicles      │  UI Anchors          │   │  │
│  │  └────────────┴───────────────┴──────────────────────┘   │  │
│  └──────────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                  Data Layer                               │  │
│  │  ┌────────────┬───────────────┬──────────────────────┐   │  │
│  │  │ SwiftData  │ File Storage  │  Cache Manager       │   │  │
│  │  │ (Local DB) │ (Assets/Maps) │  (Runtime State)     │   │  │
│  │  └────────────┴───────────────┴──────────────────────┘   │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              ║
                              ║ Encrypted Network
                              ║
┌─────────────────────────────────────────────────────────────────┐
│                      Backend Infrastructure                      │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Classified Cloud Services (AWS GovCloud / Azure Gov)    │  │
│  │  ┌────────────┬───────────────┬──────────────────────┐   │  │
│  │  │ Scenario   │ AI Training   │  Analytics Engine    │   │  │
│  │  │ Repository │ Models        │  Performance DB      │   │  │
│  │  │            │ OpFor AI      │  Metrics Aggregator  │   │  │
│  │  └────────────┴───────────────┴──────────────────────┘   │  │
│  └──────────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Integration Layer (C2 Systems, Intel Platforms)         │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

### 1.2 Core Architectural Principles

1. **Security-First Design**: All data handling follows classified information protocols
2. **Offline-Capable**: Core training functions work without network connectivity
3. **Performance-Optimized**: Target 120fps for combat realism
4. **Modular Architecture**: Component-based design for extensibility
5. **Spatial-Native**: Built specifically for visionOS spatial paradigms

## 2. visionOS-Specific Architecture Patterns

### 2.1 Presentation Modes Strategy

#### Window Mode (Primary Entry)
- **Purpose**: Mission briefing, planning, analytics review
- **Components**:
  - Mission selection interface
  - Performance dashboards
  - After-action review screens
  - Settings and configuration
- **Implementation**: `WindowGroup` with standard SwiftUI views

#### Volume Mode (Tactical Planning)
- **Purpose**: 3D terrain visualization, unit positioning, tactical overview
- **Components**:
  - Interactive 3D terrain models
  - Force disposition displays
  - Intelligence overlays
  - Mission rehearsal tools
- **Implementation**: `WindowGroup(for: Volume.self)` with RealityKit content
- **Size**: Configurable from 1m³ to 2m³ bounded space

#### Immersive Space Mode (Combat Training)
- **Purpose**: Full combat simulation, hyper-realistic training
- **Components**:
  - Complete battlefield environments
  - First-person combat scenarios
  - Multi-domain operations
  - Live-fire exercises
- **Implementation**: `ImmersiveSpace(id: "combatZone")` with full RealityKit scene
- **Style**: `.progressive` for gradual immersion transition

### 2.2 Space Transition Flow

```swift
Windows (Brief) → Volume (Plan) → Immersive (Train) → Windows (Review)
     ↓                 ↓                  ↓                    ↓
  Mission Select   Terrain Study    Live Combat      After-Action Report
```

### 2.3 Spatial Coordinate System

```
Engagement Zone Architecture:
- Origin: User's initial spawn point
- Y-Axis: Vertical (0 = ground level)
- Horizontal Plane: Tactical movement area
- Scale: 1 unit = 1 meter (real-world accuracy)

Zone Definitions:
- CQB Zone: 0-50m radius
- Urban Zone: 50-300m radius
- Tactical Zone: 300m-3km (scaled representation)
- Operational View: 3km+ (strategic map mode)
```

## 3. Data Models and Schemas

### 3.1 Core Domain Models

```swift
// MARK: - Training Session
@Model
class TrainingSession {
    var id: UUID
    var missionType: MissionType
    var scenario: Scenario
    var startTime: Date
    var endTime: Date?
    var participants: [Warrior]
    var performance: PerformanceMetrics
    var classificationLevel: ClassificationLevel
    var afterActionReport: AfterActionReport?
}

// MARK: - Scenario Definition
@Model
class Scenario {
    var id: UUID
    var name: String
    var type: ScenarioType // Urban, Desert, Mountain, etc.
    var difficulty: DifficultyLevel
    var terrain: TerrainData
    var enemyForces: [OpForUnit]
    var objectives: [MissionObjective]
    var environmentalConditions: EnvironmentConfig
    var duration: TimeInterval
    var classification: ClassificationLevel
}

// MARK: - Warrior Profile
@Model
class Warrior {
    var id: UUID
    var rank: MilitaryRank
    var unit: MilitaryUnit
    var specialization: Specialization
    var skillRatings: SkillMatrix
    var trainingHistory: [TrainingSession]
    var certifications: [Certification]
    var biometricBaseline: BiometricProfile?
    var clearanceLevel: SecurityClearance
}

// MARK: - Combat Entity
class CombatEntity: Entity, Component {
    var entityType: EntityType // Friendly, Enemy, Neutral, Objective
    var health: Float
    var armor: ArmorType
    var weapons: [WeaponSystem]
    var stance: CombatStance
    var movementSpeed: Float
    var detectionRadius: Float
}

// MARK: - Weapon System
struct WeaponSystem: Codable {
    var id: UUID
    var name: String
    var type: WeaponType // Rifle, Pistol, AT, MG, etc.
    var ammunition: AmmunitionType
    var magazineCapacity: Int
    var currentRounds: Int
    var fireRate: Float // rounds per minute
    var effectiveRange: Float // meters
    var damage: DamageModel
    var recoilPattern: RecoilPattern
}

// MARK: - Performance Metrics
struct PerformanceMetrics: Codable {
    var accuracy: Float // 0-100%
    var decisionSpeed: TimeInterval // avg decision time
    var tacticalScore: Int // 0-1000
    var objectivesCompleted: Int
    var casualtiesTaken: Int
    var enemiesNeutralized: Int
    var coverUsage: Float // percentage
    var communicationEffectiveness: Float
    var leadershipRating: Float?
    var stressLevel: Float // biometric
}

// MARK: - Terrain Data
struct TerrainData: Codable {
    var heightmap: URL // Reference to terrain data
    var size: SIMD3<Float> // kilometers
    var buildings: [Building]
    var vegetation: [VegetationZone]
    var waterBodies: [WaterFeature]
    var roads: [RoadNetwork]
    var coverPositions: [CoverPoint]
}
```

### 3.2 AI Enemy Models

```swift
// MARK: - OpFor Unit
@Observable
class OpForUnit {
    var id: UUID
    var unitType: OpForType // Infantry, Vehicle, Aircraft
    var doctrine: TacticalDoctrine // Peer, Insurgent, Terrorist
    var aiDifficulty: AIDifficulty
    var squadComposition: [AIAgent]
    var currentObjective: TacticalObjective?
    var morale: Float // 0-100
    var combatEffectiveness: Float
    var awarenessLevel: Float

    // AI Behavior
    var behaviorTree: BehaviorTree
    var tacticalMemory: [TacticalEvent]
    var adaptationLevel: Int // learns from player
}

// MARK: - AI Behavior System
class BehaviorTree {
    var rootNode: BehaviorNode

    enum BehaviorNode {
        case selector([BehaviorNode]) // OR logic
        case sequence([BehaviorNode]) // AND logic
        case action(TacticalAction)
        case condition(TacticalCondition)
    }
}

enum TacticalAction {
    case advance(direction: SIMD3<Float>)
    case takeCoever(position: SIMD3<Float>)
    case suppress(target: Entity)
    case flank(target: Entity)
    case retreat(fallbackPosition: SIMD3<Float>)
    case callReinforcements
    case coordinatedAssault
}
```

### 3.3 Analytics Schema

```swift
// MARK: - After Action Report
struct AfterActionReport: Codable {
    var sessionId: UUID
    var timestamp: Date
    var overallScore: Int
    var strengths: [PerformanceArea]
    var weaknesses: [PerformanceArea]
    var recommendations: [TrainingRecommendation]
    var keyMoments: [KeyMoment]
    var decisionAnalysis: [DecisionPoint]
    var comparisonToBaseline: ComparisonMetrics
    var nextTrainingFocus: [SkillArea]
}

struct KeyMoment: Codable {
    var timestamp: TimeInterval // seconds into mission
    var type: MomentType // KIA, ObjectiveComplete, TacticalError
    var description: String
    var videoTimestamp: TimeInterval?
    var tacticalImplication: String
    var alternativeActions: [String]
}

struct DecisionPoint: Codable {
    var timestamp: TimeInterval
    var situation: String
    var decision: String
    var outcome: DecisionOutcome
    var optimalDecision: String?
    var tacticalJustification: String
}
```

## 4. Service Layer Architecture

### 4.1 Service Components

```swift
// MARK: - Combat Simulation Service
actor CombatSimulationService {
    // Handles physics, ballistics, damage calculation
    func processWeaponFire(_ weapon: WeaponSystem, from: Entity, direction: SIMD3<Float>) async
    func calculateDamage(_ hit: HitEvent) async -> DamageResult
    func updateEntityStates() async
    func processCover(entity: Entity, threat: SIMD3<Float>) -> CoverEffectiveness
}

// MARK: - AI Director Service
actor AIDirectorService {
    // Controls OpFor behavior, difficulty scaling
    func updateOpForBehaviors() async
    func spawnReinforcements(type: OpForType, position: SIMD3<Float>) async
    func adjustDifficulty(based on: PerformanceMetrics) async
    func coordinateEnemySquad(_ squad: [OpForUnit]) async
}

// MARK: - Network Service
actor NetworkService {
    // Handles backend communication
    func fetchScenarios(clearanceLevel: SecurityClearance) async throws -> [Scenario]
    func uploadPerformanceData(_ session: TrainingSession) async throws
    func downloadAIModels() async throws
    func syncAnalytics() async throws
}

// MARK: - Analytics Service
actor AnalyticsService {
    // Tracks and analyzes performance
    func recordEvent(_ event: TrainingEvent) async
    func generateAfterActionReport(_ session: TrainingSession) async -> AfterActionReport
    func calculateSkillProgression(_ warrior: Warrior) async -> SkillProgression
    func predictReadiness(_ warrior: Warrior) async -> ReadinessScore
}

// MARK: - Spatial Audio Service
actor SpatialAudioService {
    // 3D positional audio for combat realism
    func playWeaponSound(_ weapon: WeaponSystem, position: SIMD3<Float>) async
    func playExplosion(at position: SIMD3<Float>, intensity: Float) async
    func updateAmbientAudio(environment: Environment) async
    func processRadioCommunication(_ message: RadioMessage) async
}

// MARK: - Persistence Service
actor PersistenceService {
    // Local data management
    func saveSession(_ session: TrainingSession) async throws
    func loadWarriorProfile(_ id: UUID) async throws -> Warrior
    func cacheScenario(_ scenario: Scenario) async throws
    func exportClassifiedData(to: SecureURL) async throws
}
```

### 4.2 Service Communication Pattern

```
┌─────────────┐
│   ViewModel │
└──────┬──────┘
       │ async/await
       ├─────────────┬──────────────┬───────────────┐
       ▼             ▼              ▼               ▼
┌──────────┐  ┌──────────┐  ┌──────────┐    ┌──────────┐
│ Combat   │  │ AI       │  │Analytics │    │ Network  │
│ Service  │  │ Service  │  │ Service  │    │ Service  │
└──────────┘  └──────────┘  └──────────┘    └──────────┘
       │             │              │               │
       └─────────────┴──────────────┴───────────────┘
                         │
                    ┌────▼─────┐
                    │   Data   │
                    │  Layer   │
                    └──────────┘
```

## 5. RealityKit and ARKit Integration

### 5.1 RealityKit Scene Architecture

```swift
// MARK: - Scene Structure
class CombatScene {
    var root: Entity

    // Scene hierarchy
    var terrain: Entity
    var buildings: Entity
    var friendlyForces: Entity
    var enemyForces: Entity
    var effects: Entity // explosions, smoke, etc.
    var ui: Entity // spatial UI anchors

    // Systems
    var physicsSystem: PhysicsSystem
    var animationSystem: AnimationSystem
    var particleSystem: ParticleSystem
    var audioSystem: AudioSystem
}

// MARK: - Component System
struct CombatComponent: Component {
    var health: Float
    var armor: Float
    var faction: Faction
}

struct WeaponComponent: Component {
    var weaponType: WeaponType
    var ammo: Int
    var fireMode: FireMode
}

struct AIComponent: Component {
    var behavior: BehaviorTree
    var awarenessRadius: Float
    var targetEntity: Entity?
}
```

### 5.2 ARKit Integration

```swift
// MARK: - Spatial Tracking
class SpatialTrackingManager {
    // Hand tracking for weapon manipulation
    func trackHandPoses() -> HandTrackingData

    // Eye tracking for targeting
    func getEyeGazeDirection() -> SIMD3<Float>

    // Room scanning for adaptive terrain
    func scanEnvironment() -> MeshAnchor

    // Collision detection
    func checkCollision(ray: Ray) -> CollisionResult?
}
```

### 5.3 Level of Detail System

```
Distance from User → LOD Level
─────────────────────────────
0-100m   → LOD 0 (Highest detail)
100-500m → LOD 1 (Medium detail)
500m-2km → LOD 2 (Low detail)
2km+     → LOD 3 (Billboards/Icons)
```

## 6. API Design and External Integrations

### 6.1 Backend API Structure

```swift
protocol DefenseTrainingAPI {
    // Scenario Management
    func getScenarios(filter: ScenarioFilter) async throws -> [Scenario]
    func downloadScenario(id: UUID) async throws -> ScenarioPackage

    // Performance Tracking
    func submitSessionData(_ session: TrainingSession) async throws
    func getWarriorAnalytics(id: UUID) async throws -> AnalyticsSummary

    // AI Model Management
    func getLatestOpForModel() async throws -> AIModelPackage
    func reportAIBehavior(feedback: AIFeedback) async throws

    // Leaderboard & Competition
    func getUnitRankings(unit: MilitaryUnit) async throws -> [Ranking]
    func submitCompetitionScore(_ score: CompetitionScore) async throws
}

// MARK: - REST Endpoints (Conceptual)
/*
POST   /api/v1/sessions                    - Upload training session
GET    /api/v1/scenarios                   - List available scenarios
GET    /api/v1/scenarios/{id}/download     - Download scenario package
POST   /api/v1/analytics/warrior/{id}      - Submit performance data
GET    /api/v1/analytics/warrior/{id}      - Get warrior analytics
GET    /api/v1/ai/opfor/latest             - Get latest AI model
POST   /api/v1/leaderboard/submit          - Submit competition score
GET    /api/v1/leaderboard/unit/{id}       - Get unit rankings
*/
```

### 6.2 External System Integration

```
┌─────────────────────────────────────────┐
│   Military Defense Training App         │
└──────────────┬──────────────────────────┘
               │
    ┌──────────┴──────────┐
    │                     │
    ▼                     ▼
┌──────────┐      ┌──────────────┐
│ C2       │      │ Intelligence │
│ Systems  │      │ Platforms    │
└──────────┘      └──────────────┘
    ▼                     ▼
- Mission Data        - Terrain Data
- Unit Status         - Threat Intel
- Orders              - Target Packages

    ┌──────────────┬──────────────┐
    ▼              ▼              ▼
┌────────┐   ┌─────────┐   ┌──────────┐
│Weapon  │   │Training │   │Personnel │
│Systems │   │Mgmt     │   │Records   │
└────────┘   └─────────┘   └──────────┘
```

### 6.3 Data Synchronization

```swift
actor SyncManager {
    // Bi-directional sync with backend
    func syncScenarios() async throws
    func syncPerformanceData() async throws
    func syncAIModels() async throws

    // Conflict resolution
    func resolveConflicts(_ conflicts: [SyncConflict]) async -> ResolutionResult

    // Offline queue
    var pendingUploads: [PendingUpload]
    func processPendingUploads() async throws
}
```

## 7. State Management Strategy

### 7.1 State Architecture

```swift
// MARK: - App State
@Observable
class AppState {
    var currentUser: Warrior?
    var activeSession: TrainingSession?
    var appPhase: AppPhase
    var securityContext: SecurityContext
}

enum AppPhase {
    case authentication
    case missionSelect
    case briefing
    case planning
    case training
    case afterAction
}

// MARK: - Training State
@Observable
class TrainingState {
    var scenario: Scenario
    var combatEntities: [UUID: CombatEntity]
    var playerState: PlayerState
    var objectives: [MissionObjective]
    var timeRemaining: TimeInterval
    var isPaused: Bool
}

// MARK: - Player State
@Observable
class PlayerState {
    var position: SIMD3<Float>
    var orientation: simd_quatf
    var health: Float
    var stamina: Float
    var currentWeapon: WeaponSystem
    var inventory: [InventoryItem]
    var activeBuffs: [Buff]
    var activeDebuffs: [Debuff]
}
```

### 7.2 State Flow

```
App Launch
    ↓
Authentication (Security Clearance Check)
    ↓
Mission Selection
    ↓
Mission Briefing (Window Mode)
    ↓
Tactical Planning (Volume Mode)
    ↓
Combat Training (Immersive Mode)
    ↓
After Action Review (Window Mode)
    ↓
[Return to Mission Selection]
```

## 8. Performance Optimization Strategy

### 8.1 Rendering Optimization

```swift
// MARK: - Rendering Strategy
class RenderingOptimizer {
    // Object pooling for entities
    var entityPool: EntityPool

    // Culling
    func performFrustumCulling() -> [Entity]
    func performOcclusionCulling() -> [Entity]

    // LOD Management
    func updateLOD(camera: SIMD3<Float>) -> [LODUpdate]

    // Batch rendering
    func batchSimilarEntities() -> [RenderBatch]

    // Target: 120fps @ 8K per eye
    var targetFrameTime: TimeInterval { 1.0 / 120.0 }
}
```

### 8.2 Memory Management

```
Memory Budget (Apple Vision Pro):
─────────────────────────────────
Total Available: 16GB
App Allocation: ~8GB max

Distribution:
- 3D Assets: 3GB (streaming LODs)
- Textures: 2GB (compressed, mip-mapped)
- Audio: 500MB (streaming spatial audio)
- Runtime State: 1GB
- AI Models: 1GB
- Frame Buffers: 500MB
- Reserved: 500MB
```

### 8.3 Network Optimization

```swift
actor NetworkOptimizer {
    // Prefetch scenarios
    func prefetchScenarios(predicted: [UUID]) async

    // Compress telemetry
    func compressTelemetry(_ data: TelemetryData) -> CompressedData

    // Batch uploads
    func batchAnalytics() async throws

    // Adaptive quality
    func adjustDownloadQuality(bandwidth: Bandwidth) -> QualityLevel
}
```

## 9. Security Architecture

### 9.1 Security Layers

```
┌──────────────────────────────────────────┐
│  Application Security Layer               │
│  - Code signing                           │
│  - Binary protection                      │
│  - Anti-tampering                         │
└──────────────┬───────────────────────────┘
               │
┌──────────────▼───────────────────────────┐
│  Data Security Layer                      │
│  - Encryption at rest (AES-256)          │
│  - Secure enclave integration            │
│  - Classification labeling               │
└──────────────┬───────────────────────────┘
               │
┌──────────────▼───────────────────────────┐
│  Network Security Layer                   │
│  - TLS 1.3+ only                         │
│  - Certificate pinning                   │
│  - VPN/Zero-trust integration            │
└──────────────┬───────────────────────────┘
               │
┌──────────────▼───────────────────────────┐
│  Authentication & Authorization           │
│  - CAC/PKI integration                   │
│  - Biometric authentication              │
│  - Role-based access control             │
└───────────────────────────────────────────┘
```

### 9.2 Classification Handling

```swift
enum ClassificationLevel: Int, Comparable {
    case unclassified = 0
    case cui = 1           // Controlled Unclassified
    case confidential = 2
    case secret = 3
    case topSecret = 4

    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

class SecurityContext {
    var userClearance: ClassificationLevel
    var sessionClassification: ClassificationLevel
    var dataMarkings: [DataMarking]

    func canAccess(_ resource: SecureResource) -> Bool {
        userClearance >= resource.classification
    }

    func applyClassificationWatermark(to view: some View) -> some View {
        // Add classification banners
    }
}
```

### 9.3 Audit Logging

```swift
actor AuditLogger {
    func logAccess(user: Warrior, resource: String, classification: ClassificationLevel)
    func logDataExport(data: SecureData, destination: String)
    func logAuthentication(user: Warrior, success: Bool)
    func logSecurityEvent(event: SecurityEvent)

    // Tamper-proof logs
    func generateAuditTrail() -> SignedAuditTrail
}
```

## 10. Scalability and Future Extensions

### 10.1 Extensibility Points

```swift
// MARK: - Plugin Architecture
protocol ScenarioPlugin {
    var scenarioType: ScenarioType { get }
    func load() async throws -> Scenario
    func customize(_ scenario: Scenario) -> Scenario
}

protocol WeaponPlugin {
    var weaponType: WeaponType { get }
    func createWeaponEntity() -> Entity
    func getBallistics() -> BallisticsModel
}

protocol AIBehaviorPlugin {
    var behaviorName: String { get }
    func createBehaviorTree() -> BehaviorTree
}
```

### 10.2 Multi-User Architecture (Future)

```swift
// MARK: - SharePlay Integration
class CollaborativeTrainingSession {
    var participants: [Warrior]
    var groupActivity: GroupActivity
    var syncedState: TrainingState

    func inviteWarrior(_ warrior: Warrior) async throws
    func synchronizeState() async throws
    func handleParticipantUpdate(_ update: StateUpdate) async
}
```

### 10.3 Deployment Architecture

```
┌─────────────────────────────────────────────────┐
│            Individual Devices                    │
│  - Training on personal Vision Pro              │
│  - Offline capability                           │
│  - Sync when connected                          │
└─────────────────┬───────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────┐
│          Training Center Deployment              │
│  - Multiple coordinated devices                 │
│  - Local server for low-latency                 │
│  - Instructor oversight                         │
└─────────────────┬───────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────┐
│       Enterprise Cloud (Classified)              │
│  - Scenario repository                          │
│  - Analytics aggregation                        │
│  - AI model training                            │
│  - Force-wide dashboards                        │
└──────────────────────────────────────────────────┘
```

## 11. Development Architecture

### 11.1 Project Structure

```
MilitaryDefenseTraining/
├── App/
│   ├── MilitaryDefenseTrainingApp.swift
│   ├── AppState.swift
│   └── SecurityContext.swift
├── Models/
│   ├── Domain/
│   │   ├── Warrior.swift
│   │   ├── Scenario.swift
│   │   ├── TrainingSession.swift
│   │   └── PerformanceMetrics.swift
│   ├── Combat/
│   │   ├── CombatEntity.swift
│   │   ├── WeaponSystem.swift
│   │   └── DamageModel.swift
│   └── AI/
│       ├── OpForUnit.swift
│       ├── BehaviorTree.swift
│       └── TacticalAI.swift
├── ViewModels/
│   ├── TrainingViewModel.swift
│   ├── ScenarioViewModel.swift
│   ├── CombatViewModel.swift
│   └── AnalyticsViewModel.swift
├── Views/
│   ├── Windows/
│   │   ├── MissionSelectView.swift
│   │   ├── BriefingView.swift
│   │   └── AfterActionView.swift
│   ├── Volumes/
│   │   ├── TacticalPlanningView.swift
│   │   └── TerrainVisualizationView.swift
│   └── Immersive/
│       ├── CombatView.swift
│       ├── TrainingEnvironmentView.swift
│       └── HUDOverlay.swift
├── RealityKit/
│   ├── Scenes/
│   │   ├── CombatScene.swift
│   │   └── EnvironmentSetup.swift
│   ├── Components/
│   │   ├── CombatComponent.swift
│   │   ├── WeaponComponent.swift
│   │   └── AIComponent.swift
│   └── Systems/
│       ├── CombatSystem.swift
│       ├── PhysicsSystem.swift
│       └── AISystem.swift
├── Services/
│   ├── CombatSimulationService.swift
│   ├── AIDirectorService.swift
│   ├── NetworkService.swift
│   ├── AnalyticsService.swift
│   ├── SpatialAudioService.swift
│   └── PersistenceService.swift
├── Utilities/
│   ├── Extensions/
│   ├── Helpers/
│   └── Constants.swift
├── Resources/
│   ├── Assets.xcassets
│   ├── 3DModels/
│   ├── Audio/
│   └── Scenarios/
└── Tests/
    ├── UnitTests/
    ├── IntegrationTests/
    └── UITests/
```

### 11.2 Dependency Management

```swift
// Swift Package Dependencies
dependencies: [
    .package(url: "https://github.com/apple/swift-collections", from: "1.0.0"),
    .package(url: "https://github.com/apple/swift-algorithms", from: "1.0.0"),
    // Potentially: Encrypted storage, compression libraries
]
```

## 12. Testing Architecture

### 12.1 Testing Strategy

```
┌─────────────────────────────────────────┐
│  Unit Tests                              │
│  - Model logic                           │
│  - Service functions                     │
│  - Utility methods                       │
│  - Coverage target: 80%                  │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│  Integration Tests                       │
│  - Service integration                   │
│  - Data flow                             │
│  - API communication                     │
│  - RealityKit scene setup                │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│  UI Tests                                │
│  - Critical user flows                   │
│  - Navigation                            │
│  - Gesture interactions                  │
│  - Spatial UI validation                 │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│  Performance Tests                       │
│  - Frame rate benchmarks                 │
│  - Memory usage profiling                │
│  - Network efficiency                    │
│  - Battery impact                        │
└─────────────────────────────────────────┘
```

### 12.2 Simulation Testing

```swift
class CombatSimulationTests: XCTestCase {
    func testWeaponDamageCalculation() async throws
    func testAIBehaviorUnderFire() async throws
    func testObjectiveCompletion() async throws
    func testPerformanceMetricsAccuracy() async throws
}
```

---

## Summary

This architecture provides:

1. **Robust Foundation**: MVVM with SwiftUI/RealityKit integration
2. **Security-First**: Classification handling and encryption throughout
3. **Performance-Optimized**: 120fps target with intelligent LOD and culling
4. **Scalable**: Plugin architecture and modular services
5. **Offline-Capable**: Local-first with cloud sync
6. **AI-Driven**: Advanced enemy behavior and performance analytics
7. **visionOS-Native**: Full utilization of spatial computing capabilities

The architecture supports the complete training lifecycle from mission briefing through immersive combat to comprehensive after-action review, all while maintaining military-grade security and performance standards.
