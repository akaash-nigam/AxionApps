# Reality Realms RPG - Design Document

## Table of Contents
- [Game Design Document Elements](#game-design-document-elements)
- [Core Gameplay Loop](#core-gameplay-loop)
- [Player Progression Systems](#player-progression-systems)
- [Level Design Principles](#level-design-principles)
- [Spatial Gameplay Design](#spatial-gameplay-design)
- [UI/UX for Gaming](#uiux-for-gaming)
- [Visual Style Guide](#visual-style-guide)
- [Audio Design](#audio-design)
- [Accessibility](#accessibility)
- [Tutorial and Onboarding](#tutorial-and-onboarding)
- [Difficulty Balancing](#difficulty-balancing)

---

## Game Design Document Elements

### High Concept

**Reality Realms** is a persistent mixed reality RPG that transforms your home into a living fantasy world. Every room becomes a unique realm, furniture affects tactical combat, and virtual characters remember their place in your space.

### Design Pillars

1. **Spatial Persistence**: Your home IS the game world
2. **Natural Interaction**: Sword swings, spell casting, physical dodging
3. **Adaptive Gameplay**: Game adapts to YOUR unique home layout
4. **Living World**: NPCs have schedules, pets explore autonomously
5. **Comfort First**: Extended play without fatigue or motion sickness

### Core Experience Goals

- **Immersion**: Feel like your home has become magical
- **Ownership**: This is YOUR unique realm, unlike anyone else's
- **Discovery**: Daily surprises and secrets in familiar spaces
- **Mastery**: Improve combat skills through practice
- **Connection**: Share your realm with friends remotely

---

## Core Gameplay Loop

### Minute-to-Minute Loop (Combat Encounter)

```
┌─────────────────────────────────────────────────────┐
│  1. Detect Enemy (via portal or patrol)             │
│     ↓                                               │
│  2. Position Behind Furniture (tactical cover)      │
│     ↓                                               │
│  3. Engage with Gesture Combat                      │
│     ↓                                               │
│  4. Defeat Enemy & Collect Loot                     │
│     ↓                                               │
│  5. Experience Gained → Progress Bar Fills          │
└─────────────────────────────────────────────────────┘
```

### Hour-to-Hour Loop (Gameplay Session)

```
┌─────────────────────────────────────────────────────┐
│  1. Enter Home → See What Happened Overnight         │
│     - Pet found items                               │
│     - NPCs moved around                             │
│     - New portal appeared                           │
│     ↓                                               │
│  2. Check Daily Quest Board                         │
│     - Accept 3 daily quests                         │
│     ↓                                               │
│  3. Explore Rooms for Quests                        │
│     - Living room: Defend invasion                  │
│     - Kitchen: Brew potions                         │
│     - Bedroom: Enter dream portal                   │
│     ↓                                               │
│  4. Complete Quests & Get Rewards                   │
│     ↓                                               │
│  5. Visit Friend's Realm for Co-op                  │
│     ↓                                               │
│  6. Upgrade Equipment & Skills                      │
└─────────────────────────────────────────────────────┘
```

### Day-to-Day Loop (Long-Term Progression)

```
┌─────────────────────────────────────────────────────┐
│  Day 1: Unlock Living Room Realm                    │
│  Day 3: Unlock Kitchen Alchemy Lab                  │
│  Day 7: First Companion Pet Hatches                 │
│  Day 14: Join a Guild                               │
│  Day 21: Unlock Multiplayer Raids                   │
│  Day 30: Master Your First Class                    │
│  Day 60: Unlock Advanced Classes                    │
│  Day 90: Host Your First Raid                       │
└─────────────────────────────────────────────────────┘
```

### Engagement Loops

#### Discovery Loop
**Goal**: Keep players curious about their space

- **Morning Surprises**: Log in to see what pet discovered
- **Hidden Secrets**: Furniture-specific quests unlock randomly
- **Seasonal Changes**: Realms transform with real seasons
- **Room Evolution**: Home becomes more magical over time

#### Mastery Loop
**Goal**: Improve player skill and build competence

- **Combo Training**: Practice perfect gesture sequences
- **Combat Scoring**: Rate combat performance (D to S rank)
- **Challenge Modes**: Harder versions of completed quests
- **Leaderboards**: Compare scores with friends

#### Collection Loop
**Goal**: Satisfy completionist players

- **Creature Collection**: Catch and house 100+ pet types
- **Equipment Sets**: Collect themed armor sets
- **Achievement Hunting**: 200+ achievements
- **Realm Decoration**: Unlock visual themes and decorations

---

## Player Progression Systems

### Character Classes

#### Warrior
```yaml
class: Warrior
tagline: "The Blade of Your Realm"
primary_stat: Strength
weapons: Swords, Axes, Shields
playstyle: Melee combat, high defense

starting_stats:
  health: 120
  mana: 50
  strength: 15
  intelligence: 5
  defense: 12

signature_abilities:
  - whirlwind_attack: Spin 360° to hit all nearby enemies
  - shield_bash: Stun enemies with shield slam
  - battle_cry: Buff nearby allies
  - berserker_rage: Increase damage when health low

skill_tree_paths:
  - tank: Focus on defense and protection
  - damage_dealer: Focus on high damage output
  - duelist: Focus on 1v1 combat mastery
```

#### Mage
```yaml
class: Mage
tagline: "Wielder of Arcane Power"
primary_stat: Intelligence
weapons: Staffs, Wands
playstyle: Ranged magic, crowd control

starting_stats:
  health: 80
  mana: 150
  strength: 5
  intelligence: 18
  defense: 6

signature_abilities:
  - fireball: High damage projectile
  - ice_wall: Create barrier from furniture
  - lightning_chain: Hits multiple enemies
  - teleport: Short-range blink movement

skill_tree_paths:
  - pyromancer: Fire specialization
  - cryomancer: Ice specialization
  - storm_caller: Lightning specialization
```

#### Rogue
```yaml
class: Rogue
tagline: "Shadow in Your Living Room"
primary_stat: Dexterity
weapons: Daggers, Bows
playstyle: Stealth, critical hits

starting_stats:
  health: 90
  mana: 80
  strength: 8
  intelligence: 10
  defense: 7

signature_abilities:
  - stealth: Become invisible behind furniture
  - backstab: Massive damage from behind
  - poison_blade: Damage over time
  - shadow_step: Teleport behind enemy

skill_tree_paths:
  - assassin: Focus on burst damage
  - archer: Focus on ranged combat
  - shadow_dancer: Focus on mobility
```

#### Ranger
```yaml
class: Ranger
tagline: "Guardian of the Wild Spaces"
primary_stat: Dexterity
weapons: Bows, Crossbows, Traps
playstyle: Ranged, pet companion

starting_stats:
  health: 100
  mana: 100
  strength: 10
  intelligence: 12
  defense: 9

signature_abilities:
  - multi_shot: Fire at multiple enemies
  - pet_command: Direct companion to attack
  - trap_setup: Place traps on furniture
  - mark_target: Increase damage on enemy

skill_tree_paths:
  - beast_master: Enhanced pet abilities
  - sniper: Long-range damage
  - trap_specialist: Area control
```

### Leveling System

```swift
// Experience curve
func calculateXPForLevel(_ level: Int) -> Int {
    return Int(100 * pow(Double(level), 1.5))
}

// Level milestones
let levelMilestones: [Int: Rewards] = [
    5: .unlockSkillSlot,
    10: .unlockPetSlot,
    15: .unlockSecondRoom,
    20: .unlockAdvancedClass,
    25: .unlockMounting,
    30: .unlockRaidAccess,
    40: .unlockLegendaryQuests,
    50: .maxLevel
]
```

### Equipment System

```yaml
equipment_slots:
  weapon: Primary damage source
  offhand: Shield or secondary weapon
  helmet: Head protection
  chest: Torso protection
  gloves: Hand protection
  legs: Leg protection
  boots: Foot protection
  accessory_1: Ring, amulet, etc.
  accessory_2: Second accessory
  pet: Companion creature

item_rarities:
  common:
    color: gray
    drop_rate: 60%
    stat_bonus: 1x

  uncommon:
    color: green
    drop_rate: 25%
    stat_bonus: 1.5x

  rare:
    color: blue
    drop_rate: 10%
    stat_bonus: 2x

  epic:
    color: purple
    drop_rate: 4%
    stat_bonus: 3x

  legendary:
    color: orange
    drop_rate: 1%
    stat_bonus: 5x
    special_effect: yes
```

---

## Level Design Principles

### Room-Based Level Design

Each room type has unique gameplay characteristics:

#### Living Room → Throne Room
```yaml
theme: Royal Battle Arena
size: Large (3m x 4m typical)
gameplay_focus: Large-scale combat

furniture_utilization:
  couch:
    gameplay: Cover during ranged combat
    interaction: Sit to restore health faster
    quest_hook: "Defend Your Throne"

  tv_stand:
    gameplay: High ground advantage
    interaction: Place trophies
    quest_hook: "Portal appears on screen"

  coffee_table:
    gameplay: Strategic chokepoint
    interaction: Trading post
    quest_hook: "Merchant visits daily"

enemy_types:
  - armored_knights
  - siege_creatures
  - rival_guardians

events:
  - throne_defense: Wave-based combat
  - royal_court: NPC visitors
  - guild_meetings: Multiplayer hub
```

#### Kitchen → Alchemy Lab
```yaml
theme: Potion Brewing & Crafting
size: Medium (2.5m x 3m typical)
gameplay_focus: Crafting and resource management

furniture_utilization:
  counter:
    gameplay: Potion brewing station
    interaction: Craft consumables
    quest_hook: "Recipe discovery"

  fridge:
    gameplay: Ingredient storage
    interaction: Organize materials
    quest_hook: "Rare ingredient appears"

  stove:
    gameplay: Heating elements for potions
    interaction: Cook ingredients
    quest_hook: "Fire elemental visits"

  sink:
    gameplay: Water source for potions
    interaction: Clean equipment
    quest_hook: "Water spirit quest"

minigames:
  - potion_mixing: Gesture-based brewing
  - ingredient_hunting: Find hidden items
  - recipe_discovery: Experiment with combinations
```

#### Bedroom → Restoration Chamber
```yaml
theme: Rest and Dream Exploration
size: Medium (3m x 3m typical)
gameplay_focus: Healing and dream portals

furniture_utilization:
  bed:
    gameplay: Full heal and save point
    interaction: Sleep to enter dreams
    quest_hook: "Dream portal access"

  closet:
    gameplay: Equipment storage
    interaction: Change appearance
    quest_hook: "Hidden passage"

  nightstand:
    gameplay: Quick item access
    interaction: Place active items
    quest_hook: "Bedtime story quest"

dream_mechanics:
  - dream_portals: Access special realms
  - nightmare_mode: Harder combat variants
  - lucid_dreaming: Control environment
```

### Procedural Adaptation

The game adapts to any home layout:

```swift
struct RoomAdaptation {
    // Small room (< 2m x 2m)
    func adaptForSmallSpace(_ room: Room) -> GameplayModifications {
        return GameplayModifications(
            enemyCount: .reduced(by: 0.5),
            combatStyle: .tactical,  // More strategic, less running
            spawnLocations: .frontalOnly,  // No rear attacks
            difficultyCompensation: .increasedEnemyHealth
        )
    }

    // Large room (> 4m x 4m)
    func adaptForLargeSpace(_ room: Room) -> GameplayModifications {
        return GameplayModifications(
            enemyCount: .increased(by: 1.5),
            combatStyle: .mobile,  // Encourage movement
            spawnLocations: .surrounding,  // 360° threats
            specialEvents: .bossEncounters
        )
    }

    // Unusual layouts
    func adaptForLayout(_ layout: RoomLayout) -> GameplayModifications {
        if layout.hasLShape {
            return .ambushOpportunities  // Use corners
        } else if layout.hasMultipleLevels {
            return .verticalCombat  // Stairs, platforms
        } else if layout.hasNarrowCorridors {
            return .chokepointDefense  // Tower defense style
        }
    }
}
```

---

## Spatial Gameplay Design

### Furniture-as-Gameplay Mechanics

Every furniture type has gameplay implications:

```yaml
furniture_gameplay_matrix:
  couch:
    tactical: Provides cover from projectiles
    strategic: Regeneration zone when sitting
    interactive: Summons friendly NPCs
    secret: Coins fall between cushions

  table:
    tactical: Chokepoint for enemy pathing
    strategic: Trading and crafting surface
    interactive: Place items for display
    secret: Hollow legs contain loot

  chair:
    tactical: Throwable object (Ranger ability)
    strategic: Meditation spot (mana regen)
    interactive: Sit for dialogue scenes
    secret: Check underneath for items

  bookshelf:
    tactical: Climbable high ground
    strategic: Spell research location
    interactive: Read books for lore
    secret: Secret passages behind books

  bed:
    tactical: Full cover from all sides
    strategic: Healing and save point
    interactive: Dream portal access
    secret: Under bed monster encounters

  desk:
    tactical: Elevated firing position
    strategic: Quest planning interface
    interactive: Write in journal
    secret: Locked drawers need keys
```

### Combat Spatial Design

#### Zone Control

```
┌─────────────────────────────────────────┐
│                                         │
│    [Enemy]     [Enemy]     [Enemy]      │
│                                         │
│         ┌───────────────┐               │
│         │     COUCH     │←─ COVER       │
│         │   (Furniture) │               │
│         └───────────────┘               │
│                                         │
│           ╭───────╮                     │
│           │ Player│←─ SAFE ZONE         │
│           ╰───────╯                     │
│                                         │
│    [Loot]    [Loot]    [Portal]         │
│                                         │
└─────────────────────────────────────────┘

Combat Flow:
1. Player uses couch for cover
2. Peek out to attack with bow
3. Enemies try to flank around furniture
4. Player dodges physically
5. Collect loot when enemies defeated
```

#### Environmental Hazards

```yaml
dynamic_environment:
  breakable_objects:
    vases: Break for health potions
    windows: Environmental damage zone
    decorations: Scatter for area denial

  interactive_elements:
    light_switches: Create darkness zones
    doors: Create choke points
    curtains: Provide temporary cover

  magical_modifications:
    furniture_enchantment: Glow with power
    portal_effects: Swirling energy
    combat_residue: Scorch marks, ice patches
```

---

## UI/UX for Gaming

### Spatial UI Philosophy

**Diegetic First**: UI elements exist in the game world

```yaml
diegetic_ui:
  health_display:
    location: Floating crystal near left wrist
    interaction: Glance to see exact number
    design: Pulsing red energy

  mana_display:
    location: Floating crystal near right wrist
    interaction: Glance to see exact number
    design: Pulsing blue energy

  quest_log:
    location: Magical tome on hip
    interaction: Grab gesture to open
    design: Leather-bound book with pages

  inventory:
    location: Backpack over shoulder
    interaction: Reach behind to access
    design: Spatial grid of items

  map:
    location: Projected from palm
    interaction: Look at hand, palm up
    design: Holographic room layout

  minimap:
    location: Projected on nearby wall
    interaction: Always visible, updates real-time
    design: 2D top-down view
```

### HUD Design

```
┌─────────────────────────────────────────────────────┐
│                   Top Center                        │
│              ┌─────────────────┐                    │
│              │  QUEST TRACKER  │                    │
│              │  • Defeat 5/10  │                    │
│              └─────────────────┘                    │
│                                                     │
│  Left Wrist            Center           Right Wrist│
│  ╭────────╮                            ╭────────╮  │
│  │ HEALTH │                            │  MANA  │  │
│  │  ████  │                            │  ████  │  │
│  ╰────────╯                            ╰────────╯  │
│                                                     │
│                                                     │
│               [Enemy Health Bars]                   │
│           Float above enemy heads                   │
│                                                     │
│                                                     │
│  Bottom Center                                      │
│  ┌─────────────────────────────────┐               │
│  │  Active Spell    Cooldowns      │               │
│  │   [FIRE] 2s    [ICE] Ready      │               │
│  └─────────────────────────────────┘               │
└─────────────────────────────────────────────────────┘
```

### Menu System

```yaml
main_menu:
  location: Floating in center of room
  appearance: Magical portal with options
  navigation: Gaze + pinch
  options:
    - continue_adventure
    - character_screen
    - inventory
    - skills
    - quests
    - social
    - settings
    - exit

character_screen:
  layout: Full 3D character model in front
  rotation: Swipe to rotate
  stats: Floating panels around character
  equipment: Drag items onto body parts
  appearance: Real-time preview

inventory:
  layout: 3D grid in space
  organization: Auto-sort by type
  interaction: Grab items to examine
  details: Hover for stats comparison
  capacity: 50 slots (expandable)
```

### Tutorial UI

```yaml
tutorial_prompts:
  style: Glowing arrows and outlines
  frequency: Only when needed
  dismissal: Automatic after completion
  replay: Available in help menu

  examples:
    - gesture_guide: "Swipe hand to slash"
    - gaze_target: "Look at enemy to lock on"
    - furniture_hint: "Hide behind couch for cover"
    - quest_marker: "Portal glows when quest ready"
```

---

## Visual Style Guide

### Art Direction

**Fantasy Realism with Magical Accents**

```yaml
visual_philosophy:
  realism_level: 70%  # Grounded but fantastical
  color_palette: Rich, saturated fantasy colors
  lighting: Dramatic, magical glow
  effects: Prominent but not overwhelming

art_style:
  characters:
    style: Semi-realistic with stylized proportions
    detail_level: High polygon for main characters
    animation: Motion-captured for realism
    effects: Magical auras and particle trails

  environments:
    real_world: Passthrough with magical overlays
    portals: Swirling energy vortexes
    realm_overlay: Translucent fantasy architecture
    lighting: Dynamic magical light sources

  effects:
    magic: Bright, colorful particle systems
    combat: Impact sparks, slash trails
    environment: Ambient magical particles
    ui: Holographic glows
```

### Color Coding

```yaml
color_system:
  player_team:
    primary: Blue
    accent: Gold
    glow: Cyan

  enemies:
    common: Red
    rare: Purple
    boss: Orange with black

  items:
    common: White
    uncommon: Green
    rare: Blue
    epic: Purple
    legendary: Orange

  elements:
    fire: Red-orange
    ice: Cyan-blue
    lightning: Yellow-white
    nature: Green
    shadow: Purple-black
    arcane: Pink-purple

  ui_states:
    normal: White
    highlight: Yellow
    selected: Green
    disabled: Gray
    danger: Red
    success: Green
```

### Animation Principles

```yaml
animation_guidelines:
  combat:
    anticipation: Clear wind-up before attacks
    follow_through: Realistic weight and momentum
    impact: Strong hit feedback with pause frames
    recovery: Clear vulnerable window

  magic:
    casting: Dramatic build-up with particles
    release: Burst of energy
    travel: Trail effects
    impact: Explosion or freeze effect

  character:
    idle: Subtle breathing, looking around
    movement: Realistic footsteps
    hit_reaction: Directional knockback
    death: Ragdoll physics

  ui:
    transitions: Smooth 300ms animations
    feedback: Immediate visual response
    highlights: Pulse or glow
    notifications: Slide in from top
```

---

## Audio Design

### Music System

```yaml
adaptive_music:
  exploration:
    tempo: 80-100 BPM
    instruments:
      - Strings (violins, cellos)
      - Woodwinds (flutes, clarinets)
      - Light percussion
    mood: Wonder, curiosity, calm
    variations: 4 tracks that blend

  combat:
    tempo: 120-140 BPM
    instruments:
      - Full orchestra
      - Heavy percussion (drums, timpani)
      - Brass (trumpets, horns)
    mood: Intense, urgent, heroic
    variations: Scales with danger

  boss_battle:
    tempo: 140-160 BPM
    instruments:
      - Full orchestra
      - Choir
      - Epic percussion
    mood: Epic, dramatic, challenging
    variations: Phase-based

  victory:
    tempo: 100-120 BPM
    instruments:
      - Fanfare brass
      - Bells
      - Celebratory strings
    mood: Triumphant, uplifting
    duration: 15 seconds

  ambient:
    tempo: None (atmospheric)
    instruments:
      - Pads
      - Nature sounds
      - Magical chimes
    mood: Peaceful, mysterious
    variations: Room-specific
```

### Sound Effects

```yaml
combat_sfx:
  sword_swing:
    sound: Whoosh with metal shimmer
    variation: 5 different swings
    spatialization: 3D positioned at blade

  sword_hit:
    sound: Metallic clang + flesh impact
    variation: Different for armor/flesh
    spatialization: At impact point

  spell_cast:
    sound: Magical build-up + release
    variation: Element-specific
    spatialization: Emanates from hands

  damage_taken:
    sound: Impact grunt
    variation: Gender and race specific
    spatialization: At player position

environment_sfx:
  footsteps:
    sound: Material-specific
    variation: Walking vs running
    spatialization: At player feet

  furniture_interaction:
    sound: Wood creak, metal clink
    variation: Furniture-specific
    spatialization: At furniture position

  portal:
    sound: Magical hum and swirl
    variation: Opening vs closing
    spatialization: At portal location

ui_sfx:
  menu_navigate:
    sound: Subtle magical chime
    variation: Up vs down pitch

  item_pickup:
    sound: Satisfying "pop" + jingle
    variation: Rarity-based pitch

  quest_complete:
    sound: Triumphant fanfare
    variation: Major vs minor quests

  level_up:
    sound: Epic crescendo
    variation: None (iconic)
```

### Spatial Audio

```yaml
3d_audio_configuration:
  max_simultaneous_sounds: 32
  distance_attenuation:
    reference: 1 meter
    maximum: 50 meters
    rolloff: Logarithmic

  reverb_zones:
    small_room:
      reverb_time: 0.3s
      early_reflections: High
      use: Bedroom, bathroom

    medium_room:
      reverb_time: 0.6s
      early_reflections: Medium
      use: Living room, kitchen

    large_space:
      reverb_time: 1.2s
      early_reflections: Low
      use: Outdoor realms, dungeons

  occlusion:
    furniture: -6 dB when behind
    walls: -20 dB when through
    portals: Muffled effect

  doppler_effect:
    enabled: true
    scale: 0.5  # Subtle
```

---

## Accessibility

### Motor Accessibility

```yaml
motor_options:
  one_handed_mode:
    enabled: true
    modifications:
      - Simplified gesture set
      - Auto-attack toggle
      - Hold instead of rapid tap
      - Larger hit boxes

  seated_play:
    enabled: true
    modifications:
      - Reduced arm movement required
      - Head-based aiming
      - Automatic dodging option
      - Lower enemy spawn height

  gesture_sensitivity:
    options: [Low, Medium, High]
    default: Medium
    effect: Easier gesture recognition

  auto_aim:
    enabled: Optional
    strength: [Off, Low, Medium, High]
    effect: Helps target enemies
```

### Visual Accessibility

```yaml
visual_options:
  colorblind_modes:
    - Protanopia (red-weak)
    - Deuteranopia (green-weak)
    - Tritanopia (blue-weak)
    - Achromatopsia (no color)

  high_contrast:
    enabled: Optional
    modifications:
      - Thicker outlines
      - Brighter highlights
      - Reduced particle effects
      - Clearer UI backgrounds

  text_options:
    size: [Small, Medium, Large, Extra Large]
    background: [None, Semi-transparent, Solid]
    font: [Standard, Dyslexic-friendly]

  visual_cues:
    audio_to_visual: true
    direction_indicators: Arrows for off-screen threats
    color_coded_threats: Distinctive patterns
```

### Cognitive Accessibility

```yaml
cognitive_options:
  difficulty:
    - Story (very easy, can't die)
    - Easy (forgiving)
    - Normal (balanced)
    - Hard (challenging)
    - Nightmare (punishing)

  quest_assistance:
    waypoints: Optional markers
    objective_tracking: Clear current goal
    hint_frequency: [Never, Rare, Frequent]
    tutorial_access: Replay anytime

  ui_simplification:
    reduced_hud: Hide non-essential
    icon_labels: Text on all icons
    confirmation_prompts: For important actions
    auto_pause: On low health

  gameplay_assistance:
    auto_combat: AI helps with fighting
    slow_motion: Slow time during combat
    checkpoint_anywhere: Save anytime
    unlimited_retries: No game over
```

---

## Tutorial and Onboarding

### First-Time User Experience (FTUE)

```yaml
ftue_flow:
  session_1_goals:
    - Scan room safely
    - Understand spatial controls
    - Complete first combat
    - Place first persistent object
    - Feel the magic

  duration: 20-30 minutes
  completion_rate_target: 95%
  retention_metric: 80% return next day
```

### Tutorial Sequence

#### Stage 1: Room Scanning (5 min)

```yaml
stage: Room Scanning
objectives:
  - Teach room mapping
  - Establish safe play area
  - Detect furniture

presentation:
  visuals: Magical particles scan the room
  narration: "The realm analyzes your domain..."
  interaction: Walk around, look at furniture

success_criteria:
  - 80% room coverage
  - At least 3 furniture items detected
  - Safe play area established
```

#### Stage 2: Character Creation (10 min)

```yaml
stage: Character Creation
objectives:
  - Choose class
  - Customize appearance
  - Learn character purpose

presentation:
  visuals: Life-size character model appears
  narration: "Who will you become, Guardian?"
  interaction: Gaze + pinch to customize

success_criteria:
  - Class selected
  - Name chosen
  - Appearance customized
```

#### Stage 3: Combat Training (15 min)

```yaml
stage: Combat Training
objectives:
  - Learn basic attack gesture
  - Practice blocking
  - Cast first spell
  - Defeat training dummy

presentation:
  visuals: Friendly NPC guides you
  narration: "Feel the weight of your blade..."
  interaction: Physical gestures

sub_lessons:
  - slash_attack: "Swing your hand like a sword"
  - block: "Raise your forearm to block"
  - spell_cast: "Draw a circle and push forward"
  - dodge: "Lean or step to avoid attacks"

success_criteria:
  - Land 5 successful hits
  - Block 3 attacks
  - Cast spell successfully
  - Defeat training dummy
```

#### Stage 4: First Quest (10 min)

```yaml
stage: First Real Quest
objectives:
  - Receive quest from NPC
  - Navigate to objective
  - Defeat real enemy
  - Collect loot
  - Return for reward

presentation:
  visuals: Quest marker shows location
  narration: "A goblin has invaded your realm!"
  interaction: Full gameplay loop

success_criteria:
  - Find enemy behind couch
  - Defeat enemy using learned skills
  - Pick up dropped loot
  - Return to NPC for XP
```

### Ongoing Tutorials

```yaml
just_in_time_tutorials:
  - trigger: First legendary item
    lesson: Item rarity and stats

  - trigger: Level 5 reached
    lesson: Skill point allocation

  - trigger: First death
    lesson: Resurrection system

  - trigger: Friend joins
    lesson: Multiplayer cooperation

  - trigger: First raid invite
    lesson: Group content

presentation_style:
  - Non-intrusive
  - Contextual
  - Skippable
  - Replayable from help menu
```

---

## Difficulty Balancing

### Dynamic Difficulty Adjustment (DDA)

```yaml
dda_system:
  metrics_tracked:
    - Death frequency
    - Combat duration
    - Health potion usage
    - Quest completion rate
    - Session length

  adjustment_triggers:
    too_hard:
      - 3+ deaths in 10 minutes
      - Combat lasting >5 minutes
      - Health below 20% frequently

    too_easy:
      - No deaths in 2 hours
      - Combat ending in <30 seconds
      - Health rarely below 80%

  modifications:
    when_too_hard:
      - Reduce enemy health 10%
      - Reduce enemy damage 15%
      - Increase health drop rate
      - Add combat hints

    when_too_easy:
      - Increase enemy variety
      - Add elite enemies
      - Reduce resource drops
      - Introduce new mechanics

  player_control:
    notification: "Game is adjusting difficulty"
    opt_out: Can disable in settings
    manual_override: Can set fixed difficulty
```

### Difficulty Presets

```yaml
difficulty_presets:
  story_mode:
    description: "Experience the narrative without challenge"
    enemy_health: 0.5x
    enemy_damage: 0.3x
    player_health_regen: 3x
    death_penalty: None
    resurrection: Instant
    best_for: Casual players, narrative focus

  easy:
    description: "Gentle introduction to combat"
    enemy_health: 0.7x
    enemy_damage: 0.6x
    player_health_regen: 1.5x
    death_penalty: Minor gold loss
    resurrection: 10 seconds
    best_for: New to RPGs

  normal:
    description: "Balanced challenge"
    enemy_health: 1.0x
    enemy_damage: 1.0x
    player_health_regen: 1.0x
    death_penalty: Gold and XP loss
    resurrection: 30 seconds
    best_for: Most players

  hard:
    description: "For experienced warriors"
    enemy_health: 1.5x
    enemy_damage: 1.5x
    player_health_regen: 0.5x
    death_penalty: Significant losses
    resurrection: 60 seconds
    best_for: RPG veterans

  nightmare:
    description: "Brutal, unforgiving challenge"
    enemy_health: 2.0x
    enemy_damage: 2.0x
    player_health_regen: 0x
    death_penalty: Permadeath (hardcore mode)
    resurrection: None
    best_for: Masochists
    rewards: +50% XP and loot
```

### Encounter Design

```yaml
encounter_scaling:
  solo_play:
    enemy_count: 1-3
    health_pool: Standard
    tactics: Basic AI

  duo_play:
    enemy_count: 3-5
    health_pool: 1.5x
    tactics: Flanking maneuvers

  full_party_4:
    enemy_count: 8-12
    health_pool: 2x
    tactics: Coordinated attacks, focus fire

boss_encounters:
  design_principles:
    - Telegraph attacks (2 second warning)
    - Phase changes at 75%, 50%, 25% health
    - Environmental mechanics
    - Weak points to target
    - Enrage timer (10 minutes)

  example_boss:
    name: "Living Room Guardian"
    health: 10,000
    phases:
      phase_1:
        health: 100-75%
        mechanics: Basic attacks, summons minions

      phase_2:
        health: 75-50%
        mechanics: Adds area denial zones

      phase_3:
        health: 50-25%
        mechanics: Berserk mode, faster attacks

      phase_4:
        health: 25-0%
        mechanics: Desperation, all abilities
```

---

## Conclusion

This design document provides comprehensive guidance for creating an engaging, accessible, and polished spatial RPG experience. Key principles:

- **Player-Centric**: Design adapts to individual homes and skill levels
- **Clarity**: Clear feedback for all actions and states
- **Accessibility**: Inclusive design for all players
- **Spatial Magic**: Leveraging visionOS to create wonder
- **Balanced Progression**: Rewarding both casual and hardcore players

The design prioritizes comfort, immersion, and the unique feeling of having your home transformed into a living RPG world.
