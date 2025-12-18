# Supply Chain Control Tower - Design Specifications

## 1. Spatial Design Principles

### 1.1 Core Design Philosophy

**"From Data to Dimension"**
Transform abstract supply chain data into intuitive 3D spatial experiences that leverage human spatial reasoning and natural interaction patterns.

### 1.2 Design Pillars

1. **Spatial Clarity**: Information organized in 3D space mirrors mental models
2. **Ergonomic Placement**: Content positioned for comfort and efficiency
3. **Progressive Disclosure**: Start simple, reveal complexity on demand
4. **Natural Interaction**: Gestures that feel instinctive and effortless
5. **Ambient Awareness**: Peripheral information without overwhelming focus
6. **Collaborative Presence**: Designed for multi-user coordination

### 1.3 visionOS-Specific Guidelines

```yaml
Spatial Ergonomics:
  Vertical Placement: 10-15° below eye level
  Horizontal Spread: 120° field of view (optimal zone)
  Depth Placement: 0.5m to 5m from user
  Optimal Focus: 1-2m distance

Reading Zones:
  Alert Text: 0.5-1m (large, urgent)
  Primary Content: 1-2m (comfortable reading)
  Background Info: 2-5m (ambient awareness)

Interaction Zones:
  Precise Control: 0.5m (fine manipulation)
  Standard Interaction: 1m (comfortable reach)
  Ambient Selection: 2m+ (gaze-based)
```

## 2. Window Layouts & Configurations

### 2.1 Dashboard Window

```
┌─────────────────────────────────────────────────────┐
│  Supply Chain Control Tower              [–][×]    │
├─────────────────────────────────────────────────────┤
│  ┌───────────┐ ┌───────────┐ ┌───────────┐        │
│  │   OTIF    │ │ Shipments │ │  Alerts   │        │
│  │   94.2%   │ │    847    │ │     3     │        │
│  │  ▲ 2.1%   │ │  ● Active │ │  ⚠ Medium │        │
│  └───────────┘ └───────────┘ └───────────┘        │
│                                                     │
│  Active Shipments                      [Filter ▼]  │
│  ┌─────────────────────────────────────────────┐  │
│  │ 🚢 Container #7432  LA → Shanghai  █████▌  │  │
│  │    ETA: 2h 15m ahead                       │  │
│  │                                             │  │
│  │ 🚛 Truck #9821  Dallas → Chicago  ████▌   │  │
│  │    ⚠ Weather delay: 45min                  │  │
│  │                                             │  │
│  │ ✈ Air #4432  Frankfurt → NYC  ███████▌   │  │
│  │    ✓ On schedule                           │  │
│  └─────────────────────────────────────────────┘  │
│                                                     │
│  [Open Network] [Analytics] [Planning]             │
└─────────────────────────────────────────────────────┘
```

**Design Specifications:**
- **Size**: 1200 x 800 points
- **Background**: Glass material with 20% vibrancy
- **Spacing**: 16pt margins, 12pt padding
- **Typography**: SF Pro Display
- **Colors**: Semantic (green=good, yellow=warning, red=critical)
- **Shadows**: Subtle depth for cards
- **Animations**: Smooth transitions (0.3s spring)

### 2.2 Alert Panel Window

```
┌──────────────────────────────┐
│  Alerts & Exceptions    [×] │
├──────────────────────────────┤
│                              │
│  ⛔ CRITICAL                 │
│  Port Congestion - Shanghai  │
│  Impact: 23 shipments        │
│  Delay: 48-72 hours          │
│  [View Details] [Resolve]    │
│                              │
│  ⚠ WARNING                   │
│  Weather Alert - Chicago     │
│  Impact: 5 shipments         │
│  Delay: 2-4 hours           │
│  [Reroute] [Monitor]         │
│                              │
│  ℹ INFO                      │
│  Capacity Available - LA     │
│  Opportunity: Consolidate    │
│  Savings: $12,500           │
│  [View] [Dismiss]            │
│                              │
└──────────────────────────────┘
```

**Design Specifications:**
- **Size**: 400 x 600 points
- **Position**: Upper right quadrant
- **Urgency Coding**:
  - Critical: Red glow, pulsing
  - Warning: Orange border
  - Info: Blue accent
- **Auto-dismiss**: Info alerts after 30s
- **Persistence**: Critical alerts require action
- **Sound**: Spatial audio at alert position

