# visionOS Development TODO

Complete checklist for building, testing, and deploying Spatial Screenplay Workshop on visionOS.

**Current Status**: Code complete, never built or run. Requires macOS + Xcode + visionOS SDK.

---

## 🖥️ Phase 1: Environment Setup

### Prerequisites

- [ ] **macOS 14.0+** (Sonoma or later)
- [ ] **Xcode 16.0+** installed from App Store
- [ ] **visionOS SDK** installed (comes with Xcode 16+)
- [ ] **Apple Developer Account** (for device testing and App Store)
- [ ] **Apple Vision Pro** device or access to simulator
- [ ] **Git** configured with GitHub access

### Initial Setup

- [ ] Clone repository to Mac
  ```bash
  git clone https://github.com/akaash-nigam/visionOS_Spatial-Screenplay-Workshop.git
  cd visionOS_Spatial-Screenplay-Workshop
  ```

- [ ] Open project in Xcode
  ```bash
  open SpatialScreenplayWorkshop.xcodeproj
  ```

- [ ] Select "Apple Vision Pro" simulator as target
- [ ] Verify all Swift packages resolve
- [ ] Check for any missing frameworks

### Expected Issues

⚠️ **Likely compilation errors** (we never compiled):
- Missing imports
- API mismatches
- Type errors
- SwiftData schema issues
- RealityKit compatibility

**Action**: Document all errors in GitHub Issues before fixing.

---

## 🔨 Phase 2: Build and Compilation

### First Build Attempt

- [ ] Press `Cmd+B` to build
- [ ] **Document all compilation errors**
  - Create GitHub issues for each category of errors
  - Tag with `build-error` label
  - Estimate fix time

### Expected Error Categories

#### 1. Import/Framework Errors
- [ ] Verify all framework imports exist
- [ ] Check visionOS 2.0 API availability
- [ ] Add missing `import` statements

#### 2. SwiftData Schema Errors
- [ ] Verify `@Model` macro usage
- [ ] Check relationship definitions
- [ ] Fix any schema migration issues
- [ ] Test `ModelContainer` configuration

#### 3. RealityKit Errors
- [ ] Verify `Entity` subclass syntax
- [ ] Check `Component` definitions
- [ ] Fix mesh generation code
- [ ] Verify material APIs

#### 4. SwiftUI Errors
- [ ] Fix `@Observable` macro issues
- [ ] Verify `@Environment` usage
- [ ] Check view modifiers
- [ ] Fix binding errors

#### 5. Type Errors
- [ ] Resolve type mismatches
- [ ] Fix optional unwrapping
- [ ] Add missing `Sendable` conformances
- [ ] Fix actor isolation issues

### Iterative Fixing

- [ ] Fix errors in order of severity:
  1. Framework/import errors
  2. Data model errors
  3. View errors
  4. RealityKit errors
  5. Minor warnings

- [ ] Build after each fix category
- [ ] Commit working fixes separately

### Success Criteria

- [ ] ✅ Clean build (0 errors)
- [ ] ⚠️ Minimal warnings (< 10)
- [ ] 📝 All fixes documented in commits

---

## 🧪 Phase 3: Unit Testing

### Run Unit Tests

- [ ] Press `Cmd+U` to run all tests
- [ ] Check test results in Test Navigator

### Fix Test Failures

- [ ] **SpatialLayoutEngineTests** (11 tests)
  - [ ] testCalculatePositions_ReturnsAllScenes
  - [ ] testCalculatePositions_GroupsByAct
  - [ ] testCalculatePositions_NoOverlaps
  - [ ] testCalculateInsertPosition_ValidIndex
  - [ ] testGetActDividerPositions_CreatesCorrectDividers
  - [ ] testValidate_WithinBounds
  - [ ] testCalculateBoundingBox_CorrectBounds
  - [ ] testCalculatePositions_SingleScene
  - [ ] testCalculatePositions_EmptyScenes
  - [ ] testCalculatePositions_ManyScenes
  - [ ] testCalculatePositions_Performance

### Add Missing Tests

Create tests for untested components:

- [ ] **PageCalculatorTests**
  - Page count calculation
  - Scene statistics
  - Line counting

- [ ] **ScriptFormatterTests**
  - Element formatting
  - Margin calculations
  - Font and spacing

- [ ] **ElementDetectorTests**
  - Slug line detection
  - Character name detection
  - Dialogue detection

- [ ] **AutoSaveManagerTests**
  - Timer functionality
  - Save triggering
  - Change detection

