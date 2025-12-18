# City Builder Tabletop - Technical Specifications

## Document Overview
Detailed technical specifications for implementing City Builder Tabletop on visionOS, including technology stack, implementation details, control schemes, and testing requirements.

---

## 1. Technology Stack

### 1.1 Core Technologies

| Component | Technology | Version | Purpose |
|-----------|-----------|---------|---------|
| Language | Swift | 6.0+ | Primary development language |
| UI Framework | SwiftUI | visionOS 2.0+ | User interface and menus |
| 3D Engine | RealityKit | 4.0+ | 3D rendering and spatial computing |
| AR Framework | ARKit | 6.0+ | Spatial tracking and plane detection |
| Platform SDK | visionOS SDK | 2.0+ | Vision Pro specific features |
| Audio | AVFoundation | Latest | Spatial audio rendering |
| Networking | GroupActivities | visionOS 2.0+ | Multiplayer SharePlay |
| Storage | SwiftData | Latest | Local data persistence |
| Cloud Sync | CloudKit | Latest | Optional cloud save |
| Testing | Swift Testing | Latest | Unit and integration tests |
| UI Testing | XCTest | Latest | UI automation tests |

### 1.2 Optional Dependencies

```swift
// Swift Package Manager dependencies
dependencies: [
    // None required - using native frameworks only
    // Future: Consider GameplayKit for advanced AI
]
```

---

## 2. Game Mechanics Implementation

### 2.1 Building Placement System

**Algorithm**: Grid-based placement with snap-to-grid and free placement modes

```swift
class BuildingPlacementSystem {
    // Grid parameters
    let gridSize: Float = 0.05  // 5cm grid cells
    let snapThreshold: Float = 0.025  // 2.5cm snap distance

    // Placement validation
    func canPlaceBuilding(at position: SIMD3<Float>,
                          type: BuildingType,
                          cityData: CityData) -> Bool {
        // Check zone compatibility
        guard isValidZone(position, for: type) else { return false }

        // Check for overlaps
        guard !hasOverlap(at: position, size: type.footprint) else { return false }

        // Check terrain suitability
        guard isValidTerrain(at: position) else { return false }

        // Check road access
        guard hasRoadAccess(position, within: type.maxRoadDistance) else { return false }

        return true
    }

    // Visual feedback
    func showPlacementPreview(at position: SIMD3<Float>, valid: Bool) {
        // Green hologram if valid, red if invalid
        // Snap to grid visually
        // Show affected area
    }
}
```

### 2.2 Road Construction System

**Algorithm**: Bezier curve-based road drawing with automatic intersection handling

```swift
class RoadConstructionSystem {
    // Road drawing
    func drawRoad(points: [SIMD3<Float>]) -> Road {
        // Convert points to smooth Bezier curve
        let curve = createBezierCurve(from: points)

        // Auto-generate intersections
        let intersections = detectIntersections(curve, with: existingRoads)

        // Create road segments
        let segments = subdivideAtIntersections(curve, intersections)

        // Generate road mesh
        let road = Road(
            path: curve.points,
            lanes: determineLanes(from: curve.length),
            intersections: intersections
        )

        return road
    }

    // Intersection creation
    func createIntersection(roads: [Road]) -> Intersection {
        // Calculate intersection geometry
        // Create traffic light or stop sign
        // Setup traffic flow rules
    }
}
```

### 2.3 Zoning System

```swift
enum ZoneType {
    case residential
    case commercial
    case industrial
    case mixed
    case park
}

class ZoningSystem {
    // Zone designation
    func designateZone(area: [SIMD2<Float>], type: ZoneType) {
        // Create zone polygon
        // Set development rules
        // Apply density limits
        // Configure building restrictions
    }

    // Automatic building spawning in zones
    func growZone(zone: Zone, demand: Float) {
        // Calculate available space
        // Determine building size based on demand
        // Auto-place buildings respecting rules
        // Trigger construction animations
    }
}
```

### 2.4 Citizen AI Implementation

