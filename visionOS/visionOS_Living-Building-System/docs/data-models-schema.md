# Data Models & Schema Design
## Living Building System

**Version**: 1.0
**Last Updated**: 2025-11-24
**Status**: Draft

---

## 1. Overview

This document defines all data models, relationships, and storage schemas for the Living Building System. The application uses SwiftData for local persistence, with support for iCloud synchronization where appropriate.

## 2. Data Architecture Principles

1. **Type Safety**: Leverage Swift's type system for compile-time safety
2. **Immutability**: Use value types (structs) where possible
3. **Relationships**: Clear parent-child and association relationships
4. **Versioning**: Support schema migration for app updates
5. **Privacy**: Sensitive data encrypted at rest
6. **Performance**: Indexed queries for real-time lookup

## 3. Core Domain Models

### 3.1 Home & Space Models

#### Home
```swift
@Model
final class Home {
    @Attribute(.unique) var id: UUID
    var name: String
    var address: String?
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \Room.home)
    var rooms: [Room]

    @Relationship(deleteRule: .cascade, inverse: \User.home)
    var users: [User]

    @Relationship(deleteRule: .cascade)
    var energyConfiguration: EnergyConfiguration?

    var timezone: TimeZone
    var squareFootage: Double?

    init(name: String, address: String? = nil) {
        self.id = UUID()
        self.name = name
        self.address = address
        self.createdAt = Date()
        self.updatedAt = Date()
        self.timezone = .current
        self.rooms = []
        self.users = []
    }
}
```

#### Room
```swift
@Model
final class Room {
    @Attribute(.unique) var id: UUID
    var name: String
    var roomType: RoomType
    var floorLevel: Int
    var squareFootage: Double?

    @Relationship(deleteRule: .nullify, inverse: \Home.rooms)
    var home: Home?

    @Relationship(deleteRule: .cascade, inverse: \SmartDevice.room)
    var devices: [SmartDevice]

    @Relationship(deleteRule: .cascade, inverse: \RoomAnchor.room)
    var anchors: [RoomAnchor]

    @Relationship(deleteRule: .cascade)
    var displayConfiguration: DisplayConfiguration?

    @Relationship(deleteRule: .cascade, inverse: \EnvironmentReading.room)
    var environmentReadings: [EnvironmentReading]

    var createdAt: Date
    var updatedAt: Date

    init(name: String, roomType: RoomType, floorLevel: Int = 0) {
        self.id = UUID()
        self.name = name
        self.roomType = roomType
        self.floorLevel = floorLevel
        self.createdAt = Date()
        self.updatedAt = Date()
        self.devices = []
        self.anchors = []
        self.environmentReadings = []
    }
}

enum RoomType: String, Codable {
    case kitchen
    case livingRoom
    case bedroom
    case bathroom
    case office
    case entryway
    case hallway
    case garage
    case basement
    case attic
    case laundryRoom
    case diningRoom
    case other
}
```

#### RoomAnchor
```swift
@Model
final class RoomAnchor {
    @Attribute(.unique) var id: UUID
    var anchorType: AnchorType

    // Spatial coordinates (stored as Data for SIMD3<Float>)
    @Attribute var positionData: Data
    @Attribute var rotationData: Data // Quaternion

    var persistentIdentifier: UUID? // ARKit persistent anchor ID
    var createdAt: Date

    @Relationship(deleteRule: .nullify, inverse: \Room.anchors)
    var room: Room?

    init(anchorType: AnchorType, position: SIMD3<Float>, rotation: simd_quatf) {
        self.id = UUID()
        self.anchorType = anchorType
        self.positionData = Self.encode(position)
        self.rotationData = Self.encode(rotation)
        self.createdAt = Date()
    }

    var position: SIMD3<Float> {
        get { Self.decodePosition(positionData) }
        set { positionData = Self.encode(newValue) }
    }

    var rotation: simd_quatf {
        get { Self.decodeRotation(rotationData) }
        set { rotationData = Self.encode(newValue) }
    }

    private static func encode<T>(_ value: T) -> Data {
        withUnsafeBytes(of: value) { Data($0) }
    }

    private static func decodePosition(_ data: Data) -> SIMD3<Float> {
        data.withUnsafeBytes { $0.load(as: SIMD3<Float>.self) }
    }

    private static func decodeRotation(_ data: Data) -> simd_quatf {
        data.withUnsafeBytes { $0.load(as: simd_quatf.self) }
    }
}

enum AnchorType: String, Codable {
    case wallDisplay
    case floorMarker
    case deviceLocation
    case roomCenter
}
```

