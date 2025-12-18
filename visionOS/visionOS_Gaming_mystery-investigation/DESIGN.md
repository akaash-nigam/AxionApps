# Mystery Investigation - Game Design & UI/UX Specification

## Document Information
- **Version**: 1.0
- **Last Updated**: January 2025
- **Purpose**: Game Design Document (GDD) and UI/UX Specifications
- **Audience**: Design Team, Development Team, UX Researchers

---

## 1. Game Design Document (GDD)

### Core Concept
Mystery Investigation is a spatial detective game where players solve crimes in their own living space. Evidence appears anchored to physical surfaces, suspects materialize as holograms, and logical deduction drives progression rather than action reflexes.

### Game Pillars
1. **Authentic Investigation**: Realistic detective procedures and forensic science
2. **Spatial Immersion**: Physical space becomes part of the crime scene
3. **Logical Deduction**: Thoughtful analysis over rapid reactions
4. **Educational Value**: Learn real forensic techniques while playing

---

## 2. Core Gameplay Loop

### Primary Loop (Per Case)
```
┌─────────────────────────────────────────────┐
│  1. Case Introduction                        │
│     - Receive briefing                       │
│     - Crime scene materializes               │
│     - Initial clues revealed                 │
└─────────┬───────────────────────────────────┘
          │
          ▼
┌─────────────────────────────────────────────┐
│  2. Evidence Collection                      │
│     - Search physical space                  │
│     - Discover hidden clues                  │
│     - Use forensic tools                     │
│     - Document findings                      │
└─────────┬───────────────────────────────────┘
          │
          ▼
┌─────────────────────────────────────────────┐
│  3. Analysis & Deduction                     │
│     - Examine evidence in detail             │
│     - Connect relationships                  │
│     - Build theories                         │
│     - Test hypotheses                        │
└─────────┬───────────────────────────────────┘
          │
          ▼
┌─────────────────────────────────────────────┐
│  4. Interrogation                            │
│     - Question suspects                      │
│     - Present evidence                       │
│     - Detect deception                       │
│     - Extract confessions                    │
└─────────┬───────────────────────────────────┘
          │
          ▼
┌─────────────────────────────────────────────┐
│  5. Case Solution                            │
│     - Identify perpetrator                   │
│     - Explain motive & method                │
│     - Reconstruct timeline                   │
│     - Receive evaluation                     │
└─────────────────────────────────────────────┘
```

### Secondary Loops
- **Skill Mastery**: Improve forensic techniques across cases
- **Tool Unlock**: Gain access to advanced investigation equipment
- **Achievement Collection**: Complete challenges and earn badges
- **Case Creation**: Build custom mysteries for others (post-launch)

---

## 3. Player Progression Systems

### Detective Rank Progression
```
Rookie Detective (0-5 cases)
    ├── Learn basic evidence collection
    ├── Simple linear cases
    └── Tutorial hints frequent

Junior Detective (6-15 cases)
    ├── Multi-suspect scenarios
    ├── Introduction to red herrings
    └── Reduced hint availability

Senior Detective (16-30 cases)
    ├── Complex timeline reconstruction
    ├── Multiple solution paths
    └── Advanced forensic tools

Master Detective (31-50 cases)
    ├── Expert-level cases
    ├── Minimal hints
    └── Community recognition

Legendary Investigator (50+ cases)
    ├── Procedural case generation
    ├── Case creation tools
    └── Mentorship system
```

### Skill Trees
#### Investigation Skills
- **Evidence Spotting**: Improved highlight range and visual cues
- **Forensic Analysis**: Faster tool usage and more detailed results
- **Spatial Memory**: Remember evidence locations across sessions
- **Pattern Recognition**: Connect clues more efficiently

#### Interrogation Skills
- **Psychological Reading**: Better suspect emotion detection
- **Strategic Questioning**: Unlock advanced dialogue options
- **Evidence Presentation**: More effective confrontation techniques
- **Confession Extraction**: Higher success rate on guilty suspects

#### Deduction Skills
- **Logical Reasoning**: Eliminate impossible scenarios faster
- **Timeline Construction**: Accurate event sequencing
- **Motive Analysis**: Identify true motivations vs. red herrings
- **Theory Testing**: Validate hypotheses more efficiently

