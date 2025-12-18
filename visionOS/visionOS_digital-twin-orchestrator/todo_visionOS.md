# visionOS Development Tasks

This document tracks tasks that require a visionOS environment (Xcode with visionOS SDK, Vision Pro device or simulator) for testing and validation.

## Environment Requirements

- **Xcode 15.2+** with visionOS SDK
- **Vision Pro device** or **visionOS Simulator**
- **macOS Sonoma 14.0+** on Apple Silicon Mac

---

## P0: Critical - Must Test Before Release

### RealityKit Scene Implementation
- [ ] **Test USDZ model loading** in `DigitalTwinVolumeView`
  - Verify models load from file URLs
  - Test fallback to placeholder geometry
  - Validate model scale and positioning
  - File: `Views/Volumes/DigitalTwinVolumeView.swift:272-310`

- [ ] **Test entity collision shapes** for gesture targeting
  - Verify `InputTargetComponent` works correctly
  - Test `generateCollisionShapes(recursive: true)`
  - File: `Views/Volumes/DigitalTwinVolumeView.swift:282-284`

- [ ] **Test PointLightComponent** rendering
  - Verify lighting illuminates 3D models correctly
  - Check performance with multiple lights
  - File: `Views/Volumes/DigitalTwinVolumeView.swift:395-408`

### Gesture Handling
- [ ] **Test drag rotation gesture** on 3D models
  - Verify smooth rotation on all axes
  - Test `Rotation3D` and `simd_quatf` conversions
  - File: `Views/Volumes/DigitalTwinVolumeView.swift:77-98`

- [ ] **Test magnify (pinch) gesture** for scaling
  - Verify scale limits (0.5x - 2.0x)
  - Test smooth scaling animation
  - File: `Views/Volumes/DigitalTwinVolumeView.swift:101-116`

- [ ] **Test SpatialTapGesture** for entity selection
  - Verify tap detection on 3D entities
  - Test visual feedback (highlight flash)
  - File: `Views/Volumes/DigitalTwinVolumeView.swift:118-145`

### Immersive Spaces
- [ ] **Test facility immersive space** entry/exit
  - Verify `dismissImmersiveSpace()` works correctly
  - Test transition animations
  - File: `Views/ImmersiveSpaces/FacilityImmersiveView.swift:94-99`

- [ ] **Test immersion style switching**
  - Verify `.mixed`, `.progressive`, `.full` modes
  - Test `ImmersionStyle` binding
  - File: `App/DigitalTwinOrchestratorApp.swift:174`

---

## P1: High Priority - Important for UX

### Window Management
- [ ] **Test volumetric window sizing**
  - Verify `defaultSize(width:height:depth:in: .meters)` works
  - Test window repositioning by user
  - File: `App/DigitalTwinOrchestratorApp.swift:148-150`

- [ ] **Test multiple window coordination**
  - Open dashboard + asset browser + volume simultaneously
  - Verify state sharing between windows
  - Test `openWindow(id:)` and `dismissWindow(id:)`

- [ ] **Test ornament positioning**
  - Verify `.ornament(attachmentAnchor: .scene(.trailing))` placement
  - Test ornament visibility from different angles
  - File: `Views/Volumes/DigitalTwinVolumeView.swift:70-72`

### Visual Rendering
- [ ] **Test glass background effect** on control panels
  - Verify `.glassBackgroundEffect()` renders correctly
  - Test readability of text over glass
  - Files: All view files with control panels

- [ ] **Test color accuracy** in 3D space
  - Verify `HealthThresholds.color(for:)` displays correctly
  - Test `UIColor` to RealityKit material conversion
  - File: `Views/Volumes/DigitalTwinVolumeView.swift:328-329`

- [ ] **Test text rendering** in 3D
  - Verify `MeshResource.generateText()` legibility
  - Test text orientation (billboarding)
  - File: `Views/ImmersiveSpaces/FacilityImmersiveView.swift:213-234`

---

## P2: Medium Priority - Polish & Performance

