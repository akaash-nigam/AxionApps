# Construction Site Manager - Design Specifications

## Document Overview
**Version:** 1.0
**Last Updated:** 2025-01-20
**Status:** Design Phase

This document defines the UI/UX design specifications for the Construction Site Manager visionOS application, focusing on spatial design principles, interaction patterns, and visual systems optimized for construction site management.

---

## 1. Spatial Design Principles

### 1.1 Core Spatial Philosophy

**"Augmented Intelligence, Not Augmented Reality"**

The Construction Site Manager doesn't just overlay information—it transforms how construction professionals understand and interact with their projects by making the invisible visible and the complex comprehensible.

### 1.2 Design Pillars

#### Pillar 1: Spatial Ergonomics
```
Comfortable viewing zone:
    Vertical: 10-15° below eye level
    Horizontal: ±30° from center
    Depth: 0.5m - 10m optimal
    Distance: 1m - 3m for primary content
```

**Rationale**: Construction professionals wear the device for 8+ hours. Content must be positioned for all-day comfort without neck strain.

#### Pillar 2: Progressive Disclosure
```
Information hierarchy:
    Level 1 (Always visible): Critical safety, current task
    Level 2 (Contextual): Element details, measurements
    Level 3 (On-demand): Full properties, documentation
    Level 4 (Deep dive): History, analytics, reports
```

**Rationale**: Job sites are information-rich environments. Show only what's relevant to prevent cognitive overload.

#### Pillar 3: Reality-Grounded
```
Design rules:
    - Physical world is primary canvas
    - Digital content enhances, doesn't obscure
    - Respect real-world physics and lighting
    - Maintain spatial consistency
```

**Rationale**: Workers must maintain awareness of physical hazards. Digital content should never compromise safety.

#### Pillar 4: Context-Aware
```
Contextual adaptation:
    Location → Show relevant site area
    Task → Surface appropriate tools
    Role → Display role-specific information
    Time → Present schedule-relevant data
```

**Rationale**: Same interface serves project managers, superintendents, safety officers, and trade workers—each needs different views.

### 1.3 Spatial Zones

```
Construction AR Spatial Map:

┌─────────────────────────────────────────────────────────┐
│                  Ambient Zone (10m+)                    │
│         - Site-wide status                              │
│         - Weather, schedule overview                    │
│         - Notifications (peripheral vision)             │
│                                                         │
│   ┌─────────────────────────────────────────────┐     │
│   │        Work Zone (2m - 10m)                 │     │
│   │   - Active BIM overlay                      │     │
│   │   - Crew positions                          │     │
│   │   - Equipment status                        │     │
│   │   - Safety zones                            │     │
│   │                                             │     │
│   │   ┌─────────────────────────────────┐     │     │
│   │   │  Task Zone (0.5m - 2m)          │     │     │
│   │   │  - Element details              │     │     │
│   │   │  - Measurements                 │     │     │
│   │   │  - Tools UI                     │     │     │
│   │   │  - Current task info            │     │     │
│   │   │                                 │     │     │
│   │   │  ┌───────────────────┐         │     │     │
│   │   │  │  Hand Space       │         │     │     │
│   │   │  │  (arm's length)   │         │     │     │
│   │   │  │  - Tool palette   │         │     │     │
│   │   │  │  - Quick actions  │         │     │     │
│   │   │  │  - Gestures       │         │     │     │
│   │   │  └───────────────────┘         │     │     │
│   │   └─────────────────────────────────┘     │     │
│   └─────────────────────────────────────────────┘     │
└─────────────────────────────────────────────────────────┘
```

---

## 2. Window Layouts and Configurations

### 2.1 Main Control Window (2D)

**Purpose**: Primary control center for site management

**Default Layout:**
```
┌──────────────────────────────────────────────────────┐
│  Construction Site Manager            [☰] [?] [⚙]   │
├──────────────────────────────────────────────────────┤
│                                                      │
│  📍 Downtown Tower Project                          │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                                      │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐   │
│  │  Progress  │  │   Safety   │  │   Issues   │   │
│  │    67%     │  │  Score: 95 │  │     12     │   │
│  │   ↗ +5%    │  │    ✓ OK    │  │  ⚠ 3 High  │   │
│  └────────────┘  └────────────┘  └────────────┘   │
│                                                      │
│  Today's Tasks ─────────────────────  [View All]   │
│                                                      │
│  ☑ Morning safety walk               Completed      │
│  ◻ Concrete pour - Grid B7           8:00 AM        │
│  ◻ Electrical rough-in inspection    10:00 AM       │
│  ◻ Coordination meeting               2:00 PM        │
│                                                      │
│  Active Alerts ─────────────────────                │
│                                                      │
│  ⚠ Worker near crane zone - Grid D4  [View] [ACK]  │
│  ℹ Material delivery delayed 1 hour   [Dismiss]     │
│                                                      │
│  ┌─────────────────────────────────────────────┐   │
│  │  [📍 AR View]  [📊 Reports]  [👥 Team]     │   │
│  └─────────────────────────────────────────────┘   │
│                                                      │
└──────────────────────────────────────────────────────┘
```