---

## 4. Case Structure & Design

### Case Difficulty Levels

#### Beginner Cases
```yaml
Difficulty: ⭐ (1/5)

Characteristics:
  - Linear investigation path
  - 3-4 suspects maximum
  - Clear evidence trail
  - Minimal red herrings (10%)
  - Obvious culprit indicators
  - 20-30 minute completion time

Evidence Count: 8-12 pieces
Forensic Tools Required: 1-2
Interrogation Complexity: Simple dialogue trees
Solution Paths: 1 primary path

Educational Focus:
  - Basic evidence collection
  - Simple deduction logic
  - Forensic tool introduction
```

#### Intermediate Cases
```yaml
Difficulty: ⭐⭐⭐ (3/5)

Characteristics:
  - Multiple investigation paths
  - 5-6 suspects
  - Some misleading evidence
  - Moderate red herrings (25%)
  - Requires timeline reconstruction
  - 45-60 minute completion time

Evidence Count: 15-20 pieces
Forensic Tools Required: 3-4
Interrogation Complexity: Branching dialogues
Solution Paths: 2-3 viable approaches

Educational Focus:
  - Evidence correlation
  - Alibi verification
  - Advanced forensics
```

#### Expert Cases
```yaml
Difficulty: ⭐⭐⭐⭐⭐ (5/5)

Characteristics:
  - Non-linear investigation
  - 6-8 suspects
  - Complex evidence relationships
  - Heavy red herrings (40%)
  - Multiple timeline threads
  - 90-120 minute completion time

Evidence Count: 25-35 pieces
Forensic Tools Required: All available
Interrogation Complexity: Deep psychological gameplay
Solution Paths: Multiple valid conclusions

Educational Focus:
  - Complex deduction
  - Forensic science mastery
  - Investigative procedures
```

### Case Theme Categories
1. **Classic Whodunit**: Traditional murder mysteries
2. **Theft & Burglary**: Property crime investigations
3. **Conspiracy Thriller**: Multi-layer plots with twists
4. **Cold Cases**: Historical investigations (educational)
5. **Forensic Focus**: Cases centered on specific techniques
6. **Psychological Mystery**: Character-driven investigations

---

## 5. Spatial Gameplay Design

### Evidence Placement Strategy

#### Spatial Distribution Principles
```
Physical Surface Integration:
  - Floor: Footprints, dropped items, blood spatter
  - Tables/Desks: Documents, small objects, fingerprints
  - Walls: Bullet holes, blood spatter, hanging evidence
  - Vertical surfaces: Photos, notes, scratches
  - Ceiling: Overhead clues (rare, for expert cases)

Distance Zones:
  - Near (0-1m): Detailed examination items
  - Mid (1-3m): Primary evidence locations
  - Far (3-5m): Context and scene-setting clues

Difficulty Scaling:
  - Beginner: Evidence at eye level, obvious placement
  - Advanced: Hidden under/behind furniture
  - Expert: Requires room-scale exploration
```

#### Evidence Visibility States
1. **Obvious**: Immediately visible, glowing indicator
2. **Hinted**: Subtle particle effect when nearby
3. **Hidden**: Requires specific viewing angle or tool
4. **Revealed**: Discovered through other evidence correlation

### Room Adaptation System
```swift
// Algorithm adapts evidence placement to room size

Room Size: Small (2m × 2m)
    → Evidence clustered densely
    → Vertical space utilized
    → Focus on detail examination

Room Size: Medium (3m × 3m)
    → Balanced distribution
    → Some room-scale searching
    → Mix of close and distant clues

Room Size: Large (5m × 5m)
    → Wide evidence distribution
    → Emphasis on spatial exploration
    → Multi-area investigation zones
```

---

## 6. UI/UX Design for Spatial Computing

### UI Hierarchy & Layers

#### Layer 1: World-Anchored UI (Crime Scene)
```
┌─────────────────────────────────────────────┐
│  Physical Space Integration                  │
│                                              │
│  [Evidence Markers] ← Floating labels        │
│  [Timeline Markers] ← Historical event points│
│  [Suspect Holograms] ← Life-sized NPCs       │
│  [Tool Highlights] ← Active forensic tools   │
└─────────────────────────────────────────────┘

Design Principles:
  - Minimal visual clutter
  - Context-sensitive appearance
  - Natural depth positioning
  - Physical surface alignment
```

