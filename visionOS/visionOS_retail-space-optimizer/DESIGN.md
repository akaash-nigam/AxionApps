# Retail Space Optimizer - UI/UX Design Specifications

## 1. Spatial Design Principles

### 1.1 Core Design Philosophy

**Retail-First Spatial Design**: Every interface element serves the core purpose of optimizing retail space and improving customer experience. Design decisions prioritize clarity, efficiency, and actionable insights.

**Principles**:
1. **Contextual Awareness**: UI adapts to the user's current task (designing, analyzing, presenting)
2. **Progressive Disclosure**: Start simple, reveal complexity as needed
3. **Spatial Efficiency**: Use depth to organize information hierarchically
4. **Data Visualization**: Make patterns and insights immediately visible
5. **Collaborative by Default**: Design for multi-user scenarios from the start

### 1.2 Spatial Ergonomics

```
User Comfort Zones (visionOS):

Near Zone (0.3m - 1m)
├── Purpose: Detailed work, controls, reading
├── Content: Fixture details, measurements, text input
├── Eye Level: 0° to -15° (slightly below)
└── Interaction: Precise pinch gestures

Working Zone (1m - 3m)
├── Purpose: Primary workspace, 3D manipulation
├── Content: Store volumes, fixture placement, tools
├── Eye Level: -10° to -20°
└── Interaction: Drag, rotate, scale

Overview Zone (3m - 10m)
├── Purpose: Context, dashboards, team presence
├── Content: Analytics, comparisons, avatars
├── Eye Level: -5° to -15°
└── Interaction: Gaze selection, voice commands

Peripheral Zone (10m+)
├── Purpose: Ambient information, notifications
├── Content: System status, alerts, timers
├── Eye Level: Any (attention-seeking)
└── Interaction: Glanceable only
```

### 1.3 Depth and Layering Strategy

```
Z-Depth Organization:

Foreground (0.5m - 1m)
├── Active tool palettes
├── Context menus
├── Modal dialogs
└── Detail panels

Mid-ground (1m - 2.5m)
├── Primary work volume (store 3D)
├── Floating toolbars
├── Analytics overlays
└── Active windows

Background (2.5m - 5m)
├── Secondary windows
├── Dashboard displays
├── Reference materials
└── Team presence indicators

Far Background (5m+)
├── Environmental context
├── Ambient information
└── Notifications
```

## 2. Window Layouts and Configurations

### 2.1 Main Dashboard Window

**Dimensions**: 1200pt x 800pt (scalable)
**Style**: Plain window with glass material
**Position**: Centered, -15° below eye level

#### Layout Structure

```
┌────────────────────────────────────────────────────────┐
│  Retail Space Optimizer                    [- □ ×]     │
├────────────────────────────────────────────────────────┤
│                                                         │
│  ┌─────────────────┐  ┌──────────────────────────────┐ │
│  │  Store List     │  │   Quick Stats                │ │
│  │  • Flagship     │  │   📊 Sales/sqft: $425       │ │
│  │  • Mall 1       │  │   👥 Traffic: +15%           │ │
│  │  • Downtown     │  │   💰 Conv Rate: 32%         │ │
│  │                 │  │   ⏱️  Dwell: 8.5 min        │ │
│  │  [+ New Store]  │  └──────────────────────────────┘ │
│  └─────────────────┘                                    │
│                                                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │  Recent Stores                                   │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐       │   │
│  │  │Flagship  │  │ Mall 1   │  │Downtown  │       │   │
│  │  │[Preview] │  │[Preview] │  │[Preview] │       │   │
│  │  │Open 3D   │  │Open 3D   │  │Open 3D   │       │   │
│  │  └──────────┘  └──────────┘  └──────────┘       │   │
│  └─────────────────────────────────────────────────┘   │
│                                                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │  Actions                                         │   │
│  │  [🏪 New Store]  [📊 Analytics]  [🤝 Collab]   │   │
│  └─────────────────────────────────────────────────┘   │
│                                                         │
└────────────────────────────────────────────────────────┘
```

#### Visual Design

**Glass Background**:
```swift
.background(.ultraThinMaterial)
.background {
    Color.accentColor.opacity(0.05)
}
```

**Typography**:
- Headline: SF Pro Display, 28pt, Semibold
- Store Names: SF Pro Text, 20pt, Medium
- Stats: SF Pro Rounded, 16pt, Regular
- Body: SF Pro Text, 14pt, Regular

**Color Palette**:
```swift
struct RetailColors {
    static let primary = Color(hex: "#0066FF")        // Blue (action)
    static let success = Color(hex: "#34C759")        // Green (positive metrics)
    static let warning = Color(hex: "#FF9500")        // Orange (attention)
    static let critical = Color(hex: "#FF3B30")       // Red (issues)
    static let neutral = Color(hex: "#8E8E93")        // Gray (secondary)

    // Heatmap gradient
    static let heatmapCold = Color(hex: "#3498db")    // Blue
    static let heatmapWarm = Color(hex: "#f39c12")    // Yellow
    static let heatmapHot = Color(hex: "#e74c3c")     // Red
}
```

