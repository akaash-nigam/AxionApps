# Parkour Pathways - Design Document
*Game Design & User Experience Specification*

## Document Overview

This document defines the complete game design and user experience for Parkour Pathways, covering gameplay mechanics, progression systems, spatial UI/UX, visual design, audio design, and accessibility features.

---

## 1. Game Design Document (GDD) Overview

### 1.1 Core Game Concept

**High Concept:** Transform any space into a dynamic parkour training ground that adapts to your environment and skill level.

**Genre:** Spatial Fitness / Movement Training / Competitive Athletic Gaming

**Target Audience:**
- Primary: Fitness enthusiasts and movement athletes (ages 12-35)
- Secondary: Educational market for PE programs (ages 8-18)
- Tertiary: Professional training (ages 18-40)

**Unique Selling Points:**
1. Real environment becomes your training facility
2. AI-generated courses adapted to your space
3. Professional parkour instruction with real-time feedback
4. Competitive multiplayer with global leaderboards
5. Safe indoor parkour training with injury prevention

### 1.2 Core Pillars

```yaml
design_pillars:
  1_authentic_movement:
    description: "Real parkour techniques taught by professionals"
    implementation: "Motion-captured instruction and technique analysis"
    success_metric: "90% technique accuracy correlation with expert evaluation"

  2_adaptive_challenge:
    description: "Courses that grow with player skill"
    implementation: "AI difficulty scaling and dynamic course generation"
    success_metric: "80% of players report 'challenging but achievable' difficulty"

  3_spatial_immersion:
    description: "Your room becomes the obstacle course"
    implementation: "Seamless AR integration with real furniture"
    success_metric: "95% of rooms successfully support course generation"

  4_safety_first:
    description: "Injury prevention through intelligent design"
    implementation: "Multi-layer safety system with real-time monitoring"
    success_metric: "Zero injuries attributed to unsafe course design"

  5_social_competition:
    description: "Compete and improve with others"
    implementation: "Leaderboards, ghost racing, SharePlay multiplayer"
    success_metric: "35% of users engage with competitive features weekly"
```

---

## 2. Core Gameplay Loop

### 2.1 Primary Gameplay Loop (Session)

```
┌─────────────────────────────────────────────────────────┐
│                    SELECT COURSE                        │
│   • Browse available courses                            │
│   • View difficulty and requirements                    │
│   • Check personal best times                           │
└────────────────┬────────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────────────────────┐
│                   PREPARE SPACE                         │
│   • AI scans room and validates safety                  │
│   • Player clears any hazards                           │
│   • Course preview shown in space                       │
└────────────────┬────────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────────────────────┐
│                  COMPLETE COURSE                        │
│   • Navigate obstacles in sequence                      │
│   • Receive real-time technique feedback                │
│   • Hit checkpoints for progress tracking               │
└────────────────┬────────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────────────────────┐
│                 REVIEW PERFORMANCE                      │
│   • See completion time and score                       │
│   • Analyze technique on each obstacle                  │
│   • Compare with personal bests and leaderboard         │
│   • Identify improvement areas                          │
└────────────────┬────────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────────────────────┐
│               IMPROVE & REPEAT                          │
│   • Practice specific techniques                        │
│   • Attempt same course for better time                │
│   • Try harder course variation                         │
│   • Learn new movement skills                           │
└─────────────────────────────────────────────────────────┘
```

### 2.2 Meta Progression Loop (Long-term)

```
┌─────────────────────────────────────────────────────────┐
│                  BEGINNER TRAINING                      │
│   • Learn fundamental movements                         │
│   • Build basic fitness foundation                      │
│   • Complete beginner courses                           │
└────────────────┬────────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────────────────────┐
│              SKILL DEVELOPMENT                          │
│   • Master individual techniques                        │
│   • Unlock intermediate obstacles                       │
│   • Increase physical capabilities                      │
└────────────────┬────────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────────────────────┐
│              ADVANCED TRAINING                          │
│   • Complex obstacle combinations                       │
│   • Speed and efficiency optimization                   │
│   • Competitive course attempts                         │
└────────────────┬────────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────────────────────┐
│               EXPERT MASTERY                            │
│   • Professional-level courses                          │
│   • Tournament participation                            │
│   • Community course creation                           │
│   • Mentoring other players                             │
└─────────────────────────────────────────────────────────┘
```