- [ ] **EditorUndoManagerTests**
  - Undo/redo operations
  - State snapshots
  - History limits

### Success Criteria

- [ ] ✅ All unit tests passing
- [ ] ✅ Code coverage > 80%
- [ ] ✅ No flaky tests

---

## 📱 Phase 4: Simulator Testing

### First Run on Simulator

- [ ] Select "Apple Vision Pro" simulator
- [ ] Press `Cmd+R` to run
- [ ] **Document first-run experience**

### Test Core Flows

#### Project Management
- [ ] Create new project
- [ ] View project list
- [ ] Select project
- [ ] Delete project
- [ ] Verify sample data loads

#### Script Editor
- [ ] Open editor
- [ ] Type slug line (should auto-detect)
- [ ] Type character name in caps (should trigger auto-complete)
- [ ] Type dialogue
- [ ] Type action
- [ ] Verify page count updates
- [ ] Test undo/redo (Cmd+Z, Cmd+Shift+Z)
- [ ] Open metadata panel (Cmd+I)
- [ ] Save changes

#### 3D Timeline
- [ ] View timeline (should show scene cards)
- [ ] Verify cards positioned by act
- [ ] Tap scene card (should select)
- [ ] Double-tap scene card (should open editor)
- [ ] Test drag-and-drop (may not work in simulator)
- [ ] Test floating toolbar

#### PDF Export
- [ ] Export project to PDF
- [ ] Open PDF and verify:
  - [ ] Title page present
  - [ ] Formatting correct (Courier 12pt)
  - [ ] Margins accurate
  - [ ] Page numbers present
  - [ ] Scene numbers present

### Performance Testing

- [ ] Monitor frame rate (should be 60+ FPS)
- [ ] Check memory usage (should be < 500MB)
- [ ] Test with 50+ scenes
- [ ] Profile with Instruments

### Bug Documentation

- [ ] Document all bugs in GitHub Issues
- [ ] Tag with `simulator-bug` label
- [ ] Include steps to reproduce
- [ ] Add screenshots/recordings

---

## 🥽 Phase 5: Device Testing (Apple Vision Pro)

**Note**: This phase requires physical Apple Vision Pro device.

### Setup Device

- [ ] Connect Vision Pro to Mac
- [ ] Trust computer on device
- [ ] Enable Developer Mode
- [ ] Install app via Xcode

### Spatial Interaction Testing

These tests **cannot** be done in simulator:

#### Gesture Testing
- [ ] **Tap gesture** - Select scene cards
  - Works with finger tap in air?
  - Provides haptic/audio feedback?

- [ ] **Double-tap gesture** - Open editor
  - 300ms threshold working?
  - Reliable detection?

- [ ] **Drag gesture** - Reorder scenes
  - Can grab cards in 3D?
  - Cards follow hand movement?
  - Drop detection accurate?

- [ ] **Hover effect** - Eye tracking
  - Cards highlight on gaze?
  - 500ms delay for tooltip?
  - Smooth transitions?

#### Spatial Layout Testing
- [ ] Scene cards positioned correctly in 3D space
  - Act I at z=0 (closest)
  - Act II at z=-0.5 (middle)
  - Act III at z=-1.0 (farthest)

- [ ] Cards visible from 2-4 meters away
- [ ] Text readable on cards
- [ ] No depth perception issues

#### Ergonomics Testing
- [ ] Comfortable viewing distance
- [ ] Cards not too close or far
- [ ] Toolbar reachable
- [ ] No eye strain after 30 minutes
- [ ] No motion sickness

### Performance on Device

- [ ] Maintain 60+ FPS with 50 cards
- [ ] No thermal throttling
- [ ] Battery usage reasonable
- [ ] Memory stable (no leaks)

### Accessibility Testing

- [ ] VoiceOver works on all UI
- [ ] All elements have labels
- [ ] Gesture alternatives available
- [ ] High contrast mode works

---

## 🐛 Phase 6: Bug Fixing

### Critical Bugs (Must Fix)

Track in GitHub with `critical` label:

- [ ] App crashes
- [ ] Data loss issues
- [ ] Core features broken
- [ ] Performance < 30 FPS

### High Priority Bugs

- [ ] Gestures not working
- [ ] Export fails
- [ ] Auto-save not triggering
- [ ] UI glitches

### Medium Priority

- [ ] Minor UI issues
- [ ] Polish items
- [ ] Edge cases

### Testing After Fixes

- [ ] Regression test all flows
- [ ] Verify fix doesn't break other features
- [ ] Update tests if needed

---

