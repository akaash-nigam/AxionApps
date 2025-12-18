# Business Operating System - Design Specification

## Document Overview

This document defines the comprehensive UI/UX design specifications for the Business Operating System (BOS), focusing on spatial design principles, 3D visualizations, and natural interaction patterns optimized for Apple Vision Pro.

**Version:** 1.0
**Last Updated:** 2025-01-20
**Platform:** visionOS 2.0+

---

## 1. Spatial Design Principles

### 1.1 Core Design Philosophy

**"Business as Living Organism"**

The BOS transforms abstract business data into a tangible, navigable spatial environment where:
- Departments exist as physical locations
- Data flows like rivers between entities
- Performance metrics grow or shrink organically
- Problems appear as visible disturbances
- Opportunities glow with potential

### 1.2 Fundamental Spatial Principles

#### Principle 1: Spatial Consistency
**Description:** Business elements maintain consistent positions across sessions, leveraging spatial memory.

**Implementation:**
- Finance always below (foundation)
- Strategy always above (sky/future)
- Operations at eye level (current reality)
- Customers in center (focus)
- Teams arranged in meaningful clusters

**Benefit:** Users develop muscle memory and can navigate instinctively.

#### Principle 2: Depth as Meaning
**Description:** Z-axis distance communicates data hierarchies and relationships.

**Implementation:**
- Distant objects = less immediate priority
- Close objects = urgent attention needed
- Layered depth = hierarchical data
- Overlapping = relationships and dependencies

#### Principle 3: Scale as Significance
**Description:** Physical size represents importance, magnitude, or impact.

**Implementation:**
- Revenue shown as towering structures
- Small issues as subtle indicators
- Major projects as large, detailed models
- Minor tasks as compact representations

#### Principle 4: Motion as Change
**Description:** Movement and animation indicate activity, change, and trends.

**Implementation:**
- Growing entities = positive trends
- Shrinking entities = declining metrics
- Pulsing = real-time updates
- Flowing particles = active processes
- Static = stable/completed

#### Principle 5: Ergonomic Placement
**Description:** Critical information positioned for comfortable viewing without fatigue.

**Implementation:**
- Primary data: 1.0-1.5m distance
- -10° to -15° below eye level (comfortable viewing angle)
- Navigation controls: arm's reach (0.5-0.8m)
- Ambient info: peripheral vision (2-3m)

---

## 2. Spatial Layout Design

### 2.1 Business Universe Layout

```
                         ╔═══════════════════╗
                         ║   STRATEGY SKY    ║
                         ║   (Goals, Plans)  ║
                         ╚═══════════════════╝
                                 ▲ +1.0m
                                 │

    ◄──────────────────────────────────────────────────►
     OPERATIONS         │                    PEOPLE
     (Manufacturing)    │                (Organization)
     -2.0m, 0.0        │                   +2.0m, 0.0
                        │
                   ┌────┴────┐
                   │ CUSTOMER│  ◄── Eye Level (0, 0, -1.5m)
                   │ GALAXY  │
                   └────┬────┘
                        │
                        ▼ -1.0m
                 ╔═══════════════════╗
                 ║ FINANCIAL FOUNDATION║
                 ║ (P&L, Cash Flow)    ║
                 ╚═══════════════════╝
```

### 2.2 Spatial Zones

#### Executive Zone (Eye Level, 0° to -15°)
**Position:** 0m Y, 1.0-1.5m distance
**Content:**
- Real-time KPI dashboard
- Critical alerts
- Key metrics requiring immediate attention
- AI recommendations

**Visual Treatment:**
- Floating glass panels with ultra-thin material
- High contrast for quick readability
- Subtle animations for updates
- Minimal chrome to reduce clutter

#### Operational Zone (Arm's Reach, -15° to -30°)
**Position:** -0.3m to -0.5m Y, 0.5-1.0m distance
**Content:**
- Interactive controls
- Data manipulation tools
- Detailed departmental views
- Process workflows

**Visual Treatment:**
- Tactile 3D elements
- Clear affordances for interaction
- Haptic feedback indicators
- Color-coded by function

#### Strategic Zone (Above, +10° to +30°)
**Position:** +0.5m to +1.0m Y, 1.5-2.0m distance
**Content:**
- Long-term projections
- Goal tracking
- Market analysis
- Competitive landscape

**Visual Treatment:**
- Ethereal, forward-looking aesthetic
- Translucent materials
- Subtle animations suggesting growth
- Aspirational color palette

#### Foundation Zone (Below, -30° to -45°)
**Position:** -0.8m to -1.2m Y, 1.5-2.0m distance
**Content:**
- Financial metrics (P&L, balance sheet)
- Cash flow visualizations
- Budget tracking
- Audit trail

**Visual Treatment:**
- Solid, foundational appearance
- Rock/concrete-like materials
- Stable, reassuring colors
- Minimal animation (stability)

#### Peripheral Zone (Surround, ±60° to ±120°)
**Position:** 2.0-4.0m distance, surrounding user
**Content:**
- Ambient indicators
- Non-critical notifications
- Environmental context
- Historical data

**Visual Treatment:**
- Low opacity (10-30%)
- Gentle pulses for updates
- Muted colors
- Minimal detail (silhouettes)

---

## 3. Window Layouts and Configurations

### 3.1 Executive Dashboard Window

**Type:** WindowGroup (2D Floating Panel)
**Size:** 1200 x 800 points
**Position:** Center, eye level

#### Layout Structure

