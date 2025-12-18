# Culture Architecture System - UI/UX Design Specifications

## Document Information

**Version:** 1.0
**Last Updated:** 2025-01-20
**Platform:** Apple Vision Pro (visionOS 2.0+)
**Design System:** Culture Spatial Design Language

---

## 1. Spatial Design Principles

### 1.1 Core Design Philosophy

The Culture Architecture System transforms abstract organizational values into tangible spatial experiences. Our design philosophy centers on:

1. **Cultural Tangibility**: Make intangible culture visible and interactive
2. **Spatial Metaphors**: Use natural spatial relationships (mountains, valleys, rivers, forests)
3. **Emotional Resonance**: Design evokes appropriate emotional responses
4. **Progressive Disclosure**: Start simple, reveal complexity gradually
5. **Accessibility First**: Universal participation is non-negotiable
6. **Privacy by Design**: Visual privacy preservation in all visualizations

### 1.2 visionOS Design Principles

Following Apple's visionOS guidelines with cultural adaptations:

| Principle | Application | Cultural Context |
|-----------|-------------|------------------|
| **Familiarity** | Recognizable UI patterns | Cultural metaphors are universal |
| **Dimensionality** | Meaningful depth usage | Values have spatial relationships |
| **Immersion** | Progressive immersion levels | From dashboard to full campus |
| **Authenticity** | Real materials and physics | Culture feels genuine, not artificial |
| **Focus** | Clear visual hierarchy | Important cultural signals stand out |

### 1.3 Spatial Ergonomics

```
Optimal Viewing Zone
┌─────────────────────────────────────┐
│                                     │
│     10-15° below eye level          │
│     (comfortable viewing)           │
│                                     │
│  ┌─────────────────────────┐       │
│  │   Primary Content       │       │
│  │   (0.5m - 2m distance)  │       │
│  └─────────────────────────┘       │
│                                     │
│     Secondary Content               │
│     (2m - 5m distance)              │
│                                     │
└─────────────────────────────────────┘

Interaction Zones:
- Personal (0.5-1m): Individual actions
- Team (1-3m): Collaborative spaces
- Organization (3-10m): Campus view
```

---

## 2. Window Layouts and Configurations

### 2.1 Dashboard Window (Primary Interface)

**Dimensions**: 1200 × 800 points
**Position**: Center of user's field of view
**Material**: Glass with subtle blur

```
┌────────────────────────────────────────────────────┐
│  Culture Dashboard                           ⚙︎ ⓧ   │
├────────────────────────────────────────────────────┤
│                                                    │
│  ┌─────────────┐  ┌─────────────┐  ┌──────────┐  │
│  │ Health      │  │ Engagement  │  │ Values   │  │
│  │ Score: 85%  │  │ Score: 72%  │  │ Aligned  │  │
│  │   [Gauge]   │  │  [Chart]    │  │ [Grid]   │  │
│  └─────────────┘  └─────────────┘  └──────────┘  │
│                                                    │
│  Recent Activity                                   │
│  ┌──────────────────────────────────────────────┐ │
│  │ 🌱 Innovation +12%   │ 3 recognitions given  │ │
│  │ 🤝 Collaboration up  │ 2 rituals completed   │ │
│  └──────────────────────────────────────────────┘ │
│                                                    │
│  Quick Actions                                     │
│  [Give Recognition] [View Campus] [Team Culture]  │
│                                                    │
└────────────────────────────────────────────────────┘
```

#### Dashboard Components

**Health Score Gauge** (Large, prominent)
- Circular progress indicator
- Color-coded: Green (>80%), Yellow (60-80%), Red (<60%)
- Animated pulse when score changes
- Tap to view detailed breakdown

**Engagement Chart** (Trend visualization)
- 30-day sparkline
- Hover shows daily values
- Tap to expand full analytics window

**Values Grid** (Visual value cards)
- 3×2 grid of core values
- Each card shows:
  - Value name
  - Icon/symbol
  - Current alignment %
  - Mini trend indicator

**Activity Feed** (Scrollable list)
- Real-time cultural events
- Behavior highlights
- Recognition notifications
- Ritual completions

### 2.2 Analytics Window

**Dimensions**: 1000 × 700 points
**Style**: Detailed metrics and charts

```
┌──────────────────────────────────────────────┐
│  Cultural Analytics                     ⓧ   │
├──────────────────────────────────────────────┤
│                                              │
│  Time Range: [Last 30 Days ▾]               │
│                                              │
│  ┌──────────────────────────────────────┐   │
│  │    Engagement Trend                  │   │
│  │    ╱╲      ╱╲                        │   │
│  │   ╱  ╲    ╱  ╲    ╱╲                 │   │
│  │  ╱    ╲  ╱    ╲  ╱  ╲                │   │
│  └──────────────────────────────────────┘   │
│                                              │
│  Value Breakdown                             │
│  ┌────────────────────────────────────────┐ │
│  │ Innovation      ████████░░ 82%         │ │
│  │ Collaboration   ██████████ 95%         │ │
│  │ Trust           ███████░░░ 78%         │ │
│  │ Transparency    █████████░ 88%         │ │
│  └────────────────────────────────────────┘ │
│                                              │
│  Team Comparison                             │
│  [Bar Chart showing team health scores]     │
│                                              │
└──────────────────────────────────────────────┘
```

