# Tactical Team Shooters - Testing Suite

## Overview

This comprehensive testing suite ensures **Tactical Team Shooters** is production-ready for Apple Vision Pro. The suite covers unit tests, integration tests, and documents Vision Pro-specific tests that require physical hardware.

## Test Coverage

**Target Coverage**: 80%+ code coverage
**Testing Pyramid**:
- 60% Unit Tests
- 30% Integration Tests
- 10% End-to-End Tests

## Quick Start

### Running Tests (Xcode)

```bash
# Run all tests
xcodebuild test -scheme TacticalTeamShooters

# Run specific test suite
xcodebuild test -scheme TacticalTeamShooters -only-testing:TacticalTeamShootersTests/PlayerTests

# Run with code coverage
xcodebuild test -scheme TacticalTeamShooters -enableCodeCoverage YES
```

### Running Tests (Swift Package Manager)

```bash
# Run all tests
swift test

# Run specific test
swift test --filter PlayerTests

# Run with parallel execution
swift test --parallel
```

## Test Structure

```
Tests/
├── Models/              # Unit tests for data models
│   ├── PlayerTests.swift
│   ├── WeaponTests.swift
│   └── TeamTests.swift
├── Integration/         # Integration tests
│   └── NetworkIntegrationTests.swift
└── README.md           # This file
```

## Test Suites

### 1. Unit Tests - Models

#### PlayerTests.swift
Tests the `Player` model including stats, progression, and event recording.

**Test Coverage**:
- ✅ Player initialization (default and custom)
- ✅ KDR calculations (with/without deaths)
- ✅ Win rate calculations
- ✅ Kill recording (regular and headshot)
- ✅ Death and assist recording
- ✅ Accuracy tracking
- ✅ Competitive rank system (Recruit to Legend)
- ✅ Team role assignments
- ✅ Codable conformance

**Run Command**:
```bash
swift test --filter PlayerTests
```

#### WeaponTests.swift
Tests the `Weapon` system including stats, balance, and attachments.

**Test Coverage**:
- ✅ Weapon initialization (AK-47, M4A1, AWP, Glock)
- ✅ Weapon stats (damage, fire rate, accuracy)
- ✅ Damage per second calculations
- ✅ Time to kill calculations
- ✅ Sniper one-shot mechanics
- ✅ Weapon type display names
- ✅ Weapon categories
- ✅ Recoil patterns (AK-47, M4)
- ✅ Attachment system
- ✅ Weapon modifiers
- ✅ Equipment system
- ✅ Weapon balance (AK vs M4)
- ✅ Codable conformance

**Run Command**:
```bash
swift test --filter WeaponTests
```

#### TeamTests.swift
Tests the `Team` and `Match` models including team management and match flow.

**Test Coverage**:
- ✅ Team initialization
- ✅ Player management (add/remove)
- ✅ Team size limits (5 players max)
- ✅ Match creation
- ✅ Round management
- ✅ Score tracking
- ✅ Side swapping (attackers/defenders)
- ✅ Codable conformance

**Run Command**:
```bash
swift test --filter TeamTests
```

### 2. Integration Tests

#### NetworkIntegrationTests.swift
Tests multiplayer networking, serialization, and data synchronization.

**Test Coverage**:
- ✅ PlayerInput serialization
- ✅ GameStateSnapshot serialization
- ✅ SIMD vector Codable conformance
- ✅ Quaternion Codable conformance
- ✅ Network message integrity
- ✅ Client-server data flow

**Run Command**:
```bash
swift test --filter NetworkIntegrationTests
```

## Vision Pro-Specific Tests

**⚠️ These tests require physical Apple Vision Pro hardware.**

Comprehensive documentation available in:
- **[VISIONOS_TESTING_GUIDE.md](../VISIONOS_TESTING_GUIDE.md)** - Complete guide for Vision Pro testing
- **[TESTING_STRATEGY.md](../TESTING_STRATEGY.md)** - Overall testing strategy

### Hardware-Required Test Categories

1. **ARKit Integration Tests** (~8 hours)
   - Room scanning accuracy
   - Spatial anchor persistence
   - Plane detection
   - World tracking stability

2. **Hand Tracking Tests** (~6 hours)
   - Gesture recognition
   - Precision aiming
   - Reload gestures
   - Equipment selection

3. **Eye Tracking Tests** (~4 hours)
   - Gaze-based aiming
   - Menu navigation
   - Focus indicators

4. **Spatial Audio Tests** (~6 hours)
   - 3D positional accuracy
   - Distance attenuation
   - Occlusion effects
   - Head-relative audio

5. **Room Mapping Tests** (~5 hours)
   - Multi-room support
   - Dynamic cover generation
   - Safety boundary detection

6. **Immersive Space Tests** (~4 hours)
   - Progressive immersion
   - Full immersion stability
   - Transition smoothness

7. **Performance Tests** (~8 hours)
   - 120 FPS maintenance
   - Thermal performance
   - Battery life

8. **Comfort & Accessibility** (~5 hours)
   - Motion sickness prevention
   - Visual comfort
   - Accessibility features

9. **UI/UX Tests** (~4 hours)
   - Menu readability
   - HUD positioning
   - Spatial UI interaction

10. **End-to-End Tests** (~4 hours)
    - Complete match playthrough
    - Multiplayer scenarios

**Total Vision Pro Testing Time**: ~54 hours

## Test Execution Results

### Current Status (Runnable Tests)

