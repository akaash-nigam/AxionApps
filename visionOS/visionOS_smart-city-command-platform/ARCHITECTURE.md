# Smart City Command Platform - Technical Architecture

## 1. System Architecture Overview

### 1.1 High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    visionOS Application Layer                    │
├─────────────────────────────────────────────────────────────────┤
│  WindowGroup          │  Volumes          │  ImmersiveSpace     │
│  ─────────────        │  ───────          │  ──────────────     │
│  • Operations         │  • 3D City        │  • Full City        │
│    Dashboard          │    Model          │    Immersion        │
│  • Analytics          │  • Infrastructure │  • Crisis           │
│    Panels             │    Layers         │    Management       │
│  • Controls           │  • Data Overlays  │  • Planning Mode    │
└─────────────────────────────────────────────────────────────────┘
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Presentation Layer (SwiftUI)                  │
├─────────────────────────────────────────────────────────────────┤
│  • Spatial UI Components    • Gesture Handlers                  │
│  • Glass Materials          • Eye/Hand Tracking                 │
│  • Ornaments & Toolbars     • Voice Commands                    │
└─────────────────────────────────────────────────────────────────┘
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│              ViewModel Layer (Business Logic)                    │
├─────────────────────────────────────────────────────────────────┤
│  @Observable Models with Swift Concurrency                       │
│  • CityOperationsViewModel  • EmergencyResponseViewModel        │
│  • InfrastructureViewModel  • AnalyticsViewModel                │
│  • TransportationViewModel  • PlanningViewModel                 │
└─────────────────────────────────────────────────────────────────┘
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                     Service Layer                                │
├─────────────────────────────────────────────────────────────────┤
│  • IoTDataService          • GISIntegrationService              │
│  • EmergencyDispatchService • TransportationService             │
│  • AnalyticsService        • AIIntelligenceService              │
│  • CitizenServicesAPI      • WeatherDataService                 │
└─────────────────────────────────────────────────────────────────┘
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                   Data & Persistence Layer                       │
├─────────────────────────────────────────────────────────────────┤
│  SwiftData Models:                                               │
│  • City Infrastructure     • Emergency Incidents                │
│  • Sensor Data (Time Series) • Citizen Requests                 │
│  • Analytics Cache         • Historical Data                    │
└─────────────────────────────────────────────────────────────────┘
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│              3D Rendering & Spatial Layer                        │
├─────────────────────────────────────────────────────────────────┤
│  RealityKit:                ARKit:                               │
│  • City 3D Models          • Spatial Tracking                    │
│  • Infrastructure Entities • Plane Detection                     │
│  • Particle Systems        • Scene Understanding                │
│  • Lighting & Materials    • Hand/Eye Tracking                  │
└─────────────────────────────────────────────────────────────────┘
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│              External Integrations & APIs                        │
├─────────────────────────────────────────────────────────────────┤
│  • IoT Sensor Networks (MQTT/HTTP)                              │
│  • GIS Systems (ArcGIS/QGIS)                                    │
│  • Emergency Services CAD                                        │
│  • Traffic Management (ATMS)                                     │
│  • Utility SCADA Systems                                         │
│  • Weather & Environmental APIs                                  │
│  • Social Media & Citizen Apps                                   │
│  • AI/ML Processing Services                                     │
└─────────────────────────────────────────────────────────────────┘
```

## 2. visionOS-Specific Architecture Patterns

### 2.1 Multi-Modal Presentation Strategy

#### WindowGroup - Primary Operations Interface
```swift
// Primary command center interface
WindowGroup("City Operations Center", id: "operations-center") {
    OperationsCenterView()
        .frame(minWidth: 1200, minHeight: 800)
}
.defaultSize(width: 1400, height: 900)
.windowStyle(.plain)

// Analytics and monitoring panels
WindowGroup("Analytics Dashboard", id: "analytics") {
    AnalyticsDashboardView()
}
.defaultSize(width: 800, height: 600)

// Department-specific control panels
WindowGroup("Emergency Services", id: "emergency") {
    EmergencyServicesView()
}
```

#### Volumes - 3D City Visualization
```swift
// Main 3D city model with infrastructure layers
WindowGroup("3D City Model", id: "city-model") {
    CityModelVolumeView()
        .frame(depth: 600)
}
.windowStyle(.volumetric)
.defaultSize(width: 1000, height: 800, depth: 600)