### 2.3 Recognition Window

**Dimensions**: 600 × 500 points
**Style**: Warm, celebratory

```
┌─────────────────────────────────────┐
│  Give Recognition               ⓧ  │
├─────────────────────────────────────┤
│                                     │
│  Who would you like to recognize?  │
│  [Search: Team member...]           │
│                                     │
│  Which value did they demonstrate? │
│  ┌──────┐ ┌──────┐ ┌──────┐        │
│  │ 🌱   │ │ 🤝   │ │ 💡   │        │
│  │Inno- │ │Collab│ │Trust │        │
│  │vation│ │      │ │      │        │
│  └──────┘ └──────┘ └──────┘        │
│                                     │
│  Share your story (optional)        │
│  ┌─────────────────────────────┐   │
│  │                             │   │
│  │                             │   │
│  └─────────────────────────────┘   │
│                                     │
│  Visibility: [Team ▾]               │
│                                     │
│        [Cancel]  [Send Recognition] │
│                                     │
└─────────────────────────────────────┘
```

---

## 3. Volume Designs (3D Bounded Spaces)

### 3.1 Team Culture Volume

**Dimensions**: 2m × 1.5m × 2m (Width × Height × Depth)
**Purpose**: Visualize team microculture

```
      ┌─────────────────────────┐
     ╱│                         │╲
    ╱ │   Team Innovation       │ ╲
   ╱  │                         │  ╲
  ╱   │    🌳  🌳  🌳  🌳       │   ╲
 ╱    │                         │    ╲
│     │    Collaboration         │     │
│     │         Bridge           │     │
│     │    ────────────          │     │
│     │                         │     │
│     │   Recognition Wall       │     │
│     │   ⭐ ⭐ ⭐ ⭐ ⭐         │     │
 ╲    │                         │    ╱
  ╲   │   Health: 87%           │   ╱
   ╲  │                         │  ╱
    ╲ │                         │ ╱
     ╲│                         │╱
      └─────────────────────────┘
```

#### Visual Elements

**Innovation Garden** (Top section)
- Trees representing active projects
- Growth animation tied to activity level
- Particle effects for "aha moments"
- Color shifts from seed → sapling → tree

**Collaboration Network** (Middle section)
- Connecting lines between team members (anonymous)
- Line thickness = collaboration frequency
- Animated pulses showing real-time interactions
- Bridge metaphor connecting subgroups

**Recognition Foundation** (Bottom section)
- Star field of recent recognitions
- Glow effect on new recognitions
- Cluster patterns show value themes
- Foundation strength visualized as solidity

### 3.2 Value Exploration Volume

**Dimensions**: 1.5m × 1.5m × 1.5m (Cube)
**Purpose**: Deep dive into single value

```
        ┌─────────────────┐
       ╱                 ╱│
      ╱   INNOVATION    ╱ │
     ╱                 ╱  │
    ╱─────────────────╱   │
   │                 │    │
   │   💡 Central    │    │
   │   Concept       │    │
   │                 │   ╱
   │   [Behaviors]   │  ╱
   │   around edge   │ ╱
   │                 │╱
   └─────────────────┘

Interaction:
- Rotate to see behaviors
- Pinch behavior to see examples
- Pull behavior to see impact
```

#### Interaction Model

1. **Enter Volume**: Value manifests as central icon
2. **Orbit**: Associated behaviors orbit the core
3. **Select Behavior**: Zoom to see real examples (anonymized)
4. **Impact View**: Visualize behavior's effect on health
5. **Practice Mode**: Interactive scenario to practice value

---

## 4. Full Space / Immersive Experiences

### 4.1 Culture Campus (Progressive Immersion)

**Experience**: Complete organizational landscape
**Immersion Level**: Progressive (adjustable)
**Duration**: 10-30 minute exploratory sessions

#### Campus Layout

```
                     ☀️  Purpose Mountain
                        (Mission Peak)
                           ⛰️
                          /  \
                         /    \
                        /      \
                    ___/        \___
                   /                \
          Innovation Forest      Trust Valley
              🌲🌲🌲               🏞️
                  |                  |
                  |                  |
        Collaboration Bridges (Network)
              ═══╪═══════════╪═══
                  |           |
                  |           |
          Recognition Plaza   Team Territories
              🎉🏛️            🏘️🏘️🏘️
```

#### Region Details

**Purpose Mountain** (Mission visualization)
- Highest point in landscape
- Glowing peak representing mission clarity
- Trails showing paths to purpose
- Viewpoint: See entire culture from here
- Audio: Inspirational echo, wind sounds

