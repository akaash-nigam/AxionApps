# Science Lab Sandbox - Design Document

## Document Overview
This document defines the game design, user experience, visual design, and audio design for Science Lab Sandbox, ensuring an engaging, educational, and immersive scientific learning experience.

**Version:** 1.0
**Last Updated:** 2025-01-20
**Target Audience:** Students (ages 10+), Educators, Science Enthusiasts

---

## 1. Game Design Document (GDD)

### 1.1 Core Concept

**Elevator Pitch:**
Transform your space into a fully-equipped science laboratory where you safely conduct dangerous experiments, manipulate molecules, and discover scientific principles through hands-on spatial experimentation.

**Key Pillars:**
1. **Scientific Accuracy** - Realistic simulations following actual physical laws
2. **Safe Exploration** - Conduct dangerous experiments without real-world risk
3. **Hands-On Learning** - Direct manipulation of scientific phenomena
4. **Discovery-Driven** - Learn through experimentation and hypothesis testing
5. **Spatial Innovation** - Leverage 3D space for understanding scientific concepts

### 1.2 Core Gameplay Loop

```
Discovery Loop (Primary):
┌─────────────────────────────────────────┐
│  1. Observe & Wonder                    │
│     - Notice scientific phenomena        │
│     - Ask questions                      │
│                                          │
│  2. Form Hypothesis                      │
│     - Predict outcomes                   │
│     - Design experiment                  │
│                                          │
│  3. Conduct Experiment                   │
│     - Manipulate variables               │
│     - Collect data                       │
│                                          │
│  4. Analyze Results                      │
│     - Review measurements                │
│     - Compare to predictions             │
│                                          │
│  5. Draw Conclusions                     │
│     - Confirm or refute hypothesis       │
│     - Record findings                    │
│                                          │
│  6. Share & Learn                        │
│     - Present results                    │
│     - Get AI tutor feedback              │
│     └──────────────┬───────────────────┘
│                     │
│         ┌───────────▼──────────┐
│         │  Unlock New          │
│         │  Experiments &       │
│         │  Concepts            │
│         └───────────┬──────────┘
│                     │
└─────────────────────┘
```

### 1.3 Player Progression

#### Skill Levels (Per Discipline)

**Level 1: Beginner (Ages 10-12)**
- Guided experiments with step-by-step instructions
- Basic safety training
- Simple chemical reactions (vinegar + baking soda)
- Basic physics (gravity, friction)
- Elementary biology (cell structure)
- Achievement: "Junior Scientist"

**Level 2: Intermediate (Ages 13-15)**
- Semi-guided experiments with hints
- More complex reactions (acid-base titrations)
- Forces and energy experiments
- Dissection and anatomy
- Achievement: "Lab Technician"

**Level 3: Advanced (Ages 16-18)**
- Independent experiment design
- Organic chemistry synthesis
- Quantum mechanics visualization
- Genetics and molecular biology
- Achievement: "Research Assistant"

**Level 4: Expert (College+)**
- Professional research tools
- Advanced spectroscopy
- Nuclear physics (safe simulation)
- Biochemistry and enzymology
- Achievement: "Lead Scientist"

**Level 5: Master (Professional)**
- Custom experiment creation
- Peer review participation
- Collaborative research
- Publication-quality data
- Achievement: "Master Researcher"

#### Progression System

```swift
struct ProgressionSystem {
    // Experience points earned by:
    // - Completing experiments (50-200 XP)
    // - Accurate measurements (10-50 XP)
    // - Correct hypotheses (25-100 XP)
    // - Safety compliance (10 XP)
    // - Discovering new phenomena (100-500 XP)

    let xpPerLevel = [
        1: 0,
        2: 500,
        3: 1500,
        4: 3500,
        5: 7500
    ]

    // Unlock progression
    var unlockedExperiments: Set<Experiment>
    var unlockedEquipment: Set<EquipmentType>
    var unlockedConcepts: Set<ScientificConcept>
}
```

### 1.4 Player Motivation & Rewards

#### Achievement System