#### Layer 2: Head-Locked UI (HUD)
```
┌─────────────────────────────────────────────┐
│                                              │
│  [Case Objective]                            │
│  Top-center, subtle                          │
│                                              │
│                                    [Tools]   │
│                              Right periphery │
│                                              │
│  [Evidence Count]                            │
│  Bottom-left corner                          │
└─────────────────────────────────────────────┘

Design Principles:
  - Peripheral placement (not central)
  - Semi-transparent (0.6 opacity)
  - Auto-hide when not needed
  - Comfortable reading distance (1.5m)
```

#### Layer 3: Hand-Anchored UI (Contextual)
```
Investigation Notebook:
  - Appears near left hand
  - Always accessible with gesture
  - Contains case notes and evidence log
  - Flippable pages with natural physics

Forensic Tools:
  - Holstered around player waist
  - Grabbable with pinch gesture
  - Tool belt metaphor
  - Haptic feedback on selection
```

### Color Palette & Visual Language

#### Color System
```
Primary Colors:
  - Investigation Blue: #2E5EAA (UI primary)
  - Evidence Amber: #FFB800 (Highlighting)
  - Critical Red: #D32F2F (Important findings)
  - Success Green: #388E3C (Correct deductions)

Neutral Colors:
  - Charcoal: #424242 (UI background)
  - Steel Gray: #78909C (Secondary text)
  - Paper White: #FAFAFA (Main text)
  - Shadow: #000000, 0.3 alpha (Depth)

Semantic Colors:
  - Guilty Red: #C62828 (Suspect indicator)
  - Innocent Blue: #1976D2 (Cleared suspect)
  - Uncertain Yellow: #F9A825 (Needs investigation)
  - Evidence Found: #66BB6A (Collected item)
```

#### Typography
```
Primary Font: SF Pro Rounded
  - Friendly, approachable detective theme
  - Excellent legibility in spatial context

Heading Sizes:
  - H1 (Case Title): 48pt, Bold
  - H2 (Section): 36pt, Semibold
  - H3 (Subsection): 28pt, Medium
  - Body: 20pt, Regular
  - Caption: 16pt, Light

Spatial Considerations:
  - All text readable from 1.5m distance
  - High contrast (4.5:1 minimum)
  - No text smaller than 14pt
  - Dynamic scaling based on distance
```

---

## 7. Spatial UI Components

### Evidence Marker System
```
Standard Evidence Marker:
┌─────────────────┐
│ [Icon]          │  ← Evidence type icon
│ Evidence Name   │  ← Clear label
│ [Distance: 2m]  │  ← Optional distance
└─────────────────┘

States:
  - Undiscovered: Invisible or very subtle shimmer
  - Nearby: Faint glow, increases with proximity
  - Gazed: Full opacity, pulsing highlight
  - Examined: Checkmark icon, muted appearance
  - Critical: Red border, persistent highlight

Animation:
  - Idle: Gentle float (±5cm vertical)
  - Attention: Pulse scale (1.0 → 1.1 → 1.0)
  - Discovered: Expand from point (0.5s spring)
```

### Investigation Dashboard
```
Floating Window (Optional - Toggled)
┌─────────────────────────────────────┐
│  ACTIVE CASE: The Vanished Heir    │
│  ─────────────────────────────────  │
│                                     │
│  Evidence Collected: 12/18          │
│  [████████░░░░] 67%                 │
│                                     │
│  Suspects Interviewed: 3/5          │
│  [██████░░░░░░] 60%                 │
│                                     │
│  Objectives:                        │
│  ✓ Examine crime scene              │
│  ✓ Collect fingerprint evidence     │
│  → Interview the butler             │
│  ○ Reconstruct timeline             │
└─────────────────────────────────────┘

Interaction:
  - Gaze + pinch to open/close
  - Drag to reposition
  - Pinch zoom to resize
  - Follows player at comfortable distance
```

