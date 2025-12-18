# City Builder Tabletop - Technical Architecture

## Document Overview
This document outlines the comprehensive technical architecture for City Builder Tabletop, a visionOS spatial computing game that transforms flat surfaces into living, breathing miniature cities.

---

## 1. System Architecture Overview

### 1.1 High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Application Layer                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  SwiftUI     │  │   Game       │  │  Multiplayer │      │
│  │  Interface   │  │  Coordinator │  │   Manager    │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────────┐
│                     Game Engine Layer                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  Game Loop   │  │    State     │  │    Scene     │      │
│  │   Manager    │  │   Manager    │  │   Manager    │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────────┐
│                   Simulation Layer                           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Citizen    │  │   Traffic    │  │   Economic   │      │
│  │   AI System  │  │   System     │  │   System     │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────────┐
│                  RealityKit Layer                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Entity     │  │  Component   │  │   Physics    │      │
│  │   System     │  │   System     │  │   System     │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────────┐
│                     ARKit Layer                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Plane      │  │    Hand      │  │     Eye      │      │
│  │  Detection   │  │   Tracking   │  │   Tracking   │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 Architecture Principles

1. **Entity-Component-System (ECS)**: Core architecture pattern for game entities
2. **Reactive State Management**: SwiftUI Observation framework for UI reactivity
3. **Spatial-First Design**: All systems designed for 3D spatial interaction
4. **Performance-Oriented**: Target 90 FPS with thousands of simulated entities
5. **Modular Systems**: Loosely coupled, independently testable systems

---

## 2. Game Architecture

### 2.1 Game Loop Architecture

```swift
// Core game loop running at 90 FPS
GameLoop {
    // Fixed timestep for physics/simulation (60 Hz)
    FixedUpdate(60Hz) {
        - Update citizen AI
        - Update traffic simulation
        - Update economic systems
        - Process multiplayer state
    }

    // Variable timestep for rendering (90 FPS target)
    VariableUpdate {
        - Update animations
        - Update particle effects
        - Interpolate positions
        - Update spatial audio
    }

    // Render
    Render {
        - RealityKit scene graph
        - SwiftUI overlays
        - Debug visualizations
    }
}
```

### 2.2 State Management

```swift
@Observable
class GameState {
    var cityData: CityData
    var simulationSpeed: SimulationSpeed
    var selectedTool: BuildingTool
    var gamePhase: GamePhase
    var budget: Budget
    var statistics: CityStatistics
}

enum GamePhase {
    case startup
    case surfaceDetection
    case cityPlanning
    case simulation
    case paused
    case multiplayer
}
```

### 2.3 Scene Graph Architecture

```
RootEntity
├── CityContainer (Anchored to surface)
│   ├── TerrainEntity
│   ├── BuildingsLayer
│   │   ├── ResidentialBuildings
│   │   ├── CommercialBuildings
│   │   └── IndustrialBuildings
│   ├── InfrastructureLayer
│   │   ├── Roads
│   │   ├── PowerGrid
│   │   └── WaterSystem
│   ├── CitizensLayer (Instanced rendering)
│   ├── VehiclesLayer (Instanced rendering)
│   └── EffectsLayer
├── UILayer
│   ├── FloatingToolPalette
│   ├── StatisticsPanel
│   └── NotificationSystem
└── DebugLayer (Development only)
```

---

## 3. visionOS-Specific Architecture

### 3.1 Window & Volume Management

```swift
// Volume-based primary experience
@main
struct CityBuilderApp: App {
    var body: some Scene {
        // Main game volume (primary experience)
        WindowGroup(id: "city-volume") {
            CityVolumeView()
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1.0, height: 0.5, depth: 1.0, in: .meters)

        // Settings window
        WindowGroup(id: "settings") {
            SettingsView()
        }
        .windowStyle(.plain)

        // Immersive space for full city view (optional)
        ImmersiveSpace(id: "immersive-city") {
            ImmersiveCityView()
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}
```

