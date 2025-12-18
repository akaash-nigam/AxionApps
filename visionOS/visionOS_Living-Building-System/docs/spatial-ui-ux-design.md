# Spatial UI/UX Design Specifications
## Living Building System

**Version**: 1.0
**Last Updated**: 2025-11-24
**Status**: Draft

---

## 1. Overview

This document defines the spatial user interface and user experience design for the Living Building System on visionOS. It covers spatial layouts, interaction patterns, visual design, and accessibility considerations specific to spatial computing.

## 2. visionOS Design Principles

### 2.1 Core Principles
1. **Spatial Awareness**: UI elements anchored meaningfully in physical space
2. **Natural Interaction**: Leverage eyes, hands, and voice
3. **Depth & Dimension**: Use z-space effectively
4. **Comfortable Viewing**: Respect ergonomic viewing zones
5. **Context-Aware**: Information appears where it's relevant
6. **Progressive Disclosure**: Show only what's needed
7. **Accessibility First**: Usable by everyone

### 2.2 Viewing Zones

```
Comfortable Viewing Zone:
- Distance: 0.5m to 3m from user
- Vertical: -30° to +30° from eye level
- Horizontal: -40° to +40° from center

Optimal Reading Distance: 0.7m to 1.2m
AR Overlay Distance: Match physical surface depth
```

## 3. Window Types & Usage

### 3.1 Window Hierarchy

```swift
@main
struct LivingBuildingSystemApp: App {
    @State private var immersionStyle: ImmersionStyle = .mixed

    var body: some Scene {
        // Primary dashboard window
        WindowGroup(id: "dashboard") {
            DashboardView()
        }
        .windowStyle(.plain)
        .defaultSize(width: 600, height: 800)

        // Device detail windows
        WindowGroup(id: "device-detail", for: UUID.self) { $deviceID in
            DeviceDetailView(deviceID: deviceID)
        }
        .windowStyle(.plain)
        .defaultSize(width: 400, height: 500)

        // Settings window
        WindowGroup(id: "settings") {
            SettingsView()
        }
        .windowStyle(.plain)

        // Main immersive experience
        ImmersiveSpace(id: "home-view") {
            FullHomeImmersiveView()
        }
        .immersionStyle(selection: $immersionStyle, in: .mixed, .progressive, .full)

        // Energy flow visualization
        ImmersiveSpace(id: "energy-flow") {
            EnergyFlowView()
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}
```

### 3.2 Window Specifications

| Window Type | Size (points) | Usage | Depth | Resizable |
|-------------|---------------|-------|-------|-----------|
| Dashboard | 600×800 | Main control panel | Floating | Yes |
| Device Detail | 400×500 | Device controls | Floating | No |
| Settings | 500×700 | App configuration | Floating | Yes |
| Contextual Display | 400×600 | Wall-mounted info | Anchored | No |
| Energy Widget | 300×200 | Quick energy view | Floating | No |

## 4. Contextual Wall Displays

### 4.1 Design Specifications

```swift
struct ContextualDisplayView: View {
    let room: Room
    let user: User?

    var body: some View {
        ZStack {
            // Glass background material
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                }

            // Content
            VStack(alignment: .leading, spacing: 20) {
                HeaderSection(room: room, user: user)
                WidgetGrid(widgets: room.enabledWidgets)
            }
            .padding(24)
        }
        .frame(width: 400, height: 600)
        .glassBackgroundEffect()
    }
}
```

### 4.2 Visual Design