---

## 3. Player Progression Systems

### 3.1 Skill Progression

```swift
enum SkillLevel: Int, Codable {
    case novice = 0        // 0-100 XP
    case beginner = 1      // 100-500 XP
    case intermediate = 2  // 500-1500 XP
    case advanced = 3      // 1500-5000 XP
    case expert = 4        // 5000-15000 XP
    case master = 5        // 15000+ XP

    var displayName: String {
        switch self {
        case .novice: return "Novice Traceur"
        case .beginner: return "Beginner Traceur"
        case .intermediate: return "Intermediate Traceur"
        case .advanced: return "Advanced Traceur"
        case .expert: return "Expert Traceur"
        case .master: return "Master Traceur"
        }
    }
}

struct SkillCategory {
    let name: String
    var level: Int = 0  // 0-10 for each skill
    var xp: Int = 0

    static let categories: [SkillCategory] = [
        SkillCategory(name: "Precision Jumping"),
        SkillCategory(name: "Vaulting"),
        SkillCategory(name: "Wall Running"),
        SkillCategory(name: "Balance"),
        SkillCategory(name: "Climbing"),
        SkillCategory(name: "Flow & Rhythm"),
        SkillCategory(name: "Strength & Conditioning"),
        SkillCategory(name: "Speed & Efficiency")
    ]
}
```

### 3.2 Achievement System

```yaml
achievements:
  movement_mastery:
    - name: "First Steps"
      description: "Complete your first course"
      icon: "👣"
      xp: 50

    - name: "Precision Expert"
      description: "Land 100 perfect precision jumps"
      icon: "🎯"
      xp: 500

    - name: "Vault Master"
      description: "Execute 50 flawless vaults"
      icon: "🏃"
      xp: 500

    - name: "Flow State"
      description: "Complete a course without stopping"
      icon: "🌊"
      xp: 1000

  competitive:
    - name: "Podium Finish"
      description: "Rank top 3 on any leaderboard"
      icon: "🥉"
      xp: 750

    - name: "Speed Demon"
      description: "Beat course creator's time"
      icon: "⚡"
      xp: 1000

    - name: "Consistency King"
      description: "Complete same course 10 times"
      icon: "👑"
      xp: 500

  training:
    - name: "Week Warrior"
      description: "Train 7 days in a row"
      icon: "📅"
      xp: 300

    - name: "Marathon Session"
      description: "Train for 60 minutes continuously"
      icon: "⏱️"
      xp: 500

    - name: "Technique Perfectionist"
      description: "Achieve 95%+ technique score"
      icon: "💯"
      xp: 750

  social:
    - name: "Team Player"
      description: "Complete first multiplayer course"
      icon: "🤝"
      xp: 250

    - name: "Course Creator"
      description: "Create first custom course"
      icon: "🛠️"
      xp: 500

    - name: "Mentor"
      description: "Help 10 beginners improve"
      icon: "🎓"
      xp: 1000
```

### 3.3 Unlockables

```yaml
unlockable_content:
  obstacles:
    novice_unlocked:
      - precision_target_basic
      - step_vault
      - low_balance_beam

    beginner_unlocked:
      - precision_target_elevated
      - speed_vault
      - wall_run_short

    intermediate_unlocked:
      - kong_vault
      - wall_run_extended
      - cat_leap
      - tic_tac

    advanced_unlocked:
      - double_kong
      - wall_flip
      - precision_cat_leap
      - lache

  visual_customization:
    - obstacle_color_themes
    - visual_effects_styles
    - course_environments
    - avatar_customization

  training_programs:
    - beginner_8_week_program
    - strength_building_program
    - speed_development_program
    - advanced_techniques_program

  course_types:
    - speed_run_courses
    - technique_focus_courses
    - endurance_challenges
    - creative_freestyle_courses
```

---

## 4. Level Design Principles

### 4.1 Course Design Framework