## 🎨 Phase 7: UI/UX Polish

### Visual Polish

- [ ] **Colors**: Verify all status colors match design
  - Draft: #FFE5B4 (peach)
  - Revision: #FFD700 (gold)
  - Locked: #90EE90 (green)
  - Final: #87CEEB (blue)

- [ ] **Typography**: Confirm Courier 12pt in editor
- [ ] **Animations**: Smooth 60fps transitions
- [ ] **Glassmorphic UI**: .ultraThinMaterial looks good

### Interaction Polish

- [ ] Haptic feedback on interactions
- [ ] Spatial audio for UI sounds
- [ ] Selection animations smooth
- [ ] Drag animations natural

### Edge Cases

- [ ] Empty project (no scenes)
- [ ] Very long project (100+ scenes)
- [ ] Very long scene (50+ pages)
- [ ] Special characters in text
- [ ] Unusual screen names

---

## 📸 Phase 8: App Store Assets

### Screenshots (3840 x 2160 px)

Create 5 screenshots as specified in APP_STORE.md:

- [ ] **Screenshot 1**: 3D Timeline with 12-15 cards
- [ ] **Screenshot 2**: Script Editor with auto-complete
- [ ] **Screenshot 3**: Floating Toolbar with drag action
- [ ] **Screenshot 4**: Metadata Panel open
- [ ] **Screenshot 5**: PDF Export preview

**Tools**: Use Xcode's screenshot feature or device capture

### App Preview Video (15-30 seconds)

- [ ] Script the video (see APP_STORE.md)
- [ ] Record on device
- [ ] Edit with professional transitions
- [ ] Add text overlays and music
- [ ] Export at required specs

### App Icon (1024x1024 px)

- [ ] Design app icon
- [ ] Create all required sizes
- [ ] Add to asset catalog

---

## 📋 Phase 9: Pre-Submission Checklist

### Code Quality

- [ ] All tests passing
- [ ] No compiler warnings
- [ ] SwiftLint passing
- [ ] Code reviewed
- [ ] Commented complex sections

### Performance

- [ ] Frame rate 60+ FPS (verified with Instruments)
- [ ] Memory < 1GB
- [ ] Auto-save < 100ms
- [ ] PDF export < 5s for 100 pages
- [ ] No memory leaks

### Functionality

- [ ] All MVP features working
- [ ] Sample projects included
- [ ] Tutorial/onboarding present
- [ ] Help documentation accessible
- [ ] Settings functional

### Legal & Compliance

- [ ] Privacy policy URL set
- [ ] Terms of service URL set
- [ ] Age rating correct (4+)
- [ ] Export compliance confirmed
- [ ] Contact information current

### App Store Metadata

- [ ] App name: "Spatial Screenplay Workshop"
- [ ] Subtitle: "Professional Screenwriting in 3D"
- [ ] Description filled
- [ ] Keywords optimized
- [ ] Screenshots uploaded
- [ ] Preview video uploaded
- [ ] App icon uploaded
- [ ] Support URL set
- [ ] Marketing URL set

---

## 🚀 Phase 10: App Store Submission

### App Store Connect Setup

- [ ] Create app record in App Store Connect
- [ ] Fill all metadata
- [ ] Upload screenshots and video
- [ ] Set pricing (Free)
- [ ] Configure in-app purchases (none)
- [ ] Set availability (all countries)

### Build Upload

- [ ] Archive app in Xcode (Product → Archive)
- [ ] Validate archive
- [ ] Upload to App Store Connect
- [ ] Wait for processing (15-30 minutes)
- [ ] Select build for release

### Submit for Review

