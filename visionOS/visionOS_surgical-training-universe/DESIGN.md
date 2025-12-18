# Design Specifications - Surgical Training Universe

## Document Version
- **Version**: 1.0
- **Last Updated**: 2025-11-17
- **Status**: Initial Design

---

## 1. Spatial Design Principles

### 1.1 Core Design Philosophy

**"Spatial Surgery First"**
- Leverage 3D space for anatomical accuracy
- Real-world scale (1:1) for muscle memory
- Ergonomic positioning for comfort
- Intuitive surgical interactions
- Progressive complexity disclosure

### 1.2 visionOS Design Principles

1. **Familiar + Dimensional**: Bridge 2D surgical planning with 3D practice
2. **Human-Centered**: Ergonomic positioning 10-15° below eye level
3. **Authentic**: Realistic OR environment and instruments
4. **Focused**: Minimize distractions during procedures
5. **Comfortable**: Support 30+ minute training sessions

### 1.3 Spatial Hierarchy

```
Ergonomic Zones (from user):

Intimate Zone (0.2m - 0.5m)
├── Surgical field (hands-on work)
├── Primary instruments
└── Critical feedback

Personal Zone (0.5m - 1.2m)
├── Patient anatomy
├── Secondary instruments
├── Monitoring displays
└── AI coach overlay

Social Zone (1.2m - 3.5m)
├── OR environment
├── Equipment carts
├── Team members
└── Ambient displays

Public Zone (3.5m+)
├── OR architecture
├── Spatial audio sources
└── Environmental effects
```

---

## 2. Window Layouts & Configurations

### 2.1 Main Dashboard Window

**Layout Structure**:
```
┌────────────────────────────────────────────────────┐
│  [Profile]                    [Settings] [Help]    │
├────────────────────────────────────────────────────┤
│                                                    │
│  ┌──────────────────────────────────────────────┐ │
│  │         Performance Overview                  │ │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐   │ │
│  │  │Accuracy  │  │Efficiency│  │ Safety   │   │ │
│  │  │  92%     │  │   88%    │  │   95%    │   │ │
│  │  └──────────┘  └──────────┘  └──────────┘   │ │
│  └──────────────────────────────────────────────┘ │
│                                                    │
│  Procedure Library                                │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ │
│  │Appendix │ │ Cardiac │ │  Neuro  │ │  More   │ │
│  │ectomy   │ │ CABG    │ │Craniotomy│ │ →       │ │
│  │         │ │         │ │         │ │         │ │
│  │[Start]  │ │[Start]  │ │[Start]  │ │         │ │
│  └─────────┘ └─────────┘ └─────────┘ └─────────┘ │
│                                                    │
│  Recent Activity                                  │
│  ┌────────────────────────────────────────────┐   │
│  │ ● Appendectomy - 92% - 23 min    [Review] │   │
│  │ ● Cholecystectomy - 88% - 31 min [Review] │   │
│  │ ● Laparoscopy - 95% - 18 min     [Review] │   │
│  └────────────────────────────────────────────┘   │
│                                                    │
│  [Continue Training] [View Analytics] [Collab]    │
└────────────────────────────────────────────────────┘
```

**Visual Properties**:
- **Size**: 1000×700 points
- **Material**: Glass with subtle vibrancy
- **Background**: 10% opacity white with blur
- **Corner Radius**: 20pt
- **Shadow**: Soft, 20pt offset
- **Typography**: SF Pro Display
- **Color Palette**: Medical blues and greens

### 2.2 Analytics Window

