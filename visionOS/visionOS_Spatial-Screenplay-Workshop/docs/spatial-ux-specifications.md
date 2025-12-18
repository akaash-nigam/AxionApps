# Spatial UI/UX Specifications

## Overview

This document defines the spatial user experience for Spatial Screenplay Workshop on Apple Vision Pro, including interaction patterns, spatial layouts, gestures, voice commands, and accessibility features.

## Design Principles

### 1. Spatial Comfort
- Content positioned at comfortable viewing angles (0-30° from eye level)
- Distance: 2-4 meters for primary content
- Avoid neck strain (no extreme up/down positioning)
- Respect user's physical space

### 2. Immersion Levels
- **Shared Space**: Normal app with windows, collaborate with other apps
- **Full Space**: Dedicated environment for focused work
- **Immersive**: Complete spatial experience, maximum immersion

### 3. Progressive Disclosure
- Show essential controls first
- Advanced features hidden until needed
- Context-sensitive UI
- Minimize visual clutter

### 4. Spatial Affordances
- Objects should look interactive
- Hover states indicate interactivity
- Depth cues show layer hierarchy
- Animation reinforces spatial relationships

## App Modes

### Mode 1: Project Dashboard (Shared Space)

**Purpose**: Browse and manage projects

**Layout**:
```
            User Position
                 👤
                 │
     ┌───────────┼───────────┐
     │           │           │
     │      Dashboard        │
     │    (2.5m away)        │
     │                       │
     └───────────────────────┘

Window: 1000×800 pt
Position: Center, 2.5m from user, 0° vertical
```

**Components**:
- Project grid (3×2 layout)
- "New Project" button
- Settings button (top-right)
- Search bar (top)
- Filter/sort controls

**Interactions**:
- Tap project → Open project in Timeline mode
- Long press → Context menu (Duplicate, Delete, Export)
- Hover → Show project preview (page count, last modified)

### Mode 2: Timeline View (Full Space)

**Purpose**: Visualize scene structure spatially

**Layout**:
```
                 User Position
                      👤
                      │
        ┌─────────────┼─────────────┐
        │             │             │
   [Act I]       [Act II]      [Act III]
     2m            3m             4m
  distance      distance       distance
```

**Scene Card Positioning Algorithm**:
```swift
func calculateSceneCardPosition(
    sceneIndex: Int,
    act: Int,
    totalScenesInAct: Int
) -> SIMD3<Float> {

    // Base distance by act
    let baseDistance: Float = act == 1 ? 2.0 : act == 2 ? 3.0 : 4.0

    // Horizontal spacing within act
    let cardWidth: Float = 0.4
    let spacing: Float = 0.1
    let totalWidth = Float(totalScenesInAct) * (cardWidth + spacing)
    let startX = -totalWidth / 2.0

    let x = startX + Float(sceneIndex) * (cardWidth + spacing)

    // Vertical: slightly below eye level
    let y: Float = 1.4  // Eye level ≈ 1.6m, cards at 1.4m

    // Depth
    let z = -baseDistance

    return SIMD3(x, y, z)
}
```

**Scene Card Design**:

**Dimensions**: 40cm × 50cm (physical equivalent)

**Visual Structure**:
```
┌─────────────────────────────────┐
│ [Status]           [Act II - 3] │ ← Header
├─────────────────────────────────┤
│ INT. COFFEE SHOP - DAY          │ ← Slug line (large)
│                                 │
│ 📍 Coffee Shop                  │ ← Location icon + name
│ 👥 Alex, Sarah                  │ ← Character icons + names
│ ⏱️  2.5 pages                   │ ← Duration
│                                 │
│ "Alex reveals secret to Sarah"  │ ← Summary (italic)
│                                 │
├─────────────────────────────────┤
│ [Edit] [Notes] [Storyboard]    │ ← Actions
└─────────────────────────────────┘
```

**Color Coding**:
- **By Location**: Each location has consistent color
- **By Time**: Day=yellow tint, Night=blue tint
- **By Character**: Protagonist scenes, supporting scenes
- **By Status**: Draft=white, Revised=blue, Locked=green

