# City Builder Tabletop - Game Design & UI/UX Specifications

## Document Overview
Comprehensive game design document and UI/UX specifications for City Builder Tabletop, covering gameplay loops, player progression, spatial UI design, and user experience patterns.

---

## 1. Game Design Document (GDD)

### 1.1 Core Concept

**Elevator Pitch**: "Transform any table into a living miniature city where you can watch thousands of tiny citizens live their daily lives, all while building and managing the metropolis of your dreams."

**Core Pillars**:
1. **Tactile City Building** - Natural, intuitive spatial construction
2. **Living Simulation** - Watch individual citizens with real behaviors
3. **Strategic Depth** - Balance economics, happiness, and infrastructure
4. **Collaborative Creation** - Build cities together with others

### 1.2 Target Audience

**Primary Audience**: Strategy game enthusiasts (ages 18-45)
- Fans of SimCity, Cities: Skylines, Anno series
- Enjoy sandbox building and creative freedom
- Appreciate deep simulation systems

**Secondary Audience**: Urban planning students & professionals (ages 22-50)
- Use for learning and visualization
- Value realistic simulation
- Professional presentation needs

**Tertiary Audience**: Families and educators (ages 10+)
- Educational tool for STEM learning
- Collaborative family experience
- Safe, non-violent content

---

## 2. Core Gameplay Loop

### 2.1 Minute-to-Minute Loop

```
Plan → Build → Observe → Optimize → Repeat

1. PLAN (30s-1m)
   - Survey available space
   - Decide what to build next
   - Check budget and resources

2. BUILD (1-2m)
   - Place buildings with natural gestures
   - Draw roads connecting infrastructure
   - Designate zones for growth

3. OBSERVE (2-5m)
   - Watch citizens move in
   - See traffic patterns emerge
   - Monitor city statistics

4. OPTIMIZE (1-3m)
   - Identify problems (traffic jams, unhappiness)
   - Redesign inefficient areas
   - Improve infrastructure
```

### 2.2 Session Loop (30-60 minutes)

```
1. Session Start (5m)
   - Load existing city or start new
   - Review current state and goals
   - Plan session objectives

2. Major Construction Phase (15-20m)
   - Expand residential areas
   - Add commercial districts
   - Build infrastructure

3. Problem Solving Phase (10-15m)
   - Address citizen complaints
   - Fix traffic congestion
   - Balance budget

4. Growth Phase (10-15m)
   - Watch city population grow
   - Unlock new building types
   - Expand to new areas

5. Session End (5m)
   - Review statistics
   - Set goals for next session
   - Save progress
```

### 2.3 Long-Term Progression (10-50 hours)

```
PHASE 1: VILLAGE (0-2 hours)
- Population: 0 → 500
- Buildings: Basic houses, shops, roads
- Goal: Establish sustainable small town

PHASE 2: TOWN (2-8 hours)
- Population: 500 → 2,500
- Buildings: Apartments, offices, services
- Goal: Develop diverse economy

PHASE 3: CITY (8-20 hours)
- Population: 2,500 → 10,000
- Buildings: Towers, industrial, transit
- Goal: Manage complex urban systems

PHASE 4: METROPOLIS (20-50 hours)
- Population: 10,000 → 50,000+
- Buildings: Specialized districts, landmarks
- Goal: Create efficient, happy megacity

PHASE 5: SANDBOX (Endless)
- Unlimited creative building
- Scenario challenges
- Multiplayer collaboration
```

---

## 3. Player Progression Systems

### 3.1 Unlocking System

**Progression Mechanic**: Population milestones unlock new content

| Population | Unlocks |
|------------|---------|
| 0 | Basic houses, dirt roads, small shops |
| 100 | Improved houses, paved roads, parks |
| 500 | Apartments, offices, fire station |
| 1,000 | High-rises, hospital, police station |
| 2,500 | Transit systems, large commercial |
| 5,000 | Industrial complexes, university |
| 10,000 | Skyscrapers, airport, specialized districts |
| 25,000+ | Landmarks, advanced infrastructure |

### 3.2 Achievement System