```
┌─────────────────────────────────────────────────────────┐
│  ☰ Menu          BUSINESS OPERATING SYSTEM       👤 User │ 40pt
├─────────────────────────────────────────────────────────┤
│                                                           │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐│
│  │ Revenue  │  │  Profit  │  │ Customers│  │Employees ││ 140pt
│  │ $12.4M ▲│  │  $2.1M ▼│  │  15,234 ▲│  │  1,847  ─│
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘│
│                                                           │
│  ┌──────────────────────────────────────────────────────┐│
│  │                                                       ││
│  │         FINANCIAL PERFORMANCE CHART                  ││ 300pt
│  │         [Interactive Line/Bar Chart]                 ││
│  │                                                       ││
│  └──────────────────────────────────────────────────────┘│
│                                                           │
│  ┌───────────────────┐  ┌───────────────────────────────┐│
│  │  ALERTS (3)       │  │  RECENT ACTIVITY              ││
│  │  • Budget variance│  │  • Q4 budget approved         ││ 240pt
│  │  • Customer churn │  │  • New hire: Engineering      ││
│  │  • Inventory low  │  │  • Deal closed: $500K         ││
│  └───────────────────┘  └───────────────────────────────┘│
│                                                           │
├─────────────────────────────────────────────────────────┤
│  [Dashboard] [Departments] [Analytics] [Settings]        │ 60pt
└─────────────────────────────────────────────────────────┘
```

#### Visual Specifications

**Materials:**
- Background: `.ultraThinMaterial` with 95% opacity
- Cards: `.thinMaterial` with hover effect
- Headers: `.regularMaterial`

**Typography:**
- Title: SF Pro Rounded Bold, 28pt
- Section Headers: SF Pro Semibold, 18pt
- Metrics: SF Pro Rounded Medium, 36pt (numbers)
- Body: SF Pro Regular, 14pt
- Labels: SF Pro Regular, 12pt

**Color Coding:**
- Positive trends: #00D084 (Green)
- Negative trends: #FF3B30 (Red)
- Neutral: #007AFF (Blue)
- Warnings: #FF9500 (Orange)

**Spacing:**
- Outer padding: 24pt
- Card spacing: 16pt
- Section spacing: 32pt

### 3.2 Department Detail Window

**Type:** WindowGroup (2D Panel)
**Size:** 900 x 1100 points
**Position:** Contextual (near selected department in 3D space)

#### Layout Structure

```
┌──────────────────────────────────────────────┐
│  ← Back        ENGINEERING DEPARTMENT         │
├──────────────────────────────────────────────┤
│                                                │
│  [3D PREVIEW OF DEPARTMENT VOLUME]             │
│  [Interactive 3D representation]               │
│                                                │
├──────────────────────────────────────────────┤
│                                                │
│  OVERVIEW                                      │
│  Headcount: 247 employees ▲ +12 this quarter  │
│  Budget: $12.4M (85% utilized)                 │
│  Active Projects: 23                           │
│                                                │
│  KEY METRICS                                   │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐      │
│  │ Velocity │ │ Quality  │ │Morale    │      │
│  │  8.2 ▲  │ │  94% ▲  │ │ 4.2/5 ─ │      │
│  └──────────┘ └──────────┘ └──────────┘      │
│                                                │
│  TEAM STRUCTURE                                │
│  [Org chart visualization]                     │
│                                                │
│  CURRENT INITIATIVES                           │
│  • Cloud Migration (67% complete)              │
│  • Mobile App v2 (Planning phase)              │
│  • Security Audit (On hold)                    │
│                                                │
│  [View in 3D] [Edit] [Reports]                 │
└──────────────────────────────────────────────┘
```

### 3.3 Report Window

**Type:** WindowGroup (2D Panel)
**Size:** 800 x 1200 points (scrollable)
**Position:** User-positioned

**Features:**
- Export to PDF button (top-right ornament)
- Print preview
- Share via SharePlay
- Annotation tools (markup)

---

## 4. Volume Designs (3D Bounded Spaces)

### 4.1 Department Volume

**Physical Dimensions:** 1.0m (W) x 1.0m (H) x 1.0m (D)

#### Content Structure

```
         ┌─────────────────────┐  ▲
        /│    TEAM MEMBERS     │/│ │ Top Layer
       / │  (Avatars in 3D)    │ │ │ Leadership
      /  └─────────────────────┘ │ │
     ┌─────────────────────┐     │ │
    /│   ACTIVE PROJECTS   │/│   │ │ Middle Layer
   / │  (Cards & Timelines)│ │   │ │ Work Items
  /  └─────────────────────┘ │   │ │
 ┌─────────────────────┐     │   │ ▼ Bottom Layer
 │    KPIs & METRICS   │/────┘   │   Performance
 │   (Charts & Graphs) │         ▼
 └─────────────────────┘
```

#### Visual Design

**Layers:**
1. **Bottom (0.0-0.3m):** Metrics and KPIs
   - Material: Glass with data visualization
   - Color: Cool tones (blues, teals)
   - Animation: Smooth value transitions

2. **Middle (0.3-0.7m):** Active work
   - Material: Translucent cards
   - Color: Project status colors
   - Animation: Progress indicators

3. **Top (0.7-1.0m):** Team members
   - Material: Avatar spheres
   - Color: Warm tones (portraits)
   - Animation: Availability pulses

**Boundaries:**
- Subtle edge glow (2pt, 20% opacity)
- No hard walls (content should feel open)
- Clipping: Gentle fade at edges

