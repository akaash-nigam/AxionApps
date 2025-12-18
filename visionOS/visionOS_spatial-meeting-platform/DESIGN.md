# Spatial Meeting Platform - Design Specification

## Table of Contents
1. [Spatial Design Principles](#spatial-design-principles)
2. [Window Layouts & Configurations](#window-layouts--configurations)
3. [Volume Designs](#volume-designs)
4. [Full Space / Immersive Experiences](#full-space--immersive-experiences)
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

**"Make Distance Feel Natural, Make Presence Feel Real"**

Our spatial design transforms remote collaboration into an experience that feels as natural as being in the same room. We achieve this through:

1. **Ergonomic Spatial Placement**
2. **Natural Depth Hierarchy**
3. **Comfortable Visual Distances**
4. **Intuitive Spatial Relationships**
5. **Respectful Personal Space**

### Spatial Zones

```
User-Centric Spatial Layout
│
├── Personal Zone (0-0.6m)
│   ├── Immediate controls (microphone, camera)
│   ├── Private notifications
│   └── Personal notes
│
├── Interaction Zone (0.6-2.5m)
│   ├── Meeting controls window
│   ├── Shared whiteboards
│   ├── Participant interactions
│   └── Collaborative objects
│
├── Presentation Zone (2.5-5m)
│   ├── Shared content displays
│   ├── Presentations
│   ├── Data visualizations
│   └── Group viewing area
│
└── Environmental Zone (5m+)
    ├── Background environment
    ├── Ambient participants (>12)
    ├── Decorative elements
    └── Atmospheric effects
```

### Ergonomic Guidelines

```yaml
Vertical Positioning:
  Eye Level: 0m (reference point)
  Primary Content: -10° to -15° below eye level (0 to -0.3m)
  Secondary Content: -15° to -30° below eye level (-0.3m to -0.6m)
  Controls: -5° to -20° below eye level (-0.1m to -0.4m)
  Ceiling Elements: +15° to +30° above eye level (+0.3m to +0.6m)

Horizontal Positioning:
  Center: 0° (directly ahead)
  Primary Content: ±30° (±0.6m at 2m distance)
  Secondary Content: ±45° (±1.0m at 2m distance)
  Peripheral: ±60° (±1.5m at 2m distance)

Depth Positioning:
  Near Field: 0.6-1.0m (arm's reach, interactive)
  Mid Field: 1.0-2.5m (comfortable viewing)
  Far Field: 2.5-5.0m (ambient/passive content)
  Background: 5.0m+ (environmental)

Comfortable Viewing Distances:
  Text Reading: 0.8-1.2m
  Video/Images: 1.5-2.5m
  3D Models: 1.0-3.0m
  Presentations: 2.0-4.0m
  Environments: 5.0m+
```

### Apple visionOS HIG Compliance

```yaml
Spatial Ergonomics:
  ✓ Content positioned 10-15° below eye level
  ✓ Interactive elements minimum 60pt hit target
  ✓ Comfortable viewing distance (1-3m)
  ✓ Respect user's physical space
  ✓ Avoid content behind user

Glass Materials:
  ✓ Use vibrancy for depth
  ✓ Appropriate thickness for hierarchy
  ✓ Consistent material usage
  ✓ Blend with environment

Lighting:
  ✓ Follow system lighting
  ✓ Support light/dark modes
  ✓ Dynamic shadows for depth
  ✓ Consistent light sources

Safety:
  ✓ No flashing content (seizure risk)
  ✓ Smooth motion only
  ✓ Adequate contrast ratios
  ✓ Clear focus indicators
```

---

## Window Layouts & Configurations

### Dashboard Window

**Purpose**: Main hub for meeting management and navigation

```
┌────────────────────────────────────────────────────┐
│  Spatial Meeting Platform        👤 John Doe   ⚙  │
├────────────────────────────────────────────────────┤
│                                                     │
│  📅 Today's Meetings                                │
│  ┌──────────────────────────────────────────────┐  │
│  │ ▶ 2:00 PM  Product Review                    │  │
│  │   👥 12 participants  📍 Innovation Lab       │  │
│  │   [Join Now]                          1h 15m │  │
│  ├──────────────────────────────────────────────┤  │
│  │ ⏰ 4:30 PM  Design Critique                  │  │
│  │   👥 6 participants  📍 Boardroom            │  │
│  │   Starts in 2h 30m                            │  │
│  └──────────────────────────────────────────────┘  │
│                                                     │
│  ⭐ Quick Actions                                   │
│  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐     │
│  │   📞   │ │   📅   │ │   📊   │ │   ⚙️   │     │
│  │ Instant│ │Schedule│ │Analytics│ │Settings│     │
│  │ Meeting│ │ Meeting│ │         │ │        │     │
│  └────────┘ └────────┘ └────────┘ └────────┘     │
│                                                     │
│  📜 Recent Meetings                                 │
│  • Product Planning - 2h ago                        │
│  • Team Standup - Yesterday                         │
│  • Client Presentation - 2 days ago                 │
│                                                     │
└────────────────────────────────────────────────────┘
```

**Specifications**:
- Size: 900×700 points (1.2m wide at 2m distance)
- Position: Center, 1.8m from user, -0.2m below eye level
- Material: Glass with vibrancy
- Depth: Standard 2D window with subtle drop shadow
- Background blur: 40% passthrough visibility

### Meeting Controls Window

**Purpose**: Quick access to meeting controls during active session

```
┌─────────────────────────────────────────┐
│  Meeting Controls                       │
├─────────────────────────────────────────┤
│                                          │
│  🎤 Audio                   🔊 ███████░  │
│     [Mute] ✓ Spatial Audio              │
│                                          │
│  📹 Video                                │
│     [Start Video]                        │
│                                          │
│  👥 Participants (12)                    │
│     Jane Smith     🎤 Speaking           │
│     Mike Johnson   🎤                    │
│     Sarah Lee      🎤                    │
│     [View All...]                        │
│                                          │
│  📄 Share                                │
│     [Screen] [Document] [Whiteboard]    │
│                                          │
│  ⚡ Actions                              │
│     [Record] [Transcript] [Leave]       │
│                                          │
└─────────────────────────────────────────┘
```

**Specifications**:
- Size: 400×500 points
- Position: Left side, 1.5m from user, -0.3m below eye level
- Material: Glass with high vibrancy (80%)
- Pinning: Always visible, follows user gaze at edges
- Ornament: Floating bottom toolbar

**Bottom Ornament** (Quick Actions):
```
┌────────────────────────────────────────┐
│   🎤     📹     🖐     👍     ❌       │
│  Mute  Video  Raise  Like  Leave       │
└────────────────────────────────────────┘
```

### Content Window

**Purpose**: Display shared documents, presentations, and screens

```
┌─────────────────────────────────────────────────┐
│  Shared: Q4_Roadmap.pdf               👁 8  ⚙  │
├─────────────────────────────────────────────────┤
│                                                  │
│                                                  │
│              [DOCUMENT CONTENT]                  │
│                                                  │
│         Product Roadmap Q4 2024                  │
│                                                  │
│         • Feature A - Launch Nov 1              │
│         • Feature B - Launch Nov 15             │
│         • Feature C - Launch Dec 1              │
│                                                  │
│                                                  │
├─────────────────────────────────────────────────┤
│  < Prev    Page 1 of 12    Next >     🖊 ✏️ 💬  │
└─────────────────────────────────────────────────┘
```

**Specifications**:
- Size: 1200×900 points (resizable)
- Position: Center-right, 2.5m from user, -0.15m below eye level
- Material: Opaque white with subtle glass edges
- Depth: Slight 3D depth (0.02m) for layered content
- Annotations: Support collaborative markup

### Participant Grid Window (Large Meetings)

**Purpose**: Overview of all participants in large meetings

```
┌──────────────────────────────────────────────┐
│  Participants (47)            [Grid] [List]  │
├──────────────────────────────────────────────┤
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐ │
│  │ JD │ │ SM │ │ MJ │ │ SL │ │ RT │ │ KP │ │
│  │ 🎤 │ │ 🎤 │ │ .. │ │ 🎤 │ │ .. │ │ .. │ │
│  └────┘ └────┘ └────┘ └────┘ └────┘ └────┘ │
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐ │
│  │ AL │ │ BG │ │ CH │ │ DI │ │ EJ │ │ FK │ │
│  │ .. │ │ 🎤 │ │ .. │ │ .. │ │ 🎤 │ │ .. │ │
│  └────┘ └────┘ └────┘ └────┘ └────┘ └────┘ │
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐ │
│  │ GL │ │ HM │ │ IN │ │ JO │ │ KP │ │ LQ │ │
│  │ .. │ │ .. │ │ 🎤 │ │ .. │ │ .. │ │ 🎤 │ │
│  └────┘ └────┘ └────┘ └────┘ └────┘ └────┘ │
│                                              │
│  🎤 Speaking: Jane Smith, Sarah Lee          │
└──────────────────────────────────────────────┘
```

---

## Volume Designs

### 3D Meeting Space Volume

**Purpose**: Immersive 3D meeting room with spatial participant avatars

```
3D Spatial Layout (Top View)
                    ↑ Forward
                    │
        ┌───────────┼───────────┐
        │           │           │
        │    👤     │     👤    │  Participants arranged
        │   Mike    │    Jane   │  in semicircle facing
        │           │           │  shared content
    ────┤     👤    USER   👤  ├────
        │    Sarah        Tom   │
        │           │           │
        │     👤    │     👤    │
        │    Lisa   │   Robert  │
        │           │           │
        └───────────┼───────────┘
                    │
                  [Doc]  ← Shared content
                  📄      in center
```

**Specifications**:
- Dimensions: 2.5m × 2.5m × 2.5m
- Bounds: Subtle grid visible at edges
- Participant positioning:
  - Seated height: 1.2m from floor
  - Distance from center: 1.5m radius
  - Angular spacing: Evenly distributed
  - Eye contact: Facing toward center
- Lighting: Soft directional from above, ambient fill
- Materials: Glass floor grid, transparent bounds

### 3D Participant Avatar Design

```
Avatar Composition (3D)
        ┌─────────────┐
        │   Nameplate │  ← Floating above (0.3m)
        │  Jane Smith │     Size: 12pt, readable at 3m
        └─────────────┘
              ││
         ╭────╮╭────╮     ← Head/Shoulders representation
        ││👤  │╰────╯     - Spherical avatar or
         ╰────╯            - Video texture on sphere
                           - 0.4m diameter
         ┌──────┐
         │ 🟢 🎤│          ← Status indicators
         └──────┘          - Speaking (animated ring)
                           - Muted/unmuted
              ↓
         [Spatial           ← Spatial audio source
          Audio]             positioned at avatar
```

**Avatar Specifications**:
- **Visual**:
  - Sphere: 0.4m diameter
  - Material: Video texture (if camera on) or solid color
  - Glow effect when speaking (pulsing blue)
  - Fade to 50% opacity when not active
- **Nameplate**:
  - Position: 0.3m above avatar
  - Always faces user (billboard)
  - Font: SF Pro Rounded, 12pt
  - Background: Glass with 90% vibrancy
- **Status Indicators**:
  - Speaking: Animated blue ring (60pt, 2s pulse)
  - Muted: Red slash over microphone icon
  - Hand raised: ✋ above nameplate
  - Away: Yellow glow, 30% opacity

### Whiteboard Volume

**Purpose**: Infinite collaborative whiteboard in 3D space

```
Whiteboard Layout (Front View)

┌────────────────────────────────────────┐
│                                         │  ← Infinite canvas
│    ✏️ User 1 drawing                   │    1.5m × 1.0m visible
│                                         │    Scrollable/pannable
│         🔴 ───→ ⭐                      │
│        /                                │
│       /   ✏️ User 2 annotation         │
│      /                                  │
│     ✅ Feature Launch                   │
│                                         │
│         📝 Notes:                       │
│         • Point 1                       │
│         • Point 2 ✏️ User 3            │
│                                         │
└────────────────────────────────────────┘

[Color] [Brush] [Eraser] [Shapes] [Text]  ← Floating toolbar
```

**Specifications**:
- Visible area: 1.5m × 1.0m
- Canvas size: Infinite (dynamically loaded)
- Position: 2m from user, centered
- Depth: 0.05m (thin volume)
- Interaction:
  - Direct hand drawing (finger = pen)
  - Pinch = grab and move canvas
  - Two-hand pinch = zoom
- Collaboration:
  - Real-time sync (<100ms)
  - Multi-user cursors with colors
  - Undo/redo per user
- Tools: Pen, eraser, shapes, text, sticky notes

### Data Visualization Volume

**Purpose**: Interactive 3D data visualizations

```
3D Bar Chart Example

         Revenue by Quarter (3D)
              ↑ $M
           60 │     ███
              │     ███
           40 │ ███ ███ ███
              │ ███ ███ ███
           20 │ ███ ███ ███ ███
              │ ███ ███ ███ ███
            0 └─────────────────→
               Q1  Q2  Q3  Q4

[Rotate] [Filter] [Drill Down] [Export]
```

**Specifications**:
- Dimensions: 1.5m × 1.5m × 1.0m
- Interactive:
  - Pinch to select data point → show details
  - Rotate to view from different angles
  - Filter data with voice/gestures
- Visual encoding:
  - Height = value
  - Color = category
  - Glow = highlighted/selected
- Animation: Smooth transitions between data states

---

## Full Space / Immersive Experiences

### Boardroom Environment (Mixed Reality)

**Description**: Professional boardroom blending virtual and real space

```
Boardroom Layout (Top View)

              [Presentation Wall]
                    ███████
                       │
        👤 ─────── 👤  │  👤 ─────── 👤
      Seat 1    Seat 2 │ Seat 3    Seat 4
                       │
    ╔══════════════════╧══════════════════╗
    ║                                     ║
    ║         Virtual Table               ║  ← Glass table
    ║              (Glass)                ║    3m × 1.5m
    ║                                     ║
    ╚══════════════════╤══════════════════╝
                       │
        👤 ─────── 👤 USER 👤 ─────── 👤
      Seat 5    Seat 6 │ Seat 7    Seat 8
                       │
              [You are here]
```

**Environment Specifications**:
- **Immersion**: Mixed Reality (60% virtual, 40% passthrough)
- **Room Size**: 6m × 4m × 3m high
- **Virtual Elements**:
  - Glass conference table (3m × 1.5m)
  - Presentation wall (4m wide)
  - Ceiling lights (soft, directional)
  - Floor: Subtle grid on real floor
- **Passthrough**:
  - Real physical space visible
  - Blend virtual and real furniture
  - Maintain spatial awareness
- **Lighting**:
  - Warm white (3000K)
  - Soft shadows for depth
  - Adaptive to real room lighting

### Innovation Lab (Progressive Immersion)

**Description**: Open creative space for brainstorming

```
Innovation Lab (Perspective View)

         Ceiling ━━━━━━━━━━━━━━━━━━━
        ╱                           ╱│
       ╱    💡    💡    💡         ╱ │  ← Idea bubbles floating
      ╱                           ╱  │
     ╱    👤    👤    👤         ╱   │  ← Standing participants
    ╱                           ╱    │
   ╱    📋    📋    📋         ╱     │  ← Floating boards
  ╱                           ╱      │
 ╱         ∞ Whiteboard      ╱       │  ← Infinite canvas
━━━━━━━━━━━━━━━━━━━━━━━━━━━        │
                                     │
        Floor (subtle grid)          │
```

**Environment Specifications**:
- **Immersion**: Progressive (20-80% adjustable)
- **Space**: Open, infinite feeling
- **Elements**:
  - Infinite whiteboard walls
  - Floating sticky notes
  - Participant standing positions
  - Idea bubbles (voice-to-text)
  - Ambient background (warehouse/loft)
- **Colors**: Vibrant, creative (oranges, purples)
- **Lighting**: Bright, energetic

### Auditorium (Full Immersion)

**Description**: Large presentation theater

```
Auditorium (Front View)

                  🎤 Presenter
                     👤
        ┌────────────────────────────┐
        │     PRESENTATION WALL      │  ← 8m wide screen
        │                            │
        │      [Slides/Content]      │
        │                            │
        └────────────────────────────┘

    ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐
    │ 👤│ │ 👤│ │ 👤│ │ 👤│ │ 👤│   Row 1
    └───┘ └───┘ └───┘ └───┘ └───┘

   ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐
   │ 👤│ │ 👤│ │YOU│ │ 👤│ │ 👤│    Row 2
   └───┘ └───┘ └───┘ └───┘ └───┘

  ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐
  │ 👤│ │ 👤│ │ 👤│ │ 👤│ │ 👤│     Row 3
  └───┘ └───┘ └───┘ └───┘ └───┘
```

**Environment Specifications**:
- **Immersion**: Full (100% virtual)
- **Capacity**: 100+ participants
- **Stage**: Elevated 0.5m
- **Seating**: Tiered rows, 2m spacing
- **Screen**: 8m × 4.5m presentation wall
- **Audio**: Theater acoustics simulation
- **Lighting**: Dimmed audience, spotlight on presenter

---

## 3D Visualization Specifications

### Participant Representation

#### Avatar Quality Levels

**High Detail (0-3m distance)**:
- Geometry: 5,000 polygons
- Texture: 2K resolution video texture
- Facial features: Visible
- Animation: Subtle breathing, head movements
- Speaking: Lip sync (if available)

**Medium Detail (3-7m distance)**:
- Geometry: 1,000 polygons
- Texture: 1K resolution
- Simplified features
- Animation: Speaking indicator only

**Low Detail (7m+ distance)**:
- Geometry: 200 polygons
- Texture: Solid color
- Simple sphere with nameplate
- No animation

### 3D Content Types

#### Document Display

```
3D Document Stack
    ┌──────────┐
   ┌┼──────────┼┐
  ┌┼┼──────────┼┼┐  ← Pages stacked with depth
  │┼┼  Page 1  ┼┼│    0.01m spacing between pages
  │┘│          │└│    Cast subtle shadows
  │ │          │ │
  │ │  Content │ │
  │ │          │ │
  └─┴──────────┴─┘
```

#### 3D Model Viewer

```
Product Model Display
         ↻  Rotate
         │
    ╭────┴────╮
   ╱          ╲
  │   [3D      │  ← Interactive model
  │   Model]   │    - Rotate with gesture
   ╲          ╱     - Scale with pinch
    ╰────────╯      - Exploded view
         │
    [📐 Measure]
```

---

## Interaction Patterns

### Gaze + Gesture Patterns

#### Pattern 1: Gaze to Focus, Pinch to Select

```
Step 1: Gaze → Target highlights
   👁️ ─────→  [Button] ← Subtle glow

Step 2: Pinch → Selection
   🤏        [Button] ← Pressed state
            └─ Haptic feedback
```

#### Pattern 2: Continuous Interaction (Slider)

```
   👁️ ──→  |████░░░░░░| 40%  ← Gaze at slider
            ↑
   🤏───────┘  ← Pinch and drag
            |██████░░░░| 60%  ← Value updates
```

### Direct Manipulation Patterns

#### Drag and Drop

```
1. Look + Pinch on object
   👁️ → 📄
         🤏

2. Hold pinch + Move hand
   👁️    📄 ←🤌 (moving)
         ↓
        [Drop Zone] ← Highlights when near

3. Release pinch to drop
         📄 ✓ ← Snaps into place
        [Drop Zone]
```

#### Resize Object

```
1. Two-hand pinch on object
   🤏 ← 📄 → 🤏

2. Move hands apart/together
   🤏 ←─ 📄📄 ─→ 🤏  (larger)
         or
   🤏─→ 📄 ←─🤏     (smaller)
```

### Voice Interaction Patterns

#### Voice + Gaze

```
1. Look at object
   👁️ → [Document]

2. Say command
   🗣️ "Share this"

3. Action performed
   [Document] ✓ → Shared with everyone
```

#### Ambient Voice Commands

```
No gaze required for global commands:

🗣️ "Mute"          → Mutes microphone
🗣️ "Leave meeting" → Confirms then leaves
🗣️ "Show agenda"   → Opens agenda window
🗣️ "Next slide"    → Advances presentation
```

---

## Visual Design System

### Color Palette

#### Primary Colors

```yaml
Brand Blue:
  Primary: #0071E3 (rgb(0, 113, 227))
  Light: #5EB3F6
  Dark: #0056B3
  Usage: Primary actions, links, active states

Spatial Gray:
  50:  #F5F5F7  (Lightest - backgrounds)
  100: #E8E8ED
  200: #D1D1D6
  300: #B0B0B8
  400: #86868B  (Mid - text, icons)
  500: #636366
  600: #48484A
  700: #3A3A3C
  800: #2C2C2E  (Darkest - text)
  900: #1C1C1E

Semantic Colors:
  Success: #34C759 (Green)
  Warning: #FF9500 (Orange)
  Error: #FF3B30 (Red)
  Info: #5AC8FA (Light Blue)

Speaking Indicator:
  Active: #00D4FF (Cyan)
  Gradient: #0071E3 → #00D4FF
```

#### Glass Materials

```swift
// System glass materials for visionOS
.ultraThinMaterial      // 95% transparent
.thinMaterial           // 85% transparent
.regularMaterial        // 70% transparent (default)
.thickMaterial          // 50% transparent
.ultraThickMaterial     // 30% transparent

// Usage
Controls:        .regularMaterial
Windows:         .thinMaterial
Overlays:        .ultraThinMaterial
Solid Elements:  .thickMaterial
```

### Typography

#### Font System

```yaml
visionOS Typography:
  Large Title:
    Font: SF Pro Rounded
    Size: 34pt
    Weight: Bold
    Usage: Section headers

  Title 1:
    Font: SF Pro
    Size: 28pt
    Weight: Bold
    Usage: Page titles

  Title 2:
    Font: SF Pro
    Size: 22pt
    Weight: Semibold
    Usage: Card headers

  Title 3:
    Font: SF Pro
    Size: 20pt
    Weight: Semibold
    Usage: Subsections

  Headline:
    Font: SF Pro
    Size: 17pt
    Weight: Semibold
    Usage: List items, buttons

  Body:
    Font: SF Pro
    Size: 17pt
    Weight: Regular
    Usage: Main content

  Callout:
    Font: SF Pro
    Size: 16pt
    Weight: Regular
    Usage: Secondary content

  Subheadline:
    Font: SF Pro
    Size: 15pt
    Weight: Regular
    Usage: Supporting text

  Footnote:
    Font: SF Pro
    Size: 13pt
    Weight: Regular
    Usage: Captions

  Caption 1:
    Font: SF Pro
    Size: 12pt
    Weight: Regular
    Usage: Small labels

  Caption 2:
    Font: SF Pro
    Size: 11pt
    Weight: Regular
    Usage: Timestamps
```

#### 3D Text Rendering

```yaml
Spatial Text:
  Depth: 0.02m extrusion
  Material: Matte or Glass
  Billboard: Faces user (for nameplates)
  Distance Scaling: Readable from 1-5m
  Shadow: Soft drop shadow for depth

Nameplate Example:
  Font: SF Pro Rounded
  Size: 14pt
  Weight: Semibold
  Color: White
  Background: Glass (90% vibrancy)
  Padding: 8pt horizontal, 4pt vertical
  Border Radius: 8pt
```

### Iconography

#### 2D Icons (System Icons)

```yaml
Icon Set: SF Symbols 5+
Size:
  Small: 16pt
  Medium: 24pt
  Large: 32pt
  Extra Large: 48pt

Weight: Match text weight
Rendering: Multicolor support
Hierarchy:
  Primary: Full color
  Secondary: 60% opacity
  Tertiary: 40% opacity

Common Icons:
  Microphone: mic.fill / mic.slash.fill
  Video: video.fill / video.slash.fill
  Share: square.and.arrow.up
  Hand Raise: hand.raised.fill
  Participants: person.3.fill
  Screen Share: rectangle.on.rectangle
  Whiteboard: pencil.and.scribble
  Leave: xmark.circle.fill
```

#### 3D Icons & Objects

```yaml
3D Icon Design:
  Polygon Budget: <1000 triangles
  Style: Rounded, friendly
  Materials: PBR (Physically Based Rendering)
  Size: 0.1-0.3m (physical size)
  Animation: Subtle hover effects

Examples:
  Microphone (3D):
    - Classic mic shape
    - Metallic material
    - Red mute indicator
    - Pulse animation when active

  Document (3D):
    - Paper stack with depth
    - White matte material
    - Page curl effect
    - Thumbnail preview

  Whiteboard (3D):
    - Floating board
    - Glass material
    - Active drawing shows in real-time
```

### Component Library

#### Buttons

```swift
// Primary Button
Button("Join Meeting") {
    // Action
}
.buttonStyle(.borderedProminent)
.controlSize(.large)

Visual:
  Background: Brand Blue with glass
  Text: White
  Corner Radius: 12pt
  Padding: 12pt vertical, 24pt horizontal
  Hover: Slight scale (1.05x) + brightness increase
  Pressed: Scale (0.95x)
  Disabled: 50% opacity
```

#### Cards

```swift
// Meeting Card
VStack {
    // Content
}
.background(.regularMaterial)
.clipShape(RoundedRectangle(cornerRadius: 16))
.shadow(radius: 10)

Visual:
  Material: .regularMaterial (glass)
  Corner Radius: 16pt
  Padding: 20pt
  Shadow: Soft, 10pt radius
  Hover: Slight lift (0.02m in Z)
```

#### Input Fields

```swift
TextField("Search meetings...", text: $query)
    .textFieldStyle(.roundedBorder)

Visual:
  Background: .ultraThinMaterial
  Border: 1pt, Gray 300
  Corner Radius: 8pt
  Padding: 10pt
  Focus: Blue border, glow effect
```

---

## User Flows & Navigation

### Flow 1: Join a Meeting

```
Start → Dashboard → Select Meeting → Join → Meeting Active
  │                      │              │
  │                      │              └→ Meeting Controls
  │                      │              └→ Participants View
  │                      │              └→ Shared Content
  │                      │
  │                      └→ Meeting Details → Join
  │
  └→ Quick Join (Enter Code)
```

**Detailed Steps**:

1. **Dashboard** (Window)
   - User sees upcoming meetings
   - Tap "Join Now" on meeting card

2. **Transition** (Animation)
   - Dashboard stays open
   - Meeting controls fade in (500ms)
   - Connecting indicator appears

3. **Meeting Active** (Multiple Windows/Volumes)
   - Meeting controls window (left)
   - Participants volume (center) OR
   - Shared content window (right)
   - Status: "Connected"

4. **Immersive Option**
   - Button: "Enter Immersive Mode"
   - Transition to ImmersiveSpace (1.5s fade)

### Flow 2: Share Content

```
Meeting Active → Share Button → Select Type → Choose File → Shared
                      │              │
                      │              ├→ Screen
                      │              ├→ Document
                      │              ├→ Whiteboard
                      │              └→ 3D Model
                      │
                      └→ Content appears in meeting space
```

**Detailed Steps**:

1. **Initiate Share**
   - Tap "Share" in controls
   - Share menu appears

2. **Select Type**
   - Document → File picker
   - Screen → Screen selector
   - Whiteboard → New whiteboard created
   - 3D Model → Model library

3. **Positioning** (if Document/Model)
   - Content appears in front of user (2m)
   - User can drag to reposition
   - Pinch to resize
   - Release to place

4. **Shared State**
   - All participants see content
   - Collaborative annotations available
   - Presenter has control

### Flow 3: Create Meeting

```
Dashboard → New Meeting → Configure → Schedule/Start → Meeting Created
              │               │
              │               ├→ Title
              │               ├→ Participants
              │               ├→ Environment Type
              │               ├→ Date/Time
              │               └→ Privacy Settings
              │
              └→ Instant Meeting (skips config)
```

### Navigation Patterns

#### Window Management

```
Multiple Windows Open:
┌──────────┐     ┌──────────┐     ┌──────────┐
│Dashboard │     │ Controls │     │  Content │
│          │     │          │     │          │
└──────────┘     └──────────┘     └──────────┘
     ↓                ↓                 ↓
[Close]      [Pin/Unpin]       [Resize/Move]
```

**Window Behaviors**:
- **Dashboard**: Can minimize while in meeting
- **Controls**: Always accessible (pinned option)
- **Content**: Multiple windows allowed
- **Participant Grid**: Toggle on/off

#### Spatial Navigation

```
Environments:
Windows → Volume → Immersive → Back to Windows
  ↓         ↓          ↓
2D       3D Bounded  360° Full
```

**Transition Triggers**:
- "Enter Immersive" button
- "Exit Immersive" → Eye look up + pinch
- Automatic: For specific content (3D models)

---

## Accessibility Design

### VoiceOver Navigation

```
Meeting Controls (VoiceOver Focus Order):

1. "Meeting title: Product Review"
2. "Mute button, currently unmuted"
3. "Video button, camera off"
4. "Participants button, 12 participants"
5. "Share button"
6. "Leave meeting button"

Gesture: Two-finger swipe → Next element
Action: Double tap → Activate
Info: Three-finger tap → More details
```

### High Contrast Mode

```yaml
High Contrast Adjustments:
  Background Contrast: Increase to 7:1 minimum
  Border Thickness: 2pt → 4pt
  Focus Indicators: Thicker (4pt), brighter
  Text: Pure white on pure black (in dark mode)
  Icons: Filled versions only (no thin outlines)
  Shadows: Removed (use borders instead)
  Glass: Reduced transparency (more opaque)
```

### Reduce Motion

```yaml
Animation Replacements:
  Fade: Instead of zoom/scale
  Crossfade: Instead of slide
  Instant: For rapid transitions
  Duration: Cut in half (500ms → 250ms)

Disabled Animations:
  - Particle effects
  - Parallax scrolling
  - Continuous animations (breathing, pulse)
  - Spring animations
  - Bounce effects
```

### Larger Text Support

```yaml
Dynamic Type Scaling:
  XS:  Scale 0.8x
  S:   Scale 0.9x
  M:   Scale 1.0x (default)
  L:   Scale 1.15x
  XL:  Scale 1.3x
  XXL: Scale 1.5x
  XXXL: Scale 2.0x

Layout Adjustments:
  - Reflow text (no truncation)
  - Expand containers
  - Stack horizontally → vertically (if needed)
  - Minimum button height: 60pt (XXXL)
```

---

## Error States & Loading Indicators

### Connection Error

```
┌─────────────────────────────────────┐
│  ⚠️ Connection Lost                 │
├─────────────────────────────────────┤
│                                      │
│  Your connection to the meeting     │
│  was interrupted.                   │
│                                      │
│  [Reconnecting... ●●●○○○]           │
│                                      │
│  [Try Again]  [Leave Meeting]       │
│                                      │
└─────────────────────────────────────┘
```

### Loading States

#### Joining Meeting

```
┌─────────────────────────────────────┐
│  Joining Meeting...                 │
├─────────────────────────────────────┤
│                                      │
│         ◐ Connecting                │
│                                      │
│  • Connecting to server    ✓        │
│  • Establishing media      ⟳        │
│  • Loading environment     ○        │
│                                      │
└─────────────────────────────────────┘
```

#### Loading Content

```
Document Thumbnail:
┌──────────────┐
│              │
│   ⟳          │  ← Subtle spinner
│  Loading...  │     Doesn't block UI
│              │
└──────────────┘
```

### Empty States

#### No Upcoming Meetings

```
┌─────────────────────────────────────┐
│                                      │
│           📅                         │
│                                      │
│    No Meetings Scheduled            │
│                                      │
│  You're all caught up!               │
│                                      │
│  [Schedule Meeting] [Join with Code]│
│                                      │
└─────────────────────────────────────┘
```

### Validation Errors

```
Meeting Title Field:
┌─────────────────────────────────────┐
│ Meeting Title                        │
│ [                           ]        │
│ ⚠️ Title is required                │
└─────────────────────────────────────┘
```

---

## Animation & Transition Specifications

### Window Transitions

#### Opening Window

```yaml
Animation:
  Type: Fade + Scale
  Duration: 400ms
  Easing: easeInOut
  From:
    Opacity: 0
    Scale: 0.9
  To:
    Opacity: 1.0
    Scale: 1.0
  Position: Animates from button position
```

#### Closing Window

```yaml
Animation:
  Type: Fade + Scale
  Duration: 300ms
  Easing: easeIn
  From:
    Opacity: 1.0
    Scale: 1.0
  To:
    Opacity: 0
    Scale: 0.95
  Position: Stays in place
```

### Immersive Transitions

#### Entering Immersive Space

```yaml
Animation:
  Type: Fade environment
  Duration: 1500ms
  Easing: easeInOut
  Stages:
    0ms: Windows begin to fade (500ms)
    500ms: Environment starts appearing (1000ms)
    1000ms: Full immersion
  Audio: Spatial audio smoothly transitions
```

### Participant Animations

#### Joining Animation

```yaml
Participant Appears:
  Duration: 600ms
  Easing: Spring (response: 0.5, damping: 0.7)
  From:
    Opacity: 0
    Scale: 0.5
    Position: Above final position (0.3m)
  To:
    Opacity: 1.0
    Scale: 1.0
    Position: Final position
  Effect: Gentle "pop" into existence
```

#### Speaking Indicator

```yaml
Pulse Animation:
  Duration: 2000ms
  Loop: Infinite
  Easing: easeInOut
  Property: Ring scale
  From: 1.0
  To: 1.2
  Color: Cyan glow
  Opacity: 0.8 → 0.3 (fades)
```

### Content Animations

#### Document Appears

```yaml
Slide In + Fade:
  Duration: 500ms
  Easing: easeOut
  From:
    Position: -0.5m in Z (closer)
    Opacity: 0
    Rotation: 10° on Y-axis
  To:
    Position: Final position
    Opacity: 1.0
    Rotation: 0°
```

#### Whiteboard Stroke

```yaml
Drawing Animation:
  Type: Path animation
  Speed: Real-time (follows hand)
  Width: Pressure-sensitive (if supported)
  Smoothing: Catmull-Rom spline
  Latency: <16ms (sub-frame)
  Sync: Broadcast to others <100ms
```

### Gesture Feedback

#### Button Press

```yaml
Haptic + Visual:
  Visual:
    Duration: 150ms
    Scale: 1.0 → 0.95 → 1.0
    Brightness: +20%
  Haptic:
    Type: Light impact
    Timing: At scale minimum
```

#### Drag Object

```yaml
Continuous Feedback:
  Visual:
    Opacity: 1.0 → 0.8 (while dragging)
    Shadow: Increase depth (lift effect)
  Haptic:
    Type: Selection changed (when over drop zone)
  Snap:
    Type: Spring animation to final position
    Duration: 300ms
```

### Microinteractions

#### Toggle Switch

```yaml
Animation:
  Duration: 200ms
  Easing: easeInOut
  Property: Thumb position
  Color Transition: Gray → Blue (on)
  Haptic: Light impact at switch
```

#### Notification Badge

```yaml
Appear:
  Type: Scale + Bounce
  Duration: 400ms
  Easing: Spring (damping: 0.6)
  From: Scale 0 → 1.2 → 1.0
  Color: Red with white text
```

---

## Design Tokens

### Spacing Scale

```yaml
Spacing:
  xs: 4pt
  sm: 8pt
  md: 16pt
  lg: 24pt
  xl: 32pt
  2xl: 48pt
  3xl: 64pt

3D Spacing:
  near: 0.1m
  close: 0.3m
  comfortable: 0.6m
  medium: 1.0m
  far: 2.0m
  distant: 5.0m
```

### Border Radius

```yaml
Radius:
  sm: 4pt
  md: 8pt
  lg: 12pt
  xl: 16pt
  2xl: 24pt
  round: 50% (circular)
```

### Shadows

```yaml
Elevation:
  level1:
    Radius: 2pt
    Offset: (0, 1pt)
    Opacity: 0.1

  level2:
    Radius: 4pt
    Offset: (0, 2pt)
    Opacity: 0.15

  level3:
    Radius: 8pt
    Offset: (0, 4pt)
    Opacity: 0.2

  level4:
    Radius: 16pt
    Offset: (0, 8pt)
    Opacity: 0.25
```

---

## Design System Implementation

### SwiftUI Component Example

```swift
// Primary Button Component
struct SpatialPrimaryButton: View {
    let title: String
    let action: () -> Void
    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .padding(.horizontal, 24)
        }
        .buttonStyle(.borderedProminent)
        .tint(isEnabled ? .blue : .gray)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: isEnabled ? 4 : 0)
        .animation(.easeInOut(duration: 0.2), value: isEnabled)
    }
}

// Meeting Card Component
struct MeetingCardView: View {
    let meeting: Meeting

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(meeting.title)
                .font(.title2)
                .fontWeight(.semibold)

            HStack {
                Label("\(meeting.participants.count) participants",
                      systemImage: "person.3.fill")
                Spacer()
                Label(meeting.environment.name,
                      systemImage: "location.fill")
            }
            .font(.callout)
            .foregroundColor(.secondary)

            SpatialPrimaryButton(title: "Join Now") {
                // Join meeting
            }
        }
        .padding(20)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 10)
    }
}
```

---

## Conclusion

This design specification creates a cohesive, intuitive, and beautiful spatial meeting experience that:

- **Feels Natural**: Leverages human spatial cognition
- **Looks Beautiful**: Apple-quality visual design
- **Works for Everyone**: Comprehensive accessibility
- **Delights Users**: Thoughtful microinteractions
- **Scales Gracefully**: From 2 to 100 participants

The design system ensures consistency across all interfaces while maintaining the flexibility needed for diverse meeting scenarios and user preferences.