**Layout Structure**:
```
┌────────────────────────────────────────────────────┐
│  Performance Analytics               [Export]      │
├────────────────────────────────────────────────────┤
│                                                    │
│  ┌──────────────────────────────────────────────┐ │
│  │     Skill Progression (Last 30 Days)         │ │
│  │                                              │ │
│  │  100% ┼                           ╱───       │ │
│  │   75% ┼                   ╱───╱              │ │
│  │   50% ┼           ╱───╱                      │ │
│  │   25% ┼   ╱───╱                              │ │
│  │    0% ┼───┼───┼───┼───┼───┼───┼───┼───┼     │ │
│  │       Week 1    2    3    4                  │ │
│  └──────────────────────────────────────────────┘ │
│                                                    │
│  ┌───────────────┐ ┌───────────────┐              │
│  │ Accuracy      │ │ Complications │              │
│  │               │ │               │              │
│  │   ○ 92%       │ │  ▼ -40%       │              │
│  │  ╱ ╲          │ │  (Reduced)    │              │
│  │ ○───○         │ │               │              │
│  └───────────────┘ └───────────────┘              │
│                                                    │
│  Procedure Breakdown                              │
│  ┌────────────────────────────────────────────┐   │
│  │ Appendectomy        ████████░░  15 sessions │   │
│  │ Cholecystectomy     ██████░░░░  12 sessions │   │
│  │ Laparoscopy         ████░░░░░░   8 sessions │   │
│  └────────────────────────────────────────────┘   │
└────────────────────────────────────────────────────┘
```

**Chart Types**:
- **Line Charts**: Skill progression over time
- **Radial Progress**: Competency scores
- **Bar Charts**: Procedure distribution
- **Heat Maps**: Error patterns
- **3D Visualizations**: Spatial accuracy maps

---

## 3. Volume Designs (3D Bounded Spaces)

### 3.1 Anatomy Explorer Volume

**Spatial Layout**:
```
       Top View (1m × 1m × 1m volume)
       ┌─────────────────────┐
       │                     │
       │    ┌─────────┐      │
       │    │         │      │
       │    │ Anatomy │      │
       │    │  Model  │      │
       │    │         │      │
       │    └─────────┘      │
       │                     │
       │  [Annotations]      │
       └─────────────────────┘

       Side View
       ┌─────────────────────┐
       │         ▲           │
       │         │           │
       │     [Anatomy]       │
       │         │           │
       │         ▼           │
       │                     │
       │   [Control Panel]   │
       └─────────────────────┘
```

**Interaction Elements**:

1. **Floating Control Panel** (Bottom)
   - Layer visibility toggles
   - Rotation controls
   - Zoom slider
   - Explode view button
   - Reset button

2. **Annotation Labels** (Contextual)
   - Organ names
   - Vessel identification
   - Nerve pathways
   - Anatomical landmarks
   - Measurement tools

3. **Visual Effects**:
   - **Glow**: Selected structures
   - **Transparency**: Toggle layers
   - **Pulsing**: Vessels (arterial flow)
   - **Color Coding**:
     - Red: Arteries
     - Blue: Veins
     - Yellow: Nerves
     - White: Bones
     - Pink: Muscles
     - Tan: Organs

### 3.2 Instrument Preview Volume

**Layout** (0.5m × 0.5m × 0.5m):
```
┌─────────────────┐
│                 │
│   ╱─────╲       │  <- Rotating instrument
│  │       │      │
│   ╲─────╱       │
│                 │
│  [Tool Name]    │
│  [Specifications]│
│                 │
│  [Select]  [←→] │
└─────────────────┘
```

**Features**:
- **Auto-rotation**: Slow 360° rotation
- **Annotations**: Tool features highlighted
- **Specifications**: Size, type, usage
- **Selection**: Tap to select for procedure
- **Navigation**: Swipe to browse instruments

---

## 4. Full Space / Immersive Experiences

### 4.1 Surgical Theater (Full Immersion)

**Environment Design**:

```
                     Top-Down View of OR

        ┌─────────────────────────────────────────┐
        │                                         │
        │  [Monitor]           [Surgical Light]   │
        │                           │             │
        │                           ▼             │
        │  ┌───────────────────────────┐          │
        │  │                           │          │
        │  │    Patient Anatomy        │          │
        │  │    (Operating Table)      │          │
        │  │                           │          │
        │  └───────────────────────────┘          │
        │          │                               │
        │          │ User Position                │
        │          ●                               │
        │                                         │
        │  [Instrument]              [Equipment]  │
        │  [  Table  ]               [  Cart   ]  │
        │                                         │
        └─────────────────────────────────────────┘
```