### 2.2 Store Volume Window (3D Visualization)

**Dimensions**: 2m (W) x 1.5m (H) x 2m (D) volumetric
**Style**: Volumetric window, no baseplate
**Position**: 1.5m from user, -15° below eye level

#### 3D Scene Layout

```
Store Volume Composition:

┌─────────────────────────────────┐
│      Toolbar (Top, Fixed)       │
│  [View] [Edit] [Analyze] [AI]   │
├─────────────────────────────────┤
│                                 │
│         3D Store Model          │
│                                 │
│    ╔═══════════════════╗        │
│    ║   ┌──┐  ┌──┐     ║        │
│    ║   │  │  │  │ ◄── Fixtures │
│    ║   └──┘  └──┘     ║        │
│    ║                   ║        │
│    ║   ┌────────┐     ║        │
│    ║   │ Shelf  │     ║        │
│    ║   └────────┘     ║        │
│    ╚═══════════════════╝        │
│     └── Store Floor ──┘         │
│                                 │
│  [Heatmap Overlay - Optional]   │
│                                 │
├─────────────────────────────────┤
│  Bottom Shelf: Fixture Library  │
│  [┌─┐][┌─┐][┌─┐][┌─┐][┌─┐]    │
└─────────────────────────────────┘
```

#### Visual Materials

**Store Floor**:
```swift
var floorMaterial: PhysicallyBasedMaterial {
    var material = PhysicallyBasedMaterial()
    material.baseColor = .init(tint: .white.opacity(0.9))
    material.roughness = 0.8
    material.metallic = 0.0
    return material
}
```

**Grid Lines**:
```swift
// 1-meter grid for scale reference
let gridMaterial = SimpleMaterial(
    color: .white.withAlphaComponent(0.2),
    isMetallic: false
)
```

**Fixtures**:
```swift
// Default fixture material
var fixtureMaterial: PhysicallyBasedMaterial {
    var material = PhysicallyBasedMaterial()
    material.baseColor = .init(tint: .white)
    material.roughness = 0.6
    material.metallic = 0.1
    return material
}

// Selected state
var selectedMaterial: PhysicallyBasedMaterial {
    var material = fixtureMaterial
    material.emissiveColor = .init(color: .blue)
    material.emissiveIntensity = 0.3
    return material
}

// Hover state
var hoverMaterial: PhysicallyBasedMaterial {
    var material = fixtureMaterial
    material.baseColor = .init(tint: .blue.opacity(0.3))
    return material
}
```

#### Floating Toolbar

```
Toolbar Layout (Always Visible):

┌────────────────────────────────────────────────────┐
│  👁  View  │  ✏️  Edit  │  📊 Analyze  │  🤖 AI   │
└────────────────────────────────────────────────────┘

Active Tool Expands Below:
┌────────────────────────────────────────────────────┐
│  ✏️  Edit Mode                                     │
│  ┌──┐ ┌──┐ ┌──┐ ┌──┐ ┌──┐                        │
│  │↔️│ │🔄│ │📏│ │❌│ │📋│                        │
│  Move Rotate Scale Delete Copy                     │
└────────────────────────────────────────────────────┘
```

Position: Float 0.3m above volume, track with window

### 2.3 Analytics Window

**Dimensions**: 900pt x 700pt
**Style**: Plain window with glass
**Position**: Right side of main window, same depth

#### Layout

```
┌──────────────────────────────────────────────┐
│  Analytics - Flagship Store      [- □ ×]    │
├──────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────┐ │
│  │  Date Range: Last 30 Days        [▼]   │ │
│  └─────────────────────────────────────────┘ │
│                                              │
│  Key Metrics                                 │
│  ┌───────┐  ┌───────┐  ┌───────┐           │
│  │ $425  │  │  32%  │  │ 8.5m  │           │
│  │ /sqft │  │ Conv  │  │ Dwell │           │
│  │ +12%  │  │ +5%   │  │ +15%  │           │
│  └───────┘  └───────┘  └───────┘           │
│                                              │
│  Traffic Over Time                           │
│  ┌─────────────────────────────────────────┐ │
│  │     ╭─╮                                 │ │
│  │   ╭─╯ ╰╮     ╭╮                        │ │
│  │ ╭─╯    ╰─╮ ╭─╯╰─╮                      │ │
│  │─────────────────────────────            │ │
│  └─────────────────────────────────────────┘ │
│                                              │
│  Top Performing Zones                        │
│  ┌─────────────────────────────────────────┐ │
│  │  1. Entrance Display      $1,250/sqft  │ │
│  │  2. Checkout Endcaps      $980/sqft    │ │
│  │  3. Center Aisle          $750/sqft    │ │
│  └─────────────────────────────────────────┘ │
│                                              │
│  [View in 3D]  [Export Report]              │
└──────────────────────────────────────────────┘
```

## 3. Volume Designs (3D Bounded Spaces)

### 3.1 Store Model Volume

**Scale**: 1:20 (1 meter real = 5cm in volume)
**Bounds**: 2m x 1.5m x 2m
**Content**: Full store layout with fixtures and products

