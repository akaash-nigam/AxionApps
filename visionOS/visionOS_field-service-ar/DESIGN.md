# Field Service AR Assistant - Design Specifications

## 1. Spatial Design Principles

### 1.1 Core Design Philosophy

**"Information Where You Need It, When You Need It"**

The Field Service AR Assistant follows these spatial design principles:

1. **Progressive Disclosure**: Start with 2D windows, expand to 3D volumes, immerse for hands-on work
2. **Contextual Placement**: Information appears near relevant physical objects
3. **Ergonomic Positioning**: UI at comfortable viewing angles (10-15° below eye level)
4. **Minimal Occlusion**: Preserve view of physical equipment while providing guidance
5. **Depth Hierarchy**: Use z-axis to indicate information priority
6. **Persistent Anchoring**: AR overlays stay locked to equipment, not to user's view

### 1.2 Spatial Zones

```
User's Spatial Environment:

Close Work Zone (0.3m - 0.5m)
├─ Component details
├─ Measurement tools
├─ Fine-tuned adjustments
└─ Hand interaction optimized

Primary Work Zone (0.5m - 1.5m)
├─ Equipment overview
├─ Procedure steps
├─ Tool references
└─ Main interaction area

Peripheral Zone (1.5m - 3m)
├─ Contextual windows
├─ Parts catalog
├─ Expert video feed
└─ Background monitoring

Ambient Zone (3m+)
├─ Notifications
├─ Status indicators
└─ Environmental context
```

### 1.3 visionOS Design Patterns

- **Glass Materials**: Translucent backgrounds that reveal environment
- **Vibrancy**: System-provided visual effects for depth and hierarchy
- **Shadows**: Real-time shadows for spatial grounding
- **Scale Adaptation**: UI scales with distance for consistent legibility
- **Billboard Behavior**: Critical info faces user, while spatial markers stay anchored

## 2. Window Layouts & Configurations

### 2.1 Dashboard Window (Primary Entry)

```
┌────────────────────────────────────────────────┐
│  ⚡ Field Service AR          👤 John Tech ▼   │
├────────────────────────────────────────────────┤
│                                                │
│  Today's Jobs (4)           📅 Nov 17, 2025   │
│                                                │
│  ┌──────────────────────────────────────────┐ │
│  │ 🔧 HVAC-2471 • Industrial Chiller         │ │
│  │ Acme Manufacturing                        │ │
│  │ 📍 2.3 mi away • ⏰ 9:00 AM - 11:00 AM   │ │
│  │                                           │ │
│  │ [View Details]              [Start Job ▶] │ │
│  └──────────────────────────────────────────┘ │
│                                                │
│  ┌──────────────────────────────────────────┐ │
│  │ ⚡ ELEC-5123 • Backup Generator           │ │
│  │ City Hospital                             │ │
│  │ 📍 8.7 mi away • ⏰ 1:00 PM - 3:00 PM     │ │
│  │                                           │ │
│  │ [View Details]              [Start Job ▶] │ │
│  └──────────────────────────────────────────┘ │
│                                                │
│  ┌──────────────────────────────────────────┐ │
│  │ 💧 PLUMB-8842 • Water Treatment System   │ │
│  │ Tech Campus Building 5                    │ │
│  │ 📍 12.1 mi away • ⏰ 3:30 PM - 5:00 PM    │ │
│  │                                           │ │
│  │ [View Details]              [Start Job ▶] │ │
│  └──────────────────────────────────────────┘ │
│                                                │
├────────────────────────────────────────────────┤
│  [📚 Library] [📊 Analytics] [⚙️ Settings]    │
└────────────────────────────────────────────────┘

800pt × 600pt
Glass background with vibrancy
Floating 10° below eye level
```

**Visual Specifications:**
- Background: `.ultraThinMaterial` with `.regular` vibrancy
- Corner radius: 20pt
- Padding: 24pt
- Card spacing: 16pt
- Typography: SF Pro with Dynamic Type

### 2.2 Job Details Window