**Algorithm**: Behavior tree with utility-based decision making

```swift
class CitizenBehavior {
    enum State {
        case sleeping
        case commuting
        case working
        case shopping
        case leisure
        case returning
    }

    // Behavior tree structure
    struct BehaviorTree {
        var root: BehaviorNode

        // Sequence: Wake -> Commute -> Work -> Leisure -> Return -> Sleep
    }

    // Pathfinding: A* algorithm
    func findPath(from: SIMD3<Float>, to: SIMD3<Float>) -> [SIMD3<Float>] {
        // A* on road network
        // Smooth path with Catmull-Rom spline
        // Add random variation for natural movement
    }

    // Activity scheduling
    func scheduleDay(citizen: Citizen) -> [ScheduledActivity] {
        let schedule = [
            ScheduledActivity(time: 7.0, duration: 1.0, type: .wake),
            ScheduledActivity(time: 8.0, duration: 0.5, type: .commute),
            ScheduledActivity(time: 8.5, duration: 8.0, type: .work),
            ScheduledActivity(time: 16.5, duration: 0.5, type: .commute),
            ScheduledActivity(time: 17.0, duration: 3.0, type: .leisure),
            ScheduledActivity(time: 20.0, duration: 0.5, type: .commute),
            ScheduledActivity(time: 20.5, duration: 10.5, type: .sleep)
        ]
        return schedule
    }
}
```

### 2.5 Traffic Simulation

**Algorithm**: Flow-based traffic simulation with dynamic routing

```swift
class TrafficSimulation {
    // Traffic flow calculation
    func calculateFlow(road: Road, density: Float) -> Float {
        // Simplified traffic flow model
        // Flow = Density × (1 - Density) × MaxSpeed
        let normalizedDensity = density / road.capacity
        let flow = normalizedDensity * (1 - normalizedDensity) * road.maxSpeed
        return flow
    }

    // Vehicle routing
    func routeVehicle(from: UUID, to: UUID) -> [UUID] {
        // Dijkstra with traffic weight
        // Dynamic rerouting on congestion
        // Consider road capacity
    }

    // Traffic light management
    func updateTrafficLights(intersection: Intersection, deltaTime: Float) {
        // Timed cycles
        // Adaptive timing based on traffic density
        // Emergency vehicle priority
    }
}
```

### 2.6 Economic Simulation

**Algorithm**: Supply-demand based economic model

```swift
class EconomicEngine {
    // Income calculation
    func calculateIncome(city: CityData) -> Float {
        let residential = city.buildings.filter { $0.type.isResidential }
        let commercial = city.buildings.filter { $0.type.isCommercial }
        let industrial = city.buildings.filter { $0.type.isIndustrial }

        // Tax revenue
        let propertyTax = Float(residential.count) * city.economy.taxRate * 100
        let businessTax = Float(commercial.count + industrial.count) * city.economy.taxRate * 200

        return propertyTax + businessTax
    }

    // Expense calculation
    func calculateExpenses(city: CityData) -> Float {
        let infrastructure = city.infrastructure
        let maintenance = Float(city.roads.count) * 10
        let services = Float(city.buildings.filter { $0.type.isInfrastructure }.count) * 50

        return maintenance + services + infrastructure.powerCost + infrastructure.waterCost
    }

    // Employment simulation
    func updateEmployment(city: CityData) {
        let jobs = countAvailableJobs(city)
        let workers = city.citizens.filter { $0.age >= 18 && $0.age <= 65 }.count

        city.economy.unemployment = max(0, Float(workers - jobs) / Float(workers))
    }
}
```

---

## 3. Control Schemes

### 3.1 Hand Tracking Gestures

| Gesture | Action | Implementation |
|---------|--------|----------------|
| Pinch + Move | Select and place building | Detect pinch, track position, release to place |
| Index Finger Trace | Draw roads | Track fingertip, create path, smooth curve |
| Two-Hand Spread/Pinch | Zoom in/out | Measure hand distance, scale view |
| Tap | Select/Activate | Quick pinch detection |
| Palm Up | Open tool menu | Hand pose recognition |
| Swipe | Rotate view | Hand velocity detection |