### 3.2 User Models

#### User
```swift
@Model
final class User {
    @Attribute(.unique) var id: UUID
    var name: String
    var faceIDData: Data? // Encrypted Face ID template
    var avatarImage: Data?
    var role: UserRole
    var createdAt: Date

    @Relationship(deleteRule: .nullify, inverse: \Home.users)
    var home: Home?

    @Relationship(deleteRule: .cascade, inverse: \UserPreferences.user)
    var preferences: UserPreferences?

    init(name: String, role: UserRole = .member) {
        self.id = UUID()
        self.name = name
        self.role = role
        self.createdAt = Date()
    }
}

enum UserRole: String, Codable {
    case owner
    case admin
    case member
    case guest
}
```

#### UserPreferences
```swift
@Model
final class UserPreferences {
    @Attribute(.unique) var id: UUID

    @Relationship(deleteRule: .nullify, inverse: \User.preferences)
    var user: User?

    // Display preferences per room type
    @Attribute var displayPreferencesByRoom: [String: DisplayPreferenceData] // RoomType.rawValue -> prefs

    var temperatureUnit: TemperatureUnit
    var energyCostRate: Double // $ per kWh
    var waterCostRate: Double // $ per gallon

    var updatedAt: Date

    init() {
        self.id = UUID()
        self.displayPreferencesByRoom = [:]
        self.temperatureUnit = .fahrenheit
        self.energyCostRate = 0.15
        self.waterCostRate = 0.006
        self.updatedAt = Date()
    }
}

struct DisplayPreferenceData: Codable {
    var enabledWidgets: [String] // Widget identifiers
    var layout: DisplayLayout
    var autoShow: Bool
}

enum DisplayLayout: String, Codable {
    case compact
    case normal
    case expanded
}

enum TemperatureUnit: String, Codable {
    case fahrenheit
    case celsius
}
```

### 3.3 Smart Device Models

#### SmartDevice
```swift
@Model
final class SmartDevice {
    @Attribute(.unique) var id: UUID
    var name: String
    var deviceType: DeviceType
    var manufacturer: String?
    var model: String?

    // Integration identifiers
    var homeKitIdentifier: String?
    var matterIdentifier: String?

    var isReachable: Bool
    var lastSeen: Date?
    var batteryLevel: Double? // 0.0 to 1.0

    @Relationship(deleteRule: .nullify, inverse: \Room.devices)
    var room: Room?

    @Relationship(deleteRule: .cascade, inverse: \DeviceState.device)
    var currentState: DeviceState?

    @Relationship(deleteRule: .nullify, inverse: \DeviceGroup.devices)
    var groups: [DeviceGroup]

    var capabilities: [DeviceCapability]
    var createdAt: Date
    var updatedAt: Date

    init(name: String, deviceType: DeviceType) {
        self.id = UUID()
        self.name = name
        self.deviceType = deviceType
        self.isReachable = true
        self.capabilities = []
        self.createdAt = Date()
        self.updatedAt = Date()
        self.groups = []
    }
}

enum DeviceType: String, Codable {
    case light
    case switch_
    case outlet
    case thermostat
    case lock
    case camera
    case speaker
    case blind
    case garageDoor
    case sprinkler
    case vacuum
    case sensor
    case fan
    case airPurifier
    case humidifier
    case dehumidifier
}

enum DeviceCapability: String, Codable {
    case onOff
    case brightness
    case colorTemperature
    case rgbColor
    case temperature
    case humidity
    case targetTemperature
    case fanSpeed
    case position // For blinds, garage doors
    case lock
    case motionDetection
    case contactSensor
    case airQuality
    case powerMonitoring
}
```