| Test Suite | Tests | Passed | Failed | Coverage |
|------------|-------|--------|--------|----------|
| PlayerTests | 20+ | ✅ | - | Model layer |
| WeaponTests | 20+ | ✅ | - | Weapon system |
| TeamTests | 15+ | ✅ | - | Team management |
| NetworkIntegrationTests | 5+ | ✅ | - | Networking |

### Tests Requiring Vision Pro

| Test Category | Status | Hardware Required |
|--------------|--------|-------------------|
| ARKit Tests | 📋 Documented | ✅ Vision Pro |
| Hand Tracking | 📋 Documented | ✅ Vision Pro |
| Eye Tracking | 📋 Documented | ✅ Vision Pro |
| Spatial Audio | 📋 Documented | ✅ Vision Pro |
| Room Mapping | 📋 Documented | ✅ Vision Pro |
| Performance | 📋 Documented | ✅ Vision Pro |
| Comfort | 📋 Documented | ✅ Vision Pro |

## Test Data & Fixtures

### Predefined Test Players

```swift
let testPlayer = Player(username: "TestPlayer", rank: .recruit)
let veteranPlayer = Player(username: "VeteranPlayer", rank: .veteran, teamRole: .sniper)
```

### Predefined Test Weapons

```swift
let ak47 = Weapon.ak47
let m4a1 = Weapon.m4a1
let awp = Weapon.awp
let glock = Weapon.glock
```

### Mock Data

All tests use isolated mock data and do not affect production databases or player accounts.

## Continuous Integration

### GitHub Actions (Future)

```yaml
name: Run Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run tests
        run: swift test --enable-code-coverage
      - name: Generate coverage report
        run: xcrun llvm-cov export
```

### Pre-commit Hooks (Future)

```bash
#!/bin/bash
# .git/hooks/pre-commit
swift test || exit 1
```

## Code Coverage

### Generating Coverage Reports

```bash
# Generate coverage data
xcodebuild test -scheme TacticalTeamShooters -enableCodeCoverage YES

# View coverage report
xcrun llvm-cov show \
  .build/debug/TacticalTeamShootersPackageTests.xctest/Contents/MacOS/TacticalTeamShootersPackageTests \
  -instr-profile .build/debug/codecov/default.profdata
```

### Coverage Goals

| Component | Target Coverage |
|-----------|----------------|
| Models | 90%+ |
| Game Logic | 85%+ |
| Networking | 80%+ |
| UI Components | 70%+ |
| Overall | 80%+ |

## Performance Testing

### Benchmarks

```swift
func testWeaponStatsPerformance() {
    measure {
        for _ in 0..<1000 {
            let weapon = Weapon.ak47
            _ = weapon.stats.damagePerSecond
        }
    }
}
```

### Performance Baselines

- Model initialization: < 1ms
- Stats calculation: < 0.1ms
- Serialization (Player): < 5ms
- Network message encoding: < 2ms

## Debugging Tests

### Common Issues

**Issue**: Test fails with "Module not found"
```bash
# Solution: Clean build folder
rm -rf .build
swift build
swift test
```

**Issue**: Flaky networking tests
```bash
# Solution: Run tests sequentially
swift test --parallel --num-workers 1
```

**Issue**: Vision Pro simulator limitations
```bash
# Solution: Check VISIONOS_TESTING_GUIDE.md for hardware requirements
```

### Verbose Test Output

```bash
swift test --verbose
```

### Running Single Test

```bash
swift test --filter testAK47Initialization
```

## Test Best Practices

### Writing New Tests

1. **Follow AAA Pattern**: Arrange, Act, Assert
```swift
func testPlayerKill() {
    // Arrange
    var player = Player(username: "Test")

    // Act
    player.stats.recordKill(headshot: true)

    // Assert
    XCTAssertEqual(player.stats.kills, 1)
}
```

2. **Use Descriptive Names**: `testPlayerStatsKDRWithNoDeaths`
3. **Test One Thing**: Each test should verify one behavior
4. **Avoid Test Interdependence**: Tests should run in any order
5. **Use XCTAssertEqual with Accuracy**: For floating-point comparisons

### Test Naming Convention

```
test[Component][Behavior][Condition]
```

Examples:
- `testPlayerInitializationWithCustomRank`
- `testWeaponDamagePerSecond`
- `testSniperOneShot`

## Documentation

- **[TESTING_STRATEGY.md](../TESTING_STRATEGY.md)** - Complete testing strategy
- **[VISIONOS_TESTING_GUIDE.md](../VISIONOS_TESTING_GUIDE.md)** - Vision Pro testing guide
- **[ARCHITECTURE.md](../ARCHITECTURE.md)** - System architecture
- **[TECHNICAL_SPEC.md](../TECHNICAL_SPEC.md)** - Technical specifications

## Contributing

### Adding New Tests

1. Create test file in appropriate directory
2. Follow naming conventions
3. Add documentation to this README
4. Update coverage goals
5. Run all tests before committing

### Test Review Checklist

- [ ] Tests are independent
- [ ] Tests have descriptive names
- [ ] Tests follow AAA pattern
- [ ] Tests include edge cases
- [ ] Tests are fast (< 100ms each)
- [ ] Tests don't require network/disk
- [ ] Tests are documented

## Support

For questions or issues with testing:
1. Check [TESTING_STRATEGY.md](../TESTING_STRATEGY.md)
2. Review [VISIONOS_TESTING_GUIDE.md](../VISIONOS_TESTING_GUIDE.md)
3. Run tests with `--verbose` flag
4. Check test execution logs

## License

All test code is part of the Tactical Team Shooters project and follows the same license.

---

**Last Updated**: 2025-11-19
**Test Suite Version**: 1.0.0
**Minimum visionOS**: 2.0+
**Minimum Swift**: 6.0+