```swift
class GestureRecognizer {
    func detectPinch(hand: HandAnchor) -> Bool {
        let thumbTip = hand.skeleton.joint(.thumbTip)
        let indexTip = hand.skeleton.joint(.indexFingerTip)
        let distance = simd_distance(thumbTip.position, indexTip.position)
        return distance < 0.02  // 2cm threshold
    }

    func detectSwipe(hand: HandAnchor) -> SwipeDirection? {
        // Track hand velocity
        // Determine direction
        // Minimum velocity threshold
    }
}
```

### 3.2 Eye Tracking

| Action | Implementation | Purpose |
|--------|----------------|---------|
| Gaze + Dwell | Hover information | Show building details on 1s gaze |
| Gaze + Pinch | Quick select | Select what user is looking at |
| Gaze Direction | Camera hint | Subtle camera follow of gaze |

```swift
class EyeTrackingController {
    func performRaycast(from eyeGaze: SIMD3<Float>) -> Entity? {
        // Cast ray from eye position
        // Find closest intersecting entity
        // Return for detail view
    }

    func enableDwellSelect(threshold: TimeInterval = 1.0) {
        // Track gaze duration on entity
        // Trigger selection after threshold
        // Visual feedback during dwell
    }
}
```

### 3.3 Voice Commands

| Command | Action | Parameters |
|---------|--------|------------|
| "Build residential zone" | Start zone tool | Zone type |
| "Add road" | Start road drawing | - |
| "Show population" | Display statistics | Stat type |
| "Pause simulation" | Pause game | - |
| "Speed up time" | Increase simulation speed | - |

```swift
class VoiceCommandProcessor {
    func processCommand(_ command: String) -> GameAction? {
        let lowercased = command.lowercased()

        switch lowercased {
        case let cmd where cmd.contains("build") && cmd.contains("residential"):
            return .startZoning(.residential)
        case let cmd where cmd.contains("road"):
            return .startRoadDrawing
        case let cmd where cmd.contains("show") && cmd.contains("population"):
            return .showStatistics(.population)
        default:
            return nil
        }
    }
}
```

### 3.4 Game Controller Support

| Input | Action | Notes |
|-------|--------|-------|
| Left Stick | Pan camera | Smooth movement |
| Right Stick | Rotate camera | Orbital rotation |
| Triggers | Zoom in/out | Analog zoom control |
| A Button | Confirm/Place | Primary action |
| B Button | Cancel | Secondary action |
| D-Pad | Tool selection | Quick access |

---

## 4. Physics Specifications

### 4.1 Collision Detection

```swift
class CollisionSystem {
    // Building-building collision
    func checkBuildingOverlap(new: Building, existing: [Building]) -> Bool {
        for building in existing {
            if boundingBoxIntersects(new.bounds, building.bounds) {
                return true
            }
        }
        return false
    }

    // Road-building collision
    func validateRoadClearance(road: Road) -> Bool {
        // Ensure 2m clearance from buildings
        // Allow road-building intersections at designated points
    }
}
```

### 4.2 Physics Simulation

```swift
// Minimal physics - mostly kinematic
class PhysicsConfiguration {
    static let gravity = SIMD3<Float>(0, -9.81, 0)  // Not used for most entities

    // Collision layers
    enum CollisionLayer: UInt32 {
        case terrain = 1
        case buildings = 2
        case roads = 4
        case citizens = 8
        case vehicles = 16
        case ui = 32
    }

    // Collision matrix
    static let collisionMatrix: [CollisionLayer: [CollisionLayer]] = [
        .terrain: [.buildings, .roads],
        .buildings: [.terrain],
        .roads: [.terrain],
        .citizens: [],  // No collision
        .vehicles: [],  // No collision
        .ui: []
    ]
}
```

---

## 5. Rendering Requirements

### 5.1 Visual Quality