### Performance Testing
- [ ] **Profile RealityKit scene performance**
  - Measure FPS with complex models
  - Test with 50+ entities in facility view
  - Monitor memory usage during immersive sessions

- [ ] **Test sensor visualization performance**
  - Verify 8 sensor indicators render smoothly
  - Test indicator color updates at 1Hz
  - File: `Views/Volumes/DigitalTwinVolumeView.swift:352-371`

- [ ] **Test grid rendering performance** in facility view
  - Profile floor grid with 441 line entities
  - Consider LOD or culling optimizations
  - File: `Views/ImmersiveSpaces/FacilityImmersiveView.swift:134-167`

### User Experience
- [ ] **Test comfortable viewing distances**
  - Verify models are positioned within 0.5m - 3.0m
  - Test ornament readability at various distances
  - Reference: `Models/Constants.swift:SpatialConstants`

- [ ] **Test hover effects** (if implemented)
  - Add and test `HoverEffectComponent` on interactive entities
  - Verify `SpatialConstants.hoverScale` feedback

- [ ] **Test haptic feedback** (if supported)
  - Add haptic response to tap gestures
  - Test vibration patterns for different actions

### Accessibility
- [ ] **Test VoiceOver with spatial content**
  - Verify accessibility labels on 3D entities
  - Test navigation between volumetric elements

- [ ] **Test Dynamic Type** in ornaments
  - Verify text scales appropriately in glass panels
  - Test control panel layout with large text

---

## P3: Future Enhancements - Nice to Have

### SharePlay Integration
- [ ] **Implement GroupActivities** for collaborative viewing
  - Share digital twin selection across users
  - Sync camera position and annotations
  - Requires: `GroupActivities` framework, SharePlay entitlement

### Spatial Audio
- [ ] **Add spatial audio** for alerts and notifications
  - Position alert sounds at twin locations
  - Use `AudioComponent` or `AVAudioEngine`

### Hand Tracking
- [ ] **Implement direct hand interaction**
  - Use `ARKit` hand tracking for gesture input
  - Allow "grabbing" and manipulating models directly
  - Requires: `ARKit`, `VisionOS 2.0+`

### Spatial Personas
- [ ] **Support Spatial Personas** in collaborative mode
  - Display user avatars in facility view
  - Show pointing/selection indicators

---

## Testing Checklist

Before each release, verify the following in visionOS environment:

### Smoke Test
- [ ] App launches without crashes
- [ ] Dashboard window displays correctly
- [ ] Can navigate to all windows/spaces
- [ ] Volume view loads with placeholder model
- [ ] Immersive space enters and exits cleanly

### Interaction Test
- [ ] All gestures respond (drag, pinch, tap)
- [ ] Buttons in glass panels are tappable
- [ ] Window controls work (close, resize)
- [ ] Navigation between twins works

### Visual Test
- [ ] Health colors display correctly (green/yellow/orange/red)
- [ ] Text is readable in all lighting conditions
- [ ] Glass effects render without artifacts
- [ ] Shadows and lighting look natural

### Performance Test
- [ ] Maintain 90 FPS during normal use
- [ ] No memory leaks during extended sessions
- [ ] Model loading completes within 3 seconds

---

## Notes

### Known Limitations
1. `MeshResource.generateText()` requires containerFrame for proper centering
2. `PointLightComponent` has limited shadow support
3. Simulator doesn't fully replicate device performance

### Useful Debug Commands
```swift
// Enable RealityKit debug visualization
RealityView { content in
    content.debugOptions = [.showStatistics, .showPhysics]
}

// Log entity hierarchy
func printEntityHierarchy(_ entity: Entity, indent: Int = 0) {
    print(String(repeating: "  ", count: indent) + (entity.name ?? "unnamed"))
    for child in entity.children {
        printEntityHierarchy(child, indent: indent + 1)
    }
}
```

### Resources
- [Apple visionOS Documentation](https://developer.apple.com/documentation/visionos)
- [RealityKit Documentation](https://developer.apple.com/documentation/realitykit)
- [Human Interface Guidelines - Spatial Design](https://developer.apple.com/design/human-interface-guidelines/designing-for-visionos)