**Interaction:**
- Tap any layer to focus and expand
- Drag layers vertically to reorder priority
- Pinch to zoom into specific area
- Two-hand rotate to view from different angles

### 4.2 Financial Visualization Volume

**Physical Dimensions:** 1.5m (W) x 1.2m (H) x 0.8m (D)

#### P&L Waterfall Visualization

```
                    ┌──────┐ ← Revenue (tallest)
                    │      │
                    │      │
  ┌──────┐         │      │
  │COGS  │         │      │
  │      │         │      │         ┌──────┐
  │      │    ┌────┴──────┴────┐   │      │ ← Net Profit
  └──────┘    │   Gross Margin  │   │      │
              └─────────────────┘   └──────┘
   │             │           │         │
   ▼             ▼           ▼         ▼
 -$8.2M       +$4.2M      -$1.3M    +$2.9M

[Flow animation shows money moving between columns]
```

**Visual Specifications:**
- Columns: Translucent glass with value label
- Flow: Particle system showing money movement
- Colors: Green (positive), Red (negative), Blue (neutral)
- Lighting: Spotlights illuminate each metric
- Scale: Height proportional to absolute value

### 4.3 Customer Journey Volume

**Physical Dimensions:** 1.2m (W) x 0.8m (H) x 1.5m (D)

#### Journey Stages in 3D Space

```
   Discovery → Consideration → Purchase → Retention
       │            │             │          │
       ○            ○             ○          ○
      / \          / \           / \        / \
    Paths        Paths         Paths      Paths

   [Each stage is a spatial zone customers flow through]
   [Lines connect individual customer journeys]
   [Color indicates sentiment: Green=Happy, Red=Frustrated]
```

**Interaction:**
- Tap any customer path to see details
- Filter by segment (visualization adjusts in real-time)
- Scrub timeline to see historical journeys

---

## 5. Immersive Space Design

### 5.1 Business Universe (Full Immersive)

**Environment:** 10m x 10m x 10m navigable space

#### Spatial Layout

**Central Hub (User Position):**
- User stands at center
- Quick access control panel at arm's reach
- Minimap overhead showing position

**Department Islands (Radial Layout):**
```
                    Strategy (North, +5m Z)
                           ⬆

     Operations ◄─────── USER ─────► People
     (West, -3m X)      (0,0,0)     (East, +3m X)

                           ↓
                    Finance (South, -5m Z)

            Customers (Below, -2m Y)
```

**Distance Coding:**
- 0-2m: High detail, full interaction
- 2-5m: Medium detail, visible
- 5-10m: Low detail, silhouettes
- 10m+: Fade to environment

#### Navigation

**Teleportation:**
- Point with hand at destination
- See preview of view from that position
- Confirm with pinch gesture
- Smooth transition (1 second fade)

**Walking:**
- Physical movement within safe space
- Virtual movement extends beyond physical space
- Boundaries indicated by subtle grid

**Flying:**
- Two-hand gesture: hands together → spread apart
- Fly toward gaze direction
- Speed controlled by hand separation

### 5.2 Immersive War Room (Collaborative)

**Purpose:** Multi-executive crisis management and strategic planning

**Layout:**
```
          [Main Visualization]
               ▲ Large 3D
               │ Shared Model
               │

    Exec 1 ─────┼───── Exec 2
    (Avatar)    │     (Avatar)
                │
    Exec 4 ─────┼───── Exec 3
    (Avatar)            (Avatar)

    [Individual Control Panels]
```

**Features:**
- Central shared 3D model (4m x 3m x 2m)
- Each executive has personal control panel
- Shared annotations appear in real-time
- Voting system (raise hand for yes, thumbs down for no)
- AI advisor avatar provides recommendations

**Visual Design:**
- Dark environment (reduces distractions)
- Focused lighting on shared model
- Avatar outlines (not full bodies)
- Spatial audio (voices positioned correctly)

---

## 6. 3D Visualization Specifications

### 6.1 Data Visualization Types

#### 3D Bar Chart

**Use Case:** Comparing metrics across departments/time

**Specifications:**
```swift
struct BarChart3D {
    // Dimensions
    var barWidth: Float = 0.15      // 15cm
    var barDepth: Float = 0.15      // 15cm
    var maxHeight: Float = 1.0      // 1m
    var spacing: Float = 0.05       // 5cm

    // Visual
    var material: Material = .glassMaterial
    var color: Color = .accentColor
    var showGrid: Bool = true
    var showLabels: Bool = true

    // Interaction
    var tapToHighlight: Bool = true
    var dragToReorder: Bool = true
}
```

**Animation:**
- Bars grow from bottom to top on first appearance (0.6s ease-out)
- Value changes animate smoothly (0.3s ease-in-out)
- Selected bar scales up 1.1x

**Material:**
```swift
var barMaterial: PhysicallyBasedMaterial {
    var material = PhysicallyBasedMaterial()
    material.baseColor = .init(tint: color)
    material.roughness = 0.2
    material.metallic = 0.1
    material.emissiveColor = .init(color: color.opacity(0.3))
    return material
}
```

#### Network Graph (Node-Link Diagram)

**Use Case:** Organizational relationships, data dependencies

