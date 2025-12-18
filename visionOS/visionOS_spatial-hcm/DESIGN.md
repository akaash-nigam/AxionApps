# Spatial HCM - Design Specifications

## Table of Contents
1. [Spatial Design Principles](#spatial-design-principles)
2. [Window Layouts & Configurations](#window-layouts--configurations)
3. [Volume Designs (3D Bounded Spaces)](#volume-designs-3d-bounded-spaces)
4. [Immersive Experiences](#immersive-experiences)
5. [3D Visualization Specifications](#3d-visualization-specifications)
6. [Interaction Patterns](#interaction-patterns)
7. [Visual Design System](#visual-design-system)
8. [User Flows & Navigation](#user-flows--navigation)
9. [Accessibility Design](#accessibility-design)
10. [Error States & Loading Indicators](#error-states--loading-indicators)
11. [Animations & Transitions](#animations--transitions)

---

## Spatial Design Principles

### Core Design Philosophy

**Human-Centered Spatial Computing**
- Design for human understanding, not technical complexity
- Leverage spatial relationships to convey organizational structure naturally
- Create intuitive 3D metaphors that match real-world mental models
- Balance immersion with usability—progressively reveal depth

### Key Principles

#### 1. Spatial Hierarchy
```
Depth-Based Information Architecture
├── 0.5-1m: Personal/Detail Layer
│   ├── Employee profiles
│   ├── Quick actions
│   └── Notifications
│
├── 1-2m: Team/Relationship Layer
│   ├── Team visualizations
│   ├── Collaboration spaces
│   └── Performance dashboards
│
└── 2-5m: Organization/Strategic Layer
    ├── Full org chart
    ├── Talent analytics
    └── Strategic planning
```

#### 2. Progressive Disclosure
- Start with 2D windows for familiarity
- Introduce volumetric content gradually
- Reserve full immersion for power users
- Always provide an "escape hatch" to simpler views

#### 3. Ergonomic Positioning
- **Primary content**: 10-15° below eye level (reduces neck strain)
- **Frequently accessed tools**: Within 60° field of view
- **Contextual panels**: Peripheral placement (±30°)
- **Distance**: 1-2m for primary interaction

#### 4. Visual Clarity
- Use depth to separate information layers
- Employ lighting to guide attention
- Maintain sufficient contrast in spatial environment
- Avoid visual clutter in 3D space

#### 5. Natural Interactions
- Leverage intuitive gestures (tap, drag, pinch)
- Provide immediate visual feedback
- Use spatial audio for confirmation
- Support muscle memory through consistent patterns

---

## Window Layouts & Configurations

### 1. Main Dashboard Window

**Purpose**: Primary entry point and control center

**Dimensions**: 900x700 points

**Layout Structure**:
```
┌─────────────────────────────────────────┐
│  [User Avatar]  Spatial HCM    [Settings]│  <- Header (60pt)
├─────────────────────────────────────────┤
│  ┌──────────┐  ┌──────────┐  ┌────────┐ │
│  │  Team    │  │  Analytics│  │ Alerts │ │  <- Quick Stats Cards
│  │  Overview│  │  Summary  │  │  (3)   │ │     (200x120pt each)
│  └──────────┘  └──────────┘  └────────┘ │
├─────────────────────────────────────────┤
│  Recent Activity                         │  <- Activity Feed
│  ┌─────────────────────────────────────┐│     (Scrollable)
│  │ • John Doe completed Q2 review      ││
│  │ • New employee Sarah joined team    ││
│  │ • Performance cycle starts next week││
│  └─────────────────────────────────────┘│
├─────────────────────────────────────────┤
│  Quick Actions                           │
│  [View Org Chart] [Team Health] [Reports]│  <- Action Buttons
└─────────────────────────────────────────┘
```

**Materials**: Glass background with frosted blur

**Visual Hierarchy**:
1. User identity (top-left)
2. Quick stats (most important metrics)
3. Activity feed (what's happening now)
4. Actions (what can I do)

### 2. Employee Profile Window

**Purpose**: Detailed employee information and management

**Dimensions**: 700x900 points

**Layout**:
```
┌─────────────────────────────────────────┐
│  ← Back        John Doe            Edit │  <- Navigation
├─────────────────────────────────────────┤
│  ┌────────┐  Senior Software Engineer  │
│  │ Photo  │  Engineering • 5 yrs tenure│  <- Identity Section
│  │        │  San Francisco, CA         │
│  └────────┘  [Message] [Schedule 1:1]  │
├─────────────────────────────────────────┤
│  Performance        ████████░░  82%     │  <- Metrics
│  Engagement         ███████░░░  70%     │     (Progress bars)
│  Potential          █████████░  95%     │
├─────────────────────────────────────────┤
│  📊 Performance  🎯 Goals  💪 Skills    │  <- Tabs
├─────────────────────────────────────────┤
│  [Tab Content Area - Scrollable]        │
│                                         │
│  Current Goals:                        │
│  ✓ Complete ML certification           │
│  ○ Lead team project                   │
│  ○ Mentor 2 junior engineers           │
│                                         │
└─────────────────────────────────────────┘
```

**Ornaments**:
- Toolbar at bottom with actions (Promote, Transfer, etc.)
- Quick info panel on right side (optional, appears on hover)

### 3. Analytics Dashboard Window

**Purpose**: HR metrics and insights

**Dimensions**: 1000x700 points (wider format for data visualization)

**Layout**:
```
┌─────────────────────────────────────────────────┐
│  Analytics Dashboard        [Date: Q2 2024]     │
├─────────────────────────────────────────────────┤
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌─────┐│
│  │Headcount │ │Turnover  │ │eNPS      │ │Time ││  <- KPI Cards
│  │  1,247   │ │  8.2%    │ │  +42     │ │Range││
│  └──────────┘ └──────────┘ └──────────┘ └─────┘│
├─────────────────────────────────────────────────┤
│  Department Performance                         │
│  ┌───────────────────────────────────────────┐ │
│  │         [Bar Chart Visualization]         │ │  <- Main Chart
│  │                                           │ │     (Interactive)
│  └───────────────────────────────────────────┘ │
├─────────────────────────────────────────────────┤
│  Insights                                       │
│  🔴 High attrition risk in Sales (15%)         │  <- AI Insights
│  🟡 Engineering engagement declining           │
│  🟢 Product team exceeding goals               │
└─────────────────────────────────────────────────┘
```

**Interaction**:
- Charts are interactive (tap to drill down)
- Export button in toolbar
- Filter ornament on left side

### 4. Settings Window

**Dimensions**: 600x800 points

**Layout**: Standard macOS-style settings with sidebar

```
┌─────────────────────────────────┐
│ General          │ Account      │
│ Appearance       │ Sarah Johnson│
│ Privacy          │ HR Director  │
│ Notifications    │              │
│ Accessibility    │ [Preferences]│
│ Integrations     │              │
│ About            │ [Logout]     │
└─────────────────────────────────┘
```

---

## Volume Designs (3D Bounded Spaces)

### 1. Organizational Chart Sphere

**Volume Size**: 1.2m diameter (0.6m radius)

**Concept**: Organization represented as a 3D galaxy
- CEO/Leader at center
- Direct reports orbiting at first ring
- Teams clustered by department
- Connections shown as subtle lines

**Visual Structure**:
```
       Top View                    Side View
         (Y)                          (Y)
          │                            │
    ┌─────┼─────┐                ┌────┼────┐
    │     │     │                │    │    │
────┼─────●─────┼──── (X)        │    ●    │
    │   /   \   │                │  /   \  │
    │  ○  ○  ○  │                │ ○  ○  ○ │
    └───────────┘                └─────────┘
                                      (Z)

● = CEO/Leader (center)
○ = Direct Reports (orbital ring)
```

**Node Specifications**:
- **Size**: 4-6cm diameter spheres
- **Color**: Coded by department
- **Brightness**: Indicates performance rating
- **Pulse**: Engagement level (faster = higher)
- **Glow**: High potential employees

**Interactions**:
- **Tap node**: Highlight and show tooltip
- **Double tap**: Open full profile window
- **Pinch two nodes**: Show relationship/reporting line
- **Rotate volume**: Explore from different angles
- **Expand gesture**: Zoom into department cluster

**Physics**:
- Gentle gravity toward center
- Collision avoidance between nodes
- Smooth spring-based layout

**Materials**:
```swift
// Employee node material
let material = SimpleMaterial(
    color: departmentColor,
    roughness: 0.3,
    isMetallic: false
)

// Add emissive for performance
material.emissiveColor = performanceGlow
material.emissiveIntensity = engagementLevel

// High potential: Add bloom
if employee.isHighPotential {
    material.emissiveIntensity *= 2.0
}
```

### 2. Team Dynamics Cluster

**Volume Size**: 0.8m x 0.8m x 0.8m

**Concept**: Team members arranged in 3D cluster showing collaboration strength

**Layout**:
- Team lead at center
- Team members positioned based on:
  - **Distance from lead**: Collaboration frequency
  - **Vertical position**: Seniority/experience
  - **Clustering**: Skill similarity

**Visualization Features**:
- **Connection lines**: Thickness = collaboration strength
- **Particle effects**: Active projects (flowing particles)
- **Color zones**: Skill domains
- **Orbit paths**: Career progression trajectories

**Interaction**:
- **Grab team lead**: Move entire cluster
- **Pinch member**: Pull out for focus view
- **Two-hand spread**: Expand cluster for detail
- **Rotate gesture**: View from different perspectives

### 3. Career Path 3D Model

**Volume Size**: 1.0m x 0.6m x 0.4m (landscape orientation)

**Concept**: Career journey as a 3D pathway through space

**Structure**:
```
     Current Role (You are here)
           ●
          ╱│╲
         ╱ │ ╲
   Path A│Path B│Path C
        ●  │  ●│ ●
        │  ●  │ │
        │  │  │ │
   Sr. Engineer│Product Mgr
             │ │
             ● ●
        Tech Lead│Dir Product
```

**Visual Elements**:
- **Nodes**: Possible roles (size = opportunity availability)
- **Paths**: Bezier curves connecting roles
- **Gates**: Required skills (appear as checkpoints)
- **Glow**: Recommended next steps
- **Fade**: Less common paths (lower opacity)

**Annotations**:
- **Floating labels**: Role titles
- **Skill badges**: Hover to see requirements
- **Time estimates**: Duration typically needed
- **Success rate**: % who made this transition

**Interaction**:
- **Tap role**: See detailed requirements
- **Trace path**: Highlight route and prerequisites
- **Compare paths**: Select multiple to contrast

### 4. Skill Competency Radar

**Volume Size**: 0.6m diameter sphere

**Concept**: 3D radar chart showing skill proficiency

**Structure**:
- **Axes**: Each skill category extends from center
- **Surface**: Connects proficiency points to form 3D shape
- **Multiple layers**: Compare self-assessment vs. manager assessment
- **Color gradient**: From novice (blue) to expert (gold)

**Visual Design**:
```
         Technical Skills
              (axis)
                |
     Product <--●--> Leadership
                |
           Business
```

**Features**:
- Rotate to view from any angle
- Tap skill axis to see breakdown
- Compare against role requirements (ghost overlay)
- Track progress over time (animated growth)

---

## Immersive Experiences

### 1. Organizational Galaxy (Full Space)

**Purpose**: Explore entire organization as a living ecosystem

**Immersion Level**: Progressive (starts mixed, can go to full)

**Scale**: Infinite (user can fly through)

**Visual Metaphor**: Cosmos
- **Departments**: Solar systems
- **Teams**: Planetary clusters
- **Employees**: Stars (brightness = performance)
- **Connections**: Gravitational fields
- **Projects**: Comets moving between systems

**Spatial Layout**:
```
       Engineering Galaxy
            ☆☆☆
           ☆☆☆☆☆
            ☆☆☆

   Design     ●        Sales
   ☆☆☆     (You)       ☆☆☆☆
   ☆☆                  ☆☆☆

         Product
          ☆☆☆
          ☆☆
```

**Navigation**:
- **Gaze direction**: Gentle drift toward focus
- **Hand pointing**: Fly in pointed direction
- **Pinch + pull**: Zoom in to department
- **Two-hand spread**: Zoom out to full view
- **Voice**: "Take me to Engineering" / "Show me executives"

**Information Display**:
- **Proximity labels**: Appear when close to entity
- **Constellation lines**: Show reporting structures
- **Heat map overlay**: Visualize metrics (engagement, performance)
- **Time scrubber**: See organizational changes over time

**Environmental Design**:
- **Background**: Deep space with subtle nebula
- **Lighting**: Central "sun" (company core values)
- **Ambient audio**: Gentle cosmic sounds
- **Particle effects**: Data flowing between departments

**Accessibility**:
- **Reduce motion mode**: Static positions, no drift
- **High contrast**: Brighter stars, stronger lines
- **Voice navigation**: Full voice control available
- **Guided tour**: Auto-pilot through key areas

### 2. Talent Landscape (Full Space)

**Purpose**: Visualize skills and capabilities as terrain

**Visual Metaphor**: Mountain landscape
- **Mountains**: Skill concentrations
- **Valleys**: Skill gaps
- **Rivers**: Learning pathways
- **Forests**: Growing talent
- **Peaks**: Expert level skills

**Terrain Mapping**:
```
    Peak: AI/ML Expertise
         /\    (Few experts)
        /  \
       /    \___  Valley: Data Science Gap
      /         \__
     /             \___
```

**Features**:
- **Elevation**: Skill proficiency level
- **Color**: Skill category
- **Density**: Number of employees with skill
- **Growth animation**: Trees growing (skill development)
- **Weather**: Demand trends (sun = high demand, clouds = low)

**Interaction**:
- **Walk through**: Navigate landscape naturally
- **Fly over**: Get overview from above
- **Dig in**: Tap terrain to see individual contributors
- **Plant seeds**: Identify learning opportunities

**Information Overlays**:
- **Heatmap**: Skill demand forecast
- **Trails**: Common skill development paths
- **Landmarks**: Critical capabilities
- **Biome info**: Skill category details

### 3. Culture Climate Visualization

**Purpose**: Feel the organizational culture as weather/climate

**Visual Metaphor**: Weather system
- **Temperature**: Engagement levels
- **Weather**: Satisfaction (sunny, cloudy, stormy)
- **Wind**: Collaboration flows
- **Storms**: High-stress areas
- **Sunshine**: Innovation hotspots

**Environment**:
```
   Sunny (High Engagement)
        ☀️

   Cloudy (Medium)
      ☁️☁️

   Stormy (Low/Burnout)
      ⛈️
```

**Spatial Distribution**:
- Departments appear as distinct climate zones
- Walk through to "feel" different cultures
- Temperature change as you move between teams
- Visual and audio cues for climate

**Interaction**:
- **Weather report**: Tap zone for detailed metrics
- **Forecast**: See predicted trends
- **Historical**: Scrub through past climate data
- **Intervention**: Place "sunshine" (initiatives) to improve

---

## 3D Visualization Specifications

### Employee Node Design

#### Standard Node
```
Specifications:
- Diameter: 5cm
- Geometry: Icosphere (low poly)
- Triangle count: 80
- Material: PBR (Physically Based Rendering)
```

#### Visual Encoding

**Color** (Department):
```
Engineering:    #4A90E2 (Blue)
Product:        #7B68EE (Purple)
Design:         #F5A623 (Orange)
Sales:          #50E3C2 (Teal)
Marketing:      #E94B3C (Red)
Operations:     #8B572A (Brown)
HR:             #BD10E0 (Magenta)
Finance:        #417505 (Green)
Executive:      #FFD700 (Gold)
```

**Performance Encoding** (Brightness):
```
Exceeding:      100% brightness + glow
Meeting:        80% brightness
Developing:     60% brightness
Needs Improve:  40% brightness + red tint
```

**Engagement Encoding** (Pulse rate):
```
High (80-100):  Fast pulse (1.0s cycle)
Medium (50-79): Medium pulse (2.0s cycle)
Low (0-49):     Slow pulse (3.0s cycle)
```

**Potential Encoding** (Visual effects):
```
High Potential: Blue rim light + larger size (1.2x)
Successor:      Gold crown icon above node
Flight Risk:    Red glow + warning icon
New Hire:       Green sparkles
```

### Connection Lines

**Visual Design**:
```
- Width: 0.5-2mm (based on relationship strength)
- Color: Department color at 50% opacity
- Style: Dashed for informal, solid for reporting line
- Animation: Subtle flow for active collaboration
```

**Types**:
- **Reporting line**: Solid, brighter
- **Dotted line**: Dashed
- **Collaboration**: Thin, flowing particles
- **Mentorship**: Curved, gradient

### Text and Labels

**Spatial Text Rendering**:
```swift
// Floating label above employee node
Text(employee.name)
    .font(.system(size: 14, weight: .medium))
    .padding(8)
    .background(.regularMaterial)
    .cornerRadius(8)
    .offset(y: 0.08) // 8cm above node
```

**Label Levels** (LOD - Level of Detail):
- **Close (< 1m)**: Full name + title
- **Medium (1-2m)**: Full name only
- **Far (> 2m)**: No label (show on hover)

**Readability**:
- Always face the user (billboard effect)
- Sufficient contrast with background
- Scale with distance (larger when farther)

### Particle Systems

**Use Cases**:
1. **Active Projects**: Particles flowing between collaborators
2. **New Hire**: Sparkle effect on node
3. **Promotion**: Upward particle burst
4. **Achievement**: Confetti celebration
5. **Data Flow**: Information exchange visualization

**Specifications**:
```swift
var particleEmitter = ParticleEmitterComponent()
particleEmitter.emissionRate = 10 // particles per second
particleEmitter.lifetime = 2.0 // seconds
particleEmitter.speed = 0.1 // m/s
particleEmitter.color = .gradient(.blue, .cyan)
```

---

## Interaction Patterns

### Standard Interactions

#### 1. Select (Tap)
**Visual Feedback**:
- Scale up: 1.0x → 1.1x (50ms)
- Highlight: Add rim light
- Sound: Subtle click
- Haptic: Light tap (if available)

**Behavior**:
```swift
.onTapGesture {
    withAnimation(.spring(response: 0.3)) {
        scale = 1.1
        showDetails = true
    }
    playSound(.tap)
}
```

#### 2. Hover
**Visual Feedback**:
- Subtle glow (100ms fade in)
- Show tooltip after 500ms delay
- Cursor changes (if applicable)

**Behavior**:
```swift
.hoverEffect(.highlight)
.onContinuousHover { phase in
    switch phase {
    case .active:
        showHoverTooltip = true
    case .ended:
        showHoverTooltip = false
    }
}
```

#### 3. Long Press
**Visual Feedback**:
- Growing ring animation (0-100% over 500ms)
- Scale slightly (1.0x → 1.05x)
- Trigger context menu at completion

**Behavior**:
```swift
.onLongPressGesture(minimumDuration: 0.5) {
    showContextMenu = true
} onPressingChanged: { pressing in
    if pressing {
        startLongPressAnimation()
    }
}
```

### Spatial-Specific Interactions

#### 1. Look & Tap (Indirect)
Most common visionOS interaction
- Look at element (gaze)
- Pinch fingers together (tap)
- Element highlights on gaze
- Confirms on pinch

#### 2. Direct Touch (Spatial)
For 3D objects in space
- Reach out and touch entity
- Hand appears to make contact
- Visual ripple at contact point
- Sound effect confirms

#### 3. Grab & Move
Reposition objects in space
- Pinch to grab
- Move hand while pinching
- Object follows hand
- Release pinch to drop
- Object settles with physics

#### 4. Rotate
Manipulate 3D orientation
- Two-hand grab
- Rotate hands
- Object rotates 1:1
- Momentum continues
- Snap to axes (optional)

#### 5. Scale
Resize objects
- Pinch with two hands
- Move hands apart/together
- Object scales proportionally
- Min/max limits enforced

### Context Menu Design

**Trigger**: Long press or secondary click

**Visual Design**:
```
┌──────────────────┐
│ 👤 View Profile  │
│ 📊 Performance   │
│ 🎯 Set Goals     │
│ ───────────────  │
│ 📧 Message       │
│ 📅 Schedule 1:1  │
│ ───────────────  │
│ ✏️  Edit         │
└──────────────────┘
```

**Specifications**:
- Glass material background
- Appears near selection
- Max 8 items
- Icons + labels
- Keyboard shortcuts shown

---

## Visual Design System

### Color Palette

#### Primary Colors
```
Brand Blue:     #0A84FF (Primary actions, links)
Brand Purple:   #5E5CE6 (Secondary actions, accents)
Brand Green:    #30D158 (Success, positive metrics)
Brand Orange:   #FF9500 (Warnings, attention)
Brand Red:      #FF3B30 (Errors, critical alerts)
```

#### Department Colors
```
Engineering:    #4A90E2
Product:        #7B68EE
Design:         #F5A623
Sales:          #50E3C2
Marketing:      #E94B3C
Operations:     #8B572A
HR:             #BD10E0
Finance:        #417505
Executive:      #FFD700
```

#### Semantic Colors
```
Success:        #30D158
Warning:        #FF9500
Error:          #FF3B30
Info:           #0A84FF
Neutral:        #8E8E93
```

#### Glass Materials (visionOS)
```swift
// Window background
.background(.regularMaterial)

// Emphasized panels
.background(.thickMaterial)

// Subtle overlays
.background(.thinMaterial)

// Ultra-subtle
.background(.ultraThinMaterial)
```

### Typography

#### Font Family
- **System Font**: SF Pro (San Francisco)
- **Rounded**: SF Pro Rounded (for friendly UI elements)
- **Monospaced**: SF Mono (for data/metrics)

#### Type Scale
```
Display:     34pt, weight: bold
Title 1:     28pt, weight: bold
Title 2:     22pt, weight: bold
Title 3:     20pt, weight: semibold
Headline:    17pt, weight: semibold
Body:        17pt, weight: regular
Callout:     16pt, weight: regular
Subheadline: 15pt, weight: regular
Footnote:    13pt, weight: regular
Caption 1:   12pt, weight: regular
Caption 2:   11pt, weight: regular
```

#### Spatial Text Sizing
- **Near (< 1m)**: Use standard sizes
- **Medium (1-2m)**: Increase 1.5x
- **Far (> 2m)**: Increase 2-3x
- **Always test legibility at distance**

### Materials & Lighting

#### Glass Materials
visionOS signature aesthetic

**Window Glass**:
```swift
.background(.regularMaterial)
.glassBackgroundEffect()
```

**Vibrancy**:
```swift
.foregroundStyle(.primary) // Full opacity
.foregroundStyle(.secondary) // 60% opacity
.foregroundStyle(.tertiary) // 30% opacity
```

#### 3D Materials (PBR)

**Employee Node Material**:
```swift
var material = PhysicallyBasedMaterial()
material.baseColor = PhysicallyBasedMaterial.BaseColor(tint: departmentColor)
material.roughness = 0.3
material.metallic = 0.0
material.emissiveColor = performanceGlow
material.emissiveIntensity = engagementLevel
```

**Connection Line Material**:
```swift
var lineMaterial = UnlitMaterial(color: departmentColor.withAlphaComponent(0.5))
```

#### Lighting

**Ambient Light**:
- Soft, neutral white
- Intensity: 500 lumens
- Prevents harsh shadows

**Directional Light**:
- Simulated sunlight
- Angle: 45° from top-right
- Intensity: 1000 lumens
- Soft shadows enabled

**Point Lights** (for emphasis):
- High-value entities get spotlight
- Warm white (3000K)
- Distance: 0.5m
- Falloff: quadratic

### Iconography

#### Style
- **SF Symbols**: Primary icon library
- **Style**: Rounded, consistent weight
- **Sizes**: Small (16pt), Medium (20pt), Large (24pt)
- **Colors**: Monochrome or semantic colors

#### Common Icons
```
Profile:        person.circle
Performance:    chart.bar.fill
Goals:          target
Skills:         brain.head.profile
Team:           person.3.fill
Calendar:       calendar
Message:        message.fill
Settings:       gearshape.fill
Analytics:      chart.line.uptrend.xyaxis
Search:         magnifyingglass
Filter:         line.3.horizontal.decrease.circle
Export:         square.and.arrow.up
```

#### 3D Icons
Custom 3D models for spatial context
- Simplified geometry (< 1K triangles)
- Single material
- Consistent scale (5cm)

---

## User Flows & Navigation

### Primary User Flow: View Employee Profile

```
1. Dashboard
   ↓ (Tap "View Org Chart")
2. Organizational Chart Volume appears
   ↓ (Gaze at employee node + tap)
3. Employee tooltip shows
   ↓ (Double tap node)
4. Employee Profile window opens
   ↓ (Browse tabs: Performance, Goals, Skills)
5. View detailed information
   ↓ (Tap "Message")
6. Message composition window opens
```

### Navigation Patterns

#### Window-Based Navigation
```
Dashboard (Home)
  ├─→ Employee List → Employee Profile
  ├─→ Analytics Dashboard → Drill-down Reports
  ├─→ Settings
  └─→ Help & Support
```

#### Spatial Navigation
```
2D Windows (Desktop metaphor)
  ↓ User triggers "View in 3D"
Volumetric View (Bounded 3D)
  ↓ User triggers "Explore Organization"
Immersive Space (Full immersion)
  ↓ User triggers "Exit" or pinches Digital Crown
Back to Windows
```

#### Breadcrumb Navigation
```
Dashboard > Teams > Engineering > Backend Team > John Doe

[Dashboard] > [Teams] > [Engineering] > [Backend Team] > John Doe
   ↑                                                        ↑
  (Tap to return)                              (Current location)
```

### Navigation Controls

**Window Navigation**:
- **Back button**: Top-left (standard macOS position)
- **Toolbar**: Bottom of window (primary actions)
- **Sidebar**: Left side (filtering, navigation)

**Spatial Navigation**:
- **Minimap**: Bottom-right (shows position in org)
- **Zoom controls**: Two-finger pinch
- **Reset view**: Voice command or button
- **Teleport**: Tap distant location to jump

**Keyboard Shortcuts** (for connected keyboard):
- `⌘+H`: Home (Dashboard)
- `⌘+O`: Open Org Chart
- `⌘+F`: Search
- `⌘+,`: Settings
- `ESC`: Exit immersive space
- `Space`: Toggle selection

---

## Accessibility Design

### VoiceOver Optimization

**Spatial Elements**:
```swift
// Employee node in 3D space
entity.accessibilityLabel = "John Doe, Senior Engineer, Performance: Exceeding"
entity.accessibilityHint = "Double tap to view full profile"
entity.accessibilityValue = "Engagement: 85%, Tenure: 3 years"

// Spatial position context
entity.accessibilityFrame = convertToAccessibilityFrame(entity.position)
```

**Navigation Hints**:
- "Employee node, 2 meters ahead, 30 degrees right"
- "Department cluster: Engineering, 15 employees visible"
- "You are viewing the organizational chart, 42 employees in view"

### Visual Accessibility

#### High Contrast Mode
```swift
@Environment(\.colorSchemeContrast) var contrast

var nodeColor: Color {
    contrast == .increased ?
        departmentColor.darker(by: 0.3) :
        departmentColor
}

var outlineWidth: CGFloat {
    contrast == .increased ? 3.0 : 1.0
}
```

#### Differentiate Without Color
```swift
@Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor

// Add patterns or shapes in addition to color
if differentiateWithoutColor {
    // High performers: Star shape
    // Medium performers: Circle
    // Developing: Square
}
```

#### Reduce Transparency
```swift
@Environment(\.accessibilityReduceTransparency) var reduceTransparency

var windowBackground: Material {
    reduceTransparency ? .regularMaterial : .thinMaterial
}
```

### Motor Accessibility

#### Larger Hit Targets
```
Standard:     44x44 points (minimum)
Spatial 3D:   60x60 points (recommended)
Critical:     80x80 points (important actions)
```

#### Dwell Control
Alternative to tap for users with limited mobility
```swift
.onContinuousHover { phase in
    if phase == .active {
        startDwellTimer(duration: 1.5) {
            triggerAction()
        }
    }
}
```

#### Voice Commands
Full voice control for all actions
```
"Select John Doe"
"Open profile"
"Show performance"
"Go back"
"Exit to dashboard"
```

### Cognitive Accessibility

#### Simplified Mode
Reduce visual complexity
- Remove animations
- Flatten 3D to 2D view
- Increase spacing
- Larger text

#### Clear Language
- Avoid jargon
- Use simple sentences
- Provide context
- Offer help tooltips

---

## Error States & Loading Indicators

### Error States

#### No Data State
```
┌─────────────────────────────────┐
│                                 │
│         [Empty State Icon]      │
│                                 │
│      No Employees Found         │
│                                 │
│  There are no employees matching│
│  your current filters.          │
│                                 │
│      [Clear Filters]            │
│                                 │
└─────────────────────────────────┘
```

#### Network Error
```
┌─────────────────────────────────┐
│         [⚠️ Alert Icon]         │
│                                 │
│    Connection Error             │
│                                 │
│  Unable to connect to server.   │
│  Please check your connection.  │
│                                 │
│  [Retry]  [Work Offline]        │
└─────────────────────────────────┘
```

#### Permission Error
```
┌─────────────────────────────────┐
│         [🔒 Lock Icon]          │
│                                 │
│    Access Denied                │
│                                 │
│  You don't have permission to   │
│  view this employee's data.     │
│                                 │
│      [Request Access]           │
└─────────────────────────────────┘
```

### Loading Indicators

#### Inline Loading (Small)
```swift
ProgressView()
    .progressViewStyle(.circular)
    .scaleEffect(0.8)
```

#### Window Loading (Medium)
```
┌─────────────────────────────────┐
│                                 │
│        ⟳ Loading...            │
│                                 │
│    Fetching employee data       │
│                                 │
└─────────────────────────────────┘
```

#### Immersive Space Loading (Large)
Spatial loading experience:
- Animated 3D spinner in center of space
- Translucent nodes appear incrementally
- Progress percentage displayed
- Estimated time remaining

```swift
// Spatial loading indicator
RealityView { content in
    let spinner = createSpinningTorus()
    content.add(spinner)
}

Text("Loading organizational data...")
    .font(.title2)
    .offset(y: -0.3) // Above spinner

Text("\(loadingProgress)%")
    .font(.caption)
    .offset(y: -0.4)
```

#### Skeleton Screens
For progressive loading:
```
┌─────────────────────────────────┐
│ ▒▒▒▒  ▒▒▒▒▒▒▒▒▒▒              │  <- Shimmer effect
│ ▒▒▒▒  ▒▒▒▒▒▒▒▒                │
│                                 │
│ ▒▒▒▒▒▒▒▒▒▒▒▒▒                  │
│ ▒▒▒▒▒▒▒▒▒▒                     │
└─────────────────────────────────┘
```

---

## Animations & Transitions

### Timing & Easing

**Standard Durations**:
```swift
let instant:      0.0
let veryFast:     0.1
let fast:         0.2
let normal:       0.3
let slow:         0.5
let verySlow:     0.8
```

**Easing Curves**:
```swift
// Ease out (most common)
.easeOut // Decelerates at end

// Ease in out (smooth)
.easeInOut // Accelerates and decelerates

// Spring (natural, playful)
.spring(response: 0.3, dampingFraction: 0.7)

// Custom
.timingCurve(0.4, 0.0, 0.2, 1.0)
```

### Window Animations

#### Window Appear
```swift
.transition(.opacity.combined(with: .scale(scale: 0.9)))
.animation(.spring(response: 0.4, dampingFraction: 0.8), value: isPresented)

// Sequence:
// 1. Fade in (0-100% opacity)
// 2. Scale up (0.9x → 1.0x)
// Duration: 400ms
```

#### Window Dismiss
```swift
.transition(.opacity.combined(with: .scale(scale: 0.95)))
.animation(.easeOut(duration: 0.2), value: isPresented)

// Sequence:
// 1. Scale down (1.0x → 0.95x)
// 2. Fade out (100% → 0% opacity)
// Duration: 200ms
```

### Spatial Animations

#### Node Appearance
```swift
// Fade in + scale up + gentle drop
entity.opacity = 0
entity.scale = [0.5, 0.5, 0.5]
entity.position.y += 0.2

entity.move(
    to: Transform(scale: [1, 1, 1], translation: targetPosition),
    relativeTo: nil,
    duration: 0.5,
    timingFunction: .easeOut
)
```

#### Node Selection
```swift
// Pulse + rim light + scale
withAnimation(.spring(response: 0.3)) {
    entity.scale *= 1.1
}

// Add rim light
let rimLight = PointLight()
rimLight.intensity = 500
entity.addChild(rimLight)
```

#### Connection Line Drawing
```swift
// Animated line growth
let line = createLine(from: start, to: end)
line.trimEnd = 0.0 // Start hidden

withAnimation(.linear(duration: 0.4)) {
    line.trimEnd = 1.0 // Grow to full length
}
```

### State Transitions

#### Loading → Content
```swift
if isLoading {
    ProgressView()
        .transition(.opacity)
} else {
    ContentView()
        .transition(.opacity.combined(with: .move(edge: .bottom)))
}
```

#### Empty → Populated
```swift
ForEach(employees) { employee in
    EmployeeRow(employee)
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        ))
}
```

### Micro-interactions

#### Button Press
```swift
.scaleEffect(isPressed ? 0.95 : 1.0)
.animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
```

#### Toggle
```swift
.animation(.spring(response: 0.3, dampingFraction: 0.7), value: isOn)
```

#### Progress Update
```swift
.animation(.linear(duration: 0.3), value: progress)
```

### Performance Considerations

#### Reduce Motion
```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

var animation: Animation {
    reduceMotion ? .none : .spring(response: 0.3)
}
```

#### GPU Optimization
- Use `withAnimation` over `transaction.animation`
- Batch animations when possible
- Avoid animating while scrolling
- Use `drawingGroup()` for complex animations

---

## Design Checklist

### Pre-Implementation
- [ ] All user flows mapped
- [ ] Wireframes created for each window
- [ ] 3D visualizations prototyped
- [ ] Color palette defined
- [ ] Typography scale established
- [ ] Icon set selected

### Accessibility
- [ ] VoiceOver labels for all interactive elements
- [ ] High contrast mode support
- [ ] Reduced motion alternatives
- [ ] Minimum 44pt hit targets
- [ ] Keyboard navigation support
- [ ] Voice command support

### Performance
- [ ] Animation frame rate target (90 FPS)
- [ ] Asset optimization (LOD, compression)
- [ ] Lazy loading for large datasets
- [ ] Efficient rendering pipeline

### Polish
- [ ] Smooth transitions between states
- [ ] Consistent interaction patterns
- [ ] Meaningful micro-interactions
- [ ] Appropriate audio feedback
- [ ] Error states designed
- [ ] Loading states designed

---

## Conclusion

This design system provides a comprehensive foundation for building Spatial HCM with a focus on:

1. **Spatial-First Thinking**: Leveraging 3D space meaningfully
2. **Accessibility**: Ensuring all users can navigate and understand
3. **Consistency**: Unified visual language and interaction patterns
4. **Performance**: Smooth, responsive experiences
5. **Delight**: Thoughtful animations and micro-interactions

The design balances innovation with familiarity, introducing users gradually to spatial computing while maintaining productivity and usability.
