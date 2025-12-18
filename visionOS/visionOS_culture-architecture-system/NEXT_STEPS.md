# Next Steps - Opening in Xcode

## Quick Start Guide

### Prerequisites

- **macOS:** 14.0 (Sonoma) or later
- **Xcode:** 16.0 or later with visionOS SDK 2.0+
- **Apple Vision Pro:** Device or Simulator access

---

## Step 1: Create Xcode Project

### Option A: Create New Project and Import Files

1. Open Xcode 16+
2. File → New → Project
3. Choose: **visionOS** → **App**
4. Settings:
   - Product Name: `CultureArchitectureSystem`
   - Organization Identifier: `com.culture.architecture`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Include Tests: **Yes**

5. Replace generated files with source from `CultureArchitectureSystem/` directory

### Option B: Create Swift Package (Alternative)

```bash
cd CultureArchitectureSystem
swift package init --type executable --name CultureArchitectureSystem
```

---

## Step 2: Configure Project

### Project Settings

```
General:
├─ Deployment Info
│  ├─ Minimum Deployments: visionOS 2.0
│  └─ Supported Destinations: Apple Vision Pro
├─ Identity
│  └─ Bundle Identifier: com.culture.architecture.system
└─ Version: 1.0.0 (Build 1)

Signing & Capabilities:
├─ Automatically manage signing
├─ Team: [Your Team]
└─ Capabilities:
   ├─ ARKit
   └─ Network
```

### Info.plist Additions

```xml
<key>NSCameraUsageDescription</key>
<string>Camera access for spatial experiences</string>

<key>NSHandTrackingUsageDescription</key>
<string>Hand tracking for natural interactions</string>
```

---

## Step 3: Add Files to Xcode

### File Organization in Xcode

```
CultureArchitectureSystem/
├── App/
│   ├── CultureArchitectureSystemApp.swift (main entry)
│   ├── AppModel.swift
│   └── ContentView.swift
├── Models/
│   └── [7 model files]
├── Views/
│   ├── Windows/
│   ├── Volumes/
│   └── Immersive/
├── ViewModels/
├── Services/
├── Networking/
├── Utilities/
└── Tests/
    └── UnitTests/
```

**Drag and drop** the entire `CultureArchitectureSystem/` directory structure into Xcode navigator.

---

## Step 4: Build the Project

### Command Line Build

```bash
xcodebuild \
  -scheme CultureArchitectureSystem \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  build
```

### Xcode Build

1. Select scheme: **CultureArchitectureSystem**
2. Select destination: **visionOS Simulator** or **Apple Vision Pro**
3. Product → Build (⌘B)

**Expected build time:** 2-5 minutes (first build)

---

## Step 5: Run Tests

### Command Line Tests

```bash
xcodebuild test \
  -scheme CultureArchitectureSystem \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
```

### Xcode Tests

1. Product → Test (⌘U)
2. View test results in Test Navigator (⌘6)

**Expected results:** 50+ tests passing

### Test Coverage

```bash
# Generate coverage report
xcodebuild test \
  -scheme CultureArchitectureSystem \
  -destination 'platform=visionOS Simulator' \
  -enableCodeCoverage YES
```

View coverage: Open `.xcresult` bundle in Xcode

---

## Step 6: Run the Application

### Simulator

1. Select destination: **visionOS Simulator**
2. Product → Run (⌘R)
3. Wait for simulator to boot (~30 seconds)
4. App launches with Dashboard view

### Device (if available)

1. Connect Apple Vision Pro
2. Select destination: **Apple Vision Pro**
3. Product → Run (⌘R)
4. Accept code signing prompt
5. App installs and launches

---

## Step 7: Validate Implementation

### Checklist

#### App Structure
- [ ] App builds without errors
- [ ] All scenes (WindowGroup, ImmersiveSpace) compile
- [ ] Navigation between views works

#### Data Layer
- [ ] SwiftData models are valid
- [ ] Sample data generates correctly
- [ ] Privacy features work (anonymization)

#### Views
- [ ] Dashboard displays health score
- [ ] Analytics charts render
- [ ] Recognition form works
- [ ] Volumetric views open (even if placeholder)
- [ ] Immersive space opens

#### Tests
- [ ] All unit tests pass
- [ ] No test failures
- [ ] Coverage > 80% for critical paths

---

## Step 8: Complete RealityKit Implementations

### What Needs 3D Implementation

#### 1. Team Culture Volume

**File:** `Views/Volumes/TeamCultureVolume.swift`

**TODO:**
```swift
RealityView { content in
    // Create team visualization entities
    let innovationGarden = createInnovationGarden()
    let collaborationNetwork = createCollaborationNetwork()
    let recognitionWall = createRecognitionWall()

    content.add(innovationGarden)
    content.add(collaborationNetwork)
    content.add(recognitionWall)
}
```

**Assets needed:**
- Tree models (USDZ) for innovation
- Network visualization meshes
- Recognition star particles

#### 2. Value Explorer Volume

**File:** `Views/Volumes/ValueExplorerVolume.swift`

**TODO:**
```swift
RealityView { content in
    // Central value icon
    let centerEntity = createValueIcon(for: value)

    // Orbiting behaviors
    let behaviors = createOrbitingBehaviors()

    content.add(centerEntity)
    content.add(behaviors)
}
```

#### 3. Culture Campus (Immersive)

**File:** `Views/Immersive/CultureCampusView.swift`