**Specifications:**
- **Size**: 800×600 points (default), resizable 600×400 to 1200×900
- **Position**: Floating, user-controlled
- **Style**: Glass material with vibrancy
- **Refresh**: Real-time updates
- **Ornament**: Bottom toolbar with quick actions

### 2.2 Site Selection Window

**Purpose**: Choose active site and project

```
┌────────────────────────────────────────┐
│  Select Site            [Search] [+]   │
├────────────────────────────────────────┤
│                                        │
│  Recent Sites ───────────────────────  │
│                                        │
│  📍 Downtown Tower                     │
│     Commercial • 67% Complete          │
│     Last visited: 2 hours ago          │
│                                        │
│  📍 Harbor Bridge                      │
│     Infrastructure • 23% Complete      │
│     Last visited: Yesterday            │
│                                        │
│  📍 Riverside Residential              │
│     Residential • 89% Complete         │
│     Last visited: 3 days ago           │
│                                        │
│  All Sites ───────────────────────────  │
│                                        │
│  [View all 24 sites →]                │
│                                        │
└────────────────────────────────────────┘
```

### 2.3 Issue Detail Window

**Purpose**: View and manage construction issues

```
┌────────────────────────────────────────────────────┐
│  ← Issue #127                    [Edit] [Resolve]  │
├────────────────────────────────────────────────────┤
│                                                    │
│  Electrical conduit conflicts with HVAC duct      │
│  ──────────────────────────────────────────────   │
│                                                    │
│  Priority: ⚠ High                                 │
│  Status: In Progress                              │
│  Type: Coordination / Clash                       │
│                                                    │
│  Location ────────────────────────────────────    │
│  Floor 3, Grid F-7                                │
│  [View in AR] [Show on Plan]                      │
│                                                    │
│  Details ──────────────────────────────────────   │
│  Electrical conduit routing conflicts with         │
│  main supply duct. Requires coordination between   │
│  electrical and mechanical trades.                 │
│                                                    │
│  Photos ──────────────────────────────────────    │
│  [📷 Photo 1] [📷 Photo 2] [📷 Photo 3]          │
│                                                    │
│  Assigned to: Mike Chen (Electrical)              │
│  Reported by: Sarah Johnson (Super)                │
│  Created: Today, 9:23 AM                          │
│  Due: Tomorrow, 5:00 PM                           │
│                                                    │
│  Resolution Plan ──────────────────────────────   │
│  Reroute conduit 300mm west to avoid duct.        │
│  Estimated cost: $2,400                           │
│  Schedule impact: None (slack available)          │
│                                                    │
│  Comments (3) ─────────────────────────────────   │
│  [View discussion thread]                          │
│                                                    │
└────────────────────────────────────────────────────┘
```

### 2.4 Settings Window

**Purpose**: Application configuration

```
┌────────────────────────────────────────┐
│  Settings                         [✓]  │
├────────────────────────────────────────┤
│                                        │
│  ⚙ General                            │
│  👤 Profile                            │
│  🔒 Privacy & Security                │
│  🎨 Appearance                         │
│  ♿ Accessibility                       │
│  🔔 Notifications                      │
│  📡 Sync & Offline                     │
│  🎯 AR Settings                        │
│  📱 Connected Devices                  │
│  ℹ About                               │
│                                        │
└────────────────────────────────────────┘
```

---

## 3. Volume Designs (3D Bounded Spaces)

### 3.1 Site Overview Volume

**Purpose**: Interactive 3D site model for planning and coordination

**Specifications:**
- **Size**: 2m × 1.5m × 2m (default)
- **Style**: Volumetric with glass bounds
- **Content**: Full BIM model, color-coded by status
- **Interactions**: Rotate, zoom, pan, select

**Visual Design:**

