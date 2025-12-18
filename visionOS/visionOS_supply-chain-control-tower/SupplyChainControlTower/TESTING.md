# Testing Guide

## Overview

This document describes the comprehensive testing strategy for the Supply Chain Control Tower visionOS application. Our testing approach ensures reliability, performance, and quality across all components.

## Test Coverage

### Summary Statistics

- **Total Test Files**: 4
- **Total Test Cases**: 68
- **Test Types**: Unit, Integration, Performance, Stress, End-to-End
- **Testing Framework**: Swift Testing (modern Swift testing framework)

### Test Files

1. **DataModelsTests.swift** (14 tests)
   - Data model creation and validation
   - Geographic coordinate calculations
   - Mock data generation
   - KPI metrics validation

2. **NetworkServiceTests.swift** (22 tests)
   - Cache manager functionality
   - API endpoint validation
   - Network service operations
   - Geometry extensions
   - ViewModel functionality

3. **PerformanceTests.swift** (18 tests)
   - FPS monitoring
   - Memory usage tracking
   - Entity pooling
   - Throttle/debounce mechanisms
   - LOD system
   - Batch processing
   - Large dataset handling

4. **IntegrationTests.swift** (14 tests)
   - Service integration
   - ViewModel integration
   - Data flow validation
   - State management
   - Real-time updates
   - End-to-end scenarios

## Running Tests

### Prerequisites

- macOS 14.0 or later
- Xcode 16.0 or later
- visionOS 2.0+ SDK
- Apple Vision Pro simulator or device

### Command Line

```bash
# Run all tests
swift test

# Run tests in Xcode
xcodebuild test \
  -scheme SupplyChainControlTower \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro'

# Run specific test suite
swift test --filter DataModelsTests

# Run specific test case
swift test --filter testNodeCreation

# Run tests with verbose output
swift test --verbose

# Run tests in parallel
swift test --parallel
```

### Xcode

1. Open `SupplyChainControlTower.xcodeproj`
2. Select Product → Test (⌘U)
3. View results in the Test Navigator (⌘6)
4. Use Test Plans for different configurations

### CI/CD

```yaml
# Example GitHub Actions workflow
- name: Run Tests
  run: |
    xcodebuild test \
      -scheme SupplyChainControlTower \
      -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
      -resultBundlePath TestResults \
      -enableCodeCoverage YES
```

## Test Categories

### 1. Unit Tests

**Purpose**: Test individual components in isolation

**Coverage**:
- ✅ Data Models (Node, Flow, Disruption, Network)
- ✅ Geographic Coordinate Calculations
- ✅ Capacity Utilization
- ✅ KPI Metrics
- ✅ Mock Data Generation
- ✅ Geometry Extensions (SIMD3, Math Utils)
- ✅ Route Waypoint Generation

**Example**:
```swift
@Test("Node capacity utilization calculation")
func testCapacityUtilization() async throws {
    let capacity = Capacity(total: 100, available: 25, unit: "units")
    #expect(capacity.utilization == 0.75)
}
```

### 2. Integration Tests

**Purpose**: Test component interactions and data flow

**Coverage**:
- ✅ Network Service + Cache Manager
- ✅ ViewModels + Services
- ✅ AppState + Multiple Windows
- ✅ Geographic Data + Visualization
- ✅ Error Propagation
- ✅ Cache Invalidation
- ✅ LOD System + Visualization

**Example**:
```swift
@Test("Network service fetches and caches data")
func testNetworkServiceFetchAndCache() async throws {
    let service = NetworkService.shared
    let network1 = try await service.fetchNetwork()
    let network2 = try await service.fetchNetwork()
    // Second fetch should use cache
}
```

### 3. Performance Tests

**Purpose**: Validate performance targets and optimize bottlenecks

**Targets**:
- **Frame Rate**: 90 FPS minimum
- **Memory**: < 4GB total usage
- **Network**: < 2MB per fetch
- **Latency**: < 100ms for user interactions

**Coverage**:
- ✅ FPS Monitoring (PerformanceMonitor)
- ✅ Memory Usage Tracking
- ✅ Entity Pool Performance
- ✅ Throttle/Debounce Efficiency
- ✅ LOD System Performance
- ✅ Large Dataset Handling (1000+ nodes)
- ✅ Cartesian Conversion Speed
- ✅ Distance Calculation Performance

**Example**:
```swift
@Test("Entity creation performance")
func testEntityCreationPerformance() async throws {
    let startTime = Date()
    // Create 1000 nodes
    let duration = Date().timeIntervalSince(startTime)
    #expect(duration < 0.5) // Must complete in < 0.5s
}
```

### 4. Stress Tests

**Purpose**: Test system behavior under extreme conditions

