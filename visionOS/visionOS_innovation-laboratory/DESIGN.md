# Innovation Laboratory - UI/UX Design Specifications

## Table of Contents
1. [Spatial Design Principles](#spatial-design-principles)
2. [Window Layouts & Configurations](#window-layouts--configurations)
3. [Volume Designs](#volume-designs)
4. [Full Space Immersive Experiences](#full-space-immersive-experiences)
5. [3D Visualization Specifications](#3d-visualization-specifications)
6. [Interaction Patterns](#interaction-patterns)
7. [Visual Design System](#visual-design-system)
8. [User Flows & Navigation](#user-flows--navigation)
9. [Accessibility Design](#accessibility-design)
10. [Error States & Loading Indicators](#error-states--loading-indicators)
11. [Animation & Transition Specifications](#animation--transition-specifications)

---

## Spatial Design Principles

### Core Design Philosophy

**"Innovation Materializes in Space"**

The Innovation Laboratory transforms abstract ideas into tangible spatial objects, making innovation a physical, collaborative experience in 3D space.

### Key Principles

#### 1. Progressive Spatial Disclosure
```
Level 1: Windows → 2D interface, familiar controls
Level 2: Volumes → 3D bounded content, controlled exploration
Level 3: Immersive → Full spatial immersion, unlimited creativity
```

**Implementation**:
- Users start with familiar 2D dashboard windows
- Introduce 3D volumes for prototyping when ready
- Offer full immersion for deep creative work
- Allow easy transition between levels

#### 2. Spatial Ergonomics

**Comfortable Viewing Zones**:
```
Primary Zone (0.5m - 2m):
├── Optimal: 1.0m - 1.5m
├── Angle: 10-15° below eye level
└── Width: 60° field of view

Secondary Zone (2m - 5m):
├── Context: Ambient information
├── Angle: Peripheral awareness
└── Purpose: Spatial awareness

Far Zone (5m+):
├── Background: Environmental context
└── Purpose: Immersion and atmosphere
```

#### 3. Depth as Meaning

**Z-Axis Hierarchy**:
- **Foreground (nearest)**: Active task, current focus
- **Mid-ground**: Available tools and resources
- **Background**: Context and ambient information
- **Distant**: Environmental immersion

#### 4. Natural Interaction First

- Prefer hand gestures over abstract controls
- Use gaze for attention and selection
- Voice commands for complex operations
- Physical metaphors (grab, move, throw, assemble)

#### 5. Collaboration as Core

- Shared spatial workspace visible to all
- Individual private zones for focused work
- Clear presence indicators for team members
- Synchronized spatial transformations

---

## Window Layouts & Configurations

### 1. Innovation Dashboard Window

**Purpose**: Central hub for portfolio overview and quick access

**Layout Structure**:
```
┌─────────────────────────────────────────────────────┐
│  Innovation Laboratory              [Settings] [×]  │
├─────────────────────────────────────────────────────┤
│                                                      │
│  ┌─────────────────────────────────────────────┐   │
│  │         Innovation Velocity Metrics          │   │
│  │                                              │   │
│  │   Ideas/Week: 47  ↑ 12%                     │   │
│  │   Success Rate: 28%  ↑ 5%                   │   │
│  │   Time to Market: 4.2 months  ↓ 2 months    │   │
│  └─────────────────────────────────────────────┘   │
│                                                      │
│  ┌─────────────┐  ┌─────────────┐  ┌────────────┐  │
│  │ Recent      │  │ Active      │  │ Upcoming   │  │
│  │ Ideas (12)  │  │ Prototypes  │  │ Milestones │  │
│  │             │  │ (8)         │  │ (5)        │  │
│  │ [List]      │  │ [Cards]     │  │ [Timeline] │  │
│  └─────────────┘  └─────────────┘  └────────────┘  │
│                                                      │
│  ┌──────────────────────────────────────────────┐  │
│  │ Quick Actions                                 │  │
│  │ [Create Idea] [Start Workshop] [View Analytics]│
│  └──────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────┘
```

**Specifications**:
- Size: 1200x800 points (default)
- Material: Glass with vibrancy
- Padding: 32pt all sides
- Card corners: 16pt radius
- Grid: 12-column responsive layout

**Color Zones**:
- Metrics: Blue gradient (success indicators)
- Cards: Neutral glass with category color accents
- Actions: Prominent blue CTA buttons

### 2. Idea Canvas Window

**Purpose**: Infinite brainstorming canvas for mind mapping

**Layout Structure**:
```
┌─────────────────────────────────────────────────────┐
│  Idea Canvas - Sustainable Packaging Theme     [×]  │
├─────────────────────────────────────────────────────┤
│  [Pan] [Zoom] [Add Note] [Connect] [AI Suggest]    │
├─────────────────────────────────────────────────────┤
│                                                      │
│      ┌────────────┐         ┌────────────┐         │
│      │  Edible    │─────────│  Bio-      │         │
│      │  Materials │         │  degradable│         │
│      └────────────┘         └────────────┘         │
│           │                       │                 │
│           │    ┌────────────┐     │                │
│           └────│  Packaging │─────┘                │
│                │  Innovation│                       │
│                └────────────┘                       │
│                      │                              │
│           ┌──────────┴──────────┐                  │
│    ┌──────────┐          ┌──────────┐             │
│    │ Seaweed  │          │ Mushroom │             │
│    │ Based    │          │ Mycelium │             │
│    └──────────┘          └──────────┘             │
│                                                      │
└─────────────────────────────────────────────────────┘
```

**Specifications**:
- Size: 1400x900 points (default), expandable
- Canvas: Infinite scrolling/panning
- Sticky notes: 200x150 points
- Connections: Bezier curves, 2pt stroke
- Background: Subtle grid pattern

**Interaction**:
- Double-tap to create note
- Drag to move notes
- Drag between notes to connect
- Pinch to zoom (0.5x - 3x)
- AI button generates related ideas

### 3. Analytics Dashboard Window

**Purpose**: Real-time innovation metrics and insights

**Layout Structure**:
```
┌─────────────────────────────────────────────────────┐
│  Analytics Dashboard                           [×]  │
├─────────────────────────────────────────────────────┤
│  [This Week] [This Month] [This Quarter] [Custom]  │
├─────────────────────────────────────────────────────┤
│                                                      │
│  ┌──────────────────────────────────────────────┐  │
│  │         Innovation Pipeline Flow              │  │
│  │                                               │  │
│  │  Ideas → Prototypes → Testing → Launch       │  │
│  │   147      42          18        5            │  │
│  │   [████]   [███░]      [██░░]    [█░░░]      │  │
│  └──────────────────────────────────────────────┘  │
│                                                      │
│  ┌──────────────────┐    ┌────────────────────┐   │
│  │ Success Rate     │    │ Time to Market     │   │
│  │                  │    │                    │   │
│  │ [Trend Chart]    │    │ [Bar Chart]        │   │
│  └──────────────────┘    └────────────────────┘   │
│                                                      │
│  ┌──────────────────────────────────────────────┐  │
│  │ Top Innovators         Category Distribution │  │
│  │ [Leaderboard]          [Pie Chart]           │  │
│  └──────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────┘
```

**Specifications**:
- Size: 1000x700 points
- Charts: Swift Charts framework
- Colors: Data-driven gradients
- Refresh: Real-time WebSocket updates
- Export: PDF and CSV buttons

### 4. Settings Window

**Purpose**: App configuration and integrations

**Layout Structure**:
```
┌─────────────────────────────────────────────┐
│  Settings                              [×]  │
├─────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────────────┐  │
│  │ General     │  │ User Profile         │  │
│  │ Appearance  │  │ ┌─────────────────┐ │  │
│  │ Integrations│◀─│ │  [Avatar]       │ │  │
│  │ Privacy     │  │ │  Name: ...      │ │  │
│  │ Collaboration│  │ └─────────────────┘ │  │
│  │ Accessibility│  │                     │  │
│  │ About       │  │ [Settings controls] │  │
│  └─────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────┘
```

**Specifications**:
- Size: 600x500 points
- Layout: Sidebar + detail pane
- Style: Native visionOS settings style
- Forms: Grouped form fields

---

## Volume Designs

### 1. Prototype Workshop Volume

**Purpose**: 3D modeling and prototype manipulation

**Physical Dimensions**: 800mm × 600mm × 600mm

**Layout**:
```
         Top View
    ┌────────────┐
    │  Tool      │
    │  Palette   │
    ├────────────┤
    │            │
    │  Working   │
    │  Area      │
    │            │
    ├────────────┤
    │  Material  │
    │  Library   │
    └────────────┘

     Front View              Side View
    ┌──────────┐            ┌──────┐
    │          │            │      │
    │  Proto-  │            │ Grid │
    │  type    │            │ Work │
    │  Here    │            │ Area │
    │          │            │      │
    └──────────┘            └──────┘
```

**Content Zones**:

**Top Zone (Y: 400-600mm)**:
- Floating tool palette
- Action buttons (Save, Test, Export)
- Properties panel

**Middle Zone (Y: 100-400mm)**:
- Primary workspace
- Prototype manipulation area
- Grid reference plane at Y=100mm

**Bottom Zone (Y: 0-100mm)**:
- Material library cards
- Component browser
- Recently used tools

**Lighting**:
```swift
// Three-point lighting setup
let keyLight: DirectionalLight = {
    position: (0.5, 0.8, 0.5),
    intensity: 1000,
    color: .white
}

let fillLight: DirectionalLight = {
    position: (-0.3, 0.5, -0.3),
    intensity: 400,
    color: .white
}

let rimLight: DirectionalLight = {
    position: (0, 0.3, -1),
    intensity: 600,
    color: Color(white: 0.9)
}
```

**Materials**:
- Workshop floor: Matte gray grid
- Tools: Glossy metal
- Prototypes: PBR materials with realistic properties
- Bounds: Subtle glass container

### 2. Innovation Universe Volume

**Purpose**: Explore ideas as 3D constellation

**Physical Dimensions**: 1200mm × 1000mm × 800mm

**Layout**:
```
         Spatial Layout

         ★ Ideas (spheres)
       /   \
      /     \
     ★       ★  Connected ideas
    / \     / \
   ★   ★   ★   ★

   Color coding:
   🔵 New ideas
   🟢 Validated ideas
   🟡 In progress
   🔴 Needs attention
```

**Visual Elements**:

**Idea Spheres**:
- Radius: 40-80mm (based on impact score)
- Material: Translucent glass with inner glow
- Color: Status-based gradient
- Label: Floating text below sphere
- Animation: Gentle floating/pulsing

**Connection Lines**:
- Material: Glowing energy beam
- Width: 2-5mm (relationship strength)
- Color: Metallic silver
- Animation: Flowing particles along path

**Background**:
- Particle field: Subtle stars/sparkles
- Fog: Depth cueing for distant ideas
- Environment: Dark nebula gradient

**Interaction**:
- Gaze at sphere: Highlight + show details
- Pinch sphere: Select and focus
- Pull sphere: Bring closer for detail view
- Push sphere: Send to background

### 3. Market Simulator Volume

**Purpose**: Simulate customer interaction with prototype

**Physical Dimensions**: 1000mm × 800mm × 600mm

**Layout**:
```
    ┌─────────────────────────┐
    │   Retail Environment    │
    │                         │
    │   [Shelf] [Customer]    │
    │   [Product Display]     │
    │                         │
    │   Heat Map Overlay      │
    └─────────────────────────┘
```

**Environments**:

**Retail Store**:
- Product on shelf
- Virtual customers approaching
- Purchase decision visualization
- Heat maps for attention

**Home Use**:
- Product in context
- User interaction simulation
- Ergonomics visualization
- Usage pattern flows

**Competitive Context**:
- Side-by-side comparison
- Market positioning map
- Feature matrix 3D

**Data Visualization**:
- Heat maps: Red (high interest) to blue (low)
- Flow paths: Animated customer movements
- Metrics: Floating stats panels
- Timeline: Scrubber for playback

---

## Full Space Immersive Experiences

### 1. Innovation Laboratory (Full Immersive)

**Purpose**: Complete innovation workspace with all tools

**Spatial Layout**:
```
                    Top-Down View

         Analytics Zone
              ↑
              │
    ┌─────────┼─────────┐
    │         │         │
    │  Proto  │  Idea   │  Testing
    │  Zone   │  Zone   │  Zone
    │         │         │
    │    ←────●────→    │
    │         │         │
    │         │         │
    └─────────┼─────────┘
              │
              ↓
        Collaboration Zone

    ● = User position (center)
```

**Zone Specifications**:

**Ideation Zone (Front, 0-5m)**:
- Infinite canvas at 2m distance
- Floating idea spheres
- AI assistant avatar
- Mind map visualization

**Prototyping Zone (Left, 2-4m)**:
- 3D modeling workspace
- Tool palettes
- Material library
- Component browser

**Testing Zone (Right, 2-4m)**:
- Simulation environments
- Testing controls
- Results visualization
- Feedback capture

**Analytics Zone (Above, 2m height)**:
- Floating metrics displays
- Real-time charts
- Pipeline visualization
- Portfolio overview

**Collaboration Zone (Behind, 2-3m)**:
- Team member avatars
- Shared workspace
- Communication tools
- Activity feed

**Environmental Design**:
- Floor: Subtle grid fading to infinity
- Walls: None (boundless)
- Ceiling: Distant gradient to space
- Lighting: Soft ambient + zone spotlights
- Atmosphere: Light fog for depth

**Immersion Levels**:
```swift
.progressive levels:
  - Mixed (10%): See passthrough, overlay UI
  - Balanced (50%): Blend real and virtual
  - Full (100%): Complete immersion
```

### 2. Prototype Testing Chamber

**Purpose**: Immersive product testing simulation

**Spatial Layout**:
```
    360° Environment

         ╔════════════╗
         ║  Testing   ║
         ║  Scenario  ║
         ║            ║
         ║     ●      ║  ← User
         ║            ║
         ║  [Product] ║
         ╚════════════╝
```

**Testing Environments**:

**Laboratory**:
- White clean room aesthetic
- Controlled lighting
- Testing equipment
- Measurement tools

**Retail Environment**:
- Store shelves and displays
- Ambient shoppers
- Realistic lighting
- Point-of-sale context

**Home Environment**:
- Living room / kitchen
- Natural lighting
- Furniture and context
- Daily use scenarios

**Outdoor Scene**:
- Park or street setting
- Natural lighting
- Weather simulation
- Environmental context

**Interactive Testing**:
- Grab and manipulate product
- Trigger stress tests
- Record user feedback
- Capture usage patterns

---

## 3D Visualization Specifications

### Idea Visualization

**Concept**: Ideas as glowing spheres with metadata halos

**Visual Properties**:
```swift
struct IdeaSphere {
    // Geometry
    radius: 40-80mm (novelty score based)
    segments: 64 (smooth sphere)

    // Materials
    base: TranslucentGlassMaterial
    glow: EmissiveMaterial(intensity: 0.3-0.8)

    // Colors by status
    ideation: Blue (#007AFF, alpha: 0.7)
    evaluation: Purple (#AF52DE, alpha: 0.7)
    prototyping: Orange (#FF9500, alpha: 0.7)
    validated: Green (#34C759, alpha: 0.7)
    launched: Gold (#FFD700, alpha: 0.9)

    // Animation
    float: Sine wave (amplitude: 10mm, period: 3s)
    pulse: Scale 1.0-1.05 (period: 2s)
    rotation: Slow spin (360° per 60s)
}
```

**Metadata Display**:
```
    ┌─────────────────┐
    │   ✨            │  ← Idea sphere with glow
    │    [Sphere]     │
    │                 │
    └─────────────────┘
          │
          ↓
    "Sustainable Packaging"
    Novelty: ████░ 0.85
    Impact: ███░░ 0.72
```

### Prototype Visualization

**Concept**: Realistic 3D models with physics properties

**Visual Properties**:
```swift
struct PrototypeModel {
    // Geometry
    mesh: HighDetailMesh (LOD: 3 levels)
    materials: PBR materials

    // Physics visualization
    boundingBox: Wireframe when selected
    centerOfMass: Red sphere (10mm)
    collisionShape: Transparent green overlay

    // States
    normal: Full color, PBR materials
    selected: Blue outline (5mm glow)
    dragging: Semi-transparent (0.7 alpha)
    testing: Highlight stress points

    // Annotations
    dimensions: Floating measurements
    properties: Info panel on hover
    status: Badge (top-right corner)
}
```

### Connection Visualization

**Concept**: Energy beams linking related concepts

**Visual Properties**:
```swift
struct IdeaConnection {
    // Geometry
    path: Bezier curve between spheres
    width: 2-5mm (relationship strength)

    // Material
    base: Metallic silver
    emissive: Glow effect

    // Animation
    particles: Flow along path
    speed: 0.5m/s
    density: 10 particles per meter

    // Colors by type
    similarity: Silver
    dependency: Blue
    evolution: Green
    contradiction: Red (dashed)
}
```

### Analytics Visualization

**Concept**: 3D data charts and graphs

**Chart Types**:

**1. Pipeline Flow (Sankey Diagram)**:
```
Ideas ═══════════╗
                 ║
Prototypes ══════╬══╗
                 ║  ║
Testing ═════════╬══╬═╗
                 ║  ║ ║
Launch ══════════╩══╩═╩═→
```

**2. Success Rate (3D Bar Chart)**:
```
    Height = Success %
    ┌─┐
 30%│█│
    │█│┌─┐
 20%│█││█│┌─┐
    │█││█││█│
 10%│█││█││█│┌─┐
    └─┘└─┘└─┘└─┘
    Q1 Q2 Q3 Q4
```

**3. Innovation Velocity (3D Scatter)**:
```
     Impact
       ↑
       │  ●
       │    ● ●
       │ ●
       │     ● ●
       └────────→ Time
```

---

## Interaction Patterns

### Gaze and Pinch Gestures

**Primary Interactions**:

**1. Selection**:
```
User Flow:
1. Look at object (gaze)
2. Object highlights (visual feedback)
3. Pinch thumb+index (indirect)
4. Object selected (confirmation)

Visual Feedback:
- Gaze: Subtle glow (+20% brightness)
- Hover: Scale 1.05x
- Pinch: Blue outline appears
- Selected: Persistent blue outline
```

**2. Manipulation**:
```
User Flow:
1. Gaze + pinch to select
2. Hold pinch + move hand
3. Object follows hand position
4. Release pinch to place

Visual Feedback:
- Dragging: Object semi-transparent
- Valid drop: Green zone highlight
- Invalid drop: Red zone highlight
- Dropped: Return to full opacity
```

### Direct Hand Interaction

**1. Grab and Move**:
```
Gesture: Closed fist near object
Action: Direct manipulation
Feedback: Haptic pulse on grab
Visual: Object "sticks" to hand

Code pattern:
.gesture(DragGesture()
    .targetedToEntity(entity)
    .onChanged { moveEntity($0) }
)
```

**2. Two-Handed Scale**:
```
Gesture: Pinch both hands on object
Action: Scale uniformly
Feedback: Visual scale indicators
Constraint: 0.5x - 3.0x limits

Code pattern:
.gesture(MagnifyGesture()
    .onChanged { scaleEntity($0) }
)
```

**3. Rotation**:
```
Gesture: Grab + rotate hand
Action: Rotate around axis
Feedback: Rotation guides appear
Snap: 15° increments (optional)

Code pattern:
.gesture(RotateGesture3D()
    .onChanged { rotateEntity($0) }
)
```

### Custom Innovation Gestures

**1. Idea Spark**:
```
Gesture: Open palm upward motion
Action: Generate new idea
Visual: Sparkle particle effect
Sound: Ascending chime

Recognition:
- Palm facing up (>0.8 dot product)
- All fingers extended
- Upward velocity (>0.5 m/s)
```

**2. Connection Draw**:
```
Gesture: Point index finger + draw
Action: Link two ideas
Visual: Beam follows finger
Sound: Whoosh on connection

Recognition:
- Index extended, others closed
- Movement detected
- Ray casting to target
```

**3. Brainstorm Explosion**:
```
Gesture: Hands together → spread apart
Action: Trigger AI ideation
Visual: Energy burst effect
Sound: Explosion with echo

Recognition:
- Hands < 10cm apart
- Rapid separation (>1 m/s)
- Both hands moving outward
```

---

## Visual Design System

### Color Palette

**Primary Colors**:
```swift
// Brand Colors
innovationBlue   = Color(hex: "#007AFF")  // Primary actions
creativePurple   = Color(hex: "#AF52DE")  // Creativity features
successGreen     = Color(hex: "#34C759")  // Validation/success
warningOrange    = Color(hex: "#FF9500")  // Attention needed
criticalRed      = Color(hex: "#FF3B30")  // Errors/blocking

// Neutrals (for glass materials)
glassLight       = Color(white: 1.0, opacity: 0.15)
glassMedium      = Color(white: 1.0, opacity: 0.10)
glassDark        = Color(white: 0.0, opacity: 0.20)
```

**Status Colors**:
```swift
// Idea Status
ideation         = Color(hex: "#007AFF")  // Blue
evaluation       = Color(hex: "#AF52DE")  // Purple
prototyping      = Color(hex: "#FF9500")  // Orange
testing          = Color(hex: "#5856D6")  // Indigo
validated        = Color(hex: "#34C759")  // Green
launched         = Color(hex: "#FFD700")  // Gold
archived         = Color(hex: "#8E8E93")  // Gray
```

**Semantic Colors**:
```swift
// Context-based
aiSuggestion     = Color(hex: "#5E5CE6")  // Purple-blue
collaboration    = Color(hex: "#FF2D55")  // Pink
analytics        = Color(hex: "#00C7BE")  // Teal
innovation       = Color(hex: "#FF9500")  // Orange
```

### Typography

**Font System**:
```swift
// San Francisco (system font)

// Hierarchy
largeTitle       = .system(size: 34, weight: .bold)
title1           = .system(size: 28, weight: .bold)
title2           = .system(size: 22, weight: .bold)
title3           = .system(size: 20, weight: .semibold)
headline         = .system(size: 17, weight: .semibold)
body             = .system(size: 17, weight: .regular)
callout          = .system(size: 16, weight: .regular)
subheadline      = .system(size: 15, weight: .regular)
footnote         = .system(size: 13, weight: .regular)
caption1         = .system(size: 12, weight: .regular)
caption2         = .system(size: 11, weight: .regular)
```

**Spatial Text Rendering**:
```swift
// 3D text specifications
struct SpatialText {
    font: SF Pro Rounded
    depth: 20mm extrusion
    material: Metallic or Glass
    billboarding: Face user (optional)
    maxDistance: 5m (readable)
    minSize: 14pt (minimum)
}
```

### Materials & Lighting

**Glass Materials**:
```swift
// visionOS glass backgrounds
ultraThinMaterial      // Subtle, minimal obstruction
thinMaterial           // Standard glass
regularMaterial        // More prominent
thickMaterial          // Strong separation
ultraThickMaterial     // Maximum separation

// With vibrancy
.background(.ultraThinMaterial)
.backgroundStyle(.vibrancy)
```

**3D Materials**:
```swift
// PBR Material Properties
struct InnovationMaterial {
    // Idea Sphere
    ideaGlass: {
        baseColor: Status color
        roughness: 0.1 (smooth)
        metallic: 0.0
        opacity: 0.7
        emissive: Glow color
    }

    // Prototype
    prototypeMetal: {
        baseColor: .white
        roughness: 0.3
        metallic: 0.9
        clearcoat: 0.5
    }

    // Connection
    connectionBeam: {
        baseColor: .silver
        emissive: Bright glow
        blendMode: .additive
    }
}
```

**Lighting**:
```swift
// Scene lighting setup
struct SceneLighting {
    // Image-based lighting
    ibl: "innovation_lab_env.exr"

    // Key light (main illumination)
    keyLight: DirectionalLight(
        intensity: 1000,
        color: .white,
        direction: (0.5, -0.8, 0.5)
    )

    // Fill light (soften shadows)
    fillLight: DirectionalLight(
        intensity: 400,
        color: Color(temperature: 6500),
        direction: (-0.3, -0.5, -0.3)
    )

    // Rim light (edge definition)
    rimLight: DirectionalLight(
        intensity: 600,
        color: Color(hue: 0.6, sat: 0.2, bright: 1.0),
        direction: (0, 0.3, -1)
    )
}
```

### Iconography

**Icon System**:
```swift
// SF Symbols 6.0
icons = [
    // Core actions
    "lightbulb": Create idea
    "cube": Prototype
    "flask": Test/experiment
    "chart.bar": Analytics
    "person.2": Collaboration

    // Innovation specific
    "sparkles": AI suggestions
    "brain": Ideation
    "hammer": Build/create
    "scope": Focus/explore
    "network": Connections

    // Status indicators
    "checkmark.circle": Validated
    "clock": In progress
    "exclamationmark.triangle": Needs attention
    "star.fill": Breakthrough
    "archive": Archived
]
```

**Custom 3D Icons**:
```swift
// 3D icon specifications
struct Icon3D {
    size: 80mm × 80mm × 80mm
    polyCount: <1000 triangles
    material: Single color + glow
    animation: Idle loop (subtle)
    hitArea: 120mm sphere (easy tap)
}
```

---

## User Flows & Navigation

### Primary User Journey

**1. App Launch → Dashboard**:
```
Launch App
    ↓
[Loading Animation: Innovation Lab logo pulse]
    ↓
Dashboard Window Opens (1.5m, center, 10° below eye)
    ↓
Show: Portfolio metrics, recent activity, quick actions
    ↓
User orients and reviews current state
```

**2. Create New Idea**:
```
Dashboard → "Create Idea" button
    ↓
Idea Canvas window opens (2m, left)
    ↓
Tap canvas → Sticky note appears
    ↓
Voice or keyboard: Enter idea details
    ↓
AI suggestion: Related ideas appear nearby
    ↓
Connect related ideas with gesture
    ↓
Save → Idea appears in dashboard
```

**3. Prototype an Idea**:
```
Select idea from dashboard
    ↓
Tap "Start Prototyping"
    ↓
Prototype Workshop volume opens (1.5m, center)
    ↓
AI generates initial 3D concept
    ↓
User refines with hand gestures:
  - Grab and reshape
  - Scale and rotate
  - Modify materials
    ↓
Apply physics properties
    ↓
Save prototype version
```

**4. Test Prototype**:
```
Select prototype
    ↓
Tap "Run Simulation"
    ↓
Market Simulator volume opens
    ↓
Choose environment (retail/home/outdoor)
    ↓
Watch AI customers interact
    ↓
View heat maps and metrics
    ↓
Record insights and feedback
    ↓
Iterate on prototype based on results
```

**5. Collaborate on Innovation**:
```
Open prototype/idea
    ↓
Tap "Invite Team"
    ↓
Select team members from list
    ↓
SharePlay session starts
    ↓
All users see shared workspace
    ↓
Collaborate in real-time:
  - Shared manipulations
  - Voice communication
  - Presence indicators
    ↓
Save collaborative session
```

### Navigation Patterns

**Window Management**:
```swift
// User can open multiple windows
Commands:
  - Voice: "Show analytics"
  - Gesture: Gaze + pinch window button
  - Keyboard: Cmd+1, Cmd+2, etc.

Layout:
  - System manages window placement
  - User can reposition freely
  - Windows persist between sessions
```

**Spatial Navigation**:
```swift
// Moving through immersive space
Methods:
  1. Physical movement (room-scale)
  2. Teleport gesture (point + pinch)
  3. Grab and pull environment
  4. Zone shortcuts (gaze + voice)

Orientation:
  - Compass in corner (always visible)
  - Return to center gesture
  - Mini-map (optional overlay)
```

**Cross-Experience Transitions**:
```swift
Window → Volume:
  - Expand button on window
  - Smooth 3D transformation
  - Duration: 0.8s spring animation

Volume → Immersive:
  - "Enter Lab" button
  - Fade transition (0.5s)
  - Progressive immersion control

Back Navigation:
  - Universal back gesture (swipe)
  - Home button (returns to dashboard)
  - Breadcrumb trail (top of view)
```

---

## Accessibility Design

### VoiceOver Support

**Spatial Element Description**:
```swift
// 3D entity accessibility
ideaSphere.accessibilityLabel = "Idea: Sustainable Packaging"
ideaSphere.accessibilityValue = "Novelty score 0.85, Feasibility 0.72"
ideaSphere.accessibilityHint = "Double tap to view details, two finger swipe right for options"
ideaSphere.accessibilityTraits = [.isButton, .allowsDirectInteraction]
```

**Spatial Audio Feedback**:
```swift
// Audio description of spatial layout
VoiceOver: "Innovation Dashboard, 1 meter ahead.
            Idea Universe volume, 2 meters to your left.
            Prototype Workshop, 1.5 meters ahead and right."
```

### Reduced Motion

**Alternative Animations**:
```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

// Animation variants
var ideaPulseAnimation: Animation {
    reduceMotion ? .none : .easeInOut(duration: 2).repeatForever()
}

var connectionFlowAnimation: Animation {
    reduceMotion ? .none : .linear(duration: 3).repeatForever(autoreverses: false)
}

// Disable particle effects if reduce motion enabled
if !reduceMotion {
    entity.addParticleSystem()
}
```

### Increase Contrast

**High Contrast Mode**:
```swift
@Environment(\.accessibilityIncreaseContrast) var increaseContrast

var ideaColor: Color {
    increaseContrast ?
        .blue :  // Solid blue (high contrast)
        Color.blue.opacity(0.7)  // Translucent (normal)
}

var outlineWidth: CGFloat {
    increaseContrast ? 3 : 1
}
```

### Larger Text

**Dynamic Type**:
```swift
// All text supports dynamic type
Text("Innovation Laboratory")
    .font(.largeTitle)  // Automatically scales
    .dynamicTypeSize(...DynamicTypeSize.xxxLarge)

// 3D text scales with accessibility settings
var spatialTextSize: Float {
    sizeCategory.isAccessibilityCategory ?
        48 :  // Large for accessibility
        36    // Standard
}
```

### Alternative Inputs

**Voice Commands**:
```
"Create new idea"
"Show prototype workshop"
"Start simulation"
"Invite team"
"Show analytics"
"Go back"
"Close window"
```

**Keyboard Shortcuts**:
```
Cmd + N: New idea
Cmd + P: New prototype
Cmd + T: Run test
Cmd + K: Invite team
Cmd + D: Dashboard
Cmd + W: Close window
Cmd + ,: Settings
```

**Switch Control**:
- All interactive elements focusable
- Logical tab order
- Clear focus indicators
- Grouped controls

---

## Error States & Loading Indicators

### Loading States

**App Launch**:
```
[Animation]
  ┌─────────────┐
  │      ✨     │  ← Glowing logo
  │   [Pulse]   │     Gentle pulse
  │             │     Fade in/out
  └─────────────┘

  "Innovation Laboratory"
  Loading your workspace...
```

**Content Loading**:
```swift
// Skeleton screens for data loading
struct IdeaCardSkeleton: View {
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(.gray.opacity(0.2))
                .frame(height: 100)
                .shimmer()  // Animated shimmer effect

            RoundedRectangle(cornerRadius: 4)
                .fill(.gray.opacity(0.2))
                .frame(width: 150, height: 20)
                .shimmer()
        }
    }
}
```

**3D Model Loading**:
```
Volume Space:
  ┌─────────────────┐
  │                 │
  │   ⟳            │  ← Spinning wireframe
  │   [Loading]     │    Low-poly placeholder
  │                 │    Progress indicator
  │   68%           │
  └─────────────────┘
```

**AI Processing**:
```
  [Brain Icon Animated]

  "AI is generating ideas..."

  ⚡⚡⚡ [Animated sparkles]

  [Progress bar: 0% → 100%]
```

### Error States

**Network Error**:
```
  ┌───────────────────────────┐
  │    ⚠️                     │
  │                           │
  │ Unable to connect         │
  │                           │
  │ Check your connection and │
  │ try again.                │
  │                           │
  │  [Retry]    [Dismiss]     │
  └───────────────────────────┘
```

**AI Service Error**:
```
  ┌───────────────────────────┐
  │    🤖❌                   │
  │                           │
  │ AI service unavailable    │
  │                           │
  │ Working offline. AI       │
  │ features will resume when │
  │ connection is restored.   │
  │                           │
  │  [OK]                     │
  └───────────────────────────┘
```

**Validation Error**:
```
  [Input Field with red outline]

  ⚠️ Idea title is required

  Please enter a title for your idea
  to continue.
```

**3D Model Error**:
```
Volume Space:
  ┌─────────────────┐
  │    [❌]         │
  │                 │
  │ Failed to load  │
  │ 3D model        │
  │                 │
  │ [Try Again]     │
  │ [Use Default]   │
  └─────────────────┘
```

### Empty States

**No Ideas Yet**:
```
  ┌───────────────────────────┐
  │                           │
  │        💡                 │
  │                           │
  │   Start Innovating!       │
  │                           │
  │   Your brilliant ideas    │
  │   will appear here.       │
  │                           │
  │   [Create Your First Idea]│
  │                           │
  └───────────────────────────┘
```

**No Prototypes**:
```
  ┌───────────────────────────┐
  │                           │
  │        🔧                 │
  │                           │
  │   Ready to Prototype?     │
  │                           │
  │   Turn your ideas into    │
  │   tangible innovations.   │
  │                           │
  │   [Start Prototyping]     │
  │                           │
  └───────────────────────────┘
```

**Search No Results**:
```
  ┌───────────────────────────┐
  │        🔍                 │
  │                           │
  │   No results for          │
  │   "sustainable packaging" │
  │                           │
  │   Try different keywords  │
  │   or create a new idea.   │
  │                           │
  │   [Create Idea]           │
  └───────────────────────────┘
```

---

## Animation & Transition Specifications

### Window Animations

**Window Open**:
```swift
// Scale and fade in
Animation: .spring(duration: 0.5, bounce: 0.2)

Keyframes:
  0%:   scale(0.8), opacity(0)
  40%:  scale(1.05), opacity(1)
  100%: scale(1.0), opacity(1)
```

**Window Close**:
```swift
// Fade and scale out
Animation: .easeOut(duration: 0.3)

Keyframes:
  0%:   scale(1.0), opacity(1)
  100%: scale(0.9), opacity(0)
```

**Window Minimize**:
```swift
// Genie effect to home button
Animation: .easeInOut(duration: 0.6)

Path: Bezier curve from window to icon
Scale: Shrink to point
```

### Volume Animations

**Volume Expand (from window)**:
```swift
// Transform 2D → 3D
Animation: .spring(duration: 0.8, bounce: 0.15)

Keyframes:
  0%:   depth(0), 2D plane
  30%:  depth(0.2m), partial 3D
  60%:  depth(0.5m), growing
  100%: depth(0.6m), full volume

Rotation: Gentle tilt forward during expansion
```

**Volume Collapse (to window)**:
```swift
// Transform 3D → 2D
Animation: .easeInOut(duration: 0.6)

Keyframes:
  0%:   depth(0.6m), full volume
  40%:  depth(0.3m), compressing
  70%:  depth(0.1m), almost flat
  100%: depth(0), 2D plane
```

### Immersive Transitions

**Enter Immersive Space**:
```swift
// Progressive immersion
Animation: .easeInOut(duration: 1.5)

Phases:
  1. Darken passthrough (0-0.5s)
  2. Scale virtual content (0.3-0.9s)
  3. Full immersion (0.9-1.5s)

Audio: Spatial ambience fades in
```

**Exit Immersive Space**:
```swift
// Return to passthrough
Animation: .easeOut(duration: 1.0)

Phases:
  1. Fade virtual content (0-0.4s)
  2. Restore passthrough (0.3-0.7s)
  3. Show windows (0.6-1.0s)

Audio: Spatial ambience fades out
```

### Entity Animations

**Idea Sphere Idle**:
```swift
// Gentle float and pulse
Animation: .easeInOut.repeatForever()

Float (Y-axis):
  Amplitude: 10mm
  Period: 3s
  Function: sin(time * 2π / 3)

Pulse (scale):
  Min: 1.0
  Max: 1.05
  Period: 2s
  Function: 1 + 0.05 * sin(time * 2π / 2)

Rotation (Y-axis):
  Speed: 360° per 60s
  Function: time * 6° per second
```

**Idea Selection**:
```swift
// Pop and highlight
Animation: .spring(duration: 0.4, bounce: 0.3)

Keyframes:
  0%:   scale(1.0), glow(0.3)
  50%:  scale(1.15), glow(0.8)
  100%: scale(1.1), glow(0.6)

Outline: Blue ring appears (0.2s fade in)
```

**Connection Draw**:
```swift
// Beam grows from point A to B
Animation: .linear(duration: 0.5)

Phases:
  1. Sparkle at point A (0-0.1s)
  2. Beam extends (0.1-0.4s)
  3. Sparkle at point B (0.4-0.5s)
  4. Particles flow (continuous)

Curve: Bezier path with gravity sag
```

**Prototype Manipulation**:
```swift
// Follow hand with spring physics
Animation: .interactiveSpring()

Damping: 0.7 (slight overshoot)
Response: 0.3 (quick response)
Blend: Hand position interpolated

Shadow: Updates in real-time
Collision: Haptic feedback on contact
```

### Micro-interactions

**Button Hover**:
```swift
// Subtle scale and glow
Animation: .easeOut(duration: 0.2)

Hover:
  scale(1.05)
  brightness(+10%)
  shadow(radius: 4)
```

**Button Tap**:
```swift
// Press and release
Animation: .easeInOut(duration: 0.1)

Press:   scale(0.95)
Release: scale(1.0) with spring
Haptic:  Light impact
Sound:   Click (50ms)
```

**Card Flip**:
```swift
// Reveal back content
Animation: .easeInOut(duration: 0.6)

Rotation: 0° → 180° (Y-axis)
Perspective: 1000 distance
Backface: Hidden until 90°
```

**List Item Add**:
```swift
// Slide in from top
Animation: .spring(duration: 0.6, bounce: 0.2)

Initial:  offsetY(-100), opacity(0)
Final:    offsetY(0), opacity(1)
Delay:    Stagger by 0.05s per item
```

### Loading Animations

**Spinner**:
```swift
// Rotating circle
Animation: .linear.repeatForever(autoreverses: false)

Rotation: 360° per 1s
Stroke: Dashed circle (25% arc)
Color: Gradient (blue → purple)
```

**Shimmer Effect**:
```swift
// Animated gradient sweep
Animation: .linear(duration: 1.5).repeatForever()

Gradient:
  Stops: [
    (0.0, clear),
    (0.5, white.opacity(0.3)),
    (1.0, clear)
  ]

Movement: -100% → +100% position
Angle: 45° diagonal
```

**Progress Bar**:
```swift
// Fill from left to right
Animation: .linear or .easeOut

Width: 0% → progress% → 100%
Color: Blue gradient
Height: 4pt
Corners: 2pt radius

Indeterminate mode:
  Segment moves back/forth
  Duration: 1.2s per cycle
```

---

## Conclusion

This design specification provides comprehensive UI/UX guidelines for the Innovation Laboratory visionOS application. Key design achievements:

1. **Spatial-First Design**: Leveraging 3D space meaningfully
2. **Progressive Disclosure**: Windows → Volumes → Immersive
3. **Natural Interactions**: Hand gestures, gaze, voice
4. **Comprehensive Accessibility**: VoiceOver, dynamic type, reduced motion
5. **Beautiful & Functional**: Glass materials, PBR rendering, smooth animations
6. **Collaboration-Focused**: Shared spaces, presence indicators
7. **Innovation-Optimized**: Custom gestures for creative workflows

The design creates an intuitive, delightful experience that transforms corporate innovation through spatial computing.
