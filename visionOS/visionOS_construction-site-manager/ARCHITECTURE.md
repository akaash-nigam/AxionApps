# Construction Site Manager - Technical Architecture

## Document Overview
**Version:** 1.0
**Last Updated:** 2025-01-20
**Status:** Design Phase

This document defines the technical architecture for the Construction Site Manager visionOS application, a spatial computing platform that transforms construction site management through AR overlay, BIM integration, and AI-powered safety monitoring.

---

## 1. System Architecture Overview

### 1.1 High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    Vision Pro Device Layer                       │
│  ┌──────────────┬──────────────┬──────────────┬──────────────┐ │
│  │   SwiftUI    │  RealityKit  │   ARKit      │  Hand/Eye    │ │
│  │   Views      │   Renderer   │   Tracking   │  Tracking    │ │
│  └──────────────┴──────────────┴──────────────┴──────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                              ↕
┌─────────────────────────────────────────────────────────────────┐
│                    Application Layer                             │
│  ┌──────────────┬──────────────┬──────────────┬──────────────┐ │
│  │  Presentation│   Business   │    Data      │   Spatial    │ │
│  │    Layer     │    Logic     │   Services   │   Computing  │ │
│  └──────────────┴──────────────┴──────────────┴──────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                              ↕
┌─────────────────────────────────────────────────────────────────┐
│                    Edge Computing Layer                          │
│  ┌──────────────┬──────────────┬──────────────┬──────────────┐ │
│  │   Site       │    Cache     │  Sync        │   Local      │ │
│  │   Server     │    Manager   │  Engine      │   Storage    │ │
│  └──────────────┴──────────────┴──────────────┴──────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                              ↕
┌─────────────────────────────────────────────────────────────────┐
│                    Cloud Services Layer                          │
│  ┌──────────────┬──────────────┬──────────────┬──────────────┐ │
│  │  BIM Model   │    AI/ML     │  Integration │   Analytics  │ │
│  │  Storage     │   Services   │     APIs     │   Engine     │ │
│  └──────────────┴──────────────┴──────────────┴──────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                              ↕
┌─────────────────────────────────────────────────────────────────┐
│                External Integrations Layer                       │
│  ┌──────────────┬──────────────┬──────────────┬──────────────┐ │
│  │  Procore     │  BIM 360     │  PlanGrid    │   IoT        │ │
│  │  API         │  Connector   │  Integration │   Sensors    │ │
│  └──────────────┴──────────────┴──────────────┴──────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

### 1.2 Core Architectural Principles

1. **Spatial-First Design**: Leverage visionOS capabilities for 3D visualization and interaction
2. **Offline-First**: Full functionality without connectivity, opportunistic sync
3. **Performance-Optimized**: 90 FPS rendering with complex BIM models
4. **Scalable**: Support projects from residential to mega infrastructure
5. **Secure**: End-to-end encryption, role-based access, audit trails
6. **Extensible**: Plugin architecture for trade-specific modules

---

## 2. visionOS-Specific Architecture

### 2.1 Application Presentation Modes

#### Primary Mode: Hybrid Approach
```swift
@main
struct ConstructionSiteApp: App {
    @State private var immersionStyle: ImmersionStyle = .mixed

    var body: some Scene {
        // Main control window (2D floating)
        WindowGroup("Site Control") {
            SiteControlView()
        }
        .windowStyle(.plain)
        .defaultSize(width: 800, height: 600)

        // 3D Site Visualization (Volumetric)
        WindowGroup("Site Overview", id: "site-overview") {
            SiteOverviewVolumeView()
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 2, height: 1.5, depth: 2, in: .meters)

        // AR Overlay Mode (Immersive)
        ImmersiveSpace(id: "ar-overlay") {
            ARSiteOverlayView()
        }
        .immersionStyle(selection: $immersionStyle, in: .mixed, .full)
    }
}
```

#### Mode Characteristics

| Mode | Use Case | Duration | Priority |
|------|----------|----------|----------|
| **WindowGroup (2D)** | Dashboard, lists, forms, data entry | Continuous | P0 |
| **Volumetric** | Site overview, planning, coordination meetings | 30-60 min | P0 |
| **Mixed Reality** | On-site AR overlay, progress tracking, inspections | 4-8 hours | P0 |
| **Full Immersive** | Training, client walkthroughs, design review | 15-30 min | P1 |

### 2.2 Spatial Scene Architecture

```swift
// Scene hierarchy for AR overlay
ARSiteOverlayView
├── RealityViewContainer
│   ├── SiteAnchorEntity (GPS + Visual markers)
│   │   ├── BIMModelEntity (IFC geometry)
│   │   │   ├── StructuralComponents
│   │   │   ├── MEPSystems
│   │   │   └── ArchitecturalElements
│   │   ├── ProgressOverlayEntity
│   │   │   ├── CompletedWork (Green overlay)
│   │   │   ├── InProgress (Yellow overlay)
│   │   │   └── Planned (Ghost/transparent)
│   │   ├── SafetyZoneEntity
│   │   │   ├── DangerZones (Red boundaries)
│   │   │   ├── WorkZones (Orange areas)
│   │   │   └── SafeZones (Green areas)
│   │   ├── CrewTrackingEntity
│   │   │   └── WorkerAvatars (Real-time positions)
│   │   └── AnnotationEntity
│   │       ├── IssueMarkers
│   │       ├── Measurements
│   │       └── Notes
│   └── UIOverlays
│       ├── ContextualMenu
│       ├── QuickActions
│       └── StatusIndicators
```