**Specifications:**
```swift
struct NetworkGraph3D {
    // Nodes
    var nodeRadius: Float = 0.05     // 5cm spheres
    var nodeSpacing: Float = 0.3     // 30cm minimum

    // Links
    var linkThickness: Float = 0.005 // 5mm
    var showDirectionArrows: Bool = true
    var animateFlow: Bool = true

    // Layout
    var layoutAlgorithm: LayoutAlgorithm = .forceDirected
    var centerOfMass: SIMD3<Float> = [0, 0, -1.5]
}
```

**Visual Treatment:**
- Nodes: Glowing spheres
- Links: Thin cylinders with particle flow
- Labels: Billboarded text (always face user)
- Clusters: Subtle grouping halos

#### Heat Map (3D Surface)

**Use Case:** Geographic data, density visualization

**Specifications:**
- Surface mesh subdivided for detail
- Color gradient from cool (low) to hot (high)
- Height variation represents intensity
- Smooth interpolation between data points

**Color Gradient:**
```swift
let heatMapGradient = Gradient(colors: [
    Color(red: 0.0, green: 0.0, blue: 0.5),  // Deep blue (coldest)
    Color(red: 0.0, green: 0.5, blue: 1.0),  // Cyan
    Color(red: 0.0, green: 1.0, blue: 0.0),  // Green
    Color(red: 1.0, green: 1.0, blue: 0.0),  // Yellow
    Color(red: 1.0, green: 0.5, blue: 0.0),  // Orange
    Color(red: 1.0, green: 0.0, blue: 0.0),  // Red (hottest)
])
```

### 6.2 Business Entity Representations

#### Department as Building

```swift
struct DepartmentBuilding {
    var baseSize: SIMD3<Float> = [0.3, 0.4, 0.3]  // 30cm x 40cm x 30cm
    var floors: Int  // Proportional to headcount
    var windowsLit: Float  // Percentage = utilization
    var color: Color  // Department color
    var pulseRate: Float  // Activity level
}
```

**Visual Features:**
- Windows glow when employees are active
- Height represents total headcount
- Width represents budget
- Pulsing indicates real-time activity

#### Employee as Avatar

```swift
struct EmployeeAvatar {
    var sphere: Sphere = Sphere(radius: 0.04)  // 4cm
    var profileImage: Texture?
    var statusColor: Color
    var position: SIMD3<Float>
    var availability: AvailabilityStatus
}

enum AvailabilityStatus {
    case available    // Green glow
    case busy         // Yellow glow
    case offline      // Gray, no glow
    case inMeeting    // Blue glow with pulse
}
```

#### KPI as Floating Metric

```swift
struct KPIVisualization {
    var value: Decimal
    var target: Decimal
    var trend: Trend

    var visualStyle: VisualStyle {
        let performance = value / target

        return VisualStyle(
            size: calculateSize(performance),
            color: calculateColor(performance),
            animation: calculateAnimation(trend)
        )
    }
}

func calculateColor(_ performance: Decimal) -> Color {
    switch performance {
    case 1.1...:
        return .green         // Exceeding target
    case 0.9..<1.1:
        return .blue          // On target
    case 0.7..<0.9:
        return .orange        // Below target
    default:
        return .red           // Critically low
    }
}
```

---

## 7. Interaction Patterns

### 7.1 Gaze + Pinch (Primary Interaction)

#### Selection

**Pattern:**
1. Look at entity (gaze)
2. Entity highlights with subtle glow
3. Pinch fingers together (thumb + index)
4. Entity selected (confirmation haptic)

**Visual Feedback:**
- Hover: 10% scale increase, 30% opacity glow
- Selection: 5% scale increase, solid highlight ring

**Code Example:**
```swift
.onContinuousHover { phase in
    switch phase {
    case .active:
        entity.scale *= 1.1
        entity.components.set(HoverComponent(isActive: true))
    case .ended:
        entity.scale /= 1.1
        entity.components.set(HoverComponent(isActive: false))
    }
}
.gesture(
    TapGesture()
        .targetedToEntity(entity)
        .onEnded { _ in
            selectEntity(entity)
            playHaptic(.selection)
        }
)
```

#### Manipulation

**Direct Manipulation:**
1. Gaze + pinch to select
2. Hold pinch and move hand
3. Entity follows hand position
4. Release pinch to drop

**Constrained Manipulation:**
- Snap to grid (optional)
- Constrain to specific axis
- Limit to valid drop zones

### 7.2 Two-Hand Gestures

#### Scale

**Pattern:**
1. Pinch both hands on entity
2. Move hands apart to enlarge
3. Move hands together to shrink
4. Release to finalize

**Constraints:**
- Minimum scale: 0.5x
- Maximum scale: 3.0x
- Maintain aspect ratio (default)

#### Rotate

**Pattern:**
1. Pinch both hands on entity
2. Rotate hands circularly
3. Entity rotates around center
4. Snap to 45° increments (optional)

**Feedback:**
- Haptic click at each snap point
- Visual guide showing rotation angle

### 7.3 Voice Commands

**Activation:** "Hey BOS" or hardware button

#### Command Examples

```yaml
Navigation:
  - "Show me Finance department"
  - "Go to Customer view"
  - "Return to dashboard"

Data Queries:
  - "What's our revenue this quarter?"
  - "Show me top 10 customers"
  - "Compare Q3 to Q4"

Actions:
  - "Create new report"
  - "Share this view with the team"
  - "Bookmark this configuration"

Analysis:
  - "Why did revenue drop?"
  - "What's causing the bottleneck?"
  - "Predict next quarter's performance"
```

**Feedback:**
- Visual indicator when listening (pulsing microphone icon)
- Transcription shown in real-time
- Confirmation before executing actions