```yaml
course_design_principles:
  1_clear_path:
    description: "Players should always know where to go next"
    implementation:
      - Visual path indicators
      - Numbered checkpoints
      - Color-coded obstacles
      - Directional arrows

  2_progressive_difficulty:
    description: "Gradually increase challenge throughout course"
    implementation:
      - Start with easier obstacles
      - Increase complexity mid-course
      - Challenging finale obstacle
      - Optional shortcuts for advanced players

  3_rhythm_and_flow:
    description: "Course should encourage continuous movement"
    implementation:
      - Appropriate spacing between obstacles
      - Natural transition points
      - Momentum-building sequences
      - Recovery points between intense sections

  4_risk_reward_balance:
    description: "Higher difficulty = higher score potential"
    implementation:
      - Multiple path options
      - Risky shortcuts with bigger rewards
      - Safe routes with lower scores
      - Secret techniques for bonus points

  5_spatial_awareness:
    description: "Use full 3D space effectively"
    implementation:
      - Vertical variation (different heights)
      - 360-degree obstacle placement
      - Room-scale movement patterns
      - Furniture integration
```

### 4.2 Obstacle Placement Rules

```swift
struct ObstaclePlacementRules {
    // Minimum spacing between obstacles
    static let minSpacing: Float = 1.0 // meters

    // Safety clearance around obstacles
    static let safetyClearance: Float = 0.5 // meters

    // Maximum reach distance
    static let maxReachDistance: Float = 2.5 // meters

    // Vertical spacing rules
    static let minFloorClearance: Float = 0.3 // meters
    static let maxHeightVariation: Float = 1.0 // meters per obstacle

    // Density rules
    static func maxObstacleCount(for area: Float) -> Int {
        // 1 obstacle per 2 square meters minimum
        return Int(area / 2.0)
    }

    // Furniture integration
    static let furnitureBufferZone: Float = 0.3 // meters
    static let maxFurnitureHeight: Float = 1.2 // meters
}
```

### 4.3 Course Templates

```yaml
course_templates:
  beginner_loop:
    duration: "2-3 minutes"
    obstacles: 6-8
    difficulty: "easy"
    focus: "Learning basic movements"
    pattern: |
      Start → Precision Jump → Step Vault →
      Balance Beam → Precision Jump →
      Low Wall Run → Precision Target → Finish

  intermediate_circuit:
    duration: "4-5 minutes"
    obstacles: 12-15
    difficulty: "medium"
    focus: "Technique combination and flow"
    pattern: |
      Start → Speed Vault → Wall Run →
      Precision Cat Leap → Kong Vault →
      Balance Sequence → Climbing Section →
      Flow Combo → Precision Finish → End

  advanced_gauntlet:
    duration: "6-8 minutes"
    obstacles: 20-25
    difficulty: "hard"
    focus: "Endurance and complex techniques"
    pattern: |
      Start → Complex Vault Sequence →
      Extended Wall Run → Multi-level Climbing →
      Precision Challenge → Speed Section →
      Technical Combo → Expert Finale → End

  speed_run:
    duration: "1-2 minutes"
    obstacles: 8-10
    difficulty: "variable"
    focus: "Maximum speed and efficiency"
    pattern: |
      Start → Fast Vaults → Speed Optimized Path →
      Minimal Obstacles → High Speed Finish → End
```

---

## 5. Spatial Gameplay Design

### 5.1 Spatial UI Layers

```
┌─────────────────────────────────────────────────────────┐
│              LAYER 1: HUD (Always Visible)              │
│  • Timer (top center)                                   │
│  • Current score (top right)                            │
│  • Next checkpoint indicator (contextual)               │
│  • Technique feedback (near body)                       │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│         LAYER 2: Course Elements (World-Locked)         │
│  • Virtual obstacles (anchored to room)                 │
│  • Path indicators (floor-projected)                    │
│  • Safety boundaries (room edges)                       │
│  • Checkpoint markers (3D waypoints)                    │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│         LAYER 3: Feedback (Body-Relative)               │
│  • Technique scoring (near relevant body part)          │
│  • Movement trails (following motion)                   │
│  • Impact indicators (at contact points)                │
│  • Balance assistance (feet level)                      │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│          LAYER 4: Menus (View-Locked)                   │
│  • Pause menu (center view)                             │
│  • Settings panel (comfortable distance)                │
│  • Results screen (eye level)                           │
│  • Tutorial overlays (contextual)                       │
└─────────────────────────────────────────────────────────┘
```

### 5.2 Spatial Interaction Zones