### 2.3 Coordinate Systems and Spatial Anchoring

```swift
// Multi-level coordinate system
enum CoordinateSpace {
    case world           // visionOS world coordinates
    case site            // Construction site coordinates (GPS-based)
    case building        // BIM model local coordinates
    case floor           // Per-floor coordinates for vertical projects
    case entity          // Individual entity local space
}

// Anchor hierarchy
class SiteAnchorSystem {
    // Primary anchor: GPS + Visual SLAM
    var siteOriginAnchor: AnchorEntity

    // Secondary anchors: QR markers for indoor precision
    var floorAnchors: [Int: AnchorEntity]  // Floor number -> Anchor

    // Cloud anchors for multi-user persistence
    var sharedAnchors: [String: WorldAnchor]

    // Coordinate transformations
    func transformBIMToWorld(_ point: BIMCoordinate) -> WorldCoordinate
    func transformWorldToBIM(_ point: WorldCoordinate) -> BIMCoordinate
}
```

### 2.4 Level of Detail (LOD) System

```swift
// Dynamic LOD based on distance and viewing angle
enum GeometryLOD {
    case lod400  // Full detail (0-5m): All components, textures
    case lod300  // Medium detail (5-20m): Simplified geometry
    case lod200  // Low detail (20-50m): Bounding boxes, major components
    case lod100  // Minimal (50m+): Wireframe, building outline
}

class LODManager {
    func updateLOD(for entities: [ModelEntity],
                   viewerPosition: SIMD3<Float>,
                   viewerDirection: SIMD3<Float>) {
        // Calculate distance and angle
        // Adjust geometry complexity
        // Stream textures as needed
        // Maintain 90 FPS target
    }
}
```

---

## 3. Data Models and Schemas

### 3.1 Core Domain Models

```swift
// MARK: - Site and Project Models

@Observable
class Site: Identifiable, Codable {
    var id: UUID
    var name: String
    var address: Address
    var gpsCoordinates: CLLocationCoordinate2D
    var siteOrientation: Double  // Degrees from true north
    var boundary: [CLLocationCoordinate2D]
    var projects: [Project]
    var status: SiteStatus
    var startDate: Date
    var completionDate: Date?
    var metadata: SiteMetadata
}

@Observable
class Project: Identifiable, Codable {
    var id: UUID
    var name: String
    var projectType: ProjectType
    var bimModels: [BIMModel]
    var schedule: ConstructionSchedule
    var budget: Budget
    var team: ProjectTeam
    var safety: SafetyConfiguration
    var quality: QualityPlan
    var progress: ProgressTracking
}

// MARK: - BIM Model

@Observable
class BIMModel: Identifiable, Codable {
    var id: UUID
    var name: String
    var version: String
    var format: BIMFormat  // IFC, RVT, DWG
    var fileURL: URL
    var localCacheURL: URL?
    var elements: [BIMElement]
    var spatialTree: OctreeNode  // Spatial indexing
    var disciplines: [Discipline]
    var coordinationStatus: CoordinationStatus
    var lastSyncDate: Date
}

struct BIMElement: Identifiable, Codable {
    var id: String  // IFC GUID
    var ifcType: String  // IfcWall, IfcBeam, etc.
    var name: String
    var discipline: Discipline
    var geometry: GeometryReference
    var properties: [String: PropertyValue]
    var placement: Transform3D
    var status: ElementStatus
    var assignedTo: String?
    var completionDate: Date?
}

// MARK: - Progress Tracking

@Observable
class ProgressTracking: Codable {
    var overallCompletion: Double  // 0.0 - 1.0
    var elementProgress: [String: ElementProgress]  // Element ID -> Progress
    var phaseProgress: [ConstructionPhase: Double]
    var milestones: [Milestone]
    var history: [ProgressSnapshot]
    var aiPredictedCompletion: Date?
}

struct ElementProgress: Codable {
    var elementId: String
    var status: ElementStatus
    var percentComplete: Double
    var lastUpdated: Date
    var updatedBy: String
    var photos: [PhotoReference]
    var issues: [Issue]
    var verificationStatus: VerificationStatus
}

// MARK: - Safety Models

@Observable
class SafetyConfiguration: Codable {
    var dangerZones: [DangerZone]
    var safetyRules: [SafetyRule]
    var ppeRequirements: [PPERequirement]
    var emergencyProcedures: EmergencyPlan
    var incidentReports: [IncidentReport]
    var safetyScore: Double
}

struct DangerZone: Identifiable, Codable {
    var id: UUID
    var type: DangerType  // Fall hazard, crane zone, excavation
    var boundary: [SIMD3<Float>]  // 3D polygon
    var severity: SafetySeverity
    var activeTimeRange: DateInterval?
    var warningDistance: Float  // Meters
    var restrictions: [String]
    var responsibleParty: String
}

struct WorkerTracking: Codable {
    var workerId: String
    var trade: Trade
    var currentPosition: SIMD3<Float>
    var currentTask: Task?
    var safetyCompliance: SafetyCompliance
    var lastUpdate: Date
    var proximityAlerts: [ProximityAlert]
}

// MARK: - Collaboration Models

@Observable
class CollaborationSession: Identifiable, Codable {
    var id: UUID
    var sessionType: SessionType  // Coordination, inspection, safety briefing
    var participants: [Participant]
    var sharedAnnotations: [Annotation]
    var sharedViewState: ViewState
    var startTime: Date
    var endTime: Date?
    var recording: RecordingReference?
}

struct Annotation: Identifiable, Codable {
    var id: UUID
    var type: AnnotationType  // Issue, measurement, note, photo
    var position: SIMD3<Float>
    var content: AnnotationContent
    var author: String
    var timestamp: Date
    var status: AnnotationStatus
    var assignedTo: String?
}

// MARK: - Issue Management

@Observable
class Issue: Identifiable, Codable {
    var id: UUID
    var title: String
    var description: String
    var type: IssueType  // Quality, safety, coordination, design
    var priority: IssuePriority
    var status: IssueStatus
    var location: IssueLocation
    var photos: [PhotoReference]
    var assignedTo: String
    var reporter: String
    var createdDate: Date
    var dueDate: Date
    var resolvedDate: Date?
    var relatedElements: [String]  // BIM element IDs
    var costImpact: Double?
    var scheduleImpact: TimeInterval?
}

struct IssueLocation: Codable {
    var worldPosition: SIMD3<Float>
    var siteCoordinates: SiteCoordinate
    var bimElement: String?
    var floor: Int?
    var zone: String?
    var photos: [PhotoReference]
}
```

