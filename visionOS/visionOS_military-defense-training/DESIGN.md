# Design Specifications: Military Defense Training for visionOS

## 1. Spatial Design Principles

### 1.1 Core Design Philosophy

**Mission Statement**: Create an immersive training environment that balances hyper-realism with usability, ensuring warfighters can focus on combat skills rather than interface mechanics.

**Design Pillars**:
1. **Combat Realism**: Every visual and interaction should mirror real combat conditions
2. **Spatial Clarity**: 3D interfaces must be instantly understandable under stress
3. **Minimal Distraction**: UI fades away during critical moments
4. **Tactical Feedback**: Immediate, clear feedback for all actions
5. **Accessibility**: Effective for all skill levels and physical abilities

### 1.2 visionOS Spatial Ergonomics

```
Spatial Layout Zones:

     Head Level (Eye Height: 1.7m)
     ┌─────────────────────────────┐
     │   Critical Info Only        │  ← Eye level ± 5°
     └─────────────────────────────┘

     Comfort Zone (10-15° below)
     ┌─────────────────────────────┐
     │   Primary UI Elements       │  ← Main interaction area
     │   HUD, Menus, Prompts       │
     └─────────────────────────────┘

     Extended Zone (15-30° below)
     ┌─────────────────────────────┐
     │   Secondary Info            │  ← Maps, objectives, inventory
     └─────────────────────────────┘

     Peripheral (±60° horizontal)
     ├───────────────────────────┤
     │  Status indicators         │  ← Ammo, health, compass
     └───────────────────────────┘

Depth Zones:
- 0.5m - 1.0m: Interactive UI (buttons, controls)
- 1.0m - 3.0m: Informational displays (maps, briefings)
- 3.0m - 10m: Tactical visualization (terrain models)
- 10m+: Combat simulation space
```

### 1.3 Hit Target Specifications

```yaml
Minimum_Interactive_Sizes:
  Buttons: 60pt × 60pt
  Tap_Targets: 44pt × 44pt (with 60pt spacing)
  3D_Objects: 0.1m minimum dimension
  Selection_Tolerance: ±15° gaze cone

Depth_Separation:
  Layered_UI: 0.3m minimum between layers
  Object_Spacing: 0.5m for discrete 3D elements
  Menu_Depth: 0.15m from parent surface
```

## 2. Window Layouts and Configurations

### 2.1 Mission Control Window (Primary Interface)

```
┌─────────────────────────────────────────────────────┐
│  [Classification Banner: SECRET//NOFORN]            │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────┐ │
│  │              │  │              │  │          │ │
│  │  Featured    │  │  Recent      │  │ Warrior  │ │
│  │  Training    │  │  Sessions    │  │ Profile  │ │
│  │  Scenarios   │  │              │  │          │ │
│  │  [3D Icon]   │  │  • Urban Ops │  │ Rank:    │ │
│  │              │  │  • Desert    │  │ Name:    │ │
│  │              │  │  • CQB       │  │ Unit:    │ │
│  └──────────────┘  └──────────────┘  └──────────┘ │
│                                                     │
│  ┌──────────────────────────────────────────────┐  │
│  │         Available Scenarios                   │  │
│  │  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐│  │
│  │  │ Urban  │ │Mountain│ │ Desert │ │Maritime││  │
│  │  │ [IMG]  │ │ [IMG]  │ │ [IMG]  │ │ [IMG]  ││  │
│  │  │ Easy   │ │ Medium │ │ Hard   │ │ Expert ││  │
│  │  └────────┘ └────────┘ └────────┘ └────────┘│  │
│  └──────────────────────────────────────────────┘  │
│                                                     │
│  [Start Training]  [View Analytics]  [Settings]    │
│                                                     │
├─────────────────────────────────────────────────────┤
│  [Classification Banner: SECRET//NOFORN]            │
└─────────────────────────────────────────────────────┘

Dimensions: 1000pt × 700pt
Material: .ultraThinMaterial with dark military gradient
Position: Center of user's view, 1.5m distance
```

### 2.2 Mission Briefing Window