### 2.3 Control Panel Window

```
┌──────────────────────────────────────────┐
│  Network Controls                   [×] │
├──────────────────────────────────────────┤
│                                          │
│  View Mode: [Globe] Network  Flows      │
│                                          │
│  Time Range:                             │
│  [Now] 24h  7d  30d  Custom             │
│                                          │
│  Filters:                                │
│  ☑ Delayed shipments                    │
│  ☑ Critical items only                  │
│  ☐ International only                   │
│  ☐ High value (>$100K)                  │
│                                          │
│  Display Options:                        │
│  Route Density: ▬▬▬▬▬▬▬▬○▯ 80%          │
│  Node Labels:   ▬▬▬▬▬○▯▯▯▯ 50%          │
│  Flow Speed:    ▬▬▬▬▬▬○▯▯▯ 60%          │
│                                          │
│  [Reset View] [Save Preset]              │
│                                          │
└──────────────────────────────────────────┘
```

**Design Specifications:**
- **Size**: 600 x 400 points
- **Position**: Left side, within arm's reach
- **Controls**: Large touch targets (60pt minimum)
- **Sliders**: Continuous adjustment with haptic feedback
- **Toggles**: Clear on/off states with animations
- **Presets**: Quick access to saved configurations

## 3. Volume Designs (3D Bounded Spaces)

### 3.1 Network Volume (Regional View)

```
3D Visualization (2m x 1.5m x 2m):

     ┌─────────────────────────────┐
    ╱│          SKY               │╱
   ╱ │  (Empty space for labels)  │╱
  ╱  │                            │╱
 ╱   │    ●────────●──────────●  │╱
│    │   ╱│╲      ╱│╲        ╱   │
│    │  ● │ ●    ● │ ●      ●    │  Regional Network
│    │  │●│ │    │●│ │      │    │  - Nodes as spheres
│    │  └─┼─┘    └─┼─┘      │    │  - Edges as tubes
│    │    ●────────●─────────●   │  - Flows as particles
│    │                            │
│    └────────────────────────────┘
│   ╱  (Base represents geography)╱
│  ╱                              ╱
│ ╱                              ╱
└────────────────────────────────┘
```

**Visual Design:**

**Nodes (Facilities):**
- **Shape**: Spheres (procedural gradient)
- **Size**: 20-100mm based on capacity
- **Color Coding**:
  - Green: Healthy (>80% capacity)
  - Yellow: Warning (60-80% capacity)
  - Red: Critical (<60% capacity)
- **Material**: Glass with internal glow
- **Labels**: Floating above, fade with distance

**Edges (Routes):**
- **Shape**: Cylindrical tubes
- **Thickness**: 5-20mm based on capacity
- **Color**: Gray base, highlighted when active
- **Material**: Semi-transparent glass
- **Animation**: Pulsing when active

**Flows (Shipments):**
- **Shape**: Particle system
- **Size**: 10-30mm particles
- **Color**: By status (green/yellow/red)
- **Movement**: Smooth animation along path
- **Trail**: Fading motion blur
- **Speed**: 0.5-2.0 m/s visual speed

### 3.2 Inventory Landscape Volume

```
3D Terrain (1.5m x 1m x 1.5m):

     ┌────────────────────────┐
    ╱│   Mountains = High    │╱
   ╱ │       Stock           │╱
  ╱  │    ▲▲▲                │╱
 ╱   │   ╱│││╲               │╱
│    │  ╱ ││││ ╲    ▲        │
│    │ ╱  ││││  ╲  ╱│╲       │  Inventory Landscape
│    ├────────────────────┤  │  - Height = stock level
│    ││░░░░░░░░░░░░░░░░░░││  │  - Color = turnover rate
│    │└──────────────────┘│  │  - Vegetation = activity
│    │   Valleys = Low    │  │  - Erosion = obsolescence
│    └────────────────────┘
│   ╱  Flat = Optimal     ╱
└────────────────────────┘
```

**Visual Design:**

**Terrain:**
- **Generation**: Procedural based on inventory data
- **Height**: 0-500mm (representing stock levels)
- **Resolution**: 100x100 grid
- **Material**: PBR terrain shader
- **Updates**: Smooth morphing (2s transition)

**Color Mapping:**
- **Green**: High turnover (healthy)
- **Yellow**: Moderate turnover
- **Red**: Low turnover (risk of obsolescence)
- **Blue**: Optimal stock levels

