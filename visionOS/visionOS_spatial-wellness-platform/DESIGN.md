# Spatial Wellness Platform - Design Specifications

## 1. Spatial Design Principles

### 1.1 Core Design Philosophy

**"Health Made Visible, Wellness Made Experiential"**

The Spatial Wellness Platform transforms abstract health data into intuitive 3D experiences that users can explore, understand, and act upon. Every design decision prioritizes clarity, comfort, and empowerment.

### 1.2 Fundamental Principles

#### 1. Progressive Spatial Disclosure
```
Level 1: Windows (Quick Glances)
  └─> Dashboard cards, vital stats, notifications

Level 2: Volumes (Deep Exploration)
  └─> 3D health landscapes, interactive data visualizations

Level 3: Immersive Spaces (Full Engagement)
  └─> Meditation environments, virtual workouts, therapeutic spaces
```

#### 2. Spatial Ergonomics
- **Viewing Angle**: Content placed 10-15° below eye level
- **Distance Zones**:
  - Intimate (0.5-1m): Personal health details, private data
  - Personal (1-2m): Primary interaction zone, main UI
  - Social (2-4m): Shared activities, group challenges
  - Public (4m+): Ambient environmental elements

#### 3. Depth as Meaning
- **Z-axis hierarchy**: More important = closer to user
- **Critical health alerts**: Float forward prominently
- **Historical data**: Recedes into background
- **Future goals**: Extend forward as aspirational targets

#### 4. Comfort-First Design
- **No rapid motion**: All animations ≤ 0.5s or user-controlled
- **Predictable behavior**: Clear cause-and-effect
- **Rest areas**: Calm zones with minimal visual complexity
- **Exit affordances**: Always visible and accessible

#### 5. Inclusive by Default
- **Multiple interaction modalities**: Gaze, pinch, voice, dwell
- **Adjustable complexity**: Simple → Advanced views
- **Cultural sensitivity**: Respectful health representations
- **Privacy controls**: Visible and accessible at all times

---

## 2. Window Layouts and Configurations

### 2.1 Dashboard Window (Primary Interface)

**Purpose**: Central hub for health overview and quick actions

**Dimensions**: 800pt × 600pt (default), resizable

```
┌────────────────────────────────────────────────────────┐
│  Spatial Wellness                         [👤] [⚙️]    │
├────────────────────────────────────────────────────────┤
│                                                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │   💗 72      │  │   🚶 8,543   │  │   😌 Good    │ │
│  │   Heart Rate │  │   Steps      │  │   Stress     │ │
│  │   Normal     │  │   85% Goal   │  │   Level      │ │
│  └──────────────┘  └──────────────┘  └──────────────┘ │
│                                                        │
│  Daily Goals Progress                       [View All] │
│  ┌────────────────────────────────────────────────┐   │
│  │  🎯 Steps         ████████░░  85%              │   │
│  │  💧 Hydration     ██████████  100%             │   │
│  │  🧘 Meditation    ████░░░░░░  40%              │   │
│  └────────────────────────────────────────────────┘   │
│                                                        │
│  AI Health Insights                   [🤖 Ask Coach]  │
│  ┌────────────────────────────────────────────────┐   │
│  │  "Your sleep quality improved 15% this week.   │   │
│  │   Consider maintaining your 10 PM bedtime."    │   │
│  └────────────────────────────────────────────────┘   │
│                                                        │
│  Quick Actions                                         │
│  [🧘 Meditate] [🏃 Workout] [📊 Health Landscape]     │
│                                                        │
└────────────────────────────────────────────────────────┘
```

**Design Specifications**:
- **Background**: Glass material with 80% opacity, vibrancy enabled
- **Corner Radius**: 24pt for cards, 12pt for inner elements
- **Spacing**: 16pt between cards, 24pt margins
- **Typography**:
  - Title: SF Pro Display, 32pt, Bold
  - Metrics: SF Pro Display, 40pt, Semibold
  - Body: SF Pro Text, 17pt, Regular
  - Labels: SF Pro Text, 15pt, Medium

**Interaction Zones**:
- **Vital Cards**: Tap to expand, long-press for details
- **Progress Bars**: Tap to view breakdown
- **Quick Actions**: Tap to launch experience
- **AI Insights**: Tap to chat with coach

### 2.2 Biometric Detail Window

**Dimensions**: 600pt × 800pt (portrait orientation)

```
┌──────────────────────────────────────┐
│  Heart Rate                    [✕]   │
├──────────────────────────────────────┤
│                                      │
│         ┌────────────┐               │
│         │            │               │
│         │     72     │               │
│         │    BPM     │               │
│         │            │               │
│         └────────────┘               │
│                                      │
│  Status: Normal Range ✓              │
│                                      │
│  ┌──────────────────────────────┐   │
│  │        Today's Trend         │   │
│  │                              │   │
│  │    [Line graph: 24 hours]   │   │
│  │                              │   │
│  └──────────────────────────────┘   │
│                                      │
│  Insights                            │
│  • Resting HR: 65 BPM                │
│  • Max HR today: 142 BPM             │
│  • Recovery time: Good               │
│                                      │
│  ┌──────────────────────────────┐   │
│  │  [📊 View 3D Visualization]  │   │
│  └──────────────────────────────┘   │
│                                      │
└──────────────────────────────────────┘
```

**Visual Elements**:
- **Large Metric Display**: Center-aligned, animated transitions
- **Trend Graph**: Interactive, 24-hour timeline
- **Status Indicator**: Color-coded (green/yellow/orange/red)
- **3D Visualization Button**: Launches volumetric view

### 2.3 Community Window

**Dimensions**: 900pt × 700pt

