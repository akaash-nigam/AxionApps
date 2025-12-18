# Reality Minecraft Test Suite

Comprehensive test coverage for Reality Minecraft visionOS game.

## 📋 Test Files

- **BlockSystemTests.swift** - Unit tests for block and chunk systems (18 tests)
- **InventoryTests.swift** - Unit tests for inventory management (23 tests)
- **CraftingSystemTests.swift** - Unit tests for crafting recipes (19 tests)
- **IntegrationTests.swift** - Integration tests for system interactions (15 tests)
- **UITests.swift** - UI and interaction tests (20 tests)
- **PerformanceTests.swift** - Performance benchmarks (30 tests)
- **VisionOSSpecificTests.swift** - Hardware-specific tests (25 tests)

**Total**: ~150 tests

## ⚠️ Important: Execution Requirements

**All tests require Xcode 16+ to run.** These are Swift/XCTest tests that cannot execute in standard CLI environments.

### Quick Reference

| Test Type | Xcode | Simulator | Vision Pro | User Action |
|-----------|-------|-----------|------------|-------------|
| Unit Tests | ✅ | ✅ | ❌ | ❌ |
| Integration | ✅ | ✅ | ❌ | ❌ |
| UI Tests | ✅ | ⚠️ | ✅ | ⚠️ |
| Performance | ✅ | ⚠️ | ✅ | ❌ |
| visionOS | ✅ | ❌ | ✅ | ✅ |

## 🚀 Quick Start

### Running All Tests

```bash
# Open Xcode project
open RealityMinecraft.xcodeproj

# Press ⌘U to run all tests
```

### Running Specific Test Suite

1. Open Test Navigator (⌘6)
2. Find desired test suite
3. Click play button

### Running Individual Test

1. Open test file
2. Click diamond icon next to test method
3. Or right-click → Run Test

## 📊 Test Categories

### Unit Tests (Pure Logic)
Run in simulator, no device needed:
- BlockSystemTests
- InventoryTests
- CraftingSystemTests

### Integration Tests
Require full app context, run in simulator:
- IntegrationTests

### UI Tests
Best on device, partial support in simulator:
- UITests

### Performance Tests
**Must run on Vision Pro device** for accurate metrics:
- PerformanceTests

### visionOS Hardware Tests
**Must run on Vision Pro device**, requires user interaction:
- VisionOSSpecificTests

## 📖 Documentation

See **TEST_GUIDE.md** for comprehensive documentation including:
- Detailed test descriptions
- How to run each test suite
- Performance benchmarks
- Troubleshooting guide
- Test coverage matrix

## 🎯 Performance Targets

- **90 FPS** sustained frame rate
- **< 11ms** frame time
- **< 1.5GB** memory usage
- **1000+ entities** at 60 FPS

## 🧪 Test Coverage

- Block System: ✅ Comprehensive
- Inventory: ✅ Comprehensive
- Crafting: ✅ Comprehensive
- Entity System: ✅ Integration covered
- Physics: ✅ Performance covered
- World Anchors: ✅ Device tests
- Hand Tracking: ✅ Device tests
- Spatial Mapping: ✅ Device tests
- UI/UX: ✅ Full flow tests

## ⚙️ Setup

### Requirements
- macOS 14.0+
- Xcode 16.0+
- visionOS SDK 2.0+
- Apple Vision Pro (for device-specific tests)

### First Time Setup

1. Open project in Xcode
2. Build project (⌘B)
3. Run tests (⌘U)
4. First performance test run establishes baseline

## 🐛 Troubleshooting

**Cannot find module**: Build app target first (⌘B)

**UITests fail to launch**: Check Info.plist permissions, rebuild

**VisionOS tests fail**: Must use physical Vision Pro device

**Performance variance**: Run on device, close other apps

See TEST_GUIDE.md for detailed troubleshooting.

## 📝 Adding Tests

When adding features, include:
1. Unit tests for isolated logic
2. Integration tests for system interactions
3. UI tests for interface components
4. Performance tests for critical systems
5. visionOS tests for spatial features

Follow naming convention:
```swift
func test[System][Scenario]() {
    // Test implementation
}
```

## 📞 Support

For detailed test documentation, see:
- TEST_GUIDE.md (comprehensive guide)
- Individual test files (inline documentation)
- Main README.md (project overview)

---

**Version**: 1.0.0
**Last Updated**: 2025-11-19
**Total Tests**: 150+