**Color Palette**:
```swift
extension Color {
    // Primary colors
    static let lbsPrimary = Color(red: 0.0, green: 0.5, blue: 1.0) // Blue
    static let lbsSecondary = Color(red: 0.2, green: 0.8, blue: 0.6) // Teal

    // Status colors
    static let lbsSuccess = Color(red: 0.2, green: 0.8, blue: 0.4) // Green
    static let lbsWarning = Color(red: 1.0, green: 0.8, blue: 0.0) // Yellow
    static let lbsError = Color(red: 1.0, green: 0.3, blue: 0.3) // Red
    static let lbsInfo = Color(red: 0.4, green: 0.6, blue: 1.0) // Light blue

    // Energy visualization
    static let energyLow = Color(red: 0.2, green: 0.8, blue: 0.4) // Green
    static let energyMedium = Color(red: 1.0, green: 0.8, blue: 0.0) // Orange
    static let energyHigh = Color(red: 1.0, green: 0.3, blue: 0.3) // Red
}
```

**Typography**:
```swift
extension Font {
    static let lbsTitle = Font.system(size: 28, weight: .bold, design: .rounded)
    static let lbsHeadline = Font.system(size: 20, weight: .semibold, design: .rounded)
    static let lbsBody = Font.system(size: 17, weight: .regular, design: .default)
    static let lbsCaption = Font.system(size: 14, weight: .regular, design: .default)
    static let lbsValue = Font.system(size: 48, weight: .bold, design: .rounded)
        .monospacedDigit()
}
```

**Spacing & Layout**:
```swift
struct LBSSpacing {
    static let tiny: CGFloat = 4
    static let small: CGFloat = 8
    static let medium: CGFloat = 16
    static let large: CGFloat = 24
    static let extraLarge: CGFloat = 32
}
```

### 4.3 Kitchen Display Example

```swift
struct KitchenDisplayView: View {
    @State private var recipes: [Recipe] = []
    @State private var groceryList: [GroceryItem] = []
    @State private var energyUsage: Double = 0

    var body: some View {
        VStack(alignment: .leading, spacing: LBSSpacing.large) {
            // Header
            HStack {
                Image(systemName: "fork.knife")
                    .font(.title)
                    .foregroundStyle(.secondary)
                Text("Kitchen")
                    .font(.lbsTitle)
                Spacer()
                Text(Date.now, style: .time)
                    .font(.lbsCaption)
                    .foregroundStyle(.secondary)
            }

            Divider()

            // Recipe suggestion
            RecipeWidget(recipe: recipes.first)

            // Grocery list summary
            GroceryWidget(items: groceryList)

            // Energy usage
            EnergyWidget(usage: energyUsage, type: .kitchen)

            Spacer()
        }
        .padding(LBSSpacing.large)
        .frame(width: 400, height: 600)
        .glassBackgroundEffect()
    }
}
```

### 4.4 Widget Components

```swift
struct RecipeWidget: View {
    let recipe: Recipe?

    var body: some View {
        VStack(alignment: .leading, spacing: LBSSpacing.small) {
            Label("Dinner Tonight", systemImage: "fork.knife.circle.fill")
                .font(.lbsHeadline)
                .foregroundStyle(.primary)

            if let recipe = recipe {
                Text(recipe.name)
                    .font(.lbsBody)
                    .fontWeight(.medium)

                HStack(spacing: LBSSpacing.medium) {
                    Button("View Recipe") {
                        // Action
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Start Cooking") {
                        // Action
                    }
                    .buttonStyle(.bordered)
                }
            } else {
                Text("No suggestions")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(LBSSpacing.medium)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}
```

## 5. Immersive Energy Flow Visualization

### 5.1 Spatial Layout

```
User's Home (Top-Down View):
┌──────────────────────────────────┐
│                                   │
│  [Breaker Panel]──────┬─────┐    │
│                       │     │    │
│  Bedroom         Living Room     │
│  [0.2 kW]        [3.2 kW]        │
│                       │           │
│                  Kitchen          │
│                  [1.1 kW]         │
│                                   │
└──────────────────────────────────┘

Flow Visualization:
- Thick animated streams from high-usage rooms
- Color-coded by intensity (green → yellow → red)
- Particle effects along the flow paths
- 3D depth: flows appear to move through walls
```

### 5.2 RealityView Implementation

