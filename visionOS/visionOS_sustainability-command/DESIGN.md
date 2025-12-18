# Sustainability Command Center - Design Specifications

## Document Information
- **Application**: Sustainability Impact Visualizer
- **Platform**: visionOS 2.0+ (Apple Vision Pro)
- **Version**: 1.0
- **Last Updated**: 2025-01-20

---

## 1. Spatial Design Principles

### 1.1 Core Design Philosophy

**"Feel the Impact, See the Solution, Create the Future"**

The Sustainability Command Center transforms abstract environmental data into visceral spatial experiences that inspire action. Our design principles:

1. **Emotional Connection**: Users should *feel* their environmental impact
2. **Clarity Through Depth**: Use 3D space to reveal complexity without overwhelming
3. **Hope Through Action**: Balance sobering data with empowering solutions
4. **Intuitive Navigation**: Natural gestures make sustainability data accessible
5. **Progressive Disclosure**: Start simple, reveal depth on demand

### 1.2 Spatial Design Guidelines

#### Spatial Ergonomics
```
User-Centered Spatial Layout
│
├─ Primary Content Zone (0.5m - 2m)
│  └─ Interactive dashboards and controls
│
├─ Extended Zone (2m - 5m)
│  └─ 3D visualizations and volumetric data
│
└─ Immersive Zone (5m+)
   └─ Earth visualization and scenario modeling
```

**Positioning Best Practices**:
- **Eye Level Reference**: 10-15° below eye level for comfort
- **Arm's Reach**: Primary controls within 0.5-1m
- **Gaze Angle**: Critical content within 30° horizontal cone
- **Depth Layering**: Use z-axis to show relationships, not just decoration

#### Comfort & Accessibility
- Maximum session length: 2-4 hours with break reminders
- Text size: Minimum 18pt for critical information
- Color contrast: WCAG AAA compliance
- Reduce motion options for all animations
- VoiceOver descriptions for all interactive elements

---

## 2. Window Layouts & Configurations

### 2.1 Dashboard Window (Primary Interface)

```
┌─────────────────────────────────────────────────────────────┐
│  Sustainability Command Center                    [○ □ ×]  │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐ │
│  │  Total Carbon   │  │   Reduction     │  │    Goals    │ │
│  │   Footprint     │  │   Progress      │  │   Status    │ │
│  │                 │  │                 │  │             │ │
│  │   45,234 tCO2   │  │      -12%       │  │   3 of 5    │ │
│  │   ↓ 5.2k        │  │   ━━━━━━━━━━    │  │  on track   │ │
│  └─────────────────┘  └─────────────────┘  └─────────────┘ │
│                                                               │
│  ┌───────────────────────────────────────────────────────┐  │
│  │        Emissions Breakdown (Interactive Chart)        │  │
│  │                                                         │  │
│  │  Manufacturing ████████████░░░░░ 45%                   │  │
│  │  Transportation ███████░░░░░░░░░ 28%                   │  │
│  │  Facilities     ████░░░░░░░░░░░░ 18%                   │  │
│  │  Other          ██░░░░░░░░░░░░░░  9%                   │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                               │
│  ┌──────────────────┐  ┌──────────────────┐                 │
│  │  Recent Alerts   │  │  Quick Actions   │                 │
│  │  • 2 facilities  │  │  [View Earth]    │                 │
│  │    over target   │  │  [Generate Rpt]  │                 │
│  │  • 1 new report  │  │  [Add Goal]      │                 │
│  └──────────────────┘  └──────────────────┘                 │
└─────────────────────────────────────────────────────────────┘
```

**Design Specifications**:
- **Size**: 1400×900 points (default), resizable
- **Background**: Glass material with 80% vibrancy
- **Typography**: SF Pro Display (headings), SF Pro Text (body)
- **Spacing**: 24pt padding, 16pt between cards
- **Corner Radius**: 20pt for cards, 16pt for buttons
- **Shadow**: Depth-based shadows for layering

**Color System**:
```swift
// Environmental Palette
let carbonRed = Color(red: 0.89, green: 0.24, blue: 0.21)      // High emissions
let transitionYellow = Color(red: 0.95, green: 0.77, blue: 0.06) // Warning
let sustainableGreen = Color(red: 0.20, green: 0.78, blue: 0.35) // On target
let oceanBlue = Color(red: 0.20, green: 0.60, blue: 0.86)      // Water
let renewableGold = Color(red: 1.00, green: 0.84, blue: 0.00)  // Energy

// System Colors (adapt to light/dark mode)
let primaryText = Color.primary
let secondaryText = Color.secondary
let tertiaryText = Color.tertiary
let surfaceBackground = Color(white: 0.95).opacity(0.8)
```

### 2.2 Goals Tracking Window (Vertical Side Panel)

