# Holographic Board Games - Design Document

## Document Overview
This document defines the game design and UI/UX specifications for Holographic Board Games, ensuring an engaging and comfortable spatial gaming experience.

**Version:** 1.0
**Last Updated:** 2025-01-20
**Design Pillars:** Natural, Spectacular, Accessible, Social

---

## 1. Core Design Principles

### 1.1 Design Pillars

**1. Natural Interaction**
- Game pieces respond to natural grabbing and placing motions
- No complex gestures to learn - if it feels right, it works
- Immediate visual feedback confirms successful interactions

**2. Spectacular Presentation**
- Chess pieces come alive during captures with cinematic battles
- Board evolves dynamically based on gameplay
- Celebrations feel rewarding and shareable

**3. Accessible to All**
- Tutorials teach rules through doing, not reading
- Multiple difficulty levels welcome all skill levels
- Accessibility options ensure everyone can play

**4. Social Connection**
- Remote players feel present around the board
- Natural conversation through spatial audio
- Shared moments of excitement and strategy

### 1.2 Player Experience Goals

```yaml
experience_goals:
  onboarding:
    - First piece movement within 30 seconds
    - First complete game within 15 minutes
    - Understanding of special moves within 3 games

  engagement:
    - Average session length: 30-45 minutes
    - Return rate: 70% within 7 days
    - Completion rate: 90% of started games

  satisfaction:
    - Post-game positive emotion: 85%
    - Recommendation likelihood: 4.5+ stars
    - Accessibility rating: 4.6+ stars
```

---

## 2. Game Design Document (GDD)

### 2.1 Core Gameplay Loop

```
┌─────────────────────────────────────────────────┐
│           HOLOGRAPHIC CHESS LOOP                │
└─────────────────────────────────────────────────┘

Session Flow:
1. Enter Game → Board materializes on table
2. Select Piece → Piece highlights, shows valid moves
3. Move Piece → Smooth animation to destination
4. Capture Event → Cinematic battle sequence
5. Opponent Turn → Watch AI or remote player move
6. Check/Checkmate → Dramatic notification and effects
7. Game End → Victory/defeat celebration
8. Rematch/Exit → Quick restart or return to menu

Micro-Loop (per move):
- Gaze at piece → Highlights with glow
- Pinch to grab → Haptic feedback, piece lifts
- Move hand → Piece follows smoothly
- Release on square → Snaps to position, validates move
- Animation plays → Piece settles, turn indicator changes
```

### 2.2 Chess Piece Personalities

Each piece type has unique animations and personality:

#### Pawn
```yaml
personality: Humble soldier, eager to prove themselves
animations:
  idle: Standing at attention, occasional fidget
  movement: Marching forward with determination
  capture: Quick sword strike, victory salute
  promotion: Transformation ceremony with light effects
  captured: Dramatic fall, fading away

sound_profile:
  footsteps: light_march.wav
  capture: sword_clash.wav
  promotion: ascension_choir.wav
```

#### Knight
```yaml
personality: Agile warrior on horseback
animations:
  idle: Horse pawing ground, knight looking around
  movement: Galloping leap over pieces
  capture: Mounted charge, lance strike
  victory: Rearing horse, knight raises sword
  captured: Horse stumbles, knight falls

sound_profile:
  movement: horse_gallop.wav
  capture: lance_impact.wav
  victory: victory_neigh.wav
```

#### Bishop
```yaml
personality: Mystical advisor with divine power
animations:
  idle: Gentle sway, staff glowing softly
  movement: Gliding diagonally with robes flowing
  capture: Staff strike with holy light
  blessing: Raises staff, allies nearby glow
  captured: Staff falls, figure dissipates

sound_profile:
  movement: mystical_woosh.wav
  capture: divine_strike.wav
  blessing: holy_chime.wav
```

#### Rook
```yaml
personality: Steadfast fortress guardian
animations:
  idle: Solid stance, occasional banner wave
  movement: Marching straight with heavy steps
  capture: Battering ram charge, tower collision
  fortify: Transforms into defensive position
  captured: Crumbles like stone structure

sound_profile:
  movement: heavy_march.wav
  capture: stone_crash.wav
  fortify: building_construction.wav
```

