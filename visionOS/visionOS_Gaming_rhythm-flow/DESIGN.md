# Rhythm Flow - Game Design & UI/UX Specifications

## Document Overview

This document defines the comprehensive game design, user experience, visual design, and interaction patterns for Rhythm Flow. It serves as the creative and UX blueprint for the entire game.

**Version:** 1.0
**Last Updated:** 2025-01-20
**Target Platform:** visionOS 2.0+ (Apple Vision Pro)

---

## Table of Contents

1. [Game Design Document](#game-design-document)
2. [Core Gameplay Loop](#core-gameplay-loop)
3. [Player Progression System](#player-progression-system)
4. [Level Design Principles](#level-design-principles)
5. [Spatial Gameplay Design](#spatial-gameplay-design)
6. [UI/UX Design](#uiux-design)
7. [Visual Style Guide](#visual-style-guide)
8. [Audio Design](#audio-design)
9. [Accessibility Features](#accessibility-features)
10. [Tutorial & Onboarding](#tutorial--onboarding)
11. [Difficulty Balancing](#difficulty-balancing)
12. [Monetization & Economy](#monetization--economy)

---

## Game Design Document

### High Concept

**One-Liner:** Transform your living room into a musical universe where your body becomes the instrument through full-body spatial rhythm gameplay.

**Pitch:** Rhythm Flow is the first true spatial rhythm game that uses Vision Pro's hand tracking and room awareness to create a 360-degree musical experience. Unlike traditional rhythm games bound to screens or controllers, Rhythm Flow surrounds players with flowing musical elements that they physically interact with - punching bass notes, tracing melodies, and dancing through beats. Every movement creates music, every gesture shapes the performance, and every session becomes a workout.

### Core Pillars

1. **Feel the Flow** - Achieve a state of musical flow where movement and rhythm become one
2. **Full-Body Expression** - Use your entire body as a musical instrument
3. **Spatial Immersion** - 360-degree gameplay that fills your room with music
4. **Adaptive Challenge** - AI that keeps you in the perfect difficulty sweet spot
5. **Fitness Fun** - Get an incredible workout while having pure fun

### Target Audience

#### Primary Audience (70%)
- **Age:** 16-35
- **Profile:** Rhythm game enthusiasts, VR gamers, fitness gamers
- **Motivations:** Challenge, mastery, fitness, social competition
- **Play Style:** Regular sessions, progression-focused, competitive
- **Reference Games:** Beat Saber, OSU!, Dance Dance Revolution

#### Secondary Audience (20%)
- **Age:** 8-50
- **Profile:** Casual gamers, families, music lovers
- **Motivations:** Fun, social play, creative expression
- **Play Style:** Occasional sessions, variety-seeking, social
- **Reference Games:** Just Dance, Rock Band, Guitar Hero

#### Tertiary Audience (10%)
- **Age:** 25-60
- **Profile:** Fitness enthusiasts, physical therapists, dancers
- **Motivations:** Exercise, coordination training, professional use
- **Play Style:** Structured workouts, form-focused, goal-oriented
- **Reference Games:** Ring Fit Adventure, Fitness Boxing

### Game Modes

#### 1. Campaign Mode - "Musical Journey"
```yaml
Description: Story-driven progression through musical worlds
Structure:
  - 10 themed worlds (Pop, Rock, EDM, Classical, etc.)
  - 10 songs per world
  - Boss battles with iconic tracks
  - Unlockable characters/skins
Progression:
  - Stars earned per song (1-3 stars)
  - World unlocked with 70% stars
  - Special challenges for 100% completion
Narrative:
  - Player is a "Flow Keeper" restoring rhythm to silent dimensions
  - Each world has unique visual theme and mechanics
  - NPCs provide guidance and motivation
```

#### 2. Free Play Mode
```yaml
Description: Play any unlocked song at any difficulty
Features:
  - Full song library access
  - Practice mode with speed adjustment
  - Section repeat for difficult parts
  - Custom modifiers (speed, mirror, no-fail)
  - Ghost replay of personal best
Goal: Mastery and high score chasing
```

#### 3. Fitness Mode
```yaml
Description: Structured workout programs
Programs:
  - Quick Burn (15 min high intensity)
  - Cardio Flow (30 min moderate)
  - Endurance Challenge (60 min varied)
  - Custom Workout Builder
Features:
  - Calorie tracking
  - Heart rate monitoring (Apple Watch)
  - Form coaching
  - Workout history and goals
  - Cool-down sequences
```

#### 4. Multiplayer Modes

**Battle Mode** (Competitive)
```yaml
Players: 2-4
Format: Same song, highest score wins
Features:
  - Real-time score comparison
  - Power-ups and sabotages (optional)
  - Ranked matchmaking
  - Tournament brackets
```

**Duet Mode** (Cooperative)
```yaml
Players: 2
Format: Complementary parts (melody + harmony)
Features:
  - Synchronized scoring
  - Harmony bonuses
  - Special duo moves
  - Custom duet charts
```

**Party Mode** (Casual)
```yaml
Players: 2-8
Format: Pass and play, rotating songs
Features:
  - Silly modifiers
  - Mini-games between songs
  - Team challenges
  - Spectator mode
```

#### 5. Creator Mode
```yaml
Description: Design custom beat maps
Features:
  - Visual timeline editor
  - AI-assisted generation
  - Note placement tools
  - Playtest instantly
  - Upload to community
  - Browse/download others' maps
Tools:
  - Beat snap grid
  - Note type palette
  - Pattern templates
  - Audio waveform display
```

#### 6. Daily Challenges
```yaml
Description: New challenge every day
Types:
  - High score challenge
  - Survival mode (no misses)
  - Speed trials (faster songs)
  - Accuracy challenge (95%+ required)
  - Themed playlists
Rewards:
  - Exclusive badges
  - Bonus XP
  - Limited-time unlockables
```

---

## Core Gameplay Loop

### Moment-to-Moment Gameplay (Seconds)

```
1. Note appears in distance (visual + audio cue)
      ↓
2. Player tracks approaching note
      ↓
3. Player prepares gesture (muscle memory)
      ↓
4. Note enters hit zone
      ↓
5. Player executes gesture
      ↓
6. Hit detection + immediate feedback
      ↓
7. Score popup + audio confirmation
      ↓
8. Combo builds + multiplier increases
      ↓
9. Repeat with next note
```

### Short-Term Loop (Minutes)

```
Song Selection
      ↓
Calibration/Warmup (optional)
      ↓
3-2-1 Countdown
      ↓
Song Gameplay (2-5 min)
      ↓
Results Screen
      ↓
Rewards/Unlocks
      ↓
Next Song or Exit
```

### Medium-Term Loop (Sessions)

```
Login + Daily Bonus
      ↓
Check Challenges/Friends
      ↓
Play 3-10 Songs
      ↓
Level Up + Unlock Content
      ↓
Adjust Goals/Progress
      ↓
Share Best Moments
      ↓
Logout
```

### Long-Term Loop (Weeks/Months)

```
Master Easy Songs
      ↓
Progress to Hard
      ↓
Unlock All Content
      ↓
Chase Leaderboards
      ↓
Create Custom Maps
      ↓
Join Competitive Scene
      ↓
Maintain Fitness Goals
```

---

## Player Progression System

### Experience & Leveling

```swift
// Level Progression Formula
func calculateLevel(xp: Int) -> Int {
    // XP required = 1000 * level^1.5
    return Int(pow(Double(xp) / 1000.0, 1.0/1.5))
}

// XP Sources
enum XPSource {
    case songCompletion(difficulty: Difficulty)  // 100-500 XP
    case perfectHit                              // 5 XP
    case fullCombo                               // 500 XP bonus
    case newHighScore                            // 200 XP
    case dailyChallenge                          // 1000 XP
    case multiplayer                             // 300 XP
    case createBeatMap                           // 500 XP
}
```

### Unlockable Content

#### Progression Tiers
```yaml
Beginner (Levels 1-10):
  - Tutorial completion
  - Basic songs unlocked
  - First visual theme
  - Friend multiplayer

Intermediate (Levels 11-30):
  - Advanced songs
  - Hard difficulty
  - More themes
  - Creator mode basic

Advanced (Levels 31-60):
  - Expert songs
  - All visual themes
  - Advanced creator tools
  - Ranked multiplayer

Master (Levels 61-100):
  - Expert+ difficulty
  - Exclusive songs
  - Pro creator features
  - Elite cosmetics
  - Tournament access
```

#### Unlockable Types

**Songs**
```yaml
Unlock Methods:
  - Complete previous songs (campaign)
  - Reach player level
  - Complete challenges
  - Purchase song packs
  - Subscribe to Flow Pass
```

**Visual Themes**
```yaml
Available Themes:
  - Neon Cyberpunk (default)
  - Natural Zen
  - Concert Stage
  - Abstract Geometry
  - Retro Arcade
  - Fantasy Realm
  - Underwater
  - Space Station
  - Custom Upload (creator)
```

**Avatars & Cosmetics**
```yaml
Customization:
  - Hand trail effects
  - Hit impact styles
  - Combo flame colors
  - Player aura/glow
  - Victory animations
  - Profile badges
```

### Achievement System

```yaml
Categories:
  - Skill (Full combo, accuracy milestones)
  - Persistence (Play 100 songs, 50 hours)
  - Exploration (Try all modes, all difficulties)
  - Social (Multiplayer wins, friends invited)
  - Creation (Maps uploaded, downloads received)
  - Fitness (Calories burned, workout streaks)

Examples:
  - "First Steps": Complete tutorial
  - "Combo King": 500+ combo
  - "Perfectionist": 100% accuracy on Expert
  - "Marathon Dancer": 60-minute session
  - "Social Butterfly": 50 multiplayer games
  - "Creator": 10 maps uploaded
  - "Fitness Guru": Burn 10,000 calories
```

---

## Level Design Principles

### Beat Map Design Philosophy

1. **Follow the Music** - Notes should feel natural to the song's rhythm and melody
2. **Build Gradually** - Start simple, increase complexity
3. **Create Flow** - Smooth transitions between movements
4. **Reward Variety** - Mix punch/swipe/hold for engagement
5. **Respect Physics** - Human body has limits; design accordingly
6. **Consider Space** - Use full 360° but don't cause tangling

### Note Placement Guidelines

#### Spatial Zones
```
┌─────────────────────────────────────┐
│         Ceiling Zone (2.5m+)        │
│         - Rare jumps/reaches        │
├─────────────────────────────────────┤
│       Upper Zone (1.8-2.5m)         │
│       - High punches/swipes         │
├─────────────────────────────────────┤
│     ★ Sweet Spot (1.0-1.8m) ★       │
│     - Primary gameplay zone         │
│     - Most comfortable              │
├─────────────────────────────────────┤
│       Lower Zone (0.5-1.0m)         │
│       - Squats/low hits             │
├─────────────────────────────────────┤
│       Floor Zone (0-0.5m)           │
│       - Only for special moves      │
└─────────────────────────────────────┘
```

#### Difficulty Curve Per Song

```yaml
Intro (0-20%):
  - Simple patterns
  - Single-hand focused
  - Establish rhythm
  - Note density: Low

Verse 1 (20-40%):
  - Introduce complexity
  - Both hands active
  - Note density: Medium-Low

Chorus (40-60%):
  - Peak intensity
  - Complex patterns
  - 360° engagement
  - Note density: High

Verse 2 (60-70%):
  - Recovery period
  - Return to medium complexity
  - Note density: Medium

Bridge (70-80%):
  - Unique patterns
  - Surprise elements
  - Note density: Varied

Final Chorus (80-95%):
  - Maximum intensity
  - All techniques combined
  - Note density: Very High

Outro (95-100%):
  - Wind down
  - Victory lap
  - Note density: Low → None
```

### Pattern Design Library

#### Basic Patterns
```yaml
Single Alternating:
  - L R L R L R
  - Good for: Beginners, rhythm establishment

Double Punch:
  - LL RR LL RR
  - Good for: Emphasis on beats

Triplets:
  - L R L, R L R
  - Good for: Fast sections

Crossovers:
  - L→R, R→L (hands cross)
  - Good for: Dynamic movement
```

#### Advanced Patterns
```yaml
360° Spin:
  - Notes placed in circle, clockwise/counterclockwise
  - Good for: Chorus climax

Vertical Cascade:
  - Notes rain from above in sequence
  - Good for: Melodic sections

Wave Pattern:
  - Side-to-side flowing motion
  - Good for: Smooth, continuous sections

Starburst:
  - Notes explode from center, hit in sequence
  - Good for: Dramatic moments
```

---

## Spatial Gameplay Design

### Room-Scale Utilization

#### Play Space Tiers

**Minimal Space (1.5m x 1.5m)**
```yaml
Gameplay Adaptations:
  - Front-facing notes only
  - Reduced arm extension
  - No 360° spins
  - Vertical emphasis
Best For: Apartments, small rooms
```

**Standard Space (2.5m x 2.5m)**
```yaml
Gameplay Features:
  - 180° gameplay
  - Full arm extension
  - Side steps allowed
  - Moderate 360° patterns
Best For: Living rooms, bedrooms
Recommended: Default setting
```

**Large Space (3.5m x 3.5m+)**
```yaml
Gameplay Features:
  - Full 360° gameplay
  - Room-scale movement
  - Dodge mechanics active
  - Environmental interactions
Best For: Dedicated play areas
```

### Spatial Interaction Design

#### Note Flow Directions

```
        ↑ (Ceiling Notes)
        │
← ────  ●  ──── → (Side Notes)
        │
        ↓ (Floor Notes)

Plus:
  ↗ ↖ (Diagonal)
  ↘ ↙
  ⟲ ⟳ (Circular)
```

#### Environmental Integration

**Passthrough Mode**
```yaml
Features:
  - Real furniture visible
  - Notes avoid obstacles
  - Use couch as stage
  - Window becomes portal
  - Walls for boundary effects
Benefits:
  - Enhanced safety
  - Spatial grounding
  - Mixed reality immersion
```

**Full Immersion Mode**
```yaml
Features:
  - Complete virtual environment
  - Themed worlds
  - Maximum visual spectacle
  - Particle effects everywhere
Benefits:
  - Pure fantasy
  - No distractions
  - Maximum immersion
```

### Comfort & Safety

#### Motion Comfort Features
```yaml
Comfort Settings:
  - Reduce horizon tilt: On/Off
  - Limit particle density: Low/Med/High
  - Static reference points: On/Off
  - Fade during rotation: On/Off
  - Slow-mo mode: Available

Safety Features:
  - Boundary warnings (visual + haptic)
  - Furniture collision detection
  - Emergency pause gesture
  - Auto-pause if user leaves area
  - Fatigue detection (suggest breaks)
```

---

## UI/UX Design

### Spatial UI Hierarchy

```
┌──────────────────────────────────────────┐
│          Sky Layer (4m+)                 │
│          - Environmental visuals         │
├──────────────────────────────────────────┤
│       Background Layer (3-4m)            │
│       - Song title, artist               │
│       - Background animations            │
├──────────────────────────────────────────┤
│      Gameplay Layer (0.8-2m)             │
│      ★ NOTES & OBSTACLES ★               │
│      - Primary focus                     │
├──────────────────────────────────────────┤
│         HUD Layer (anchored)             │
│         - Score (top)                    │
│         - Combo (center-left)            │
│         - Energy (bottom)                │
└──────────────────────────────────────────┘
```

### Main Menu Design

```
┌────────────────────────────────────────┐
│                                        │
│         🎵 RHYTHM FLOW 🎵              │
│                                        │
│    ┌──────────┐  ┌──────────┐         │
│    │  PLAY    │  │ FITNESS  │         │
│    └──────────┘  └──────────┘         │
│                                        │
│    ┌──────────┐  ┌──────────┐         │
│    │MULTIPLAYER│  │ CREATE  │         │
│    └──────────┘  └──────────┘         │
│                                        │
│         [Settings] [Profile]           │
│                                        │
│    Daily Challenge: Beat Boss (EDM)    │
│         [Quick Play →]                 │
└────────────────────────────────────────┘
```

### Song Selection Screen

```yaml
Layout: 3D Carousel
View: Album covers in circular arrangement
Selection Method: Gaze + pinch or hand swipe
Preview: 30-second audio clip on hover

Information Display:
  - Album artwork (large)
  - Song title & artist
  - Duration
  - BPM
  - Difficulty ratings (E/N/H/Ex/Ex+)
  - Your best score
  - Global average score
  - Leaderboard position

Filters:
  - Genre
  - Difficulty
  - Duration
  - BPM range
  - Owned/Unowned
  - Favorites
```

### In-Game HUD

```
Top Center:
  ┌────────────────────────┐
  │  Score: 125,450        │
  │  Accuracy: 94.5%       │
  └────────────────────────┘

Left Side:
  ┌──────────┐
  │ COMBO    │
  │   87x    │ ← Grows with combo
  └──────────┘

Right Side:
  ┌──────────┐
  │ MULTI    │
  │  1.5x    │ ← Score multiplier
  └──────────┘

Bottom Center:
  [████████░░] ← Energy/Health bar

Minimal Mode (optional):
  - Hide everything except combo
  - Show score only on hit
  - Maximum immersion
```

### Results Screen

```yaml
Layout: Spatial panel, 1.5m from player

Display Order (with animations):
  1. Song title + difficulty (fade in)
  2. Grade letter (zoom + spin)
  3. Score breakdown (count up):
     - Base score
     - Combo bonus
     - Accuracy bonus
     - Final score
  4. Statistics:
     - Perfect: 234
     - Great: 45
     - Good: 12
     - Miss: 3
     - Max Combo: 234
     - Accuracy: 94.5%
  5. Comparison:
     - Personal best: +5,000
     - Friends average: +12,000
     - Global rank: #1,234
  6. Rewards earned:
     - +850 XP
     - Level up! (if applicable)
     - New unlock! (if applicable)
  7. Actions:
     - Retry
     - Next song
     - Share replay
     - Return to menu
```

### Settings Interface

```yaml
Categories:
  - Gameplay
  - Visual
  - Audio
  - Comfort
  - Accessibility
  - Privacy

Gameplay Settings:
  - Difficulty offset: -2 to +2
  - Note speed: 0.5x to 2.0x
  - No-fail mode: On/Off
  - Practice mode: On/Off
  - Auto-pause on miss: On/Off

Visual Settings:
  - Visual theme: [List]
  - Particle density: Low/Med/High
  - Brightness: 0-100%
  - Color scheme: [Presets]
  - HUD opacity: 0-100%

Audio Settings:
  - Master volume: 0-100%
  - Music volume: 0-100%
  - SFX volume: 0-100%
  - Spatial audio: On/Off
  - Audio latency calibration: -100ms to +100ms

Comfort Settings:
  - Play space size: Small/Med/Large
  - 360° gameplay: On/Off
  - Reduced motion: On/Off
  - Break reminders: Every X minutes

Accessibility Settings:
  - Seated mode: On/Off
  - One-handed mode: L/R/Off
  - Color blind mode: [Types]
  - High contrast: On/Off
  - Subtitles: On/Off
  - Voice guidance: On/Off
```

---

## Visual Style Guide

### Art Direction

**Primary Style:** Neon Cyberpunk meets Musical Energy

**Visual Principles:**
1. **Energy Visualization** - Music should be visible as flowing energy
2. **Clarity First** - Gameplay elements always readable
3. **Spatial Depth** - Use full 3D space
4. **Responsive Visuals** - Everything reacts to music and player
5. **Clean Futurism** - Modern, sleek, not cluttered

### Color Palette

#### Primary Gameplay Colors
```yaml
Note Colors (Hand Differentiation):
  Left Hand: Blue (#00D9FF)
  Right Hand: Red (#FF0055)
  Both Hands: Green (#00FF88)
  Special: Yellow (#FFD700)
  Bonus: Purple (#B900FF)

Hit Quality Feedback:
  Perfect: Gold (#FFD700)
  Great: Silver (#C0C0C0)
  Good: Bronze (#CD7F32)
  Okay: White (#FFFFFF)
  Miss: Dark Gray (#444444)

UI Colors:
  Primary: Electric Blue (#0099FF)
  Secondary: Neon Pink (#FF0099)
  Accent: Cyan (#00FFFF)
  Success: Green (#00FF00)
  Warning: Orange (#FF9900)
  Error: Red (#FF0000)
```

#### Theme Variations
```yaml
Neon Cyberpunk:
  Background: Dark purple (#1A0033)
  Accents: Cyan, magenta, yellow
  Style: Grid lines, holograms

Natural Zen:
  Background: Soft gradient (sky/water)
  Accents: Greens, blues, earth tones
  Style: Organic shapes, particles

Concert Stage:
  Background: Dark with spotlights
  Accents: Colored stage lights
  Style: Dramatic lighting, smoke

Retro Arcade:
  Background: Black with grid
  Accents: Bright primaries
  Style: Pixel art, 8-bit aesthetic
```

### Typography

```yaml
Font Family: SF Pro (Apple system font)

Hierarchy:
  - H1 (Game Title): 72pt, Bold
  - H2 (Section): 48pt, Semibold
  - H3 (Subsection): 36pt, Medium
  - Body: 24pt, Regular
  - Caption: 18pt, Light

In-Game Text:
  - Score: Monospace, Bold, Large
  - Combo: Display font, Emphasis
  - Feedback: Bold, Animated

Accessibility:
  - High contrast mode: White on black
  - Minimum size: 18pt
  - Clear letter spacing
```

### Animation Principles

```yaml
Timing:
  - Fast interactions: 0.1-0.2s
  - UI transitions: 0.3-0.4s
  - Screen transitions: 0.5-0.7s
  - Celebration animations: 1.0-2.0s

Easing:
  - Standard: Ease-in-out
  - Poppy elements: Bounce
  - Serious elements: Linear
  - Natural movement: Spring physics

Note Animations:
  - Spawn: Scale up from 0 (0.2s)
  - Approach: Smooth curve
  - Hit: Explode particles (0.3s)
  - Miss: Fade + shrink (0.5s)
```

### Visual Effects

#### Particle Systems
```yaml
Hit Effect:
  - Burst of 50-100 particles
  - Color matches note
  - Radial explosion
  - 0.5s lifetime

Combo Trail:
  - Follows hand movement
  - Color intensity increases with combo
  - Persistence: 0.3s
  - Glow effect

Perfect Streak:
  - Rainbow particles
  - Spiral pattern
  - Continuous emission
  - Audio-reactive

Environment:
  - Background ambient particles
  - Audio-reactive visuals
  - Themed to song genre
  - Non-distracting
```

---

## Audio Design

### Sound Design Philosophy

1. **Music First** - Never overshadow the song
2. **Spatial Precision** - Sound comes from note location
3. **Tactile Feedback** - Audio confirms every action
4. **Musical Integration** - SFX in key with song
5. **Dynamic Mix** - Balance changes with gameplay

### Sound Categories

#### Music
```yaml
Primary Track:
  - Full mix or stems
  - High quality (AAC 256kbps+)
  - Adaptive mixing based on performance

Background Music:
  - Menu ambience
  - Results screen music
  - Low-key, non-intrusive
```

#### Sound Effects

**Note Sounds**
```yaml
Hit Sounds (musical, pitched to song key):
  Perfect: Bright chime (harmonious)
  Great: Bell tone (pleasant)
  Good: Soft tone (acceptable)
  Okay: Dull thud (concerning)
  Miss: Discordant buzz (negative)

Note Types:
  Punch: Kick drum hit
  Swipe: Whoosh + chord
  Hold: Sustained tone
  Special: Unique per type
```

**UI Sounds**
```yaml
Menu Navigation:
  - Hover: Soft tick
  - Select: Affirmative beep
  - Back: Negative beep
  - Error: Alert sound

Feedback:
  - Combo milestone: Arpeggio up
  - Multiplier increase: Power-up sound
  - Level up: Fanfare
  - Achievement: Victory chime
```

**Ambient**
```yaml
Environmental:
  - Theme-specific atmosphere
  - Audio-reactive elements
  - Spatial positioning
  - Dynamic based on intensity
```

### Spatial Audio Implementation

```yaml
Note Audio:
  - 3D positioned at note location
  - Distance attenuation (max 10m)
  - Doppler effect for fast notes
  - Occlusion by obstacles

Environmental Audio:
  - Reverb matches room size
  - Material-based reflections
  - Head-tracking for realism

Music:
  - Primarily non-spatial (head-locked)
  - Optional: Spatial stems (drums left, bass right, etc.)
```

### Music Integration

```yaml
Stem Separation (for advanced songs):
  - Drums
  - Bass
  - Melody
  - Vocals

Dynamic Mixing:
  - Emphasize drums during punch sections
  - Highlight melody during swipe patterns
  - Reduce vocals during complex parts
  - Full mix during breaks

Audio-Reactive Visuals:
  - Particle spawn on beats
  - Color shifts on pitch changes
  - Environment pulses to bass
  - Note glow synced to music
```

---

## Accessibility Features

### Visual Accessibility

```yaml
Color Blind Modes:
  - Protanopia (red-blind)
  - Deuteranopia (green-blind)
  - Tritanopia (blue-blind)
  - Monochrome
Implementation:
  - Pattern overlays on notes
  - Shape differentiation
  - High contrast outlines

High Contrast Mode:
  - Black background
  - Pure white notes
  - Reduced particles
  - Clear boundaries

Text Scaling:
  - 100% - 200%
  - Maintains readability
  - Adjusts layout
```

### Physical Accessibility

```yaml
Seated Mode:
  - Lower note placement
  - Reduced vertical range
  - No jumping/squatting
  - Same difficulty scaling

One-Handed Mode:
  - Choose dominant hand
  - All notes adjusted to one side
  - Reduced note density
  - Maintains rhythm

Reduced Motion:
  - No camera movement
  - Minimal particle effects
  - Simplified animations
  - Static backgrounds
```

### Cognitive Accessibility

```yaml
Simplified UI:
  - Larger buttons
  - Clear icons
  - Reduced complexity
  - Consistent layouts

Gameplay Assists:
  - Slow-motion mode (0.5x-0.9x)
  - Auto-hit (aims for "Good" quality)
  - Extended timing windows
  - Visual guides for note paths
  - Practice mode with pause

Tutorials:
  - Step-by-step instructions
  - Visual demonstrations
  - Patient pacing
  - Repeat-friendly
```

### Audio Accessibility

```yaml
Deaf/Hard of Hearing:
  - Visual metronome
  - Beat pulse indicators
  - Lyric display
  - Vibration feedback (strong)
  - Visual audio cues

Subtitle Support:
  - Lyrics display
  - Sound effect descriptions
  - Directional indicators
  - Customizable size/color
```

---

## Tutorial & Onboarding

### First-Time User Experience (FTUE)

#### Session 1: Introduction (5-10 minutes)

```yaml
Step 1 - Welcome (1 min):
  - Brand video
  - What is Rhythm Flow?
  - Benefits overview
  - Safety reminder

Step 2 - Room Setup (2 min):
  - Scan play area
  - Clear obstacles
  - Confirm space size
  - Set boundaries

Step 3 - Basic Calibration (1 min):
  - Test hand tracking
  - Adjust height
  - Audio latency test
  - Verify comfortable

Step 4 - Core Tutorial (5 min):
  - Punch Tutorial:
      Song: Simple beat
      Instruction: "Punch the blue notes with your left hand"
      Practice: 20 notes
      Success: 70% hits

  - Both Hands:
      Instruction: "Now use both hands! Blue left, red right"
      Practice: 30 notes
      Success: 70% hits

  - Timing:
      Instruction: "Hit right when they reach the line"
      Visual: Hit zone indicator
      Practice: 20 notes with timing feedback

  - Swipes:
      Instruction: "Swipe in the arrow direction"
      Practice: 15 swipes
      Success: 60% hits

Step 5 - First Song (2 min):
  - Choose: 3 easy songs offered
  - Play: Full song with forgiving settings
  - Celebrate: Always get "Great job!" message
  - Reward: Unlock more songs

Step 6 - What's Next:
  - Show campaign mode
  - Show fitness mode
  - Show multiplayer
  - Encourage exploration
```

### Progressive Tutorials

```yaml
Advanced Techniques (unlock at level 5):
  - Hold notes
  - 360° gameplay
  - Obstacle dodging
  - Combo building

Fitness Mode (unlock at level 3):
  - Workout structure
  - Calorie tracking
  - Form tips
  - Goal setting

Creator Mode (unlock at level 10):
  - Beat map basics
  - Placement tools
  - Testing process
  - Publishing

Multiplayer (unlock at level 2):
  - How to invite
  - SharePlay setup
  - Battle vs Duet
  - Etiquette
```

### In-Game Hints

```yaml
Contextual Tips:
  - "Try using your whole arm for more power!"
  - "Keep your eyes on approaching notes"
  - "Take a break if you're tired"
  - "Challenge a friend to beat your score!"

Milestone Messages:
  - First perfect hit: "Perfect! Keep it up!"
  - 50 combo: "Combo master! The multiplier is rising!"
  - Song complete: "Great performance! Here's your score..."
  - New high score: "New personal best! You're improving!"
```

---

## Difficulty Balancing

### Difficulty Tiers

```yaml
Easy:
  Target Audience: Beginners, casual players
  Note Density: 1-2 notes per second
  Complexity: Single hand patterns
  Speed: 70% of normal
  Success Rate: 90%+ expected
  Patterns: Repetitive, predictable

Normal:
  Target Audience: Regular players
  Note Density: 2-4 notes per second
  Complexity: Both hands, simple combinations
  Speed: 100% normal
  Success Rate: 75-85% expected
  Patterns: Varied, learnable

Hard:
  Target Audience: Experienced players
  Note Density: 4-6 notes per second
  Complexity: Complex patterns, some 360°
  Speed: 130% of normal
  Success Rate: 60-75% expected
  Patterns: Challenging, requires practice

Expert:
  Target Audience: Skilled players
  Note Density: 6-8 notes per second
  Complexity: Advanced patterns, full 360°
  Speed: 160% of normal
  Success Rate: 50-65% expected
  Patterns: Very challenging

Expert+:
  Target Audience: Masters
  Note Density: 8-12 notes per second
  Complexity: Extreme patterns, constant movement
  Speed: 200% of normal
  Success Rate: 40-55% expected
  Patterns: For top 1% players
```

### Dynamic Difficulty Adjustment (AI)

```yaml
Monitoring Metrics:
  - Hit accuracy (last 100 notes)
  - Combo maintenance
  - Miss frequency
  - Movement efficiency
  - Frustration signals (pausing, quitting)

Adjustment Parameters:
  - Note speed: ±5-20%
  - Note density: ±10-30%
  - Pattern complexity: ±1 level
  - Rest periods: ±20%

Flow State Scoring:
  Perfect Flow (0.7-0.9):
    - Player hitting 75-90%
    - Maintaining combos
    - Steady improvement
    → No adjustment needed

Too Easy (0.9+):
    - Player hitting 90%+
    - Bored signals
    → Increase difficulty +5%

Too Hard (< 0.5):
    - Player hitting < 50%
    - Frequent misses
    → Decrease difficulty -10%

Implementation:
  - Adjust between songs, not during
  - Show notification: "Difficulty adjusted"
  - Allow manual override
  - Learn player preferences
```

---

## Monetization & Economy

### Pricing Structure

```yaml
Base Game: $39.99
  Includes:
    - 50 licensed songs
    - All game modes
    - Campaign (10 worlds)
    - Multiplayer
    - Creator tools

Song Packs: $4.99 - $9.99
  - Artist Pack (15 songs): $9.99
  - Genre Pack (10 songs): $6.99
  - Chart Toppers (20 songs): $9.99

Flow Pass Subscription: $9.99/month
  Includes:
    - All songs (200+)
    - Weekly new releases
    - Exclusive content
    - Cloud storage
    - Early access features
    - Ad-free experience

À la Carte:
  - Custom song conversion: $0.99
  - Visual themes: $2.99
  - Avatar skins: $1.99
```

### Free Content

```yaml
Free Weekly Song:
  - One song free every week
  - Rotates from library
  - Keep if you play 10 times
  - Encourage engagement

Free Events:
  - Daily challenges (always free)
  - Holiday events
  - Community events
  - Limited-time modes
```

### Progression Economy

```yaml
Earned Currency: "Flow Points"
  Earned from:
    - Playing songs: 10-50 per song
    - Daily login: 50
    - Challenges: 100-500
    - Achievements: 50-1000

  Spent on:
    - Visual themes: 5,000
    - Avatar items: 2,000-10,000
    - Replay slots: 1,000
    - Custom song slots: 2,500

No Pay-to-Win:
  - Cannot buy Flow Points with real money
  - Cosmetics only
  - Skill progression unaffected
```

---

## Conclusion

This design document establishes the creative vision for Rhythm Flow. The game balances challenge and accessibility, creating a spatial rhythm experience that's fun for everyone while rewarding mastery.

**Core Design Tenets:**
- Music and movement in harmony
- Progressive challenge that feels fair
- Inclusive design for all abilities
- Social and competitive features
- Fitness benefits without feeling like work

The next phase is implementing these designs in the actual visionOS application, following the technical architecture and specifications defined in the companion documents.