```
┌────────────────────────────────────────────────────────┐
│  Mission Briefing - Urban Assault                      │
│  [CLOSE]                              [START MISSION]  │
├────────────────────────────────────────────────────────┤
│                                                        │
│  ┌──────────────────┐  ┌──────────────────────────┐  │
│  │                  │  │  OBJECTIVE                 │  │
│  │  [3D Terrain]    │  │  1. Secure building       │  │
│  │  [Rotating Map]  │  │  2. Extract HVT           │  │
│  │                  │  │  3. Exfiltrate            │  │
│  │  Tap to Explore  │  │                           │  │
│  └──────────────────┘  │  ENEMY FORCES             │  │
│                        │  - 15-20 Infantry         │  │
│  MISSION DETAILS       │  - Light vehicles         │  │
│  Duration: 30-45 min   │  - Possible sniper        │  │
│  Difficulty: ★★★☆☆    │                           │  │
│  Environment: Urban    │  SUPPORT AVAILABLE        │  │
│  Weather: Clear        │  - Air support (CAS)      │  │
│  Time: 1400 hours      │  - QRF on standby         │  │
│                        │  - Medical evacuation     │  │
│  LOADOUT               └──────────────────────────┘  │
│  ┌────────────────────────────────────────────────┐  │
│  │ [M4A1] [M9] [Frags×2] [Smoke×2] [Med Kit]     │  │
│  │ [Customize Loadout]                            │  │
│  └────────────────────────────────────────────────┘  │
│                                                        │
│  [◄ Previous Mission]              [Next Mission ►]   │
└────────────────────────────────────────────────────────┘

Dimensions: 900pt × 650pt
Material: Dark glass with military HUD aesthetic
Features: Interactive 3D terrain preview (tap to expand to volume)
```

### 2.3 After Action Review Window

```
┌───────────────────────────────────────────────────────────┐
│  After Action Review - Mission Complete                   │
│  [SAVE]  [EXPORT]  [REPLAY]                     [CLOSE]  │
├───────────────────────────────────────────────────────────┤
│                                                           │
│  ┌─────────────────────┐    PERFORMANCE SUMMARY          │
│  │                     │    ┌──────────────────────────┐ │
│  │   Mission Success   │    │ Tactical Score:    850   │ │
│  │        ✓            │    │ Accuracy:           78%  │ │
│  │                     │    │ Decision Speed:    2.3s  │ │
│  │   Grade: B+         │    │ Objectives:        3/3   │ │
│  │   Score: 850/1000   │    │ Casualties:         0    │ │
│  │                     │    │ Enemies Engaged:   18    │ │
│  └─────────────────────┘    └──────────────────────────┘ │
│                                                           │
│  STRENGTHS                   AREAS FOR IMPROVEMENT        │
│  ┌─────────────────────┐    ┌──────────────────────────┐ │
│  │ ✓ Cover usage       │    │ ⚠ Slow target acquisition│ │
│  │ ✓ Team coordination │    │ ⚠ Ammo management       │ │
│  │ ✓ Objective speed   │    │ ⚠ Exposure to threats   │ │
│  └─────────────────────┘    └──────────────────────────┘ │
│                                                           │
│  KEY MOMENTS                                              │
│  ┌───────────────────────────────────────────────────┐   │
│  │ [00:03:45] ⚠ Nearly exposed to sniper              │   │
│  │            Better scan before crossing             │   │
│  │                                                    │   │
│  │ [00:12:20] ✓ Excellent flanking maneuver          │   │
│  │            Surprise attack neutralized enemy squad │   │
│  │                                                    │   │
│  │ [00:24:10] ⚠ Objective secured but exposed        │   │
│  │            Should have established security first  │   │
│  └───────────────────────────────────────────────────┘   │
│                                                           │
│  RECOMMENDED TRAINING                                     │
│  • Target Acquisition Drills                             │
│  • Fire Discipline Training                              │
│  • Tactical Movement Under Fire                          │
│                                                           │
│  [View Detailed Analytics]  [Replay Mission]  [Continue] │
└───────────────────────────────────────────────────────────┘

Dimensions: 1200pt × 800pt
Features:
- Performance graphs
- Timeline scrubbing for replay
- AI-generated recommendations
```

## 3. Volume Designs (3D Bounded Spaces)

### 3.1 Tactical Planning Volume

