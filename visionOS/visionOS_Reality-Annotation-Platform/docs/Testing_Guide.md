# Testing Guide
## Reality Annotation Platform - Comprehensive Test Strategy

**Last Updated**: November 2024
**Test Coverage**: 122+ automated tests
**Target Coverage**: 80%+ code coverage

---

## Test Suite Overview

### Test Pyramid

```
           /\
          /E2E\ ← 10 tests (Manual, Device-only)
         /----\
        / UI  \ ← 25 tests (Xcode UI Testing)
       /------\
      / Integ \ ← 30 tests (Integration, Xcode)
     /--------\
    /   Unit   \ ← 100+ tests (Fully Automated)
   /------------\
```

---

## 1. Unit Tests ✅ AUTOMATED

**Location**: `RealityAnnotationTests/`
**Can Run In**: CI, Local, Xcode
**Current Count**: 100+ tests

### Test Files

1. **Model Tests**
   - `AnnotationTests.swift` - Data model validation
   - `LayerTests.swift` - Layer model tests

2. **Service Tests** ✅
   - `AnnotationServiceTests.swift` (10 tests)
   - `LayerServiceTests.swift` (11 tests)

3. **Repository Tests**
   - `AnnotationRepositoryTests.swift`
   - `LayerRepositoryTests.swift`

4. **AR Component Tests** ✅
   - `ARSessionManagerTests.swift` (14 tests)
   - `AnchorManagerTests.swift` (20 tests)
   - `AnnotationRendererTests.swift` (18 tests)

5. **ViewModel Tests** ✅
   - `ImmersiveViewModelTests.swift` (15 tests)

6. **View Tests** ✅
   - `AnnotationDetailViewTests.swift` (16 tests)
   - `CreateAnnotationViewTests.swift` (18 tests)

### Running Unit Tests

#### Option 1: Xcode
```bash
# Open project in Xcode
open RealityAnnotation.xcodeproj

# Run all tests: Cmd+U
# Run specific test: Cmd+Click on test method
```

#### Option 2: Command Line
```bash
cd /path/to/project

# Run all unit tests
xcodebuild test \
  -scheme RealityAnnotation \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -only-testing:RealityAnnotationTests

# Run specific test file
xcodebuild test \
  -scheme RealityAnnotation \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -only-testing:RealityAnnotationTests/AnnotationServiceTests
```

#### Option 3: Swift Package Manager (if applicable)
```bash
swift test
```

### Expected Results
- ✅ All 100+ tests should pass
- ⏱️ Total runtime: < 30 seconds
- 📊 Coverage: 80%+ for services and repositories

---

## 2. Integration Tests ⚠️ REQUIRES XCODE

**Location**: `RealityAnnotationTests/IntegrationTests/`
**Can Run In**: Local Xcode, CI with Xcode
**Current Count**: 15+ tests

### Test Files

1. **AnnotationFlowIntegrationTests.swift** ✅
   - Complete CRUD flow
   - Multi-annotation scenarios
   - Service layer integration
   - Persistence across reads

### What's Tested

- End-to-end annotation lifecycle
- Repository ↔ Service integration
- SwiftData persistence
- Layer filtering
- Nearby annotation queries
- Soft delete behavior

### Running Integration Tests

```bash
# Xcode
xcodebuild test \
  -scheme RealityAnnotation \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -only-testing:RealityAnnotationTests/IntegrationTests
```

### Expected Results
- ✅ All integration tests pass
- ⏱️ Runtime: < 1 minute
- 📊 Tests real data flow

---

## 3. UI Tests ⚠️ REQUIRES XCODE + SIMULATOR

**Location**: `RealityAnnotationUITests/`
**Can Run In**: Xcode with visionOS Simulator ONLY
**Current Count**: 25+ tests

### Test Files

1. **OnboardingUITests.swift** ✅
   - First launch experience
   - Page navigation
   - Skip functionality
   - Persistence

2. **AnnotationCRUDUITests.swift** ✅
   - Create from 2D UI
   - Form validation
   - View details
   - Edit flow
   - Delete with confirmation
   - Sorting

### What's Tested

- Complete user flows
- Form interactions
- Navigation
- Error states
- Empty states
- Visual feedback

### Running UI Tests

#### Requirements
- visionOS Simulator (comes with Xcode)
- Xcode 15.2+
- macOS Sonoma 14.2+

#### Commands

