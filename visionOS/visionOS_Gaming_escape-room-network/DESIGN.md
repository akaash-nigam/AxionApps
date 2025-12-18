# Escape Room Network - Game Design Document

## Table of Contents
1. [Game Design Overview](#game-design-overview)
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

## Game Design Overview

### Vision Statement

**Escape Room Network** transforms physical spaces into collaborative puzzle-solving experiences, where players work together across distances to solve mysteries that span their real-world environments.

### Core Pillars

1. **Spatial Discovery**: Every room becomes a unique puzzle space
2. **Collaborative Problem-Solving**: Teamwork across distances
3. **Adaptive Challenge**: AI-driven difficulty matching player skill
4. **Seamless Integration**: Virtual elements blend naturally with reality

### Player Fantasy

*"I'm a detective/explorer solving impossible mysteries in my own home, working with friends across the world to escape increasingly complex scenarios that use our actual rooms in creative ways."*

---

## Core Gameplay Loop

### Primary Loop (15-60 minutes)

```
Start Puzzle
    ↓
Explore Room → Discover Clues → Solve Sub-Puzzles
    ↓           ↓                    ↓
    ←───────────┴────────────────────┘
    ↓
Complete Objective → Unlock Next Area/Puzzle
    ↓
All Objectives Complete → Escape Success
    ↓
Rewards & Progression
    ↓
Choose Next Puzzle
```

### Secondary Loops

**Mastery Loop** (Weeks)
```
Play Beginner Puzzles → Develop Skills → Unlock Advanced Puzzles
    ↓                       ↓                ↓
    ←───────────────────────┴────────────────┘
    ↓
Compete on Leaderboards → Community Recognition
```

**Social Loop** (Ongoing)
```
Solo Practice → Invite Friends → Multiplayer Sessions
    ↓              ↓                 ↓
    ←──────────────┴─────────────────┘
    ↓
Share Achievements → Community Building
```

**Creation Loop** (Advanced)
```
Play Puzzles → Learn Design → Create Custom Puzzles
    ↓             ↓               ↓
    ←─────────────┴───────────────┘
    ↓
Share with Community → Get Feedback → Iterate
```

---

## Player Progression Systems

### Experience & Leveling

```yaml
progression:
  max_level: 50

  xp_sources:
    - puzzle_completion: 100-500 XP (based on difficulty)
    - speed_bonus: up to 100 XP
    - no_hints_bonus: 50 XP
    - perfect_solve: 100 XP
    - multiplayer_teamwork: 75 XP
    - daily_challenge: 200 XP

  level_rewards:
    level_5: "Unlock Intermediate Puzzles"
    level_10: "Custom Room Builder Access"
    level_15: "Advanced Puzzle Types"
    level_20: "Creator Tools Pro"
    level_25: "Expert Difficulty"
    level_30: "Custom Puzzle Sharing"
    level_50: "Master Detective Title"

skill_trees:
  observation:
    - enhanced_hint_vision
    - faster_clue_discovery
    - hidden_object_mastery

  logic:
    - pattern_recognition_boost
    - code_breaking_assistance
    - puzzle_complexity_preference

  collaboration:
    - team_coordination_tools
    - shared_vision_markers
    - voice_clarity_enhancement
```

### Unlockable Content

```yaml
unlockables:
  puzzle_packs:
    - name: "Mystery Manor"
      unlock_level: 5
      puzzles: 10

    - name: "Sci-Fi Station"
      unlock_level: 10
      puzzles: 15

    - name: "Historical Heist"
      unlock_level: 15
      puzzles: 12

  customization:
    - avatar_accessories
    - virtual_object_skins
    - room_themes
    - celebration_effects

  tools:
    - advanced_hint_system
    - puzzle_creation_templates
    - analytics_dashboard
```

### Achievements

```yaml
achievements:
  speed_runner:
    description: "Complete 10 puzzles in under 15 minutes each"
    reward: "Speed Runner Badge"

  detective:
    description: "Complete 50 puzzles without using hints"
    reward: "Detective Title"

  team_player:
    description: "Complete 25 multiplayer puzzles"
    reward: "Team Player Badge"

  architect:
    description: "Create 10 custom puzzles with 4+ star ratings"
    reward: "Architect Title"

  explorer:
    description: "Play puzzles in 5 different rooms"
    reward: "Explorer Badge"
```

---

## Level Design Principles

### Puzzle Structure

Every puzzle follows a **three-act structure**:

**Act 1: Discovery** (25% of puzzle)
- Player explores room
- Discovers initial clues
- Understands basic mechanics
- Low difficulty, high engagement

**Act 2: Challenge** (50% of puzzle)
- Multiple interconnected sub-puzzles
- Requires critical thinking
- May need teamwork (multiplayer)
- Medium-high difficulty

**Act 3: Resolution** (25% of puzzle)
- Final puzzle ties everything together
- Uses knowledge from previous sections
- Satisfying "aha!" moment
- Dramatic escape sequence

### Puzzle Types

```yaml
puzzle_categories:
  logic:
    - code_breaking
    - pattern_matching
    - sequence_solving
    - symbolic_reasoning

  spatial:
    - alignment_puzzles
    - perspective_challenges
    - 3d_manipulation
    - room_navigation

  observation:
    - hidden_object_finding
    - detail_spotting
    - environmental_storytelling
    - clue_collection

  collaborative:
    - information_asymmetry
    - simultaneous_actions
    - complementary_roles
    - communication_challenges

  physical:
    - object_manipulation
    - gesture_sequences
    - hand_coordination
    - precision_placement
```

### Environmental Integration

```yaml
room_adaptation:
  living_room:
    - use_furniture: sofas, tables, TV area
    - puzzle_types: hidden_objects, perspective_alignment
    - difficulty_modifier: 1.0x

  bedroom:
    - use_furniture: bed, dresser, closet
    - puzzle_types: sequential_discovery, intimate_details
    - difficulty_modifier: 0.9x (smaller space)

  kitchen:
    - use_furniture: counters, cabinets, appliances
    - puzzle_types: logical_sequences, object_placement
    - difficulty_modifier: 1.1x (complex geometry)

  multi_room:
    - use_furniture: all_available
    - puzzle_types: interconnected_mysteries
    - difficulty_modifier: 1.3x (requires navigation)
```

---

## Spatial Gameplay Design

### Interaction Zones

```
┌─────────────────────────────────────────┐
│           Spatial Design Zones           │
├─────────────────────────────────────────┤
│                                         │
│  Near Field (0.3m - 0.8m)              │
│  - Detail examination                   │
│  - Fine manipulation                    │
│  - Reading clues                        │
│                                         │
│  Mid Field (0.8m - 2m)                 │
│  - Primary puzzle interaction           │
│  - Object placement                     │
│  - Gesture controls                     │
│                                         │
│  Far Field (2m - 5m)                   │
│  - Room exploration                     │
│  - Multi-object relationships           │
│  - Environmental puzzles                │
│                                         │
└─────────────────────────────────────────┘
```

### Hand Interaction Design

```yaml
interactions:
  pinch:
    action: "Select/Pickup small objects"
    visual_feedback: "Object highlights, lifts slightly"
    audio_feedback: "Subtle click sound"

  grab:
    action: "Grab and move large objects"
    visual_feedback: "Hand outline matches object"
    audio_feedback: "Grab sound, ambient while holding"

  rotate:
    action: "Rotate held object"
    visual_feedback: "Rotation axis indicator"
    audio_feedback: "Mechanical rotation sound"

  point:
    action: "Mark locations for teammates"
    visual_feedback: "Floating marker appears"
    audio_feedback: "Notification chime"

  swipe:
    action: "Navigate UI, flip pages"
    visual_feedback: "Smooth transition"
    audio_feedback: "Page turn sound"
```

### Gaze Integration

```yaml
gaze_mechanics:
  object_highlighting:
    trigger: "Look at interactive object for 0.5s"
    effect: "Subtle glow, name appears"

  contextual_hints:
    trigger: "Look at puzzle element for 3s while stuck"
    effect: "Hint overlay appears"

  teammate_attention:
    trigger: "Look at teammate avatar"
    effect: "Show their current focus"

  environmental_scanning:
    trigger: "Sweep gaze across room"
    effect: "Reveal hidden clue indicators"
```

---

## UI/UX for Gaming

### HUD Design

```
┌─────────────────────────────────────────┐
│                                         │
│  [Timer]              [Objectives: 2/5] │
│                                         │
│                                         │
│                                         │
│         [GAMEPLAY AREA]                 │
│                                         │
│                                         │
│                                         │
│  [Hint Available]    [Teammates: 3]    │
│                                         │
│        [Inventory]  [Menu ⋮]           │
└─────────────────────────────────────────┘
```

**HUD Elements:**

```yaml
persistent_hud:
  timer:
    position: "top_left"
    style: "minimalist, non-intrusive"
    visibility: "always_visible"

  objectives:
    position: "top_right"
    style: "checklist with icons"
    visibility: "toggle_with_gaze"

  teammates:
    position: "bottom_right"
    style: "avatar icons with status"
    visibility: "always_visible_in_multiplayer"

  inventory:
    position: "bottom_left"
    style: "compact item grid"
    visibility: "expand_on_look"

  hints:
    position: "left_center"
    style: "pulsing icon when available"
    visibility: "appear_when_stuck"
```

### Menu System

**Main Menu**
```
┌─────────────────────────────────┐
│   ESCAPE ROOM NETWORK           │
│                                 │
│   [Play Solo]                   │
│   [Play with Friends]           │
│   [Daily Challenge]             │
│   [Browse Puzzles]              │
│   [Create Room]                 │
│   [Settings]                    │
│   [Achievements]                │
└─────────────────────────────────┘
```

**In-Game Pause Menu**
```
┌─────────────────────────────────┐
│   PAUSED                        │
│                                 │
│   [Resume]                      │
│   [View Objectives]             │
│   [Get Hint]                    │
│   [Settings]                    │
│   [Exit to Menu]                │
└─────────────────────────────────┘
```

### Spatial UI Principles

```yaml
ui_design_rules:
  comfort:
    - "Keep UI 0.8m - 2m from viewer"
    - "Avoid rapid UI movement"
    - "Fade in/out smoothly (0.3s)"

  readability:
    - "Minimum font size: 24pt"
    - "High contrast (WCAG AAA)"
    - "Clear spacing between elements"

  interaction:
    - "Buttons minimum 60x60mm"
    - "Hover state before selection"
    - "Audio + visual feedback"

  integration:
    - "UI anchored to room surfaces when possible"
    - "Transparent backgrounds"
    - "Respect room geometry"
```

---

## Visual Style Guide

### Art Direction

**Theme:** Neo-Mystery Aesthetic
- Clean, modern interface design
- Holographic virtual objects
- Environmental lighting integration
- Minimalist puzzle elements with detailed textures

### Color Palette

```yaml
primary_colors:
  brand_blue: "#00A8E8"
  mystery_purple: "#7B2CBF"
  accent_cyan: "#00F5D4"

ui_colors:
  background: "#1A1A2E"
  surface: "#16213E"
  text_primary: "#FFFFFF"
  text_secondary: "#B4B4B4"

gameplay_colors:
  clue_indicator: "#FFD60A"  # Gold
  locked_element: "#C1121F"  # Red
  unlocked_element: "#00B4D8"  # Blue
  teammate_marker: "#06FFA5"  # Green
  hint_glow: "#F72585"  # Pink
```

### Visual Effects

```yaml
effects:
  discovery:
    type: "particle_burst"
    color: "gold"
    duration: 1.5s

  unlock:
    type: "hologram_fade_in"
    color: "cyan"
    duration: 2.0s

  completion:
    type: "energy_wave"
    color: "green"
    duration: 3.0s

  hint_reveal:
    type: "pulsing_glow"
    color: "pink"
    duration: "continuous"

  teammate_action:
    type: "light_trail"
    color: "purple"
    duration: 1.0s
```

### Typography

```yaml
fonts:
  display:
    family: "SF Pro Rounded"
    weight: "Bold"
    use: "Titles, headers"

  ui:
    family: "SF Pro"
    weight: "Medium"
    use: "Buttons, labels"

  body:
    family: "SF Pro"
    weight: "Regular"
    use: "Clues, descriptions"

  monospace:
    family: "SF Mono"
    weight: "Regular"
    use: "Codes, technical puzzles"

sizes:
  title: 48pt
  heading: 32pt
  body: 24pt
  caption: 18pt
```

---

## Audio Design

### Audio Categories

```yaml
music:
  menu_theme:
    style: "Ambient electronic"
    tempo: 80 BPM
    mood: "Mysterious, inviting"

  gameplay_ambient:
    style: "Adaptive atmospheric"
    tempo: "Variable based on tension"
    layers:
      - base_atmosphere
      - tension_layer
      - discovery_motif

  victory_theme:
    style: "Uplifting orchestral electronic"
    tempo: 120 BPM
    mood: "Triumphant, satisfying"

sfx:
  interaction:
    - object_pickup
    - object_place
    - object_rotate
    - button_press
    - drawer_open
    - lock_click

  puzzle:
    - clue_discovered
    - puzzle_progress
    - puzzle_complete
    - hint_appear
    - timer_warning

  ui:
    - menu_select
    - menu_back
    - notification
    - achievement_unlock

  social:
    - player_joined
    - player_left
    - teammate_discovery
    - voice_chat_toggle

voice:
  narrator:
    style: "Professional, mysterious"
    use: "Tutorial, story elements"

  hints:
    style: "Helpful, encouraging"
    use: "Adaptive hint system"
```

### Spatial Audio Design

```yaml
3d_audio:
  clue_objects:
    type: "Point source"
    attenuation: "Natural rolloff"
    max_distance: 10m
    effect: "Subtle audio beacon for discovery"

  environmental:
    type: "Ambient soundscape"
    attenuation: "Room-based"
    effect: "Immersive atmosphere"

  teammate_voice:
    type: "Positional voice chat"
    attenuation: "Distance + obstruction aware"
    max_distance: 50m (virtual)
    effect: "Natural conversation placement"

  music:
    type: "Non-spatial stereo"
    effect: "Consistent mood setting"
```

### Adaptive Music System

```yaml
music_layers:
  tension_levels:
    calm:
      - ambient_pad
      - subtle_melody

    engaged:
      - ambient_pad
      - subtle_melody
      - rhythm_layer

    challenged:
      - ambient_pad
      - subtle_melody
      - rhythm_layer
      - tension_strings

    urgent:
      - all_layers
      - intensity_percussion
      - pitch_shift: +2

  triggers:
    - time_remaining < 5min: "urgent"
    - puzzle_near_solution: "challenged"
    - actively_solving: "engaged"
    - exploring: "calm"
```

---

## Accessibility

### Visual Accessibility

```yaml
visual_options:
  colorblind_modes:
    - protanopia
    - deuteranopia
    - tritanopia

  text_scaling:
    range: "100% - 200%"
    default: "100%"

  high_contrast:
    enabled: "Toggle in settings"
    effect: "Enhanced UI contrast, thicker outlines"

  reduced_motion:
    enabled: "Toggle in settings"
    effect: "Disable particle effects, smooth camera only"

  visual_indicators:
    audio_to_visual: "Sound waves shown as visual ripples"
    distance_markers: "Grid overlay for spatial awareness"
```

### Audio Accessibility

```yaml
audio_options:
  subtitles:
    all_dialogue: true
    sound_descriptions: "Optional"
    size: "Adjustable"

  audio_cues:
    visual_alternatives: "Light flashes for important sounds"
    haptic_feedback: "Controller vibration"

  voice_chat:
    text_chat_alternative: true
    speech_to_text: true
    text_to_speech: true
```

### Motor Accessibility

```yaml
motor_options:
  alternative_controls:
    - eye_tracking_only
    - voice_commands
    - game_controller
    - accessibility_switch

  interaction_assistance:
    auto_grab: "Objects snap to hand when close"
    hold_duration_adjust: "0.1s - 2s"
    gesture_simplification: "Simplified gestures available"

  gameplay_adjustments:
    no_time_limit: "Optional timer disable"
    pause_anytime: "Always available"
    hint_frequency: "Increased for assistance"
```

### Cognitive Accessibility

```yaml
cognitive_options:
  difficulty_assistance:
    - simplified_puzzles
    - more_frequent_hints
    - objective_reminders
    - step_by_step_guides

  ui_simplification:
    - reduced_ui_elements
    - larger_touch_targets
    - clear_visual_hierarchy

  gameplay_pace:
    - extended_time_limits
    - automatic_pauses
    - progress_saving_anywhere
```

---

## Tutorial & Onboarding

### First Time User Experience (FTUE)

**Step 1: Welcome (2 minutes)**
```
1. Welcome screen with app overview
2. Privacy & permissions explanation
3. Basic gesture tutorial (pinch, grab, point)
4. Comfort settings configuration
```

**Step 2: Room Scanning (3 minutes)**
```
1. Guided room scanning tutorial
2. Show how app recognizes furniture
3. Explain spatial anchor concept
4. Preview how puzzles will appear
```

**Step 3: First Puzzle (5 minutes)**
```
1. Simple single-room tutorial puzzle
2. Teaches core mechanics:
   - Finding clues
   - Interacting with objects
   - Solving simple logic puzzle
   - Using hints
3. Celebrates completion
4. Explains progression system
```

**Step 4: Multiplayer Introduction (Optional, 5 minutes)**
```
1. Invite friend or play with AI teammate
2. Teaches communication
3. Collaborative puzzle solving
4. SharePlay setup
```

### Progressive Tutorialization

```yaml
tutorial_moments:
  first_clue:
    trigger: "Player looks around for 10s"
    message: "Look for glowing objects - they're clues!"

  first_interaction:
    trigger: "Gaze at clue for 2s without interacting"
    message: "Pinch your fingers together to pick it up"

  first_puzzle:
    trigger: "Examining first puzzle mechanism"
    message: "Try rotating this to align the symbols"

  first_hint:
    trigger: "Stuck for 2 minutes"
    message: "Need help? Look at the Hint button"

  first_multiplayer:
    trigger: "Starting first multiplayer session"
    message: "Work together! Share what you see with your teammates"
```

---

## Difficulty Balancing

### Difficulty Levels

```yaml
difficulty_system:
  beginner:
    puzzle_complexity: "3-5 steps"
    clue_visibility: "High (glowing indicators)"
    hint_frequency: "Every 2 minutes if stuck"
    time_limit: "None"
    target_completion: "15-20 minutes"

  intermediate:
    puzzle_complexity: "5-8 steps"
    clue_visibility: "Medium (subtle highlights)"
    hint_frequency: "Every 5 minutes if stuck"
    time_limit: "Optional 45 minutes"
    target_completion: "25-35 minutes"

  advanced:
    puzzle_complexity: "8-12 steps"
    clue_visibility: "Low (minimal indicators)"
    hint_frequency: "Every 10 minutes if stuck"
    time_limit: "Optional 30 minutes"
    target_completion: "40-60 minutes"

  expert:
    puzzle_complexity: "12+ steps, multi-layered"
    clue_visibility: "Minimal (natural integration)"
    hint_frequency: "Limited (3 hints total)"
    time_limit: "Optional 60 minutes"
    target_completion: "60-90 minutes"
```

### Adaptive Difficulty

```yaml
dynamic_adjustment:
  skill_tracking:
    - puzzle_completion_time
    - hint_usage_frequency
    - success_rate
    - complexity_preference

  auto_adjustment:
    performing_well:
      - "Suggest higher difficulty"
      - "Add optional challenge objectives"
      - "Unlock advanced puzzle types"

    struggling:
      - "Offer easier variations"
      - "Increase hint frequency"
      - "Add guided mode"

  player_control:
    manual_override: "Always available"
    preference_saving: true
```

### Balancing Metrics

```yaml
success_metrics:
  completion_rate:
    target: "85%"
    beginner: "95%"
    intermediate: "85%"
    advanced: "75%"
    expert: "60%"

  player_satisfaction:
    challenge_rating: "7-8/10 (challenging but fair)"
    frustration_points: "< 2 per puzzle"
    eureka_moments: "> 3 per puzzle"

  engagement:
    average_session: "30-45 minutes"
    return_rate: "> 70% within 3 days"
    puzzle_replay: "20% of players"
```

---

## Puzzle Examples

### Example 1: "The Hidden Code"

```yaml
puzzle_name: "The Hidden Code"
difficulty: Beginner
type: Logic + Observation
duration: 15 minutes

setup:
  - 4 virtual number panels appear on different walls
  - Each panel shows a symbol (moon, star, sun, cloud)
  - A virtual safe appears on coffee table

solution:
  1. Observe symbols on each panel
  2. Notice symbols match items in room (moon clock, star photo, etc.)
  3. Count how many of each symbol in room
  4. Enter counts into safe in panel order
  5. Safe opens, puzzle complete

hint_progression:
  hint_1: "Look around - do you see these symbols anywhere else?"
  hint_2: "Try counting how many of each symbol you find"
  hint_3: "Enter the counts into the safe in the same order as the panels"
```

### Example 2: "Synchronized Actions"

```yaml
puzzle_name: "Synchronized Actions"
difficulty: Intermediate
type: Collaborative + Spatial
duration: 30 minutes
players: 2-4

setup:
  - Each player sees unique colored buttons in their room
  - All players see a central shared timer
  - Virtual energy beams connect between rooms

solution:
  1. Players discover they each see different button colors
  2. Players must communicate which colors they see
  3. Determine correct sequence by combining information
  4. All players press their buttons simultaneously
  5. Energy beams align, next area unlocks

hint_progression:
  hint_1: "Share what you see - your views are different!"
  hint_2: "The sequence combines everyone's colors"
  hint_3: "You need to act at the same time"
```

---

## Summary

This design document establishes:

1. **Core Gameplay**: Clear loops from 15-minute puzzles to long-term progression
2. **Player Progression**: Level system, unlockables, and skill trees
3. **Spatial Design**: Three interaction zones optimized for Vision Pro
4. **Comprehensive UI/UX**: Intuitive HUD and menu systems
5. **Rich Audio**: Adaptive music and spatial sound design
6. **Full Accessibility**: Multiple accommodation options
7. **Effective Onboarding**: Progressive tutorial system
8. **Balanced Difficulty**: AI-driven adaptive challenge

All design elements work together to create an engaging, accessible, and replayable spatial puzzle experience that leverages Vision Pro's unique capabilities.