```swift
enum Achievement: String {
    // Safety Achievements
    case "Perfect Safety Record" = "100 experiments with zero violations"
    case "Emergency Response" = "Successfully handle 10 emergency stops"

    // Skill Achievements
    case "Chemistry Novice" = "Complete 10 chemistry experiments"
    case "Physics Pro" = "Master all classical mechanics concepts"
    case "Biology Expert" = "Complete full anatomy course"
    case "Astronomy Adept" = "Map 50 celestial objects"

    // Discovery Achievements
    case "Eureka Moment" = "Make an unexpected discovery"
    case "Hypothesis Hero" = "Form 25 correct hypotheses"
    case "Data Master" = "Collect 1000 precise measurements"

    // Collaboration Achievements
    case "Team Player" = "Complete 10 collaborative experiments"
    case "Peer Reviewer" = "Provide quality feedback on 50 experiments"
    case "Mentor" = "Guide 5 junior scientists"

    // Special Achievements
    case "Nobel Laureate" = "Recreate all Nobel Prize experiments"
    case "Historical Scientist" = "Complete all famous historical experiments"
    case "Renaissance Scientist" = "Master all scientific disciplines"
}
```

#### Visual Progression

- **Lab Coat Customization**: Unlock different coat styles and colors
- **Laboratory Expansion**: Unlock new lab equipment and stations
- **Certificate Wall**: Display earned certificates and achievements
- **Equipment Badges**: Show mastery of specific equipment
- **Periodic Table Completion**: Light up elements as you work with them

### 1.5 Difficulty Balancing

#### Adaptive Difficulty

```swift
class DifficultyAdjuster {
    func adjustDifficulty(based on: PlayerPerformance) -> DifficultyLevel {
        // Monitors:
        // - Success rate on experiments
        // - Time to complete tasks
        // - Accuracy of measurements
        // - Hypothesis correctness
        // - Safety violations

        if performance.successRate > 0.9 {
            return .challenging  // Increase complexity
        } else if performance.successRate < 0.5 {
            return .supportive  // Provide more guidance
        } else {
            return .balanced
        }
    }
}

enum DifficultyLevel {
    case beginner       // Heavy guidance, simple experiments
    case intermediate   // Moderate hints, standard experiments
    case advanced       // Minimal guidance, complex experiments
    case expert         // No guidance, professional research
    case adaptive       // AI-adjusted based on performance
}
```

#### Challenge Modes

- **Speed Challenge**: Complete experiment in limited time
- **Precision Challenge**: Achieve exact measurements
- **Resource Challenge**: Limited equipment and materials
- **Mystery Challenge**: Identify unknown substances
- **Safety Challenge**: Handle most dangerous experiments

---

## 2. Core Gameplay Design

### 2.1 Chemistry Gameplay

#### Experiment Types

**Type 1: Chemical Reactions**
```
Objective: Combine reagents to produce specific compounds
Mechanics:
  - Select chemicals from inventory
  - Measure precise amounts using pipettes
  - Mix in appropriate glassware
  - Monitor temperature and reaction progress
  - Observe color changes, precipitates, gas formation
  - Record observations and measurements

Example: Acid-Base Neutralization
  - Add 25mL of 1M HCl to beaker
  - Slowly add NaOH while monitoring pH
  - Stop at pH 7 (neutralization point)
  - Observe salt formation (NaCl)
```

**Type 2: Molecular Manipulation**
```
Objective: Build and understand molecular structures
Mechanics:
  - Grab individual atoms from periodic table
  - Connect atoms using hands (bond formation)
  - Rotate molecule to view from all angles
  - Zoom to atomic scale to see electron clouds
  - Observe bond angles and molecular geometry
  - Predict reactivity based on structure

Example: Building Caffeine Molecule
  - Select C, H, N, O atoms
  - Form aromatic rings
  - Add functional groups
  - Visualize 3D structure
  - Explore electron density
```

**Type 3: Synthesis Challenges**
```
Objective: Create target compound from starting materials
Mechanics:
  - Given: Starting materials and target
  - Plan: Reaction pathway
  - Execute: Multi-step synthesis
  - Purify: Separate product from byproducts
  - Verify: Spectroscopic analysis

Example: Aspirin Synthesis
  - React salicylic acid with acetic anhydride
  - Add catalyst (H2SO4)
  - Heat and monitor
  - Crystallize product
  - Verify purity
```

### 2.2 Physics Gameplay

#### Experiment Types

