# Testing Guide for Spatial Screenplay Workshop

This document outlines all test types for the visionOS Spatial Screenplay Workshop application, including tests that can be run in the current environment and those that require visionOS hardware/simulator.

## Test Status

✅ = Can be run in current environment
⏳ = Requires visionOS simulator
🎯 = Requires physical visionOS device

---

## 1. Unit Tests ✅

### SpatialLayoutEngineTests ✅
**Status**: Implemented and can be run
**Location**: `SpatialScreenplayWorkshopTests/SpatialLayoutEngineTests.swift`

Tests the spatial layout algorithm for positioning scene cards in 3D space.

**Test Cases**:
- ✅ `testCalculatePositions_ReturnsAllScenes` - Verifies all scenes get positions
- ✅ `testCalculatePositions_GroupsByAct` - Validates act grouping by Z-depth
- ✅ `testCalculatePositions_NoOverlaps` - Ensures cards don't overlap
- ✅ `testCalculateInsertPosition_ValidIndex` - Tests dynamic insertion
- ✅ `testGetActDividerPositions_CreatesCorrectDividers` - Validates act dividers
- ✅ `testValidate_WithinBounds` - Checks container boundary validation
- ✅ `testCalculateBoundingBox_CorrectBounds` - Tests bounding box calculation
- ✅ `testCalculatePositions_SingleScene` - Edge case: single scene
- ✅ `testCalculatePositions_EmptyScenes` - Edge case: empty scene list
- ✅ `testCalculatePositions_ManyScenes` - Stress test with 50 scenes
- ✅ `testCalculatePositions_Performance` - Performance test with 100 scenes

**To Run**:
```bash
swift test --filter SpatialLayoutEngineTests
```

### PageCalculatorTests ✅
**Status**: Should be implemented
**Location**: `SpatialScreenplayWorkshopTests/PageCalculatorTests.swift`

**Test Cases to Implement**:
- Calculate page count from text
- Calculate page count for scene
- Validate 55 lines per page
- Test word counting
- Test dialogue vs action ratios

### ScriptFormatterTests ✅
**Status**: Should be implemented
**Location**: `SpatialScreenplayWorkshopTests/ScriptFormatterTests.swift`

**Test Cases to Implement**:
- Format slug lines correctly
- Format dialogue with proper margins
- Format action lines
- Handle transitions
- Validate margin calculations

### ElementDetectorTests ✅
**Status**: Should be implemented
**Location**: `SpatialScreenplayWorkshopTests/ElementDetectorTests.swift`

**Test Cases to Implement**:
- Detect slug lines (INT./EXT.)
- Detect character names (all caps)
- Detect parenthetical (wrapped in parens)
- Detect transitions (ends with TO:)
- Parse slug line components

---

## 2. Integration Tests ⏳

These tests require the visionOS simulator to run.

### TimelineIntegrationTests ⏳
**Status**: Not yet implemented
**Location**: `SpatialScreenplayWorkshopTests/TimelineIntegrationTests.swift`

**Test Cases to Implement**:
- Load project into timeline
- Create scene cards for all scenes
- Position cards using layout engine
- Update timeline when scenes change
- Handle scene reordering
- Validate RealityKit entity hierarchy

**To Run** (requires visionOS simulator):
```bash
xcodebuild test \
  -scheme SpatialScreenplayWorkshop \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -testPlan IntegrationTests
```

### ScriptEditorIntegrationTests ⏳
**Status**: Not yet implemented
**Location**: `SpatialScreenplayWorkshopTests/ScriptEditorIntegrationTests.swift`

**Test Cases to Implement**:
- Load scene into editor
- Auto-detect element types
- Calculate page count in real-time
- Save changes back to scene
- Undo/redo operations
- Character auto-complete

---

## 3. UI Tests ⏳

UI tests require visionOS simulator or device.

### ProjectListUITests ⏳
**Status**: Not yet implemented
**Location**: `SpatialScreenplayWorkshopUITests/ProjectListUITests.swift`

**Test Cases to Implement**:
- Display list of projects
- Create new project
- Tap project card to open
- Display project metadata correctly
- Filter projects by status