```swift
struct EnergyFlowView: View {
    @State private var energyData: EnergyFlowData?

    var body: some View {
        RealityView { content in
            // Create flow visualization entities
            if let data = energyData {
                let flowSystem = createFlowSystem(data: data)
                content.add(flowSystem)
            }
        } update: { content in
            // Update flow rates in real-time
            updateFlowSystem(content: content, data: energyData)
        }
        .task {
            // Stream real-time energy data
            for await data in energyManager.streamFlowData() {
                energyData = data
            }
        }
    }

    func createFlowSystem(data: EnergyFlowData) -> Entity {
        let root = Entity()

        for flow in data.flows {
            let flowEntity = createFlowEntity(
                from: flow.source,
                to: flow.destination,
                power: flow.power
            )
            root.addChild(flowEntity)
        }

        return root
    }

    func createFlowEntity(
        from source: SIMD3<Float>,
        to destination: SIMD3<Float>,
        power: Double
    ) -> Entity {
        let entity = Entity()

        // Particle system for flow
        let particleEmitter = ParticleEmitterComponent(
            particleCount: Int(power * 10),
            color: colorForPower(power),
            speed: Float(power / 10.0)
        )

        entity.components[ParticleEmitterComponent.self] = particleEmitter
        entity.position = source

        // Animate particles along path
        animateFlow(entity, to: destination, duration: 2.0)

        return entity
    }

    func colorForPower(_ power: Double) -> UIColor {
        switch power {
        case 0..<1.0:
            return UIColor(Color.energyLow)
        case 1.0..<2.5:
            return UIColor(Color.energyMedium)
        default:
            return UIColor(Color.energyHigh)
        }
    }
}
```

### 5.3 Energy Flow Indicators

```swift
struct EnergyIndicatorView: View {
    let appliance: String
    let power: Double // kW
    let position: SIMD3<Float>

    var body: some View {
        VStack(spacing: LBSSpacing.small) {
            Text(appliance)
                .font(.lbsCaption)
                .fontWeight(.medium)

            Text(power, format: .number.precision(.fractionLength(1)))
                .font(.lbsValue)
                .foregroundStyle(colorForPower)
                +
                Text(" kW")
                .font(.lbsBody)
                .foregroundStyle(.secondary)

            PowerMeter(power: power)
        }
        .padding(LBSSpacing.medium)
        .glassBackgroundEffect()
        .position3D(position)
    }

    var colorForPower: Color {
        switch power {
        case 0..<1.0: .energyLow
        case 1.0..<2.5: .energyMedium
        default: .energyHigh
        }
    }
}

struct PowerMeter: View {
    let power: Double
    let maxPower: Double = 5.0

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                Capsule()
                    .fill(.ultraThinMaterial)
                    .frame(height: 8)

                // Fill
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [.energyLow, .energyMedium, .energyHigh],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(
                        width: geometry.size.width * min(power / maxPower, 1.0),
                        height: 8
                    )
            }
        }
        .frame(height: 8)
    }
}
```

## 6. Device Control Interface

### 6.1 Look-to-Control Pattern

```swift
struct DeviceControlOverlay: View {
    let device: SmartDevice
    @State private var isLooking = false
    @State private var showControls = false

    var body: some View {
        ZStack {
            // Subtle indicator when user looks at device
            if isLooking {
                Circle()
                    .stroke(Color.lbsPrimary, lineWidth: 2)
                    .frame(width: 80, height: 80)
                    .transition(.scale.combined(with: .opacity))
            }

            // Full controls appear on sustained look
            if showControls {
                DeviceControlPanel(device: device)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .onContinuousHover { phase in
            switch phase {
            case .active:
                isLooking = true
                // Show controls after 0.5s of sustained looking
                Task {
                    try? await Task.sleep(for: .milliseconds(500))
                    if isLooking {
                        withAnimation(.spring) {
                            showControls = true
                        }
                    }
                }
            case .ended:
                isLooking = false
                withAnimation {
                    showControls = false
                }
            }
        }
    }
}
```

### 6.2 Device Control Panels