**Spatial Elements**:

1. **Operating Table** (Center, 0.8m ahead)
   - Dimension: 1.8m × 0.6m
   - Height: Adjustable (default 0.9m)
   - Material: Medical-grade steel appearance
   - Patient anatomy positioned on top

2. **Surgical Lights** (Above, 2.5m high)
   - Adjustable position and intensity
   - Realistic light cone
   - Shadow casting enabled
   - Color temperature: 4500K

3. **Instrument Table** (Right, 0.6m away)
   - Dimension: 0.8m × 0.4m
   - Instruments organized by type
   - Hover to highlight
   - Pinch to select

4. **Monitoring Displays** (Left, 1.5m away)
   - Vital signs (Heart rate, BP, O2)
   - Procedure timer
   - Performance metrics
   - AI coach suggestions

5. **Equipment Cart** (Far right)
   - Additional instruments
   - Suture materials
   - Cautery unit
   - Irrigation system

6. **AI Coach Overlay** (Top right field of view)
   - Translucent panel
   - Real-time feedback
   - Step-by-step guidance
   - Warning indicators

**Environment Settings**:
- **Wall Color**: Soft green (OR standard)
- **Floor**: Vinyl tile texture
- **Ceiling**: Drop ceiling with lights
- **Ambient Sound**: OR ambience (30dB)
- **Temperature Indicator**: Visual "cold" tint

### 4.2 Collaborative Surgical Theater

**Additional Elements**:

```
┌─────────────────────────────────────────┐
│                                         │
│  [Avatar 1]          [Avatar 2]         │
│  Instructor          Observer           │
│      │                   │              │
│      ▼                   ▼              │
│  ┌───────────────────────────┐          │
│  │    Shared Anatomy         │          │
│  │                           │          │
│  └───────────────────────────┘          │
│          │                               │
│          ● User                          │
│        Lead                              │
│                                         │
│  [Laser Pointer Mode]  [Voice Chat]     │
└─────────────────────────────────────────┘
```

**Collaborative Features**:
- **Avatars**: Simplified representations with name tags
- **Spatial Audio**: Voice positioned by avatar location
- **Laser Pointers**: Instructors can point to anatomy
- **Shared View**: All see same anatomical state
- **Role Indicators**: Color-coded outlines
- **Turn-Based Control**: One person operates at a time

---

## 5. 3D Visualization Specifications

### 5.1 Anatomical Model Rendering

**Visual Quality**:
- **Polygon Count**:
  - High Detail: 100K polygons
  - Medium Detail: 50K polygons
  - Low Detail: 20K polygons
- **Texture Resolution**: 4K diffuse maps
- **Material Properties**:
  - Subsurface scattering for tissue
  - Specular highlights for wet surfaces
  - Normal maps for fine detail
  - Roughness maps for realistic materials

**Tissue Appearance**:
```
Material Definitions:

Skin:
  - Albedo: Peachy-pink
  - Subsurface: Medium
  - Roughness: 0.4
  - Normal: Pores and fine lines

Muscle:
  - Albedo: Deep red
  - Subsurface: High
  - Roughness: 0.6
  - Specular: Low

Fat:
  - Albedo: Yellow-white
  - Subsurface: Very high
  - Roughness: 0.3
  - Translucency: Medium

Organs:
  - Albedo: Varies by organ
  - Subsurface: High
  - Wetness: High specular
  - Detail: Anatomical features

Blood:
  - Albedo: Dark red
  - Roughness: 0.1
  - Reflectivity: High
  - Viscosity: Animated flow
```

### 5.2 Surgical Instrument Rendering

**Instrument Materials**:
- **Stainless Steel**:
  - Metallic: 1.0
  - Roughness: 0.2
  - Reflections: Environment maps