#### Queen
```yaml
personality: Commanding ruler with supreme power
animations:
  idle: Regal pose, crown glowing
  movement: Graceful glide in any direction
  capture: Multiple swift strikes, overwhelming power
  dominance: All pieces nearby bow slightly
  captured: Crown falls dramatically

sound_profile:
  movement: silk_rustle.wav
  capture: power_surge.wav
  dominance: royal_fanfare.wav
```

#### King
```yaml
personality: Strategic leader, must be protected
animations:
  idle: Surveying board, strategic thinking pose
  movement: Cautious single-step movement
  castle: Coordinated swap with rook, fortress forms
  check: Defensive stance, shield appears
  checkmate: Defeated pose, crown topples

sound_profile:
  movement: regal_step.wav
  castle: fortress_build.wav
  check: alarm_bell.wav
  checkmate: defeat_theme.wav
```

### 2.3 Board Evolution

The chess board responds to gameplay state:

```yaml
board_states:
  opening:
    atmosphere: Calm, strategic
    lighting: Bright, clear
    effects: Minimal particle effects
    music: Contemplative ambient

  mid_game:
    atmosphere: Rising tension
    lighting: Dynamic shadows from remaining pieces
    effects: Captured piece ghosts fade slowly
    music: Building intensity

  end_game:
    atmosphere: High stakes, dramatic
    lighting: Spotlight on king positions
    effects: Check indicators pulse
    music: Dramatic orchestral

  check:
    visual: Red glow around threatened king
    audio: Warning bell
    haptic: Alert pulse
    ui: Arrow showing threat path

  checkmate:
    visual: Victorious color floods board
    audio: Victory fanfare or defeat theme
    animation: Winner's pieces celebrate
    ui: Game summary appears
```

---

## 3. Spatial UI/UX Design

### 3.1 Interface Hierarchy

```
┌──────────────────────────────────────────────────┐
│                 SPATIAL LAYOUT                    │
│                                                   │
│      Player 2 Info                                │
│      ┌──────────────────┐                        │
│      │ Name | Timer    │                         │
│      └──────────────────┘                        │
│                                                   │
│  ┌───────────────────────────────┐               │
│  │                               │               │
│  │       CHESS BOARD             │  Captured     │
│  │       (Volumetric)            │  Pieces       │
│  │                               │  Display      │
│  │                               │               │
│  └───────────────────────────────┘               │
│                                                   │
│      ┌──────────────────┐                        │
│      │ Name | Timer    │                         │
│      └──────────────────┘                        │
│      Player 1 Info                                │
│                                                   │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐       │
│  │  Undo    │  │  Pause   │  │  Hint    │       │
│  └──────────┘  └──────────┘  └──────────┘       │
│                                                   │
└──────────────────────────────────────────────────┘
```

### 3.2 UI Component Specifications

#### Game HUD
```swift
struct GameHUD {
    // Player information
    struct PlayerInfo {
        let name: String
        let avatar: Image
        let timer: TimeInterval
        let capturedPieces: [ChessPiece]
        let materialAdvantage: Int
    }

    // Move history
    struct MoveHistory {
        let moves: [ChessMove]
        let maxVisible: Int = 10
        let scrollable: Bool = true
    }

    // Action buttons
    struct ActionBar {
        let buttons: [ActionButton] = [
            .undo,
            .pause,
            .hint,
            .settings,
            .resign
        ]
    }

    // Visual properties
    let opacity: CGFloat = 0.85
    let cornerRadius: CGFloat = 16
    let glassEffect: Bool = true
    let position: UIPosition = .periphery  // Outside play area
}
```

#### Piece Selection Indicator
```yaml
selection_feedback:
  visual:
    - Piece lifts slightly (0.05m)
    - Glowing outline (player color)
    - Valid moves show as highlighted squares
    - Invalid moves show as dimmed

  audio:
    - Selection chime
    - Valid move indicators pulse sound
    - Invalid move rejection sound

  haptic:
    - Selection confirmation tap
    - Hover over valid square: gentle pulse
    - Hover over invalid square: warning buzz
```