// Infrastructure layer visualization
WindowGroup("Infrastructure Systems", id: "infrastructure") {
    InfrastructureVolumeView()
}
.windowStyle(.volumetric)
```

#### ImmersiveSpace - Full Spatial Experiences
```swift
// Immersive city exploration and crisis management
ImmersiveSpace(id: "city-immersive") {
    CityImmersiveView()
}
.immersionStyle(selection: $immersionLevel, in: .progressive)

// Planning and simulation mode
ImmersiveSpace(id: "planning-mode") {
    UrbanPlanningImmersiveView()
}
.immersionStyle(selection: .constant(.full), in: .full)
```

### 2.2 Spatial Zones Architecture

```
Emergency Command Zone (0.5m - 1m from user)
├── Critical Alerts (Red pulse indicators)
├── Emergency Dispatch Controls
├── One-tap Response Actions
└── Resource Deployment Interface

Operations Zone (1m - 2m from user)
├── Department Status Panels
├── Resource Management
├── Real-time Analytics
├── Communication Hub
└── Citizen Services Queue

Strategic Zone (2m - 5m from user)
├── 3D City Overview
├── Long-term Planning Tools
├── Predictive Models
├── What-if Scenarios
└── Policy Dashboard

Ambient Zone (Beyond 5m)
├── Contextual City Data
├── Environmental Sensors
├── Background Monitoring
└── Historical Trends
```

## 3. Data Models and Schemas

### 3.1 Core Domain Models

```swift
import SwiftData
import Foundation
import CoreLocation

// MARK: - City Infrastructure

@Model
final class City {
    @Attribute(.unique) var id: UUID
    var name: String
    var population: Int
    var area: Double // sq km
    var boundaries: [CLLocationCoordinate2D]
    var centerCoordinate: CLLocationCoordinate2D

    @Relationship(deleteRule: .cascade) var districts: [District]
    @Relationship(deleteRule: .cascade) var infrastructure: [Infrastructure]
    @Relationship(deleteRule: .cascade) var sensors: [IoTSensor]

    var lastUpdated: Date
    var metadata: [String: String]

    init(name: String, population: Int, area: Double, centerCoordinate: CLLocationCoordinate2D) {
        self.id = UUID()
        self.name = name
        self.population = population
        self.area = area
        self.centerCoordinate = centerCoordinate
        self.lastUpdated = Date()
        self.districts = []
        self.infrastructure = []
        self.sensors = []
        self.boundaries = []
        self.metadata = [:]
    }
}

@Model
final class District {
    @Attribute(.unique) var id: UUID
    var name: String
    var type: DistrictType
    var boundaries: [CLLocationCoordinate2D]
    var population: Int
    var area: Double

    @Relationship var city: City?
    @Relationship(deleteRule: .cascade) var buildings: [Building]

    init(name: String, type: DistrictType, population: Int, area: Double) {
        self.id = UUID()
        self.name = name
        self.type = type
        self.population = population
        self.area = area
        self.boundaries = []
        self.buildings = []
    }
}

enum DistrictType: String, Codable {
    case residential, commercial, industrial, mixed, government, park
}

@Model
final class Building {
    @Attribute(.unique) var id: UUID
    var name: String?
    var address: String
    var location: CLLocationCoordinate2D
    var height: Double // meters
    var floors: Int
    var type: BuildingType
    var occupancy: Int

    @Relationship var district: District?
    @Relationship(deleteRule: .cascade) var utilities: [UtilityConnection]

    var model3DAsset: String? // Reference to USDZ model

    init(address: String, location: CLLocationCoordinate2D, height: Double, type: BuildingType) {
        self.id = UUID()
        self.address = address
        self.location = location
        self.height = height
        self.floors = Int(height / 3.5) // Estimate
        self.type = type
        self.occupancy = 0
        self.utilities = []
    }
}

enum BuildingType: String, Codable {
    case residential, commercial, industrial, government, hospital, school, emergency
}

// MARK: - Infrastructure Systems

@Model
final class Infrastructure {
    @Attribute(.unique) var id: UUID
    var name: String
    var type: InfrastructureType
    var status: OperationalStatus
    var health: Double // 0-100%
    var capacity: Double
    var currentLoad: Double