#### DeviceState
```swift
@Model
final class DeviceState {
    @Attribute(.unique) var id: UUID

    @Relationship(deleteRule: .nullify, inverse: \SmartDevice.currentState)
    var device: SmartDevice?

    var isOn: Bool?
    var brightness: Double? // 0.0 to 1.0
    var colorTemperature: Int? // Kelvin
    var rgbColor: RGBColor?
    var temperature: Double? // Current temperature
    var targetTemperature: Double?
    var humidity: Double?
    var position: Double? // 0.0 (closed) to 1.0 (open)
    var isLocked: Bool?
    var powerConsumption: Double? // Watts

    var lastUpdated: Date

    init() {
        self.id = UUID()
        self.lastUpdated = Date()
    }
}

struct RGBColor: Codable {
    var red: Double // 0.0 to 1.0
    var green: Double
    var blue: Double
}
```

#### DeviceGroup
```swift
@Model
final class DeviceGroup {
    @Attribute(.unique) var id: UUID
    var name: String
    var groupType: GroupType

    @Relationship(deleteRule: .nullify, inverse: \SmartDevice.groups)
    var devices: [SmartDevice]

    var createdAt: Date

    init(name: String, groupType: GroupType) {
        self.id = UUID()
        self.name = name
        self.groupType = groupType
        self.devices = []
        self.createdAt = Date()
    }
}

enum GroupType: String, Codable {
    case room // All devices in a room
    case floor // All devices on a floor
    case type // All devices of same type
    case custom // User-defined group
}
```

### 3.4 Scene & Automation Models

#### HomeScene
```swift
@Model
final class HomeScene {
    @Attribute(.unique) var id: UUID
    var name: String
    var icon: String // SF Symbol name

    @Relationship(deleteRule: .cascade, inverse: \SceneAction.scene)
    var actions: [SceneAction]

    var createdAt: Date
    var lastExecuted: Date?

    init(name: String, icon: String = "house.fill") {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.actions = []
        self.createdAt = Date()
    }
}
```

#### SceneAction
```swift
@Model
final class SceneAction {
    @Attribute(.unique) var id: UUID

    @Relationship(deleteRule: .nullify, inverse: \HomeScene.actions)
    var scene: HomeScene?

    var deviceID: UUID
    var actionType: ActionType
    var targetValue: ActionValue
    var executionOrder: Int

    init(deviceID: UUID, actionType: ActionType, targetValue: ActionValue, order: Int) {
        self.id = UUID()
        self.deviceID = deviceID
        self.actionType = actionType
        self.targetValue = targetValue
        self.executionOrder = order
    }
}

enum ActionType: String, Codable {
    case turnOn
    case turnOff
    case setBrightness
    case setTemperature
    case setPosition
    case lock
    case unlock
}

struct ActionValue: Codable {
    var boolValue: Bool?
    var doubleValue: Double?
    var intValue: Int?
}
```

#### Automation
```swift
@Model
final class Automation {
    @Attribute(.unique) var id: UUID
    var name: String
    var isEnabled: Bool

    @Relationship(deleteRule: .cascade)
    var trigger: AutomationTrigger?

    @Relationship(deleteRule: .cascade)
    var conditions: [AutomationCondition]

    @Relationship(deleteRule: .cascade)
    var actions: [SceneAction]

    var createdAt: Date
    var lastExecuted: Date?

    init(name: String, isEnabled: Bool = true) {
        self.id = UUID()
        self.name = name
        self.isEnabled = isEnabled
        self.conditions = []
        self.actions = []
        self.createdAt = Date()
    }
}
```