```
     ┌─────────────────────────────────┐
    ╱                                 ╱│
   ╱     Tactical Planning Volume    ╱ │
  ╱                                 ╱  │
 ╱─────────────────────────────────╱   │
│                                 │    │
│    ╔═══════════════════════╗   │    │
│    ║                       ║   │   ╱
│    ║   [3D Terrain Map]    ║   │  ╱
│    ║                       ║   │ ╱
│    ║   • Enemy positions   ║   │╱
│    ║   • Friendly forces   ║   │
│    ║   • Objectives        ║   │
│    ║                       ║   │
│    ║   [Rotate to explore] ║   │
│    ║                       ║   │
│    ╚═══════════════════════╝   │
│                                 │
│  [Layers] [Routes] [Intelligence]│
└─────────────────────────────────┘

Size: 1.5m × 1.0m × 1.5m (adjustable)
Content: Interactive 3D battlefield terrain
Interactions:
  - Two-hand rotation
  - Pinch-to-zoom
  - Tap to place waypoints
  - Drag to draw routes
```

#### Tactical Planning Features

```swift
// Layer System
enum TacticalLayer {
    case terrain        // Base 3D terrain
    case intelligence   // Enemy positions, threats
    case friendly       // Blue force positions
    case objectives     // Mission goals
    case routes         // Planned movement paths
    case fireSupport    // Artillery/air strike zones
    case danger         // IED, mines, hazards
}

// Visual Representation
Terrain:      Realistic 3D heightmap with textures
Enemy:        Red translucent markers (infantry, vehicles)
Friendly:     Blue markers with unit symbols
Objectives:   Green glowing waypoints
Routes:       Animated dotted lines
Fire Support: Orange/red circles with radius
Danger:       Yellow warning symbols
```

### 3.2 Weapon Inspection Volume

```
     ┌─────────────────────────┐
    ╱                         ╱│
   ╱   Weapon Configuration  ╱ │
  ╱                         ╱  │
 ╱─────────────────────────╱   │
│                         │    │
│   ┌───────────────┐     │    │
│   │               │     │   ╱
│   │  [M4A1 3D]    │     │  ╱
│   │  Rotating     │     │ ╱
│   │               │     │╱
│   └───────────────┘     │
│                         │
│   ATTACHMENTS           │
│   • Optic: [ACOG]       │
│   • Grip: [Vertical]    │
│   • Light: [Surefire]   │
│                         │
│   [Apply] [Reset]       │
└─────────────────────────┘

Size: 0.8m × 0.8m × 0.8m
Content: 3D weapon model with attachments
Interaction: Rotate to inspect, tap to modify
```

## 4. Full Space / Immersive Experiences

### 4.1 Combat Environment Design

#### Visual Hierarchy
```
Immersive Combat Space (Progressive Immersion)

Level 1: Passthrough with Digital Overlay (50% immersion)
├─ Real environment visible
├─ Virtual enemies/objectives overlaid
└─ HUD elements anchored to view

Level 2: Mixed Reality (75% immersion)
├─ Virtual terrain replaces floor
├─ Real furniture becomes cover
├─ Blended lighting

Level 3: Full Virtual (100% immersion)
├─ Complete battlefield environment
├─ No passthrough
└─ Total combat simulation
```

#### Environmental Design

**Urban Combat Environment**
```yaml
Setting: Middle Eastern City
Time: Afternoon (14:00)
Weather: Clear, dusty
Lighting:
  - Harsh sunlight from above
  - Deep shadows in alleyways
  - Light shafts through buildings

Elements:
  - Multi-story buildings (3-5 floors)
  - Narrow streets and alleys
  - Market stalls and vehicles
  - Rubble and debris
  - Functional doors and windows

Color Palette:
  - Sandstone: #D4C5A9
  - Concrete: #8B8B8B
  - Shadow: #2D2D2D
  - Sky: #87CEEB
  - Accent (red): #8B0000 (enemy indicators)
  - Accent (blue): #0047AB (friendly indicators)
```

**Mountain Environment**
```yaml
Setting: Rugged mountainous terrain
Time: Morning (06:00)
Weather: Partly cloudy, wind
Lighting:
  - Low angle sunrise
  - Rim lighting on peaks
  - Atmospheric haze

Elements:
  - Rocky outcrops
  - Sparse vegetation
  - Elevation changes
  - Cave systems
  - Sniper positions

Color Palette:
  - Rock: #5D5D5D
  - Vegetation: #3D5C29
  - Sky: #A8C8E0
  - Snow: #F0F0F0 (high elevations)
```

**Desert Environment**
```yaml
Setting: Open desert with scattered structures
Time: Midday (12:00)
Weather: Clear, heat haze
Lighting:
  - Intense overhead sun
  - Minimal shadows
  - Shimmering heat effects

Elements:
  - Sand dunes
  - Rocky formations
  - Abandoned buildings
  - Vehicle wrecks
  - Dust storms (dynamic)

Color Palette:
  - Sand: #EDC9AF
  - Rock: #8B7355
  - Sky: #00BFFF
  - Heat shimmer: Subtle distortion
```