**Type 1: Mechanics**
```
Objective: Explore forces, motion, and energy
Mechanics:
  - Place objects in 3D space
  - Apply forces by pushing/pulling
  - Observe trajectories in real-time
  - Measure velocity, acceleration, energy
  - View force vectors and graphs

Example: Projectile Motion
  - Set launch angle and velocity
  - Release projectile
  - Observe parabolic trajectory
  - Measure range and height
  - Compare to calculated values
```

**Type 2: Electricity & Magnetism**
```
Objective: Build circuits and explore electromagnetic phenomena
Mechanics:
  - Connect circuit components in 3D
  - Visualize current flow as animated particles
  - See electric/magnetic fields
  - Measure voltage, current, resistance
  - Observe electromagnetic induction

Example: Build Simple Circuit
  - Connect battery, resistor, LED
  - See electron flow animation
  - Measure current with ammeter
  - Calculate power dissipation
  - Observe Ohm's Law
```

**Type 3: Quantum Mechanics**
```
Objective: Visualize quantum phenomena
Mechanics:
  - Manipulate quantum states
  - Observe wave-particle duality
  - View probability distributions
  - Simulate quantum tunneling
  - Explore uncertainty principle

Example: Hydrogen Atom Orbitals
  - Select quantum numbers (n, l, m)
  - See 3D probability cloud
  - Zoom to atomic scale
  - Transition between energy levels
  - Observe photon emission
```

### 2.3 Biology Gameplay

#### Experiment Types

**Type 1: Microscopy**
```
Objective: Observe and identify biological specimens
Mechanics:
  - Prepare microscope slides
  - Adjust magnification (40x to 1000x)
  - Focus on specimen
  - Identify cellular structures
  - Take measurements and photos

Example: Cell Structure Study
  - Select plant or animal cell
  - Zoom to cellular level
  - Identify organelles
  - Measure cell dimensions
  - Compare to reference images
```

**Type 2: Dissection**
```
Objective: Explore anatomy through virtual dissection
Mechanics:
  - Select organism (frog, fetal pig, etc.)
  - Use surgical tools (scalpel, forceps, scissors)
  - Remove skin and tissue layers
  - Identify organs and systems
  - Label anatomical structures

Example: Frog Dissection
  - Pin frog to dissection tray
  - Make incisions carefully
  - Expose organs (heart, lungs, liver)
  - Trace circulatory system
  - Document findings
```

**Type 3: Molecular Biology**
```
Objective: Explore DNA, proteins, and cellular processes
Mechanics:
  - Extract and manipulate DNA
  - Sequence genes
  - Model protein folding
  - Simulate cellular processes
  - Engineer genetic modifications

Example: DNA Replication
  - Unzip DNA double helix
  - Watch DNA polymerase action
  - See base pairing
  - Observe replication fork
  - Count base pairs
```

### 2.4 Astronomy Gameplay

```
Objective: Explore celestial objects and cosmic phenomena
Mechanics:
  - Manipulate planets, stars, galaxies
  - Adjust time scale (seconds to billions of years)
  - Observe gravitational interactions
  - Measure astronomical distances
  - Simulate cosmic events

Example: Solar System Dynamics
  - Add planets to solar system
  - Adjust orbital parameters
  - Speed up time
  - Observe stable orbits
  - Calculate orbital periods
```

---

## 3. Spatial Gameplay Design

### 3.1 Laboratory Layout

#### Personal Laboratory (2m × 2m)
```
┌─────────────────────────────┐
│                             │
│    ╔═══════════════╗        │
│    ║  Lab Bench    ║        │
│    ║  (Main Work   ║        │
│    ║   Area)       ║        │
│    ╚═══════════════╝        │
│                             │
│  [Equip]        [Data]      │
│   Rack          Display     │
│                             │
│      [Safety]               │
│       Panel                 │
└─────────────────────────────┘

Equipment positioned around user:
- Lab bench: 0.8m in front (arm's reach)
- Equipment rack: 1m to the left
- Data displays: Floating at eye level
- Safety panel: Always accessible
```

#### Full Laboratory (3m × 3m)
```
┌───────────────────────────────────┐
│                                   │
│   [Biology]     [Physics]         │
│    Station      Playground        │
│                                   │
│                                   │
│         ╔═══════════╗             │
│         ║ Chemistry ║             │
│         ║  Bench    ║             │
│         ╚═══════════╝             │
│           (Center)                │
│                                   │
│                                   │
│   [Astronomy]   [Equipment]       │
│    Observatory   Storage          │
│                                   │
└───────────────────────────────────┘
```

