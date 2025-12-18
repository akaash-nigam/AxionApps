# Spatial UX Design Document
## Home Maintenance Oracle - visionOS

**Version**: 1.0
**Last Updated**: 2025-11-24
**Status**: Draft

---

## Table of Contents

1. [Design Principles](#design-principles)
2. [Spatial Layout](#spatial-layout)
3. [Window Management](#window-management)
4. [3D Content & Volumes](#3d-content--volumes)
5. [Gestures & Interactions](#gestures--interactions)
6. [Voice Commands](#voice-commands)
7. [Accessibility](#accessibility)
8. [Visual Design](#visual-design)
9. [Sound Design](#sound-design)
10. [Scene Flows](#scene-flows)

---

## Design Principles

### Core Principles for Spatial Computing

1. **Context-Aware**: UI adapts to the physical environment
2. **Anchored to Reality**: Information tied to real objects
3. **Comfortable Viewing**: Respect personal space, avoid fatigue
4. **Glanceable**: Key information visible without interaction
5. **Progressive Disclosure**: Show details on demand
6. **Spatial Memory**: Consistent placement helps muscle memory

### visionOS Human Interface Guidelines

- **Comfortable viewing distance**: 0.5-5 meters
- **Primary content**: 1-2 meters from user
- **Minimum text size**: 16pt at 1 meter
- **Maximum simultaneous windows**: 3-5
- **Interaction zones**: Front hemisphere, arm's reach

---

## Spatial Layout

### Default Home Scene

```
                          [User Position]
                                │
                                │ 1.5m
                                ▼
    ┌────────────────────────────────────────────┐
    │          Recognition Target Area           │
    │         (Appliance in real world)         │
    │                                            │
    │  ┌────────────────────────────────────┐  │
    │  │  [Floating Info Card]              │  │  0.5m above appliance
    │  │  Brand: GE                         │  │
    │  │  Model: GDT695SSJ2SS               │  │
    │  │  Status: ✓ Operational             │  │
    │  └────────────────────────────────────┘  │
    │                                            │
    │  [Quick Actions Panel]                    │
    │  ⚙️ Manual  📹 Tutorials  🛒 Parts        │ 0.3m below card
    │                                            │
    └────────────────────────────────────────────┘

         Left Panel (-1m)                Right Panel (+1m)
    ┌──────────────────────┐      ┌──────────────────────┐
    │  📖 Manual Viewer    │      │  📋 Maintenance      │
    │                      │      │     Schedule         │
    │  [PDF Content]       │      │                      │
    │                      │      │  ✅ Change Filter    │
    │  Page 12/48          │      │  ⏰ Clean Coils      │
    │                      │      │  📅 Annual Service   │
    └──────────────────────┘      └──────────────────────┘
```

### Room Overview Mode

```
                    [User at Room Center]
                           │
            ┌──────────────┼──────────────┐
            │              │              │
            │              │              │
      ┌─────┴─────┐  ┌─────┴─────┐  ┌─────┴─────┐
      │ 🚰 Sink   │  │ 🍳 Oven   │  │ ❄️ Fridge │
      │ ✓ OK      │  │ ⚠️ Filter │  │ ✓ OK      │
      └───────────┘  └───────────┘  └───────────┘

                  [Floor Plan View]
                  Toggle in nav bar
```

---

## Window Management

### Window Types

#### 1. Main Recognition Window (Ornament Style)

```swift
struct RecognitionView: View {
    var body: some View {
        VStack {
            // Recognition target
            recognitionTargetView
        }
        .frame(width: 400, height: 600)
        .glassBackgroundEffect()
        .ornament(attachmentAnchor: .scene(.bottom)) {
            quickActionsPanel
        }
    }
}
```

**Properties**:
- Size: 400x600pt
- Position: Follows user gaze to appliance
- Appearance: Glass material with vibrancy
- Behavior: Auto-hides when not looking at appliance

#### 2. Manual Viewer Window (Volume)

```swift
WindowGroup(id: "manual-viewer") {
    ManualViewerView()
        .frame(width: 800, height: 1000)
}
.windowStyle(.volumetric)
.defaultSize(width: 0.8, height: 1.0, depth: 0.1, in: .meters)
```

**Properties**:
- Size: 800x1000pt (0.8x1.0m)
- Position: User's left side, 1m away
- Appearance: High contrast for readability
- Behavior: Stays in place, user can reposition

#### 3. Tutorial Volume (Immersive)

```swift
ImmersiveSpace(id: "tutorial") {
    TutorialVolumeView()
}
.immersionStyle(selection: .constant(.mixed), in: .mixed)
```

**Properties**:
- Type: Mixed immersion
- Content: Video player + 3D annotations
- Position: Overlays actual appliance
- Behavior: Anchored to ARKit world anchor

#### 4. Inventory Dashboard (Traditional)

```swift
WindowGroup(id: "inventory") {
    InventoryDashboardView()
}
.defaultSize(width: 1200, height: 800)
```

**Properties**:
- Size: 1200x800pt
- Position: User preference (moveable)
- Appearance: Standard glass window
- Behavior: Traditional app window

### Window Layout Rules

**Z-Depth Ordering** (front to back):
1. Active modal/alert: z=0 (closest)
2. Quick actions ornament: z=0.1m
3. Recognition card: z=0.2m
4. Side panels: z=0.3m
5. Background windows: z=0.5m

**Spacing Guidelines**:
- Minimum inter-window gap: 0.2m
- Maximum comfortable depth: 5m
- Preferred depth range: 1-2m

---

## 3D Content & Volumes

### Appliance 3D Overlay

**Purpose**: Highlight appliance parts, show maintenance points

```swift
struct Appliance3DOverlay: View {
    @State private var highlightedPart: AppliancePart?

    var body: some View {
        RealityView { content in
            // Load 3D model of appliance
            let applianceEntity = try await Entity.load(named: "dishwasher_model")

            // Position at world anchor
            applianceEntity.transform = worldAnchor.transform

            // Add highlighting
            if let part = highlightedPart {
                let highlight = createHighlight(for: part)
                applianceEntity.addChild(highlight)
            }

            content.add(applianceEntity)
        }
    }

    func createHighlight(for part: AppliancePart) -> Entity {
        let highlightEntity = ModelEntity(
            mesh: .generateBox(size: part.boundingBox.size),
            materials: [UnlitMaterial(color: .yellow.withAlphaComponent(0.3))]
        )
        highlightEntity.position = part.position
        return highlightEntity
    }
}
```

### Tutorial AR Annotations

**3D Arrows & Labels**:

```swift
struct TutorialAnnotation: View {
    let step: TutorialStep

    var body: some View {
        RealityView { content in
            // Create 3D arrow pointing to part
            let arrow = createArrow(
                from: step.cameraPosition,
                to: step.partPosition
            )
            content.add(arrow)

            // Add floating text label
            let label = createLabel(step.instruction)
            label.position = step.partPosition + [0, 0.1, 0]
            content.add(label)
        }
    }

    func createArrow(from: SIMD3<Float>, to: SIMD3<Float>) -> Entity {
        // Create curved arrow entity
        let arrowEntity = ModelEntity(
            mesh: .generateArrow(from: from, to: to),
            materials: [SimpleMaterial(color: .blue, isMetallic: false)]
        )
        return arrowEntity
    }
}
```

### Part Comparison Volume

**Side-by-side 3D models**:

```swift
struct PartComparisonVolume: View {
    let originalPart: Part
    let replacementPart: Part

    var body: some View {
        HStack(spacing: 0.3) {
            RealityView { content in
                let original = try await Entity.load(named: originalPart.modelName)
                original.position = [-0.2, 0, 0]
                content.add(original)

                let replacement = try await Entity.load(named: replacementPart.modelName)
                replacement.position = [0.2, 0, 0]
                content.add(replacement)
            }
        }
        .frame(depth: 0.5)
    }
}
```

---

## Gestures & Interactions

### Standard visionOS Gestures

#### Look & Tap

**Primary interaction**: User looks at element, taps fingers

```swift
Button("View Manual") {
    openManual()
}
.buttonStyle(.bordered)
.hoverEffect()  // Highlights on gaze
```

#### Pinch & Drag

**Window repositioning**:

```swift
.gesture(
    DragGesture()
        .targetedToAnyEntity()
        .onChanged { value in
            entity.position = value.convert(value.location3D, from: .local, to: .scene)
        }
)
```

#### Two-Hand Gestures

**Resize windows**:

```swift
.gesture(
    MagnifyGesture()
        .onChanged { value in
            windowScale *= value.magnification
        }
)
```

### Custom Gestures

#### Swipe Navigation

**Tutorial steps**:

```swift
.gesture(
    DragGesture(minimumDistance: 50)
        .onEnded { gesture in
            if gesture.translation.width < 0 {
                // Swipe left: Next step
                tutorialViewModel.nextStep()
            } else if gesture.translation.width > 0 {
                // Swipe right: Previous step
                tutorialViewModel.previousStep()
            }
        }
)
```

#### Pinch-to-Zoom

**Manual pages, diagrams**:

```swift
@State private var zoomLevel: CGFloat = 1.0

var body: some View {
    PDFViewer(document: manual)
        .scaleEffect(zoomLevel)
        .gesture(
            MagnifyGesture()
                .onChanged { value in
                    zoomLevel = value.magnification
                }
        )
}
```

### Interaction States

**Visual feedback**:

```swift
enum InteractionState {
    case idle
    case hover      // User looking at element
    case pressed    // User tapping
    case dragging   // User moving element
}

struct InteractiveButton: View {
    @State private var state: InteractionState = .idle

    var body: some View {
        Button(action: action) {
            Text(label)
                .padding()
                .background(backgroundColor(for: state))
        }
        .hoverEffect { phase in
            state = phase == .ended ? .hover : .idle
        }
    }

    func backgroundColor(for state: InteractionState) -> Color {
        switch state {
        case .idle: return .blue.opacity(0.3)
        case .hover: return .blue.opacity(0.5)
        case .pressed: return .blue.opacity(0.7)
        case .dragging: return .blue.opacity(0.6)
        }
    }
}
```

---

## Voice Commands

### Natural Language Understanding

```swift
import Speech

class VoiceCommandManager: ObservableObject {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))

    @Published var recognizedCommand: VoiceCommand?

    func startListening() {
        // Request permission, start recognition
    }

    func parseCommand(_ text: String) -> VoiceCommand? {
        let lowercased = text.lowercased()

        // Intent detection
        if lowercased.contains("show manual") || lowercased.contains("open manual") {
            return .showManual
        } else if lowercased.contains("maintenance") {
            return .showMaintenance
        } else if lowercased.contains("tutorial") || lowercased.contains("how to") {
            let issue = extractIssue(from: text)
            return .showTutorial(issue: issue)
        } else if lowercased.contains("order") || lowercased.contains("buy") {
            let part = extractPart(from: text)
            return .orderPart(part: part)
        }

        return nil
    }
}

enum VoiceCommand {
    case showManual
    case showMaintenance
    case showTutorial(issue: String?)
    case orderPart(part: String?)
    case scanAppliance
    case addToInventory
    case setReminder(task: String?)
}
```

### Command Examples

| User Says | Action |
|-----------|--------|
| "Show manual" | Open manual for currently viewed appliance |
| "How do I fix a leaking dishwasher?" | Search tutorials for "dishwasher leaking" |
| "Order a replacement filter" | Open parts search for current appliance's filter |
| "When is maintenance due?" | Open maintenance schedule |
| "Add this to my inventory" | Save current appliance to user's inventory |
| "Set a reminder to clean the coils" | Create maintenance task |
| "Next step" | Advance to next tutorial step |
| "Go back" | Navigate to previous screen |

### Voice Feedback

```swift
import AVFoundation

class VoiceAssistant {
    private let synthesizer = AVSpeechSynthesizer()

    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        synthesizer.speak(utterance)
    }

    func confirmCommand(_ command: VoiceCommand) {
        switch command {
        case .showManual:
            speak("Opening manual")
        case .showTutorial(let issue):
            if let issue = issue {
                speak("Searching for tutorials about \(issue)")
            } else {
                speak("What issue would you like help with?")
            }
        case .orderPart(let part):
            speak("Searching for \(part ?? "replacement parts")")
        default:
            speak("Okay")
        }
    }
}
```

---

## Accessibility

### VoiceOver Support

```swift
struct ApplianceCard: View {
    let appliance: Appliance

    var body: some View {
        VStack {
            Image(appliance.imageName)
                .accessibilityLabel("Photo of \(appliance.brand) \(appliance.category)")

            Text(appliance.model)
                .accessibilityLabel("Model number \(appliance.model)")

            MaintenanceStatusBadge(status: appliance.status)
                .accessibilityLabel(accessibilityStatusLabel)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
        .accessibilityHint("Double tap to view details")
    }

    var accessibilityStatusLabel: String {
        switch appliance.status {
        case .operational:
            return "Status: Operational"
        case .maintenanceDue:
            return "Status: Maintenance due"
        case .issue:
            return "Status: Issue detected"
        }
    }

    var accessibilityDescription: String {
        "\(appliance.brand) \(appliance.category), model \(appliance.model), \(accessibilityStatusLabel)"
    }
}
```

### Text Size & Contrast

```swift
struct AccessibleText: View {
    let text: String
    @Environment(\.sizeCategory) var sizeCategory

    var body: some View {
        Text(text)
            .font(.system(size: fontSize))
            .foregroundColor(.primary)
            .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
    }

    var fontSize: CGFloat {
        switch sizeCategory {
        case .small, .medium, .large:
            return 16
        case .extraLarge, .extraExtraLarge:
            return 20
        case .extraExtraExtraLarge:
            return 24
        default:
            return 16
        }
    }
}
```

### Reduced Motion

```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

var animation: Animation? {
    reduceMotion ? nil : .easeInOut
}

// Usage
.transition(.opacity)
.animation(animation, value: isPresented)
```

### Spatial Audio Cues

```swift
import AVFAudio

class SpatialAudioManager {
    private let audioEngine = AVAudioEngine()
    private let environmentNode = AVAudioEnvironmentNode()

    func playSpatialSound(
        _ soundName: String,
        at position: SIMD3<Float>
    ) {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "wav") else { return }

        let audioFile = try! AVAudioFile(forReading: url)
        let playerNode = AVAudioPlayerNode()

        audioEngine.attach(playerNode)
        audioEngine.connect(playerNode, to: environmentNode, format: audioFile.processingFormat)
        audioEngine.connect(environmentNode, to: audioEngine.mainMixerNode, format: nil)

        environmentNode.listenerPosition = AVAudio3DPoint(x: 0, y: 0, z: 0)
        playerNode.position = AVAudio3DPoint(
            x: position.x,
            y: position.y,
            z: position.z
        )

        playerNode.scheduleFile(audioFile, at: nil)
        playerNode.play()
    }
}

// Usage: Play sound when appliance recognized
spatialAudioManager.playSpatialSound("recognition_success", at: appliancePosition)
```

---

## Visual Design

### Color System

```swift
extension Color {
    // Brand colors
    static let hmoPrimary = Color(red: 0, green: 0.478, blue: 1.0)  // #007AFF
    static let hmoSecondary = Color(red: 0.204, green: 0.78, blue: 0.349)  // #34C759

    // Status colors
    static let statusGood = Color.green
    static let statusWarning = Color.orange
    static let statusCritical = Color.red

    // Adaptive colors
    static let cardBackground = Color(uiColor: .systemBackground)
    static let secondaryText = Color(uiColor: .secondaryLabel)
}
```

### Typography

```swift
extension Font {
    static let hmoTitle = Font.system(size: 32, weight: .bold, design: .rounded)
    static let hmoHeadline = Font.system(size: 24, weight: .semibold)
    static let hmoBody = Font.system(size: 16, weight: .regular)
    static let hmoCaption = Font.system(size: 14, weight: .regular)
    static let hmoMonospace = Font.system(size: 14, design: .monospaced)  // For model numbers
}
```

### Glass Materials

```swift
struct GlassCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding()
            .frame(maxWidth: .infinity)
            .background(.regularMaterial)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

// Usage
GlassCard {
    VStack {
        Text("GE Dishwasher")
        Text("Model: GDT695SSJ2SS")
    }
}
```

### Icons & Symbols

```swift
enum HMOSymbol: String {
    case appliance = "cube.box.fill"
    case manual = "book.fill"
    case tutorial = "play.rectangle.fill"
    case maintenance = "wrench.and.screwdriver.fill"
    case parts = "shippingbox.fill"
    case calendar = "calendar"
    case checkmark = "checkmark.circle.fill"
    case warning = "exclamationmark.triangle.fill"
    case camera = "camera.viewfinder"

    var image: Image {
        Image(systemName: rawValue)
    }
}
```

---

## Sound Design

### Audio Feedback

| Event | Sound | Description |
|-------|-------|-------------|
| Appliance recognized | Gentle chime (C-E-G) | Success confirmation |
| Manual loaded | Page turn | Content ready |
| Task completed | Success ding | Positive reinforcement |
| Error | Soft error tone | Non-intrusive alert |
| Navigation | Subtle click | UI feedback |
| Voice command accepted | Short beep | Recognition confirmed |

```swift
import AVFoundation

class SoundManager {
    static let shared = SoundManager()

    private var audioPlayers: [String: AVAudioPlayer] = [:]

    func preloadSounds() {
        let sounds = [
            "recognition_success",
            "page_turn",
            "task_complete",
            "error",
            "click",
            "voice_accepted"
        ]

        for sound in sounds {
            guard let url = Bundle.main.url(forResource: sound, withExtension: "wav") else { continue }
            audioPlayers[sound] = try? AVAudioPlayer(contentsOf: url)
            audioPlayers[sound]?.prepareToPlay()
        }
    }

    func play(_ sound: String) {
        audioPlayers[sound]?.play()
    }
}
```

### Haptic Feedback

```swift
#if os(iOS)
import UIKit

class HapticManager {
    static let shared = HapticManager()

    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let notificationGenerator = UINotificationFeedbackGenerator()

    func trigger(_ type: HapticType) {
        switch type {
        case .selection:
            impactLight.impactOccurred()
        case .success:
            notificationGenerator.notificationOccurred(.success)
        case .warning:
            notificationGenerator.notificationOccurred(.warning)
        case .error:
            notificationGenerator.notificationOccurred(.error)
        }
    }
}

enum HapticType {
    case selection
    case success
    case warning
    case error
}
#endif
```

---

## Scene Flows

### Flow 1: Appliance Recognition

```
User enters room with Vision Pro
    │
    ▼
[Home Screen]
"Point at an appliance"
    │
    ▼
User looks at dishwasher
    │
    ▼
[Recognition in progress...]
Camera feed analyzed (2s)
    │
    ▼
[Appliance Card appears]
Floating above dishwasher
- Brand: GE
- Model: GDT695SSJ2SS
- Status: ✓ Operational
    │
    ▼
[Quick Actions Panel]
⚙️ Manual  📹 Tutorials  🛒 Parts
    │
    ├─── User taps "Manual"
    │    ▼
    │    [Manual Window opens on left]
    │    PDF viewer with search
    │
    ├─── User taps "Tutorials"
    │    ▼
    │    [Tutorial list appears]
    │    User selects "How to clean filter"
    │    ▼
    │    [Immersive tutorial mode]
    │    Video overlaid on dishwasher
    │    3D arrows point to parts
    │
    └─── User taps "Parts"
         ▼
         [Parts browser opens]
         List of compatible parts
         Price comparison
```

### Flow 2: Maintenance Reminder

```
User receives notification
"HVAC filter change due"
    │
    ▼
User opens app
    │
    ▼
[Maintenance Dashboard]
List of upcoming tasks
- Today: HVAC filter
- This week: Clean coils
- This month: Inspect furnace
    │
    ▼
User selects "HVAC filter"
    │
    ▼
[Task Detail View]
- Description
- Last completed: 3 months ago
- Estimated time: 5 minutes
- Cost: $25 (if ordering filter)
    │
    ▼
User taps "Start Task"
    │
    ▼
[Guided mode]
1. Shows where HVAC is in home (3D map)
2. User walks to HVAC
3. Shows filter location with AR overlay
4. Option to watch tutorial
    │
    ▼
User completes task
    │
    ▼
[Capture photo] (optional)
Take photo of new filter
    │
    ▼
[Mark Complete]
Task logged in history
Next reminder scheduled
```

### Flow 3: Part Ordering

```
User identifies broken part
    │
    ▼
[Point camera at part]
Recognition in progress...
    │
    ▼
[Part identified]
"Dishwasher Door Latch"
Part #: WD13X10003
    │
    ▼
[Price Comparison]
Amazon: $12.99 (Prime)
eBay: $10.50 (+ $3 shipping)
Manufacturer: $15.99
    │
    ▼
User selects Amazon listing
    │
    ▼
[Order Confirmation]
- Part: Door latch
- Price: $12.99
- Delivery: 2 days
- Compatibility: ✓ Confirmed
    │
    ▼
User taps "Order"
    │
    ▼
Opens Safari with affiliate link
Purchase on Amazon
    │
    ▼
Returns to app
Order tracked in app
```

---

**Document Status**: Ready for Review
**Next Steps**: Create interactive prototypes, conduct user testing with Vision Pro hardware