**Innovation Forest**
- Living trees = active innovation projects
- Growth tied to progress and learning
- Paths encourage exploration
- Hidden clearings for breakthrough moments
- Audio: Rustling leaves, occasional chimes
- Interaction: Plant new ideas, nurture growth

**Trust Valley**
- Flowing rivers of transparent communication
- Bridges spanning departmental gaps
- Clear water = high trust
- Murky patches = areas needing attention
- Audio: Flowing water, harmonious tones
- Interaction: Strengthen bridges, clear waters

**Collaboration Network**
- Suspended bridges connecting regions
- Thickness = collaboration frequency
- Glow = collaboration quality
- Real-time pulses = active collaboration
- Audio: Footsteps, connection sounds
- Interaction: Traverse to explore connections

**Recognition Plaza**
- Central gathering space
- Recognition wall displaying recent appreciations
- Celebration fountain (active = recent recognitions)
- Fireworks for major milestones
- Audio: Ambient celebration, applause
- Interaction: Give recognition, participate in celebrations

**Team Territories**
- Distinct neighborhoods for each team
- Architectural style reflects team personality
- Size relative to team impact
- Glow indicates team health
- Audio: Team-specific ambient sounds
- Interaction: Enter to see team culture

### 4.2 Onboarding Journey (Full Immersion)

**Experience**: New employee cultural introduction
**Immersion Level**: Full
**Duration**: 20 minutes

#### Journey Progression

**Act 1: Welcome Portal** (2 minutes)
- Fade from passthrough to culture space
- Greeting from leadership (video or avatar)
- Introduction to culture as living system
- Personal avatar creation (anonymous)

**Act 2: Values Walk** (8 minutes)
- Guided tour through each value region
- Interactive demonstrations of each value
- Stories from employees (anonymized)
- Personal reflection moments

**Act 3: Connection Moment** (5 minutes)
- Meet your team in their territory
- First recognition experience
- Join first ritual
- Plant your first contribution

**Act 4: Campus Overview** (5 minutes)
- Fly over entire landscape
- See how you fit in bigger picture
- Set personal culture intentions
- Transition back to dashboard

### 4.3 Recognition Ceremony (Mixed Immersion)

**Experience**: Team or org-wide celebration
**Immersion Level**: Mixed (virtual + passthrough)
**Duration**: 10-15 minutes

```
      🎆  Celebration Space  🎆
         (Shared Virtual)

   [Employee Avatars in Circle]
         👤 👤 👤 👤 👤
         👤       👤
         👤 👤 👤 👤 👤

    Center: Recognition Showcase
         Recognition stories
         fly to center stage
              ⭐
         Achievement unlocked
         animations play

    Background: Passthrough
    (Connected to physical world)
```

#### Ceremony Flow

1. **Gathering** (2 min): Participants appear in circle
2. **Celebration** (8 min): Recognitions showcased one by one
3. **Group Moment** (3 min): Collective celebration gesture
4. **Disperse** (2 min): Fade back to regular spaces

---

## 5. 3D Visualization Specifications

### 5.1 Cultural Health Visualization

#### Health Auroras

```
High Health (>80%)
┌─────────────────────────────────┐
│    ╱╲      ╱╲      ╱╲           │
│   ╱  ╲    ╱  ╲    ╱  ╲          │
│  ╱ 🟢 ╲  ╱ 🟢 ╲  ╱ 🟢 ╲         │
│ Vibrant, flowing, golden light  │
│ Particle density: High          │
│ Motion: Smooth, upward waves    │
└─────────────────────────────────┘

Medium Health (60-80%)
┌─────────────────────────────────┐
│    ⌇      ⌇      ⌇              │
│   🟡     🟡     🟡               │
│ Moderate glow, gentle movement  │
│ Particle density: Medium        │
│ Motion: Slow pulses             │
└─────────────────────────────────┘

Low Health (<60%)
┌─────────────────────────────────┐
│    .      .      .              │
│   🔴     🔴     🔴               │
│ Dim, static, warning signals    │
│ Particle density: Low           │
│ Motion: Irregular flickers      │
└─────────────────────────────────┘
```

### 5.2 Value Landscapes

| Value | Visual Metaphor | Material | Color Palette | Animation |
|-------|----------------|----------|---------------|-----------|
| **Innovation** | Forest/Garden | Organic, growing | Purple, green, sparkles | Growing, blooming |
| **Collaboration** | Bridges, Rivers | Flowing, connecting | Blue, silver | Pulses, flows |
| **Trust** | Foundation, Bedrock | Solid, stable | Deep blue, gold | Steady glow |
| **Transparency** | Glass, Clear Water | Transparent | Clear, white, light | Clarity waves |
| **Purpose** | Mountain Peak | Majestic, elevated | Orange, gold | Beacon pulses |
| **Diversity** | Kaleidoscope | Multifaceted | Rainbow spectrum | Prismatic shifts |

### 5.3 Connection Architecture

**Social Network Visualization**

