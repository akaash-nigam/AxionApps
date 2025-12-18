# visionOS Environment Setup Guide
## Complete Todo List for Apple Vision Pro Development

This document provides a **step-by-step checklist** for setting up and deploying the Virtual Pet Ecosystem app on visionOS/Apple Vision Pro.

---

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Development Environment Setup](#development-environment-setup)
3. [Xcode Project Creation](#xcode-project-creation)
4. [visionOS Configuration](#visionos-configuration)
5. [Simulator Setup](#simulator-setup)
6. [Physical Device Setup](#physical-device-setup)
7. [Code Migration](#code-migration)
8. [RealityKit Integration](#realitykit-integration)
9. [ARKit Spatial Features](#arkit-spatial-features)
10. [Testing on visionOS](#testing-on-visionos)
11. [Performance Optimization](#performance-optimization)
12. [App Store Submission](#app-store-submission)

---

## 1. Prerequisites

### ✅ Hardware Requirements

- [ ] **Mac with Apple Silicon (M1/M2/M3)**
  - Minimum: MacBook Pro M1 with 16GB RAM
  - Recommended: MacBook Pro M2 Pro/Max with 32GB+ RAM
  - Required for visionOS Simulator

- [ ] **Apple Vision Pro** (for device testing)
  - Not required for initial development
  - Simulator works for most features
  - Needed for final testing and spatial calibration

### ✅ Software Requirements

- [ ] **macOS Sonoma 14.0+**
  ```bash
  # Check macOS version
  sw_vers
  # Should show: ProductVersion: 14.x or higher
  ```

- [ ] **Xcode 15.2+** (16.0+ recommended)
  ```bash
  # Check Xcode version
  xcodebuild -version
  # Should show: Xcode 15.2 or higher
  ```

- [ ] **Command Line Tools**
  ```bash
  xcode-select --install
  ```

- [ ] **visionOS SDK**
  - Installed automatically with Xcode 15.2+
  - Go to Xcode → Settings → Platforms
  - Download "visionOS" if not already installed

### ✅ Apple Developer Account

- [ ] **Enroll in Apple Developer Program** ($99/year)
  - Visit: https://developer.apple.com/programs/
  - Required for device testing and App Store submission
  - Not required for Simulator development

- [ ] **Create App ID**
  - Go to: https://developer.apple.com/account/resources/identifiers/
  - Click "+" to create new identifier
  - Select "App IDs"
  - Bundle ID: `com.yourcompany.virtualpetecosystem`
  - Enable capabilities: ARKit, RealityKit

---

## 2. Development Environment Setup

### ✅ Install Xcode from App Store

```bash
# Option 1: App Store (recommended)
# Open App Store → Search "Xcode" → Install

# Option 2: Direct Download
# Visit: https://developer.apple.com/download/
# Download Xcode 16.0 or later
```

### ✅ Accept Xcode License

```bash
sudo xcodebuild -license accept
```

### ✅ Install visionOS Platform Support

1. Open Xcode
2. Go to **Xcode → Settings** (⌘,)
3. Select **Platforms** tab
4. Click **Get** next to "visionOS"
5. Wait for download (~8GB)

### ✅ Verify Installation

```bash
# List available simulators
xcrun simctl list devices

# Should include visionOS devices like:
# Apple Vision Pro (visionOS 1.0)
# Apple Vision Pro (visionOS 2.0)
```

### ✅ Install Required Tools

```bash
# Install Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install SwiftLint (optional but recommended)
brew install swiftlint

# Install CocoaPods (if needed for dependencies)
sudo gem install cocoapods

# Install xcbeautify (for better build output)
brew install xcbeautify
```

---

## 3. Xcode Project Creation

### ✅ Create New visionOS Project

**Step 1: New Project**
1. Open Xcode
2. File → New → Project (⌘⇧N)
3. Select **visionOS** tab
4. Choose **App** template
5. Click **Next**

**Step 2: Project Configuration**
```
Product Name:        Virtual Pet Ecosystem
Team:                [Your Apple Developer Team]
Organization ID:     com.yourcompany
Bundle Identifier:   com.yourcompany.virtualpetecosystem
Interface:           SwiftUI
Language:            Swift
```

**Step 3: Initial View Style**
- Select **Volume** (for 3D pet content)
- Check **Show 2D window** (for menus)
- Uncheck **Immersive Space** initially (add later)

**Step 4: Project Location**
- Save next to our existing `VirtualPetEcosystem` folder
- Structure:
  ```
  visionOS_Gaming_virtual-pet-ecosystem/
  ├── VirtualPetEcosystem/        # Swift Package (existing)
  └── VirtualPetEcosystemApp/     # Xcode visionOS App (new)
  ```

### ✅ Import Swift Package

**In Xcode Project:**
1. Select project in Navigator
2. Select app target
3. Go to **General** tab
4. Scroll to **Frameworks, Libraries, and Embedded Content**
5. Click **+**
6. Click **Add Package Dependency**
7. Select **Add Local...**
8. Navigate to `VirtualPetEcosystem` folder
9. Click **Add Package**

### ✅ Project Structure

```
VirtualPetEcosystemApp/
├── VirtualPetEcosystemApp.swift       # App entry point
├── ContentView.swift                   # Main SwiftUI view
├── ImmersiveView.swift                 # 3D immersive view
├── Models/
│   └── (Link to VirtualPetEcosystem package)
├── Views/
│   ├── PetSelectionView.swift
│   ├── PetCareView.swift
│   ├── BreedingView.swift
│   └── SettingsView.swift
├── RealityKitContent/
│   ├── 3DModels/
│   │   ├── Luminos.usdz
│   │   ├── Fluffkins.usdz
│   │   ├── Crystalites.usdz
│   │   ├── Aquarians.usdz
│   │   └── Shadowlings.usdz
│   └── Materials/
├── Assets.xcassets/
└── Info.plist
```

---

## 4. visionOS Configuration

### ✅ Configure Info.plist

**Add Required Keys:**
```xml
<key>NSCameraUsageDescription</key>
<string>Camera access is required to map your home environment for pet exploration.</string>

<key>NSWorldSensingUsageDescription</key>
<string>World sensing enables pets to navigate and interact with your furniture.</string>

<key>NSHandsTrackingUsageDescription</key>
<string>Hand tracking allows natural petting and feeding gestures.</string>

<key>UIRequiredDeviceCapabilities</key>
<array>
    <string>arkit</string>
    <string>world-tracking</string>
    <string>hand-tracking</string>
</array>

<key>UIApplicationSceneManifest</key>
<dict>
    <key>UIApplicationSupportsMultipleScenes</key>
    <true/>
    <key>UISceneConfigurations</key>
    <dict>
        <key>UIWindowSceneSessionRoleApplication</key>
        <array>
            <dict>
                <key>UISceneConfigurationName</key>
                <string>Default Configuration</string>
                <key>UISceneDelegateClassName</key>
                <string>$(PRODUCT_MODULE_NAME).SceneDelegate</string>
            </dict>
        </array>
    </dict>
</dict>
```

### ✅ Configure Build Settings

**Deployment Info:**
- **Minimum Deployment Target**: visionOS 1.0
- **Targeted Device**: Vision Pro

**Signing & Capabilities:**
1. Select target → **Signing & Capabilities**
2. Enable **Automatically manage signing**
3. Select your **Team**
4. Add capabilities:
   - [ ] **ARKit**
   - [ ] **RealityKit**
   - [ ] **Group Activities** (for SharePlay)
   - [ ] **Background Modes** → Audio, AirPlay, and Picture in Picture

### ✅ Configure Scheme

1. Product → Scheme → Edit Scheme
2. Run → Info
   - Build Configuration: Debug
   - Executable: Virtual Pet Ecosystem.app
3. Run → Options
   - [ ] GPU Frame Capture: Automatically Enabled
   - [ ] Metal API Validation: Enabled (Debug only)

---

## 5. Simulator Setup

### ✅ Launch visionOS Simulator

**Method 1: From Xcode**
1. Select scheme: **Virtual Pet Ecosystem** → **Apple Vision Pro**
2. Press ⌘R (Run)
3. Simulator launches automatically

**Method 2: Manual Launch**
```bash
# List available simulators
xcrun simctl list devices | grep Vision

# Boot specific simulator
xcrun simctl boot "Apple Vision Pro (visionOS 2.0)"

# Open Simulator app
open /Applications/Xcode.app/Contents/Developer/Applications/Simulator.app
```

### ✅ Simulator Controls

**Keyboard Shortcuts:**
```
⌥ (Option) + Drag         = Rotate view
⇧ (Shift) + Drag          = Pan view
⌘Q                        = Quit simulator
⌘K                        = Toggle keyboard
⌘⇧H                       = Home button
```

**Simulate Gestures:**
- **Tap**: Click in space
- **Pinch**: Option + Click + Drag
- **Rotate**: Option + Shift + Drag
- **Eye Tracking**: Move cursor (simulates gaze)

### ✅ Test Basic Functionality

```swift
// In ContentView.swift
import SwiftUI
import RealityKit

struct ContentView: View {
    var body: some View {
        RealityView { content in
            // Test: Add a simple sphere
            let mesh = MeshResource.generateSphere(radius: 0.1)
            let material = SimpleMaterial(color: .blue, isMetallic: false)
            let entity = ModelEntity(mesh: mesh, materials: [material])

            content.add(entity)
        }
    }
}
```

**Run and verify:**
- [ ] Blue sphere appears in simulator
- [ ] Can rotate view with Option + Drag
- [ ] No console errors

---

## 6. Physical Device Setup

### ✅ Connect Apple Vision Pro

**Step 1: Enable Developer Mode**
1. On Vision Pro: Settings → Privacy & Security → Developer Mode
2. Toggle **Developer Mode** ON
3. Restart Vision Pro when prompted

**Step 2: Pair with Mac**
1. Connect Vision Pro to Mac via USB-C cable
2. On Vision Pro: Tap **Trust** when asked
3. On Mac: Open Xcode → Window → Devices and Simulators
4. Verify Vision Pro appears in device list

**Step 3: Install App**
1. Select **Vision Pro** in scheme selector
2. Product → Run (⌘R)
3. First time: Enter Mac password to enable developer mode
4. Wait for app installation (~2-5 minutes)

### ✅ Wireless Debugging (Optional)

1. Xcode → Window → Devices and Simulators
2. Select your Vision Pro
3. Check **Connect via network**
4. Disconnect USB-C cable
5. Vision Pro remains in device list over WiFi

**Requirements:**
- Same WiFi network
- Network discoverable

---

## 7. Code Migration

### ✅ Create App Entry Point

**VirtualPetEcosystemApp.swift:**
```swift
import SwiftUI
import VirtualPetEcosystem

@main
struct VirtualPetEcosystemApp: App {
    @StateObject private var petManager = PetManager()

    var body: some Scene {
        // Main window for menus
        WindowGroup(id: "main") {
            MainMenuView()
                .environmentObject(petManager)
        }
        .defaultSize(width: 800, height: 600)

        // Volume for 3D pet display
        WindowGroup(id: "pet-volume") {
            PetVolumeView()
                .environmentObject(petManager)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1, height: 1, depth: 1, in: .meters)

        // Immersive space for full room
        ImmersiveSpace(id: "home-ecosystem") {
            HomeEcosystemView()
                .environmentObject(petManager)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}
```

### ✅ Create Main Views

**MainMenuView.swift:**
```swift
import SwiftUI
import VirtualPetEcosystem

struct MainMenuView: View {
    @EnvironmentObject var petManager: PetManager
    @Environment(\.openWindow) var openWindow
    @Environment(\.dismissWindow) var dismissWindow

    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Text("Virtual Pet Ecosystem")
                    .font(.extraLargeTitle)

                VStack(spacing: 20) {
                    Button("My Pets (\(petManager.petCount))") {
                        openWindow(id: "pet-volume")
                    }

                    Button("Adopt New Pet") {
                        // Navigate to pet selection
                    }

                    Button("Breeding Lab") {
                        // Navigate to breeding
                    }

                    Button("Enter Home Ecosystem") {
                        // Open immersive space
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
    }
}
```

### ✅ Integrate Swift Package Models

```swift
import VirtualPetEcosystem

// All models are now available:
// - Pet, PetSpecies, LifeStage
// - PetPersonality, EmotionalState
// - GeneticData, GeneticTrait
// - FoodType, PlayActivity
// - PetManager, PersistenceManager
// - BreedingSystem

// Example usage:
let pet = Pet(name: "Sparky", species: .luminos)
petManager.addPet(pet)
```

---

## 8. RealityKit Integration

### ✅ Create 3D Pet Models

**Option 1: Using Reality Composer Pro (Recommended)**

1. Open Reality Composer Pro (included with Xcode 15.2+)
   ```bash
   open /Applications/Reality\ Composer\ Pro.app
   ```

2. Create new project: **File → New**
3. Add 3D model for each species:
   - Import USDZ files or create primitives
   - Add materials (PBR, emissive for Luminos)
   - Set up animations (idle, walk, play, eat)

4. Export scenes:
   - File → Export
   - Format: Reality File (.reality)
   - Save to: `RealityKitContent/Scenes/`

**Option 2: Programmatic Creation (For Prototyping)**

```swift
import RealityKit

class PetEntityFactory {
    static func createPet(for species: PetSpecies) -> ModelEntity {
        let mesh: MeshResource
        let material: Material

        switch species {
        case .luminos:
            mesh = .generateSphere(radius: 0.15)
            var mat = PhysicallyBasedMaterial()
            mat.emissiveColor = .init(color: .yellow)
            mat.emissiveIntensity = 2.0
            material = mat

        case .fluffkins:
            mesh = .generateSphere(radius: 0.2)
            var mat = PhysicallyBasedMaterial()
            mat.baseColor = .init(tint: .brown)
            mat.roughness = 0.9
            material = mat

        case .crystalites:
            mesh = .generateBox(size: 0.15)
            var mat = PhysicallyBasedMaterial()
            mat.baseColor = .init(tint: .cyan)
            mat.metallic = 0.8
            mat.clearcoat = .init(floatLiteral: 1.0)
            material = mat

        case .aquarians:
            mesh = .generateSphere(radius: 0.15)
            var mat = PhysicallyBasedMaterial()
            mat.baseColor = .init(tint: .blue.withAlphaComponent(0.6))
            mat.blending = .transparent(opacity: .init(floatLiteral: 0.6))
            material = mat

        case .shadowlings:
            mesh = .generateSphere(radius: 0.12)
            var mat = UnlitMaterial()
            mat.color = .init(tint: .black.withAlphaComponent(0.7))
            mat.blending = .transparent(opacity: .init(floatLiteral: 0.7))
            material = mat
        }

        let entity = ModelEntity(mesh: mesh, materials: [material])

        // Add components
        entity.components[CollisionComponent.self] = CollisionComponent(
            shapes: [.generateSphere(radius: 0.15)],
            mode: .trigger
        )

        entity.components[InputTargetComponent.self] = InputTargetComponent()

        return entity
    }
}
```

### ✅ Implement Pet RealityView

```swift
import SwiftUI
import RealityKit
import VirtualPetEcosystem

struct PetRealityView: View {
    let pet: Pet
    @State private var petEntity: ModelEntity?

    var body: some View {
        RealityView { content in
            // Create pet entity
            let entity = PetEntityFactory.createPet(for: pet.species)
            petEntity = entity

            // Position pet
            entity.position = [0, 0, -0.5]

            content.add(entity)

            // Add lighting
            let light = PointLight()
            light.light.intensity = 1000
            light.position = [0, 1, 0]
            content.add(light)

        } update: { content in
            // Update pet appearance based on emotional state
            updatePetAppearance()
        }
        .gesture(
            TapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    // Handle tap - pet the pet!
                    handlePetTap(value.entity)
                }
        )
    }

    private func updatePetAppearance() {
        // Update based on pet.emotionalState, health, etc.
    }

    private func handlePetTap(_ entity: Entity) {
        // Trigger petting interaction
    }
}
```

---

## 9. ARKit Spatial Features

### ✅ Request Permissions

```swift
import ARKit

class ARPermissionManager {
    static func requestPermissions() async -> Bool {
        let arkitSession = ARKitSession()

        let worldTracking = WorldTrackingProvider()
        let handTracking = HandTrackingProvider()
        let sceneReconstruction = SceneReconstructionProvider()

        do {
            try await arkitSession.requestAuthorization(for: [
                .worldSensing,
                .handTracking
            ])
            return true
        } catch {
            print("AR authorization failed: \(error)")
            return false
        }
    }
}
```

### ✅ Implement Spatial Anchoring

```swift
import ARKit

actor SpatialAnchorManager {
    private let arkitSession = ARKitSession()
    private let worldTracking = WorldTrackingProvider()
    private var anchors: [UUID: WorldAnchor] = [:]

    func start() async throws {
        try await arkitSession.run([worldTracking])
    }

    func createAnchor(at position: simd_float3) async throws -> UUID {
        let transform = simd_float4x4(translation: position)
        let anchor = WorldAnchor(originFromAnchorTransform: transform)

        try await worldTracking.addAnchor(anchor)
        anchors[anchor.id] = anchor

        return anchor.id
    }

    func removeAnchor(_ id: UUID) async throws {
        guard let anchor = anchors[id] else { return }
        try await worldTracking.removeAnchor(anchor)
        anchors.removeValue(forKey: id)
    }
}
```

### ✅ Implement Hand Tracking

```swift
import ARKit

class HandGestureRecognizer: ObservableObject {
    private let handTracking = HandTrackingProvider()
    @Published var isPetting = false
    @Published var isFeeding = false

    func startTracking() async {
        for await update in handTracking.anchorUpdates {
            processHandUpdate(update.anchor)
        }
    }

    private func processHandUpdate(_ hand: HandAnchor) {
        // Detect petting gesture
        isPetting = detectPettingGesture(hand)

        // Detect feeding gesture
        isFeeding = detectFeedingGesture(hand)
    }

    private func detectPettingGesture(_ hand: HandAnchor) -> Bool {
        // Check hand velocity and position
        let velocity = hand.originFromAnchorTransform.columns.3
        // Implement gesture detection logic
        return false // Placeholder
    }

    private func detectFeedingGesture(_ hand: HandAnchor) -> Bool {
        // Check for cupped hand posture
        // Implement gesture detection logic
        return false // Placeholder
    }
}
```

### ✅ Implement Room Mapping

```swift
import ARKit

class RoomMapper: ObservableObject {
    private let sceneReconstruction = SceneReconstructionProvider()
    @Published var detectedSurfaces: [UUID: MeshAnchor] = [:]

    func startMapping() async {
        for await update in sceneReconstruction.anchorUpdates {
            switch update.event {
            case .added:
                detectedSurfaces[update.anchor.id] = update.anchor
            case .updated:
                detectedSurfaces[update.anchor.id] = update.anchor
            case .removed:
                detectedSurfaces.removeValue(forKey: update.anchor.id)
            }
        }
    }

    func findSuitableSpots(for species: PetSpecies) -> [simd_float3] {
        var spots: [simd_float3] = []

        for (_, anchor) in detectedSurfaces {
            // Analyze mesh geometry
            // Find horizontal surfaces for sitting
            // Find vertical surfaces for climbing
            // etc.
        }

        return spots
    }
}
```

---

## 10. Testing on visionOS

### ✅ Unit Tests (Already Complete)

```bash
cd VirtualPetEcosystem
swift test
# All 106 tests should pass
```

### ✅ visionOS-Specific Tests

**Create XCTest target for app:**

1. File → New → Target
2. Select **visionOS** → **Unit Testing Bundle**
3. Name: `VirtualPetEcosystemAppTests`

**Add UI Tests:**

```swift
import XCTest

class VirtualPetEcosystemUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testMainMenuAppears() {
        XCTAssertTrue(app.staticTexts["Virtual Pet Ecosystem"].exists)
    }

    func testPetAdoption() {
        app.buttons["Adopt New Pet"].tap()
        app.buttons["Luminos"].tap()

        let nameField = app.textFields["Pet Name"]
        nameField.tap()
        nameField.typeText("Sparky")

        app.buttons["Adopt"].tap()

        XCTAssertTrue(app.staticTexts["Sparky"].exists)
    }
}
```

### ✅ Performance Testing

```swift
class PerformanceTests: XCTestCase {
    func testPetRenderingPerformance() {
        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
            // Measure rendering performance
        }
    }

    func testFrameRate() {
        // Ensure 60 FPS
        let metrics = [XCTOSSignpostMetric.renderDuration]
        let options = XCTMeasureOptions()
        options.iterationCount = 100

        measure(metrics: metrics, options: options) {
            // Render frame
        }
    }
}
```

### ✅ Accessibility Testing

1. Settings → Accessibility → VoiceOver (ON)
2. Test all UI elements are accessible
3. Test hand gesture alternatives
4. Test with reduced motion

---

## 11. Performance Optimization

### ✅ Profile with Instruments

**Launch Instruments:**
1. Product → Profile (⌘I)
2. Select template:
   - **Time Profiler**: CPU usage
   - **Allocations**: Memory leaks
   - **Core Animation**: Frame rate
   - **Energy Log**: Battery impact

**Target Performance:**
- [ ] 60 FPS sustained
- [ ] <1.5GB memory usage
- [ ] <20% battery drain per hour
- [ ] <2 second launch time

### ✅ Optimize 3D Assets

```bash
# Optimize USDZ files
xcrun usdz_converter input.fbx output.usdz \
  --arkit-compatibility \
  --optimize

# Check file size
ls -lh RealityKitContent/3DModels/

# Target: <10MB per model
```

### ✅ Implement LOD (Level of Detail)

```swift
class LODManager {
    func updatePetLOD(for pet: Pet, distance: Float) -> MeshResource {
        switch distance {
        case 0..<2:
            return highDetailMesh(for: pet.species)
        case 2..<5:
            return mediumDetailMesh(for: pet.species)
        default:
            return lowDetailMesh(for: pet.species)
        }
    }
}
```

### ✅ Enable Metal Frame Capture

1. Edit Scheme → Run → Options
2. Enable **GPU Frame Capture**: Automatically Enabled
3. Run app
4. Debug → Capture GPU Frame
5. Analyze draw calls, shader performance

---

## 12. App Store Submission

### ✅ Prepare App Metadata

**App Store Connect:**
1. Visit: https://appstoreconnect.apple.com
2. My Apps → + → New App
3. Fill in:
   - Platform: **visionOS**
   - Name: Virtual Pet Ecosystem
   - Primary Language: English
   - Bundle ID: com.yourcompany.virtualpetecosystem
   - SKU: VIRTUALPETECO001

### ✅ Create Screenshots

**Required Sizes for visionOS:**
- 2880 x 1620 (landscape)
- 1920 x 1080 (landscape)

**Capture in Simulator:**
1. Run app in Simulator
2. Navigate to best scenes
3. File → Save Screen (⌘S)
4. Edit in Preview or Photoshop

**Tips:**
- Show pet interaction
- Demonstrate breeding
- Show multiple species
- Highlight spatial features

### ✅ Create Preview Video

**Requirements:**
- Duration: 15-30 seconds
- Resolution: 1920x1080 minimum
- Format: .mov or .m4v
- Max size: 500MB

**Tools:**
- QuickTime Player (screen recording)
- iMovie (editing)
- Final Cut Pro (professional)

### ✅ Write App Description

**Short Description (30 characters):**
```
Magical pets in your space
```

**Full Description (4000 characters max):**
```
Virtual Pet Ecosystem brings truly persistent, intelligent companions to your home. Unlike traditional virtual pets confined to screens, these magical creatures explore your actual space, develop unique personalities, and form genuine emotional bonds.

REVOLUTIONARY FEATURES:

True Persistence
• Pets exist in specific locations in your home
• Remember their favorite spots (your couch, windowsills, chairs)
• Continue "living" when the app is closed
• Age in real-time over months and years

5 Unique Species
• Luminos - Bioluminescent light creatures
• Fluffkins - Soft furry companions
• Crystalites - Geometric crystalline beings
• Aquarians - Graceful floating entities
• Shadowlings - Mysterious shy creatures

AI Personality System
• Each pet develops a unique personality
• 10 personality traits that evolve through interaction
• Influenced by your care style and environment
• No two pets are ever the same

Advanced Genetics
• Breed pets to create unique offspring
• Mendelian inheritance with 15+ genetic traits
• Rare legendary traits to discover
• Multi-generation family trees

Natural Interactions
• Pet with your hands using natural gestures
• Feed different food types
• Play fetch, hide & seek, and more
• Voice recognition for pet names

Life Simulation
• 4 life stages: Baby → Youth → Adult → Elder
• Dynamic emotional states (10 emotions)
• Realistic needs: hunger, happiness, energy, health
• Experience and leveling system

...
```

### ✅ Privacy Policy

**Required Information:**
- What data is collected (pet names, preferences)
- How spatial data is used (stays on-device)
- Third-party services (none for this app)
- User rights (data deletion)

**Host at:** https://yourcompany.com/virtualpet/privacy

### ✅ Age Rating

**Use App Store Connect Questionnaire:**
- Cartoon/Fantasy Violence: None
- Realistic Violence: None
- Sexual Content: None
- Profanity: None
- Alcohol/Drugs/Tobacco: None
- Mature/Suggestive Themes: None
- Horror/Fear Themes: None
- Gambling: None
- User Generated Content: No
- Web Browsing: No
- Location Services: Yes (for spatial anchoring)
- Made for Kids: No

**Result:** Rated 4+

### ✅ Archive and Upload

**Step 1: Archive**
```bash
# In Xcode
Product → Archive
# Wait for build to complete
```

**Step 2: Validate**
1. In Organizer, select archive
2. Click **Validate App**
3. Select distribution method: **App Store Connect**
4. Select signing: **Automatically manage signing**
5. Click **Validate**
6. Fix any issues

**Step 3: Upload**
1. Click **Distribute App**
2. Select **App Store Connect**
3. Select **Upload**
4. Wait for upload (5-15 minutes)

**Step 4: Submit for Review**
1. Go to App Store Connect
2. Select your app
3. Select version
4. Fill in all required metadata
5. Add screenshots and preview
6. Click **Submit for Review**

### ✅ Review Process

**Timeline:**
- Initial review: 24-48 hours
- Revisions: 24 hours

**Common Rejection Reasons:**
1. Missing privacy policy
2. Crashes or bugs
3. Incomplete app metadata
4. Performance issues
5. Guideline violations

**Response:**
- Fix issues promptly
- Respond in Resolution Center
- Resubmit within 14 days

---

## 📝 Quick Reference Checklist

### Pre-Development
- [ ] Mac with Apple Silicon + macOS Sonoma 14.0+
- [ ] Xcode 16.0+ installed
- [ ] visionOS SDK downloaded
- [ ] Apple Developer account enrolled

### Project Setup
- [ ] Created visionOS Xcode project
- [ ] Imported VirtualPetEcosystem Swift package
- [ ] Configured Info.plist permissions
- [ ] Set up signing & capabilities

### Development
- [ ] Implemented main app structure
- [ ] Created RealityKit pet models
- [ ] Integrated ARKit spatial features
- [ ] Implemented hand gesture recognition
- [ ] Added spatial anchoring

### Testing
- [ ] All 106 unit tests pass
- [ ] UI tests created and passing
- [ ] Tested in Simulator
- [ ] Tested on physical Vision Pro
- [ ] Performance profiling complete
- [ ] Accessibility verified

### App Store
- [ ] App metadata prepared
- [ ] Screenshots captured
- [ ] Preview video created
- [ ] Privacy policy published
- [ ] App archived and validated
- [ ] Submitted for review

---

## 🆘 Troubleshooting

### Common Issues

**Issue: Simulator won't launch**
```bash
# Reset simulator
xcrun simctl erase all
xcrun simctl shutdown all
# Restart Xcode
```

**Issue: "No code signature found"**
- Go to Signing & Capabilities
- Toggle "Automatically manage signing" off then on
- Clean build folder (⌘⇧K)

**Issue: ARKit features not working**
- Check Info.plist permissions are set
- Request authorization in code
- ARKit requires physical device (not all features work in Simulator)

**Issue: Poor performance**
- Enable Metal Frame Capture
- Profile with Instruments
- Reduce polygon count in 3D models
- Implement LOD system

**Issue: App crash on launch**
- Check Console.app for crash logs
- Verify all resources are included in build
- Test in clean simulator

---

## 📚 Additional Resources

### Apple Documentation
- [visionOS Developer](https://developer.apple.com/visionos/)
- [RealityKit Documentation](https://developer.apple.com/documentation/realitykit)
- [ARKit Documentation](https://developer.apple.com/documentation/arkit)
- [Human Interface Guidelines - visionOS](https://developer.apple.com/design/human-interface-guidelines/visionos)

### Sample Code
- [Apple Vision Pro Sample Code](https://developer.apple.com/documentation/visionos/samples)
- [RealityKit Examples](https://github.com/topics/realitykit)

### Community
- [Apple Developer Forums - visionOS](https://developer.apple.com/forums/tags/visionos)
- [Stack Overflow - visionOS](https://stackoverflow.com/questions/tagged/visionos)

---

## 🎯 Next Steps

Once this checklist is complete:

1. **Beta Testing** via TestFlight
   - Invite 10-100 testers
   - Gather feedback
   - Iterate on features

2. **Marketing**
   - Create landing page
   - Social media presence
   - Press kit

3. **Launch**
   - Submit to App Store
   - Monitor reviews
   - Respond to users

4. **Updates**
   - Monthly new pet species
   - Seasonal events
   - Bug fixes and improvements

---

**Good luck with your visionOS journey! 🚀**