**Vegetation (Activity):**
- **Trees**: High activity items
- **Grass**: Regular movement
- **Barren**: Stagnant inventory
- **Density**: Activity level

**Erosion (Obsolescence):**
- **Cracks**: Items at risk
- **Dust**: Very slow movement
- **Warnings**: Pulsing red areas

### 3.3 Flow River Volume

```
3D River System (3m x 1m x 1m):

     Source                   Delta
      (Origin)              (Destination)
        ╱╲
       ╱  ╲
      ╱    ╲
     ╱  ⇓⇓  ╲
    ╱   ⇓⇓   ╲
   ╱    ⇓⇓    ╲
  ╱─────⇓⇓─────╲
 ╱      ⇓⇓      ╲
│  Lake ⇓⇓ Lake  │   ← Distribution Centers
│  (DC) ⇓⇓ (DC)  │
│       ⇓⇓       │
│       ⇓⇓⇓⇓     │
│    ⇓⇓⇓⇓⇓⇓⇓    │
│ ⇓⇓⇓⇓⇓⇓⇓⇓⇓⇓⇓  │
└────Ocean───────┘   ← Customers
```

**Visual Design:**

**River Flow:**
- **Fluid**: Particle-based fluid simulation
- **Width**: 50-200mm based on volume
- **Speed**: 100-500mm/s based on velocity
- **Color**: Blue gradient (light=fast, dark=slow)
- **Material**: Water shader with reflections

**Sources (Origins):**
- **Mountains**: Supplier locations
- **Springs**: Material sources
- **Height**: Supply capacity

**Lakes (Distribution Centers):**
- **Size**: Proportional to capacity
- **Activity**: Ripples for throughput
- **Color**: Fill level indicator

**Ocean (Customers):**
- **Waves**: Demand patterns
- **Tides**: Seasonal variation
- **Depth**: Market size

**Bottlenecks:**
- **Narrow passages**: Capacity constraints
- **Rapids**: High-speed flows
- **Dams**: Blockages/delays

## 4. Immersive Space: Global Command Center

### 4.1 Primary: Globe Visualization

```
        User Position
             👤
            ╱│╲
           ╱ │ ╲
       Alert Zone (0.5-1m)
          ╱  │  ╲
    Operations Zone (1-2m)
       ╱     │     ╲
  Strategic Zone (2-5m)
     ╱        │        ╲
    ╱    ┌────●────┐    ╱
   │    ╱  Globe   ╲   │
   │   │   5m dia.  │  │
   │   │     ●      │  │  ← Center: 2m forward
   │    ╲  Rotates /   │
    ╲    └─────────┘   ╱
     ╲                ╱
      ╲              ╱
       ──────────────
```

**Globe Design:**

**Physical Properties:**
- **Diameter**: 5 meters
- **Position**: 2m in front of user, centered
- **Material**: Semi-transparent with continents
- **Rotation**: Gesture-controlled, inertia

**Geographic Features:**
- **Continents**: Subtle relief mapping
- **Oceans**: Darker blue, slight transparency
- **Cities**: Glowing points
- **Borders**: Faint lines

**Supply Chain Overlay:**
- **Facilities**: 3D pins rising from surface
- **Routes**: Arcing lines above surface
- **Flows**: Animated particles along arcs
- **Disruptions**: Storm-like visual effects

**Node Design (Facilities):**
```
Facility Pin (3D):
       ╱▔╲
      │ ● │  ← Icon (warehouse, port, etc.)
      │───│  ← Colored by status
      │   │  ← Height = capacity
      └───┘
       ╱╲
      ╱──╲  ← Base anchored to globe
```

**Specifications:**
- **Height**: 50-200mm from surface
- **Icon**: 3D model of facility type
- **Glow**: Status-based (green/yellow/red)
- **Label**: Appears on focus (300ms dwell)
- **Interaction**: Tap to select, details appear

**Route Design (Shipping Lanes):**
```
Route Arc (3D):
     ●─────────●
    ╱ ∙ ∙ ∙ ∙ ╲   ← Arc rises 500mm above globe
   ╱  particles ╲
  ●              ●
Node              Node
```

**Specifications:**
- **Curve**: Geodesic arc
- **Height**: 500mm peak above surface
- **Thickness**: 5-20mm based on capacity
- **Color**: Gray (inactive), blue (selected)
- **Particles**: Flow direction indicators
- **Animation**: 2s travel time (visual speed)