**Card States**:
- **Default**: Flat card, subtle shadow
- **Hover**: Slight scale (1.05×), brighter
- **Selected**: Bold border, elevated (10cm forward)
- **Editing**: Full opacity, others dimmed to 60%

**Interactions**:

| Gesture | Action |
|---------|--------|
| Tap | Select card |
| Double tap | Open in editor |
| Long press | Show context menu |
| Drag | Reorder scene (snaps to valid positions) |
| Pinch (two hands) | Zoom timeline (closer/farther) |
| Rotate gesture | Rotate timeline view |

**Controls** (Floating Toolbar):

Position: Bottom center, 1.2m from user, 0.5m below cards

```
┌─────────────────────────────────────────────────┐
│ [−] [+] │ [🎨] │ [👁️] │ [↶] │ [✓] │ [📤] │ [⋮] │
│ Zoom    Color  View  Undo Save Export More     │
└─────────────────────────────────────────────────┘
```

### Mode 3: Script Editor (Immersive)

**Purpose**: Focused writing with minimal distraction

**Layout**:
```
                    👤
                    │
         ┌──────────┼──────────┐
         │    Text Editor      │
         │     (2m away)       │
         │                     │
         │   Floating          │
         │   Keyboard          │
         │   (1m away)         │
         └─────────────────────┘

Scene Card Preview (right side, 3m away, 30° angle)
```

**Text Editor**:
- **Size**: 800×1000 pt
- **Background**: Translucent dark (reduces eye strain)
- **Font**: Courier 14pt (screenplay standard)
- **Line height**: 1.5
- **Margins**: Match screenplay format

**Auto-Formatting**:
```
Type "INT" → Recognizes slug line → Formats to:
INT. [CURSOR] - [TIME]

Type character name "ALEX" → Recognizes dialogue → Centers name
                    ALEX
            [CURSOR]
```

**Floating Toolbar** (Top):
```
┌───────────────────────────────────────────────────┐
│ Scene 7 │ [←] [→] │ [B] [I] [U] │ [Character] │ 📊│
│         Prev/Next  Format       Summon Char  Stats│
└───────────────────────────────────────────────────┘
```

**Side Panel** (Right, collapsible):
- Scene metadata
- Character list (tap to insert name)
- Location list
- Notes

**Interactions**:
- **Bluetooth keyboard**: Primary input method
- **Dictation**: Voice input via system
- **Gaze + Pinch**: Select text
- **Virtual keyboard**: Fallback (hand typing)

### Mode 4: Character Performance (Full Space)

**Purpose**: Hear dialogue with life-sized characters

**Layout**:
```
         [Character 1]      User      [Character 2]
               👤             👤             👤
               │              │              │
         (1.5m away)     (center)      (1.5m away)
         (facing user)                 (facing user)


         Dialogue Script (floating, 2m ahead, below eye level)
```

**Character Rendering**:
- **Height**: Based on character profile (1.5m - 2.0m)
- **Position**: 1.5-2m from user
- **Representation**:
  - **Simple**: Glowing silhouette with label
  - **Avatar**: 3D humanoid model
  - **Detailed**: Custom imported model

**Character Appearance**:
```swift
struct CharacterAvatarStyle {
    case silhouette        // Glowing outline, low resource
    case simpleAvatar      // Basic 3D humanoid
    case detailedAvatar    // High-quality 3D model
}
```

**Dialogue Display**:
```
┌─────────────────────────────┐
│  Scene 7: Coffee Shop       │
│                             │
│  [Alex] is speaking...      │
│                             │
│  ALEX                       │
│  I need to tell you         │
│  something.                 │
│                             │
│  ▶ Playing                  │
└─────────────────────────────┘
```

**Spatial Audio**:
- Voice emanates from character position
- Volume adjusts with distance (natural falloff)
- Binaural rendering for realism