```swift
struct LightControlPanel: View {
    @Bindable var device: SmartDevice
    @State private var brightness: Double = 0.8

    var body: some View {
        VStack(spacing: LBSSpacing.large) {
            // Header
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(device.isOn ? .yellow : .secondary)
                Text(device.name)
                    .font(.lbsHeadline)
                Spacer()
                Toggle("", isOn: $device.isOn)
                    .toggleStyle(.switch)
            }

            if device.isOn {
                // Brightness slider
                VStack(alignment: .leading, spacing: LBSSpacing.small) {
                    Text("Brightness")
                        .font(.lbsCaption)
                        .foregroundStyle(.secondary)

                    Slider(value: $brightness, in: 0...1)
                        .tint(.lbsPrimary)

                    HStack {
                        Text("\(Int(brightness * 100))%")
                            .font(.lbsBody.monospacedDigit())
                        Spacer()
                    }
                }

                // Quick presets
                HStack(spacing: LBSSpacing.small) {
                    BrightnessPresetButton(level: 0.25, label: "25%", brightness: $brightness)
                    BrightnessPresetButton(level: 0.50, label: "50%", brightness: $brightness)
                    BrightnessPresetButton(level: 0.75, label: "75%", brightness: $brightness)
                    BrightnessPresetButton(level: 1.0, label: "100%", brightness: $brightness)
                }
            }
        }
        .padding(LBSSpacing.large)
        .frame(width: 320)
        .glassBackgroundEffect()
    }
}

struct ThermostatControlPanel: View {
    @Bindable var device: SmartDevice
    @State private var targetTemp: Double = 72

    var body: some View {
        VStack(spacing: LBSSpacing.large) {
            // Current temperature (large)
            VStack(spacing: LBSSpacing.tiny) {
                Text("Currently")
                    .font(.lbsCaption)
                    .foregroundStyle(.secondary)

                Text(device.currentTemperature ?? 0, format: .number.precision(.fractionLength(0)))
                    .font(.system(size: 64, weight: .bold, design: .rounded).monospacedDigit())
                    +
                    Text("°F")
                    .font(.title)
                    .foregroundStyle(.secondary)
            }

            Divider()

            // Target temperature control
            VStack(spacing: LBSSpacing.medium) {
                Text("Set Temperature")
                    .font(.lbsHeadline)

                HStack(spacing: LBSSpacing.large) {
                    Button {
                        targetTemp -= 1
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.largeTitle)
                    }

                    Text(targetTemp, format: .number.precision(.fractionLength(0)))
                        .font(.lbsValue)
                        +
                        Text("°")
                        .font(.title)

                    Button {
                        targetTemp += 1
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.largeTitle)
                    }
                }
                .buttonStyle(.borderless)
            }

            // Mode selector
            Picker("Mode", selection: $device.thermostatMode) {
                Text("Off").tag(ThermostatMode.off)
                Text("Heat").tag(ThermostatMode.heat)
                Text("Cool").tag(ThermostatMode.cool)
                Text("Auto").tag(ThermostatMode.auto)
            }
            .pickerStyle(.segmented)
        }
        .padding(LBSSpacing.large)
        .frame(width: 360)
        .glassBackgroundEffect()
    }
}
```

## 7. Gesture Interactions

### 7.1 Supported Gestures

| Gesture | Action | Context |
|---------|--------|---------|
| Tap | Select/Activate | Buttons, toggles |
| Pinch | Quick toggle | Lights on/off |
| Look + Tap | Contextual control | Device control |
| Drag | Adjust value | Sliders, dimmers |
| Two-finger pinch | Zoom | Energy flow view |
| Rotation | Not used | N/A |

### 7.2 Pinch Gesture Example

```swift
struct QuickToggleGesture: ViewModifier {
    let device: SmartDevice
    let onToggle: () -> Void

    func body(content: Content) -> some View {
        content
            .gesture(
                SpatialTapGesture(count: 1, coordinateSpace: .local)
                    .targetedToAnyEntity()
                    .onEnded { value in
                        // Quick toggle on pinch
                        onToggle()

                        // Haptic feedback
                        let feedback = UIImpactFeedbackGenerator(style: .medium)
                        feedback.impactOccurred()
                    }
            )
    }
}
```