    @Relationship var city: City?
    @Relationship(deleteRule: .cascade) var components: [InfrastructureComponent]
    @Relationship(deleteRule: .cascade) var sensors: [IoTSensor]

    var lastMaintenance: Date
    var nextMaintenance: Date
    var criticality: CriticalityLevel

    init(name: String, type: InfrastructureType, capacity: Double, criticality: CriticalityLevel) {
        self.id = UUID()
        self.name = name
        self.type = type
        self.status = .operational
        self.health = 100.0
        self.capacity = capacity
        self.currentLoad = 0
        self.components = []
        self.sensors = []
        self.lastMaintenance = Date()
        self.nextMaintenance = Calendar.current.date(byAdding: .month, value: 6, to: Date()) ?? Date()
        self.criticality = criticality
    }
}

enum InfrastructureType: String, Codable {
    case water, power, gas, telecommunications, sewage, stormwater, roads, bridges, tunnels
}

enum OperationalStatus: String, Codable {
    case operational, degraded, maintenance, failure, emergency

    var color: String {
        switch self {
        case .operational: return "green"
        case .degraded: return "yellow"
        case .maintenance: return "blue"
        case .failure: return "red"
        case .emergency: return "red"
        }
    }
}

enum CriticalityLevel: String, Codable {
    case low, medium, high, critical
}

@Model
final class InfrastructureComponent {
    @Attribute(.unique) var id: UUID
    var name: String
    var componentType: String
    var location: CLLocationCoordinate2D
    var status: OperationalStatus
    var installDate: Date
    var lifespan: Int // years

    @Relationship var infrastructure: Infrastructure?

    var needsReplacement: Bool {
        let age = Calendar.current.dateComponents([.year], from: installDate, to: Date()).year ?? 0
        return age >= lifespan
    }
}

// MARK: - IoT Sensors

@Model
final class IoTSensor {
    @Attribute(.unique) var id: UUID
    var sensorId: String
    var type: SensorType
    var location: CLLocationCoordinate2D
    var status: SensorStatus

    @Relationship var city: City?
    @Relationship var infrastructure: Infrastructure?
    @Relationship(deleteRule: .cascade) var readings: [SensorReading]

    var lastReading: Date?
    var batteryLevel: Double? // 0-100%

    init(sensorId: String, type: SensorType, location: CLLocationCoordinate2D) {
        self.id = UUID()
        self.sensorId = sensorId
        self.type = type
        self.location = location
        self.status = .active
        self.readings = []
    }
}

enum SensorType: String, Codable {
    case temperature, humidity, airQuality, noise, traffic, flood, seismic, camera, pressure, flow
}

enum SensorStatus: String, Codable {
    case active, inactive, maintenance, error
}

@Model
final class SensorReading {
    @Attribute(.unique) var id: UUID
    var timestamp: Date
    var value: Double
    var unit: String
    var quality: DataQuality

    @Relationship var sensor: IoTSensor?

    init(value: Double, unit: String, timestamp: Date = Date()) {
        self.id = UUID()
        self.value = value
        self.unit = unit
        self.timestamp = timestamp
        self.quality = .good
    }
}

enum DataQuality: String, Codable {
    case good, fair, poor, invalid
}

// MARK: - Emergency & Incidents

@Model
final class EmergencyIncident {
    @Attribute(.unique) var id: UUID
    var incidentNumber: String
    var type: IncidentType
    var severity: IncidentSeverity
    var status: IncidentStatus

    var location: CLLocationCoordinate2D
    var address: String
    var description: String

    var reportedAt: Date
    var dispatchedAt: Date?
    var resolvedAt: Date?

    @Relationship(deleteRule: .cascade) var responses: [EmergencyResponse]
    @Relationship(deleteRule: .cascade) var updates: [IncidentUpdate]

    var affectedCitizens: Int
    var estimatedImpact: String

    init(type: IncidentType, severity: IncidentSeverity, location: CLLocationCoordinate2D, description: String) {
        self.id = UUID()
        self.incidentNumber = "INC-\(Int(Date().timeIntervalSince1970))"
        self.type = type
        self.severity = severity
        self.status = .reported
        self.location = location
        self.address = ""
        self.description = description
        self.reportedAt = Date()
        self.responses = []
        self.updates = []
        self.affectedCitizens = 0
        self.estimatedImpact = ""
    }
}

