# visionOS Testing & Validation Checklist

This document contains tasks that must be performed in an actual visionOS environment (Apple Vision Pro device or visionOS Simulator).

## Pre-Flight Checklist

### Environment Setup
- [ ] Xcode 15.2+ installed with visionOS SDK
- [ ] visionOS Simulator configured or Vision Pro device connected
- [ ] Developer account provisioned for visionOS development
- [ ] Signing certificates configured for device deployment

---

## 1. Build & Launch Verification

### Initial Build
- [ ] Project builds without errors for visionOS target
- [ ] No SwiftUI preview crashes
- [ ] App launches in visionOS Simulator
- [ ] App launches on Vision Pro device (if available)

### SwiftData Migration
- [ ] Clean install creates database correctly
- [ ] App handles empty database state gracefully
- [ ] Sample data loads correctly on first launch

---

## 2. Window System Testing

### Standard Windows
- [ ] Main dashboard window opens at correct size
- [ ] Window resizing works within visionOS constraints
- [ ] Window repositioning works with grab bar
- [ ] Multiple windows can be opened simultaneously
- [ ] Windows restore position after app restart

### Window Ornaments
- [ ] `DashboardToolbarOrnament` displays correctly below window
- [ ] `QuickActionsOrnament` displays correctly above window
- [ ] `StatusOrnament` displays in top-trailing corner
- [ ] `ImmersionControlOrnament` displays on trailing edge
- [ ] `BreadcrumbOrnament` displays in top-leading corner
- [ ] `KPISummaryOrnament` displays in bottom-leading corner
- [ ] Ornament buttons respond to tap gestures
- [ ] Ornaments update when app state changes

### Window Transitions
- [ ] Opening new windows animates smoothly
- [ ] Closing windows animates smoothly
- [ ] Window z-ordering works correctly

---

## 3. Immersive Space Testing

### Immersion Level Transitions
- [ ] Transition from `.none` to `.minimal` works
- [ ] Transition from `.minimal` to `.partial` works
- [ ] Transition from `.partial` to `.focused` works
- [ ] Transition from `.focused` to `.full` works
- [ ] Transition from `.full` to `.complete` works
- [ ] Reverse transitions work (decreasing immersion)
- [ ] Direct jumps between non-adjacent levels work
- [ ] Animation timing feels natural (0.5s default)

### Passthrough Behavior
- [ ] `.none` level shows full passthrough
- [ ] `.partial` level shows ~70% passthrough
- [ ] `.focused` level dims surroundings appropriately
- [ ] `.full` level shows minimal passthrough (~15%)
- [ ] `.complete` level shows no passthrough (full skybox)

### Environment Configuration
- [ ] Skybox opacity matches immersion level
- [ ] Ground plane appears at `.partial` and above
- [ ] Ambient lighting adjusts per level
- [ ] Fog effect appears at `.focused` and above

---

## 4. 3D Entity Visualization Testing

### Department Buildings
- [ ] Department entities render at correct positions
- [ ] Building height correlates with headcount
- [ ] Department colors match type configuration
- [ ] Floor lines render correctly (1 per 25 employees)
- [ ] Performance ring displays around base
- [ ] Ring segments light up based on KPI performance
- [ ] Budget indicators display on side
- [ ] Labels are readable and face user (billboarding)
- [ ] Point lights create ambient glow effect

### KPI Gauges
- [ ] Gauge arcs render correctly
- [ ] Filled segments match performance value
- [ ] Colors match performance status (green/blue/orange/red)
- [ ] Value displays are readable

### Data Flow Visualization
- [ ] Path segments render between entities
- [ ] Paths follow arc trajectory correctly
- [ ] Particles are positioned along paths
- [ ] Colors are configurable and render correctly

### Entity Pooling Performance
- [ ] Initial pool pre-warming completes <1s
- [ ] Entity acquisition is <0.1ms (check with Instruments)
- [ ] No visible frame drops when rebuilding scene
- [ ] Pool metrics show >90% hit rate in steady state
- [ ] Memory usage is stable during extended use

---

## 5. Gesture & Interaction Testing

### Tap Gestures
- [ ] Tapping department entity selects it
- [ ] Tapping selected entity deselects it
- [ ] Tap audio feedback plays
- [ ] Tap haptic feedback fires (on device)
- [ ] Selection highlight appears on tapped entity

### Drag Gestures
- [ ] Dragging entity moves it in space
- [ ] Drag audio feedback plays during drag
- [ ] Entity snaps back or stays based on configuration
- [ ] Drag has appropriate resistance/inertia

### Long Press Gestures
- [ ] Long press shows context menu/detail panel
- [ ] Long press audio feedback plays
- [ ] Release cancels if moved away

### Pinch Gestures (if using hand tracking)
- [ ] Pinch detection works reliably
- [ ] Pinch triggers associated actions
- [ ] Release detection is accurate

### Gaze Tracking
- [ ] Entities highlight on gaze hover
- [ ] Hover effect is subtle but visible
- [ ] Gaze + pinch works as indirect interaction

---

## 6. Hand Tracking Testing

### Basic Tracking
- [ ] Left hand joint positions are accurate
- [ ] Right hand joint positions are accurate
- [ ] Both hands track simultaneously
- [ ] Tracking recovers after hands leave view

### Gesture Recognition
- [ ] Pinch gesture detected correctly
- [ ] Point gesture detected correctly
- [ ] Open palm gesture detected correctly
- [ ] Fist gesture detected correctly
- [ ] Thumbs up gesture detected (if implemented)