```swift
struct SpatialZones {
    // Intimate Zone: 0.3m - 0.6m
    // Used for: Detail views, precise interactions
    static let intimateZone = 0.3...0.6

    // Personal Zone: 0.6m - 1.2m
    // Used for: Primary UI, hand interactions
    static let personalZone = 0.6...1.2

    // Social Zone: 1.2m - 3.0m
    // Used for: Course obstacles, gameplay space
    static let socialZone = 1.2...3.0

    // Public Zone: 3.0m+
    // Used for: Environmental elements, distant markers
    static let publicZone = 3.0...100.0
}
```

### 5.3 Visual Feedback Systems

```yaml
visual_feedback:
  obstacle_states:
    inactive:
      appearance: "Semi-transparent, muted colors"
      purpose: "Show upcoming obstacles without distraction"

    active:
      appearance: "Full opacity, vibrant colors"
      purpose: "Current obstacle player should engage with"

    completed:
      appearance: "Green checkmark, particle effects"
      purpose: "Positive reinforcement for completion"

    nearby:
      appearance: "Pulsing highlight, subtle glow"
      purpose: "Draw attention to next obstacle"

  movement_trails:
    hand_trails:
      color: "Blue gradient"
      duration: "0.5 seconds"
      purpose: "Show hand movement path for vaults/grabs"

    body_trail:
      color: "White gradient"
      duration: "1.0 seconds"
      purpose: "Visualize movement flow and technique"

  technique_indicators:
    perfect:
      visual: "Gold ring, sparkle particles"
      sound: "Achievement chime"

    good:
      visual: "Green checkmark"
      sound: "Positive beep"

    acceptable:
      visual: "Yellow indicator"
      sound: "Neutral tone"

    needs_improvement:
      visual: "Red arrow showing correction"
      sound: "Guidance tone"
```

---

## 6. UI/UX Design

### 6.1 Main Menu Design

```
┌─────────────────────────────────────────────────────────┐
│                   PARKOUR PATHWAYS                      │
│                                                         │
│   ┌───────────────────────────────────────────┐       │
│   │                                             │       │
│   │          [PLAY]  (Large Primary Button)    │       │
│   │                                             │       │
│   └───────────────────────────────────────────┘       │
│                                                         │
│   [Training Programs]    [Course Browser]              │
│                                                         │
│   [Leaderboards]        [Multiplayer]                  │
│                                                         │
│   [Profile & Stats]     [Settings]                     │
│                                                         │
│                                                         │
│   Player Status:                                        │
│   ● Level 12 - Intermediate Traceur                    │
│   ● 2,450 XP / 5,000 XP to Advanced                    │
│   ● Daily Streak: 7 days 🔥                            │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### 6.2 Course Selection UI

```yaml
course_browser:
  filters:
    - difficulty: [Easy, Medium, Hard, Expert]
    - duration: [Quick (< 3min), Standard (3-6min), Long (6min+)]
    - focus: [Technique, Speed, Endurance, Creative]
    - space_required: [Small (2x2m), Medium (3x3m), Large (4x4m+)]

  course_card:
    preview: "3D miniature of course layout"
    info:
      - name: "Course name"
      - difficulty: "Visual indicator (color + stars)"
      - duration: "Estimated completion time"
      - obstacles: "Count and types"
      - personal_best: "Your best time/score"
      - leaderboard: "Your rank / Total players"
    actions:
      - "Play Course"
      - "View Details"
      - "Practice Mode"

  sorting:
    - "Recommended for You" (AI-suggested)
    - "Popular This Week"
    - "New Courses"
    - "Personal Bests"
    - "Not Yet Completed"
```

### 6.3 In-Game HUD

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│                    ⏱️ 02:34.58                         │
│                                                         │
│  Checkpoint 3/5                    Score: 8,450  ⭐⭐⭐  │
│                                                         │
│                                                         │
│                                                         │
│                   [Player View]                         │
│                                                         │
│              [OBSTACLE AHEAD]                           │
│                                                         │
│                                                         │
│           ⬆️                                            │
│       Next: Speed Vault                                 │
│       Distance: 2.5m                                    │
│                                                         │
│                                                         │
│  💓 145 BPM    🔥 234 Cal    Technique: 92%            │
└─────────────────────────────────────────────────────────┘
```

### 6.4 Results Screen