### 3.2 Equipment Interaction Design

#### Beaker Interaction
```
Spatial Behaviors:
1. Grab: Pinch to pick up
2. Pour: Tilt to pour contents
   - Liquid flows realistically
   - Splash physics if tilted too fast
   - Visual feedback (fill level)

3. Mix: Stir with hand motion
   - Circular motion detection
   - Vortex visualization
   - Speed affects mixing rate

4. Heat: Place on burner
   - Temperature indicator appears
   - Color changes with heat
   - Steam particles at boiling point
```

#### Microscope Interaction
```
Spatial Behaviors:
1. Gaze: Look through eyepiece
   - View enlarges to fill vision
   - Depth of field simulation

2. Dial: Twist focus knob
   - Rotation gesture
   - Haptic clicks for precision
   - Real-time focus adjustment

3. Slide: Move specimen slide
   - Push/pull gesture
   - Pan across specimen
   - Smooth inertia

4. Magnify: Change objective lens
   - Select lens with pinch
   - Zoom animation
   - Adjust lighting automatically
```

### 3.3 Scale Manipulation

#### Multi-Scale View System
```
Scale Levels:
- Cosmic (1m = 1 billion km): View galaxies and cosmic structures
- Astronomical (1m = 1 million km): View solar systems
- Macro (1m = 1m): Normal human scale
- Micro (1m = 1mm): View cells and small organisms
- Molecular (1m = 1nm): View molecules and atoms
- Atomic (1m = 1pm): View atomic structure
- Subatomic (1m = 1fm): View nuclear particles

Transition Animation:
- Smooth zoom with scale indicators
- Context preservation (show both scales during transition)
- Audio cues for scale changes
- Scientific notation display

Example: Zooming into Water
  Macro → See water droplet
  Micro → See individual molecules
  Molecular → See H2O structure
  Atomic → See electron clouds
```

---

## 4. UI/UX Design

### 4.1 Spatial UI Framework

#### HUD Design
```
┌─────────────────────────────────────────┐
│                  ▲                      │ ← Safety Indicator
│              [SAFE] pH: 7.0             │   (Always visible)
│                                         │
│  ┌──────┐                     ┌──────┐ │
│  │Timer │                     │ Temp │ │ ← Context Panels
│  │2:34  │                     │23.5°C│ │   (Float near work)
│  └──────┘                     └──────┘ │
│                                         │
│           [ Experiment Area ]           │
│                                         │
│  ┌─────────────┐         ┌───────────┐ │
│  │Observations │         │ Controls  │ │ ← Tool Palettes
│  │ [+] Note    │         │ [⏸]Pause │ │   (Edge of vision)
│  └─────────────┘         └───────────┘ │
│                                         │
│            [Help] [Menu]                │ ← Quick Actions
└─────────────────────────────────────────┘   (Bottom center)
```

#### UI Placement Zones

**Near Field (0.3m - 0.8m)**
- Critical controls
- Detailed data displays
- Precision measurement tools
- Active experiment feedback

**Mid Field (0.8m - 2m)**
- Main workspace
- Equipment and materials
- General information panels
- Collaboration tools

**Far Field (2m - 4m)**
- Ambient information
- Tutorial hints
- Peripheral notifications
- Background data visualization

### 4.2 Menu System

#### Main Menu
```
┌──────────────────────────────┐
│   SCIENCE LAB SANDBOX        │
│                              │
│   ┌────────────────────┐    │
│   │  NEW EXPERIMENT    │    │ ← Start new
│   └────────────────────┘    │
│                              │
│   ┌────────────────────┐    │
│   │  CONTINUE          │    │ ← Resume last
│   └────────────────────┘    │
│                              │
│   ┌────────────────────┐    │
│   │  LABORATORY        │    │ ← Choose discipline
│   │  Chemistry    →    │    │
│   │  Physics      →    │    │
│   │  Biology      →    │    │
│   │  Astronomy    →    │    │
│   └────────────────────┘    │
│                              │
│   ┌────────────────────┐    │
│   │  PROGRESS          │    │ ← View achievements
│   └────────────────────┘    │
│                              │
│   ┌────────────────────┐    │
│   │  SETTINGS          │    │
│   └────────────────────┘    │
└──────────────────────────────┘
```