### 4.2 Alert Zone (0.5-1m)

```
    👤 User
     │
    0.5-1m
     │
  ┌──▼──┐
  │ ⚠ │  ← Critical Alert
  │─────│
  │ Text│  ← Large, urgent text
  │─────│
  │[Act]│  ← Action buttons
  └─────┘
```

**Design Specifications:**
- **Position**: 0.5m in front, eye level
- **Size**: 400 x 300mm
- **Background**: Red glow (critical), orange (warning)
- **Typography**: 32pt bold, high contrast
- **Animation**: Fade in with spatial sound
- **Persistence**: Until action taken
- **Interaction**: Direct manipulation

### 4.3 Operations Zone (1-2m)

```
Floating Panels:

  ┌─────────┐  ┌─────────┐  ┌─────────┐
  │ Panel 1 │  │ Panel 2 │  │ Panel 3 │
  │ Network │  │ Flows   │  │ KPIs    │
  │         │  │         │  │         │
  └─────────┘  └─────────┘  └─────────┘
       │            │            │
      1-2m         1-2m         1-2m
       │            │            │
       └────────────┼────────────┘
                    │
                   👤 User
```

**Design Specifications:**
- **Arrangement**: Arc around user (120° FOV)
- **Distance**: 1-2m from user
- **Size**: 600 x 400mm per panel
- **Material**: Glass background
- **Content**: Interactive controls, data
- **Interaction**: Gaze + pinch, direct touch

### 4.4 Strategic Zone (2-5m)

```
Background Visualizations:

    ╔═══════════════════════╗
    ║   Trend Lines         ║  ← 3-4m distance
    ║   ╱╲  ╱╲  ╱╲         ║
    ║  ╱  ╲╱  ╲╱  ╲        ║
    ╚═══════════════════════╝

    ╔═══════════════════════╗
    ║   World Map           ║  ← 4-5m distance
    ║   ● ● ● ● ●           ║
    ║   Regional Context    ║
    ╚═══════════════════════╝
```

**Design Specifications:**
- **Content**: Ambient, contextual information
- **Distance**: 2-5m from user
- **Opacity**: 50-70% (background presence)
- **Updates**: Slow, smooth transitions
- **Interaction**: Gaze to bring forward

## 5. Interaction Patterns

### 5.1 Gaze Interactions

**Focus Highlight:**
```
Normal State → Gaze Dwelt (300ms) → Focused State

   ●           →        ◉         →      ⊙
  Node                  Glow             Highlight + Info
```

**Design:**
- **Dwell Time**: 300ms for highlight
- **Visual**: Subtle glow, scale 1.1x
- **Info Panel**: Appears after 500ms
- **Sound**: Soft confirmation tone

**Gaze Navigation:**
- **Activation**: Look at region + hand gesture
- **Transition**: Smooth camera movement (1-2s)
- **Easing**: Ease-in-out cubic

### 5.2 Pinch Gestures

**Standard Pinch (Select):**
```
Hand State:
   ○   ○
  ╱│╲ ╱│╲
   │   │
   └───┘  Pinch
```

**Specifications:**
- **Detection**: Thumb + index finger
- **Distance**: <20mm for activation
- **Feedback**: Haptic click + visual highlight
- **Uses**: Select, confirm, grab

**Pinch + Drag (Move):**
```
Pinch → Move → Release

  ◉  →  ◉───→  →  ●
Select  Drag     Release
```

**Specifications:**
- **Visual**: Ghost preview while dragging
- **Constraints**: Snap to grid, bounds checking
- **Feedback**: Continuous haptic during drag
- **Uses**: Reposition, adjust, transfer

### 5.3 Two-Hand Gestures

**Pinch-to-Zoom:**
```
Both Hands:
  ←  ●     ●  →  Spread apart
      Zoom In

  →  ●     ●  ←  Move together
      Zoom Out
```

**Specifications:**
- **Range**: 0.5x to 5.0x zoom
- **Smooth**: Continuous scaling
- **Center**: Midpoint between hands
- **Uses**: Zoom globe, scale volumes

**Rotate:**
```
Both Hands in Circle:
    ●
   ╱ ╲
  ●───●  Rotate gesture
   ╲ ╱
    ●
```