```yaml
results_screen_layout:
  header:
    - course_name
    - completion_status: "✓ COURSE COMPLETE"

  primary_stats:
    - completion_time:
        display: "Large, prominent"
        comparison: "vs Personal Best"
    - total_score:
        display: "Prominent"
        breakdown: "Base + Technique + Speed bonuses"
    - star_rating: "1-3 stars based on performance"

  detailed_analysis:
    technique_breakdown:
      - precision_jumping: "95%"
      - vaulting: "87%"
      - balance: "92%"
      - overall_technique: "91%"

    obstacle_by_obstacle:
      - obstacle_name
      - time_taken
      - technique_score
      - points_earned

    fitness_metrics:
      - calories_burned
      - average_heart_rate
      - peak_heart_rate
      - active_minutes

  leaderboard_position:
    - global_rank
    - friends_rank
    - percentile

  actions:
    - "Retry Course" (improve score)
    - "Next Course" (progression)
    - "Share Results" (social)
    - "Detailed Analysis" (deep dive)
    - "Back to Menu"
```

### 6.5 Tutorial System

```yaml
tutorial_flow:
  stage_1_introduction:
    - welcome_message
    - game_concept_explanation
    - room_scanning_tutorial
    - safety_guidelines

  stage_2_basic_movement:
    - precision_jump_tutorial:
        - demonstration (AI avatar)
        - player_attempt
        - feedback_and_correction
        - practice_repetitions: 3

    - basic_vault_tutorial:
        - demonstration
        - hand_placement_guidance
        - player_attempt
        - feedback

  stage_3_game_elements:
    - checkpoint_system
    - scoring_mechanics
    - technique_feedback
    - time_trial_concept

  stage_4_first_course:
    - easy_guided_course
    - real_time_coaching
    - completion_celebration
    - progression_explanation

  ongoing_tutorials:
    - contextual_tips
    - new_obstacle_introductions
    - advanced_technique_unlocks
    - feature_discovery
```

---

## 7. Visual Style Guide

### 7.1 Color Palette

```yaml
primary_colors:
  brand_primary: "#00D9FF"      # Cyan - Energy & Movement
  brand_secondary: "#FF3D71"    # Red - Intensity & Challenge
  brand_accent: "#FFD700"       # Gold - Achievement & Success

difficulty_colors:
  beginner: "#4CAF50"           # Green
  intermediate: "#FF9800"       # Orange
  advanced: "#F44336"           # Red
  expert: "#9C27B0"             # Purple

ui_colors:
  background: "#1A1A2E"         # Dark blue-gray
  surface: "#16213E"            # Slightly lighter
  text_primary: "#FFFFFF"       # White
  text_secondary: "#B0B0B0"     # Gray
  success: "#4CAF50"            # Green
  warning: "#FFC107"            # Amber
  error: "#F44336"              # Red

obstacle_colors:
  inactive: "#404040"           # Dark gray (50% opacity)
  active: "#00D9FF"             # Cyan (full opacity)
  completed: "#4CAF50"          # Green
  highlighted: "#FFD700"        # Gold
```

### 7.2 Typography

```yaml
typography:
  display:
    font: "SF Pro Display"
    weight: "Bold"
    size: "48pt"
    usage: "Main titles, course names"

  heading:
    font: "SF Pro Display"
    weight: "Semibold"
    size: "32pt"
    usage: "Section headers"

  body:
    font: "SF Pro Text"
    weight: "Regular"
    size: "18pt"
    usage: "Descriptions, instructions"

  caption:
    font: "SF Pro Text"
    weight: "Medium"
    size: "14pt"
    usage: "Labels, secondary info"

  monospace:
    font: "SF Mono"
    weight: "Regular"
    size: "16pt"
    usage: "Times, scores, technical data"
```

### 7.3 Visual Effects

```yaml
particle_effects:
  completion:
    type: "Burst"
    particles: "Sparkles"
    color: "Gold"
    duration: "1.5s"

  perfect_landing:
    type: "Ring expansion"
    particles: "Energy waves"
    color: "Cyan"
    duration: "0.8s"

  trail:
    type: "Following particles"
    particles: "Motion blur"
    color: "White"
    duration: "0.5s fade"

  checkpoint:
    type: "Column of light"
    particles: "Rising sparkles"
    color: "Green"
    duration: "2.0s"

materials:
  obstacles:
    base: "Matte plastic"
    highlight: "Glowing edges"
    active_state: "Pulsing glow"

  environment:
    floor_markers: "Projected light"
    boundaries: "Energy fence shader"
    targets: "Holographic material"
```

---