enum IncidentType: String, Codable {
    case fire, medical, crime, accident, infrastructure, natural, hazmat, civil
}

enum IncidentSeverity: String, Codable {
    case low, medium, high, critical, catastrophic
}

enum IncidentStatus: String, Codable {
    case reported, dispatched, responding, onScene, contained, resolved, closed
}

@Model
final class EmergencyResponse {
    @Attribute(.unique) var id: UUID
    var unitId: String
    var unitType: EmergencyUnitType
    var status: ResponseStatus

    var dispatchedAt: Date
    var arrivedAt: Date?
    var clearedAt: Date?

    var currentLocation: CLLocationCoordinate2D?
    var route: [CLLocationCoordinate2D]

    @Relationship var incident: EmergencyIncident?

    init(unitId: String, unitType: EmergencyUnitType) {
        self.id = UUID()
        self.unitId = unitId
        self.unitType = unitType
        self.status = .dispatched
        self.dispatchedAt = Date()
        self.route = []
    }
}

enum EmergencyUnitType: String, Codable {
    case fire, police, ambulance, hazmat, rescue, utility
}

enum ResponseStatus: String, Codable {
    case dispatched, enRoute, onScene, returning, available
}

// MARK: - Transportation

@Model
final class TransportationAsset {
    @Attribute(.unique) var id: UUID
    var assetId: String
    var type: TransportAssetType
    var route: String?

    var currentLocation: CLLocationCoordinate2D?
    var heading: Double
    var speed: Double // km/h
    var capacity: Int
    var occupancy: Int

    var status: AssetStatus
    var lastUpdated: Date

    init(assetId: String, type: TransportAssetType, capacity: Int) {
        self.id = UUID()
        self.assetId = assetId
        self.type = type
        self.capacity = capacity
        self.occupancy = 0
        self.status = .active
        self.heading = 0
        self.speed = 0
        self.lastUpdated = Date()
    }
}

enum TransportAssetType: String, Codable {
    case bus, metro, tram, ferry, bikeshare, scooter
}

enum AssetStatus: String, Codable {
    case active, idle, maintenance, outOfService
}

// MARK: - Citizen Services

@Model
final class CitizenRequest {
    @Attribute(.unique) var id: UUID
    var requestNumber: String
    var type: RequestType
    var category: String
    var priority: RequestPriority
    var status: RequestStatus

    var description: String
    var location: CLLocationCoordinate2D?
    var address: String?

    var submittedAt: Date
    var assignedAt: Date?
    var completedAt: Date?

    var assignedDepartment: String?
    var assignedStaff: String?

    @Relationship(deleteRule: .cascade) var updates: [RequestUpdate]

    init(type: RequestType, category: String, description: String, priority: RequestPriority) {
        self.id = UUID()
        self.requestNumber = "REQ-\(Int(Date().timeIntervalSince1970))"
        self.type = type
        self.category = category
        self.priority = priority
        self.status = .submitted
        self.description = description
        self.submittedAt = Date()
        self.updates = []
    }
}

enum RequestType: String, Codable {
    case complaint, request, inquiry, report, permit
}

enum RequestPriority: String, Codable {
    case low, normal, high, urgent
}

enum RequestStatus: String, Codable {
    case submitted, assigned, inProgress, resolved, closed
}

@Model
final class RequestUpdate {
    @Attribute(.unique) var id: UUID
    var timestamp: Date
    var message: String
    var updatedBy: String

    @Relationship var request: CitizenRequest?

    init(message: String, updatedBy: String) {
        self.id = UUID()
        self.timestamp = Date()
        self.message = message
        self.updatedBy = updatedBy
    }
}

@Model
final class IncidentUpdate {
    @Attribute(.unique) var id: UUID
    var timestamp: Date
    var message: String
    var updatedBy: String

    @Relationship var incident: EmergencyIncident?

    init(message: String, updatedBy: String) {
        self.id = UUID()
        self.timestamp = Date()
        self.message = message
        self.updatedBy = updatedBy
    }
}

// MARK: - Analytics Models

@Model
final class AnalyticsSnapshot {
    @Attribute(.unique) var id: UUID
    var timestamp: Date
    var metricType: String
    var value: Double
    var metadata: [String: String]