### TimelineUITests ⏳
**Status**: Not yet implemented
**Location**: `SpatialScreenplayWorkshopUITests/TimelineUITests.swift`

**Test Cases to Implement**:
- Display scene cards in 3D
- Cards render with correct colors
- Act labels visible
- Toolbar functional
- Add scene button works
- Filter dropdown works

### ScriptEditorUITests ⏳
**Status**: Not yet implemented
**Location**: `SpatialScreenplayWorkshopUITests/ScriptEditorUITests.swift`

**Test Cases to Implement**:
- Editor displays scene text
- Toolbar buttons functional
- Statistics update in real-time
- Save button works
- Undo/redo buttons work
- Metadata panel opens

**To Run** (requires visionOS simulator):
```bash
xcodebuild test \
  -scheme SpatialScreenplayWorkshop \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -testPlan UITests
```

---

## 4. Spatial Interaction Tests 🎯

These tests require a physical Apple Vision Pro device to properly test spatial gestures and eye tracking.

### TimelineSpatialGestureTests 🎯
**Status**: Not yet implemented
**Location**: `SpatialScreenplayWorkshopUITests/TimelineSpatialGestureTests.swift`

**Test Cases to Implement**:
- **Tap gesture**: Tap scene card to select
- **Double-tap gesture**: Double-tap to open editor
- **Drag gesture**: Drag card to reorder scenes
- **Hover effect**: Gaze at card to show hover state
- **Pinch gesture**: Pinch to zoom timeline
- **3D positioning**: Verify cards positioned correctly in space
- **Depth perception**: Validate act depth layering
- **Field of view**: Test cards visible at 2-4 meter distance

### ImmersiveEditorTests 🎯
**Status**: Not yet implemented (future Sprint 4+)
**Location**: `SpatialScreenplayWorkshopUITests/ImmersiveEditorTests.swift`

**Test Cases to Implement**:
- Open immersive editor space
- Floating editor panels respond to gestures
- Voice input works
- Spatial keyboard functional
- Can exit immersive mode

**To Run** (requires physical device):
```bash
# Must run on connected Apple Vision Pro device
xcodebuild test \
  -scheme SpatialScreenplayWorkshop \
  -destination 'platform=visionOS,name=<Device Name>' \
  -testPlan SpatialInteractionTests
```

---

## 5. Performance Tests ⏳

### Timeline Performance Tests ⏳
**Status**: Not yet implemented
**Location**: `SpatialScreenplayWorkshopTests/TimelinePerformanceTests.swift`

**Test Cases to Implement**:
- **Frame rate**: Maintain 60+ FPS with 50 scene cards
- **Memory usage**: Stay under 500MB with large projects
- **Layout performance**: Calculate positions in < 16ms
- **Animation smoothness**: Card animations at 60fps
- **Gesture latency**: < 100ms response to taps

**Metrics to Track**:
- Frame rate (target: 60+ FPS)
- Memory footprint (target: < 500MB)
- CPU usage (target: < 50%)
- Layout calculation time (target: < 16ms)
- Gesture response time (target: < 100ms)

### Editor Performance Tests ⏳
**Status**: Not yet implemented
**Location**: `SpatialScreenplayWorkshopTests/EditorPerformanceTests.swift`

**Test Cases to Implement**:
- Type 1000 characters smoothly
- Calculate page count in < 50ms
- Undo/redo in < 100ms
- Auto-save in background without lag

**To Run** (requires visionOS simulator):
```bash
xcodebuild test \
  -scheme SpatialScreenplayWorkshop \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -testPlan PerformanceTests
```

---

## 6. Accessibility Tests ⏳

### VoiceOverTests ⏳
**Status**: Not yet implemented
**Location**: `SpatialScreenplayWorkshopUITests/VoiceOverTests.swift`

**Test Cases to Implement**:
- All UI elements have accessibility labels
- VoiceOver navigation works
- Scene cards readable by VoiceOver
- Editor accessible with VoiceOver
- Gestures accessible

### ReducedMotionTests ⏳
**Status**: Not yet implemented
**Location**: `SpatialScreenplayWorkshopUITests/ReducedMotionTests.swift`