## 8. Audio Design

### 8.1 Music System

```yaml
music_layers:
  ambient_base:
    description: "Calm background atmosphere"
    intensity: 0.2
    when: "Menu, setup, low-activity gameplay"

  rhythmic_layer:
    description: "Steady beat for movement rhythm"
    intensity: 0.5
    when: "Active gameplay, medium intensity"

  energetic_layer:
    description: "High-energy electronic music"
    intensity: 0.8
    when: "Fast-paced gameplay, competition"

  epic_layer:
    description: "Triumphant orchestral elements"
    intensity: 1.0
    when: "Final obstacles, victory moments"

dynamic_mixing:
  - Layers fade in/out based on gameplay intensity
  - BPM matches player movement rhythm
  - Volume adjusts for important audio cues
  - Smooth transitions between sections
```

### 8.2 Sound Effects

```yaml
movement_sfx:
  footsteps:
    variations: 8
    materials: ["concrete", "wood", "metal", "soft"]
    volume: "Dynamic based on impact force"
    spatial: true

  landings:
    perfect: "Clean impact + success chime"
    good: "Solid impact"
    heavy: "Heavy thud + grunt"
    spatial: true

  hand_contact:
    vault_touch: "Palm contact on surface"
    grip: "Grabbing hold sound"
    release: "Hand sliding off"
    spatial: true

  movement:
    whoosh: "Air movement during jumps/vaults"
    clothing: "Subtle cloth movement"
    breathing: "Dynamic exertion sounds"
    spatial: false (follows player)

obstacle_sfx:
  activation:
    sound: "Energize/power-up"
    volume: "Medium"
    spatial: true

  completion:
    sound: "Success chime + particle burst"
    volume: "Medium-high"
    spatial: true

  checkpoint:
    sound: "Milestone achievement"
    volume: "High"
    spatial: true

ui_sfx:
  button_press: "Click"
  menu_navigate: "Subtle whoosh"
  achievement_unlock: "Triumphant fanfare"
  error: "Negative beep"
  confirmation: "Positive chime"

coaching_voice:
  encouragement:
    - "Nice technique!"
    - "Keep that momentum!"
    - "Perfect landing!"

  guidance:
    - "Hands on the vault"
    - "Look for the target"
    - "Build up speed"

  corrections:
    - "Bend your knees more"
    - "Land lighter"
    - "Keep your balance"
```

### 8.3 Spatial Audio Configuration

```swift
struct SpatialAudioConfig {
    // Distance attenuation
    static let maxDistance: Float = 20.0 // meters
    static let referenceDistance: Float = 1.0 // meters
    static let rolloffFactor: Float = 2.0

    // Reverb for environment
    static let roomReverb: AVAudioUnitReverb = {
        let reverb = AVAudioUnitReverb()
        reverb.loadFactoryPreset(.mediumRoom)
        reverb.wetDryMix = 30 // 30% wet
        return reverb
    }()

    // Occlusion (when obstacles between source and listener)
    static let occlusionEffect: Float = 0.6 // 40% reduction

    // Doppler effect for fast-moving sounds
    static let dopplerFactor: Float = 1.0
}
```

---

## 9. Accessibility Features

### 9.1 Visual Accessibility

```yaml
visual_accessibility:
  colorblind_modes:
    - protanopia: "Red-green colorblind"
    - deuteranopia: "Green-red colorblind"
    - tritanopia: "Blue-yellow colorblind"
    implementation: "Alternative color schemes for obstacles"

  high_contrast_mode:
    description: "Increase contrast for all UI elements"
    obstacle_visibility: "Stronger outlines, brighter colors"
    text: "Pure white on pure black"

  reduce_motion:
    description: "Minimize excessive visual motion"
    effects: "Reduce particle effects"
    animations: "Simpler, slower transitions"

  text_size:
    options: ["Small", "Medium", "Large", "Extra Large"]
    scaling: "100% - 200%"

  voiceover_support:
    - Full navigation with VoiceOver
    - Audio descriptions of obstacles
    - Spatial audio cues for navigation
    - Haptic feedback for confirmations
```

### 9.2 Motor Accessibility

