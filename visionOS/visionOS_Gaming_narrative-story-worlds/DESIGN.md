# Narrative Story Worlds - Design Document

## Table of Contents

1. [Game Design Document (GDD)](#game-design-document-gdd)
2. [Core Gameplay Loop](#core-gameplay-loop)
3. [Player Progression Systems](#player-progression-systems)
4. [Spatial Gameplay Design](#spatial-gameplay-design)
5. [UI/UX Design](#uiux-design)
6. [Visual Style Guide](#visual-style-guide)
7. [Audio Design](#audio-design)
8. [Accessibility Design](#accessibility-design)
9. [Tutorial & Onboarding](#tutorial--onboarding)
10. [Difficulty & Pacing](#difficulty--pacing)

---

## 1. Game Design Document (GDD)

### Game Vision

**Elevator Pitch**: A spatial narrative adventure where your living room becomes a theater stage, and AI-driven characters tell personalized stories that adapt to your choices and emotions in real-time.

### Core Pillars

1. **Emotional Connection**: Players form genuine relationships with characters
2. **Meaningful Choices**: Every decision reshapes the narrative
3. **Spatial Presence**: Characters feel like they're really there
4. **Adaptive Storytelling**: AI tailors the experience to each player
5. **Cinematic Quality**: Film-quality visuals and performances

### Target Player Profile

```yaml
Demographics:
  Age: 25-45 (primary), 18-65 (secondary)
  Platform: Apple Vision Pro owners
  Gaming Background: Narrative game enthusiasts, film/TV lovers
  Tech Savviness: Early adopters, comfortable with new technology

Psychographics:
  Motivations:
    - Emotional experiences
    - Story-driven content
    - Character relationships
    - Multiple playthroughs to explore choices

  Pain Points Solved:
    - Passive film/TV consumption
    - Repetitive linear narratives
    - Disconnected game characters
    - Lack of agency in stories

  Player Types (Bartle):
    - Achievers: 30% (complete all story branches)
    - Explorers: 40% (discover all paths)
    - Socializers: 20% (discuss choices with community)
    - Killers: 10% (make dramatic/dark choices)
```

### Core Experience

```
Player arrives home → Launches app → Room calibrates
    ↓
Character appears in their living room
    ↓
Story begins with intimate conversation
    ↓
Player makes first choice via gesture
    ↓
Story branches, room transforms subtly
    ↓
45-90 minute emotional journey
    ↓
Climactic choice with major consequences
    ↓
Resolution with epilogue showing impacts
    ↓
Reflection on choices, urge to replay
```

---

## 2. Core Gameplay Loop

### Micro Loop (Scene-Level)

```
┌─────────────────────────────────────┐
│  1. Character Speaks (30-90s)       │
│     - Dialogue with emotion         │
│     - Spatial audio from position   │
│     - Facial animations             │
└───────────────┬─────────────────────┘
                ↓
┌─────────────────────────────────────┐
│  2. Present Choice (10-30s)         │
│     - Options appear in space       │
│     - Player considers              │
│     - Time pressure (optional)      │
└───────────────┬─────────────────────┘
                ↓
┌─────────────────────────────────────┐
│  3. Player Selects (2-5s)           │
│     - Point and pinch gesture       │
│     - Visual/haptic feedback        │
│     - Choice animation              │
└───────────────┬─────────────────────┘
                ↓
┌─────────────────────────────────────┐
│  4. Consequence Plays Out (10-60s)  │
│     - Character reacts emotionally  │
│     - Environment may change        │
│     - Relationship shifts           │
└───────────────┬─────────────────────┘
                │
                └──────► Loop to step 1

Total Loop Duration: 1-3 minutes
Loops per Session: 15-45
```

### Meso Loop (Chapter-Level)

```
Chapter Introduction (5 min)
    ↓
Setup Situation & Stakes (10 min)
    ↓
Rising Action with Choices (20-30 min)
    ↓
Climactic Moment (10 min)
    ↓
Resolution & Consequences (5 min)
    ↓
Epilogue & Next Chapter Tease (2 min)

Total: 45-60 minutes per chapter
```

### Macro Loop (Full Story)

```
Episode 1: Intro (Free)
    → 60% convert to Episode 2

Episodes 2-5: Rising Season Arc
    → 45% complete season

Season Finale: Major Choices
    → 70% want Season 2

Season 2 Launch
    → Import previous choices
```

---

## 3. Player Progression Systems

### Narrative Progression

```yaml
Progress Tracking:
  Story Completion: % of scenes experienced
  Branches Discovered: Unique paths found
  Character Relationships: Trust/bond levels
  Secrets Uncovered: Hidden lore discovered

No Traditional Leveling:
  - No XP or stats
  - No combat progression
  - No skill trees

  Instead:
  - Emotional depth unlocks
  - Character intimacy gates content
  - Previous choices enable new options
```

### Relationship System

```
Character Bond Levels:
├── Stranger (0-20%): Surface conversations
├── Acquaintance (20-40%): Personal topics
├── Friend (40-60%): Vulnerabilities shared
├── Confidant (60-80%): Deep secrets revealed
├── Soulmate/Nemesis (80-100%): Ultimate trust or betrayal

Relationship Factors:
- Choice alignment with character values
- Emotional support given
- Secrets kept vs. shared
- Consistency over time
- Sacrifice for character
```

### Unlockable Content

```yaml
Story Branches:
  - High trust → Intimate confession scene
  - Low trust → Confrontation scene
  - Neutral → Professional distance

Alternative Scenes:
  - Romance path vs. friendship path
  - Cooperation vs. independence
  - Truth vs. protection

Hidden Epilogues:
  - Perfect playthrough endings
  - Tragedy endings
  - Bittersweet endings
  - Hopeful endings
```

---

## 4. Spatial Gameplay Design

### Room-Scale Story Design

```
Small Room (< 15m²):
  - Intimate conversations dominate
  - 1-2 characters maximum
  - Close camera work
  - Personal space invasion (intentional)

Medium Room (15-30m²):
  - Multiple characters possible
  - Characters use furniture
  - Stage-like blocking
  - Player can move around scene

Large Room (> 30m²):
  - Epic scale moments
  - Characters across space
  - Environmental storytelling
  - Room transformations visible
```

### Spatial Storytelling Techniques

#### Character Blocking

```swift
// Example: Betrayal Scene
func stageBetrayal(in room: RoomFeatures) {
    // Character starts close (trust)
    character.position = playerPosition + SIMD3(0, 0, -1.2)

    // During revelation, backs away (distance)
    character.moveTo(playerPosition + SIMD3(2, 0, -2), duration: 3.0)

    // If player pursues, character turns away
    if playerAdvances {
        character.turnAway()
        character.moveTo(doorway) // Retreat to exit
    }
}
```

#### Environmental Transformation

```
Emotional State → Visual Changes:

Trust Building:
  - Room brightens subtly
  - Warm color temperature
  - Soft ambient particles

Tension Rising:
  - Shadows deepen
  - Cool color shift
  - Flickering lights

Betrayal:
  - Red undertones
  - Sharp shadows
  - Environment geometry shifts

Resolution:
  - Return to neutral or new warmth
  - Settled lighting
  - Physical changes persist
```

#### Memory Manifestation

```yaml
Flashback Mechanics:
  Trigger: Character touches object

  Visual Treatment:
    - Desaturate present environment (30%)
    - Fade in memory version
    - Different lighting (golden hour, etc.)
    - Younger character model

  Spatial Design:
    - Same room, different time
    - Objects appear/disappear
    - Player observes (can't interact)

  Return to Present:
    - Reverse transition
    - Character emotional response
    - Object now significant
```

### Navigation & Movement

```yaml
Player Movement:
  Default: Stationary (seated or standing)

  Optional Movement:
    - Walk around character (different perspectives)
    - Approach objects to examine
    - Back away from intense moments

  Character Movement:
    - Natural paths around furniture
    - Emotional-driven distance changes
    - Respect player space boundaries
    - Furniture usage (sit, lean, pace)
```

---

## 5. UI/UX Design

### Diegetic UI Philosophy

**Principle**: UI exists within the story world, not floating overlays

```yaml
Traditional UI → Diegetic Alternative:

Health Bar → None (no combat)
Quest Log → Character's journal (physical object)
Dialogue Box → Speech emanates from character
Choices → Thought bubbles in space
Inventory → Physical items in room
Pause Menu → Time-out gesture creates pocket watch
Settings → Character asks "How should I speak?"
```

### Choice Interface Design

```
Choice Presentation:

Visual Design:
┌─────────────────┐
│  "Trust her"    │ ← Glowing orb
│  [Heart icon]   │   positioned 0.5m
│  +Relationship  │   from player
└─────────────────┘

┌─────────────────┐
│  "Question her" │ ← Different position
│  [? icon]       │   in arc around
│  ~Relationship  │   player vision
└─────────────────┘

┌─────────────────┐
│  "Stay silent"  │ ← Third option
│  [... icon]     │   completes the arc
│  No change      │
└─────────────────┘

Interaction:
1. Player gazes at option → Highlights
2. Player pinches → Selection animation
3. Unselected options fade out
4. Selected option flows toward character
5. Character responds to choice
```

### HUD Elements (Minimal)

```
┌────────────────────────────────────┐
│ Top-Right: Chapter Progress        │ ← Subtle, fades after 2s
│  "Chapter 2: The Confession"       │
│  ●●●○○ (3 of 5 scenes)            │
└────────────────────────────────────┘

┌────────────────────────────────────┐
│ Bottom: Relationship Indicator     │ ← Only during key moments
│  Sarah ♥♥♥♥○ (4/5 trust)         │
└────────────────────────────────────┘

┌────────────────────────────────────┐
│ Center (rarely): Important Notice  │
│  "This choice cannot be undone"    │
│  [Haptic pulse]                    │
└────────────────────────────────────┘
```

### Menu System Design

#### Main Menu (Window Mode)

```
Narrative Story Worlds
─────────────────────
▶ Continue Story
  New Story
  Load Story
  Settings
  Extras
─────────────────────

Visual: Character portrait background
Audio: Ambient theme music
Interaction: Gaze + pinch or controller
```

#### Pause Menu (Immersive Space)

```
Gesture: Both palms facing forward → Time freezes

Suspended Animation:
- Characters freeze mid-gesture
- Soft focus on background
- Ethereal pause music

Menu Options (floating):
│ ▶ Resume
│ ↻ Replay Last Scene
│ 💾 Save & Exit
│ ⚙ Settings
│ ℹ Story Journal

Return: Double tap → Time resumes
```

#### Settings (Accessibility First)

```yaml
Comfort Settings:
  Intensity Level: [Gentle] [Moderate] [Intense]
  Content Warnings: [Enabled] with specific filters
  Break Reminders: Every [30/45/60] minutes

Interaction Settings:
  Primary Input: [Gaze+Pinch] [Controller] [Voice+Gesture]
  Dominant Hand: [Right] [Left] [Either]
  Seated Mode: [On] [Off]

Visual Settings:
  Lighting Intensity: [50-150%]
  Character Distance: [Intimate] [Comfortable] [Distant]
  Subtitle Size: [Small/Medium/Large/XL]
  Subtitle Background: [None/Subtle/Strong]

Audio Settings:
  Master Volume: Slider
  Dialogue Volume: Slider
  Music Volume: Slider
  Spatial Audio: [On] [Off]
  Captions: [Off/Dialogue Only/Full]
```

---

## 6. Visual Style Guide

### Art Direction

**Style**: Photorealistic with cinematic lighting, leaning slightly stylized to avoid uncanny valley

```yaml
Character Visual Goals:
  - Realistic enough to be believable
  - Stylized enough to be appealing
  - Expressive enough for emotion
  - Consistent across lighting conditions

Reference Touchstones:
  - "The Last of Us Part II" character fidelity
  - A24 film cinematography
  - Portrait photography lighting
  - Contemporary fashion photography
```

### Color Palette

```
Primary Palette (Neutral Base):
  #F5F5DC - Warm white (ambient)
  #8B7355 - Natural wood tones
  #4A4A4A - Deep gray (shadows)
  #E8DCC0 - Soft cream (highlights)

Emotional Overlays:
  Trust/Warmth:
    #FFD700 - Golden hour
    #FFA07A - Warm salmon
    #F4A460 - Sandy brown

  Tension/Mystery:
    #4B0082 - Deep indigo
    #483D8B - Dark slate blue
    #696969 - Dim gray

  Conflict/Danger:
    #8B0000 - Dark red
    #B22222 - Fire brick
    #2F4F4F - Dark slate gray

  Hope/Resolution:
    #87CEEB - Sky blue
    #98FB98 - Pale green
    #F0E68C - Khaki

UI Accent Colors:
  Choice Positive: #90EE90 (Light green)
  Choice Negative: #FF6B6B (Soft red)
  Choice Neutral: #B0B0B0 (Silver)
  Selection: #FFFFFF (Pure white glow)
```

### Lighting Design

```yaml
Natural Lighting:
  Purpose: Realism and grounding
  Technique:
    - Match real room lighting
    - Add subtle fill from character direction
    - Rim lights for separation

Emotional Lighting:
  Purpose: Mood and storytelling
  Technique:
    - Color temperature shifts (warm/cool)
    - Intensity changes (bright/dim)
    - Direction changes (above/below/side)
    - Shadow play on walls

Dramatic Lighting:
  Purpose: Key story moments
  Technique:
    - Spotlighting character faces
    - Volumetric light shafts
    - High contrast for tension
    - Soft focus for intimacy
```

### Character Design

```
Main Characters (3-4 per episode):
  Polygon Budget: 50K triangles (high LOD)
  Texture Resolution: 4K base color, 4K normal
  Facial Blend Shapes: 52 (ARKit compatible)
  Skeleton: 65 bones (humanoid rig)

Design Principles:
  - Realistic proportions
  - Distinct silhouettes
  - Memorable faces
  - Appropriate age representation
  - Diverse representation

Wardrobe:
  - Contemporary clothing
  - Fabric simulation where needed
  - Detail appropriate to distance
  - Color coordination with scenes
```

### Environmental Design

```yaml
Story Objects:
  Clues:
    - Highlighted with subtle glow
    - Examinable in detail
    - Persistent across sessions

  Set Pieces:
    - Photos (story context)
    - Letters (backstory)
    - Objects (memory triggers)

  Interactive Props:
    - Door handles (character movement)
    - Chairs (sitting animations)
    - Tables (object placement)

Environmental Effects:
  Particles:
    - Dust motes (atmosphere)
    - Light rays (drama)
    - Subtle sparkles (magic realism)

  Atmospheric:
    - Fog/haze (mystery)
    - Rain outside windows (mood)
    - Ambient sound visualizers
```

---

## 7. Audio Design

### Spatial Audio Strategy

**Philosophy**: Sound should enhance presence and emotion without overwhelming

```yaml
Character Dialogue:
  Source: Character mouth position (tracked)
  Falloff: Natural inverse square law
  Occlusion: Subtle (furniture blocks slightly)
  Reverb: Room-appropriate (calculated from room scan)
  Intimacy: Closer whispers for secrets

Environmental Ambience:
  Layers:
    - Room tone (subtle, constant)
    - Outside world (through walls/windows)
    - Character movements (footsteps, cloth)
    - Object interactions (doors, items)

  Spatial Placement:
    - Windows: Street sounds from that direction
    - Walls: Neighbor sounds (very subtle)
    - Corners: Subtle reverb tails

Emotional Music:
  Type: Adaptive/Dynamic
  Layers:
    - Base: Minimal piano/strings
    - Tension: Additional percussion/bass
    - Climax: Full orchestral

  Spatialization:
    - Non-diegetic (surrounds player evenly)
    - Swells for dramatic moments
    - Fades for dialogue clarity
```

### Music Design

```
Leitmotifs (Character Themes):

Sarah's Theme:
  - Instrument: Solo violin
  - Mood: Melancholic hope
  - Use: Her appearances, emotional beats

Marcus's Theme:
  - Instrument: Guitar harmonic
  - Mood: Gentle mystery
  - Use: His backstory, revelations

Player Theme:
  - Instrument: Piano motif
  - Mood: Introspective
  - Use: Choice moments, reflection

Adaptive Music System:
  Tension Level 0-100%:
    0-25%: Minimal piano, sparse
    25-50%: Add strings, rhythm
    50-75%: Full arrangement, building
    75-100%: Climactic orchestration

  Transition: Smooth crossfades (5-10s)
  Silence: Used strategically for impact
```

### Voice Acting Direction

```yaml
Recording Specifications:
  Format: 48kHz, 24-bit, mono
  Processing: Minimal (natural sound)
  Takes: 3-5 per line (variation)
  Ambience: Dead room (add reverb in-engine)

Direction Style:
  Method Acting: Emotional authenticity
  Conversational: Natural speech patterns
  Variation: Different emotional reads
  Timing: Leave space for player consideration

Emotional Range Per Character:
  - Neutral baseline
  - Happy/joyful (multiple intensities)
  - Sad/crying (multiple intensities)
  - Angry/frustrated
  - Fearful/anxious
  - Surprised/shocked
  - Disgusted/repulsed
  - Loving/tender
```

### Sound Effects

```yaml
Interaction Sounds:
  Choice Selection:
    - Whoosh (choice moving)
    - Chime (confirmation)
    - Haptic pulse (tactile)

  Object Interaction:
    - Pickup: Material-appropriate (paper, wood, metal)
    - Rotation: Subtle scrape
    - Place down: Soft thud

Environmental Storytelling:
  Door Opens: Creak reveals new area
  Rain Starts: Mood shift
  Clock Ticks: Time pressure
  Heartbeat: Player tension (subtle)

Character Foley:
  Footsteps: Shoe type + floor material
  Cloth: Movement rustles
  Breathing: Emotional state indicator
  Touch: When character touches objects
```

### Haptic Design

```yaml
Emotional Haptics:
  Heartbeat Pattern:
    Calm: 60 BPM, gentle
    Nervous: 90 BPM, pronounced
    Fear: 120 BPM, sharp

  Touch Feedback:
    Character Touch: Warm pulse
    Object Pickup: Material texture
    Choice Select: Crisp tap

  Environmental:
    Thunder: Low rumble
    Door Slam: Sharp impact
    Revelation: Sustained vibration
```

---

## 8. Accessibility Design

### Vision Accessibility

```yaml
Subtitle System:
  Size: Adjustable (16pt - 32pt)
  Position: Below character (spatially)
  Background: Optional high-contrast box
  Speaker ID: Color-coded names
  Sound Effects: [Door opens], [Thunder]
  Emotion Tags: [Angrily], [Whispers]

Audio Descriptions:
  - Scene setting narration
  - Character appearance descriptions
  - Action descriptions
  - Emotional cues (for non-verbal)

Visual Assistance:
  - High contrast mode
  - Outline mode for characters
  - Simplified lighting (less flicker)
  - Object highlight assistance
```

### Hearing Accessibility

```yaml
Visual Dialogue:
  - Full subtitles (all speech)
  - Environmental sound captions
  - Music emotional descriptions
  - Direction indicators for off-screen sounds

Haptic Enhancement:
  - Dialogue rhythm in haptics
  - Music beat in haptics
  - Emotional moments emphasized
  - Ambient sound translated to pulses

Visual Sound Indicators:
  - Speech waves emanating from character
  - Music visualizer (subtle)
  - Sound direction arrows
```

### Motor Accessibility

```yaml
Input Alternatives:
  Gaze-Only Mode:
    - Dwell-select (2s gaze = select)
    - No gestures required
    - Voice confirmation optional

  Controller Mode:
    - Full experience with gamepad
    - Stick navigation
    - Button selection
    - No hand tracking required

  Voice Commands:
    - "Select option 1/2/3"
    - "Pause story"
    - "Replay last dialogue"
    - "Save and exit"

Timing Adjustments:
  - Disable timed choices
  - Extend all timers 2x/3x/unlimited
  - Auto-pause on inactivity
```

### Cognitive Accessibility

```yaml
Complexity Options:
  Simple Mode:
    - 2 choices maximum (vs. 3-4)
    - Clear right/wrong removed
    - Extended decision time
    - Simpler vocabulary

  Story Assistance:
    - Recap option at any time
    - Character relationship reminder
    - Previous choice review
    - Key information highlighted

  Pacing Control:
    - Slow mode (longer pauses)
    - Skip repeated information
    - Adjustable dialogue speed
```

### Comfort Accessibility

```yaml
Motion Comfort:
  - Seated mode (no standing required)
  - Stationary camera (no forced movement)
  - Fade transitions (no cuts)
  - Grounded reference points

Sensory Sensitivities:
  - Reduce visual effects
  - Disable flashing
  - Lower audio dynamics
  - Remove jumpscares

Content Warnings:
  - Pre-episode warnings
  - Real-time skip options
  - Granular content filters
  - Alternative scene options
```

---

## 9. Tutorial & Onboarding

### First-Time User Experience (FTUE)

```
Session 1: Introduction (15 minutes)
────────────────────────────────────

1. Welcome & Room Scan (2 min)
   ├─ App explains purpose
   ├─ Player walks around briefly
   └─ System maps room

2. Character Introduction (3 min)
   ├─ Simple character appears
   ├─ "Can you see me? Good."
   ├─ Character moves, player tracks
   └─ Natural presence established

3. First Dialogue (3 min)
   ├─ Character speaks directly
   ├─ Spatial audio demonstration
   ├─ Eye contact established
   └─ Player just listens (no interaction yet)

4. First Choice (5 min)
   ├─ "I need your help with something..."
   ├─ Two simple options appear
   ├─ Tutorial: "Look at your choice, then pinch"
   ├─ Player selects
   ├─ Character reacts positively
   └─ Choice impact explained

5. Story Hook (2 min)
   ├─ Character reveals mystery
   ├─ "This is your story now"
   ├─ Cliffhanger moment
   └─ "To be continued..." with purchase prompt

Tutorial Principles:
  - Learn by doing, not reading
  - No walls of text
  - Natural integration
  - Character teaches player
  - Immediate payoff
```

### Progressive Complexity

```
Chapter 1: Basics
  - 2 choices per decision
  - Clear consequences
  - Single character
  - One room
  - Linear with minor branches

Chapter 2: Expanded
  - 3 choices per decision
  - Ambiguous outcomes
  - Two characters
  - Objects to examine
  - Meaningful branches

Chapter 3: Complex
  - 4 choices some decisions
  - Timed choices introduced
  - Multiple characters
  - Room transformations
  - Major branching

Chapters 4-5: Full Depth
  - All mechanics available
  - Complex moral choices
  - Ensemble cast
  - Non-linear structure
  - Consequence tracking
```

### Gesture Tutorial

```swift
// Integrated into first scene

Gesture: Gaze
  Character: "Look at me... yes, like that."
  Feedback: Eyes lock when looking at character

Gesture: Point
  Character: "Now, point at one of these thoughts."
  Feedback: Choice highlights when pointed at

Gesture: Pinch
  Character: "Pinch your fingers to choose."
  Feedback: Haptic + visual confirmation

Gesture: Examine
  Character: "You can pick up objects, try it."
  Tutorial Object: Photo frame appears
  Feedback: Object comes to hand, rotates

No explicit "Tutorial Level":
  - Everything learned in story context
  - Character is patient teacher
  - Failures are story moments
  - Player never feels lectured
```

---

## 10. Difficulty & Pacing

### Difficulty Philosophy

**There is no "difficulty" in traditional sense** - no enemies, no failure states

Instead: **Emotional Difficulty**

```yaml
Intensity Levels (Player Selectable):

Gentle Mode:
  - Slower pacing
  - More time for choices
  - Softer emotional beats
  - Happy endings favored
  - Character always forgiving

Moderate Mode (Default):
  - Balanced pacing
  - Standard choice time
  - Full emotional range
  - Multiple endings possible
  - Natural consequences

Intense Mode:
  - Faster pacing
  - Timed choices (15-30s)
  - Heavy emotional moments
  - Tragic endings possible
  - Permanent consequences
```

### Pacing Design

```
Story Pacing Rhythm (Per Chapter):

Minute 0-5: Introduction
  - Slow, establishing
  - Character setup
  - Situation explanation
  - Calm before storm

Minute 5-15: Rising Action
  - Pace increases
  - Choices introduced
  - Stakes revealed
  - Tension building

Minute 15-25: Complications
  - Faster dialogue
  - More frequent choices
  - Emotional intensity rises
  - Music intensifies

Minute 25-35: Climax
  - Peak intensity
  - Critical choices
  - Emotional maximum
  - Fastest pace

Minute 35-45: Resolution
  - Pace slows
  - Consequences shown
  - Emotional catharsis
  - Reflection moment

Minute 45-50: Epilogue
  - Very slow
  - Character reflection
  - Next chapter tease
  - Emotional cool-down
```

### AI-Driven Pacing Adjustments

```swift
class PacingDirector {
    func adjustPacing(
        playerEngagement: Float,
        sessionDuration: TimeInterval,
        emotionalIntensity: Float
    ) -> PacingAdjustment {

        // Player disengaged (looking away, slow responses)
        if playerEngagement < 0.4 {
            return .insertSurprise // Wake them up
        }

        // Player overwhelmed (rapid blinking, physical distance)
        if emotionalIntensity > 0.8 && sessionDuration > 30.minutes {
            return .insertBreak // Breathing room
        }

        // Player highly engaged (leaning in, quick responses)
        if playerEngagement > 0.7 {
            return .accelerate // They're hooked, maintain pace
        }

        // Default: Maintain authored pace
        return .maintain
    }
}
```

### Break Reminders

```yaml
Comfort Breaks (Subtle Integration):

Every 30 Minutes:
  Character: "This is a lot to process... do you need a moment?"
  Player can:
    - Continue story
    - Take break (pause, character waits patiently)
    - Save and exit

Every 60 Minutes:
  Character: "We've been at this a while. Why don't we continue this tomorrow?"
  Stronger encouragement to break

Every 90 Minutes:
  Mandatory pause:
  Character: "I think we both need rest. I'll be here when you return."
  Auto-save, gentle exit

Design Rationale:
  - visionOS comfort limits
  - Emotional fatigue prevention
  - Encourage returning (vs. burning out)
  - Character cares about player health
```

---

## Design Principles Summary

### 1. Spatial-First Storytelling
Every element designed for 3D space, not adapted from 2D

### 2. Emotional Authenticity
Characters feel real through consistency, memory, and natural behavior

### 3. Meaningful Agency
Player choices matter and create genuinely different experiences

### 4. Comfort & Accessibility
Everyone can experience the story, regardless of ability

### 5. Cinematic Quality
Film-level production values in an interactive medium

### 6. Respect Player Time
Sessions designed for engagement without exhaustion

### 7. Privacy-Conscious
All AI processing on-device, player data stays private

### 8. Replayability
Multiple playthroughs reveal new facets and paths

---

**This design creates an intimate, emotional, and unforgettable narrative experience that leverages spatial computing to make players feel like they're living inside a story rather than just watching or playing one.**