#### Visual Hierarchy

```
Layer 1: Architecture (Always Visible)
├── Floor (grid overlay optional)
├── Walls (semi-transparent)
├── Entrances (highlighted)
└── Structural columns

Layer 2: Fixtures (Toggleable Detail Levels)
├── LOD 0 (< 1m): Full detail, textures, products
├── LOD 1 (1-3m): Medium detail, simplified geometry
├── LOD 2 (> 3m): Low poly, solid colors
└── Labels: Show on hover or always (user preference)

Layer 3: Analytics Overlays (Toggleable)
├── Traffic heatmap (color-coded floor overlay)
├── Dwell time indicators (height-based columns)
├── Customer paths (animated lines)
└── Conversion zones (colored boundaries)

Layer 4: Interaction Feedback
├── Selection highlights (glow effect)
├── Drag targets (drop zones)
├── Measurement lines (when measuring)
└── Collision indicators (red when overlapping)
```

#### Grid System

```swift
struct StoreGrid {
    let cellSize: Float = 0.5  // 0.5m cells (at 1:20 = 2.5cm)
    let majorGridEvery: Int = 2  // Major line every 1m

    func createGrid(for bounds: BoundingBox) -> Entity {
        let gridEntity = Entity()

        // Minor grid lines (0.5m)
        for x in stride(from: bounds.min.x, to: bounds.max.x, by: cellSize) {
            addLine(from: [x, 0, bounds.min.z], to: [x, 0, bounds.max.z],
                   color: .white.withAlphaComponent(0.1))
        }

        // Major grid lines (1m)
        for x in stride(from: bounds.min.x, to: bounds.max.x, by: cellSize * Float(majorGridEvery)) {
            addLine(from: [x, 0, bounds.min.z], to: [x, 0, bounds.max.z],
                   color: .white.withAlphaComponent(0.3))
        }

        return gridEntity
    }
}
```

### 3.2 Fixture Preview Volume

**Dimensions**: 0.5m x 0.5m x 0.5m
**Purpose**: Detailed fixture examination
**Trigger**: Double-tap fixture in main volume

#### Features

- Full 360° rotation (auto-rotate or manual)
- Product placement visualization
- Dimension annotations
- Material/finish options
- Exploded view option

```
Fixture Detail View:

    ┌───────────────────┐
    │   Shelf Unit      │
    │                   │
    │      ┌─────┐      │
    │      │ 🏷️  │      │ ← Products shown
    │      │ 📦  │      │
    │      └─────┘      │
    │                   │
    │  W: 1.2m          │
    │  H: 2.0m          │
    │  D: 0.5m          │
    │                   │
    │  [Edit] [Delete]  │
    └───────────────────┘
```

### 3.3 Comparison Volume

**Dimensions**: 3m x 1.5m x 1.5m
**Purpose**: Side-by-side layout comparison
**Layout**: Split view showing two scenarios

```
Comparison View:

┌─────────────┬─────────────┐
│  Current    │  Proposed   │
│   Layout    │   Layout    │
│             │             │
│  ┌──┐  ┌──┐│ ┌──┐        │
│  │  │  │  ││ │  │  ┌──┐  │
│  └──┘  └──┘│ └──┘  │  │  │
│            ││       └──┘  │
│  Sales:    ││  Sales:     │
│  $425/sqft ││  $475/sqft  │
│            ││  (+12%)     │
└─────────────┴─────────────┘
        │
        ▼
   [Apply Changes]
```

## 4. Full Space / Immersive Experiences

### 4.1 Store Walkthrough (Mixed Reality)

**Mode**: Mixed immersion (passthrough visible)
**Scale**: 1:1 (life-size)
**Purpose**: Experience customer perspective

#### Environment Setup

```swift
struct ImmersiveStoreView: View {
    @State private var storeEnvironment: Entity?
    @State private var customerPath: [PathPoint] = []
    @State private var currentPosition = SIMD3<Float>(0, 1.6, 0)  // Eye height

    var body: some View {
        RealityView { content in
            // Load store environment
            let store = try await loadStoreEnvironment()
            content.add(store)

            // Add lighting
            let sunlight = DirectionalLight()
            sunlight.intensity = 50000
            content.add(sunlight)

            // Ambient lighting
            let ambient = AmbientLight()
            ambient.intensity = 5000
            content.add(ambient)

            // Add customer path visualization
            if !customerPath.isEmpty {
                let pathEntity = createCustomerPath(customerPath)
                content.add(pathEntity)
            }
        }
        .upperLimbVisibility(.hidden)  // Hide hands for cleaner view
        .persistentSystemOverlays(.hidden)  // Full immersion
    }
}
```

#### Navigation Controls

```
Immersive Navigation:

Physical Movement:
├── Walk in play area (tracked automatically)
├── Look around naturally (head tracking)
└── Safety boundary warnings

Teleportation:
├── Gaze at floor location
├── Pinch to confirm
└── Smooth transition (fade + move)

Guided Tour:
├── Predefined camera path
├── Auto-narration (optional)
├── Pause/resume controls
└── Skip to next point
```