| Asset Type | Polygon Count | Texture Size | LOD Levels |
|----------|---------------|--------------|------------|
| Small Building | 500-1000 | 1024x1024 | 3 |
| Large Building | 2000-5000 | 2048x2048 | 4 |
| Citizen | 200-300 | 512x512 | 2 |
| Vehicle | 300-500 | 512x512 | 2 |
| Road Segment | 100-200 | 1024x1024 tiling | 2 |
| Tree/Prop | 100-300 | 512x512 | 2 |

### 5.2 Shader Requirements

```swift
// Custom shaders
enum CustomShader {
    case buildingGhost  // Transparent preview during placement
    case zoneOverlay    // Colored zone boundaries
    case trafficFlow    // Animated traffic density visualization
    case constructionEffect  // Building construction animation
}

// Material properties
struct BuildingMaterial {
    var baseColor: UIColor
    var metallic: Float = 0.0
    var roughness: Float = 0.7
    var emissive: UIColor? = nil  // For night lights
}
```

### 5.3 Lighting

```swift
class LightingSystem {
    // Day/night cycle
    func updateTimeOfDay(hour: Float) {
        // Adjust directional light (sun)
        // Enable building lights at night
        // Update ambient lighting
        // Adjust skybox
    }

    // Per-building lighting
    func setupBuildingLights(building: Entity) {
        // Window lights (night only)
        // Street lights along roads
        // Ambient building glow
    }
}
```

---

## 6. Multiplayer/Networking Specifications

### 6.1 Network Architecture

**Protocol**: SharePlay (GroupActivities framework)

```swift
struct NetworkMessage: Codable {
    var type: MessageType
    var timestamp: Date
    var sender: UUID
    var payload: Data

    enum MessageType {
        case stateSync
        case buildingPlaced
        case roadDrawn
        case zoneCreated
        case vote
        case chat
    }
}
```

### 6.2 State Synchronization

**Strategy**: Delta state updates with conflict resolution

```swift
class StateSynchronizer {
    // Send only changes
    func sendUpdate(change: StateChange) async {
        let message = NetworkMessage(
            type: .stateSync,
            timestamp: Date(),
            sender: localPlayerID,
            payload: try! JSONEncoder().encode(change)
        )

        try? await messenger.send(message)
    }

    // Conflict resolution
    func resolveConflict(local: StateChange, remote: StateChange) -> StateChange {
        // Last-write-wins with timestamp
        if remote.timestamp > local.timestamp {
            return remote
        }
        return local
    }

    // Voting for major decisions
    func initiateVote(proposal: CityProposal) async {
        // Send vote request to all players
        // Collect votes
        // Apply result when majority reached
    }
}
```

### 6.3 Bandwidth Requirements

| Operation | Data Size | Frequency | Bandwidth |
|-----------|-----------|-----------|-----------|
| Building Placement | ~500 bytes | On action | Minimal |
| Road Creation | ~1-2 KB | On action | Minimal |
| Citizen Update | ~100 bytes | Every 5s | Low |
| Full State Sync | ~100 KB | On join | One-time |
| Voice Chat | 20 Kbps | Continuous | Handled by SharePlay |

**Total**: < 50 Kbps per player (excluding voice)

---

## 7. Performance Budgets

### 7.1 Frame Rate Targets

| Scenario | Target FPS | Minimum FPS | Notes |
|----------|-----------|-------------|-------|
| Small City (< 1000 citizens) | 90 | 60 | Full detail |
| Medium City (< 5000 citizens) | 90 | 60 | Some LOD |
| Large City (< 10000 citizens) | 60 | 45 | Aggressive LOD |
| Multiplayer (4 players) | 60 | 45 | Network overhead |

### 7.2 Memory Budget

| Component | Memory Allocation | Notes |
|-----------|-------------------|-------|
| 3D Assets | 500 MB | With aggressive LOD |
| Textures | 300 MB | Compressed |
| Simulation State | 200 MB | 10K citizens + buildings |
| Audio | 50 MB | Streaming spatial audio |
| UI | 50 MB | SwiftUI + RealityKit overlays |
| System Reserve | 400 MB | visionOS overhead |
| **Total** | **~1.5 GB** | Under 2GB limit |