```
     ┌─────────────────────┐
    ╱                     ╱│
   ╱     [Building]      ╱ │   Glass container
  ╱         │           ╱  │
 ╱      ┌───┴───┐      ╱   │
┌───────│░░░░░░░│─────┐    │
│       │░Green░│     │    │  Completed (Green)
│   ┌───│░area░░│───┐ │    │  In Progress (Orange)
│   │ ┌─│░░░░░░░│─┐ │ │   ╱   Not Started (Gray Ghost)
│   │ │ └───────┘ │ │ │  ╱    Issues (Red Markers)
│   │ │    🏗     │ │ │ ╱
│   │ └───────────┘ │ │╱
│   └───────────────┘ │
└─────────────────────┘

     Bottom ornament:
   [Layers] [Timeline] [Filter]
```

**Layer Controls:**
```
Filters (toggleable):
☑ Structure
☑ Architectural
☑ MEP Systems
☑ Safety Zones
☑ Worker Locations
☑ Equipment
☐ Completed Work (ghosted)
```

**Timeline Scrubber:**
```
━━━━━━━━━●━━━━━━━━━━━━━━━━━━→
Jan       Today            Dec
          ▼
     Show as-built up to today
```

### 3.2 Coordination Volume

**Purpose**: Multi-trade clash detection and resolution

```
┌─────────────────────────┐
│   Clash Detection       │
├─────────────────────────┤
│                         │
│    [3D Model View]      │
│    Highlighting:        │
│    🔴 Structural        │
│    🔵 Electrical        │
│    🟢 Mechanical        │
│                         │
│  Conflicts: 3 Found     │
│  ⚠ High Priority: 1     │
│  ⚠ Medium: 2            │
│                         │
│  [< Prev] [Next >]      │
│                         │
└─────────────────────────┘
```

### 3.3 Schedule 4D Volume

**Purpose**: Visualize construction sequence over time

**Animation Controls:**
```
⏮ ⏪ ▶ ⏩ ⏭   Speed: [1x ▼]

Week 1: Foundation
Week 4: Structure L1-L3
Week 8: MEP Rough-In
Week 12: Finishes
```

**Visual States:**
- **Future work**: Transparent ghost (10% opacity)
- **Current week**: Solid color, pulsing outline
- **Completed**: Full color, no effects

---

## 4. Full Space / Immersive Experiences

### 4.1 AR Site Overlay (Mixed Reality)

**Primary Use Mode**: On-site construction management

**Visual Layers:**

```
Physical Site (Passthrough)
         │
         ├─ Layer 1: BIM Overlay (Ghost/Wireframe)
         │    └─ Aligned to GPS + Visual markers
         │    └─ Transparent to see through
         │    └─ Color-coded by status
         │
         ├─ Layer 2: Progress Indication
         │    └─ Green = Completed
         │    └─ Orange = In Progress
         │    └─ Red = Behind Schedule
         │
         ├─ Layer 3: Safety Zones
         │    └─ Red boundaries for danger zones
         │    └─ Pulsing when user approaches
         │    └─ Warning radius: 2m
         │
         ├─ Layer 4: Annotations
         │    └─ Issue markers (Red pins)
         │    └─ Measurements (Blue lines)
         │    └─ Notes (Yellow cards)
         │
         ├─ Layer 5: Worker Tracking
         │    └─ Avatars with trade colors
         │    └─ Name tags at distance
         │    └─ Privacy mode available
         │
         └─ Layer 6: UI Overlay
              └─ Contextual menus
              └─ Tool palette
              └─ Status bar
```

**UI Placement in AR:**

```
                    Status Bar
         ┌────────────────────────────┐
         │  Site ┊ 67% ┊ 12 Issues  │
         └────────────────────────────┘

USER'S VIEW →                 Tool Palette
                               (right side)
                              ┌──────┐
   [BIM Model Overlay]        │  📏  │ Measure
   with color coding          │  📝  │ Annotate
                              │  📷  │ Photo
                              │  ⚠   │ Issue
   [Safety Zones]             │  ✓   │ Approve
   visible as boundaries      └──────┘


         Contextual Info Panel
         (when looking at element)
         ┌──────────────────┐
         │  Concrete Wall   │
         │  Grid B-7        │
         │  Status: Complete│
         │  [Details →]     │
         └──────────────────┘
```

### 4.2 Immersive Training Environment

**Purpose**: Safety training and site familiarization

**Experience Flow:**
```
1. Intro Scene
   - Welcome message
   - Training objectives
   - Safety briefing

2. Site Walkthrough
   - Guided tour of virtual site
   - Hazard identification
   - Equipment orientation

3. Interactive Scenarios
   - Respond to safety situations
   - Practice procedures
   - Emergency response

4. Assessment
   - Test knowledge
   - Certification
   - Performance feedback
```

**Visual Environment:**
- Fully immersive (real world replaced)
- Photorealistic construction site
- Animated equipment and workers
- Spatial audio for realism
- Clear exit indicators