```
┌────────────────────────────────────────────────────┐
│  ← Back to Jobs          HVAC-2471              ⋮  │
├────────────────────────────────────────────────────┤
│                                                    │
│  Industrial Chiller - Model CH-5000               │
│  Acme Manufacturing, Building B                   │
│                                                    │
│  ┌──────────────────┬────────────────────────────┐│
│  │                  │  Customer: Acme Mfg.       ││
│  │   [3D Preview]   │  Contact: Jane Doe         ││
│  │                  │  Phone: (555) 123-4567     ││
│  │                  │  Priority: High            ││
│  └──────────────────┴────────────────────────────┘│
│                                                    │
│  📋 Repair Procedure                              │
│  ┌────────────────────────────────────────────┐  │
│  │ ✅ 1. Safety shutdown sequence              │  │
│  │ ⏸  2. Drain refrigerant system              │  │
│  │ ⏸  3. Replace compressor bearings           │  │
│  │ ⏸  4. Recharge system                       │  │
│  │ ⏸  5. Test operation                        │  │
│  └────────────────────────────────────────────┘  │
│                                                    │
│  🔧 Required Parts (3)                            │
│  • Bearing Kit (SKU-4421) - In stock             │
│  • Refrigerant R-410A (SKU-8832) - In stock      │
│  • Oil Filter (SKU-2211) - In stock              │
│                                                    │
│  ┌──────────────────────────────────────────────┐│
│  │         [View 3D Model] [Start AR Mode]      ││
│  └──────────────────────────────────────────────┘│
└────────────────────────────────────────────────────┘

1000pt × 700pt
```

**Interaction Patterns:**
- Tap "[View 3D Model]" → Opens volumetric window
- Tap "[Start AR Mode]" → Transitions to immersive space
- Procedure steps expand on tap for detailed instructions
- Parts list items show inventory status with color coding

### 2.3 Equipment Library Window

```
┌────────────────────────────────────────────────────┐
│  🔍 Search equipment...                    [⚙️]    │
├────────────────────────────────────────────────────┤
│                                                    │
│  Categories                                        │
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐             │
│  │ HVAC │ │ Elec │ │ Plum │ │ Mech │             │
│  └──────┘ └──────┘ └──────┘ └──────┘             │
│                                                    │
│  HVAC Equipment (247 models)                      │
│  ┌────────────────────────────────────┐           │
│  │ [IMG] Industrial Chiller CH-5000   │           │
│  │       Capacity: 500 tons            │           │
│  │       Common Issues: Bearing wear   │           │
│  │       [View Details]                │           │
│  └────────────────────────────────────┘           │
│                                                    │
│  ┌────────────────────────────────────┐           │
│  │ [IMG] Rooftop Unit RTU-3200        │           │
│  │       Capacity: 32 tons             │           │
│  │       Common Issues: Coil freezing  │           │
│  │       [View Details]                │           │
│  └────────────────────────────────────┘           │
│                                                    │
└────────────────────────────────────────────────────┘

900pt × 650pt
```

## 3. Volume Designs (3D Bounded Spaces)

### 3.1 Equipment Preview Volume

```
     Physical Dimensions: 60cm × 60cm × 60cm

         ╭─────────────────────╮
        ╱                     ╱│
       ╱     Equipment 3D    ╱ │
      ╱      Model          ╱  │
     ╱                     ╱   │
    ├─────────────────────┤    │
    │                     │    │
    │   [Rotate gesture]  │    │
    │                     │    │
    │   ┌─────────────┐   │    │
    │   │   Chiller   │   │   ╱
    │   │    Model    │   │  ╱
    │   └─────────────┘   │ ╱
    │                     │╱
    └─────────────────────┘

    Ornament bar at bottom:
    [⟲ Rotate] [✂️ Explode] [🔍 Components] [📏 Measure]
```

**Visual Specifications:**
- Volume size: 0.6m³ (60cm × 60cm × 60cm)
- Background: Slightly frosted glass
- Lighting: Three-point lighting (key, fill, rim)
- Model scale: Auto-fit to 80% of volume
- Material: PBR (Physically Based Rendering)
  - Metallic: 0.8 for metal parts
  - Roughness: 0.3 for worn surfaces
  - Subsurface scattering: For translucent parts