```yaml
motor_accessibility:
  difficulty_adjustments:
    - slower_pace: "More time to react"
    - larger_targets: "Bigger precision zones"
    - simplified_controls: "Fewer required gestures"
    - auto_grab: "Automatic hand placement assistance"

  alternative_controls:
    - voice_only: "Complete courses with voice commands"
    - gaze_only: "Eye tracking for all interactions"
    - controller: "Traditional gamepad support"
    - assisted_mode: "AI helps with difficult movements"

  rest_periods:
    - mandatory_breaks: "Prevent overexertion"
    - adjustable_intensity: "Scale physical demands"
    - seated_mode: "Modified courses for seated play"
```

### 9.3 Cognitive Accessibility

```yaml
cognitive_accessibility:
  simplified_ui:
    description: "Cleaner, less cluttered interface"
    options: "Hide non-essential information"

  clear_instructions:
    - step_by_step: "Break down complex movements"
    - visual_guides: "Show exactly what to do"
    - repeat_demos: "Unlimited demonstration replays"

  customizable_pace:
    - no_timers: "Remove time pressure"
    - guided_mode: "AI coach throughout course"
    - pause_anytime: "Complete control over pacing"

  difficulty_assist:
    - adaptive_difficulty: "Auto-adjust to player ability"
    - skip_obstacles: "Option to bypass difficult sections"
    - practice_mode: "Isolated skill practice"
```

### 9.4 Hearing Accessibility

```yaml
hearing_accessibility:
  visual_audio_cues:
    - sound_visualization: "Visual representation of sounds"
    - directional_indicators: "Arrows for spatial sounds"
    - text_callouts: "On-screen text for voice cues"

  haptic_substitution:
    - rhythm_haptics: "Feel the music beat"
    - impact_haptics: "Contact feedback"
    - guidance_haptics: "Direction and distance info"

  closed_captions:
    - coaching_dialogue: "All spoken words as text"
    - sound_effects: "[Footstep sounds]"
    - music_cues: "[Energetic music intensifies]"
```

---

## 10. Tutorial & Onboarding

### 10.1 First-Time User Experience (FTUE)

```yaml
ftue_flow:
  step_1_welcome:
    duration: "30 seconds"
    content:
      - welcome_message
      - game_concept_video
      - safety_disclaimer
    interaction: "Tap to continue"

  step_2_space_setup:
    duration: "1-2 minutes"
    content:
      - room_scanning_explanation
      - clear_space_instructions
      - safety_boundary_setup
    interaction: "Scan room with device"

  step_3_controls:
    duration: "1 minute"
    content:
      - hand_tracking_calibration
      - gesture_demonstrations
      - ui_navigation_practice
    interaction: "Follow on-screen instructions"

  step_4_first_movement:
    duration: "2 minutes"
    content:
      - precision_jump_tutorial
      - ai_coach_demonstration
      - player_practice (3 attempts)
      - technique_feedback
    interaction: "Perform movement"

  step_5_first_course:
    duration: "3-4 minutes"
    content:
      - simple_3_obstacle_course
      - real_time_coaching
      - completion_celebration
      - progression_explanation
    interaction: "Complete course"

  step_6_feature_overview:
    duration: "1 minute"
    content:
      - main_menu_tour
      - progression_system_explanation
      - next_steps_guidance
    interaction: "Explore menu"
```

### 10.2 Progressive Tutorials

```yaml
progressive_learning:
  movement_tutorials:
    unlock_conditions: "When new obstacle type available"
    format:
      - professional_demonstration
      - technique_breakdown
      - guided_practice
      - mastery_challenge

  feature_tutorials:
    multiplayer:
      trigger: "When player completes 5 courses"
      content: "SharePlay explanation and invitation"

    course_creation:
      trigger: "When player reaches Intermediate level"
      content: "Custom course builder tutorial"

    competitive:
      trigger: "When player completes first course"
      content: "Leaderboards and ghost racing intro"

  contextual_tips:
    frequency: "First 3 times encountering new situation"
    examples:
      - "First time near boundary: Safety warning"
      - "First poor technique: Correction tip"
      - "First pause: Menu overview"
```

---

## 11. Difficulty Balancing

### 11.1 Difficulty Scaling Framework