```
┌────────────────────────────────────────────────────────┐
│  Community                    [Active Challenges ▼]    │
├────────────────────────────────────────────────────────┤
│                                                        │
│  [🏆 Challenges]  [👥 Friends]  [📊 Leaderboard]      │
│                                                        │
│  Active Challenges                                     │
│  ┌────────────────────────────────────────────────┐   │
│  │  🏃 Step Challenge                             │   │
│  │  "10,000 Steps Daily - March"                  │   │
│  │  ─────────────────────────  75%                │   │
│  │  👥 42 participants    🏅 Rank: #8             │   │
│  │  ⏰ 12 days remaining                          │   │
│  └────────────────────────────────────────────────┘   │
│                                                        │
│  ┌────────────────────────────────────────────────┐   │
│  │  🧘 Meditation Streak                          │   │
│  │  "7 Days of Mindfulness"                       │   │
│  │  ────────────  40%                             │   │
│  │  👥 Personal    🔥 Streak: 3 days              │   │
│  └────────────────────────────────────────────────┘   │
│                                                        │
│  [+ Create Challenge]                                  │
│                                                        │
└────────────────────────────────────────────────────────┘
```

### 2.4 Settings Window

**Dimensions**: 700pt × 500pt

```
┌────────────────────────────────────────────┐
│  Settings                            [✕]   │
├────────────────────────────────────────────┤
│                                            │
│  [👤 Profile]  [🔒 Privacy]  [🔗 Devices] │
│  [🔔 Notifications]  [♿ Accessibility]    │
│                                            │
│  Privacy Settings                          │
│  ┌──────────────────────────────────────┐ │
│  │  Data Sharing                        │ │
│  │  ○ Private (default)                 │ │
│  │  ○ Organization (anonymized)         │ │
│  │  ○ Friends only                      │ │
│  └──────────────────────────────────────┘ │
│                                            │
│  Health Data Permissions                   │
│  │  HealthKit Access         [✓]          │
│  │  Location for Workouts    [✓]          │
│  │  Camera for Pose Detect   [✗]          │
│                                            │
│  Data Management                           │
│  [Export My Data]  [Delete All Data]      │
│                                            │
└────────────────────────────────────────────┘
```

---

## 3. Volume Designs (3D Bounded Spaces)

### 3.1 Health Landscape Volume

**Concept**: Interactive 3D terrain representing overall health status

**Dimensions**: 1.0m × 1.0m × 1.0m

**Visual Design**:
```
     Top View                    Side View

    Fitness Peak              │    /\
   /           \              │   /  \  ← Fitness Peak
  /  Heart ♥   \             │  /____\
 /   Lake       \            │  |    | ← Heart Lake
└───Sleep───────┘            │  |____|
    Valley                   │    ██   ← Sleep Valley
                              │
```

**Design Specifications**:

1. **Terrain Topology**:
   - **Fitness Peak**: Height = activity level (0-100%)
   - **Heart Lake**: Depth/color = cardiovascular health
   - **Sleep Valley**: Smoothness = sleep quality
   - **Nutrition Garden**: Vegetation = dietary balance
   - **Stress Mountain**: Elevation = stress levels

2. **Materials**:
   - **Healthy areas**: Vibrant greens, blues (RGB: 46, 204, 113)
   - **Attention areas**: Warm yellows (RGB: 241, 196, 15)
   - **Concern areas**: Oranges/reds (RGB: 231, 76, 60)
   - **Terrain**: Physically-based rendering (PBR) materials
   - **Water**: Reflective shader with ripples

3. **Lighting**:
   - **Ambient**: Soft top-down lighting (intensity: 0.3)
   - **Directional**: Simulated sunlight (intensity: 0.7, angle: 45°)
   - **Point lights**: At health markers for emphasis

4. **Interactivity**:
   - **Gaze**: Hover over areas to see details
   - **Tap**: Tap region to focus and display metrics
   - **Drag**: Rotate landscape 360°
   - **Pinch**: Scale (0.5x - 2.0x)

### 3.2 Heart Rate River Volume

**Concept**: Flowing river visualization of heart rate over time

**Dimensions**: 1.2m × 0.6m × 0.6m

**Visual Design**:
```
   Time Flow Direction →

   ╔═════════════════════════╗
   ║  ∿∿∿∿∿∿∿∿∿∿∿∿∿∿∿∿∿∿∿  ║  ← Calm flow (60-70 BPM)
   ║      ≋≋≋≋≋≋≋≋≋≋≋≋      ║  ← Elevated (90-120 BPM)
   ║        ∿∿∿∿∿∿∿         ║  ← Resting (60-70 BPM)
   ╚═════════════════════════╝

   Past ←─────────────────→ Present
```

**Design Elements**:
- **Flow Speed**: Faster flow = higher heart rate
- **River Width**: Wider = more variability
- **Water Color**:
  - Blue (60-100 BPM): Resting/Normal
  - Green (100-140 BPM): Exercise zone
  - Yellow (140-170 BPM): High intensity
  - Red (170+ BPM): Maximum effort
- **Particles**: Flowing light particles show directionality
- **Time Markers**: Subtle landmarks every 4 hours

**Interaction**:
- **Tap segment**: View exact BPM at that time
- **Scrub timeline**: Drag finger along river to scan history
- **Zoom**: Pinch to see minute-by-minute detail

### 3.3 Sleep Cycle Globe

**Concept**: Orbital visualization of sleep stages

**Dimensions**: 0.8m × 0.8m × 0.8m (spherical)

