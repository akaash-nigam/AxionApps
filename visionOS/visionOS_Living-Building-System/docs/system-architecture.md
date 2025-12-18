# System Architecture Document
## Living Building System

**Version**: 1.0
**Last Updated**: 2025-11-24
**Status**: Draft

---

## 1. Executive Summary

This document outlines the system architecture for the Living Building System, a visionOS application that transforms homes into intelligent, responsive environments through spatial computing. The architecture emphasizes modularity, real-time performance, on-device processing, and seamless integration with smart home ecosystems.

## 2. Architecture Overview

### 2.1 High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     visionOS Application                     │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌───────────────────────────────────────────────────────┐  │
│  │           Presentation Layer (SwiftUI)                │  │
│  ├───────────────────────────────────────────────────────┤  │
│  │  • ImmersiveSpace Views                               │  │
│  │  • WindowGroup Views                                   │  │
│  │  • Contextual Display Components                       │  │
│  │  • RealityView Containers                              │  │
│  └───────────────────────────────────────────────────────┘  │
│                           │                                   │
│                           ▼                                   │
│  ┌───────────────────────────────────────────────────────┐  │
│  │              Application Layer (Swift)                 │  │
│  ├───────────────────────────────────────────────────────┤  │
│  │  ┌──────────────┐  ┌──────────────┐  ┌─────────────┐ │  │
│  │  │   Context    │  │    Device    │  │   Energy    │ │  │
│  │  │   Manager    │  │   Manager    │  │   Manager   │ │  │
│  │  └──────────────┘  └──────────────┘  └─────────────┘ │  │
│  │  ┌──────────────┐  ┌──────────────┐  ┌─────────────┐ │  │
│  │  │ Environment  │  │ Maintenance  │  │  Spatial    │ │  │
│  │  │   Manager    │  │   Manager    │  │  Manager    │ │  │
│  │  └──────────────┘  └──────────────┘  └─────────────┘ │  │
│  └───────────────────────────────────────────────────────┘  │
│                           │                                   │
│                           ▼                                   │
│  ┌───────────────────────────────────────────────────────┐  │
│  │               Domain Layer (Swift)                     │  │
│  ├───────────────────────────────────────────────────────┤  │
│  │  • Business Logic                                      │  │
│  │  • Domain Models                                       │  │
│  │  • Use Cases / Interactors                             │  │
│  │  • State Management (@Observable)                      │  │
│  └───────────────────────────────────────────────────────┘  │
│                           │                                   │
│                           ▼                                   │
│  ┌───────────────────────────────────────────────────────┐  │
│  │            Data & Integration Layer                    │  │
│  ├───────────────────────────────────────────────────────┤  │
│  │  ┌──────────────┐  ┌──────────────┐  ┌─────────────┐ │  │
│  │  │   SwiftData  │  │   HomeKit    │  │   Matter    │ │  │
│  │  │  Repository  │  │   Service    │  │   Service   │ │  │
│  │  └──────────────┘  └──────────────┘  └─────────────┘ │  │
│  │  ┌──────────────┐  ┌──────────────┐  ┌─────────────┐ │  │
│  │  │   Sensor     │  │    Energy    │  │  RealityKit │ │  │
│  │  │   Service    │  │   Service    │  │  Renderer   │ │  │
│  │  └──────────────┘  └──────────────┘  └─────────────┘ │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                               │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                   External Integrations                      │
├─────────────────────────────────────────────────────────────┤
│  • HomeKit Accessories    • Smart Meters                     │
│  • Matter Devices         • Solar Inverters                  │
│  • Environmental Sensors  • Battery Systems                  │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 Architectural Principles

1. **Separation of Concerns**: Clear boundaries between presentation, business logic, and data access
2. **On-Device First**: All processing happens locally; no cloud dependencies for core features
3. **Real-Time Responsive**: Sub-second latency for all user interactions
4. **Privacy by Design**: User data never leaves the device
5. **Modular & Extensible**: Easy to add new device types and features
6. **visionOS Native**: Leverages platform-specific capabilities (spatial computing, eye tracking)

## 3. Layer Details

### 3.1 Presentation Layer

**Technology**: SwiftUI, RealityKit, ARKit

**Components**:

#### 3.1.1 ImmersiveSpace Views
- **FullHomeView**: Main immersive experience showing entire home
- **EnergyFlowVisualization**: 3D particle system for energy/water flow
- **RoomContextOverlay**: Contextual information overlays on walls
- **EnvironmentalHeatmap**: Temperature/humidity visualization

#### 3.1.2 WindowGroup Views
- **DashboardWindow**: Central home control dashboard
- **SettingsWindow**: App configuration and preferences
- **DeviceDetailWindow**: Detailed device controls
- **MaintenanceWindow**: Maintenance task management