**Specifications:**
- **Detection**: Circular hand motion
- **Rotation**: Match hand rotation angle
- **Inertia**: Continue rotating on release
- **Uses**: Rotate globe, spin volumes

### 5.4 Custom Gestures

**Route Drawing:**
```
1. Point at Origin → 2. Draw Path → 3. Point at Destination

    ●                 ●───┐           ●───┐
   Origin                │   Path        │   ●
                         └────→          └────● Dest
```

**Specifications:**
- **Input**: Continuous hand position
- **Smoothing**: Catmull-Rom spline
- **Validation**: Real-time feasibility check
- **Visual**: Animated preview path
- **Confirmation**: Release to commit

**Thumbs Up (Approve):**
```
    ╱▔╲
   │ ● │  Thumb extended
    ╲│╱
     │
```

**Specifications:**
- **Detection**: Thumb up, fingers curled
- **Hold**: 200ms minimum
- **Feedback**: Green checkmark animation
- **Sound**: Approval chime
- **Uses**: Approve recommendations, confirm actions

**X Gesture (Cancel):**
```
  Left Hand    Right Hand
      ╲          ╱
       ●        ●   Cross arms
        ╲      ╱
         ╲    ╱
          ╲  ╱
           ××
```

**Specifications:**
- **Detection**: Crossed forearms
- **Hold**: 300ms minimum
- **Feedback**: Red X animation
- **Sound**: Cancellation tone
- **Uses**: Reject, cancel, clear

## 6. Visual Design System

### 6.1 Color Palette

**Primary Colors:**
```yaml
Supply Chain Theme:
  Ocean Blue:    #0066CC  # Primary brand
  Sky Blue:      #4A90E2  # Secondary
  Deep Navy:     #002B5C  # Dark background

Status Colors:
  Success Green: #00C853  # Healthy, on-time
  Warning Yellow:#FFB300  # Caution, delayed
  Error Red:     #D32F2F  # Critical, failed
  Info Blue:     #2196F3  # Information

Neutral Palette:
  White Glass:   #FFFFFF  α=0.2
  Light Glass:   #F5F5F5  α=0.15
  Medium Glass:  #E0E0E0  α=0.3
  Dark Glass:    #424242  α=0.5
```

**Glass Materials:**
```swift
// visionOS glass backgrounds
.background(.ultraThinMaterial)      // Subtle
.background(.thinMaterial)           // Light
.background(.regularMaterial)        // Standard
.background(.thickMaterial)          // Prominent
.background(.ultraThickMaterial)     // Heavy
```

**Color Usage:**
- **Windows**: Light glass with vibrancy
- **Alerts**: Status color glow
- **3D Nodes**: Status color core with glass shell
- **Routes**: Neutral gray, highlighted blue
- **Flows**: Status colors with trails

### 6.2 Typography

**Font System:**
```yaml
Primary Font: SF Pro Display
Monospace: SF Mono (for data, codes)

Hierarchy:
  Title 1:     48pt Bold      # Window titles
  Title 2:     34pt Semibold  # Section headers
  Title 3:     24pt Medium    # Subsections
  Headline:    20pt Semibold  # Emphasis
  Body:        17pt Regular   # Standard text
  Callout:     16pt Regular   # Secondary info
  Subheadline: 15pt Regular   # Metadata
  Footnote:    13pt Regular   # Fine print
  Caption:     12pt Regular   # Labels

3D Spatial Text:
  Large Labels:  200mm font    # Distant visibility
  Medium Labels: 100mm font    # Mid-range
  Small Labels:  50mm font     # Close reading
```

**Text Rendering:**
- **Clarity**: High-resolution text rendering
- **Depth**: Slight z-offset for readability
- **Shadows**: Subtle drop shadow for contrast
- **Animations**: Fade in/out, scale

### 6.3 Iconography

**Icon Style:**
- **Design**: SF Symbols 5.0
- **Weight**: Medium (default), Bold (emphasis)
- **Size**: 24pt (standard), 32pt (large)
- **Color**: Semantic or monochrome
- **3D**: Extruded for spatial depth

**Custom Icons:**
```yaml
Facilities:
  Warehouse:   📦 3D building model
  Port:        🚢 Harbor with cranes
  Factory:     🏭 Industrial complex
  DC:          🏢 Distribution hub
  Customer:    📍 Location pin

Transport:
  Truck:       🚛 Semi-truck
  Ship:        🚢 Container vessel
  Plane:       ✈️ Cargo aircraft
  Rail:        🚆 Train

Status:
  Healthy:     ✓ Checkmark
  Warning:     ⚠ Triangle
  Error:       ⛔ Stop sign
  Info:        ℹ Circle-i
```