**Controls**:
```
┌────────────────────────────────────────────┐
│ [⏮️] [⏯️] [⏭️] │ [🔄] [🎙️] │ [⚙️] [✕]     │
│ Prev Play Next  Repeat Record Settings Close│
└────────────────────────────────────────────┘
```

**Blocking Mode**:
- Drag characters to position them
- Add movement markers (character walks to door)
- Save blocking for production reference

### Mode 5: Location Scout (Immersive)

**Purpose**: Explore virtual locations, blend with real space

**Modes**:

#### A. Overlay Mode (AR)
- Virtual furniture/props overlaid on real room
- See through to real space
- Align virtual location with physical walls

#### B. Full Virtual Mode
- Replace entire room with virtual location
- Complete immersion
- User can walk around (tracked)

**Layout**:
```
     [Virtual Environment surrounding user]

     Floating Control Panel (left hand, 0.5m away)
     Camera Viewfinder (right, when active)
```

**Control Panel**:
```
┌──────────────────────┐
│ Location Scout       │
├──────────────────────┤
│ Location:            │
│ Coffee Shop ▼        │
│                      │
│ Time: Day ▼          │
│ Weather: Clear ▼     │
│                      │
│ Lighting:            │
│ [═══════○──] 80%     │
│                      │
│ [📷 Camera]          │
│ [📐 Measure]         │
│ [💾 Save Setup]      │
└──────────────────────┘
```

**Camera Tool**:
- Mark camera positions
- Set focal length
- Preview shot framing
- Save camera angles for production

**Measurement Tool**:
- Measure distances
- Check clearances
- Verify set dimensions

### Mode 6: Storyboard Editor (Full Space)

**Purpose**: Create and animate storyboards

**Layout**:
```
                     👤 User
                     │
         ┌───────────┼───────────┐
         │                       │
    Drawing Canvas           Frame Timeline
     (2m ahead)              (below, 1m)

     [Frame 1][Frame 2][Frame 3][Frame 4]...
```

**Drawing Canvas**:
- **Size**: 1200×800 pt (16:9 aspect)
- **Tools**: Drawing, shapes, text, import image
- **Apple Pencil**: Supported for iPad/Mac companion

**Frame Timeline**:
```
┌──────────────────────────────────────────┐
│ [+]  Frame  Frame  Frame  Frame  [Play]  │
│      ╔═1═╗  ╔═2═╗  ╔═3═╗  ╔═4═╗        │
│      ║   ║  ║   ║  ║   ║  ║   ║        │
│      ╚═══╝  ╚═══╝  ╚═══╝  ╚═══╝        │
│        3s     2s     4s     3s          │
└──────────────────────────────────────────┘
```

**Frame Properties Panel**:
```
┌────────────────────┐
│ Frame 1            │
├────────────────────┤
│ Shot: WS ▼         │
│ Camera: Static ▼   │
│ Duration: 3s       │
│                    │
│ Dialogue:          │
│ [Text field]       │
│                    │
│ Notes:             │
│ [Text field]       │
└────────────────────┘
```

**Playback Mode**:
- Frames transition with timing
- Audio playback (dialogue, temp music)
- Full-screen animatic preview

## Gesture Reference

### Primary Gestures (System Standard)

| Gesture | Description | Use Case |
|---------|-------------|----------|
| **Gaze + Pinch** | Look at object, pinch fingers | Select/activate |
| **Gaze + Pinch + Drag** | Pinch and move hand | Move objects |
| **Double Pinch** | Quick two pinches | Alternate select |
| **Long Pinch** | Hold pinch 1s | Context menu |
| **Two-Hand Pinch** | Both hands pinch | Scale/zoom |

### Custom Gestures

| Gesture | Description | Use Case |
|---------|-------------|----------|
| **Gaze + Double Tap** | Look + quick double pinch | Quick edit mode |
| **Circular Hand Motion** | Draw circle with finger | Cycle through scenes |
| **Push Away** | Push hand forward | Dismiss/close |
| **Pull Toward** | Pull hand toward self | Bring closer |

### Keyboard Shortcuts