#### AutomationTrigger
```swift
@Model
final class AutomationTrigger {
    @Attribute(.unique) var id: UUID
    var triggerType: TriggerType
    var triggerData: Data // Encoded trigger-specific data

    init(triggerType: TriggerType, triggerData: Data) {
        self.id = UUID()
        self.triggerType = triggerType
        self.triggerData = triggerData
    }
}

enum TriggerType: String, Codable {
    case time // Specific time of day
    case deviceState // Device state change
    case location // User arrives/leaves
    case sensor // Sensor threshold
    case sunrise
    case sunset
}
```

#### AutomationCondition
```swift
@Model
final class AutomationCondition {
    @Attribute(.unique) var id: UUID
    var conditionType: ConditionType
    var conditionData: Data

    init(conditionType: ConditionType, conditionData: Data) {
        self.id = UUID()
        self.conditionType = conditionType
        self.conditionData = conditionData
    }
}

enum ConditionType: String, Codable {
    case time // Before/after time
    case deviceState
    case dayOfWeek
    case temperature
    case humidity
    case anyoneHome
}
```

### 3.5 Energy Models

#### EnergyConfiguration
```swift
@Model
final class EnergyConfiguration {
    @Attribute(.unique) var id: UUID

    var hasSmartMeter: Bool
    var hasSolar: Bool
    var hasBattery: Bool

    var electricityRatePerKWh: Double
    var gasRatePerTherm: Double?
    var waterRatePerGallon: Double

    // API credentials (encrypted in Keychain, only store identifiers here)
    var meterAPIIdentifier: String?
    var solarAPIIdentifier: String?
    var batteryAPIIdentifier: String?

    var updatedAt: Date

    init() {
        self.id = UUID()
        self.hasSmartMeter = false
        self.hasSolar = false
        self.hasBattery = false
        self.electricityRatePerKWh = 0.15
        self.waterRatePerGallon = 0.006
        self.updatedAt = Date()
    }
}
```

#### EnergyReading
```swift
@Model
final class EnergyReading {
    @Attribute(.unique) var id: UUID
    var timestamp: Date
    var energyType: EnergyType

    // Consumption
    var instantaneousPower: Double? // kW or gallons/min
    var cumulativeConsumption: Double? // kWh or gallons

    // Generation (solar)
    var instantaneousGeneration: Double? // kW
    var cumulativeGeneration: Double? // kWh

    // By circuit/appliance (optional)
    var circuitBreakdown: [String: Double]? // Circuit name -> kW

    var deviceID: UUID? // If specific device (smart plug)

    init(timestamp: Date = Date(), energyType: EnergyType) {
        self.id = UUID()
        self.timestamp = timestamp
        self.energyType = energyType
    }
}

enum EnergyType: String, Codable {
    case electricity
    case gas
    case water
    case solar
}
```

#### EnergyAnomaly
```swift
@Model
final class EnergyAnomaly {
    @Attribute(.unique) var id: UUID
    var detectedAt: Date
    var anomalyType: AnomalyType
    var severity: AnomalySeverity

    var energyType: EnergyType
    var affectedDeviceID: UUID?
    var expectedValue: Double
    var actualValue: Double
    var description: String

    var isDismissed: Bool
    var resolvedAt: Date?

    init(
        detectedAt: Date = Date(),
        anomalyType: AnomalyType,
        severity: AnomalySeverity,
        energyType: EnergyType,
        expectedValue: Double,
        actualValue: Double,
        description: String
    ) {
        self.id = UUID()
        self.detectedAt = detectedAt
        self.anomalyType = anomalyType
        self.severity = severity
        self.energyType = energyType
        self.expectedValue = expectedValue
        self.actualValue = actualValue
        self.description = description
        self.isDismissed = false
    }
}

enum AnomalyType: String, Codable {
    case suspectedLeak
    case unusuallyHigh
    case unusuallyLow
    case continuousUsage
    case spikage
}

enum AnomalySeverity: String, Codable {
    case low
    case medium
    case high
    case critical
}
```