### 7.4 Gesture Library

#### Standard Gestures

| Gesture | Action | Visual Feedback | Haptic |
|---------|--------|-----------------|--------|
| **Tap** | Select/Activate | Scale 0.95x → 1.0x | Light impact |
| **Long Press** | Context Menu | Menu appears | Medium impact |
| **Drag** | Move | Ghost follows hand | Continuous light |
| **Swipe** | Navigate/Dismiss | Slide animation | Light impact |
| **Pinch** | Zoom In | Content enlarges | None |
| **Spread** | Zoom Out | Content shrinks | None |
| **Rotate** | Rotate Object | Entity rotates | Tick at angles |

#### Custom Business Gestures

| Gesture | Action | Description |
|---------|--------|-------------|
| **Drill Down** | Navigate deeper | Push forward while pinching |
| **Roll Up** | Navigate up hierarchy | Pull back while pinching |
| **Compare** | Show comparison | Bring two entities together |
| **Allocate** | Move resources | Drag from source to target |
| **Approve** | Confirm action | Thumbs up gesture |
| **Reject** | Decline action | Thumbs down gesture |

---

## 8. Visual Design System

### 8.1 Color Palette

#### Primary Colors

```swift
struct BOSColors {
    // Brand
    static let primary = Color(hex: "007AFF")      // iOS Blue
    static let secondary = Color(hex: "5856D6")    // Purple
    static let accent = Color(hex: "00D084")       // Green

    // Functional
    static let success = Color(hex: "34C759")      // Green
    static let warning = Color(hex: "FF9500")      // Orange
    static let error = Color(hex: "FF3B30")        // Red
    static let info = Color(hex: "5AC8FA")         // Light Blue

    // Neutrals
    static let background = Color(hex: "1C1C1E")   // Dark Gray
    static let surface = Color(hex: "2C2C2E")      // Medium Gray
    static let divider = Color(hex: "3A3A3C")      // Light Gray

    // Text
    static let textPrimary = Color(hex: "FFFFFF")  // White
    static let textSecondary = Color(hex: "EBEBF5", opacity: 0.6)
    static let textTertiary = Color(hex: "EBEBF5", opacity: 0.3)
}
```

#### Department Colors

```swift
enum DepartmentColor {
    case executive      // Gold: #FFD700
    case finance        // Green: #00D084
    case operations     // Orange: #FF9500
    case sales          // Blue: #007AFF
    case marketing      // Purple: #AF52DE
    case engineering    // Teal: #5AC8FA
    case hr             // Pink: #FF2D55
    case customerService// Indigo: #5856D6
}
```

#### Data Visualization Colors

```swift
// Sequential (for ordered data)
let sequentialBlue = [
    Color(hex: "EDF8FB"),
    Color(hex: "B3CDE3"),
    Color(hex: "8C96C6"),
    Color(hex: "8856A7"),
    Color(hex: "810F7C")
]

// Diverging (for data with meaningful midpoint)
let divergingRedBlue = [
    Color(hex: "D7191C"),  // Red
    Color(hex: "FDAE61"),  // Orange
    Color(hex: "FFFFBF"),  // Yellow (midpoint)
    Color(hex: "ABD9E9"),  // Light Blue
    Color(hex: "2C7BB6")   // Blue
]

// Categorical (for distinct categories)
let categorical = [
    Color(hex: "1F77B4"),
    Color(hex: "FF7F0E"),
    Color(hex: "2CA02C"),
    Color(hex: "D62728"),
    Color(hex: "9467BD"),
    Color(hex: "8C564B"),
    Color(hex: "E377C2"),
    Color(hex: "7F7F7F"),
    Color(hex: "BCBD22"),
    Color(hex: "17BECF")
]
```

### 8.2 Typography

#### Spatial Text Rendering

**Principles:**
- Billboarded text (always faces user) for critical labels
- World-locked text for spatial annotations
- Depth-tested text (occludes behind objects)

**Font Hierarchy:**

```swift
struct BOSTypography {
    // Display
    static let display = Font.system(size: 48, weight: .bold, design: .rounded)

    // Titles
    static let title1 = Font.system(size: 34, weight: .semibold)
    static let title2 = Font.system(size: 28, weight: .semibold)
    static let title3 = Font.system(size: 22, weight: .semibold)

    // Headings
    static let headline = Font.system(size: 17, weight: .semibold)
    static let subheadline = Font.system(size: 15, weight: .medium)

    // Body
    static let body = Font.system(size: 17, weight: .regular)
    static let bodyEmphasized = Font.system(size: 17, weight: .semibold)
    static let callout = Font.system(size: 16, weight: .regular)

    // Captions
    static let caption1 = Font.system(size: 12, weight: .regular)
    static let caption2 = Font.system(size: 11, weight: .regular)

    // Monospaced (for numbers)
    static let metrics = Font.system(size: 36, weight: .medium, design: .rounded)
        .monospacedDigit()
}
```

#### Text Contrast Requirements

- **2D Windows:** Follow standard WCAG 2.1 AA (4.5:1 for normal text)
- **3D Space:** Enhanced contrast (7:1 minimum) due to varied lighting
- **Spatial Labels:** High contrast background plate or glow outline

**Implementation:**
```swift
Text("Revenue")
    .font(.headline)
    .foregroundStyle(.white)
    .background {
        RoundedRectangle(cornerRadius: 4)
            .fill(.black.opacity(0.5))
            .blur(radius: 2)
    }
```