#### Overlay UI

```
Minimal UI Overlay (Bottom):

┌──────────────────────────────────┐
│                                  │
│  ┌─┐ Exit  │  👁 Show Metrics    │
│  └─┘       │  🎯 Show Paths      │
│           │  ⏸️  Pause Tour      │
└──────────────────────────────────┘
     (Glass ornament, bottom center)
```

### 4.2 Presentation Mode (Full Immersion)

**Mode**: Full immersion (no passthrough)
**Purpose**: Client presentations and approvals
**Features**: Cinematic quality, scripted sequence

#### Presentation Sequence

```
1. Fade In
   └── Store exterior → entrance view

2. Entrance Experience
   ├── Customer perspective
   ├── First impression analysis
   └── Traffic flow visualization

3. Department Showcase
   ├── Each department highlighted
   ├── Key products spotlighted
   ├── Performance metrics appear
   └── Optimization suggestions

4. Journey Playback
   ├── Typical customer path animated
   ├── Interaction hotspots highlighted
   ├── Purchase decisions shown
   └── Improvement opportunities marked

5. Results Summary
   ├── Before/after comparison
   ├── Projected ROI
   ├── Implementation timeline
   └── Call to action

6. Fade Out
   └── Return to mixed reality
```

#### Presentation Controls

```swift
struct PresentationControls: View {
    @State private var currentSlide = 0
    @State private var isPlaying = true

    var body: some View {
        HStack {
            Button(action: { previousSlide() }) {
                Image(systemName: "chevron.left")
            }

            Text("Section \(currentSlide + 1) of \(totalSlides)")
                .font(.caption)

            Button(action: { nextSlide() }) {
                Image(systemName: "chevron.right")
            }

            Spacer()

            Button(action: { isPlaying.toggle() }) {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
            }

            Button(action: { exitPresentation() }) {
                Image(systemName: "xmark")
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
    }
}
```

## 5. 3D Visualization Specifications

### 5.1 Heatmap Visualization

#### Traffic Heatmap

```swift
struct TrafficHeatmap {
    let data: [[Double]]  // 2D grid, values 0.0 to 1.0
    let resolution: Int = 100  // 100x100 grid

    func createVisualization() -> ModelEntity {
        let entity = ModelEntity()

        for y in 0..<resolution {
            for x in 0..<resolution {
                let intensity = data[y][x]
                let color = heatmapColor(for: intensity)

                let cell = createHeatmapCell(
                    x: x, y: y,
                    color: color,
                    height: Float(intensity) * 0.3  // 0-30cm tall
                )

                entity.addChild(cell)
            }
        }

        return entity
    }

    private func heatmapColor(for intensity: Double) -> UIColor {
        // Blue (cold) → Yellow (warm) → Red (hot)
        let hue = CGFloat(0.66 - (intensity * 0.66))  // 0.66 (blue) to 0.0 (red)
        return UIColor(hue: hue, saturation: 0.8, brightness: 0.9, alpha: 0.7)
    }
}
```

#### Dwell Time Visualization

```
Dwell Time Columns:

Height = Dwell Duration
Color = Purchase Conversion

    ████  ← Long dwell + purchase (tall, green)
    ██    ← Medium dwell, no purchase (medium, yellow)
    █     ← Quick browse (short, blue)
    ████  ← Long dwell + purchase (tall, green)
```

#### Customer Path Visualization

```swift
struct CustomerPathRenderer {
    func createPath(points: [PathPoint]) -> Entity {
        let pathEntity = Entity()

        // Create line segments
        for i in 0..<(points.count - 1) {
            let start = points[i].position
            let end = points[i + 1].position

            let segment = createPathSegment(from: start, to: end)

            // Animate flow direction
            animateFlow(segment, speed: 1.0)

            pathEntity.addChild(segment)
        }

        // Add interaction markers
        for (index, point) in points.enumerated() where point.hasInteraction {
            let marker = createInteractionMarker(at: point.position)
            pathEntity.addChild(marker)
        }

        return pathEntity
    }

    private func createPathSegment(from start: SIMD3<Float>, to end: SIMD3<Float>) -> ModelEntity {
        let mesh = MeshResource.generateBox(
            width: 0.02,
            height: 0.01,
            depth: simd_distance(start, end)
        )

        var material = UnlitMaterial(color: .blue.withAlphaComponent(0.6))
        material.blending = .transparent

        let entity = ModelEntity(mesh: mesh, materials: [material])

        // Position and orient
        entity.position = (start + end) / 2
        entity.look(at: end, from: start, relativeTo: nil)

        return entity
    }
}
```

### 5.2 Product Visualization

#### Product Display States

```swift
enum ProductDisplayState {
    case realistic      // Full 3D model with textures
    case simplified     // Low-poly placeholder
    case iconic         // 2D icon billboard
    case hidden         // Not rendered

    func material(for product: Product) -> Material {
        switch self {
        case .realistic:
            return loadPBRMaterial(for: product)
        case .simplified:
            return SimpleMaterial(color: product.categoryColor, isMetallic: false)
        case .iconic:
            return UnlitMaterial(color: .white, texture: .init(product.iconImage))
        case .hidden:
            return UnlitMaterial(color: .clear)
        }
    }
}
```