- **Handles**:
  - Textured grip patterns
  - Slight roughness
- **Joints**:
  - Animated articulation
  - Realistic constraints

### 5.3 Lighting Design

**Primary Lighting**:
1. **Surgical Light** (Main)
   - Intensity: 800 lux
   - Color: Cool white (4500K)
   - Shadows: Soft, minimal
   - Coverage: 0.5m diameter

2. **Ambient OR Light**
   - Intensity: 300 lux
   - Color: Neutral (4000K)
   - Source: Ceiling panels
   - Shadows: None

3. **Accent Lights**
   - Monitor glow: Blue tint
   - Equipment LEDs: Various
   - Emergency exit: Red

**Dynamic Lighting**:
- Adjustable surgical light position
- Intensity controls
- Shadow quality settings
- Performance-based LOD

---

## 6. Interaction Patterns

### 6.1 Gaze and Pinch Gestures

**Gaze Interaction**:
```
State Diagram:

No Gaze → Gaze Dwell (100ms) → Hover State
                                     │
                                     ▼
                             Highlight Object
                                     │
                                     ▼
                    Pinch Gesture → Select/Activate
```

**Visual Feedback**:
- **Gaze Cursor**: Subtle dot (5pt diameter)
- **Hover State**:
  - Soft glow around object
  - Scale up 5%
  - Pulse animation
- **Selection**:
  - Bright highlight
  - Haptic click
  - Confirmation sound

### 6.2 Hand Tracking Gestures

**Primary Gestures**:

1. **Instrument Grip**
   - **Action**: Hold surgical instrument
   - **Gesture**: Pinch and hold
   - **Visual**: Instrument attached to hand
   - **Haptic**: Continuous light feedback

2. **Incision**
   - **Action**: Cut tissue
   - **Gesture**: Swipe with scalpel
   - **Visual**: Tissue separates along path
   - **Haptic**: Resistance based on tissue
   - **Audio**: Cutting sound

3. **Grasping**
   - **Action**: Hold tissue/organ
   - **Gesture**: Pinch tissue
   - **Visual**: Deformation around grip
   - **Haptic**: Squeeze resistance
   - **Audio**: Soft tissue sound

4. **Suturing**
   - **Action**: Stitch tissue
   - **Gesture**: Circular wrist motion
   - **Visual**: Needle path shown
   - **Haptic**: Penetration feedback
   - **Audio**: Needle through tissue

5. **Cauterization**
   - **Action**: Stop bleeding
   - **Gesture**: Point and hold
   - **Visual**: Smoke/charring effect
   - **Haptic**: Heat sensation (vibration)
   - **Audio**: Sizzling sound

**Advanced Gestures**:

6. **Two-Hand Manipulation**
   - **Action**: Retract and operate
   - **Gesture**: Both hands active
   - **Visual**: Coordinated movements
   - **Complexity**: High skill requirement

7. **Precise Placement**
   - **Action**: Accurate positioning
   - **Gesture**: Slow, controlled movement
   - **Visual**: Alignment guides
   - **Feedback**: Snap-to-grid (optional)

### 6.3 Voice Commands

**Supported Commands**:

| Command | Action |
|---------|--------|
| "Select [instrument]" | Change instrument |
| "Zoom in/out" | Adjust view scale |
| "Show [anatomy]" | Highlight structure |
| "Hide layers" | Toggle visibility |
| "Next step" | Advance procedure |
| "Repeat instructions" | AI coach repeats |
| "Pause procedure" | Freeze simulation |
| "Resume" | Continue procedure |
| "Cancel" | Exit procedure |

**Voice Feedback**:
- Visual indicator when listening
- Confirmation of command
- Error message if not understood
- Natural language processing for variations

---

## 7. Visual Design System

### 7.1 Color Palette