    init(metricType: String, value: Double, metadata: [String: String] = [:]) {
        self.id = UUID()
        self.timestamp = Date()
        self.metricType = metricType
        self.value = value
        self.metadata = metadata
    }
}

@Model
final class UtilityConnection {
    @Attribute(.unique) var id: UUID
    var utilityType: InfrastructureType
    var serviceLevel: String
    var status: OperationalStatus

    @Relationship var building: Building?
}
```

### 3.2 ViewModel Observable Models

```swift
import Observation
import SwiftUI
import RealityKit

@Observable
final class CityOperationsViewModel {
    // State
    var selectedCity: City?
    var activeIncidents: [EmergencyIncident] = []
    var infrastructureAlerts: [Infrastructure] = []
    var sensorData: [IoTSensor] = []

    // UI State
    var isLoading = false
    var errorMessage: String?
    var selectedLayer: CityLayer = .all

    // Services
    private let iotService: IoTDataService
    private let emergencyService: EmergencyDispatchService
    private let analyticsService: AnalyticsService

    init(iotService: IoTDataService, emergencyService: EmergencyDispatchService, analyticsService: AnalyticsService) {
        self.iotService = iotService
        self.emergencyService = emergencyService
        self.analyticsService = analyticsService
    }

    func loadCityData() async throws {
        isLoading = true
        defer { isLoading = false }

        async let incidents = emergencyService.fetchActiveIncidents()
        async let infrastructure = iotService.fetchInfrastructureStatus()
        async let sensors = iotService.fetchSensorData()

        (activeIncidents, infrastructureAlerts, sensorData) = try await (incidents, infrastructure, sensors)
    }

    func dispatchEmergencyResponse(to incident: EmergencyIncident) async throws {
        try await emergencyService.dispatchUnits(for: incident)
    }
}

enum CityLayer: String, CaseIterable {
    case all, infrastructure, emergency, transportation, environment, buildings
}
```

## 4. Service Layer Architecture

### 4.1 Service Protocols

```swift
// MARK: - IoT Data Service

protocol IoTDataServiceProtocol {
    func fetchSensorData() async throws -> [IoTSensor]
    func fetchInfrastructureStatus() async throws -> [Infrastructure]
    func streamSensorReadings() -> AsyncStream<SensorReading>
    func updateSensorStatus(_ sensor: IoTSensor, status: SensorStatus) async throws
}

final class IoTDataService: IoTDataServiceProtocol {
    private let apiClient: APIClient
    private let cache: CacheService

    init(apiClient: APIClient, cache: CacheService) {
        self.apiClient = apiClient
        self.cache = cache
    }

    func streamSensorReadings() -> AsyncStream<SensorReading> {
        AsyncStream { continuation in
            Task {
                // MQTT or WebSocket connection
                for await reading in apiClient.streamData(endpoint: "/sensors/live") {
                    continuation.yield(reading)
                }
            }
        }
    }
}

// MARK: - Emergency Dispatch Service

protocol EmergencyDispatchServiceProtocol {
    func fetchActiveIncidents() async throws -> [EmergencyIncident]
    func dispatchUnits(for incident: EmergencyIncident) async throws
    func updateIncidentStatus(_ incident: EmergencyIncident, status: IncidentStatus) async throws
    func calculateOptimalRoute(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) async throws -> [CLLocationCoordinate2D]
}

final class EmergencyDispatchService: EmergencyDispatchServiceProtocol {
    private let apiClient: APIClient
    private let routingService: RoutingService

    func dispatchUnits(for incident: EmergencyIncident) async throws {
        // AI-powered unit selection and routing
        let optimalUnits = try await selectOptimalUnits(for: incident)
        let routes = try await calculateRoutes(units: optimalUnits, to: incident.location)

        // Dispatch via CAD integration
        try await apiClient.post("/emergency/dispatch", body: [
            "incident_id": incident.id.uuidString,
            "units": optimalUnits.map { $0.unitId },
            "routes": routes
        ])
    }
}

// MARK: - GIS Integration Service

protocol GISIntegrationServiceProtocol {
    func loadCityGeometry() async throws -> [Building]
    func geocode(address: String) async throws -> CLLocationCoordinate2D
    func reverseGeocode(coordinate: CLLocationCoordinate2D) async throws -> String
    func loadInfrastructureLayers() async throws -> [InfrastructureLayer]
}

