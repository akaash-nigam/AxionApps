# Arena Esports - Design Document
*Game Design & UI/UX Specifications for visionOS Competitive Gaming*

---

## Document Overview

**Version:** 1.0
**Last Updated:** 2025-11-19
**Status:** Design Phase
**Related Documents:** ARCHITECTURE.md, TECHNICAL_SPEC.md, IMPLEMENTATION_PLAN.md

---

## Table of Contents

1. [Game Design Document (GDD)](#game-design-document-gdd)
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

## 1. Game Design Document (GDD)

### Game Vision

**Arena Esports** is a competitive 5v5 spatial combat game that leverages Apple Vision Pro's unique capabilities to create the first true 360-degree professional esports experience. Players compete in spherical arenas where spatial awareness, vertical positioning, and three-dimensional tactics determine victory.

### Core Pillars

1. **Spatial Mastery** - Players must master 360-degree awareness and vertical positioning
2. **Competitive Integrity** - Fair, skill-based competition with ultra-low latency
3. **Team Coordination** - Success requires seamless 3D formation and communication
4. **Professional Focus** - Designed for esports with spectator experience as priority
5. **Innovation** - Gameplay impossible on traditional platforms

### Game Modes

#### Competitive Modes

**Elimination (5v5)**
- Two teams compete in best-of-7 rounds
- No respawns during rounds
- First team to win 4 rounds wins match
- Round time: 100 seconds
- Objective: Eliminate all opponents

**Domination (5v5)**
- Capture and hold 3 control points in spherical formation
- Points generate score over time
- First team to 100 points wins
- Respawn enabled with 5-second delay
- Match time: 10 minutes

**King of the Sphere (5v5)**
- Central sphere that rotates in 3D space
- Team inside scores points
- Dynamic positioning challenges
- First to 75 points wins
- Match time: 8 minutes

#### Training Modes

**Aim Lab**
- Practice spatial targeting
- Moving targets in 360 degrees
- Accuracy and reaction time tracking
- Difficulty scaling

**Movement Training**
- Master 360-degree navigation
- Obstacle courses
- Speed run challenges
- Vertical movement practice

**1v1 Duel**
- Practice combat mechanics
- Ranked ladder
- Quick matches (best of 3 rounds)

**Custom Games**
- Configure match settings
- Private lobbies
- Experiment with strategies

### Win Conditions

**Elimination:** Eliminate all enemy players
**Domination:** Reach score threshold first
**King of the Sphere:** Control center longest
**Tournament:** Win best-of-5 match series

---

## 2. Core Gameplay Loop

### Micro Loop (Per Round - 2-5 minutes)

```
1. SPAWN PHASE (5 seconds)
   ↓
   • Team spawns in formation
   • Quick strategy discussion
   • Equipment check

2. POSITIONING PHASE (10-20 seconds)
   ↓
   • Navigate to strategic positions
   • Vertical advantage seeking
   • Cover identification
   • Enemy detection

3. ENGAGEMENT PHASE (30-60 seconds)
   ↓
   • Spatial combat
   • Ability usage
   • Team coordination
   • Dynamic repositioning

4. RESOLUTION PHASE (Variable)
   ↓
   • Victory/defeat
   • Round end
   • Score update
   • Quick replay

5. PREPARATION (10 seconds)
   ↓
   • Strategy adjustment
   • Equipment changes
   • Communication
   ↓
   REPEAT or MATCH END
```

### Macro Loop (Per Match - 15-30 minutes)

```
1. MATCHMAKING (30-60 seconds)
   • Find 10 players
   • Balanced teams
   • Skill matching

2. LOADING (10 seconds)
   • Arena loading
   • Team formation
   • Brief strategy

3. MATCH PLAY (10-20 minutes)
   • Multiple rounds
   • Score tracking
   • Dynamic adaptation

4. RESULTS (30 seconds)
   • Match statistics
   • Performance analysis
   • Rank changes
   • Rewards

5. REPEAT or EXIT
```

### Meta Loop (Career Progression)

```
AMATEUR
   ↓ (Play matches, improve skills)
RANKED PLAY
   ↓ (Climb ladder, join teams)
SEMI-PRO
   ↓ (Team tournaments, sponsorships)
PROFESSIONAL
   ↓ (League play, prize pools)
CHAMPION
```

---

## 3. Player Progression Systems

### Skill Rating System

**ELO-based Ranking**
```
Rank Tiers:
├── Initiate (0-999)
├── Apprentice (1000-1299)
├── Skilled (1300-1599)
├── Expert (1600-1899)
├── Master (1900-2199)
├── Grandmaster (2200-2499)
└── Champion (2500+)

Rating Changes:
• Win: +15 to +35 (based on opponent rank)
• Loss: -10 to -25
• Performance bonus: ±5
• Placement matches: ±50 (first 10 games)
```

### Experience & Levels

```swift
struct PlayerLevel {
    let level: Int
    let totalXP: Int
    let xpForNextLevel: Int

    static func xpRequired(for level: Int) -> Int {
        // Exponential curve: 100 * (1.15^level)
        return Int(100 * pow(1.15, Double(level)))
    }
}

enum XPSource {
    case matchWin(amount: 100)
    case matchLoss(amount: 50)
    case kill(amount: 10)
    case assist(amount: 5)
    case objective(amount: 20)
    case firstBlood(amount: 15)
    case comeback(amount: 50)
    case mvp(amount: 100)
}
```

### Unlockable Content

**Cosmetics**
- Player skins (no gameplay advantage)
- Weapon skins
- Victory animations
- Voice lines
- Arena customizations

**Equipment** (Unlocked early, balanced)
- All weapons available by level 5
- All abilities by level 10
- Focus on skill, not grinding

### Achievement System

```swift
enum Achievement {
    // Combat
    case firstKill
    case multiKill(count: Int) // 2, 3, 4, 5
    case headshot Specialist(count: 100)
    case pacifist(winsWithoutKills: 10)

    // Spatial
    case verticalMastery(killsFromAbove: 50)
    case threeSixtyAwareness(killsBehindYou: 20)
    case aerialAce(midAirKills: 30)

    // Teamwork
    case supportSpecialist(assists: 500)
    case protector(teammatesSaved: 100)
    case strategist(objectiveCaptures: 100)

    // Career
    case winStreak(wins: 10)
    case combackKing(comebackWins: 25)
    case consistent(positiveKDRatio100Games: true)
    case champion(reachChampionRank: true)

    // Special
    case betaTester
    case foundingPlayer
    case tournamentWinner
}
```

### Battle Pass (Seasonal)

```
Season Duration: 90 days

Free Track:
├── XP Boosts
├── Basic Cosmetics
└── Currency

Premium Track ($9.99):
├── Exclusive Skins
├── Unique Effects
├── More Currency
├── Early Access Items
└── Prestige Cosmetics (Level 100)

Pro Track ($19.99):
├── Premium Track +
├── Professional Analytics
├── Replay System
├── Custom Training Scenarios
└── Priority Matchmaking
```

---

## 4. Level Design Principles

### Arena Design Philosophy

**360-Degree Balance**
- No "back" to arena - threats from all directions
- Symmetrical design for competitive fairness
- Clear sight lines balanced with cover
- Vertical variety for strategic depth

**Scale & Spacing**
```
Arena Dimensions:
├── Radius: 15-25 meters
├── Vertical Range: ±10 meters from center
├── Combat Range: 5-30 meters optimal
└── Spawn Distance: 20 meters from center

Sight Lines:
├── Long Range: 30+ meters (sniper positions)
├── Medium Range: 10-30 meters (rifles)
├── Close Range: 0-10 meters (close combat)
└── Obstructed: Multiple cover points
```

### Arena Types

**Training Arena "Sphere One"**
```
Purpose: Tutorial and basic training
Design:
├── Simple spherical structure
├── Minimal obstacles
├── Clear sight lines
├── Marked zones for learning
└── Difficulty: Beginner
```

**Competitive Arena "Nexus"**
```
Purpose: Ranked matches
Design:
├── Balanced tri-point structure
├── Three major platforms at 120° intervals
├── Vertical layers (low, mid, high)
├── Dynamic cover elements
├── Environmental hazards (minimal)
└── Difficulty: Intermediate
```

**Professional Arena "Apex Sphere"**
```
Purpose: Tournament play
Design:
├── Complex multi-level structure
├── Five key positions forming pentagram
├── Dynamic rotating elements
├── Strategic chokepoints
├── Spectator-optimized layout
└── Difficulty: Expert
```

**Experimental Arena "Gravity Well"**
```
Purpose: Custom games, variety
Design:
├── Non-uniform gravity zones
├── Rotating sections
├── Asymmetric layout
├── Environmental mechanics
└── Difficulty: Variable
```

### Environmental Elements

**Cover Objects**
- **Half Cover:** 50% concealment, breakable
- **Full Cover:** 100% concealment, durable
- **Dynamic Cover:** Moves or rotates
- **Destructible:** Can be destroyed during match

**Hazards**
- **Energy Barriers:** Cause damage over time
- **Void Zones:** Instant death if exit arena
- **Laser Grids:** Moving obstacles
- **Gravity Wells:** Alter movement

**Objectives**
- **Control Points:** Static capture zones
- **Power Nodes:** Grant temporary advantages
- **Spawn Beacons:** Dynamic team spawns
- **Intel Stations:** Reveal enemy positions

---

## 5. Spatial Gameplay Design

### 360-Degree Combat Mechanics

**Threat Awareness System**
```swift
enum ThreatDirection {
    case front      // 0-45°
    case frontLeft  // 45-90°
    case left       // 90-135°
    case backLeft   // 135-180°
    case back       // 180-225°
    case backRight  // 225-270°
    case right      // 270-315°
    case frontRight // 315-360°
    case above      // +45° elevation
    case below      // -45° elevation
}

struct ThreatIndicator {
    let direction: ThreatDirection
    let distance: Float
    let urgency: ThreatLevel // Low, Medium, High, Critical
    let type: ThreatType // Enemy, Projectile, Hazard
}
```

**Visual Indicators**
- **Directional Arrows:** Point to threats outside FOV
- **Distance Rings:** Show threat proximity
- **Color Coding:** Red (critical), Orange (high), Yellow (medium)
- **Audio Cues:** Spatial sound indicates direction

### Vertical Strategy

**Height Advantage System**
```
High Ground Benefits:
├── +10% damage from above
├── Better visibility (+20% view distance)
├── Harder to hit (-15% accuracy penalty for attackers)
└── Strategic positioning bonus

Low Ground Benefits:
├── More cover options
├── Easier escape routes
├── Surprise attack potential
└── Less exposure
```

**Vertical Movement**
- **Jump:** Quick vertical boost (1.2m height)
- **Dash:** Rapid horizontal/vertical movement
- **Grapple:** Swing between positions (advanced)
- **Gravity Shift:** Temporary orientation change

### Spatial Formation Tactics

**Team Formations**
```
Star Formation (5 points):
    • Central commander
    • 4 players at cardinal points
    • 360° coverage
    • Best for: Defense

Diamond Formation:
    • Point player (scout)
    • 2 side players (support)
    • 2 rear players (defense)
    • Best for: Advancing

Sphere Shell:
    • Players form outer shell
    • Protected center zone
    • Rotating coverage
    • Best for: Objective control

Split Formation:
    • 2-3 split into teams
    • Flanking maneuvers
    • Pincer attacks
    • Best for: Aggressive plays
```

---

## 6. UI/UX for Gaming

### HUD Design Philosophy

**Minimalist Combat HUD**
- Information without obstruction
- Critical data always visible
- Context-sensitive elements
- Spatial integration (not flat overlays)

### HUD Layout

```
Field of View (Natural Eye Position):
                    ┌─────────────┐
                    │   MINIMAP   │ (Top, 10° up)
                    └─────────────┘

┌────────────┐                         ┌────────────┐
│   TEAM     │                         │  AMMO      │
│   STATUS   │ (Left, 30°)             │  HEALTH    │ (Right, 30°)
└────────────┘                         └────────────┘

                    ┌─────────────┐
                    │   RETICLE   │ (Center)
                    └─────────────┘

                    ┌─────────────┐
                    │  ABILITIES  │ (Bottom, 15° down)
                    └─────────────┘
```

### HUD Components

**Health & Shield**
```swift
struct HealthDisplay {
    let position: AnchorPosition = .bottomRight
    let distance: Float = 0.7 // meters from eye

    // Visual design
    let style: DisplayStyle = .arc // Circular arc
    let color: HealthColor = .dynamic // Green → Yellow → Red
    let opacity: Float = 0.8

    // Information
    let currentHealth: Float
    let maxHealth: Float
    let shield: Float
    let regenerating: Bool
}
```

**Weapon & Ammo**
```swift
struct WeaponDisplay {
    let position: AnchorPosition = .bottomRight
    let distance: Float = 0.7

    // Current weapon stats
    let weaponName: String
    let ammo: Int
    let reserveAmmo: Int
    let reloadProgress: Float // 0-1

    // Visual feedback
    let lowAmmoWarning: Bool // When < 30%
    let reloadIndicator: Bool
    let weaponIcon: String
}
```

**Minimap (Spatial Radar)**
```swift
struct SpatialMinimap {
    let position: AnchorPosition = .topCenter
    let distance: Float = 1.0
    let radius: Float = 0.15 // Map size

    // 3D spherical minimap showing:
    struct MapElement {
        let type: ElementType // Ally, Enemy, Objective
        let position: SIMD3<Float> // 3D position
        let elevation: Float // Height indicator
        let opacity: Float // Based on distance
    }

    // Features
    let showEnemies: Bool // Only when visible
    let showObjectives: Bool
    let showTeammates: Bool
    let elevationLayers: Bool
}
```

**Ability Indicators**
```swift
struct AbilityUI {
    let position: AnchorPosition = .bottomCenter
    let distance: Float = 0.8

    struct AbilitySlot {
        let ability: Ability
        let cooldownRemaining: TimeInterval
        let charges: Int
        let ready: Bool

        // Visual states
        let highlightWhenReady: Bool
        let cooldownAnimation: Animation
    }

    let abilities: [AbilitySlot]
}
```

**Threat Indicators**
```swift
struct ThreatIndicatorUI {
    // World-space indicators
    let style: IndicatorStyle = .directional

    struct Threat {
        let direction: SIMD3<Float>
        let distance: Float
        let type: ThreatType
        let urgency: Float // 0-1

        // Rendering
        let color: Color // Based on urgency
        let size: Float // Based on distance
        let animation: Animation // Pulse for urgent
    }
}
```

### Menu System

**Main Menu**
```
┌─────────────────────────────────┐
│         ARENA ESPORTS           │
│                                 │
│      [PLAY COMPETITIVE]         │ ← Primary action
│      [TRAINING]                 │
│      [TOURNAMENT]               │
│      [PROFILE]                  │
│      [SETTINGS]                 │
│                                 │
│   Rank: Master (2150)           │
│   Players Online: 12,543        │
└─────────────────────────────────┘
```

**Pause Menu (In-Game)**
```
┌─────────────────────────────────┐
│         PAUSED                  │
│                                 │
│      [RESUME]                   │
│      [SETTINGS]                 │
│      [CONTROLS]                 │
│      [LEAVE MATCH]              │
│                                 │
│   Time Remaining: 4:32          │
│   Score: 2-1                    │
└─────────────────────────────────┘
```

**Settings Menu**
```
GAMEPLAY
├── Sensitivity (Aim)
├── Movement Speed
├── Auto-Reload
├── Damage Numbers
└── HUD Opacity

CONTROLS
├── Hand Tracking
├── Eye Tracking
├── Controller Config
├── Gesture Customization
└── Button Mapping

AUDIO
├── Master Volume
├── Music Volume
├── SFX Volume
├── Voice Chat Volume
└── Spatial Audio

VIDEO
├── Quality Preset
├── Frame Rate Target
├── Dynamic Resolution
├── Effects Quality
└── HUD Scale

ACCESSIBILITY
├── Color Blind Mode
├── High Contrast
├── Reduced Motion
├── Audio Cues
└── Haptic Intensity
```

### Post-Match Screen

```
┌─────────────────────────────────────────┐
│              VICTORY                    │
│                                         │
│         [Match Statistics]              │
│                                         │
│   YOUR PERFORMANCE                      │
│   Kills: 12  Deaths: 5  Assists: 8     │
│   Accuracy: 67%  Damage: 2,430          │
│   MVP: You!  (+100 XP bonus)            │
│                                         │
│   RATING CHANGE: +23                    │
│   2127 → 2150 (Master)                  │
│                                         │
│   [VIEW REPLAY]  [CONTINUE]            │
└─────────────────────────────────────────┘
```

---

## 7. Visual Style Guide

### Art Direction

**Visual Theme:** Futuristic Competitive Sports
- Clean, professional aesthetic
- High-tech sci-fi elements
- Focus on clarity over decoration
- Consistent color language

### Color Palette

**Primary Colors**
```
Team Blue:   #00A8FF (Friendly forces)
Team Orange: #FF6B00 (Enemy forces)
Neutral:     #FFFFFF (Environment)
Objective:   #FFD700 (Goals/points)
Danger:      #FF0000 (Warnings)
Safe:        #00FF00 (Confirmations)
```

**UI Colors**
```
Background: #0A0E27 (Dark blue-black)
Panel:      #1A1F3A (Lighter panels)
Text:       #E0E6F5 (Off-white)
Accent:     #00D9FF (Cyan highlights)
Disabled:   #666A7E (Gray)
```

### Typography

**Font Family:** SF Pro (System font for consistency)

**Font Sizes:**
- **Headlines:** 36pt (Menu titles)
- **Body Large:** 24pt (Primary actions)
- **Body Medium:** 18pt (Standard text)
- **Body Small:** 14pt (Secondary info)
- **Caption:** 12pt (Metadata)

**Font Weights:**
- **Bold:** Titles, important actions
- **Semibold:** Headings
- **Regular:** Body text
- **Light:** Captions, metadata

### Visual Effects

**Player Visuals**
```swift
struct PlayerVisuals {
    // Body
    let bodyMaterial: PhysicallyBasedMaterial // Sleek armor
    let teamColor: Color // Blue or Orange
    let emissiveGlow: Float = 0.3 // Subtle glow

    // Effects
    let trailEffect: ParticleSystem // Movement trail
    let hitEffect: ParticleSystem // When damaged
    let eliminatedEffect: ParticleSystem // Death effect

    // Customization
    let skinVariant: String
    let armorPattern: String
}
```

**Weapon Visuals**
```swift
struct WeaponVisuals {
    // Model
    let weaponMesh: ModelAsset
    let weaponMaterial: Material

    // Effects
    let muzzleFlash: ParticleSystem
    let bulletTracer: LineRenderer
    let reloadAnimation: Animation

    // Customization
    let weaponSkin: String
    let effectColor: Color
}
```

**Environmental Effects**
```swift
struct EnvironmentVisuals {
    // Arena
    let arenaMaterial: Material // Semi-transparent grid
    let boundaryGlow: EmissiveEffect

    // Atmospheric
    let ambientParticles: ParticleSystem // Floating energy
    let lightingScheme: LightingProfile

    // Dynamic
    let impactDecals: DecalSystem
    let energyRipples: ShaderEffect
}
```

### Iconography

**Icon Style:**
- Simple geometric shapes
- 2px stroke weight
- Rounded corners
- Consistent size (32x32 base)

**Icon Categories:**
```
Weapons: Recognizable silhouettes
Abilities: Abstract symbols
UI Actions: Standard icons (settings gear, etc.)
Team: Clear team identification
Status: Universal symbols (health cross, shield, etc.)
```

---

## 8. Audio Design

### Audio Philosophy

**Competitive Audio Priority:**
1. **Positional Accuracy:** Critical for gameplay
2. **Clarity:** Distinct, identifiable sounds
3. **Balance:** No sound overpowers others
4. **Consistency:** Reliable audio cues

### Sound Categories

**Weapon Audio**
```swift
enum WeaponSound {
    case fire           // Firing sound
    case reload         // Reload sequence
    case empty          // Empty mag click
    case draw           // Weapon equipped
    case impact         // Bullet hits
}

struct WeaponAudioProfile {
    let basePitch: Float
    let volume: Float
    let spatialBlend: Float = 1.0 // Full 3D
    let maxDistance: Float = 50.0
    let rolloffCurve: AudioRolloff = .logarithmic

    // Variations
    let fireVariations: [AudioClip] // Prevent repetition
    let layeredSounds: [AudioClip] // Multiple samples
}
```

**Movement Audio**
```swift
enum MovementSound {
    case footstep(surface: SurfaceType)
    case jump
    case land(velocity: Float)
    case dash
    case sprint
}

struct FootstepSystem {
    let surfaces: [SurfaceType: AudioClip]
    let interval: TimeInterval = 0.3 // Time between steps
    let volumeBasedOnSpeed: Bool = true
    let spatialAudio: Bool = true
}
```

**Combat Audio**
```swift
enum CombatSound {
    case hit(damage: Float)
    case headshot
    case elimination
    case assist
    case damaged
    case shieldBreak
    case healthLow
}

struct HitFeedbackAudio {
    let baseclip: AudioClip
    let pitchVariation: Float = 0.1
    let volumeScaling: Bool = true // Based on damage
    let directionalCue: Bool = true // Direction of hit
}
```

**UI Audio**
```swift
enum UISound {
    case menuNavigate
    case menuSelect
    case menuBack
    case notification
    case achievement
    case countdown
    case matchStart
    case matchEnd
    case victory
    case defeat
}

struct UIAudioProfile {
    let volume: Float = 0.7
    let spatialBlend: Float = 0.0 // Non-spatial (2D)
    let priority: Int = 100 // High priority
}
```

**Ambient Audio**
```swift
struct ArenaAmbience {
    let backgroundLoop: AudioClip
    let spatialElements: [SpatialSound]
    let intensityModulation: Bool = true // Based on combat

    struct SpatialSound {
        let position: SIMD3<Float>
        let clip: AudioClip
        let looping: Bool
        let volume: Float
    }
}
```

### Voice Communication

**Voice Chat System**
```swift
struct VoiceChatConfig {
    let codec: AudioCodec = .opus
    let bitrate: Int = 48_000 // 48 kbps
    let spatialVoice: Bool = true
    let proximity: Float = 30.0 // meters

    // Processing
    let noiseSupression: Bool = true
    let echoCancellation: Bool = true
    let autoGainControl: Bool = true

    // Privacy
    let pushToTalk: Bool = false // Always on by default
    let muteShortcut: Gesture = .doubleTap
}
```

**Callout System**
```swift
enum TacticalCallout {
    case enemySpotted(direction: Direction)
    case reloading
    case coverMe
    case advancing
    case retreat
    case abilityReady(ability: Ability)
    case objectiveSecured
}

// Quick voice lines triggered by gestures
struct CalloutAudio {
    let clips: [AudioClip] // Multiple voice actor variations
    let cooldown: TimeInterval = 3.0
    let teamOnly: Bool = true
}
```

### Music Design

**Dynamic Music System**
```swift
struct MusicSystem {
    enum Intensity {
        case menu       // Calm, atmospheric
        case warmup     // Building tension
        case combat     // Intense, rhythmic
        case clutch     // High stakes
        case victory    // Triumphant
        case defeat     // Somber
    }

    let layers: [MusicLayer]
    let crossfadeDuration: TimeInterval = 2.0
    let adaptiveIntensity: Bool = true

    func transitionTo(_ intensity: Intensity) {
        // Smooth crossfade between intensity levels
    }
}

struct MusicLayer {
    let clip: AudioClip
    let intensity: MusicSystem.Intensity
    let volume: Float
    let fadeInDuration: TimeInterval
}
```

**Soundtrack**
```
Main Theme: Epic orchestral with electronic elements
Menu Music: Ambient electronic, atmospheric
Combat Music: High-energy electronic, driving rhythm
Victory Theme: Triumphant, celebratory
Defeat Theme: Respectful, motivational
```

---

## 9. Accessibility

### Visual Accessibility

**Color Blind Modes**
```swift
enum ColorBlindMode {
    case none
    case protanopia    // Red-green (red weak)
    case deuteranopia  // Red-green (green weak)
    case tritanopia    // Blue-yellow

    func adjustColors(_ color: Color) -> Color {
        // Apply color transformation matrix
    }
}

struct ColorBlindPalette {
    // Alternative color schemes that work for all types
    let teamBlue: Color = .cyan      // Instead of pure blue
    let teamOrange: Color = .yellow  // Instead of orange
    let danger: Color = .magenta     // Instead of red
    let safe: Color = .blue          // Instead of green
}
```

**High Contrast Mode**
```swift
struct HighContrastSettings {
    let enabled: Bool
    let contrastRatio: Float = 7.0 // WCAG AAA standard

    // Enhanced visibility
    let outlineThickness: Float = 3.0
    let outlineColor: Color = .black
    let backgroundColor: Color = .white
    let textColor: Color = .black
}
```

**Text Scaling**
```swift
struct TextAccessibility {
    let scaleFactor: Float = 1.0 // 0.8 - 2.0
    let minimumSize: Float = 14.0
    let boldText: Bool = false
    let useSystemFont: Bool = true
}
```

### Auditory Accessibility

**Visual Audio Cues**
```swift
struct VisualAudioCues {
    let enabled: Bool

    // Show visual indicators for sound events
    let showFootsteps: Bool
    let showWeaponFire: Bool
    let showReload: Bool
    let showVoiceChat: Bool

    // Visual style
    let indicatorSize: Float
    let indicatorColor: Color
    let fadeoutDuration: TimeInterval
}
```

**Closed Captions**
```swift
struct ClosedCaptions {
    let enabled: Bool
    let fontSize: Float
    let backgroundColor: Color
    let position: CaptionPosition

    enum CaptionPosition {
        case bottom
        case top
        case customPosition(SIMD2<Float>)
    }

    // Caption content
    let showDialogue: Bool
    let showSoundEffects: Bool
    let showMusic: Bool
    let showDirection: Bool // [Gunfire from behind]
}
```

**Mono Audio**
```swift
struct MonoAudioSettings {
    let enabled: Bool
    // Converts spatial audio to mono
    // Useful for hearing impaired users
}
```

### Motor Accessibility

**Alternative Controls**
```swift
enum ControlScheme {
    case standard       // Full hand tracking + eye
    case simplified     // Reduced gesture complexity
    case controller     // Full game controller support
    case oneHanded      // Single hand operation
    case voiceOnly      // Voice commands primarily
    case custom         // User-defined mapping
}

struct SimplifiedControls {
    // Reduce required gestures
    let gestures: Set<HandGesture> = [
        .point,     // Aim
        .pinch,     // Shoot
        .openPalm   // Shield
    ]

    // Auto-features
    let autoReload: Bool = true
    let autoPickup: Bool = true
    let aimAssist: Float = 0.5 // Increased
}
```

**Haptic Feedback**
```swift
struct HapticSettings {
    let enabled: Bool
    let intensity: Float // 0.0 - 1.0

    // Customizable haptic events
    let onShoot: Bool
    let onHit: Bool
    let onDamaged: Bool
    let onObjective: Bool
    let onUIInteraction: Bool
}
```

### Cognitive Accessibility

**Reduced Motion**
```swift
struct ReducedMotionSettings {
    let enabled: Bool

    // Simplified animations
    let reduceParticleEffects: Bool
    let reduceScreenShake: Bool
    let simplifyTransitions: Bool
    let reducedFieldOfView: Bool

    // Slower pacing option
    let reducedGameSpeed: Float = 0.8 // 80% speed
}
```

**Tutorial Assistance**
```swift
struct TutorialSettings {
    let extendedTutorial: Bool
    let practiceMode: Bool // Infinite time/ammo
    let visualGuidance: Bool // Highlight objectives
    let audioInstructions: Bool
    let allowSkip: Bool
}
```

**Comfort Settings**
```swift
struct ComfortSettings {
    let vignetteIntensity: Float // Reduce peripheral vision during movement
    let reducedTurningSpeed: Bool
    let teleportMovement: Bool // Alternative to smooth movement
    let comfortBreakReminders: Bool
    let sessionTimeLimit: TimeInterval?
}
```

---

## 10. Tutorial & Onboarding

### Onboarding Flow

**Phase 1: Welcome (2 minutes)**
```
1. Welcome message
2. Vision Pro comfort check
3. Play space calibration
4. Physical space requirements
5. Safety briefing
```

**Phase 2: Basic Controls (5 minutes)**
```
1. Look around (eye tracking)
2. Point to aim (hand tracking)
3. Pinch to shoot
4. Movement basics
   • Forward/backward
   • Strafe left/right
5. Jump practice
```

**Phase 3: Combat Fundamentals (10 minutes)**
```
1. Weapon handling
   • Firing
   • Reloading
   • Weapon switching
2. Hit detection
   • Body shots
   • Headshots
3. Health and damage
4. Cover usage
```

**Phase 4: Spatial Awareness (10 minutes)**
```
1. 360-degree threats
   • Threat indicators
   • Audio cues
   • Minimap usage
2. Vertical combat
   • High ground advantage
   • Low ground tactics
3. Spherical navigation
```

**Phase 5: Team Play (5 minutes)**
```
1. Team identification
2. Communication
   • Voice chat
   • Callouts
   • Gestures
3. Formation basics
4. Objective play
```

**Phase 6: First Match (10 minutes)**
```
1. Matchmaking introduction
2. Guided first match
   • AI opponents
   • Real-time tips
   • Performance feedback
3. Results explanation
```

### Interactive Tutorial System

```swift
struct TutorialStep {
    let id: String
    let title: String
    let description: String
    let objective: TutorialObjective
    let hints: [String]
    let skipable: Bool

    enum TutorialObjective {
        case lookAround(duration: TimeInterval)
        case pointAtTarget(count: Int)
        case hitTarget(count: Int)
        case moveToPosition(position: SIMD3<Float>)
        case eliminateEnemy(count: Int)
        case captureObjective
        case useAbility(ability: Ability)
        case surviveFor(duration: TimeInterval)
    }
}

class TutorialManager {
    var currentStep: TutorialStep?
    var completedSteps: Set<String> = []

    func checkObjectiveComplete() -> Bool {
        guard let step = currentStep else { return false }

        switch step.objective {
        case .hitTarget(let count):
            return playerStats.targetsHit >= count
        case .eliminateEnemy(let count):
            return playerStats.enemiesEliminated >= count
        // ... other cases
        }
    }

    func showHint() {
        // Display contextual hint for current step
    }
}
```

### Adaptive Learning

```swift
struct AdaptiveTutorial {
    // Track player performance
    var skillAssessment: SkillAssessment

    func adjustDifficulty() {
        if skillAssessment.accuracy < 0.3 {
            // Make targets larger, slower
            targetSize *= 1.5
            targetSpeed *= 0.7
        } else if skillAssessment.accuracy > 0.8 {
            // Progress faster, challenge more
            skipBasicSteps()
            introduceAdvancedConcepts()
        }
    }

    struct SkillAssessment {
        var accuracy: Float
        var reactionTime: TimeInterval
        var spatialAwareness: Float
        var learningSpeed: Float
    }
}
```

---

## 11. Difficulty Balancing

### Skill-Based Matchmaking

```swift
struct MMRCalculation {
    let baseRating: Int
    let recentPerformance: [MatchResult]
    let winStreak: Int
    let consistency: Float

    func calculateMMR() -> Int {
        var mmr = baseRating

        // Recent performance (last 10 games)
        let recentWinRate = calculateWinRate(recent: 10)
        mmr += Int((recentWinRate - 0.5) * 100)

        // Win streak bonus
        if winStreak >= 3 {
            mmr += winStreak * 5
        }

        // Consistency factor (reduce MMR swings for consistent players)
        let variance = calculatePerformanceVariance()
        if variance < 0.2 {
            mmr = Int(Float(mmr) * 1.1) // 10% bonus for consistency
        }

        return mmr
    }
}
```

### Weapon Balancing

```swift
struct WeaponBalance {
    // Time to Kill (TTK) targets
    let optimalTTK: [WeaponType: TimeInterval] = [
        .spatialRifle: 0.6,      // 6 shots @ 0.1s = 0.6s
        .pulseBlaster: 0.4,       // 2 shots @ 0.2s = 0.4s
        .gravityLauncher: 1.0,    // 1 shot @ 1.0s = 1.0s
        .energySword: 0.3         // 2 swings @ 0.15s = 0.3s
    ]

    // Usage rate tracking
    func trackUsageRates() {
        // Monitor weapon pick rates
        // Adjust if one weapon dominates (>40% usage)
    }

    // Win rate tracking
    func trackWinRates() {
        // Monitor win rates by weapon
        // Adjust if win rate deviates >5% from average
    }
}
```

### Map Balancing

```swift
struct MapBalance {
    let mapID: UUID
    var teamAWinRate: Float
    var teamBWinRate: Float

    var isBalanced: Bool {
        let difference = abs(teamAWinRate - teamBWinRate)
        return difference < 0.05 // Within 5%
    }

    func suggestAdjustments() -> [MapAdjustment] {
        var adjustments: [MapAdjustment] = []

        if teamAWinRate > 0.55 {
            adjustments.append(.moveSpawnPoint(team: .a, direction: .back))
            adjustments.append(.addCover(near: .teamBSpawn))
        }

        return adjustments
    }
}
```

### Ability Balancing

```swift
struct AbilityBalance {
    let ability: Ability
    var usageRate: Float        // How often picked
    var successRate: Float      // How often effective
    var winRateImpact: Float    // Impact on match outcome

    func isBalanced() -> Bool {
        // Target usage rate: 20-30% (balanced across 4-5 abilities)
        let usageBalanced = usageRate > 0.15 && usageRate < 0.35

        // Success rate should be moderate (not too easy/hard)
        let successBalanced = successRate > 0.4 && successRate < 0.7

        // Win rate impact should be neutral
        let impactBalanced = abs(winRateImpact) < 0.05

        return usageBalanced && successBalanced && impactBalanced
    }
}
```

---

## Conclusion

This design document establishes:

- **Comprehensive game design** with clear loops and progression
- **Spatial-first gameplay** utilizing 360-degree combat
- **Professional UI/UX** optimized for competitive play
- **Cohesive visual/audio design** supporting gameplay clarity
- **Robust accessibility** ensuring inclusivity
- **Thorough onboarding** for player success
- **Balanced gameplay** through data-driven iteration

**Next Steps:**
1. Review and validate design specifications
2. Create detailed implementation plan
3. Begin prototyping core gameplay
4. Iterate based on playtesting

---

**Document Status:** Draft - Ready for Review
**Next Document:** IMPLEMENTATION_PLAN.md