### 3.2 Surface Detection & Anchoring

```swift
class SurfaceDetectionSystem {
    private var arSession: ARKitSession
    private var planeDetection: PlaneDetectionProvider
    private var worldTracking: WorldTrackingProvider

    // Detect and track flat surfaces
    func detectSurfaces() async throws -> [PlaneAnchor] {
        // ARKit plane detection
        // Filter for horizontal surfaces
        // Validate minimum size (0.5m x 0.5m)
        // Return suitable surfaces
    }

    // Anchor city to selected surface
    func anchorCity(to surface: PlaneAnchor) -> AnchorEntity {
        let anchor = AnchorEntity(anchor: surface)
        // Configure persistent anchoring
        // Setup spatial reference frame
        return anchor
    }
}
```

### 3.3 Spatial Persistence

```swift
class SpatialPersistenceManager {
    // Save city state with spatial anchor
    func saveCity(city: CityData, anchor: AnchorEntity) async throws {
        // Serialize city data
        // Store anchor identifier
        // Save to local storage + iCloud
    }

    // Restore city to previously saved location
    func restoreCity(at location: UUID) async throws -> (CityData, AnchorEntity) {
        // Load anchor from WorldAnchorAPI
        // Restore city data
        // Recreate scene graph
    }
}
```

---

## 4. Game Data Models

### 4.1 Core Data Structures

```swift
struct CityData: Codable {
    var id: UUID
    var name: String
    var createdDate: Date
    var lastModified: Date
    var surfaceSize: SIMD2<Float>

    var buildings: [Building]
    var roads: [Road]
    var zones: [Zone]
    var infrastructure: Infrastructure

    var citizens: [Citizen]
    var vehicles: [Vehicle]

    var economy: EconomyState
    var statistics: Statistics
}

struct Building: Codable, Identifiable {
    var id: UUID
    var type: BuildingType
    var position: SIMD3<Float>
    var rotation: simd_quatf
    var level: Int
    var capacity: Int
    var occupancy: Int
    var constructionProgress: Float
}

enum BuildingType: Codable {
    case residential(ResidentialType)
    case commercial(CommercialType)
    case industrial(IndustrialType)
    case infrastructure(InfrastructureType)

    enum ResidentialType { case smallHouse, apartment, tower }
    enum CommercialType { case shop, office, mall }
    enum IndustrialType { case factory, warehouse, powerPlant }
    enum InfrastructureType { case school, hospital, policeStation, fireStation }
}

struct Citizen: Codable, Identifiable {
    var id: UUID
    var name: String
    var age: Int
    var occupation: Occupation
    var home: UUID? // Building ID
    var workplace: UUID? // Building ID
    var happiness: Float
    var income: Float
    var currentActivity: Activity
}

struct Road: Codable, Identifiable {
    var id: UUID
    var type: RoadType
    var path: [SIMD3<Float>]
    var lanes: Int
    var trafficCapacity: Int
    var connections: [UUID] // Connected road IDs
}
```

### 4.2 Simulation State

```swift
struct EconomyState: Codable {
    var treasury: Float
    var taxRate: Float
    var income: Float
    var expenses: Float
    var unemployment: Float
    var gdp: Float
}

struct Statistics: Codable {
    var population: Int
    var populationGrowth: Float
    var averageHappiness: Float
    var trafficDensity: Float
    var powerUsage: Float
    var waterUsage: Float
    var pollution: Float
    var crimerate: Float
}
```

---

## 5. RealityKit Components & Systems

### 5.1 Custom Components