**Categories**:

1. **Builder Achievements**
   - "First Home" - Place first residential building
   - "Road Warrior" - Build 10km of roads
   - "Skyline" - Have 100 buildings in city
   - "Megalopolis" - Reach 50,000 population

2. **Economic Achievements**
   - "In the Black" - First profitable month
   - "Millionaire Mayor" - $1M in treasury
   - "Zero Unemployment" - < 1% unemployment
   - "Economic Boom" - 20% GDP growth

3. **Citizen Happiness**
   - "Happy Town" - 80% average happiness
   - "Paradise" - 95% average happiness
   - "Zero Crime" - < 0.5% crime rate
   - "Green City" - < 10% pollution

4. **Engineering Achievements**
   - "Traffic Master" - Zero traffic jams
   - "Grid Perfection" - Perfect grid layout
   - "Transit King" - 50% public transit usage
   - "Sustainable" - 100% renewable energy

### 3.3 Skill Development

**Player Skills Developed**:
- Urban planning fundamentals
- Resource management
- Problem-solving under constraints
- Long-term strategic thinking
- Spatial reasoning

---

## 4. Level Design Principles

### 4.1 Surface Adaptation

**Design Philosophy**: "The city adapts to your space"

**Small Surface (0.5m × 0.5m)**: Compact city
- Dense vertical building
- Efficient road networks
- Focus on optimization

**Medium Surface (1m × 1m)**: Balanced city
- Mix of density and sprawl
- Detailed districts
- Recommended experience

**Large Surface (2m+ × 2m+)**: Sprawling metropolis
- Multiple districts
- Long-term mega-projects
- Collaborative multiplayer

### 4.2 Starting Scenarios

**Tutorial City**:
- Pre-placed starter buildings
- Guided objectives
- Learn basic mechanics
- 30-minute experience

**Blank Canvas**:
- Empty landscape
- Full creative freedom
- Standard mode
- No guidance

**Challenge Scenarios**:
- "Island City" - Limited space
- "Mountain Valley" - Terrain constraints
- "Economic Crisis" - Low starting budget
- "Traffic Nightmare" - Fix congestion
- "Natural Disaster" - Recover from disaster

### 4.3 Difficulty Scaling

| Difficulty | Budget | Citizen Demands | Disaster Frequency |
|------------|--------|-----------------|-------------------|
| Relaxed | High starting funds | Low expectations | None |
| Standard | Medium funds | Balanced demands | Rare |
| Challenging | Low funds | High expectations | Occasional |
| Expert | Minimal funds | Very demanding | Frequent |

---

## 5. Spatial Gameplay Design for Vision Pro

### 5.1 Viewing Perspectives

**God View (Default)**:
- Look down at city from above
- Walk around table to view from all angles
- Natural planning perspective
- Comfortable for long sessions

**Street Level View**:
- Lean in close to see citizen detail
- Watch traffic at eye level
- Inspect individual buildings
- Immersive but brief

**Aerial View**:
- Step back for full city overview
- Strategic planning
- Before/after comparisons
- Screenshot/presentation mode

### 5.2 Scale Dynamics

**Zoom Levels**:

```
MACRO SCALE (3m+ viewing distance)
- See entire city at once
- Strategic planning
- District organization
- Visible: City shape, major landmarks

CITY SCALE (1-2m viewing distance)
- Default view
- Building placement
- Road network design
- Visible: Individual buildings, roads

NEIGHBORHOOD SCALE (0.5-1m viewing distance)
- Detailed inspection
- Watch traffic flow
- See citizen groups
- Visible: Cars, citizen clusters

STREET SCALE (< 0.5m viewing distance)
- Maximum detail
- Individual citizen tracking
- Building inspection
- Visible: Individual citizens, building details
```

### 5.3 Comfort-Driven Design

**Ergonomics**:
- Primary interactions at waist-to-chest height
- Avoid prolonged overhead reaching
- Support seated and standing play
- Regular reminder to change position

**Motion Comfort**:
- No camera movement (player moves physically)
- Smooth animations only
- No rapid flashing effects
- Gentle citizen/vehicle motion