```
┌──────────────────────┐
│   Goals & Targets    │
├──────────────────────┤
│                      │
│  ○ Net Zero by 2030  │
│    ━━━━━━━━━░ 75%    │
│    25% emissions ↓    │
│    [Details →]       │
│                      │
│  ○ Renewable Energy  │
│    ━━━━━░░░░░ 45%    │
│    45% of total      │
│    [Details →]       │
│                      │
│  ✓ Waste Reduction   │
│    ━━━━━━━━━━ 100%   │
│    Achieved 2024     │
│    [View →]          │
│                      │
│  ○ Water Efficiency  │
│    ━━━━░░░░░░ 38%    │
│    Behind schedule   │
│    [Action Required] │
│                      │
│  ○ Supply Chain      │
│    ━━░░░░░░░░ 22%    │
│    Early stage       │
│    [Details →]       │
│                      │
│  [+ Add New Goal]    │
│                      │
└──────────────────────┘
```

**Design Specifications**:
- **Size**: 600×800 points (fixed width, scrollable)
- **Position**: Left side of dashboard, 1m from user
- **Progress Indicators**: Circular radial progress + linear bar
- **Status Colors**:
  - On Track: Green
  - At Risk: Yellow
  - Behind: Red
  - Achieved: Blue checkmark

### 2.3 Analytics Detail Window

```
┌───────────────────────────────────────────────────┐
│  Analytics & Insights               [Time Range]  │
├───────────────────────────────────────────────────┤
│                                                    │
│  Emission Trends (Last 12 Months)                 │
│  ┌────────────────────────────────────────────┐   │
│  │    60k tCO2                                 │   │
│  │    ┊                                        │   │
│  │    50k  ╱╲    ╱╲                           │   │
│  │    ┊   ╱  ╲  ╱  ╲╱╲                        │   │
│  │    40k ╱    ╲╱      ╲    ╱╲                │   │
│  │    ┊                 ╲  ╱  ╲╱              │   │
│  │    30k                ╲╱                    │   │
│  │    └──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──    │   │
│  │     J  F  M  A  M  J  J  A  S  O  N  D     │   │
│  └────────────────────────────────────────────┘   │
│                                                    │
│  AI Insights                                       │
│  ┌────────────────────────────────────────────┐   │
│  │  💡 Opportunity: Switch to renewable energy │   │
│  │     at Shanghai facility could reduce       │   │
│  │     emissions by 18% (2,400 tCO2/year)      │   │
│  │     ROI: 14 months    [Explore →]           │   │
│  └────────────────────────────────────────────┘   │
│                                                    │
│  ┌────────────────────────────────────────────┐   │
│  │  ⚠️  Alert: Manufacturing emissions up 8%   │   │
│  │     vs. last quarter. Root cause analysis   │   │
│  │     suggests equipment inefficiency.        │   │
│  │     [Investigate →]                         │   │
│  └────────────────────────────────────────────┘   │
│                                                    │
└───────────────────────────────────────────────────┘
```

**Chart Specifications**:
- **Chart Library**: Swift Charts
- **Animations**: Smooth transitions (0.3s ease-in-out)
- **Interactions**: Tap data points for details, pinch to zoom
- **Tooltips**: Hover for exact values

---

## 3. Volume Designs (3D Bounded Spaces)

### 3.1 Carbon Flow Volume (Sankey Diagram)

**Physical Dimensions**: 1.5m × 1.2m × 1.0m

```
        Sources              Processes          Destinations
          │                     │                    │
     [Manufacturing]────────────┼──────────────>[Scope 1]
          │                     │                    │
     [Transportation]───────────┼──────────────>[Scope 2]
          │                     │                    │
     [Facilities]───────────────┼──────────────>[Scope 3]
          │                     │                    │
     [Supply Chain]─────────────┘                    │
                                                      │
                              Flows visualized as particles
                              Width = emission volume
                              Color = intensity
```

**Visual Design**:
- **Flow Particles**: Glowing orbs that travel along paths
  - High emissions: Dense red particles
  - Medium emissions: Orange particles
  - Low emissions: Green particles
- **Flow Width**: Proportional to emission volume
- **Animation**: Continuous flow at realistic speed (1 month = 5 seconds)
- **Materials**:
  - Paths: Translucent tubes with inner glow
  - Particles: Emissive spheres with bloom effect
  - Labels: Billboard text facing user

**Interaction**:
- **Tap Flow**: Highlight path, show exact tCO2 value
- **Pinch Node**: Drill down into subcategories
- **Rotate**: Two-finger rotation gesture
- **Scale**: Pinch to zoom 0.5x - 2.0x

### 3.2 Energy Consumption 3D Chart

**Physical Dimensions**: 1.0m × 1.0m × 1.0m (cube)

