# Reality Minecraft Test Suite Guide

## Overview

This directory contains comprehensive test coverage for Reality Minecraft, including unit tests, integration tests, UI tests, performance tests, and visionOS-specific hardware tests.

**Total Test Files**: 6
**Estimated Total Test Methods**: 150+

## Test Execution Requirements

### ⚠️ Important Note on Test Execution

All test files in this suite are written in Swift using XCTest and **require Xcode to run**. These tests cannot be executed in a standard command-line environment without the Xcode toolchain and visionOS SDK.

## Test Files Overview

### 1. BlockSystemTests.swift ✅ UNIT TESTS

**Requires**: Xcode 16+, visionOS SDK 2.0+
**Device Required**: No (can run in simulator)
**Test Count**: ~18 tests

#### What It Tests:
- Block type registry validation (10 block types)
- Block properties (hardness, transparency, light emission, tool requirements)
- Block position calculations and world coordinate conversions
- Chunk creation and initialization
- Chunk block storage (16x16x16 3D array)
- ChunkManager operations (creation, reuse, world block access)
- Performance benchmarks for chunk operations

#### Key Test Methods:
- `testBlockTypeRegistry()`
- `testBlockProperties()`
- `testChunkCreation()`
- `testChunkBlockStorage()`
- `testChunkManagerCreatesChunks()`
- `testChunkManagerReusesChunks()`
- `testWorldBlockAccess()`
- `testChunkPerformance()`

#### How to Run:
```bash
# In Xcode
1. Open RealityMinecraft.xcodeproj
2. Select Test navigator (⌘6)
3. Find BlockSystemTests
4. Click the play button next to the test class
# Or use Cmd+U to run all tests
```

---

### 2. InventoryTests.swift ✅ UNIT TESTS

**Requires**: Xcode 16+, visionOS SDK 2.0+
**Device Required**: No (can run in simulator)
**Test Count**: ~23 tests

#### What It Tests:
- Inventory creation and initialization (36 slots)
- Add/remove item operations
- Item stacking behavior (64 max stack size)
- Item quantity tracking
- Inventory full scenarios
- Insufficient item handling
- Hotbar functionality (9 slots, slot selection)
- Codable serialization (save/load)
- Performance benchmarks

#### Key Test Methods:
- `testInventoryCreation()`
- `testAddItem()`
- `testItemStacking()`
- `testInventoryFull()`
- `testRemoveItem()`
- `testHasItem()`
- `testHotbarSelection()`
- `testInventoryCodable()`
- `testInventoryPerformance()`

#### How to Run:
```bash
# In Xcode
1. Open RealityMinecraft.xcodeproj
2. Navigate to InventoryTests in Test navigator
3. Run individual tests or entire suite
```

---

### 3. CraftingSystemTests.swift ✅ UNIT TESTS

**Requires**: Xcode 16+, visionOS SDK 2.0+
**Device Required**: No (can run in simulator)
**Test Count**: ~19 tests

#### What It Tests:
- Recipe registry (10+ Minecraft recipes)
- Recipe pattern matching (simple and complex grids)
- Successful crafting operations
- Failed crafting scenarios (no recipe, insufficient ingredients)
- Ingredient consumption
- Available recipes based on inventory
- Crafting result delivery to inventory
- Complex crafting chains (log → planks → sticks → tools)
- Performance benchmarks

#### Key Recipes Tested:
- Oak Planks (from logs)
- Sticks (from planks)
- Crafting Table
- Wooden Pickaxe
- Stone Pickaxe
- Torches
- Chest

#### Key Test Methods:
- `testRecipeRegistry()`
- `testSimpleRecipeMatching()`
- `testSuccessfulCrafting()`
- `testFailedCraftingNoRecipe()`
- `testCraftingConsumesIngredients()`
- `testComplexCraftingChain()`
- `testCraftingPerformance()`

#### How to Run:
```bash
# In Xcode
1. Open RealityMinecraft.xcodeproj
2. Navigate to CraftingSystemTests
3. Run tests
```

---

### 4. IntegrationTests.swift ⚠️ INTEGRATION TESTS

**Requires**: Xcode 16+, visionOS SDK 2.0+, Full App Context
**Device Required**: No (can run in simulator)
**Test Count**: ~15 tests

#### What It Tests:
- Game state transitions (menu → loading → playing → paused)
- Entity-Component-System integration
- Event publish/subscribe system
- Multiple event handlers
- Chunk and block integration across chunk boundaries
- Entity and chunk interaction
- Game loop system coordination
- Player and inventory integration
- World persistence round-trip (save → load)
- Crafting and inventory workflow
- Performance integration tests