**Session Length**:
- Target: 30-60 minute sessions
- Break reminders every 45 minutes
- Quick save/resume
- Comfortable pacing

---

## 6. UI/UX for Spatial Gaming

### 6.1 HUD Design in Spatial Context

**Floating Tool Palette** (Primary UI):
```
Position: Upper left of city, always visible
Size: 30cm × 10cm floating panel
Distance: 50cm from city center

Layout:
┌─────────────────────────────────┐
│ [Zone] [Road] [Build] [Delete] │
│ [Info] [Stats] [Speed] [Menu]  │
└─────────────────────────────────┘

Behavior:
- Follow user around table (anchored to city, not user)
- Transparent when behind buildings
- Highlight selected tool
- Haptic feedback on selection
```

**Statistics Panel** (Secondary UI):
```
Position: Upper right of city
Size: 40cm × 30cm floating panel
Distance: 60cm from city center

Content:
┌─────────────────────────────┐
│ CITY STATISTICS             │
│                             │
│ Population:      5,234      │
│ Happiness:       ████░ 82%  │
│ Treasury:        $2.4M      │
│ Employment:      ████░ 91%  │
│                             │
│ [Detailed View] [Graphs]    │
└─────────────────────────────┘

Behavior:
- Can be minimized to icon
- Expands on gaze
- Real-time updates
- Charts animate in
```

**Context Menus**:
```
Position: Above selected building/object
Size: Adaptive to content
Behavior:
- Appears on selection
- Faces user
- Auto-dismisses on new action

Example:
┌──────────────────┐
│ Residential Apt  │
│ ────────────────│
│ Occupancy: 95%   │
│ Happiness: 78%   │
│ ────────────────│
│ [Upgrade]        │
│ [Demolish]       │
└──────────────────┘
```

### 6.2 Visual Feedback Systems

**Building Placement Feedback**:
- **Valid Placement**: Green holographic preview, satisfying "click" sound
- **Invalid Placement**: Red holographic preview, error tone, shake animation
- **Under Construction**: Scaffold animation, progress bar, construction sounds
- **Complete**: Celebratory particle effect, citizens move in

**Zone Indicators**:
- **Residential**: Blue overlay, house icons
- **Commercial**: Yellow overlay, shop icons
- **Industrial**: Orange overlay, factory icons
- **Parks**: Green overlay, tree icons

**Problem Indicators**:
- **Traffic Jam**: Red glow on road segment, car honking sounds
- **Unhappy Citizens**: Floating sad emojis above buildings
- **Fire/Emergency**: Red flashing, siren sounds, emergency vehicles
- **Low Budget**: Treasury panel pulses red
- **Power Outage**: Buildings go dark, warning icon

**Success Indicators**:
- **Population Growth**: "+50 citizens" floats above city
- **Milestone Reached**: Fireworks particle effect, fanfare sound
- **Achievement Unlocked**: Medal appears, satisfying chime
- **Budget Surplus**: Treasury panel glows green

### 6.3 Notification System

**Notification Types**:

1. **Urgent** (Red):
   - Fire outbreak
   - Economic crisis
   - Disaster warning
   - Position: Center, modal, requires acknowledgment

2. **Important** (Yellow):
   - Low budget warning
   - High unemployment
   - Traffic congestion
   - Position: Upper center, dismissible after 5s

3. **Informational** (Blue):
   - Milestone reached
   - New unlock available
   - Achievement earned
   - Position: Lower right, auto-dismiss after 3s

**Notification Panel**:
```
Position: Lower right corner of city
Stacks vertically
Max 3 visible, rest in history

Example:
┌──────────────────────────────┐
│ 🏆 Achievement: "Happy Town" │
│ ⚠️  Traffic congestion on    │
│     Main Street              │
│ ℹ️  Population: 1,000        │
└──────────────────────────────┘
```

### 6.4 Menu System Design

**Main Menu** (Spatial):
```
Floating in front of user
3D layered panels

┌─────────────────────────┐
│   CITY BUILDER         │
│                         │
│   ▶ New City           │
│   ▶ Load City          │
│   ▶ Multiplayer        │
│   ▶ Scenarios          │
│   ▶ Settings           │
│   ▶ Quit               │
└─────────────────────────┘
```