**TODO:**
- Purpose Mountain terrain
- Innovation Forest with trees
- Trust Valley with rivers
- Collaboration Bridges
- Recognition Plaza
- Team Territory buildings

**Use Reality Composer Pro** to create scenes

#### 4. Onboarding Journey

**File:** `Views/Immersive/OnboardingImmersiveView.swift`

**TODO:**
- Guided tour path
- Interactive value demonstrations
- Welcome portal
- Team introduction scene

---

## Step 9: Implement Hand Tracking

### File: Create `HandTrackingManager.swift`

```swift
import ARKit

class HandTrackingManager: ObservableObject {
    private let arkitSession = ARKitSession()
    private let handTracking = HandTrackingProvider()

    func startTracking() async {
        guard HandTrackingProvider.isSupported else { return }

        do {
            try await arkitSession.run([handTracking])
            await processHandUpdates()
        } catch {
            print("Hand tracking failed: \(error)")
        }
    }

    private func processHandUpdates() async {
        for await update in handTracking.anchorUpdates {
            switch update.event {
            case .added, .updated:
                handleHandPose(update.anchor)
            case .removed:
                break
            }
        }
    }

    private func handleHandPose(_ anchor: HandAnchor) {
        // Detect custom gestures
        if isPlantingGesture(anchor) {
            performPlantingAction()
        }
    }
}
```

---

## Step 10: Performance Testing

### Instruments Profiling

```bash
# Time Profiler
xcodebuild \
  -scheme CultureArchitectureSystem \
  -destination 'platform=visionOS Simulator' \
  -instrument 'Time Profiler'

# Allocations
xcodebuild \
  -scheme CultureArchitectureSystem \
  -destination 'platform=visionOS Simulator' \
  -instrument 'Allocations'
```

### Performance Targets

| Metric | Target | How to Measure |
|--------|--------|----------------|
| Frame Rate | 90 FPS | Instruments (GPU/Metal) |
| Load Time | < 3s | Time Profiler |
| Memory | < 2 GB | Allocations Instrument |
| Battery | < 15%/hr | Energy Log |

---

## Step 11: Accessibility Testing

### VoiceOver Testing

1. Settings → Accessibility → VoiceOver → On
2. Navigate through all views
3. Verify all elements have labels
4. Test interactive elements

### Dynamic Type Testing

1. Settings → Display & Brightness → Text Size
2. Move slider to largest
3. Verify all text scales properly

### Reduce Motion Testing

1. Settings → Accessibility → Reduce Motion → On
2. Verify animations are simplified
3. No motion sickness triggers

---

## Step 12: Prepare for App Store

### Required Assets

#### Screenshots (All required sizes)
- 2732×2048 (12.9" iPad Pro)
- 2388×1668 (11" iPad Pro)
- 2048×2732 (12.9" iPad Pro Portrait)
- 1668×2388 (11" iPad Pro Portrait)

#### App Preview Videos
- Max 30 seconds
- Demonstrate key features
- Show spatial interactions

#### App Store Metadata
- App name: Culture Architecture System
- Subtitle: Transform Organizational Culture
- Description: (Use content from README.md)
- Keywords: culture, enterprise, visionOS, spatial, organization
- Category: Business
- Age Rating: 4+

### Privacy Policy

Required for App Store submission. Template:

```
Culture Architecture System Privacy Policy

Data Collection:
- Anonymous employee IDs (SHA256 hashed)
- Team-level behavioral metrics
- Cultural engagement data

NO Personal Information Collected:
- No names, emails, or personal identifiers
- K-anonymity enforced (min team size: 5)
- Data aggregated at team level

Data Usage:
- Cultural health visualization
- Engagement analytics
- Team collaboration metrics

Data Protection:
- Encryption at rest and in transit
- TLS 1.3 for all communications
- OAuth 2.0 authentication

User Rights:
- Access to anonymized data
- Data deletion requests
- Opt-out of analytics
```

---

## Common Issues & Solutions

### Issue: "Module 'SwiftData' not found"

**Solution:**
- Ensure visionOS 2.0+ deployment target
- Clean build folder (Shift+Cmd+K)
- Rebuild

### Issue: "@Observable not available"

**Solution:**
- Requires iOS 17+ / visionOS 2.0+
- Update deployment target

### Issue: RealityKit entities not visible

**Solution:**
- Check lighting in scene
- Verify entity positions (not behind camera)
- Add debug bounding boxes

### Issue: Tests fail to build

**Solution:**
- Add `@testable import CultureArchitectureSystem` to test files
- Ensure test target includes all source files
- Check scheme configuration

---

## Resources

### Apple Documentation
- [visionOS Documentation](https://developer.apple.com/visionos/)
- [RealityKit Documentation](https://developer.apple.com/documentation/realitykit/)
- [SwiftData Guide](https://developer.apple.com/documentation/swiftdata)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/visionos)

### Sample Code
- [Apple Sample Code for visionOS](https://developer.apple.com/documentation/visionos/world)
- [WWDC 2024 Videos](https://developer.apple.com/videos/)

### Community
- [Apple Developer Forums](https://developer.apple.com/forums/tags/visionos)
- [Swift Forums](https://forums.swift.org/)

---

## Support

For questions about this implementation:

1. Review documentation in this repository
2. Check TEST_RESULTS.md for validation details
3. Refer to ARCHITECTURE.md for technical decisions
4. See IMPLEMENTATION_PLAN.md for roadmap

---

**Ready to build! Open this project in Xcode 16+ and start developing! 🚀**