#### Move Validation Overlay
```yaml
move_indicators:
  valid_moves:
    visual: Green circle on square
    opacity: 0.6
    animation: Gentle pulsing
    interaction: Tap to confirm move

  capture_moves:
    visual: Red X on enemy piece
    opacity: 0.7
    animation: Aggressive pulsing
    interaction: Tap to execute capture

  special_moves:
    castle:
      visual: Blue connection line between king and rook
      label: "Castle"
    en_passant:
      visual: Yellow indicator with EP label
    promotion:
      visual: Crown icons showing promotion options
```

### 3.3 Menu System

#### Main Menu
```yaml
main_menu:
  layout: Window mode (2D)
  position: Center of user view
  size: 800x600 points

  sections:
    header:
      - App logo (animated hologram)
      - Tagline: "Where boards become worlds"

    primary_actions:
      - New Game (large, prominent)
      - Continue Game (if save exists)
      - Multiplayer (SharePlay)

    secondary_actions:
      - Tutorial
      - Settings
      - Game Library
      - Achievements

    footer:
      - Version info
      - Help/Support
```

#### Settings Interface
```yaml
settings:
  categories:
    gameplay:
      - Difficulty Level (Beginner, Intermediate, Advanced, Expert)
      - Time Controls (None, Blitz, Rapid, Classical)
      - Move Validation (Strict, Helpful, Permissive)
      - Undo Availability (Unlimited, Limited, Off)

    visual:
      - Board Theme (Wood, Marble, Metal, Holographic)
      - Piece Style (Classic, Modern, Fantasy, Sci-Fi)
      - Animation Speed (Fast, Normal, Slow, Off)
      - Effects Quality (High, Medium, Low)

    audio:
      - Music Volume (0-100%)
      - SFX Volume (0-100%)
      - Voice Chat (On/Off)
      - Spatial Audio (On/Off)

    accessibility:
      - VoiceOver Support
      - High Contrast Mode
      - Reduce Motion
      - Larger Pieces
      - Alternative Controls

    account:
      - Player Profile
      - iCloud Sync
      - Statistics
      - Privacy Settings
```

---

## 4. Visual Design

### 4.1 Color Palette

```yaml
brand_colors:
  primary: "#4A90E2"      # Holographic blue
  secondary: "#E24A90"    # Holographic pink
  accent: "#90E24A"       # Success green

chess_colors:
  white_pieces:
    primary: "#F5F5F5"    # Off-white
    highlight: "#FFFFFF"  # Pure white
    shadow: "#CCCCCC"     # Light gray

  black_pieces:
    primary: "#2C2C2C"    # Dark gray
    highlight: "#444444"  # Medium gray
    shadow: "#000000"     # Pure black

board:
  light_square: "#F0D9B5"  # Traditional light wood
  dark_square: "#B58863"   # Traditional dark wood
  highlight: "#90E24A80"   # Green with transparency
  danger: "#E24A4A80"      # Red with transparency

ui:
  background: "#1C1C1E"    # Dark background
  surface: "#2C2C2E"       # Elevated surface
  border: "#48484A"        # Subtle border
  text_primary: "#FFFFFF"  # White text
  text_secondary: "#98989D" # Gray text
```

### 4.2 Typography

```yaml
fonts:
  title:
    family: SF Pro Display
    weight: Bold
    size: 34pt

  headline:
    family: SF Pro Display
    weight: Semibold
    size: 24pt

  body:
    family: SF Pro Text
    weight: Regular
    size: 17pt

  caption:
    family: SF Pro Text
    weight: Regular
    size: 13pt

  chess_notation:
    family: SF Mono
    weight: Medium
    size: 15pt
```

### 4.3 Visual Effects

```yaml
particle_effects:
  piece_capture:
    - Explosion of light particles
    - Piece fragments dissolve
    - Smokey trail effect
    - Duration: 1.5 seconds

  check_indicator:
    - Pulsing red aura around king
    - Warning symbols orbit king
    - Ground plane highlights
    - Continuous until resolved

  victory_celebration:
    - Confetti explosion
    - Winner's pieces dance
    - Board lights up with winner color
    - Victory banner appears
    - Duration: 3 seconds

  promotion:
    - Ascending light beam
    - Pawn dissolves at top
    - New piece materializes
    - Crown descends and places
    - Duration: 2 seconds
```

---

## 5. Audio Design

### 5.1 Sound Effects Library