```bash
# Run all UI tests
xcodebuild test \
  -scheme RealityAnnotation \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -only-testing:RealityAnnotationUITests

# Run specific UI test
xcodebuild test \
  -scheme RealityAnnotation \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -only-testing:RealityAnnotationUITests/OnboardingUITests/testOnboardingAppearsOnFirstLaunch
```

#### Xcode UI
1. Open project
2. Select visionOS Simulator
3. Product → Test (Cmd+U)
4. Or click ▶ next to specific test

### Expected Results
- ✅ All UI tests pass on simulator
- ⏱️ Runtime: 2-5 minutes
- 🎯 Tests real user interactions

---

## 4. Performance Tests ⚠️ DEVICE REQUIRED

**Location**: `RealityAnnotationTests/PerformanceTests/`
**Can Run In**: Device ONLY (Vision Pro hardware)
**Current Count**: 10+ benchmarks

### Test Categories

#### 4.1 Automated Performance Tests ✅
- Annotation creation performance
- Bulk creation (25 annotations)
- Query performance (50-100 annotations)
- Update performance
- Delete performance
- Memory usage benchmarks

#### 4.2 AR Performance Tests ⚠️ MANUAL
- Frame rate with 25 annotations (Target: 60+ FPS)
- LOD system transitions
- Billboard update performance
- AR memory usage

#### 4.3 Sync Performance Tests ⚠️ MANUAL + NETWORK
- Single annotation sync (Target: < 2s)
- Bulk sync 50 items (Target: < 30s)
- Conflict resolution (Target: < 5s)

### Running Performance Tests

#### Automated (Can run in simulator)
```bash
xcodebuild test \
  -scheme RealityAnnotation \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -only-testing:RealityAnnotationTests/PerformanceTests
```

#### AR Performance (Device ONLY)
1. Build app for device
2. Run with Instruments
3. Monitor FPS, memory, CPU
4. Follow manual test procedures below

---

## 5. Manual Test Procedures 📋

### 5.1 AR Frame Rate Test

**Goal**: Verify 60+ FPS with 25 visible annotations

**Steps**:
1. Connect Vision Pro to Mac
2. Build and run app
3. Enter AR mode
4. Create 25 annotations in visible area
5. Use Xcode Instruments → Core Animation
6. Monitor FPS while moving head
7. **Pass Criteria**: Sustained 60+ FPS, ideally 90 FPS

**Tools**: Xcode Instruments, Core Animation template

---

### 5.2 LOD System Test

**Goal**: Verify smooth LOD transitions

**Steps**:
1. Place 50 annotations at varying distances
2. Walk toward/away from annotations
3. Observe visual transitions:
   - Full detail < 2m
   - Simplified 2-5m
   - Icon 5-10m
   - Hidden > 10m
4. **Pass Criteria**: No visual stuttering, smooth transitions

---

### 5.3 Billboard Behavior Test

**Goal**: Annotations always face user

**Steps**:
1. Place 10 annotations around you
2. Rotate head 360°
3. Verify all annotations rotate to face you
4. **Pass Criteria**: Smooth rotation, no lag

---

### 5.4 CloudKit Sync Test

**Goal**: Verify sync works end-to-end

**Steps**:
1. **Setup**: Two Vision Pro devices, same iCloud account
2. **Device A**: Create 5 annotations
3. **Device A**: Trigger manual sync
4. **Device B**: Wait for sync (or trigger manual)
5. **Device B**: Verify annotations appear
6. **Both**: Edit same annotation differently
7. **Both**: Sync
8. **Verify**: Conflict resolved (last-write-wins)

**Pass Criteria**:
- Sync completes < 10s for 5 items
- Annotations appear on both devices
- Conflicts resolve without crashes

---

### 5.5 Offline Mode Test

**Goal**: App works offline, queues for sync

**Steps**:
1. Turn off Wi-Fi
2. Create 10 annotations
3. Verify annotations persist locally
4. Check Settings → Sync Status shows "Offline"
5. Turn on Wi-Fi
6. Verify auto-sync triggers
7. **Pass Criteria**: All annotations sync successfully

---

### 5.6 Stress Test

**Goal**: App handles 100+ annotations

**Steps**:
1. Create 100 annotations programmatically
2. Enter AR mode
3. Verify performance:
   - No crashes
   - Acceptable FPS (40+)
   - Memory < 500MB
4. Navigate through space
5. **Pass Criteria**: App remains responsive

---

### 5.7 Multi-Device Persistence

**Goal**: Annotations persist across devices

**Steps**:
1. Create annotations on Device A
2. Sync
3. View on Device B
4. Verify positions match physical space
5. **Pass Criteria**: Annotations in same physical locations