### 3.2 Supporting Models

```swift
// MARK: - Enumerations

enum ProjectType: String, Codable {
    case residential
    case commercial
    case industrial
    case infrastructure
    case renovation
}

enum Discipline: String, Codable {
    case architectural
    case structural
    case mechanical
    case electrical
    case plumbing
    case fireProtection
    case civilEngineering
}

enum ElementStatus: String, Codable {
    case notStarted
    case inProgress
    case completed
    case approved
    case rejected
    case onHold
}

enum DangerType: String, Codable {
    case fallHazard
    case craneOperatingZone
    case excavation
    case confinedSpace
    case heavyEquipment
    case electricalWork
    case hotWork
    case overhead
}

enum SafetySeverity: String, Codable, Comparable {
    case low
    case medium
    case high
    case critical

    static func < (lhs: SafetySeverity, rhs: SafetySeverity) -> Bool {
        let order: [SafetySeverity] = [.low, .medium, .high, .critical]
        return order.firstIndex(of: lhs)! < order.firstIndex(of: rhs)!
    }
}

// MARK: - Value Types

struct Transform3D: Codable {
    var position: SIMD3<Float>
    var rotation: simd_quatf
    var scale: SIMD3<Float>

    func toMatrix() -> float4x4 {
        // Convert to transformation matrix
    }
}

struct SiteCoordinate: Codable {
    var x: Double  // Easting
    var y: Double  // Northing
    var elevation: Double
    var coordinateSystem: String  // e.g., "EPSG:4326"
}

struct PhotoReference: Identifiable, Codable {
    var id: UUID
    var fileURL: URL
    var thumbnail: URL?
    var captureDate: Date
    var location: SIMD3<Float>?
    var direction: SIMD3<Float>?
    var metadata: PhotoMetadata
}
```

### 3.3 Data Persistence Strategy

```swift
// Three-tier storage strategy

// Tier 1: In-Memory Cache (Active Session)
class InMemoryCache {
    static let shared = InMemoryCache()
    private var activeModels: [UUID: BIMModel] = [:]
    private var visibleElements: Set<String> = []
    private var maxMemoryMB: Int = 2048
}

// Tier 2: Device Storage (SwiftData)
@Model
class PersistentProject {
    // SwiftData for offline access
    // Last 7 days of site data
    // Optimized queries for spatial data
}

// Tier 3: Cloud Storage (CloudKit/Custom Backend)
actor CloudSyncManager {
    func sync(site: Site) async throws
    func uploadProgress(_ progress: ProgressSnapshot) async throws
    func downloadBIMModel(_ id: UUID) async throws -> BIMModel
    func resolveConflicts(_ conflicts: [DataConflict]) async throws
}
```

---

## 4. Service Layer Architecture

### 4.1 Service Organization

