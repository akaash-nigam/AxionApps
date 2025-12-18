# Corporate University Platform - Design Specifications

## Document Overview
**Version**: 1.0
**Last Updated**: 2025-01-20
**Status**: Draft
**Platform**: visionOS 2.0+

## Table of Contents
1. [Spatial Design Principles](#spatial-design-principles)
2. [Window Layouts and Configurations](#window-layouts-and-configurations)
3. [Volume Designs](#volume-designs)
4. [Full Space / Immersive Experiences](#full-space--immersive-experiences)
5. [3D Visualization Specifications](#3d-visualization-specifications)
6. [Interaction Patterns](#interaction-patterns)
7. [Visual Design System](#visual-design-system)
8. [User Flows and Navigation](#user-flows-and-navigation)
9. [Accessibility Design](#accessibility-design)
10. [Error States and Loading Indicators](#error-states-and-loading-indicators)
11. [Animation and Transition Specifications](#animation-and-transition-specifications)

---

## 1. Spatial Design Principles

### Core Spatial Principles

#### 1.1 Ergonomic Positioning

**Vertical Placement**:
- **Primary Content**: 10-15° below eye level
- **Secondary Content**: Up to 30° below eye level
- **Peripheral Content**: Up to 45° to sides
- **Ceiling Content**: Avoid above 10° (neck strain)

```
Eye Level Reference (0°)
        ┌─────────────────────┐
        │                     │
  -10°  │  Primary Actions    │ Dashboard, Buttons
        │                     │
  -15°  │  Main Content       │ Course Cards, Videos
        │                     │
  -25°  │  Detail Info        │ Descriptions, Stats
        │                     │
  -30°  │  Secondary Content  │ Additional Info
        └─────────────────────┘
```

**Horizontal Placement**:
- **Comfortable Zone**: ±60° from center
- **Extended Zone**: ±90° (neck turn required)
- **Critical Info**: Within ±30° of center

**Depth Placement**:
- **Comfortable Range**: 0.5m - 3m
- **Reading Distance**: 0.6m - 1.2m
- **Interactive Objects**: 0.5m - 2m
- **Background Elements**: 3m - 10m

#### 1.2 Spatial Hierarchy

**Z-Axis Depth Layers**:
```
User ← 0m
├── 0.5m: Interactive Controls (buttons, inputs)
├── 1.0m: Primary Content (course cards, lessons)
├── 2.0m: Secondary Content (details, info panels)
├── 3.0m: Context Content (navigation, breadcrumbs)
└── 5-10m: Background/Ambient (environments, decorative)
```

**Size and Scale Relationships**:
- **Foreground** (0.5-1m): Smaller elements (buttons 60-100pt)
- **Midground** (1-2m): Medium elements (cards 200-400pt)
- **Background** (2m+): Large elements (environments, decorative)

#### 1.3 Progressive Disclosure

**Spatial Expansion Pattern**:
1. **Entry**: Start with minimal window (dashboard)
2. **Exploration**: Add volumes for 3D visualization
3. **Immersion**: Transition to full environment
4. **Focus**: Collapse back to essential information

```
Dashboard Window → Skill Tree Volume → Practice Environment → Assessment Focus
     (2D)              (3D Bounded)         (Full Immersive)       (Hybrid)
```

#### 1.4 Attention Management

**Focus Techniques**:
- **Glow/Highlight**: Draw attention without disrupting
- **Subtle Animation**: Gentle pulse or float
- **Spatial Audio**: Directional sound cues
- **Depth of Field**: Blur non-critical elements
- **Scale**: Enlarge important elements slightly

**Distraction Prevention**:
- Avoid auto-playing videos in periphery
- Use subtle environmental motion
- Limit simultaneous animations to 2-3
- Provide "focus mode" for assessments

#### 1.5 Spatial Comfort

**Comfort Guidelines**:
- ✅ Avoid rapid perspective changes
- ✅ Provide stable reference points
- ✅ Use smooth, predictable transitions
- ✅ Allow user-controlled movement speed
- ✅ Provide "rest" views (minimal motion)
- ✅ Offer exit from immersion anytime

**Motion Sensitivity**:
- **Low Motion Mode**: Reduce animations, use fades
- **Teleportation**: Alternative to smooth locomotion
- **Static Backgrounds**: Option for sensitive users

---

## 2. Window Layouts and Configurations

### 2.1 Dashboard Window

**Primary Learning Hub**

**Specifications**:
- **Size**: 1200 × 800 pt (default), resizable 800-2000 width
- **Style**: Plain glass material
- **Position**: Center, 1.5m from user
- **Resizability**: Content-adaptive

**Layout Structure**:
```
┌─────────────────────────────────────────────────────────┐
│  ← Dashboard                    🔍 Search      Profile ⚙  │ Toolbar (60pt)
├─────────────────────────────────────────────────────────┤
│                                                           │
│  Welcome back, [Name]                                     │
│                                                           │
│  ┌───────────┐ ┌───────────┐ ┌───────────┐              │
│  │           │ │           │ │           │              │
│  │  Course   │ │  Course   │ │  Course   │              │ In Progress
│  │  Card 1   │ │  Card 2   │ │  Card 3   │              │ (200pt)
│  │           │ │           │ │           │              │
│  └───────────┘ └───────────┘ └───────────┘              │
│                                                           │
│  Your Learning Path                    View All →        │
│  ┌────────────────────────────────────────────┐          │
│  │  ▸ Module 1: Introduction        [███████░░] 70%      │
│  │  ▸ Module 2: Advanced Topics     [██░░░░░░░] 20%      │ Progress Section
│  │  ▸ Module 3: Practice            [░░░░░░░░░] 0%       │ (300pt)
│  └────────────────────────────────────────────┘          │
│                                                           │
│  Recommended for You                                      │
│  ┌───────────┐ ┌───────────┐ ┌───────────┐              │
│  │  Course   │ │  Course   │ │  Course   │              │ Recommendations
│  │  Card 4   │ │  Card 5   │ │  Card 6   │              │ (200pt)
│  └───────────┘ └───────────┘ └───────────┘              │
│                                                           │
└─────────────────────────────────────────────────────────┘
```

**Ornaments**:
- **Top**: Search bar, notifications, profile menu
- **Bottom**: Navigation tabs (optional)
- **Leading**: Quick actions sidebar (optional)

**Components**:
```swift
struct DashboardView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                WelcomeHeader()
                InProgressCoursesSection()
                LearningPathSection()
                RecommendationsSection()
            }
            .padding()
        }
        .frame(minWidth: 800, minHeight: 600)
        .glassBackgroundEffect()
    }
}
```

### 2.2 Course Browser Window

**Specifications**:
- **Size**: 1000 × 700 pt
- **Style**: Plain glass with blur
- **Multiple Instances**: Yes (compare courses)

**Layout**:
```
┌─────────────────────────────────────────────┐
│  Courses               Filters ▼  Sort ▼     │
├──────────┬──────────────────────────────────┤
│          │                                   │
│  Filters │  ┌─────┐ ┌─────┐ ┌─────┐        │
│          │  │     │ │     │ │     │        │
│  □ All   │  │ C 1 │ │ C 2 │ │ C 3 │        │
│  ☑ Tech  │  │     │ │     │ │     │        │
│  □ Lead  │  └─────┘ └─────┘ └─────┘        │
│  □ Sales │                                   │
│          │  ┌─────┐ ┌─────┐ ┌─────┐        │
│  Level   │  │ C 4 │ │ C 5 │ │ C 6 │        │
│  ⚫─────○ │  └─────┘ └─────┘ └─────┘        │
│          │                                   │
└──────────┴──────────────────────────────────┘
```

### 2.3 Course Detail Window

**Specifications**:
- **Size**: 1200 × 900 pt
- **Style**: Volumetric preview option
- **Resizability**: Yes

**Layout**:
```
┌───────────────────────────────────────────────────────┐
│  ← Back to Courses                                     │
├───────────────────────────────────────────────────────┤
│  ┌──────────────────┐                                  │
│  │                  │  Course Title                    │
│  │   Thumbnail /    │  by Instructor Name              │
│  │   3D Preview     │                                  │
│  │                  │  ⭐⭐⭐⭐⭐ 4.8 (1,234 reviews)   │
│  └──────────────────┘                                  │
│                       ⏱ 12 hours | 📊 Intermediate    │
│  [  Enroll Now  ] [  Preview  ] [  Save  ]            │
│                                                        │
│  ┌─ Overview ─┬─ Syllabus ─┬─ Reviews ─┬─ Resources ┐│
│  │                                                     ││
│  │  Course Description...                             ││
│  │                                                     ││
│  │  What You'll Learn:                                ││
│  │  • Skill 1                                         ││
│  │  • Skill 2                                         ││
│  │  • Skill 3                                         ││
│  │                                                     ││
│  └─────────────────────────────────────────────────────┘│
└───────────────────────────────────────────────────────┘
```

### 2.4 Learning Window (Active Lesson)

**Specifications**:
- **Size**: 1400 × 900 pt
- **Style**: Focused, minimal distractions
- **Position**: Front and center

**Layout**:
```
┌───────────────────────────────────────────────────────┐
│  Module 2: Advanced Topics  |  Lesson 3 of 12  [◼] [×]│
├───────────────────────────────────────────────────────┤
│                                                        │
│                                                        │
│               Main Content Area                        │
│          (Video / 3D Model / Text)                     │
│                                                        │
│                                                        │
├───────────────────────────────────────────────────────┤
│  [◀ Previous]              [▶ Next]       [✓ Complete]│
└───────────────────────────────────────────────────────┘

Floating Ornaments:
- Left: Table of Contents
- Right: AI Tutor Chat
- Bottom: Progress Bar
```

### 2.5 Analytics Window

**Specifications**:
- **Size**: 1400 × 900 pt
- **Style**: Volumetric charts option
- **Data Visualization Focus**

**Layout**:
```
┌───────────────────────────────────────────────────────┐
│  Analytics Dashboard                    [2D] [3D]      │
├───────────────────────────────────────────────────────┤
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐  │
│  │   Progress   │ │ Time Spent   │ │ Completion   │  │
│  │     75%      │ │  24 hours    │ │     12/15    │  │
│  └──────────────┘ └──────────────┘ └──────────────┘  │
│                                                        │
│  Learning Trends                                       │
│  ┌────────────────────────────────────────────────┐   │
│  │        📊 Chart / Graph                        │   │
│  │                                                │   │
│  └────────────────────────────────────────────────┘   │
│                                                        │
│  Skills Acquired                                       │
│  ┌────────────────────────────────────────────────┐   │
│  │  [==========] Python           Expert          │   │
│  │  [========  ] Leadership       Advanced        │   │
│  │  [=====     ] Public Speaking  Intermediate    │   │
│  └────────────────────────────────────────────────┘   │
└───────────────────────────────────────────────────────┘
```

---

## 3. Volume Designs

### 3.1 Skill Tree Volume

**Spatial 3D Knowledge Map**

**Specifications**:
- **Size**: 1.2m × 1.2m × 1.0m
- **Style**: Volumetric, interactive
- **Interaction**: Direct manipulation with hands

**Visual Design**:
```
       ┌─────────┐
       │ Advanced│ ← Top Level (Locked)
       └────┬────┘
            │
       ┌────┴────┐
       │         │
   ┌───┴──┐  ┌──┴───┐
   │Inter-│  │Inter-│ ← Middle Level (In Progress)
   │med 1 │  │med 2 │
   └───┬──┘  └──┬───┘
       │        │
   ┌───┴────────┴───┐
   │                 │
 ┌─┴─┐  ┌─┴─┐  ┌─┴─┐
 │B 1│  │B 2│  │B 3│ ← Base Level (Completed)
 └───┘  └───┘  └───┘
```

**Node States**:
- **Completed**: ✓ Green glow, solid connection
- **In Progress**: ⟳ Blue pulse, animated connection
- **Locked**: 🔒 Gray, dashed connection
- **Available**: ○ White, ready to start

**Interactions**:
- **Tap Node**: View details
- **Pull Node**: Bring to focus
- **Pinch & Expand**: Zoom into sub-skills
- **Rotate**: View from different angles

**Component Specs**:
```swift
struct SkillTreeVolume: View {
    var body: some View {
        RealityView { content in
            let skillTree = createSkillTreeEntity()
            content.add(skillTree)
        }
        .gesture(
            RotateGesture3D()
                .onChanged { value in
                    rotateSkillTree(value.rotation)
                }
        )
    }
}
```

### 3.2 Progress Globe Volume

**3D Progress Visualization**

**Specifications**:
- **Size**: 0.8m × 0.8m × 0.8m (sphere)
- **Style**: Rotating globe
- **Animation**: Continuous slow rotation

**Visual Design**:
```
        ╱───────────────╲
       ╱  📊 Analytics   ╲
      │   ────────────    │
      │   75% Complete    │  ← Rotating display
      │                   │     of stats
       ╲   12 of 16      ╱
        ╲───────────────╱

Color-coded regions:
- Green: Completed areas
- Blue: In progress
- Gray: Not started
```

**Elements**:
- **Surface Texture**: Progress heatmap
- **Floating Labels**: Course names
- **Particle Effects**: Achievement sparks
- **Audio**: Ambient progress sounds

### 3.3 Knowledge Map Volume

**Concept Network Visualization**

**Specifications**:
- **Size**: 1.5m × 1.0m × 1.0m
- **Style**: Interactive network graph
- **Complexity**: Up to 100 nodes

**Visual Design**:
```
         Node connections in 3D space:

    ○────○────○
    │    │    │
    │    ○    ○────○
    │         │
    ○────○────○
         │
    ○────○────○

Concept nodes: ○
Connections: ────
Clustered by topic with depth
```

**Interaction**:
- **Gaze at Node**: Highlight related concepts
- **Tap Node**: View concept details
- **Pull Connection**: See relationship strength
- **Pinch to Zoom**: Navigate hierarchy

### 3.4 Assessment Arena Volume

**Interactive Quiz Space**

**Specifications**:
- **Size**: 1.0m × 0.8m × 1.0m
- **Style**: Game-like environment
- **Purpose**: Spatial quiz interaction

**Visual Design**:
```
Question displayed in center:
┌───────────────────────┐
│  What is...?          │
└───────────────────────┘
          │
    ┌─────┼─────┐
    │     │     │
  ┌─┴─┐ ┌─┴─┐ ┌─┴─┐
  │ A │ │ B │ │ C │  ← Answer options
  └───┘ └───┘ └───┘     floating in 3D

Grab correct answer and place in target
```

**Feedback**:
- **Correct**: Green explosion, success sound
- **Incorrect**: Red shake, gentle buzz
- **Partial**: Yellow glow, encouraging sound

---

## 4. Full Space / Immersive Experiences

### 4.1 Virtual Classroom

**Collaborative Learning Environment**

**Environment Specs**:
- **Type**: Progressive immersion
- **Size**: 10m × 4m × 8m
- **Capacity**: 30 learners
- **Passthrough**: 0-100% adjustable

**Layout**:
```
Side View:
                 Ceiling (4m)
    ┌────────────────────────────────┐
    │        Presentation Area       │
    │  ┌──────┐                      │
    │  │Screen│                      │
    │  └──────┘                      │
    │    👤 Instructor               │
    │                                │
    │  👤 👤 👤   Student Seating    │
    │  👤 👤 👤   (Desks/Chairs)     │
    │  👤 👤 👤                       │
    └────────────────────────────────┘
           Floor (0m)

Top View:
    ┌────────────────┐
    │   [Screen]     │
    │      👤        │ Instructor
    │                │
    │  👤  👤  👤   │
    │  👤  👤  👤   │ Students (3×3)
    │  👤  👤  👤   │
    │                │
    │  [Whiteboard]  │
    └────────────────┘
```

**Features**:
- **Whiteboard**: Shared drawing surface
- **Presentation Screen**: Video/slides
- **Avatars**: Simplified learner representations
- **Spatial Audio**: Voice positioned by seat
- **Hand Raise**: Gesture to ask questions
- **Breakout Spaces**: Small group areas

**Immersion Levels**:
- **0%**: Classroom overlaid on real room
- **50%**: Blend of real and virtual
- **100%**: Fully immersive classroom

### 4.2 Manufacturing Floor

**Equipment Training Simulation**

**Environment Specs**:
- **Type**: Full immersion
- **Size**: 20m × 5m × 15m
- **Realism**: Photorealistic equipment
- **Safety**: Virtual-only practice

**Layout**:
```
    Equipment Stations:
    ┌────────┐  ┌────────┐  ┌────────┐
    │Station │  │Station │  │Station │
    │   1    │  │   2    │  │   3    │
    │ [====] │  │ [====] │  │ [====] │
    └────────┘  └────────┘  └────────┘
         │           │           │
         └───────────┴───────────┘
              Work Area

    Safety Zones marked in green
    Danger Zones marked in red
    Tool Storage along walls
```

**Interactive Elements**:
- **Equipment**: Full-scale 3D models
- **Tools**: Grabbable, realistic physics
- **Control Panels**: Interactive buttons/levers
- **Indicators**: Real-time feedback (pressure, temperature)
- **Safety Gear**: Virtual PPE (hard hat, gloves)

**Training Features**:
- **Step-by-Step Guides**: AR overlays
- **Error Prevention**: Block dangerous actions
- **Mistake Recovery**: Undo and retry
- **Performance Metrics**: Track accuracy, speed
- **AI Instructor**: Voice guidance

### 4.3 Executive Boardroom

**Leadership Training**

**Environment Specs**:
- **Type**: Mixed immersion
- **Size**: 8m × 3m × 6m
- **Purpose**: Presentation practice
- **Real-World Blend**: Yes

**Layout**:
```
    ┌────────────────────────────┐
    │      [Presentation]        │
    │                            │
    │    ┌──────────────┐        │
    │    │  Conference  │        │
    │    │    Table     │        │
    │   👤👤        👤👤   │
    │   👤👤        👤👤   │ AI Executives
    │                            │
    │         👤 You             │
    └────────────────────────────┘
```

**Scenarios**:
- **Pitch Practice**: Present to AI board members
- **Q&A Simulation**: Handle tough questions
- **Body Language**: Feedback on presence
- **Slide Control**: Gesture-based advancement
- **Confidence Building**: Adjustable difficulty

**AI Reactions**:
- **Engaged**: Nodding, attentive posture
- **Confused**: Puzzled expressions, questions
- **Impressed**: Smiles, note-taking
- **Skeptical**: Crossed arms, frowns

### 4.4 Innovation Lab

**Creative Problem-Solving Space**

**Environment Specs**:
- **Type**: Progressive immersion
- **Size**: 12m × 4m × 10m
- **Purpose**: Brainstorming and prototyping
- **Collaboration**: Multi-user

**Layout**:
```
    Workbenches around perimeter:
    ┌─[Bench]─────────────[Bench]─┐
    │                              │
    │         Center               │
    │         Space                │ Open collaboration
    │    (Floating Ideas)          │ area
    │                              │
    └─[Bench]─────────────[Bench]─┘

    3D Printer      Tools      Materials
```

**Features**:
- **Idea Board**: Floating sticky notes
- **3D Sketching**: Draw objects in space
- **Physics Sandbox**: Test concepts
- **Material Library**: Virtual materials
- **Team Presence**: See colleagues' avatars

### 4.5 Outdoor Training Area

**Team Building & Physical Training**

**Environment Specs**:
- **Type**: Full immersion
- **Size**: 50m × 5m × 50m
- **Terrain**: Natural environment
- **Weather**: Dynamic (sunny, rainy, etc.)

**Layout**:
```
    Large open space with:
    - Obstacle course
    - Team challenge stations
    - Nature trails
    - Meeting areas
    - Rest zones
```

**Activities**:
- **Trust Exercises**: Virtual team building
- **Problem Solving**: Physical challenges
- **Communication**: Coordination tasks
- **Leadership**: Role rotation
- **Reflection**: Quiet spaces for discussion

---

## 5. 3D Visualization Specifications

### 5.1 Data Visualization in 3D

**Chart Types**:

1. **3D Bar Chart**
   - **Use**: Progress comparison
   - **Interaction**: Tap bar for details
   - **Animation**: Grow from base

2. **Skill Radar** (3D Spider Chart)
   - **Use**: Skill assessment
   - **Interaction**: Rotate to view all axes
   - **Color**: Gradient based on proficiency

3. **Progress Ribbon**
   - **Use**: Timeline visualization
   - **Interaction**: Scroll through time
   - **Animation**: Flowing ribbon

4. **Achievement Constellation**
   - **Use**: Badges and certificates
   - **Interaction**: Fly through stars
   - **Effect**: Sparkle on new achievement

### 5.2 3D Models

**Asset Specifications**:
- **Format**: USDZ
- **Polygon Count**: 10,000 - 50,000 (LOD-based)
- **Texture Resolution**: 2048×2048 (high), 1024×1024 (medium), 512×512 (low)
- **Materials**: PBR (Metallic-Roughness)
- **Animation**: Skeletal (if applicable)

**Model Categories**:
1. **Equipment Models** (Manufacturing)
   - High detail for close interaction
   - Realistic materials and lighting
   - Interactive components

2. **Avatar Models** (Collaboration)
   - Simplified humanoid
   - Facial expressions (limited)
   - Hand gestures

3. **Environment Assets** (Scenes)
   - Modular pieces
   - LOD levels (3 minimum)
   - Optimized for performance

4. **UI Elements** (3D Buttons)
   - Simple geometry
   - Clear affordances
   - Responsive to interaction

### 5.3 Particle Effects

**Effect Types**:

1. **Achievement Celebration**
   - **Particles**: Gold stars, confetti
   - **Duration**: 2-3 seconds
   - **Trigger**: Course completion, milestone

2. **Progress Indicator**
   - **Particles**: Blue sparkles
   - **Duration**: Continuous (subtle)
   - **Trigger**: Active learning

3. **Error Feedback**
   - **Particles**: Red warning symbols
   - **Duration**: 1 second
   - **Trigger**: Incorrect answer

4. **Ambient Environment**
   - **Particles**: Dust motes, floating papers
   - **Duration**: Continuous (very subtle)
   - **Purpose**: Atmosphere

**Performance Specs**:
- **Max Particles**: 1,000 concurrent
- **Update Rate**: 30 FPS
- **GPU Usage**: < 5%

---

## 6. Interaction Patterns

### 6.1 Gaze and Pinch Gestures

**Gaze Targeting**:
```
User's gaze → [Target Element]
              └─ Highlight (300ms dwell)
                 └─ Pinch to activate
```

**Visual Feedback**:
- **Hover State** (Gaze):
  - Subtle scale: 1.0 → 1.05
  - Glow: 0 → 20% white
  - Audio: Soft hover sound (optional)

- **Active State** (Pinch):
  - Scale: 1.05 → 0.98 (press)
  - Glow: 20% → 50% (bright)
  - Audio: Click sound
  - Haptic: Light impact

**Interaction Specs**:
```swift
Button("Enroll") {
    enrollAction()
}
.hoverEffect(.highlight)
.onTapGesture {
    // Pinch recognized
    performAction()
}
```

### 6.2 Hand Tracking Gestures

**Standard Gestures**:

1. **Grab & Move**
   - **Recognition**: Closed fist
   - **Action**: Pick up object
   - **Visual**: Object follows hand
   - **Release**: Open hand

2. **Two-Hand Scale**
   - **Recognition**: Two pinch gestures
   - **Action**: Scale object between hands
   - **Visual**: Size indicator
   - **Range**: 0.1x - 5.0x

3. **Rotate**
   - **Recognition**: Circular wrist motion
   - **Action**: Rotate object
   - **Visual**: Rotation handles
   - **Constraint**: All axes or locked

4. **Push/Pull**
   - **Recognition**: Forward/backward palm
   - **Action**: Move object in Z-axis
   - **Visual**: Distance indicator
   - **Range**: 0.5m - 2m

**Custom Learning Gestures**:

1. **Raise Hand** (Ask Question)
   ```
   Hand above head (1s hold)
   → Visual: Hand icon appears
   → Action: Notify instructor/AI
   → Feedback: "Question received"
   ```

2. **Thumbs Up** (Understand)
   ```
   Thumb extended upward
   → Visual: Checkmark appears
   → Action: Log understanding
   → Feedback: Progress updated
   ```

3. **Wave** (Need Help)
   ```
   Side-to-side motion (2-3 waves)
   → Visual: Help icon
   → Action: Request assistance
   → Feedback: "Help is on the way"
   ```

4. **Pinch & Pull** (Deep Dive)
   ```
   Pinch concept + pull toward self
   → Visual: Concept expands
   → Action: Show detailed info
   → Feedback: Detail panel opens
   ```

### 6.3 Voice Commands

**Supported Commands**:

| Command | Action | Feedback |
|---------|--------|----------|
| "Next lesson" | Advance to next | "Loading [lesson name]" |
| "Repeat" | Replay content | "Replaying..." |
| "Help" | Summon AI tutor | AI tutor appears |
| "Pause" | Pause playback | Pause icon |
| "Bookmark this" | Save current point | "Bookmarked" |
| "Show progress" | Display stats | Progress window opens |
| "Exit immersion" | Return to windows | Fade transition |

**Voice Command UI**:
```
🎤 Listening...
┌──────────────────┐
│ "Next lesson"    │ ← Transcription
└──────────────────┘
✓ Command recognized
```

### 6.4 Interaction Hierarchy

**Priority Order** (when multiple inputs conflict):
1. **Direct Touch** (highest priority)
2. **Hand Gesture**
3. **Gaze + Pinch**
4. **Voice Command**
5. **Automatic** (lowest priority)

**Example**:
- If user is touching button AND saying "Next", touch takes priority

---

## 7. Visual Design System

### 7.1 Color Palette

**Primary Colors** (Glass-Optimized):
```
Learning Blue:    #0A84FF (Primary actions, progress)
Success Green:    #30D158 (Completions, correct)
Warning Yellow:   #FFD60A (Attention, help)
Error Red:        #FF453A (Errors, incorrect)
```

**Neutral Colors**:
```
Background:       Adaptive glass (system)
Text Primary:     #FFFFFF (light mode) / #000000 (dark mode)
Text Secondary:   70% opacity
Text Tertiary:    50% opacity
Dividers:         20% opacity
```

**Accent Colors** (Category-Based):
```
Technology:       #5E5CE6 (Purple)
Leadership:       #FF9F0A (Orange)
Sales:            #FF375F (Pink)
Operations:       #32ADE6 (Cyan)
Compliance:       #BF5AF2 (Magenta)
```

**Semantic Colors**:
```
Locked Content:   #8E8E93 (Gray)
In Progress:      #0A84FF (Blue) with pulse
Completed:        #30D158 (Green) with glow
Featured:         Linear gradient (Blue → Purple)
```

**Glass Material Colors**:
```
Primary Glass:    Adaptive (vibrancy enabled)
Secondary Glass:  80% opacity
Accent Glass:     Tinted with primary color (10%)
```

### 7.2 Typography

**Type Scale** (Spatial-Optimized):
```
Display:   48pt / 52pt line height  (Page titles)
Title 1:   34pt / 40pt line height  (Section headers)
Title 2:   28pt / 34pt line height  (Card titles)
Title 3:   22pt / 28pt line height  (List headers)
Headline:  17pt / 22pt line height  (Emphasis)
Body:      17pt / 22pt line height  (Body text)
Callout:   16pt / 21pt line height  (Secondary)
Subhead:   15pt / 20pt line height  (Labels)
Footnote:  13pt / 18pt line height  (Captions)
Caption 1: 12pt / 16pt line height  (Smallest)
```

**Font Family**:
- **System Font**: SF Pro (San Francisco)
- **Rounded Option**: SF Pro Rounded (friendlier feel)
- **Monospace**: SF Mono (code, data)

**Font Weights**:
```
Ultralight:  100  (Decorative only)
Thin:        200  (Large display)
Light:       300  (Display)
Regular:     400  (Body text)
Medium:      500  (Emphasis)
Semibold:    600  (Headers)
Bold:        700  (Strong emphasis)
Heavy:       800  (Titles)
Black:       900  (Display)
```

**Spatial Text Rendering**:
- **3D Text**: Subtle depth (0.01m extrusion)
- **Floating Labels**: Billboard rendering (face user)
- **Reading Distance**: Optimize for 0.6-1.2m
- **Contrast**: Minimum 4.5:1 (WCAG AA)

### 7.3 Materials and Lighting

**Material Types**:

1. **Glass (Primary UI)**
   ```swift
   .glassBackgroundEffect(
       in: RoundedRectangle(cornerRadius: 16),
       displayMode: .always
   )
   ```
   - **Blur Radius**: System adaptive
   - **Vibrancy**: Enabled
   - **Thickness**: Visual depth

2. **Solid (3D Objects)**
   ```swift
   Material.simple(
       color: .blue,
       roughness: 0.3,
       metallic: 0.1
   )
   ```
   - **PBR**: Physically accurate
   - **Roughness**: 0.0 (mirror) - 1.0 (matte)
   - **Metallic**: 0.0 (dielectric) - 1.0 (metal)

3. **Emissive (Highlights)**
   ```swift
   Material.emissive(
       color: .green,
       intensity: 2.0
   )
   ```
   - **Use**: Completed items, active elements
   - **Intensity**: 1.0 - 5.0
   - **Animation**: Pulse effect

4. **Transparent (Ghosts)**
   ```swift
   Material.simple(
       color: .white,
       opacity: 0.3
   )
   ```
   - **Use**: Locked content, previews
   - **Opacity**: 0.1 - 0.5
   - **Tint**: Category color

**Lighting Setup**:

```swift
// Directional Light (Main)
let sunlight = DirectionalLight()
sunlight.light.intensity = 2000  // Lux
sunlight.light.color = .white
sunlight.shadow = DirectionalLightComponent.Shadow(
    maximumDistance: 10.0,
    depthBias: 0.1
)

// Ambient Light (Fill)
let ambient = AmbientLight()
ambient.light.intensity = 500  // Lux
ambient.light.color = UIColor(white: 0.9, alpha: 1.0)

// Point Lights (Accents)
let accent = PointLight()
accent.light.intensity = 1000
accent.light.color = .blue
accent.light.attenuationRadius = 3.0
```

**Lighting Scenarios**:
- **Bright Focus**: High directional, low ambient (assessments)
- **Comfortable Learning**: Medium directional, medium ambient (lessons)
- **Ambient Exploration**: Low directional, high ambient (browsing)

### 7.4 Iconography in 3D Space

**Icon Style**:
- **Source**: SF Symbols 5.0+
- **Rendering**: Extruded 3D or flat billboard
- **Size**: 24-44pt (adaptive to distance)
- **Color**: Monochrome or semantic

**Icon Categories**:

1. **Navigation**
   - chevron.left / right
   - arrow.left / right
   - house (home)
   - magnifyingglass (search)

2. **Actions**
   - plus (add)
   - checkmark (complete)
   - xmark (cancel)
   - bookmark (save)
   - paperplane (send)

3. **Status**
   - clock (in progress)
   - checkmark.circle (completed)
   - lock (locked)
   - star (favorite)

4. **Content**
   - book (course)
   - video (video lesson)
   - cube (3D content)
   - person (profile)

**3D Icon Treatment**:
```swift
Image(systemName: "checkmark.circle.fill")
    .font(.system(size: 44, weight: .medium))
    .foregroundStyle(.green)
    .symbolEffect(.bounce, value: completed)
```

**Spatial Icons**:
- **Floating**: Billboard orientation
- **Anchored**: Fixed to surface
- **Depth**: Subtle extrusion (0.005m)
- **Glow**: Emissive for important states

### 7.5 Shadows and Depth

**Shadow Specifications**:
```swift
// Window Shadows
.shadow(
    color: .black.opacity(0.2),
    radius: 20,
    x: 0,
    y: 10
)

// Card Shadows
.shadow(
    color: .black.opacity(0.1),
    radius: 10,
    x: 0,
    y: 5
)

// Interactive Element Shadows
.shadow(
    color: .black.opacity(0.15),
    radius: 8,
    x: 0,
    y: 4
)
```

**Depth Cues**:
- **Parallax**: Background moves slower than foreground
- **Atmospheric Fog**: Distant objects slightly faded
- **Size**: Larger = closer
- **Occlusion**: Foreground hides background

---

## 8. User Flows and Navigation

### 8.1 Onboarding Flow

```
Launch App
    ↓
Welcome Screen (Window)
    ↓
[  Get Started  ]
    ↓
Spatial Orientation Tutorial
- Look around (gaze)
- Pinch to select
- Hand gestures demo
    ↓
Profile Setup
- Name, role, interests
- Learning goals
    ↓
Personalized Recommendations
- Suggested courses
    ↓
Dashboard (Main Hub)
```

### 8.2 Course Discovery Flow

```
Dashboard
    ↓
[  Browse Courses  ] or [  Search  ]
    ↓
Course Browser Window
    ↓
Apply Filters / Search
    ↓
Course Cards (Grid)
    ↓
Tap Course Card
    ↓
Course Detail Window
    ↓
[  Enroll  ] or [  Preview  ] or [  Save  ]
    ↓
Enrollment Confirmation
    ↓
Dashboard (Updated with new course)
```

### 8.3 Learning Flow

```
Dashboard
    ↓
Tap In-Progress Course
    ↓
Course Overview Window
    ↓
[  Continue Learning  ] or [  View Syllabus  ]
    ↓
Lesson Window (2D) or Immersive Environment (3D)
    ↓
Complete Lesson Content
    ↓
[  Mark Complete  ]
    ↓
Progress Updated
    ↓
[  Next Lesson  ] or [  Back to Course  ]
    ↓
Assessment (if end of module)
    ↓
Results + Feedback
    ↓
Certificate (if course complete)
```

### 8.4 AI Tutor Flow

```
During Lesson
    ↓
[  Need Help?  ] or Voice: "Help"
    ↓
AI Tutor Chat Appears (Ornament)
    ↓
Type or Speak Question
    ↓
AI Generates Response
    ↓
[  Helpful?  Yes / No  ]
    ↓
Continue or Ask Follow-Up
    ↓
[  Close  ] when done
```

### 8.5 Collaboration Flow

```
Course with Collaboration
    ↓
[  Join Session  ] or [  Create Session  ]
    ↓
SharePlay Invitation (if create)
    ↓
Immersive Collaborative Space Opens
    ↓
Avatars of Participants Appear
    ↓
Spatial Voice Chat Active
    ↓
Collaborative Activity
- Group discussion
- Shared problem solving
- Peer review
    ↓
[  Leave Session  ]
    ↓
Return to Individual Learning
```

### 8.6 Navigation Patterns

**Primary Navigation**:
- **Dashboard** (Home): Always accessible
- **My Learning**: In-progress courses
- **Browse**: Explore catalog
- **Profile**: Settings, progress

**Window Management**:
```swift
// Open new window
await openWindow(id: "courseBrowser")

// Close current window
dismiss()

// Open immersive space
await openImmersiveSpace(id: "learningEnvironment")

// Dismiss immersive space
await dismissImmersiveSpace()
```

**Breadcrumb Navigation**:
```
Dashboard > My Learning > Course Title > Module 2 > Lesson 3
   ↑           ↑              ↑            ↑          ↑
 Tappable to navigate back to any level
```

---

## 9. Accessibility Design

### 9.1 VoiceOver Support

**Audio Descriptions for Spatial Elements**:
```swift
entity.accessibilityLabel = "Interactive equipment model"
entity.accessibilityHint = "Double tap to interact, or use pinch gesture"
entity.accessibilityValue = "Status: Ready to operate"
```

**Spatial Audio Cues**:
- **Important Elements**: Emit subtle audio beacon
- **Navigation**: Spatial sound at key locations
- **Feedback**: Directional audio for actions

**Rotor Support**:
- **Headings**: Jump between sections
- **Landmarks**: Navigate to key areas
- **Actions**: Quick access to primary actions

### 9.2 Visual Accessibility

**High Contrast Mode**:
```swift
@Environment(\.colorSchemeContrast) var contrast

var borderStyle: some View {
    if contrast == .increased {
        RoundedRectangle(cornerRadius: 8)
            .strokeBorder(.primary, lineWidth: 3)
    } else {
        RoundedRectangle(cornerRadius: 8)
            .strokeBorder(.primary, lineWidth: 1)
    }
}
```

**Dynamic Type**:
- Support all size categories
- Layout adapts to larger text
- Icons scale appropriately

**Color Independence**:
- Never rely solely on color
- Use icons + color
- Provide text labels

### 9.3 Motor Accessibility

**Large Touch Targets**:
- Minimum: 60pt × 60pt (44mm × 44mm)
- Preferred: 80pt × 80pt for critical actions

**Alternative Inputs**:
- Voice commands for all actions
- Dwell selection (gaze hold)
- Switch control support

**Reduced Motion**:
```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

var transition: AnyTransition {
    reduceMotion ? .opacity : .scale.combined(with: .opacity)
}
```

### 9.4 Cognitive Accessibility

**Simplified Mode**:
- Reduce visual complexity
- Clearer language
- Step-by-step guidance
- Longer timeouts

**Focus Mode**:
- Single task at a time
- Hide distractions
- Clear progress indicators

---

## 10. Error States and Loading Indicators

### 10.1 Error States

**Network Error**:
```
┌────────────────────────────┐
│     ⚠️ Connection Lost    │
│                            │
│  Could not connect to      │
│  the learning platform.    │
│                            │
│  [  Retry  ] [  Offline  ] │
└────────────────────────────┘
```

**Content Not Available**:
```
┌────────────────────────────┐
│     📦 Content Missing     │
│                            │
│  This lesson requires      │
│  additional content.       │
│                            │
│  [  Download  ] [  Skip  ] │
└────────────────────────────┘
```

**Assessment Failed**:
```
┌────────────────────────────┐
│     ❌ Not Passed         │
│                            │
│  Score: 65% (70% required) │
│                            │
│  Review weak areas and     │
│  try again.                │
│                            │
│  [  Review  ] [  Retake  ] │
└────────────────────────────┘
```

**Error Principles**:
- ✅ Clear explanation of what happened
- ✅ Actionable steps to resolve
- ✅ Avoid technical jargon
- ✅ Provide alternative path
- ✅ Maintain user progress

### 10.2 Loading Indicators

**Page Loading** (Windows):
```swift
ProgressView("Loading courses...")
    .progressViewStyle(.circular)
    .scaleEffect(1.5)
```

**Content Streaming** (Immersive):
```
Circular progress with percentage:
     ┌─────┐
     │ 65% │  ← Animated spinner
     └─────┘
 "Loading environment..."
```

**Skeleton Screens** (Course Cards):
```
┌─────────────┐
│░░░░░░░░░░░░░│  ← Animated shimmer
│░░░░░░░░░░░░░│     placeholder
│░░░░░░░      │
└─────────────┘
```

**Progress Types**:
- **Indeterminate**: Unknown duration (spinner)
- **Determinate**: Known duration (progress bar)
- **Skeleton**: Content loading (placeholders)

### 10.3 Empty States

**No Courses Enrolled**:
```
┌────────────────────────────┐
│     📚 Start Learning      │
│                            │
│  You haven't enrolled in   │
│  any courses yet.          │
│                            │
│  [  Browse Courses  ]      │
└────────────────────────────┘
```

**No Search Results**:
```
┌────────────────────────────┐
│     🔍 No Results Found    │
│                            │
│  Try different keywords    │
│  or browse all courses.    │
│                            │
│  [  Clear Filters  ]       │
└────────────────────────────┘
```

**Empty States Principles**:
- ✅ Explain why it's empty
- ✅ Provide clear next action
- ✅ Use friendly, encouraging tone
- ✅ Include relevant illustration

---

## 11. Animation and Transition Specifications

### 11.1 Window Transitions

**Window Open**:
```swift
.transition(.scale(scale: 0.95).combined(with: .opacity))
.animation(.spring(duration: 0.3, bounce: 0.2), value: isPresented)
```
- **Duration**: 0.3 seconds
- **Easing**: Spring with bounce
- **Effect**: Fade + scale from center

**Window Close**:
```swift
.transition(.scale(scale: 1.05).combined(with: .opacity))
.animation(.easeInOut(duration: 0.2), value: isPresented)
```
- **Duration**: 0.2 seconds
- **Easing**: Ease-in-out
- **Effect**: Fade + slight scale up

### 11.2 Space Transitions

**Enter Immersive Space**:
```
Phase 1: Fade out windows (0.3s)
Phase 2: Expand view (0.4s)
Phase 3: Environment appears (0.3s)
Total: 1.0 second
```

**Exit Immersive Space**:
```
Phase 1: Environment fades (0.3s)
Phase 2: Compress view (0.3s)
Phase 3: Windows return (0.4s)
Total: 1.0 second
```

### 11.3 UI Animations

**Button Press**:
```swift
Button("Enroll") {
    action()
}
.buttonStyle(.bordered)
.animation(.spring(duration: 0.2), value: isPressed)
```
- **Press**: Scale to 0.95 (50ms)
- **Release**: Spring back to 1.0 (150ms)

**Progress Update**:
```swift
ProgressView(value: progress)
    .animation(.easeInOut(duration: 0.5), value: progress)
```
- **Duration**: 0.5 seconds per update
- **Easing**: Ease-in-out
- **Effect**: Smooth fill

**Card Flip**:
```swift
.rotation3DEffect(
    .degrees(flipped ? 180 : 0),
    axis: (x: 0, y: 1, z: 0)
)
.animation(.spring(duration: 0.6), value: flipped)
```
- **Duration**: 0.6 seconds
- **Axis**: Y (vertical flip)
- **Easing**: Spring

### 11.4 3D Animations

**Object Appear**:
```swift
entity.scale = [0.01, 0.01, 0.01]
entity.move(
    to: Transform(scale: [1, 1, 1]),
    relativeTo: nil,
    duration: 0.5,
    timingFunction: .easeOut
)
```

**Rotation Animation**:
```swift
var rotationAnimation: AnimationDefinition {
    .orbit(
        duration: 10,
        axis: [0, 1, 0],
        startTransform: entity.transform,
        spinClockwise: true
    )
}
```

**Pulse Effect** (Achievement):
```swift
entity.availableAnimations.forEach { animation in
    entity.playAnimation(animation.repeat())
}
```

### 11.5 Loading Animations

**Spinner**:
```swift
ProgressView()
    .progressViewStyle(.circular)
    .rotationEffect(.degrees(rotation))
    .onAppear {
        withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
            rotation = 360
        }
    }
```

**Shimmer Effect** (Skeleton):
```swift
LinearGradient(
    colors: [.clear, .white.opacity(0.5), .clear],
    startPoint: .leading,
    endPoint: .trailing
)
.offset(x: shimmerOffset)
.animation(.linear(duration: 1.5).repeatForever(autoreverses: false), value: shimmerOffset)
```

### 11.6 Micro-interactions

**Hover Effects**:
- **Scale**: 1.0 → 1.05 (200ms)
- **Glow**: 0% → 20% (200ms)
- **Lift**: Subtle shadow increase

**Tap Feedback**:
- **Visual**: Scale + glow
- **Audio**: Click sound (50ms)
- **Haptic**: Light impact

**Success Animation**:
- **Checkmark**: Draw path animation (400ms)
- **Glow**: Pulse effect (600ms)
- **Sound**: Success chime

**Error Animation**:
- **Shake**: Left-right oscillation (300ms)
- **Flash**: Red tint (200ms)
- **Sound**: Error buzz

### 11.7 Animation Performance

**Performance Guidelines**:
- **Target**: 90 FPS maintained
- **Max Concurrent Animations**: 5
- **GPU Acceleration**: Prefer when possible
- **Reduce Motion**: Provide alternatives

**Optimization Techniques**:
```swift
// Use .animation(_:value:) instead of withAnimation
.animation(.spring, value: state)

// Disable implicit animations
.transaction { transaction in
    transaction.animation = nil
}

// Animate only necessary properties
.animation(.default, value: position)  // Good
.animation(.default)                    // Bad (animates everything)
```

---

## Summary

This design specification provides comprehensive guidance for creating a world-class spatial learning experience on visionOS. Key design principles include:

- **Spatial Ergonomics**: Content positioned 10-15° below eye level for comfort
- **Progressive Disclosure**: Start with windows, expand to volumes, immerse fully
- **Consistent Interactions**: Gaze + pinch, hand gestures, voice commands
- **Accessible Design**: VoiceOver, Dynamic Type, alternative inputs
- **Visual Clarity**: Glass materials, clear typography, semantic colors
- **Smooth Animations**: Spring-based, 90 FPS target
- **User-Centered**: Clear error states, helpful empty states, intuitive navigation

All designs follow Apple's Human Interface Guidelines for visionOS and prioritize user comfort, accessibility, and learning effectiveness.