#### Experiment Selection
```
┌──────────────────────────────────────┐
│  CHEMISTRY EXPERIMENTS               │
│                                      │
│  Beginner  │  Intermediate  │  Advanced │
│  ─────────────────────────────────  │
│                                      │
│  ╔══════════════════════════╗       │
│  ║ Acid-Base Titration      ║       │
│  ║ ⭐⭐⭐☆☆ Difficulty: Med  ║       │
│  ║ 🕐 15-20 min              ║       │
│  ║ 🎯 Learn: pH, indicators  ║       │
│  ║                          ║       │
│  ║ [START] [PREVIEW]        ║       │
│  ╚══════════════════════════╝       │
│                                      │
│  ╔══════════════════════════╗       │
│  ║ Molecular Building       ║       │
│  ║ ⭐⭐☆☆☆ Difficulty: Easy  ║       │
│  ║ 🕐 10 min                 ║       │
│  ║ 🎯 Learn: Bonds, geometry ║       │
│  ║                          ║       │
│  ║ [START] [PREVIEW]        ║       │
│  ╚══════════════════════════╝       │
└──────────────────────────────────────┘
```

### 4.3 In-Experiment UI

#### Data Collection Panel
```
┌─────────────────────────┐
│  MEASUREMENTS           │
│  ─────────────────────  │
│  Time: 2:34             │
│  Temp: 23.5°C ▲         │
│  pH: 7.2 ─              │
│  Volume: 50.0 mL        │
│                         │
│  [📊 Graph] [📷 Photo] │
│  [📝 Note]  [✓ Record] │
└─────────────────────────┘
```

#### AI Tutor Panel
```
┌─────────────────────────────┐
│  🤖 AI LAB ASSISTANT        │
│  ───────────────────────    │
│  "Notice how the solution   │
│   is turning pink? That's   │
│   the indicator showing     │
│   we're approaching the     │
│   equivalence point."       │
│                             │
│  💡 Hint Available          │
│  ❓ Ask Question            │
└─────────────────────────────┘
```

#### Safety Indicator
```
┌─────────────────┐
│  ✓ SAFE         │  ← Green: Safe
│  ⚠ CAUTION      │  ← Yellow: Caution
│  ⛔ DANGER       │  ← Red: Dangerous
│  🚨 EMERGENCY   │  ← Flashing: Critical
└─────────────────┘

Conditions monitored:
- Chemical hazards (corrosive, toxic, etc.)
- Temperature extremes
- Pressure levels
- Radiation exposure
- Proper PPE usage
```

### 4.4 Tutorial & Onboarding

#### First Launch Experience

**Step 1: Welcome (30 seconds)**
```
"Welcome to Science Lab Sandbox!
Your personal laboratory awaits.
Let's learn the basics of spatial science."

[Interactive elements appear one by one]
```

**Step 2: Hand Tracking Introduction (1 minute)**
```
"Hold up your hands and wiggle your fingers.
Good! Now try these gestures:

1. Pinch your thumb and finger together
   ✓ Perfect! That's how you grab objects.

2. Open your hand and close it
   ✓ Great! That's how you release.

3. Rotate your wrist
   ✓ Excellent! That's how you pour liquids."
```

**Step 3: Safety Training (2 minutes)**
```
"Safety is our top priority!
Even though everything is virtual,
we follow real lab safety protocols.

⚗️ Always check safety indicators
🥽 Know your equipment
⚠️ Read warning labels
🚨 Practice emergency stops"

[Interactive safety quiz]
```

**Step 4: First Experiment (5 minutes)**
```
"Let's conduct your first experiment!
We'll mix vinegar and baking soda.

1. Grab the beaker [→]
2. Add vinegar [pour gesture]
3. Add baking soda [pinch & drop]
4. Observe the reaction! 🎉

Watch the bubbles form!
That's CO2 gas being released."
```

**Step 5: Exploration Encouraged (1 minute)**
```
"Congratulations! You're a scientist now!

✓ You've completed your first experiment
✓ You've learned basic controls
✓ You understand safety protocols

Now explore and discover!
The laboratory is yours."

[Achievement unlocked: "First Steps in Science"]
```