**Primary Colors** (Medical Theme):
```
Primary Blue (Trust/Medical)
├─ Primary: #0A7AFF
├─ Light:   #5AB3FF
└─ Dark:    #004D99

Success Green (Safety)
├─ Primary: #34C759
├─ Light:   #7FE89C
└─ Dark:    #1A7A35

Warning Yellow (Caution)
├─ Primary: #FFD60A
├─ Light:   #FFF066
└─ Dark:    #B39500

Danger Red (Alerts)
├─ Primary: #FF3B30
├─ Light:   #FF7670
└─ Dark:    #CC0000

Neutral Grays (UI)
├─ Gray 1:  #F2F2F7 (Backgrounds)
├─ Gray 2:  #E5E5EA (Borders)
├─ Gray 3:  #C7C7CC (Disabled)
├─ Gray 4:  #8E8E93 (Secondary text)
└─ Gray 5:  #3A3A3C (Primary text)
```

**Anatomical Color Coding**:
```
Anatomy Colors:
├─ Arteries:  #FF0000 (Bright red)
├─ Veins:     #0066CC (Blue)
├─ Nerves:    #FFD700 (Gold/yellow)
├─ Bones:     #F5F5DC (Beige/white)
├─ Muscles:   #8B0000 (Dark red)
├─ Fat:       #FFFACD (Pale yellow)
├─ Organs:    Varies by organ
└─ Pathology: #800080 (Purple highlights)
```

### 7.2 Typography

**Font System** (SF Pro Family):

```
Title Large
├─ Font: SF Pro Display Bold
├─ Size: 34pt
├─ Weight: Bold
└─ Use: Main headings

Title
├─ Font: SF Pro Display Semibold
├─ Size: 28pt
├─ Weight: Semibold
└─ Use: Section headings

Headline
├─ Font: SF Pro Display Semibold
├─ Size: 22pt
├─ Weight: Semibold
└─ Use: Card titles

Body
├─ Font: SF Pro Text Regular
├─ Size: 17pt
├─ Weight: Regular
└─ Use: Body text

Callout
├─ Font: SF Pro Text Regular
├─ Size: 16pt
├─ Weight: Regular
└─ Use: Annotations

Caption
├─ Font: SF Pro Text Regular
├─ Size: 12pt
├─ Weight: Regular
└─ Use: Labels, metadata
```

**3D Spatial Text**:
- **Billboard Mode**: Always face user
- **Depth**: Slight 3D extrusion (2pt)
- **Background**: Translucent pill shape
- **Contrast**: High contrast for readability
- **Distance Scaling**: Larger when farther

### 7.3 Materials and Glass Effects

**Glass Material (visionOS Standard)**:
```swift
.background(.regularMaterial) // Primary windows
.background(.thinMaterial)    // Overlays
.background(.ultraThinMaterial) // Subtle backgrounds
.background(.thickMaterial)   // Emphasis panels
```

**Vibrancy Effects**:
```swift
.foregroundStyle(.primary)     // High contrast text
.foregroundStyle(.secondary)   // Lower emphasis
.foregroundStyle(.tertiary)    // Least emphasis
```

**Custom Materials**:
- **Surgical Lights**: Emissive white material
- **Monitors**: Glowing screen material
- **Metal Instruments**: Metallic PBR materials
- **Tissue**: Subsurface scattering materials
- **Blood**: Translucent fluid material

### 7.4 Iconography in 3D Space

**Icon Style**:
- **SF Symbols**: Primary icon set
- **Size**: Minimum 44pt hit target
- **Depth**: Flat in windows, 3D in volumes
- **Color**: Monochrome or accent colors
- **Hover**: Scale and glow effects

**Custom Surgical Icons**:
```
Instrument Icons:
├─ Scalpel:   [Blade symbol]
├─ Forceps:   [Grasp symbol]
├─ Retractor: [Pull symbol]
├─ Suture:    [Needle/thread]
├─ Cautery:   [Lightning bolt]
└─ Sponge:    [Clean symbol]

Action Icons:
├─ Cut:       [Scissors]
├─ Grasp:     [Hand]
├─ Suture:    [Stitch]
├─ Irrigate:  [Water drop]
└─ Cauterize: [Flame]
```