**Visual Design**:
```
        🌙
       /   \
      /     \
     |  😴  |  ← Central sphere (body)
      \     /
       \   /
        ‾‾‾

   Orbit Rings:
   ○ ○ ○ ○ ○  ← Deep Sleep (dark blue)
     ○ ○ ○    ← REM (purple)
   ○ ○ ○ ○    ← Light Sleep (light blue)
       ○      ← Awake (yellow)
```

**Design Elements**:
- **Central Orb**: Glowing sphere representing the sleeper
- **Orbital Rings**: Each sleep stage as a ring
  - Deep Sleep: Dark blue, thick ring, close to center
  - REM: Purple, medium ring, iridescent
  - Light Sleep: Light blue, thin ring, outer layer
  - Awake: Yellow markers, sporadic
- **Animation**: Rings slowly rotate, particles flow along stages
- **Time Scale**: 360° = 8 hours

**Metrics Display**:
- Floating labels show:
  - Total sleep: 7h 42m
  - Deep sleep: 1h 18m (17%)
  - REM: 2h 10m (28%)
  - Light: 4h 14m (55%)
  - Awake: 3 × 6m (4%)

### 3.4 Activity Timeline Volume

**Concept**: 3D timeline of daily activities

**Dimensions**: 1.2m × 0.6m × 0.4m

**Visual Design**:
```
Height = Activity Intensity

High │      ███
     │     █████
Med  │    ███░███   ███
     │   ███░░░███ █████
Low  │  ███░░░░░████████░
     └──────────────────────→ Time
     6am    12pm    6pm    12am
```

**Design Elements**:
- **Bar Height**: Physical activity intensity
- **Bar Color**: Activity type
  - 🏃 Red: Cardio
  - 💪 Orange: Strength
  - 🧘 Blue: Mindfulness
  - 🚶 Green: Walking
- **Transparency**: Confidence level of data
- **Glow**: Recent activities have subtle glow
- **Connections**: Arcs between related activities

---

## 4. Immersive Experiences

### 4.1 Meditation Temple (Progressive Immersion)

**Environment**: Serene temple in a misty mountain setting

**Visual Design**:
```
                   ⛰️ Distant Mountains
                      (Soft blue)

        ☁️ ☁️ ☁️  Floating mist

    ┌─────────────────────┐
    │    Temple Space     │  Golden light
    │                     │  Wooden floor
    │      🧘‍♀️ User       │  Stone pillars
    │                     │  Incense smoke
    └─────────────────────┘

    🌸  🌸  Lotus flowers  🌸  🌸
```

**Design Specifications**:

1. **Architecture**:
   - **Floor**: Polished wooden planks, subtle grain
   - **Pillars**: Stone with carved mantras
   - **Ceiling**: Open to sky with fabric canopy
   - **Walls**: Semi-transparent, blend with environment

2. **Lighting**:
   - **Ambient**: Warm golden hour (5000K)
   - **Directional**: Soft sun rays through canopy
   - **Volumetric**: Visible light shafts through mist
   - **Point lights**: Subtle candle flickers

3. **Environmental Elements**:
   - **Mist**: Slow-moving particle system
   - **Incense smoke**: Rising tendrils, interactive
   - **Water feature**: Gentle trickling sound + ripples
   - **Petals**: Occasional falling flower petals
   - **Wind**: Subtle fabric and leaf movement

4. **Spatial Audio**:
   - **Ambient**: Distant bird calls, gentle wind
   - **Foreground**: Water trickling, incense burning
   - **Music**: Optional calming meditation music (0-40Hz)
   - **Voice**: Guided meditation narration (optional)

5. **Biofeedback Integration**:
   - **Heart Rate**: Subtle pulsing light orb
   - **Breathing**: Expanding/contracting sphere guide
   - **Stress Level**: Environment color temperature adjusts

6. **Immersion Levels**:
   - **0% (Window)**: Temple view in window
   - **25%**: Temple appears in room, walls visible
   - **50%**: Room fades, temple prominent
   - **75%**: Mostly temple, slight room outline
   - **100%**: Full immersion, no passthrough

### 4.2 Virtual Gym (Full Immersion)

**Environment**: Modern fitness studio with coach

**Visual Design**:
```
    ┌─────────────────────────────────────┐
    │          Virtual Gym               │
    │                                    │
    │     [🤸 Coach Avatar]              │
    │                                    │
    │              VS                    │
    │                                    │
    │     [🧍 User Mirror]               │
    │                                    │
    │  Equipment: [🏋️] [🧘] [🏃]        │
    └─────────────────────────────────────┘
```

**Design Elements**:

1. **Coach Avatar**:
   - **Appearance**: Athletic, diverse representation
   - **Positioning**: 3m in front, eye level
   - **Animation**: Smooth exercise demonstrations
   - **Feedback**: Real-time form corrections
   - **Voice**: Encouraging, motivational

2. **User Mirror**:
   - **Reflection**: Skeletal overlay showing form
   - **Guides**: Alignment lines for proper form
   - **Highlighting**: Color-coded joint tracking
     - Green: Correct positioning
     - Yellow: Slightly off
     - Red: Needs correction

3. **Equipment**:
   - **Virtual weights**: Visible when needed
   - **Exercise mat**: Marked safe exercise zone
   - **Timer**: Floating countdown display
   - **Rep counter**: Automatic tracking

4. **Metrics Overlay**:
   - **Heart Rate**: Top-left corner
   - **Calories**: Top-right corner
   - **Rep Count**: Bottom-center
   - **Form Score**: Bottom-right (0-100%)

5. **Spatial Audio**:
   - **Coach voice**: Positioned at avatar
   - **Music**: Energetic workout playlist
   - **Sound effects**: Rep completions, milestones
   - **Breathing cues**: Inhale/exhale sounds