### 3.6 Environment Models

#### EnvironmentReading
```swift
@Model
final class EnvironmentReading {
    @Attribute(.unique) var id: UUID
    var timestamp: Date

    @Relationship(deleteRule: .nullify, inverse: \Room.environmentReadings)
    var room: Room?

    var temperature: Double? // Fahrenheit
    var humidity: Double? // Percentage
    var airQualityIndex: Int?
    var pm25: Double? // μg/m³
    var co2: Int? // ppm
    var voc: Int? // ppb
    var lightLevel: Double? // lux
    var noiseLevel: Double? // dB

    init(timestamp: Date = Date()) {
        self.id = UUID()
        self.timestamp = timestamp
    }
}
```

#### EnvironmentAlert
```swift
@Model
final class EnvironmentAlert {
    @Attribute(.unique) var id: UUID
    var createdAt: Date
    var alertType: EnvironmentAlertType
    var severity: AlertSeverity
    var message: String
    var roomID: UUID
    var reading: Double
    var threshold: Double

    var isDismissed: Bool
    var resolvedAt: Date?

    init(
        alertType: EnvironmentAlertType,
        severity: AlertSeverity,
        message: String,
        roomID: UUID,
        reading: Double,
        threshold: Double
    ) {
        self.id = UUID()
        self.createdAt = Date()
        self.alertType = alertType
        self.severity = severity
        self.message = message
        self.roomID = roomID
        self.reading = reading
        self.threshold = threshold
        self.isDismissed = false
    }
}

enum EnvironmentAlertType: String, Codable {
    case temperatureTooHigh
    case temperatureTooLow
    case humidityTooHigh
    case humidityTooLow
    case poorAirQuality
    case highCO2
    case highVOC
    case noiseTooLoud
}

enum AlertSeverity: String, Codable {
    case info
    case warning
    case critical
}
```

### 3.7 Maintenance Models

#### MaintenanceTask
```swift
@Model
final class MaintenanceTask {
    @Attribute(.unique) var id: UUID
    var title: String
    var description: String
    var taskType: MaintenanceTaskType
    var category: MaintenanceCategory

    var dueDate: Date?
    var recurrenceInterval: RecurrenceInterval?
    var lastCompletedDate: Date?

    var priority: TaskPriority
    var estimatedCost: Double?
    var estimatedDuration: TimeInterval? // seconds

    var deviceID: UUID? // If task is for specific device
    var roomID: UUID? // If task is for specific room

    var isCompleted: Bool
    var isPredictive: Bool // Generated by ML prediction

    var createdAt: Date
    var completedAt: Date?

    @Relationship(deleteRule: .cascade, inverse: \TaskHistory.task)
    var history: [TaskHistory]

    init(
        title: String,
        description: String,
        taskType: MaintenanceTaskType,
        category: MaintenanceCategory,
        dueDate: Date? = nil,
        priority: TaskPriority = .normal
    ) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.taskType = taskType
        self.category = category
        self.dueDate = dueDate
        self.priority = priority
        self.isCompleted = false
        self.isPredictive = false
        self.createdAt = Date()
        self.history = []
    }
}

enum MaintenanceTaskType: String, Codable {
    case inspection
    case cleaning
    case replacement
    case repair
    case service
    case testing
}

enum MaintenanceCategory: String, Codable {
    case hvac
    case plumbing
    case electrical
    case appliance
    case exterior
    case interior
    case safety
    case yard
    case seasonal
}

enum TaskPriority: String, Codable {
    case low
    case normal
    case high
    case urgent
}

enum RecurrenceInterval: String, Codable {
    case daily
    case weekly
    case biweekly
    case monthly
    case quarterly
    case semiannual
    case annual
}
```