#### Key Test Methods:
- `testGameStateTransitions()`
- `testEntityCreationAndComponents()`
- `testEventPublishSubscribe()`
- `testChunkAndBlockIntegration()`
- `testGameLoopSystemsIntegration()`
- `testPlayerInventoryIntegration()`
- `testWorldDataIntegration()`
- `testCraftingInventoryIntegration()`

#### How to Run:
```bash
# In Xcode
1. Open RealityMinecraft.xcodeproj
2. Ensure all dependencies are built
3. Run IntegrationTests suite
# Note: These tests require app context and may need full build
```

---

### 5. UITests.swift 🎮 UI/UX TESTS

**Requires**: Xcode 16+, visionOS SDK 2.0+, Vision Pro Simulator or Device
**Device Required**: Yes (Simulator minimum, Vision Pro recommended)
**Test Count**: ~20 tests

#### What It Tests:
- Main menu appearance and elements
- Button navigation (New World, Load World, Settings)
- Settings view controls (Graphics, Audio, Gameplay)
- Game HUD visibility (Health bar, Hunger bar, Hotbar)
- World selection interface
- Accessibility features (VoiceOver labels, touch target sizes)
- Immersive space transitions
- UI responsiveness and performance
- Error handling UI
- Complete user flow scenarios

#### Key Test Methods:
- `testMainMenuAppears()`
- `testNewWorldButton()`
- `testSettingsNavigation()`
- `testGameHUDAppears()`
- `testHealthBarVisible()`
- `testHotbarSlots()`
- `testVoiceOverLabels()`
- `testMinimumTouchTargetSizes()`
- `testImmersiveSpaceTransition()`
- `testCompleteUserFlow()`

#### How to Run:
```bash
# In Xcode with Simulator
1. Open RealityMinecraft.xcodeproj
2. Select Vision Pro Simulator as destination
3. Product → Test (⌘U) or run UITests individually

# On Physical Vision Pro
1. Connect Vision Pro device
2. Select device as destination
3. Run UITests
# Note: Some tests may require user interaction
```

---

### 6. PerformanceTests.swift ⚡ PERFORMANCE BENCHMARKS

**Requires**: Xcode 16+, visionOS SDK 2.0+
**Device Required**: Vision Pro strongly recommended for accurate results
**Test Count**: ~30 tests

#### What It Tests:
- Block system performance (chunk creation, block access, filling)
- Entity system performance (creation, queries, updates, component operations)
- Inventory performance (operations, stacking)
- Crafting performance (recipe matching, operations)
- Physics performance (updates, collision detection)
- Event system performance (publish/subscribe)
- World persistence performance (save, load, list)
- Game state transition performance
- Memory usage (chunks, entities)
- Combined system performance (full game loop)
- Frame time consistency (90 FPS target)

#### Performance Targets:
- **Frame Rate**: 90 FPS sustained
- **Frame Time**: < 11ms per frame
- **Memory**: < 1.5 GB total
- **Chunk Operations**: < 1ms for single chunk access
- **Entity Updates**: 1000+ entities at 60 FPS

#### Key Test Methods:
- `testChunkCreationPerformance()`
- `testEntityQueryPerformance()`
- `testPhysicsUpdatePerformance()`
- `testFullGameLoopSimulation()`
- `testFrameTimeConsistency90FPS()`
- `testMemoryUsageChunks()`
- `testMemoryUsageEntities()`

#### How to Run:
```bash
# In Xcode (Best on Device)
1. Open RealityMinecraft.xcodeproj
2. Select Vision Pro device (not simulator for accurate results)
3. Product → Profile (⌘I) or run PerformanceTests
4. Review metrics in Test Results

# Note: Performance tests use XCTest measure() blocks
# Results will show baseline comparisons and standard deviations
```

---

### 7. VisionOSSpecificTests.swift 🥽 HARDWARE TESTS

**Requires**: Xcode 16+, visionOS SDK 2.0+, **Apple Vision Pro Device**
**Device Required**: **YES - MUST RUN ON VISION PRO**
**Test Count**: ~25 tests

#### What It Tests:
- World anchor creation and persistence
- World anchor removal
- Multiple world anchors
- Spatial mapping initialization
- Horizontal plane detection (floor)
- Vertical plane detection (walls)
- Raycast to surfaces
- Scene reconstruction (mesh anchors)
- Hand tracking initialization
- Hand visibility detection
- Pinch gesture detection
- Punch gesture detection
- Spread gesture detection
- Hand position tracking accuracy
- Both hands tracking simultaneously
- Gesture recognition accuracy
- Immersive space transitions
- Spatial audio positioning
- Spatial audio listener movement
- ARKit session initialization
- ARKit world tracking
- Device performance at 90 FPS
- Device memory under load
- Battery performance estimation
- Frame time variance for comfort
- Complete gameplay scenario integration