### 8.3 Materials and Lighting

#### Glass Materials

```swift
// Ultra Thin - Subtle backgrounds
var ultraThin: Material {
    .ultraThinMaterial
        .opacity(0.8)
}

// Thin - Control panels
var thin: Material {
    .thinMaterial
        .opacity(0.9)
}

// Regular - Cards and containers
var regular: Material {
    .regularMaterial
}

// Thick - Modal overlays
var thick: Material {
    .thickMaterial
        .opacity(0.95)
}
```

#### Physical Materials (RealityKit)

```swift
// Glass for data visualizations
var glassDataViz: PhysicallyBasedMaterial {
    var material = PhysicallyBasedMaterial()
    material.baseColor = .init(tint: .white.opacity(0.1))
    material.roughness = 0.05
    material.metallic = 0.0
    material.clearcoat = 1.0
    material.clearcoatRoughness = 0.0
    material.opacity = 0.3
    return material
}

// Metal for controls
var metalControl: PhysicallyBasedMaterial {
    var material = PhysicallyBasedMaterial()
    material.baseColor = .init(tint: .gray)
    material.roughness = 0.3
    material.metallic = 0.9
    return material
}

// Matte for text backgrounds
var matteBackground: PhysicallyBasedMaterial {
    var material = PhysicallyBasedMaterial()
    material.baseColor = .init(tint: .black.opacity(0.6))
    material.roughness = 1.0
    material.metallic = 0.0
    return material
}
```

#### Lighting Setup

**Immersive Space Lighting:**
```swift
// Image-based lighting for realistic reflections
var iblComponent: ImageBasedLightComponent {
    let resource = try! EnvironmentResource.load(named: "office_environment")
    return ImageBasedLightComponent(
        source: .single(resource),
        intensityExponent: 1.0
    )
}

// Directional light (key light)
var keyLight: DirectionalLight {
    var light = DirectionalLight()
    light.light.intensity = 5000
    light.light.color = .white
    light.light.isRealWorldProxy = false
    light.shadow = DirectionalLightComponent.Shadow(
        maximumDistance: 10.0,
        depthBias: 0.1
    )
    return light
}

// Ambient light (fill)
var fillLight: PointLight {
    var light = PointLight()
    light.light.intensity = 2000
    light.light.color = UIColor(white: 0.9, alpha: 1.0)
    light.light.attenuationRadius = 15.0
    return light
}

// Accent lights (rim lights for important entities)
func createAccentLight(color: UIColor, position: SIMD3<Float>) -> PointLight {
    var light = PointLight()
    light.light.intensity = 3000
    light.light.color = color
    light.light.attenuationRadius = 5.0
    light.position = position
    return light
}
```

### 8.4 Iconography in 3D Space

#### Icon Specifications

**2D Icons (SF Symbols):**
- Size: 20pt to 48pt
- Weight: Regular or Medium
- Rendering: Hierarchical with accent color
- Background: Optional circular or rounded square container

**3D Icons:**
```swift
struct Icon3D {
    var size: Float = 0.08        // 8cm
    var depth: Float = 0.02       // 2cm extrusion
    var material: Material = .glossy
    var animation: Animation = .none
}
```

**Common Icons:**
- Dashboard: Stacked layers
- Analytics: Rising bar chart
- People: Group of spheres
- Finance: Dollar sign ($)
- Settings: Gear
- Alerts: Exclamation mark

**Implementation:**
```swift
func create3DIcon(sfSymbol: String) -> ModelEntity {
    // Extrude SF Symbol path to 3D
    let symbolConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .medium)
    let symbolImage = UIImage(systemName: sfSymbol, withConfiguration: symbolConfig)

    // Generate mesh from symbol path
    let mesh = try! MeshResource.generate3DSymbol(
        from: symbolImage!,
        extrusionDepth: 0.02
    )

    var material = PhysicallyBasedMaterial()
    material.baseColor = .init(tint: .white)
    material.metallic = 0.8
    material.roughness = 0.2

    return ModelEntity(mesh: mesh, materials: [material])
}
```

---

## 9. User Flows and Navigation

### 9.1 App Launch Flow

```
┌─────────────────┐
│  Launch Screen  │
│  (BOS Logo)     │
└────────┬────────┘
         │ 2 seconds
         ▼
┌─────────────────┐
│ Authentication  │
│ (Biometric)     │
└────────┬────────┘
         │ Success
         ▼
┌─────────────────┐     ┌──────────────┐
│  Dashboard      │────▶│ First Time   │
│  (Main Window)  │     │ Tutorial     │
└────────┬────────┘     │ (Optional)   │
         │              └──────────────┘
         │ Auto-load data
         ▼
┌─────────────────┐
│  Ready State    │
│  - Data loaded  │
│  - Sync active  │
│  - All features │
│    available    │
└─────────────────┘
```

### 9.2 Primary Navigation Patterns

#### Tab-Based Navigation (2D Windows)

```swift
TabView(selection: $selectedTab) {
    DashboardView()
        .tabItem {
            Label("Dashboard", systemImage: "square.grid.2x2")
        }
        .tag(Tab.dashboard)

    DepartmentsView()
        .tabItem {
            Label("Departments", systemImage: "building.2")
        }
        .tag(Tab.departments)

    AnalyticsView()
        .tabItem {
            Label("Analytics", systemImage: "chart.xyaxis.line")
        }
        .tag(Tab.analytics)

    SettingsView()
        .tabItem {
            Label("Settings", systemImage: "gearshape")
        }
        .tag(Tab.settings)
}
```