```swift
// Building component
struct BuildingComponent: Component {
    var buildingType: BuildingType
    var level: Int
    var capacity: Int
    var occupancy: Int
    var constructionProgress: Float
}

// Citizen component (for instanced rendering)
struct CitizenComponent: Component {
    var citizenID: UUID
    var currentPosition: SIMD3<Float>
    var targetPosition: SIMD3<Float>
    var speed: Float
    var activity: Activity
}

// Vehicle component
struct VehicleComponent: Component {
    var vehicleType: VehicleType
    var road: UUID
    var pathProgress: Float
    var speed: Float
}

// Zone marker component
struct ZoneComponent: Component {
    var zoneType: ZoneType
    var area: [SIMD2<Float>]
    var density: Float
}

// Traffic node component
struct TrafficNodeComponent: Component {
    var connections: [UUID]
    var trafficFlow: Float
    var isIntersection: Bool
}
```

### 5.2 Custom Systems

```swift
// Citizen behavior system
class CitizenSystem: System {
    static let query = EntityQuery(where: .has(CitizenComponent.self))

    init(scene: Scene) {
        // Initialize system
    }

    func update(context: SceneUpdateContext) {
        // Update all citizens
        // Path finding
        // Activity transitions
        // Visual updates
    }
}

// Traffic simulation system
class TrafficSystem: System {
    static let query = EntityQuery(where: .has(VehicleComponent.self))

    func update(context: SceneUpdateContext) {
        // Update vehicle positions
        // Traffic flow calculations
        // Collision avoidance
        // Route optimization
    }
}

// Building growth system
class BuildingGrowthSystem: System {
    func update(context: SceneUpdateContext) {
        // Process construction
        // Handle upgrades
        // Manage capacity
        // Visual state updates
    }
}
```

---

## 6. ARKit Integration

### 6.1 Plane Detection

```swift
class PlaneDetectionManager {
    private let session: ARKitSession
    private var planeData: PlaneDetectionProvider

    func startDetection() async {
        let planeData = PlaneDetectionProvider(alignments: [.horizontal])
        try? await session.run([planeData])

        for await update in planeData.anchorUpdates {
            handlePlaneUpdate(update)
        }
    }

    func handlePlaneUpdate(_ update: AnchorUpdate<PlaneAnchor>) {
        switch update.event {
        case .added:
            // New surface detected
        case .updated:
            // Surface updated
        case .removed:
            // Surface removed
        }
    }
}
```

### 6.2 Hand Tracking Integration

```swift
class HandTrackingManager {
    private let session: ARKitSession
    private var handTracking: HandTrackingProvider

    func processHandInput() async {
        for await update in handTracking.anchorUpdates {
            if let handAnchor = update.anchor {
                processGestures(handAnchor)
            }
        }
    }

    func processGestures(_ hand: HandAnchor) {
        // Detect pinch for selection
        // Detect swipe for building placement
        // Detect spread for zoom
        // Detect pointing for inspection
    }
}
```

### 6.3 Eye Tracking Integration

```swift
class EyeTrackingManager {
    func getGazeTarget() -> Entity? {
        // Ray cast from eye gaze
        // Find intersected entity
        // Return for detail view
    }

    func enableGazeInteraction(for entity: Entity) {
        // Add hover component
        // Setup gaze callbacks
        // Enable detail UI
    }
}
```

---

## 7. Simulation Architecture

### 7.1 Citizen AI System

```swift
class CitizenAIManager {
    private var behaviorTree: BehaviorTree
    private var pathfinding: PathfindingSystem

    // Activity scheduling
    func scheduleDailyActivities(citizen: Citizen) -> [Activity] {
        // Generate daily routine
        // Wake up -> commute -> work -> leisure -> home -> sleep
    }

    // Decision making
    func makeDecisions(citizen: Citizen, cityState: CityData) {
        // Evaluate happiness
        // Consider job changes
        // Evaluate moving
        // Social interactions
    }

    // Movement
    func updateMovement(citizen: Citizen, deltaTime: Float) {
        // A* pathfinding
        // Smooth interpolation
        // Collision avoidance
    }
}
```

### 7.2 Traffic Simulation