#### Product Highlights

```
Product Highlighting Scenarios:

Performance-Based:
├── Top Sellers: Gold glow
├── High Margin: Green glow
├── Slow Movers: Red outline
└── Out of Stock: Gray + icon

User Selection:
├── Hovered: Subtle white highlight
├── Selected: Blue outline + glow
├── Related Products: Dotted connection lines
└── Incompatible: Red distance indicator
```

### 5.3 Fixture Visualization

#### Fixture Library Categories

```
Fixture Types & Visual Styles:

Shelving:
├── Gondola (retail standard)
├── Wall shelves
├── Glass displays
└── Pegboard

Racks:
├── Clothing racks
├── Display racks
├── Endcaps
└── Promotional stands

Specialized:
├── Refrigeration units (light blue tint)
├── Checkout counters (highlighted)
├── Mannequins
└── Tables

Custom:
├── User-uploaded models
├── Procedurally generated
└── Brand-specific fixtures
```

#### Fixture Visual Feedback

```swift
extension FixtureEntity {
    func applyState(_ state: InteractionState) {
        switch state {
        case .normal:
            opacity = 1.0
            outlineWidth = 0

        case .hovered:
            opacity = 1.0
            outlineWidth = 0.002
            outlineColor = .white

        case .selected:
            opacity = 1.0
            outlineWidth = 0.005
            outlineColor = .blue
            addGlow(color: .blue, intensity: 0.3)

        case .dragging:
            opacity = 0.7
            addGlow(color: .blue, intensity: 0.5)
            showDropTargets()

        case .invalid:
            opacity = 0.5
            outlineWidth = 0.005
            outlineColor = .red
            shake()  // Brief shake animation

        case .locked:
            opacity = 0.6
            addLockIcon()
        }
    }
}
```

## 6. Interaction Patterns

### 6.1 Fixture Placement Workflow

```
Step 1: Select from Library
┌──────────────────────────┐
│  Fixture Library         │
│  ┌───┐ ┌───┐ ┌───┐      │
│  │🗄️ │ │📋 │ │🪑 │      │
│  └───┘ └───┘ └───┘      │
│   ↓ Tap to select        │
└──────────────────────────┘

Step 2: Preview in Hand
        ┌───┐
        │🗄️ │  ← Fixture follows hand
        └───┘
         ↓ Gaze at placement location

Step 3: Position on Grid
    Grid snapping:
    ┌─┬─┬─┬─┐
    ├─┼─┼─┼─┤
    │ │█│ │ │  ← Fixture snaps to grid
    ├─┼─┼─┼─┤
    └─┴─┴─┴─┘
     ↓ Pinch to place

Step 4: Adjust & Confirm
    Fine tuning:
    • Drag to reposition
    • Two-finger pinch to rotate
    • Scale gesture (if allowed)
    ↓ Tap elsewhere to confirm
```

### 6.2 Analytics Overlay Toggle

```swift
struct AnalyticsOverlayControl: View {
    @State private var activeOverlays: Set<OverlayType> = []

    var body: some View {
        VStack(alignment: .leading) {
            Text("Analytics Overlays")
                .font(.headline)

            Toggle("Traffic Heatmap", isOn: binding(for: .traffic))
                .onChange(of: binding(for: .traffic).wrappedValue) { _, enabled in
                    if enabled {
                        showTrafficHeatmap()
                    } else {
                        hideTrafficHeatmap()
                    }
                }

            Toggle("Dwell Time", isOn: binding(for: .dwellTime))

            Toggle("Customer Paths", isOn: binding(for: .paths))

            Toggle("Sales Performance", isOn: binding(for: .sales))

            Slider(value: $overlayOpacity, in: 0...1) {
                Text("Opacity")
            }
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(12)
    }
}
```

### 6.3 Gesture Reference

```
visionOS Gesture Dictionary:

Basic Interactions:
├── Look: Eye gaze focuses elements
├── Tap: Index finger + thumb pinch
├── Long Press: Hold pinch for 0.5s
└── Double Tap: Two quick pinches

Manipulation:
├── Drag: Pinch + move hand
├── Rotate: Two-hand twist gesture
├── Scale: Two-hand pinch (closer/further)
└── Orbit: One hand circles around object

Multi-Selection:
├── Lasso: Draw circle with finger
├── Box Select: Drag rectangle
└── Add to Selection: Pinch while looking at item

Measurement:
├── Start: Pinch at first point
├── Extend: Move hand, line extends
└── End: Release pinch

Navigation:
├── Teleport: Gaze at floor + pinch
├── Rotate View: Two-finger rotate
└── Reset View: Three-finger tap
```

### 6.4 Context Menus