#### TaskHistory
```swift
@Model
final class TaskHistory {
    @Attribute(.unique) var id: UUID

    @Relationship(deleteRule: .nullify, inverse: \MaintenanceTask.history)
    var task: MaintenanceTask?

    var completedAt: Date
    var completedBy: String? // User name
    var cost: Double?
    var notes: String?
    var photos: [Data]? // Image data
    var serviceProvider: String?
    var receiptImage: Data?

    init(completedAt: Date = Date()) {
        self.id = UUID()
        self.completedAt = completedAt
    }
}
```

### 3.8 Display Configuration Models

#### DisplayConfiguration
```swift
@Model
final class DisplayConfiguration {
    @Attribute(.unique) var id: UUID

    var enabledWidgets: [WidgetType]
    var layout: DisplayLayout
    var autoShowOnApproach: Bool
    var showDistance: Double // meters
    var hideDistance: Double

    var backgroundColor: ColorData
    var foregroundColor: ColorData
    var cornerRadius: Double

    var updatedAt: Date

    init() {
        self.id = UUID()
        self.enabledWidgets = []
        self.layout = .normal
        self.autoShowOnApproach = true
        self.showDistance = 2.0
        self.hideDistance = 4.0
        self.backgroundColor = ColorData(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.9)
        self.foregroundColor = ColorData(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.cornerRadius = 12.0
        self.updatedAt = Date()
    }
}

enum WidgetType: String, Codable {
    case weather
    case calendar
    case tasks
    case energy
    case water
    case recipes
    case groceryList
    case traffic
    case sleepData
    case alarm
    case healthReminders
    case focusTimer
    case emails
    case packages
    case climate
}

struct ColorData: Codable {
    var red: Double
    var green: Double
    var blue: Double
    var alpha: Double
}
```

## 4. Relationships Diagram

```
Home
├── rooms: [Room]
│   ├── devices: [SmartDevice]
│   │   └── currentState: DeviceState
│   ├── anchors: [RoomAnchor]
│   ├── displayConfiguration: DisplayConfiguration
│   └── environmentReadings: [EnvironmentReading]
├── users: [User]
│   └── preferences: UserPreferences
└── energyConfiguration: EnergyConfiguration

DeviceGroup
└── devices: [SmartDevice] (many-to-many)

HomeScene
└── actions: [SceneAction]

Automation
├── trigger: AutomationTrigger
├── conditions: [AutomationCondition]
└── actions: [SceneAction]

MaintenanceTask
└── history: [TaskHistory]

Standalone:
- EnergyReading
- EnergyAnomaly
- EnvironmentAlert
```

## 5. SwiftData Configuration

### 5.1 Model Container Setup
```swift
import SwiftData

@MainActor
func createModelContainer() -> ModelContainer {
    let schema = Schema([
        Home.self,
        Room.self,
        RoomAnchor.self,
        User.self,
        UserPreferences.self,
        SmartDevice.self,
        DeviceState.self,
        DeviceGroup.self,
        HomeScene.self,
        SceneAction.self,
        Automation.self,
        AutomationTrigger.self,
        AutomationCondition.self,
        EnergyConfiguration.self,
        EnergyReading.self,
        EnergyAnomaly.self,
        EnvironmentReading.self,
        EnvironmentAlert.self,
        MaintenanceTask.self,
        TaskHistory.self,
        DisplayConfiguration.self
    ])

    let modelConfiguration = ModelConfiguration(
        schema: schema,
        isStoredInMemoryOnly: false,
        allowsSave: true,
        cloudKitDatabase: .automatic // Enable iCloud sync
    )

    do {
        return try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
        fatalError("Could not create ModelContainer: \(error)")
    }
}
```