**Pause Menu** (Overlay):
```
Semi-transparent overlay
City visible but dimmed
Quick access to key functions

┌──────────────────┐
│ PAUSED          │
│                  │
│ ▶ Resume        │
│ ▶ Statistics     │
│ ▶ Save          │
│ ▶ Settings       │
│ ▶ Main Menu     │
└──────────────────┘
```

**Building Selection Menu**:
```
Carousel of building types
Rotate with hand swipe
3D preview of building

    [Prev]  BUILDING   [Next]

      [3D Preview]

      Small House
      Cost: $1,000
      Capacity: 4

      [Place] [Info]
```

---

## 7. Audio Design

### 7.1 Music System

**Dynamic Music**: Adapts to city size and activity

**Layers** (Additive):
1. **Base Layer** (Always): Gentle ambient melody
2. **Growth Layer** (>500 pop): Adds uplifting progression
3. **Bustle Layer** (>2,500 pop): Urban rhythm elements
4. **Metropolis Layer** (>10,000 pop): Full orchestration

**Mood Adaptation**:
- **Peaceful**: Soft piano, strings
- **Growth**: Hopeful brass, building melodies
- **Crisis**: Tense strings, urgent percussion
- **Success**: Triumphant fanfare

### 7.2 Spatial Sound Effects

**Positioned Audio** (3D spatial):
- **Traffic**: Car sounds at vehicle positions
- **Construction**: Hammering, drilling at building sites
- **Citizens**: Chatter in populated areas
- **Emergencies**: Sirens from emergency vehicles

**Environmental Audio**:
- **Day**: Birds chirping, gentle breeze
- **Night**: Crickets, distant city hum
- **Weather**: Rain patter, thunder, wind

**UI Audio**:
- **Button Click**: Satisfying click
- **Building Placed**: Construction start sound
- **Road Drawn**: Pavement rolling sound
- **Error**: Gentle negative tone
- **Success**: Positive chime

### 7.3 Audio Accessibility

**Options**:
- Master volume control
- Separate music/SFX/ambient volumes
- Subtitles for all spoken content
- Visual indicators for audio cues
- Spatial audio toggle (for motion sensitivity)

---

## 8. Tutorial & Onboarding Design

### 8.1 First-Time User Experience (FTUE)

**Step 1: Welcome** (30 seconds)
- "Welcome to City Builder Tabletop!"
- Show city appearing on table
- Explain spatial nature of game

**Step 2: Surface Detection** (1 minute)
- "Find a flat surface like a table"
- Scan surface guidance
- Confirm surface selection

**Step 3: Basic Building** (3 minutes)
- "Let's build your first house"
- Pinch gesture tutorial
- Place first residential building
- Watch citizens move in

**Step 4: Road Creation** (2 minutes)
- "Connect your buildings with roads"
- Finger trace gesture tutorial
- Draw first road
- See traffic appear

**Step 5: Zones** (2 minutes)
- "Designate areas for growth"
- Zone selection tutorial
- Create residential zone
- Watch auto-building

**Step 6: Management** (2 minutes)
- "Monitor your city's health"
- Show statistics panel
- Explain key metrics
- Set goals

**Total FTUE**: ~10 minutes to basic competency

### 8.2 Progressive Tutorials

**Unlock-Based Learning**:
- Each new building type has brief explanation
- First time using feature shows tooltip
- Help hints available on demand
- Can skip for experienced players

**Tutorial City Mode**:
- Pre-built starter city
- Guided objectives
- Cannot fail
- Teaches through doing

---

## 9. Difficulty Balancing

### 9.1 Economic Balance

**Starting Budget by Difficulty**:
- Relaxed: $100,000
- Standard: $50,000
- Challenging: $25,000
- Expert: $10,000

**Income/Expense Ratio**:
- Relaxed: Income × 1.5
- Standard: Income × 1.0
- Challenging: Income × 0.8
- Expert: Income × 0.6