---

## 5. Visual Style Guide

### 5.1 Art Direction

**Style:** Clean Scientific Realism
- Realistic equipment and materials
- Accurate scientific visualization
- Clean, uncluttered workspace
- Professional laboratory aesthetic
- Educational clarity over artistic flair

**Color Palette:**

**Primary Colors (Laboratory)**
- White: #FFFFFF (Lab coats, clean surfaces)
- Light Gray: #E0E0E0 (Equipment casings)
- Dark Gray: #404040 (Metal components)
- Black: #000000 (Text, details)

**Accent Colors (Scientific)**
- Chemistry Blue: #4A90E2 (Water, cold)
- Physics Green: #50C878 (Energy, positive)
- Biology Pink: #FF6B9D (Organic, life)
- Astronomy Purple: #9B59B6 (Space, cosmic)

**Safety Colors**
- Safe Green: #4CAF50
- Caution Yellow: #FFC107
- Danger Red: #F44336
- Info Blue: #2196F3

**Chemical Colors**
- Acids: Red spectrum
- Bases: Blue spectrum
- Neutral: Clear/white
- Indicators: pH-dependent spectrum

### 5.2 Equipment Visual Design

#### Chemistry Equipment

**Beaker**
```
Materials:
- Glass: Clear borosilicate glass material
  - Transparency: 90%
  - Index of refraction: 1.474
  - Slight imperfections for realism

- Graduations: White ceramic paint
  - Measurement markings every 10mL
  - Bold numbers for readability

- Contents: Dynamic material
  - Color based on chemical
  - Opacity based on concentration
  - Surface tension simulation
```

**Bunsen Burner**
```
Materials:
- Base: Brushed metal
- Gas tube: Chrome
- Flame: Procedural shader
  - Blue inner cone
  - Orange outer flame
  - Heat distortion effect
  - Particle emitter for realism
```

#### Physics Equipment

**Force Sensor**
```
Visual Design:
- Digital display: LED numbers
- Force vector: Animated arrow
- Magnitude indicator: Color-coded
  - Low: Green
  - Medium: Yellow
  - High: Red

- Graph overlay: Real-time plot
```

### 5.3 Visual Effects

#### Chemical Reactions

**Color Changes**
```
- Smooth gradient transitions
- Timing based on reaction kinetics
- Localized color mixing (not instant uniform)
- Diffusion simulation for realistic blending
```

**Precipitate Formation**
```
- Particle system for solid formation
- Settling animation (gravity-based)
- Cloudiness effect during formation
- Final settled layer
```

**Gas Evolution**
```
- Bubble particles rising through liquid
- Size variation (small to large)
- Coalescence at surface
- Popping animation at interface
- Rising gas particles above liquid
```

#### Phase Transitions

**Melting**
```
- Surface becomes liquid
- Dripping if supported
- Heat glow effect
- Smooth solid→liquid transition
```

**Boiling**
```
- Vigorous bubbling
- Steam particles rising
- Surface turbulence
- Heat waves (distortion)
```

**Crystallization**
```
- Crystal nucleation points
- Growth animation
- Geometric crystal structure
- Reflective surfaces
```

### 5.4 Data Visualization

#### Graphs
```
Types:
- Line graphs: Temperature, pH over time
- Bar graphs: Comparative data
- Scatter plots: Experimental data points
- Molecular orbital diagrams
- Energy level diagrams
- Probability distributions

Style:
- Clean grid lines
- Color-coded data series
- Interactive tooltips
- Zoomable/pannable
- Exportable for reports
```

#### 3D Visualizations
```
- Molecular structures (ball-and-stick, space-filling)
- Electron density clouds
- Electric/magnetic field lines
- Wave functions (quantum mechanics)
- Orbital trajectories
- Anatomical structures
```

---

## 6. Audio Design

### 6.1 Spatial Audio Strategy

**Positioning:**
- All sounds positioned in 3D space
- Distance-based attenuation
- Occlusion by virtual objects
- Room acoustics simulation

**Categories:**

**Environmental Audio (Ambient)**
```
Laboratory Ambience:
- Soft HVAC hum (continuous, 40dB)
- Distant equipment sounds (sporadic, 35dB)
- Gentle air circulation (continuous, 30dB)

Position: Ambient (no specific source)
Purpose: Establish laboratory atmosphere
```