| Key | Action |
|-----|--------|
| `⌘N` | New scene |
| `⌘S` | Save |
| `⌘E` | Export |
| `⌘Z` | Undo |
| `⌘⇧Z` | Redo |
| `Tab` | Next script element |
| `⌘Return` | Summon characters |
| `Space` | Play/pause dialogue |
| `←` `→` | Previous/next scene |

## Voice Commands

### Navigation
```
"Go to scene [number]"
"Show timeline"
"Open script editor"
"Next scene" / "Previous scene"
```

### Editing
```
"Create new scene"
"Delete scene [number]"
"Move scene [number] to [position]"
"Add character [name]"
```

### Performance
```
"Play scene [number]"
"Pause"
"Repeat last line"
"Show [character name]"
```

### Export
```
"Export to PDF"
"Save project"
```

## Accessibility Features

### VoiceOver Support

**Scene Cards**:
```
VoiceOver: "Scene 7, Interior Coffee Shop, Day, 2.5 pages,
            Characters Alex and Sarah, Status Locked.
            Button. Double-tap to edit."
```

**Script Editor**:
- Read current line
- Navigate by element type (action, dialogue, etc.)
- Announce formatting changes

### Visual Accessibility

**High Contrast Mode**:
- Increase card border weight
- Higher color saturation
- Black/white mode option

**Text Size**:
- Adjustable font size (12pt - 18pt)
- Maintain screenplay formatting ratios

**Reduce Motion**:
- Disable card animations
- Instant transitions
- Static layouts

### Motor Accessibility

**Dwell Control**:
- Gaze-based selection (look for 1.5s)
- No pinch required
- Voice commands as alternative

**Switch Control**:
- Navigate via external switch
- Scan through UI elements

### Cognitive Accessibility

**Simplified Mode**:
- Fewer on-screen elements
- Larger touch targets
- Clear labels (no icons only)

**Focus Mode**:
- Hide all but current scene
- Reduce visual complexity
- Minimize distractions

## Visual Design System

### Typography

```swift
struct ScreenplayFonts {
    static let scriptFont = Font.custom("Courier", size: 14)
    static let uiFont = Font.system(.body, design: .rounded)
    static let cardTitle = Font.system(.title3, weight: .bold)
    static let cardBody = Font.system(.body)
    static let caption = Font.system(.caption)
}
```

### Color Palette

**Primary Colors**:
```swift
struct BrandColors {
    static let primary = Color(hex: "1A237E")      // Navy Blue
    static let secondary = Color(hex: "FFB300")    // Gold
    static let background = Color(hex: "121212")   // Dark
    static let surface = Color(hex: "1E1E1E")      // Card background
}
```

**Semantic Colors**:
```swift
struct StatusColors {
    static let draft = Color.white
    static let revised = Color.blue
    static let locked = Color.green
    static let needsWork = Color.orange
}

struct LocationColors {
    // Generated dynamically per location
    // Using HSL color space for consistency
}
```

### Spacing System

```swift
struct Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}
```

### Depth Layers

```swift
struct DepthLayer {
    static let background: Float = -5.0    // Environment
    static let far: Float = -4.0           // Act III
    static let medium: Float = -3.0        // Act II
    static let near: Float = -2.0          // Act I
    static let foreground: Float = -1.0    // UI controls
    static let overlay: Float = -0.5       // Modals
}
```

### Animation System

**Timing Functions**:
```swift
struct Animations {
    static let quick = Animation.easeInOut(duration: 0.15)
    static let standard = Animation.easeInOut(duration: 0.3)
    static let slow = Animation.easeInOut(duration: 0.5)
    static let spring = Animation.spring(response: 0.3, dampingFraction: 0.7)
}
```

**Common Animations**:

**Card Hover**:
```swift
.scaleEffect(isHovered ? 1.05 : 1.0)
.animation(.spring, value: isHovered)
```

**Card Selection**:
```swift
.offset(z: isSelected ? 0.1 : 0)  // Move forward 10cm
.shadow(radius: isSelected ? 20 : 10)
```