**Interaction Modes:**

1. **Inspection Mode** (Default)
   - Free rotation with drag gesture
   - Pinch to zoom (0.5x - 2.0x)
   - Double-tap to reset view

2. **Exploded View Mode**
   - Components separate along assembly axes
   - Animation: 1.5 second smooth transition
   - Labels appear for each component
   - Tap component to isolate

3. **Component Mode**
   - Highlight selected component
   - Show part number, name, wear status
   - Display replacement history
   - Link to parts catalog

4. **Measurement Mode**
   - Dimensional annotations
   - Critical clearances highlighted
   - Tap-to-measure between points

### 3.2 Parts Catalog Volume

```
     Physical Dimensions: 40cm × 50cm × 40cm

         ╭─────────────────╮
        ╱   Parts Grid    ╱│
       ╱   [Category]    ╱ │
      ╱                 ╱  │
     ├─────────────────┤   │
     │  ┌───┐ ┌───┐   │   │
     │  │[P]│ │[P]│   │   │
     │  └───┘ └───┘   │   │
     │  Bearing Oil    │  ╱
     │  Kit     Filter │ ╱
     └─────────────────┘╱

     Interactive 3D grid of parts
     Tap to expand details
     Stock status color coding
```

## 4. Full Space / Immersive Experiences

### 4.1 AR Repair Guidance (Mixed Reality)

**Spatial Layout:**

```
Physical Equipment (Center of attention)
        │
        │  AR Overlays anchored to equipment:
        │
        ├─ Step Indicator (Above equipment)
        │  "Step 2 of 5: Remove access panel"
        │
        ├─ Component Highlight (On equipment)
        │  Glowing outline on target component
        │
        ├─ Directional Arrows (Pointing to target)
        │  Animated arrows guiding to next action
        │
        ├─ Tool Callout (Near work area)
        │  "Use 10mm socket wrench"
        │
        └─ Safety Warning (If hazard detected)
           Red zone highlighting danger area

Floating UI (User-relative)
        │
        ├─ Progress Bar (Top periphery)
        │  [████████░░░░] 60% Complete
        │
        ├─ Timer (Top right)
        │  ⏱ 23:45 elapsed
        │
        ├─ Action Button (Bottom center)
        │  [✓ Complete Step] [☎️ Call Expert]
        │
        └─ Expert Feed (Right side, if active)
           [Live video with spatial audio]
```

**Visual Design:**