```
       👤 ──────── 👤
        │╲       ╱│
        │ ╲    ╱  │
        │  ╲ ╱   │
        │   ╳    │
        │  ╱ ╲   │
        │ ╱   ╲  │
        │╱     ╲│
       👤 ──────── 👤

Line Properties:
- Thickness: Collaboration frequency
- Color: Relationship type
  - Blue: Peer collaboration
  - Green: Mentorship
  - Gold: Cross-functional
  - Purple: Innovation partnership
- Animation: Pulses on interaction
- Glow intensity: Relationship health
```

---

## 6. Interaction Patterns

### 6.1 Gaze and Pinch Gestures

#### Primary Interactions

| Gesture | Target | Action | Feedback |
|---------|--------|--------|----------|
| **Gaze** | Any entity | Highlight | Subtle glow |
| **Tap** | Clickable | Select/Open | Ripple effect |
| **Long Press** | Any element | Context menu | Menu appears |
| **Drag** | Movable entity | Reposition | Ghost preview |
| **Pinch** | Scalable | Resize | Size indicator |
| **Double Tap** | Info element | Expand detail | Zoom animation |

### 6.2 Hand Tracking Gestures

#### Cultural Gestures

**Planting Gesture** (Innovation)
```
Hand Position: Pinch fingers
Movement: Downward motion
Action: Plant innovation seed
Feedback: Growing plant animation
Duration: 0.5s
```

**Building Gesture** (Collaboration)
```
Hand Position: Both hands, palms facing
Movement: Spread hands apart
Action: Create/strengthen bridge
Feedback: Bridge construction animation
Duration: 1.0s
```

**Nurturing Gesture** (Support)
```
Hand Position: Open palm
Movement: Hover over element
Action: Provide positive energy
Feedback: Glowing warmth effect
Duration: 2.0s hold
```

**Celebrating Gesture** (Recognition)
```
Hand Position: Both hands raised
Movement: Quick upward thrust
Action: Trigger celebration
Feedback: Confetti/particle burst
Duration: Instant
```

### 6.3 Navigation Patterns

#### Campus Navigation

**Walking Navigation**
- Physical movement translates to virtual movement
- Speed matches comfortable walking pace
- Boundaries gently prevent edge collisions
- Mini-map available via gesture

**Teleportation**
- Long-press on distant location
- Arc trajectory preview appears
- Release to teleport
- Fade transition (no motion sickness)

**Fly-over Mode**
- Pinch + lift gesture
- Controlled elevation changes
- Bird's eye view of culture
- Return to ground via downward gesture

---

## 7. Visual Design System

### 7.1 Color Palette

#### Primary Colors (Cultural Values)

```
Innovation Purple
━━━━━━━━━━━━━━━━
Primary:   #8B5CF6 (HSL: 258, 90%, 66%)
Light:     #C4B5FD
Dark:      #6D28D9
Usage: Innovation elements, creativity

Collaboration Blue
━━━━━━━━━━━━━━━━
Primary:   #3B82F6 (HSL: 217, 91%, 60%)
Light:     #93C5FD
Dark:      #1E40AF
Usage: Bridges, connections, teamwork

Trust Gold
━━━━━━━━━━━━━━━━
Primary:   #F59E0B (HSL: 38, 92%, 50%)
Light:     #FCD34D
Dark:      #B45309
Usage: Foundations, reliability

Growth Green
━━━━━━━━━━━━━━━━
Primary:   #10B981 (HSL: 160, 84%, 39%)
Light:     #6EE7B7
Dark:      #047857
Usage: Development, progress

Transparency Clear
━━━━━━━━━━━━━━━━
Primary:   #FFFFFF with 60% opacity
Accent:    #E0F2FE
Usage: Openness, clarity
```

#### System Colors

```
Background: #000000 with 20% opacity (glass)
Surface:    #1F2937 with 80% opacity
Text:       #F9FAFB (primary)
            #D1D5DB (secondary)
Success:    #10B981
Warning:    #F59E0B
Error:      #EF4444
Info:       #3B82F6
```

### 7.2 Typography (Spatial Text Rendering)

#### Font System

```swift
// San Francisco Pro (System Font)
Title 1:      .system(size: 34, weight: .bold)
Title 2:      .system(size: 28, weight: .semibold)
Title 3:      .system(size: 24, weight: .semibold)
Headline:     .system(size: 20, weight: .semibold)
Body:         .system(size: 17, weight: .regular)
Callout:      .system(size: 16, weight: .regular)
Subhead:      .system(size: 15, weight: .regular)
Footnote:     .system(size: 13, weight: .regular)
Caption 1:    .system(size: 12, weight: .regular)
Caption 2:    .system(size: 11, weight: .regular)
```

#### Spatial Text Guidelines

- **Minimum Size**: 28pt for distant text (>2m)
- **Reading Distance**: 0.5-1.5m optimal
- **Line Height**: 1.4× font size
- **Max Line Length**: 60 characters
- **Contrast Ratio**: 7:1 minimum (WCAG AAA)