### 4.2 Heads-Up Display (HUD)

```
                    ┌─────────────────────┐
                    │   Mission Timer     │
                    │      15:23          │
                    └─────────────────────┘

 ┌──────────────┐                        ┌──────────────┐
 │   COMPASS    │                        │   AMMO       │
 │              │                        │              │
 │    N  045°   │                        │  [■■■■■■■□]  │
 │              │                        │   28 / 120   │
 └──────────────┘                        └──────────────┘


 ┌──────────────┐                        ┌──────────────┐
 │   HEALTH     │                        │  OBJECTIVES  │
 │              │                        │              │
 │  [████████]  │                        │  1. ✓ Secure │
 │    100%      │                        │  2. → Extract│
 │              │                        │  3. ○ Exfil  │
 └──────────────┘                        └──────────────┘


                    ┌─────────────────────┐
                    │   Crosshair/Reticle │
                    │         ⊕           │
                    └─────────────────────┘

                    ┌─────────────────────┐
                    │   Threat Indicator  │
                    │    [Enemy: 45m]     │
                    └─────────────────────┘

HUD Specifications:
├─ Opacity: 70% (adjustable)
├─ Color: Green/Yellow/Red (status-dependent)
├─ Font: Monospace military-style
├─ Size: Adaptive to distance
└─ Position: Fixed to viewport (head-locked)
```

#### Dynamic HUD Behavior

```swift
enum HUDState {
    case exploration    // Full HUD visible
    case combat         // Minimal HUD, focus on crosshair
    case planning       // Objective/map focus
    case injured        // Health warnings prominent
}

class HUDManager {
    var currentState: HUDState = .exploration

    func updateHUD(combatIntensity: Float) {
        // Fade non-critical elements during intense combat
        if combatIntensity > 0.7 {
            currentState = .combat
            // Show only: health, ammo, crosshair, threat indicators
        } else {
            currentState = .exploration
            // Show full HUD
        }
    }

    func getHUDOpacity(element: HUDElement) -> Float {
        switch (currentState, element) {
        case (.combat, .crosshair), (.combat, .health), (.combat, .ammo):
            return 1.0
        case (.combat, _):
            return 0.3  // Fade other elements
        default:
            return 0.7
        }
    }
}
```

### 4.3 3D Entity Design

#### Enemy Combatants

```yaml
Infantry_Enemy:
  Model: Humanoid, realistic proportions
  LOD_Levels:
    - LOD0 (0-100m): 50k polygons, full detail
    - LOD1 (100-300m): 15k polygons
    - LOD2 (300-1000m): 5k polygons
    - LOD3 (1000m+): Billboard sprite

  Materials:
    - Clothing: PBR fabric with wear
    - Skin: Subsurface scattering
    - Equipment: Metallic/rough variation

  Animation_States:
    - Idle: Scanning, shifting weight
    - Walk: Tactical movement
    - Run: Sprint with weapon ready
    - Crouch: Low profile movement
    - Prone: Crawling, sniping
    - Combat: Firing, reloading
    - Hit_Reaction: Flinch, fall
    - Death: Ragdoll physics

  Indicators:
    - Awareness: Color-coded outline
      - Grey: Unaware
      - Yellow: Suspicious
      - Orange: Alert
      - Red: Engaging
    - Health: Overhead bar (instructor mode only)
```

#### Weapons

```yaml
M4A1_Rifle:
  Model: Highly detailed 3D
  Polygon_Count: 25k (LOD0)
  Textures:
    - Albedo: 4K
    - Normal: 4K
    - Metallic: 2K
    - Roughness: 2K

  Animations:
    - Idle_Sway: Subtle movement
    - Fire: Muzzle flash, recoil
    - Reload: Magazine swap (3s)
    - Inspect: Weapon check
    - Malfunction: Jam clearing

  Effects:
    - Muzzle_Flash: Particle system
    - Shell_Ejection: Physics-based
    - Smoke: Trailing after fire
    - Sound: 3D positional

  Attachments:
    - Optics: ACOG, Holo, Iron
    - Foregrip: Vertical, Angled
    - Light: Weapon-mounted
    - Laser: Visible/IR
```

#### Environmental Objects