### Evidence Examination View
```
When examining evidence in detail:

┌─────────────────────────────────────────┐
│  3D Model (Rotatable)                   │
│  ┌─────────────────┐                    │
│  │                 │                    │
│  │   [Evidence]    │  ← 360° rotation  │
│  │                 │     Pinch to zoom │
│  └─────────────────┘                    │
│                                         │
│  Name: Bloody Knife                     │
│  Type: Weapon                           │
│  Location Found: Kitchen Counter        │
│                                         │
│  [Forensic Analysis]                    │
│  • Blood Type: AB+                      │
│  • Fingerprints: 2 partial matches      │
│  • Material: Stainless steel            │
│                                         │
│  Related Suspects: [2 connections]      │
│  [View Connections] [Add to Theory]     │
└─────────────────────────────────────────┘
```

---

## 8. Suspect Hologram Design

### Visual Design
```
Hologram Appearance:
  - Semi-transparent (0.7-0.9 opacity)
  - Subtle scan lines (retro-futuristic)
  - Blue-tinted lighting
  - Particle effects at edges
  - Life-sized scale (1:1)

Emotional States (Visual):
  Calm:
    - Steady posture
    - Normal opacity (0.8)
    - Slow breathing animation

  Nervous:
    - Fidgeting hands
    - Opacity flicker (0.7-0.8)
    - Faster breathing
    - Avoiding eye contact

  Defensive:
    - Crossed arms
    - Increased opacity (0.9)
    - Rigid posture
    - Intense gaze

  Guilty/Breaking:
    - Hunched shoulders
    - Opacity pulsing
    - Hand to face gestures
    - Downward gaze
```

### Interrogation UI
```
During Suspect Interview:

┌─────────────────────────────────────────┐
│  INTERROGATING: James Butler            │
│  Stress Level: [███████░░░] High (75%) │
│  ─────────────────────────────────────  │
│                                         │
│  Suspect: "I was in the library all    │
│           evening, I swear!"            │
│                                         │
│  Your Response:                         │
│  → "Tell me about your alibi"           │
│  → "Where were you at 9 PM?"            │
│  → [Present: Bloody Knife] 🔓          │
│  → [Present: Butler's Fingerprint] 🔒  │
│                                         │
│  Notes: Seems nervous about timeline   │
└─────────────────────────────────────────┘

Indicators:
  🔓 = Available (evidence collected)
  🔒 = Locked (missing evidence)
  → = Selected option
  ○ = Available option
```

---

## 9. Forensic Tool UI Design

### Magnifying Glass
```
Visual Design:
  - Realistic magnifying lens (15cm diameter)
  - Wooden/brass handle
  - Glass shader with refraction
  - Held naturally in hand

UI Overlay:
┌───────────────┐
│  ╭─────────╮  │
│ │           │ │ ← Magnified view
│ │  Detail   │ │   (2x, 5x, or 10x)
│ │           │ │
│  ╰─────────╯  │
│ Zoom: 5x      │ ← Current level
│ [Tap to cycle]│
└───────────────┘

Interaction:
  - Pinch and hold to use
  - Move near evidence
  - Tap lens to change zoom
  - Reveals micro-evidence
```

### UV Light
```
Visual Design:
  - Flashlight form factor
  - Purple/black light beam
  - Realistic cone projection
  - Volumetric light shaft

Effect:
  - Reveals hidden evidence (blood, fluids)
  - Glowing evidence under UV
  - Real-time shader effect
  - Satisfying discovery moment

UI Indicator:
  [UV Mode Active]
  Battery: [████░] 80%
  Duration: Unlimited (spatial game)
```

### Fingerprint Kit
```
Visual Design:
  - Brush + powder container
  - Realistic dusting animation
  - Progressive reveal mechanic
  - Satisfying tactile feedback

UI Overlay:
┌─────────────────┐
│ Dusting...      │
│ [████████░░] 75%│
│                 │
│ Hold steady     │
│ Continue motion │
└─────────────────┘

Interaction:
  - Brush motion over surface
  - Powder appears on contact
  - Fingerprint slowly revealed
  - Photo capture when complete
```

---

## 10. Case Board / Theory Building

