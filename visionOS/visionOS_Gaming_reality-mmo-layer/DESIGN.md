# Reality MMO Layer - Game Design Document & UI/UX Specification

## Document Information

**Version:** 1.0
**Last Updated:** 2025-01-20
**Status:** Design Phase
**Document Type:** Game Design Document (GDD) + UI/UX Specification

---

## Table of Contents

1. [Game Overview](#1-game-overview)
2. [Core Gameplay Loop](#2-core-gameplay-loop)
3. [Player Progression Systems](#3-player-progression-systems)
4. [Level Design Principles](#4-level-design-principles)
5. [Spatial Gameplay Design](#5-spatial-gameplay-design)
6. [UI/UX for Gaming](#6-uiux-for-gaming)
7. [Visual Style Guide](#7-visual-style-guide)
8. [Audio Design](#8-audio-design)
9. [Accessibility](#9-accessibility)
10. [Tutorial and Onboarding](#10-tutorial-and-onboarding)
11. [Difficulty Balancing](#11-difficulty-balancing)

---

## 1. Game Overview

### 1.1 High Concept

Reality MMO Layer transforms the entire physical world into a persistent fantasy MMO game world. Players explore their real neighborhoods, cities, and beyond while seeing a rich layer of virtual content overlaid on reality. Every location becomes meaningful—parks host world bosses, buildings contain dungeons, and landmarks serve as guild territories.

**Genre:** Location-Based Augmented Reality MMO
**Core Pillars:**
1. **Exploration** - Discover virtual content everywhere in the real world
2. **Social** - Meet and coordinate with players in physical proximity
3. **Progression** - Develop your character through real-world activity
4. **Competition** - Guild warfare for territorial control

### 1.2 Unique Selling Points

**For Players:**
- First true persistent AR MMO with global real-world integration
- Your daily routine becomes an epic adventure
- Physical exploration rewarded with virtual progression
- Real-world social connections through shared AR experiences

**For Vision Pro:**
- Showcases outdoor AR capabilities
- Natural hand and eye tracking for immersive control
- Spatial audio creates believable virtual inhabitants
- Seamless indoor-outdoor transitions

### 1.3 Target Experience

**Moment-to-Moment:**
- Walk through your neighborhood and see virtual creatures, NPCs, and resources
- Tap into quests at local landmarks
- Encounter other players as glowing avatars with guild affiliations
- Collect resources and engage in combat using gesture controls

**Session Goals:**
- Complete daily quests in your area (15-30 minutes)
- Participate in guild activities and territory defense (30-60 minutes)
- Explore new areas to discover content (60+ minutes)

**Long-Term Aspirations:**
- Reach max level and unlock prestige classes
- Lead a powerful guild controlling major territories
- Accumulate rare legendary items
- Participate in global world events affecting entire cities

---

## 2. Core Gameplay Loop

### 2.1 Primary Loops

#### Exploration Loop (Beginner Focus)
```
Explore New Location
    ↓
Discover Content (NPCs, Quests, Resources)
    ↓
Complete Objectives / Collect Items
    ↓
Gain Experience & Unlock New Areas
    ↓
(Return to Explore)
```

**Duration:** 5-20 minutes per cycle
**Rewards:** XP, items, map completion, location unlocks

#### Combat Loop (Core Gameplay)
```
Encounter Enemy / Accept Challenge
    ↓
Engage with Gesture-Based Abilities
    ↓
Defeat Enemy / Complete Combat Objective
    ↓
Receive Loot & XP
    ↓
Improve Equipment / Learn Skills
    ↓
(Return to Encounter)
```

**Duration:** 1-5 minutes per cycle
**Rewards:** XP, equipment, currency, skill points

#### Social Loop (Multiplayer Focus)
```
Meet Nearby Players
    ↓
Form Party / Join Guild
    ↓
Coordinate Group Activities
    ↓
Complete Group Content
    ↓
Build Relationships & Reputation
    ↓
(Return to Meet)
```

**Duration:** 30-120 minutes per cycle
**Rewards:** Social bonds, guild resources, group-exclusive loot

#### Economic Loop (Endgame Focus)
```
Gather Resources / Complete Content
    ↓
Craft Items / Find Rare Drops
    ↓
Trade in Marketplace
    ↓
Accumulate Wealth
    ↓
Purchase Upgrades / Cosmetics
    ↓
(Return to Gather)
```

**Duration:** Variable
**Rewards:** Currency, rare items, economic influence

### 2.2 Session Structures

**Quick Session (5-15 minutes)**
- Log in, check daily bonuses
- Complete 2-3 nearby quests
- Collect local resources
- Social check-in with guild

**Standard Session (30-60 minutes)**
- Daily quest completion
- Exploration of 2-3 new locations
- Guild activity participation
- Marketplace trading

**Epic Session (2+ hours)**
- Major dungeon raid with guild
- Territorial warfare
- Long-distance exploration to new city
- World event participation

### 2.3 Retention Mechanics

**Daily Rewards:**
- Login bonus (increasing with streak)
- Daily quest with unique rewards
- Daily guild contribution objectives

**Weekly Content:**
- Weekly challenge quest (higher difficulty, better rewards)
- Guild war events (territorial battles)
- Special vendor rotations

**Monthly Events:**
- Seasonal world events
- Limited-time quests and cosmetics
- Ranked competitive seasons
- New content drops

---

## 3. Player Progression Systems

### 3.1 Experience and Leveling

**Level Range:** 1-60 (Soft cap), Prestige levels beyond

**Experience Curve:**
```
Level 1-10:    100, 150, 225, 340, 510, 765, 1150, 1725, 2590, 3885
Level 11-20:   5830, 8745, 13120, 19680, 29520, 44280, 66420, 99630, 149445, 224170
Level 21-30:   336255, 504383, 756575, 1134863, 1702295...
(Exponential scaling: XP[n] = 100 * 1.5^(n-1))
```

**XP Sources:**
- Quest completion: 500-5000 XP based on difficulty
- Enemy kills: 10-100 XP based on level difference
- Location discovery: 200-1000 XP
- Guild activities: 1000-10000 XP
- Daily challenges: 2000 XP

**Level-Up Rewards:**
- +3 Attribute points
- +1-2 Skill points
- +20 Health, +15 Mana
- New abilities unlocked every 5 levels
- Access to new content zones

### 3.2 Character Classes

**Warrior** (Melee Tank/DPS)
- **Playstyle:** Close-range combat, high survivability
- **Primary Stat:** Strength
- **Signature Abilities:**
  - Shield Bash (stun)
  - Whirlwind Attack (AoE)
  - Battle Cry (buff allies)
  - Charge (gap closer)

**Mage** (Ranged Magical DPS)
- **Playstyle:** Long-range spellcasting, area control
- **Primary Stat:** Intelligence
- **Signature Abilities:**
  - Fireball (direct damage)
  - Ice Nova (AoE slow)
  - Teleport (mobility)
  - Meteor (ultimate AoE)

**Rogue** (Melee DPS/Stealth)
- **Playstyle:** High single-target damage, mobility
- **Primary Stat:** Agility
- **Signature Abilities:**
  - Backstab (high damage from behind)
  - Stealth (invisibility)
  - Poison Blade (DoT)
  - Shadow Step (teleport to target)

**Cleric** (Support/Healer)
- **Playstyle:** Group support, healing, buffs
- **Primary Stat:** Wisdom
- **Signature Abilities:**
  - Heal (restore health)
  - Divine Shield (damage absorption)
  - Resurrection (revive fallen allies)
  - Holy Light (AoE heal + damage)

**Ranger** (Ranged Physical DPS)
- **Playstyle:** Long-range precision, nature magic
- **Primary Stat:** Agility
- **Signature Abilities:**
  - Aimed Shot (high single-target damage)
  - Trap (area control)
  - Pet Summon (companion)
  - Multi-Shot (AoE)

### 3.3 Skill Trees

Each class has 3 specialization trees:

**Example: Warrior Trees**

**Protection (Tank)**
- Improved armor and health
- Threat generation bonuses
- Defensive cooldowns
- Team damage mitigation

**Arms (DPS)**
- Increased damage output
- Critical strike bonuses
- Burst damage abilities
- Execute mechanics

**Fury (Berserker)**
- Attack speed bonuses
- Lifesteal mechanics
- AoE damage focus
- Risk/reward playstyle

**Skill Point Allocation:**
- 1-2 points per level
- Can reset for gold cost
- Hybrid builds possible
- Unique capstone abilities at tree end

### 3.4 Equipment System

**Equipment Slots:**
- Head (helmet)
- Chest (armor)
- Hands (gloves)
- Legs (pants)
- Feet (boots)
- Main Hand (weapon)
- Off Hand (shield/weapon/tome)
- Accessory 1 (ring)
- Accessory 2 (necklace)

**Item Rarity:**
- **Common** (Gray): Basic stats, vendor trash
- **Uncommon** (Green): Modest stat bonuses
- **Rare** (Blue): Good stats + 1 special property
- **Epic** (Purple): Great stats + 2-3 special properties
- **Legendary** (Orange): Excellent stats + unique mechanics

**Item Acquisition:**
- Enemy drops (random)
- Quest rewards (guaranteed)
- Crafting (player-made)
- Marketplace (player trading)
- World bosses (guaranteed epic/legendary)

**Upgrade Systems:**
- Enchanting: Add stat bonuses
- Socketing: Insert gems for effects
- Transmogrification: Change appearance
- Item level scaling with player level

### 3.5 Crafting System

**Professions:**
- **Blacksmithing:** Weapons and heavy armor
- **Leatherworking:** Medium armor, accessories
- **Tailoring:** Light armor, bags
- **Alchemy:** Potions, elixirs, transmutation
- **Enchanting:** Magical enhancements
- **Jewelcrafting:** Rings, necklaces, gems

**Crafting Flow:**
1. Gather raw materials from world
2. Learn recipes (drops, vendors, discovery)
3. Combine materials at crafting station
4. Create item with variable quality
5. Sell or use crafted items

**Resource Nodes:**
- Mining: Ore veins in mountainous areas
- Herbalism: Plants in parks and forests
- Fishing: Water sources
- Salvaging: Break down equipment for materials

---

## 4. Level Design Principles

### 4.1 Location-Based Content Design

**Urban Environments**
```yaml
Park/Green Space:
  Purpose: Safe exploration zone, resource gathering
  Content:
    - Friendly NPCs and quest givers
    - Harvestable resources (herbs, materials)
    - Low-level enemies for beginners
    - Peaceful activities (fishing, gathering)
  Spawn Density: High
  Danger Level: Low

Downtown/Business District:
  Purpose: High-activity hub, social center
  Content:
    - Marketplace vendors
    - Guild recruitment areas
    - Faction representatives
    - Mini-dungeons in buildings
  Spawn Density: Very High
  Danger Level: Medium

Residential Areas:
  Purpose: Player housing, quiet content
  Content:
    - Claimable housing plots
    - Neighborhood quests
    - Daily quest hubs
    - Low-key activities
  Spawn Density: Medium
  Danger Level: Low

Industrial Zones:
  Purpose: Challenging content, rare resources
  Content:
    - Elite enemies
    - Rare resource nodes
    - Dangerous dungeons
    - Guild war objectives
  Spawn Density: Medium
  Danger Level: High

Landmarks:
  Purpose: Major objectives, memorable experiences
  Content:
    - World bosses
    - Territory control points
    - Major quest chains
    - Photo opportunities
  Spawn Density: Low (quality over quantity)
  Danger Level: Very High
```

**Suburban/Rural Environments**
```yaml
Suburban Neighborhoods:
  Purpose: Casual exploration, family-friendly content
  Content:
    - Side quests with local flavor
    - Collectible hunts
    - Pet battles
    - Calm activities

Rural/Natural Areas:
  Purpose: Exploration, nature-themed content
  Content:
    - Wildlife encounters
    - Hidden treasures
    - Scenic vistas with bonuses
    - Long-distance travel rewards

Highways/Roads:
  Purpose: Travel routes, dynamic events
  Content:
    - Random encounters while traveling
    - Traveling merchants
    - Escort quest routes
    - Fast travel waypoints
```

### 4.2 Dungeon Design

**Instanced Dungeons**
- Located in real buildings/structures
- Requires proximity to enter
- 1-5 players
- 15-45 minute completion time
- Boss encounters with mechanics
- Guaranteed loot chests

**Dungeon Structure:**
```
Entrance Area
  ↓
Trash Mob Sections (3-5 enemy groups)
  ↓
Mini-Boss (Optional, bonus loot)
  ↓
More Trash Sections
  ↓
Final Boss (Mechanic-heavy fight)
  ↓
Loot Room + Exit
```

**Dungeon Difficulty Tiers:**
- Normal: Intended for questing, easy
- Heroic: Requires coordination, better loot
- Mythic: Endgame challenge, best loot
- Challenge Mode: Timed, leaderboards

### 4.3 World Boss Design

**Spawn Mechanics:**
- Spawns at major landmarks
- 2-4 hour respawn timer
- Announced globally 15 minutes before spawn
- Requires 10-50 players to defeat

**Boss Phases:**
1. **Engagement (100-75% HP):** Basic mechanics, telegraphed attacks
2. **Escalation (75-40% HP):** New abilities, increased difficulty
3. **Desperate (40-10% HP):** Ultimate abilities, high damage
4. **Enrage (< 10% HP):** Berserk mode, kill or be wiped

**Loot Distribution:**
- Personal loot system (everyone gets something)
- Contribution-based bonus rolls
- Guaranteed epic+ item
- Rare cosmetic drops

### 4.4 Dynamic Events

**Event Types:**

**Invasion Events**
- Location: Random city zones
- Duration: 30-60 minutes
- Objective: Defeat waves of enemies
- Reward: Event currency, experience

**Escort Missions**
- Location: Travel routes
- Duration: 15-30 minutes
- Objective: Protect NPC to destination
- Reward: Reputation, items

**Capture Points**
- Location: Strategic landmarks
- Duration: Ongoing
- Objective: Hold location for guild
- Reward: Territory control, bonuses

**World Quests**
- Location: All zones
- Duration: 24 hours (refreshes daily)
- Objective: Various tasks
- Reward: Experience, gear, currency

---

## 5. Spatial Gameplay Design for Vision Pro

### 5.1 Comfort-First Design

**Stationary Comfort**
- No forced rapid movement
- Optional teleportation for navigation assistance
- Gradual introduction to head rotation
- Breaks encouraged every 20-30 minutes

**Movement Comfort**
- Virtual content moves with player (anchored to world)
- Smooth camera transitions
- No artificial locomotion (player physically walks)
- Horizon lock for orientation reference

**Visual Comfort**
- High contrast for virtual objects vs. reality
- Clear depth cues
- No flashing effects (epilepsy prevention)
- Adjustable opacity for virtual elements

### 5.2 Spatial UI Layout

**Near Space (0.5m - 1.5m)**
- Personal character sheet
- Inventory management
- Quest journal
- Skill tree

**Mid Space (1.5m - 5m)**
- Enemy health bars
- Damage numbers
- Loot notifications
- Party member indicators

**Far Space (5m+)**
- Quest markers on landmarks
- World map overlay
- Guild territory boundaries
- Distant player avatars

### 5.3 Gesture-Based Gameplay

**Movement Gestures**
- Natural walking (player moves physically)
- Point to set waypoint
- Pinch-drag to rotate map

**Combat Gestures**

**Fireball Spell:**
1. Extend arm forward, palm open
2. Curl fingers into fist
3. Thrust forward
4. → Fireball projectile launches

**Shield Block:**
1. Cross arms in front of chest
2. Hold position
3. → Defensive buff activated

**Sword Slash:**
1. Grip gesture with dominant hand
2. Diagonal swipe motion
3. → Melee attack executes

**Bow Attack:**
1. One hand extends forward (bow)
2. Other hand pulls back (draw)
3. Release pull hand
4. → Arrow fires

**Loot Collection:**
1. Gaze at loot item
2. Pinch gesture
3. → Item added to inventory

### 5.4 Eye Tracking Integration

**Target Selection**
- Gaze at entity for 0.5 seconds to highlight
- Gaze + pinch to lock target
- Double-blink to quick-select (optional)

**UI Navigation**
- Gaze to highlight buttons
- Dwell (1 second) or pinch to activate
- Gaze-scrolling for long lists

**Environmental Interaction**
- Look at NPCs to see name/level
- Look at objects to reveal interactivity
- Look at quest objectives to show details

### 5.5 Spatial Audio Cues

**Directional Audio**
- Enemy locations indicated by sound
- Resource nodes emit gathering sounds
- Players emit social audio (voice chat)
- Quest objectives have audio pings

**Audio Storytelling**
- NPCs speak dialogue spatially
- Ambient audio changes by location type
- Dynamic music intensity based on danger
- Victory fanfares for achievements

---

## 6. UI/UX for Gaming

### 6.1 HUD Design (Heads-Up Display)

**Minimal HUD Philosophy**
- Show only essential information
- Contextual elements appear when needed
- Transparent backgrounds to preserve reality view
- Customizable positioning and scale

**HUD Elements:**

```
┌──────────────────────────────────────────────────┐
│  [Health: ████████░░ 80%]                       │  Top Left
│  [Mana:   ██████░░░░ 60%]                       │
│  [XP: ──────────█░░░░░ 75% to Level 25]         │
│                                                   │
│  [Quest Tracker]                   [Mini-Map]    │  Right Side
│  • Defeat 5 Wolves (3/5)          ╔═══════╗     │
│  • Collect Herbs (10/15)          ║ [·][^]║     │
│                                    ║ [ ][ ]║     │
│                                    ╚═══════╝     │
│                                                   │
│  [Ability Bar]                                   │  Bottom Center
│  [1:Fireball ●] [2:Shield ○] [3:Heal ●] [4:...]│
│                                                   │
│  [Guild: DragonSlayers]                          │  Top Right
│  [Online Members: 23]                            │
│  [Territory: Downtown]                           │
└──────────────────────────────────────────────────┘

Legend:
● = Ready to use
○ = On cooldown
█ = Filled resource bar
░ = Empty resource bar
```

**HUD Modes:**
- **Full HUD:** All elements visible (default)
- **Minimal HUD:** Only health/mana
- **Hidden HUD:** Everything hidden (screenshots, immersion)
- **Combat HUD:** Focus on combat info

### 6.2 Menu Systems

**Main Menu (Pre-Login)**
```
╔════════════════════════════╗
║   REALITY MMO LAYER        ║
║                             ║
║   [Start Game]              ║
║   [Settings]                ║
║   [Credits]                 ║
║   [Exit]                    ║
╚════════════════════════════╝
```

**Character Selection**
```
╔════════════════════════════════════════╗
║  Select Your Hero                      ║
╠════════════════════════════════════════╣
║                                         ║
║   [Avatar Preview - Rotatable 3D]      ║
║                                         ║
║   Name: PlayerName                     ║
║   Level: 45                            ║
║   Class: Warrior                       ║
║   Location: San Francisco              ║
║                                         ║
║   [Play] [Create New] [Delete]         ║
╚════════════════════════════════════════╝
```

**Pause Menu (In-Game)**
```
╔════════════════════════════╗
║   [Resume]                 ║
║   [Character]              ║
║   [Inventory]              ║
║   [Quests]                 ║
║   [Guild]                  ║
║   [Map]                    ║
║   [Social]                 ║
║   [Marketplace]            ║
║   [Settings]               ║
║   [Logout]                 ║
╚════════════════════════════╝
```

### 6.3 Inventory Interface

**Grid-Based Inventory**
```
╔═══════════════════════════════════════╗
║  Inventory [25/50]       [Sort] [Search]
╠═══════════════════════════════════════╣
║  ┌──┬──┬──┬──┬──┬──┬──┬──┬──┬──┐     ║
║  │⚔│🛡│💎│🌿│⚗│  │  │  │  │  │     ║
║  ├──┼──┼──┼──┼──┼──┼──┼──┼──┼──┤     ║
║  │🗡│👕│👖│👢│  │  │  │  │  │  │     ║
║  ├──┼──┼──┼──┼──┼──┼──┼──┼──┼──┤     ║
║  │📜│📜│🔑│💰│  │  │  │  │  │  │     ║
║  └──┴──┴──┴──┴──┴──┴──┴──┴──┴──┘     ║
║                                        ║
║  Selected: [Iron Sword]                ║
║  Damage: 45-60                         ║
║  +15 Strength                          ║
║  Required Level: 20                    ║
║                                        ║
║  [Equip] [Drop] [Sell]                ║
╚═══════════════════════════════════════╝
```

**Equipment Paper Doll**
```
╔═══════════════════════════╗
║     Character Sheet       ║
╠═══════════════════════════╣
║         [Head]            ║
║                            ║
║   [Main]  👤  [Off]       ║
║   Hand         Hand        ║
║                            ║
║        [Chest]            ║
║                            ║
║         [Legs]            ║
║                            ║
║         [Feet]            ║
║                            ║
║  [Ring1]      [Ring2]     ║
║      [Necklace]           ║
║                            ║
║  Stats:                   ║
║  Attack Power: 450        ║
║  Defense: 320             ║
║  Crit Chance: 25%         ║
╚═══════════════════════════╝
```

### 6.4 Quest Interface

**Quest Journal**
```
╔══════════════════════════════════════════╗
║  Quest Journal                           ║
╠══════════════════════════════════════════╣
║  [Active] [Completed] [Available]        ║
║                                           ║
║  ┌──────────────────────────────────┐   ║
║  │ ⚔ Dragon's Bane (Main)           │   ║
║  │   Level 40 • Epic Quest           │   ║
║  │                                    │   ║
║  │   Objectives:                     │   ║
║  │   • Slay the Dragon (0/1)         │   ║
║  │   • Collect Dragon Scales (5/10)  │   ║
║  │                                    │   ║
║  │   Rewards:                        │   ║
║  │   • 50,000 XP                     │   ║
║  │   • Legendary Sword               │   ║
║  │   • 5,000 Gold                    │   ║
║  │                                    │   ║
║  │   [Track] [Abandon]               │   ║
║  └──────────────────────────────────┘   ║
║                                           ║
║  ┌──────────────────────────────────┐   ║
║  │ 🌿 Herb Gathering (Daily)         │   ║
║  │   [...]                           │   ║
║  └──────────────────────────────────┘   ║
╚══════════════════════════════════════════╝
```

**Quest Notification (Spatial)**
```
          ✨ Quest Complete! ✨
     ───────────────────────────────
          Dragon's Bane

         Rewards Received:
           +50,000 XP
           [Dragonslayer Sword]
           +5,000 Gold

            Level Up! → 41

     ───────────────────────────────
              [Continue]
```

### 6.5 Social Interface

**Friend List**
```
╔════════════════════════════════════╗
║  Friends [15/50]                   ║
╠════════════════════════════════════╣
║  🟢 Alice (Lvl 48 Mage) - Online   ║
║     Location: Downtown             ║
║     [Message] [Invite] [Trade]     ║
║                                     ║
║  🟢 Bob (Lvl 45 Warrior) - Online  ║
║     Location: Park District        ║
║     [Message] [Invite] [Trade]     ║
║                                     ║
║  ⚪ Carol (Lvl 40 Cleric) - Offline║
║     Last seen: 2 hours ago         ║
║                                     ║
║  [Add Friend] [Settings]           ║
╚════════════════════════════════════╝
```

**Guild Interface**
```
╔════════════════════════════════════╗
║  Guild: DragonSlayers              ║
║  Level: 25 | Members: 45/50        ║
╠════════════════════════════════════╣
║  [Roster] [Chat] [Bank] [Perks]    ║
║                                     ║
║  Territory Control:                ║
║  • Downtown ✓                      ║
║  • Park District ✓                 ║
║  • Industrial Zone (Contested)     ║
║                                     ║
║  Guild Bank:                       ║
║  Gold: 1,250,000                   ║
║  Items: 234                        ║
║                                     ║
║  Weekly Activities:                ║
║  [ ] Raid: Dragon's Lair (0/20)    ║
║  [✓] Territory Defense (15/10)     ║
║  [ ] Guild Dungeon (2/5)           ║
║                                     ║
║  [Contribute] [Request] [Leave]    ║
╚════════════════════════════════════╝
```

### 6.6 Map Interface

**World Map (AR Overlay)**
```
┌─────────────────────────────────────┐
│  [Filter: Quests ▼]  [Zoom: 50%]   │
│                                      │
│    N                                │
│    ↑                                │
│  W ←+→ E                            │
│    ↓                                │
│    S                                │
│                                      │
│  ╔══════════════════════════╗      │
│  ║   ⚔        🏛        🌲   ║      │
│  ║      YOU                  ║      │
│  ║        ⬤     ⬤     ⬤    ║      │
│  ║   🏰                   🏰 ║      │
│  ║             🌲      🌲    ║      │
│  ║        ⬤                 ║      │
│  ║   ⬤     🌳         ⚔     ║      │
│  ╚══════════════════════════╝      │
│                                      │
│  Legend:                            │
│  ⬤ Player  🏰 Guild Territory       │
│  ⚔ Quest  🌲 Resource Node          │
│  🏛 Landmark  🌳 Dungeon             │
│                                      │
│  [Waypoint] [Zoom In] [Zoom Out]    │
└─────────────────────────────────────┘
```

---

## 7. Visual Style Guide

### 7.1 Art Direction

**Overall Aesthetic:** High Fantasy meets Modern Reality

**Visual Goals:**
- Seamless blend of virtual and real
- Fantasy elements feel "at home" in real world
- Readable at various distances and lighting
- Optimized for outdoor AR visibility

**Color Palette:**

**Primary Colors (UI)**
- Gold: `#FFD700` - Highlights, rewards, legendary items
- Steel Blue: `#4682B4` - Primary UI elements
- Deep Purple: `#6A0DAD` - Magic effects, epic items
- Forest Green: `#228B22` - Nature elements, safe zones

**Secondary Colors (World)**
- Ember Orange: `#FF4500` - Fire effects, danger
- Ice Blue: `#87CEEB` - Water/ice effects
- Shadow Black: `#1C1C1C` - Dark elements, enemies
- Holy White: `#F0F8FF` - Healing, divine magic

**Rarity Colors:**
- Common: `#9D9D9D` (Gray)
- Uncommon: `#1EFF00` (Green)
- Rare: `#0070DD` (Blue)
- Epic: `#A335EE` (Purple)
- Legendary: `#FF8000` (Orange)

### 7.2 Character Design

**Player Avatars:**
- Stylized realistic proportions
- Clear class identity from silhouette
- Customizable features (hair, face, body type)
- Animated with personality (idle animations)
- Visible from 50+ meters with clear guild emblems

**Avatar Customization:**
```
Body:
  - Height: Short / Medium / Tall
  - Build: Slim / Athletic / Muscular

Face:
  - 12 face shapes
  - 20 hairstyles
  - 8 skin tones
  - Facial hair options

Class Indicators:
  - Warrior: Heavy armor, weapon visible
  - Mage: Robes, magical aura
  - Rogue: Light armor, dual weapons
  - Cleric: Holy symbols, staff
  - Ranger: Bow, nature theme
```

**NPC Design:**
- Distinct from players (unique models)
- Clear role indication (merchant, quest giver, enemy)
- Floating icons above head for identification
- Animated interactions (wave, point, emote)

### 7.3 Environment Integration

**Virtual Objects in Real World:**
- Respect real lighting (shadows match time of day)
- Occlusion by real objects (no clipping through walls)
- Appropriate scale (don't feel out of place)
- Subtle particle effects for discoverability

**Content Archetypes:**

**Quest Giver NPC:**
- Glowing aura (subtle, not blinding)
- Exclamation mark icon above head
- Idle animation (looking around, gesturing)
- Name tag: `[!] Wise Sage (Quest)`

**Enemy Creature:**
- Red health bar when engaged
- Aggressive animation stance
- Particle effects (flames, shadow, etc.)
- Name tag: `[Hostile] Shadow Wolf (Lvl 25)`

**Resource Node:**
- Gentle sparkle particle effect
- Interactable highlight on gaze
- Contextual icon (pickaxe for ore, herb for plant)
- Name tag: `[Gather] Iron Ore Vein`

**Dungeon Entrance:**
- Swirling portal effect
- Large and visible from distance
- Level requirement displayed
- Name tag: `[Dungeon] Shadow Crypts (Lvl 30-35)`

### 7.4 Visual Effects (VFX)

**Ability Effects:**
- Clear telegraph before impact (0.5s warning)
- Satisfying impact feedback
- Appropriate to ability type
- Performance-optimized (< 1000 particles)

**Fireball Example:**
```
1. Casting (1s):
   - Hand glows orange
   - Particle swirl around palm
   - Audio: Charging sound

2. Projectile (0.5-2s):
   - Orange sphere travels forward
   - Trail of embers
   - Audio: Whoosh sound

3. Impact:
   - Explosion particle burst
   - Fire damage numbers appear
   - Camera shake (subtle)
   - Audio: Boom + crackling
```

**Environmental Effects:**
- Weather matches real world (rain, fog, etc.)
- Time-of-day affects lighting on virtual objects
- Seasonal themes (winter snow, autumn leaves)
- Special effects for world events

---

## 8. Audio Design

### 8.1 Music System

**Layered Adaptive Music:**
- Base layer always playing (ambient)
- Combat layer fades in during fights
- Epic layer for boss encounters
- Victory stinger for completions

**Music Zones:**
```
Safe Zones (Towns, Parks):
  - Peaceful orchestral
  - Acoustic instruments
  - Slow tempo (60-80 BPM)

Exploration (General World):
  - Adventurous themes
  - Medium tempo (90-110 BPM)
  - Varied instrumentation

Combat:
  - Intense percussion
  - Fast tempo (130-150 BPM)
  - Brass and strings

Boss Fights:
  - Epic orchestral
  - Choir vocals
  - Dynamic changes per phase
```

**Player Controls:**
- Music volume slider
- Toggle music on/off
- Select preferred genres (unlockable)

### 8.2 Sound Effects (SFX)

**Combat SFX:**
- Weapon swings: Whoosh sounds
- Impacts: Meaty thud for hits, clang for blocks
- Spells: Unique sound per ability type
- Critical hits: Distinctive high-pitched ding

**UI SFX:**
- Button click: Soft tap
- Menu open: Gentle whoosh
- Item pickup: Satisfying ping
- Quest complete: Victory chime
- Level up: Epic fanfare

**World SFX:**
- Footsteps: Match real terrain
- Ambient creatures: Birds, insects, monsters
- Resource gathering: Mining clink, herb rustle
- Dungeon atmosphere: Echoes, drips, rumbles

### 8.3 Spatial Audio Implementation

**3D Audio Positioning:**
- All sounds emit from source position in world
- Volume decreases with distance (1m-50m range)
- Occlusion by real objects (muffled through walls)
- Doppler effect for fast-moving sounds

**Priority System:**
```
Priority Levels:
1. Critical (Always play): Player actions, immediate threats
2. High: Combat, NPCs speaking, quest pings
3. Medium: Nearby players, ambient creatures
4. Low: Distant events, background ambience

Max Simultaneous Sounds: 32
```

**Spatial Audio Scenarios:**

**Enemy Behind Player:**
- Growl sound from rear direction
- Player turns head → sound shifts naturally
- Audio cue to check surroundings

**Guild Voice Chat:**
- Voice sources positioned at player avatars
- Natural conversation positioning
- Voice fades with distance (0-100m range)

**Quest Objective Ping:**
- Directional pulse every 10 seconds
- Points toward objective
- Helps player navigate to goal

### 8.4 Voice Acting

**NPC Dialogue:**
- Professional voice actors for main quests
- Text-to-speech for generated quests (high quality)
- Multiple voices per race/type
- Subtitles always available

**Voice Lines:**
- Quest acceptance: "I need your help!"
- Quest completion: "Thank you, hero!"
- Shop keeper: "What can I get ya?"
- Enemy aggro: Roars, taunts

**Player Voice Emotes:**
- Quick voice commands (Hello, Thanks, Help)
- Guild chat voice option
- Party voice chat (proximity-based)
- Toggle push-to-talk or always-on

---

## 9. Accessibility

### 9.1 Visual Accessibility

**Color Blindness Support:**
- High contrast mode
- Colorblind-friendly palettes
  - Deuteranopia (red-green)
  - Protanopia (red-green)
  - Tritanopia (blue-yellow)
- Icon shapes in addition to colors
- Rarity indicated by border pattern + color

**Low Vision Support:**
- UI scaling (100% - 200%)
- Large text mode
- High contrast UI elements
- Outline mode for virtual objects

**Visual Sensitivity:**
- Reduce flashing effects
- Disable screen shake
- Slower animations option
- Simplified particle effects

### 9.2 Auditory Accessibility

**Hearing Impairment:**
- Subtitles for all dialogue (required)
- Visual indicators for audio cues
  - Enemy direction: Red arrow on HUD
  - Quest ping: Glowing path
  - Danger: Screen flash + HUD alert
- Adjustable subtitle size and contrast

**Audio Customization:**
- Independent volume sliders (music, SFX, voice, UI)
- Mono audio option
- Visual sound effect indicators
- Captions for environmental sounds

### 9.3 Motor Accessibility

**Alternate Control Schemes:**
- Reduced gesture complexity mode
- Button-only controls (game controller)
- Voice-only controls (experimental)
- Auto-aim assistance (adjustable strength)

**Gameplay Assistance:**
- Auto-loot option
- Simplified combat (fewer inputs)
- Longer ability cooldowns but stronger effects
- Auto-navigation to waypoints

**Physical Comfort:**
- Seated play mode (reduced movement requirement)
- Frequent break reminders
- Adjustable interaction distances
- One-handed mode

### 9.4 Cognitive Accessibility

**Difficulty Options:**
- Story mode: Reduced challenge, focus on exploration
- Normal mode: Standard balanced gameplay
- Hard mode: Increased challenge, better rewards

**Guidance Systems:**
- Optional detailed tutorials
- Waypoint system for quests
- Objective trackers with clear descriptions
- In-game help encyclopedia

**UI Simplification:**
- Simplified HUD option (less info)
- Focus mode (highlights next objective)
- Reading assistance (dyslexia-friendly fonts)
- Clear, simple language in UI text

### 9.5 Safety Features

**Motion Sickness Prevention:**
- Vignette effect during fast movement
- Reduced head movement requirement
- Stationary play option
- Comfort warnings before intense content

**Physical Safety:**
- Passthrough reminder every 15 minutes
- Obstacle detection warnings
- Safe play area boundary
- Auto-pause if user appears distressed

**Social Safety:**
- Block and report system
- Profanity filter (adjustable)
- Anonymous mode (hide real location)
- Private mode (invisible to other players)

---

## 10. Tutorial and Onboarding

### 10.1 First-Time User Experience (FTUE)

**Session 1: Introduction (5-10 minutes)**

1. **Welcome Screen**
   - Brand identity and logo
   - Privacy notice and location permission request
   - Terms of service acceptance

2. **Account Creation**
   - Email/password or Sign in with Apple
   - Privacy settings: Location sharing, social visibility
   - Notifications preferences

3. **Character Creation**
   - Choose class (with descriptions)
   - Customize appearance
   - Name your character
   - Starter area selection (current location)

4. **AR Calibration**
   - Hand tracking setup
   - Eye tracking calibration
   - Comfort settings check

5. **First Steps**
   - "Look around" - Familiarize with AR view
   - "Walk forward" - Confirm locomotion
   - "See your first NPC" - Introduce virtual objects

6. **First Quest**
   - Talk to Tutorial NPC
   - Accept simple quest (collect 3 items nearby)
   - Learn to interact with objects (pinch gesture)
   - Turn in quest

7. **First Combat**
   - NPC summons training dummy
   - Learn basic attack gesture
   - Defeat dummy
   - Learn about abilities

8. **Quest Complete**
   - Receive rewards
   - Level up to Level 2
   - Congratulations screen
   - "Explore the world!" message

**Tutorial Pacing:**
- One mechanic at a time
- Immediate practice after learning
- Positive reinforcement
- Can skip if experienced player

### 10.2 Progressive Tutorials

**Levels 1-5: Core Mechanics**
- Basic movement and navigation
- Combat fundamentals
- Inventory management
- Quest system
- Death and respawning

**Levels 6-10: Social Features**
- Adding friends
- Party system
- Trading with players
- Guild introduction
- Voice chat

**Levels 11-20: Advanced Systems**
- Crafting professions
- Marketplace usage
- Skill trees and specialization
- Dungeon system
- World bosses

**Levels 21-30: Endgame Preparation**
- Territory control
- Guild warfare
- Advanced crafting
- Rare resource farming
- Build optimization

**Level 31+: Self-Directed**
- No more forced tutorials
- Optional help tooltips
- Advanced guides in menu

### 10.3 Contextual Tooltips

**Just-In-Time Learning:**
- Appears when relevant (e.g., "Guild" tooltip when near guild recruiter)
- Unobtrusive (can be dismissed or ignored)
- Reappears if player struggles
- Can be disabled in settings

**Example Tooltips:**
```
💡 New Feature Unlocked!
You can now join a guild! Guilds work together to control territory and complete group challenges.

[Learn More] [Dismiss]
```

### 10.4 Help System

**In-Game Encyclopedia:**
- Searchable knowledge base
- Categories: Classes, Abilities, Items, Locations, Quests
- Video guides (embedded tutorials)
- Community tips section

**Mentor System:**
- Experienced players can volunteer as mentors
- New players can request mentor
- Mentor sees "Help Needed" icon on map
- Rewards for helping (cosmetics, reputation)

---

## 11. Difficulty Balancing

### 11.1 Difficulty Curves

**Level Progression Difficulty:**
```
Levels 1-10:   Easy - Learning mechanics
Levels 11-20:  Moderate - Applying skills
Levels 21-30:  Challenging - Strategy required
Levels 31-40:  Hard - Mastery needed
Levels 41-50:  Very Hard - Endgame preparation
Levels 51-60:  Expert - Endgame content
```

**Enemy Scaling:**
- Same-level enemy: Balanced fight (60% win rate)
- +1-2 levels: Challenging (+25% difficulty)
- +3-4 levels: Very hard (+50% difficulty)
- +5+ levels: Avoid or group up (+100% difficulty)
- -1-3 levels: Easy farming
- -4+ levels: Trivial (reduced rewards)

### 11.2 Solo vs. Group Balance

**Solo Content:**
- Story quests balanced for solo
- World exploration solo-friendly
- Optional challenges for solo players
- Fair rewards for solo play

**Group Content:**
- Dungeons require 3-5 players
- World bosses require 10-50 players
- Guild activities require coordination
- Significantly better rewards for group content

**Scaling:**
- Some quests scale to party size
- Enemy health/damage adjusts
- Loot quantity increases with more players

### 11.3 Economy Balance

**Currency Influx Sources:**
- Quest rewards: 10-1000 gold
- Enemy drops: 1-50 gold
- Selling items: Variable
- Daily rewards: 100-500 gold

**Currency Sinks:**
- Repairs: 5-10% of income
- Consumables: 10-20% of income
- Skill respec: 1000 gold
- Guild upgrades: Collective effort
- Mount purchases: 10,000-100,000 gold
- Cosmetics: 500-50,000 gold

**Target:** Players have enough for essentials, but meaningful choices for luxuries

### 11.4 PvP Balance

**Class Balance Philosophy:**
- No hard counters (no 100% win/loss matchups)
- Skill > gear > level
- Each class has strengths and weaknesses
- Regular balance patches based on data

**Territory Control Balance:**
- Smaller guilds can hold smaller territories
- Large guilds have more responsibilities
- Defender advantage (20% stat boost in owned territory)
- Attack windows prevent 24/7 defense requirement

**Rating System:**
- ELO-based matchmaking for competitive modes
- Seasonal rankings with rewards
- Fair matches (± 100 rating points)

### 11.5 Reward Pacing

**Short-Term Rewards (Minutes):**
- Quest completions
- Enemy kills
- Resource gathering

**Medium-Term Rewards (Hours):**
- Level ups
- Equipment upgrades
- Skill unlocks

**Long-Term Rewards (Days/Weeks):**
- Rare item drops
- Achievement completions
- Reputation ranks

**Prestige Rewards (Months):**
- Max level attainment
- Legendary items
- Guild accomplishments
- Leaderboard positions

---

## Conclusion

This design document provides a comprehensive blueprint for Reality MMO Layer's game design and UI/UX. The design prioritizes:

- **Accessibility:** Ensuring all players can enjoy the game regardless of ability
- **Clarity:** Clear visual and audio communication of game state
- **Comfort:** Vision Pro-optimized for extended play sessions
- **Engagement:** Rewarding short and long-term play
- **Social:** Encouraging cooperation and community

The spatial design leverages Vision Pro's unique capabilities while respecting player comfort and real-world safety. The progression systems provide long-term engagement, while the UI/UX ensures players can easily access all features.

---

**Next Document:**
- IMPLEMENTATION_PLAN.md - Detailed development roadmap and milestones