// MARK: - Analytics Service

protocol AnalyticsServiceProtocol {
    func calculateCityMetrics() async throws -> CityMetrics
    func predictTrafficFlow(for date: Date) async throws -> TrafficPrediction
    func detectAnomalies() async throws -> [Anomaly]
    func generateReport(type: ReportType, period: DateInterval) async throws -> Report
}

// MARK: - AI Intelligence Service

protocol AIIntelligenceServiceProtocol {
    func predictIncident(type: IncidentType, in area: District) async throws -> PredictionResult
    func optimizeResourceAllocation() async throws -> ResourcePlan
    func analyzeTrafficPatterns() async throws -> TrafficAnalysis
    func recommendInfrastructureMaintenance() async throws -> [MaintenanceRecommendation]
}
```

## 5. RealityKit and ARKit Integration

### 5.1 3D City Rendering Architecture

```swift
import RealityKit
import ARKit

// MARK: - City Reality System

final class CityRealitySystem {
    let rootEntity: Entity
    private var buildingEntities: [UUID: ModelEntity] = [:]
    private var infrastructureEntities: [UUID: Entity] = [:]
    private var sensorMarkers: [UUID: Entity] = [:]

    init() {
        rootEntity = Entity()
        rootEntity.name = "CityRoot"
    }

    func loadCityModel(city: City) async throws {
        // Load base terrain/map
        let terrain = try await loadTerrain(for: city)
        rootEntity.addChild(terrain)

        // Load buildings
        for building in city.districts.flatMap({ $0.buildings }) {
            let entity = try await createBuildingEntity(building)
            buildingEntities[building.id] = entity
            rootEntity.addChild(entity)
        }

        // Load infrastructure layers
        for infrastructure in city.infrastructure {
            let entity = try await createInfrastructureEntity(infrastructure)
            infrastructureEntities[infrastructure.id] = entity
            rootEntity.addChild(entity)
        }
    }

    private func createBuildingEntity(_ building: Building) async throws -> ModelEntity {
        // Load 3D model or create procedural geometry
        let entity: ModelEntity

        if let assetName = building.model3DAsset {
            entity = try await ModelEntity.load(named: assetName)
        } else {
            // Procedural building
            entity = createProceduralBuilding(height: building.height, type: building.type)
        }

        // Position in world space
        let position = convertGeoToWorld(building.location)
        entity.position = position
        entity.name = building.address

        // Add interaction components
        entity.components.set(InputTargetComponent())
        entity.components.set(HoverEffectComponent())

        return entity
    }

    private func createProceduralBuilding(height: Float, type: BuildingType) -> ModelEntity {
        let mesh = MeshResource.generateBox(width: 20, height: height, depth: 20)
        var material = PhysicallyBasedMaterial()
        material.baseColor = .init(tint: colorForBuildingType(type))
        material.roughness = 0.8

        let entity = ModelEntity(mesh: mesh, materials: [material])
        return entity
    }

    private func createInfrastructureEntity(_ infrastructure: Infrastructure) async throws -> Entity {
        let container = Entity()
        container.name = infrastructure.name

        // Create visualization based on type
        switch infrastructure.type {
        case .water, .power, .gas:
            // Create network lines
            let network = createNetworkVisualization(infrastructure)
            container.addChild(network)

        case .roads:
            // Create road network
            let roads = createRoadNetwork(infrastructure)
            container.addChild(roads)

        default:
            break
        }

        // Add status indicators
        let statusLight = createStatusIndicator(status: infrastructure.status)
        container.addChild(statusLight)

        return container
    }

    func updateInfrastructureStatus(_ infrastructure: Infrastructure) {
        guard let entity = infrastructureEntities[infrastructure.id] else { return }

        // Update visual representation
        updateEntityStatus(entity, status: infrastructure.status)

        // Trigger alerts if needed
        if infrastructure.status == .failure || infrastructure.status == .emergency {
            highlightCriticalInfrastructure(entity)
        }
    }

    func showSensorData(_ sensors: [IoTSensor]) {
        // Clear existing markers
        sensorMarkers.values.forEach { $0.removeFromParent() }
        sensorMarkers.removeAll()

        // Create new markers
        for sensor in sensors {
            let marker = createSensorMarker(sensor)
            sensorMarkers[sensor.id] = marker
            rootEntity.addChild(marker)
        }
    }

