# Testing Strategy Document
## Living Building System

**Version**: 1.0
**Last Updated**: 2025-11-24
**Status**: Draft

---

## 1. Overview

This document outlines the comprehensive testing strategy for the Living Building System, covering unit tests, integration tests, UI tests, and performance tests.

## 2. Testing Pyramid

```
           ┌─────────────┐
           │  Manual     │  5%
           │  Testing    │
           ├─────────────┤
           │     UI      │  15%
           │    Tests    │
           ├─────────────┤
           │ Integration │  30%
           │    Tests    │
           ├─────────────┤
           │    Unit     │  50%
           │    Tests    │
           └─────────────┘
```

## 3. Unit Testing

### 3.1 Test Framework

```swift
import Testing // Swift Testing framework

@Test("Device toggle updates state correctly")
func testDeviceToggle() async throws {
    // Arrange
    let appState = AppState()
    let mockService = MockHomeKitService()
    let manager = DeviceManager(appState: appState, homeKitService: mockService)

    var device = SmartDevice(name: "Test Light", deviceType: .light)
    device.isOn = false
    appState.devices[device.id] = device

    // Act
    try await manager.toggleDevice(device)

    // Assert
    #expect(appState.devices[device.id]?.isOn == true)
    #expect(mockService.commandHistory.count == 1)
}

@Test("Energy calculation is accurate")
func testEnergyCalculation() {
    // Arrange
    let snapshot = EnergySnapshot(
        totalPower: 3.5, // kW
        timestamp: Date()
    )

    // Act
    let hourlyCost = snapshot.calculateCost(rate: 0.15)

    // Assert
    #expect(hourlyCost == 0.525) // 3.5 kW * $0.15/kWh
}
```

### 3.2 Test Coverage Goals

| Component | Target Coverage |
|-----------|----------------|
| Domain Models | 100% |
| Business Logic | 95% |
| Managers | 90% |
| Services | 85% |
| UI Views | 60% |

### 3.3 Mock Objects

```swift
class MockHomeKitService: HomeKitServiceProtocol {
    var mockDevices: [HMAccessory] = []
    var commandHistory: [(device: UUID, action: String)] = []
    var shouldThrowError = false

    func requestAuthorization() async throws {
        if shouldThrowError {
            throw HomeKitError.authorizationFailed
        }
    }

    func discoverAccessories(in home: HMHome) async throws -> [HMAccessory] {
        if shouldThrowError {
            throw HomeKitError.noPrimaryHome
        }
        return mockDevices
    }

    func setDeviceState(_ device: SmartDevice, isOn: Bool) async throws {
        commandHistory.append((device.id, "toggle"))

        if shouldThrowError {
            throw HomeKitError.deviceUnreachable
        }
    }
}

class MockEnergyService: EnergyMeterServiceProtocol {
    var mockReading: EnergyReading?

    func getCurrentReading() async throws -> EnergyReading {
        guard let reading = mockReading else {
            throw EnergyMeterError.noData
        }
        return reading
    }

    func streamRealTimeData() -> AsyncStream<EnergyReading> {
        AsyncStream { continuation in
            if let reading = mockReading {
                continuation.yield(reading)
            }
            continuation.finish()
        }
    }
}
```

### 3.4 Test Suites

```swift
@Suite("Device Management Tests")
struct DeviceManagementTests {
    @Test("Discover devices")
    func testDeviceDiscovery() async throws {
        // Test implementation
    }

    @Test("Toggle device")
    func testDeviceToggle() async throws {
        // Test implementation
    }

    @Test("Group devices")
    func testDeviceGrouping() async throws {
        // Test implementation
    }

    @Test("Execute scene")
    func testSceneExecution() async throws {
        // Test implementation
    }
}

@Suite("Energy Monitoring Tests")
struct EnergyMonitoringTests {
    @Test("Calculate consumption")
    func testConsumptionCalculation() async throws {
        // Test implementation
    }

    @Test("Detect anomalies")
    func testAnomalyDetection() async throws {
        // Test implementation
    }

    @Test("Cost calculation")
    func testCostCalculation() async throws {
        // Test implementation
    }
}
```

## 4. Integration Testing

### 4.1 Service Integration Tests