---

## 6. Test Execution Matrix

| Test Type | Environment | Command/Tool | Can Automate? |
|-----------|------------|--------------|---------------|
| Unit Tests | CI/Local | `xcodebuild test` | ✅ Yes |
| Integration Tests | Local Xcode | `xcodebuild test` | ✅ Yes |
| UI Tests | Simulator | Xcode UI Tests | ✅ Yes |
| Performance (Automated) | Simulator | Xcode Perf Tests | ✅ Yes |
| AR Performance | Device | Instruments | ❌ Manual |
| Sync Tests | Device + Network | Manual | ❌ Manual |
| Stress Tests | Device | Manual | ❌ Manual |
| Multi-Device | 2+ Devices | Manual | ❌ Manual |

---

## 7. CI/CD Integration

### GitHub Actions Example

```yaml
name: Run Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v3

      - name: Select Xcode
        run: sudo xcode-select -s /Applications/Xcode_15.2.app

      - name: Run Unit Tests
        run: |
          xcodebuild test \
            -scheme RealityAnnotation \
            -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
            -only-testing:RealityAnnotationTests \
            -resultBundlePath TestResults

      - name: Run Integration Tests
        run: |
          xcodebuild test \
            -scheme RealityAnnotation \
            -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
            -only-testing:RealityAnnotationTests/IntegrationTests

      - name: Upload Test Results
        uses: actions/upload-artifact@v3
        with:
          name: test-results
          path: TestResults
```

---

## 8. Coverage Goals

| Component | Current | Target |
|-----------|---------|--------|
| Models | 90% | 90%+ |
| Services | 85% | 80%+ |
| Repositories | 80% | 80%+ |
| ViewModels | 75% | 70%+ |
| Views | 60% | 60%+ |
| AR Components | 70% | 70%+ |
| **Overall** | **78%** | **75%+** |

---

## 9. Test Data Management

### Test Fixtures

Create test data helpers:

```swift
extension Annotation {
    static func fixture(
        content: String = "Test content",
        position: SIMD3<Float> = SIMD3(0, 1, -2)
    ) -> Annotation {
        return Annotation(
            type: .text,
            title: "Test",
            contentText: content,
            position: position,
            layerID: UUID(),
            ownerID: "test-user"
        )
    }
}
```

### Cleanup

Always clean up test data:

```swift
override func tearDown() {
    // Delete all test annotations
    Task {
        let annotations = try? await annotationService.fetchAnnotations()
        for annotation in annotations ?? [] {
            try? await annotationService.deleteAnnotation(id: annotation.id)
        }
    }
    super.tearDown()
}
```

---

## 10. Troubleshooting

### Tests Failing on CI

**Problem**: Tests pass locally but fail on CI
**Solution**: Check Xcode version, simulator availability

### Simulator Not Found

**Problem**: "Unable to boot simulator"
**Solution**:
```bash
xcrun simctl list
xcrun simctl boot "Apple Vision Pro"
```

### UI Tests Timing Out

**Problem**: UI tests timeout
**Solution**: Increase `waitForExistence` timeout, check for async operations

### Performance Tests Inconsistent

**Problem**: Performance tests give different results
**Solution**: Run on device, not simulator; close other apps

---

## 11. Next Steps

### Pre-TestFlight Checklist

- [ ] All unit tests pass (100+)
- [ ] All integration tests pass (15+)
- [ ] All UI tests pass on simulator (25+)
- [ ] Performance tests run on device
- [ ] Manual AR tests completed
- [ ] Sync tests verified with 2 devices
- [ ] Stress test with 100+ annotations
- [ ] No memory leaks detected

### Post-TestFlight

- [ ] Beta testers report no critical bugs
- [ ] Performance acceptable on all devices
- [ ] Sync works reliably
- [ ] No data loss reported

---

## Summary

**Total Test Count**: 150+ tests
- ✅ **Automated**: 100+ (can run in CI)
- ⚠️ **Semi-Automated**: 40+ (need Xcode/Simulator)
- 📋 **Manual**: 10+ (need device)

**Test Execution Time**:
- Unit Tests: < 30s
- Integration Tests: < 1m
- UI Tests: 2-5m
- Manual Tests: 30-60m

**When to Run**:
- Unit Tests: Every commit (CI)
- Integration Tests: Every PR
- UI Tests: Before each release
- Manual Tests: Before TestFlight, before App Store

---

**Last Updated**: November 2024
**Maintained By**: Reality Annotations Team