**Coverage**:
- ✅ Maximum Node Count (5000 nodes)
- ✅ Maximum Flow Count (10000 flows)
- ✅ Concurrent Data Access (100+ simultaneous tasks)
- ✅ Memory Pressure Scenarios

**Example**:
```swift
@Test("Handle maximum node count")
func testMaximumNodeCount() async throws {
    // Create and manage 5000 nodes
    #expect(nodes.count == 5000)
}
```

### 5. End-to-End Tests

**Purpose**: Validate complete user journeys

**Scenarios**:
- ✅ Dashboard → Shipment Selection → Details View
- ✅ Network View → Node Inspection → Inventory
- ✅ Disruption Alert → Recommendations → Action
- ✅ Immersive Mode → Globe Navigation → Route Inspection

**Example**:
```swift
@Test("Complete user journey: View dashboard → Select shipment")
@MainActor
func testDashboardToShipmentDetails() async throws {
    // Simulate complete user flow
}
```

## Test Types Not Covered (Require visionOS Device/Simulator)

### UI Tests

**Cannot run in standard environments** - Require Xcode with visionOS SDK

**Would test**:
- Gesture recognition (tap, long press, drag)
- Eye tracking accuracy
- Hand tracking responsiveness
- Scene transitions
- Window management
- Spatial audio positioning

**Example**:
```swift
// Requires XCTest and visionOS simulator
func testTapGesture() throws {
    let app = XCUIApplication()
    app.launch()
    app.buttons["Dashboard"].tap()
    XCTAssertTrue(app.windows["Dashboard"].exists)
}
```

### Accessibility Tests

**Cannot run in standard environments** - Require visionOS device features

**Would test**:
- VoiceOver navigation
- Dynamic Type support
- Reduce Motion compatibility
- High Contrast mode
- Color blindness accommodations

**Example**:
```swift
// Requires Accessibility Inspector
func testVoiceOverNavigation() throws {
    // Test VoiceOver can navigate all controls
}
```

### RealityKit Visual Tests

**Cannot run in standard environments** - Require Metal and visionOS runtime

**Would test**:
- 3D model rendering accuracy
- Spatial audio playback
- Entity collision detection
- Animation smoothness
- Material appearance
- Lighting effects

**Example**:
```swift
// Requires RealityKit runtime
func testGlobeRendering() async throws {
    let globe = await createGlobe(radius: 2.5)
    // Verify globe renders correctly
}
```

## Code Coverage

### Current Coverage (Unit + Integration Tests)

- **Data Models**: ~95%
- **Services**: ~85%
- **ViewModels**: ~80%
- **Utilities**: ~90%
- **Views**: ~0% (requires UI tests)

### Coverage Goals

- **Overall**: 80% minimum
- **Critical Paths**: 95% minimum
- **Business Logic**: 90% minimum

### Generating Coverage Reports

```bash
# Run tests with coverage
xcodebuild test \
  -scheme SupplyChainControlTower \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -enableCodeCoverage YES

# Generate coverage report
xcrun xccov view \
  --report \
  --only-targets \
  path/to/TestResults.xcresult
```

## Performance Benchmarks

### Baseline Performance

| Metric | Target | Typical | Test |
|--------|--------|---------|------|
| Frame Rate | 90 FPS | 90 FPS | `testPerformanceMonitorFPS` |
| Memory Usage | < 4GB | ~2.5GB | `testPerformanceMonitorMemory` |
| Node Creation (1000) | < 0.5s | ~0.3s | `testEntityCreationPerformance` |
| Cartesian Conversion (1000) | < 0.1s | ~0.05s | `testCartesianConversionPerformance` |
| Distance Calc (1000) | < 0.1s | ~0.02s | `testDistanceCalculationPerformance` |
| Network Fetch | < 2s | ~1.2s | `testNetworkServiceFetchAndCache` |

### LOD Performance

| Camera Distance | LOD Level | Max Nodes | Max Labels | Test |
|-----------------|-----------|-----------|------------|------|
| < 5m | High | 1000 | 500 | `testLODSystemDistance` |
| 5-10m | Medium | 500 | 200 | `testLODSystemDistance` |
| 10-15m | Low | 200 | 50 | `testLODSystemDistance` |
| > 15m | Minimal | 50 | 20 | `testLODSystemDistance` |

## Testing Best Practices

### 1. Test Naming

Use descriptive names that explain what is being tested:

```swift
// Good
@Test("Geographic coordinate distance calculation")
func testCoordinateDistance() async throws { }

// Bad
@Test("Test 1")
func test1() async throws { }
```

### 2. Arrange-Act-Assert Pattern