### 5.2 Indexes for Performance
```swift
// Key queries that need indexes:
// - Find rooms by type
// - Find devices by room
// - Find energy readings by timestamp range
// - Find maintenance tasks by due date
// - Find environment readings by room and timestamp

// SwiftData automatically indexes @Attribute(.unique) properties
// For compound queries, consider denormalization or in-memory caching
```

## 6. Data Retention Policies

### 6.1 Real-Time Data
- **EnergyReading**: Keep 7 days of granular data, aggregate older data to hourly
- **EnvironmentReading**: Keep 7 days of granular data, aggregate to hourly

### 6.2 Historical Data
- **Aggregated Energy**: Keep 2 years
- **Aggregated Environment**: Keep 1 year
- **Maintenance History**: Keep indefinitely
- **Device States**: Current state only (no history)

### 6.3 Cleanup Strategy
```swift
func cleanupOldData() async {
    let context = modelContext
    let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!

    // Delete old energy readings
    let oldEnergyReadings = try? context.fetch(
        FetchDescriptor<EnergyReading>(
            predicate: #Predicate { $0.timestamp < sevenDaysAgo }
        )
    )
    oldEnergyReadings?.forEach { context.delete($0) }

    // Similar for environment readings
    // Aggregate before deletion (not shown here)
}
```

## 7. Data Migration Strategy

### 7.1 Version 1 to Version 2 (Example)
```swift
// When adding new properties or models:
// 1. Add new properties with default values
// 2. SwiftData handles lightweight migrations automatically
// 3. For complex migrations, use VersionedSchema

enum LivingBuildingSystemSchema: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [Home.self, Room.self, /* ... */]
    }
}
```

## 8. Caching Strategy

### 8.1 In-Memory Cache
```swift
@Observable
class DataCache {
    var currentEnergySnapshot: EnergySnapshot?
    var deviceStates: [UUID: DeviceState] = [:]
    var latestEnvironmentReadings: [UUID: EnvironmentReading] = [:] // Room ID -> Reading

    var cacheExpirationInterval: TimeInterval = 5.0 // seconds
}
```

### 8.2 Cache Invalidation
- Device state changes: Immediate
- Energy readings: 5 seconds
- Environment readings: 10 seconds
- Maintenance tasks: On modification only

## 9. Data Synchronization

### 9.1 iCloud Sync
- **Synced**: Home, Room, User, UserPreferences, Devices, Scenes, Automations, Maintenance
- **Not Synced**: Energy readings, Environment readings (too frequent, device-specific)

### 9.2 Conflict Resolution
```swift
// SwiftData + CloudKit handles most conflicts
// For custom resolution:
func resolveConflict<T: PersistentModel>(local: T, remote: T) -> T {
    // Use most recent updatedAt timestamp
    // Or merge specific properties
}
```

## 10. Data Privacy & Encryption

### 10.1 Encrypted Fields
- User.faceIDData: Encrypted in Keychain
- API credentials: Never stored in SwiftData, use Keychain

### 10.2 Keychain Storage
```swift
struct KeychainKeys {
    static let homeKitTokenPrefix = "com.lbs.homekit."
    static let energyAPIKeyPrefix = "com.lbs.energy."
    static let faceIDPrefix = "com.lbs.faceid."
}
```

## 11. Sample Data for Development

```swift
extension Home {
    static var preview: Home {
        let home = Home(name: "Sample Home", address: "123 Main St")

        let kitchen = Room(name: "Kitchen", roomType: .kitchen)
        let livingRoom = Room(name: "Living Room", roomType: .livingRoom)

        home.rooms = [kitchen, livingRoom]

        let lightSwitch = SmartDevice(name: "Kitchen Light", deviceType: .light)
        lightSwitch.room = kitchen

        let thermostat = SmartDevice(name: "Main Thermostat", deviceType: .thermostat)
        thermostat.room = livingRoom

        return home
    }
}
```

---

**Document Owner**: Backend Team
**Review Cycle**: On schema changes
**Next Review**: As needed