### Spatial Mind Map UI
```
Virtual Cork Board (Floating)
┌─────────────────────────────────────────┐
│  CASE THEORY: Who Killed John Doe?     │
│  ─────────────────────────────────────  │
│                                         │
│      [Victim]                           │
│         │                               │
│    ┌────┴────┐                          │
│    │         │                          │
│ [Wife]   [Business                      │
│    │     Partner]                       │
│    │         │                          │
│ [Motive:  [Motive:                      │
│  Money]   Debt]                         │
│    │         │                          │
│    └────┬────┘                          │
│         │                               │
│    [Evidence]                           │
│         │                               │
│    [Bloody Knife]                       │
│         │                               │
│    [Fingerprints → Wife]                │
│                                         │
│  Confidence: [███████░░░] 70%          │
│                                         │
│  [Test Theory] [Save Draft]             │
└─────────────────────────────────────────┘

Interaction:
  - Drag evidence to board
  - Draw connections with finger
  - Auto-arrangement algorithm
  - Color-coded relationships
  - Confidence meter updates
```

---

## 11. Menu Systems

### Main Menu
```
Immersive Environment: Detective Office
┌─────────────────────────────────────────┐
│                                         │
│      MYSTERY INVESTIGATION              │
│      ──────────────────                 │
│                                         │
│      ▶ Start New Case                   │
│      ⟳ Continue Investigation           │
│      📁 Case Archives                    │
│      ⚙️  Settings                        │
│      🏆 Achievements                     │
│      👥 Multiplayer                      │
│      ❓ How to Play                      │
│                                         │
│      Version 1.0                        │
└─────────────────────────────────────────┘

Environment Details:
  - Warm desk lamp lighting
  - Case files scattered on desk
  - Evidence board in background
  - Soft jazz music (optional)
  - Rain on window ambiance
```

### Case Selection
```
┌─────────────────────────────────────────┐
│  AVAILABLE CASES                        │
│  ─────────────────────────────────────  │
│                                         │
│  [Case Card]                            │
│  ┌─────────────────┐                    │
│  │ Case #001       │                    │
│  │ The Vanished    │  Difficulty: ⭐⭐   │
│  │ Heir            │  Time: 45-60 min  │
│  │                 │  Status: New       │
│  └─────────────────┘                    │
│  "A wealthy heir disappears..."         │
│                                         │
│  [Case Card]                            │
│  ┌─────────────────┐                    │
│  │ Case #002       │                    │
│  │ Deadly Reunion  │  Difficulty: ⭐⭐⭐  │
│  │                 │  Time: 60-90 min  │
│  │                 │  Status: 67% ✓    │
│  └─────────────────┘                    │
│  "Continue your investigation..."       │
│                                         │
│  [← Back] [Filter ▼] [Sort ▼]          │
└─────────────────────────────────────────┘

Interaction:
  - Gaze + pinch to select
  - Swipe to scroll cases
  - Filter by difficulty/status
  - Preview case details
```

### Pause Menu
```
In-Game Overlay (Translucent)
┌─────────────────────────────────────────┐
│  ⏸ PAUSED                                │
│  ─────────────────────────────────────  │
│                                         │
│  ▶ Resume Investigation                 │
│  💾 Save Progress                        │
│  📋 Review Evidence                      │
│  📖 Case Notes                           │
│  💡 Request Hint (3 available)          │
│  ⚙️  Settings                            │
│  🚪 Abandon Case                         │
│  🏠 Return to Main Menu                  │
│                                         │
│  Time Elapsed: 32:15                    │
│  Progress: 45%                          │
└─────────────────────────────────────────┘

Features:
  - Crime scene frozen in background
  - Semi-transparent overlay
  - Quick save/load
  - Hint system with cost
```

---

## 12. Tutorial & Onboarding