**Equipment Audio (Interactive)**
```
Burner:
- Gas flow (hiss, directional)
- Ignition (click + whoosh)
- Flame roar (continuous, varies with setting)
Position: Equipment location

Microscope:
- Focus dial clicks (haptic + audio)
- Objective lens rotation (smooth mechanical)
- Stage movement (subtle slide)
Position: Microscope location

Centrifuge:
- Motor spin-up (rising pitch)
- Running (steady hum, varying speed)
- Spin-down (falling pitch)
- Complete (beep)
Position: Centrifuge location
```

**Reaction Audio (Dynamic)**
```
Chemical Reactions:
- Fizzing (bubble formation)
- Boiling (vigorous bubbling)
- Precipitate formation (subtle chime)
- Explosion (safe virtual, dramatic)
- Color change (gentle tone shift)

Position: Reaction vessel location
Volume: Proportional to reaction rate
```

**Measurement Audio (Feedback)**
```
Data Collection:
- Measurement recorded (soft beep)
- Error/warning (alert tone)
- Achievement (success chime)
- Milestone (fanfare)

Position: UI element location or stereo
Purpose: Provide immediate feedback
```

### 6.2 Music System

**Menu Music**
```
Style: Inspiring orchestral with scientific themes
Tempo: 85 BPM
Mood: Wonder, curiosity, excitement
Instrumentation:
- Strings (wonder)
- Piano (precision)
- Synth pads (modernity)
- Light percussion (energy)

Volume: -20dB (background, non-intrusive)
```

**Laboratory Music (Optional)**
```
Style: Ambient electronic
Tempo: 70-90 BPM
Mood: Focused, contemplative
Instrumentation:
- Synthesizers
- Subtle rhythms
- Atmospheric pads

Volume: -25dB (very subtle)
Control: Player can disable during experiments
```

**Discovery Music (Triggered)**
```
Style: Triumphant fanfare
Duration: 5-10 seconds
Triggered by:
- Major discoveries
- Completing difficult experiments
- Unlocking achievements
- Breaking records

Volume: -15dB (prominent but not overwhelming)
```

### 6.3 Voice Over (AI Tutor)

**Voice Characteristics:**
- Gender: Neutral/selectable
- Tone: Friendly, encouraging, professional
- Pace: Moderate (not rushed)
- Clarity: High (educational context)

**Voice Lines:**

**Encouragement:**
```
"Great observation!"
"That's exactly right!"
"Interesting hypothesis!"
"Nice measurement technique!"
```

**Guidance:**
```
"Try adjusting the temperature."
"Check your pH indicator."
"Remember to record your observations."
"Consider what happens when..."
```

**Safety:**
```
"⚠️ Caution: Corrosive substance"
"Remember your safety protocols"
"Well done following safety procedures"
"🚨 Emergency stop activated"
```

**Educational:**
```
"This reaction is exothermic, releasing heat."
"Notice how the electrons are shared in this covalent bond."
"The force is inversely proportional to the square of the distance."
```

### 6.4 Accessibility Audio

**Audio Cues for Vision Impaired:**
```
- Equipment selection (unique tone per type)
- Spatial positioning (stereo panning)
- Measurement values (text-to-speech)
- Safety warnings (priority audio)
- Completion confirmations (distinct sounds)
```

**Audio Subtitles:**
```
- Display text for all important sounds
- Visual indicators for audio cues
- Haptic feedback alternatives
```

---

## 7. Accessibility Design

### 7.1 Visual Accessibility

**High Contrast Mode**
```
- Increase contrast ratio to 7:1 minimum
- Bold outlines on all interactive elements
- Enhanced color differentiation
- Larger UI elements
```

**Color Blind Modes**
```
Deuteranopia (Red-Green):
- Use blue/yellow instead of red/green for safety
- Pattern overlays on colored liquids
- Shape differentiation in addition to color

Protanopia (Red-Green):
- Similar adjustments to Deuteranopia

Tritanopia (Blue-Yellow):
- Use red/cyan distinctions
- High contrast markers
```

**Text Scaling**
```
- Base text: 16pt
- Large text: 24pt
- Extra large text: 32pt
- All UI scales proportionally
```

### 7.2 Motor Accessibility