```swift
class TrafficSimulationSystem {
    private var roadNetwork: RoadGraph
    private var vehicles: [UUID: Vehicle]

    // Traffic flow simulation
    func simulateTraffic(deltaTime: Float) {
        // Update vehicle positions
        // Calculate traffic density
        // Optimize routing
        // Handle congestion
    }

    // Pathfinding for vehicles
    func findRoute(from: UUID, to: UUID) -> [UUID]? {
        // Dijkstra's algorithm
        // Consider traffic density
        // Real-time rerouting
    }
}
```

### 7.3 Economic Simulation

```swift
class EconomicSimulationSystem {
    private var economy: EconomyState

    // Economic cycle update
    func updateEconomy(city: CityData, deltaTime: Float) {
        calculateIncome(city)
        calculateExpenses(city)
        updateEmployment(city)
        simulateMarket(city)
    }

    // Resource management
    func manageResources(city: CityData) {
        // Power supply/demand
        // Water supply/demand
        // Service distribution
    }
}
```

---

## 8. Multiplayer Architecture

### 8.1 Network Architecture

```swift
class MultiplayerManager {
    private var groupSession: GroupSession<CityCollaboration>?
    private var messenger: GroupSessionMessenger
    private var syncEngine: SynchronizationEngine

    // SharePlay integration
    func startCollaboration() async throws {
        let activity = CityCollaboration()
        groupSession = try await activity.prepareForActivation().activate()
        messenger = GroupSessionMessenger(session: groupSession!)
    }

    // State synchronization
    func synchronizeState(localState: GameState) async {
        // Serialize state changes
        // Send to all participants
        // Handle conflicts
    }
}

struct CityCollaboration: GroupActivity {
    static let activityIdentifier = "com.example.citybuilder.collaboration"

    var metadata: GroupActivityMetadata {
        var metadata = GroupActivityMetadata()
        metadata.title = "City Building Session"
        metadata.type = .generic
        return metadata
    }
}
```

### 8.2 State Synchronization

```swift
class SynchronizationEngine {
    // Delta state updates
    func synchronizeDelta(changes: [StateChange]) {
        // Send only changes, not full state
        // Timestamp for ordering
        // Conflict resolution
    }

    // Conflict resolution
    func resolveConflict(local: StateChange, remote: StateChange) -> StateChange {
        // Last-write-wins for most changes
        // Democratic voting for major decisions
        // Role-based permissions
    }
}
```

---

## 9. Audio Architecture

### 9.1 Spatial Audio System

```swift
class SpatialAudioManager {
    private var audioEngine: AVAudioEngine
    private var environment: AVAudioEnvironmentNode

    // Ambient city sounds
    func playCityAmbience(citySize: Int) {
        // Scale ambience to city size
        // Traffic sounds at road locations
        // Citizen chatter in populated areas
        // Construction sounds at building sites
    }

    // Positional audio
    func playSound(at position: SIMD3<Float>, sound: AudioResource) {
        // 3D positioned audio
        // Spatial audio rendering
        // Distance attenuation
    }
}
```

---

## 10. Performance Optimization

### 10.1 Rendering Optimization

```swift
class RenderingOptimizer {
    // Level of Detail (LOD) system
    func updateLOD(camera: Transform, entities: [Entity]) {
        for entity in entities {
            let distance = distance(camera.position, entity.position)
            entity.components[LODComponent.self]?.level = lodLevel(for: distance)
        }
    }

    // Instanced rendering for citizens/vehicles
    func setupInstancedRendering() {
        // Use InstancedMeshes for thousands of citizens
        // GPU-based animation
        // Frustum culling
    }

    // Occlusion culling
    func cullOccluded(camera: Transform) {
        // Hide buildings behind other buildings
        // Optimize draw calls
    }
}
```

### 10.2 Simulation Optimization

```swift
class SimulationOptimizer {
    // Spatial partitioning
    func partitionCity(city: CityData) -> SpatialGrid {
        // Divide city into grid cells
        // Only simulate nearby citizens
        // Distance-based update frequency
    }

    // Detail levels based on view
    func adjustSimulationDetail(cameraDistance: Float) {
        // Full simulation when zoomed in
        // Simplified when zoomed out
        // Background simulation for inactive areas
    }
}
```