### 7.3 CPU Budget (per frame @ 90 FPS = 11ms)

| System | Time Budget | Notes |
|--------|-------------|-------|
| Game Logic | 2 ms | State updates |
| Simulation | 3 ms | Citizens, traffic, economy |
| Physics | 1 ms | Minimal collisions |
| Input Processing | 1 ms | Gestures, eye tracking |
| Networking | 1 ms | State sync |
| RealityKit | 3 ms | Scene graph updates |
| **Total** | **11 ms** | 90 FPS target |

### 7.4 GPU Budget

| Operation | Budget | Notes |
|-----------|--------|-------|
| Draw Calls | < 1000 | Instanced rendering |
| Triangles | < 2M | With LOD |
| Texture Bandwidth | < 2 GB/s | Texture streaming |
| Shader Complexity | Medium | PBR materials |

---

## 8. Testing Requirements

### 8.1 Unit Testing

**Coverage Target**: > 80% for game logic

```swift
@Test("Building placement validation")
func testBuildingPlacement() {
    let system = BuildingPlacementSystem()
    let city = CityData()

    // Test valid placement
    #expect(system.canPlaceBuilding(at: SIMD3(0, 0, 0), type: .residential(.house), cityData: city))

    // Test invalid overlap
    city.buildings.append(Building(position: SIMD3(0, 0, 0), type: .residential(.house)))
    #expect(!system.canPlaceBuilding(at: SIMD3(0, 0, 0), type: .commercial(.shop), cityData: city))
}

@Test("Economic calculations")
func testEconomicCalculations() {
    let economy = EconomicEngine()
    let city = createTestCity(buildings: 100, citizens: 1000)

    let income = economy.calculateIncome(city)
    let expenses = economy.calculateExpenses(city)

    #expect(income > 0)
    #expect(expenses > 0)
}

@Test("Citizen pathfinding")
func testPathfinding() {
    let behavior = CitizenBehavior()
    let path = behavior.findPath(from: SIMD3(0, 0, 0), to: SIMD3(10, 0, 10))

    #expect(path.count > 0)
    #expect(path.first == SIMD3(0, 0, 0))
    #expect(path.last == SIMD3(10, 0, 10))
}
```

### 8.2 Integration Testing

```swift
@Test("Full simulation cycle")
func testSimulationIntegration() {
    let game = GameEngine()
    game.createNewCity()

    // Add buildings
    game.placeBuilding(type: .residential(.house), at: SIMD3(0, 0, 0))
    game.placeBuilding(type: .commercial(.office), at: SIMD3(5, 0, 0))

    // Run simulation
    game.update(deltaTime: 1.0)

    #expect(game.state.citizens.count > 0)
    #expect(game.state.economy.income > 0)
}

@Test("Multiplayer state synchronization")
func testMultiplayerSync() async {
    let host = MultiplayerManager()
    let client = MultiplayerManager()

    await host.startCollaboration()
    await client.joinCollaboration()

    host.placeBuilding(type: .residential(.house), at: SIMD3(0, 0, 0))

    try? await Task.sleep(for: .seconds(1))

    #expect(client.gameState.buildings.count == 1)
}
```

### 8.3 UI Testing

```swift
@Test("Building placement UI flow")
@MainActor
func testBuildingPlacementUI() {
    let app = XCUIApplication()
    app.launch()

    // Open tool palette
    app.buttons["ToolPalette"].tap()

    // Select residential
    app.buttons["Residential"].tap()

    // Simulate gesture placement
    let cityVolume = app.otherElements["CityVolume"]
    cityVolume.tap()

    // Verify building appears
    #expect(app.otherElements.matching(identifier: "Building").count == 1)
}
```

### 8.4 Performance Testing