```swift
@Test("HomeKit service integration")
func testHomeKitIntegration() async throws {
    // Requires actual HomeKit accessory or simulator
    let service = HomeKitService()

    try await service.requestAuthorization()

    let accessories = try await service.discoverAccessories(in: testHome)
    #expect(!accessories.isEmpty)

    if let light = accessories.first(where: { $0.category.categoryType == .lightbulb }) {
        try await service.turnOnLight(light)
        // Verify state change
    }
}
```

### 4.2 SwiftData Integration Tests

```swift
@Test("Data persistence")
func testDataPersistence() async throws {
    // Setup in-memory container
    let container = try ModelContainer(
        for: Home.self, Room.self, SmartDevice.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    let context = ModelContext(container)

    // Create test data
    let home = Home(name: "Test Home")
    let room = Room(name: "Living Room", roomType: .livingRoom)
    home.rooms.append(room)

    context.insert(home)
    try context.save()

    // Fetch and verify
    let descriptor = FetchDescriptor<Home>()
    let homes = try context.fetch(descriptor)

    #expect(homes.count == 1)
    #expect(homes.first?.name == "Test Home")
    #expect(homes.first?.rooms.count == 1)
}
```

### 4.3 API Integration Tests

```swift
@Test("Energy API integration")
func testEnergyAPIIntegration() async throws {
    // Use test API credentials
    let service = SenseEnergyService()

    let credentials = MeterCredentials(
        apiKey: "test_key",
        username: "test@example.com",
        password: "test_password",
        deviceID: nil
    )

    try await service.authenticate(credentials: credentials)

    let reading = try await service.getCurrentReading()

    #expect(reading.energyType == .electricity)
    #expect(reading.instantaneousPower != nil)
}
```

## 5. UI Testing

### 5.1 SwiftUI View Tests

```swift
@Test("Dashboard displays correctly")
@MainActor
func testDashboardView() async {
    let appState = AppState.preview
    let view = DashboardView()
        .environment(appState)

    // Test rendering
    // Note: visionOS UI testing is limited in simulator
}
```

### 5.2 Interaction Tests

```swift
@Test("Device toggle interaction")
@MainActor
func testDeviceToggleInteraction() async throws {
    let appState = AppState()
    let device = SmartDevice(name: "Test Light", deviceType: .light)
    device.isOn = false
    appState.devices[device.id] = device

    // Simulate toggle
    // In visionOS, use spatial interaction testing
}
```

### 5.3 Accessibility Tests

```swift
@Test("VoiceOver labels are present")
@MainActor
func testAccessibilityLabels() {
    let device = SmartDevice(name: "Living Room Light", deviceType: .light)
    let view = DeviceControlView(device: device)

    // Verify accessibility properties
    // Check for proper labels, hints, values
}
```

## 6. Performance Testing

### 6.1 Load Testing

```swift
@Test("Handle 100 devices")
func testManyDevices() async throws {
    let appState = AppState()

    // Add 100 devices
    for i in 0..<100 {
        let device = SmartDevice(name: "Device \(i)", deviceType: .light)
        appState.devices[device.id] = device
    }

    let startTime = Date()

    // Perform operations
    for device in appState.devices.values {
        _ = device.isOn
    }

    let elapsed = Date().timeIntervalSince(startTime)

    // Should complete in under 100ms
    #expect(elapsed < 0.1)
}
```

### 6.2 Memory Testing

```swift
@Test("Memory usage under continuous updates")
func testMemoryUsage() async throws {
    let appState = AppState()
    let mockService = MockEnergyService()

    mockService.mockReading = EnergyReading(timestamp: Date(), energyType: .electricity)

    let manager = EnergyManager(appState: appState, energyService: mockService)

    // Simulate 1000 updates
    for _ in 0..<1000 {
        try await manager.updateEnergyData()
    }

    // Verify no memory leaks
    // Use Instruments for detailed analysis
}
```

### 6.3 Rendering Performance

```swift
@Test("Energy flow renders at 60fps")
func testRenderingPerformance() async {
    let renderer = EnergyFlowRenderer()

    // Create complex flow visualization
    for i in 0..<50 {
        let source = SIMD3<Float>(0, 0, 0)
        let destination = SIMD3<Float>(Float(i), Float(i), 0)
        _ = renderer.createFlowVisualization(
            from: source,
            to: destination,
            power: Double(i) / 10.0,
            energyType: .electricity
        )
    }

    // Measure frame time
    // Should maintain 60fps (16.67ms per frame)
}
```