```swift
// MARK: - Core Services

protocol ServiceProtocol {
    func initialize() async throws
    func shutdown() async throws
}

// Spatial Computing Services
class SpatialTrackingService: ServiceProtocol {
    func getCurrentDevicePose() -> Transform3D
    func trackHands() -> AsyncStream<HandTrackingData>
    func trackEyes() -> AsyncStream<EyeTrackingData>
    func trackWorldMapping() -> AsyncStream<ARMeshAnchor>
}

class SiteAnchoringService: ServiceProtocol {
    func establishSiteOrigin(gps: CLLocationCoordinate2D) async throws -> AnchorEntity
    func alignBIMModel(_ model: BIMModel, to anchor: AnchorEntity) async throws
    func placeFloorAnchors(for floors: [Int]) async throws
    func createCloudAnchor(at position: SIMD3<Float>) async throws -> WorldAnchor
}

// BIM Services
class BIMImportService: ServiceProtocol {
    func importIFC(from url: URL) async throws -> BIMModel
    func parseElements(_ model: BIMModel) async throws -> [BIMElement]
    func buildSpatialIndex(_ elements: [BIMElement]) async throws -> OctreeNode
    func extractProperties(_ element: BIMElement) async throws -> [String: PropertyValue]
}

class BIMRenderingService: ServiceProtocol {
    func generateRealityKitEntities(from model: BIMModel) async throws -> ModelEntity
    func applyLOD(_ entities: [ModelEntity], level: GeometryLOD) async throws
    func updateMaterials(_ entities: [ModelEntity], for status: ElementStatus)
    func generateCollisionShapes(for entities: [ModelEntity])
}

// Progress Tracking Services
class ProgressTrackingService: ServiceProtocol {
    func captureProgress(for elements: [String]) async throws -> [ElementProgress]
    func compareWithSchedule(_ progress: ProgressTracking) -> ScheduleVariance
    func generateProgressReport(for site: Site) async throws -> ProgressReport
    func aiPredictCompletion(based on: [ProgressSnapshot]) async throws -> Date
}

class AIVisionService: ServiceProtocol {
    func analyzePhoto(_ photo: PhotoReference) async throws -> ProgressAnalysis
    func detectCompletionStatus(_ photo: PhotoReference) async throws -> ElementStatus
    func identifyIssues(in photo: PhotoReference) async throws -> [Issue]
    func measureDimensions(in photo: PhotoReference) async throws -> [Measurement]
}

// Safety Services
class SafetyMonitoringService: ServiceProtocol {
    func monitorWorkerProximity() async throws -> AsyncStream<ProximityAlert>
    func detectDangerZoneViolations() async throws -> AsyncStream<SafetyViolation>
    func validatePPECompliance(for worker: WorkerTracking) async throws -> SafetyCompliance
    func predictHazards(based on: [WorkerTracking]) async throws -> [PredictedHazard]
}

class SafetyAlertService: ServiceProtocol {
    func sendImmediateAlert(_ alert: SafetyAlert) async throws
    func notifySupervisor(_ violation: SafetyViolation) async throws
    func broadcastEmergency(_ emergency: EmergencyAlert) async throws
    func logIncident(_ incident: IncidentReport) async throws
}

// Collaboration Services
class CollaborationService: ServiceProtocol {
    func createSession(_ type: SessionType) async throws -> CollaborationSession
    func joinSession(_ id: UUID) async throws
    func shareAnnotation(_ annotation: Annotation) async throws
    func syncViewState(_ state: ViewState) async throws
    func leaveSession() async throws
}

class MultiUserSyncService: ServiceProtocol {
    func syncParticipantPositions() async -> AsyncStream<[ParticipantPosition]>
    func shareGazeDirection() async throws
    func syncSharedEntities() async throws
    func resolveConflicts(_ conflicts: [SyncConflict]) async throws
}

// Integration Services
class ProcoreIntegrationService: ServiceProtocol {
    func syncProject(_ project: Project) async throws
    func uploadIssue(_ issue: Issue) async throws -> String  // External ID
    func downloadRFIs() async throws -> [RFI]
    func updateSchedule(_ schedule: ConstructionSchedule) async throws
}

class BIM360IntegrationService: ServiceProtocol {
    func downloadModel(_ modelId: String) async throws -> BIMModel
    func uploadProgress(_ progress: ProgressTracking) async throws
    func syncDocuments() async throws -> [Document]
}

class IoTSensorService: ServiceProtocol {
    func connectToSensors() async throws
    func readSensorData() async -> AsyncStream<SensorReading>
    func processSensorAlerts() async -> AsyncStream<SensorAlert>
}

// Data Services
class SyncService: ServiceProtocol {
    func syncToCloud() async throws
    func syncFromCloud() async throws -> [Update]
    func enableOfflineMode()
    func resumeOnlineMode() async throws
    var isSyncing: Bool { get }
}

class CacheService: ServiceProtocol {
    func cacheModel(_ model: BIMModel) async throws
    func getCachedModel(_ id: UUID) async throws -> BIMModel?
    func clearCache(olderThan days: Int) async throws
    func getCacheSize() async -> Int64
}
```

### 4.2 Service Communication Pattern

```swift
// Event-driven architecture with Combine/AsyncSequence

actor ServiceCoordinator {
    static let shared = ServiceCoordinator()

    private var services: [String: any ServiceProtocol] = [:]
    private let eventBus = EventBus()

    func register(_ service: any ServiceProtocol, for key: String) {
        services[key] = service
    }

    func initialize() async throws {
        for service in services.values {
            try await service.initialize()
        }
    }

    func publishEvent(_ event: ServiceEvent) {
        eventBus.publish(event)
    }

    func subscribe<T: ServiceEvent>(to eventType: T.Type) -> AsyncStream<T> {
        eventBus.subscribe(to: eventType)
    }
}

// Service events
protocol ServiceEvent {
    var timestamp: Date { get }
    var source: String { get }
}

struct ProgressUpdatedEvent: ServiceEvent {
    var timestamp: Date
    var source: String
    var elementId: String
    var newStatus: ElementStatus
}

struct SafetyAlertEvent: ServiceEvent {
    var timestamp: Date
    var source: String
    var alert: SafetyAlert
    var severity: SafetySeverity
}
```

---

## 5. RealityKit and ARKit Integration

### 5.1 RealityKit Entity Component System