### 7.3 Materials and Lighting

#### Glass Materials (visionOS Standard)

```swift
// Dashboard window background
.background(.ultraThinMaterial)

// Volume boundaries
.background(.thinMaterial)

// Floating panels
.background(.regularMaterial)

// Heavy emphasis
.background(.thickMaterial)
```

#### 3D Materials (RealityKit)

| Material Type | Use Case | Properties |
|--------------|----------|------------|
| **Metallic** | Achievements, milestones | Roughness: 0.2, Metallic: 0.9 |
| **Glass** | Transparency visualizations | Opacity: 0.3, Refraction: 1.5 |
| **Organic** | Nature metaphors (trees, water) | Subsurface scattering |
| **Emission** | Active elements, highlights | Emission intensity: 2.0 |
| **Holographic** | Data overlays | Fresnel effect |

#### Lighting Design

```
Environment Lighting:
- Ambient: Soft, neutral (color temp 5000K)
- Directional: From above-front (simulating natural light)
- Point Lights: For emphasis and atmosphere

Region-Specific Lighting:
- Innovation Forest: Dappled, dynamic
- Trust Valley: Warm, golden
- Recognition Plaza: Bright, celebratory
- Team Territories: Customizable per team
```

### 7.4 Iconography in 3D Space

#### Icon Design Principles

1. **Recognizable**: Clear from 3m distance
2. **Simple**: Maximum 3 primary shapes
3. **Dimensional**: Subtle depth (0.1m extrusion)
4. **Consistent**: Unified style across all icons
5. **Animated**: Gentle idle animations

#### Core Icons

```
Innovation:      💡 Lightbulb (glowing, pulsing)
Collaboration:   🤝 Handshake (connecting motion)
Trust:           🛡️ Shield (protective stance)
Transparency:    🪟 Window (clarity effect)
Growth:          🌱 Seedling (growing animation)
Recognition:     ⭐ Star (sparkling)
Purpose:         🎯 Target (focusing rings)
Community:       👥 People (gathering motion)
Learning:        📚 Book (page turning)
Celebration:     🎉 Confetti (bursting)
```

---

## 8. User Flows and Navigation

### 8.1 Primary User Flows

#### Flow 1: Morning Cultural Check-in

```
1. App Launch
   ↓
2. Dashboard Loads (1s)
   ├─ Health Score prominently displayed
   ├─ Overnight changes highlighted
   └─ New recognitions notification
   ↓
3. User Reviews Changes
   ├─ Tap health score → Detailed view
   └─ Scan activity feed
   ↓
4. Quick Action
   ├─ Give recognition, or
   └─ Open campus for deeper exploration
```

#### Flow 2: Give Recognition

```
1. Dashboard → "Give Recognition" button
   ↓
2. Recognition Window Opens
   ↓
3. Search Team Member (or browse)
   ↓
4. Select Value Demonstrated
   ├─ Visual value selector
   └─ Each value shows examples
   ↓
5. Add Personal Message (optional)
   ↓
6. Choose Visibility
   ├─ Private (recipient only)
   ├─ Team
   └─ Organization
   ↓
7. Send Recognition
   ↓
8. Celebration Animation
   ├─ Confetti in window
   ├─ Recognition appears in plaza
   └─ Notification to recipient
```

#### Flow 3: Explore Culture Campus

```
1. Dashboard → "View Campus" button
   ↓
2. Transition to Immersive Space
   ├─ Fade from passthrough
   ├─ Culture campus materializes
   └─ Tutorial overlay (first time)
   ↓
3. Orientation
   ├─ Overview of regions
   ├─ Navigation instructions
   └─ Mini-map available
   ↓
4. Free Exploration
   ├─ Walk to regions
   ├─ Interact with elements
   ├─ View team territories
   └─ Discover insights
   ↓
5. Deep Dive (optional)
   ├─ Enter specific region
   ├─ View detailed analytics
   └─ Participate in activities
   ↓
6. Return
   ├─ Gesture to exit
   ├─ Fade to passthrough
   └─ Dashboard reappears
```

### 8.2 Navigation Structure

```
App Structure
├── Dashboard (Window)
│   ├── Health Overview
│   ├── Activity Feed
│   ├── Quick Actions
│   └── Settings
│
├── Analytics (Window)
│   ├── Engagement Trends
│   ├── Value Breakdown
│   ├── Team Comparisons
│   └── Custom Reports
│
├── Recognition (Window)
│   ├── Give Recognition
│   ├── View Received
│   └── Team Recognition Feed
│
├── Team Culture (Volume)
│   ├── Team Visualization
│   ├── Team Health
│   ├── Team Rituals
│   └── Team Members
│
├── Value Explorer (Volume)
│   ├── Value Deep Dive
│   ├── Behavior Examples
│   ├── Impact Visualization
│   └── Practice Scenarios
│
└── Culture Campus (Immersive)
    ├── Purpose Mountain
    ├── Innovation Forest
    ├── Trust Valley
    ├── Collaboration Bridges
    ├── Recognition Plaza
    └── Team Territories
```