```yaml
ambient:
  board_presence: subtle_hum.wav
  piece_idle_breathing: soft_whoosh_loop.wav

movement:
  pawn_step: light_footstep.wav
  knight_gallop: horse_hooves.wav
  bishop_glide: mystical_swoosh.wav
  rook_march: heavy_footstep.wav
  queen_move: regal_sweep.wav
  king_step: authoritative_step.wav

captures:
  pawn_clash: sword_strike.wav
  knight_charge: lance_impact.wav
  bishop_strike: staff_blast.wav
  rook_crush: stone_smash.wav
  queen_attack: power_surge.wav

special_moves:
  castle: fortress_gate.wav
  en_passant: surprise_strike.wav
  promotion: transformation_chime.wav
  check: warning_bell.wav
  checkmate: victory_fanfare.wav / defeat_gong.wav

ui:
  button_click: soft_tap.wav
  menu_open: interface_woosh.wav
  piece_select: selection_ping.wav
  illegal_move: error_buzz.wav
```

### 5.2 Music Composition

```yaml
music_tracks:
  main_menu:
    mood: Welcoming, mysterious
    tempo: 80 BPM
    instruments: [piano, strings, synth_pad]
    duration: 3:00 (looping)

  gameplay_opening:
    mood: Contemplative, strategic
    tempo: 70 BPM
    instruments: [classical_guitar, cello, subtle_percussion]
    duration: 4:00 (looping)

  gameplay_midgame:
    mood: Building tension
    tempo: 90 BPM
    instruments: [strings, brass, percussion]
    duration: 4:30 (looping)

  gameplay_endgame:
    mood: High stakes, dramatic
    tempo: 100 BPM
    instruments: [full_orchestra, choir]
    duration: 3:30 (looping)

  victory:
    mood: Triumphant, celebratory
    tempo: 120 BPM
    instruments: [brass, timpani, choir]
    duration: 0:30 (one-shot)

  defeat:
    mood: Somber, reflective
    tempo: 60 BPM
    instruments: [piano, strings]
    duration: 0:20 (one-shot)
```

---

## 6. Tutorial & Onboarding

### 6.1 First-Time User Experience (FTUE)

```yaml
ftue_flow:
  step_1_welcome:
    duration: 15s
    content:
      - Welcome message
      - App value proposition
      - Privacy assurance
    interaction: "Tap to continue"

  step_2_board_appears:
    duration: 10s
    content:
      - Board materializes on table
      - "This is your holographic chess board"
      - Encourage walking around to see 3D
    interaction: "Look around the board"

  step_3_select_piece:
    duration: 30s
    content:
      - Highlight a white pawn
      - "Gaze at a piece to select it"
      - "Pinch to grab it"
    interaction: Wait for user to grab pawn
    help: Show hand gesture animation

  step_4_move_piece:
    duration: 30s
    content:
      - Show valid move squares
      - "Move your hand to a green square"
      - "Release to place the piece"
    interaction: Wait for successful move
    help: Valid moves pulse

  step_5_piece_animation:
    duration: 10s
    content:
      - Piece animates to position
      - "Pieces come alive in holographic chess!"
      - Show brief capture animation preview
    interaction: Auto-advance

  step_6_practice_game:
    duration: 5-10min
    content:
      - "Let's play a practice game"
      - AI assists with move suggestions
      - Tutorial tips appear as needed
    interaction: Complete 10 moves
    success_criteria: Understanding of basic movement

  step_7_completion:
    duration: 20s
    content:
      - Congratulations message
      - Unlock full game
      - Encourage multiplayer
    interaction: "Start playing!"
```

### 6.2 Contextual Tutorials

```yaml
contextual_help:
  special_moves:
    trigger: First opportunity to castle
    content: "You can castle! This special move protects your king."
    demonstration: Animated example
    optional: User can dismiss

  piece_strategies:
    trigger: Piece selection
    content: Brief tooltip about piece strengths
    example: "Knights excel in closed positions"
    frequency: Once per piece type

  check_situation:
    trigger: King in check
    content: "Your king is in check! You must move it to safety"
    help: Highlight escape squares
    critical: Cannot dismiss until resolved

  tactical_opportunities:
    trigger: AI detects tactics
    content: "Hint available - see a good move?"
    interaction: Optional hint system
    cost: Limited hints per game
```