```
         Energy (kWh)
            ↑
      1000k │     ███
            │     ███
       800k │ ███ ███
            │ ███ ███ ███
       600k │ ███ ███ ███
            │ ███ ███ ███ ███
       400k │ ███ ███ ███ ███ ███
            │ ███ ███ ███ ███ ███
       200k │ ███ ███ ███ ███ ███ ███
            │ ███ ███ ███ ███ ███ ███
          0 └─────────────────────────→ Time
              Q1  Q2  Q3  Q4  Q1  Q2

     Color coding:
     ███ Renewable (green)
     ███ Fossil Fuels (red)
     ███ Grid (yellow)
```

**Visual Design**:
- **Bars**: Extruded 3D columns with metallic materials
- **Segmentation**: Stacked by energy source
- **Grid**: Subtle floor grid for scale reference
- **Annotations**: Floating labels with leader lines
- **Lighting**: Directional light to enhance depth

**Interaction**:
- **Tap Column**: Explode view showing energy source breakdown
- **Swipe Timeline**: Scrub through historical data
- **Height Reference**: Scale line appears when gazing at bars

### 3.3 Supply Chain Network Volume

**Physical Dimensions**: 2.0m × 1.5m × 1.5m

```
       Geographic Layout (3D Force-Directed Graph)
                        ┌──────┐
                        │ You  │
                        └───┬──┘
                            │
              ┌─────────────┼─────────────┐
              │             │             │
          ┌───┴───┐     ┌───┴───┐     ┌───┴───┐
          │ Tier 1│     │ Tier 1│     │ Tier 1│
          └───┬───┘     └───┬───┘     └───┬───┘
              │             │             │
          ┌───┴───┐     ┌───┴───┐     ┌───┴───┐
          │ Tier 2│     │ Tier 2│     │ Tier 2│
          └───────┘     └───────┘     └───────┘

     Connections show:
     • Emission flows (animated particles)
     • Transport routes (curved lines)
     • Impact intensity (line thickness + color)
```

**Visual Design**:
- **Nodes**:
  - Your company: Large gold sphere with glow
  - Suppliers: Sized by emission contribution
  - Color: Heat map from green (low) to red (high)
- **Edges**:
  - Curved Bezier paths between nodes
  - Animated particles flowing along paths
  - Thickness proportional to emission volume
- **Materials**:
  - Nodes: Metallic with environment reflection
  - Edges: Emissive gradient materials
  - Background: Subtle star field for depth

**Interaction**:
- **Tap Node**: Supplier details, emissions breakdown
- **Trace Path**: Drag finger to highlight full supply chain
- **Filter**: Voice command "Show only high emission suppliers"
- **Compare**: Select two nodes to see side-by-side comparison

---

## 4. Full Space / Immersive Experiences

### 4.1 Earth Sustainability Visualization

**Immersion Level**: Progressive (default) or Full

**Scene Composition**:

```
                        ┌─────────────────┐
                        │   Earth Sphere  │
                        │   (3m diameter) │
                        │   5m distance   │
                        └─────────────────┘
                               ↓
            Overlays (toggle layers):
            • Heat map of emissions intensity
            • Facility markers (glowing pins)
            • Supply chain paths (arc trajectories)
            • Impact zones (translucent spheres)
            • Renewable energy installations (green stars)
            • Deforestation regions (red areas)
```

**Earth Visual Design**:
- **Base Model**:
  - High-resolution Earth texture (16K)
  - Normal mapping for terrain detail
  - Specular highlights on oceans
  - Cloud layer with subtle animation
- **Atmosphere**:
  - Volumetric fog shader
  - Blue atmospheric scattering
  - Glow at horizon
- **Night Side**:
  - City lights texture
  - Facility markers glow brighter
- **Rotation**: Slow auto-rotation (24 hours = 2 minutes)

**Data Overlay Layers**:

1. **Emission Heat Map**:
   - Texture overlay projected onto Earth
   - Red (high) → Yellow (medium) → Green (low)
   - Updates in real-time as data changes
   - Animated pulse effect for new data

2. **Facility Markers**:
   - 3D pins at geographic locations
   - Height indicates emission level
   - Color indicates efficiency rating
   - Particle effects for active facilities
   - Label appears on gaze

3. **Supply Chain Arcs**:
   - Curved arcs between locations
   - Animated particles flowing along routes
   - Arc color based on emission intensity
   - Interactive: tap to trace full chain

4. **Impact Zones**:
   - Translucent spheres showing affected areas
   - Size represents impact radius
   - Opacity represents severity
   - Animated ripple effect for active impacts

**UI Controls (Floating Panels)**:

```
┌─────────────────┐
│  Layer Control  │
├─────────────────┤
│ ☑ Heat Map      │
│ ☑ Facilities    │
│ ☑ Supply Chain  │
│ ☐ Impact Zones  │
│ ☐ Renewables    │
└─────────────────┘

┌─────────────────┐
│  Time Control   │
├─────────────────┤
│ ◀ ■ ▶          │
│ ━━━●━━━━━━━━━  │
│ 2024 Q3         │
└─────────────────┘

┌─────────────────┐
│  Scenario       │
├─────────────────┤
│ • Current State │
│ ○ Target 2030   │
│ ○ Net Zero 2050 │
│ ○ Custom...     │
└─────────────────┘
```

**Spatial Audio**:
- **Ambient**: Gentle Earth atmosphere sounds
- **Facilities**: Industrial hum at facility locations
- **Supply Chain**: Transportation sounds along routes
- **Alerts**: Notification chimes spatially positioned
- **Achievement**: Positive sound when goal reached

### 4.2 Scenario Comparison Mode

**Layout**: Split Earth view

```
        Current State              Future Scenario
             Earth                      Earth
         (Present Day)              (2030 Target)
              │                          │
              ├──────────┬───────────────┤
              │          │               │
         Dark emissions  │          Reduced glow
         Many red zones  │          Mostly green
         Dense supply    │          Optimized routes
         chains          │          More renewables
```

**Interaction**:
- **Slide Timeline**: Morph between states
- **Highlight Differences**: Flash changed regions
- **Metrics Panel**: Shows comparison statistics
- **Voice Command**: "Show impact of achieving this goal"

### 4.3 Stakeholder Presentation Mode

**Purpose**: Board presentations, investor meetings

**Features**:
- **Guided Tour**: Automated flythrough of key metrics
- **Spotlight Mode**: Dim everything except focused data
- **Annotation Tools**: Draw in 3D space to highlight points
- **Screen Recording**: Capture presentation for replay
- **Multi-User**: Remote attendees see same view via SharePlay

---

## 5. Interaction Patterns

### 5.1 Direct Manipulation

#### Select
```swift
// Gaze + Tap
.onTapGesture {
    highlightEntity()
    showDetails()
}

// Visual Feedback
- Subtle scale up (1.0 → 1.05)
- Glow effect appears
- Haptic click feedback
```

#### Move
```swift
// Pinch + Drag
.gesture(DragGesture()
    .onChanged { value in
        entity.position = value.location3D
    }
)

// Visual Feedback
- Entity follows hand smoothly
- Shadow shows placement
- Snap guides for alignment
```

#### Rotate
```swift
// Two-finger rotation
.gesture(RotateGesture3D()
    .onChanged { value in
        entity.rotate(by: value.rotation)
    }
)

// Visual Feedback
- Rotation indicator appears
- Momentum continues after release
- Snap to cardinal directions (optional)
```

### 5.2 Environmental Gestures

#### Measure Impact (Circle Area)
```
User Action:
1. Extend index finger
2. Draw circle around facilities
3. Close circle to complete

System Response:
1. Green outline follows finger
2. Circle fills with translucent surface
3. Calculate total emissions in area
4. Display result in floating label
```

#### Set Target (Draw Line)
```
User Action:
1. Point at chart
2. Draw horizontal line at desired value
3. Release to confirm

System Response:
1. Dashed line appears following finger
2. Snap to chart grid
3. Show numerical value
4. Create goal dialog appears
```

#### Timeline Scrub (Swipe)
```
User Action:
1. Swipe left (future) or right (past)
2. Swipe speed = time travel speed

System Response:
1. Date indicator updates
2. Data morphs smoothly
3. Facilities appear/disappear
4. Audio pitch shifts with speed
```

### 5.3 Voice Commands

```
"Show me my carbon footprint"
→ Opens dashboard, highlights total

"What are my biggest emission sources?"
→ Sorts and highlights top 5 sources

"How are we tracking toward net zero?"
→ Opens goals, focuses on net zero target

"Compare this quarter to last year"
→ Enters comparison mode with timeline

"Show supply chain emissions"
→ Opens supply chain 3D volume

"View Earth"
→ Enters immersive Earth visualization

"Create a report for the board"
→ Launches report generation wizard
```

### 5.4 Contextual Menus

```swift
.contextMenu {
    Button("View Details") { /* ... */ }
    Button("Set Goal") { /* ... */ }
    Button("Generate Report") { /* ... */ }
    Divider()
    Button("Share") { /* ... */ }
    Button("Export Data") { /* ... */ }
}

// Appears as floating menu near selected item
// Activated by tap-and-hold or secondary tap
```

---

## 6. Visual Design System

### 6.1 Typography

#### Font Families
```swift
// San Francisco Pro (System Font)
let displayFont = Font.system(.largeTitle, design: .rounded, weight: .bold)
let headingFont = Font.system(.title, design: .default, weight: .semibold)
let bodyFont = Font.system(.body, design: .default, weight: .regular)
let captionFont = Font.system(.caption, design: .default, weight: .regular)
let monoFont = Font.system(.body, design: .monospaced, weight: .regular)
```