**Scene Transition**:
```swift
.transition(.asymmetric(
    insertion: .move(edge: .trailing).combined(with: .opacity),
    removal: .move(edge: .leading).combined(with: .opacity)
))
```

## Loading & Empty States

### Loading State
```
┌────────────────────┐
│                    │
│    ⏳ Loading      │
│    Project...      │
│                    │
└────────────────────┘
```

### Empty State (No Scenes)
```
┌─────────────────────────────┐
│                             │
│     📝 No scenes yet        │
│                             │
│  Get started by creating    │
│  your first scene           │
│                             │
│    [Create First Scene]     │
│                             │
└─────────────────────────────┘
```

### Error State
```
┌─────────────────────────────┐
│     ⚠️ Unable to Load       │
│                             │
│  Could not load project     │
│  Please try again           │
│                             │
│  [Retry]  [Go Back]         │
└─────────────────────────────┘
```

## Onboarding Flow

### First Launch

**Step 1: Welcome** (Shared Space)
```
Welcome to Spatial Screenplay Workshop
Transform your screenwriting with spatial computing

[Continue]
```

**Step 2: Permissions**
```
We need your permission to:
✓ Save projects to iCloud
✓ Access spatial tracking
✓ Use hand tracking

[Allow] [Learn More]
```

**Step 3: Tutorial**
```
Let's create your first project

[Start Tutorial] [Skip Tutorial]
```

**Interactive Tutorial**:
1. Create project → Form appears
2. Add first scene → Card appears in space
3. Tap scene card → Opens editor
4. Write line of dialogue → Auto-formatting demo
5. Summon character → Character appears
6. Play dialogue → Hear voice
7. Success! → Project dashboard

**Duration**: ~5 minutes

## Performance Guidelines

### Frame Rate Targets

- **Timeline View**: 60 FPS minimum, 90 FPS target
- **Script Editor**: 60 FPS (text rendering)
- **Character Performance**: 90 FPS (character rendering + audio)
- **Location Scout**: 90 FPS (immersive environment)

### Optimization Techniques

**Render Budget**:
- Maximum 100 visible scene cards
- 2-3 characters at a time
- 1 environment active

**Culling**:
- Distance-based: Hide cards > 6m away
- Frustum culling: Hide cards outside view
- Occlusion culling: Hide cards behind others

## Responsive Design

### Room Size Adaptation

**Small Room** (< 3m × 3m):
- Reduce card spacing
- Closer timeline depth (1.5-3m)
- Vertical stacking if needed

**Large Room** (> 5m × 5m):
- Expand timeline
- Use full space
- Increase card spacing

### User Height Adaptation

```swift
func adjustForUserHeight(_ height: Float) -> Float {
    // Place cards at comfortable viewing angle
    // Eye level - 20cm
    return height - 0.2
}
```

## Multi-Window Support

**Shared Space Mode**:
- Main window: Project dashboard
- Secondary window: Script editor (2D fallback)
- Inspector window: Scene properties

**Concurrent Windows**:
- Timeline + Script Editor
- Script Editor + Character Performance
- Location Scout + Reference Images

## Context Menus

### Scene Card Context Menu
```
Edit Scene
Add Note
Duplicate Scene
Move to...
──────────────
Mark as Locked
Change Status
──────────────
Delete Scene
```

### Character Context Menu
```
Edit Character
Test Voice
──────────────
Scenes with Character
──────────────
Remove from Scene
Delete Character
```

## Tooltips & Help

**Hover Tooltips**:
- Show after 1 second hover
- Brief description
- Keyboard shortcut if available

```
┌─────────────────────┐
│ Export Project      │
│ ⌘E                  │
└─────────────────────┘
```

**Contextual Help**:
- "?" button in each view
- Quick tips overlay
- Link to full documentation

## Haptic Feedback

**Supported Gestures** (via Apple Watch):
- Tap: Light click
- Drag start: Gentle tap
- Snap to position: Medium click
- Error: Double tap
- Success: Triple tap

---

**Document Version**: 1.0
**Last Updated**: 2025-11-24
**Author**: UX Design Team