---

## 7. Difficulty Balancing

### 7.1 AI Difficulty Levels

```yaml
beginner:
  elo_range: 800-1000
  characteristics:
    - Random legal moves
    - No look-ahead
    - Doesn't recognize tactics
    - Makes occasional blunders
  target_audience: Complete beginners
  win_rate_target: 30% player wins

intermediate:
  elo_range: 1200-1400
  characteristics:
    - 2-ply search depth
    - Basic material evaluation
    - Recognizes simple tactics
    - Occasional strategic errors
  target_audience: Casual players
  win_rate_target: 50% balanced

advanced:
  elo_range: 1600-1800
  characteristics:
    - 4-ply search depth
    - Positional evaluation
    - Tactical combinations
    - Opening book knowledge
  target_audience: Experienced players
  win_rate_target: 70% AI wins

expert:
  elo_range: 2000-2200
  characteristics:
    - 6-ply search depth
    - Advanced positional understanding
    - Deep tactical calculation
    - Endgame tablebase
  target_audience: Strong players
  win_rate_target: 85% AI wins
```

### 7.2 Adaptive Difficulty

```yaml
adaptive_system:
  enabled_by_default: true
  adjustment_frequency: Every 3 games

  tracking_metrics:
    - Win/loss ratio
    - Average game length
    - Blunder frequency
    - Time per move

  adjustments:
    player_struggling:
      - Reduce AI depth by 1 ply
      - Increase hint availability
      - Add encouraging messages

    player_dominating:
      - Increase AI depth by 1 ply
      - Reduce hint availability
      - Suggest harder difficulty

    balanced_games:
      - Maintain current difficulty
      - Provide performance feedback
```

---

## 8. Accessibility Features

### 8.1 Visual Accessibility

```yaml
visual_accommodations:
  high_contrast_mode:
    - Increased contrast between pieces and board
    - Thicker outlines on pieces
    - Simplified visual effects

  larger_pieces:
    - Scale pieces up 25-50%
    - Increase board size accordingly
    - Reduce animation complexity

  colorblind_modes:
    - Deuteranopia compensation
    - Protanopia compensation
    - Tritanopia compensation
    - Pattern overlays on pieces

  reduce_motion:
    - Disable all animations
    - Instant piece movement
    - Static UI elements
```

### 8.2 Audio Accessibility

```yaml
audio_accommodations:
  voiceover_support:
    - Piece descriptions
    - Board position announcements
    - Move validation feedback
    - Game state notifications

  audio_cues:
    - Different tones for each piece type
    - Spatial audio for piece positions
    - Verbal move notation
    - Alert sounds for check/checkmate

  captions:
    - All sound effects captioned
    - Music mood descriptions
    - Voice chat transcription
```

### 8.3 Motor Accessibility

```yaml
motor_accommodations:
  alternative_controls:
    - Voice commands for moves
    - Gaze-only selection
    - Game controller support
    - Extended time for interactions

  simplified_gestures:
    - Tap instead of pinch
    - Larger interaction zones
    - Snap-to-grid for imprecise movements
    - Undo always available

  auto_play_features:
    - Auto-execute obvious moves
    - Suggested move acceptance
    - Quick rematch option
```

---

## 9. Social Features

### 9.1 Player Presence

```yaml
remote_player_representation:
  avatar:
    - Customizable appearance
    - Memoji integration
    - Position relative to board
    - Gaze direction indicator

  presence_indicators:
    - Online status
    - Currently selecting piece
    - Thinking/contemplating
    - Reaction emojis

  communication:
    - Spatial voice chat
    - Quick chat emotes
    - Celebration animations
    - Good game gestures
```

### 9.2 Spectator Mode

```yaml
spectator_features:
  viewing_options:
    - Free camera movement
    - Fixed perspectives (player 1, player 2, overhead)
    - Cinematic angles for captures
    - Instant replay of moves

  information_display:
    - Material count
    - Evaluation bar
    - Move history
    - Player statistics

  interaction:
    - Cannot affect game
    - Can chat with other spectators
    - Reaction emojis visible to players
    - Recording/screenshots allowed
```

---

## 10. Progression Systems

### 10.1 Player Statistics