---

## 11. Save/Load System

### 11.1 Persistence Architecture

```swift
class PersistenceManager {
    // Save city state
    func saveCity(_ city: CityData, anchor: AnchorEntity) async throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(city)

        // Local save
        try await saveLocally(data, id: city.id)

        // iCloud sync (optional)
        try await syncToiCloud(data, id: city.id)

        // Save spatial anchor
        try await saveAnchor(anchor, id: city.id)
    }

    // Load city state
    func loadCity(id: UUID) async throws -> (CityData, AnchorEntity) {
        let data = try await loadFromStorage(id: id)
        let decoder = JSONDecoder()
        let city = try decoder.decode(CityData.self, from: data)

        let anchor = try await loadAnchor(id: id)

        return (city, anchor)
    }
}
```

---

## 12. Testing Architecture

### 12.1 Unit Testing

```swift
// Game logic tests
@Test("Economic system calculates income correctly")
func testEconomicIncome() {
    let economy = EconomicSimulationSystem()
    let city = createTestCity()

    economy.calculateIncome(city)

    #expect(city.economy.income > 0)
}

// AI behavior tests
@Test("Citizens follow daily routines")
func testCitizenRoutine() {
    let ai = CitizenAIManager()
    let citizen = Citizen(...)

    let activities = ai.scheduleDailyActivities(citizen: citizen)

    #expect(activities.count == 5) // Wake, commute, work, leisure, sleep
}
```

### 12.2 Integration Testing

```swift
// System integration tests
@Test("Traffic system integrates with road network")
func testTrafficIntegration() {
    let traffic = TrafficSimulationSystem()
    let roads = createTestRoadNetwork()

    traffic.simulateTraffic(deltaTime: 1.0)

    #expect(traffic.vehicles.count > 0)
}
```

### 12.3 Performance Testing

```swift
// Performance benchmarks
@Test("Simulate 10,000 citizens at 60 FPS")
func testCitizenPerformance() {
    let system = CitizenSystem()
    let citizens = create10KCitizens()

    measure {
        system.update(context: testContext)
    }

    // Ensure < 16ms per frame
}
```

---

## 13. Technology Stack

### Core Technologies
- **Language**: Swift 6.0+
- **UI Framework**: SwiftUI (Observation framework)
- **3D Engine**: RealityKit 4.0+
- **AR Framework**: ARKit 6.0+
- **Platform**: visionOS 2.0+
- **Testing**: Swift Testing
- **Networking**: GroupActivities (SharePlay)
- **Audio**: AVFAudio (Spatial Audio)

### Design Patterns
- Entity-Component-System (ECS)
- Model-View-ViewModel (MVVM) for UI
- Observer pattern for state changes
- Command pattern for user actions
- Strategy pattern for AI behaviors
- Factory pattern for entity creation

---

## 14. Performance Targets

- **Frame Rate**: 90 FPS (target), 60 FPS (minimum)
- **Simulation Scale**: 10,000+ citizens
- **Buildings**: 1,000+ simultaneous buildings
- **Vehicles**: 500+ active vehicles
- **Memory**: < 2GB RAM usage
- **Battery**: 3+ hours of continuous play
- **Latency**: < 50ms for multiplayer state sync

---

## 15. Security & Privacy

### Data Protection
- All city data encrypted at rest
- iCloud sync uses end-to-end encryption
- No telemetry without explicit consent
- Spatial data never leaves device
- Multiplayer uses encrypted SharePlay

### Surface Scanning
- Only detect plane geometry
- No room reconstruction beyond required surfaces
- No photos/videos captured
- Spatial anchors stored locally

---

This architecture provides a solid foundation for building a scalable, performant, and immersive city-building experience on visionOS.