```swift
struct FixtureContextMenu: View {
    let fixture: Fixture

    var body: some View {
        VStack(spacing: 0) {
            Button(action: { editFixture() }) {
                Label("Edit Details", systemImage: "pencil")
            }

            Divider()

            Button(action: { duplicateFixture() }) {
                Label("Duplicate", systemImage: "plus.square.on.square")
            }

            Button(action: { rotateFixture() }) {
                Label("Rotate 90°", systemImage: "rotate.right")
            }

            Divider()

            Menu("Change Fixture") {
                ForEach(FixtureType.allCases) { type in
                    Button(type.name) {
                        changeFixtureType(to: type)
                    }
                }
            }

            Divider()

            Button(role: .destructive, action: { deleteFixture() }) {
                Label("Delete", systemImage: "trash")
            }
        }
        .frame(width: 200)
        .background(.regularMaterial)
        .cornerRadius(12)
        .shadow(radius: 8)
    }
}

// Trigger: Long press on fixture
.onLongPressGesture {
    showContextMenu(for: fixture, at: touchLocation)
}
```

## 7. Visual Design System

### 7.1 Color Palette

#### Primary Colors

```swift
extension Color {
    // Brand Colors
    static let retailPrimary = Color(hex: "#0066FF")
    static let retailSecondary = Color(hex: "#5856D6")

    // Functional Colors
    static let success = Color(hex: "#34C759")
    static let warning = Color(hex: "#FF9500")
    static let error = Color(hex: "#FF3B30")
    static let info = Color(hex: "#5AC8FA")

    // Neutral Palette
    static let neutralLight = Color(hex: "#F2F2F7")
    static let neutralMedium = Color(hex: "#8E8E93")
    static let neutralDark = Color(hex: "#1C1C1E")

    // Analytics Colors
    static let analyticsBlue = Color(hex: "#007AFF")
    static let analyticsGreen = Color(hex: "#34C759")
    static let analyticsOrange = Color(hex: "#FF9500")
    static let analyticsRed = Color(hex: "#FF3B30")
    static let analyticsPurple = Color(hex: "#AF52DE")
}
```

#### Heatmap Gradients

```swift
struct HeatmapGradient {
    static let traffic = LinearGradient(
        colors: [
            Color(hex: "#3498db"),  // Blue (low)
            Color(hex: "#2ecc71"),  // Green (medium-low)
            Color(hex: "#f39c12"),  // Yellow (medium-high)
            Color(hex: "#e74c3c")   // Red (high)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let sales = LinearGradient(
        colors: [
            Color(hex: "#95a5a6"),  // Gray (poor)
            Color(hex: "#f39c12"),  // Orange (average)
            Color(hex: "#27ae60"),  // Green (good)
            Color(hex: "#2ecc71")   // Bright green (excellent)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let conversion = LinearGradient(
        colors: [
            Color.red.opacity(0.3),     // Low conversion
            Color.yellow.opacity(0.5),  // Medium
            Color.green.opacity(0.7)    // High conversion
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
}
```

### 7.2 Typography System

```swift
struct RetailTypography {
    // Headings
    static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    static let title1 = Font.system(size: 28, weight: .semibold, design: .default)
    static let title2 = Font.system(size: 22, weight: .semibold, design: .default)
    static let title3 = Font.system(size: 20, weight: .medium, design: .default)

    // Body
    static let body = Font.system(size: 17, weight: .regular, design: .default)
    static let bodyEmphasis = Font.system(size: 17, weight: .semibold, design: .default)
    static let callout = Font.system(size: 16, weight: .regular, design: .default)

    // Supporting
    static let subheadline = Font.system(size: 15, weight: .regular, design: .default)
    static let footnote = Font.system(size: 13, weight: .regular, design: .default)
    static let caption1 = Font.system(size: 12, weight: .regular, design: .default)
    static let caption2 = Font.system(size: 11, weight: .regular, design: .default)

    // Monospaced (for measurements, data)
    static let measurement = Font.system(size: 15, weight: .medium, design: .monospaced)
    static let data = Font.system(size: 13, weight: .regular, design: .monospaced)
}

// Usage
Text("Store Analytics")
    .font(RetailTypography.title1)

Text("$425.50/sqft")
    .font(RetailTypography.measurement)
```

### 7.3 Materials and Lighting

#### Glass Materials

```swift
// Window backgrounds
.background(.ultraThinMaterial)  // Primary windows
.background(.thinMaterial)       // Panels, cards
.background(.regularMaterial)    // Context menus, popovers
.background(.thickMaterial)      // Emphasized panels
.background(.ultraThickMaterial) // Modal dialogs
```

#### Custom Materials

```swift
struct RetailMaterials {
    // Glass panel with tint
    static var primaryPanel: some ShapeStyle {
        Material.ultraThin.blendMode(.normal)
    }

    // Semi-transparent overlay
    static var overlay: some ShapeStyle {
        Color.black.opacity(0.3).blendMode(.multiply)
    }

    // Highlight effect
    static var highlight: some ShapeStyle {
        LinearGradient(
            colors: [.white.opacity(0.3), .clear],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
```

#### 3D Lighting Setup