- **Highlight Colors:**
  - Primary target: Cyan (#00FFFF) with glow
  - Secondary targets: Yellow (#FFD700)
  - Danger zones: Red (#FF3B30) with pulsing
  - Completed areas: Green (#34C759) with checkmark

- **Overlay Opacity:**
  - Active step: 90% opacity
  - Future steps: 20% opacity (preview)
  - Completed steps: Fade out

- **Animation:**
  - Step transition: 0.5s cross-fade
  - Highlight pulse: 2s loop
  - Arrow animation: Flowing particles toward target

### 4.2 Remote Collaboration Space

```
Technician's View:
┌────────────────────────────────────────┐
│                                        │
│  [Physical equipment with AR overlays] │
│                                        │
│  Expert's annotations appear in 3D:    │
│  • Drawn arrows pointing to parts     │
│  • Floating text notes                │
│  • Measurement lines                  │
│                                        │
└────────────────────────────────────────┘

Floating Expert Window (Right side):
┌──────────────────┐
│   Expert: Lisa   │
│  ┌────────────┐  │
│  │ [Video]    │  │
│  │  Face of   │  │
│  │  Expert    │  │
│  └────────────┘  │
│                  │
│  🎤 Spatial Audio│
│  Volume: ▮▮▮▮▯▯  │
│                  │
│ [End Call]       │
└──────────────────┘

Annotation Tools (Bottom):
[✏️ Draw] [📝 Note] [📏 Measure] [📸 Capture]
```

**Collaboration Features:**

1. **Spatial Annotations:**
   - Expert draws in 3D space
   - Annotations anchored to equipment
   - Color-coded by author (Expert: Blue, Tech: Green)
   - Fade after 30 seconds unless pinned

2. **Shared Cursor:**
   - Expert's pointing location shown as beam
   - Laser-pointer effect with dot at intersection
   - Real-time sync (<100ms latency)

3. **Voice Communication:**
   - Spatial audio positioned near expert video
   - Automatic noise cancellation
   - Echo suppression
   - Voice activity detection (visual indicator)

4. **Video Feed:**
   - Size: 300pt × 400pt window
   - Position: Right side, user-relative
   - Quality: Adaptive (720p - 360p based on bandwidth)
   - Can minimize to small avatar

## 5. 3D Visualization Specifications

### 5.1 Equipment Models

**Level of Detail (LOD) System:**

| Distance | Polygon Count | Texture Resolution | Use Case |
|----------|---------------|-------------------|----------|
| 0-0.5m   | 50,000        | 4096×4096        | Close inspection |
| 0.5-2m   | 10,000        | 2048×2048        | Normal work |
| 2m+      | 1,000         | 1024×1024        | Overview |

**Material Properties:**
```swift
// Example: Metal component
PhysicallyBasedMaterial {
    baseColor: UIColor(white: 0.8)
    metallic: 0.9
    roughness: 0.3
    normal: normalMap (detail texture)
    ambientOcclusion: aoMap
}

// Example: Worn rubber seal
PhysicallyBasedMaterial {
    baseColor: UIColor.black
    metallic: 0.0
    roughness: 0.9
    subsurfaceScattering: enabled
    opacity: 0.95
}
```

### 5.2 AR Overlay Elements

**Component Highlights:**
```swift
// Glowing outline shader
OutlineMaterial {
    color: .cyan
    width: 2pt // Screen-space thickness
    glow: 0.5 // Bloom intensity
    animation: pulse(period: 2.0s)
}
```

**Directional Arrows:**
```swift
ArrowEntity {
    style: .curved // Bezier path to target
    color: .systemBlue
    animation: .flowingDash
    headSize: 0.05m
    lineWidth: 0.01m
}
```

**Measurement Lines:**
```swift
MeasurementLine {
    startPoint: SIMD3<Float>
    endPoint: SIMD3<Float>
    color: .yellow
    label: "24.5 cm"
    labelBackground: .glassMaterial
    precision: .millimeter
}
```

### 5.3 Lighting & Shadows

```swift
// Environment lighting
ImageBasedLighting {
    environment: .warehouse // Match typical job sites
    intensity: 1.0
    shadows: .enabled
}

// Additional lights for clarity
DirectionalLight {
    direction: SIMD3<Float>(0, -1, 0.3)
    intensity: 500 // Lux
    castsShadow: true
    shadowQuality: .medium
}
```

## 6. Interaction Patterns

### 6.1 Gaze + Pinch Gestures

**Button Interaction:**
```
1. Look at button → Highlight appears (0.1s fade-in)
2. Pinch gesture → Visual press feedback
3. Release → Action executes + haptic
```

**Visual Feedback:**
- Idle: 0% highlight
- Gaze: 20% highlight + subtle scale (1.0 → 1.05)
- Pinch down: 40% highlight + scale (1.05 → 0.95)
- Pinch release: Spring animation back to 1.0

**Timing:**
- Gaze dwell before highlight: 100ms
- Highlight fade-in: 150ms
- Press animation: 100ms
- Release animation: 200ms with spring (damping: 0.7)

### 6.2 Hand Tracking Gestures

#### Point & Identify
```
User extends index finger → Raycast from fingertip
    │
    ├─ Hit component → Highlight + show info
    │
    ├─ No hit → Show distance to nearest component
    │
    └─ Hold for 1.5s → Pin information panel
```

**Visual:**
- Ray: Subtle cyan line from fingertip
- Hit point: Glowing sphere
- Info panel: Follows hit point with smooth lag

#### Pinch & Grab
```
Pinch detected on interactive object
    │
    ├─ Small object → Attach to hand, follow 1:1
    │
    ├─ Large object → Rotate/scale in place
    │
    └─ Release → Return with physics simulation
```

#### Measure (Two Hands)
```
Extend both index fingers
    │
    ├─ Calculate distance between fingertips
    │
    ├─ Draw measurement line in real-time
    │
    └─ Pinch either hand → Save measurement
```

### 6.3 Voice Commands

**Wake Word:** "Hey Assistant" (optional)

**Command Grammar:**
```
Primary Commands:
- "Next step" → Advance procedure
- "Previous step" → Go back
- "Repeat instructions" → Audio playback
- "Call expert" → Initiate collaboration
- "Take photo" → Capture evidence
- "Complete step" → Mark current step done

Navigation:
- "Go to step [number]" → Jump to specific step
- "Show overview" → Display full procedure
- "Show parts" → Open parts list

Information:
- "What's this?" (while pointing) → Identify component
- "How much time remaining?" → Show estimate
- "What tools do I need?" → List required tools

Collaboration:
- "Share my view" → Enable video feed
- "Mute" / "Unmute" → Audio control
- "End call" → Terminate session
```

**Voice Feedback:**
- Confirmation tone for recognized commands
- Spoken acknowledgment ("Moving to next step")
- Error tone + message if not understood

## 7. Visual Design System

### 7.1 Color Palette

**Primary Colors:**
```
Brand Blue:     #007AFF (interactive elements)
Success Green:  #34C759 (completed items)
Warning Yellow: #FFD700 (cautions)
Error Red:      #FF3B30 (errors, dangers)
```

**Semantic Colors:**
```
Equipment Colors:
- HVAC:        #00C7BE (Cyan)
- Electrical:  #FFD700 (Yellow)
- Plumbing:    #5E5CE6 (Indigo)
- Mechanical:  #FF9500 (Orange)

Status Colors:
- Scheduled:   #8E8E93 (Gray)
- In Progress: #007AFF (Blue)
- Completed:   #34C759 (Green)
- Overdue:     #FF3B30 (Red)
- On Hold:     #FFD700 (Yellow)

Safety Colors:
- Safe:        #34C759 (Green)
- Caution:     #FF9500 (Orange)
- Danger:      #FF3B30 (Red)
- Info:        #007AFF (Blue)
```

**Glass Materials:**
```swift
// Backgrounds
.ultraThinMaterial  // Primary windows
.thinMaterial       // Overlays, tooltips
.regularMaterial    // Modals, panels
.thickMaterial      // High emphasis areas

// Vibrancy levels
.primary            // Headers, important text
.secondary          // Body text
.tertiary           // Subtle text, placeholders
```

### 7.2 Typography

**Type Scale (SF Pro):**
```
Large Title:  34pt / 41pt line / Bold
Title 1:      28pt / 34pt line / Bold
Title 2:      22pt / 28pt line / Bold
Title 3:      20pt / 25pt line / Semibold
Headline:     17pt / 22pt line / Semibold
Body:         17pt / 22pt line / Regular
Callout:      16pt / 21pt line / Regular
Subheadline:  15pt / 20pt line / Regular
Footnote:     13pt / 18pt line / Regular
Caption 1:    12pt / 16pt line / Regular
Caption 2:    11pt / 13pt line / Regular
```

**Spatial Text Rendering:**
```swift
// 3D text in AR space
Text3D("Component Name") {
    font: .system(size: 24, weight: .bold, design: .rounded)
    depth: 0.01 // Slight extrusion
    material: .unlit // Always readable
    billboard: .yAxis // Rotate to face user
    minScale: 0.5 // Don't get too small when far
    maxScale: 2.0 // Don't get too large when close
}
```

**Dynamic Type Support:**
- All UI text scales with user preference
- Maximum size: xxxLarge for accessibility
- Spatial text: Scale with distance for consistent legibility
- Minimum size: 18pt for AR overlays at 0.5m

### 7.3 Iconography

**Icon Style:**
- SF Symbols for standard icons
- Custom symbols for equipment-specific items
- Line weight: Medium (2.5pt at 100pt size)
- Corner radius: Rounded
- Alignment: Center-aligned in circles/squares

**Icon Sizes:**
```
Small:   20pt (list items, inline)
Medium:  28pt (buttons, tabs)
Large:   40pt (featured actions)
Hero:    60pt (empty states, onboarding)
```

**Equipment Category Icons:**
```
🔧 HVAC:       Snowflake in circle
⚡ Electrical:  Lightning bolt
💧 Plumbing:    Water drop
⚙️ Mechanical:  Gear
🔥 Fire Safety: Flame
🏗️ Structural:  Building
```

**Action Icons:**
```
▶️  Start/Play
⏸  Pause
✓  Complete
✕  Cancel
📸 Capture
📹 Record
☎️  Call
💬 Chat
📍 Location
🔍 Search
⚙️  Settings
ℹ️  Info
```

### 7.4 Spacing & Layout

**Spatial Grid:**
```
Base unit: 8pt

Micro:   4pt  (tight spacing)
Small:   8pt  (default spacing)
Medium:  16pt (section spacing)
Large:   24pt (major sections)
XLarge:  32pt (page margins)
XXLarge: 48pt (dramatic separation)
```

**Safe Areas:**
- Window edges: 24pt padding
- Volume bounds: 10cm from edges
- AR overlays: 5cm minimum from screen edges
- Touch targets: 60pt × 60pt minimum

## 8. User Flows & Navigation

### 8.1 Primary User Flow

```
┌─────────────┐
│  Dashboard  │ (Window)
└──────┬──────┘
       │ Tap "View Details"
       ▼
┌─────────────┐
│ Job Details │ (Window)
└──────┬──────┘
       │ Tap "View 3D Model"
       ▼
┌─────────────┐
│ 3D Preview  │ (Volume)
│ Inspect     │
│ Equipment   │
└──────┬──────┘
       │ Tap "Start AR Mode"
       ▼
┌─────────────┐
│ AR Repair   │ (Immersive)
│ Guidance    │
└──────┬──────┘
       │ Complete all steps
       ▼
┌─────────────┐
│ Completion  │ (Window)
│ Summary     │
└─────────────┘
```

### 8.2 Expert Call Flow

```
AR Repair Mode
    │
    │ Tap "Call Expert"
    ▼
┌─────────────────┐
│ Expert List     │ (Sheet overlay)
│ - Lisa (HVAC)   │
│ - Mike (Elec)   │
│ - Sarah (All)   │
└────────┬────────┘
         │ Select expert
         ▼
┌─────────────────┐
│ Connecting...   │ (Loading)
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Collaborative   │ (AR + Video)
│ Session         │
│                 │
│ [Equipment]     │  ┌─────────┐
│ with overlays   │  │ Expert  │
│ and annotations │  │ Video   │
│                 │  └─────────┘
└────────┬────────┘
         │ Issue resolved
         ▼
┌─────────────────┐
│ Session Summary │ (Window)
│ - Duration      │
│ - Actions taken │
│ - Annotations   │
└─────────────────┘
```

### 8.3 Navigation Patterns

**Window Management:**
- Windows can be repositioned by user
- App remembers window positions per space
- Close button (⊗) always top-right
- Back navigation (←) top-left when applicable

**Depth Navigation:**
```
Summary → Detail → Action
(Window)  (Window/Volume)  (Immersive)

User can always:
- Back button to previous level
- Home button to dashboard
- Close current window
```

**Breadcrumbs (in complex flows):**
```
Dashboard > Jobs > HVAC-2471 > AR Repair > Step 3
   [↩]      [↩]      [↩]         [↩]        Current
```

## 9. Accessibility Design

### 9.1 VoiceOver Spatial Navigation

**Spatial Element Ordering:**
```
Window elements: Top-to-bottom, left-to-right (standard)

AR elements: Distance-based (nearest first)
1. Elements within 0.5m (close work)
2. Elements 0.5m - 1.5m (primary zone)
3. Elements 1.5m+ (peripheral)

Within each zone: Clockwise from top
```

**Audio Descriptions:**
```swift
// Equipment component
.accessibilityLabel("Compressor bearing, serial B-4421")
.accessibilityHint("Double-tap to view details")
.accessibilityValue("Condition: Worn, replacement recommended")

// AR overlay
.accessibilityLabel("Step 2 indicator")
.accessibilityValue("Remove access panel using 10mm socket")
.accessibilityHint("This overlay is positioned above the equipment")
```

### 9.2 High Contrast Mode

```swift
// Automatically adapt to environment settings
@Environment(\.colorSchemeContrast) var contrast

if contrast == .increased {
    // Use higher contrast colors
    highlightColor = .cyan  // More vivid
    strokeWidth = 3pt       // Thicker
    separatorColor = .white // More visible
}
```

**Contrast Ratios:**
- Text on glass: Minimum 7:1 (WCAG AAA)
- AR overlays on any background: Minimum 4.5:1 with outline
- Interactive elements: 3:1 for large elements

### 9.3 Reduce Motion

```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

if reduceMotion {
    // Disable:
    - Particle effects
    - Pulsing animations
    - Flowing dash lines
    - Rotation animations

    // Keep:
    - Fades (instant or 0.2s max)
    - Necessary state changes
    - Functional transitions
}
```

### 9.4 Alternative Inputs

**Voice-Only Navigation:**
```
"Show my jobs" → Dashboard
"Open job 2471" → Job details
"Start repair" → AR mode
"What's step 1?" → Read first instruction
"Complete step" → Mark done
"Go back" → Previous screen
```

**Dwell-Time Activation:**
- Look at button for 2 seconds
- Progress ring shows countdown
- Activates without hand gesture
- Adjustable timing in settings

**Switch Control:**
- Support for external switch devices
- Scan through elements
- Activate with single switch
- Configurable scanning speed

## 10. Error States & Loading Indicators

### 10.1 Loading States

**Initial App Load:**
```
┌────────────────────────────┐
│                            │
│      [App Icon]            │
│                            │
│   Field Service AR         │
│                            │
│   Loading...               │
│   ▮▮▮▮▯▯▯▯ 50%            │
│                            │
└────────────────────────────┘
```

**Equipment Recognition:**
```
AR View with overlay:

┌────────────────────────────┐
│                            │
│  [Live camera feed]        │
│                            │
│    🔍 Scanning...          │
│                            │
│    ⊙ Scanning indicator   │
│    (rotating circles)      │
│                            │
│  Point device at           │
│  equipment to identify     │
│                            │
└────────────────────────────┘
```

**Data Sync:**
```
┌────────────────────────────┐
│  Syncing Data...           │
│                            │
│  Jobs:      ✓ Complete     │
│  Equipment: ▮▮▯▯ 50%       │
│  Parts:     ⏳ Pending     │
│                            │
│  [Cancel]                  │
└────────────────────────────┘
```

**Loading Indicators:**
- Spinner: System `ProgressView()` for indeterminate
- Progress bar: Linear for determinate progress
- Skeleton screens: For list loading
- Shimmer effect: Optional for premium feel

### 10.2 Error States

**Network Error:**
```
┌────────────────────────────┐
│      ⚠️                    │
│                            │
│  Connection Lost           │
│                            │
│  Couldn't sync jobs.       │
│  You can continue working  │
│  offline.                  │
│                            │
│  [Try Again] [Work Offline]│
└────────────────────────────┘
```

**Recognition Failure:**
```
AR View:

┌────────────────────────────┐
│  [Live camera feed]        │
│                            │
│    ❌ Not Recognized       │
│                            │
│  This equipment isn't in   │
│  the database.             │
│                            │
│  [Try Again]               │
│  [Enter Manually]          │
│  [Call Expert]             │
└────────────────────────────┘
```

**Permission Denied:**
```
┌────────────────────────────┐
│      🔒                    │
│                            │
│  Camera Access Required    │
│                            │
│  AR features need camera   │
│  access to scan equipment. │
│                            │
│  [Open Settings]           │
└────────────────────────────┘
```

### 10.3 Empty States

**No Jobs:**
```
┌────────────────────────────┐
│                            │
│      ✓                     │
│                            │
│   All Caught Up!           │
│                            │
│   No jobs scheduled today. │
│                            │
│   [Browse Equipment]       │
│   [View Past Jobs]         │
│                            │
└────────────────────────────┘
```

**No Search Results:**
```
┌────────────────────────────┐
│  🔍 "Turbine"              │
├────────────────────────────┤
│                            │
│      🔍                    │
│                            │
│  No Results Found          │
│                            │
│  Try a different search    │
│  term or browse categories.│
│                            │
│  [Clear Search]            │
│                            │
└────────────────────────────┘
```

## 11. Animation & Transition Specifications

### 11.1 Window Transitions

**Open Window:**
```swift
.transition(.asymmetric(
    insertion: .scale(scale: 0.9).combined(with: .opacity),
    removal: .opacity
))
.animation(.spring(response: 0.4, dampingFraction: 0.8), value: isPresented)
```

**Close Window:**
```swift
.transition(.opacity)
.animation(.easeOut(duration: 0.2), value: isPresented)
```

**Navigation Push:**
```swift
.transition(.move(edge: .trailing))
.animation(.easeInOut(duration: 0.3), value: navigationPath)
```

### 11.2 AR Overlay Animations

**Step Transition:**
```swift
// Fade out old step
oldStepEntity.opacity = 0.0
oldStepEntity.scale = 0.8

// Fade in new step
newStepEntity.opacity = 0.0 → 1.0
newStepEntity.scale = 0.8 → 1.0

Animation: EaseInOut, 0.5s
```

**Highlight Pulse:**
```swift
// Glowing outline
opacity: 0.5 → 1.0 → 0.5
scale: 1.0 → 1.05 → 1.0

Animation: Loop, 2.0s, easeInOut
```

**Arrow Flow:**
```swift
// Dashed line with moving particles
particles: Spawn at tail, flow to head
speed: 0.3 m/s
lifetime: 2.0s
color: gradient (blue → cyan)

Animation: Continuous
```

### 11.3 UI Micro-interactions

**Button Press:**
```
Hover:   Scale 1.0 → 1.05 (0.1s spring)
Press:   Scale 1.05 → 0.95 (0.1s easeIn)
Release: Scale 0.95 → 1.0 (0.2s spring, damping 0.7)
         + Haptic feedback
```

**Checkmark Completion:**
```
Step 1: Draw circle (0.3s)
Step 2: Draw checkmark (0.2s)
Step 3: Scale pulse 1.0 → 1.2 → 1.0 (0.4s)
Total: 0.9s

Animation: Spring with overshoot
```

**Progress Bar:**
```
Fill: Animate from current to new value
Duration: 0.5s
Easing: EaseInOut
If >50% jump: Show shimmer effect
```

### 11.4 Spatial Transitions

**Window → Volume:**
```
1. Window scales down to 0.9
2. Window fades to 0.0
3. Volume appears at 0.0 scale
4. Volume scales to 1.0 with spring

Duration: 0.6s total
Overlap: Transitions start 0.2s apart
```

**Volume → Immersive:**
```
1. Volume content scales up (1.0 → 1.5)
2. Volume bounds fade out
3. AR environment fades in
4. AR overlays appear at equipment location

Duration: 0.8s total
Effect: Seamless "stepping into" the volume
```

**Immersive → Window:**
```
1. AR overlays fade out (0.3s)
2. Passthrough darkens slightly
3. Window appears centered (0.4s)
4. Immersive space closes

Duration: 1.0s total
User always lands back in safe, familiar window
```

---

## Summary

This design specification provides:

1. **Spatial-First UI**: Progressive disclosure from windows to volumes to immersive
2. **Ergonomic Design**: Comfortable viewing angles and interaction zones
3. **Visual Hierarchy**: Clear depth, color, and typography system
4. **Rich Interactions**: Gaze, hand tracking, voice, and gestures
5. **Accessibility**: VoiceOver, high contrast, reduce motion, alternative inputs
6. **Enterprise Polish**: Professional aesthetics suitable for field work
7. **Error Resilience**: Comprehensive error and empty states
8. **Smooth Animations**: Purposeful transitions that guide users

The design balances Apple's spatial computing best practices with the practical needs of field service technicians working in challenging environments.
