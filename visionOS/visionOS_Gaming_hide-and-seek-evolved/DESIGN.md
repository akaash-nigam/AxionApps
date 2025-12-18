# Hide and Seek Evolved - Game Design Document

**Version:** 1.0
**Platform:** Apple Vision Pro
**Genre:** Spatial Stealth / Family Party Game
**Last Updated:** January 2025

## Table of Contents

1. [Game Design Overview](#game-design-overview)
2. [Core Gameplay Loop](#core-gameplay-loop)
3. [Player Progression System](#player-progression-system)
4. [Level Design Principles](#level-design-principles)
5. [Spatial Gameplay Design](#spatial-gameplay-design)
6. [UI/UX for Gaming](#uiux-for-gaming)
7. [Visual Style Guide](#visual-style-guide)
8. [Audio Design](#audio-design)
9. [Accessibility](#accessibility)
10. [Tutorial & Onboarding](#tutorial--onboarding)
11. [Difficulty Balancing](#difficulty-balancing)

---

## Game Design Overview

### Vision Statement

Hide and Seek Evolved transforms the timeless childhood game into a magical spatial computing experience that combines physical movement with supernatural abilities, creating moments of wonder, laughter, and connection for players of all ages.

### Design Pillars

```yaml
core_pillars:
  1_wonder:
    description: "Create magical moments through impossible abilities"
    examples:
      - "Becoming invisible while standing in plain sight"
      - "Shrinking small enough to hide in a flower pot"
      - "Seeing heat signatures like a superhero"

  2_accessibility:
    description: "Ensure everyone can play and excel"
    principles:
      - "Multiple skill paths (stealth, speed, cleverness)"
      - "Abilities for different mobility levels"
      - "AI balancing for mixed skill groups"

  3_physicality:
    description: "Encourage active movement in real space"
    goals:
      - "Get players moving around their room"
      - "Combine digital and physical hiding"
      - "Reward spatial awareness"

  4_social_connection:
    description: "Bring families and friends together"
    features:
      - "Shared space gameplay"
      - "Cooperative and competitive modes"
      - "Memorable moments worth sharing"

  5_depth:
    description: "Easy to learn, hard to master"
    progression:
      - "Simple core mechanics"
      - "Advanced ability combinations"
      - "Strategic depth through experience"
```

### Target Experience

**For Hiders:**
- Thrill of finding the perfect spot
- Satisfaction of clever ability use
- Tension of being almost discovered
- Joy of successful evasion

**For Seekers:**
- Detective satisfaction of following clues
- Power fantasy of special abilities
- Excitement of the chase
- Triumph of finding hidden players

---

## Core Gameplay Loop

### Macro Loop (Full Game Session)

```
┌──────────────────────────────────────────────┐
│  1. Welcome & Player Setup                   │
│     - Create/load player profiles            │
│     - Choose avatars                         │
│     - Configure preferences                  │
└─────────────────┬────────────────────────────┘
                  │
┌─────────────────▼────────────────────────────┐
│  2. Room Scanning (First Time / Updated)     │
│     - Scan physical space                    │
│     - Identify furniture                     │
│     - Generate hiding spots                  │
│     - Set safety boundaries                  │
└─────────────────┬────────────────────────────┘
                  │
┌─────────────────▼────────────────────────────┐
│  3. Game Configuration                       │
│     - Number of rounds                       │
│     - Round duration                         │
│     - Ability loadouts                       │
│     - Team or FFA                            │
└─────────────────┬────────────────────────────┘
                  │
┌─────────────────▼────────────────────────────┐
│  4. Round Loop (Multiple Rounds)             │ ◄─┐
│     - Role assignment                        │   │
│     - Hiding phase                           │   │
│     - Seeking phase                          │   │
│     - Round results                          │   │
└─────────────────┬────────────────────────────┘   │
                  │                                │
                  └────────────────────────────────┘
                  │
┌─────────────────▼────────────────────────────┐
│  5. Game Summary                             │
│     - Final scores                           │
│     - Highlights & funny moments             │
│     - Unlocked achievements                  │
│     - Progression updates                    │
└──────────────────────────────────────────────┘
```

### Micro Loop (Single Round)

```yaml
round_flow:
  1_role_assignment:
    duration: 10 seconds
    actions:
      - Assign hiders and seekers (rotate from previous round)
      - Display role on HUD
      - Show available abilities
      - Countdown to hiding phase

  2_hiding_phase:
    duration: 60 seconds
    hider_actions:
      - Explore room for hiding spots
      - Choose optimal location
      - Activate abilities (camouflage, size change)
      - Position for best concealment
      - Signal "ready" when positioned
    seeker_actions:
      - Face wall / eyes closed
      - Countdown timer visible
      - Anticipation building

  3_seeking_phase:
    duration: 180 seconds (3 minutes)
    hider_actions:
      - Maintain hiding position
      - Use abilities to avoid detection
      - Watch seeker movements
      - Silent movement if necessary
      - Can surrender if desired
    seeker_actions:
      - Search room systematically
      - Look for clues (footprints, disturbances)
      - Use abilities (thermal vision, sound tracking)
      - Check suspicious spots
      - Tag hiders when found
    ending_conditions:
      - All hiders found (seekers win)
      - Time expires (hiders win)
      - Emergency stop (round canceled)

  4_round_results:
    duration: 15 seconds
    actions:
      - Display winner
      - Show stats (time to find, hiding quality, etc.)
      - Award points
      - Preview next round roles
      - Countdown to next round
```

### Moment-to-Moment Gameplay

**Hider Moment:**
```
[THINKING]
"The seeker is looking this way..."
  ↓
[DECISION]
"Should I activate camouflage or stay still?"
  ↓
[ACTION]
*Activates camouflage - becomes 90% transparent*
  ↓
[TENSION]
"They're walking right toward me!"
  ↓
[OUTCOME]
"They walked right past! Success!"
  ↓
[EMOTION]
Relief, satisfaction, excitement
```

**Seeker Moment:**
```
[OBSERVATION]
"I see footprints leading to the bookshelf..."
  ↓
[DEDUCTION]
"Someone must be hiding there"
  ↓
[DECISION]
"Use thermal vision to confirm?"
  ↓
[ACTION]
*Activates thermal vision - heat signature appears*
  ↓
[OUTCOME]
"Found you! You were behind the shelf!"
  ↓
[EMOTION]
Triumph, cleverness, achievement
```

---

## Player Progression System

### Experience & Leveling

```yaml
progression_mechanics:
  player_level:
    max_level: 50
    xp_sources:
      - successful_hides: 100 XP
      - successful_seeks: 150 XP
      - perfect_round: 300 XP (all hidden/all found)
      - creative_hiding: 50 XP (using unique spots)
      - ability_mastery: 75 XP (effective ability use)
      - playing_with_family: 25 XP per round

  ability_unlocks:
    level_5:
      - Advanced Camouflage (95% opacity)
      - Enhanced Thermal Range (+2m)
    level_10:
      - Extreme Size (0.2x - 2.5x)
      - Sound Cloak (mask footsteps)
    level_15:
      - Decoy Projection (create false hider)
      - Motion Tracker (detect movement)
    level_20:
      - Phase Shift (temporary invincibility)
      - X-Ray Vision (see through one obstacle)

  customization_unlocks:
    avatars:
      - Default avatars (8 available from start)
      - Themed avatars (unlock through play)
      - Seasonal avatars (special events)
    visual_effects:
      - Camouflage patterns
      - Thermal vision colors
      - Footprint styles
      - Found/ready animations
```

### Achievement System

```yaml
categories:
  stealth_master:
    - "Ghost": Never found in 5 consecutive rounds
    - "Invisible": Win using only camouflage 10 times
    - "Tiny Titan": Win while at minimum size
    - "Perfect Hiding": 100% concealment score

  seeking_expert:
    - "Eagle Eye": Find all hiders in under 60 seconds
    - "Detective": Win using only clues (no special vision)
    - "Speed Demon": Find hider within 10 seconds
    - "Heat Seeker": 50 finds using thermal vision

  family_fun:
    - "Family Night": Play with 3+ generations
    - "Marathon": 20 rounds in one session
    - "Everyone Wins": Rotate so everyone wins at least once
    - "Helpful": Give 100 hints to other players

  creative:
    - "Innovator": Use 50 unique hiding spots
    - "Combo Master": Use 3+ abilities in one hiding session
    - "Trickster": Use decoys successfully 20 times
    - "Architect": Rearrange environment 10 times

  social:
    - "Party Host": Play with 8 different people
    - "Coach": Help new players through tutorial
    - "Good Sport": Complete 50 rounds without complaints
    - "Encouraging": Give thumbs up to all players 25 times
```

### Skill Trees (Future Content)

```yaml
skill_trees:
  stealth_path:
    tier_1:
      - Improved Camouflage Duration (+5s)
      - Faster Size Change (-0.5s)
    tier_2:
      - Camouflage While Moving
      - Silent Footsteps (automatic)
    tier_3:
      - Perfect Invisibility (100% transparent, 5s)
      - Chameleon (match surface colors)

  seeker_path:
    tier_1:
      - Extended Thermal Range (+1m)
      - Enhanced Clue Visibility
    tier_2:
      - Reduced Ability Cooldowns (-5s)
      - Movement Speed Boost
    tier_3:
      - Sixth Sense (hider direction indicator)
      - Time Extension (+30s when close to finding)
```

---

## Level Design Principles

### Room Archetypes

Since players use their own rooms, we design for common room types:

```yaml
living_room:
  characteristics:
    - Large open space
    - Sofas, chairs, coffee table
    - TV stand, shelves
    - Good vertical hiding (low furniture)
  hiding_opportunities: HIGH
  difficulty: MEDIUM
  recommended_players: 4-6

bedroom:
  characteristics:
    - Medium space
    - Bed, dresser, closet
    - Nightstands, desk
    - Great vertical hiding (under bed)
  hiding_opportunities: VERY HIGH
  difficulty: EASY (lots of spots)
  recommended_players: 2-4

kitchen:
  characteristics:
    - Smaller space
    - Counters, table, island
    - Limited hiding (mostly open)
    - Requires creative ability use
  hiding_opportunities: LOW
  difficulty: HARD (few spots)
  recommended_players: 2-3

office:
  characteristics:
    - Desk, bookshelves, file cabinets
    - Computer, office chair
    - Medium hiding spots
  hiding_opportunities: MEDIUM
  difficulty: MEDIUM
  recommended_players: 2-4

playroom:
  characteristics:
    - Toys, storage bins, play structures
    - Often colorful and varied
    - Excellent for children
  hiding_opportunities: HIGH
  difficulty: EASY
  recommended_players: 3-6

multi_room:
  characteristics:
    - Combined spaces
    - Diverse furniture mix
    - Maximum variety
  hiding_opportunities: VERY HIGH
  difficulty: VARIABLE
  recommended_players: 6-8
```

### Dynamic Environment Features

```yaml
environmental_hazards:
  none: "Family-friendly, no hazards"

environmental_bonuses:
  furniture_synergy:
    description: "Hiding behind stacked furniture increases concealment"
    bonus: +15% hiding quality

  corner_concealment:
    description: "Room corners provide natural concealment"
    bonus: "Harder to check all angles"

  lighting_advantage:
    description: "Darker areas slightly harder to spot"
    bonus: "Visual clue for good hiding"

  high_ground:
    description: "Elevated hiding (on furniture) = wider view"
    bonus: "See seeker approaching"
```

### Hiding Spot Quality Calculation

```swift
func calculateHidingQuality(
    position: SIMD3<Float>,
    room: RoomLayout,
    furniture: FurnitureItem?
) -> Float {
    var quality: Float = 0.5 // Base quality

    // Occlusion from multiple angles
    let occlusionScore = calculateOcclusionScore(position, room)
    quality += occlusionScore * 0.3

    // Furniture association
    if let furniture = furniture {
        quality += furniture.hidingPotential * 0.2
    }

    // Accessibility (penalties for hard-to-reach spots)
    let accessibility = calculateAccessibility(position)
    quality += accessibility * 0.15

    // Unexpectedness (less used spots are better)
    let novelty = 1.0 - (usageFrequency[position] ?? 0)
    quality += novelty * 0.15

    // Room coverage (distance from open areas)
    let coverage = calculateCoverage(position, room)
    quality += coverage * 0.2

    return min(max(quality, 0.0), 1.0)
}
```

---

## Spatial Gameplay Design

### Vision Pro Spatial Advantages

```yaml
spatial_features:
  1_real_furniture_integration:
    description: "Virtual abilities enhance real furniture"
    examples:
      - "Hide behind real sofa with virtual camouflage"
      - "Shrink to hide in real plant pot"
      - "Real shadows affect virtual detection"

  2_room_scale_movement:
    description: "Players physically move through space"
    benefits:
      - "Authentic hide and seek feel"
      - "Physical exercise"
      - "Spatial awareness development"

  3_mixed_reality_clues:
    description: "Digital clues in physical space"
    examples:
      - "Virtual footprints on real floor"
      - "Heat signatures on walls"
      - "Sound wave visualizations"

  4_shared_space_multiplayer:
    description: "All players in same physical room"
    advantages:
      - "Real proximity tension"
      - "Authentic social interaction"
      - "Physical celebration moments"

  5_occlusion_accuracy:
    description: "Real furniture blocks virtual elements"
    impact:
      - "Fair line-of-sight"
      - "Realistic hiding"
      - "Physical-digital unity"
```

### Spatial Comfort Design

```yaml
comfort_features:
  1_stable_reference_frame:
    - All UI anchored to world/head, not floating
    - Minimal unexpected movement
    - Clear horizon line

  2_telegraphed_transitions:
    - Size changes: 1.5s smooth scale
    - Camouflage: 2s fade
    - State changes: Visual countdown

  3_vignette_for_intensity:
    - Thermal vision: Subtle vignette
    - High tension moments: Slight blur at edges
    - Never full occlusion

  4_snap_rotation_option:
    - 30° snap turns available
    - Smooth rotation default
    - User configurable

  5_seated_mode:
    - Full gameplay from chair/couch
    - Arm-reach hiding spots highlighted
    - Virtual movement option
```

### Safe Play Space Design

```yaml
safety_systems:
  guardian_boundaries:
    visual_design:
      - Soft blue grid when approached
      - Pulsing warning at 0.5m
      - Red barrier at 0.1m
    audio_cues:
      - Gentle chime at warning distance
      - Urgent tone at boundary
    haptics:
      - Subtle pulse when close
      - Strong pulse at boundary

  furniture_safety:
    collision_prevention:
      - Highlight furniture edges in passthrough
      - Audio alert when too close
      - Slow-motion effect near collision
    safe_zones:
      - Clear paths highlighted
      - Movement suggestions

  player_collision:
    prevention:
      - Player outlines always visible
      - Proximity warning (1m)
      - Automatic pause if too close (0.3m)
```

---

## UI/UX for Gaming

### HUD Design (In-Game)

```yaml
hud_layout:
  top_center:
    - Round timer (large, always visible)
    - Current role (HIDER / SEEKER)
    - Round number (Round 3 of 5)

  top_left:
    - Player avatar
    - Active abilities with cooldown timers
    - Quick ability indicators

  top_right:
    - Mini scoreboard
    - Players found/remaining
    - Team status (if team mode)

  bottom_center:
    - Contextual prompts
      * "Press to activate camouflage"
      * "Point to search location"
      * "Thumbs up when ready"

  bottom_left:
    - Safety indicators
    - Boundary proximity warning

  bottom_right:
    - Settings quick access
    - Pause button
    - Emergency stop

minimal_mode:
  description: "Reduced HUD for experienced players"
  visible:
    - Timer only
    - Critical alerts only
  toggle: "Double tap air with both hands"
```

### Menu System Design

```yaml
main_menu:
  layout: "Floating panel in front of player"
  position: "1.5m away, eye level"
  size: "1.2m wide, 0.8m tall"

  options:
    - "▶ Play" (large, primary button)
    - "👥 Players" (manage profiles)
    - "⚙ Settings"
    - "🏆 Achievements"
    - "📊 Stats"
    - "❓ Help"

  style:
    - Translucent background (room visible through)
    - Soft shadows for depth
    - Animated hover states
    - Spatial audio on interactions

pause_menu:
  activation:
    - Hand gesture: "Palm forward"
    - Voice: "Pause game"
    - Button: Pause in HUD

  options:
    - "▶ Resume"
    - "🔄 Restart Round"
    - "⚙ Settings"
    - "❌ End Game"

  behavior:
    - Freezes game immediately
    - Blurs background
    - Maintains spatial audio (ambient only)

round_results:
  layout: "Centered celebration screen"
  duration: "15 seconds (skippable)"

  content:
    header: "HIDERS WIN!" / "SEEKERS WIN!"
    stats:
      - Time taken
      - Hiding spots used
      - Abilities activated
      - Quality score (0-100)
    next:
      - "Next round in 5... 4... 3..."
      - Role assignments shown
```

### Settings Interface

```yaml
settings_categories:
  gameplay:
    - Round duration: [2 min, 3 min, 5 min, custom]
    - Hiding time: [30s, 60s, 90s]
    - Ability cooldowns: [Standard, Short, Long, None]
    - Auto-rotate roles: [Yes, No]
    - Team mode: [FFA, 2 teams, 3 teams]

  audio:
    - Master volume: 0-100%
    - Music volume: 0-100%
    - SFX volume: 0-100%
    - Voice chat: [On, Off]
    - Spatial audio: [On, Off]

  comfort:
    - Movement type: [Physical only, Virtual assisted]
    - Rotation: [Smooth, Snap 30°, Snap 45°]
    - Vignette: [Off, Subtle, Strong]
    - Motion blur: [On, Off]

  accessibility:
    - Text size: [Small, Medium, Large, XL]
    - Contrast: [Normal, High]
    - Colorblind mode: [Off, Protanopia, Deuteranopia, Tritanopia]
    - Captions: [Off, On]
    - Voice commands: [Off, On]

  privacy:
    - Analytics: [On, Off]
    - Voice recording: [Never, Highlights only]
    - Room data storage: [Session only, Persistent]
```

---

## Visual Style Guide

### Art Direction

```yaml
visual_theme: "Magical Realism"

description: >
  Clean, family-friendly aesthetic that makes magical abilities feel
  natural in real spaces. Vibrant but not overwhelming, with particle
  effects and shaders that enhance rather than obscure reality.

color_palette:
  primary:
    - Mystic Blue: "#4A90E2"
    - Magical Purple: "#9B59B6"
    - Energy Green: "#2ECC71"

  secondary:
    - Warm Orange: "#E67E22"
    - Soft Pink: "#FF6B9D"
    - Cool Teal: "#1ABC9C"

  neutral:
    - Cloud White: "#ECF0F1"
    - Slate Gray: "#7F8C8D"
    - Deep Space: "#2C3E50"

  semantic:
    - Success Green: "#27AE60"
    - Warning Yellow: "#F39C12"
    - Error Red: "#E74C3C"
    - Info Blue: "#3498DB"
```

### Visual Effects Design

```yaml
camouflage_effect:
  activation:
    - 2s transition from opaque to transparent
    - Shimmer particles emanate from body
    - Soft glow outline during transition
    - Sound: Magical shimmer

  active_state:
    - 10-90% opacity (based on level)
    - Subtle vertex distortion (like heat haze)
    - Occasional sparkle particles
    - Outline visible to player only

  deactivation:
    - 1.5s fade back to solid
    - Particles reverse flow
    - Flash of light at full visibility

size_manipulation:
  shrinking:
    - Smooth scale down animation
    - Particle implosion effect
    - Pitch shift in voice/audio
    - Magical dust swirl

  growing:
    - Smooth scale up animation
    - Particle explosion effect
    - Deeper voice/audio pitch
    - Energy aura expansion

thermal_vision:
  visual_treatment:
    - Heat map shader overlay
    - Color gradient: Blue (cold) → Red (hot)
    - Scanline effect for tech feel
    - Slight chromatic aberration
    - Vignette to focus attention

  player_highlights:
    - Warm red-orange glow
    - Pulsing intensity
    - Outline enhancement
    - Heat shimmer particles

clue_visualization:
  footprints:
    - Glowing blue-white impressions
    - Fade out over 30 seconds
    - Particle trail leading to next print
    - Subtle shimmer

  disturbances:
    - Yellow-orange indicator markers
    - Floating question mark icons
    - Pulsing attention animation
    - Connecting lines between related clues

ui_elements:
  buttons:
    - Rounded rectangle (12px radius)
    - Frosted glass material
    - Subtle drop shadow
    - Scale animation on hover (1.05x)
    - Haptic feedback on press

  panels:
    - Translucent background (20% opacity)
    - Soft blur behind panel
    - Edge glow (1px, subtle)
    - Smooth fade in/out transitions

  text:
    - Font: SF Pro (Apple system font)
    - Title: 32pt, Bold
    - Body: 18pt, Regular
    - Caption: 14pt, Medium
    - Always high contrast with background
```

### Avatar Design

```yaml
avatar_style:
  aesthetic: "Simple, friendly, expressive"
  representation: "Abstract humanoid shapes"

  customization:
    body_type: [Slim, Average, Athletic, Stocky]
    height: [Short, Medium, Tall]
    color_primary: [20+ colors]
    color_secondary: [20+ colors]
    pattern: [Solid, Stripes, Dots, Gradient]
    accessory: [Hat, Glasses, Cape, etc.]

  animation:
    idle: "Gentle breathing motion"
    walking: "Simple step animation"
    hiding: "Crouched/small pose"
    found: "Surprised expression"
    victory: "Arms raised, jumping"
    defeat: "Slumped shoulders"
```

---

## Audio Design

### Music System

```yaml
music_structure:
  adaptive_music: true
  layers: 4

  tension_levels:
    level_0_menu:
      description: "Calm, inviting"
      instruments: [Piano, soft strings]
      tempo: 80 BPM
      mood: "Welcoming, peaceful"

    level_1_hiding:
      description: "Gentle suspense"
      instruments: [Piano, strings, light percussion]
      tempo: 90 BPM
      mood: "Anticipation, focus"

    level_2_seeking_start:
      description: "Building tension"
      instruments: [Full orchestration]
      tempo: 110 BPM
      mood: "Active, searching"

    level_3_almost_found:
      description: "High intensity"
      instruments: [Full orchestra, dramatic percussion]
      tempo: 130 BPM
      mood: "Excitement, danger"

    level_4_found:
      description: "Climax moment"
      instruments: [Stinger, full orchestral hit]
      duration: 3 seconds
      mood: "Victory/defeat"

  dynamic_transitions:
    - Seeker approaches hider: Gradually increase tension
    - Hider activates ability: Brief magical flourish
    - Timer running low: Add urgency (faster tempo, more percussion)
    - Round end: Resolve to victory/defeat theme
```

### Sound Effects

```yaml
gameplay_sfx:
  abilities:
    camouflage_activate:
      sound: "Magical shimmer with chimes"
      duration: 2s
      spatial: true
      volume: Medium

    size_shrink:
      sound: "Whoosh down with pitch drop"
      duration: 1.5s
      spatial: true
      volume: Medium

    size_grow:
      sound: "Whoosh up with pitch rise"
      duration: 1.5s
      spatial: true
      volume: Medium

    thermal_vision:
      sound: "Electronic hum with ping"
      duration: 0.5s (activation) + loop
      spatial: false
      volume: Low

  detection:
    player_found:
      sound: "Success fanfare"
      duration: 2s
      spatial: true
      volume: High

    clue_discovered:
      sound: "Soft ping"
      duration: 0.3s
      spatial: true
      volume: Medium

    footstep:
      sound: "Subtle step (varies by surface)"
      duration: 0.2s
      spatial: true
      volume: Low

  ui:
    button_press:
      sound: "Soft click"
      duration: 0.1s
      spatial: false
      volume: Low

    menu_open:
      sound: "Whoosh in"
      duration: 0.3s
      spatial: false
      volume: Medium

    countdown:
      sound: "Beep (pitch rises each second)"
      duration: 0.1s
      spatial: false
      volume: Medium

  safety:
    boundary_warning:
      sound: "Gentle chime"
      duration: 0.5s
      spatial: true
      volume: Medium

    boundary_critical:
      sound: "Urgent beep"
      duration: 0.3s
      spatial: true
      volume: High
```

### Spatial Audio Implementation

```yaml
spatial_audio_features:
  player_positioning:
    - 3D audio for all players
    - Footstep direction and distance
    - Breathing sounds when close (if enabled)
    - Voice chat with spatial positioning

  environmental_audio:
    - Room reverb based on scanned geometry
    - Furniture occlusion of sounds
    - Distance attenuation
    - Doppler effect for fast movement

  ability_audio:
    - Camouflage shimmer emanates from player
    - Thermal vision scanner sweep (directional)
    - Size change whoosh from player center
    - Clue discovery ping at clue location

  ambience:
    - Subtle room tone
    - Occasional magical sparkle sounds
    - Environmental enhancement (virtual)
    - Day/night ambience variation
```

---

## Accessibility

### Visual Accessibility

```yaml
colorblind_modes:
  protanopia:
    - Red-green color blindness
    - Replace red with blue tones
    - Increase contrast for important elements

  deuteranopia:
    - Red-green color blindness (different type)
    - Use orange and blue instead of red/green
    - Pattern overlays for color-coded elements

  tritanopia:
    - Blue-yellow color blindness
    - Replace blue with purple
    - Use high contrast text

high_contrast_mode:
  - Black text on white backgrounds
  - Thick borders on all UI elements
  - Simplified visual effects
  - Enhanced outlines on interactive elements

text_scaling:
  - 150% scale option
  - 200% scale option
  - Dynamic layout adjustment
  - Minimum touch target: 44pt

visual_assistance:
  - Outline glow on all players (always visible)
  - Enhanced hiding spot indicators
  - Larger UI elements
  - Reduced visual clutter option
```

### Auditory Accessibility

```yaml
deaf_hard_of_hearing:
  captions:
    - All voice chat captioned
    - Sound effect captions
      * "[Footsteps approaching]"
      * "[Magical shimmer]"
      * "[Countdown beep]"
    - Directional indicators for spatial sounds
    - Customizable caption size and background

  visual_indicators:
    - Sound wave visualization (direction + intensity)
    - Vibration patterns for audio cues
    - Visual countdown instead of audio
    - Flashing border for important events

audio_customization:
  - Individual volume sliders (music, SFX, voice, ambient)
  - Mono audio option
  - Audio compression for dynamic range
  - Tinnitus frequency reduction
```

### Motor Accessibility

```yaml
limited_mobility:
  seated_mode:
    - Full gameplay from chair/sofa
    - Hiding spots within arm's reach
    - Virtual movement option
    - Reduced physical requirements

  alternative_controls:
    - Voice commands for all actions
    - Eye tracking for UI navigation
    - Single-hand mode
    - Reduced gesture complexity
    - Button/controller support

  ability_assists:
    - Auto-activate abilities based on situation
    - Extended cooldown but stronger effects
    - AI suggestions for hiding spots
    - Guided movement to optimal locations

customization:
  - Adjustable gesture sensitivity
  - Hold duration adjustment
  - Sticky targeting (lock onto targets)
  - Automation options for repetitive actions
```

### Cognitive Accessibility

```yaml
simplification_options:
  simple_mode:
    - Reduced ability count (2 instead of 5)
    - Longer round times
    - Clearer instructions
    - Visual guides throughout

  tutorial_assistance:
    - Repeat tutorial option
    - Step-by-step guides
    - Practice mode (no pressure)
    - AI partner for learning

  ui_clarity:
    - Simple language
    - Iconography with labels
    - Clear visual hierarchy
    - Reduced animation/motion

  time_pressure:
    - Adjustable timers
    - Option to disable timer
    - Pause anytime
    - No competitive pressure mode
```

---

## Tutorial & Onboarding

### First-Time User Experience (FTUE)

```yaml
onboarding_flow:
  step_1_welcome:
    duration: 30 seconds
    content:
      - Welcome message
      - Brief game explanation (video/animation)
      - Privacy and safety notice
      - "Let's get started!" CTA

  step_2_room_scanning:
    duration: 2-3 minutes
    content:
      - "Scan your room" instructions
      - Visual guide for good scanning
      - Progress indicator
      - Furniture detection feedback
      - "Great! Found [X] hiding spots!"

  step_3_player_setup:
    duration: 1 minute
    content:
      - "Create your profile"
      - Name input
      - Avatar customization
      - Accessibility preferences
      - Save and continue

  step_4_movement_tutorial:
    duration: 2 minutes
    content:
      - "Let's learn to move"
      - Walk around play area
      - Practice hiding gesture
      - Practice seeking gesture
      - Boundary system explanation

  step_5_hiding_tutorial:
    duration: 3 minutes
    content:
      - "You're a HIDER first"
      - Find a hiding spot (guided)
      - Activate camouflage (practice)
      - Try size manipulation (practice)
      - "Stay still, seeker coming!"

  step_6_seeking_tutorial:
    duration: 3 minutes
    content:
      - "Now you're a SEEKER"
      - Look for clues (footprints highlighted)
      - Try thermal vision (guided)
      - Find AI hider (easy)
      - "You found them! Great job!"

  step_7_full_round:
    duration: 5 minutes
    content:
      - "Ready for a full round?"
      - Play complete round vs AI
      - All systems active
      - Light hints if struggling
      - Victory celebration

  step_8_multiplayer:
    duration: 1 minute
    content:
      - "Invite friends to play!"
      - Multiplayer setup explanation
      - SharePlay tutorial
      - "You're ready! Have fun!"

total_onboarding_time: 15-20 minutes
skippable: "Yes, after step 4"
replay: "Always available in Help menu"
```

### Contextual Tutorials

```yaml
just_in_time_tutorials:
  first_ability_use:
    trigger: "Player unlocks new ability"
    content: "Brief explanation + practice"
    duration: 30 seconds

  first_multiplayer:
    trigger: "Player joins multiplayer session"
    content: "Multiplayer-specific tips"
    duration: 45 seconds

  new_room:
    trigger: "Playing in newly scanned room"
    content: "Room-specific hiding tips"
    duration: 20 seconds

  achievement_unlock:
    trigger: "First achievement earned"
    content: "Achievement system explanation"
    duration: 30 seconds
```

---

## Difficulty Balancing

### Dynamic Difficulty Adjustment

```yaml
difficulty_factors:
  player_skill_rating:
    calculation:
      - Success rate (hiding/seeking)
      - Average time to complete objectives
      - Ability usage effectiveness
      - Historical performance
    range: 0.0 (novice) - 1.0 (expert)

  auto_balancing:
    hider_adjustments:
      novice:
        - Better hiding spots suggested
        - Longer camouflage duration (+5s)
        - More obvious spots highlighted
        - Gentle hints if stuck

      expert:
        - Harder spots required for high score
        - Standard ability durations
        - Fewer visual guides
        - Faster seekers

    seeker_adjustments:
      novice:
        - More frequent clues generated
        - Brighter clue highlighting
        - Generous thermal vision range
        - Extended seeking time (+30s)

      expert:
        - Fewer clues
        - Subtle clue appearance
        - Standard thermal range
        - Standard seeking time
        - Hiders get better abilities

ai_opponent_scaling:
  easy:
    - Predictable patterns
    - Uses one ability at a time
    - Makes "mistakes"
    - Reacts slowly

  medium:
    - Varied strategies
    - Combines abilities
    - Good spatial awareness
    - Normal reaction time

  hard:
    - Optimal strategies
    - Advanced ability combos
    - Excellent spatial awareness
    - Fast reactions

  adaptive:
    - Adjusts to player performance
    - Matches player skill level
    - Creates close matches
    - Learns from player behavior
```

### Fairness Systems

```yaml
role_balancing:
  automatic_rotation:
    - Players alternate roles each round
    - Ensures everyone gets to hide and seek
    - Tracks stats separately for each role

  team_balancing:
    - AI assigns teams based on skill
    - Mixes experienced and new players
    - Adjusts team size for fairness
    - Rebalances if one team dominates

hiding_spot_allocation:
  quality_distribution:
    - AI ensures all players have access to good spots
    - Adjusts spot quality based on player size/ability
    - No spots reserved exclusively for high-level players
    - Seasonal rotation of "premium" spots

ability_balancing:
  cooldown_adjustment:
    - Powerful abilities = longer cooldowns
    - Weaker abilities = shorter cooldowns
    - Context-sensitive (if player struggling, reduce cooldowns)

  counter_abilities:
    - Every hider ability has seeker counter
    - Camouflage ↔ Thermal Vision
    - Size Manipulation ↔ Enhanced Clue Detection
    - Sound Masking ↔ Audio Tracking
```

---

## Conclusion

This design document establishes:

1. **Clear Design Vision**: Magical, accessible, social, physical gameplay
2. **Engaging Progression**: Unlockable abilities, achievements, skill trees
3. **Polished UX**: Intuitive controls, beautiful visuals, spatial audio
4. **Accessibility**: Comprehensive options for all players
5. **Balanced Gameplay**: Fair, fun, and challenging for all skill levels

The design prioritizes family fun, physical activity, and memorable shared experiences while leveraging Vision Pro's unique spatial computing capabilities.