### First-Time Experience Flow
```
Step 1: Welcome & Comfort Setup (2 min)
  ├── Adjust play area boundaries
  ├── Comfort settings (seated/standing)
  └── Control scheme selection

Step 2: Spatial Basics (3 min)
  ├── Hand tracking calibration
  ├── Gaze interaction practice
  └── Voice command introduction

Step 3: Evidence Collection (5 min)
  ├── Find first evidence (highlighted)
  ├── Pick up and examine
  ├── Use magnifying glass
  └── Document in evidence log

Step 4: Interrogation Intro (5 min)
  ├── Meet first suspect hologram
  ├── Ask basic questions
  ├── Present evidence
  └── Observe reactions

Step 5: Case Solving (10 min)
  ├── Build theory on case board
  ├── Connect evidence and suspects
  ├── Make accusation
  └── See case resolution

Total Tutorial: ~25 minutes (skippable)
```

### Progressive Complexity
```
Tutorial Case (Case #000):
  - 1 obvious culprit
  - 5 pieces of evidence (all highlighted)
  - 2 suspects (one clearly guilty)
  - Linear path to solution
  - Constant helpful hints
  - No red herrings

First Real Case (Case #001):
  - Tutorial wheels removed gradually
  - 3 suspects, less obvious
  - 10 evidence pieces, some hidden
  - Minimal hints available
  - Few red herrings (15%)

By Case #005:
  - Full game mechanics enabled
  - Player expected to be competent
  - Hints available but costly
  - Standard difficulty curve
```

---

## 13. Audio Design

### Music System
```
Dynamic Soundtrack Layers:

Investigation Phase:
  - Base: Ambient pads (mysterious atmosphere)
  - Layer 2: Subtle piano melody (thoughtful)
  - Layer 3: Light percussion (building tension)

Evidence Discovery:
  - Stinger: Discovery chime
  - Brief musical flourish
  - Returns to investigation music

Interrogation:
  - Base: Tense strings
  - Layer: Rhythmic pulse (heartbeat)
  - Intensity scales with suspect stress

Case Solution:
  - Success: Triumphant orchestral
  - Failure: Somber strings
  - Revelation: Dramatic crescendo

Adaptive System:
  - Music responds to player progress
  - Tension increases when stuck
  - Calms during examination phases
```

### Sound Effects (SFX)

#### Evidence SFX
```
Pickup: Soft whoosh + material sound
  - Paper: Rustle
  - Metal: Light clink
  - Glass: Delicate chime

Examination: Contextual sounds
  - Magnifying: Subtle glass tone
  - UV Light: Electrical hum
  - Fingerprint: Brush swishes

Discovery: Rewarding chime
  - Major evidence: Rich bell tone
  - Minor clue: Subtle ping
  - Critical find: Orchestral hit
```

#### UI SFX
```
Menu Navigation:
  - Selection: Soft click
  - Hover: Quiet tone
  - Confirmation: Satisfying thunk
  - Error: Gentle negative sound

Notifications:
  - New objective: Chime
  - Hint available: Gentle bell
  - Progress milestone: Flourish
```

#### Spatial Audio (3D)
```
Crime Scene Ambiance:
  - Position: All around player
  - Examples: Ticking clock, rain outside, creaky floors

Suspect Voice:
  - Position: From hologram location
  - Realistic distance attenuation
  - Spatial dialogue mixing

Evidence Audio Cues:
  - Position: At evidence location
  - Subtle audio hints (e.g., ticking watch)
  - Guides player attention spatially
```

---

## 14. Accessibility Design

### Visual Accessibility
```
Color Blindness Support:
  - Pattern overlays in addition to color
  - Configurable color schemes
  - High contrast mode
  - Shape-based evidence indicators

Text Scaling:
  - All text dynamically sizeable
  - Minimum 14pt, maximum 36pt
  - Maintains layout integrity
  - Distance-adaptive sizing

Low Vision:
  - Enhanced evidence outlines
  - Audio descriptions of visual elements
  - Haptic feedback for guidance
  - Simplified visual mode
```

### Motor Accessibility
```
One-Handed Mode:
  - All gestures doable with single hand
  - Alternative to two-hand spread
  - Longer dwell times for selection
  - Reduced precision requirements

Simplified Gestures:
  - Replace complex motions
  - Gaze-only control option
  - Voice command alternatives
  - Controller support

Seated Play:
  - Evidence comes to player
  - No room-scale requirement
  - Comfortable reach distances
  - Adjustable play area height
```