**3D Icon Specifications:**
- **Poly Count**: <1000 triangles
- **Material**: PBR with emission
- **Size**: 50-100mm height
- **Animation**: Rotate on selection

### 6.4 Materials & Lighting

**visionOS Materials:**
```swift
// Glass materials for windows
.glass
.frosted
.chrome
.matte

// 3D entity materials
PhysicallyBasedMaterial(
    baseColor: .color(.blue),
    metallic: 0.2,
    roughness: 0.4,
    emission: .color(.blue, intensity: 0.5)
)
```

**Lighting Setup:**
```yaml
Command Center Lighting:
  Ambient:
    Color: Soft white (#F8F8F8)
    Intensity: 0.3

  Directional (Sun):
    Color: White (#FFFFFF)
    Intensity: 0.8
    Angle: 45° above horizon

  Point Lights (Nodes):
    Color: Status-based
    Intensity: 0.5-1.0
    Radius: 0.5-2.0m

  Spotlights (Focus):
    Color: White
    Intensity: 1.5
    Cone: 30° angle
```

**Material Properties:**
- **Glass**: Refraction index 1.5, transparency 0.8
- **Metal**: Metallic 1.0, roughness 0.2
- **Plastic**: Metallic 0.0, roughness 0.6
- **Emission**: For glowing indicators

## 7. User Flows & Navigation

### 7.1 Primary User Flow: Disruption Management

```
1. Disruption Detected
   ↓
   Alert appears (0.5m, critical zone)
   + Spatial sound
   + Red pulsing
   ↓
2. User Gazes at Alert
   ↓
   Auto-highlight + details
   ↓
3. User Pinches to Select
   ↓
   Opens Disruption Details Panel (1m)
   + Affected shipments highlighted on globe
   + Impact visualization
   ↓
4. AI Recommendations Appear
   ↓
   [Reroute] [Expedite] [Communicate] [Monitor]
   ↓
5. User Selects Recommendation
   ↓
   Preview of changes shown on globe
   + Cost impact
   + Time savings
   ↓
6. User Confirms (Thumbs Up)
   ↓
   Action executed
   + Confirmation animation
   + Updated globe state
   + Alert dismissed
   ↓
7. Return to Monitoring
```

### 7.2 Navigation Hierarchy

```
App Launch
   ↓
Dashboard Window (Default)
   ├─→ Open Network Volume
   │      └─→ Select Region
   │            └─→ Enter Immersive Globe
   │
   ├─→ Open Inventory Volume
   │      └─→ Explore Landscape
   │
   ├─→ Open Flow River Volume
   │      └─→ Analyze Flows
   │
   └─→ Analytics Window
          └─→ Reports & Insights
```

### 7.3 Modal Interactions

**Contextual Menus:**
```
Long-press on Node
   ↓
   ┌──────────────┐
   │ View Details │
   ├──────────────┤
   │ Edit         │
   ├──────────────┤
   │ Optimize     │
   ├──────────────┤
   │ Alert Rules  │
   └──────────────┘
```

## 8. Accessibility Design

### 8.1 VoiceOver Experience

**Spatial Audio Descriptions:**
```
User navigates globe with gaze:
  → "Los Angeles Distribution Center"
  → "Capacity 85%, 1200 units"
  → "3 active shipments, 1 delayed"
  → "Double-tap to select"
```

**Specifications:**
- **Descriptions**: Concise, informative
- **Spatial Audio**: Sounds from entity location
- **Navigation**: Logical traversal order
- **Feedback**: Confirmation for all actions

### 8.2 Reduced Motion

**Alternatives:**
```yaml
Full Motion → Reduced Motion:
  Animated Flows → Static arrows
  Rotating Globe → Panning views
  Particle Systems → Directional indicators
  Smooth Transitions → Instant changes
```

### 8.3 High Contrast

**Enhanced Visibility:**
```yaml
Standard → High Contrast:
  Glass Backgrounds → Solid backgrounds
  Subtle Shadows → Heavy outlines
  Gradient Colors → Flat colors
  Text Contrast: 7:1 ratio (WCAG AAA)
```

### 8.4 Alternative Controls