    private func createSensorMarker(_ sensor: IoTSensor) -> Entity {
        let marker = Entity()

        // Visual indicator
        let mesh = MeshResource.generateSphere(radius: 2)
        var material = UnlitMaterial()
        material.color = .init(tint: colorForSensorType(sensor.type))

        let sphere = ModelEntity(mesh: mesh, materials: [material])
        marker.addChild(sphere)

        // Position
        marker.position = convertGeoToWorld(sensor.location)
        marker.name = sensor.sensorId

        // Add pulsing animation for active sensors
        if sensor.status == .active {
            addPulseAnimation(to: sphere)
        }

        return marker
    }

    private func convertGeoToWorld(_ coordinate: CLLocationCoordinate2D) -> SIMD3<Float> {
        // Convert lat/lon to local ENU coordinates
        // This would use the city center as origin
        // Simplified version - real implementation would use proper map projection
        let x = Float(coordinate.longitude * 100000)
        let z = Float(coordinate.latitude * 100000)
        return SIMD3(x, 0, z)
    }
}

// MARK: - Spatial Interactions

final class SpatialInteractionHandler {
    func handleEntityTap(_ entity: Entity) {
        // Determine entity type and show relevant info
        if let buildingEntity = entity as? ModelEntity {
            showBuildingDetails(for: buildingEntity)
        }
    }

    func handleEntityHover(_ entity: Entity) {
        // Show quick info on hover
        displayTooltip(for: entity)
    }
}
```

### 5.2 Hand Tracking Integration

```swift
import ARKit

final class HandTrackingManager {
    private let arKitSession = ARKitSession()
    private let handTracking = HandTrackingProvider()

    func startTracking() async throws {
        try await arKitSession.run([handTracking])
    }

    func processHandGestures() -> AsyncStream<CityGesture> {
        AsyncStream { continuation in
            Task {
                for await update in handTracking.anchorUpdates {
                    let gesture = detectCityGesture(from: update.anchor)
                    if let gesture {
                        continuation.yield(gesture)
                    }
                }
            }
        }
    }

    private func detectCityGesture(from anchor: HandAnchor) -> CityGesture? {
        // Detect custom city control gestures
        // - Point and tap: Deploy resource
        // - Double tap: Emergency response
        // - Pinch expand: Zoom area
        // - Palm glide: Navigate city
        // - Two points: Measure distance

        return nil // Implementation details
    }
}

enum CityGesture {
    case deployResource(location: SIMD3<Float>)
    case emergencyResponse(location: SIMD3<Float>)
    case zoomArea(center: SIMD3<Float>, scale: Float)
    case navigate(direction: SIMD3<Float>)
    case measure(start: SIMD3<Float>, end: SIMD3<Float>)
}
```

## 6. API Design and External Integrations

### 6.1 Network Layer Architecture

```swift
import Foundation

// MARK: - API Client

final class APIClient {
    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(baseURL: URL) {
        self.baseURL = baseURL
        self.session = URLSession.shared
        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()

        decoder.dateDecodingStrategy = .iso8601
        encoder.dateEncodingStrategy = .iso8601
    }

    func get<T: Decodable>(_ endpoint: String) async throws -> T {
        let url = baseURL.appendingPathComponent(endpoint)
        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }

        return try decoder.decode(T.self, from: data)
    }

    func post<T: Encodable, R: Decodable>(_ endpoint: String, body: T) async throws -> R {
        let url = baseURL.appendingPathComponent(endpoint)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try encoder.encode(body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }

        return try decoder.decode(R.self, from: data)
    }

    func streamData<T: Decodable>(endpoint: String) -> AsyncStream<T> {
        // WebSocket or Server-Sent Events implementation
        AsyncStream { continuation in
            // Implementation
        }
    }
}

enum APIError: Error {
    case invalidResponse
    case networkError(Error)
    case decodingError(Error)
}

// MARK: - Integration Endpoints