### 4.3 Relaxation Beach (Progressive Immersion)

**Environment**: Peaceful beach at sunset

**Visual Design**:
```
         🌅 Sunset
    ☁️ ☁️ ☁️ Gentle clouds

    ~~~~~~~~~~~~~~~~~~~  Ocean waves
    ~~~~~~~~~~~~~~~~~~~

    🏖️ ______________ Sandy beach

       🧘 User

    🌴 Palm trees 🌴
```

**Design Specifications**:

1. **Environment**:
   - **Sky**: Gradient sunset (orange→pink→purple)
   - **Ocean**: Gentle wave animation, foam particles
   - **Sand**: Fine grain texture, footprints fade
   - **Vegetation**: Swaying palm trees, tropical plants

2. **Lighting**:
   - **Sun**: Low on horizon, warm glow (2500K)
   - **Sky**: Soft ambient from sunset colors
   - **Reflections**: Water reflects sky
   - **Shadows**: Long, soft shadows from objects

3. **Particle Systems**:
   - **Waves**: Foam particles at shore
   - **Spray**: Occasional sea spray mist
   - **Birds**: Distant flying silhouettes
   - **Fireflies**: Emerge as sun sets (optional)

4. **Spatial Audio**:
   - **Waves**: Rhythmic ocean sounds (0.3 Hz)
   - **Wind**: Gentle breeze through palms
   - **Seabirds**: Distant calls
   - **Breathing guide**: Synchronized with waves

5. **Therapeutic Features**:
   - **Breathing sphere**: Rises/falls with ocean rhythm
   - **Color therapy**: Sky gradually shifts colors
   - **Progressive relaxation**: Environment evolves over session
   - **Exit portal**: Glowing path back when ready

### 4.4 Guided Yoga Studio (Mixed Immersion)

**Environment**: Minimalist studio with instructor

**Visual Design**:
```
    ┌───────────────────────────────┐
    │      Yoga Studio            │
    │                             │
    │   [Instructor Avatar]       │
    │                             │
    │   [Pose Outline]            │
    │         ⬇️                   │
    │   [Your Position]           │
    │                             │
    │  Mat Grid ■ ■ ■ ■          │
    └───────────────────────────────┘
```

**Design Elements**:

1. **Studio Space**:
   - **Floor**: Wooden, warm tone
   - **Walls**: Soft white, minimalist
   - **Windows**: Frosted glass, natural light
   - **Mirrors**: Side walls for self-check
   - **Props**: Blocks, straps appear as needed

2. **Instructor**:
   - **Avatar**: Calm, welcoming presence
   - **Positioning**: Front-center, 2m distance
   - **Demonstration**: Smooth pose transitions
   - **Voice**: Soothing guidance, breathing cues
   - **Eye contact**: Occasional check-ins

3. **Pose Guidance**:
   - **Outline overlay**: Target pose in wireframe
   - **Alignment lines**: Vertical/horizontal guides
   - **Hand tracking**: Skeleton overlay on user
   - **Joint markers**: Color-coded accuracy
   - **Adjustments**: Real-time form corrections

4. **Session Flow**:
   - **Warm-up**: Gentle stretches (5 min)
   - **Flow**: Vinyasa sequence (20-40 min)
   - **Cool-down**: Restorative poses (5 min)
   - **Savasana**: Final relaxation (5 min)

---

## 5. Interaction Patterns

### 5.1 Gaze + Pinch (Primary Interaction)

**Pattern**: Look at target, pinch fingers together to select

```
User gazes at button
        ↓
Button highlights (0.1s delay)
        ↓
User pinches fingers
        ↓
Action triggers + haptic feedback
        ↓
Visual confirmation
```

**Design Guidelines**:
- **Hover State**: Subtle glow, 10% scale increase
- **Active State**: Brightness increase, ripple effect
- **Feedback**: Immediate visual + haptic (light impact)
- **Debounce**: 200ms to prevent accidental double-taps

### 5.2 Direct Touch (Volumetric Content)

**Pattern**: Reach out and touch 3D objects directly

```
Hand approaches object
        ↓
Object highlights when in range (10cm)
        ↓
Contact detected
        ↓
Haptic feedback + visual response
        ↓
Object manipulated (drag/rotate/scale)
```

**Design Guidelines**:
- **Proximity detection**: 10cm range
- **Contact haptic**: Medium impact
- **Manipulation**: Smooth physics-based movement
- **Release**: Gentle settle animation

### 5.3 Two-Hand Gestures

**Resize Volume**:
```
Both hands pinch object corners
        ↓
Move hands apart/together
        ↓
Volume scales proportionally
        ↓
Release to confirm size
```

**Rotate Volume**:
```
Both hands on object
        ↓
Rotate hands in circular motion
        ↓
Object rotates on Y-axis
        ↓
Release to set orientation
```

### 5.4 Voice Commands

**Activation**: "Hey Coach" or dedicated button

**Common Commands**:
```
Voice Commands:
├── Navigation
│   ├── "Show my dashboard"
│   ├── "Open health landscape"
│   └── "Go to meditation"
│
├── Health Queries
│   ├── "What's my heart rate?"
│   ├── "How did I sleep last night?"
│   └── "Show my weekly progress"
│
├── Actions
│   ├── "Start a workout"
│   ├── "Log 8 glasses of water"
│   └── "Join step challenge"
│
└── AI Coach
    ├── "Give me health insights"
    ├── "What should I focus on today?"
    └── "Create a wellness plan"
```

**Feedback**:
- **Listening**: Animated waveform, blue glow
- **Processing**: Spinner, "Thinking..." text
- **Response**: Text appears + voice reply
- **Error**: "Sorry, I didn't understand. Try again?"