#### Type Scale
```
Display:     48pt / Bold Rounded       (Hero metrics)
Title 1:     34pt / Semibold           (Section headers)
Title 2:     28pt / Semibold           (Card headers)
Title 3:     22pt / Semibold           (Subsection headers)
Headline:    17pt / Semibold           (Emphasis)
Body:        17pt / Regular            (Primary content)
Callout:     16pt / Regular            (Secondary content)
Subhead:     15pt / Regular            (Labels)
Footnote:    13pt / Regular            (Supporting text)
Caption:     12pt / Regular            (Annotations)
```

#### Spatial Typography (3D Text)
```swift
// Text in 3D space
ModelEntity(
    mesh: .generateText(
        "1,234 tCO2",
        extrusionDepth: 0.01,
        font: .systemFont(ofSize: 0.05),
        containerFrame: .zero,
        alignment: .center,
        lineBreakMode: .byWordWrapping
    ),
    materials: [SimpleMaterial(color: .white, isMetallic: false)]
)

// Best Practices:
- Always face the user (billboard component)
- Minimum size: 0.03m for readability
- Use contrasting background
- Add subtle glow for legibility
```

### 6.2 Color Palette

#### Environmental Colors
```swift
// Primary Palette
let emissionRed    = Color(hex: "#E34034")  // High emissions
let warningOrange  = Color(hex: "#F2994A")  // Medium emissions
let cautionYellow  = Color(hex: "#F2C94C")  // Approaching target
let neutralGray    = Color(hex: "#828282")  // Neutral/baseline
let targetGreen    = Color(hex: "#27AE60")  // On target
let achievedBlue   = Color(hex: "#2D9CDB")  // Goal achieved

// Secondary Palette
let waterBlue      = Color(hex: "#56CCF2")  // Water metrics
let solarGold      = Color(hex: "#F9A826")  // Solar energy
let windCyan       = Color(hex: "#00C9A7")  // Wind energy
let forestGreen    = Color(hex: "#219653")  // Forest/carbon sink
let soilBrown      = Color(hex: "#8B4513")  // Land use

// UI Colors (Adaptive)
let primaryText    = Color.primary
let secondaryText  = Color.secondary
let tertiaryText   = Color.tertiary
let backgroundColor = Color(UIColor.systemBackground)
let surfaceColor   = Color(UIColor.secondarySystemBackground)
```

#### Color Usage Guidelines