### 9.2 Citizen Happiness

**Happiness Factors**:
- Housing Quality: 20%
- Employment: 25%
- Services (schools, hospitals): 20%
- Low Crime: 15%
- Low Pollution: 10%
- Parks/Recreation: 10%

**Difficulty Modifiers**:
- Relaxed: +20% base happiness
- Standard: No modifier
- Challenging: -10% base happiness
- Expert: -20% base happiness

### 9.3 Simulation Speed

**Available Speeds**:
- **Paused**: 0x (full control)
- **Slow**: 0.5x (learning, detailed watching)
- **Normal**: 1x (standard play)
- **Fast**: 2x (waiting for growth)
- **Ultra**: 5x (skip ahead, risky)

**Speed Unlocks**:
- Paused, Slow, Normal: Always available
- Fast: Unlock at 500 population
- Ultra: Unlock at 2,500 population

---

## 10. Accessibility Design

### 10.1 Motor Accessibility

**One-Handed Mode**:
- All gestures doable with one hand
- Tool palette moveable
- Larger touch targets
- Simplified gestures

**Voice Control**:
- Complete game controllable via voice
- Natural language commands
- Voice confirmation for actions

**Controller Support**:
- Full gamepad support
- Remappable controls
- Accessible button layout

### 10.2 Visual Accessibility

**Colorblind Modes**:
- Protanopia (red-blind)
- Deuteranopia (green-blind)
- Tritanopia (blue-blind)
- Zone colors adjusted per mode
- Icon-based indicators in addition to color

**High Contrast Mode**:
- Increased building outlines
- Stronger zone colors
- Enhanced UI borders
- Better text readability

**Text Scaling**:
- 100% (default)
- 150% (readable)
- 200% (large)
- Affects all UI text

### 10.3 Cognitive Accessibility

**Simplified Mode**:
- Reduced complexity
- Fewer citizen needs
- Simplified economics
- More forgiving

**Tooltips**:
- Extensive help system
- Explain every building
- Clarify every metric
- On-demand access

**No Time Pressure**:
- Pause anytime
- No fail states (relaxed mode)
- Save anywhere
- Undo last action

---

## 11. Visual Style Guide

### 11.1 Art Direction

**Style**: "Miniature Realism with Playful Touch"

**Visual Characteristics**:
- Clean, readable geometry
- Slightly stylized proportions
- Warm, inviting color palette
- Subtle cartoon influence
- Detailed textures

**Reference Games**:
- Cities: Skylines (realism)
- SimCity (playfulness)
- Anno 1800 (detail level)

### 11.2 Color Palette

**Primary Colors**:
- **UI Blue**: #2196F3 (primary actions, highlights)
- **Success Green**: #4CAF50 (valid placement, positive)
- **Warning Yellow**: #FFC107 (caution, important info)
- **Error Red**: #F44336 (invalid, urgent)
- **Neutral Gray**: #9E9E9E (disabled, secondary)