### 5.5 Gesture Library

| Gesture | Action | Visual Feedback |
|---------|--------|-----------------|
| **Palm Scan** | Check vitals | Scanning animation, particles |
| **Step Forward** | Join activity | Portal opens, invitation |
| **Arms Up** | Celebrate achievement | Confetti, fireworks effect |
| **Hand Raise** | Request help | Help beacon, coach appears |
| **Open Palms** | Meditate mode | Calm ripple effect |
| **Chest Expansion** | Breathing exercise | Expanding sphere guide |
| **Swipe Away** | Dismiss notification | Fade out, gentle sound |
| **Pull Down** | Refresh data | Loading spinner, refresh sound |

---

## 6. Visual Design System

### 6.1 Color Palette

**Primary Colors**:
```
Health Green (Primary)
  Light: #52C770  (RGB: 82, 199, 112)
  Base:  #2ECC71  (RGB: 46, 204, 113)
  Dark:  #27AE60  (RGB: 39, 174, 96)

Wellness Blue (Secondary)
  Light: #5DADE2  (RGB: 93, 173, 226)
  Base:  #3498DB  (RGB: 52, 152, 219)
  Dark:  #2980B9  (RGB: 41, 128, 185)

Mindfulness Purple (Accent)
  Light: #BB8FCE  (RGB: 187, 143, 206)
  Base:  #9B59B6  (RGB: 155, 89, 182)
  Dark:  #8E44AD  (RGB: 142, 68, 173)
```

**Status Colors**:
```
Optimal:  #2ECC71 (Green)
  Used for: Healthy metrics, goals achieved

Good:     #3498DB (Blue)
  Used for: Normal range, progressing well

Caution:  #F39C12 (Yellow/Orange)
  Used for: Needs attention, slight concern

Warning:  #E67E22 (Orange)
  Used for: Outside range, take action

Critical: #E74C3C (Red)
  Used for: Emergency, immediate attention
```

**Neutral Colors**:
```
Background:
  Glass Light: rgba(255, 255, 255, 0.15)
  Glass Dark:  rgba(0, 0, 0, 0.30)

Text:
  Primary:   #FFFFFF (100% opacity)
  Secondary: #FFFFFF (70% opacity)
  Tertiary:  #FFFFFF (40% opacity)

Dividers:
  Light: rgba(255, 255, 255, 0.1)
  Dark:  rgba(0, 0, 0, 0.1)
```

**Gradient Palettes**:
```
Energy Gradient (Fitness):
  #FF6B6B → #FFA500 → #FFD93D
  (Red → Orange → Yellow)

Calm Gradient (Meditation):
  #667EEA → #764BA2 → #F78FB3
  (Blue-purple → Purple → Pink)

Nature Gradient (Wellness):
  #11998E → #38EF7D
  (Teal → Green)

Sky Gradient (Background):
  #667EEA → #F78FB3 → #FFA500
  (Dawn to dusk)
```

### 6.2 Typography

**Font Family**: SF Pro (System Font)

```
Display Styles:
  Extra Large:  SF Pro Display, 40pt, Bold
                Used for: Large metrics, hero numbers

  Large:        SF Pro Display, 32pt, Semibold
                Used for: Window titles, section headers

  Medium:       SF Pro Display, 24pt, Medium
                Used for: Card titles, important labels

Body Styles:
  Body Large:   SF Pro Text, 19pt, Regular
                Used for: Primary content, descriptions

  Body:         SF Pro Text, 17pt, Regular
                Used for: Standard text, paragraphs

  Body Small:   SF Pro Text, 15pt, Regular
                Used for: Secondary information

Label Styles:
  Label:        SF Pro Text, 15pt, Medium
                Used for: Input labels, categories

  Caption:      SF Pro Text, 13pt, Regular
                Used for: Metadata, timestamps

  Fine Print:   SF Pro Text, 11pt, Regular
                Used for: Legal, minor details
```

**Spatial Text Rendering**:
- **Depth**: Text floats 2-5cm from background
- **Shadows**: Soft drop shadow for readability
- **Contrast**: Minimum 4.5:1 against background
- **Size adaptation**: Text scales with viewing distance

**3D Text** (for immersive spaces):
```
Material: Metallic, slight emission
Depth: 5-10mm extrusion
Lighting: Receives scene lighting
Use: Titles in environments, signage
```

### 6.3 Materials and Lighting

**Glass Materials**:
```
Window Background:
  - Base: Frosted glass (blur radius: 40pt)
  - Opacity: 15% in light mode, 30% in dark mode
  - Vibrancy: Enabled
  - Reflections: Subtle environment reflections
  - Borders: 1pt white/black with 10% opacity

Card Surface:
  - Base: Glass material
  - Opacity: 20% in light mode, 40% in dark mode
  - Blur: 30pt
  - Elevation: 2-3mm from window
  - Shadow: Soft, 10% opacity
```

**3D Materials (Volumes & Immersive)**:
```
Health Landscape:
  - Terrain: PBR material, roughness 0.6
  - Grass: Texture with normal maps
  - Water: Reflective, ripple normals
  - Rocks: Rough, ambient occlusion

UI Panels in 3D:
  - Material: Brushed metal or glass
  - Transparency: 30-50%
  - Emission: Slight glow for readability
  - Depth: 5-10mm thickness
```