## 7. Test Data

### 7.1 Test Fixtures

```swift
struct TestData {
    static let sampleHome = Home(name: "Test Home", address: "123 Test St")

    static let sampleRooms: [Room] = [
        Room(name: "Living Room", roomType: .livingRoom),
        Room(name: "Kitchen", roomType: .kitchen),
        Room(name: "Bedroom", roomType: .bedroom)
    ]

    static let sampleDevices: [SmartDevice] = [
        SmartDevice(name: "Living Room Light", deviceType: .light),
        SmartDevice(name: "Thermostat", deviceType: .thermostat),
        SmartDevice(name: "Front Door Lock", deviceType: .lock)
    ]

    static let sampleEnergyReading = EnergyReading(
        timestamp: Date(),
        energyType: .electricity
    ).apply {
        $0.instantaneousPower = 3.5
        $0.cumulativeConsumption = 125.0
    }
}
```

### 7.2 Test Utilities

```swift
extension SmartDevice {
    func apply(_ changes: (inout SmartDevice) -> Void) -> SmartDevice {
        var copy = self
        changes(&copy)
        return copy
    }
}

extension Date {
    static func daysAgo(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -days, to: Date())!
    }
}
```

## 8. Continuous Integration

### 8.1 CI Pipeline

```yaml
# .github/workflows/test.yml
name: Test

on: [push, pull_request]

jobs:
  test:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v4

      - name: Select Xcode version
        run: sudo xcode-select -s /Applications/Xcode_15.2.app

      - name: Build
        run: xcodebuild build -scheme LivingBuildingSystem -destination 'platform=visionOS Simulator,name=Apple Vision Pro'

      - name: Run tests
        run: xcodebuild test -scheme LivingBuildingSystem -destination 'platform=visionOS Simulator,name=Apple Vision Pro' -resultBundlePath TestResults

      - name: Code coverage
        run: xcrun xccov view --report TestResults.xcresult

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage.xml
```

### 8.2 Pre-commit Hooks

```bash
#!/bin/sh
# .git/hooks/pre-commit

# Run tests
xcodebuild test -scheme LivingBuildingSystem -destination 'platform=visionOS Simulator,name=Apple Vision Pro' -quiet

if [ $? -ne 0 ]; then
    echo "Tests failed. Commit aborted."
    exit 1
fi

# Run linter
swiftlint

if [ $? -ne 0 ]; then
    echo "SwiftLint failed. Commit aborted."
    exit 1
fi

exit 0
```

## 9. Test Reporting

### 9.1 Coverage Reports

```swift
// Generate coverage report
// xcodebuild test -scheme LivingBuildingSystem -enableCodeCoverage YES
// xcrun xccov view --report TestResults.xcresult > coverage.txt

// Minimum coverage thresholds:
// - Overall: 80%
// - Critical paths: 95%
```

### 9.2 Test Documentation

```swift
/// Tests the device toggle functionality
/// - Verifies state update
/// - Verifies service call
/// - Verifies error handling
@Test("Device toggle updates state correctly")
func testDeviceToggle() async throws {
    // Implementation
}
```

## 10. Manual Testing Checklist

### 10.1 Smoke Tests

- [ ] App launches successfully
- [ ] Home view displays correctly
- [ ] Can discover devices
- [ ] Can toggle a device
- [ ] Energy data displays
- [ ] No crashes in basic flows

### 10.2 Regression Tests

- [ ] Device control works after update
- [ ] Energy visualization renders correctly
- [ ] Contextual displays appear on approach
- [ ] Scene execution works
- [ ] Maintenance tasks display
- [ ] Settings persist

### 10.3 Platform-Specific Tests (visionOS)

- [ ] Immersive space loads
- [ ] Eye tracking works for device selection
- [ ] Hand gestures recognized
- [ ] Spatial audio plays correctly
- [ ] Room anchors persist
- [ ] Performance at 60fps

---

**Document Owner**: QA Team
**Review Cycle**: After each release
**Next Review**: As needed
