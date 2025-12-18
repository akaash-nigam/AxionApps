# Shadow Boxing Champions - Design Document

## Document Overview

This document encompasses the complete game design, UI/UX, and player experience design for Shadow Boxing Champions. It serves as the definitive guide for creating an engaging, accessible, and revolutionary boxing training game for Apple Vision Pro.

**Version:** 1.0
**Last Updated:** 2025-11-19
**Game Genre:** Fitness Combat Simulation / Training
**Target Platform:** visionOS 2.0+ (Apple Vision Pro)

---

## Table of Contents

1. [Game Design Overview](#game-design-overview)
2. [Core Gameplay Loop](#core-gameplay-loop)
3. [Player Progression System](#player-progression-system)
4. [Training Modes](#training-modes)
5. [Sparring and Competition](#sparring-and-competition)
6. [Level Design Principles](#level-design-principles)
7. [Spatial Gameplay Design](#spatial-gameplay-design)
8. [UI/UX for Gaming](#uiux-for-gaming)
9. [Visual Style Guide](#visual-style-guide)
10. [Audio Design](#audio-design)
11. [Accessibility Features](#accessibility-features)
12. [Tutorial and Onboarding](#tutorial-and-onboarding)
13. [Difficulty Balancing](#difficulty-balancing)

---

## 1. Game Design Overview

### 1.1 Core Vision

Shadow Boxing Champions bridges the gap between professional athletic training and engaging gameplay, creating an experience that is simultaneously:
- **Authentic**: Real boxing techniques and training methods
- **Engaging**: Gamified progression and competition
- **Accessible**: Suitable for beginners through professionals
- **Revolutionary**: Leverages spatial computing in ways previously impossible

### 1.2 Design Pillars

#### Pillar 1: Authentic Boxing Experience
Every aspect of the game reflects real boxing training and competition:
- Professional technique analysis
- Realistic opponent behavior
- Accurate physics and impact
- Championship-level coaching

#### Pillar 2: Progressive Challenge
Players continuously improve through well-designed difficulty curves:
- Gradual skill building
- Appropriate challenge at every level
- Clear feedback on improvement
- Achievable yet ambitious goals

#### Pillar 3: Spatial Immersion
Full utilization of Vision Pro's unique capabilities:
- Life-size opponents in your space
- Natural boxing movements
- Spatial audio for atmosphere
- Room-scale gameplay

#### Pillar 4: Meaningful Fitness
Real physical and skill development:
- Measurable fitness improvements
- Genuine boxing technique
- Professional-grade training
- Health integration

### 1.3 Target Experience

**For Beginners:**
- Welcoming introduction to boxing
- Clear instruction and guidance
- Achievable early victories
- Confidence building

**For Intermediate:**
- Technical refinement
- Strategic depth
- Competitive challenge
- Skill mastery path

**For Advanced:**
- Professional-level training
- Complex opponent AI
- Tournament competition
- Performance optimization

### 1.4 Game Modes Summary

| Mode | Duration | Intensity | Focus |
|------|----------|-----------|-------|
| **Quick Spar** | 3-5 min | Low-Med | Casual practice |
| **Technical Training** | 10-15 min | Low | Skill building |
| **Fitness Workout** | 15-30 min | High | Cardio/stamina |
| **Competitive Match** | 15-20 min | High | Winning/strategy |
| **Tournament** | 30-45 min | Variable | Championship |
| **Daily Challenge** | 5-10 min | Variable | Focused goal |

---

## 2. Core Gameplay Loop

### 2.1 Macro Loop (Career Progression)

```
Select Training → Practice Techniques → Improve Skills
                           ↓
                    Gain Experience
                           ↓
                    Level Up / Unlock
                           ↓
         Face Tougher Opponents → Win Matches
                           ↓
                   Earn Rewards
                           ↓
              Unlock New Content
                           ↓
              Return to Training
```

### 2.2 Session Loop (Single Match)

```
Pre-Match Setup:
- Select opponent
- Choose match length
- Warm-up exercises

Round Structure (3-12 rounds):
1. Round Start (Touch gloves)
2. Combat Phase:
   - Throw punches
   - Defend attacks
   - Manage stamina
   - Execute combos
3. Round End (Break)
4. Coach feedback
5. Recovery period

Post-Match:
- Results screen
- Statistics review
- Rewards/unlocks
- Save progress
- Share achievements
```

### 2.3 Micro Loop (Moment-to-Moment)

**Combat Flow (per second):**
```
Assess → Decide → Execute → React → Repeat

Assess:
- Opponent position
- Openings/vulnerabilities
- Your stamina level
- Opponent patterns

Decide:
- Offensive action (punch combo)
- Defensive action (block/dodge)
- Movement (advance/retreat)
- Recovery (conserve stamina)

Execute:
- Perform chosen action
- Monitor execution quality
- Adjust timing

React:
- Opponent counters
- Damage feedback
- Adjust strategy
- Continue flow
```

### 2.4 Engagement Hooks

**Short-term (During Match):**
- Punch impact satisfaction
- Combo completion
- Successful defense
- Score updates
- Round victories

**Medium-term (Per Session):**
- Match victories
- Personal records
- Skill improvements
- Daily challenges
- Achievement unlocks

**Long-term (Career):**
- Level progression
- Opponent mastery
- Tournament wins
- Global rankings
- Skill mastery

---

## 3. Player Progression System

### 3.1 Experience and Leveling

#### XP Sources

| Activity | Base XP | Multipliers |
|----------|---------|-------------|
| Training session | 100 | +50% with good form |
| Sparring win | 300 | +difficulty% |
| Sparring loss | 100 | +effort% |
| Perfect round | 50 | Bonus |
| Combo executed | 10-50 | By combo complexity |
| Defense successful | 15 | Per successful dodge |
| Daily challenge | 200 | Completion bonus |
| Tournament round | 500 | +placement bonus |

#### Level Progression

```
Level Formula: XP Required = 1000 * (level ^ 1.5)

Level 1 → 2: 1,000 XP
Level 2 → 3: 2,828 XP
Level 3 → 4: 5,196 XP
Level 5 → 6: 11,180 XP
Level 10 → 11: 31,622 XP
Level 20 → 21: 89,442 XP
Level 50 (max): 353,553 XP
```

### 3.2 Skill Trees

#### Power Branch
- **Heavy Hitter**: +15% punch damage
  - **Devastating Blows**: +30% critical hit damage
    - **One-Hit Wonder**: Chance for instant knockdown

#### Speed Branch
- **Quick Hands**: +10% punch speed
  - **Lightning Jabs**: Jabs cost 50% less stamina
    - **Flurry Master**: Can throw 3x speed combos

#### Defense Branch
- **Iron Guard**: -15% damage taken when blocking
  - **Evasion Expert**: +25% dodge success rate
    - **Counter Specialist**: Successful dodges enable powerful counters

#### Stamina Branch
- **Cardio King**: +20% stamina pool
  - **Second Wind**: Stamina regenerates 50% faster
    - **Endless Energy**: Never drop below 25% stamina

#### Technique Branch
- **Form Perfect**: +15% technique score
  - **Precision Striker**: +20% punch accuracy
    - **Technical Knockout**: Perfect form punches deal 2x damage

### 3.3 Unlockable Content

#### Opponents (Progressive Difficulty)

**Tier 1: Beginners (Levels 1-5)**
- Danny "First Timer"
- Sarah "Gym Newbie"
- Mike "Practice Partner"

**Tier 2: Amateur (Levels 6-15)**
- Carlos "Quick Jab"
- Tyra "The Wall"
- Jin "Counter King"

**Tier 3: Professional (Levels 16-30)**
- "Iron" Ivan Volkov
- "Lightning" Lisa Chen
- Marcus "The Mauler" Johnson

**Tier 4: Champions (Levels 31-50)**
- "Phantom" Freddie Martinez (Evasive specialist)
- "Crusher" Kate Williams (Power puncher)
- Diego "El Toro" Rodriguez (Aggressive swarmer)
- **Final Boss**: "The Legend" (Adaptive master)

#### Training Venues

1. **Home Gym** (Default)
   - Small, intimate space
   - Basic equipment
   - Personal atmosphere

2. **Local Boxing Gym** (Level 5)
   - Traditional gym aesthetic
   - Other boxers training
   - Authentic atmosphere

3. **Professional Training Center** (Level 15)
   - State-of-the-art facility
   - Elite equipment
   - High-tech displays

4. **Championship Arena** (Level 25)
   - Full crowd simulation
   - Broadcast quality
   - High-pressure environment

5. **The Legend's Gym** (Level 40)
   - Exclusive training space
   - Master-level instruction
   - Ultimate atmosphere

#### Gear and Customization

**Gloves:**
- Speed Gloves (lighter, faster punches)
- Power Gloves (heavier, more damage)
- Technical Gloves (better accuracy feedback)
- Champion Gloves (balanced, prestigious)

**Appearance:**
- Glove colors (15 options)
- Training attire (10 outfits)
- Victory animations (8 variations)
- Entrance styles (6 options)

### 3.4 Achievement System

#### Categories

**Combat Achievements:**
- First Blood: Land your first punch
- Combo Starter: Execute a 3-punch combo
- Combo Master: Execute a 10-punch combo
- Perfect Round: Win a round without taking damage
- Knockout Artist: Achieve 10 knockouts
- Defensive Specialist: Win a match landing only counter-punches

**Training Achievements:**
- Dedicated: Complete 10 training sessions
- Student of the Game: Complete all technique drills
- Fitness Fanatic: Burn 10,000 calories
- Marathon Runner: Train for 10 consecutive days
- Century Club: Complete 100 training sessions

**Competition Achievements:**
- First Victory: Win your first match
- Undefeated: Win 10 matches in a row
- Tournament Champion: Win your first tournament
- Grand Champion: Win the championship tournament
- Perfect Season: Win a tournament without losing a round

**Skill Achievements:**
- Technician: Achieve 95%+ average technique score
- Power Puncher: Reach max power rating
- Speed Demon: Reach max speed rating
- Iron Chin: Reach max defense rating
- Complete Fighter: Max all skill categories

---

## 4. Training Modes

### 4.1 Technical Training

#### Punch Technique Drills

**Jab Drill**
- **Objective**: Perfect the jab technique
- **Duration**: 3 minutes
- **Success Criteria**:
  - 90%+ form accuracy
  - Consistent snap and extension
  - Proper shoulder rotation
- **Feedback**: Real-time form visualization
- **Progression**: Speed increases with mastery

**Power Cross Drill**
- **Objective**: Maximize cross power
- **Duration**: 3 minutes
- **Success Criteria**:
  - Full hip rotation
  - Weight transfer
  - 85%+ power output
- **Feedback**: Power meter display
- **Progression**: Target power thresholds increase

**Hook Technique**
- **Objective**: Master circular punch mechanics
- **Duration**: 4 minutes
- **Success Criteria**:
  - Proper elbow positioning
  - Torso rotation
  - Target accuracy
- **Feedback**: Arc visualization
- **Progression**: Speed and power targets

**Uppercut Mastery**
- **Objective**: Perfect the uppercut
- **Duration**: 4 minutes
- **Success Criteria**:
  - Knee bend and explosion
  - Vertical trajectory
  - Chin target accuracy
- **Feedback**: Trajectory tracking
- **Progression**: Combo integration

#### Combination Training

**Basic Combos:**
1. Jab-Cross (1-2)
2. Jab-Jab-Cross (1-1-2)
3. Jab-Cross-Hook (1-2-3)
4. Cross-Hook-Cross (2-3-2)

**Intermediate Combos:**
5. Jab-Cross-Hook-Cross (1-2-3-2)
6. Jab-Body-Head-Hook (1-3-2-3)
7. Double Jab-Cross-Uppercut (1-1-2-5)
8. Roll-Hook-Cross (Defensive + 3-2)

**Advanced Combos:**
9. 6-punch combination (1-2-3-2-3-2)
10. Defensive counter sequences
11. Freestyle combinations

### 4.2 Defensive Training

#### Slip and Duck Drill
- **Setup**: Opponent throws slow, telegraphed punches
- **Objective**: Avoid 20 punches using head movement
- **Success**: 80%+ avoidance rate
- **Progression**: Punch speed increases

#### Block and Parry
- **Setup**: Mixed punch attacks
- **Objective**: Successfully block/parry 30 punches
- **Success**: 85%+ defense rate
- **Progression**: Faster combos, feints

#### Counter-Punching
- **Setup**: Opponent attacks with openings
- **Objective**: Counter-punch after each defense
- **Success**: 10 successful counters
- **Progression**: Shorter windows, faster opponents

### 4.3 Fitness Workouts

#### Cardio Blitz (15 minutes)
```
Warmup: 2 min light jabs
Round 1: 3 min continuous punching (moderate)
Rest: 1 min
Round 2: 3 min speed combos (high intensity)
Rest: 1 min
Round 3: 3 min power punches (maximum effort)
Cooldown: 2 min light movement
```
**Target**: 200-300 calories burned

#### HIIT Boxing (20 minutes)
```
30s all-out → 30s rest × 20 rounds

Odd rounds: Maximum speed punching
Even rounds: Power combinations
```
**Target**: 250-400 calories burned

#### Endurance Builder (30 minutes)
```
6 rounds × 4 minutes (1 min rest between)

Each round:
- 1 min jab focus
- 1 min combo work
- 1 min defensive movement
- 1 min power punches
```
**Target**: 400-500 calories burned

### 4.4 Scenario Training

#### Aggressive Opponent
- Constant forward pressure
- High punch volume
- Practice defensive movement and counter-punching

#### Defensive Opponent
- Tight guard
- Counter-punch specialist
- Practice combination breaking through defense

#### Technical Boxer
- Precise punching
- Good footwork
- Practice matching technique and strategy

#### Power Puncher
- Heavy shots
- Knockout threat
- Practice evasion and movement

---

## 5. Sparring and Competition

### 5.1 Sparring Structure

#### Quick Spar (3 rounds × 1 minute)
- Casual practice
- Friendly opponent
- Focus on fun and experimentation
- No ranking impact

#### Standard Match (3 rounds × 2 minutes)
- Balanced competition
- Ranked opponent
- Affects rankings
- Full scoring system

#### Championship Bout (5 rounds × 2 minutes)
- High stakes
- Tough opponents
- Maximum rewards
- Tournament format

### 5.2 Scoring System

#### Points Breakdown

**Offensive Points:**
- Jab landed: 1 point
- Power punch landed: 2 points
- Clean body shot: 2 points
- Head shot (accurate): 3 points
- Combo bonus: +1-5 points
- Knockdown: 50 points

**Defensive Points:**
- Successful block: 1 point
- Successful slip/duck: 2 points
- Counter-punch: +2 point bonus
- Perfect defense (5 in a row): 10 points

**Technique Multiplier:**
- Poor form (< 50%): 0.5x
- Average form (50-75%): 1.0x
- Good form (75-90%): 1.25x
- Excellent form (90%+): 1.5x

**Damage System:**
- Health: 100 points
- Light punch: -3 HP
- Medium punch: -5 HP
- Heavy punch: -8 HP
- Critical hit: -12 HP
- Below 30 HP: Increased knockdown risk
- 0 HP: Technical knockout

### 5.3 AI Opponent Behavior

#### Fighting Styles

**Boxer (Outfighter)**
```
Strategy:
- Maintain distance
- Use jab frequently
- Circle away from power
- Counter-punch opportunities

Weaknesses:
- Pressure fighters
- Body attacks
- Cutting off the ring
```

**Brawler (Slugger)**
```
Strategy:
- Aggressive forward pressure
- Heavy punches
- Willingness to take hits
- Break down opponent

Weaknesses:
- Technical boxers
- Movement and evasion
- Stamina drain
```

**Swarmer (Infighter)**
```
Strategy:
- Close distance quickly
- High volume punching
- Body attacks
- Constant pressure

Weaknesses:
- Long-range fighters
- Straight punches
- Footwork and spacing
```

**Counter-Puncher**
```
Strategy:
- Defensive first
- Wait for mistakes
- Capitalize on openings
- Efficient energy use

Weaknesses:
- Feints and pressure
- Varied attacks
- Patience required
```

#### Adaptive AI Features

**Pattern Recognition:**
- Learns player's favorite combos
- Adapts defense accordingly
- Exploits predictable patterns

**Dynamic Difficulty:**
- Adjusts based on player performance
- Increases aggression if winning
- Becomes more cautious if losing

**Personality Traits:**
- Some opponents taunt
- Some are respectful
- Affects crowd reaction
- Adds character

### 5.4 Tournament System

#### Structure

```
Single Elimination Bracket:
- 8 or 16 fighters
- Player starts as seed based on ranking
- Progress through rounds
- Championship bout for finals

Round Format:
- Quarterfinals: 3 rounds × 2 min
- Semifinals: 4 rounds × 2 min
- Finals: 5 rounds × 2 min
```

#### Tournament Types

**Rookie Tournament** (Level 1-10)
- 8 fighters
- Beginner difficulty
- Rewards: 1,000 XP, Unlock opponent

**Regional Championship** (Level 11-25)
- 16 fighters
- Intermediate difficulty
- Rewards: 5,000 XP, New venue, Gear

**National Championship** (Level 26-40)
- 16 fighters
- Advanced difficulty
- Rewards: 15,000 XP, Elite opponents, Rare gear

**World Championship** (Level 41+)
- 16 fighters
- Expert difficulty
- Rewards: 50,000 XP, Legendary status, All unlocks

---

## 6. Level Design Principles

### 6.1 Spatial Environment Design

#### Design Goals
- **Believable**: Feels like a real boxing venue
- **Immersive**: Enhances the experience
- **Adaptive**: Works in various room sizes
- **Performance**: Maintains 90 FPS

#### Environment Layers

**Layer 1: Play Space (Essential)**
- Boxing ring floor
- Opponent space
- Player movement area
- Safety boundaries

**Layer 2: Immediate Context (Important)**
- Ring ropes/corners
- Training equipment (for training modes)
- Lighting
- Audio sources

**Layer 3: Atmosphere (Enhancement)**
- Crowd/spectators
- Venue architecture
- Ambient effects
- Background details

### 6.2 Venue Progression

#### Home Gym
**Atmosphere:**
- Intimate, personal space
- Minimal distractions
- Focus on fundamentals
- Quiet, focused

**Visual Elements:**
- Simple boxing ring or mat
- Basic lighting
- Minimal decoration
- Clean aesthetic

**Audio:**
- Ambient gym sounds
- Quiet music
- Clear coaching voice

#### Local Gym
**Atmosphere:**
- Community feel
- Other boxers in background
- Authentic gym vibes
- Motivating

**Visual Elements:**
- Traditional boxing gym
- Heavy bags, speed bags (visible)
- Vintage boxing posters
- Natural lighting

**Audio:**
- Gym ambience
- Equipment sounds
- Energetic music
- Motivational coaching

#### Professional Facility
**Atmosphere:**
- Elite training environment
- Modern, high-tech
- Professional level
- Inspiring

**Visual Elements:**
- State-of-the-art ring
- LED displays with stats
- Modern architecture
- Professional lighting

**Audio:**
- High-quality sound system
- Professional commentary
- Intense music
- Technical coaching

#### Championship Arena
**Atmosphere:**
- High-stakes competition
- Full crowd
- Broadcast quality
- Adrenaline-pumping

**Visual Elements:**
- Professional boxing ring
- Crowd of thousands (particles/LOD)
- Spotlights and effects
- Jumbotron displays

**Audio:**
- Roaring crowd
- Announcer commentary
- Championship music
- High-energy coaching

### 6.3 Adaptive Scaling

#### Small Space (2m × 2m)
- Compact ring
- Closer opponent
- Limited movement
- Focus on technique

#### Recommended Space (3m × 3m)
- Full-size ring
- Proper distance
- Full movement
- Complete experience

#### Large Space (4m × 4m+)
- Expanded ring
- More movement room
- Advanced footwork
- Group training options

---

## 7. Spatial Gameplay Design

### 7.1 Spatial Zones

#### Comfort Zones for Vision Pro

```
Inner Zone (0.5m - 1.0m):
- UI elements
- Hand visualization
- Glove models
- Immediate feedback

Sweet Spot (1.0m - 2.5m):
- Opponent position
- Primary gameplay
- Combat interaction
- Visual focus

Outer Zone (2.5m - 4.0m):
- Environment
- Crowd/atmosphere
- Contextual elements
- Ambient details
```

### 7.2 Opponent Positioning

#### Dynamic Positioning System

```swift
class OpponentPositioner {
    // Keep opponent in optimal range
    let optimalDistance: Float = 2.0  // meters
    let minDistance: Float = 1.5
    let maxDistance: Float = 2.8

    func updatePosition(playerPosition: SIMD3<Float>) {
        // Maintain facing player
        // Stay within optimal range
        // Adapt to room boundaries
        // Circle and move naturally
    }
}
```

#### Movement Patterns

**Stationary Training:**
- Opponent stays in place
- Player can move freely
- Focus on technique

**Dynamic Sparring:**
- Opponent circles
- Advances and retreats
- Cuts angles
- Realistic footwork

**Aggressive Mode:**
- Constant forward pressure
- Backs player into corners (safely)
- Creates urgency

**Defensive Mode:**
- Opponent moves away
- Requires player to pursue
- Practice closing distance

### 7.3 Safety and Boundaries

#### Virtual Boundary System

**Visual Warnings:**
- Subtle glow appears at room edges
- Increases intensity as player approaches
- Different colors for different directions
- Non-intrusive during gameplay

**Haptic Feedback:**
- Gentle vibration near boundaries
- Stronger as player gets closer
- Directional feedback

**Automatic Positioning:**
- Opponent repositions to keep player centered
- Ring "moves" with player if needed
- Prevents player from leaving safe area

**Emergency Stop:**
- Raised hand gesture pauses game
- Voice command: "Stop" or "Pause"
- Automatic pause if boundary breached

### 7.4 Spatial Audio Design

#### Audio Sources Positioning

**Opponent:**
- Breathing (positional)
- Grunt on punches
- Impact sounds
- Movement sounds

**Environment:**
- Crowd from all directions
- Corner coach (behind player)
- Bell (specific location)
- Ambience (surrounding)

**Feedback:**
- Impact sounds (3D positioned)
- UI sounds (head-locked)
- Music (immersive, not head-locked)
- Coaching (positional or head-locked based on context)

---

## 8. UI/UX for Gaming

### 8.1 Menu System Design

#### Main Menu

```
┌─────────────────────────────────────────┐
│                                         │
│      SHADOW BOXING CHAMPIONS            │
│                                         │
│         ┌──────────────┐                │
│         │  START       │                │
│         ├──────────────┤                │
│         │  TRAINING    │                │
│         ├──────────────┤                │
│         │  TOURNAMENT  │                │
│         ├──────────────┤                │
│         │  PROFILE     │                │
│         ├──────────────┤                │
│         │  SETTINGS    │                │
│         └──────────────┘                │
│                                         │
│  [Level 23]  [Next: 2,450 XP]          │
└─────────────────────────────────────────┘
```

**Interaction:**
- Gaze + pinch to select
- Voice commands supported
- Hand ray pointer
- Spatial buttons (3D depth)

#### Mode Selection

```
TRAINING MODES:
┌─────────────┐  ┌─────────────┐  ┌─────────────┐
│  TECHNIQUE  │  │   FITNESS   │  │  SPARRING   │
│             │  │             │  │             │
│  [15 min]   │  │  [30 min]   │  │  [10 min]   │
│  [Medium]   │  │  [High]     │  │  [Variable] │
└─────────────┘  └─────────────┘  └─────────────┘
```

### 8.2 In-Game HUD

#### Minimalist HUD Design

```
    [◀ ROUND 2/3]                    [STAMINA: ████████░░]

                    [02:00]




                 [OPPONENT]
                 [████░░░░░░]




         [PLAYER: ██████████]


[COMBO: 4x]                              [SCORE: 145]
```

**HUD Elements:**
- Top left: Round indicator
- Top right: Stamina bar
- Top center: Round timer
- Center top: Opponent health
- Bottom center: Player health
- Bottom left: Combo counter
- Bottom right: Score

**Design Principles:**
- Minimal visual obstruction
- High contrast for readability
- Peripheral placement
- Fade during intense action
- Scale based on importance

### 8.3 Feedback Systems

#### Visual Feedback

**Punch Impact:**
- Flash on contact
- Particle burst
- Opponent reaction animation
- Screen shake (subtle)

**Damage Taken:**
- Red vignette flash
- Opponent glove trail visualization
- Health bar animation

**Combo Progress:**
- Growing combo meter
- Number display
- Color progression (white → yellow → orange → red)
- Trail effects on gloves

**Perfect Technique:**
- Golden glow on gloves
- "Perfect!" text
- Sparkle effects
- Bonus score popup

#### Haptic Feedback

**Punch Landed:**
- Quick pulse on hand
- Intensity based on power
- Different pattern per punch type

**Damage Taken:**
- Strong pulse
- Duration based on damage
- Directional if possible

**Low Stamina:**
- Rhythmic pulse pattern
- Increases as stamina drops
- Warning feeling

**Critical Moments:**
- Distinct pattern for:
  - Knockdown warning
  - Round ending
  - Victory/defeat

#### Audio Feedback

**Actions:**
- Whoosh on punch throw
- Impact sound on connection
- Miss sound (subtle whoosh)
- Block/parry sound

**Status:**
- Low stamina heartbeat
- Low health warning tone
- Combo milestone sound
- Achievement notification

**Coaching:**
- Encouragement on good performance
- Tips on mistakes
- Round-end summary
- Victory/defeat commentary

### 8.4 Results Screen

```
┌─────────────────────────────────────────┐
│         VICTORY!                        │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │  KNOCKOUT                        │   │
│  │  Round 2, 1:45                   │   │
│  └─────────────────────────────────┘   │
│                                         │
│  STATISTICS:                            │
│  • Punches Thrown: 87                   │
│  • Punches Landed: 52 (60%)             │
│  • Total Damage: 485                    │
│  • Technique Score: 87/100              │
│  • Combos: 12                           │
│  • Defense: 72%                         │
│                                         │
│  REWARDS:                               │
│  • XP Earned: +450                      │
│  • Rank: ↑ +25                          │
│  • Achievement: "First Knockout"        │
│                                         │
│  [Share]  [Rematch]  [Main Menu]       │
└─────────────────────────────────────────┘
```

### 8.5 Settings Interface

```
SETTINGS

GAMEPLAY:
├─ Difficulty: [Auto] [Easy] [Medium] [Hard] [Expert]
├─ Match Length: [Short] [Medium] [Long] [Custom]
├─ Training Guidance: [Full] [Hints] [Minimal] [Off]
└─ Auto-Pause: [On] [Off]

CONTROLS:
├─ Dominant Hand: [Right] [Left] [Both]
├─ Punch Sensitivity: ◀━━━━●━━━▶
├─ Voice Commands: [On] [Off]
└─ Gamepad Support: [On] [Off]

AUDIO:
├─ Master Volume: ◀━━━━━●━━▶
├─ Music Volume: ◀━━━●━━━━▶
├─ SFX Volume: ◀━━━━━━●━▶
├─ Voice Volume: ◀━━━━━●━━▶
└─ Spatial Audio: [On] [Off]

VISUALS:
├─ Graphics Quality: [Auto] [Low] [Medium] [High] [Ultra]
├─ Particle Effects: [Full] [Reduced] [Minimal]
├─ Crowd Detail: [Full] [Reduced] [Off]
└─ Motion Blur: [On] [Off]

FITNESS:
├─ HealthKit Sync: [On] [Off]
├─ Calorie Tracking: [On] [Off]
├─ Heart Rate Monitor: [On] [Off]
└─ Workout Intensity: [Light] [Moderate] [Intense]

ACCESSIBILITY:
├─ Colorblind Mode: [Off] [Protanopia] [Deuteranopia] [Tritanopia]
├─ Subtitle Size: [Small] [Medium] [Large]
├─ Haptic Intensity: ◀━━━●━━━━▶
└─ Comfort Mode: [On] [Off]
```

---

## 9. Visual Style Guide

### 9.1 Art Direction

#### Visual Pillars

**Realistic Foundation:**
- Authentic boxing aesthetic
- Physically accurate proportions
- Real-world materials
- Believable lighting

**Stylized Enhancement:**
- Slight exaggeration for clarity
- Enhanced visual feedback
- Cinematic effects
- Polished presentation

**Performance Optimized:**
- Efficient rendering
- Smart LOD usage
- Optimized effects
- Consistent frame rate

### 9.2 Color Palette

#### Primary Colors

```
Brand Red:     #E02020  - Gloves, accents, energy
Champion Gold: #FFD700  - Victory, achievements, excellence
Fighter Blue:  #2962FF  - Calm, training, interface
```

#### Neutral Colors

```
Dark Slate:    #1A1A1A  - Backgrounds, depth
Medium Gray:   #666666  - Secondary elements
Light Gray:    #CCCCCC  - Text, borders
Pure White:    #FFFFFF  - Highlights, important text
```

#### Status Colors

```
Health Green:  #4CAF50  - Full health, positive
Warning Orange:#FF9800  - Low stamina, caution
Danger Red:    #F44336  - Low health, critical
Perfect Gold:  #FFD54F  - Excellent technique
```

### 9.3 Character Design

#### Player Representation

**Virtual Gloves:**
- Realistic boxing glove model
- High-quality PBR materials
- Leather texture and stitching
- Player's chosen color
- Brand markings (subtle)
- Wear and tear over time (optional)

**Shadow Player (Optional):**
- Translucent representation
- Shows proper form
- Training mode only
- Ethereal, ghost-like
- Correct positioning guide

#### Opponent Design

**Visual Characteristics:**
- Realistic proportions
- Distinct appearances
- Varied body types
- Appropriate gear
- Animated facial expressions
- Damage visualization (bruising, swelling)

**Personality Through Design:**
- Aggressive: Muscular, forward stance
- Technical: Lean, precise movements
- Defensive: Balanced, calculated
- Brawler: Powerful, intimidating

### 9.4 Environment Art

#### Lighting

**Training Modes:**
- Natural, even lighting
- Focus on player and opponent
- Minimal shadows
- Clear visibility

**Competition Modes:**
- Dramatic spotlights
- Rim lighting on fighters
- Atmospheric beams
- Dynamic during action

**Atmosphere:**
- Warm tones for training
- Cool tones for technical
- Intense for competition
- Celebratory for victory

#### Materials

**Boxing Ring:**
- Canvas floor (roughness 0.7)
- Rope material (wrapped cloth)
- Corner pads (vinyl, slight shine)
- Posts (metal, painted)

**Equipment:**
- Leather gloves (worn, realistic)
- Heavy bags (canvas/leather)
- Speed bags (leather, shiny)
- Focus mitts (bright colors)

**Architecture:**
- Clean, professional spaces
- Appropriate wear and tear
- Believable materials
- Performance optimized

### 9.5 Visual Effects

#### Impact Effects

**Punch Connection:**
```
Duration: 0.1-0.2 seconds

Elements:
- Burst of particles (sweat droplets)
- Flash of light
- Ripple effect on target
- Motion blur on glove
- Slight camera shake (< 2 pixels)
```

**Critical Hit:**
```
Duration: 0.3 seconds

Elements:
- Larger particle burst
- Bright flash (golden)
- Slow-motion (0.5x speed)
- Enhanced sound
- Screen effect
```

**Block/Parry:**
```
Duration: 0.15 seconds

Elements:
- Spark-like particles
- Deflection visual
- Small light flash
- Defensive sound
```

#### Status Effects

**Low Stamina:**
- Heavy breathing particles
- Sweat dripping
- Slight blur at edges
- Slowed movement visualization

**Low Health:**
- Red vignette (pulsing)
- Vision slight blur
- Increased damage effects
- Unstable footing visualization

**Perfect Form:**
- Golden glow on gloves
- Trail effects
- Sparkles
- Enhanced impact

---

## 10. Audio Design

### 10.1 Audio Pillars

1. **Spatial Authenticity**: Sounds come from correct positions
2. **Responsive Feedback**: Immediate audio response to actions
3. **Atmospheric Immersion**: Believable environment sounds
4. **Dynamic Intensity**: Audio adapts to gameplay state

### 10.2 Sound Categories

#### Combat Sounds

**Punch Throws:**
- Whoosh (varies by punch type)
- Cloth/glove friction
- Air displacement
- Intensity matches speed

**Punch Impacts:**
- Body hits (thud, deeper)
- Face hits (sharper, higher)
- Glove-on-glove (block sound)
- Power variation (quieter to louder)

**Miss Sounds:**
- Subtle whoosh
- Near-miss has slight impact
- Empty air sound

**Movement:**
- Footwork (subtle)
- Weight shifts
- Breathing (positional)
- Body movement

#### Environmental Sounds

**Crowd:**
```
Layers:
- Base ambience (constant murmur)
- Reactions (to action)
  - Gasp (near miss)
  - Cheer (good hit)
  - Groan (damage taken)
  - Roar (knockdown)
- Spatial positioning (surround)
```

**Venue:**
- Bell (round start/end)
- Announcer (introduction, decision)
- Corner coach (between rounds)
- Equipment sounds (if visible)

**Atmospheric:**
- Room tone (subtle)
- Air conditioning (venues)
- Distant activity
- Spatial reverb

#### Music System

**Layered Music Approach:**

```
Training Mode:
Layer 1: Ambient pad (always)
Layer 2: Light percussion (moderate intensity)
Layer 3: Melody (high intensity)
Layer 4: Bass (peak intensity)

Match Mode:
Layer 1: Tension strings
Layer 2: Rising percussion
Layer 3: Full drums
Layer 4: Orchestral hits
```

**Dynamic Mixing:**
- Layers fade in/out based on:
  - Match intensity
  - Player performance
  - Round time remaining
  - Health status
- Smooth crossfades (2-3 seconds)

#### UI Sounds

**Menu Navigation:**
- Hover/highlight (subtle)
- Select (satisfying click)
- Back (different tone)
- Error (gentle warning)

**Feedback:**
- Achievement unlock (triumphant)
- Level up (exciting)
- Reward earned (positive)
- Milestone (celebratory)

**Coaching Voice:**
- Encouragement phrases
- Technique tips
- Strategy advice
- Round summaries
- Natural, motivational tone

### 10.3 Spatial Audio Implementation

#### Distance Attenuation

```
0-2m:    Full volume, clear
2-5m:    Gradual falloff
5-10m:   Reduced, ambient
10m+:    Very quiet, background
```

#### Occlusion

- Opponent behind objects: Muffled
- Environmental sounds: Natural occlusion
- Dynamic based on position

#### Reverb Zones

**Small Gym:**
- Short reverb tail
- Intimate feel
- Clear sounds

**Large Arena:**
- Long reverb tail
- Spacious feel
- Crowd echo

### 10.4 Audio Accessibility

**Visual Indicators:**
- Subtitle for coaching voice
- Impact direction indicators
- Sound wave visualizations (optional)

**Adjustable:**
- Individual volume sliders
- Balance between categories
- Mono option (if needed)

**Hearing Impaired:**
- Enhanced visual feedback
- Haptic emphasis
- Clear visual cues replace audio

---

## 11. Accessibility Features

### 11.1 Vision Accessibility

#### Colorblind Modes

**Protanopia (Red-blind):**
- Red → Blue adjustments
- Health bar → Blue to Yellow
- Danger → Orange highlights

**Deuteranopia (Green-blind):**
- Green → Blue adjustments
- Similar to Protanopia

**Tritanopia (Blue-blind):**
- Blue → Red adjustments
- Alternative color schemes

**High Contrast Mode:**
- Increased contrast ratios
- Darker backgrounds
- Brighter text and important elements
- Simplified visual effects

#### Visual Clarity

**Text Sizing:**
- Small (default)
- Medium (+25%)
- Large (+50%)
- Extra Large (+100%)

**Visual Simplification:**
- Reduce particle effects
- Minimize motion blur
- Disable screen shake
- Simpler backgrounds

### 11.2 Hearing Accessibility

**Subtitle Options:**
- All dialogue subtitled
- Sound effect descriptions
- Directional indicators
- Environmental sounds noted
- Music lyrics (if applicable)

**Visual Sound Indicators:**
- Punch impact direction arrows
- Opponent audio cues (visual)
- Warning sounds (visual)

**Haptic Emphasis:**
- Stronger haptics for audio cues
- Varied patterns for different sounds
- Directional haptic feedback

### 11.3 Motor Accessibility

**Control Adjustments:**

**Punch Sensitivity:**
- Very Low: Large movements required
- Low: Normal movements
- Medium (default)
- High: Small movements register
- Very High: Minimal movement needed

**Punch Speed Requirements:**
- Slow: More time to execute
- Normal (default)
- Fast: Quick reactions needed

**Alternative Control:**
- Gamepad support
- Voice commands for actions
- Seated mode (no footwork required)
- One-handed mode

**Assist Options:**
- Auto-block (when stamina low)
- Punch aim assist
- Simplified combos
- Extended input windows

### 11.4 Cognitive Accessibility

**Complexity Options:**

**Simplified Mode:**
- Reduced opponent variety
- Clearer attack patterns
- More telegraph time
- Simpler combos

**Tutorial Options:**
- Repeatable any time
- Step-by-step breakdowns
- Practice mode (no pressure)
- Video demonstrations

**Information Display:**
- Clear, concise instructions
- Visual + audio + text
- Adjustable notification speed
- Pauseable tutorials

### 11.5 Physical Accessibility

**Comfort Features:**

**Intensity Options:**
- Very Light (minimal movement)
- Light (reduced intensity)
- Moderate (default)
- High (full intensity)
- Custom (player defined)

**Session Management:**
- Mandatory rest periods
- Customizable break frequency
- Sitting/standing options
- Reduced play area option

**Motion Sickness Prevention:**
- Stable camera (no rotation)
- Static reference points
- Vignette during movement
- Reduced visual effects
- Comfort mode (extra stability)

---

## 12. Tutorial and Onboarding

### 12.1 First-Time User Experience

#### Initial Setup (2-3 minutes)

```
Step 1: Welcome
- Brief introduction
- Set expectations
- Explain spatial nature

Step 2: Space Calibration
- Scan play area
- Establish boundaries
- Test movement

Step 3: Hand Tracking
- Calibrate hand detection
- Test fist recognition
- Verify accuracy

Step 4: Comfort Check
- Set intensity level
- Choose standing/sitting
- Adjust settings
```

#### Basic Tutorial (5-7 minutes)

```
Module 1: Your First Punch (1 min)
- Make a fist
- Throw a jab
- See impact
- Success!

Module 2: Punch Types (2 min)
- Jab (quick, straight)
- Cross (power, straight)
- Hook (side punch)
- Uppercut (rising punch)
- Practice each 3 times

Module 3: Defense (2 min)
- Blocking (hands up)
- Ducking (crouch)
- Slipping (side movement)
- Practice avoiding punches

Module 4: Your First Match (2 min)
- Ultra-easy opponent
- Guided instructions
- Cannot lose
- Build confidence
```

### 12.2 Progressive Learning

#### Beginner Phase (Levels 1-5)

**Skills Introduced:**
- Basic punch types
- Simple defense
- Stamina management
- Basic combos (2-3 punches)

**Learning Aids:**
- Constant coaching
- Visual guides
- Slow opponents
- Frequent feedback

#### Intermediate Phase (Levels 6-15)

**Skills Introduced:**
- Advanced combos
- Counter-punching
- Movement and spacing
- Strategic thinking

**Learning Aids:**
- Situational tips
- Replay analysis
- Varied opponents
- Performance feedback

#### Advanced Phase (Levels 16-30)

**Skills Introduced:**
- Fighting styles
- Adaptation strategies
- Advanced footwork
- Psychological tactics

**Learning Aids:**
- High-level tips
- Opponent weaknesses revealed
- Strategy suggestions
- Detailed analytics

#### Expert Phase (Levels 31+)

**Skills Introduced:**
- Mastery techniques
- Perfect execution
- Championship strategies
- Teaching others

**Learning Aids:**
- Minimal guidance
- Performance analytics
- Comparative stats
- Community features

### 12.3 Contextual Help

#### In-Game Tutorials

**Triggered by:**
- New game mode first access
- Struggling with concept (3 failures)
- Specific situations
- Player request

**Format:**
- Brief overlay
- Voice explanation
- Visual demonstration
- Practice opportunity
- Optional skip

**Examples:**

"You're throwing arm punches. Remember to rotate your hips for more power. Let's practice..."

"That opponent counters jabs. Try mixing in crosses and hooks. Watch..."

"Your stamina is low. Focus on defense and let it recover. Like this..."

### 12.4 Help System

#### In-Game Help Menu

```
HELP TOPICS:

Basic Controls
├─ Throwing Punches
├─ Defensive Moves
├─ Movement
└─ Stamina Management

Game Modes
├─ Training
├─ Sparring
├─ Tournaments
└─ Daily Challenges

Advanced Techniques
├─ Combinations
├─ Counter-Punching
├─ Fighting Styles
└─ Strategy

Progression
├─ Experience & Levels
├─ Skill Trees
├─ Unlockables
└─ Achievements

Settings & Options
└─ Accessibility
```

**Each Topic Includes:**
- Text explanation
- Visual demonstration
- Practice option
- Related topics
- Video tutorial (if complex)

---

## 13. Difficulty Balancing

### 13.1 Difficulty Dimensions

#### Opponent Stats Scaling

| Difficulty | Health | Damage | Speed | Defense | Stamina | Reaction |
|------------|--------|--------|-------|---------|---------|----------|
| Very Easy  | 50%    | 50%    | 60%   | 40%     | 70%     | 400ms    |
| Easy       | 70%    | 70%    | 75%   | 60%     | 85%     | 300ms    |
| Medium     | 100%   | 100%   | 100%  | 100%    | 100%    | 200ms    |
| Hard       | 130%   | 120%   | 120%  | 120%    | 120%    | 150ms    |
| Expert     | 160%   | 140%   | 140%  | 150%    | 150%    | 100ms    |
| Master     | 200%   | 160%   | 160%  | 180%    | 180%    | 75ms     |

#### AI Behavior Complexity

**Very Easy:**
- Telegraphed attacks
- Predictable patterns
- Slow reactions
- Rarely combos
- Poor defense

**Easy:**
- Some variation
- Basic patterns
- Normal reactions
- Simple combos (2-3)
- Basic defense

**Medium:**
- Good variation
- Adaptive patterns
- Quick reactions
- Medium combos (3-4)
- Solid defense

**Hard:**
- High variation
- Learning patterns
- Very quick reactions
- Complex combos (4-5)
- Strong defense

**Expert:**
- Maximum variation
- Counter-learning
- Instant reactions
- Advanced combos (5-6)
- Excellent defense

**Master:**
- Unpredictable
- Pattern exploitation
- Inhuman reactions
- Master combos (6+)
- Perfect defense

### 13.2 Dynamic Difficulty Adjustment (DDA)

#### Performance Tracking

```swift
struct PerformanceMetrics {
    var winRate: Float         // Last 10 matches
    var averageRoundTime: Float
    var damageRatio: Float     // Dealt vs. taken
    var comboSuccess: Float
    var defenseRate: Float

    var difficultyScore: Float {
        // Composite score 0-1
        (winRate * 0.3 +
         damageRatio * 0.3 +
         comboSuccess * 0.2 +
         defenseRate * 0.2)
    }
}
```

#### Adjustment System

**When to Adjust:**
- After every match
- Gradual changes only
- Player can override
- More responsive in early game

**How Much:**
```
If difficultyScore > 0.8:  // Player dominating
    Increase difficulty by 5%

If difficultyScore < 0.3:  // Player struggling
    Decrease difficulty by 5%

If difficultyScore 0.4-0.7:  // Sweet spot
    Maintain difficulty
```

**Limits:**
- Maximum 1 tier adjustment per session
- Minimum 3 matches before adjustment
- Player-selected difficulty is floor
- Explicit notification of changes

### 13.3 Skill-Based Matchmaking (Multiplayer)

#### Rating System

**ELO-based:**
```
Starting Rating: 1200

After Match:
Winner: +K * (1 - expectedScore)
Loser:  -K * expectedScore

Where:
K = 32 (high volatility for new players)
K = 16 (moderate for intermediate)
K = 8 (low for experienced)

expectedScore = 1 / (1 + 10^((opponentRating - yourRating) / 400))
```

#### Matchmaking Tiers

| Tier | Rating Range | Population % |
|------|--------------|--------------|
| Bronze | 0-999 | 15% |
| Silver | 1000-1199 | 25% |
| Gold | 1200-1399 | 30% |
| Platinum | 1400-1599 | 20% |
| Diamond | 1600-1799 | 8% |
| Champion | 1800+ | 2% |

#### Match Search Parameters

```
Ideal: ±50 rating
Acceptable: ±100 rating (after 30s)
Desperate: ±200 rating (after 60s)
Last Resort: Anyone (after 90s)

Factor in:
- Connection quality
- Geographic proximity
- Time of day
- Previous matches
```

### 13.4 Accessibility Difficulty

**Separate from Challenge:**
- Accessibility ≠ easier
- Removes barriers
- Maintains challenge
- Respects player ability

**Examples:**
- Seated mode doesn't reduce difficulty
- Increased contrast doesn't reduce challenge
- Subtitles don't make easier
- Longer input windows ≠ easier opponents

---

## Conclusion

This design document provides comprehensive guidance for creating Shadow Boxing Champions - a revolutionary boxing training and competition game for Vision Pro that:

- **Engages** players with compelling gameplay loops
- **Challenges** appropriately across all skill levels
- **Teaches** real boxing techniques professionally
- **Immerses** through spatial computing
- **Includes** all players through accessibility
- **Motivates** continued play through progression

**Design Success Criteria:**
- 85%+ player satisfaction
- 30+ minute average session
- 75%+ 3-month retention
- 4.5+ star rating
- 90%+ tutorial completion

The design balances fun, fitness, and authentic boxing training to create an experience that's engaging for gamers and valuable for athletes.

Refer to ARCHITECTURE.md and TECHNICAL_SPEC.md for implementation details.