#### 3.1.3 RealityView Components
- **ContextualDisplayEntity**: Wall-mounted AR displays
- **FlowParticleSystem**: Energy flow visualization entities
- **DeviceControlEntity**: 3D control interfaces for devices
- **SensorIndicatorEntity**: Visual indicators for sensors

**Responsibilities**:
- Render UI components
- Handle user gestures and eye tracking
- Display AR content in physical space
- Respond to state changes
- Manage spatial layout

### 3.2 Application Layer

**Technology**: Swift, Combine (or async/await for async operations)

**Managers**:

#### 3.2.1 ContextManager
- Determines which contextual display to show based on user location
- Manages user proximity detection
- Coordinates with SpatialManager for room identification
- Personalizes content per user (Face ID integration)

**Key Methods**:
```swift
func updateUserContext(position: SIMD3<Float>, facing: SIMD3<Float>)
func getContextualDisplay(for room: Room, user: User) -> ContextualDisplay
func subscribeToContextChanges() -> AsyncStream<DisplayContext>
```

#### 3.2.2 DeviceManager
- Manages all smart home devices
- Handles device state updates
- Coordinates device control commands
- Maintains device group relationships

**Key Methods**:
```swift
func discoverDevices() async throws -> [SmartDevice]
func controlDevice(_ device: SmartDevice, action: DeviceAction) async throws
func createScene(_ scene: HomeScene) async throws
func executeAutomation(_ automation: Automation)
```

#### 3.2.3 EnergyManager
- Aggregates energy data from multiple sources
- Calculates consumption rates and costs
- Detects anomalies in usage patterns
- Manages historical data for trends

**Key Methods**:
```swift
func getCurrentConsumption() async -> EnergySnapshot
func getFlowVisualizationData() async -> FlowData
func detectAnomalies() async -> [EnergyAnomaly]
func calculateCost(for period: TimePeriod) -> Cost
```

#### 3.2.4 EnvironmentManager
- Monitors environmental sensors
- Generates heatmaps and air quality data
- Provides comfort recommendations
- Alerts on out-of-range conditions

**Key Methods**:
```swift
func getEnvironmentalData() async -> EnvironmentSnapshot
func generateHeatmap(for metric: EnvironmentMetric) -> Heatmap
func checkComfortLevels() async -> ComfortScore
func subscribeToAlerts() -> AsyncStream<EnvironmentAlert>
```

#### 3.2.5 MaintenanceManager
- Tracks maintenance schedules
- Generates predictive maintenance alerts
- Manages task history and documentation
- Calculates home health score

**Key Methods**:
```swift
func getUpcomingTasks() async -> [MaintenanceTask]
func completeTask(_ task: MaintenanceTask, documentation: TaskDocumentation)
func predictMaintenanceNeeds() async -> [PredictiveAlert]
func calculateHomeHealthScore() async -> HealthScore
```

#### 3.2.6 SpatialManager
- Manages ARKit room mapping
- Tracks anchor points for displays
- Handles spatial persistence
- Coordinates AR content placement

**Key Methods**:
```swift
func scanRoom() async throws -> RoomMesh
func placeAnchor(at position: SIMD3<Float>, for type: AnchorType) -> ARAnchor
func trackUserPosition() -> AsyncStream<UserPosition>
func persistSpatialData()
```

### 3.3 Domain Layer

**Technology**: Swift, Observation Framework

**Responsibilities**:
- Define core business entities
- Implement business rules
- Manage application state
- Coordinate use cases

**Core Models**:
- `Room`, `Home`, `User`
- `SmartDevice`, `DeviceGroup`, `Scene`, `Automation`
- `EnergyReading`, `WaterReading`, `GasReading`
- `EnvironmentSensor`, `EnvironmentReading`
- `MaintenanceTask`, `MaintenanceHistory`
- `ContextualDisplay`, `DisplayWidget`

**State Management**:
Uses Swift's `@Observable` macro for reactive state management:
```swift
@Observable
class HomeState {
    var currentRoom: Room?
    var devices: [SmartDevice] = []
    var energyData: EnergySnapshot?
    var environmentData: EnvironmentSnapshot?
    var maintenanceTasks: [MaintenanceTask] = []
}
```

### 3.4 Data & Integration Layer

**Technology**: SwiftData, HomeKit, Matter, URLSession

#### 3.4.1 SwiftData Repository
- Persistent storage for app data
- Models: Room configurations, user preferences, maintenance history
- Synchronization with iCloud (optional)