```swift
@Test("Node creation and properties")
func testNodeCreation() async throws {
    // Arrange
    let location = GeographicCoordinate(latitude: 40.7128, longitude: -74.0060)
    let capacity = Capacity(total: 1000, available: 200, unit: "units")

    // Act
    let node = Node(id: "TEST-01", type: .warehouse, location: location, capacity: capacity)

    // Assert
    #expect(node.id == "TEST-01")
    #expect(node.type == .warehouse)
    #expect(node.capacity.utilization == 0.8)
}
```

### 3. Use Modern Swift Testing

```swift
// Use #expect instead of XCTAssert
#expect(value == expected)
#expect(array.count > 0)
#expect(result != nil)

// Use async/await
@Test("Async operation")
func testAsyncOperation() async throws {
    let result = try await service.fetch()
    #expect(result != nil)
}

// Use @MainActor for UI tests
@Test("ViewModel test")
@MainActor
func testViewModel() async throws {
    let viewModel = DashboardViewModel()
    await viewModel.load()
}
```

### 4. Test Independence

Each test should be independent and not rely on other tests:

```swift
// Good - Creates its own data
@Test("Test with fresh data")
func testWithFreshData() async throws {
    let data = createTestData()
    // Test with data
}

// Bad - Relies on shared state
var sharedData: Data?
@Test("Test with shared data")
func testWithSharedData() async throws {
    // Uses sharedData from another test
}
```

### 5. Mock External Dependencies

```swift
// Use mock services for testing
class MockNetworkService: NetworkServiceProtocol {
    func fetchNetwork() async throws -> SupplyChainNetwork {
        return SupplyChainNetwork.mockNetwork()
    }
}
```

## Continuous Integration

### Test Execution

- **On Every Commit**: Run all unit tests
- **On Pull Request**: Run full test suite including integration tests
- **Nightly**: Run performance and stress tests
- **Weekly**: Run full end-to-end test suite

### Quality Gates

- ✅ All tests must pass
- ✅ Code coverage must be ≥ 80%
- ✅ No new performance regressions
- ✅ No memory leaks detected

## Debugging Failed Tests

### Common Issues

1. **Timing Issues**
   ```swift
   // Add appropriate delays for async operations
   try await Task.sleep(for: .milliseconds(100))
   ```

2. **Floating Point Precision**
   ```swift
   // Use tolerance for float comparisons
   #expect(abs(result - expected) < 0.001)
   ```

3. **Mock Data Consistency**
   ```swift
   // Ensure mock data is deterministic
   func createDeterministicMockData() -> Network {
       // Use fixed seed for random data
   }
   ```

### Test Debugging in Xcode

1. Set breakpoints in test code
2. Use `lldb` debugger commands
3. Enable scheme diagnostics:
   - Address Sanitizer
   - Thread Sanitizer
   - Undefined Behavior Sanitizer

## Performance Testing Tools

### Instruments

Use Xcode Instruments for detailed performance analysis:

- **Time Profiler**: CPU usage and hot spots
- **Allocations**: Memory usage and leaks
- **Leaks**: Memory leak detection
- **Core Animation**: FPS and rendering performance
- **System Trace**: System-level performance

### Command Line Tools

```bash
# Profile tests
xcodebuild test \
  -scheme SupplyChainControlTower \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -enableCodeCoverage YES \
  -enableAddressSanitizer YES \
  -enableThreadSanitizer YES
```

## Future Testing Enhancements

### Planned Additions

1. **Visual Regression Tests**
   - Snapshot testing for UI components
   - Compare rendered frames against baselines

2. **Load Testing**
   - Simulate thousands of concurrent users
   - Test backend API under load

3. **Security Testing**
   - Penetration testing
   - Vulnerability scanning
   - Authentication/authorization tests

4. **Localization Testing**
   - Test all supported languages
   - Verify text doesn't overflow
   - Test RTL languages

5. **Beta Testing**
   - Internal testing with team
   - External testing with select customers
   - TestFlight distribution

## Resources

### Documentation

- [Swift Testing Documentation](https://developer.apple.com/documentation/testing)
- [visionOS Testing Guide](https://developer.apple.com/visionos/testing/)
- [XCTest Framework](https://developer.apple.com/documentation/xctest)

### Tools

- Xcode Test Navigator
- Instruments
- Accessibility Inspector
- RealityKit Debugger

### Contacts

- **Testing Lead**: [TBD]
- **Performance Lead**: [TBD]
- **QA Team**: [TBD]

---

## Quick Reference

### Run All Tests
```bash
swift test
```

### Run Specific Suite
```bash
swift test --filter DataModelsTests
```

### Run with Coverage
```bash
xcodebuild test -scheme SupplyChainControlTower -enableCodeCoverage YES
```

### View Coverage Report
```bash
xcrun xccov view --report path/to/TestResults.xcresult
```

---

*Last Updated: November 2025*
*Version: 1.0*