```yaml
tracked_statistics:
  overall:
    - Total games played
    - Win/loss/draw record
    - Favorite piece
    - Longest winning streak
    - Total playtime

  per_game:
    - Move accuracy
    - Tactics found
    - Blunders avoided
    - Average time per move
    - Opening repertoire

  achievements:
    - First victory
    - Checkmate with each piece
    - Flawless games (no blunders)
    - Tournament wins
    - Social milestones
```

### 10.2 Unlockables

```yaml
unlockable_content:
  board_themes:
    - Wood Classic (default)
    - Marble Elegance (10 games)
    - Futuristic Hologram (50 games)
    - Fantasy Realm (100 games)

  piece_sets:
    - Classic (default)
    - Medieval Warriors (first victory)
    - Sci-Fi Robots (20 victories)
    - Fantasy Creatures (100 victories)

  animations:
    - Standard (default)
    - Epic Battles (10 captures)
    - Magical Effects (50 captures)
    - Cinematic Sequences (100 captures)

  special_effects:
    - Victory Fireworks
    - Custom board borders
    - Ambient particles
    - Seasonal themes
```

---

## 11. User Interface Specifications

### 11.1 Button Design

```swift
struct HolographicButton: View {
    let title: String
    let icon: Image?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                if let icon = icon {
                    icon
                        .font(.system(size: 20))
                }
                Text(title)
                    .font(.headline)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .shadow(radius: 4)
            )
            .foregroundStyle(.primary)
        }
        .hoverEffect()
    }
}
```

### 11.2 Card Design

```swift
struct GameCard: View {
    let game: GameInfo

    var body: some View {
        VStack(alignment: .leading) {
            // Game thumbnail
            AsyncImage(url: game.imageURL)
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            // Game info
            VStack(alignment: .leading, spacing: 8) {
                Text(game.title)
                    .font(.title3)
                    .fontWeight(.semibold)

                Text(game.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                HStack {
                    Label("\(game.players) players", systemImage: "person.2")
                    Spacer()
                    Label("\(game.duration) min", systemImage: "clock")
                }
                .font(.caption2)
                .foregroundStyle(.tertiary)
            }
            .padding()
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 8)
    }
}
```

---

## 12. Animation Timing

### 12.1 Animation Durations

```yaml
timing_standards:
  micro_interactions:
    button_press: 0.1s
    toggle: 0.2s
    tooltip: 0.15s

  piece_movement:
    one_square: 0.3s
    two_squares: 0.5s
    knight_jump: 0.4s
    castle: 0.8s

  capture_sequences:
    approach: 0.3s
    battle: 0.8s
    celebration: 0.4s
    total: 1.5s

  ui_transitions:
    menu_appear: 0.4s
    menu_disappear: 0.3s
    page_transition: 0.5s
    modal_present: 0.4s

  game_events:
    check_indicator: 0.2s (instant)
    checkmate: 2.0s (dramatic)
    promotion: 1.5s
    victory: 3.0s
```

### 12.2 Easing Functions

```yaml
easing_curves:
  piece_movement: easeInOutQuad
  ui_elements: easeOutCubic
  attention_grabbing: easeOutBack
  dismissals: easeInQuad
  celebrations: easeOutElastic
```

---

## Appendix: Design Assets Checklist

```yaml
required_assets:
  3d_models:
    - ☐ Chess pieces (6 types × 2 colors)
    - ☐ Chess board (multiple themes)
    - ☐ Capture effect particles
    - ☐ Victory celebration effects

  textures:
    - ☐ Wood grain (board)
    - ☐ Marble (pieces and board)
    - ☐ Metal (pieces)
    - ☐ Holographic shader

  audio:
    - ☐ 30+ sound effects
    - ☐ 6 music tracks
    - ☐ Spatial audio profiles

  ui_graphics:
    - ☐ App icon
    - ☐ Menu backgrounds
    - ☐ Button assets
    - ☐ Achievement icons

  animations:
    - ☐ 6 piece idle animations
    - ☐ 6 × 3 piece movement animations
    - ☐ 15 capture battle sequences
    - ☐ 10 celebration animations
```

---

*This design document ensures Holographic Board Games delivers an engaging, accessible, and visually spectacular spatial gaming experience.*