```swift
// Custom ECS components for construction

// Progress visualization component
struct ProgressComponent: Component {
    var status: ElementStatus
    var percentComplete: Double
    var highlightColor: UIColor
    var animationState: AnimationState
}

// Safety zone component
struct SafetyZoneComponent: Component {
    var zoneType: DangerType
    var severity: SafetySeverity
    var isActive: Bool
    var warningDistance: Float
    var visualEffect: SafetyVisualizationEffect
}

// Interactive element component
struct InteractiveElementComponent: Component {
    var canSelect: Bool
    var canMeasure: Bool
    var canAnnotate: Bool
    var onTap: ((Entity) -> Void)?
    var onHover: ((Entity, Bool) -> Void)?
}

// BIM metadata component
struct BIMMetadataComponent: Component {
    var ifcGuid: String
    var ifcType: String
    var discipline: Discipline
    var properties: [String: PropertyValue]
    var relatedElements: [String]
}

// LOD component
struct LODComponent: Component {
    var currentLOD: GeometryLOD
    var availableLODs: [GeometryLOD: ModelEntity]
    var switchDistance: [GeometryLOD: Float]
}

// Systems for processing components
class ProgressVisualizationSystem: System {
    func update(context: SceneUpdateContext) {
        // Update progress visualization based on status
        // Animate transitions between states
        // Update colors and materials
    }
}

class SafetyMonitoringSystem: System {
    func update(context: SceneUpdateContext) {
        // Check worker proximity to safety zones
        // Trigger alerts when violations detected
        // Update zone visualizations
    }
}

class LODManagementSystem: System {
    func update(context: SceneUpdateContext) {
        // Calculate distance from camera to entities
        // Switch LOD levels based on distance
        // Manage memory and performance
    }
}

class InteractionSystem: System {
    func update(context: SceneUpdateContext) {
        // Process gaze, gesture, and hand tracking
        // Highlight hovered elements
        // Handle selection and manipulation
    }
}
```

### 5.2 ARKit World Tracking

```swift
class ARWorldTrackingManager {
    private let arSession: ARKitSession
    private let worldTracking: WorldTrackingProvider
    private let planeDetection: PlaneDetectionProvider
    private let sceneReconstruction: SceneReconstructionProvider

    func startTracking() async throws {
        // Configure ARKit providers
        let configuration = ARKitSession.Configuration(
            worldTracking: WorldTrackingProvider.Configuration(
                userProvidedWorldOrigin: siteGPSOrigin
            ),
            planeDetection: PlaneDetectionProvider.Configuration(
                alignments: [.horizontal, .vertical]
            ),
            sceneReconstruction: SceneReconstructionProvider.Configuration(
                voxelSize: 0.01  // 1cm precision
            )
        )

        try await arSession.run([worldTracking, planeDetection, sceneReconstruction])

        // Process world tracking updates
        Task {
            for await update in worldTracking.anchorUpdates {
                handleAnchorUpdate(update)
            }
        }

        // Process scene mesh
        Task {
            for await update in sceneReconstruction.anchorUpdates {
                handleMeshUpdate(update)
            }
        }
    }

    func alignToSiteCoordinates(gps: CLLocationCoordinate2D,
                                 altitude: Double,
                                 orientation: Double) {
        // Convert GPS to local world coordinates
        // Apply site orientation offset
        // Create transformation matrix
    }
}
```

### 5.3 Hand and Eye Tracking

```swift
class HandGestureRecognizer {
    private let handTracking: HandTrackingProvider

    func recognizeGestures() -> AsyncStream<ConstructionGesture> {
        AsyncStream { continuation in
            Task {
                for await update in handTracking.anchorUpdates {
                    if let gesture = detectConstructionGesture(update) {
                        continuation.yield(gesture)
                    }
                }
            }
        }
    }

    private func detectConstructionGesture(_ update: HandAnchor.Update) -> ConstructionGesture? {
        // Measure: Two-finger pinch with extension
        // Annotate: Point gesture held
        // Approve: Thumbs up
        // Flag Issue: X gesture
        // Zoom: Pinch/spread
    }
}

class EyeTrackingService {
    private let eyeTracking: EyeTrackingProvider

    func trackFocus() -> AsyncStream<SIMD3<Float>> {
        AsyncStream { continuation in
            Task {
                for await update in eyeTracking.anchorUpdates {
                    let focusPoint = calculateFocusPoint(update)
                    continuation.yield(focusPoint)
                }
            }
        }
    }

    func detectIntentions() -> AsyncStream<UserIntention> {
        // Analyze gaze patterns to predict user intentions
        // Pre-load documentation for focused elements
        // Prepare context menus
    }
}
```

---

## 6. API Design and External Integrations

### 6.1 REST API Structure

```swift
// Base API client
class APIClient {
    private let baseURL: URL
    private let session: URLSession
    private let authenticator: AuthenticationManager

    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        var request = URLRequest(url: endpoint.url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Add authentication
        request = try await authenticator.authenticate(request)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }

        return try JSONDecoder().decode(T.self, from: data)
    }
}

// Endpoint definitions
enum Endpoint {
    case getSite(id: UUID)
    case updateProgress(siteId: UUID, progress: ProgressTracking)
    case uploadIssue(siteId: UUID, issue: Issue)
    case downloadBIMModel(modelId: UUID)
    case syncSafetyAlerts(siteId: UUID)

    var url: URL { /* construct URL */ }
    var method: HTTPMethod { /* return method */ }
}

// Integration protocols
protocol ProjectManagementIntegration {
    func authenticate(credentials: Credentials) async throws
    func syncProject(_ project: Project) async throws
    func uploadIssue(_ issue: Issue) async throws -> String
    func downloadUpdates(since date: Date) async throws -> [Update]
}

protocol BIMIntegration {
    func authenticate(credentials: Credentials) async throws
    func listModels(projectId: String) async throws -> [BIMModelMetadata]
    func downloadModel(modelId: String) async throws -> URL
    func uploadProgress(modelId: String, progress: ProgressTracking) async throws
}
```