```yaml
Building_Design:
  Style: Modular construction
  Components:
    - Walls: Destructible layers
    - Doors: Interactive (open/breach)
    - Windows: Breakable glass
    - Roof: Accessible via stairs
    - Interior: Furniture, clutter

  Materials:
    - Concrete: Weathered, bullet marks
    - Metal: Rusted, corroded
    - Wood: Splintered, aged
    - Glass: Reflective, transparent

  Interaction:
    - Cover: Automatic detection
    - Destruction: Bullet holes, explosions
    - Entry: Multiple breach points
```

## 5. Interaction Patterns

### 5.1 Weapon Interaction

```
Weapon Readiness:
1. Hands down → Weapon lowered (movement mode)
2. Raise hands → Weapon ready (combat mode)
3. Eye-level aim → Precision targeting

Firing:
1. Look at target (eye tracking)
2. Index finger pinch (trigger)
3. Visual feedback:
   - Muzzle flash
   - Recoil animation
   - Hit markers
   - Shell ejection

Reload:
1. Detect magazine gesture
2. Show reload animation
3. Brief vulnerability period
4. Tactical reload vs. emergency reload

Weapon Switch:
1. Tap weapon on HUD
   OR
2. Voice command: "Switch to pistol"
```

### 5.2 Movement Interaction

```yaml
Locomotion_System:
  Type: Hybrid (teleport + continuous)

  Modes:
    Tactical_Walk:
      - Default movement
      - Joystick/gesture direction
      - Speed: 1.5 m/s
      - Full situational awareness

    Sprint:
      - Hold sprint gesture
      - Speed: 5 m/s
      - Reduced weapon accuracy
      - Stamina drain

    Crouch:
      - Lower hands/body
      - Speed: 0.8 m/s
      - Improved stealth
      - Better cover usage

    Prone:
      - Full lower gesture
      - Speed: 0.3 m/s
      - Maximum stealth
      - Best weapon stability

    Teleport:
      - Long-range repositioning
      - Point and select
      - Brief vulnerability
      - Tactical only (non-combat)

Comfort_Options:
  - Vignette during movement
  - Snap turning (45°)
  - Reduced motion effects
```

### 5.3 Team Command Gestures

```
Squad Commands (Hand Signals):

Point + Forward Wave → "Advance"
Point + Horizontal Sweep → "Suppress Fire"
Point + Hook Gesture → "Flank Right/Left"
Fist Raised → "Hold Position"
Fist + Back Motion → "Fall Back"
Point + Circle → "Rally Here"

Voice Commands:
"Contact front" → Alert teammates
"Fire mission" → Call support
"Medic" → Request medical
"Status" → Squad report
```

### 5.4 Environmental Interaction

```yaml
Cover_System:
  Detection: Automatic
  Visual_Indicator: Highlight nearby cover
  Usage:
    - Move near cover object
    - Auto-duck when appropriate
    - Lean gestures for peeking

Door_Interaction:
  Normal_Open:
    - Look at door
    - Tap gesture
    - Smooth opening animation

  Breach:
    - Approach door
    - Hold breach gesture
    - Explosive/kick option
    - Dramatic entry

Object_Manipulation:
  Pickup: Pinch + lift gesture
  Throw: Throwing motion (grenades)
  Use: Context-sensitive tap
```

## 6. Visual Design System

### 6.1 Color Palette

```css
/* Primary Colors */
--military-green: #3D5C29;
--tactical-black: #1A1A1A;
--steel-gray: #5D6D7E;

/* Status Colors */
--friendly-blue: #0047AB;
--enemy-red: #8B0000;
--neutral-yellow: #FFA500;
--objective-green: #00FF00;

/* UI Colors */
--ui-background: rgba(20, 20, 20, 0.85);
--ui-border: rgba(100, 100, 100, 0.5);
--ui-text: #E0E0E0;
--ui-text-dim: #A0A0A0;
--ui-accent: #00FF88;

/* Warning Colors */
--warning: #FFB300;
--danger: #D32F2F;
--critical: #C62828;

/* Classification Banners */
--unclassified: #00FF00;
--cui: #00BFFF;
--confidential: #0000FF;
--secret: #FF0000;
--top-secret: #FF8C00;
```

### 6.2 Typography