**Lighting Setups**:
```
Dashboard (Window):
  - Ambient: System-provided
  - No custom lights needed

Health Landscape (Volume):
  - Ambient: 0.3 intensity, white
  - Directional: 0.7 intensity, warm (3500K), 45° angle
  - Rim light: 0.2 intensity, cool, highlights edges

Meditation Space (Immersive):
  - Ambient: 0.2 intensity, warm (2700K)
  - Directional: 0.5 intensity, golden hour
  - Volumetric: Visible light rays
  - Point lights: Candles, fireflies (0.1 intensity)

Virtual Gym (Immersive):
  - Ambient: 0.4 intensity, neutral (5000K)
  - Directional: 0.8 intensity, bright
  - Spotlights: Highlight exercise area
  - Rim lights: Define user silhouette
```

### 6.4 Iconography

**2D Icons** (Windows):
```
Style: SF Symbols (Apple's icon set)
Size:
  - Small: 16pt
  - Medium: 24pt
  - Large: 32pt
Weight: Regular (adapts to text weight)
Color: Matches text color or status color

Common Icons:
  ♥️  heart.fill          - Heart health
  🏃 figure.walk         - Activity
  😊 face.smiling        - Mental health
  💧 drop.fill           - Hydration
  🛏️  bed.double.fill    - Sleep
  🥗 fork.knife          - Nutrition
  🧘 figure.mind.and.body - Meditation
  📊 chart.bar.fill      - Analytics
  ⚙️  gearshape.fill     - Settings
  🏆 trophy.fill         - Achievements
```

**3D Icons** (Volumes & Immersive):
```
Style: Low-poly, friendly
Material: Emission + base color
Animation: Gentle float, subtle pulse

Examples:
  Heart: Beating animation
  Steps: Footprint trail
  Water: Droplet ripple
  Sleep: Crescent moon rotation
```

### 6.5 Animations and Transitions

**Animation Principles**:
1. **Purposeful**: Every animation communicates state
2. **Comfortable**: No jarring motion (max 0.5s)
3. **Natural**: Ease-in-out curves, physics-based
4. **Responsive**: Immediate feedback (<50ms)
5. **Subtle**: Support UI, don't distract

**Transition Catalog**:

```swift
// Window transitions
.transition(.opacity.combined(with: .scale))
.animation(.spring(response: 0.3, dampingFraction: 0.7))

// Card appearance
.transition(.move(edge: .bottom).combined(with: .opacity))
.animation(.easeOut(duration: 0.3))

// Immersive space entry
.transition(.fade(duration: 0.5))

// Value changes (metrics)
.animation(.spring(response: 0.5, dampingFraction: 0.6))

// Loading states
.animation(.linear(duration: 1.0).repeatForever(autoreverses: false))
```

**Easing Functions**:
```
Ease In Out:     Most common, balanced feel
Ease Out:        Actions, button presses
Spring:          Playful, natural motion
Linear:          Progress indicators, looping
Custom cubic:    Fine-tuned motion curves
```

**Animation Examples**:

1. **Heart Rate Update**:
```
Old value fades out → Brief pause → New value fades in
With color change based on status
Duration: 0.4s total
```

2. **Goal Completion**:
```
Progress bar fills → Checkmark appears → Confetti burst
Scale pulse on checkmark
Duration: 1.2s total
```

3. **Entering Meditation**:
```
Dashboard fades out (0.3s) →
Environment fades in (0.5s) →
Breathing guide appears (0.3s)
Total: 1.1s
```

4. **3D Health Landscape Rotation**:
```
User drags → Volume follows finger with slight lag (physics)
Release → Gentle settle to nearest 45° angle
Momentum continues briefly
```

---

## 7. User Flows and Navigation

### 7.1 Onboarding Flow

```
Launch App
    ↓
Welcome Screen (Window)
  "Welcome to Spatial Wellness"
  [Continue]
    ↓
Health Goals Setup (Window)
  "What are your wellness goals?"
  [x] Improve fitness
  [x] Better sleep
  [x] Reduce stress
  [x] Healthy eating
  [Continue]
    ↓
Privacy & Permissions (Window)
  "Your health data is private"
  [Grant HealthKit Access]
  [Maybe Later]
    ↓
Quick Tour (Progressive)
  1. Dashboard overview
  2. 3D Health Landscape demo
  3. Meditation space preview
  4. Community features
  [Skip Tour] / [Next]
    ↓
Dashboard (Ready to use)
```

### 7.2 Primary Navigation Structure

```
App Entry Point: Dashboard (Window)
                      │
        ┌─────────────┼─────────────┬──────────────┐
        ↓             ↓             ↓              ↓
    Activity     Biometrics    Community      Meditation
    (Window)     (Window)      (Window)       (Immersive)
        │             │             │
        ↓             ↓             ↓
  Start Workout  3D Landscape  Challenges
  (Immersive)    (Volume)      (Window)
```

### 7.3 Core User Flow: Starting a Meditation Session

```
1. User on Dashboard
   ↓
2. Taps "Meditate" quick action
   ↓
3. Environment selection sheet appears
   Options:
   - 🏯 Temple (Default)
   - 🏖️ Beach
   - 🌲 Forest
   - 🌌 Space
   ↓
4. Select Temple → Tap "Begin"
   ↓
5. Transition animation (0.5s)
   Dashboard fades → Temple fades in
   ↓
6. Immersive space loads (Progressive, 75%)
   ↓
7. Coach voice: "Welcome. Find a comfortable position."
   ↓
8. Breathing guide appears (expanding sphere)
   ↓
9. Session begins (5-30 min, user choice)
   │
   ├─ Guided meditation playing
   ├─ Biometric tracking active
   ├─ Environment subtly animates
   └─ Exit button always visible (top-right)
   ↓
10. Session ends naturally OR user exits
    ↓
11. Summary window appears
    - Duration: 15 min
    - Avg Heart Rate: 62 BPM
    - Stress Reduction: -23%
    [Save Session] [Share]
    ↓
12. Return to Dashboard
    Updated metrics + Achievement unlocked
```

