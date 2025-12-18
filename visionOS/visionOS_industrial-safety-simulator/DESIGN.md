# Industrial Safety Simulator - Design Specifications

## Table of Contents
1. [Spatial Design Principles](#spatial-design-principles)
2. [Visual Design System](#visual-design-system)
3. [Window Layouts and Configurations](#window-layouts-and-configurations)
4. [Volume Designs (3D Bounded Spaces)](#volume-designs-3d-bounded-spaces)
5. [Full Space/Immersive Experiences](#full-spaceimmersive-experiences)
6. [3D Visualization Specifications](#3d-visualization-specifications)
7. [Interaction Patterns](#interaction-patterns)
8. [User Flows and Navigation](#user-flows-and-navigation)
9. [Accessibility Design](#accessibility-design)
10. [Error States and Loading Indicators](#error-states-and-loading-indicators)
11. [Animation and Transition Specifications](#animation-and-transition-specifications)

---

## Spatial Design Principles

### Core Design Philosophy

**"Safety Through Immersion, Clarity Through Design"**

The Industrial Safety Simulator's design prioritizes:
1. **Realistic Hazard Representation**: Dangers must be clearly visible and accurately portrayed
2. **Intuitive Safety Indicators**: Universal safety color coding and clear visual hierarchy
3. **Comfortable Spatial Ergonomics**: Extended training sessions without fatigue
4. **Progressive Complexity**: Gradual introduction to spatial interfaces
5. **Confidence Building**: Clear feedback and guidance throughout the experience

### Spatial Hierarchy Framework

```
Environmental Hierarchy (Z-Axis Depth):

Critical Safety Alerts          [0.3m - 0.5m]  ← Closest, most urgent
├── Emergency stop controls
├── Danger warnings
└── Critical feedback

Primary Training Content        [0.8m - 2m]    ← Main interaction zone
├── Equipment models
├── Training instructions
├── Interactive hazards
└── Performance feedback

Contextual Information          [2m - 4m]      ← Supportive content
├── Score displays
├── Timer
├── Scenario objectives
└── Help hints

Environmental Context           [4m - 20m]     ← Immersive background
├── Factory environment
├── Other workers (collaborative)
├── Ambient hazards
└── Spatial landmarks
```

### Ergonomic Positioning Guidelines

#### Vertical Placement
- **Eye Level Reference**: 0° (horizontal gaze)
- **Optimal Viewing Zone**: -10° to -15° below eye level
- **Readable Text Range**: -5° to -20°
- **Peripheral Alerts**: -20° to -30° (below) or +10° to +20° (above)

#### Horizontal Distribution
- **Primary Content**: ±30° from center
- **Secondary Content**: ±30° to ±60° from center
- **Peripheral Indicators**: ±60° to ±90° from center

#### Distance Guidelines
- **Reading Distance**: 0.8m - 1.2m for text-heavy content
- **Interaction Distance**: 0.6m - 1.5m for hand interactions
- **Observation Distance**: 2m - 5m for large equipment or environments

### Safety-Specific Design Patterns

#### Universal Safety Colors
- **Red**: Immediate danger, prohibited actions, emergency stop
- **Orange**: High-priority warnings, active hazards
- **Yellow**: Caution, moderate risk, attention required
- **Green**: Safe conditions, correct actions, proceed
- **Blue**: Mandatory actions, required PPE, information
- **Purple**: Radiation hazards (industry-specific)

#### Hazard Visibility Enhancement
- **Pulsing Glow**: Active hazards pulse gently (1-second cycle)
- **Proximity Intensity**: Warnings brighten as user approaches
- **Outline Emphasis**: Critical elements have bold outlines
- **Contrast Requirements**: Minimum 4.5:1 contrast ratio for all safety text

---

## Visual Design System

### Color Palette

#### Primary Colors

```swift
// Brand Colors
let primaryBlue = Color(hex: "#0066CC")      // Professional, trustworthy
let primaryNavy = Color(hex: "#1A3A52")      // Corporate, stable
let accentOrange = Color(hex: "#FF6B35")     // Energy, action

// Safety Indication Colors (ISO 3864 compliant)
let safetyRed = Color(hex: "#C1272D")        // Danger, prohibition
let safetyOrange = Color(hex: "#FF8200")     // Warning, high priority
let safetyYellow = Color(hex: "#FFD100")     // Caution, moderate risk
let safetyGreen = Color(hex: "#00833E")      // Safe, proceed, emergency exit
let safetyBlue = Color(hex: "#005EB8")       // Mandatory, information

// Neutrals
let neutralDark = Color(hex: "#1C1C1E")      // Dark text, high contrast
let neutralMedium = Color(hex: "#636366")    // Secondary text
let neutralLight = Color(hex: "#E5E5EA")     // Borders, dividers
let neutralPale = Color(hex: "#F2F2F7")      // Backgrounds, cards

// Semantic Colors
let successGreen = Color(hex: "#34C759")     // Success states, achievements
let errorRed = Color(hex: "#FF3B30")         // Errors, failures
let warningYellow = Color(hex: "#FFCC00")    // Warnings, attention needed
let infoBlue = Color(hex: "#007AFF")         // Information, guidance
```

#### Glass Materials (visionOS-Specific)

```swift
// Standard visionOS materials with safety-appropriate tints

// Windows and Cards
let standardGlass = Material.regular          // Default windows
let thickGlass = Material.thick               // Important panels
let thinGlass = Material.thin                 // Subtle overlays
let ultraThinGlass = Material.ultraThin       // Minimal chrome

// Safety-specific tinted glass
let dangerGlass = Material.regular
    .tinted(.red.opacity(0.15))              // Emergency panels
let warningGlass = Material.regular
    .tinted(.orange.opacity(0.12))           // Warning dialogs
let safeGlass = Material.regular
    .tinted(.green.opacity(0.10))            // Success confirmations
```

### Typography

#### Font System

```swift
// Primary Typeface: SF Pro (System Default)
// Benefits: Optimized for visionOS, excellent legibility, Dynamic Type support

// Hierarchy
let displayLarge = Font.system(size: 56, weight: .bold)        // Hero headlines
let displayMedium = Font.system(size: 44, weight: .semibold)   // Section headers
let displaySmall = Font.system(size: 32, weight: .medium)      // Subsection headers

let titleLarge = Font.system(size: 28, weight: .semibold)      // Card titles
let titleMedium = Font.system(size: 24, weight: .medium)       // Content headers
let titleSmall = Font.system(size: 20, weight: .medium)        // List headers

let bodyLarge = Font.system(size: 18, weight: .regular)        // Primary body text
let bodyMedium = Font.system(size: 16, weight: .regular)       // Standard body text
let bodySmall = Font.system(size: 14, weight: .regular)        // Secondary text

let labelLarge = Font.system(size: 16, weight: .semibold)      // Button labels
let labelMedium = Font.system(size: 14, weight: .medium)       // Small buttons
let labelSmall = Font.system(size: 12, weight: .medium)        // Captions, metadata

// Monospaced for data
let codeMedium = Font.system(size: 16, weight: .regular, design: .monospaced)
```

#### 3D Text Specifications

```swift
// For spatial text entities in RealityKit

struct SpatialTextStyle {
    // Floating UI text in 3D space
    static let floatingLabel = TextStyle(
        font: .systemFont(ofSize: 24, weight: .semibold),
        alignment: .center,
        color: .white,
        depth: 0.01,                    // Slight extrusion
        materials: [SimpleMaterial(
            color: .white,
            isMetallic: false
        )]
    )

    // Warning signs and safety signage
    static let safetySign = TextStyle(
        font: .systemFont(ofSize: 36, weight: .bold),
        alignment: .center,
        color: .white,
        depth: 0.02,
        materials: [SimpleMaterial(
            color: .white,
            isMetallic: false
        )]
    )

    // Hazard labels
    static let hazardLabel = TextStyle(
        font: .systemFont(ofSize: 28, weight: .heavy),
        alignment: .center,
        color: .red,
        depth: 0.015,
        materials: [SimpleMaterial(
            color: .red,
            isMetallic: false
        )]
    )
}
```

### Iconography

#### SF Symbols Usage

```swift
// Primary navigation icons
let dashboardIcon = "square.grid.2x2"
let trainingIcon = "figure.walk"
let analyticsIcon = "chart.bar.fill"
let scenarioIcon = "cube.fill"
let settingsIcon = "gearshape.fill"

// Safety-specific icons
let hazardIcon = "exclamationmark.triangle.fill"
let fireIcon = "flame.fill"
let chemicalIcon = "drop.fill"
let electricalIcon = "bolt.fill"
let fallIcon = "figure.fall"
let ppeHelmetIcon = "helmet.fill"        // visionOS 2.0+
let ppeGlovesIcon = "glove.fill"

// Actions
let startIcon = "play.fill"
let pauseIcon = "pause.fill"
let stopIcon = "stop.fill"
let emergencyStopIcon = "octagon.fill"
let checkmarkIcon = "checkmark.circle.fill"
let xmarkIcon = "xmark.circle.fill"

// Status indicators
let successIcon = "checkmark.seal.fill"
let warningIcon = "exclamationmark.triangle.fill"
let errorIcon = "xmark.octagon.fill"
let infoIcon = "info.circle.fill"
```

#### Custom 3D Icons

For immersive spaces, use custom 3D icon models:
- **PPE Icons**: 3D models of helmets, gloves, vests
- **Equipment Icons**: Simplified machinery representations
- **Hazard Symbols**: Volumetric warning symbols

### Materials and Lighting

#### Standard Materials

```swift
// Industrial Metal (equipment, machinery)
let industrialMetal = SimpleMaterial(
    color: .init(white: 0.7),
    roughness: 0.4,
    isMetallic: true
)

// Painted Metal (safety equipment)
let paintedMetal = SimpleMaterial(
    color: .init(red: 0.9, green: 0.3, blue: 0.2), // Safety orange
    roughness: 0.6,
    isMetallic: false
)

// Hazardous Materials (chemicals, radiation)
let hazardousMaterial = SimpleMaterial(
    color: .yellow,
    roughness: 0.2,
    isMetallic: false
).withEmissiveColor(.yellow, intensity: 0.5)  // Self-illuminated

// Concrete/Industrial Surfaces
let concreteMaterial = PhysicallyBasedMaterial()
concreteMaterial.baseColor = .init(tint: .init(white: 0.6))
concreteMaterial.roughness = 0.9
concreteMaterial.metallic = 0.0
```

#### Lighting Design

```swift
// Factory floor lighting
let factoryLighting = EnvironmentLighting(
    intensity: 800,                    // Bright industrial lighting
    color: .init(white: 0.95),        // Cool white
    shadows: .hard                     // Sharp shadows from overhead lights
)

// Emergency lighting (fire scenario)
let emergencyLighting = EnvironmentLighting(
    intensity: 200,                    // Dimmed emergency state
    color: .init(red: 1.0, green: 0.3, blue: 0.2),  // Red emergency lights
    shadows: .soft
)

// Outdoor construction site
let outdoorLighting = EnvironmentLighting(
    intensity: 1200,                   // Bright daylight
    color: .init(white: 1.0),         // Neutral white
    shadows: .hard,
    environmentMap: "construction_sky.hdr"
)
```

---

## Window Layouts and Configurations

### 1. Main Dashboard Window

**Window ID**: `main-dashboard`
**Default Size**: 1200pt × 800pt
**Resizability**: Content-based (800pt-1600pt width, 600pt-1000pt height)

#### Layout Structure

```
┌─────────────────────────────────────────────────────────────┐
│ [User Avatar] Industrial Safety Simulator    [🔔] [⚙️] [✕] │ ← Title Bar (48pt)
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐│
│  │ Current Status  │  │ Quick Actions   │  │ Progress     ││
│  │                 │  │                 │  │              ││
│  │ ✓ 8 Completed   │  │ [Start Training]│  │ Level 2      ││
│  │ → 2 In Progress │  │ [View Scenarios]│  │ 65% Complete ││
│  │ ⚠ 1 Failed      │  │ [Certifications]│  │              ││
│  └─────────────────┘  └─────────────────┘  └──────────────┘│ ← Cards (180pt)
│                                                               │
│  Recent Training Sessions                          [See All] │
│  ┌───────────────────────────────────────────────────────┐  │
│  │ Fire Evacuation             85%  ✓  2 hours ago       │  │
│  │ Chemical Spill Response     92%  ✓  Yesterday         │  │
│  │ Lockout/Tagout Procedures   68%  ⚠  2 days ago        │  │
│  └───────────────────────────────────────────────────────┘  │ ← List (320pt)
│                                                               │
│  Upcoming Training                                            │
│  ┌───────────────────────────────────────────────────────┐  │
│  │ Confined Space Entry        Due: Tomorrow             │  │
│  │ Height Work Safety          Due: In 3 days            │  │
│  └───────────────────────────────────────────────────────┘  │ ← List (160pt)
│                                                               │
│  [View Full Analytics]         [Browse Scenario Library]     │ ← Footer (60pt)
└─────────────────────────────────────────────────────────────┘
```

#### Component Specifications

**Status Cards** (3-column grid):
- Size: 360pt × 180pt each
- Spacing: 20pt between cards
- Glass material: `.regular`
- Corner radius: 16pt
- Padding: 24pt

**Session List Items**:
- Height: 72pt each
- Spacing: 8pt between items
- Background: `.ultraThin` glass on hover
- Layout: Icon (40pt) | Title | Score | Status Badge | Timestamp

**Quick Action Buttons**:
- Height: 48pt
- Width: 100% of card
- Style: Prominent filled style
- Corner radius: 12pt

### 2. Analytics Dashboard Window

**Window ID**: `analytics-dashboard`
**Default Size**: 1400pt × 900pt
**Resizability**: Content-based

#### Layout Structure

```
┌─────────────────────────────────────────────────────────────────┐
│ Analytics Dashboard                         [Export] [⚙️] [✕]  │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│ [Last 7 Days ▼]  [Last 30 Days]  [Last 90 Days]  [Custom]       │
│                                                                   │
│ ┌─────────────────────────────────────────────────────────────┐ │
│ │ Performance Trend                                   📈      │ │
│ │                                                             │ │
│ │     100% ┼─────────────────────────────────────            │ │
│ │      80% ┼         ╱─╲     ╱──╲                            │ │
│ │      60% ┼      ╱─╱   ╲───╱    ╲──╮                        │ │
│ │      40% ┼   ╱─╱                  ╲                        │ │
│ │      20% ┼──╱                                              │ │
│ │       0% ┼────────────────────────────────────            │ │
│ │          Mon  Tue  Wed  Thu  Fri  Sat  Sun                │ │
│ └─────────────────────────────────────────────────────────────┘ │
│                                                                   │
│ ┌──────────────────────┐  ┌──────────────────────────────────┐ │
│ │ Hazard Recognition   │  │ Incident Risk Heatmap            │ │
│ │                      │  │                                  │ │
│ │ ● Fire:         92%  │  │  [3D factory floor visualization]│ │
│ │ ● Chemical:     88%  │  │  Red zones: High risk            │ │
│ │ ● Electrical:   95%  │  │  Green zones: Low risk           │ │
│ │ ● Fall:         85%  │  │                                  │ │
│ └──────────────────────┘  └──────────────────────────────────┘ │
│                                                                   │
│ ┌─────────────────────────────────────────────────────────────┐ │
│ │ Team Performance Comparison                                 │ │
│ │ [Bar chart comparing team members]                          │ │
│ └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

#### Chart Specifications

**Line Charts** (Performance Trend):
- Height: 280pt
- Line width: 3pt
- Point markers: 8pt diameter
- Grid lines: 1pt, 20% opacity
- Colors: Success green for improvement, warning orange for decline

**Bar Charts** (Team Comparison):
- Bar height: 32pt
- Spacing: 12pt
- Corner radius: 6pt
- Animation: Grow from left, 0.6s ease-out

**Heatmaps** (Risk Visualization):
- Interactive 3D factory floor
- Color gradient: Green → Yellow → Orange → Red
- Opacity: 60% to allow seeing through
- Interaction: Tap zone for details

### 3. Scenario Library Window

**Window ID**: `scenario-library`
**Default Size**: 1200pt × 900pt

#### Layout Structure

```
┌─────────────────────────────────────────────────────────────┐
│ Scenario Library                       [🔍 Search] [✕]      │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│ ┌─────────┬─────────┬─────────┬─────────┬─────────┐        │
│ │   All   │  Fire   │Chemical │Electrical│  LOTO  │  ...   │
│ └─────────┴─────────┴─────────┴─────────┴─────────┘        │ ← Filter Tabs
│                                                               │
│ ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│ │  [3D Preview]│  │  [3D Preview]│  │  [3D Preview]│       │
│ │              │  │              │  │              │       │
│ │ Fire         │  │ Chemical     │  │ Electrical   │       │
│ │ Evacuation   │  │ Spill        │  │ Safety       │       │
│ │              │  │ Response     │  │              │       │
│ │ ⭐⭐⭐⭐⭐      │  │ ⭐⭐⭐⭐       │  │ ⭐⭐⭐         │       │
│ │ 15 min       │  │ 20 min       │  │ 25 min       │       │
│ │ Intermediate │  │ Advanced     │  │ Basic        │       │
│ │              │  │              │  │              │       │
│ │ [Start]      │  │ [Start]      │  │ [Start]      │       │
│ └──────────────┘  └──────────────┘  └──────────────┘       │ ← Scenario Cards
│                                                               │
│ ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│ │ [More scenarios in grid layout...]                        │
│ └──────────────┘  └──────────────┘  └──────────────┘       │
└─────────────────────────────────────────────────────────────┘
```

#### Scenario Card Specifications

- **Card Size**: 360pt × 480pt
- **3D Preview**: 360pt × 240pt (1.5:1 aspect ratio)
- **Preview Type**: Real-time RealityKit scene preview or static render
- **Hover State**: Slight scale (1.02x) + glow effect
- **Metadata Layout**:
  - Title: 24pt semibold
  - Difficulty: Pill badge with color coding
  - Duration: Icon + text
  - Rating: Star visualization

---

## Volume Designs (3D Bounded Spaces)

### 1. Equipment Training Volume

**Volume ID**: `equipment-training`
**Default Size**: 2m × 2m × 2m
**Content Scale**: 1:1 (real-world scale)

#### Visual Structure

```
        ← 2 meters →
    ┌────────────────┐  ↑
   ╱                ╱│  │
  ╱   [Equipment]  ╱ │  2m
 ╱    3D Model    ╱  │  │
┌────────────────┐   │  ↓
│                │   │
│   Interactive  │   ╱
│   Volume       │  ╱  2m depth
│   Space        │ ╱
└────────────────┘
```

#### Content Organization

**Central Equipment Model**:
- Position: Center of volume (0, 0, 0)
- Scale: 1:1 real-world scale
- Rotation: User can rotate 360° by walking around
- Materials: Physically accurate (metal, plastic, rubber)

**Floating UI Elements**:
- **Component Labels**: Float near relevant parts (0.1m offset)
- **Instruction Panels**: Positioned at user's reading height (-0.3m from eye level)
- **Safety Warnings**: Red badges near hazard points
- **Interaction Hints**: Appear on hover, fade after 3 seconds

**Interaction Zones**:
```swift
// Example: Machinery inspection volume
VolumeView {
    RealityView { content in
        // Main equipment
        let machine = loadMachineModel()
        machine.position = [0, 0, 0]
        content.add(machine)

        // Hazard indicators
        let pinchPoint = createHazardIndicator(.pinchPoint)
        pinchPoint.position = [0.2, 0.5, 0.1]  // On machine
        content.add(pinchPoint)

        // Instructional UI
        let instructionPanel = createInstructionPanel(
            text: "Inspect guard before operation",
            position: [-0.8, 0.3, 0]  // Left side, readable height
        )
        content.add(instructionPanel)
    }
}
.frame(width: 2, height: 2, depth: 2, in: .meters)
```

#### Lighting

- **Primary Light**: Directional from above-front (simulating workshop lighting)
- **Fill Light**: Soft ambient to reduce harsh shadows
- **Rim Light**: Subtle edge lighting to define equipment silhouette
- **Indicator Lights**: Hazard markers self-illuminate (emissive materials)

### 2. Hazard Identification Volume

**Volume ID**: `hazard-identification`
**Default Size**: 3m × 2.5m × 3m
**Content**: Partial industrial environment with hidden hazards

#### Design Pattern

**Environment Section**:
- Small factory corner or work station
- Multiple equipment pieces
- 5-10 hazards at varying difficulty levels
- Realistic clutter and detail

**Hazard Visualization**:
- **Before Identification**: Subtle visual cues only
  - Frayed wire (electrical hazard)
  - Liquid puddle with shimmer (slip hazard)
  - Unsecured equipment (struck-by hazard)

- **After Identification**: Clear indicators
  - Highlight glow around hazard
  - Floating label with hazard type
  - Severity color coding

**User Interaction Flow**:
1. User enters volume
2. Timer starts
3. User looks around to find hazards
4. Tap/pinch to identify hazard
5. Immediate feedback (correct/incorrect)
6. Continue until all found or time expires

---

## Full Space/Immersive Experiences

### 1. Factory Floor Simulation

**Space ID**: `factory-simulation`
**Immersion**: Progressive (50% default)
**Environment Size**: 20m × 8m × 15m

#### Environmental Design

**Layout**:
```
                    ← 20 meters →
    ┌──────────────────────────────────────┐
    │ [Loading    │  [Work     │  [Storage │  ↑
    │  Dock]      │   Floor]   │   Area]   │  │
    │             │            │           │  │
    │ [Machine 1] │ [Conveyor] │ [Machine2]│  15m
    │             │            │           │  │
    │ [Office]    │  [Assembly │  [Ship.   │  │
    │  Area       │   Line]    │   Area]   │  ↓
    └──────────────────────────────────────┘
```

**Zones**:

1. **Safe Walkways** (Green floor markings)
   - 1.5m wide corridors
   - Clear path markings
   - Emergency exit signs

2. **Caution Zones** (Yellow stripes)
   - Equipment operation areas
   - Loading/unloading zones
   - Elevated work areas

3. **Danger Zones** (Red boundaries)
   - Active machinery
   - High-voltage areas
   - Chemical storage

**Visual Elements**:

- **Floor**: Industrial concrete texture with painted lines
- **Walls**: Corrugated metal panels, ventilation ducts, safety posters
- **Ceiling**: Exposed rafters, overhead cranes, fluorescent lights
- **Equipment**: Realistic machinery models with moving parts
- **Details**: Tool carts, pallets, safety equipment stations, fire extinguishers

**Dynamic Elements**:

```swift
// Animated machinery
let conveyor = ConveyorBelt()
conveyor.speed = 0.3  // m/s
conveyor.animate(continuously: true)

// Moving hazards
let forklift = ForkliftEntity()
forklift.followPath(waypointPath, speed: 1.5)  // Periodic crossing

// Environmental hazards
let steamLeak = ParticleEmitter(type: .steam)
steamLeak.position = [5, 2, 3]
steamLeak.emissionRate = 100
steamLeak.lifetime = 3.0
```

**Safety Signage**:
- Emergency exits (green, illuminated)
- Fire extinguisher locations (red signs)
- PPE requirement signs (blue)
- Hazard warnings (yellow/orange triangles)
- First aid stations (green cross)

#### Ambient Elements

**Audio Layers**:
1. **Machinery hum**: 40-50 dB, continuous
2. **Conveyor movement**: Directional, positional
3. **Ventilation**: Background white noise
4. **Occasional sounds**: Tool drops, alerts, distant voices

**Lighting**:
- **Overhead fluorescents**: Bright (800 lux), slightly cool
- **Task lighting**: Focused on work areas
- **Emergency lighting**: Dim green along exit paths
- **Warning lights**: Rotating amber lights on machinery

### 2. Fire Evacuation Simulation

**Space ID**: `fire-evacuation`
**Immersion**: Full
**Environment**: Multi-floor building interior

#### Scenario Progression

**Phase 1: Normal Conditions** (0-30 seconds)
- Well-lit office/factory environment
- Normal audio ambience
- User oriented to space and exit locations

**Phase 2: Fire Alarm** (30s-60s)
- Alarm sounds (penetrating, urgent tone)
- Emergency lighting activates
- Strobes flash
- Instruction: "Evacuate immediately"

**Phase 3: Smoke Development** (60s-120s)
- Volumetric smoke begins to fill space
- Visibility gradually reduces
- Temperature indicator shows rising heat
- Breathing becomes labored (audio cue)

**Phase 4: Emergency Evacuation** (120s-240s)
- Heavy smoke (1-2m visibility)
- Exit signs illuminated (green, glowing)
- Audio: Fire crackling, alarms, distant shouts
- User must find exit route while avoiding hazards

#### Visual Effects

**Smoke Simulation**:
```swift
let smokeEmitter = ParticleEmitter()
smokeEmitter.particleImage = "smoke_particle"
smokeEmitter.birthRate = 200
smokeEmitter.lifetime = 8.0
smokeEmitter.velocity = 0.3  // Upward drift
smokeEmitter.emissionShape = .sphere(radius: 2.0)
smokeEmitter.color = .gray.withAlphaComponent(0.8)
smokeEmitter.blendMode = .alpha

// Smoke density increases over time
smokeEmitter.birthRate += 50 * deltaTime  // More dense
```

**Fire Glow**:
- Orange volumetric glow from fire source
- Flickering intensity (randomized)
- Heat distortion effect (subtle screen-space distortion)
- Emissive materials on fire-affected surfaces

**Visibility System**:
- Dynamic fog density based on smoke level
- Exponential visibility reduction
- Exit signs always visible (emissive, no fog occlusion)

### 3. Chemical Plant Simulation

**Space ID**: `chemical-plant`
**Immersion**: Progressive
**Environment**: Process area with tanks, pipes, and control stations

#### Industrial Equipment

**Major Elements**:
- **Storage Tanks**: 4m height, labeled with chemical names and hazard symbols
- **Pipe Network**: Color-coded (red=fire suppression, blue=water, yellow=chemicals)
- **Valves and Controls**: Interactive, labeled with function
- **Control Panel**: Display screens, switches, emergency shutoff
- **Containment Areas**: Berms and drainage systems

**Hazard Scenarios**:

1. **Pipe Leak Detection**:
   - Small liquid stream from pipe joint
   - Hissing audio cue
   - Growing puddle formation
   - User must identify leak source and shut valve

2. **Gas Release**:
   - Invisible gas (represented by distortion effect)
   - Gas detector alarm
   - Visual cue: Particle effect for visibility
   - User must don respirator and evacuate/contain

3. **Pressure Alert**:
   - Pressure gauge enters red zone
   - Warning alarm
   - Vibration effect on pipes
   - User must follow emergency shutdown procedure

---

## 3D Visualization Specifications

### Performance Metrics Dashboard (3D)

**Floating Data Visualization** in immersive space:

```
         Performance Rings
              ___
            /     \         ← Overall Score (outermost)
           /  ___  \
          /  /   \  \       ← Category Scores (middle)
         |  |  ⭐ |  |
          \  \___/  /       ← Current Session (innermost)
           \       /
            \_____/

  Hazard Recognition: 92%  [────────▓▓] ← Stat bars float around
  Response Time: 2.3s      [────▓▓────]
  Compliance: 88%          [───────▓──]
```

**Implementation**:
```swift
// 3D progress ring entity
let progressRing = createProgressRing(
    radius: 0.3,
    thickness: 0.05,
    progress: 0.85,
    color: .green
)
progressRing.position = [0, 1.5, -1.0]  // Eye level, 1m away

// Animated progress bars in 3D space
let statBars = createStatBarsArray([
    ("Hazard Recognition", 0.92),
    ("Response Time", 0.65),
    ("Compliance", 0.88)
])
positionRadially(statBars, around: progressRing, radius: 0.5)
```

### Hazard Heatmap (3D Spatial)

**3D Factory Floor with Risk Overlay**:
- Base: Miniature 3D model of factory (1:20 scale)
- Overlay: Volumetric heat zones
- Colors: Green (safe) → Yellow (caution) → Orange (warning) → Red (danger)
- Interaction: Pinch and rotate to view from any angle
- Detail: Tap zone to see incident history and recommendations

### Training Progress Visualization

**Skill Tree in 3D Space**:
```
                     [Master]
                        │
           ┌────────────┼────────────┐
           │            │            │
       [Advanced]   [Advanced]   [Advanced]
       Fire Safety  Chemical    Electrical
           │            │            │
     ┌─────┼─────┐     │       ┌────┼────┐
  [Basic] [Basic] [Basic] [Basic] [Basic] [Basic]
    ✓       ✓       →       ✓       ✓      ○

Legend:
✓ Completed (green, glowing)
→ In Progress (blue, pulsing)
○ Locked (gray, faded)
```

**Spatial Arrangement**:
- Tree grows vertically in front of user
- Completed nodes closer, locked nodes farther
- Connecting paths light up as skills unlock
- Interactive: Tap node to see details and start training

---

## Interaction Patterns

### Primary Interactions

#### 1. Hazard Identification

**Gaze + Tap Pattern**:
```
User Flow:
1. Look at suspected hazard
2. Gaze cursor appears on object
3. Hold gaze for 0.5s → object highlights
4. Tap (pinch) to identify
5. Immediate feedback:
   ✓ Correct: Green glow + sound + points
   ✗ Incorrect: Red flash + explanation
```

**Visual Feedback**:
```swift
// Gaze highlight
.onHover { isHovered in
    withAnimation(.easeIn(duration: 0.3)) {
        opacity = isHovered ? 1.0 : 0.6
        scale = isHovered ? 1.05 : 1.0
    }
}

// Tap confirmation
.onTapGesture {
    // Correct identification
    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
        entity.addComponent(GlowComponent(color: .green))
        entity.scale *= 1.1
    }

    playSound("success_chime")
    showFloatingText("+10 points", above: entity)
}
```

#### 2. Equipment Operation

**Direct Manipulation**:
```
Valve Turning:
1. Pinch near valve handle
2. Rotate hand while pinching
3. Valve rotates to match hand rotation
4. Visual feedback: Valve position, flow indicators
5. Audio feedback: Creaking, flowing water/gas
6. Haptic feedback (if available): Resistance feel
```

**Proximity-Based Interaction**:
```swift
// Hand approaches control
func onHandNear(control: Entity, handAnchor: HandAnchor) {
    // Show instruction overlay
    let instruction = "Pinch to grasp, rotate to turn valve"
    showInstructionNear(control, text: instruction)

    // Highlight interactive parts
    control.highlightGrabbableParts()
}
```

#### 3. PPE Donning Verification

**Hand Tracking Validation**:
```
Helmet Check:
1. User reaches up to "put on" helmet
2. Hand tracking detects both hands near head
3. Upward motion detected
4. Virtual helmet appears on user avatar
5. Checklist item marked: ✓ Hard hat donned
6. Visual confirmation: Green checkmark overlay
```

**Safety Procedure Sequencing**:
```swift
let ppeSequence: [PPEItem] = [
    .hardHat,
    .safetyGlasses,
    .gloves,
    .safetyVest
]

// User must complete in order
func verifyPPESequence() {
    for (index, item) in ppeSequence.enumerated() {
        if !isWorn(item) && index == currentStep {
            showInstruction("Put on \(item.name)")
            highlightPPE(item)
            return
        }
    }
    // All PPE donned correctly
    proceedToTraining()
}
```

#### 4. Emergency Stop

**Gesture Recognition**:
```
Emergency Stop Gesture:
Physical: Both hands raised, palms forward
Recognition: HandTracking detects pose
Response: IMMEDIATE
  - Freeze all simulation
  - Show "EMERGENCY STOP" overlay (large, red)
  - Play urgent tone
  - Display options: Resume | Exit | Help
```

**Button Interaction**:
```
Emergency Stop Button:
- Large red button entity (physical simulation)
- Position: Always accessible (follows user in periphery)
- Interaction: Hit/push button
- Animation: Button depresses, locks
- Effect: Same as gesture
```

### Secondary Interactions

#### Voice Commands

```swift
let voiceCommands: [String: Action] = [
    "emergency stop": { executeEmergencyStop() },
    "show help": { displayHelpOverlay() },
    "repeat instruction": { repeatLastInstruction() },
    "identify hazard": { enterIdentificationMode() },
    "next step": { advanceToNextStep() },
    "show exits": { highlightEmergencyExits() },
    "call supervisor": { initiateSuper visorAssistance() }
]
```

#### Toolbar Placement

**Persistent Toolbar** (visionOS ornament):
```
Position: Below main content window
Content: [Pause] [Help] [Settings] [Score: 85]
Style: Floating glass bar, 60pt height
Behavior: Always visible, follows window focus
```

#### Contextual Menus

**3D Context Menu** on objects:
```
Long-press on equipment entity:
┌─────────────────┐
│ 🔍 Inspect      │
│ 📋 Details      │
│ ⚠️ Hazards      │
│ 📖 Manual       │
└─────────────────┘
```

---

## User Flows and Navigation

### Onboarding Flow

```
1. Welcome Screen (Window)
   │
   ├─→ [Skip Tutorial] ────────────────┐
   │                                    │
   ├─→ [Start Tutorial]                │
   │                                    │
   ↓                                    │
2. Basic Controls Tutorial (Volume)    │
   - Gaze and tap                      │
   - Direct manipulation                │
   - Voice commands                     │
   │                                    │
   ↓                                    │
3. Safety Introduction (Immersive)     │
   - Hazard types overview             │
   - PPE identification                 │
   - Emergency procedures               │
   │                                    │
   ↓                                    │
4. First Scenario (Guided)             │
   - Simple hazard identification       │
   - Step-by-step guidance              │
   - Completion celebration             │
   │                                    │
   └────────────────────────────────────┘
   │
   ↓
5. Main Dashboard
```

### Training Session Flow

```
Dashboard
   │
   ├─→ Browse Scenarios
   │   │
   │   ├─→ Select Scenario
   │   │   │
   │   │   ├─→ View Details (Window)
   │   │   │   - Description
   │   │   │   - Objectives
   │   │   │   - Difficulty
   │   │   │   - Estimated time
   │   │   │   - Required PPE
   │   │   │   │
   │   │   │   ├─→ [Cancel] → Back to library
   │   │   │   │
   │   │   │   └─→ [Start Training]
   │   │   │       │
   │   │   │       ↓
   │   │   │   Preparation Screen
   │   │   │   - Review objectives
   │   │   │   - Confirm readiness
   │   │   │   - Equipment check
   │   │   │   │
   │   │   │   ├─→ [Not Ready] → Back to details
   │   │   │   │
   │   │   │   └─→ [I'm Ready]
   │   │   │       │
   │   │   │       ↓
   │   │   │   Loading Screen
   │   │   │   - Download assets (if needed)
   │   │   │   - Initialize environment
   │   │   │   - "Entering immersive space..."
   │   │   │   │
   │   │   │   ↓
   │   │   │   Immersive Training Session
   │   │   │   - Complete objectives
   │   │   │   - Receive real-time feedback
   │   │   │   - Can pause anytime
   │   │   │   │
   │   │   │   ├─→ [Emergency Stop] → Immediate pause
   │   │   │   ├─→ [Pause] → Pause menu
   │   │   │   │   ├─→ Resume
   │   │   │   │   ├─→ Settings
   │   │   │   │   └─→ Exit (save progress)
   │   │   │   │
   │   │   │   └─→ Complete Objectives
   │   │   │       │
   │   │   │       ↓
   │   │   │   Session Complete
   │   │   │   - Exit immersive space
   │   │   │   - Calculate score
   │   │   │   - Generate report
   │   │   │   │
   │   │   │   ↓
   │   │   │   Results Screen (Window)
   │   │   │   - Score breakdown
   │   │   │   - Performance metrics
   │   │   │   - Achievements unlocked
   │   │   │   - Areas for improvement
   │   │   │   - AI insights
   │   │   │   │
   │   │   │   ├─→ [Retry Scenario]
   │   │   │   ├─→ [View Detailed Analytics]
   │   │   │   ├─→ [Next Recommended Scenario]
   │   │   │   └─→ [Return to Dashboard]
```

### Navigation Hierarchy

```
App Structure:
│
├─ Dashboard (Window - Always accessible)
│  ├─ Quick Actions
│  ├─ Recent Sessions
│  ├─ Progress Overview
│  └─ Notifications
│
├─ Scenario Library (Window)
│  ├─ Filter by category
│  ├─ Search
│  ├─ Scenario cards
│  └─ Scenario details
│
├─ Training Session (Immersive Space)
│  ├─ Active scenario
│  ├─ Pause menu (accessible anytime)
│  └─ Emergency controls
│
├─ Analytics (Window)
│  ├─ Performance dashboard
│  ├─ Trend analysis
│  ├─ Comparison views
│  └─ Export options
│
├─ Profile & Settings (Window)
│  ├─ User information
│  ├─ Preferences
│  ├─ Certifications
│  ├─ Privacy controls
│  └─ Integration settings
│
└─ Help & Support (Window)
   ├─ Tutorial library
   ├─ Documentation
   ├─ FAQ
   └─ Contact support
```

---

## Accessibility Design

### VoiceOver Optimization

**Spatial Content Description Strategy**:

```swift
// 3D entity accessibility
hazardEntity.accessibilityLabel = "Fire hazard"
hazardEntity.accessibilityValue = "High severity, 3 meters ahead at 12 o'clock position"
hazardEntity.accessibilityHint = "Double tap to identify hazard and receive safety guidance"
hazardEntity.accessibilityTraits = [.button, .startsMediaSession]

// Spatial relationship descriptions
func describeEnvironment() -> String {
    var description = ""

    // Describe nearest important elements
    let nearbyElements = findNearbyElements(within: 5.0)  // 5 meters

    for element in nearbyElements.sorted(by: { $0.distance < $1.distance }) {
        let direction = clockDirection(to: element)
        let distance = Int(element.distance)

        description += "\(element.type) at \(direction) o'clock, \(distance) meters away. "
    }

    return description
}
```

**VoiceOver Navigation**:
- Logical focus order: Near to far, left to right, important to supplementary
- Focus indicator: Audible tone + verbal confirmation
- Quick nav: "Next hazard", "Next exit", "Next control"

### Reduce Motion Adaptations

```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

// Adapted animations
func animateHazardWarning() {
    if reduceMotion {
        // Static warning
        hazardEntity.components[GlowComponent.self]?.isConstant = true
    } else {
        // Pulsing animation
        hazardEntity.components[GlowComponent.self]?.pulse(duration: 1.0)
    }
}

// Simplified transitions
func transitionToImmersive() {
    if reduceMotion {
        // Instant transition
        openImmersiveSpace()
    } else {
        // Animated fade
        withAnimation(.easeInOut(duration: 1.0)) {
            openImmersiveSpace()
        }
    }
}
```

### Color Blindness Accommodation

**Pattern-Based Differentiation**:
```swift
struct HazardIndicator {
    let severity: HazardSeverity

    var visualRepresentation: some View {
        ZStack {
            // Color (for those who can see it)
            Circle()
                .fill(severity.color)

            // Pattern (for color-blind users)
            Image(systemName: severity.symbolPattern)
                .font(.title.bold())
                .foregroundStyle(.white)

            // Text label (always)
            Text(severity.rawValue)
                .font(.caption2.bold())
                .foregroundStyle(.white)
        }
    }
}

enum HazardSeverity {
    case low, medium, high, critical

    var color: Color {
        switch self {
        case .low: return .green
        case .medium: return .yellow
        case .high: return .orange
        case .critical: return .red
        }
    }

    var symbolPattern: String {
        switch self {
        case .low: return "circle"
        case .medium: return "triangle"
        case .high: return "diamond"
        case .critical: return "octagon"
        }
    }
}
```

**High Contrast Mode**:
```swift
@Environment(\.colorSchemeContrast) var contrast

var hazardColor: Color {
    if contrast == .increased {
        return .red  // Pure, maximum contrast red
    } else {
        return Color(red: 0.8, green: 0.2, blue: 0.2)  // Standard red
    }
}
```

### Alternative Input Methods

**Dwell Selection** (for users unable to pinch):
```swift
.onContinuousHover { phase in
    switch phase {
    case .active(let location):
        // Start dwell timer
        dwellTimer.start(duration: 1.5)
    case .ended:
        dwellTimer.cancel()
    }
}

// Visual dwell progress indicator
Circle()
    .trim(from: 0, to: dwellProgress)
    .stroke(Color.blue, lineWidth: 4)
    .frame(width: 60, height: 60)
```

**Voice-Only Operation**:
- Every action accessible via voice command
- Voice feedback confirms action
- "What can I say?" command lists available commands
- Context-aware commands (different in menus vs. training)

---

## Error States and Loading Indicators

### Loading States

#### Scenario Loading

**Window-based loading**:
```swift
struct ScenarioLoadingView: View {
    @State private var progress: Double = 0

    var body: some View {
        VStack(spacing: 24) {
            // Animated 3D preview
            RealityView { content in
                let loadingScene = LoadingAnimation()
                content.add(loadingScene)
            }
            .frame(width: 300, height: 300)

            Text("Preparing Safety Scenario")
                .font(.title2.bold())

            Text("Fire Evacuation Training")
                .font(.body)
                .foregroundStyle(.secondary)

            ProgressView(value: progress, total: 1.0)
                .progressViewStyle(.linear)
                .frame(width: 400)

            Text("Loading assets... \(Int(progress * 100))%")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(40)
        .background(.ultraThinMaterial)
        .cornerRadius(24)
    }
}
```

**Immersive space loading**:
```
[Full black space with centered content]

        ⟲  ← Rotating Safety Symbol

    Entering Training Environment

        ▓▓▓▓▓▓▓▓░░░░ 75%

    Tip: Look around to familiarize yourself
        with emergency exit locations
```

#### Asset Streaming

**Progressive loading indicator**:
```swift
struct AssetStreamingIndicator: View {
    let assetsLoaded: Int
    let totalAssets: Int

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "arrow.down.circle.fill")
                .symbolEffect(.pulse)

            VStack(alignment: .leading, spacing: 4) {
                Text("Loading scenario assets")
                    .font(.caption.bold())

                Text("\(assetsLoaded) of \(totalAssets) complete")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("\(Int(Double(assetsLoaded) / Double(totalAssets) * 100))%")
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}
```

### Error States

#### Network Error

```swift
struct NetworkErrorView: View {
    let error: NetworkError
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 60))
                .foregroundStyle(.red)

            VStack(spacing: 8) {
                Text("Connection Lost")
                    .font(.title2.bold())

                Text(error.localizedDescription)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 12) {
                Button(action: retryAction) {
                    Label("Retry Connection", systemImage: "arrow.clockwise")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button("Work Offline") {
                    enableOfflineMode()
                }
                .buttonStyle(.bordered)
            }
            .frame(width: 300)
        }
        .padding(40)
        .background(.ultraThinMaterial)
        .cornerRadius(24)
    }
}
```

#### Session Error

```swift
struct TrainingSessionErrorView: View {
    let error: TrainingError

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.orange)

            Text("Training Session Error")
                .font(.title2.bold())

            Text(error.userFriendlyMessage)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            if error.isRecoverable {
                Button("Resume Training") {
                    recoverSession()
                }
                .buttonStyle(.borderedProminent)
            } else {
                VStack(spacing: 12) {
                    Button("Save Progress & Exit") {
                        saveAndExit()
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Restart Scenario") {
                        restartScenario()
                    }
                    .buttonStyle(.bordered)
                }
            }

            Button("Contact Support") {
                openSupportWithError(error)
            }
            .buttonStyle(.borderless)
            .font(.caption)
        }
        .padding(40)
        .background(.ultraThinMaterial)
        .cornerRadius(24)
    }
}
```

#### Empty State

```swift
struct EmptyScenarioLibraryView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "cube.transparent")
                .font(.system(size: 80))
                .foregroundStyle(.quaternary)

            VStack(spacing: 8) {
                Text("No Scenarios Available")
                    .font(.title3.bold())

                Text("Scenarios are currently downloading or your subscription may need to be renewed.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 400)
            }

            HStack(spacing: 12) {
                Button("Check Downloads") {
                    openDownloadsPanel()
                }
                .buttonStyle(.bordered)

                Button("Browse Library") {
                    openOnlineLibrary()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(60)
    }
}
```

---

## Animation and Transition Specifications

### Window Transitions

**Window open**:
```swift
.transition(.asymmetric(
    insertion: .scale(scale: 0.9).combined(with: .opacity),
    removal: .scale(scale: 1.1).combined(with: .opacity)
))
.animation(.spring(response: 0.5, dampingFraction: 0.8), value: isShowing)
```

**Window resize**:
```swift
.animation(.spring(response: 0.4, dampingFraction: 0.85), value: windowSize)
```

### Immersive Space Transitions

**Enter immersive space**:
```
Duration: 1.5 seconds

0.0s - 0.3s:  Dim windows (fade to 50% opacity)
0.3s - 0.6s:  Scale windows down (to 70%)
0.6s - 0.9s:  Fade out windows completely
0.9s - 1.2s:  Fade in immersive environment (from black)
1.2s - 1.5s:  Brighten environment to full visibility
```

**Exit immersive space**:
```
Duration: 1.0 seconds

0.0s - 0.3s:  Fade environment to black
0.3s - 0.5s:  Remove environment
0.5s - 0.7s:  Fade in windows (at 70% scale)
0.7s - 1.0s:  Scale windows to 100%, full opacity
```

### UI Element Animations

**Button press**:
```swift
.buttonStyle(SafetyButtonStyle())

struct SafetyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
```

**Card hover**:
```swift
.hoverEffect { effect, isActive, _ in
    effect
        .scaleEffect(isActive ? 1.05 : 1.0)
        .shadow(color: .black.opacity(isActive ? 0.2 : 0.1), radius: isActive ? 20 : 10)
}
```

**Notification slide-in**:
```swift
.transition(.asymmetric(
    insertion: .move(edge: .top).combined(with: .opacity),
    removal: .move(edge: .top).combined(with: .opacity)
))
.animation(.spring(response: 0.6, dampingFraction: 0.8), value: showNotification)
```

### 3D Entity Animations

**Hazard pulse**:
```swift
// Pulsing glow for hazards
let pulseAnimation = FromToByAnimation(
    from: 1.0,
    to: 1.3,
    duration: 1.0,
    timing: .easeInOut,
    isAdditive: false,
    repeatMode: .repeat(count: .max, autoreverses: true)
)

hazardEntity.scale.runAnimation(pulseAnimation)
```

**Equipment operation**:
```swift
// Valve rotation animation
let rotationAnimation = FromToByAnimation(
    from: Transform(rotation: simd_quatf(angle: 0, axis: [0, 1, 0])),
    to: Transform(rotation: simd_quatf(angle: .pi / 2, axis: [0, 1, 0])),
    duration: 0.8,
    timing: .easeInOut
)

valveEntity.transform.runAnimation(rotationAnimation)
```

**Particle effects**:
```swift
// Fire particle system
let fireEmitter = ParticleEmitterComponent(
    particles: [
        ParticleEmitterComponent.Particle(
            texture: .init(named: "fire_particle"),
            birthRate: 100,
            lifetime: 2.0,
            velocity: SIMD3<Float>(0, 0.5, 0),
            acceleration: SIMD3<Float>(0, -0.1, 0),
            scale: .random(in: 0.1...0.3),
            color: .orange.withAlpha(0.8)
        )
    ]
)

fireEntity.components.set(fireEmitter)
```

### Feedback Animations

**Success confirmation**:
```swift
// Green checkmark animation
withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
    checkmark.opacity = 1.0
    checkmark.scale = 1.0
}

// Followed by scale-down
withAnimation(.easeOut(duration: 0.3).delay(0.8)) {
    checkmark.scale = 0.0
}
```

**Error shake**:
```swift
// Shake animation for errors
let shakeAnimation = Animation
    .easeInOut(duration: 0.1)
    .repeatCount(3, autoreverses: true)

withAnimation(shakeAnimation) {
    offset.x = 10  // Shake left-right
}
```

**Score increment**:
```swift
// Animated number count-up
@State private var displayedScore: Int = 0
let finalScore: Int = 850

// Animate score counting
withAnimation(.easeOut(duration: 1.5)) {
    displayedScore = finalScore
}

Text("\(displayedScore)")
    .font(.system(size: 60, weight: .bold, design: .rounded))
    .monospacedDigit()  // Prevent layout shift
    .contentTransition(.numericText())
```

---

## Design Token System

```swift
enum DesignTokens {
    // Spacing
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }

    // Corner Radius
    enum CornerRadius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let full: CGFloat = 9999
    }

    // Shadows
    enum Shadow {
        static let sm = Color.black.opacity(0.1)
        static let md = Color.black.opacity(0.15)
        static let lg = Color.black.opacity(0.2)
    }

    // Animation Durations
    enum Duration {
        static let instant: Double = 0.15
        static let fast: Double = 0.3
        static let normal: Double = 0.5
        static let slow: Double = 0.8
        static let slower: Double = 1.2
    }

    // Z-Index (depth in spatial)
    enum Depth {
        static let critical: Float = 0.3
        static let important: Float = 0.6
        static let normal: Float = 1.0
        static let background: Float = 2.0
        static let far: Float = 5.0
    }
}
```

---

This design specification provides comprehensive guidance for creating a cohesive, accessible, and immersive Industrial Safety Simulator experience on visionOS, balancing safety training effectiveness with spatial computing capabilities and user comfort.