```swift
struct DifficultyScaling {
    // Factors that contribute to difficulty
    struct Factors {
        var obstacleComplexity: Float      // 0.0 - 1.0
        var spacing: Float                 // tighter = harder
        var precisionRequired: Float       // 0.0 - 1.0
        var speedRequirement: Float        // 0.0 - 1.0
        var endurance: Float               // course duration
        var technicalVariety: Float        // number of different moves
    }

    func calculateDifficulty(_ factors: Factors) -> DifficultyLevel {
        let score = (
            factors.obstacleComplexity * 0.25 +
            factors.spacing * 0.15 +
            factors.precisionRequired * 0.20 +
            factors.speedRequirement * 0.15 +
            factors.endurance * 0.15 +
            factors.technicalVariety * 0.10
        )

        switch score {
        case 0.0..<0.3:
            return .easy
        case 0.3..<0.5:
            return .medium
        case 0.5..<0.7:
            return .hard
        case 0.7...1.0:
            return .expert
        default:
            return .medium
        }
    }
}
```

### 11.2 Adaptive Difficulty System

```yaml
adaptive_difficulty:
  performance_tracking:
    metrics:
      - completion_rate: "Success/fail ratio"
      - technique_scores: "Average across obstacles"
      - completion_times: "Relative to expected time"
      - retry_frequency: "How often replaying courses"

  adjustment_triggers:
    make_easier:
      - failed_course_3_times
      - technique_scores_below_50_percent
      - player_frustration_detected

    make_harder:
      - completing_courses_first_try
      - technique_scores_above_90_percent
      - completion_times_much_faster_than_expected

  adjustment_methods:
    - increase_precision_tolerance
    - add_more_checkpoints
    - reduce_time_pressure
    - show_additional_guidance
    - simplify_obstacle_techniques

difficulty_settings:
  preset_modes:
    casual:
      - no_time_limits
      - forgiving_precision
      - extra_guidance
      - focus_on_learning

    standard:
      - balanced_challenge
      - normal_precision
      - standard_guidance
      - focus_on_improvement

    hardcore:
      - tight_time_limits
      - strict_precision
      - minimal_guidance
      - focus_on_mastery

  custom_adjustments:
    - precision_tolerance: "0.5x - 2.0x"
    - time_limits: "Off / Relaxed / Standard / Strict"
    - guidance_level: "Minimal / Standard / Extensive"
    - technique_strictness: "Lenient / Standard / Strict"
```

---

## 12. Social & Community Features

### 12.1 Social Integration

```yaml
social_features:
  friends:
    - friend_list
    - friend_leaderboards
    - friend_challenges
    - shared_achievements

  challenges:
    - send_course_challenge
    - weekly_group_challenges
    - tournament_brackets
    - community_events

  sharing:
    - share_results (social media)
    - share_replays
    - share_custom_courses
    - share_achievements

  spectating:
    - watch_friend_attempts
    - view_replay_ghosts
    - leaderboard_replay_viewing
```

### 12.2 Community Content

```yaml
user_generated_content:
  course_creation:
    tools:
      - obstacle_placement
      - difficulty_tuning
      - testing_tools
      - metadata_editing

    sharing:
      - publish_to_community
      - share_with_friends
      - featured_courses
      - trending_courses

    curation:
      - rating_system (1-5 stars)
      - difficulty_verification
      - safety_validation
      - featured_selection

  training_programs:
    - create_workout_sequences
    - share_training_plans
    - follow_community_programs
    - instructor_verified_programs
```

---

## Conclusion

This design document provides comprehensive game design and UX specifications for Parkour Pathways. The design prioritizes:

1. **Authentic Movement**: Real parkour techniques with professional instruction
2. **Adaptive Challenge**: AI-driven difficulty scaling for optimal engagement
3. **Spatial Immersion**: Full utilization of visionOS spatial capabilities
4. **Safety First**: Multi-layer safety systems preventing injuries
5. **Progressive Learning**: Structured progression from novice to expert
6. **Accessibility**: Inclusive design for diverse abilities
7. **Social Competition**: Engaging multiplayer and community features

The design creates a unique spatial gaming experience that transforms any space into a professional parkour training facility, making authentic movement training accessible while maintaining the challenge and authenticity that serious practitioners demand.

**Key Design Achievements:**
- Comprehensive progression system with 6 skill levels
- Detailed spatial UI framework optimized for visionOS
- Extensive accessibility features for inclusive gameplay
- Dynamic difficulty scaling adapting to player skill
- Rich audio design with spatial audio integration
- Strong social and community features

This design document serves as the definitive reference for implementing the complete player experience in Parkour Pathways.
