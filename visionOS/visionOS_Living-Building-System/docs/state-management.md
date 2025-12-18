# State Management Architecture
## Living Building System

**Version**: 1.0
**Last Updated**: 2025-11-24
**Status**: Draft

---

## 1. Overview

This document defines the state management strategy for the Living Building System using Swift's modern `@Observable` macro and async/await patterns.

## 2. State Management Principles

1. **Single Source of Truth**: Each piece of data has one authoritative source
2. **Unidirectional Data Flow**: Data flows in one direction (state → view)
3. **Immutability**: State changes create new values rather than mutating existing ones
4. **Observable**: Views automatically update when observed state changes
5. **Async-First**: State updates use async/await for predictable concurrency

## 3. Core State Container

### 3.1 App State

```swift
@Observable
@MainActor
class AppState {
    // Current home and room context
    var currentHome: Home?
    var currentRoom: Room?
    var currentUser: User?

    // Device state
    var devices: [UUID: SmartDevice] = [:]
    var deviceStates: [UUID: DeviceState] = [:]

    // Energy data
    var currentEnergySnapshot: EnergySnapshot?
    var energyHistory: [EnergyReading] = []

    // Environment data
    var environmentReadings: [UUID: EnvironmentReading] = [:] // Room ID -> Reading
    var environmentAlerts: [EnvironmentAlert] = []

    // Maintenance
    var maintenanceTasks: [MaintenanceTask] = []
    var upcomingTasks: [MaintenanceTask] = []

    // UI state
    var isImmersiveSpaceActive = false
    var selectedDeviceID: UUID?
    var showingSettings = false

    // Loading states
    var isLoadingDevices = false
    var isLoadingEnergy = false
    var isLoadingEnvironment = false

    // Error state
    var currentError: AppError?

    init() {
        // Initialize with default values
    }
}
```

### 3.2 Sub-States

```swift
@Observable
@MainActor
class DeviceState {
    var devices: [UUID: SmartDevice] = [:]
    var groups: [DeviceGroup] = []
    var scenes: [HomeScene] = []
    var automations: [Automation] = []

    func updateDevice(_ device: SmartDevice) {
        devices[device.id] = device
    }

    func devicesByRoom(_ roomID: UUID) -> [SmartDevice] {
        devices.values.filter { $0.room?.id == roomID }
    }
}

@Observable
@MainActor
class EnergyState {
    var currentSnapshot: EnergySnapshot?
    var historicalData: [EnergyReading] = []
    var solarData: SolarProduction?
    var anomalies: [EnergyAnomaly] = []

    var totalConsumption: Double {
        currentSnapshot?.totalPower ?? 0
    }

    var topConsumers: [(device: String, power: Double)] {
        currentSnapshot?.deviceBreakdown.sorted { $0.value > $1.value }.prefix(5).map { ($0.key, $0.value) } ?? []
    }
}

@Observable
@MainActor
class EnvironmentState {
    var readings: [UUID: EnvironmentReading] = [:] // Room ID -> Reading
    var alerts: [EnvironmentAlert] = []

    func reading(for roomID: UUID) -> EnvironmentReading? {
        readings[roomID]
    }

    var activeAlerts: [EnvironmentAlert] {
        alerts.filter { !$0.isDismissed }
    }
}
```

## 4. State Updates

### 4.1 Managers as State Coordinators

```swift
@MainActor
class DeviceManager {
    private let appState: AppState
    private let homeKitService: HomeKitServiceProtocol

    init(appState: AppState, homeKitService: HomeKitServiceProtocol) {
        self.appState = appState
        self.homeKitService = homeKitService
    }

    func refreshDevices() async throws {
        appState.isLoadingDevices = true
        defer { appState.isLoadingDevices = false }

        do {
            guard let home = appState.currentHome else {
                throw DeviceError.noHomeSelected
            }

            let devices = try await homeKitService.discoverAccessories(in: home)

            // Update state
            for device in devices {
                appState.devices[device.id] = device
            }
        } catch {
            appState.currentError = .deviceError(error)
            throw error
        }
    }

    func toggleDevice(_ device: SmartDevice) async throws {
        let newState = !device.isOn

        // Optimistic update
        var updatedDevice = device
        updatedDevice.isOn = newState
        appState.devices[device.id] = updatedDevice

        do {
            try await homeKitService.setDeviceState(device, isOn: newState)
        } catch {
            // Revert on error
            appState.devices[device.id] = device
            throw error
        }
    }
}
```

### 4.2 Real-Time Updates

```swift
@MainActor
class EnergyManager {
    private let appState: AppState
    private let energyService: EnergyMeterServiceProtocol
    private var streamTask: Task<Void, Never>?

    func startRealTimeMonitoring() {
        streamTask = Task {
            for await reading in energyService.streamRealTimeData() {
                // Update state with new reading
                appState.currentEnergySnapshot = EnergySnapshot(from: reading)

                // Add to history
                appState.energyHistory.append(reading)

                // Keep only last 1000 readings
                if appState.energyHistory.count > 1000 {
                    appState.energyHistory.removeFirst()
                }

                // Check for anomalies
                if let anomaly = detectAnomaly(reading) {
                    appState.environmentAlerts.append(
                        EnvironmentAlert(from: anomaly)
                    )
                }
            }
        }
    }

    func stopRealTimeMonitoring() {
        streamTask?.cancel()
        streamTask = nil
    }

    private func detectAnomaly(_ reading: EnergyReading) -> EnergyAnomaly? {
        // Anomaly detection logic
        nil
    }
}
```

## 5. View Integration