**Zone Colors**:
- **Residential**: Light Blue (#64B5F6)
- **Commercial**: Warm Yellow (#FFD54F)
- **Industrial**: Orange (#FF9800)
- **Parks**: Green (#66BB6A)
- **Mixed Use**: Purple (#AB47BC)

**Building Colors**:
- **Residential**: Earth tones (browns, tans, creams)
- **Commercial**: Modern (grays, glass blues)
- **Industrial**: Metallic (steels, dark grays)
- **Infrastructure**: Institutional (blues, whites)

### 11.3 Animation Principles

**Building Construction** (3-5 seconds):
1. Foundation appears (0.5s)
2. Frame builds up (1-2s)
3. Walls fill in (1s)
4. Roof completes (0.5s)
5. Details pop in (0.5s)

**Citizen Movement**:
- Walk speed: 2m/s (in-game scale)
- Smooth interpolation
- Idle animations when stopped
- Turn anticipation

**Traffic Flow**:
- Smooth acceleration/deceleration
- Follow road curves
- Stop at traffic lights
- Collision avoidance

**UI Transitions**:
- Panel slide in/out: 0.3s ease-in-out
- Button press: 0.1s scale down
- Fade in/out: 0.2s
- Number count-ups: 0.5s

---

## 12. Multiplayer UX Design

### 12.1 Collaboration Interface

**Player Indicators**:
- Each player has assigned color
- Colored outline on their selected buildings
- Name tag above their view position
- Transparent avatar showing where they're looking

**Shared Tools**:
- Tool palette visible to all
- Lock tool when player using it
- "Player X is placing building" notification
- Collaborative cursor visible

**Voting System**:
```
Major Decision Required:
┌─────────────────────────────────┐
│ Demolish City Hall?             │
│                                 │
│ ✓ Yes (2) | ✗ No (1)           │
│                                 │
│ [Your Vote]                     │
└─────────────────────────────────┘

Auto-resolves after 30 seconds
Majority wins
Ties = no action
```

### 12.2 Communication

**Spatial Voice Chat**:
- Positional audio (hear from player location)
- Push-to-talk or always-on
- Visual indicator when speaking
- Mute individual players

**Quick Commands**:
- "Look here!" - Draws attention
- "Good idea!" - Positive feedback
- "Wait!" - Hold action
- "Let's vote" - Call for vote

**Text Chat** (Optional):
- Floating chat bubbles
- Minimal, not intrusive
- Preset messages available
- Full keyboard for detailed

### 12.3 Role Assignment

**Optional Roles**:
- **Mayor**: Final say on votes, budget control
- **Residential Planner**: Focus on housing
- **Commercial Developer**: Shops and offices
- **Industrial Manager**: Factories and production
- **Infrastructure Chief**: Roads, utilities, services

**Benefits**:
- Specialized unlock bonuses
- Faster building in role area
- Role-specific statistics
- Organized collaboration

---

## 13. Monetization UX

### 13.1 Base Game Purchase

**Price**: $29.99

**Included Content**:
- Full city builder experience
- Unlimited city saves
- All core building types
- Multiplayer support
- Regular updates

### 13.2 In-App Purchases

**Expansion Packs** ($9.99 each):
- **Disasters Pack**: Earthquakes, floods, tornados, emergency management
- **Transportation Pack**: Airports, train stations, metro systems
- **Green City Pack**: Renewable energy, parks, environmental focus
- **Historical Pack**: Build ancient cities, period-specific buildings

**Season Pass** ($39.99/year):
- All expansion packs
- Exclusive building skins
- Early access to features
- Priority support

**Building Packs** ($2.99 each):
- **Modern Architecture**: Contemporary designs
- **Fantasy Buildings**: Whimsical, imaginative structures
- **Famous Landmarks**: Eiffel Tower, Statue of Liberty, etc.

**UI Design for IAP**:
- Non-intrusive
- Optional content only
- No pay-to-win mechanics
- Preview before purchase
- Clear value proposition

---

## 14. Juice & Game Feel

### 14.1 Satisfying Interactions

**Building Placement**:
- Smooth snap-to-grid (feel magnetic)
- Satisfying "thunk" sound on placement
- Construction animation immediately starts
- Particle effects on completion

**Road Drawing**:
- Smooth trail follows finger
- Satisfying "zip" sound when drawn
- Road materializes with rolling animation
- Traffic immediately appears

**Zone Creation**:
- Area fills with colored overlay
- Boundary snaps to grid
- Zone icon appears with pop
- First building spawns quickly

**Demolition**:
- Building shakes
- Explosion particle effect
- Debris falls
- Satisfying crumble sound

### 14.2 Polish Details

**Ambient Life**:
- Birds fly over city
- Clouds drift slowly
- Trees sway gently
- Day/night cycle gradual

**Micro-Animations**:
- Building windows light up at night
- Vehicles have working headlights
- Citizens wave at each other
- Flags wave in breeze

**Environmental Details**:
- Shadows move with time of day
- Rain creates puddles on roads
- Snow accumulates on roofs
- Seasonal decorations (holidays)

---

This comprehensive design document ensures City Builder Tabletop delivers an engaging, accessible, and polished spatial gaming experience on Vision Pro.