- [ ] Fill review information
- [ ] Add demo account (if needed - we don't need one)
- [ ] Add reviewer notes (see APP_STORE.md)
- [ ] Submit for review

### Review Process

- [ ] Initial review: 1-3 days
- [ ] Respond to any questions within 24 hours
- [ ] Fix any rejection issues
- [ ] Resubmit if needed

**Expected timeline**: 3-7 days for approval

---

## 📊 Phase 11: Post-Launch

### Launch Day

- [ ] App goes live on App Store
- [ ] Send press release
- [ ] Post on social media
- [ ] Email announcement
- [ ] Product Hunt launch
- [ ] Reddit posts (r/screenwriting, r/visionOS)

### Monitoring (Week 1)

- [ ] Check crash reports daily
- [ ] Monitor reviews
- [ ] Respond to all reviews (positive and negative)
- [ ] Track downloads
- [ ] Monitor performance metrics

### User Feedback

- [ ] Create feedback collection system
- [ ] Discord community setup
- [ ] Email support monitoring
- [ ] Feature request tracking

### Analytics (Optional - requires opt-in)

- [ ] Set up crash reporting (Sentry)
- [ ] Anonymous usage analytics
- [ ] Performance monitoring
- [ ] User retention tracking

---

## 🔄 Phase 12: Version 1.1 Planning

### Gather Feedback

- [ ] Review all user feedback
- [ ] Analyze crash reports
- [ ] Check feature requests
- [ ] Survey beta users

### Prioritize Features

Based on POST_MVP_EPICS.md:

**v1.1 Candidates** (Q2 2025):
- [ ] iCloud sync
- [ ] Real-time collaboration
- [ ] Bug fixes from v1.0

### Development Cycle

- [ ] Create v1.1 milestone in GitHub
- [ ] Plan sprints
- [ ] Assign story points
- [ ] Begin development

---

## 🎯 Success Metrics

### Technical Metrics

- [ ] **Crash-free rate**: > 99%
- [ ] **Average rating**: > 4.5 stars
- [ ] **Frame rate**: 60+ FPS
- [ ] **Memory**: < 1GB
- [ ] **Load time**: < 3 seconds

### User Metrics

- [ ] **Downloads**: 1,000+ in first month
- [ ] **Active users**: 500+ weekly
- [ ] **Retention**: 40%+ after 7 days
- [ ] **Reviews**: 100+ with 4.5+ average

### Business Metrics

- [ ] **Press coverage**: 5+ articles
- [ ] **Social mentions**: 100+ posts
- [ ] **Community**: 200+ Discord members
- [ ] **Feature requests**: 50+ collected

---

## 📝 Issue Tracking Template

For each issue discovered, create GitHub issue with:

```markdown
**Environment**:
- Device: [Simulator / Vision Pro]
- visionOS: [version]
- App Version: [version]

**Steps to Reproduce**:
1.
2.
3.

**Expected**:
**Actual**:

**Screenshots**:

**Priority**: [Critical / High / Medium / Low]
**Category**: [Build / Runtime / UI / Performance / Data]
```

---

## ✅ Quick Start Checklist

If you're just getting started, do these first:

1. [ ] Clone repo to Mac with Xcode
2. [ ] Try building (document all errors)
3. [ ] Fix build errors one category at a time
4. [ ] Run on simulator
5. [ ] Fix critical bugs
6. [ ] Test on device
7. [ ] Create screenshots
8. [ ] Submit to App Store

---

## 📞 Resources

**Documentation**:
- [README.md](README.md) - Project overview
- [CONTRIBUTING.md](CONTRIBUTING.md) - Development guide
- [docs/TESTING.md](docs/TESTING.md) - Testing guide
- [docs/APP_STORE.md](docs/APP_STORE.md) - App Store materials

**Apple Resources**:
- [visionOS Documentation](https://developer.apple.com/visionos/)
- [RealityKit Documentation](https://developer.apple.com/documentation/realitykit)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Human Interface Guidelines - visionOS](https://developer.apple.com/design/human-interface-guidelines/visionos)

**Support**:
- Email: support@spatialscreenplay.app
- GitHub Issues: [Create Issue](https://github.com/akaash-nigam/visionOS_Spatial-Screenplay-Workshop/issues/new)

---

## 📅 Estimated Timeline

**Optimistic** (everything works):
- Phase 1-2 (Setup & Build): 1 day
- Phase 3 (Unit Tests): 1 day
- Phase 4 (Simulator): 2 days
- Phase 5 (Device): 2 days
- Phase 6 (Bug Fixes): 3 days
- Phase 7 (Polish): 2 days
- Phase 8 (Assets): 1 day
- Phase 9 (Prep): 1 day
- Phase 10 (Submit): 1 day + review time (3-7 days)

**Total**: ~14-18 days + review time

**Realistic** (with issues):
- Phase 1-2: 2-3 days (build errors)
- Phase 3: 2 days (test fixes)
- Phase 4: 3-4 days (simulator issues)
- Phase 5: 3-4 days (device testing)
- Phase 6: 5-7 days (bug fixing)
- Phase 7: 3 days (polish)
- Phase 8: 2 days (assets)
- Phase 9: 1 day
- Phase 10: 1 day + review (3-7 days)

**Total**: ~22-30 days + review time

---

**Last Updated**: November 24, 2025
**Status**: Code complete, never built
**Next Step**: Phase 1 - Environment Setup

Good luck! 🚀