### 4.3 Client Presentation Mode

**Purpose**: Show project progress to stakeholders

**Features:**
- Time-lapse construction animation
- Side-by-side planned vs. actual
- Key milestone highlights
- Cinematic camera paths
- Narration support

---

## 5. 3D Visualization Specifications

### 5.1 BIM Model Rendering

**Visual Styles:**

| Style | Use Case | Appearance |
|-------|----------|------------|
| **Realistic** | Client presentations | Full textures, shadows, realistic materials |
| **Technical** | Coordination | Color by system, simplified geometry |
| **Progress** | Site management | Color by status, transparency for future |
| **X-Ray** | Inspection | Wireframe with hidden systems visible |
| **Thermal** | MEP systems | Heat map visualization |

**Color Coding Standards:**

```swift
// Progress Status Colors
enum StatusColor {
    case notStarted    = #CCCCCC  // Gray
    case inProgress    = #FFA500  // Orange
    case completed     = #4CAF50  // Green
    case approved      = #2196F3  // Blue
    case issue         = #F44336  // Red
    case onHold        = #9C27B0  // Purple
}

// Discipline Colors
enum DisciplineColor {
    case architectural = #8D6E63  // Brown
    case structural    = #757575  // Dark Gray
    case mechanical    = #2196F3  // Blue
    case electrical    = #FFC107  // Amber
    case plumbing      = #4CAF50  // Green
    case fireProtection = #F44336  // Red
}

// Safety Colors
enum SafetyColor {
    case safe          = #4CAF50  // Green
    case caution       = #FFC107  // Yellow
    case danger        = #F44336  // Red
    case restricted    = #9C27B0  // Purple
}
```

### 5.2 Material and Lighting

**Glass Materials (visionOS Style):**
```swift
// UI Panels
.glassBackgroundEffect()
.vibrancy(.regular)

// Danger zones
.glassBackgroundEffect(
    in: RoundedRectangle(cornerRadius: 8),
    displayMode: .always
)
.opacity(0.3)
.foregroundStyle(.red)
```

**Lighting:**
- Ambient: Match real-world lighting
- Directional: Soft shadows for depth perception
- Point lights: Highlight important elements
- Emissive: Safety alerts, notifications

### 5.3 Transparency and Occlusion

**Occlusion Rules:**
1. Real world always occludes virtual
2. Safety information never fully occluded
3. Selected elements brought to front
4. UI elements always on top

**Transparency:**
```
Opacity Levels:
- Future work: 10-20%
- Ghost view: 30-40%
- Context elements: 50-60%
- Active elements: 100%
```

---

## 6. Interaction Patterns

### 6.1 Gaze and Pinch

**Selection:**
```
1. User looks at element
   └─> Element highlights (subtle glow)

2. User pinches fingers
   └─> Element selected (strong highlight)
   └─> Context menu appears

3. User releases pinch
   └─> Action confirmed
```

**Visual Feedback:**
```
Hover (gaze):
  └─ 200ms delay before highlight
  └─ Subtle blue glow
  └─ 0.3s fade in

Selection (pinch):
  └─ Immediate highlight
  └─ Bright blue outline
  └─ Haptic feedback
  └─ Audio "click"
```

### 6.2 Hand Tracking Gestures

**Measurement Gesture:**
```
Action: Extend thumb and index finger (both hands)

Visual Feedback:
1. First point: Blue sphere appears
2. Connecting line: Dashed blue line follows second hand
3. Second point: Blue sphere, line solidifies
4. Result: Dimension label appears at midpoint

       ●━━━━━━━━━━●
       └─ 3.45m ─┘
```

**Annotation Gesture:**
```
Action: Point with index finger, hold 1 second

Visual Feedback:
1. Point at surface
2. Reticle appears (0.5s)
3. Reticle fills (1.0s)
4. Annotation pin appears
5. Voice input activates

    ⊕  →  ⊗  →  📍
   Start  Fill  Done
```

### 6.3 Voice Commands

**Command Structure:**
```
"[Action] [Object] [Optional: Location/Modifier]"

Examples:
- "Show electrical systems"
- "Hide completed work"
- "Measure this wall"
- "Create issue here"
- "Find John Smith"
- "What's the schedule for today?"
- "Show me Grid B-7"
```

**Voice Feedback:**
```
1. User speaks
2. Audio waveform visual indicator
3. Command recognized → checkmark
4. Action performed
5. Verbal confirmation (optional)
```

### 6.4 Context Menus