### Gesture Thresholds
- [ ] Pinch threshold (0.02m) feels natural
- [ ] Point angle threshold works correctly
- [ ] Palm openness calculation is reliable

### Pointing Ray
- [ ] Pointing ray direction is accurate
- [ ] Ray origin is at index fingertip
- [ ] Ray can be used for distant selection

---

## 7. Spatial Audio Testing

### Interaction Sounds
- [ ] Tap sound plays on entity tap
- [ ] Select sound plays on selection
- [ ] Drag sound plays during drag
- [ ] Drop sound plays on drag release

### Navigation Sounds
- [ ] Window open sound plays
- [ ] Window close sound plays
- [ ] Immersive enter sound plays on level increase
- [ ] Immersive exit sound plays on level decrease

### Data Event Sounds
- [ ] Data update sound plays on refresh
- [ ] KPI alert sound plays for critical KPIs
- [ ] Sync sound plays after successful sync

### Spatial Positioning
- [ ] Audio appears to come from entity position
- [ ] Volume attenuates with distance
- [ ] Stereo positioning is accurate

### Volume Controls
- [ ] Master volume affects all sounds
- [ ] Category volumes work independently
- [ ] Mute/unmute works correctly

---

## 8. Layout Algorithm Testing

### Barnes-Hut Performance
- [ ] 50 entities layout at 60 FPS
- [ ] 100 entities layout at 60 FPS
- [ ] 200 entities layout at 60 FPS
- [ ] 500 entities layout at 30+ FPS (acceptable)

### Layout Quality
- [ ] Entities spread out evenly
- [ ] No entity overlaps in stable state
- [ ] Connected entities stay relatively close
- [ ] Central hub is clearly visible

### Configuration
- [ ] `theta` parameter affects accuracy/speed tradeoff
- [ ] `barnesHutThreshold` switches algorithms correctly
- [ ] Force strength parameters create good results

---

## 9. Navigation Testing

### Navigation Coordinator
- [ ] `navigate(to:)` opens correct destinations
- [ ] `navigateBack()` returns to previous view
- [ ] `returnToDashboard()` works from any depth
- [ ] Navigation history tracks correctly

### Deep Linking
- [ ] Department detail opens from dashboard
- [ ] KPI detail opens from department view
- [ ] Report viewer opens from reports list
- [ ] Back navigation works through deep stack

---

## 10. Error Handling Testing

### Network Errors
- [ ] Offline banner appears when disconnected
- [ ] Cached data displays when offline
- [ ] Reconnection triggers sync
- [ ] Error alerts display appropriately

### Data Errors
- [ ] Invalid data shows error state
- [ ] Missing required fields handled gracefully
- [ ] Corrupted cache recovers correctly

### Initialization Errors
- [ ] SwiftData failure shows fallback UI
- [ ] In-memory fallback works correctly
- [ ] User is notified of degraded state

---

## 11. Accessibility Testing

### VoiceOver
- [ ] All interactive elements are accessible
- [ ] 3D entities have appropriate labels
- [ ] Navigation is possible with VoiceOver
- [ ] Status changes are announced

### Pointer Control
- [ ] Dwell control works if enabled
- [ ] Alternative input methods work

### Dynamic Type
- [ ] Large text doesn't break layouts
- [ ] Ornament text remains readable
- [ ] Window content scales appropriately

---

## 12. Performance Profiling

### Using Instruments
- [ ] Profile with "Time Profiler" for CPU usage
- [ ] Profile with "RealityKit Trace" for 3D performance
- [ ] Profile with "Allocations" for memory leaks
- [ ] Profile with "Energy Log" for battery impact

### Target Metrics
- [ ] Frame rate: 90 FPS sustained (immersive)
- [ ] Frame rate: 60 FPS minimum (windows)
- [ ] Memory: <500MB during normal use
- [ ] Launch time: <3 seconds to interactive
- [ ] Entity pool hit rate: >90%

### Thermal Testing
- [ ] Extended use doesn't cause thermal throttling
- [ ] Performance degrades gracefully if throttled

---

## 13. Device-Specific Testing

### Vision Pro Hardware
- [ ] Eye tracking accuracy is acceptable
- [ ] Hand tracking works in various lighting
- [ ] Spatial audio is immersive
- [ ] Display quality is sharp
- [ ] Comfort during extended use

### Simulator Limitations
- [ ] Document features that can't be tested in simulator
- [ ] Note any simulator-only bugs
- [ ] Verify eye tracking fallback (click-to-select)

---

## Sign-Off

| Area | Tester | Date | Status |
|------|--------|------|--------|
| Build & Launch | | | |
| Windows | | | |
| Immersive Space | | | |
| 3D Visualization | | | |
| Gestures | | | |
| Hand Tracking | | | |
| Spatial Audio | | | |
| Layout Algorithm | | | |
| Navigation | | | |
| Error Handling | | | |
| Accessibility | | | |
| Performance | | | |
| Device Testing | | | |

---

## Notes

### Known Simulator Limitations
- Eye tracking requires device
- Hand tracking has reduced accuracy
- Spatial audio positioning is approximated
- Thermal behavior can't be tested

### Testing Tips
1. Use Simulator first for quick iteration
2. Test on device for gesture accuracy
3. Profile performance on device (not simulator)
4. Test in various lighting conditions for hand tracking
5. Test both sitting and standing positions