---

## 9. Accessibility Design

### 9.1 VoiceOver Experience

#### Spatial Audio Cues

```
Element Type         | Audio Cue
---------------------|---------------------------
Button               | Subtle click on focus
Interactive Entity   | Gentle chime on gaze
Region Boundary      | Tone shift on crossing
Health Change        | Rising/falling tone
Recognition          | Celebration sound
Navigation           | Directional audio beacon
```

#### Descriptive Labels

```swift
// Example: Cultural region accessibility

.accessibilityLabel("Innovation Forest region")
.accessibilityValue("Health score 82%, trending up")
.accessibilityHint("Double tap to explore innovation activities. Contains 12 active projects.")
.accessibilityActions {
    Button("View Projects") { showProjects() }
    Button("View Team Activity") { showActivity() }
    Button("Navigate to Region") { navigateToRegion() }
}
```

### 9.2 Reduce Motion Alternatives

| Standard Animation | Reduce Motion Alternative |
|-------------------|---------------------------|
| Growing tree animation | Opacity fade + size change |
| Flowing river particles | Static gradient |
| Flying to location | Instant transition with fade |
| Celebration confetti | Static burst pattern |
| Health pulse | Color change only |
| Bridge construction | Fade in completed bridge |

### 9.3 Vision Accessibility

#### High Contrast Mode

- Increase contrast ratio to 10:1
- Thicker outlines on all elements
- Eliminate subtle gradients
- Brighter, more saturated colors

#### Color Blind Modes

```
Protanopia (Red-blind):
- Replace red with blue/brown
- Use patterns in addition to color

Deuteranopia (Green-blind):
- Replace green with blue/orange
- High contrast blue/yellow scheme

Tritanopia (Blue-blind):
- Replace blue with red/cyan
- Red/green color scheme
```

### 9.4 Motor Accessibility

#### Alternative Input Methods

1. **Voice Control**
   - "Show dashboard"
   - "Give recognition to [name]"
   - "Navigate to innovation forest"
   - "View team culture"

2. **Dwell Selection**
   - Gaze at element for 1.5s
   - Progress indicator appears
   - Auto-selects on completion

3. **Switch Control**
   - Single switch scanning
   - Configurable scan speed
   - Auditory feedback

### 9.5 Cognitive Accessibility

#### Simplified Mode

- Reduce visual complexity
- One concept at a time
- Larger, clearer text
- More explicit instructions
- Extended timeout periods
- Optional guided tours

---

## 10. Error States and Loading Indicators

### 10.1 Loading States

#### Dashboard Loading

```
┌────────────────────────────────────────┐
│  Culture Dashboard                 ⚙︎ ⓧ  │
├────────────────────────────────────────┤
│                                        │
│          [Animated Spinner]            │
│                                        │
│      Loading cultural insights...      │
│                                        │
│        ━━━━━━━━━━ 60%                  │
│                                        │
└────────────────────────────────────────┘
```

#### Immersive Space Loading

```
Fade from passthrough
         ↓
Translucent loading sphere
    (rotating, glowing)
         ↓
"Materializing culture campus..."
         ↓
Regions fade in one by one
         ↓
Full campus revealed
```

#### Skeleton Screens

```
Dashboard with Skeletons:
┌────────────────────────────────────────┐
│  ┌─────────────┐  ┌─────────────┐     │
│  │ ▓▓▓▓▓▓▓▓▓▓ │  │ ▓▓▓▓▓▓▓▓▓▓ │     │
│  │ ▓▓▓▓▓▓     │  │ ▓▓▓▓▓▓     │     │
│  └─────────────┘  └─────────────┘     │
│                                        │
│  ┌──────────────────────────────────┐ │
│  │ ▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓           │ │
│  │ ▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓             │ │
│  └──────────────────────────────────┘ │
└────────────────────────────────────────┘

Pulsing animation suggests loading
```

### 10.2 Error States

#### Network Error

```
┌────────────────────────────────────────┐
│            ⚠️                          │
│                                        │
│    Unable to connect to culture API    │
│                                        │
│    Working offline with cached data    │
│                                        │
│    [ Retry ]    [ View Cached Data ]   │
│                                        │
└────────────────────────────────────────┘
```

#### Data Unavailable

```
┌────────────────────────────────────────┐
│            ℹ️                          │
│                                        │
│    Team Too Small to Display           │
│                                        │
│    For privacy, teams need at least    │
│    5 members to show cultural data.    │
│                                        │
│    Current team size: 3                │
│                                        │
│         [ Understand ]                 │
│                                        │
└────────────────────────────────────────┘
```

#### Authentication Error

```
┌────────────────────────────────────────┐
│            🔒                          │
│                                        │
│    Session Expired                     │
│                                        │
│    Please sign in again to continue    │
│    accessing your culture space.       │
│                                        │
│         [ Sign In ]                    │
│                                        │
└────────────────────────────────────────┘
```