**Alternative Controls**
```
Voice Only Mode:
- All actions available via voice commands
- "Grab beaker", "Pour slowly", "Measure temperature"

Simplified Gestures:
- Reduce precision requirements
- Larger hit boxes for interactions
- Dwell-based selection (gaze only)
- Controller support for traditional input

Assisted Mode:
- AI helps with precise measurements
- Snap-to positions for equipment
- Guided pouring (controlled automatically)
```

### 7.3 Cognitive Accessibility

**Simplified Instructions**
```
- Step-by-step with visual aids
- Reduce text complexity
- Picture-based guides
- Clear progress indicators
```

**Extended Time**
```
- No time limits (or optional)
- Pause anytime
- Save progress frequently
- Repeat tutorials unlimited times
```

### 7.4 Audio Accessibility

**Deaf/Hard of Hearing**
```
- Visual indicators for all audio cues
- Closed captions for voice over
- Visual alarm for safety warnings
- Haptic feedback for important events
```

---

## 8. Tutorial & Help System

### 8.1 Contextual Help

**Always Available:**
```
- Hover over equipment: "Beaker - Used for mixing and holding liquids"
- Gaze at controls: Tooltip appears
- Voice command: "What is this?" → Explanation
```

**AI Tutor Integration:**
```
- Proactive tips during experiments
- Answer questions in natural language
- Provide hints without spoiling discovery
- Adapt explanations to skill level
```

### 8.2 Experiment Guides

**Three Levels of Guidance:**

**Full Guidance (Beginner):**
```
Step 1: [Visual highlight on beaker]
"Grab the 100mL beaker from the rack"
[Wait for completion]

Step 2: [Highlight vinegar]
"Pour 50mL of vinegar into the beaker"
[Show measurement helper]
[Wait for completion]

Step 3: ...
```

**Moderate Guidance (Intermediate):**
```
"Your goal is to create a neutralization reaction.
You'll need:
- Beaker
- Acid (HCl)
- Base (NaOH)
- pH indicator

Steps:
1. Measure 50mL of acid
2. Add base slowly until neutral
3. Record your observations

[Hints available if needed]"
```

**Minimal Guidance (Advanced):**
```
"Objective: Synthesize aspirin from salicylic acid
Starting materials provided
Expected yield: 70-90%
Time: 30-45 minutes

[No further guidance unless requested]"
```

---

## 9. Social & Sharing Features

### 9.1 Collaborative Experiments

**Shared Laboratory:**
```
- Up to 4 players in same virtual space
- See each other as avatars
- Share equipment and materials
- Divide tasks (one measures, one pours, etc.)
- Shared data collection
- Group analysis
```

**Roles in Collaboration:**
```
- Lead Scientist: Coordinates experiment
- Assistant: Handles measurements
- Observer: Records data
- Analyst: Interprets results
```

### 9.2 Sharing Results

**Export Options:**
```
- Lab Report (PDF)
  - Formatted scientifically
  - Includes graphs and photos
  - Proper citations

- Video Recording
  - Key moments of experiment
  - Narration option
  - Educational presentation

- Data Export
  - CSV format
  - Compatible with Excel, Google Sheets
  - Graphing software

- Social Share
  - Screenshot with achievement
  - Quick facts about discovery
  - Privacy controls
```

### 9.3 Community Features

**Experiment Library:**
```
- Browse experiments by others
- Rate difficulty and quality
- Try community-created experiments
- Comment and discuss
```

**Leaderboards (Optional):**
```
- Most experiments completed
- Highest accuracy scores
- Safety streak records
- Discovery achievements
```

---

## Conclusion

This design document provides comprehensive guidance for creating an engaging, educational, and accessible science laboratory experience in visionOS. The design prioritizes scientific accuracy, hands-on learning, and the unique capabilities of spatial computing to make science education more immersive and effective than traditional methods.

**Core Design Principles:**
1. **Learn by Doing** - Active experimentation over passive observation
2. **Safe Exploration** - Dangerous experiments without risk
3. **Scientific Rigor** - Accurate simulations and real data
4. **Progressive Challenge** - Adapt to player skill and interest
5. **Inclusive Access** - Accessible to all learners
6. **Joyful Discovery** - Celebrate scientific wonder

This design creates a foundation for transforming how students learn science through the power of spatial computing on Apple Vision Pro.