#### Spatial Navigation (3D Space)

**Navigation Menu (Arm's Reach):**
- Floating radial menu
- 6-8 primary destinations
- Tap to teleport
- Pinch+drag to preview

**Breadcrumb Trail:**
- Shows navigation history
- Tap any breadcrumb to return
- Fades after 5 seconds

**Minimap:**
- Top-right corner (or overhead)
- Shows user position + orientation
- Tap to recenter
- Pinch to zoom

### 9.3 Department Drill-Down Flow

```
Dashboard
   │
   │ Tap "Engineering"
   ▼
Department Overview (2D Window)
   │
   │ Tap "View in 3D"
   ▼
Department Volume (3D Bounded)
   │
   │ Tap "Team Member"
   ▼
Employee Detail (2D Window)
   │
   │ Tap "Close"
   ▼
Department Volume
   │
   │ Swipe to dismiss
   ▼
Dashboard
```

### 9.4 Data Exploration Flow

```
High-Level Metrics (Dashboard)
   │
   │ Identify anomaly
   ▼
Drill Down (Tap metric)
   │
   ├─ Show related data
   ├─ Display trends
   └─ AI explanation
   │
   │ "Why?" (Voice command)
   ▼
Root Cause Analysis
   │
   ├─ Visualize contributing factors
   ├─ Show dependencies
   └─ Recommend actions
   │
   │ Select action
   ▼
Action Detail View
   │
   └─ Execute or schedule
```

---

## 10. Accessibility Design

### 10.1 Visual Accessibility

#### High Contrast Mode

```swift
@Environment(\.colorSchemeContrast) var colorSchemeContrast

var foregroundColor: Color {
    colorSchemeContrast == .increased ? .white : .primary
}

var backgroundColor: Color {
    colorSchemeContrast == .increased ? .black : Color(.systemBackground)
}
```

**Changes in High Contrast:**
- Remove transparency
- Thicken borders (1pt → 3pt)
- Increase color saturation
- Add texture to distinguish elements

#### Reduce Transparency

```swift
@Environment(\.accessibilityReduceTransparency) var reduceTransparency

var panelBackground: some View {
    if reduceTransparency {
        Color.black.opacity(0.95)
    } else {
        Material.ultraThinMaterial
    }
}
```

### 10.2 Motor Accessibility

#### Larger Hit Targets

```swift
// Minimum 60pt / 60mm for all interactive elements
.frame(minWidth: 60, minHeight: 60)
.contentShape(Rectangle())  // Extend hit area beyond visual bounds
```

#### Dwell Selection

```swift
// Enable selection by gazing for 1.5 seconds
.onContinuousHover { phase in
    if case .active = phase {
        startDwellTimer()
    } else {
        cancelDwellTimer()
    }
}

func startDwellTimer() {
    dwellTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { _ in
        selectEntity()
    }
}
```

#### Voice-Only Mode

- All functions accessible via voice
- No gestures required
- Visual confirmations for all commands

### 10.3 Cognitive Accessibility

#### Reduce Motion

```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

withAnimation(reduceMotion ? .none : .spring()) {
    // Animate or instantly update
}
```

**Changes:**
- Disable autoplay animations
- Crossfade instead of slide transitions
- Instant appear/disappear instead of scale
- Static backgrounds instead of particle effects

#### Simplified Mode

```swift
@AppStorage("simplifiedMode") var simplifiedMode = false

var dashboardContent: some View {
    if simplifiedMode {
        SimplifiedDashboardView()  // Fewer elements, larger text
    } else {
        StandardDashboardView()
    }
}
```

**Simplified Mode Features:**
- Fewer simultaneous elements
- Larger text and controls
- Removed peripheral information
- Linear navigation only

---

## 11. Error States and Loading Indicators

### 11.1 Loading States

#### Initial Data Load

```swift
struct DashboardView: View {
    @State private var isLoading = true

    var body: some View {
        if isLoading {
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.5)

                Text("Loading your business data...")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Material.ultraThinMaterial)
        } else {
            // Dashboard content
        }
    }
}
```

#### Incremental Loading (Pagination)

```swift
// Show skeleton placeholders while loading
ForEach(0..<10) { index in
    if index < loadedItems.count {
        ItemView(item: loadedItems[index])
    } else {
        SkeletonItemView()
            .onAppear {
                loadMoreItems()
            }
    }
}
```

#### Spatial Loading

```swift
// 3D entities appear with fade + scale animation
entity.isEnabled = false
entity.scale = [0.01, 0.01, 0.01]
entity.opacity = 0.0

// Animate in
entity.isEnabled = true
entity.scale.animate(to: [1, 1, 1], duration: 0.4, curve: .easeOut)
entity.opacity.animate(to: 1.0, duration: 0.3)
```

### 11.2 Error States

#### Network Error

```swift
struct NetworkErrorView: View {
    let error: NetworkError
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 60))
                .foregroundStyle(.red)

            Text("Connection Lost")
                .font(.title2.bold())

            Text(error.localizedDescription)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button("Try Again", action: retryAction)
                .buttonStyle(.borderedProminent)
        }
        .padding(40)
        .background(Material.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
```

#### Data Error

```swift
// Inline error for specific failed elements
struct DataErrorIndicator: View {
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)

            Text("Unable to load data")
                .font(.caption)

            Button("Retry") {
                // Retry action
            }
            .font(.caption.bold())
        }
        .padding(12)
        .background(.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
```

#### Empty State

```swift
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text(title)
                .font(.title2.bold())

            Text(message)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding(40)
    }
}

// Usage
EmptyStateView(
    icon: "tray",
    title: "No Departments",
    message: "Get started by adding your first department to organize your business.",
    actionTitle: "Add Department",
    action: { showAddDepartment() }
)
```

### 11.3 Spatial Error Indicators

```swift
// Entity that failed to load
func showErrorIndicator(at position: SIMD3<Float>) {
    let errorEntity = Entity()

    // Red pulsing sphere
    var errorMesh = MeshResource.generateSphere(radius: 0.05)
    var errorMaterial = PhysicallyBasedMaterial()
    errorMaterial.baseColor = .init(tint: .red)
    errorMaterial.emissiveColor = .init(color: .red)
    errorMaterial.emissiveIntensity = 5.0

    errorEntity.components.set(ModelComponent(
        mesh: errorMesh,
        materials: [errorMaterial]
    ))

    errorEntity.position = position

    // Pulsing animation
    animatePulse(errorEntity)

    // Tap to see error details
    errorEntity.components.set(InputTargetComponent())

    content.add(errorEntity)
}
```

---

## 12. Animation and Transition Specifications

### 12.1 Timing Functions

```swift
// Easing curves
struct Easing {
    static let `default` = Animation.easeInOut(duration: 0.3)
    static let quick = Animation.easeOut(duration: 0.2)
    static let smooth = Animation.spring(response: 0.5, dampingFraction: 0.7)
    static let bouncy = Animation.spring(response: 0.6, dampingFraction: 0.6)
    static let gentle = Animation.easeInOut(duration: 0.5)
}
```

### 12.2 Common Animations

#### Appear/Disappear

```swift
// Fade + scale
.transition(.asymmetric(
    insertion: .scale(scale: 0.8).combined(with: .opacity),
    removal: .scale(scale: 1.2).combined(with: .opacity)
))
.animation(.spring(response: 0.4, dampingFraction: 0.8), value: isPresented)
```

#### Slide In/Out

```swift
.transition(.move(edge: .trailing).combined(with: .opacity))
.animation(.easeInOut(duration: 0.3), value: isPresented)
```

#### Morph Between States

```swift
// Number counter animation
Text("\(animatedValue, specifier: "%.1f")")
    .font(.system(size: 48, design: .rounded).monospacedDigit())
    .contentTransition(.numericText(value: animatedValue))
    .animation(.easeInOut(duration: 0.6), value: animatedValue)
```

### 12.3 Spatial Animations

#### Entity Movement

```swift
// Smooth movement along bezier curve
func moveEntity(_ entity: Entity, to target: SIMD3<Float>) {
    let startPos = entity.position
    let controlPoint1 = startPos + [0, 0.5, 0]  // Arc upward
    let controlPoint2 = target + [0, 0.5, 0]

    entity.position.animate(
        to: target,
        duration: 1.0,
        curve: .bezier(p1: controlPoint1, p2: controlPoint2)
    )
}
```

#### Data Update Animation

```swift
// Bar chart value update
func animateBarHeight(from oldValue: Float, to newValue: Float) {
    let duration = 0.6

    // Smooth height transition
    barEntity.scale.y.animate(
        to: newValue,
        duration: duration,
        curve: .easeInOut
    )

    // Subtle bounce at end
    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
        barEntity.scale.y.animate(
            to: newValue * 1.05,
            duration: 0.1,
            curve: .easeOut
        )
        barEntity.scale.y.animate(
            to: newValue,
            duration: 0.1,
            delay: 0.1,
            curve: .easeIn
        )
    }
}
```

#### Particle Systems

```swift
// Celebrate milestone achievement
func celebrateAchievement(at position: SIMD3<Float>) {
    let particleEmitter = ParticleEmitterComponent()
    particleEmitter.emitterShape = .sphere
    particleEmitter.birthRate = 100
    particleEmitter.lifetime = 2.0
    particleEmitter.speed = 0.5
    particleEmitter.color = .evolving(start: .green, end: .yellow)
    particleEmitter.size = .evolving(start: 0.01, end: 0.0)

    let entity = Entity()
    entity.position = position
    entity.components.set(particleEmitter)

    content.add(entity)

    // Remove after animation
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
        entity.removeFromParent()
    }
}
```

### 12.4 Transition Guidelines

**Duration Ranges:**
- Micro: 100-150ms (button press feedback)
- Quick: 200-300ms (modal appear/disappear)
- Standard: 300-500ms (page transitions)
- Slow: 500-800ms (complex state changes)
- Cinematic: 800-1200ms (first-time experiences)

**Reduce Motion Overrides:**
- All animations >300ms should be instant if `reduceMotion` is enabled
- Keep micro-interactions (<200ms) as they aid usability

---

## Conclusion

This design specification provides comprehensive guidance for creating a cohesive, intuitive, and beautiful spatial computing experience for the Business Operating System. Key design principles:

1. **Spatial Memory:** Consistent positioning builds intuitive navigation
2. **Natural Interactions:** Gestures match real-world expectations
3. **Visual Clarity:** High contrast, readable typography, meaningful color
4. **Accessibility First:** Every user can access all functionality
5. **Performance:** Smooth 90 FPS animations and interactions
6. **Delight:** Thoughtful animations and feedback create joy

Adherence to these specifications ensures a world-class visionOS application that transforms how businesses operate.