**Spatial Context Menu:**
```
       Look at element + pinch

          ┌─────────────┐
          │   Details   │
          ├─────────────┤
          │  📏 Measure │
          │  📝 Note    │
          │  📷 Photo   │
          │  ⚠ Issue    │
          │  ✓ Approve  │
          │  ℹ Info     │
          └─────────────┘
              ↓
           Element
```

---

## 7. Visual Design System

### 7.1 Typography

**Font Family**: SF Pro (System font)

**Type Scale:**
```swift
enum TextStyle {
    case largeTitle   // 34pt, Bold
    case title1       // 28pt, Bold
    case title2       // 22pt, Bold
    case title3       // 20pt, Semibold
    case headline     // 17pt, Semibold
    case body         // 17pt, Regular
    case callout      // 16pt, Regular
    case subheadline  // 15pt, Regular
    case footnote     // 13pt, Regular
    case caption1     // 12pt, Regular
    case caption2     // 11pt, Regular
}
```

**Spatial Text Rendering:**
```swift
// 3D text in space
Text3D("Grid B-7")
    .font(.title2.weight(.semibold))
    .depth(.medium)  // Extruded text
    .billboardMode(.horizontal)  // Always faces user
```

**Legibility:**
- Minimum size in AR: 14pt
- Maximum viewing distance: 5 meters
- High contrast against all backgrounds
- Adaptive brightness

### 7.2 Color Palette

**Primary Colors:**
```swift
// Brand Colors
let primaryBlue    = Color(hex: "#2196F3")  // Actions, links
let secondaryBlue  = Color(hex: "#1976D2")  // Hover states
let accentOrange   = Color(hex: "#FF9800")  // Highlights

// Semantic Colors
let successGreen   = Color(hex: "#4CAF50")  // Success, complete
let warningYellow  = Color(hex: "#FFC107")  // Warnings, caution
let errorRed       = Color(hex: "#F44336")  // Errors, danger
let infoBlue       = Color(hex: "#2196F3")  // Information

// Neutral Colors
let textPrimary    = Color.primary           // Adapts to light/dark
let textSecondary  = Color.secondary
let background     = Color(.systemBackground)
let surface        = Color(.secondarySystemBackground)
```

**Spatial Colors:**
```swift
// Glass materials with vibrancy
.foregroundStyle(.primary)      // High contrast
.foregroundStyle(.secondary)    // Medium contrast
.foregroundStyle(.tertiary)     // Low contrast
```

**Construction-Specific Palette:**
```
Concrete: #BDBDBD
Steel:    #616161
Wood:     #8D6E63
Glass:    #90CAF9 (translucent)
```

### 7.3 Materials and Lighting

**visionOS Glass Materials:**
```swift
// Standard UI panels
struct GlassPanel: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(.regularMaterial)
            .strokeBorder(.quaternary, lineWidth: 1)
    }
}

// Danger zones
struct DangerZoneVisual: View {
    var body: some View {
        Capsule()
            .fill(.red.opacity(0.2))
            .stroke(.red, lineWidth: 2)
            .glassBackgroundEffect()
    }
}
```

**3D Materials:**
- **Metal**: PBR metallic workflow
- **Concrete**: Rough, matte appearance
- **Glass**: Transparency with refraction
- **Plastic**: Slight gloss

**Lighting for Depth:**
```swift
// Subtle shadow for depth
.shadow(color: .black.opacity(0.1),
        radius: 8, x: 0, y: 4)

// Glow for emphasis
.shadow(color: .blue.opacity(0.5),
        radius: 12, x: 0, y: 0)
```

### 7.4 Iconography

**Icon Style:**
- SF Symbols for UI elements
- Custom 3D icons for construction elements
- Consistent stroke weight: 2pt
- Grid system: 44×44pt minimum touch target

**Construction Icons:**
```
Safety:
⚠ Warning
🚧 Construction
⛑ Hard Hat
🔒 Restricted
🔥 Hot Work

Elements:
🏗 Structure
⚡ Electrical
💧 Plumbing
❄ HVAC
🔥 Fire Protection

Actions:
📏 Measure
📝 Note
📷 Photo
✓ Approve
✗ Reject
```

**3D Spatial Icons:**
- Floating above surface
- Always face user (billboard)
- Scale based on distance
- Fade with distance

---

## 8. User Flows and Navigation

### 8.1 Primary User Flows

**Flow 1: Daily Site Inspection**