**Switch Control:**
- **Scanning**: Sequential element highlighting
- **Dwell**: Auto-select on focus (adjustable)
- **External**: Bluetooth switch support

**Voice Control:**
```
User: "Show Los Angeles"
  → Camera navigates to LA node

User: "Select shipment 7432"
  → Shipment highlighted and detailed

User: "Approve recommendation"
  → First recommendation confirmed
```

## 9. Error States & Loading

### 9.1 Loading States

**Initial Load:**
```
   ⟲ Loading Network...

   ▰▰▰▰▰▰▰▰▰▱ 90%

   Loaded 45,328 nodes
```

**Design:**
- **Indicator**: Spinning globe wireframe
- **Progress**: Percentage + count
- **Time**: Estimated time remaining
- **Interruptible**: Cancel option

**Incremental Loading:**
```
Immediate:      Core data (1-5s)
Progressive:    Detailed data (5-15s)
Background:     Historical data (15-60s)
```

**Visual:**
- **Phase 1**: Globe outline
- **Phase 2**: Continents appear
- **Phase 3**: Nodes populate
- **Phase 4**: Routes connect

### 9.2 Error States

**Network Error:**
```
┌────────────────────────────┐
│   ⚠ Connection Lost        │
│                            │
│   Cannot reach servers     │
│                            │
│   Showing cached data      │
│   Last updated: 5 min ago  │
│                            │
│   [Retry] [Work Offline]   │
└────────────────────────────┘
```

**Data Error:**
```
┌────────────────────────────┐
│   ⚠ Data Unavailable       │
│                            │
│   Shipment #7432           │
│   not found                │
│                            │
│   [Refresh] [Report Issue] │
└────────────────────────────┘
```

**Design:**
- **Icon**: Warning symbol
- **Message**: Clear, actionable
- **Actions**: Retry, fallback options
- **Context**: What failed, why, what next

### 9.3 Empty States

**No Active Shipments:**
```
┌────────────────────────────┐
│      📦                    │
│                            │
│   No Active Shipments      │
│                            │
│   All deliveries complete! │
│                            │
│   [View History]           │
└────────────────────────────┘
```

**Design:**
- **Visual**: Positive illustration
- **Message**: Encouraging, informative
- **Action**: Next step suggestion

## 10. Animation & Transitions

### 10.1 Animation Principles

```yaml
Duration:
  Instant: 0ms          # Immediate feedback
  Fast: 150ms           # Micro-interactions
  Standard: 300ms       # UI transitions
  Slow: 500ms           # Page transitions
  Very Slow: 1000ms     # Scene changes

Easing:
  Linear: Data updates
  Ease-In: Disappearing
  Ease-Out: Appearing
  Ease-In-Out: Movement
  Spring: Playful interactions
```

### 10.2 Specific Animations

**Window Transitions:**
```swift
.transition(.asymmetric(
    insertion: .scale(scale: 0.8).combined(with: .opacity),
    removal: .scale(scale: 1.2).combined(with: .opacity)
))
.animation(.spring(duration: 0.3), value: isPresented)
```

**Flow Particles:**
```swift
ParticleSystem:
  Emission Rate: 10 particles/sec
  Lifetime: 2 seconds
  Speed: 0.5 m/s
  Color: Fade from status color to transparent
  Trail: Motion blur effect
```

**Globe Rotation:**
```swift
RotationAnimation:
  Duration: Infinite
  Speed: User-controlled
  Inertia: Continues on release (decay over 2s)
  Damping: 0.8
```

**Alert Pulsing:**
```swift
.repeatForever(autoreverses: true) {
    .scale(from: 1.0, to: 1.1, duration: 0.5)
    .opacity(from: 0.8, to: 1.0, duration: 0.5)
}
```

### 10.3 Micro-Interactions

**Button Press:**
```
Normal → Pressed → Released
 1.0x  →  0.95x  →  1.0x
          (50ms)     (150ms)
+ Haptic feedback on press
```

**Toggle Switch:**
```
Off → On
 ○  →  ●
(200ms spring animation)
+ Haptic click
+ Color change
```

**Selection:**
```
Idle → Hover → Selected
       1.1x     1.2x
       Glow     Highlight
     (150ms)   (200ms)
```

---

This design specification creates a cohesive, intuitive, and visually stunning spatial computing experience that transforms complex supply chain data into an immersive, actionable 3D environment optimized for Apple Vision Pro.