**Schema**:
```swift
@Model
class RoomConfiguration {
    @Attribute(.unique) var id: UUID
    var name: String
    var roomType: RoomType
    var anchors: [AnchorData]
    var displayPreferences: DisplayPreferences
}
```

#### 3.4.2 HomeKit Service
- Integration with HomeKit accessories
- Device discovery and control
- Scene and automation management
- Status monitoring

**Protocol Conformance**:
```swift
protocol HomeKitServiceProtocol {
    func requestAuthorization() async throws
    func discoverAccessories() async throws -> [HMAccessory]
    func sendCommand(to accessory: HMAccessory, characteristic: HMCharacteristic, value: Any) async throws
}
```

#### 3.4.3 Matter Service
- Matter protocol implementation
- Cross-ecosystem device support
- Commission new Matter devices

#### 3.4.4 Sensor Service
- Environmental sensor data collection
- Real-time data streaming
- Calibration and accuracy management

#### 3.4.5 Energy Service
- Smart meter API integration
- Solar inverter data collection
- Battery system monitoring
- Historical data aggregation

#### 3.4.6 RealityKit Renderer
- Particle system management
- 3D content rendering
- Performance optimization
- Material and shader application

## 4. Data Flow Patterns

### 4.1 Real-Time Device Control Flow
```
User Gesture → Presentation Layer → DeviceManager → HomeKit Service → Physical Device
                                          ↓
                                    State Update
                                          ↓
                                  HomeState (@Observable)
                                          ↓
                                   UI Auto-Updates
```

### 4.2 Contextual Display Flow
```
ARKit User Position → SpatialManager → ContextManager → Domain Logic → Display Selection
                                                              ↓
                                                    RealityView Update
                                                              ↓
                                                    AR Overlay Rendered
```

### 4.3 Energy Visualization Flow
```
Smart Meter → Energy Service → EnergyManager → Flow Calculation → RealityKit Renderer
                                      ↓
                               Historical Storage
                                      ↓
                              SwiftData Repository
```

## 5. Module Organization

```
LivingBuildingSystem/
├── App/
│   ├── LivingBuildingSystemApp.swift
│   └── AppConfiguration.swift
├── Presentation/
│   ├── ImmersiveViews/
│   ├── WindowViews/
│   ├── Components/
│   └── RealityContent/
├── Application/
│   ├── Managers/
│   └── Coordinators/
├── Domain/
│   ├── Models/
│   ├── UseCases/
│   └── State/
├── Data/
│   ├── Repositories/
│   ├── Services/
│   └── Persistence/
├── Integrations/
│   ├── HomeKit/
│   ├── Matter/
│   ├── Sensors/
│   └── Energy/
└── Utilities/
    ├── Extensions/
    ├── Helpers/
    └── Constants/
```

## 6. Communication Patterns

### 6.1 Between Layers
- **Presentation → Application**: Direct method calls, @Observable property observation
- **Application → Domain**: Use case execution, state updates
- **Domain → Data**: Repository pattern, async/await
- **Data → External**: Protocol-based service abstraction

### 6.2 Asynchronous Operations
- **Swift Concurrency**: async/await for all async operations
- **AsyncStream**: Real-time data streams (sensor readings, device updates)
- **Task Groups**: Parallel device discovery and status updates

### 6.3 State Synchronization
- **@Observable**: Primary state management mechanism
- **Single Source of Truth**: HomeState as central state container
- **Derived State**: Computed properties for UI-specific transformations

## 7. Dependency Management

### 7.1 Dependency Injection
```swift
protocol DependencyContainer {
    var deviceManager: DeviceManager { get }
    var energyManager: EnergyManager { get }
    var contextManager: ContextManager { get }
    var environmentManager: EnvironmentManager { get }
    var maintenanceManager: MaintenanceManager { get }
    var spatialManager: SpatialManager { get }
}

class DefaultDependencyContainer: DependencyContainer {
    // Singleton instances with lazy initialization
}
```

### 7.2 Third-Party Dependencies
- **Minimal External Dependencies**: Prefer Apple frameworks
- **Potential Libraries**:
  - Charts framework (for data visualization)
  - Network framework (for local device discovery)

## 8. Threading & Concurrency

### 8.1 Main Actor
- All UI updates on @MainActor
- View models annotated with @MainActor

### 8.2 Background Processing
- Device discovery on background tasks
- Energy data aggregation on background queue
- Sensor data processing on dedicated queue

### 8.3 ARKit Processing
- ARKit callbacks on dedicated queue
- Spatial processing on separate actor

```swift
actor SpatialProcessor {
    func processRoomMesh(_ mesh: ARMeshAnchor) async -> RoomMesh
    func calculateUserProximity(to position: SIMD3<Float>) async -> Float
}
```