```
1. Launch App
   ├─ Authenticate (Face ID)
   └─ Load recent site
       ↓
2. Open AR Overlay
   ├─ BIM model aligns
   └─ Progress layer activates
       ↓
3. Walk Site
   ├─ Check progress vs. plan
   ├─ Identify issues
   └─ Take photos
       ↓
4. Create Issues
   ├─ Flag issue gesture
   ├─ Voice description
   ├─ Assign to worker
   └─ Save
       ↓
5. Review & Report
   ├─ Progress summary
   ├─ Issues logged
   └─ Sync to cloud
```

**Flow 2: Progress Update**

```
1. Navigate to Area
   ├─ AR overlay active
   └─ Element in view
       ↓
2. Select Element
   ├─ Gaze + pinch
   └─ Context menu appears
       ↓
3. Update Status
   ├─ "Mark as Complete"
   ├─ Capture photo (optional)
   └─ Confirm
       ↓
4. Verification
   ├─ Element turns green
   ├─ Progress % updates
   └─ Sync to cloud
```

**Flow 3: Coordination Meeting**

```
1. Start Collaboration Session
   ├─ Open Site Volume
   └─ Invite participants
       ↓
2. Navigate to Clash
   ├─ Shared view
   ├─ Highlight conflict
   └─ Discuss
       ↓
3. Propose Solution
   ├─ Annotate
   ├─ Voice discussion
   └─ Capture decision
       ↓
4. Assign Work
   ├─ Create tasks
   ├─ Assign to trades
   └─ Set deadlines
       ↓
5. Document
   ├─ Meeting notes
   ├─ Photos
   └─ Action items
```

### 8.2 Navigation Patterns

**Spatial Navigation:**
```
Window Mode:
  - Tab bars for sections
  - Sidebar for hierarchy
  - Breadcrumbs for depth

Volume Mode:
  - Rotate: Two-finger twist
  - Zoom: Pinch/spread
  - Pan: Drag with hand
  - Reset: "Reset view" button

AR Mode:
  - Physical movement (walk)
  - Teleport to location (tap map)
  - Follow worker (select avatar)
  - Return to site origin (home button)
```

**Information Architecture:**
```
App Structure:
├─ Dashboard (Home)
├─ Sites
│  └─ Site Detail
│     ├─ Overview
│     ├─ Progress
│     ├─ Safety
│     ├─ Issues
│     ├─ Schedule
│     └─ Team
├─ AR View
│  ├─ BIM Overlay
│  ├─ Progress Layer
│  ├─ Safety Layer
│  └─ Annotations
├─ Reports
│  ├─ Daily Logs
│  ├─ Progress Reports
│  ├─ Safety Reports
│  └─ Custom Reports
└─ Settings
```

---

## 9. Accessibility Design

### 9.1 VoiceOver Optimization

**Spatial Element Descriptions:**
```swift
// BIM element accessibility
element.accessibilityLabel = "Concrete wall, Grid B-7"
element.accessibilityHint = "Double tap to view details. Located 5 meters ahead."
element.accessibilityValue = "Status: In Progress, 60% complete"

// Spatial audio cue
element.accessibilityDirectionalAudioCue = .location(bearing: 45°, distance: 5m)
```

**Readable Content:**
- All text has proper labels
- Status communicated verbally
- Spatial relationships described
- Distance information provided

### 9.2 Visual Accommodations

**High Contrast Mode:**
```swift
@Environment(\.accessibilityReduceTransparency) var reduceTransparency
@Environment(\.colorSchemeContrast) var contrast

var backgroundColor: Color {
    if contrast == .increased {
        return .black  // Pure black for high contrast
    } else {
        return .background
    }
}
```

**Text Scaling:**
- All text respects Dynamic Type
- Layout adapts to larger text
- Minimum tap targets: 44×44pt
- Increased spacing for readability

**Color Blindness:**
- Never use color alone
- Patterns in addition to colors
- High contrast ratios (WCAG AA)
- Simulation testing for all types

### 9.3 Motor Accommodations

**Dwell Control:**
```
Gaze at element → Auto-select after 2s
  └─ Progress ring shows countdown
  └─ Cancel by looking away
```

**Voice Control:**
```
"Show numbers" → Label all interactive elements
"Tap 5" → Activate element #5
"Scroll down" → Navigate content
```

**Switch Control:**
- Sequential navigation
- Item scanning
- Group scanning
- Auto-scanning with adjustable timing

---

## 10. Error States and Loading Indicators

### 10.1 Error States

**Network Error:**
```
┌─────────────────────────────────┐
│                                 │
│          📡                      │
│                                 │
│     Connection Lost             │
│                                 │
│  Working in offline mode.       │
│  Changes will sync when         │
│  connection is restored.        │
│                                 │
│     [Retry Connection]          │
│                                 │
└─────────────────────────────────┘
```