```swift
enum MilitaryFont {
    static let title = Font.custom("SF Pro", size: 34)
        .weight(.bold)
        .leading(.tight)

    static let headline = Font.custom("SF Mono", size: 24)
        .weight(.semibold)

    static let body = Font.custom("SF Pro", size: 17)
        .weight(.regular)

    static let caption = Font.custom("SF Mono", size: 12)
        .weight(.regular)

    static let hud = Font.custom("SF Mono", size: 16)
        .weight(.medium)
        .monospacedDigit() // For consistent number width

    static let classification = Font.custom("SF Pro", size: 14)
        .weight(.bold)
        .smallCaps()
}

/* Typography Rules */
Headings: Bold, high contrast
Body: Regular weight, readable
HUD: Monospace for alignment
Numbers: Monospaced digits
Classification: Small caps, bold
```

### 6.3 Materials and Lighting

```swift
// Glass Materials (visionOS)
enum MilitaryMaterials {
    static let windowBackground: Material = .ultraThinMaterial
        .opacity(0.85)

    static let hudGlass: Material = .thinMaterial
        .opacity(0.7)

    static let tacticalPanel: Material = .regularMaterial
        .opacity(0.9)

    static let combatOverlay: Material = .ultraThinMaterial
        .opacity(0.5)
}

// 3D Materials (RealityKit)
enum CombatMaterials {
    static func enemy() -> PhysicallyBasedMaterial {
        var material = PhysicallyBasedMaterial()
        material.baseColor = .init(tint: .red.withAlphaComponent(0.3))
        material.roughness = 0.8
        material.metallic = 0.1
        return material
    }

    static func terrain() -> PhysicallyBasedMaterial {
        var material = PhysicallyBasedMaterial()
        material.baseColor = .init(tint: .brown)
        material.roughness = 0.9
        material.metallic = 0.0
        return material
    }

    static func weapon() -> PhysicallyBasedMaterial {
        var material = PhysicallyBasedMaterial()
        material.baseColor = .init(tint: .black)
        material.roughness = 0.4
        material.metallic = 0.7
        return material
    }
}
```

#### Lighting Configuration

```swift
// Battlefield Lighting
struct BattlefieldLighting {
    // Primary directional light (sun)
    static let sunlight: DirectionalLight = {
        let light = DirectionalLight()
        light.light.color = .white
        light.light.intensity = 100000 // Lux
        light.shadow = DirectionalLightComponent.Shadow(
            maximumDistance: 100,
            depthBias: 0.01
        )
        return light
    }()

    // Ambient light
    static let ambient: AmbientLight = {
        let light = AmbientLight()
        light.light.color = UIColor(white: 0.8, alpha: 1.0)
        light.light.intensity = 5000
        return light
    }()

    // Dynamic lights (muzzle flash, explosions)
    static func muzzleFlash(position: SIMD3<Float>) -> PointLight {
        let light = PointLight()
        light.light.color = .yellow
        light.light.intensity = 50000
        light.light.attenuationRadius = 5.0
        light.position = position
        return light
    }
}
```

### 6.4 Iconography in 3D Space

```yaml
Icon_Design:
  Style: Flat with subtle depth
  Size: 0.05m - 0.15m (3D space)
  Depth: 0.01m extrusion
  Material: Glowing, translucent

Icon_Types:
  Waypoint:
    Shape: Diamond
    Color: Green
    Animation: Gentle pulse

  Enemy:
    Shape: Triangle (inverted)
    Color: Red
    Animation: Flash when detected

  Friendly:
    Shape: Square
    Color: Blue
    Animation: Static or breathing

  Objective:
    Shape: Star
    Color: Gold
    Animation: Rotating slowly

  Danger:
    Shape: Exclamation
    Color: Yellow/Red
    Animation: Rapid pulse

  Item:
    Shape: Hexagon
    Color: White
    Animation: Gentle bob
```

## 7. User Flows and Navigation

### 7.1 Primary User Flow

```
App Launch
    ↓
Security Check (CAC/Biometric)
    ↓
┌─────────────────────┐
│  Mission Control    │ ← Main Window
│  (Window)           │
└─────────────────────┘
         ↓
    [Select Scenario]
         ↓
┌─────────────────────┐
│  Mission Briefing   │ ← Briefing Window
│  (Window)           │
└─────────────────────┘
         ↓
    [Plan Mission]
         ↓
┌─────────────────────┐
│  Tactical Planning  │ ← 3D Volume
│  (Volume)           │
└─────────────────────┘
         ↓
    [Start Training]
         ↓
┌─────────────────────┐
│  Combat Environment │ ← Immersive Space
│  (Immersive)        │
└─────────────────────┘
         ↓
    [Mission Complete]
         ↓
┌─────────────────────┐
│  After Action       │ ← Review Window
│  (Window)           │
└─────────────────────┘
         ↓
    [Continue] → Back to Mission Control
```