### 10.3 Empty States

#### New Organization (No Data Yet)

```
┌────────────────────────────────────────┐
│                                        │
│            🌱                          │
│                                        │
│    Welcome to Culture Architecture!    │
│                                        │
│    Your culture is just beginning      │
│    to take shape.                      │
│                                        │
│    Start by:                           │
│    • Giving your first recognition     │
│    • Exploring the culture campus      │
│    • Inviting your team                │
│                                        │
│    [ Get Started ]                     │
│                                        │
└────────────────────────────────────────┘
```

#### No Recognitions Yet

```
┌────────────────────────────────────────┐
│                                        │
│            ⭐                          │
│                                        │
│    No recognitions yet                 │
│                                        │
│    Be the first to celebrate a         │
│    team member's contribution!         │
│                                        │
│    [ Give Recognition ]                │
│                                        │
└────────────────────────────────────────┘
```

---

## 11. Animation and Transition Specifications

### 11.1 Micro-interactions

#### Button Press

```
State: Default → Pressed → Released

Default:
- Scale: 1.0
- Opacity: 1.0

Pressed (0.1s, ease-in):
- Scale: 0.95
- Opacity: 0.8

Released (0.2s, spring):
- Scale: 1.05 → 1.0
- Opacity: 1.0
- Ripple effect radiates
```

#### Health Score Update

```
Duration: 1.0s
Easing: ease-in-out

1. Current value pulses (0.2s)
2. Counter animates to new value (0.6s)
3. Color shifts if threshold crossed (0.2s)
4. Subtle particle burst for improvement
```

#### Recognition Sent

```
Duration: 2.0s
Sequence:
1. Button press animation (0.1s)
2. Recognition card forms (0.3s)
3. Card flies toward recipient (0.8s)
4. Celebration burst at destination (0.3s)
5. Window fades out (0.5s)
```

### 11.2 Scene Transitions

#### Window → Volume

```
Duration: 0.8s

1. Window scales down slightly (0.2s)
2. Volume fades in at target location (0.3s)
3. Window fades out (0.3s)
4. Volume scales to full size (0.3s, overlap)

Easing: ease-in-out with spring on final scale
```

#### Window → Immersive Space

```
Duration: 2.0s

1. All windows fade out (0.5s)
2. Passthrough gradually reduces (0.5s)
3. Culture campus fades in (0.5s)
4. Regions materialize sequentially (0.5s)

Easing: smooth ease-in-out
```

#### Immersive → Passthrough

```
Duration: 1.5s

1. Campus regions fade (0.5s)
2. Passthrough gradually returns (0.5s)
3. Dashboard window fades in (0.5s)

Easing: ease-out
```

### 11.3 Spatial Animations

#### Growing Tree (Innovation)

```
Duration: 3.0s (loop possible)

Keyframes:
0%   - Seed (small sphere)
20%  - Sprout emerges
40%  - Stem grows
60%  - Branches spread
80%  - Leaves appear
100% - Full tree, gentle sway

Easing: Natural growth curve
Particle effects: Green sparkles during growth
```

#### Flowing River (Collaboration)

```
Duration: Continuous loop

Elements:
- Water surface with animated normal map
- Particle system following river path
- Reflection of surrounding regions
- Speed varies with collaboration intensity

Fast flow = high collaboration
Slow flow = low collaboration
```

#### Bridge Construction (Connection)

```
Duration: 2.5s

Sequence:
1. Foundations appear on both ends (0.5s)
2. Cables span the gap (0.5s)
3. Deck segments build from both sides (1.0s)
4. Handrails and details added (0.5s)
5. Glow pulse confirms connection

Easing: Construction-like (linear with pauses)
```

### 11.4 Performance Guidelines

| Animation Type | Target Frame Rate | Particle Count | Polygon Budget |
|---------------|-------------------|----------------|----------------|
| **UI Micro-animations** | 90 FPS | N/A | N/A |
| **Volume Content** | 90 FPS | < 5,000 | < 50K polygons |
| **Immersive Light** | 85 FPS | < 10,000 | < 100K polygons |
| **Immersive Heavy** | 75 FPS (acceptable) | < 20,000 | < 200K polygons |

**Optimization Strategies:**
- Use LOD (Level of Detail) systems
- Particle pooling and reuse
- Occlusion culling
- Texture atlasing
- Instanced rendering for repeated elements

---

## 12. Design Tokens

### 12.1 Spacing System

```swift
// Spatial spacing (SwiftUI points)
enum Spacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
    static let xxxl: CGFloat = 64
}

// 3D spatial distances (meters)
enum SpatialDistance {
    static let intimate: Float = 0.5      // Personal space
    static let personal: Float = 1.0      // Arm's reach
    static let social: Float = 2.0        // Comfortable conversation
    static let public: Float = 5.0        // Group gathering
}
```

### 12.2 Animation Durations