### Cognitive Accessibility
```
Difficulty Adjustments:
  - Extended hint system
  - Evidence highlighting always on
  - Simplified dialogue trees
  - Linear investigation paths

Content Warnings:
  - Violence level settings
  - Graphic content toggle
  - Sensitive topic filters
  - Age-appropriate mode

Pacing Options:
  - No time limits
  - Unlimited saves
  - Pausable interrogations
  - Adjustable text speed
```

---

## 15. Difficulty & Balancing

### Adaptive Difficulty System
```swift
// System monitors player performance
Performance Metrics:
  - Evidence discovery speed
  - Correct deduction rate
  - Hint usage frequency
  - Case completion time

Adjustments Applied:
  Low Performance:
    → Increase evidence visibility
    → Provide more hints
    → Reduce red herrings
    → Simplify next case

  High Performance:
    → Subtle evidence placement
    → Fewer hints available
    → More red herrings
    → Unlock harder cases

  Balanced Performance:
    → Standard difficulty maintained
    → Gradual complexity increase
    → Skill-appropriate challenges
```

### Challenge Balance
```
Evidence Placement Balance:
  - 70% findable with normal exploration
  - 20% requires careful searching
  - 10% needs forensic tools or hints

Red Herring Ratio:
  - Beginner: 10% misleading evidence
  - Intermediate: 25% misleading
  - Expert: 40% misleading

Hint System:
  - 3 free hints per case
  - Additional hints cost progress (reduce final score)
  - Hints progressively more specific
  - Never give away complete solution
```

---

## 16. Polish & Game Feel

### Juice Elements
```
Evidence Discovery:
  - Particle burst effect
  - Satisfying sound
  - Haptic pulse
  - Brief slow-motion
  - Camera subtle zoom

Correct Deduction:
  - Connection line animation
  - Evidence pieces snap together
  - Confidence meter jump
  - Positive audio cue
  - Visual celebration

Confession Moment:
  - Dramatic camera focus
  - Lighting change
  - Background blur
  - Powerful music swell
  - Hologram opacity increase

Case Solved:
  - Fireworks particle effect
  - Achievement unlock animation
  - Statistics display
  - Rating reveal (S, A, B, C)
  - Unlock next case animation
```

### Animation Principles
```
Evidence Pickup:
  - Anticipation: Slight pull before pickup
  - Action: Smooth arc to hand
  - Follow-through: Gentle settle in hand
  - Total duration: 0.5 seconds

Hologram Appearance:
  - Materialize from floor up
  - Scan line effect
  - Opacity fade-in (0 → 0.8)
  - Audio materialization sound
  - Total duration: 1.5 seconds

UI Transitions:
  - Ease-in-out curves
  - Overshoot on important actions
  - Spring physics for natural feel
  - Respect user comfort (no jarring motion)
```

---

## 17. Social & Multiplayer UX

### Co-op Investigation UI
```
Shared Evidence View:
┌─────────────────────────────────────────┐
│  TEAM INVESTIGATION                     │
│  ─────────────────────────────────────  │
│                                         │
│  Team Members: [2/4]                    │
│  • You (Lead Detective)                 │
│  • Sarah (Forensic Specialist) 🎤       │
│                                         │
│  Shared Evidence: 15/18                 │
│  • 8 found by you                       │
│  • 7 found by Sarah                     │
│                                         │
│  Active Task: Interview butler          │
│  Sarah is examining fingerprints...     │
│                                         │
│  [Voice Chat: On] [Share Screen]        │
└─────────────────────────────────────────┘

Features:
  - Real-time evidence sync
  - Role-based responsibilities
  - Shared case board
  - Spatial voice chat
  - Player location indicators
```

### Player Avatars (Multiplayer)
```
Simple Representation:
  - Detective badge floating at chest level
  - Player name above badge
  - Animated hand ghosts (semi-transparent)
  - Audio indicator when speaking
  - Tool/evidence currently held

Not Full Body:
  - Keeps focus on investigation
  - Reduces uncanny valley
  - Better performance
  - More comfortable for players
```

---

## 18. Settings & Customization

