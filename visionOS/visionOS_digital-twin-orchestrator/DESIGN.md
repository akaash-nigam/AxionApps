# Digital Twin Orchestrator - Design Specifications

## Table of Contents
1. [Spatial Design Principles](#spatial-design-principles)
2. [Window Layouts and Configurations](#window-layouts-and-configurations)
3. [Volume Designs](#volume-designs)
4. [Full Space / Immersive Experiences](#full-space--immersive-experiences)
5. [3D Visualization Specifications](#3d-visualization-specifications)
6. [Interaction Patterns](#interaction-patterns)
7. [Visual Design System](#visual-design-system)
8. [User Flows and Navigation](#user-flows-and-navigation)
9. [Accessibility Design](#accessibility-design)
10. [Error States and Loading Indicators](#error-states-and-loading-indicators)
11. [Animation and Transition Specifications](#animation-and-transition-specifications)

---

## 1. Spatial Design Principles

### Core Spatial Principles for Digital Twin Orchestrator

#### 1.1 Ergonomic Positioning
```
Optimal Viewing Zones:
┌────────────────────────────────────────┐
│  Dashboard Window: 10-15° below eye    │
│  Position: 1.5m from user              │
│  Size: 1.4m width at this distance     │
└────────────────────────────────────────┘

┌────────────────────────────────────────┐
│  Digital Twin Volume: Eye level        │
│  Position: 1-2m from user              │
│  Size: 1.5m³ bounded volume            │
└────────────────────────────────────────┘

┌────────────────────────────────────────┐
│  Detail Components: Slight below eye   │
│  Position: 0.5-1m (examination range)  │
│  Size: 0.3-0.8m depending on detail    │
└────────────────────────────────────────┘
```

**Ergonomic Guidelines:**
- Primary content positioned 10-15° below eye level (reduces neck strain)
- Interactive elements at arm's reach (0.5-1.5m)
- Seated workstation optimized for 8+ hour use
- Critical alerts at eye level (immediate attention)
- Peripheral information at edges of field of view

#### 1.2 Depth Hierarchy

```
Z-Axis Information Architecture:
                User
                 ◉
                 │
        ┌────────┼────────┐
        │        │        │
    Critical   Primary  Context
    Alerts     Data     Info
    (-0.5m)    (1.5m)   (3m)

Near (-0.5 to 0m):
  • Critical alerts
  • Emergency notifications
  • Confirmation dialogs

Middle (1-2m):
  • Main digital twin
  • Primary controls
  • Active dashboards

Far (2-5m):
  • Contextual information
  • Secondary metrics
  • Background data
```

**Depth Design Rules:**
- Use Z-depth meaningfully for information hierarchy
- Closer = more urgent/important
- Further = contextual/supporting
- Avoid cluttering middle depth range
- Use depth as a filtering mechanism

#### 1.3 Progressive Disclosure

**Spatial Information Layers:**

```
Level 1: Overview (Dashboard Window)
└─ Facility health overview
└─ Active alerts count
└─ Key performance metrics
   │
   ├─ User Action: Select Asset
   │
   ├─> Level 2: Asset View (Volume)
       └─ 3D digital twin
       └─ Sensor overlay
       └─ Real-time status
          │
          ├─ User Action: Select Component
          │
          ├─> Level 3: Component Detail (Volume)
              └─ Exploded view
              └─ Part-level sensors
              └─ Maintenance history
                 │
                 ├─ User Action: Enter Immersive Mode
                 │
                 ├─> Level 4: Full Facility (Immersive Space)
                     └─ Walk through entire facility
                     └─ See all systems in context
                     └─ Real-world scale visualization
```

**Progressive Disclosure Principles:**
- Start simple, reveal complexity on demand
- Each level adds detail and context
- Easy navigation between levels
- Preserve context when diving deeper

#### 1.4 Spatial Context Preservation

**Persistent Spatial Anchors:**
- Dashboard always returns to same location
- Digital twins anchored to physical space (when in AR mode)
- Controls remain in consistent positions
- Muscle memory for frequent actions

**Context Switching:**
```swift
// When switching between twins, animate transition
func switchTwin(from: DigitalTwin, to: DigitalTwin) {
    // Fade out current twin
    // Slide in new twin from same anchor point
    // Preserve viewing angle and zoom level
    // Maintain UI element positions
}
```

#### 1.5 Scale and Proportion

**Appropriate Sizing for Different Asset Types:**

| Asset Type | Real-World Size | Spatial Size | Rationale |
|------------|----------------|--------------|-----------|
| Small component (valve) | 0.3m | 0.3m (1:1) | Examine details at real scale |
| Medium equipment (pump) | 2m | 1.0m (1:2) | Full view within volume |
| Large machinery (turbine) | 10m | 1.5m (1:7) | Comprehensible in space |
| Entire facility | 200m | 5m (1:40) | Walk through at scaled size |

**Scaling Interactions:**
- Pinch to scale between ranges
- Snap to common scales (1:1, 1:10, 1:100)
- Display current scale prominently
- Context-appropriate default scale

---

## 2. Window Layouts and Configurations

### 2.1 Primary Dashboard Window

```
┌─────────────────────────────────────────────────────────────┐
│  ● ● ●                Digital Twin Orchestrator             │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Facility   │  │   Active     │  │   Critical   │      │
│  │   Overview   │  │   Twins      │  │   Alerts     │      │
│  │              │  │              │  │              │      │
│  │   ████ 95%   │  │   ▼ ▼ ▼     │  │   ⚠ 2       │      │
│  │   Health     │  │   12 Active  │  │   New        │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│                                                               │
│  ┌─────────────────────────────────────────────────────┐    │
│  │              Real-Time Metrics Timeline              │    │
│  │   ┌─────────────────────────────────────────────┐   │    │
│  │   │ Efficiency ────┬───────────┬──────────      │   │    │
│  │   │ Temperature ───┼─────────┬─┼──────────      │   │    │
│  │   │ Pressure ──────┴─────────┴─┴──────────      │   │    │
│  │   └─────────────────────────────────────────────┘   │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                               │
│  ┌─────────────────────────────────────────────────────┐    │
│  │              Active Predictions                      │    │
│  │  ⚡ Turbine A-3 - Bearing failure predicted         │    │
│  │     72 hours ahead • 92% confidence                  │    │
│  │     [Schedule Maintenance]                           │    │
│  │                                                       │    │
│  │  ⚡ Heat Exchanger B-1 - Efficiency degradation     │    │
│  │     14 days ahead • 85% confidence                   │    │
│  │     [View Details]                                   │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

**Layout Specifications:**
- **Header**: 60pt height, glass material background
- **Metric Cards**: 200x200pt, 20pt corner radius, subtle shadows
- **Timeline Chart**: Full width, 300pt height, interactive scrubbing
- **Predictions List**: Card-based, priority sorted, expandable
- **Spacing**: 20pt between elements, 40pt margins

**Materials:**
- Background: `.regularMaterial` with 0.8 opacity
- Cards: `.thinMaterial` with subtle border
- Text: `.primary` for headers, `.secondary` for metadata
- Charts: Custom gradient fills with glass overlay

**Interactive Elements:**
- Hover effects: Subtle scale (1.05x) and glow
- Tap targets: Minimum 60pt
- Cards expand on selection
- Real-time updates without jarring transitions

### 2.2 Asset Browser Window

```
┌──────────────────────────────────────────┐
│  ● ● ●         Asset Browser             │
├──────────────────────────────────────────┤
│  [Search assets...]           [Filter ▼] │
├──────────────────────────────────────────┤
│                                           │
│  📁 Facility Alpha                        │
│    ├─ 🏭 Production Line 1               │
│    │   ├─ ⚙️ Turbine A-1         [95%]  │
│    │   ├─ ⚙️ Turbine A-2         [89%]  │
│    │   └─ ⚙️ Turbine A-3  ⚠️     [72%]  │
│    ├─ 🏭 Production Line 2               │
│    │   └─ ...                            │
│    └─ 🔧 Support Systems                 │
│                                           │
│  📁 Facility Beta                         │
│    └─ ...                                 │
│                                           │
│  ┌────────────────────────────┐          │
│  │    Selected: Turbine A-3   │          │
│  │    Status: Warning          │          │
│  │    Health: 72%              │          │
│  │    Last Update: 2s ago      │          │
│  │                             │          │
│  │    [View in 3D]             │          │
│  └────────────────────────────┘          │
│                                           │
└──────────────────────────────────────────┘
```

**Features:**
- Hierarchical tree navigation
- Search with filtering
- Health indicators on every asset
- Quick preview on selection
- Contextual actions

### 2.3 Analytics Window

```
┌─────────────────────────────────────────────────────┐
│  ● ● ●              Analytics Dashboard             │
├─────────────────────────────────────────────────────┤
│  [Turbine A-3]         [Last 7 Days ▼]              │
├─────────────────────────────────────────────────────┤
│                                                       │
│  Performance Trend                                   │
│  ┌───────────────────────────────────────────────┐  │
│  │ 100% ┤                                         │  │
│  │  90% ┤     ╱‾‾╲                               │  │
│  │  80% ┤    ╱    ╲                              │  │
│  │  70% ┤   ╱      ╲___                          │  │
│  │  60% ┤                                         │  │
│  │      └────────────────────────────────────     │  │
│  │       Mon  Tue  Wed  Thu  Fri  Sat  Sun       │  │
│  └───────────────────────────────────────────────┘  │
│                                                       │
│  Sensor Correlations                                 │
│  ┌───────────────────────────────────────────────┐  │
│  │  Temperature ↑  →  Efficiency ↓                │  │
│  │  Correlation: 0.87                             │  │
│  │                                                 │  │
│  │  Vibration ↑    →  Bearing Wear ↑             │  │
│  │  Correlation: 0.94                             │  │
│  └───────────────────────────────────────────────┘  │
│                                                       │
│  Predictive Insights                                 │
│  ┌───────────────────────────────────────────────┐  │
│  │  Based on current trends:                      │  │
│  │  • Bearing failure likely in 72 hours          │  │
│  │  • Efficiency will drop below 65% threshold    │  │
│  │  • Recommended action: Schedule maintenance    │  │
│  │    during next planned downtime (Sat)          │  │
│  └───────────────────────────────────────────────┘  │
│                                                       │
└─────────────────────────────────────────────────────┘
```

---

## 3. Volume Designs

### 3.1 Digital Twin Volume - Standard View

```
                    Top View
        ╔═══════════════════════════╗
        ║                           ║
        ║         ⚙️                ║
        ║      TURBINE              ║
        ║                           ║
        ║  [Sensor Overlay ☐]      ║
        ║  [Health View    ☑]      ║
        ║  [Exploded View  ☐]      ║
        ║                           ║
        ╚═══════════════════════════╝

                  Side View
        ╔═══════════════════════════╗
        ║         ┌─────┐           ║
        ║         │⚙️   │           ║
        ║         │     │           ║
        ║         └─────┘           ║
        ║    Health: 72% ⚠️        ║
        ╚═══════════════════════════╝
```

**Specifications:**
- **Bounding Volume**: 1.5m x 1.5m x 1.5m
- **3D Model**: High-poly PBR model with LOD
- **Lighting**: Three-point lighting (key, fill, rim)
- **Background**: Transparent with subtle grid
- **Controls**: Floating ornaments at bottom

**Visual Enhancements:**
- Health-based coloring (gradient from green to red)
- Pulsing glow on alerts
- Particle effects for active flows
- Real-time shader effects for temperature

### 3.2 Component Detail Volume - Exploded View

```
     Exploded View Animation:

     Assembly State (0%)
         ┌──┐
         │##│
         │##│     Complete component
         │##│
         └──┘

     Partial Explosion (50%)
         ┌─┐
         │▓│  ← Cover

         │▓│  ← Body

         └─┘  ← Base

     Full Explosion (100%)

         [▓]  ← Cover (labeled)


         [▓]  ← Inner mechanism


         [▓]  ← Base assembly
```

**Interaction:**
- Drag slider to control explosion amount
- Tap component to highlight and show info
- Part labels appear on hover
- X-ray mode shows internal structure

**Visual Style:**
- Transparent ghosting for removed parts
- Connector lines showing assembly relationships
- Color-coded by function or material
- Animated assembly/disassembly

### 3.3 Sensor Overlay Volume

```
     Digital Twin with Sensor Overlay:

                 🌡️ 85°C
                  │
         ┌────────┼────────┐
         │        │        │
     ⚡  │     ⚙️      │  📊
    2.3kW│               │  95%
         │               │
         └───────────────┘
              │
              ⚡ Vibration
              12 Hz
```

**Sensor Visualization Types:**

| Sensor Type | Visualization | Color Mapping |
|-------------|---------------|---------------|
| Temperature | Heat heatmap | Blue → Red |
| Pressure | Contour lines | Low → High |
| Vibration | Wave animation | Calm → Intense |
| Flow | Particle stream | Slow → Fast |
| Power | Electric arcs | Dim → Bright |

**Interactive Features:**
- Toggle sensor layers on/off
- Filter by sensor type
- Historical playback
- Threshold indicators

---

## 4. Full Space / Immersive Experiences

### 4.1 Facility Immersive Space

```
         Immersive Facility View (Top Down)

    ╔═══════════════════════════════════════════╗
    ║                                           ║
    ║     🏭          🏭           🏭          ║
    ║   Building A   Building B  Building C     ║
    ║      ⚙️          ⚙️           ⚙️         ║
    ║                                           ║
    ║   ══════════════════════════════          ║
    ║   Pipeline Network                        ║
    ║   ══════════════════════════════          ║
    ║                                           ║
    ║              You are here                 ║
    ║                   👤                      ║
    ║                                           ║
    ╚═══════════════════════════════════════════╝

    Navigation:
    • Walk/teleport through facility
    • Scale view (1:1 to 1:100)
    • Portal to specific areas
    • Follow flow pathways
```

**Immersion Levels:**

**Mixed Reality Mode:**
- Facility overlaid on actual control room
- See colleagues and physical controls
- Digital twins augment real space
- Safety features (see obstacles)

**Progressive Mode:**
- Blend between real and virtual
- Environment partially replaced
- Focus on specific production line
- Peripheral vision shows context

**Full Immersion Mode:**
- Complete virtual environment
- 360° facility representation
- Day/night lighting
- Weather effects (outdoor facilities)

### 4.2 Simulation Space

```
     Simulation Mode Interface:

     ┌────────────────────────────────────┐
     │  SIMULATION MODE                   │
     │  ⚠️ Changes not applied to real    │
     │     system until confirmed         │
     └────────────────────────────────────┘

     Time Controls:
     ◄◄  ◄  ▌▌  ►  ►►
     [Speed: 10x]

     Parameter Adjustments:
     Temperature: [████████░░] 85°C
     Pressure:    [██████░░░░] 2.5 bar
     Flow Rate:   [█████████░] 45 L/min

     [Run Simulation]
     [Compare with Current]
     [Apply Changes]
```

**Simulation Features:**
- Time manipulation (pause, slow-mo, speed up)
- Parameter adjustment sliders
- Before/after comparison
- Predicted outcomes visualization
- Risk assessment

**Visual Feedback:**
```
Current State     vs     Simulated State
     ⚙️                        ⚙️
   [75%]                     [92%]
   Yellow                    Green

Predicted Impact:
  Efficiency: +17%
  Energy Use: -12%
  Output: +8%
  Cost Savings: $2,500/day
```

---

## 5. 3D Visualization Specifications

### 5.1 Material and Lighting

**PBR Materials:**
```swift
// Metal surfaces
metalMaterial.roughness = 0.2
metalMaterial.metallic = 1.0
metalMaterial.baseColor = Color(red: 0.7, green: 0.7, blue: 0.75)

// Painted surfaces
paintedMaterial.roughness = 0.6
paintedMaterial.metallic = 0.0
paintedMaterial.baseColor = healthBasedColor

// Glass/transparent
glassMaterial.roughness = 0.1
glassMaterial.opacity = 0.3
glassMaterial.refractionIndex = 1.5
```

**Lighting Setup:**
```
Three-Point Lighting:

Key Light (Main):
  Position: 45° right, 30° above
  Intensity: 1000 lumens
  Color: Warm white

Fill Light:
  Position: 45° left, 15° above
  Intensity: 500 lumens
  Color: Cool white

Rim Light:
  Position: Behind, 45° above
  Intensity: 300 lumens
  Color: Subtle blue

Environment:
  IBL: Industrial HDR map
  Ambient: Low intensity
```

### 5.2 Health-Based Visual Coding

```swift
func visualStyle(for healthScore: Double) -> VisualStyle {
    switch healthScore {
    case 90...100:
        return VisualStyle(
            color: .green,
            emission: 0.2,
            pulse: false,
            particles: nil
        )

    case 70..<90:
        return VisualStyle(
            color: .yellow,
            emission: 0.3,
            pulse: false,
            particles: nil
        )

    case 50..<70:
        return VisualStyle(
            color: .orange,
            emission: 0.5,
            pulse: true,
            pulseRate: 1.0,
            particles: "warning_sparks"
        )

    case 0..<50:
        return VisualStyle(
            color: .red,
            emission: 0.8,
            pulse: true,
            pulseRate: 2.0,
            particles: "critical_smoke"
        )

    default:
        return VisualStyle(
            color: .gray,
            emission: 0.0,
            pulse: false,
            particles: nil
        )
    }
}
```

### 5.3 Flow Visualizations

**Energy Flow:**
```
Electrical Power:
  ⚡━━━━⚡━━━━⚡
  Animated lightning bolts
  Thickness = power level
  Speed = frequency

Steam Flow:
  ≋≋≋≋≋→≋≋≋≋≋→
  Particle system
  Density = pressure
  Speed = flow rate

Material Flow:
  ●●●●→●●●●→
  Sphere particles
  Count = throughput
  Color = material type
```

**Heat Visualization:**
```
Heat Map Gradient:
Blue → Cyan → Green → Yellow → Orange → Red

   🔵  🔷  🟢  🟡  🟠  🔴
  -10°  20°  50°  80°  110° 140°C

Applied as:
  - Surface shader
  - Emission intensity
  - Particle color
```

---

## 6. Interaction Patterns

### 6.1 Direct Manipulation

**Gaze + Pinch Pattern:**
```
1. User looks at component
   └─> Component highlights (subtle glow)

2. User pinches thumb+index
   └─> Component selected (bright highlight)

3. User moves hand while pinching
   └─> Component follows hand
   └─> Other parts fade (focus mode)

4. User releases pinch
   └─> Component snaps to position
   └─> Detail panel appears
```

**Grab and Rotate:**
```
1. User makes grab gesture (fist)
   └─> Entire twin becomes manipulatable

2. User rotates hand
   └─> Twin rotates with hand

3. User spreads fingers
   └─> Manipulation ends
   └─> Twin settles to position
```

### 6.2 Indirect Manipulation

**Voice Commands:**
```
User: "Show turbine A-3"
└─> Twin loads and centers

User: "What's the problem?"
└─> AI highlights failing component
└─> Explanation appears

User: "Show me last week"
└─> Timeline rewinds
└─> Historical data plays

User: "Compare with baseline"
└─> Side-by-side view
└─> Differences highlighted
```

**Control Ornaments:**
```
Floating Control Panel:
┌─────────────────────────┐
│  [🔍-]  [Rotate]  [🔍+] │
│  [⏮]   [⏯]      [⏭]   │
│  [📊]  [⚙️]     [🎯]   │
└─────────────────────────┘

Positioned:
  - Below twin (0.2m)
  - Always facing user
  - Follows twin on selection
```

### 6.3 Progressive Interaction

**Hover → Tap → Hold:**
```
Hover (gaze):
  └─> Show label
  └─> Subtle highlight

Tap (quick pinch):
  └─> Select component
  └─> Show quick info

Hold (pinch for 1s):
  └─> Enter manipulation mode
  └─> Show advanced controls
```

---

## 7. Visual Design System

### 7.1 Color Palette

**Primary Colors:**
```swift
struct DigitalTwinColors {
    // Operational Status
    static let optimal = Color(hex: "#00C853")      // Green
    static let normal = Color(hex: "#2196F3")       // Blue
    static let warning = Color(hex: "#FFC107")      // Amber
    static let critical = Color(hex: "#F44336")     // Red
    static let offline = Color(hex: "#9E9E9E")      // Gray

    // UI Elements
    static let primary = Color(hex: "#1976D2")      // Deep Blue
    static let accent = Color(hex: "#FF6F00")       // Orange
    static let background = Color(hex: "#121212").opacity(0.3)

    // Glass Materials
    static let glassTint = Color.white.opacity(0.1)
    static let glassStroke = Color.white.opacity(0.3)
}
```

**Semantic Colors:**
| Use Case | Color | Hex |
|----------|-------|-----|
| Success | Green | #4CAF50 |
| Info | Blue | #2196F3 |
| Warning | Amber | #FFC107 |
| Error | Red | #F44336 |
| Prediction | Purple | #9C27B0 |
| Historical | Gray | #757575 |

### 7.2 Typography

**Spatial Text Rendering:**
```swift
struct DigitalTwinTypography {
    // Spatial 3D Text
    static let twinLabel = Font.system(size: 48, weight: .bold)
    static let componentLabel = Font.system(size: 32, weight: .medium)
    static let sensorLabel = Font.system(size: 24, weight: .regular)

    // 2D Window Text
    static let windowTitle = Font.system(size: 28, weight: .bold)
    static let sectionHeader = Font.system(size: 22, weight: .semibold)
    static let body = Font.system(size: 17, weight: .regular)
    static let caption = Font.system(size: 14, weight: .regular)
    static let footnote = Font.system(size: 12, weight: .regular)

    // Monospace (for values)
    static let metricValue = Font.system(size: 24, weight: .medium).monospaced()
    static let timestamp = Font.system(size: 14, weight: .regular).monospaced()
}
```

**Text Hierarchy in 3D Space:**
```
Distance-based sizing:
  0.5m: 48pt (close examination)
  1.0m: 32pt (standard viewing)
  2.0m: 24pt (overview)
  3.0m: 18pt (context)
```

### 7.3 Iconography

**Icon Style:**
- Style: SF Symbols-based
- Weight: Medium to Semibold
- Size: 24pt (window), 48pt (spatial)
- Treatment: Filled for active states

**Icon Set:**
```
Status Icons:
  ✓ Optimal (checkmark.circle.fill)
  ⚠ Warning (exclamationmark.triangle.fill)
  ✗ Critical (xmark.octagon.fill)
  ○ Offline (circle.slash)

Action Icons:
  🔍 Zoom (magnifyingglass)
  🔄 Rotate (arrow.clockwise)
  ⏯ Play/Pause (playpause.fill)
  📊 Analytics (chart.bar.fill)
  ⚙️ Settings (gears.fill)

Asset Icons:
  🏭 Facility (building.2.fill)
  ⚙️ Equipment (gearshape.fill)
  🔧 Component (wrench.fill)
  📡 Sensor (antenna.radiowaves.left.and.right)
```

### 7.4 Glass Materials

**Material Specifications:**
```swift
extension Material {
    static var dashboardGlass: Material {
        var material = PhysicallyBasedMaterial()
        material.baseColor = .init(tint: .white.opacity(0.1))
        material.roughness = .init(floatLiteral: 0.2)
        material.opacity = .init(floatLiteral: 0.85)
        material.blending = .transparent(opacity: .init(floatLiteral: 0.85))
        return material
    }

    static var volumeGlass: Material {
        var material = PhysicallyBasedMaterial()
        material.baseColor = .init(tint: .white.opacity(0.05))
        material.roughness = .init(floatLiteral: 0.1)
        material.opacity = .init(floatLiteral: 0.3)
        return material
    }
}
```

---

## 8. User Flows and Navigation

### 8.1 Primary User Flow

```
App Launch
    │
    ├─> [First Time]
    │   ├─> Onboarding
    │   ├─> Permission requests
    │   └─> Tutorial
    │
    └─> [Returning User]
        │
        ├─> Dashboard appears
        │   └─> Shows facility overview
        │
        ├─> User selects asset from list
        │   └─> Volume window opens with 3D twin
        │       │
        │       ├─> User examines twin
        │       │   ├─> Rotate, zoom, inspect
        │       │   └─> View sensor overlays
        │       │
        │       ├─> User sees prediction
        │       │   ├─> Tap to view details
        │       │   └─> Schedule maintenance
        │       │
        │       └─> User enters immersive mode
        │           └─> Full facility walkthrough
        │
        └─> User receives alert
            └─> Navigate to critical asset
```

### 8.2 Navigation Patterns

**Window-to-Volume:**
```swift
Button("View in 3D") {
    openWindow(id: "twin-volume", value: selectedTwin.id)
}
.buttonStyle(.borderedProminent)
```

**Volume-to-Immersive:**
```swift
Button("Enter Facility") {
    openImmersiveSpace(id: "facility-space")
}
.onChange(of: immersiveSpaceState) { oldValue, newValue in
    if newValue == .open {
        // Hide windows
        dismissWindow(id: "twin-volume")
    }
}
```

**Back Navigation:**
```
Immersive Space → Volume → Window → Dashboard

Universal back gesture:
  • Hand swipe left
  • Or voice: "Go back"
  • Or UI button in top-left
```

### 8.3 Multi-Window Management

```
Typical Workspace Layout:

        [Dashboard]
            │
    ┌───────┼───────┐
    │               │
[Asset List]   [Analytics]
                    │
                    │
              [3D Twin Volume]
              (Floating nearby)
```

**Window Arrangement Rules:**
- Dashboard: Center, primary position
- Asset List: Left of dashboard
- Analytics: Right of dashboard
- 3D Volumes: Floating in comfortable view zone
- Max simultaneous windows: 4-5 (avoid clutter)

---

## 9. Accessibility Design

### 9.1 Visual Accessibility

**High Contrast Mode:**
```swift
@Environment(\.colorSchemeContrast) var contrast

var borderWidth: CGFloat {
    contrast == .increased ? 3 : 1
}

var statusColor: Color {
    switch (status, contrast) {
    case (.critical, .increased):
        return Color(red: 1.0, green: 0.0, blue: 0.0) // Pure red
    case (.critical, .standard):
        return Color(hex: "#F44336")
    // ... other cases
    }
}
```

**Color Blindness Support:**
```
Instead of relying solely on color:
  ✓ Use icons/symbols
  ✓ Use patterns/textures
  ✓ Use labels
  ✓ Use position/hierarchy

Example:
  Optimal:  ✓ Green + Checkmark
  Warning:  ⚠ Yellow + Triangle
  Critical: ✗ Red + X-mark
```

### 9.2 Motor Accessibility

**Alternative Inputs:**
- Voice control for all functions
- Keyboard shortcuts
- Switch control support
- Larger tap targets (60pt minimum)
- Dwell-based selection

**Reduced Motion:**
```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

func transition() -> AnyTransition {
    reduceMotion ? .opacity : .scale.combined(with: .opacity)
}
```

### 9.3 Cognitive Accessibility

**Simplified Mode:**
```
Standard View:
  • All sensors visible
  • Real-time updates
  • Complex visualizations

Simplified View:
  • Key metrics only
  • Slower update rate
  • Simple color coding
  • Clear labels
```

**Consistent Layouts:**
- Predictable element positions
- Consistent iconography
- Clear navigation paths
- Obvious back buttons

---

## 10. Error States and Loading Indicators

### 10.1 Loading States

**Initial Load:**
```
┌─────────────────────────┐
│                         │
│        ⏳               │
│   Loading Twin...       │
│   [████████░░] 80%      │
│                         │
└─────────────────────────┘
```

**3D Model Loading:**
```swift
struct LoadingTwin: View {
    @State private var rotation: Angle = .zero

    var body: some View {
        VStack {
            // Spinning wireframe outline
            Model3D(
                url: Bundle.main.url(forResource: "loading",
                                    withExtension: "usdz")!
            )
            .rotation3DEffect(rotation, axis: (0, 1, 0))
            .onAppear {
                withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                    rotation = .degrees(360)
                }
            }

            Text("Loading Digital Twin...")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
```

**Skeleton Screens:**
```
Dashboard Loading:
┌─────────────────────────┐
│  ░░░░ ░░░░░░░░░░░       │  ← Header
│                         │
│  ▓▓▓▓  ▓▓▓▓  ▓▓▓▓       │  ← Metric cards (pulsing)
│  ▓▓▓▓  ▓▓▓▓  ▓▓▓▓       │
│                         │
│  ░░░░░░░░░░░░░░░░░░     │  ← Chart area
│  ░░░░░░░░░░░░░░░░░░     │
│                         │
└─────────────────────────┘
```

### 10.2 Error States

**Network Error:**
```
┌─────────────────────────────┐
│     ⚠️                      │
│  Connection Lost            │
│                             │
│  Unable to reach backend    │
│  servers. Operating in      │
│  offline mode with cached   │
│  data.                      │
│                             │
│  Last sync: 2 minutes ago   │
│                             │
│  [Retry Connection]         │
│  [Continue Offline]         │
│                             │
└─────────────────────────────┘
```

**Data Error:**
```
┌─────────────────────────────┐
│     🔧                      │
│  Data Sync Issue            │
│                             │
│  Some sensors are not       │
│  reporting data:            │
│                             │
│  • Temperature Sensor 3     │
│  • Pressure Sensor 1        │
│                             │
│  Displaying last known      │
│  values (5 minutes old)     │
│                             │
│  [View Details]             │
│                             │
└─────────────────────────────┘
```

**Model Load Error:**
```
3D Model Failed to Load:

     [📦]
      ✗

  "turbine_a3.usdz"
  failed to load

  [Use Simplified Model]
  [Try Again]
  [Report Issue]
```

### 10.3 Empty States

**No Assets:**
```
┌─────────────────────────────┐
│                             │
│         🏭                  │
│                             │
│  No Digital Twins Yet       │
│                             │
│  Get started by connecting  │
│  your first asset.          │
│                             │
│  [+ Add Asset]              │
│  [Import from CAD]          │
│                             │
└─────────────────────────────┘
```

**No Alerts:**
```
┌─────────────────────────────┐
│         ✓                   │
│                             │
│  All Systems Optimal        │
│                             │
│  No active alerts or        │
│  predictions.               │
│                             │
│  Last check: Just now       │
│                             │
└─────────────────────────────┘
```

---

## 11. Animation and Transition Specifications

### 11.1 Micro-interactions

**Button Press:**
```swift
.onTapGesture {
    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
        // Scale down
        buttonScale = 0.95
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            // Scale back
            buttonScale = 1.0
        }
    }

    action()
}
```

**Hover Effect:**
```swift
.onContinuousHover { phase in
    switch phase {
    case .active:
        withAnimation(.easeOut(duration: 0.2)) {
            hovered = true
            scale = 1.05
            glowIntensity = 0.3
        }
    case .ended:
        withAnimation(.easeOut(duration: 0.2)) {
            hovered = false
            scale = 1.0
            glowIntensity = 0.0
        }
    }
}
```

### 11.2 Scene Transitions

**Window Appearance:**
```swift
.transition(.asymmetric(
    insertion: .scale(scale: 0.8).combined(with: .opacity),
    removal: .scale(scale: 1.1).combined(with: .opacity)
))
.animation(.spring(response: 0.6, dampingFraction: 0.8), value: isPresented)
```

**Twin Loading:**
```swift
// Fade in with scale
Model3D(url: twinURL)
    .opacity(modelLoaded ? 1.0 : 0.0)
    .scaleEffect(modelLoaded ? 1.0 : 0.8)
    .animation(.easeInOut(duration: 0.8), value: modelLoaded)
```

### 11.3 Data Update Animations

**Metric Value Change:**
```swift
Text(metricValue, format: .number)
    .contentTransition(.numericText())
    .animation(.smooth, value: metricValue)
```

**Chart Update:**
```swift
// Animated path drawing
.stroke(style: StrokeStyle(lineWidth: 2))
.trim(from: 0, to: animationProgress)
.animation(.easeInOut(duration: 1.0), value: animationProgress)
```

**Health Score Change:**
```swift
// Circular progress with spring
Circle()
    .trim(from: 0, to: healthScore / 100)
    .stroke(healthColor, lineWidth: 10)
    .animation(.spring(response: 1.0, dampingFraction: 0.7), value: healthScore)
```

### 11.4 Spatial Animations

**Twin Rotation:**
```swift
.rotation3DEffect(
    .degrees(rotationAngle),
    axis: (x: 0, y: 1, z: 0),
    anchor: .center,
    perspective: 1.0
)
.animation(.interactiveSpring, value: rotationAngle)
```

**Exploded View Animation:**
```swift
func explodeComponents(amount: Float) {
    for component in components {
        let direction = component.position - twinCenter
        let offset = direction * amount

        withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
            component.position = component.originalPosition + offset
        }
    }
}
```

**Particle Flow:**
```swift
// Continuous flow animation
ParticleEmitterComponent(
    birthRate: flowRate,
    lifespan: 2.0,
    speed: flowVelocity,
    acceleration: [0, -9.8, 0],  // Gravity
    color: .evolving(start: .blue, end: .cyan)
)
```

---

## Summary

This design specification provides:

1. **Spatial design principles** optimized for extended use
2. **Complete window layouts** for all interface types
3. **Volumetric 3D designs** with interaction specifications
4. **Immersive experiences** for full facility visualization
5. **Comprehensive visual language** (colors, typography, materials)
6. **Detailed interaction patterns** (direct, indirect, progressive)
7. **User flows** covering all major tasks
8. **Accessibility features** for inclusive design
9. **Error and loading states** for all scenarios
10. **Animation specifications** for polished experience

These designs ensure the Digital Twin Orchestrator provides an intuitive, efficient, and comfortable spatial computing experience for industrial operations teams.