**BIM Load Error:**
```
┌─────────────────────────────────┐
│          ⚠                       │
│                                 │
│   Unable to Load BIM Model      │
│                                 │
│  The model file is corrupted    │
│  or not supported.              │
│                                 │
│  Error code: BIM_001            │
│                                 │
│  [Try Again]  [Contact Support] │
└─────────────────────────────────┘
```

**AR Tracking Lost:**
```
         ┌──────────────┐
         │  Move device │
         │  to restore  │
         │   tracking   │
         └──────────────┘
              ↓
         [Animation]
     (User moving device)
```

### 10.2 Loading States

**Initial Load:**
```
┌─────────────────────────────────┐
│                                 │
│     Construction Site Manager   │
│                                 │
│     ⟳ Loading site data...     │
│     ███████░░░░░░░░  45%        │
│                                 │
│     • Downloading BIM model     │
│     • Syncing progress data     │
│     • Fetching team info        │
│                                 │
└─────────────────────────────────┘
```

**AR Alignment:**
```
         ┌──────────────┐
         │  Aligning    │
         │   to site    │
         └──────────────┘
              ↓
         ⟳ Scanning...
              ↓
         ✓ Aligned!
```

**Progress Indicators:**
```swift
// Determinate progress
ProgressView(value: progress, total: 1.0) {
    Text("Loading BIM Model")
}
.progressViewStyle(.linear)

// Indeterminate
ProgressView {
    Text("Syncing...")
}
.progressViewStyle(.circular)

// Spatial progress (3D)
Sphere()
    .trim(from: 0, to: progress)
    .stroke(.blue, lineWidth: 4)
```

### 10.3 Empty States

**No Sites:**
```
┌─────────────────────────────────┐
│                                 │
│          🏗                     │
│                                 │
│    No Sites Yet                 │
│                                 │
│  Start by adding your first     │
│  construction site.             │
│                                 │
│       [+ Add Site]              │
│                                 │
└─────────────────────────────────┘
```

**No Issues:**
```
┌─────────────────────────────────┐
│          ✓                      │
│                                 │
│    No Open Issues               │
│                                 │
│  Great work! All issues are     │
│  resolved.                      │
│                                 │
└─────────────────────────────────┘
```

---

## 11. Animation and Transition Specifications

### 11.1 Timing Functions

```swift
enum AnimationCurve {
    static let `default` = Animation.easeInOut(duration: 0.3)
    static let spring = Animation.spring(response: 0.4, dampingFraction: 0.8)
    static let quick = Animation.easeOut(duration: 0.2)
    static let slow = Animation.easeInOut(duration: 0.5)
}
```

### 11.2 Transitions

**Window Appearance:**
```swift
.transition(.asymmetric(
    insertion: .scale(scale: 0.9).combined(with: .opacity),
    removal: .opacity
))
.animation(.spring(response: 0.4, dampingFraction: 0.8))
```

**Element Highlight:**
```swift
// Smooth fade in
.opacity(isHighlighted ? 1.0 : 0.0)
.animation(.easeInOut(duration: 0.3))

// Pulse effect
.scaleEffect(isHighlighted ? 1.05 : 1.0)
.animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true))
```

**Progress Updates:**
```swift
// Number count up
Text("\(Int(progress * 100))%")
    .contentTransition(.numericText())
    .animation(.default)
```

**Safety Alert:**
```swift
// Pulsing danger zone
Circle()
    .stroke(.red, lineWidth: 4)
    .scaleEffect(isPulsing ? 1.2 : 1.0)
    .opacity(isPulsing ? 0.3 : 1.0)
    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true))
```

### 11.3 Spatial Animations

**Entity Movement:**
```swift
entity.move(
    to: Transform(translation: targetPosition),
    relativeTo: nil,
    duration: 0.5,
    timingFunction: .easeInOut
)
```

**Fade In/Out:**
```swift
var opacityComponent = OpacityComponent()
opacityComponent.opacity = 0.0

entity.components[OpacityComponent.self] = opacityComponent

// Animate to visible
entity.components[OpacityComponent.self]?.opacity = 1.0
// (RealityKit automatically interpolates over time)
```

**4D Timeline:**
```swift
// Animate construction sequence
for week in 1...52 {
    let elementsThisWeek = schedule.elements(for: week)

    await animateConstruction(elementsThisWeek) { element in
        // Fade in from ghost
        element.opacity: 0.1 → 1.0 (over 0.5s)
        // Change color to indicate progress
        element.color: .gray → .green
    }

    await Task.sleep(nanoseconds: animationDelay)
}
```

---

## 12. Design Patterns Library

### 12.1 Common Components