### 7.4 Secondary Flow: Exploring Health Data

```
1. Dashboard: User gazes at "Heart Rate" card
   ↓
2. Card highlights (hover effect)
   ↓
3. User taps (pinch gesture)
   ↓
4. Biometric Detail Window opens
   Shows: Current HR, 24h graph, insights
   ↓
5. User taps "View 3D Visualization"
   ↓
6. Heart Rate River Volume appears
   Flowing river representation of HR over time
   ↓
7. User interacts:
   - Drags to rotate view
   - Taps segments for details
   - Pinches to zoom timeline
   ↓
8. User taps "X" to close volume
   ↓
9. Return to Detail Window
   (can open other visualizations)
   ↓
10. Close window → Back to Dashboard
```

### 7.5 Social Flow: Joining a Challenge

```
1. Open Community Window
   ↓
2. Browse active challenges
   ↓
3. Select "10,000 Steps Daily - March"
   ↓
4. Challenge details appear:
   - Description
   - Participants (42)
   - Duration (30 days)
   - Current leaderboard preview
   ↓
5. Tap "Join Challenge"
   ↓
6. Confirmation:
   "You're in! Your step count will be tracked automatically."
   [View My Progress]
   ↓
7. Dashboard now shows:
   - Challenge widget
   - Current rank
   - Today's steps toward goal
   ↓
8. Notifications:
   - Daily progress updates
   - Rank changes
   - Friend activity
   - Completion milestones
```

---

## 8. Accessibility Design

### 8.1 VoiceOver Optimizations

**Labeling Strategy**:
```
Good: "Heart rate: 72 beats per minute. Status: Normal range."
Bad:  "Heart icon. 72. BPM."

Good: "Start meditation session button"
Bad:  "Button"

Good: "Sleep quality score: 85 out of 100. Tap for details."
Bad:  "85. Tap."
```

**3D Content Descriptions**:
```
Health Landscape Volume:
"Your health landscape. A three-dimensional visualization of your overall wellness. Fitness peak shows 75% activity level. Heart lake indicates good cardiovascular health. Sleep valley shows 85% sleep quality. Tap to explore specific areas."
```

**Spatial Audio Cues**:
- Important notifications: Positioned front-center
- Secondary info: Positioned at sides
- Background elements: Ambient, non-localized

### 8.2 Alternative Interaction Modes

**Dwell Control**:
```
1. Look at button for 2 seconds
2. Progress ring fills around button
3. Auto-activates when full
4. Haptic + audio feedback
```

**Voice Control**:
```
"Tap [element name]"
"Show numbers" (displays number labels)
"Tap 7" (taps numbered element)
"Start meditation"
```

**Switch Control**:
```
Elements highlight in sequence
User triggers switch to select
Supports:
- Bluetooth switches
- Camera-based switches (head movement)
- Keyboard keys
```

### 8.3 Visual Accommodations

**High Contrast Mode**:
```
Standard:
  Background: Glass (15% opacity)
  Text: White (100% opacity)

High Contrast:
  Background: Solid (100% opacity, dark)
  Text: White (100% opacity)
  Borders: Thicker (2pt → 4pt)
  Icons: Filled versions preferred
```

**Reduce Transparency**:
```
Glass materials → Solid materials
Blur effects disabled
Opacity increased to 100%
```

**Color Blindness Modes**:
```
In addition to color:
- Icons for status (✓ ⚠ ✕)
- Patterns/textures
- Text labels
- Shape differences

Protanopia/Deuteranopia (Red-Green):
  Avoid red/green only distinctions
  Use blue/orange or shapes

Tritanopia (Blue-Yellow):
  Avoid blue/yellow only distinctions
  Use red/green or shapes
```

### 8.4 Motor Accessibility

**Larger Hit Targets**:
```
Standard: 60pt minimum
Large: 80pt for important actions
Spacing: 16pt minimum between targets
```

**Sticky Gestures**:
```
Pinch and hold → Target "sticks" to finger
No need for precise hold
Release anywhere to activate
```

**Adjustable Gesture Sensitivity**:
```
Settings → Accessibility → Gestures
├─ Pinch Sensitivity: Low/Medium/High
├─ Hold Duration: 0.5s / 1.0s / 2.0s
└─ Drag Threshold: Small/Medium/Large
```

### 8.5 Cognitive Accessibility

**Simplified Mode**:
```
Toggle: Settings → Accessibility → Simplified Mode

Changes:
- Fewer options on screen
- Larger text
- More spacing
- Clearer labels
- Step-by-step flows
- Less animation
```

**Guided Mode**:
```
Coach always visible
Provides hints:
"Look at this card to see your heart rate"
"Tap here to start meditating"
Clear next steps highlighted
```

---

## 9. Error States and Loading Indicators

### 9.1 Loading States

**Spinner** (Quick operations < 3s):
```
┌────────────────────────┐
│                        │
│        ⟳              │
│   Loading...           │
│                        │
└────────────────────────┘
```

**Progress Bar** (Longer operations):
```
┌────────────────────────┐
│  Syncing HealthKit    │
│  ████████░░░░░░  60%  │
│  Estimated: 30s        │
└────────────────────────┘
```

**Skeleton Screens** (Content loading):
```
┌────────────────────────┐
│  ▓▓▓▓▓▓▓▓▓▓▓▓        │  ← Title skeleton
│  ▓▓▓▓▓▓░░░░░░        │  ← Subtitle skeleton
│  ▓▓▓▓▓▓▓▓░░░░        │  ← Content skeleton
│                        │
│  ▓▓▓▓▓▓  ▓▓▓▓▓▓      │  ← Card skeletons
└────────────────────────┘
```