## 9. Error Handling Strategy

### 9.1 Error Types
```swift
enum LBSError: Error {
    case deviceNotFound
    case deviceUnreachable
    case authorizationDenied
    case networkError(underlying: Error)
    case dataCorruption
    case spatialTrackingLost
}
```

### 9.2 Recovery Strategies
- **Graceful Degradation**: Show cached data when real-time unavailable
- **Retry Logic**: Exponential backoff for transient failures
- **User Feedback**: Clear error messages with actionable steps

## 10. Performance Considerations

### 10.1 Memory Management
- Weak references for delegates
- Lazy loading for heavy resources
- Image/texture caching
- Particle system pooling

### 10.2 Rendering Performance
- Target: 60fps minimum
- LOD (Level of Detail) for complex visualizations
- Occlusion culling for off-screen content
- Throttling for real-time updates (max 10Hz for energy data)

### 10.3 Battery Optimization
- Low-power mode for background monitoring
- Reduce ARKit processing when inactive
- Batch network requests
- Optimize particle count dynamically

## 11. visionOS-Specific Considerations

### 11.1 ImmersiveSpace Management
```swift
@main
struct LivingBuildingSystemApp: App {
    @State private var immersionStyle: ImmersionStyle = .mixed

    var body: some Scene {
        WindowGroup {
            DashboardView()
        }

        ImmersiveSpace(id: "home-view") {
            FullHomeView()
        }
        .immersionStyle(selection: $immersionStyle, in: .mixed, .progressive, .full)
    }
}
```

### 11.2 Eye Tracking Integration
- Device selection via gaze
- Attention-based UI updates
- Privacy-preserving eye tracking

### 11.3 Hand Tracking
- Gesture recognition for control
- Pinch gestures for quick actions
- Spatial pointer for precise interaction

## 12. Scalability

### 12.1 Device Limits
- Support up to 100 devices per home
- Efficient polling strategies (event-driven when possible)
- Device prioritization for updates

### 12.2 Data Storage
- Rolling window for real-time data (7 days)
- Aggregated historical data (1 year+)
- Automatic cleanup of old maintenance records

### 12.3 Multi-Home Support
- Home switching in settings
- Per-home configuration
- Shared family access (iCloud)

## 13. Security Architecture

### 13.1 On-Device Security
- Keychain for device credentials
- Encrypted SwiftData storage
- Secure enclave for sensitive data

### 13.2 Network Security
- TLS for all external communications
- Certificate pinning for critical services
- Local network privacy authorization

### 13.3 Access Control
- Face ID for user identification
- Per-user device permissions
- Audit log for sensitive actions

## 14. Testing Architecture

### 14.1 Unit Tests
- Domain logic tests (100% coverage goal)
- Manager tests with mocked dependencies
- State management tests

### 14.2 Integration Tests
- HomeKit service integration
- SwiftData repository tests
- End-to-end flow tests

### 14.3 UI Tests
- Critical user flows
- Gesture interaction tests
- Accessibility tests

### 14.4 Performance Tests
- Frame rate monitoring
- Memory leak detection
- Battery consumption profiling

## 15. Development Phases

### Phase 1: Foundation
- Project setup and module structure
- Core domain models
- SwiftData schema
- Basic UI structure

### Phase 2: Device Integration
- HomeKit service implementation
- Device manager
- Basic device control UI

### Phase 3: Spatial Features
- ARKit room mapping
- Contextual displays
- Spatial manager

### Phase 4: Energy & Monitoring
- Energy service integration
- Flow visualization
- Environmental monitoring

### Phase 5: Advanced Features
- Maintenance tracking
- Predictive analytics
- Scene and automation

### Phase 6: Polish & Optimization
- Performance optimization
- Error handling refinement
- Accessibility
- Beta testing

## 16. Future Considerations

- **Widget Extensions**: Home Screen widgets for quick status
- **Watch App**: Quick device control from Apple Watch
- **Shortcuts Integration**: Siri shortcuts for common tasks
- **SharePlay**: Collaborative home management
- **Third-Party Integrations**: Plugin system for additional services

## 17. Decision Log

| Date | Decision | Rationale |
|------|----------|-----------|
| 2025-11-24 | Use @Observable over Combine | Simpler, more modern Swift concurrency model |
| 2025-11-24 | SwiftData for persistence | Native, type-safe, integrates with SwiftUI |
| 2025-11-24 | Clean architecture with layers | Maintainability, testability, scalability |
| 2025-11-24 | On-device processing | Privacy, reduced latency, offline capability |

---

**Document Owner**: Architecture Team
**Review Cycle**: Quarterly or on major feature additions
**Next Review**: 2026-02-24