### 6.2 Integration Implementations

```swift
// Procore integration
class ProcoreAdapter: ProjectManagementIntegration {
    func syncProject(_ project: Project) async throws {
        // Map internal model to Procore API
        // Handle field mappings
        // Sync bidirectionally
    }
}

// BIM 360 integration
class BIM360Adapter: BIMIntegration {
    func downloadModel(modelId: String) async throws -> URL {
        // OAuth authentication
        // Download IFC file
        // Cache locally
        // Return local URL
    }
}

// IoT sensor integration
class IoTGateway {
    func connectToMQTT(broker: String, port: Int) async throws {
        // MQTT connection for IoT sensors
        // Subscribe to relevant topics
        // Process sensor data
    }

    func processSensorData(_ data: Data) -> SensorReading {
        // Parse sensor payload
        // Convert to internal format
        // Trigger alerts if needed
    }
}
```

---

## 7. State Management Strategy

### 7.1 Observable Architecture

```swift
// App-wide state container
@Observable
class AppState {
    // Current context
    var currentSite: Site?
    var currentProject: Project?
    var activeSession: CollaborationSession?

    // User state
    var currentUser: User
    var userRole: UserRole
    var permissions: Set<Permission>

    // View state
    var presentationMode: PresentationMode = .window
    var selectedElements: Set<String> = []
    var activeFilters: [Filter] = []
    var viewSettings: ViewSettings

    // Spatial state
    var devicePose: Transform3D?
    var siteAnchor: AnchorEntity?
    var visibleArea: BoundingBox?

    // Sync state
    var isSyncing: Bool = false
    var lastSyncDate: Date?
    var pendingUploads: Int = 0
    var isOffline: Bool = false
}

// Feature-specific stores
@Observable
class ProgressStore {
    var tracking: ProgressTracking?
    var recentUpdates: [ProgressSnapshot] = []
    var aiPredictions: AIProgressPrediction?

    func updateElementStatus(_ elementId: String, status: ElementStatus) async {
        // Update progress
        // Notify observers
        // Sync to cloud
    }
}

@Observable
class SafetyStore {
    var activeAlerts: [SafetyAlert] = []
    var dangerZones: [DangerZone] = []
    var workerTracking: [WorkerTracking] = []
    var complianceScore: Double = 1.0

    func addAlert(_ alert: SafetyAlert) {
        // Add to active alerts
        // Notify relevant parties
        // Log for compliance
    }
}

@Observable
class IssueStore {
    var openIssues: [Issue] = []
    var myIssues: [Issue] = []
    var recentlyResolved: [Issue] = []

    func createIssue(_ issue: Issue) async throws {
        // Save locally
        // Upload to server
        // Notify assigned person
    }
}
```

### 7.2 Data Flow Architecture

```
User Interaction
      ↓
   View Layer (SwiftUI)
      ↓
   ViewModel / Store (@Observable)
      ↓
   Service Layer
      ↓
   ┌──────────┬──────────┬──────────┐
   ↓          ↓          ↓          ↓
Local Cache  SwiftData  API Client Cloud Sync
   ↓          ↓          ↓          ↓
   └──────────┴──────────┴──────────┘
              ↓
        Data Model Updates
              ↓
        Observer Notifications
              ↓
        View Re-render
```

---

## 8. Performance Optimization Strategy

### 8.1 Rendering Optimization

```swift
class RenderingOptimizer {
    // Frustum culling
    func cullOutOfView(entities: [ModelEntity],
                       camera: PerspectiveCamera) -> [ModelEntity] {
        entities.filter { entity in
            camera.frustum.contains(entity.visualBounds)
        }
    }

    // Occlusion culling
    func cullOccluded(entities: [ModelEntity],
                      sceneDepth: DepthTexture) -> [ModelEntity] {
        // Use scene depth to cull occluded objects
    }

    // Draw call batching
    func batchSimilarEntities(_ entities: [ModelEntity]) -> [ModelEntity] {
        // Merge entities with same materials
        // Reduce draw calls
    }

    // Texture streaming
    func streamTextures(for entities: [ModelEntity],
                        priority: LODPriority) async {
        // Load high-res textures on demand
        // Unload distant textures
    }
}
```

### 8.2 Memory Management

```swift
class MemoryManager {
    private var memoryBudget: Int64 = 8_000_000_000  // 8 GB
    private var currentUsage: Int64 = 0

    func manageMemory() {
        // Monitor memory pressure
        // Unload distant or unused assets
        // Reduce LOD when needed
        // Clear caches strategically
    }

    func prioritizeAssets() -> [Asset: Priority] {
        // Visible elements: High priority
        // Soon-to-be-visible: Medium priority
        // Out of view: Low priority (can unload)
    }
}
```

### 8.3 Network Optimization

```swift
class NetworkOptimizer {
    // Differential sync
    func syncChangesOnly(_ site: Site) async throws {
        let changes = detectChanges(since: lastSyncDate)
        try await upload(changes)
    }

    // Progressive download
    func downloadBIMModel(_ id: UUID) async throws -> BIMModel {
        // Download metadata first
        // Stream geometry progressively
        // Load textures on demand
    }

    // Request coalescing
    func coalesceRequests(_ requests: [APIRequest]) -> [APIRequest] {
        // Combine similar requests
        // Batch where possible
        // Reduce API calls
    }
}
```