**Button Styles:**
```swift
// Primary action
Button("Continue") { }
    .buttonStyle(.borderedProminent)

// Secondary action
Button("Cancel") { }
    .buttonStyle(.bordered)

// Destructive action
Button("Delete", role: .destructive) { }
    .buttonStyle(.bordered)

// Spatial button (3D)
Button3D {
    // Action
} label: {
    Label("Measure", systemImage: "ruler")
}
```

**Cards:**
```swift
struct IssueCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundStyle(.red)
                Text("High Priority")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("2h ago")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Text("Electrical conduit conflicts with HVAC duct")
                .font(.headline)

            Text("Floor 3, Grid F-7")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
```

**List Items:**
```swift
List {
    ForEach(issues) { issue in
        NavigationLink {
            IssueDetailView(issue: issue)
        } label: {
            IssueRow(issue: issue)
        }
    }
}
.listStyle(.plain)
```

### 12.2 Spatial Components

**Floating Label:**
```swift
struct FloatingLabel: View {
    let text: String
    let position: SIMD3<Float>

    var body: some View {
        RealityView { content in
            let textEntity = ModelEntity(
                mesh: .generateText(text),
                materials: [SimpleMaterial(color: .white, isMetallic: false)]
            )
            textEntity.position = position
            textEntity.billboard(.all)  // Always face user
            content.add(textEntity)
        }
    }
}
```

**Measurement Line:**
```swift
struct MeasurementLine: View {
    let start: SIMD3<Float>
    let end: SIMD3<Float>

    var distance: Float {
        simd_distance(start, end)
    }

    var body: some View {
        RealityView { content in
            // Create line entity
            let line = createLine(from: start, to: end, color: .blue)
            content.add(line)

            // Create distance label at midpoint
            let midpoint = (start + end) / 2
            let label = createLabel("\(String(format: "%.2f", distance))m", at: midpoint)
            content.add(label)

            // Create endpoint spheres
            let startSphere = createSphere(at: start, radius: 0.05, color: .blue)
            let endSphere = createSphere(at: end, radius: 0.05, color: .blue)
            content.add(startSphere)
            content.add(endSphere)
        }
    }
}
```

---

## 13. Responsive Design

### 13.1 Adaptive Layouts

**Window Size Classes:**
```swift
@Environment(\.horizontalSizeClass) var horizontalSizeClass
@Environment(\.verticalSizeClass) var verticalSizeClass

var body: some View {
    if horizontalSizeClass == .compact {
        CompactLayout()
    } else {
        RegularLayout()
    }
}
```

**Dynamic Spacing:**
```swift
var spacing: CGFloat {
    switch horizontalSizeClass {
    case .compact: return 12
    case .regular: return 20
    default: return 16
    }
}
```

### 13.2 Distance-Based Scaling

**Spatial UI Scaling:**
```swift
func scaleFactor(for distance: Float) -> Float {
    // UI elements scale with distance for readability
    let minScale: Float = 1.0
    let maxScale: Float = 3.0
    let minDistance: Float = 1.0
    let maxDistance: Float = 10.0

    let normalized = (distance - minDistance) / (maxDistance - minDistance)
    return simd_mix(minScale, maxScale, simd_clamp(normalized, 0, 1))
}
```

---

## Appendices

### A. Design Checklist

**For Each New Feature:**
- [ ] Follows spatial ergonomics (10-15° below eye level)
- [ ] Progressive disclosure applied
- [ ] Accessible (VoiceOver, Dynamic Type, high contrast)
- [ ] Error states designed
- [ ] Loading states designed
- [ ] Empty states designed
- [ ] Works in bright sunlight
- [ ] Works in low light
- [ ] Tested with reduced motion
- [ ] Voice control alternative provided
- [ ] Animations respect user preferences

### B. Design Tokens

```swift
// Spacing
enum Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
}

// Corner Radius
enum CornerRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
}

// Shadows
enum Shadow {
    static let sm = (radius: 4.0, x: 0.0, y: 2.0, opacity: 0.1)
    static let md = (radius: 8.0, x: 0.0, y: 4.0, opacity: 0.1)
    static let lg = (radius: 16.0, x: 0.0, y: 8.0, opacity: 0.15)
}
```

### C. Platform-Specific Considerations

**visionOS Unique Features:**
- Glass materials with vibrancy
- Adaptive window positioning
- Spatial audio
- Eye tracking (privacy-preserving)
- Hand tracking (high precision)
- Passthrough (environmental awareness)

---

## Document Version History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 1.0 | 2025-01-20 | Initial design specifications | Claude |

---

**End of Design Specifications**