## 8. Spatial Audio

### 8.1 Audio Cues

```swift
enum AudioCue {
    case deviceToggled
    case sceneActivated
    case alertReceived
    case energyThresholdExceeded
    case confirmationSuccess
    case error

    var soundFile: String {
        switch self {
        case .deviceToggled: "toggle.caf"
        case .sceneActivated: "scene_activate.caf"
        case .alertReceived: "alert.caf"
        case .energyThresholdExceeded: "warning.caf"
        case .confirmationSuccess: "success.caf"
        case .error: "error.caf"
        }
    }
}

func playAudioCue(_ cue: AudioCue, at position: SIMD3<Float>? = nil) {
    let audioResource = try? AudioFileResource.load(named: cue.soundFile)

    if let position = position {
        // Spatial audio at specific position
        let audioEntity = Entity()
        audioEntity.position = position
        audioEntity.components[AudioPlaybackComponent.self] = AudioPlaybackComponent(
            resource: audioResource,
            isPositional: true
        )
    } else {
        // Non-spatial audio
        // Play through system audio
    }
}
```

## 9. Accessibility

### 9.1 VoiceOver Support

```swift
struct AccessibleDeviceControl: View {
    let device: SmartDevice

    var body: some View {
        Toggle(isOn: $device.isOn) {
            Label(device.name, systemImage: device.icon)
        }
        .accessibilityLabel("\(device.name) light")
        .accessibilityValue(device.isOn ? "On" : "Off")
        .accessibilityHint("Double tap to toggle")
    }
}
```

### 9.2 Pointer Control

```swift
// All interactive elements support pointer control automatically
// Ensure minimum hit target size of 44×44 points
struct AccessibleButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .frame(minWidth: 44, minHeight: 44)
        }
        .hoverEffect()
    }
}
```

### 9.3 High Contrast Mode

```swift
@Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor

struct StatusIndicator: View {
    let status: DeviceStatus

    var body: some View {
        HStack {
            Circle()
                .fill(status.color)
                .frame(width: 12, height: 12)

            if differentiateWithoutColor {
                Image(systemName: status.icon)
                    .foregroundStyle(status.color)
            }

            Text(status.label)
        }
    }
}
```

## 10. Animations & Transitions

### 10.1 Standard Animations

```swift
extension Animation {
    static let lbsSpring = Animation.spring(response: 0.4, dampingFraction: 0.8)
    static let lbsEaseInOut = Animation.easeInOut(duration: 0.3)
    static let lbsFast = Animation.easeInOut(duration: 0.15)
}
```

### 10.2 Contextual Display Animation

```swift
struct ContextualDisplayModifier: ViewModifier {
    let isVisible: Bool

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .scaleEffect(isVisible ? 1 : 0.8)
            .animation(.lbsSpring, value: isVisible)
    }
}
```

## 11. Dark Mode & Appearance

```swift
@Environment(\.colorScheme) var colorScheme

// Adaptive colors
extension Color {
    static var lbsBackground: Color {
        Color(uiColor: .systemBackground)
    }

    static var lbsSecondaryBackground: Color {
        Color(uiColor: .secondarySystemBackground)
    }
}
```

## 12. Performance Guidelines

### 12.1 Frame Rate Targets
- UI Animations: 60 FPS minimum
- Particle Systems: 60 FPS (reduce particle count if needed)
- Real-time Updates: 10-30 Hz (no need for 60 Hz data updates)

### 12.2 Optimization Techniques
- Use `.drawingGroup()` for complex overlays
- Lazy load widget content
- Throttle real-time data updates
- Use LOD for distant 3D content

---

**Document Owner**: Design Team
**Review Cycle**: Quarterly
**Next Review**: 2026-02-24