---

## 8. User Flows and Navigation

### 8.1 Primary User Flow

```
App Launch
    │
    ▼
Dashboard (Window)
    │
    ├─→ Procedure Library → Select Procedure
    │                            │
    │                            ▼
    │                       Procedure Brief (Window)
    │                            │
    │                            ▼
    │                    Enter Surgical Theater (Immersive)
    │                            │
    │                            ├─→ Practice Procedure
    │                            │        │
    │                            │        ├─→ AI Coaching
    │                            │        ├─→ Error Correction
    │                            │        └─→ Completion
    │                            │             │
    │                            ▼             ▼
    │                    Performance Review (Window)
    │                            │
    │                            └─→ Return to Dashboard
    │
    ├─→ Anatomy Explorer (Volume)
    │        │
    │        └─→ Study Anatomy → Return
    │
    ├─→ Analytics (Window)
    │        │
    │        └─→ View Progress → Return
    │
    └─→ Settings (Window)
             │
             └─→ Configure → Return
```

### 8.2 Navigation Patterns

**Window Navigation**:
- **Tabs**: Main sections (Dashboard, Library, Analytics)
- **Back Button**: Standard top-left placement
- **Close**: Top-right corner or gesture
- **Deep Linking**: Jump to specific procedures

**Spatial Navigation**:
- **Gaze + Pinch**: Primary selection
- **Hand Tracking**: Direct manipulation
- **Voice**: "Go to [section]"
- **Breadcrumbs**: Show current location

**Immersive Space Navigation**:
- **Digital Crown**: Quick exit
- **Menu Button**: In-procedure menu
- **Gestures**: Minimal, focus on procedure
- **Voice**: "Pause", "Exit", "Help"

### 8.3 State Transitions

**Window ↔ Volume**:
- **Smooth fade**: 300ms transition
- **Maintain context**: Remember selections
- **Spatial anchoring**: Consistent positioning

**Window ↔ Immersive**:
- **Fade to black**: 500ms transition
- **Loading indicator**: During asset load
- **Environment build**: Gradual appearance
- **Audio transition**: Fade in OR ambience

---

## 9. Accessibility Design

### 9.1 VoiceOver Support

**Spatial Audio Cues**:
- **Element Position**: Audio indicates location
- **Depth Cues**: Volume and reverb for distance
- **Haptic Feedback**: Confirms selections
- **Descriptive Labels**: All elements labeled

**Example Labels**:
```
Scalpel Button:
├─ Label: "Scalpel"
├─ Hint: "Select scalpel for incision. Requires precise cutting motion."
├─ Value: "Not selected"
└─ Traits: Button, Interactive

Anatomy Model:
├─ Label: "Heart anatomy model"
├─ Hint: "Pinch and drag to rotate. Double tap to reset view."
├─ Value: "Rotated 45 degrees"
└─ Traits: Interactive, Rotatable
```

### 9.2 Visual Accessibility

**High Contrast Mode**:
- Increased border thickness (2pt → 4pt)
- Stronger color saturation
- Reduced transparency
- Enhanced text outlines

**Reduced Transparency**:
- Replace glass materials with opaque
- Maintain visual hierarchy with borders
- Increase contrast ratios to 7:1

**Color Blind Modes**:
- **Protanopia**: Red-blind friendly
- **Deuteranopia**: Green-blind friendly
- **Tritanopia**: Blue-blind friendly
- **Pattern Overlays**: Add textures to colors

### 9.3 Motor Accessibility

**Larger Hit Targets**:
- Minimum: 60pt (vs standard 44pt)
- Spacing: 16pt minimum between targets
- Dwell Time Selection: Hold gaze to select

**Simplified Gestures**:
- Single tap instead of double tap
- Longer hold times (800ms vs 500ms)
- Reduced precision requirements
- Alternative control methods