```swift
enum AnimationDuration {
    static let instant: TimeInterval = 0.1
    static let fast: TimeInterval = 0.2
    static let normal: TimeInterval = 0.3
    static let slow: TimeInterval = 0.5
    static let verySlow: TimeInterval = 1.0
}
```

### 12.3 Corner Radius

```swift
enum CornerRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let full: CGFloat = 9999  // Fully rounded
}
```

---

## 13. Responsive Design

### 13.1 Window Resizing

#### Minimum Sizes

| Window | Minimum Width | Minimum Height | Optimal Size |
|--------|---------------|----------------|--------------|
| Dashboard | 800pt | 600pt | 1200 × 800pt |
| Analytics | 600pt | 500pt | 1000 × 700pt |
| Recognition | 400pt | 400pt | 600 × 500pt |
| Settings | 400pt | 400pt | 500 × 600pt |

#### Responsive Breakpoints

```
Compact (< 800pt width):
- Single column layout
- Collapsed navigation
- Larger touch targets

Regular (800-1200pt width):
- Two column layout
- Side navigation
- Standard spacing

Spacious (> 1200pt width):
- Three column layout
- Expanded panels
- Maximum information density
```

### 13.2 Volume Adaptation

Volumes maintain aspect ratio but can scale:

```
Team Culture Volume:
- Minimum: 1m × 0.75m × 1m
- Maximum: 3m × 2.25m × 3m
- Optimal: 2m × 1.5m × 2m

Content scales proportionally
Text remains readable at all sizes
Interaction targets maintain minimum 60pt
```

---

## 14. Design System Components

### 14.1 Button Styles

```swift
// Primary Action Button
.buttonStyle(.borderedProminent)
.tint(.blue)
.font(.headline)
.padding(.horizontal, 24)
.padding(.vertical, 12)

// Secondary Button
.buttonStyle(.bordered)
.tint(.secondary)

// Tertiary/Text Button
.buttonStyle(.plain)
.foregroundColor(.blue)
```

### 14.2 Card Component

```
┌──────────────────────────────┐
│  [Icon]  Title               │
│                              │
│  Content text here...        │
│                              │
│  Value: 85%                  │
│  ████████░░                  │
│                              │
│  [ Action Button ]           │
└──────────────────────────────┘

Properties:
- Background: .regularMaterial
- Corner radius: 16pt
- Padding: 20pt
- Shadow: .drop(radius: 10)
```

### 14.3 Value Badge

```
  ┌─────────────┐
  │    💡       │
  │ Innovation  │
  │    85%      │
  └─────────────┘

Properties:
- Size: 100 × 120pt
- Background: Value color with 20% opacity
- Border: 2pt, value color
- Icon: 48pt
- Text: .subheadline
```

---

## 15. Brand Guidelines

### 15.1 Logo Usage

**Primary Logo**: "Culture Architecture System"
- Wordmark with spatial culture icon
- Minimum size: 120pt wide
- Clear space: 20pt on all sides

**Symbol**: Abstract culture landscape
- Standalone icon for app
- Minimum size: 60 × 60pt

### 15.2 Voice and Tone

**Design Voice**: Warm, encouraging, insightful

**UI Copy Guidelines**:
- Conversational but professional
- Use "we" and "together" (collective)
- Celebrate achievements warmly
- Be honest about challenges
- Avoid jargon, explain clearly
- Active voice preferred

**Examples**:
- ✅ "Your team's collaboration is thriving!"
- ❌ "Collaboration metrics above threshold"
- ✅ "Let's strengthen trust together"
- ❌ "Trust index requires improvement"

---

## Appendix A: Design Checklist

### Pre-Implementation Review

- [ ] All layouts tested at minimum sizes
- [ ] Color contrast meets WCAG AAA (7:1)
- [ ] All interactive elements have hover states
- [ ] VoiceOver labels for all UI elements
- [ ] Reduce Motion alternatives provided
- [ ] Loading states designed
- [ ] Error states designed
- [ ] Empty states designed
- [ ] Animations stay at 90 FPS
- [ ] Hit targets minimum 60pt
- [ ] Text readable at 2m distance
- [ ] Privacy preserved in visualizations
- [ ] K-anonymity respected (min 5 people)

---

## Appendix B: Design Resources

### Figma Files
- `CultureSystem_DesignSystem.fig` - Component library
- `CultureSystem_Windows.fig` - 2D window designs
- `CultureSystem_Immersive.fig` - 3D space concepts
- `CultureSystem_Flows.fig` - User flow diagrams

### Asset Library
- `/Assets/Icons/` - All iconography (SF Symbols + custom)
- `/Assets/3DModels/` - Cultural landscape models (.usdz)
- `/Assets/Textures/` - Materials and textures
- `/Assets/Animations/` - Animation references
- `/Assets/Audio/` - Spatial audio files

---

**Document Version History**

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 1.0 | 2025-01-20 | Initial design specification | Claude AI |

---

*This design specification ensures a cohesive, accessible, and delightful spatial experience for the Culture Architecture System. All implementation should reference this document for visual and interaction standards.*