### Game Settings Menu
```
┌─────────────────────────────────────────┐
│  SETTINGS                                │
│  ─────────────────────────────────────  │
│                                         │
│  📺 Display                              │
│    ├─ UI Scale: [────●──] 125%          │
│    ├─ UI Distance: [───●───] 1.5m       │
│    └─ Text Size: [────●──] Large        │
│                                         │
│  🎮 Controls                             │
│    ├─ Hand Tracking: ✓ On               │
│    ├─ Eye Tracking: ✓ On                │
│    ├─ Voice Commands: ✓ On              │
│    ├─ Gaze Dwell Time: [──●────] 0.5s   │
│    └─ Haptic Feedback: [─────●─] 80%    │
│                                         │
│  🔊 Audio                                │
│    ├─ Master Volume: [────●──] 75%      │
│    ├─ Music: [───●───] 60%              │
│    ├─ SFX: [────●──] 80%                │
│    ├─ Dialogue: [─────●─] 90%           │
│    └─ Spatial Audio: ✓ On               │
│                                         │
│  ♿ Accessibility                         │
│    ├─ Color Blind Mode: Off ▼           │
│    ├─ One-Handed Mode: ○ Off            │
│    ├─ Seated Mode: ○ Off                │
│    ├─ Hint Frequency: Normal ▼          │
│    └─ Content Filters: Configure →      │
│                                         │
│  🌐 Language: English (US) ▼             │
│  💾 Cloud Save: ✓ iCloud Enabled         │
│  🔒 Privacy: Manage Data →               │
│                                         │
│  [Restore Defaults] [Apply] [Cancel]    │
└─────────────────────────────────────────┘
```

---

## 19. Monetization UX

### Premium Content Display
```
Case Expansion Pack:
┌─────────────────────────────────────────┐
│  🔒 HISTORICAL MYSTERIES PACK            │
│  ─────────────────────────────────────  │
│                                         │
│  [Preview Image]                        │
│                                         │
│  Includes 5 Cases:                      │
│  • The Ripper Returns (Victorian)       │
│  • Chicago Speakeasy Murder (1920s)     │
│  • Cold War Conspiracy (1960s)          │
│  • Art Heist in Paris (1980s)           │
│  • Bonus: The Unsolved File             │
│                                         │
│  Educational Content:                   │
│  ✓ Historical forensic techniques       │
│  ✓ Period-accurate investigations       │
│  ✓ Real historical context              │
│                                         │
│  $14.99                                 │
│  [Purchase] [Preview Cases]             │
│  4.8 ⭐ (2,453 reviews)                  │
└─────────────────────────────────────────┘

Principles:
  - No aggressive upselling
  - Try before buy (previews)
  - Clear value proposition
  - No pay-to-win mechanics
  - Optional, enriching content
```

---

## 20. Player Feedback Systems

### Progress Indicators
```
Case Completion Screen:
┌─────────────────────────────────────────┐
│  CASE SOLVED! 🎉                         │
│  ─────────────────────────────────────  │
│                                         │
│  The Vanished Heir                      │
│  Culprit: Butler James                  │
│                                         │
│  Performance Rating: A                  │
│  ⭐⭐⭐⭐⭐                                 │
│                                         │
│  Statistics:                            │
│  • Time: 42:15 (Fast!)                  │
│  • Evidence: 16/18 (89%)                │
│  • Deductions: 8/10 correct             │
│  • Hints Used: 1                        │
│                                         │
│  Achievements Unlocked:                 │
│  🏆 Speed Sleuth - Complete under 45min │
│                                         │
│  XP Earned: +350                        │
│  Rank Progress: [████████░░] 82% to     │
│                 Senior Detective        │
│                                         │
│  [View Case Summary] [Next Case]        │
└─────────────────────────────────────────┘
```

---

## Conclusion

This design document provides comprehensive specifications for creating an engaging, accessible, and immersive detective experience on Vision Pro. The design prioritizes:

1. **Spatial Intuition**: Natural interactions that leverage 3D space
2. **Player Comfort**: Extended play sessions without fatigue
3. **Progressive Complexity**: Gentle learning curve with deep mastery
4. **Educational Value**: Real forensic science principles
5. **Accessibility**: Inclusive design for all players

All design decisions support the core pillars of authentic investigation, spatial immersion, logical deduction, and educational value while maintaining the highest standards of user experience in spatial computing.