---

## 10. Error States and Loading Indicators

### 10.1 Loading States

**Model Loading**:
```
┌─────────────────────┐
│                     │
│    ⟳ Loading...     │
│                     │
│  Anatomy Model      │
│                     │
│  ▓▓▓▓▓▓▓▓░░░░       │
│  65% Complete       │
│                     │
└─────────────────────┘
```

**Specifications**:
- **Spinner**: Smooth rotation, 2s period
- **Progress Bar**: Determinate when possible
- **Message**: Clear status text
- **Cancellation**: Allow user to cancel

**Streaming Assets**:
- Show low-poly model immediately
- Stream high-res textures progressively
- Indicate loading with subtle shimmer

### 10.2 Error States

**Network Error**:
```
┌─────────────────────────┐
│    ⚠️  Network Error     │
│                         │
│  Could not connect to   │
│  surgical training      │
│  server.                │
│                         │
│  [Try Again] [Offline]  │
└─────────────────────────┘
```

**Asset Loading Error**:
```
┌─────────────────────────┐
│    ⚠️  Loading Failed    │
│                         │
│  Unable to load         │
│  anatomy model.         │
│                         │
│  [Retry] [Report Issue] │
└─────────────────────────┘
```

**Procedure Error**:
```
┌─────────────────────────┐
│    ⚠️  Critical Error    │
│                         │
│  Excessive bleeding     │
│  detected.              │
│                         │
│  [Correct] [Restart]    │
└─────────────────────────┘
```

### 10.3 Empty States

**No Sessions**:
```
┌─────────────────────────┐
│                         │
│    📚 No Sessions Yet    │
│                         │
│  Start your first       │
│  surgical procedure to  │
│  begin training.        │
│                         │
│  [Browse Procedures]    │
└─────────────────────────┘
```

**No Network (Offline)**:
```
┌─────────────────────────┐
│    📶 Offline Mode       │
│                         │
│  You can still practice │
│  procedures. Data will  │
│  sync when connected.   │
│                         │
│  [Continue]             │
└─────────────────────────┘
```

---

## 11. Animation and Transition Specifications

### 11.1 UI Animations

**Window Animations**:
```swift
// Appear
.transition(.opacity.combined(with: .scale))
.animation(.smooth(duration: 0.3), value: isShowing)

// Dismiss
.transition(.opacity.combined(with: .move(edge: .bottom)))
.animation(.easeInOut(duration: 0.25), value: isDismissed)
```

**Timing Functions**:
- **Ease In Out**: Standard transitions (0.3s)
- **Spring**: Interactive elements (response: 0.3, damping: 0.7)
- **Linear**: Progress indicators
- **Ease Out**: Appearing elements
- **Ease In**: Disappearing elements

### 11.2 3D Animations

**Anatomical Transitions**:
- **Fade In/Out**: 0.5s smooth fade
- **Rotation**: Smooth 0.8s easeInOut
- **Scale**: Spring animation (0.4s)
- **Position**: Ease curve (0.6s)

**Surgical Actions**:
- **Cut Animation**:
  - Duration: Matches gesture speed
  - Effect: Tissue separation with slight gap
  - Blood: Appears along cut line (0.2s delay)

- **Suture Animation**:
  - Duration: 1.0s per stitch
  - Effect: Tissue pulls together
  - Thread: Bezier curve following needle

- **Cautery Animation**:
  - Duration: Continuous while active
  - Effect: Smoke particles (2s lifetime)
  - Color: Tissue darkening (0.5s)

### 11.3 Micro-interactions

**Button Hover**:
- Scale: 1.0 → 1.05 (0.2s spring)
- Glow: Fade in (0.15s)
- Haptic: Light tap on hover

**Selection**:
- Scale: 1.0 → 1.08 → 1.05 (0.3s bounce)
- Glow: Bright pulse (0.2s)
- Haptic: Medium click
- Audio: Confirmation chime