| Element | Light Mode | Dark Mode | Purpose |
|---------|-----------|-----------|---------|
| High Emissions | Red (#E34034) | Red (#FF6B6B) | Alert, urgent action |
| Medium Emissions | Orange (#F2994A) | Orange (#FFA07A) | Warning, monitor |
| On Target | Green (#27AE60) | Green (#6FCF97) | Success, positive |
| Background | White 80% | Black 80% | Glass material |
| Text Primary | Black 87% | White 87% | Main content |
| Text Secondary | Black 60% | White 60% | Supporting info |

#### Accessibility
- All color combinations meet WCAG AAA (7:1 contrast ratio)
- Color is never the only means of conveying information
- Patterns and shapes supplement color coding
- High contrast mode increases contrast to 10:1

### 6.3 Materials & Lighting

#### Glass Materials (visionOS Standard)
```swift
// Primary window background
.background(.regularMaterial)
.backgroundStyle(.glass)

// Elevated surfaces
.background(.thickMaterial)

// Subtle overlays
.background(.thinMaterial)

// Chrome accents
.background(.ultraThinMaterial)
```

#### 3D Materials (RealityKit)

**Emission Sources (High Impact)**:
```swift
var material = SimpleMaterial()
material.color = .init(tint: .red, texture: nil)
material.metallic = .init(floatLiteral: 0.8)
material.roughness = .init(floatLiteral: 0.2)
material.emissiveColor = .red
material.emissiveIntensity = 2.0
```

**Sustainable Solutions (Low Impact)**:
```swift
var material = SimpleMaterial()
material.color = .init(tint: .green, texture: nil)
material.metallic = .init(floatLiteral: 0.3)
material.roughness = .init(floatLiteral: 0.6)
material.emissiveColor = .green
material.emissiveIntensity = 0.5
```

**Earth Sphere**:
```swift
var earthMaterial = PhysicallyBasedMaterial()
earthMaterial.baseColor = .init(texture: .init(earthDiffuseTexture))
earthMaterial.normal = .init(texture: .init(earthNormalTexture))
earthMaterial.roughness = .init(floatLiteral: 0.9)
earthMaterial.metallic = .init(floatLiteral: 0.0)
```

#### Lighting Setup
```swift
// Ambient light
let ambient = DirectionalLight()
ambient.light.color = .white
ambient.light.intensity = 500

// Directional light (sun)
let sun = DirectionalLight()
sun.light.color = .init(white: 1.0)
sun.light.intensity = 1000
sun.look(at: [0, 0, 0], from: [1, 1, 1], relativeTo: nil)

// Rim light (highlights)
let rim = SpotLight()
rim.light.intensity = 300
rim.light.color = .init(white: 0.9)
```

### 6.4 Iconography in 3D Space

#### Icon Style
- **SF Symbols**: Use for 2D UI (windows)
- **3D Custom Icons**: Use for spatial environment
  - Facility markers: Building models
  - Energy sources: Solar panel, wind turbine models
  - Transport: Vehicle models
  - Alerts: Exclamation pyramid

#### Icon Sizing
```
Small:   0.05m × 0.05m  (Detail markers)
Medium:  0.10m × 0.10m  (Standard icons)
Large:   0.20m × 0.20m  (Primary indicators)
Hero:    0.50m × 0.50m  (Feature highlights)
```

#### Icon Materials
```swift
// Standard icon material
var iconMaterial = SimpleMaterial()
iconMaterial.color = .init(tint: .white, texture: nil)
iconMaterial.metallic = .init(floatLiteral: 0.5)
iconMaterial.roughness = .init(floatLiteral: 0.3)

// Add glow for emphasis
iconMaterial.emissiveColor = primaryColor
iconMaterial.emissiveIntensity = 1.5
```

---

## 7. User Flows & Navigation

### 7.1 App Launch Flow

```
1. App Icon Tap
   ↓
2. Splash Screen (< 1s)
   - Rotating Earth
   - "Loading sustainability data..."
   ↓
3. Dashboard Window Opens
   - Fades in from center
   - Animates to optimal position
   - Data loads progressively
   ↓
4. Welcome Tip (First Time Users)
   - "Tap 'View Earth' to see global impact"
   - [Dismiss] or [Take Tour]
```

### 7.2 Primary Navigation Flow

```
Dashboard (Home)
│
├─→ Goals Tracking
│   └─→ Goal Details
│       └─→ Add/Edit Goal
│
├─→ Analytics
│   ├─→ Emission Trends
│   ├─→ Forecasting
│   └─→ AI Recommendations
│
├─→ 3D Visualizations
│   ├─→ Carbon Flow Volume
│   ├─→ Energy Chart Volume
│   └─→ Supply Chain Volume
│
├─→ Earth Immersive
│   ├─→ Current State
│   ├─→ Scenario Modeling
│   └─→ Presentation Mode
│
├─→ Reports
│   ├─→ Generate Report
│   ├─→ Report History
│   └─→ Export/Share
│
└─→ Settings
    ├─→ Organization Profile
    ├─→ Data Sources
    ├─→ Preferences
    └─→ About
```

### 7.3 Data Exploration Flow

```
User sees high emission on dashboard
   ↓
Taps emission source
   ↓
Card expands with details:
- Facility breakdown
- Trend over time
- Comparison to target
   ↓
User taps "View in 3D"
   ↓
Opens Carbon Flow Volume
   ↓
User selects specific flow
   ↓
Highlights path, shows details
   ↓
User asks "How can we reduce this?"
   ↓
AI recommendations appear
   ↓
User taps recommendation
   ↓
Shows detailed implementation plan
   ↓
User creates goal from recommendation
   ↓
Returns to Goals Tracking
```

### 7.4 Report Generation Flow

```
Dashboard → [Generate Report]
   ↓
Report Configuration:
- Time period selector
- Included metrics (checkboxes)
- Format (PDF, Excel, Web)
- Audience (Board, Regulatory, Public)
   ↓
[Generate] button
   ↓
Progress indicator (3-5 seconds)
   ↓
Report preview appears:
- Scroll through pages
- Edit sections
- Add annotations
   ↓
[Export] or [Share]
   ↓
System share sheet:
- Email
- AirDrop
- Save to Files
- Print
```

---

## 8. Accessibility Design

### 8.1 VoiceOver Experience

#### Window Navigation
```
VoiceOver announces:
"Sustainability Dashboard window. Showing carbon footprint 45,234 tons CO2, down 5,200 tons from last quarter. Three cards: Total Carbon Footprint, Reduction Progress, Goals Status. Swipe right to explore."

User swipes right:
"Total Carbon Footprint. 45,234 tons CO2 equivalent. Down 10.3% from last quarter. Double-tap to view details."

User double-taps:
"Opening detailed emission breakdown..."
```

#### 3D Entity Descriptions
```
User navigates to Earth view:
"Earth visualization. Showing global facilities and emissions. 5 facilities highlighted. Largest emission source: Shanghai manufacturing, 12,500 tons CO2. Tap facility for details or say 'list all facilities'."

User taps facility:
"Shanghai Manufacturing Facility. Emissions: 12,500 tons CO2, 28% of total. On track to meet reduction target. Actions available: View details, Set goal, Generate report."
```

### 8.2 Visual Accessibility

#### Text Scaling
```swift
// Support Dynamic Type
Text("Carbon Footprint")
    .font(.title)
    .dynamicTypeSize(.xSmall ... .xxxLarge)

// In 3D space, scale text entities
func updateTextSize(for dynamicTypeSize: DynamicTypeSize) {
    let scale: Float = {
        switch dynamicTypeSize {
        case .xSmall: return 0.7
        case .large: return 1.3
        case .xxxLarge: return 2.0
        default: return 1.0
        }
    }()
    textEntity.scale = [scale, scale, scale]
}
```

#### High Contrast
```swift
@Environment(\.accessibilityContrast) var contrast

var strokeWidth: CGFloat {
    contrast == .increased ? 3.0 : 1.5
}

var chartColors: [Color] {
    if contrast == .increased {
        return [.red, .green, .blue, .yellow] // Highly distinct
    } else {
        return [.red, .orange, .green, .blue] // Normal palette
    }
}
```

#### Reduce Motion
```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

func animateEmissions() {
    if reduceMotion {
        // Cross-fade instead of particle animation
        withAnimation(.easeInOut(duration: 0.3)) {
            updateEmissionValues()
        }
    } else {
        // Full particle system animation
        startParticleAnimation()
    }
}
```

### 8.3 Alternative Input Methods

#### Keyboard Shortcuts
```
Command + D : Open Dashboard
Command + G : Goals Tracking
Command + E : Earth View
Command + R : Generate Report
Command + / : Help
Tab         : Next element
Shift + Tab : Previous element
Space       : Activate focused element
Escape      : Close window / Exit immersive
```

#### Switch Control
- Sequential scanning mode
- Automatic highlighting of interactive elements
- Adjustable scan speed
- Audio feedback for selections

---

## 9. Error States & Loading Indicators

### 9.1 Loading States

#### Dashboard Loading
```
┌─────────────────────────────────────┐
│  Sustainability Command Center      │
├─────────────────────────────────────┤
│                                     │
│     ⟳  Loading sustainability data  │
│                                     │
│     ▓▓▓▓▓▓▓▓▓▓░░░░░░░░░  60%        │
│                                     │
└─────────────────────────────────────┘
```

#### 3D Scene Loading
```
Earth appears in low resolution
    ↓
High-res textures stream in
    ↓
Facility markers pop in one by one
    ↓
Data overlays fade in
    ↓
"Ready" with subtle haptic feedback
```

#### Progress Indicators
```swift
// Determinate (known duration)
ProgressView(value: progress, total: 1.0)
    .progressViewStyle(.circular)
    .tint(.green)

// Indeterminate (unknown duration)
ProgressView("Calculating emissions...")
    .progressViewStyle(.circular)
```

### 9.2 Error States

#### Network Error
```
┌──────────────────────────────────┐
│  ⚠️  Connection Error            │
├──────────────────────────────────┤
│  Unable to fetch latest data.    │
│  Showing cached data from:       │
│  2024-11-17 10:23 AM            │
│                                  │
│  [Retry] [Use Offline Mode]     │
└──────────────────────────────────┘
```

#### Data Validation Error
```
┌──────────────────────────────────┐
│  ❌  Invalid Data                │
├──────────────────────────────────┤
│  Emission value out of range.    │
│  Expected: 0 - 100,000 tCO2     │
│  Received: -150 tCO2            │
│                                  │
│  Please check data source and    │
│  try again.                      │
│                                  │
│  [Contact Support] [Dismiss]     │
└──────────────────────────────────┘
```

#### Empty State
```
┌──────────────────────────────────┐
│  No Goals Set                    │
├──────────────────────────────────┤
│  🎯                              │
│                                  │
│  You haven't created any         │
│  sustainability goals yet.       │
│                                  │
│  Set your first goal to start    │
│  tracking progress.              │
│                                  │
│  [Create Goal]                   │
└──────────────────────────────────┘
```

### 9.3 Success States

#### Goal Achieved
```
Celebration animation:
- Confetti particles in 3D space
- Success chime audio
- Gentle haptic celebration
- Achievement badge appears

┌──────────────────────────────────┐
│  🎉  Goal Achieved!              │
├──────────────────────────────────┤
│  Waste Reduction Goal            │
│                                  │
│  You've successfully diverted    │
│  90% of waste from landfills!    │
│                                  │
│  Impact: 2,400 tons waste saved  │
│  Cost savings: $128,000          │
│                                  │
│  [Share Achievement] [Dismiss]   │
└──────────────────────────────────┘
```

#### Report Generated
```
┌──────────────────────────────────┐
│  ✓  Report Ready                 │
├──────────────────────────────────┤
│  Q3 2024 ESG Report              │
│  Generated: Nov 17, 2024         │
│  Pages: 24                       │
│  Format: PDF                     │
│                                  │
│  [View] [Share] [Download]       │
└──────────────────────────────────┘
```

---

## 10. Animation & Transition Specifications

### 10.1 Window Transitions

#### Window Open
```swift
// Fade in + scale up
.transition(.asymmetric(
    insertion: .scale(scale: 0.8).combined(with: .opacity),
    removal: .opacity
))
.animation(.spring(response: 0.4, dampingFraction: 0.7), value: isPresented)
```

#### Window Close
```swift
// Scale down + fade out
.transition(.scale(scale: 0.9).combined(with: .opacity))
.animation(.easeInOut(duration: 0.25), value: isPresented)
```

#### Window Position Change
```swift
// Smooth move with overshoot
.animation(.spring(response: 0.5, dampingFraction: 0.75), value: position)
```

### 10.2 Data Updates

#### Chart Data Change
```swift
// Animate values
withAnimation(.easeInOut(duration: 0.6)) {
    chartData = newData
}

// Morph between states
.interpolation(.catmullRom)
```

#### Counter Animation
```swift
// Smooth number counting
AnimatableModifier(
    from: oldValue,
    to: newValue,
    duration: 0.8,
    curve: .easeOut
)
```

### 10.3 3D Entity Animations

#### Entity Entrance
```swift
// Pop in with scale
entity.scale = [0.01, 0.01, 0.01]
entity.move(
    to: Transform(scale: [1, 1, 1]),
    relativeTo: nil,
    duration: 0.4,
    timingFunction: .easeOut
)
```

#### Particle Flow
```swift
// Continuous emission
let particleEmitter = ParticleEmitterComponent()
particleEmitter.emissionShape = .sphere
particleEmitter.birthRate = 100
particleEmitter.lifeSpan = 2.0
particleEmitter.speed = 0.5
entity.components[ParticleEmitterComponent.self] = particleEmitter
```

#### Earth Rotation
```swift
// Smooth continuous rotation
let rotationSpeed: Float = .pi / 60 // 2 min per rotation
entity.transform.rotation *= simd_quatf(
    angle: rotationSpeed * deltaTime,
    axis: [0, 1, 0]
)
```

### 10.4 Interaction Feedback

#### Hover
```swift
// Subtle highlight
entity.components[HoverEffectComponent.self] = HoverEffectComponent()

// Scale up slightly
withAnimation(.easeInOut(duration: 0.15)) {
    scale = 1.05
}
```

#### Tap
```swift
// Immediate feedback
HapticManager.shared.play(.click)

// Visual feedback
withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
    scale = 0.95 // Compress
}
DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
    withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
        scale = 1.0 // Release
    }
}
```

---

## 11. Responsive Design

### 11.1 Window Adaptation

```swift
// Adapt layout based on window size
@Environment(\.horizontalSizeClass) var horizontalSizeClass

var layout: some View {
    if horizontalSizeClass == .compact {
        VStack { /* Vertical layout */ }
    } else {
        HStack { /* Horizontal layout */ }
    }
}
```

### 11.2 Content Scaling

```swift
// Scale content for different viewing distances
func updateDetailLevel(viewerDistance: Float) {
    switch viewerDistance {
    case 0..<2:
        showDetailLevel(.high)
    case 2..<5:
        showDetailLevel(.medium)
    default:
        showDetailLevel(.low)
    }
}
```

---

## Appendix A: Design Checklist

- [ ] All text meets minimum size requirements (18pt in 2D, 0.03m in 3D)
- [ ] Color contrast meets WCAG AAA standards
- [ ] All interactive elements have 60pt+ hit targets
- [ ] VoiceOver labels for all interactive elements
- [ ] Reduce motion alternatives for all animations
- [ ] High contrast mode support
- [ ] Dynamic Type support throughout
- [ ] Keyboard navigation functional
- [ ] Alternative text for all visual information
- [ ] Error states designed and implemented
- [ ] Loading states for all async operations
- [ ] Success feedback for all user actions
- [ ] Haptic feedback where appropriate
- [ ] Spatial audio enhances experience
- [ ] Comfortable viewing angles (10-15° below eye level)

---

## Appendix B: Design Resources

### Figma Files
- Dashboard wireframes
- 3D visualization sketches
- Icon library
- Component library

### Assets Needed
- Earth texture (16K resolution)
- Normal maps for terrain
- Cloud layer texture
- City lights (night side)
- Facility 3D models
- Icon set (3D)
- Particle textures
- Sound effects
- Background audio

---

*This design specification provides comprehensive guidance for creating an intuitive, beautiful, and impactful sustainability visualization experience on visionOS.*
