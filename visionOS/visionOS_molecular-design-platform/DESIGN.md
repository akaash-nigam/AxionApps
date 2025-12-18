# UI/UX Design Specifications: Molecular Design Platform

## Document Overview
This document defines the comprehensive user experience and interface design for the Molecular Design Platform on visionOS.

**Version:** 1.0
**Last Updated:** 2025-11-17
**Design Language:** visionOS Spatial Design
**Status:** Design Phase

---

## Table of Contents
1. [Spatial Design Principles](#spatial-design-principles)
2. [Window Layouts & Configurations](#window-layouts--configurations)
3. [Volume Designs](#volume-designs)
4. [Full Space/Immersive Experiences](#full-space-immersive-experiences)
5. [3D Visualization Specifications](#3d-visualization-specifications)
6. [Interaction Patterns](#interaction-patterns)
7. [Visual Design System](#visual-design-system)
8. [User Flows & Navigation](#user-flows--navigation)
9. [Accessibility Design](#accessibility-design)
10. [Error States & Loading Indicators](#error-states--loading-indicators)
11. [Animation & Transition Specifications](#animation--transition-specifications)

---

## 1. Spatial Design Principles

### 1.1 Core Spatial Principles for Molecular Design

#### Ergonomic Positioning
```
Vertical Positioning:
  ┌─────────────────────┐
  │   Eye Level (0°)    │ ← Reference point
  │                     │
  │   -10° to -15°      │ ← Optimal viewing zone for primary content
  │                     │
  │   -20° to -30°      │ ← Secondary information
  │                     │
  │   Below -30°        │ ← Persistent controls
  └─────────────────────┘
```

**Guidelines:**
- Primary molecular visualizations: 10-15° below eye level
- Control panels: 15-25° below eye level
- Persistent toolbars: Bottom of field of view
- Notifications: Upper peripheral vision

#### Depth Hierarchy
```
Depth Layers (from user):
  0.3m - 0.5m: Critical alerts, modal dialogs
  0.5m - 1.0m: Primary workspace (molecular editing)
  1.0m - 2.0m: Secondary windows (properties, analytics)
  2.0m - 3.0m: Reference materials, documentation
  3.0m - 5.0m: Ambient context, library browsers
```

**Z-Axis Usage:**
- Closer = higher priority/active task
- Further = reference/passive information
- Depth conveys hierarchy naturally

#### Spatial Comfort Zones

**Primary Manipulation Zone** (0.5m - 1.5m)
- Main molecular editing
- Fine detail work
- Active simulations
- Hand tracking optimal

**Reading Zone** (0.8m - 1.8m)
- Text-heavy interfaces
- Property panels
- Analytics dashboards
- Comfortable reading distance

**Ambient Zone** (2.0m - 5.0m)
- Peripheral awareness
- Background processes
- Molecular library
- Collaboration presence

### 1.2 Molecular-Specific Design Principles

#### Scale Awareness
```
Molecular Scale Mapping:
  Real World          →  Virtual Space
  1 Angstrom (1Å)     →  1-2 cm (default)
  10 Angstroms        →  10-20 cm
  100 Angstroms       →  1-2 meters

  User can adjust scale: 0.1x to 10x
```

#### Scientific Accuracy
- Maintain correct atomic proportions
- Accurate bond angles and lengths
- Realistic molecular dynamics
- Validated color schemes (CPK, element-specific)

#### Progressive Disclosure
1. **Level 1**: Simple ball-and-stick model
2. **Level 2**: Add surface/volume representation
3. **Level 3**: Show electron density
4. **Level 4**: Display quantum properties
5. **Level 5**: Full simulation with dynamics

---

## 2. Window Layouts & Configurations

### 2.1 Main Control Panel

```
┌─────────────────────────────────────────────────────────┐
│  Molecular Design Platform        🔍 ⚙️ 👤         ✕   │ ← Title bar
├─────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────────────────────────┐  │
│  │             │  │                                 │  │
│  │   Project   │  │    Molecule Library            │  │
│  │   Tree      │  │    [Grid View]                 │  │
│  │             │  │                                 │  │
│  │  📁 Project │  │  ┌─────┐ ┌─────┐ ┌─────┐       │  │
│  │  └─ Mol-1   │  │  │ H₂O │ │ CO₂ │ │ C₆H₁₂│      │  │
│  │  └─ Mol-2   │  │  └─────┘ └─────┘ └─────┘       │  │
│  │  📁 Sims    │  │                                 │  │
│  │             │  │  [Filters: Name, Formula, MW]   │  │
│  │             │  │                                 │  │
│  └─────────────┘  └─────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
      200pt              600pt
```

**Specifications:**
- **Size**: 800×600pt (default), resizable 600-1200pt width
- **Material**: `.regularMaterial` with vibrancy
- **Position**: User-adjustable, suggested 1.5m, -15°
- **Ornaments**: Top toolbar with quick actions

**Components:**

*Sidebar (200pt)*
- Project hierarchy tree
- Recent molecules
- Saved searches
- Favorites

*Main Area (600pt)*
- Molecule grid (3-4 columns)
- List view option
- Search/filter bar
- Sort controls

### 2.2 Properties Panel

```
┌──────────────────────────────────┐
│  Molecular Properties        ✕  │
├──────────────────────────────────┤
│  Ethanol (C₂H₆O)                │
│                                  │
│  Basic Properties                │
│  ├─ Molecular Weight: 46.07 g/mol│
│  ├─ Formula: C₂H₆O               │
│  └─ Atoms: 9                     │
│                                  │
│  Calculated Properties           │
│  ├─ LogP: -0.31                  │
│  ├─ TPSA: 20.23 Ų                │
│  ├─ H-Bond Donors: 1             │
│  └─ H-Bond Acceptors: 1          │
│                                  │
│  Predicted Properties            │
│  ├─ Solubility: ████████░ 82%   │
│  ├─ Bioavailability: ██████ 65% │
│  └─ Toxicity: ██░░░░░░░ 18%     │
│                                  │
│  [Export] [Calculate More]       │
└──────────────────────────────────┘
```

**Specifications:**
- **Size**: 400×700pt (default)
- **Material**: Glass with high vibrancy
- **Position**: Right side of molecule viewer
- **Behavior**: Auto-opens when molecule selected
- **Updates**: Real-time as molecule edited

### 2.3 Simulation Control Panel

```
┌──────────────────────────────────┐
│  Molecular Dynamics          ✕  │
├──────────────────────────────────┤
│  Simulation Status: ⏸ Paused     │
│                                  │
│  Timeline                        │
│  ├─────────●─────────────────┤  │
│  0ps    5.3ps          10ps      │
│                                  │
│  Parameters                      │
│  ├─ Temperature: 298K            │
│  ├─ Pressure: 1 atm              │
│  ├─ Time Step: 1 fs              │
│  └─ Duration: 10 ps              │
│                                  │
│  Energy: -2,450.3 kJ/mol         │
│  [Live graph]                    │
│  │     ╱╲    ╱╲                 │
│  │   ╱    ╲╱    ╲               │
│  │ ╱              ╲             │
│  └─────────────────────          │
│                                  │
│  [◄◄] [▶] [⏸] [►] [⏹]         │
│                                  │
│  Speed: [0.1x] [1x] [10x] [100x]│
└──────────────────────────────────┘
```

**Specifications:**
- **Size**: 450×650pt
- **Material**: Glass with medium vibrancy
- **Position**: Left side of simulation volume
- **Real-time Updates**: Energy, temperature graphs
- **Playback Controls**: Play, pause, scrub timeline

### 2.4 Analytics Dashboard

```
┌─────────────────────────────────────────────────────────────┐
│  Project Analytics                    📊 📈 📉         ✕   │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────────────────┐  ┌──────────────────────────────┐│
│  │  Pipeline Overview   │  │  Property Distribution      ││
│  │                      │  │                              ││
│  │  Lead                │  │       LogP Distribution     ││
│  │  Optimization: 45%   │  │  Count                      ││
│  │  ████████░░░         │  │    ┃   ▅▆██▅▃              ││
│  │                      │  │    ┃  ▂███████▄▂           ││
│  │  Candidates: 127     │  │    ┗━━━━━━━━━━━━━━━━━━      ││
│  │  Active: 23          │  │    -2  0  2  4  6  8       ││
│  │  Optimized: 8        │  │                              ││
│  └──────────────────────┘  └──────────────────────────────┘│
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Success Rate Trends                                 │  │
│  │  %                                                    │  │
│  │  100┃                               ╱──               │  │
│  │   75┃                     ╱────────╱                 │  │
│  │   50┃           ╱────────╱                           │  │
│  │   25┃   ╱──────╱                                     │  │
│  │    0┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━     │  │
│  │     Jan  Feb  Mar  Apr  May  Jun                     │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

**Specifications:**
- **Size**: 1000×700pt
- **Material**: Glass with low vibrancy
- **Charts**: SwiftUI Charts framework
- **Updates**: Real-time data streaming
- **Export**: PDF, CSV, PNG

---

## 3. Volume Designs

### 3.1 Single Molecule Viewer Volume

```
     ╔═══════════════════════════╗
    ╱                             ╱│
   ╱        Molecule             ╱ │
  ╱         Volume              ╱  │
 ╱                             ╱   │  0.6m cube (default)
╔═══════════════════════════╗     │
║                           ║     │
║         ●───●             ║     │  Molecule centered
║        ╱│    ╲            ║     │  Auto-scaled to fit
║       ● │     ●           ║     ╱
║         ●───●             ║    ╱
║                           ║   ╱
║      [Rotate] [Scale]     ║  ╱
╚═══════════════════════════╝ ╱
```

**Specifications:**
- **Default Size**: 0.6m × 0.6m × 0.6m
- **Range**: 0.3m to 2.0m (user-adjustable)
- **Background**: Transparent
- **Baseplate**: Hidden
- **Lighting**: Three-point lighting (key, fill, rim)
- **Rotation**: Free 3D rotation with gestures
- **Scale**: Auto-fit with manual override

**Controls (Bottom Ornament):**
- Rotation reset
- Auto-fit
- Visualization style selector
- Measurement tools

### 3.2 Protein Structure Volume

```
     ╔═══════════════════════════╗
    ╱                             ╱│
   ╱      Protein Volume         ╱ │
  ╱      (Larger scale)          ╱  │
 ╱                               ╱   │  1.2m cube
╔═══════════════════════════╗       │
║    ╭─────╮                 ║       │
║   ╱  α   ╲                 ║       │
║  │ helix  │   ╭──β──╮      ║       │  Ribbon representation
║   ╲      ╱   │ sheet│      ║       │
║    ╰────╯     ╰─────╯      ║      ╱
║         ╲    ╱             ║     ╱
║          ╰──╯ loop         ║    ╱
║                            ║   ╱
║  [Secondary Structure]     ║  ╱
╚════════════════════════════╝ ╱
```

**Specifications:**
- **Size**: 1.0m - 2.0m (large proteins)
- **Representation**: Ribbon (default), cartoon, surface
- **Color Scheme**: By chain, secondary structure, or residue
- **Active Site**: Highlighted region
- **Interaction**: Select residues, measure distances

### 3.3 Molecular Complex Volume

```
     ╔═══════════════════════════╗
    ╱                             ╱│
   ╱    Docking Complex          ╱ │
  ╱                              ╱  │
 ╱                              ╱   │  1.5m cube
╔═══════════════════════════╗      │
║      Protein               ║      │
║    ┌─────────┐             ║      │
║    │         │  ●──●       ║      │  Protein + Ligand
║    │  Active │  │  │ ←Ligand      │
║    │   Site  │  ●──●       ║     ╱
║    │         │             ║    ╱
║    └─────────┘             ║   ╱
║                            ║  ╱
║  Binding Energy: -45.2 kJ  ║ ╱
╚════════════════════════════╝╱
```

**Specifications:**
- **Components**: Multiple molecules in one volume
- **Color Coding**: Each molecule different color
- **Transparency**: Protein semi-transparent, ligand opaque
- **Interaction**: Drag ligand to re-dock
- **Analysis**: Real-time binding energy calculation

---

## 4. Full Space/Immersive Experiences

### 4.1 Molecular Laboratory Environment

**Mixed Reality Mode**
```
User's View (Mixed Mode):
  ┌──────────────────────────────────────────────┐
  │  Real desk visible                           │
  │                                              │
  │         ╔═══╗                                │
  │    H₂O  ║ ● ║ ← Molecule floating           │
  │         ║●─●║    above desk                 │
  │         ╚═══╝                                │
  │                                              │
  │  [Physical keyboard]  [Coffee mug]          │
  │                                              │
  │  Molecule Library ────┐                      │
  │  ┌────┬────┬────┐     │← Floating at       │
  │  │ CO₂│ CH₄│ NH₃│     │  edge of desk      │
  │  └────┴────┴────┘─────┘                     │
  └──────────────────────────────────────────────┘
```

**Features:**
- Passthrough: Full visibility
- Anchoring: Molecules anchor to desk surface
- Lighting: Match real environment
- Shadows: Cast on real surfaces
- Workflow: Traditional desk work enhanced

**Full Immersion Mode**
```
User's View (Full Immersion):
  ┌──────────────────────────────────────────────┐
  │         Virtual Laboratory Space             │
  │                                              │
  │  ┌────────┐    ●─●        ┌─────────────┐   │
  │  │Controls│    Mol1        │ Properties  │   │
  │  │        │                │ Panel       │   │
  │  │ ▶ Play │       ●─●      │             │   │
  │  │ ⏸ Pause│       Mol2     │ MW: 46.07   │   │
  │  └────────┘                │ LogP: -0.31 │   │
  │                            └─────────────┘   │
  │         Molecule Library                     │
  │  ┌────────────────────────────────────┐      │
  │  │  [20+ molecules in spatial grid]   │      │
  │  └────────────────────────────────────┘      │
  │                                              │
  │  Synthetic floor with grid pattern          │
  └──────────────────────────────────────────────┘
```

**Features:**
- Environment: Synthetic lab (clean, professional)
- Lighting: Controlled, consistent illumination
- Space: 5m radius hemisphere
- Focus: No distractions
- Collaboration: Avatar presence visible

### 4.2 Spatial Layout in Full Immersion

**360° Workspace Organization**
```
                    Forward (0°)
                    └─ Main Workspace
                         ● Molecule

   Left (270°)                        Right (90°)
   └─ Controls                        └─ Properties
      Tools                              Analytics

                    Back (180°)
                    └─ Library
                       Reference
```

**Vertical Organization**
```
  Eye Level + 20°  →  Notifications, alerts
  Eye Level        →  Reference line
  Eye Level - 15°  →  Primary molecule
  Eye Level - 25°  →  Controls, properties
  Eye Level - 40°  →  Persistent toolbar
  Floor Level      →  Molecule library grid
```

### 4.3 Collaborative Space

```
Multi-User Immersive Space:

  User A ← ──────────────── → User B
     👤                         👤
        ╲                     ╱
         ╲     ●───●         ╱
          ╲   ╱│    ╲       ╱
           ● ● │     ●     ●  ← Shared molecule
                ●───●            (both can edit)

         [User A cursor]  [User B cursor]
              ⌖                ⌖
```

**Features:**
- **SharePlay Integration**: Synchronized state
- **Presence Indicators**: See others' gaze and hands
- **Annotation**: Collaborative markup
- **Audio**: Spatial audio for each participant
- **Permissions**: Owner controls edit access

---

## 5. 3D Visualization Specifications

### 5.1 Molecular Representation Styles

#### Ball-and-Stick (Default)
```
Specifications:
  Atoms:
    - Sphere radius: Element VDW radius × 0.3
    - Material: Matte with slight specular
    - Color: CPK color scheme

  Bonds:
    - Cylinder radius: 0.15Å (visual)
    - Length: Actual bond length
    - Material: Matte, colored by atom

  Performance:
    - LOD: 3 levels based on distance
    - Max atoms: 100,000
```

Visual Example:
```
        Oxygen (red)
             ●
            ╱ ╲
           ╱   ╲  ← Bonds (white/colored)
          ╱     ╲
    Carbon      Carbon
      ●           ●
    (gray)      (gray)
```

#### Space-Filling (CPK)
```
Specifications:
  Atoms:
    - Sphere radius: Full VDW radius
    - Material: Glossy with highlights
    - Color: CPK standard

  Bonds:
    - Not visible (atoms touch/overlap)

  Performance:
    - Lower polygon LOD
    - Max atoms: 50,000
```

Visual Example:
```
        ⬤  Oxygen (large, red)
       ╱ ╲
      ╱   ╲
    ⬤     ⬤  Carbon (medium, gray)
   Atoms overlap at bonds
```

#### Ribbon (Proteins)
```
Specifications:
  Secondary Structure:
    - α-helix: Spiral ribbon, 0.3m wide
    - β-sheet: Flat arrow, 0.5m wide
    - Loop: Thin tube, 0.1m wide

  Colors:
    - By chain (default)
    - By secondary structure
    - By residue type
    - By B-factor (mobility)

  Performance:
    - Smooth curves (Catmull-Rom splines)
    - LOD for distant proteins
```

Visual Example:
```
   ╔══════╗
  ║ α-helix ║  ← Spiral ribbon
   ╚══════╝
         ╲
          ╰─────╮  Loop (thin)
                │
           ▬▬▬▬▶  β-sheet (flat arrow)
```

#### Surface Representation
```
Specifications:
  Surface Type:
    - Van der Waals (VDW)
    - Solvent accessible (SAS)
    - Molecular surface (Connolly)

  Material:
    - Semi-transparent (60% opacity)
    - Smooth shading
    - Environment mapping

  Colors:
    - Electrostatic potential
    - Hydrophobicity
    - Solid color

  Performance:
    - Marching cubes algorithm
    - Mesh optimization
    - Max vertices: 500,000
```

### 5.2 Color Schemes

#### CPK (Corey-Pauling-Koltun) - Default
```swift
enum CPKColor {
    static let hydrogen    = Color.white
    static let carbon      = Color.gray
    static let nitrogen    = Color.blue
    static let oxygen      = Color.red
    static let fluorine    = Color.green
    static let chlorine    = Color(hex: "1FF01F") // Bright green
    static let bromine     = Color(hex: "A52A2A") // Brown
    static let iodine      = Color(hex: "940094") // Purple
    static let sulfur      = Color.yellow
    static let phosphorus  = Color.orange

    // Metals
    static let iron        = Color(hex: "E06633")
    static let copper      = Color(hex: "C88033")
}
```

#### By Element Type
```
Nonmetals:    Light colors (H, C, N, O)
Halogens:     Green family (F, Cl, Br, I)
Metals:       Metallic colors (Fe, Cu, Zn)
Noble gases:  Cyan family (He, Ne, Ar)
```

#### By Property
```
Charge:       Red (positive) → Blue (negative)
Hydrophobicity: Orange (hydrophobic) → Blue (hydrophilic)
Temperature:  Blue (cold) → Red (hot)
Energy:       Green (low) → Red (high)
```

### 5.3 Lighting & Materials

#### Three-Point Lighting Setup
```
                  ┌─ Key Light
                  │  (Main illumination, 45° above)
                  │
        ┌─────────┼─────────┐
        │         ↓         │
        │      Molecule     │
    Fill Light ←─   ─→ Rim Light
    (Soften shadows) (Edge highlight)
```

**Specifications:**
```swift
// Key light
DirectionalLight {
    intensity: 1000 lux
    color: .white
    angle: 45° above, 30° left
    shadows: enabled
}

// Fill light
DirectionalLight {
    intensity: 300 lux
    color: Color(white: 0.95) // Slightly warm
    angle: 30° above, 30° right
    shadows: disabled
}

// Rim light
DirectionalLight {
    intensity: 400 lux
    color: Color(white: 1.0, alpha: 0.8)
    angle: Behind and above
    shadows: disabled
}

// Ambient
AmbientLight {
    intensity: 100 lux
    color: .white
}
```

#### Material Specifications

**Atom Materials:**
```swift
// Matte atoms (default)
var atomMaterial: SimpleMaterial {
    var material = SimpleMaterial()
    material.color = .init(tint: elementColor)
    material.roughness = 0.6
    material.metallic = 0.0
    return material
}

// Glossy atoms (space-filling)
var glossyMaterial: SimpleMaterial {
    var material = SimpleMaterial()
    material.color = .init(tint: elementColor)
    material.roughness = 0.2
    material.metallic = 0.1
    return material
}
```

**Bond Materials:**
```swift
var bondMaterial: SimpleMaterial {
    var material = SimpleMaterial()
    material.color = .init(tint: .white)
    material.roughness = 0.7
    material.metallic = 0.0
    return material
}
```

---

## 6. Interaction Patterns

### 6.1 Gaze and Pinch Gestures

#### Atom Selection
```
Sequence:
1. User gazes at atom → Atom highlights (glow effect)
2. User pinches → Atom selects (blue outline)
3. User drags (pinch held) → Atom follows hand
4. User releases pinch → Atom drops at position

Visual Feedback:
  Gaze:    ◉ ← Subtle glow
  Hover:   ◎ ← Brighter glow + scale 1.1x
  Select:  ⦿ ← Blue outline + scale 1.2x
  Drag:    ⊕ ← Follow cursor, semi-transparent
```

#### Bond Creation
```
Sequence:
1. Select first atom (pinch)
2. Drag toward second atom
3. Dotted line appears from atom1 to cursor
4. Hover over atom2 → atom2 highlights
5. Release pinch → Bond created

Visual:
  Atom1 ●─────────  (dotted line follows cursor)
              ⌖

  Atom1 ●─────────● Atom2  (release creates bond)
```

### 6.2 Hand Tracking Gestures

#### Molecular Rotation (Two-Hand)
```
Gesture:
  Left hand pinch at left side of molecule
  Right hand pinch at right side of molecule
  Rotate hands → molecule rotates

Visual Feedback:
    L ⌖              ⌖ R
       ╲   ●───●   ╱
        ╲ ╱│    ╲ ╱
         ● │     ●
           ●───●

  Rotation axis visualized during gesture
```

#### Grab and Move (Full Hand)
```
Gesture:
  Close hand around molecule (grab gesture)
  Move hand → molecule follows
  Open hand → release molecule

Visual:
    ✊ → 🤚
     ↓     ↓
   [●─●]  ●─●
   Grabbed | Released
```

#### Precision Editing (Pinch + Hold)
```
Gesture:
  Pinch atom
  Hold for 1 second → Precision mode activates

Precision Mode:
  - Grid overlay appears
  - Fine movements (0.1Å increments)
  - Coordinate display
  - Snap to grid option

Visual:
  ┌───┬───┬───┐
  │   │ ● │   │ ← Atom snaps to grid
  ├───┼───┼───┤
  │   │   │   │   Coordinates: (1.2, 3.4, 2.1)
  └───┴───┴───┘
```

### 6.3 Voice Commands

#### Basic Commands
```
"Show [molecule name]"        → Open molecule viewer
"Hide properties"              → Close properties panel
"Rotate molecule"              → Auto-rotate animation
"Calculate properties"         → Run property calculation
"Start simulation"             → Begin molecular dynamics
"Pause"                        → Pause current operation
"Export as PDB"                → Export file

Examples:
  User: "Show ethanol"
  → Opens ethanol in viewer

  User: "Change to space-filling"
  → Switches visualization style
```

#### Advanced Commands
```
"Select all carbon atoms"      → Multi-select by element
"Measure distance between atom 5 and atom 12"
"Add hydrogen atom at position x2 y3 z1"
"Optimize geometry"            → Run optimization
"Compare with aspirin"         → Side-by-side view
```

---

## 7. Visual Design System

### 7.1 Color Palette

#### Primary Colors
```
Brand Blue:     #007AFF (SF Symbols blue)
Success Green:  #34C759
Warning Orange: #FF9500
Error Red:      #FF3B30
Info Purple:    #AF52DE
```

#### UI Colors (Adaptive)
```swift
// Light Mode | Dark Mode
Background:  #FFFFFF  |  #000000
Secondary:   #F2F2F7  |  #1C1C1E
Tertiary:    #E5E5EA  |  #2C2C2E
Label:       #000000  |  #FFFFFF
Secondary:   #3C3C43  |  #EBEBF5
Tertiary:    #3C3C43  |  #EBEBF5 (60% opacity)
```

#### Molecular Colors (CPK - Always Same)
```
See Section 5.2 for full CPK color scheme
```

### 7.2 Typography

#### Font System
```swift
// visionOS uses SF Pro (San Francisco)
Title:           .largeTitle  (34pt, Bold)
Headline:        .title       (28pt, Semibold)
Subheadline:     .title2      (22pt, Regular)
Body:            .body        (17pt, Regular)
Caption:         .caption     (12pt, Regular)
Molecular Data:  .monospaced  (14pt, Regular) // For formulas, coordinates
```

#### Text Hierarchy in 3D Space
```
Floating Labels:
  Primary:   Title font, 40pt equivalent at 1m distance
  Secondary: Body font, 28pt equivalent at 1m distance
  Tertiary:  Caption font, 20pt equivalent at 1m distance

Distance Scaling:
  Text automatically scales to remain legible:
  - At 0.5m: Scale 0.7x
  - At 1.0m: Scale 1.0x (base)
  - At 2.0m: Scale 1.4x
  - At 5.0m: Scale 2.5x
```

#### Molecular Formulas
```
Rendering:
  H₂O    → Subscripts properly formatted
  CO₂    → Numbers subscripted
  CH₃⁺   → Charges superscripted

Font: SF Pro with OpenType features
```

### 7.3 Materials and Effects

#### Glass Materials (visionOS)
```swift
// Window backgrounds
.regularMaterial      // Standard glass (default)
.thinMaterial         // More transparent
.thickMaterial        // Less transparent
.ultraThinMaterial    // Very transparent
.ultraThickMaterial   // Very opaque
```

#### Molecular Surface Materials
```swift
// Semi-transparent surface
var surfaceMaterial: PhysicallyBasedMaterial {
    var material = PhysicallyBasedMaterial()
    material.baseColor = .init(tint: .blue)
    material.opacity = 0.4
    material.roughness = 0.3
    material.metallic = 0.0
    material.blending = .transparent(opacity: 0.4)
    return material
}
```

#### Glow Effects
```swift
// Atom hover glow
struct AtomGlowModifier: ViewModifier {
    let isHovered: Bool

    func body(content: Content) -> some View {
        content
            .shadow(color: .blue.opacity(isHovered ? 0.6 : 0),
                   radius: isHovered ? 20 : 0)
            .scaleEffect(isHovered ? 1.1 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isHovered)
    }
}
```

### 7.4 Iconography

#### App Icon
```
Design:
  - Molecule representation (simple, recognizable)
  - 3D appearance with depth
  - Uses brand blue as primary color
  - Scientific but approachable

Example:
  ╔═══════════╗
  ║   ●─●─●   ║  Simple molecular structure
  ║   │ │ │   ║  on gradient background
  ║   ●─●─●   ║  (Blue to purple gradient)
  ╚═══════════╝
```

#### Toolbar Icons
```
SF Symbols used throughout:
  atom                → Molecule viewer
  chart.bar.xaxis     → Analytics
  play.circle         → Start simulation
  pause.circle        → Pause
  square.and.arrow.up → Export
  magnifyingglass     → Search
  slider.horizontal.3 → Settings
  person.2            → Collaboration
```

---

## 8. User Flows & Navigation

### 8.1 Primary User Flow: Molecule Design

```
Start
  │
  ├─> Open App
  │     │
  │     ├─> Main Control Panel appears
  │     │
  │     ├─> User: "Create New Molecule"
  │     │     │
  │     │     ├─> Molecule Editor opens (Volume)
  │     │     │     │
  │     │     │     ├─> User adds atoms (pinch gestures)
  │     │     │     ├─> User creates bonds (drag gestures)
  │     │     │     ├─> Real-time property calculation
  │     │     │     │
  │     │     │     ├─> User: "Calculate Properties"
  │     │     │     │     │
  │     │     │     │     └─> Properties panel appears
  │     │     │     │           - Molecular weight
  │     │     │     │           - LogP prediction
  │     │     │     │           - Solubility
  │     │     │     │
  │     │     │     ├─> User: "Optimize Structure"
  │     │     │     │     │
  │     │     │     │     └─> Geometry optimization runs
  │     │     │     │           Structure adjusts
  │     │     │     │
  │     │     │     └─> User: "Save Molecule"
  │     │     │           │
  │     │     │           └─> Saved to project
  │     │     │                 Returns to library
  │     │     │
  │     │     Alternative: Import Molecule
  │     │           │
  │     │           ├─> User: "Import from file"
  │     │           ├─> File picker
  │     │           └─> Molecule loads in viewer
  │     │
  │     └─> Success state: Molecule in library
  │
End
```

### 8.2 Simulation Workflow

```
Start: Molecule selected in library
  │
  ├─> User: "Run Simulation"
  │     │
  │     ├─> Simulation type selector appears
  │     │     • Molecular Dynamics
  │     │     • Docking
  │     │     • Conformational Search
  │     │     • Quantum Chemistry
  │     │
  │     ├─> User selects "Molecular Dynamics"
  │     │     │
  │     │     ├─> Parameter panel appears
  │     │     │     - Temperature: 298K
  │     │     │     - Duration: 10ps
  │     │     │     - Time step: 1fs
  │     │     │
  │     │     ├─> User: "Start"
  │     │     │     │
  │     │     │     ├─> Immersive Space opens
  │     │     │     ├─> Molecule animates
  │     │     │     ├─> Progress indicator
  │     │     │     ├─> Real-time energy graph
  │     │     │     │
  │     │     │     ├─> Simulation completes
  │     │     │     │     │
  │     │     │     │     └─> Results panel
  │     │     │     │           - Final energy
  │     │     │     │           - Trajectory data
  │     │     │     │           - Analysis graphs
  │     │     │
  │     │     └─> User: "Export Results"
  │     │           │
  │     │           └─> Save trajectory file
  │     │
  │     Alternative: User pauses/stops
  │           │
  │           └─> Returns to parameter panel
  │                 Can resume or adjust
  │
End
```

### 8.3 Navigation Structure

```
App Structure:
  MolecularDesignApp
  │
  ├─ Main Control Panel (WindowGroup)
  │   ├─ Project Browser
  │   ├─ Molecule Library
  │   └─ Quick Actions
  │
  ├─ Molecule Viewer (VolumetricWindowGroup)
  │   ├─ 3D Visualization
  │   ├─ Properties Panel
  │   └─ Editing Tools
  │
  ├─ Simulation Environment (ImmersiveSpace)
  │   ├─ Simulation Controls
  │   ├─ Real-time Visualization
  │   └─ Data Monitoring
  │
  ├─ Analytics Dashboard (WindowGroup)
  │   ├─ Project Metrics
  │   ├─ Success Trends
  │   └─ Property Distributions
  │
  └─ Settings (WindowGroup)
      ├─ Preferences
      ├─ Integrations
      └─ Account Management
```

### 8.4 Transition Patterns

```swift
// Window to Volume
func openMoleculeViewer(for molecule: Molecule) {
    // 1. Fade out library view
    withAnimation(.easeOut(duration: 0.3)) {
        libraryOpacity = 0
    }

    // 2. Open volumetric window
    Task {
        try await Task.sleep(for: .milliseconds(200))
        openWindow(id: "molecule-viewer")
    }

    // 3. Fade in molecule
    Task {
        try await Task.sleep(for: .milliseconds(400))
        withAnimation(.easeIn(duration: 0.4)) {
            moleculeOpacity = 1
        }
    }
}

// Volume to Immersive
func enterImmersiveMode() {
    // 1. Molecule scales up
    withAnimation(.easeInOut(duration: 0.5)) {
        moleculeScale = 2.0
    }

    // 2. Volume fades
    withAnimation(.easeOut(duration: 0.3).delay(0.2)) {
        volumeOpacity = 0
    }

    // 3. Immersive space opens
    Task {
        try await Task.sleep(for: .milliseconds(500))
        await openImmersiveSpace(id: "molecular-lab")
    }
}
```

---

## 9. Accessibility Design

### 9.1 VoiceOver Navigation

```
Molecular Structure VoiceOver Description:
  "Molecule: Ethanol.
   Contains 9 atoms: 2 carbon, 6 hydrogen, 1 oxygen.
   Molecular weight: 46.07 grams per mole.
   Currently showing ball-and-stick representation.
   Double-tap to open detailed view."

Atom Selection:
  "Carbon atom 1, position x: 1.2, y: 3.4, z: 2.1.
   Bonded to 4 atoms: hydrogen 2, hydrogen 3, carbon 2, hydrogen 4.
   Double-tap to select, drag to move."

Simulation Status:
  "Molecular dynamics simulation running.
   Progress: 53 percent complete.
   Current energy: negative 2,450.3 kilojoules per mole.
   Double-tap to pause."
```

### 9.2 Alternative Representations

#### Haptic Feedback
```swift
// Atom selection
func selectAtom() {
    let generator = UIImpactFeedbackGenerator(style: .medium)
    generator.impactOccurred()
}

// Bond creation
func createBond() {
    let generator = UIImpactFeedbackGenerator(style: .heavy)
    generator.impactOccurred()
}

// Simulation milestone
func simulationProgress(percent: Double) {
    if percent.truncatingRemainder(dividingBy: 10) == 0 {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}
```

#### Sonification (Audio Feedback)
```
Molecular Property → Audio Mapping:

  Molecular Weight:
    Low (< 100)     → Low pitch tone
    Medium (100-500) → Medium pitch
    High (> 500)     → High pitch

  Energy Level:
    Stable          → Calm ambient tone
    Unstable        → Dissonant, tense tone

  Bond Strength:
    Weak            → Soft, quiet
    Strong          → Loud, resonant
```

### 9.3 Reduced Motion Mode

```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

// Adaptive animations
func animateMoleculeAppearance() {
    if reduceMotion {
        // Instant appearance with crossfade
        moleculeOpacity = 1.0
    } else {
        // Smooth animation with rotation
        withAnimation(.easeInOut(duration: 0.8)) {
            moleculeOpacity = 1.0
            moleculeRotation = .identity
        }
    }
}

// Simulation playback
var simulationSpeed: Double {
    reduceMotion ? 0.5 : 1.0 // Slower when motion reduced
}
```

---

## 10. Error States & Loading Indicators

### 10.1 Loading States

#### Molecule Loading
```
┌───────────────────────────┐
│   Loading Molecule...     │
│                           │
│         ◐                 │  Rotating activity indicator
│                           │
│   Parsing structure...    │
│   ████████░░░░ 65%        │  Progress bar
│                           │
│   Estimated: 2 seconds    │
└───────────────────────────┘
```

#### Simulation Progress
```
┌───────────────────────────┐
│   Running Simulation      │
│                           │
│   Frame: 5,342 / 10,000   │
│   ██████████░░░░░ 53%     │
│                           │
│   Energy: -2,450.3 kJ/mol │
│   Temperature: 298.2 K    │
│                           │
│   Time remaining: 2m 15s  │
│                           │
│   [Pause] [Cancel]        │
└───────────────────────────┘
```

#### Property Calculation
```
┌───────────────────────────┐
│   Calculating Properties  │
│                           │
│   ✓ Molecular Weight      │
│   ✓ LogP                  │
│   ⧗ Solubility...         │  In progress
│   ○ Toxicity              │  Pending
│   ○ Bioavailability       │  Pending
│                           │
│   Using AI Model v2.3     │
└───────────────────────────┘
```

### 10.2 Error States

#### File Import Error
```
┌───────────────────────────┐
│   ⚠ Import Failed         │
│                           │
│   Cannot read file:       │
│   "molecule.xyz"          │
│                           │
│   Error: Invalid format   │
│   Expected: XYZ format    │
│   Found: Unknown format   │
│                           │
│   Suggestion:             │
│   • Check file format     │
│   • Try converting to SDF │
│   • Use format detector   │
│                           │
│   [Try Again] [Cancel]    │
└───────────────────────────┘
```

#### Simulation Failure
```
┌───────────────────────────┐
│   ✗ Simulation Failed     │
│                           │
│   Error at frame 2,341    │
│                           │
│   Reason:                 │
│   Energy minimization     │
│   did not converge        │
│                           │
│   Recommendations:        │
│   • Reduce time step      │
│   • Increase iterations   │
│   • Check structure       │
│                           │
│   [View Logs]             │
│   [Adjust Parameters]     │
│   [Report Issue]          │
└───────────────────────────┘
```

#### Network Error
```
┌───────────────────────────┐
│   ⚠ Connection Lost       │
│                           │
│   Cannot reach server:    │
│   api.molecular.com       │
│                           │
│   Working offline         │
│                           │
│   • Local work saved      │
│   • Will sync when online │
│   • Some features disabled│
│                           │
│   [Retry Connection]      │
│   [Work Offline]          │
└───────────────────────────┘
```

### 10.3 Empty States

#### No Molecules in Library
```
┌─────────────────────────────────┐
│   Your Molecule Library         │
│                                 │
│          ⚛                      │  Large icon
│                                 │
│   No molecules yet              │
│                                 │
│   Get started by:               │
│   • Creating a new molecule     │
│   • Importing from file         │
│   • Searching database          │
│                                 │
│   [Create New]  [Import]        │
└─────────────────────────────────┘
```

#### No Simulation Results
```
┌─────────────────────────────────┐
│   Simulation Results            │
│                                 │
│          📊                     │
│                                 │
│   No results available          │
│                                 │
│   Run a simulation to see       │
│   trajectory and analysis data  │
│                                 │
│   [Start Simulation]            │
└─────────────────────────────────┘
```

---

## 11. Animation & Transition Specifications

### 11.1 Micro-Interactions

#### Button Press
```swift
struct ButtonPressAnimation: ViewModifier {
    @State private var isPressed = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .opacity(isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressed = true }
                    .onEnded { _ in isPressed = false }
            )
    }
}
```

**Timing**: 100ms
**Easing**: Ease-in-out
**Scale**: 0.95x when pressed

#### Hover Effect
```swift
.onContinuousHover { phase in
    switch phase {
    case .active:
        withAnimation(.easeOut(duration: 0.2)) {
            hoverScale = 1.05
            hoverGlow = 0.6
        }
    case .ended:
        withAnimation(.easeIn(duration: 0.2)) {
            hoverScale = 1.0
            hoverGlow = 0.0
        }
    }
}
```

**Timing**: 200ms
**Easing**: Ease-out (in), ease-in (out)
**Scale**: 1.05x when hovered

### 11.2 Molecular Animations

#### Rotation Animation
```swift
func autoRotate() {
    withAnimation(
        .linear(duration: 10)
        .repeatForever(autoreverses: false)
    ) {
        moleculeRotation = Angle(degrees: 360)
    }
}
```

**Duration**: 10 seconds per rotation
**Easing**: Linear
**Repeat**: Continuous

#### Bond Formation
```swift
func animateBondFormation(from atom1: Atom, to atom2: Atom) {
    // Phase 1: Atoms move closer (300ms)
    withAnimation(.easeInOut(duration: 0.3)) {
        atom1.position += (atom2.position - atom1.position) * 0.1
        atom2.position += (atom1.position - atom2.position) * 0.1
    }

    // Phase 2: Bond appears (200ms)
    Task {
        try await Task.sleep(for: .milliseconds(300))
        withAnimation(.easeOut(duration: 0.2)) {
            bondOpacity = 1.0
        }
    }

    // Phase 3: Flash effect (100ms)
    Task {
        try await Task.sleep(for: .milliseconds(500))
        withAnimation(.easeInOut(duration: 0.1)) {
            bondGlow = 1.0
        }
        try await Task.sleep(for: .milliseconds(100))
        withAnimation(.easeInOut(duration: 0.1)) {
            bondGlow = 0.0
        }
    }
}
```

**Total Duration**: 600ms
**Phases**: Approach → Appear → Flash

#### Simulation Playback
```swift
func playSimulationFrame(_ frame: SimulationFrame) {
    // Interpolate between frames for smooth motion
    withAnimation(.linear(duration: frameDuration)) {
        for (index, position) in frame.atomPositions.enumerated() {
            atoms[index].position = position
        }
    }
}
```

**Frame Rate**: 30-60 fps
**Interpolation**: Linear between frames
**Smoothing**: Optional spring physics

### 11.3 Transition Effects

#### Window Open/Close
```swift
.transition(.asymmetric(
    insertion: .scale(scale: 0.8).combined(with: .opacity),
    removal: .scale(scale: 1.2).combined(with: .opacity)
))
.animation(.spring(response: 0.5, dampingFraction: 0.7), value: isShowing)
```

**Duration**: 500ms
**Easing**: Spring (response: 0.5, damping: 0.7)
**Effect**: Scale + opacity

#### Panel Slide In/Out
```swift
.transition(.move(edge: .trailing))
.animation(.easeInOut(duration: 0.3), value: isPanelVisible)
```

**Duration**: 300ms
**Easing**: Ease-in-out
**Direction**: From right edge

#### Mode Transition (Window → Immersive)
```swift
func transitionToImmersive() {
    // 1. Molecule scales and moves to center
    withAnimation(.easeInOut(duration: 0.5)) {
        moleculeScale = 2.0
        moleculePosition = centerPosition
    }

    // 2. Windows fade out
    withAnimation(.easeOut(duration: 0.3).delay(0.2)) {
        windowOpacity = 0.0
    }

    // 3. Immersive environment fades in
    Task {
        try await Task.sleep(for: .milliseconds(500))
        await openImmersiveSpace(id: "molecular-lab")

        withAnimation(.easeIn(duration: 0.4)) {
            environmentOpacity = 1.0
        }
    }
}
```

**Total Duration**: 1.2 seconds
**Phases**: Scale → Fade windows → Open immersive

---

## Appendix: Design Checklist

### Pre-Implementation Checklist
- [ ] All spatial positions defined (depth, angle)
- [ ] Window sizes specified (min, default, max)
- [ ] Color scheme defined (light/dark modes)
- [ ] Typography hierarchy established
- [ ] Interaction patterns documented
- [ ] Accessibility requirements clear
- [ ] Animation timings specified
- [ ] Error states designed
- [ ] Loading indicators created
- [ ] Empty states designed

### visionOS Specific
- [ ] Glass materials selected
- [ ] Spatial audio events defined
- [ ] Hand gesture interactions specified
- [ ] Gaze interaction patterns documented
- [ ] Immersive space layouts designed
- [ ] Ornament positions defined
- [ ] Focus indicators designed
- [ ] Depth hierarchy established

### Molecular Visualization
- [ ] Representation styles defined
- [ ] Color schemes selected (CPK, etc.)
- [ ] LOD levels specified
- [ ] Lighting setup documented
- [ ] Material properties defined
- [ ] Performance targets set

---

**Document Status**: Complete
**Next Step**: Generate IMPLEMENTATION_PLAN.md