```swift
struct StoreLightingEnvironment {
    static func setup(in content: RealityViewContent) {
        // Ambient light (soft fill)
        let ambient = AmbientLight()
        ambient.intensity = 3000
        ambient.color = .white
        content.add(ambient)

        // Directional light (sun/key light)
        let sun = DirectionalLight()
        sun.intensity = 50000
        sun.position = [5, 10, 5]
        sun.look(at: [0, 0, 0], from: sun.position, relativeTo: nil)
        sun.shadow = DirectionalLightComponent.Shadow(
            maximumDistance: 20,
            depthBias: 2
        )
        content.add(sun)

        // Fill light (reduce harsh shadows)
        let fill = DirectionalLight()
        fill.intensity = 10000
        fill.position = [-3, 5, -3]
        fill.look(at: [0, 0, 0], from: fill.position, relativeTo: nil)
        content.add(fill)

        // Image-based lighting (environment)
        if let environment = try? EnvironmentResource.load(named: "StoreEnvironment") {
            content.environment = environment
        }
    }
}
```

### 7.4 Iconography

#### System Icons (SF Symbols)

```swift
struct RetailIcons {
    // Navigation
    static let home = "house.fill"
    static let stores = "building.2.fill"
    static let analytics = "chart.bar.fill"
    static let settings = "gearshape.fill"

    // Tools
    static let select = "arrow.up.left.and.arrow.down.right"
    static let move = "arrow.up.and.down.and.arrow.left.and.right"
    static let rotate = "rotate.right.fill"
    static let scale = "arrow.up.left.and.down.right.magnifyingglass"
    static let delete = "trash.fill"
    static let duplicate = "plus.square.on.square"

    // Fixtures
    static let shelf = "rectangle.stack.fill"
    static let rack = "rectangle.3.group.fill"
    static let table = "square.fill"
    static let display = "square.grid.2x2.fill"

    // Analytics
    static let traffic = "figure.walk"
    static let sales = "dollarsign.circle.fill"
    static let conversion = "chart.line.uptrend.xyaxis"
    static let time = "clock.fill"

    // Actions
    static let add = "plus.circle.fill"
    static let save = "square.and.arrow.down.fill"
    static let export = "square.and.arrow.up.fill"
    static let share = "square.and.arrow.up"
    static let collaborate = "person.2.fill"

    // States
    static let success = "checkmark.circle.fill"
    static let warning = "exclamationmark.triangle.fill"
    static let error = "xmark.circle.fill"
    static let info = "info.circle.fill"
}
```

#### Custom 3D Icons

```
Fixture Icons (3D glyphs):
├── Low-poly representations
├── Single color (category-based)
├── Size: 0.1m x 0.1m x 0.1m
└── Used in: Fixture library, tooltips
```

## 8. User Flows and Navigation

### 8.1 Primary User Flow

```
App Launch
    │
    ├─→ First Launch
    │      ├─→ Onboarding
    │      ├─→ Create First Store
    │      └─→ Tutorial Mode
    │
    └─→ Returning User
           ├─→ Dashboard
           │      ├─→ Store List
           │      ├─→ Recent Stores (Quick Access)
           │      └─→ Quick Stats
           │
           ├─→ Select Store
           │      ├─→ Open 3D View (Volume)
           │      ├─→ View Analytics (Window)
           │      └─→ Start Collaboration (Session)
           │
           └─→ Edit Store
                  ├─→ Place Fixtures
                  ├─→ View Analytics Overlays
                  ├─→ Generate Suggestions
                  ├─→ Compare Scenarios
                  └─→ Present to Stakeholders (Immersive)
```

### 8.2 Store Creation Flow

```
Step 1: Basic Information
┌─────────────────────────┐
│ Store Name: [_______]   │
│ Location:   [_______]   │
│ Store Type: [▼]         │
│             [Next]      │
└─────────────────────────┘

Step 2: Dimensions
┌─────────────────────────┐
│ Width:  [____] meters   │
│ Depth:  [____] meters   │
│ Height: [____] meters   │
│         [Back] [Next]   │
└─────────────────────────┘

Step 3: Layout Template
┌─────────────────────────┐
│ Choose template:        │
│ ○ Blank                 │
│ ○ Retail Standard       │
│ ○ Boutique              │
│ ○ Department Store      │
│ ● Import Existing       │
│         [Back] [Create] │
└─────────────────────────┘

Step 4: Confirmation
┌─────────────────────────┐
│ Store created!          │
│ [Open in 3D]            │
│ [Add Fixtures]          │
│ [Import Products]       │
└─────────────────────────┘
```

### 8.3 Navigation Transitions

```swift
struct NavigationTransitions {
    // Window to Volume
    static let windowToVolume = AnyTransition.asymmetric(
        insertion: .scale(scale: 0.8).combined(with: .opacity),
        removal: .scale(scale: 1.2).combined(with: .opacity)
    ).animation(.spring(response: 0.4, dampingFraction: 0.8))

    // Volume to Immersive
    static let volumeToImmersive = AnyTransition.opacity
        .animation(.easeInOut(duration: 1.0))

    // Between windows
    static let windowSwitch = AnyTransition.move(edge: .trailing)
        .combined(with: .opacity)
        .animation(.easeInOut(duration: 0.3))
}
```