### 8.4 Target Performance Metrics

| Metric | Target | Critical Path |
|--------|--------|---------------|
| **Frame Rate** | 90 FPS sustained | RealityKit rendering |
| **Frame Time** | <11ms per frame | Entity updates, culling |
| **BIM Model Load** | <30 seconds (500MB) | IFC parsing, geometry conversion |
| **Memory Usage** | <6 GB active | Asset streaming, caching |
| **Sync Latency** | <2 seconds | Differential sync |
| **AR Tracking** | <20ms latency | ARKit processing |
| **Battery Life** | 8 hours continuous | Display brightness, processing |
| **Thermal** | No throttling | Asset complexity, rendering load |

---

## 9. Security Architecture

### 9.1 Security Layers

```swift
// Authentication
class AuthenticationManager {
    func authenticate(credentials: Credentials) async throws -> AuthToken {
        // OAuth 2.0 / SAML for enterprise SSO
        // Multi-factor authentication support
        // Biometric authentication (Face ID)
    }

    func refreshToken(_ token: AuthToken) async throws -> AuthToken {
        // Automatic token refresh
    }
}

// Authorization
class AuthorizationManager {
    func checkPermission(_ permission: Permission,
                         for user: User,
                         in context: SecurityContext) -> Bool {
        // Role-based access control (RBAC)
        // Site-specific permissions
        // Feature-level permissions
    }

    func filterData<T>(_ data: [T], for user: User) -> [T] {
        // Filter data based on user permissions
        // Ensure data isolation between contractors
    }
}

// Encryption
class EncryptionService {
    func encryptData(_ data: Data, key: SymmetricKey) throws -> Data {
        // AES-256 encryption for data at rest
    }

    func encryptTransport(_ request: URLRequest) throws -> URLRequest {
        // TLS 1.3 for data in transit
        // Certificate pinning for API calls
    }
}

// Audit trail
class AuditLogger {
    func log(event: AuditEvent) async {
        // Immutable audit logs
        // Track all data access and modifications
        // Compliance reporting
    }
}
```

### 9.2 Data Protection

```swift
// Geofencing
class GeofenceManager {
    func checkLocation() -> Bool {
        // Verify device is on authorized site
        // Disable data access outside geofence
        // Log location violations
    }
}

// Data classification
enum DataClassification {
    case publicCase internal
    case confidential
    case restricted
}

class DataProtectionManager {
    func classifyData(_ data: Any) -> DataClassification {
        // Automatic data classification
    }

    func applyProtection(to data: Data,
                         classification: DataClassification) -> ProtectedData {
        // Apply appropriate encryption
        // Set access controls
        // Enable audit logging
    }
}
```

### 9.3 Privacy Considerations

```swift
class PrivacyManager {
    // Worker tracking anonymization
    func anonymizeWorkerData(_ tracking: WorkerTracking) -> AnonymousTracking {
        // Remove personally identifiable information
        // Preserve safety-relevant data
        // Aggregate for analytics only
    }

    // Data retention policies
    func enforceRetention() async {
        // Delete old data per policy
        // Archive for compliance
        // User data deletion requests
    }

    // Privacy controls
    func applyPrivacySettings(_ settings: PrivacySettings) {
        // User-configurable privacy options
        // Transparency in data collection
        // Opt-in for non-essential tracking
    }
}
```

---

## 10. Scalability and Deployment

### 10.1 Scalability Approach

```swift
// Project size scalability
class ScalabilityManager {
    func optimizeForProjectSize(_ project: Project) -> OptimizationStrategy {
        switch project.estimatedComplexity {
        case .small:  // <10,000 elements
            return .fullLoadStrategy
        case .medium:  // 10,000 - 100,000 elements
            return .spatialPartitioningStrategy
        case .large:  // 100,000 - 1M elements
            return .progressiveLoadingStrategy
        case .megaproject:  // >1M elements
            return .cloudRenderingStrategy
        }
    }
}

// Multi-site support
actor SiteManager {
    private var sites: [UUID: Site] = [:]
    private var activeCache: [UUID: CachedSiteData] = [:]

    func switchSite(to siteId: UUID) async throws {
        // Unload current site
        // Load new site data
        // Update spatial anchors
        // Reconfigure services
    }

    func prefetchNearby sites() async {
        // Predictive caching for multi-site users
    }
}
```

### 10.2 Deployment Architecture

```
                    ┌─────────────────────┐
                    │   Global CDN        │
                    │   (BIM Files)       │
                    └─────────────────────┘
                              ↕
┌─────────────────────────────────────────────────────────┐
│                    Cloud Services                        │
│  ┌────────────┬────────────┬────────────┬────────────┐ │
│  │ API Gateway│  Auth      │  BIM       │  Analytics │ │
│  │            │  Service   │  Storage   │  Engine    │ │
│  └────────────┴────────────┴────────────┴────────────┘ │
└─────────────────────────────────────────────────────────┘
                              ↕
                    ┌─────────────────────┐
                    │   Edge Gateway      │
                    │   (Site Server)     │
                    └─────────────────────┘
                              ↕
          ┌───────────────────┴───────────────────┐
          ↕                   ↕                   ↕
    ┌──────────┐        ┌──────────┐        ┌──────────┐
    │ Vision   │        │ Vision   │        │ Vision   │
    │ Pro #1   │        │ Pro #2   │        │ Pro #N   │
    └──────────┘        └──────────┘        └──────────┘
```