**Drag**:
- Lift: Scale 1.05, shadow (0.2s)
- Follow: Hand position (no lag)
- Drop: Scale 1.0, settle (0.3s spring)

---

## 12. Responsive Design

### 12.1 Distance-Based Scaling

```
UI Scaling by Distance:

Close (0.5m):
├─ Text: 100% size
├─ Buttons: Standard 44pt
└─ Detail: High

Medium (1.0m):
├─ Text: 120% size
├─ Buttons: 52pt
└─ Detail: Medium

Far (2.0m):
├─ Text: 150% size
├─ Buttons: 66pt
└─ Detail: Low

Very Far (3.0m+):
├─ Text: 200% size
├─ Buttons: 88pt
└─ Detail: Minimal
```

### 12.2 Adaptive Layouts

**Window Size Adaptation**:
- **Small** (<600pt): Single column
- **Medium** (600-1000pt): Two columns
- **Large** (>1000pt): Three columns + sidebar

**Content Density**:
- **Compact**: More information, smaller spacing
- **Regular**: Standard spacing
- **Spacious**: Generous whitespace

---

## 13. Brand & Visual Identity

### 13.1 App Icon

**Design**:
- **Shape**: Rounded square (visionOS standard)
- **Symbol**: Stylized surgical scalpel + heart outline
- **Colors**: Medical blue gradient
- **Depth**: Layered 3D effect
- **Background**: Clean white or subtle gradient

### 13.2 Loading Screen

```
┌─────────────────────────┐
│                         │
│                         │
│    [App Icon]           │
│                         │
│  Surgical Training      │
│      Universe           │
│                         │
│    ⟳ Loading...         │
│                         │
└─────────────────────────┘
```

### 13.3 Sound Design

**UI Sounds**:
- **Button Tap**: Soft click (50ms)
- **Success**: Ascending chime (200ms)
- **Error**: Descending tone (150ms)
- **Notification**: Gentle ping (100ms)

**Surgical Sounds**:
- **Scalpel Cut**: Tissue separation (varies)
- **Forceps Grasp**: Metal click (80ms)
- **Suture**: Thread pull (120ms)
- **Cautery**: Sizzle (continuous)
- **Monitor Beep**: Heart rate (800ms interval)

**Ambient Sounds**:
- **OR Ambience**: Ventilation (continuous, 30dB)
- **Monitor**: Rhythmic beeping (40dB)
- **Equipment**: Subtle hums (25dB)

---

## 14. Design Specifications Summary

### 14.1 Key Metrics

| Element | Specification |
|---------|---------------|
| **Minimum Hit Target** | 60pt (accessible), 44pt (standard) |
| **Text Contrast** | 4.5:1 minimum, 7:1 preferred |
| **Animation Duration** | 0.2s - 0.5s (most UI) |
| **Glass Opacity** | 10-30% depending on context |
| **Corner Radius** | 20pt windows, 12pt buttons |
| **Spacing Unit** | 8pt base grid |
| **Max Text Width** | 600pt for readability |

### 14.2 Design Tokens

```swift
// Spacing
enum Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

// Corner Radius
enum CornerRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 20
    static let full: CGFloat = 999
}

// Shadows
enum Shadow {
    static let sm = ShadowStyle(radius: 4, offset: 2)
    static let md = ShadowStyle(radius: 8, offset: 4)
    static let lg = ShadowStyle(radius: 16, offset: 8)
}
```

---

## Conclusion

This design specification provides comprehensive guidance for creating an intuitive, accessible, and visually stunning surgical training experience in visionOS. The design prioritizes:

- **Clinical Realism**: Authentic OR environment and instruments
- **Ergonomic Comfort**: Optimal spatial positioning
- **Intuitive Interactions**: Natural surgical gestures
- **Accessibility**: Inclusive design for all users
- **Visual Excellence**: Beautiful, professional aesthetics

All design decisions support the primary goal: enabling surgeons to achieve mastery through immersive, realistic training.