## 9. Error States and Loading Indicators

### 9.1 Loading States

```swift
struct LoadingView: View {
    @State private var rotation: Double = 0

    var body: some View {
        VStack(spacing: 16) {
            // 3D store icon rotating
            Model3D(named: "StoreIcon") { model in
                model
                    .resizable()
                    .frame(width: 100, height: 100, depth: 100)
                    .rotation3DEffect(
                        .degrees(rotation),
                        axis: (x: 0, y: 1, z: 0)
                    )
            } placeholder: {
                ProgressView()
            }
            .onAppear {
                withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }

            Text("Loading Store...")
                .font(RetailTypography.title3)

            ProgressView(value: loadProgress, total: 1.0)
                .frame(width: 200)

            Text("\(Int(loadProgress * 100))%")
                .font(RetailTypography.caption1)
                .foregroundColor(.secondary)
        }
        .padding(40)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
    }
}
```

### 9.2 Empty States

```swift
struct EmptyStoreListView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "building.2")
                .font(.system(size: 64))
                .foregroundColor(.secondary)

            VStack(spacing: 8) {
                Text("No Stores Yet")
                    .font(RetailTypography.title2)

                Text("Create your first store to start optimizing")
                    .font(RetailTypography.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button(action: { createNewStore() }) {
                Label("Create Store", systemImage: "plus.circle.fill")
                    .font(RetailTypography.bodyEmphasis)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(60)
    }
}
```

### 9.3 Error States

```swift
struct ErrorView: View {
    let error: Error
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.warning)

            VStack(spacing: 8) {
                Text("Something Went Wrong")
                    .font(RetailTypography.title2)

                Text(error.localizedDescription)
                    .font(RetailTypography.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            HStack {
                Button(action: { dismissError() }) {
                    Text("Dismiss")
                }
                .buttonStyle(.bordered)

                Button(action: retry) {
                    Label("Try Again", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(40)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
    }
}
```

## 10. Animation and Transition Specifications

### 10.1 Animation Timings

```swift
struct AnimationTimings {
    // Quick interactions
    static let quick = Animation.easeOut(duration: 0.2)
    static let quickSpring = Animation.spring(response: 0.3, dampingFraction: 0.7)

    // Standard transitions
    static let standard = Animation.easeInOut(duration: 0.3)
    static let standardSpring = Animation.spring(response: 0.4, dampingFraction: 0.8)

    // Deliberate movements
    static let deliberate = Animation.easeInOut(duration: 0.5)
    static let deliberateSpring = Animation.spring(response: 0.6, dampingFraction: 0.75)

    // Gentle, ambient
    static let ambient = Animation.easeInOut(duration: 2.0)
}
```

### 10.2 Fixture Animations

```swift
extension FixtureEntity {
    func animatePlacement() {
        // Scale up from 0
        transform.scale = [0.01, 0.01, 0.01]

        withAnimation(AnimationTimings.standardSpring) {
            transform.scale = [1, 1, 1]
        }

        // Slight bounce
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(AnimationTimings.quickSpring) {
                transform.scale = [1.1, 1.1, 1.1]
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(AnimationTimings.quickSpring) {
                transform.scale = [1, 1, 1]
            }
        }

        // Play sound
        AudioFeedbackController.shared.playFeedback(.fixturePlace, at: position)
    }

    func animateRemoval() {
        withAnimation(AnimationTimings.quick) {
            opacity = 0
            transform.scale = [0.8, 0.8, 0.8]
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            removeFromParent()
        }

        AudioFeedbackController.shared.playFeedback(.fixtureDelete, at: position)
    }
}
```

### 10.3 Heatmap Animation

```swift
struct HeatmapAnimator {
    func animateReveal(heatmap: HeatmapEntity, duration: Double = 1.0) {
        let cells = heatmap.children

        for (index, cell) in cells.enumerated() {
            let delay = Double(index) / Double(cells.count) * duration

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(AnimationTimings.standard) {
                    cell.opacity = 0.7
                    cell.transform.scale.y = 1.0
                }
            }
        }
    }

    func animatePulse(heatmap: HeatmapEntity) {
        withAnimation(
            Animation
                .easeInOut(duration: 2.0)
                .repeatForever(autoreverses: true)
        ) {
            heatmap.opacity = 0.5
        }
    }
}
```

---

## Accessibility Design Guidelines

### VoiceOver Labels
- All interactive 3D elements must have descriptive labels
- State changes must be announced
- Context must be provided for spatial elements

### Alternative Interactions
- All pinch gestures should have tap alternatives
- Voice commands for common actions
- Keyboard shortcuts for power users

### Visual Accessibility
- High contrast mode support
- Minimum touch target: 60pt x 60pt
- Text scaling support (Dynamic Type)
- Color-blind friendly palettes

### Motion
- Respect Reduce Motion preference
- Provide static alternatives to animations
- Avoid rapid flashing or strobing effects

---

*This design specification provides comprehensive UI/UX guidelines for building an accessible, beautiful, and efficient Retail Space Optimizer experience on visionOS.*
