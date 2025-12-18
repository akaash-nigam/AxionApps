# Spatial ERP - Design Specifications

## Table of Contents
1. [Design Philosophy](#design-philosophy)
2. [Spatial Design Principles](#spatial-design-principles)
3. [Window Layouts & Configurations](#window-layouts--configurations)
4. [Volume Designs](#volume-designs)
5. [Immersive Space Experiences](#immersive-space-experiences)
6. [3D Visualization Specifications](#3d-visualization-specifications)
7. [Interaction Patterns](#interaction-patterns)
8. [Visual Design System](#visual-design-system)
9. [User Flows & Navigation](#user-flows--navigation)
10. [Accessibility Design](#accessibility-design)
11. [Error States & Loading Indicators](#error-states--loading-indicators)
12. [Animation & Transitions](#animation--transitions)

---

## Design Philosophy

### Core Principles

**1. Enterprise Meets Spatial**
- Professional aesthetics with spatial depth
- Business-appropriate color palette and typography
- Sophisticated interactions that respect enterprise context

**2. Information Density with Clarity**
- Maximum insight with minimum cognitive load
- Progressive disclosure of complex data
- Hierarchical organization using depth and space

**3. Natural Business Operations**
- Interactions mirror real-world business processes
- Spatial metaphors that make sense to executives
- Gestures that feel intuitive in operational context

**4. Performance First**
- Smooth 90 FPS even with dense data
- Instant feedback for all interactions
- Optimized rendering for complex visualizations

**5. Accessibility as Standard**
- VoiceOver support for all features
- Multiple interaction modalities
- High contrast and clarity throughout

---

## Spatial Design Principles

### Depth & Layering Strategy

```
Z-Axis Layout (Distance from User)

┌────────────────────────────────────────────────────────────┐
│  0.5m - 1.0m: Transaction Zone                             │
│  • Input forms                                              │
│  • Approval buttons                                         │
│  • Quick actions                                            │
│  • Detailed data entry                                      │
├────────────────────────────────────────────────────────────┤
│  1.0m - 2.0m: Process Zone                                  │
│  • Workflows and process flows                              │
│  • Interactive charts and graphs                            │
│  • Real-time monitoring dashboards                          │
│  • Operational controls                                     │
├────────────────────────────────────────────────────────────┤
│  2.0m - 5.0m: Strategic Zone                                │
│  • Executive dashboards                                     │
│  • High-level KPIs                                          │
│  • Strategic planning views                                 │
│  • Enterprise overview                                      │
└────────────────────────────────────────────────────────────┘
```

### Spatial Ergonomics

**Viewing Angles**
- **Primary Content**: 0° to -15° (slightly below eye level)
- **Secondary Content**: -15° to -30°
- **Tertiary/Background**: -30° to -45°
- **Avoid**: Above +10° (neck strain)

**Comfortable Reach Zones**
- **Immediate**: 0.3m - 0.6m (high-frequency interactions)
- **Comfortable**: 0.6m - 1.2m (normal interactions)
- **Extended**: 1.2m - 2.0m (occasional interactions)
- **Visual Only**: 2.0m+ (no direct manipulation)

### Spatial Grid System

```
┌─────────────────────────────────────────────────────────────┐
│                    Spatial Grid (meters)                     │
│                                                              │
│  Horizontal: 0.2m increments (minimum spacing)               │
│  Vertical: 0.15m increments (accounting for angle)           │
│  Depth: 0.3m increments (comfortable focal shifts)           │
│                                                              │
│  Safe Zone: 1.5m wide × 1.2m tall × 2.0m deep                │
│  (Assuming user is seated or standing in center)             │
└─────────────────────────────────────────────────────────────┘
```

---

## Window Layouts & Configurations

### Dashboard Window (Primary)

**Dimensions**: 1400 × 900 points
**Position**: Center, -10° below eye level
**Distance**: 1.2 meters from user

```
┌─────────────────────────────────────────────────────────────┐
│  ╔═══════════════════════════════════════════════════════╗  │
│  ║              Spatial ERP - Dashboard                  ║  │
│  ╚═══════════════════════════════════════════════════════╝  │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Today • Q4 2024 • Enterprise View        [Settings] │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                              │
│  ┌──────────┬──────────┬──────────┬──────────┐              │
│  │ Revenue  │ Profit   │ Orders   │ Inventory│              │
│  │ $4.2M    │ $890K    │ 1,247    │ 94% ✓    │              │
│  │ ▲ 12.3%  │ ▲ 8.1%   │ ▼ 2.4%   │ ▲ 3.2%   │              │
│  │ [Chart]  │ [Chart]  │ [Chart]  │ [Chart]  │              │
│  └──────────┴──────────┴──────────┴──────────┘              │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  Critical Alerts                               [3]  │    │
│  ├─────────────────────────────────────────────────────┤    │
│  │  🔴 Production Line B - Bottleneck Detected         │    │
│  │  🟡 Q4 Budget Variance - Finance Review Required    │    │
│  │  🟡 Supplier X - Delivery Delay Expected            │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
│  ┌──────────────┬──────────────┬────────────────────────┐   │
│  │  Financial   │  Operations  │  Supply Chain          │   │
│  │  Analysis    │  Center      │  Network               │   │
│  │  [Launch]    │  [Launch]    │  [Launch]              │   │
│  └──────────────┴──────────────┴────────────────────────┘   │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

**Components**:
1. **Header Bar**: App title, context (date/period), settings
2. **KPI Cards**: 4 primary metrics with sparklines
3. **Alerts Panel**: Critical items requiring attention
4. **Quick Launch**: Access to specialized views/spaces

**Glass Material**: `.ultraThinMaterial` with 90% opacity
**Corner Radius**: 32 points
**Shadow**: Soft, diffused (0.1m depth)

---

### Financial Analysis Window

**Dimensions**: 1200 × 800 points
**Position**: -30° horizontal offset (left side)
**Distance**: 1.5 meters from user

```
┌───────────────────────────────────────────────────────────┐
│  ╔═══════════════════════════════════════════════════╗   │
│  ║         Financial Analysis - Q4 2024               ║   │
│  ╚═══════════════════════════════════════════════════╝   │
│                                                           │
│  ┌─────────────────────────────────────────────────────┐ │
│  │  P&L Statement        YTD Actual    Budget   Var%   │ │
│  ├─────────────────────────────────────────────────────┤ │
│  │  Revenue              $42.3M       $40.0M   +5.8%   │ │
│  │  Cost of Sales        $28.4M       $26.5M   +7.2%   │ │
│  │  Gross Profit         $13.9M       $13.5M   +3.0%   │ │
│  │  Operating Exp        $8.2M        $8.0M    +2.5%   │ │
│  │  EBITDA              $5.7M        $5.5M    +3.6%   │ │
│  │  Net Income          $3.8M        $3.7M    +2.7%   │ │
│  └─────────────────────────────────────────────────────┘ │
│                                                           │
│  ┌────────────────────────────────────┐                  │
│  │   Revenue Trend (12 Months)        │                  │
│  │                                     │                  │
│  │   [Interactive Line Chart]          │                  │
│  │                                     │                  │
│  └────────────────────────────────────┘                  │
│                                                           │
│  ┌──────────────┬──────────────┬────────────────┐        │
│  │ Cost Center  │ Cash Flow    │ Budget Drill   │        │
│  │ Analysis     │ Forecast     │ Down           │        │
│  └──────────────┴──────────────┴────────────────┘        │
│                                                           │
└───────────────────────────────────────────────────────────┘
```

**Typography**:
- Title: SF Pro Display, 28pt, Semibold
- Section Headers: SF Pro Text, 18pt, Medium
- Data Labels: SF Pro Text, 14pt, Regular
- Numeric Data: SF Mono, 16pt, Medium

**Colors**:
- Positive Variance: Green (#00C853)
- Negative Variance: Red (#D32F2F)
- Neutral: Gray (#757575)
- Background: Glass with subtle tint

---

## Volume Designs

### Operations Volume (3D Factory Floor)

**Dimensions**: 1.5m × 1.2m × 1.5m (W×H×D)
**Position**: Front-center, arm's reach
**Scale**: 1:100 (real-world to virtual)

```
                Top View
    ┌─────────────────────────────┐
    │                             │
    │   🏭                  🏭    │
    │  Line A              Line C │
    │   ▓▓▓                ▓▓▓    │
    │                             │
    │         🏭                  │
    │        Line B               │
    │         ▓▓▓                 │
    │                             │
    │                             │
    │   📦 ← ← ← ← ← ← ← 📦      │
    │  Storage          Shipping  │
    │                             │
    └─────────────────────────────┘

        Side View (Depth Layers)
    ┌─────────────────────────────┐
    │  Equipment (Layer 1)         │
    │  ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀            │
    │                              │
    │  Workflows (Layer 2)         │
    │  ≈≈≈≈≈≈≈≈≈≈≈≈≈≈             │
    │                              │
    │  Metrics (Layer 3)           │
    │  ━━━━━━━━━━━━━━             │
    └─────────────────────────────┘
```

**3D Elements**:

1. **Production Lines** (Equipment)
   - Geometry: Low-poly machinery models
   - Material: Metallic with PBR textures
   - Animation: Rotating components when active
   - Status Indicators: Colored halos (green/yellow/red)

2. **Material Flows** (Workflows)
   - Geometry: Particle streams
   - Material: Glowing particles, semi-transparent
   - Animation: Flow direction, speed varies by throughput
   - Color: Gradient based on material type

3. **Status Metrics** (Floating Labels)
   - Position: Above each workstation
   - Content: OEE%, Current Output, Target
   - Material: Glass background with text
   - Behavior: Billboard (always face user)

**Interactions**:
- **Tap**: Select line/equipment, show details
- **Pinch + Drag**: Rotate entire volume
- **Two-Finger Scale**: Zoom in/out
- **Long Press**: Bring up context menu

**Performance Indicators**:
```swift
// Color coding for status
enum OperationalStatus {
    case optimal    // Green (#4CAF50)
    case warning    // Yellow (#FFC107)
    case critical   // Red (#F44336)
    case offline    // Gray (#9E9E9E)
}

// Visual representation
- Optimal: Smooth particle flow, bright green glow
- Warning: Choppy flow, pulsing yellow
- Critical: Stopped flow, flashing red
- Offline: No flow, muted gray
```

---

### Supply Chain Galaxy Volume

**Dimensions**: 2.0m × 1.5m × 2.0m (larger for global view)
**Position**: Front-left, strategic zone
**Scale**: World map with node overlay

```
         Front View - Supply Chain Galaxy
    ┌───────────────────────────────────────┐
    │                                       │
    │         ⭐ (Supplier A)               │
    │        /│\                            │
    │       / │ \                           │
    │      /  │  \       ⭐ (Supplier B)    │
    │     /   │   \      │                  │
    │    🏭───┼────🏭───┤                   │
    │  (Plant)(HQ)(Plant)│                   │
    │         │          │                  │
    │         │     ⭐───┘                  │
    │         │   (Supplier C)              │
    │         │                             │
    │    📦──────📦                         │
    │  (Warehouse)(Distribution)            │
    │                                       │
    └───────────────────────────────────────┘
```

**3D Elements**:

1. **Supplier Nodes** (Stars)
   - Geometry: Sphere with corona effect
   - Size: Proportional to volume
   - Color: Rating-based (green to red gradient)
   - Pulsing: Activity level

2. **Facilities** (Planets/Buildings)
   - Geometry: Building icons or simple 3D models
   - Material: Glass with company colors
   - Label: Name and key metrics
   - Orbiting: Inventory levels (smaller spheres)

3. **Logistics Routes** (Connecting Lines)
   - Geometry: Bezier curves in 3D
   - Material: Animated dashed lines
   - Width: Proportional to volume
   - Color: On-time (green) vs delayed (red)
   - Animation: Flow direction and speed

4. **Inventory Indicators**
   - Position: Orbiting facilities
   - Size: Proportional to stock level
   - Color: Heat map (blue=low, red=high)
   - Behavior: Slow rotation around parent

**Interactions**:
- **Gaze + Pinch**: Select node/route
- **Tap on Node**: Expand details panel
- **Drag Route**: Simulate alternative logistics
- **Pinch on Star**: Filter by supplier

---

## Immersive Space Experiences

### Operations Command Center (Full Immersive)

**Environment**: 360° operational overview
**Mode**: Mixed or Full immersion
**Layout**: Radial arrangement around user

```
                   Top-Down View

             Strategic Dashboard
                    ┌───┐
                    │ ⬆ │
                    └───┘
                      │
    Production    ────●────    Financial
      View             │         Analysis
      ┌──┐            👤           ┌──┐
      │⬅ │                        │ ➡│
      └──┘                        └──┘
                      │
                   ┌──┐
                   │⬇ │
                   └──┘
              Supply Chain
                Network
```

**Spatial Arrangement**:

**Front (0°)**: Strategic Dashboard
- Position: 2.5m away, eye level
- Size: 3m wide × 2m tall
- Content: Enterprise KPIs, critical alerts
- Always visible, primary focus

**Right (90°)**: Financial Analysis
- Position: 2m away, slightly below eye level
- Size: 2.5m wide × 2m tall
- Content: Real-time financial data, P&L
- Turn right to view

**Back (180°)**: Historical Data / Reports
- Position: 2m away
- Size: 2m wide × 1.5m tall
- Content: Historical trends, archives
- Turn around to view

**Left (270°)**: Operations & Production
- Position: 2m away
- Size: 2.5m wide × 2m tall
- Content: Factory floor, production lines
- Turn left to view

**Floor Level**: Supply Chain Network
- Position: Below, 45° down
- Size: 4m diameter circle
- Content: Global network map
- Look down to view

**Ceiling Level**: Organizational Structure
- Position: Above, 30° up
- Size: 3m diameter circle
- Content: Org chart, resource allocation
- Look up to view (limited time)

**Center Console** (Arm's reach)
- Position: 0.6m away, waist level
- Size: 0.8m wide × 0.5m tall
- Content: Quick actions, filters, period selector
- Always accessible

**Navigation**:
- **Head Rotation**: Natural view switching
- **Gesture**: Swipe to rotate environment
- **Voice**: "Show financial" / "Show operations"
- **Minimap**: Small compass for orientation

**Collaboration Mode**:
- Multiple users share same space
- Avatars show position and gaze direction
- Shared cursor for pointing/annotation
- Spatial audio for voice communication
- Each user can have private side panels

---

### Financial Universe (Full Immersive)

**Theme**: Business data as cosmic landscape
**Metaphor**: Navigate through financial dimensions

```
       Side View - Financial Universe

    ┌─────────────────────────────────────┐
    │         ☀️ (Revenue Sun)            │
    │           │                          │
    │           │                          │
    │     ●─────●─────●                    │
    │  (Q1)   (Q2)  (Q3)  (Q4)             │
    │   Cost Centers as Planets            │
    │                                      │
    │    💰          💰         💰         │
    │  Cash       Budget     Forecast      │
    │  Flows      Mountains  Nebula        │
    │                                      │
    │                                      │
    │  ─────────────────────────           │
    │  P&L Baseline (Ground Plane)         │
    └─────────────────────────────────────┘
```

**Elements**:

**Revenue Streams** (Rivers/Waterfalls)
- Geometry: Flowing particle systems
- Direction: High to low (downhill)
- Width: Proportional to amount
- Color: Category-based gradient
- Sound: Gentle water flow

**Cost Centers** (Planetary Systems)
- Geometry: Spheres with rings
- Size: Budget size
- Color: Variance (green/red gradient)
- Orbit: Sub-departments
- Interaction: Tap to explore

**Profit Margins** (Mountain Ranges)
- Geometry: Terrain mesh
- Height: Profit level
- Color: Altitude-based gradient
- Valleys: Loss periods
- Peaks: High-profit periods

**Cash Position** (Ocean Level)
- Geometry: Flat water plane
- Height: Current cash level
- Movement: Gentle waves
- Color: Blue (healthy) to red (low)
- Rising/Falling: Real-time changes

**Budget Variance** (Weather Systems)
- Geometry: Particle clouds
- Type: Rain (overspend), Sun (under-budget)
- Position: Above cost centers
- Intensity: Variance magnitude
- Animation: Dynamic weather effects

**Interactions**:
- **Walk Through**: Navigate financial landscape
- **Reach Out**: Grab and examine elements
- **Dive Into**: Zoom into cost centers
- **Timeline**: Scrub through periods

---

## 3D Visualization Specifications

### Data-to-Visual Mapping Rules

#### Quantitative Data
```swift
// Size Mapping
func size(for value: Double, range: ClosedRange<Double>) -> Float {
    let normalized = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
    return Float(0.1 + (normalized * 0.5)) // 0.1m to 0.6m
}

// Color Mapping (Heatmap)
func color(for value: Double, range: ClosedRange<Double>) -> UIColor {
    let normalized = (value - range.lowerBound) / (range.upperBound - range.lowerBound)

    // Blue (low) → Yellow (mid) → Red (high)
    if normalized < 0.5 {
        return UIColor.interpolate(from: .systemBlue, to: .systemYellow, progress: normalized * 2)
    } else {
        return UIColor.interpolate(from: .systemYellow, to: .systemRed, progress: (normalized - 0.5) * 2)
    }
}

// Height/Elevation Mapping
func elevation(for value: Double, max: Double) -> Float {
    return Float((value / max) * 1.5) // Max 1.5m tall
}
```

#### Categorical Data
```swift
// Shape Mapping
enum EntityShape {
    case cube      // Buildings, facilities
    case sphere    // Suppliers, vendors
    case cylinder  // Equipment, machinery
    case cone      // Alerts, issues
    case pyramid   // Goals, targets
}

// Color Mapping (Category)
let categoryColors: [String: UIColor] = [
    "Finance": UIColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0),
    "Operations": UIColor(red: 0.8, green: 0.4, blue: 0.2, alpha: 1.0),
    "Supply Chain": UIColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 1.0),
    "HR": UIColor(red: 0.8, green: 0.2, blue: 0.8, alpha: 1.0)
]
```

#### Temporal Data
```swift
// Animation Speed (Rate of Change)
func animationSpeed(for changeRate: Double) -> TimeInterval {
    // Faster animation = higher rate of change
    return 1.0 / max(changeRate, 0.1)
}

// Timeline Visualization
// Position on circular timeline (360° = 1 year)
func timelineAngle(for date: Date, year: Int) -> Float {
    let calendar = Calendar.current
    let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
    return Float(dayOfYear) * (360.0 / 365.0) * .pi / 180.0
}
```

### 3D Asset Specifications

**Low-Poly Models** (Distance LOD)
- **LOD 0** (0-2m): 5,000-10,000 triangles
- **LOD 1** (2-5m): 1,000-5,000 triangles
- **LOD 2** (5m+): 500-1,000 triangles

**Texture Specifications**
- **Resolution**: 1024×1024 (LOD 0), 512×512 (LOD 1), 256×256 (LOD 2)
- **Format**: PNG with alpha for UI, USDZ for 3D
- **Compression**: ASTC for textures
- **Maps**: Albedo, Normal, Metallic, Roughness

**Materials** (PBR)
```swift
var businessGlassMaterial: PhysicallyBasedMaterial {
    var material = PhysicallyBasedMaterial()
    material.baseColor = .init(tint: .white.withAlphaComponent(0.1))
    material.metallic = 0.0
    material.roughness = 0.1
    material.blending = .transparent(opacity: 0.3)
    return material
}

var metricGlowMaterial: UnlitMaterial {
    var material = UnlitMaterial()
    material.color = .init(tint: .systemBlue)
    material.blending = .transparent(opacity: 0.7)
    return material
}
```

---

## Interaction Patterns

### Primary Interactions

#### Selection
```
Pattern: Gaze + Pinch (Indirect) or Direct Tap
Visual Feedback:
  1. Hover: Subtle scale (1.0 → 1.05) + soft glow
  2. Select: Scale pulse (1.05 → 1.1 → 1.05) + highlight
  3. Active: Persistent highlight + connected UI
Audio: Soft click (50ms, -20dB)
```

#### Manipulation
```
Pattern: Pinch + Drag
Visual Feedback:
  1. Grab: Entity becomes semi-transparent (70% opacity)
  2. Move: Follow hand with smooth interpolation
  3. Snap: Grid lines appear, snap to points
  4. Release: Fade back to full opacity
Audio: Grab tone (100ms), release tone (80ms)
```

#### Navigation
```
Pattern: Look + Walk (in immersive) or Swipe (in window)
Visual Feedback:
  1. Look: UI fades in direction of gaze
  2. Transition: Smooth movement with motion blur
  3. Arrival: Fade in new content
Animation: Ease-in-out, 300ms duration
```

### Business-Specific Interactions

#### Approve Transaction
```
Gesture: Two thumbs up
Process:
  1. Detect gesture
  2. Show confirmation prompt
  3. User confirms with tap or voice
  4. Execute approval
  5. Visual: Green checkmark animation
  6. Audio: Success chime
```

#### Drill-Down Analysis
```
Gesture: Pinch on element + pull towards self
Process:
  1. Element enlarges and moves forward
  2. Background dims (focus mode)
  3. Detailed panel appears
  4. Related metrics highlight
Visual: Zoom transition with depth-of-field
```

#### Compare Metrics
```
Gesture: Select two elements, bring hands together
Process:
  1. Both elements highlight
  2. Comparison panel appears
  3. Side-by-side visualization
  4. Difference metrics calculated
Visual: Elements connect with line, share space
```

#### Time Scrubbing
```
Gesture: Horizontal swipe in air or on timeline
Process:
  1. Timeline appears (if not visible)
  2. Date indicator follows hand
  3. Data updates in real-time
  4. Stop to lock on period
Visual: Timeline with playhead, smooth data transitions
```

---

## Visual Design System

### Color Palette

#### Primary Colors
```swift
struct BrandColors {
    // Primary Brand
    static let primary = Color(red: 0.0, green: 0.45, blue: 0.90)      // #0073E6 Blue
    static let primaryDark = Color(red: 0.0, green: 0.35, blue: 0.70)  // #0059B3
    static let primaryLight = Color(red: 0.2, green: 0.55, blue: 1.0)  // #338CFF

    // Secondary
    static let secondary = Color(red: 0.3, green: 0.3, blue: 0.3)      // #4D4D4D Gray
    static let accent = Color(red: 0.95, green: 0.6, blue: 0.0)        // #F29900 Orange
}
```

#### Semantic Colors
```swift
struct SemanticColors {
    // Status
    static let success = Color(red: 0.0, green: 0.6, blue: 0.2)        // #009933 Green
    static let warning = Color(red: 0.95, green: 0.6, blue: 0.0)       // #F29900 Orange
    static let error = Color(red: 0.8, green: 0.0, blue: 0.0)          // #CC0000 Red
    static let info = Color(red: 0.0, green: 0.45, blue: 0.90)         // #0073E6 Blue

    // Data Visualization
    static let positive = Color(red: 0.0, green: 0.8, blue: 0.3)       // #00CC4D
    static let negative = Color(red: 0.9, green: 0.0, blue: 0.0)       // #E60000
    static let neutral = Color(red: 0.5, green: 0.5, blue: 0.5)        // #808080
}
```

#### Gradient Mappings
```swift
// Performance Gradient (Bad → Good)
let performanceGradient = Gradient(colors: [
    Color(red: 0.8, green: 0.0, blue: 0.0),    // Red (0%)
    Color(red: 0.95, green: 0.6, blue: 0.0),   // Orange (50%)
    Color(red: 0.95, green: 0.8, blue: 0.0),   // Yellow (75%)
    Color(red: 0.0, green: 0.8, blue: 0.3)     // Green (100%)
])

// Financial Health Gradient
let financialGradient = Gradient(colors: [
    Color(red: 0.2, green: 0.2, blue: 0.8),    // Deep Blue (low)
    Color(red: 0.0, green: 0.6, blue: 0.8),    // Cyan (medium)
    Color(red: 0.0, green: 0.8, blue: 0.4)     // Green (high)
])
```

### Typography

#### Font System
```swift
// Primary Font: SF Pro (System)
struct Typography {
    // Display
    static let displayLarge = Font.system(size: 48, weight: .bold, design: .default)
    static let displayMedium = Font.system(size: 36, weight: .semibold, design: .default)
    static let displaySmall = Font.system(size: 28, weight: .medium, design: .default)

    // Headlines
    static let headlineLarge = Font.system(size: 24, weight: .semibold, design: .default)
    static let headlineMedium = Font.system(size: 20, weight: .medium, design: .default)
    static let headlineSmall = Font.system(size: 18, weight: .medium, design: .default)

    // Body
    static let bodyLarge = Font.system(size: 17, weight: .regular, design: .default)
    static let bodyMedium = Font.system(size: 15, weight: .regular, design: .default)
    static let bodySmall = Font.system(size: 13, weight: .regular, design: .default)

    // Labels
    static let labelLarge = Font.system(size: 14, weight: .medium, design: .default)
    static let labelMedium = Font.system(size: 12, weight: .medium, design: .default)
    static let labelSmall = Font.system(size: 10, weight: .medium, design: .default)

    // Numeric (Monospaced)
    static let numericLarge = Font.system(size: 20, weight: .medium, design: .monospaced)
    static let numericMedium = Font.system(size: 16, weight: .medium, design: .monospaced)
    static let numericSmall = Font.system(size: 14, weight: .regular, design: .monospaced)
}
```

#### Text in 3D Space
```swift
// Billboard Text (Always faces user)
entity.components.set(BillboardComponent())

// Spatial Text Sizing (based on distance)
func textScale(forDistance distance: Float) -> Float {
    // Maintain apparent size regardless of distance
    return distance * 0.01 // Scale factor
}

// Text Material
var text3DMaterial: UnlitMaterial {
    var material = UnlitMaterial()
    material.color = .init(tint: .white)
    material.blending = .transparent(opacity: 0.95)
    return material
}
```

### Iconography

#### Icon Specifications
- **Size**: 44×44 pt minimum (touch target)
- **Style**: SF Symbols when available
- **Weight**: Medium (default), Bold (emphasis)
- **Rendering**: Template for tinting
- **3D**: Depth extrusion of 0.01m for spatial icons

#### Icon Usage
```swift
struct Icons {
    // Navigation
    static let dashboard = Image(systemName: "square.grid.2x2")
    static let financial = Image(systemName: "dollarsign.circle")
    static let operations = Image(systemName: "gearshape.2")
    static let supplyChain = Image(systemName: "shippingbox")

    // Actions
    static let approve = Image(systemName: "checkmark.circle.fill")
    static let reject = Image(systemName: "xmark.circle.fill")
    static let edit = Image(systemName: "pencil.circle")
    static let delete = Image(systemName: "trash")

    // Status
    static let success = Image(systemName: "checkmark.circle.fill")
    static let warning = Image(systemName: "exclamationmark.triangle.fill")
    static let error = Image(systemName: "xmark.octagon.fill")
    static let info = Image(systemName: "info.circle.fill")
}
```

### Materials & Lighting

#### Glass Materials
```swift
// Heavy Glass (Primary Windows)
let heavyGlass = Material.glass(
    opacity: 0.9,
    blur: .heavy,
    tint: Color.white.opacity(0.05)
)

// Medium Glass (Secondary Panels)
let mediumGlass = Material.glass(
    opacity: 0.85,
    blur: .medium,
    tint: Color.white.opacity(0.03)
)

// Light Glass (Overlays)
let lightGlass = Material.glass(
    opacity: 0.7,
    blur: .light,
    tint: Color.white.opacity(0.01)
)
```

#### Lighting Setup
```swift
// Environment Lighting
func setupLighting(in scene: Scene) {
    // Image-based lighting
    let environment = EnvironmentResource.skybox("BusinessOffice")
    scene.lighting.resource = environment
    scene.lighting.intensityExponent = 1.2

    // Key Light (Simulates office lighting)
    let keyLight = DirectionalLight()
    keyLight.light.color = .white
    keyLight.light.intensity = 1000
    keyLight.look(at: [0, 0, 0], from: [2, 3, 2], relativeTo: nil)

    // Fill Light (Softer, from opposite)
    let fillLight = DirectionalLight()
    fillLight.light.color = .white
    fillLight.light.intensity = 300
    fillLight.look(at: [0, 0, 0], from: [-1, 1, -1], relativeTo: nil)

    scene.addChild(keyLight)
    scene.addChild(fillLight)
}
```

---

## User Flows & Navigation

### Primary User Flow: Daily Operations Check

```
┌──────────────────────────────────────────────────────────┐
│ 1. Launch App                                             │
│    • App opens to Dashboard Window                        │
│    • Loads latest KPIs and alerts                         │
│    • Duration: 2 seconds                                  │
└──────────────┬───────────────────────────────────────────┘
               │
               ▼
┌──────────────────────────────────────────────────────────┐
│ 2. Review KPIs                                            │
│    • Scan 4 primary metrics                               │
│    • Identify anomalies (color-coded)                     │
│    • Duration: 10-15 seconds                              │
└──────────────┬───────────────────────────────────────────┘
               │
               ▼
┌──────────────────────────────────────────────────────────┐
│ 3. Check Alerts                                           │
│    • Review critical alerts (if any)                      │
│    • Tap alert to see details                             │
│    • Duration: 5-30 seconds (depending on alerts)         │
└──────────────┬───────────────────────────────────────────┘
               │
          Decision Point
               │
     ┌─────────┴─────────┐
     │                   │
     ▼                   ▼
┌─────────┐         ┌──────────┐
│ Require │         │   All    │
│ Action? │         │ Clear?   │
└────┬────┘         └────┬─────┘
     │                   │
     ▼                   ▼
┌──────────────┐    ┌──────────────┐
│ 4a. Drill    │    │ 4b. Continue │
│    Into Issue│    │    Operations│
└──────────────┘    └──────────────┘
```

### Navigation Hierarchy

```
Dashboard (Home)
├─ Financial Analysis
│  ├─ P&L Statement
│  ├─ Balance Sheet
│  ├─ Cash Flow
│  └─ Cost Centers
│     └─ Department Details
├─ Operations Center [Immersive]
│  ├─ Production Overview [Volume]
│  ├─ Equipment Monitoring
│  ├─ Quality Metrics
│  └─ Scheduling
├─ Supply Chain
│  ├─ Inventory Management
│  ├─ Supplier Network [Volume]
│  ├─ Logistics Tracking
│  └─ Procurement
└─ Settings & Admin
   ├─ User Preferences
   ├─ Data Sources
   ├─ Security Settings
   └─ System Configuration
```

### Transition Animations

**Window to Window**
```swift
.transition(.asymmetric(
    insertion: .scale.combined(with: .opacity),
    removal: .opacity
))
.animation(.spring(duration: 0.4), value: isPresented)
```

**Window to Volume**
```swift
// Window fades, volume expands from center
.transition(.scale(scale: 0.1).combined(with: .opacity))
.animation(.spring(duration: 0.6, bounce: 0.3), value: isPresented)
```

**Volume to Immersive Space**
```swift
// Smooth zoom into immersive environment
.transition(.opacity)
.animation(.easeInOut(duration: 1.0), value: immersionState)
```

---

## Accessibility Design

### VoiceOver Navigation

**Element Labeling**
```swift
// Descriptive labels for all interactive elements
Button(action: approveTransaction) {
    Image(systemName: "checkmark.circle")
}
.accessibilityLabel("Approve transaction 1247 for $12,450")
.accessibilityHint("Double tap to approve this purchase order")
.accessibilityValue("Requires CFO approval")

// Group related elements
HStack {
    Text("Revenue")
    Text("$4.2M")
    Text("+12.3%")
}
.accessibilityElement(children: .combine)
.accessibilityLabel("Revenue 4.2 million dollars, up 12.3 percent")
```

**Spatial Audio Feedback**
```swift
// Use spatial audio to indicate element positions
func playAccessibilitySound(for element: Entity, in space: ImmersiveSpace) {
    let position = element.position(relativeTo: nil)
    spatialAudioManager.playTone(at: position, frequency: 440, duration: 0.1)
}
```

### High Contrast Mode

```swift
@Environment(\.accessibilityContrast) var contrast

var foregroundColor: Color {
    contrast == .high ? .black : Color(white: 0.2)
}

var backgroundColor: Color {
    contrast == .high ? .white : Color(white: 0.95)
}

// Increase border thickness
var borderWidth: CGFloat {
    contrast == .high ? 3 : 1
}
```

### Reduced Motion

```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

var animationDuration: Double {
    reduceMotion ? 0.01 : 0.3
}

var transitionAnimation: Animation {
    reduceMotion ? .none : .spring(duration: 0.3)
}

// Disable particle effects
var showParticles: Bool {
    !reduceMotion
}
```

---

## Error States & Loading Indicators

### Loading States

#### Initial Load
```
┌─────────────────────────────────────────┐
│                                          │
│          [Animated Logo]                 │
│                                          │
│     Loading Enterprise Data...           │
│                                          │
│     ▓▓▓▓▓▓▓▓▓░░░░░░░░░░  60%            │
│                                          │
└─────────────────────────────────────────┘
```

#### Incremental Load (Skeleton)
```
┌─────────────────────────────────────────┐
│  ▓▓▓▓▓▓▓▓▓▓  ▓▓▓▓  ▓▓▓▓▓▓▓              │ KPI Cards
│  ▓▓▓▓▓▓▓▓▓▓  ▓▓▓▓  ▓▓▓▓▓▓▓              │ (shimmer)
│                                          │
│  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓           │ Alerts
│  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓           │ (shimmer)
└─────────────────────────────────────────┘
```

```swift
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [
                        .clear,
                        .white.opacity(0.3),
                        .clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: phase)
            )
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 400
                }
            }
    }
}
```

#### Refresh Indicator (Pull-to-Refresh)
```swift
struct RefreshIndicator: View {
    @Binding var isRefreshing: Bool

    var body: some View {
        HStack(spacing: 8) {
            ProgressView()
                .progressViewStyle(.circular)

            Text("Updating data...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .opacity(isRefreshing ? 1 : 0)
        .animation(.easeInOut, value: isRefreshing)
    }
}
```

### Error States

#### Network Error
```
┌─────────────────────────────────────────┐
│                                          │
│         ⚠️                               │
│                                          │
│     Unable to Connect                    │
│     to Enterprise Systems                │
│                                          │
│     Please check your network            │
│     connection and try again.            │
│                                          │
│     [Retry]   [Work Offline]             │
│                                          │
└─────────────────────────────────────────┘
```

#### Data Error
```
┌─────────────────────────────────────────┐
│                                          │
│         ❌                               │
│                                          │
│     Failed to Load Financial Data        │
│                                          │
│     Error: Invalid response from API     │
│     (Error code: 500)                    │
│                                          │
│     [Try Again]   [Contact Support]      │
│                                          │
└─────────────────────────────────────────┘
```

#### Empty State
```
┌─────────────────────────────────────────┐
│                                          │
│         📊                               │
│                                          │
│     No Data Available                    │
│                                          │
│     There are no transactions for        │
│     the selected period.                 │
│                                          │
│     [Change Period]   [Learn More]       │
│                                          │
└─────────────────────────────────────────┘
```

```swift
struct ErrorView: View {
    let error: AppError
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: error.icon)
                .font(.system(size: 60))
                .foregroundColor(.red)

            Text(error.title)
                .font(.title2)
                .fontWeight(.semibold)

            Text(error.message)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            HStack(spacing: 16) {
                Button("Retry", action: retryAction)
                    .buttonStyle(.borderedProminent)

                Button("Contact Support") {
                    // Open support
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
    }
}
```

---

## Animation & Transitions

### Timing Functions

```swift
// Animation curves for different contexts
enum AnimationCurve {
    static let standard = Animation.spring(duration: 0.3, bounce: 0.0)
    static let emphasized = Animation.spring(duration: 0.4, bounce: 0.2)
    static let smooth = Animation.easeInOut(duration: 0.3)
    static let quick = Animation.easeOut(duration: 0.15)
}
```

### Component Animations

#### KPI Card Update
```swift
struct KPICard: View {
    let metric: Metric
    @State private var displayValue: Double = 0

    var body: some View {
        VStack {
            Text(displayValue, format: .currency(code: "USD"))
                .font(.title)
                .contentTransition(.numericText())
        }
        .onChange(of: metric.value) { oldValue, newValue in
            withAnimation(.spring(duration: 0.5)) {
                displayValue = newValue
            }
        }
    }
}
```

#### Alert Appearance
```swift
struct AlertBanner: View {
    let alert: Alert
    @State private var isVisible = false

    var body: some View {
        HStack {
            // Alert content
        }
        .offset(y: isVisible ? 0 : -100)
        .opacity(isVisible ? 1 : 0)
        .onAppear {
            withAnimation(.spring(duration: 0.5, bounce: 0.3)) {
                isVisible = true
            }
        }
    }
}
```

#### Chart Animation
```swift
struct BarChart: View {
    let data: [DataPoint]
    @State private var animationProgress: CGFloat = 0

    var body: some View {
        HStack(alignment: .bottom, spacing: 4) {
            ForEach(data) { point in
                Rectangle()
                    .fill(point.color)
                    .frame(height: point.value * animationProgress)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                animationProgress = 1.0
            }
        }
    }
}
```

### 3D Animations

#### Entity Pulse (Alert)
```swift
func pulseEntity(_ entity: Entity, color: UIColor) {
    let duration: TimeInterval = 1.0

    // Scale animation
    var scaleTransform = entity.transform
    scaleTransform.scale = SIMD3(1.2, 1.2, 1.2)

    entity.move(
        to: scaleTransform,
        relativeTo: entity.parent,
        duration: duration / 2
    )

    // Return to original
    DispatchQueue.main.asyncAfter(deadline: .now() + duration / 2) {
        entity.move(
            to: entity.transform,
            relativeTo: entity.parent,
            duration: duration / 2
        )
    }
}
```

#### Data Flow Animation
```swift
class FlowAnimationSystem: System {
    func animateFlow(from source: Entity, to destination: Entity) {
        let particle = createParticle()

        // Calculate path
        let path = generateBezierPath(from: source.position, to: destination.position)

        // Animate along path
        var currentSegment = 0
        let totalSegments = path.count - 1

        Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { timer in
            guard currentSegment < totalSegments else {
                timer.invalidate()
                particle.removeFromParent()
                return
            }

            let progress = CGFloat(currentSegment) / CGFloat(totalSegments)
            particle.position = path[currentSegment]

            currentSegment += 1
        }
    }
}
```

### Performance Considerations

**Animation Budget**
- Maximum 60 simultaneous animations
- Prefer GPU-accelerated transforms (scale, rotation, position)
- Avoid animating expensive properties (shadows, blurs)
- Use CADisplayLink for smooth frame-locked animations

**Optimization Techniques**
```swift
// Layer backing for better performance
view.layer.shouldRasterize = true
view.layer.rasterizationScale = UIScreen.main.scale

// Reduce animation when app is backgrounded
NotificationCenter.default.addObserver(
    forName: UIApplication.didEnterBackgroundNotification,
    object: nil,
    queue: .main
) { _ in
    pauseNonEssentialAnimations()
}
```

---

## Conclusion

This design specification provides a comprehensive blueprint for creating a professional, accessible, and engaging spatial ERP experience. Key design principles:

1. **Enterprise Professionalism**: Sophisticated design appropriate for business context
2. **Spatial Optimization**: Thoughtful use of 3D space for information hierarchy
3. **Intuitive Interactions**: Natural gestures and familiar patterns
4. **Visual Clarity**: High contrast, clear typography, meaningful color
5. **Accessibility First**: Full support for all users
6. **Performance Aware**: Smooth animations without compromising responsiveness

All design decisions should be validated through user testing with actual enterprise users to ensure the spatial experience enhances rather than hinders business operations.