### 7.2 Navigation Patterns

```swift
// Navigation Manager
@Observable
class NavigationManager {
    enum Screen {
        case missionControl
        case briefing(Scenario)
        case planning(Scenario)
        case combat(Scenario)
        case afterAction(TrainingSession)
        case settings
    }

    var currentScreen: Screen = .missionControl
    var navigationStack: [Screen] = []

    func navigate(to screen: Screen) {
        navigationStack.append(currentScreen)
        currentScreen = screen
    }

    func goBack() {
        if let previous = navigationStack.popLast() {
            currentScreen = previous
        }
    }
}
```

### 7.3 In-Combat Quick Access

```
Combat Pause Menu:
┌────────────────────────┐
│   Mission Paused       │
│                        │
│  [Resume]              │
│  [Restart Mission]     │
│  [Change Loadout]      │
│  [Settings]            │
│  [Abort Mission]       │
│                        │
└────────────────────────┘

Access: Palm-up gesture + look at hand
```

## 8. Accessibility Design

### 8.1 Visual Accessibility

```yaml
High_Contrast_Mode:
  UI_Elements:
    - Background: Pure black (#000000)
    - Foreground: Pure white (#FFFFFF)
    - Accent: Bright yellow (#FFFF00)

  Borders:
    - Thickness: 4pt (doubled)
    - Color: High contrast

  Text:
    - Size: 150% default
    - Weight: Bold
    - Shadow: Strong drop shadow

Color_Blind_Support:
  Protanopia:
    - Red → Blue gradient
    - Green remains
    - Enemy: Blue/Purple

  Deuteranopia:
    - Red/Green → Blue/Yellow
    - Enemy: Purple
    - Friendly: Yellow

  Tritanopia:
    - Blue → Green
    - Yellow → Red
    - Adjusted palette
```

### 8.2 Audio Accessibility

```yaml
Visual_Indicators_for_Audio:
  Gunfire:
    - Direction indicator on HUD
    - Pulse effect from direction

  Footsteps:
    - Proximity circles
    - Directional arrows

  Voice_Comms:
    - Subtitles
    - Speaker identification
    - Color-coded by role

  Explosions:
    - Screen flash
    - Radius indicator
```

### 8.3 Motor Accessibility

```yaml
Simplified_Controls:
  Auto_Aim:
    - Sticky targeting
    - Aim assistance
    - Larger hit boxes

  Reduced_Gestures:
    - Tap instead of pinch
    - Voice commands priority
    - Dwell-based selection

  Assistance:
    - Auto-reload
    - Auto-cover
    - AI teammate support
```

## 9. Error States and Loading Indicators

### 9.1 Loading States

```
Initial Load:
┌─────────────────────────┐
│                         │
│   [Military Logo]       │
│                         │
│   Loading Mission...    │
│   [████████░░] 80%      │
│                         │
│   Preparing terrain     │
│                         │
└─────────────────────────┘

In-Mission Load:
┌─────────────────────────┐
│  ⟳  Loading checkpoint  │
└─────────────────────────┘
(Minimal overlay, semi-transparent)

Asset Streaming:
- Seamless background loading
- No interruption to gameplay
- Priority: Visible assets first
```

### 9.2 Error States

```
Network Error:
┌─────────────────────────────┐
│   ⚠ Connection Lost         │
│                             │
│   Training will continue    │
│   in offline mode.          │
│                             │
│   Performance data will     │
│   sync when reconnected.    │
│                             │
│   [OK]  [Retry Connection]  │
└─────────────────────────────┘

Mission Failed:
┌─────────────────────────────┐
│   ✗ Mission Failed          │
│                             │
│   All objectives eliminated │
│                             │
│   Time: 15:30               │
│   Enemies: 12/18            │
│                             │
│   [Retry]  [Review]  [Exit] │
└─────────────────────────────┘

System Error:
┌─────────────────────────────┐
│   ⚠ System Error            │
│                             │
│   Training simulation       │
│   encountered an error.     │
│                             │
│   Error Code: SIM-2045      │
│                             │
│   [Report]  [Restart]       │
└─────────────────────────────┘
```

### 9.3 Empty States