struct SmartCityEndpoints {
    static let iotSensors = "/api/v1/sensors"
    static let infrastructure = "/api/v1/infrastructure"
    static let emergencyCAD = "/api/v1/emergency/cad"
    static let traffic = "/api/v1/traffic"
    static let gis = "/api/v1/gis"
    static let weather = "/api/v1/weather"
    static let analytics = "/api/v1/analytics"
}
```

## 7. State Management Strategy

### 7.1 App-Wide State

```swift
import SwiftUI
import Observation

@Observable
final class AppState {
    // User session
    var currentUser: User?
    var userRole: UserRole = .operator

    // City selection
    var selectedCity: City?
    var cities: [City] = []

    // View state
    var activeWorkspace: Workspace = .operations
    var immersiveMode: ImmersionMode = .none

    // Real-time data streams
    var liveIncidents: [EmergencyIncident] = []
    var criticalAlerts: [Alert] = []

    // Connectivity
    var isConnected = true
    var lastSyncTime: Date?

    func switchCity(_ city: City) {
        selectedCity = city
        // Trigger data reload
    }
}

enum Workspace {
    case operations, emergency, planning, analytics
}

enum ImmersionMode {
    case none, partial, full
}

enum UserRole: String {
    case operator, supervisor, director, planner, emergency
}
```

## 8. Performance Optimization Strategy

### 8.1 3D Asset Optimization

- **Level of Detail (LOD)**: Multiple building models based on distance
- **Occlusion Culling**: Don't render hidden buildings
- **Instancing**: Reuse common building types
- **Texture Atlases**: Combine textures to reduce draw calls
- **Async Loading**: Load 3D assets progressively

### 8.2 Data Management

- **Streaming**: Load only visible city area
- **Caching**: Cache frequently accessed data
- **Delta Updates**: Only sync changes, not full datasets
- **Time-based Aggregation**: Roll up historical sensor data

### 8.3 Rendering Performance

- **Target**: 90 FPS for smooth experience
- **Metal Performance Shaders**: GPU-accelerated computations
- **Background Processing**: Offload heavy tasks from main thread
- **Lazy Loading**: Only render visible UI components

## 9. Security Architecture

### 9.1 Security Layers

```
┌─────────────────────────────────────────┐
│         Authentication Layer             │
├─────────────────────────────────────────┤
│  • Multi-factor Authentication           │
│  • Role-based Access Control (RBAC)      │
│  • Session Management                    │
│  • Single Sign-On (SSO)                  │
└─────────────────────────────────────────┘
                  ▼
┌─────────────────────────────────────────┐
│         Authorization Layer              │
├─────────────────────────────────────────┤
│  • Department-level Permissions          │
│  • Data Access Controls                  │
│  • Feature Flags                         │
│  • Audit Logging                         │
└─────────────────────────────────────────┘
                  ▼
┌─────────────────────────────────────────┐
│         Data Protection Layer            │
├─────────────────────────────────────────┤
│  • End-to-end Encryption                 │
│  • Data Anonymization                    │
│  • Secure Storage (Keychain)             │
│  • Certificate Pinning                   │
└─────────────────────────────────────────┘
                  ▼
┌─────────────────────────────────────────┐
│         Network Security Layer           │
├─────────────────────────────────────────┤
│  • TLS 1.3                               │
│  • VPN Support                           │
│  • Intrusion Detection                   │
│  • Rate Limiting                         │
└─────────────────────────────────────────┘
```

### 9.2 Privacy Protection

- **Citizen Data Anonymization**: Remove PII from visualizations
- **Consent Management**: Track and enforce data usage permissions
- **Data Minimization**: Collect only necessary information
- **Audit Trails**: Log all data access and modifications
- **Transparency Reports**: Generate public accountability reports

## 10. Scalability & Deployment Architecture

### 10.1 Deployment Models

**On-Premise Deployment**
- City data center hosted
- Complete data sovereignty
- Custom security policies

**Hybrid Cloud**
- Local processing for sensitive data
- Cloud analytics and AI processing
- Edge computing for IoT

**Multi-Region**
- Distributed city networks
- Regional coordination
- Disaster recovery

### 10.2 Scaling Strategy

- **Horizontal Scaling**: Add more API servers
- **Data Partitioning**: Shard by district/department
- **Edge Computing**: Process IoT data locally
- **CDN**: Distribute 3D assets globally
- **Load Balancing**: Distribute user connections

---

This architecture provides a comprehensive foundation for building the Smart City Command Platform with enterprise-grade scalability, security, and performance.