**3D Scene Loading** (Volumes/Immersive):
```
1. Low-res proxy appears immediately
2. Text/UI loads next
3. Full-res textures stream in
4. Smooth cross-fade to final

Progress indicator: Bottom-right corner
"Loading environment... 80%"
```

### 9.2 Error States

**Network Error**:
```
┌────────────────────────┐
│         ⚠️            │
│  Unable to Connect    │
│                        │
│  Check your internet  │
│  connection and try   │
│  again.                │
│                        │
│  [Retry] [Go Offline] │
└────────────────────────┘
```

**Data Sync Error**:
```
┌────────────────────────┐
│         ⚠️            │
│  Sync Failed          │
│                        │
│  Your data couldn't   │
│  sync with HealthKit. │
│                        │
│  [Try Again] [Details]│
└────────────────────────┘
```

**Permission Denied**:
```
┌────────────────────────┐
│         🔒            │
│  Permission Needed    │
│                        │
│  To track your heart  │
│  rate, grant access   │
│  to HealthKit.         │
│                        │
│  [Open Settings]      │
│  [Learn More]         │
└────────────────────────┘
```

**No Data Available**:
```
┌────────────────────────┐
│         📊            │
│  No Data Yet          │
│                        │
│  Start tracking your  │
│  health to see        │
│  insights here.        │
│                        │
│  [Get Started]        │
└────────────────────────┘
```

### 9.3 Empty States

**Empty Dashboard** (New user):
```
┌────────────────────────┐
│        👋              │
│  Welcome!              │
│                        │
│  Let's start tracking │
│  your wellness        │
│  journey.              │
│                        │
│  [Set Up Profile]     │
│  [Connect Device]     │
└────────────────────────┘
```

**No Challenges Joined**:
```
┌────────────────────────┐
│        🏆             │
│  No Active Challenges │
│                        │
│  Join a challenge to  │
│  stay motivated with  │
│  friends.              │
│                        │
│  [Browse Challenges]  │
└────────────────────────┘
```

---

## 10. Design Specifications Summary

### 10.1 Design Checklist

**Visual Design**:
- [ ] Follows visionOS Human Interface Guidelines
- [ ] Glass materials with appropriate opacity
- [ ] Minimum contrast ratio 4.5:1
- [ ] All text uses SF Pro font
- [ ] Color palette applied consistently
- [ ] Iconography from SF Symbols
- [ ] Animations are comfortable (≤0.5s)
- [ ] 3D content optimized (<100k polygons)

**Spatial Design**:
- [ ] Content placed 10-15° below eye level
- [ ] Minimum 60pt hit targets
- [ ] Appropriate depth hierarchy (Z-axis)
- [ ] Volumes sized 0.5-2m per dimension
- [ ] Immersive transitions are smooth
- [ ] Exit affordances always visible

**Interaction Design**:
- [ ] Hover effects implemented
- [ ] Immediate feedback (<50ms)
- [ ] Gesture recognition (<100ms)
- [ ] Voice commands supported
- [ ] Multi-modal interactions available

**Accessibility**:
- [ ] All elements have VoiceOver labels
- [ ] Supports Dynamic Type
- [ ] High contrast mode supported
- [ ] Reduce motion respected
- [ ] Alternative interaction methods available
- [ ] Cognitive load minimized

**Performance**:
- [ ] Maintains 90 FPS
- [ ] Render time <11ms/frame
- [ ] Memory usage <500MB
- [ ] Assets optimized (LOD, compression)
- [ ] Smooth animations (no jank)

---

## 11. Design Assets and Resources

### 11.1 Design Files

```
Design Assets
├── Figma Files
│   ├── Windows_Designs.fig
│   ├── Volume_Concepts.fig
│   ├── Immersive_Environments.fig
│   └── Component_Library.fig
│
├── 3D Models (Reality Composer Pro)
│   ├── Health_Landscape.rcproject
│   ├── Meditation_Temple.rcproject
│   ├── Virtual_Gym.rcproject
│   └── Relaxation_Beach.rcproject
│
├── Textures
│   ├── terrain_diffuse.png
│   ├── terrain_normal.png
│   ├── water_normal.png
│   └── sky_hdri.exr
│
├── Icons (SF Symbols + Custom)
│   ├── custom_health_icons.svg
│   └── 3d_icon_models/
│
└── Animation References
    ├── transition_timings.txt
    └── easing_curves.json
```

### 11.2 Style Guide Document

Create a companion style guide PDF that includes:
- Color swatches with hex/RGB values
- Typography specimens with sizing
- Component examples (buttons, cards, etc.)
- Spacing system
- Icon library
- Animation specifications
- Code snippets for common patterns

---

## Summary

This design specification provides:

1. **Spatial Design Principles**: Progressive disclosure, ergonomics, depth hierarchy
2. **Window Layouts**: Dashboard, biometrics, community, settings
3. **Volume Designs**: Health landscape, heart river, sleep globe, activity timeline
4. **Immersive Experiences**: Meditation temple, virtual gym, relaxation beach, yoga studio
5. **Interaction Patterns**: Gaze+pinch, gestures, voice commands
6. **Visual Design System**: Colors, typography, materials, iconography
7. **User Flows**: Onboarding, core flows, navigation structure
8. **Accessibility**: VoiceOver, alternatives, accommodations
9. **States**: Loading, errors, empty states
10. **Assets**: Design files, 3D models, resources

This comprehensive design guide ensures a cohesive, accessible, and delightful spatial wellness experience.