### 5.1 Observing State

```swift
struct DashboardView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Automatically updates when appState changes
                if let home = appState.currentHome {
                    HomeHeader(home: home)
                }

                EnergySection(snapshot: appState.currentEnergySnapshot)

                DeviceGrid(devices: Array(appState.devices.values))

                MaintenanceSection(tasks: appState.upcomingTasks)
            }
        }
    }
}
```

### 5.2 Triggering State Changes

```swift
struct DeviceControlView: View {
    @Environment(AppState.self) private var appState
    let device: SmartDevice

    var body: some View {
        Toggle(device.name, isOn: Binding(
            get: { appState.devices[device.id]?.isOn ?? false },
            set: { newValue in
                Task {
                    try? await deviceManager.toggleDevice(device)
                }
            }
        ))
    }
}
```

## 6. State Persistence

### 6.1 SwiftData Integration

```swift
@MainActor
class StateRepository {
    private let modelContext: ModelContext

    func saveState(_ appState: AppState) async throws {
        // Save current state to SwiftData
        if let home = appState.currentHome {
            modelContext.insert(home)
        }

        for device in appState.devices.values {
            modelContext.insert(device)
        }

        try modelContext.save()
    }

    func loadState() async throws -> AppState {
        let appState = AppState()

        // Load from SwiftData
        let descriptor = FetchDescriptor<Home>()
        let homes = try modelContext.fetch(descriptor)
        appState.currentHome = homes.first

        return appState
    }
}
```

### 6.2 State Restoration

```swift
@MainActor
class AppStateManager {
    private let repository: StateRepository

    func restoreState() async {
        do {
            let savedState = try await repository.loadState()
            // Apply saved state to app
        } catch {
            print("Failed to restore state: \(error)")
        }
    }

    func saveState(every interval: TimeInterval = 300) {
        Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(interval))
                try? await repository.saveState(appState)
            }
        }
    }
}
```

## 7. Computed Properties

```swift
extension AppState {
    var totalEnergyConsumption: Double {
        currentEnergySnapshot?.totalPower ?? 0
    }

    var energyCost: Double {
        (totalEnergyConsumption / 1000.0) * (currentUser?.preferences?.energyCostRate ?? 0.15)
    }

    var activeDeviceCount: Int {
        devices.values.filter { $0.isOn }.count
    }

    var unresolvedAlerts: Int {
        environmentAlerts.filter { !$0.isDismissed }.count
    }

    var overdueTasks: [MaintenanceTask] {
        maintenanceTasks.filter { task in
            if let dueDate = task.dueDate {
                return dueDate < Date() && !task.isCompleted
            }
            return false
        }
    }
}
```

## 8. Action Pattern

### 8.1 State Actions

```swift
enum AppAction {
    case selectHome(Home)
    case selectRoom(Room)
    case toggleDevice(SmartDevice)
    case executeScene(HomeScene)
    case dismissAlert(EnvironmentAlert)
    case completeTask(MaintenanceTask)
}

@MainActor
class ActionDispatcher {
    private let appState: AppState
    private let deviceManager: DeviceManager
    private let sceneManager: SceneManager

    func dispatch(_ action: AppAction) async throws {
        switch action {
        case .selectHome(let home):
            appState.currentHome = home
            try await loadHomeData(home)

        case .selectRoom(let room):
            appState.currentRoom = room

        case .toggleDevice(let device):
            try await deviceManager.toggleDevice(device)

        case .executeScene(let scene):
            try await sceneManager.execute(scene)

        case .dismissAlert(let alert):
            alert.isDismissed = true

        case .completeTask(let task):
            task.isCompleted = true
            task.completedAt = Date()
        }
    }

    private func loadHomeData(_ home: Home) async throws {
        // Load devices, rooms, etc.
    }
}
```

## 9. Error Handling

```swift
enum AppError: LocalizedError {
    case deviceError(Error)
    case energyError(Error)
    case networkError(Error)
    case unauthorized

    var errorDescription: String? {
        switch self {
        case .deviceError(let error):
            return "Device error: \(error.localizedDescription)"
        case .energyError(let error):
            return "Energy monitoring error: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .unauthorized:
            return "Authorization required"
        }
    }
}

@MainActor
extension AppState {
    func handleError(_ error: Error) {
        currentError = AppError.from(error)

        // Auto-dismiss after 5 seconds
        Task {
            try? await Task.sleep(for: .seconds(5))
            if currentError?.id == error.id {
                currentError = nil
            }
        }
    }
}
```

## 10. Testing

### 10.1 Mock State

```swift
extension AppState {
    static var preview: AppState {
        let state = AppState()
        state.currentHome = Home.preview
        state.devices = [
            UUID(): SmartDevice(name: "Living Room Light", deviceType: .light),
            UUID(): SmartDevice(name: "Thermostat", deviceType: .thermostat)
        ]
        state.currentEnergySnapshot = EnergySnapshot(
            totalPower: 3.5,
            timestamp: Date()
        )
        return state
    }
}
```

### 10.2 State Testing

```swift
@Test
func testDeviceToggle() async throws {
    let appState = AppState()
    let mockService = MockHomeKitService()
    let deviceManager = DeviceManager(appState: appState, homeKitService: mockService)

    let device = SmartDevice(name: "Test Light", deviceType: .light)
    device.isOn = false
    appState.devices[device.id] = device

    try await deviceManager.toggleDevice(device)

    #expect(appState.devices[device.id]?.isOn == true)
}
```

---

**Document Owner**: Architecture Team
**Review Cycle**: Quarterly
**Next Review**: 2026-02-24