```
No Scenarios Available:
┌─────────────────────────────┐
│                             │
│   📦 No Scenarios           │
│                             │
│   Download scenarios from   │
│   the training library.     │
│                             │
│   [Browse Library]          │
│                             │
└─────────────────────────────┘

No Training History:
┌─────────────────────────────┐
│                             │
│   📊 No Training Data       │
│                             │
│   Complete a training       │
│   session to see analytics. │
│                             │
│   [Start First Mission]     │
│                             │
└─────────────────────────────┘
```

## 10. Animation and Transition Specifications

### 10.1 UI Transitions

```swift
// Window Transitions
enum Transition {
    static let windowAppear: Animation = .spring(
        response: 0.5,
        dampingFraction: 0.8
    )

    static let windowDismiss: Animation = .easeOut(
        duration: 0.3
    )

    static let sceneTransition: Animation = .easeInOut(
        duration: 1.0
    )

    static let combatFeedback: Animation = .spring(
        response: 0.2,
        dampingFraction: 0.6
    )
}

// Usage
.transition(.asymmetric(
    insertion: .scale.combined(with: .opacity),
    removal: .opacity
))
.animation(Transition.windowAppear, value: isShown)
```

### 10.2 Combat Animations

```yaml
Weapon_Animations:
  Fire:
    Duration: 0.1s
    Keyframes:
      - 0.0s: Rest position
      - 0.05s: Maximum recoil
      - 0.1s: Return to rest
    Easing: Ease-out

  Reload:
    Duration: 3.0s
    Keyframes:
      - 0.0s: Start
      - 0.5s: Magazine release
      - 1.0s: Magazine drop
      - 1.5s: New magazine grab
      - 2.5s: Magazine insert
      - 3.0s: Bolt release
    Easing: Linear with pauses

  Weapon_Switch:
    Duration: 0.8s
    Keyframes:
      - 0.0s: Lower current weapon
      - 0.4s: Weapons swapped
      - 0.8s: Raise new weapon
    Easing: Ease-in-out

Character_Animations:
  Walk:
    Duration: 1.0s (loop)
    Speed: Adaptive to velocity

  Run:
    Duration: 0.6s (loop)
    Speed: Adaptive to velocity

  Death:
    Duration: 2.0s
    Type: Ragdoll physics
    Settling: 5.0s
```

### 10.3 Environmental Effects

```yaml
Particle_Systems:
  Muzzle_Flash:
    Particles: 50-100
    Duration: 0.1s
    Size: 0.1m - 0.3m
    Color: Yellow to orange
    Emission: Cone, 30°

  Smoke:
    Particles: 500-1000
    Duration: 5.0s
    Size: 0.5m - 2.0m
    Color: Gray with alpha
    Emission: Continuous

  Explosion:
    Particles: 1000-2000
    Duration: 3.0s
    Size: 1.0m - 10.0m
    Color: Orange/red/black
    Emission: Sphere burst

  Dust_Impact:
    Particles: 100-200
    Duration: 0.5s
    Size: 0.05m - 0.2m
    Color: Brown/tan
    Emission: Impact point
```

## 11. Performance Budget

```yaml
Rendering_Budget:
  Frame_Rate: 120fps (8.3ms per frame)
  Resolution: 8K per eye
  Draw_Calls: < 2000 per frame
  Polygons_On_Screen: < 5M triangles
  Texture_Memory: < 2GB active

Frame_Time_Budget:
  Rendering: 5ms
  Physics: 1ms
  AI: 1ms
  Animation: 0.5ms
  Audio: 0.3ms
  UI: 0.5ms
  Overhead: 0.5ms
  Total: 8.3ms

Asset_Budget:
  Scene_Size: < 500MB
  Texture_Atlas: 4K maximum
  Model_Complexity: LOD based
  Audio_Files: Compressed, streamed
```

---

## Summary

This design specification provides:

1. **Spatial Design Principles**: visionOS-native ergonomics and hit targets
2. **Complete UI System**: Windows, volumes, and immersive spaces
3. **Visual Language**: Military-themed color palette, typography, materials
4. **Interaction Patterns**: Gestures, voice, eye tracking, hand tracking
5. **3D Environments**: Detailed battlefield scenarios with realistic lighting
6. **HUD Design**: Context-aware heads-up display
7. **Navigation Flows**: Complete user journey from briefing to combat
8. **Accessibility**: Support for visual, auditory, and motor accommodations
9. **Animations**: Smooth transitions and realistic combat effects
10. **Performance**: Optimized for 120fps on Apple Vision Pro

The design balances combat realism with spatial computing best practices, ensuring an immersive yet usable training experience for military personnel.
