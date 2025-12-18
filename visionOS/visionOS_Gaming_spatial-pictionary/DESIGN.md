# Spatial Pictionary - Game Design Document

## Document Information
- **Version**: 1.0
- **Last Updated**: 2025-11-19
- **Game Title**: Spatial Pictionary
- **Genre**: Social Party Game / Creative Drawing
- **Platform**: Apple Vision Pro (visionOS 2.0+)
- **Target Audience**: Families, Social Gamers, Educators (Ages 8+)

---

## Table of Contents
1. [Game Design Vision](#game-design-vision)
2. [Core Gameplay Loop](#core-gameplay-loop)
3. [Player Progression Systems](#player-progression-systems)
4. [Level Design Principles](#level-design-principles)
5. [Spatial Gameplay Design](#spatial-gameplay-design)
6. [UI/UX for Gaming](#uiux-for-gaming)
7. [Visual Style Guide](#visual-style-guide)
8. [Audio Design](#audio-design)
9. [Accessibility](#accessibility)
10. [Tutorial & Onboarding](#tutorial--onboarding)
11. [Difficulty Balancing](#difficulty-balancing)

---

## 1. Game Design Vision

### Creative Vision Statement

**Spatial Pictionary transforms the classic party game into a three-dimensional creative experience where imagination literally comes to life in the air around you.**

Players become spatial artists, sculpting clues with their hands while others walk around, explore, and discover answers from every angle. The game celebrates creativity, laughter, and those magical "aha!" moments when a confusing scribble transforms into perfect clarity from just the right perspective.

### Design Pillars

#### 1. Accessible Creativity
- **Anyone can draw in 3D**: Simple gestures create impressive results
- **No artistic skill required**: Expression matters more than perfection
- **Instant gratification**: See your creation come alive immediately
- **Forgiving tools**: Undo, erase, and restart freely

#### 2. Spatial Discovery
- **Multi-angle exploration**: Walk around drawings to find clues
- **Perspective reveals**: What looks wrong from one side is perfect from another
- **Physical engagement**: Natural movement enhances gameplay
- **Social awareness**: See other players' reactions and movements

#### 3. Joyful Social Play
- **Shared laughter**: Hilarious attempts create memorable moments
- **Collaborative success**: Everyone celebrates correct guesses
- **Natural interaction**: Face-to-face play without screens between players
- **Inclusive participation**: Multiple ways to contribute and enjoy

#### 4. Comfortable Experience
- **No motion sickness**: Stable reference frames, gentle movements
- **Adjustable difficulty**: Scale complexity to player experience
- **Natural breaks**: Round-based structure prevents fatigue
- **Ergonomic design**: Comfortable hand positions and viewing angles

---

## 2. Core Gameplay Loop

### Primary Gameplay Loop (Per Round)

```
┌─────────────────────────────────────────────────────────┐
│                   START ROUND                           │
│  • Select artist for this turn                         │
│  • Other players prepare to guess                      │
└─────────────────┬───────────────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────────────┐
│              WORD SELECTION                             │
│  Artist receives 3 word options:                        │
│  • Easy (1 point)                                       │
│  • Medium (2 points)                                    │
│  • Hard (3 points)                                      │
│  • 15 seconds to choose                                 │
└─────────────────┬───────────────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────────────┐
│               DRAWING PHASE                             │
│  • Artist draws in 3D space (90 seconds)                │
│  • Uses hand gestures to create strokes                 │
│  • Applies colors, shapes, and effects                  │
│  • Word hidden from other players                       │
│  • Timer counts down visibly                            │
└─────────────────┬───────────────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────────────┐
│              GUESSING PHASE                             │
│  • Guessers walk around drawing (concurrent)            │
│  • Submit guesses via voice or text                     │
│  • First correct guess wins                             │
│  • Partial credit for close guesses (optional)          │
│  • Hint system available after 30 seconds               │
└─────────────────┬───────────────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────────────┐
│              REVEAL & SCORING                           │
│  • Correct answer displayed                             │
│  • Winner announced with celebration                    │
│  • Points awarded:                                      │
│    - First correct guesser: Base points + time bonus    │
│    - Artist: Bonus for successful communication         │
│  • Drawing stays visible for appreciation               │
└─────────────────┬───────────────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────────────┐
│              NEXT ROUND                                 │
│  • Rotate to next artist                                │
│  • Update leaderboard                                   │
│  • 5 second transition                                  │
│  • OR end game if final round                           │
└─────────────────────────────────────────────────────────┘
```

### Secondary Loops

#### Discovery Loop (Learning & Mastery)
1. **Experiment** with new drawing techniques and gestures
2. **Observe** what works well in others' drawings
3. **Practice** discovered techniques in next round
4. **Master** advanced gestures and spatial composition
5. **Unlock** new tools and effects through achievement

#### Social Loop (Community Building)
1. **Create** shared experiences through drawing
2. **Share** hilarious moments and creative solutions
3. **Bond** over collaborative guessing and celebration
4. **Return** for more fun with same group
5. **Invite** new players to expand the circle

#### Collection Loop (Progression)
1. **Draw** and complete rounds
2. **Earn** points and achievements
3. **Unlock** new colors, brushes, and effects
4. **Save** favorite creations to gallery
5. **Showcase** best artwork to others

---

## 3. Player Progression Systems

### Experience & Leveling

```yaml
player_level_system:
  experience_sources:
    - complete_round: 50 XP
    - correct_guess: 100 XP
    - artistic_bonus: 25-100 XP (based on drawing quality votes)
    - first_win_of_day: 200 XP
    - complete_achievement: 500-2000 XP
    - consecutive_days: 100 XP per day

  level_milestones:
    level_5: "Unlock: Neon brush style"
    level_10: "Unlock: Particle effects"
    level_15: "Unlock: Advanced shapes tool"
    level_20: "Unlock: Custom color palettes"
    level_25: "Unlock: Collaborative drawing mode"
    level_30: "Unlock: Animation tools"
    level_50: "Title: Master Spatial Artist"

  prestige_system:
    enabled: true
    prestige_level: 100
    rewards:
      - Exclusive avatar customization
      - Special drawing effects
      - Custom badges
      - Gallery expansion
```

### Achievement System

#### Drawing Achievements
- **First Strokes**: Complete your first drawing
- **3D Thinker**: Create drawing using all three dimensions
- **Speed Artist**: Complete drawing in under 30 seconds with correct guess
- **Perfectionist**: Win round without using undo
- **Color Master**: Use 10+ colors in a single drawing
- **Minimalist**: Win with only 3 strokes
- **Sculptor**: Create 3D volume using only sculpting tools

#### Guessing Achievements
- **Quick Wit**: Guess correctly within 10 seconds
- **Different Angle**: Guess after walking around drawing
- **Close Call**: Submit guess within 1 second of timeout
- **Persistent**: Make 10 guesses in a single round (before getting correct)
- **Mind Reader**: Guess correctly before artist finishes

#### Social Achievements
- **Party Starter**: Host a game with 8 players
- **Regular**: Play 7 days in a row
- **Crowd Pleaser**: Have your drawing voted "Most Creative"
- **Mentor**: Play 10 rounds with a new player
- **Viral Artist**: Share a drawing that gets 100+ likes

#### Collection Achievements
- **Gallery Owner**: Save 50 drawings
- **Curator**: Organize drawings into 10 themed collections
- **Completionist**: Unlock all drawing tools
- **Category Master**: Get correct guesses in all word categories

### Unlockable Content

#### Drawing Tools
- **Starter Kit** (Free):
  - Basic brush
  - 12 standard colors
  - Simple shapes (sphere, cube, cylinder)
  - Eraser

- **Level Unlocks**:
  - Glow brush (Level 5)
  - Neon effects (Level 10)
  - Particle trails (Level 15)
  - Advanced shapes (Level 20)
  - Gradient colors (Level 25)

- **Achievement Unlocks**:
  - Animated brush (Speed Artist achievement)
  - Rainbow effect (Color Master achievement)
  - Mirror mode (3D Thinker achievement)

#### Visual Customization
- Avatar accessories
- Canvas frame designs
- Particle effect themes
- UI color schemes
- Celebration animations

---

## 4. Level Design Principles

### Spatial Environment Design

Since Spatial Pictionary doesn't have traditional "levels," we design experiences through:

#### Canvas Environments

**1. Classic Studio (Default)**
- Clean, minimal environment
- Neutral gray canvas frame
- Soft ambient lighting
- Optimal for focusing on drawing
- Comfortable for long sessions

**2. Neon Arcade**
- Vibrant, energetic environment
- Glowing grid floor
- Bright accent lighting
- Pumps energy for parties
- Unlocked at Level 10

**3. Natural Gallery**
- Wooden frame, museum feel
- Warm natural lighting
- Plants and natural elements
- Calming, creative atmosphere
- Unlocked with "Gallery Owner" achievement

**4. Cosmic Space**
- Floating in star field
- Deep space ambiance
- Ethereal lighting
- Immersive, magical feel
- Premium unlock ($2.99)

**5. Classroom**
- Educational environment
- Whiteboard aesthetic
- Bright, clear lighting
- Perfect for learning
- Educational license only

#### Canvas Variations

**Size Options**:
- **Compact** (0.5m³): Close-quarters, seated play
- **Standard** (1.0m³): Default, balanced
- **Large** (1.5m³): Room-scale, multiple artists
- **Massive** (2.0m³): Special events, complex scenes

**Interaction Zones**:
- **Drawing Canvas**: Central 3D space for creation
- **Tool Palette**: Left/right sidebars with tools
- **Score Display**: Upper area, unobtrusive
- **Timer**: Upper right, visible but not distracting
- **Player Avatars**: Positioned around canvas perimeter

---

## 5. Spatial Gameplay Design for Vision Pro

### 3D Drawing Mechanics

#### Hand Gesture System

**Primary Drawing Gesture: Index Extended**
```
Comfort: ★★★★★ (5/5)
Precision: ★★★★☆ (4/5)
Learning Curve: ★★★★★ (5/5 - Most intuitive)

Execution:
1. Extend index finger, curl other fingers
2. Move hand through space to draw line
3. Line appears as glowing trail following fingertip
4. Continuous drawing until hand closes

Best For: Quick sketches, outlines, general drawing
```

**Precision Drawing: Pinch & Drag**
```
Comfort: ★★★★☆ (4/5)
Precision: ★★★★★ (5/5)
Learning Curve: ★★★★☆ (4/5)

Execution:
1. Pinch thumb and index finger together
2. Drag pinched fingers through space
3. Fine-detail line follows pinch point
4. Release pinch to end stroke

Best For: Detailed work, small features, text
```

**Sculpting: Open Palm Push/Pull**
```
Comfort: ★★★☆☆ (3/5 - Can be tiring)
Precision: ★★★☆☆ (3/5)
Learning Curve: ★★★☆☆ (3/5)

Execution:
1. Open palm facing canvas
2. Push forward to add material/volume
3. Pull backward to subtract/carve
4. Two hands for large shapes

Best For: 3D volumes, organic shapes, faces
```

#### Viewing & Navigation

**Guesser Viewing Strategies**:
1. **Orbit**: Circle around drawing (most common)
2. **Zoom**: Step closer for detail inspection
3. **Duck & Peek**: Change vertical perspective
4. **Side-by-Side**: Compare views with other players

**Artist Camera Control**:
- Rotate canvas with two-finger swipe
- Zoom in/out with pinch gesture
- Reset view with double-tap
- Lock view for consistent perspective

### Spatial Composition Guidelines

#### Depth Guidelines for Artists

**Effective 3D Drawing Tips**:
1. **Layer Objects**: Place elements at different depths
2. **Use Perspective**: Smaller things farther away
3. **Key Angles**: Consider multiple viewing positions
4. **Centerpiece**: Put main subject in center
5. **Supporting Details**: Add context around edges

**Depth Zones**:
- **Foreground** (-0.3m to -0.1m): Important details, focal points
- **Mid-ground** (-0.1m to +0.1m): Main subject
- **Background** (+0.1m to +0.3m): Context, environment

### Comfort-First Spatial Design

**Ergonomic Positioning**:
- Canvas center: Eye level, arms' reach (1.2m away)
- Tool palette: Comfortable side position (0.8m away)
- UI elements: Upper peripheral vision (avoid neck strain)
- Floor reference: Visible grid for spatial grounding

**Fatigue Prevention**:
- Auto-adjust canvas height to player
- Remind artists to lower arms every 60 seconds
- Suggest seated mode after 20 minutes
- Dim bright elements during long sessions

**Motion Comfort**:
- No artificial locomotion (player moves physically)
- Stable canvas anchor (world-locked)
- Smooth transitions (no sudden movements)
- Clear boundaries (visual guides)

---

## 6. UI/UX for Gaming

### HUD Design in Spatial Context

#### Minimal HUD Philosophy

**Always Visible (Heads-Up Display)**:
```
┌────────────────────────────────────────────┐
│  Timer: 1:23  │  Round: 3/8  │  Score: 450 │ Top bar
└────────────────────────────────────────────┘

                   [Drawing Canvas]
                   (Main focus area)

┌────────────────────────────────────────────┐
│  Tool    │  Color   │  Size   │  Undo      │ Bottom palette
│  [Brush] │  [●●●●●] │  [───]  │  [↶]       │
└────────────────────────────────────────────┘
```

**Contextual UI (Appears When Needed)**:
- Word selection panel (artist only, at round start)
- Guess input field (guessers only, during guessing)
- Hint button (after 30 seconds)
- Settings menu (paused state)

#### Menu Systems

**Main Menu (Window Mode)**:
```
╔═══════════════════════════════════════════╗
║      SPATIAL PICTIONARY                   ║
║                                           ║
║  ┌───────────────────────────────────┐   ║
║  │  [Quick Play]                     │   ║
║  │  Start game with default settings │   ║
║  └───────────────────────────────────┘   ║
║                                           ║
║  ┌───────────────────────────────────┐   ║
║  │  [Host Multiplayer]               │   ║
║  │  Create room for friends          │   ║
║  └───────────────────────────────────┘   ║
║                                           ║
║  ┌───────────────────────────────────┐   ║
║  │  [Join Game]                      │   ║
║  │  Enter friend's game              │   ║
║  └───────────────────────────────────┘   ║
║                                           ║
║  ┌───────────────────────────────────┐   ║
║  │  [Practice Mode]                  │   ║
║  │  Draw freely, no pressure         │   ║
║  └───────────────────────────────────┘   ║
║                                           ║
║  [Gallery]  [Settings]  [Tutorial]       ║
╚═══════════════════════════════════════════╝
```

**In-Game Pause Menu (Floating Panel)**:
- Resume Game
- Settings (volume, brightness, controls)
- View Rules
- Leave Game
- End Session

#### Tool Palette Design

**Left-Hand Palette (Tools)**:
```
┌─────────┐
│ [Brush] │ ← Selected (highlighted)
│ [Eraser]│
│ [Shape] │
│ [Sculpt]│
│ [Text]  │
└─────────┘
  Floating
  0.8m left
  Eye level
```

**Right-Hand Palette (Properties)**:
```
┌──────────┐
│ Colors:  │
│ ●●●●●●●● │ ← 2 rows of 8
│ ●●●●●●●● │
│          │
│ Size:    │
│ ────o──  │ ← Slider
│          │
│ Effect:  │
│ [Solid] ▼│ ← Dropdown
└──────────┘
  Floating
  0.8m right
  Eye level
```

### Interaction Feedback

**Visual Feedback**:
- Tool selection: Highlight + enlarge selected tool
- Drawing: Trail particles from fingertip
- Successful guess: Green glow + confetti
- Timer warning: Red pulsing at <10 seconds
- Boundary approach: Canvas edge glows yellow

**Audio Feedback**:
- Tool switch: Soft "click"
- Drawing stroke: Gentle brush sound (spatial audio at draw point)
- Correct guess: Celebration chime
- Wrong guess: Soft "bonk"
- Timer warning: Heartbeat sound at <10 seconds

**Haptic Feedback** (if supported):
- Drawing: Light pulse on stroke
- Tool select: Medium pulse
- Correct guess: Strong celebration pulse
- Boundary hit: Warning pulse

---

## 7. Visual Style Guide

### Art Direction

**Overall Aesthetic**: **Playful Minimalism**
- Clean, uncluttered interfaces
- Vibrant but not overwhelming colors
- Soft, rounded shapes
- Gentle glow effects
- Professional yet approachable

### Color Palette

#### Primary Colors
```
Brand Blue:    #4A90E2 (Trust, calm)
Creative Pink: #FF6B9D (Energy, creativity)
Success Green: #50E3C2 (Positive feedback)
Warning Yellow:#F5A623 (Attention, caution)
Error Red:     #E24A4A (Errors, urgency)
```

#### Drawing Colors (Standard Palette)
```
Row 1: Warm Colors
Red:    #FF4444
Orange: #FF8833
Yellow: #FFDD44
Pink:   #FF6B9D
Purple: #AA66FF
Brown:  #8B6F47
Gold:   #FFD700
White:  #FFFFFF

Row 2: Cool Colors
Blue:   #4A90E2
Cyan:   #44DDFF
Green:  #44FF88
Lime:   #AAFF44
Teal:   #44FFAA
Navy:   #2244AA
Gray:   #888888
Black:  #222222
```

#### Extended Palette (Unlockable)
- Pastel set (16 colors)
- Neon set (16 colors)
- Earth tones (16 colors)
- Metallic (8 colors)
- Custom (user-defined)

### Typography

**UI Text**:
- **Headings**: SF Pro Rounded Bold, 24-32pt
- **Body**: SF Pro Regular, 16-18pt
- **Captions**: SF Pro Light, 12-14pt
- **Numbers**: SF Mono Regular, 18-24pt

**Spatial Text Rendering**:
- 3D depth for headings (+5cm depth)
- Flat for body text
- High contrast for readability
- Minimum size: 14pt at 1m distance

### Material & Lighting

#### Drawing Materials

**Solid**:
- Matte finish
- No reflections
- Base material for most drawings
- Performance: Excellent

**Glow**:
- Emissive properties
- Soft bloom effect
- Intensity: 0.5-2.0
- Performance: Good

**Neon**:
- High emissive
- Sharp edges
- Vibrant colors
- Performance: Medium

**Sketch**:
- Semi-transparent
- Textured appearance
- Pencil-like quality
- Performance: Good

**Particle**:
- Animated particles
- Trailing effect
- Celebration mode
- Performance: Medium (particle count dependent)

#### Lighting Design

**Three-Point Lighting Setup**:
1. **Key Light**: Directional, from upper front (intensity: 1000)
2. **Fill Light**: Point light, from below (intensity: 300)
3. **Rim Light**: Point light, from behind (intensity: 500)

**Ambient Lighting**:
- Base ambient: 500 lux
- Auto-adjust to room lighting (0.3-1.5x)
- Warmer tones for evening (2700K)
- Cooler tones for daytime (5000K)

### Animation Principles

**Timing**:
- UI transitions: 0.3 seconds (ease-in-out)
- Tool switches: 0.15 seconds (ease-out)
- Celebration: 2.0 seconds (bouncy)
- Drawing appear: 0.5 seconds per stroke (linear)

**Easing**:
- Standard: Ease-in-out cubic
- Playful: Spring (dampening: 0.7)
- Urgent: Ease-out quad
- Subtle: Linear

---

## 8. Audio Design

### Music

#### Dynamic Music System

**Adaptive Layers**:
- **Base Layer**: Calm, ambient background (always playing)
- **Energy Layer**: Upbeat rhythm (added during drawing phase)
- **Tension Layer**: Suspenseful tones (added when timer <20 seconds)
- **Celebration Layer**: Triumphant melody (correct guess)

**Music Tracks**:
1. **Menu Theme**: Uplifting, inviting (120 BPM)
2. **Gameplay Theme**: Energetic, creative (128 BPM, loopable)
3. **Victory Theme**: Celebratory fanfare (15 seconds)
4. **Gallery Theme**: Relaxed, contemplative (100 BPM)

**Volume Mixing**:
- Menu music: 60% volume
- Gameplay music: 40% volume (allows conversation)
- Victory music: 80% volume (momentary)
- User adjustable: 0-100%

### Sound Effects

#### Drawing Sounds (Spatial Audio)

**Brush Strokes**:
- **Solid Brush**: Soft "whoosh" (position: draw point)
- **Glow Brush**: Chime-like tone (position: draw point)
- **Neon Brush**: Electric hum (position: draw point)
- **Sketch Brush**: Pencil scratch (position: draw point)
- **Eraser**: Gentle "poof" (position: erase point)

**Tool Interactions**:
- Tool select: "Click" (position: palette)
- Color pick: "Plop" (position: palette)
- Undo: "Rewind" sound (position: canvas center)
- Clear all: "Sweep" (position: canvas center)

#### UI Sounds

**Navigation**:
- Button press: Soft "tap"
- Menu open: "Slide in" whoosh
- Menu close: "Slide out" whoosh
- Toggle on: "Pop"
- Toggle off: "Click"

**Feedback**:
- Correct guess: Celebration chime (3-note ascending)
- Wrong guess: Gentle "bonk" (1 note, descending)
- Timer warning: Heartbeat (spatial, from timer location)
- Round start: "Ding" (cheerful)
- Round end: "Womp womp" or "Ta-da!" (based on success)

#### Social Sounds

**Player Actions**:
- Player joins: "Hello" chime
- Player leaves: "Goodbye" chime
- Chat message: Notification "pop"
- Reaction: Corresponding emoji sound (laugh, applause, etc.)

**Celebrations**:
- First correct guess: Full celebration (confetti, cheers)
- Artist bonus: Bonus chime
- Achievement unlocked: Achievement fanfare
- Level up: Triumphant jingle

### Spatial Audio Implementation

**3D Positioning**:
- Drawing sounds at exact stroke position
- UI sounds at interface element position
- Player voices from their avatar position
- Ambient sounds distributed around canvas

**Reverb & Environment**:
- Canvas environment: Small room reverb (0.3s RT60)
- UI elements: No reverb (dry)
- Celebration: Large hall reverb (1.5s RT60)
- Voice chat: Slight room reverb (0.2s RT60)

**Distance Attenuation**:
- Drawing sounds: 1/distance² (realistic)
- UI sounds: No attenuation (always audible)
- Player voices: 1/distance (gentle falloff)
- Max audible distance: 5 meters

---

## 9. Accessibility

### Motor Accessibility

**One-Handed Mode**:
- All tools accessible with single hand
- Auto-rotate canvas for different angles
- Voice commands for tool switching
- Extended time limits

**Seated Play Mode**:
- Canvas height adjusts automatically
- Reduced physical movement requirements
- All features accessible while seated
- No standing required for any gameplay

**Simplified Gestures**:
- Reduce gesture complexity
- Increase tolerance for imprecise movements
- Longer dwell times for selections
- Alternative inputs (voice, gaze)

### Visual Accessibility

**High Contrast Mode**:
- Black backgrounds
- Bright, saturated colors only
- Thicker stroke widths (2x)
- Enhanced UI element borders

**Colorblind Modes**:
- **Protanopia** (red-blind): Adjusted palette
- **Deuteranopia** (green-blind): Adjusted palette
- **Tritanopia** (blue-blind): Adjusted palette
- Pattern overlays on colors
- Color labels (optional)

**Low Vision Support**:
- UI scaling (100%-200%)
- Spatial text magnification
- VoiceOver integration
- High-contrast canvas frame

### Auditory Accessibility

**Deaf/Hard of Hearing**:
- Visual timer (progress bar)
- Closed captions for voice chat
- Visual feedback for all audio cues
- Vibration/haptic alternatives

**Visual Alerts**:
- Flashing border for correct guess
- Animated icons for events
- Text notifications for audio cues
- Color-coded event system

### Cognitive Accessibility

**Simplified Mode**:
- Reduced word difficulty
- Longer time limits (120 seconds)
- Fewer tool options (4 instead of 8)
- Clear, simple instructions

**Tutorial Options**:
- Repeatable tutorial
- Step-by-step guidance
- Hint system always available
- Practice mode (no time pressure)

**Clear Communication**:
- Simple, concise language
- Icons with text labels
- Consistent UI patterns
- Predictable game flow

---

## 10. Tutorial & Onboarding

### First-Time User Experience (FTUE)

#### Phase 1: Welcome & Comfort (2 minutes)

**Step 1: Introduction (30 seconds)**
```
Visual: Friendly welcome screen
Narrator: "Welcome to Spatial Pictionary! Let's learn how to draw in the air."

Goal: Set expectations, create excitement
```

**Step 2: Comfort Calibration (30 seconds)**
```
Action: Ask player to look around
Instruction: "Take a moment to look around. The game will adjust to your space."

Goal: Check room size, calibrate tracking
```

**Step 3: Hand Tracking Test (60 seconds)**
```
Action: Wiggle fingers, wave hands
Instruction: "Great! Now let's see your hands. Wiggle your fingers!"
Visual: Hand outlines appear when detected

Goal: Verify hand tracking works
```

#### Phase 2: Drawing Basics (3 minutes)

**Step 4: First Stroke (45 seconds)**
```
Instruction: "Extend your index finger and move it through the air."
Guided: Draw a simple line
Feedback: "Perfect! You just drew in 3D!"

Goal: Learn primary drawing gesture
```

**Step 5: Drawing Shapes (60 seconds)**
```
Task: Draw a circle
Instruction: "Try drawing a circle in the air."
Hint: Ghost circle appears to guide
Feedback: "Nice circle! Let's try a square."

Goal: Build drawing confidence
```

**Step 6: Color Selection (45 seconds)**
```
Instruction: "Point at a color to select it, then draw again."
Task: Select blue, draw line
Feedback: "Beautiful! You're a natural artist."

Goal: Learn tool palette interaction
```

**Step 7: Erasing & Undo (30 seconds)**
```
Instruction: "Made a mistake? Just flick your wrist left to undo."
Task: Draw something, undo it
Alternative: "Or use the eraser tool."

Goal: Learn correction tools
```

#### Phase 3: Gameplay Introduction (3 minutes)

**Step 8: Guessing Mechanics (60 seconds)**
```
Scenario: AI draws a simple cat
Instruction: "Walk around the drawing to see it from different angles."
Task: Move around, observe
Instruction: "When you know what it is, say your guess out loud."
Task: Voice guess "cat"
Feedback: "Correct! That's how you play!"

Goal: Understand guessing phase
```

**Step 9: Practice Round (90 seconds)**
```
Task: Draw "dog" (assigned word)
Time: 90 seconds
AI Guessers: Simulated players make guesses
Feedback: Encouraging comments
Result: AI guesses correctly
Celebration: Points awarded

Goal: Experience full round flow
```

**Step 10: Ready to Play (30 seconds)**
```
Summary: Quick recap
Options:
  - [Play Another Practice Round]
  - [Start Real Game]
  - [Watch Tutorial Video]
  - [Skip to Main Menu]

Goal: Player feels prepared
```

### In-Game Tutorials

**Contextual Tips** (appear during gameplay):
- First time using new tool: Tooltip explains it
- Struggling to draw: Suggest simplified approach
- Not moving around: Remind to view from angles
- Running out of time: Suggest time management

**Help System**:
- "?" button always available
- Quick reference for gestures
- Video demonstrations
- Practice sandbox mode

---

## 11. Difficulty Balancing

### Word Difficulty Classification

#### Easy Words (1 Point)
**Characteristics**:
- Common, everyday objects
- Simple shapes
- Widely recognized
- Easy to draw and guess

**Examples**: Cat, Tree, House, Car, Ball, Sun, Apple, Book

**Target Guess Rate**: 85-95%
**Average Time to Guess**: 30-45 seconds

#### Medium Words (2 Points)
**Characteristics**:
- More specific concepts
- Moderate complexity
- May require some detail
- Some cultural knowledge

**Examples**: Astronaut, Skateboard, Castle, Butterfly, Robot, Piano

**Target Guess Rate**: 60-75%
**Average Time to Guess**: 45-65 seconds

#### Hard Words (3 Points)
**Characteristics**:
- Abstract concepts
- Complex or specific subjects
- Challenging to represent visually
- May need creative interpretation

**Examples**: Democracy, Evolution, Quantum, Nostalgia, Perspective, Irony

**Target Guess Rate**: 35-50%
**Average Time to Guess**: 60-85 seconds

### Dynamic Difficulty Adjustment

```yaml
difficulty_adaptation:
  tracking_metrics:
    - guess_success_rate
    - average_guess_time
    - player_satisfaction_votes
    - rounds_completed

  adjustment_triggers:
    too_easy:
      condition: success_rate > 90% over 3 rounds
      action: Increase difficulty by 1 level

    too_hard:
      condition: success_rate < 40% over 3 rounds
      action: Decrease difficulty by 1 level

    just_right:
      condition: success_rate 60-75%
      action: Maintain current difficulty

  constraints:
    - Never adjust more than 1 level per 5 rounds
    - Respect player's manual difficulty setting
    - Group difficulty based on lowest skill player
    - Offer difficulty override in settings
```

### Hint System Design

**Hint Progression** (activates after 30 seconds without guess):

**Hint 1: Category Reveal (30 seconds)**
```
Display: "Category: Animals"
Spoiler Level: Low
Effectiveness: Narrows search space
```

**Hint 2: Letter Count (45 seconds)**
```
Display: "_ _ _" (3 letters)
Spoiler Level: Medium
Effectiveness: Helps with spelling
```

**Hint 3: First Letter (60 seconds)**
```
Display: "C _ _"
Spoiler Level: High
Effectiveness: Strong clue
```

**Hint 4: Multiple Choice (75 seconds)**
```
Display: "Is it: Cat, Cow, or Crab?"
Spoiler Level: Very High
Effectiveness: Almost gives answer
```

**Scoring Adjustment with Hints**:
- No hints: 100% points
- 1 hint: 75% points
- 2 hints: 50% points
- 3 hints: 25% points
- 4 hints: 10% points (pity points)

### Time Balancing

**Round Duration**:
- **Quick Play**: 60 seconds
- **Standard**: 90 seconds (default)
- **Relaxed**: 120 seconds
- **Custom**: 30-300 seconds

**Time Pressure Effects**:
- **Generous Time** (90s+): More detailed drawings, higher quality
- **Moderate Time** (60-90s): Balanced gameplay, good for most
- **Time Crunch** (<60s): Fast-paced, exciting, stressful

---

## Design Conclusion

Spatial Pictionary's game design prioritizes **joy, creativity, and comfort** while leveraging Vision Pro's unique spatial capabilities. The design balances accessibility (anyone can play) with depth (mastery is rewarding), ensuring players of all skill levels can have fun together.

**Core Design Success Metrics**:
- 95%+ players complete tutorial
- 8/10 average fun rating
- 85%+ session completion rate
- <5% motion discomfort reports
- 60%+ return within 7 days

**Next Steps**:
1. Prototype core drawing mechanics
2. Playtest with diverse age groups
3. Iterate based on comfort feedback
4. Balance difficulty with analytics
5. Polish UI/UX based on user testing

*Document Version: 1.0 | Last Updated: 2025-11-19*