#### Key Test Methods:
- `testWorldAnchorCreation()`
- `testWorldAnchorPersistence()`
- `testPlaneDetection()`
- `testRaycastToSurface()`
- `testSceneReconstruction()`
- `testHandTrackingInitialization()`
- `testPinchGestureDetection()`
- `testHandPositionTracking()`
- `testSpatialAudioPositioning()`
- `testDevicePerformance90FPS()`
- `testFrameTimeVariance()`
- `testCompleteGameplayScenario()`

#### User Interaction Required:
Many tests require user actions:
- Show hands in tracking volume
- Perform gestures (pinch, spread, fist)
- Move hands for position tracking
- Look around room for plane detection

#### How to Run:
```bash
# ONLY on Physical Vision Pro
1. Connect Vision Pro to Mac
2. Open RealityMinecraft.xcodeproj
3. Select Vision Pro device as destination
4. Build and install app to device
5. Run VisionOSSpecificTests

# ⚠️ These tests WILL FAIL in simulator
# They require actual ARKit, hand tracking, and spatial hardware
```

---

## Test Execution Matrix

| Test Suite | Xcode Required | Simulator OK | Device Required | User Interaction |
|------------|----------------|--------------|-----------------|------------------|
| BlockSystemTests | ✅ Yes | ✅ Yes | ❌ No | ❌ No |
| InventoryTests | ✅ Yes | ✅ Yes | ❌ No | ❌ No |
| CraftingSystemTests | ✅ Yes | ✅ Yes | ❌ No | ❌ No |
| IntegrationTests | ✅ Yes | ✅ Yes | ❌ No | ❌ No |
| UITests | ✅ Yes | ⚠️ Partial | ✅ Recommended | ⚠️ Some tests |
| PerformanceTests | ✅ Yes | ⚠️ Inaccurate | ✅ Required | ❌ No |
| VisionOSSpecificTests | ✅ Yes | ❌ No | ✅ **REQUIRED** | ✅ **Yes** |

---

## Running Tests in Xcode

### Quick Start

1. **Open Project**
   ```bash
   cd /path/to/RealityMinecraft
   open RealityMinecraft.xcodeproj
   ```

2. **Run All Tests**
   - Press `⌘U` (Command + U)
   - All tests will run in sequence

3. **Run Specific Test Suite**
   - Open Test Navigator (`⌘6`)
   - Click play button next to specific test suite

4. **Run Individual Test**
   - Open test file in editor
   - Click diamond icon in gutter next to test method
   - Or right-click test method name → Run Test

### Setting Test Destination

1. **For Unit/Integration Tests**: Vision Pro Simulator
   - Click destination selector in toolbar
   - Choose "Vision Pro" under Simulators

2. **For Performance Tests**: Vision Pro Device
   - Connect Vision Pro
   - Choose device from destination selector

3. **For visionOS Tests**: Vision Pro Device (Required)
   - Must use physical device
   - Simulator will fail

### Viewing Test Results

1. **Test Navigator** (`⌘6`)
   - Green checkmarks: Passed
   - Red X: Failed
   - Click test for details

2. **Report Navigator** (`⌘9`)
   - Detailed test logs
   - Performance metrics
   - Memory usage graphs

3. **Performance Results**
   - Click test method
   - View baseline comparisons
   - See standard deviations

---

## Test Coverage Summary

### Coverage by System

| System | Unit Tests | Integration Tests | UI Tests | Performance Tests | Device Tests |
|--------|-----------|-------------------|----------|-------------------|--------------|
| Block System | ✅ 18 | ✅ 3 | ❌ | ✅ 4 | ❌ |
| Inventory | ✅ 23 | ✅ 2 | ✅ 3 | ✅ 3 | ❌ |
| Crafting | ✅ 19 | ✅ 2 | ❌ | ✅ 3 | ❌ |
| Entities | ❌ | ✅ 4 | ❌ | ✅ 5 | ❌ |
| Game State | ❌ | ✅ 2 | ✅ 5 | ✅ 1 | ✅ 1 |
| World Anchors | ❌ | ❌ | ❌ | ❌ | ✅ 5 |
| Spatial Mapping | ❌ | ❌ | ❌ | ❌ | ✅ 5 |
| Hand Tracking | ❌ | ❌ | ❌ | ❌ | ✅ 7 |
| Spatial Audio | ❌ | ❌ | ❌ | ❌ | ✅ 3 |
| Physics | ❌ | ❌ | ❌ | ✅ 2 | ❌ |
| Event System | ❌ | ✅ 2 | ❌ | ✅ 2 | ❌ |
| World Persistence | ❌ | ✅ 1 | ❌ | ✅ 3 | ❌ |
| UI/UX | ❌ | ❌ | ✅ 20 | ❌ | ❌ |