```swift
@Test("Simulate 10K citizens")
func testLargeCityPerformance() {
    let city = createLargeCity(citizens: 10000, buildings: 1000)
    let simulation = SimulationEngine()

    measure {
        simulation.update(city, deltaTime: 1/90.0)
    }

    // Ensure < 11ms per frame
}

@Test("Memory usage under load")
func testMemoryUsage() {
    let city = createLargeCity(citizens: 10000, buildings: 1000)

    let memoryBefore = getMemoryUsage()
    let simulation = SimulationEngine()
    simulation.update(city, deltaTime: 1.0)
    let memoryAfter = getMemoryUsage()

    #expect(memoryAfter - memoryBefore < 2_000_000_000)  // < 2GB
}
```

### 8.5 Spatial Testing

```swift
@Test("Surface detection accuracy")
func testSurfaceDetection() async {
    let detector = SurfaceDetectionSystem()
    let surfaces = try? await detector.detectSurfaces()

    #expect(surfaces != nil)
    #expect(surfaces!.count > 0)

    // Verify surface is horizontal
    for surface in surfaces! {
        #expect(surface.alignment == .horizontal)
    }
}

@Test("Gesture recognition accuracy")
func testGestureRecognition() {
    let recognizer = GestureRecognizer()
    let mockHand = createMockPinchGesture()

    #expect(recognizer.detectPinch(hand: mockHand))
}
```

---

## 9. Accessibility Requirements

### 9.1 Motor Accessibility

- **One-handed operation**: All features accessible with single hand
- **Simplified gestures**: Large gesture targets, reduced precision requirements
- **Voice control**: Complete game controllable via voice
- **Controller support**: Full gamepad support

### 9.2 Visual Accessibility

- **High contrast mode**: Increased building/road contrast
- **Colorblind modes**: Zone colors for protanopia, deuteranopia, tritanopia
- **Scalable UI**: Text size adjustable 100%-200%
- **Audio cues**: Sound effects for all visual feedback

### 9.3 Cognitive Accessibility

- **Tutorial mode**: Step-by-step guided learning
- **Simplified mode**: Reduced complexity for younger players
- **Pause anytime**: No time pressure
- **Clear feedback**: Explicit success/failure indicators

---

## 10. Build & Deployment

### 10.1 Build Configuration

```swift
// Debug build
#if DEBUG
    let enableDebugVisualizations = true
    let logLevel = .verbose
    let performanceOverlay = true
#else
    let enableDebugVisualizations = false
    let logLevel = .error
    let performanceOverlay = false
#endif
```

### 10.2 App Store Requirements

- **Minimum visionOS**: 2.0
- **Required Capabilities**:
  - Hand Tracking
  - Plane Detection
  - World Tracking
  - Spatial Audio
- **Optional Capabilities**:
  - Eye Tracking
  - SharePlay
  - Game Controller
- **Privacy**: NSWorldSensingUsageDescription
- **Age Rating**: 4+ (everyone)

### 10.3 TestFlight Beta

- **Internal Testing**: Development team (10 users)
- **External Testing**: Beta testers (100 users)
- **Testing Period**: 4 weeks
- **Feedback Collection**: In-app feedback form + analytics

---

## 11. Development Tools

### 11.1 Required Tools

- Xcode 16.0+
- visionOS 2.0 SDK
- Reality Composer Pro
- Instruments (performance profiling)
- Swift Testing

### 11.2 Recommended Tools

- Git for version control
- Swift-Format for code formatting
- SwiftLint for code quality
- Figma for UI design mockups

---

## 12. Code Quality Standards

### 12.1 Swift Style Guide

- Follow Swift API Design Guidelines
- Use meaningful variable names
- Document public APIs with DocC comments
- Maximum function length: 50 lines
- Maximum file length: 500 lines

### 12.2 Architecture Patterns

- MVVM for UI components
- ECS for game entities
- Repository pattern for data persistence
- Dependency injection for testability

---

This technical specification provides the detailed blueprint for implementing City Builder Tabletop with high quality, performance, and testability.