**Test Cases to Implement**:
- Animations respect Reduce Motion setting
- Timeline still functional without animations
- Cards still selectable without hover effects

---

## 7. CloudKit Sync Tests ⏳

**Status**: Not yet implemented (Post-MVP)
**Location**: `SpatialScreenplayWorkshopTests/CloudKitSyncTests.swift`

**Test Cases to Implement**:
- Project syncs to iCloud
- Changes sync across devices
- Conflict resolution works
- Offline changes sync when online

---

## 8. Export Tests ⏳

### PDFExportTests ⏳
**Status**: Not yet implemented (Sprint 4)
**Location**: `SpatialScreenplayWorkshopTests/PDFExportTests.swift`

**Test Cases to Implement**:
- Export screenplay to PDF
- PDF follows industry formatting
- Page numbers correct
- All scenes included
- Metadata in PDF properties

### FountainExportTests ⏳
**Status**: Not yet implemented (Sprint 4)
**Location**: `SpatialScreenplayWorkshopTests/FountainExportTests.swift`

**Test Cases to Implement**:
- Export to Fountain format
- Import Fountain files
- Round-trip conversion (export then import)
- Preserve all screenplay elements

---

## Running Tests

### Current Environment (Linux/CLI) ✅
Only unit tests can be run:
```bash
# Run all unit tests
swift test

# Run specific test suite
swift test --filter SpatialLayoutEngineTests

# Run with verbose output
swift test --verbose
```

### visionOS Simulator ⏳
Required for integration, UI, and performance tests:
```bash
# Run all tests
xcodebuild test \
  -scheme SpatialScreenplayWorkshop \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro'

# Run specific test plan
xcodebuild test \
  -scheme SpatialScreenplayWorkshop \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -testPlan IntegrationTests
```

### Physical Device 🎯
Required for spatial interaction tests:
```bash
xcodebuild test \
  -scheme SpatialScreenplayWorkshop \
  -destination 'platform=visionOS,id=<DEVICE_UDID>' \
  -testPlan SpatialInteractionTests
```

---

## Test Coverage Goals

- **Unit Tests**: 80%+ code coverage
- **Integration Tests**: All critical paths covered
- **UI Tests**: All user-facing features covered
- **Performance Tests**: Meet all performance targets
- **Accessibility Tests**: 100% VoiceOver coverage

---

## Continuous Integration

### CI Pipeline (Future)
```yaml
# .github/workflows/tests.yml
name: Tests

on: [push, pull_request]

jobs:
  unit-tests:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v3
      - name: Run unit tests
        run: swift test

  simulator-tests:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v3
      - name: Run simulator tests
        run: |
          xcodebuild test \
            -scheme SpatialScreenplayWorkshop \
            -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
```

---

## Next Steps

1. ✅ **Implement unit tests** - Start with SpatialLayoutEngineTests
2. ⏳ **Set up visionOS simulator** - Required for integration/UI tests
3. ⏳ **Implement integration tests** - Test RealityKit integration
4. ⏳ **Implement UI tests** - Test all views
5. 🎯 **Test on device** - Spatial interaction testing
6. ⏳ **Performance testing** - Optimize based on results
7. ⏳ **Accessibility testing** - Ensure VoiceOver support

---

## Test Summary

| Test Type | Count | Can Run Now | Requires Simulator | Requires Device |
|-----------|-------|-------------|-------------------|-----------------|
| Unit Tests | 11 | ✅ Yes | ⏳ No | 🎯 No |
| Integration Tests | ~10 | ❌ No | ⏳ Yes | 🎯 No |
| UI Tests | ~20 | ❌ No | ⏳ Yes | 🎯 No |
| Spatial Tests | ~10 | ❌ No | ⏳ Partial | 🎯 Yes |
| Performance Tests | ~10 | ❌ No | ⏳ Yes | 🎯 Best |
| Accessibility Tests | ~5 | ❌ No | ⏳ Yes | 🎯 Yes |
| **TOTAL** | **~66** | **11** | **~45** | **~10** |