**Total Tests**: ~150+

---

## Why These Tests Cannot Run Without Xcode

### Technical Reasons:

1. **Swift Compilation Required**
   - Tests are written in Swift
   - Require Swift compiler from Xcode toolchain
   - Cannot run in Python, Node.js, or standard CLI environments

2. **XCTest Framework Dependency**
   - All tests use Apple's XCTest framework
   - XCTest is part of Xcode SDK
   - No standalone XCTest runner exists

3. **visionOS SDK Required**
   - Tests import visionOS-specific frameworks:
     - `@testable import Reality_Minecraft` (app module)
     - `import ARKit` (spatial features)
     - `import RealityKit` (3D rendering)
   - These SDKs only available in Xcode

4. **App Context Required**
   - Unit tests use `@testable import` to access internal types
   - Requires compiled app module
   - Cannot test without building full app

5. **Hardware Abstraction**
   - Many tests require ARKit, hand tracking, spatial audio
   - These features only work on Vision Pro hardware
   - Simulator provides limited support

### Alternative Testing Approaches:

Since tests cannot run outside Xcode, consider:

1. **Continuous Integration**
   - Use Xcode Cloud or GitHub Actions with macOS runners
   - Automate test execution on commit/PR
   - Example: `.github/workflows/xcode-tests.yml`

2. **Local Pre-commit Hooks**
   - Run quick unit tests before commit
   - Example: `.git/hooks/pre-commit` script

3. **Manual Test Sessions**
   - Schedule regular testing on Vision Pro device
   - Document test results
   - Track performance metrics over time

---

## Test Maintenance

### Adding New Tests

1. **Unit Tests**: Add to appropriate test file (BlockSystemTests, etc.)
2. **Integration Tests**: Add to IntegrationTests.swift
3. **UI Tests**: Add to UITests.swift
4. **New Systems**: Create new test file following naming convention

### Test Naming Convention

```swift
func test[SystemName][Scenario]() {
    // Example: testInventoryStackingWithMaxSize()
}
```

### Performance Test Baselines

Performance tests use XCTest baselines:
1. First run establishes baseline
2. Subsequent runs compare against baseline
3. Update baselines when making intentional performance changes

---

## Troubleshooting

### Common Issues

**Issue**: "Cannot find type 'Reality_Minecraft' in scope"
**Fix**: Build app target first (⌘B) before running tests

**Issue**: "No such module 'ARKit'"
**Fix**: Ensure visionOS SDK 2.0+ selected, deployment target is visionOS 2.0+

**Issue**: UITests fail with "App failed to launch"
**Fix**: Check Info.plist permissions, rebuild app, restart simulator

**Issue**: VisionOSSpecificTests fail immediately
**Fix**: Must run on physical Vision Pro device, not simulator

**Issue**: Hand tracking tests timeout
**Fix**: Ensure hands visible in tracking volume, grant hand tracking permission

**Issue**: Performance tests show high variance
**Fix**: Close other apps, run on device (not simulator), disable debugging

---

## Performance Benchmarks

Expected performance on Apple Vision Pro:

| Metric | Target | Acceptable | Critical |
|--------|--------|------------|----------|
| Frame Rate | 90 FPS | > 85 FPS | < 80 FPS |
| Frame Time | < 11ms | < 12ms | > 15ms |
| Memory | < 1.2 GB | < 1.5 GB | > 2 GB |
| Chunk Load | < 1ms | < 2ms | > 5ms |
| Entity Update (1000) | < 8ms | < 10ms | > 15ms |

---

## Contributing Tests

When adding new features, include:
- ✅ Unit tests for isolated logic
- ✅ Integration tests for system interactions
- ✅ UI tests if adding UI components
- ✅ Performance tests for critical systems
- ✅ visionOS tests if using spatial features

---

## Test Documentation Standards

Each test should include:
```swift
func testFeatureName() {
    // GIVEN: Setup initial state
    let inventory = Inventory(maxSlots: 36)

    // WHEN: Perform action
    inventory.addItem("dirt", quantity: 64)

    // THEN: Verify result
    XCTAssertEqual(inventory.getItemQuantity("dirt"), 64)
}
```

---

**Last Updated**: 2025-11-19
**Test Suite Version**: 1.0.0
**Total Test Coverage**: Unit (60), Integration (15), UI (20), Performance (30), Device (25)