### 10.3 Edge Computing

```swift
// Site edge server for low-latency operations
class EdgeServer {
    func handleRealTimeTracking() async {
        // Worker position tracking
        // Safety monitoring
        // Immediate alerts
        // Low latency (<50ms)
    }

    func cacheFrequentlyAccessed() async {
        // BIM models for active areas
        // Schedule data
        // Issue database
        // Photo cache
    }

    func syncWithCloud() async {
        // Batch uploads during off-peak
        // Differential sync
        // Conflict resolution
    }
}
```

---

## 11. Testing Strategy

### 11.1 Testing Pyramid

```swift
// Unit Tests (70%)
class BIMImportServiceTests: XCTestCase {
    func testIFCParsing() async throws {
        let service = BIMImportService()
        let model = try await service.importIFC(from: testFileURL)
        XCTAssertEqual(model.elements.count, expectedElementCount)
    }
}

// Integration Tests (20%)
class SafetyIntegrationTests: XCTestCase {
    func testProximityAlertFlow() async throws {
        let tracking = SafetyTrackingService()
        let alert = SafetyAlertService()

        // Simulate worker entering danger zone
        // Verify alert is triggered
        // Confirm notification sent
    }
}

// UI Tests (10%)
class SiteOverlayUITests: XCTestCase {
    func testAROverlayRendering() throws {
        let app = XCUIApplication()
        app.launch()

        // Navigate to AR view
        // Verify BIM model visible
        // Test interactions
    }
}

// Spatial Tests
class SpatialInteractionTests: XCTestCase {
    func testHandGestureRecognition() async throws {
        // Simulate hand tracking data
        // Verify gesture recognition
        // Confirm action triggered
    }
}

// Performance Tests
class PerformanceTests: XCTestCase {
    func testRenderingPerformance() {
        measure {
            // Render complex BIM model
            // Measure frame time
            // Verify 90 FPS target
        }
    }
}
```

---

## 12. Monitoring and Analytics

### 12.1 Telemetry

```swift
class TelemetryService {
    func trackPerformance() {
        // Frame rate
        // Memory usage
        // Network latency
        // Battery consumption
        // Thermal state
    }

    func trackUsage() {
        // Feature usage
        // Session duration
        // User flows
        // Error rates
        // Crash reports
    }

    func trackBusiness() {
        // Safety incidents prevented
        // Issues detected
        // Progress captured
        // ROI metrics
    }
}
```

### 12.2 Logging

```swift
class LoggingService {
    func log(_ message: String, level: LogLevel, category: LogCategory) {
        // Structured logging
        // Multiple log levels
        // Category-based filtering
        // Remote log aggregation
    }
}
```

---

## 13. Future Architecture Considerations

### 13.1 Planned Enhancements

1. **AI-Powered Scheduling**
   - Neural network for schedule optimization
   - Predictive delay detection
   - Resource allocation AI

2. **Drone Integration**
   - Autonomous progress capture
   - Aerial safety monitoring
   - Site mapping updates

3. **Robotics Coordination**
   - Construction robot interfaces
   - Autonomous equipment tracking
   - Collaborative human-robot workflows

4. **Digital Twin Handover**
   - Complete facility data transfer
   - FM system integration
   - Lifecycle management

### 13.2 Extensibility Points

```swift
// Plugin architecture for custom modules
protocol ConstructionPlugin {
    var id: String { get }
    var name: String { get }
    var version: String { get }

    func initialize(context: PluginContext) async throws
    func provideCustomViews() -> [CustomView]
    func handleCustomGestures() -> [GestureHandler]
}

class PluginManager {
    func registerPlugin(_ plugin: ConstructionPlugin) async throws
    func loadPlugins() async throws
}
```

---

## Appendices

### A. Technology Stack Summary

| Layer | Technology | Purpose |
|-------|------------|---------|
| **Platform** | visionOS 2.0+ | Spatial computing foundation |
| **Language** | Swift 6.0+ | Modern, safe, concurrent |
| **UI** | SwiftUI | Declarative UI framework |
| **3D** | RealityKit | 3D rendering and ECS |
| **AR** | ARKit | World tracking, spatial understanding |
| **Persistence** | SwiftData | Local database |
| **Networking** | URLSession, WebSockets | API communication, real-time sync |
| **Async** | Swift Concurrency | async/await, actors |
| **Testing** | XCTest | Unit and integration testing |

### B. Key Performance Indicators

- **90 FPS**: Sustained frame rate for all spatial interactions
- **<30s**: BIM model loading for 500MB files
- **<20ms**: AR tracking latency
- **8 hours**: Battery life for continuous field use
- **±5mm**: Spatial tracking accuracy
- **99.9%**: Service uptime

### C. Dependencies and Third-Party Libraries

| Library | Purpose | License |
|---------|---------|---------|
| **Reality Composer Pro** | 3D content creation | Apple |
| **IFC.swift** | IFC file parsing | MIT |
| **SwiftProtobuf** | Efficient data serialization | Apache 2.0 |
| **MQTTNIO** | IoT sensor communication | Apache 2.0 |

---

## Document Version History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 1.0 | 2025-01-20 | Initial architecture document | Claude |

---

**End of Architecture Document**
