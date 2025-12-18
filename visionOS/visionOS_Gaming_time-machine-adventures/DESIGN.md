# Time Machine Adventures - Design Document

## Game Design Document (GDD)

### Core Concept

**High Concept**: Transform any room into an interactive museum of history where students physically explore, touch, and learn from the past through spatial computing.

**Genre**: Educational Adventure / Historical Mystery
**Platform**: Apple Vision Pro (visionOS 2.0+)
**Target Audience**: Students (8-18), Educators, History Enthusiasts
**Session Length**: 30-45 minutes (recommended)
**Difficulty**: Adaptive (Elementary to Advanced)

### Design Pillars

1. **Authentic Historical Education**
   - Every element historically accurate and educator-verified
   - Curriculum-aligned learning objectives
   - Primary source integration
   - Multiple historical perspectives

2. **Spatial Immersion**
   - Physical room becomes historical environment
   - Natural interaction with artifacts and characters
   - Leverages spatial memory for learning retention
   - Comfortable, extended-use design

3. **Adaptive Learning**
   - AI-powered difficulty adjustment
   - Personalized learning paths
   - Multiple learning styles supported
   - Real-time assessment integration

4. **Engaging Discovery**
   - Mystery-driven exploration
   - Rewarding artifact collection
   - Meaningful character interactions
   - Progressive challenge and mastery

## Core Gameplay Loop

### Primary Loop (Daily Play Session)

```
1. Select Time Period
   ↓
2. Room Transforms into Historical Environment
   ↓
3. Discover Hidden Artifacts
   ↓
4. Examine Artifacts in Detail
   ↓
5. Gather Clues
   ↓
6. Converse with Historical Characters
   ↓
7. Solve Mystery
   ↓
8. Unlock New Content
   ↓
9. Review Learning Progress
   ↓
10. Return to Time Map
```

### Secondary Loops

#### Collection Loop
- Discover artifacts → Examine details → Catalog in museum → Complete era set → Unlock special content

#### Character Relationship Loop
- Meet character → Ask questions → Build relationship → Unlock deeper knowledge → Access exclusive mysteries

#### Mastery Loop
- Attempt mystery → Learn from mistakes → Research topics → Retry with knowledge → Master concept → Progress to harder mysteries

### Meta Progression

```
Beginner Explorer
    ↓ (10 artifacts discovered)
Apprentice Historian
    ↓ (Complete 5 mysteries)
Time Traveler
    ↓ (Explore 3 eras)
Master Detective
    ↓ (Solve 20 mysteries)
Historical Scholar
    ↓ (Collect 100 artifacts)
Chrono Expert
```

## Player Progression Systems

### Experience and Unlocks

```swift
struct ProgressionSystem {
    // Player Level (1-50)
    var currentLevel: Int = 1
    var experiencePoints: Int = 0
    var experienceToNextLevel: Int { currentLevel * 100 }

    // Unlockable Content
    var unlockedEras: [HistoricalEra] = []
    var unlockedCharacters: [HistoricalCharacter] = []
    var unlockedMysteries: [Mystery] = []

    // Achievements
    var achievements: [Achievement] = []
    var badges: [Badge] = []

    // Skills
    var researchSkill: Int = 1 // Faster information discovery
    var observationSkill: Int = 1 // See hidden artifacts easier
    var conversationSkill: Int = 1 // Better character responses
    var deductionSkill: Int = 1 // More effective clues

    mutating func gainExperience(_ xp: Int, for activity: Activity) {
        experiencePoints += xp

        // Level up
        while experiencePoints >= experienceToNextLevel {
            levelUp()
        }

        // Skill progression
        improveSkill(for: activity)
    }
}
```

### Unlocking New Eras

**Tier 1 (Available at Start)**
- Ancient Egypt (3100 BCE)
- Ancient Greece (800 BCE)
- Ancient Rome (500 BCE)

**Tier 2 (Unlock at Level 5)**
- Medieval Europe (1000 CE)
- Ancient China (221 BCE)
- Mayan Civilization (250 CE)

**Tier 3 (Unlock at Level 10)**
- Renaissance Italy (1400 CE)
- Edo Period Japan (1600 CE)
- Industrial Revolution (1760 CE)

**Tier 4 (Unlock at Level 20)**
- Ancient India (500 BCE)
- Islamic Golden Age (750 CE)
- Age of Exploration (1500 CE)

### Artifact Collection System

```swift
enum ArtifactRarity {
    case common      // 60% drop rate
    case uncommon    // 25% drop rate
    case rare        // 10% drop rate
    case epic        // 4% drop rate
    case legendary   // 1% drop rate
}

struct ArtifactCollection {
    var totalArtifacts: Int = 0
    var artifactsByEra: [HistoricalEra: [Artifact]] = [:]
    var artifactsByRarity: [ArtifactRarity: [Artifact]] = [:]

    var completionPercentage: Double {
        Double(totalArtifacts) / Double(totalPossibleArtifacts) * 100.0
    }

    func checkSetCompletion(era: HistoricalEra) -> Bool {
        let collected = artifactsByEra[era]?.count ?? 0
        let total = era.totalArtifacts
        return collected == total
    }

    mutating func addArtifact(_ artifact: Artifact) {
        totalArtifacts += 1
        artifactsByEra[artifact.era, default: []].append(artifact)
        artifactsByRarity[artifact.rarity, default: []].append(artifact)

        // Check for set completion rewards
        if checkSetCompletion(era: artifact.era) {
            unlockSetBonus(era: artifact.era)
        }
    }
}
```

## Level Design Principles

### Historical Environment Structure

Each historical era follows this spatial design:

```
Central Hub (Safe Zone)
├── Discovery Zones (Artifact Areas)
│   ├── High Ground Artifacts (on surfaces)
│   ├── Hidden Artifacts (require exploration)
│   └── Special Artifacts (puzzle-locked)
├── Character Interaction Zones
│   ├── Teacher Character (always available)
│   ├── Expert Character (quest giver)
│   └── Common Folk (ambient dialogue)
├── Information Stations
│   ├── Timeline Wall
│   ├── Map Display
│   └── Encyclopedia Access
└── Mystery Zones
    ├── Crime Scene (investigation)
    ├── Puzzle Area (challenges)
    └── Resolution Point (solution)
```

### Ancient Egypt Example Layout

```
Player's Room (3m x 3m) Transforms Into:

North Wall:
- Pyramid vista with Nile River visible
- Timeline of dynasties (interactive)
- Hieroglyphics tutorial area

East Wall:
- Market scene with ambient NPCs
- Artifact vendor (teaches about trade)
- Common artifacts on market stall

South Wall:
- Temple entrance
- Pharaoh's throne room
- Historical character position (Cleopatra)

West Wall:
- Scribe's workshop
- Papyrus scrolls (readable)
- Writing tutorial

Floor:
- Stone tile overlay (period-appropriate)
- Scattered artifacts (discoverable)
- Puzzle floor patterns

Center:
- Rotating sarcophagus (examination piece)
- Mystery investigation table
- Player's virtual journal
```

### Spatial Gameplay Design for Vision Pro

#### Comfort-First Design
- **No Artificial Movement**: Player uses natural walking within tracked space
- **Stationary Comfort**: All content accessible from seated or standing position
- **Visual Stability**: Artifacts anchored to real surfaces reduce motion sickness
- **Break Integration**: Natural pause points every 10-15 minutes
- **Progressive Immersion**: Gradual transition from real to historical environment

#### Interaction Zones

```swift
enum InteractionZone {
    case near(0.3...1.0)     // meters - Detailed examination
    case mid(1.0...2.5)      // meters - Character conversation
    case far(2.5...4.0)      // meters - Environmental elements
    case ambient(4.0+)       // meters - Background atmosphere
}

struct SpatialLayout {
    func placeContent(in room: RoomModel) {
        // Near zone: Artifacts on real surfaces
        placeArtifacts(on: room.surfaces, zone: .near)

        // Mid zone: Characters and UI elements
        placeCharacters(in: room.center, zone: .mid)

        // Far zone: Environmental overlays
        placeEnvironment(on: room.walls, zone: .far)

        // Ambient zone: Skybox and atmospheric effects
        placeAmbiance(zone: .ambient)
    }
}
```

## Spatial Gameplay Design for Vision Pro

### Multi-Modal Interaction Design

#### Gaze + Pinch (Primary)
```
Look at artifact → Highlight appears → Pinch to select → Opens detail view
```

#### Hand Tracking (Secondary)
```
Reach toward artifact → Hand proximity highlight → Grab gesture → Pick up artifact
```

#### Voice Commands (Tertiary)
```
"Show me pottery" → Highlights all pottery → "Examine that one" → Opens detail view
```

### HUD Design in Spatial Context

#### Persistent HUD Elements

```
Eye-Level (2m distance):
┌─────────────────────────────────────────────────┐
│  Current Era: Ancient Egypt                     │
│  ┌─────────┐  ┌──────────┐  ┌────────────────┐ │
│  │ Journal │  │ Timeline │  │ Objectives 3/5 │ │
│  └─────────┘  └──────────┘  └────────────────┘ │
└─────────────────────────────────────────────────┘

Bottom-Right (Peripheral):
┌──────────────────┐
│ Discovered: 12/50│
│ XP: 450/500      │
│ Level: 5         │
└──────────────────┘

Top-Left (Contextual):
┌──────────────────┐
│ Hint Available   │
│ [Look to view]   │
└──────────────────┘
```

#### Contextual Overlays

When examining artifacts:
```
           ╔═══════════════════════════════════╗
           ║  EGYPTIAN POTTERY VESSEL          ║
           ║  ─────────────────────────────    ║
           ║  Period: New Kingdom (1550 BCE)   ║
           ║  Material: Clay, Painted          ║
           ║  Use: Storage vessel              ║
           ║                                   ║
           ║  ⚪ Historical Context             ║
           ║  ⚪ Cultural Significance          ║
           ║  ⚪ Construction Method            ║
           ║                                   ║
           ║  [Rotate to examine details]      ║
           ╚═══════════════════════════════════╝
```

### Menu Systems

#### Main Menu (Window Mode)

```swift
struct MainMenuView: View {
    @StateObject var coordinator: GameCoordinator
    @State private var selectedEra: HistoricalEra?
    @State private var showingProgress = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                // Title
                Text("Time Machine Adventures")
                    .font(.system(size: 56, weight: .bold, design: .serif))
                    .foregroundStyle(.linearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    ))

                // Era Selection Grid
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 200))], spacing: 20) {
                    ForEach(coordinator.availableEras) { era in
                        EraCard(era: era, isUnlocked: era.isUnlocked)
                            .onTapGesture {
                                selectedEra = era
                            }
                    }
                }

                // Action Buttons
                HStack(spacing: 30) {
                    Button(action: { showingProgress = true }) {
                        Label("Progress", systemImage: "chart.bar.fill")
                    }
                    .buttonStyle(.bordered)

                    Button(action: { coordinator.showSettings() }) {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                    .buttonStyle(.bordered)

                    if let era = selectedEra {
                        Button(action: { coordinator.startJourney(era: era) }) {
                            Label("Begin Journey", systemImage: "arrow.right.circle.fill")
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
                }
            }
            .padding(50)
        }
        .sheet(isPresented: $showingProgress) {
            ProgressView(progress: coordinator.playerProgress)
        }
    }
}
```

#### In-Game Pause Menu (Floating Spatial UI)

```swift
struct PauseMenuView: View {
    @Binding var isPresented: Bool
    @ObservedObject var gameState: GameStateManager

    var body: some View {
        ZStack {
            // Semi-transparent background
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .frame(width: 400, height: 500)

            VStack(spacing: 25) {
                Text("Paused")
                    .font(.system(size: 42, weight: .bold))

                Divider()

                // Menu Options
                VStack(spacing: 15) {
                    PauseMenuButton(title: "Resume", icon: "play.fill") {
                        isPresented = false
                    }

                    PauseMenuButton(title: "Journal", icon: "book.fill") {
                        gameState.showJournal()
                    }

                    PauseMenuButton(title: "Timeline", icon: "clock.fill") {
                        gameState.showTimeline()
                    }

                    PauseMenuButton(title: "Artifacts", icon: "cube.fill") {
                        gameState.showCollection()
                    }

                    PauseMenuButton(title: "Settings", icon: "gearshape.fill") {
                        gameState.showSettings()
                    }

                    Divider()

                    PauseMenuButton(title: "Exit to Menu", icon: "rectangle.portrait.and.arrow.right") {
                        gameState.exitToMainMenu()
                    }
                    .foregroundColor(.red)
                }
            }
            .padding(40)
        }
    }
}
```

### Game Settings and Options

```swift
struct GameSettings: Codable {
    // Comfort Settings
    var comfortMode: ComfortMode = .balanced
    var breakReminders: Bool = true
    var breakInterval: TimeInterval = 1800 // 30 minutes
    var reducedMotion: Bool = false
    var vignettingIntensity: Double = 0.3

    // Interaction Settings
    var primaryInput: InputMode = .gazeAndPinch
    var handTrackingEnabled: Bool = true
    var voiceCommandsEnabled: Bool = true
    var gestureSpeed: GestureSpeed = .medium

    // Visual Settings
    var textSize: TextSize = .medium
    var highContrast: Bool = false
    var colorblindMode: ColorblindMode = .none
    var particleEffects: EffectQuality = .high

    // Audio Settings
    var masterVolume: Double = 1.0
    var musicVolume: Double = 0.7
    var sfxVolume: Double = 0.8
    var voiceVolume: Double = 1.0
    var spatialAudioEnabled: Bool = true

    // Accessibility
    var voiceOverEnabled: Bool = false
    var subtitlesEnabled: Bool = true
    var audioDescriptions: Bool = false
    var simplifiedUI: Bool = false

    // Learning Settings
    var difficultyLevel: DifficultyLevel = .adaptive
    var hintsEnabled: Bool = true
    var hintFrequency: HintFrequency = .moderate
    var educationalOverlays: Bool = true

    // Privacy
    var eyeTrackingAnalytics: Bool = true
    var usageAnalytics: Bool = true
    var shareProgress: Bool = false
}
```

## Visual Style Guide

### Color Palette

#### Primary Colors
```swift
extension Color {
    // Brand Colors
    static let timeMachineBlue = Color(red: 0.2, green: 0.4, blue: 0.8)
    static let timeMachinePurple = Color(red: 0.5, green: 0.2, blue: 0.8)
    static let timeMachineGold = Color(red: 0.85, green: 0.65, blue: 0.13)

    // Era-Specific Colors
    static let egyptGold = Color(red: 0.85, green: 0.65, blue: 0.13)
    static let greeceBlue = Color(red: 0.0, green: 0.3, blue: 0.6)
    static let romeRed = Color(red: 0.7, green: 0.1, blue: 0.1)
    static let medievalGreen = Color(red: 0.2, green: 0.5, blue: 0.2)
    static let renaissanceYellow = Color(red: 0.9, green: 0.7, blue: 0.2)

    // UI Colors
    static let discoveryHighlight = Color(red: 1.0, green: 0.8, blue: 0.2)
    static let interactiveBlue = Color(red: 0.3, green: 0.7, blue: 1.0)
    static let successGreen = Color(red: 0.2, green: 0.8, blue: 0.3)
    static let warningOrange = Color(red: 1.0, green: 0.6, blue: 0.0)
}
```

### Typography System

```swift
extension Font {
    // Headings
    static let heroTitle = Font.custom("Cinzel-Bold", size: 56)
    static let sectionTitle = Font.custom("Cinzel-Bold", size: 42)
    static let cardTitle = Font.custom("Cinzel-SemiBold", size: 28)

    // Body Text
    static let bodyLarge = Font.system(size: 20, weight: .regular, design: .serif)
    static let bodyMedium = Font.system(size: 16, weight: .regular, design: .serif)
    static let bodySmall = Font.system(size: 14, weight: .regular, design: .serif)

    // UI Elements
    static let buttonText = Font.system(size: 18, weight: .semibold, design: .rounded)
    static let captionText = Font.system(size: 12, weight: .medium, design: .rounded)

    // Educational Content
    static let historicalFacts = Font.custom("Garamond", size: 18)
    static let artifactLabels = Font.custom("Garamond", size: 14)
}
```

### Material and Shader Specifications

#### Artifact Materials
```swift
struct ArtifactMaterials {
    // Ancient Pottery
    static func pottery() -> PhysicallyBasedMaterial {
        var material = PhysicallyBasedMaterial()
        material.baseColor = .init(tint: .brown, texture: .init("pottery_diffuse"))
        material.roughness = .init(floatLiteral: 0.7)
        material.normal = .init(texture: .init("pottery_normal"))
        return material
    }

    // Metal (Bronze, Iron, Gold)
    static func metal(type: MetalType) -> PhysicallyBasedMaterial {
        var material = PhysicallyBasedMaterial()
        material.baseColor = .init(tint: type.color, texture: .init(type.texture))
        material.roughness = .init(floatLiteral: type.roughness)
        material.metallic = .init(floatLiteral: 0.9)
        material.normal = .init(texture: .init(type.normalMap))
        return material
    }

    // Stone
    static func stone() -> PhysicallyBasedMaterial {
        var material = PhysicallyBasedMaterial()
        material.baseColor = .init(tint: .gray, texture: .init("stone_diffuse"))
        material.roughness = .init(floatLiteral: 0.9)
        material.normal = .init(texture: .init("stone_normal"))
        material.ambientOcclusion = .init(texture: .init("stone_ao"))
        return material
    }
}
```

## Audio Design

### Spatial Audio Implementation

#### Historical Soundscapes

```swift
struct HistoricalSoundscape {
    let era: HistoricalEra

    func createAmbiance() -> [PositionedAudioSource] {
        switch era {
        case .ancientEgypt:
            return [
                PositionedAudioSource(
                    file: "egypt_nile_water.wav",
                    position: SIMD3<Float>(10, 0, 0),
                    volume: 0.3,
                    looping: true,
                    falloffDistance: 5.0
                ),
                PositionedAudioSource(
                    file: "egypt_market_chatter.wav",
                    position: SIMD3<Float>(-5, 0, 5),
                    volume: 0.4,
                    looping: true,
                    falloffDistance: 3.0
                ),
                PositionedAudioSource(
                    file: "egypt_construction.wav",
                    position: SIMD3<Float>(0, 0, -10),
                    volume: 0.2,
                    looping: true,
                    falloffDistance: 8.0
                )
            ]

        case .medievalCastle:
            return [
                PositionedAudioSource(
                    file: "castle_torch_crackle.wav",
                    position: SIMD3<Float>(0, 2, -2),
                    volume: 0.2,
                    looping: true,
                    falloffDistance: 2.0
                ),
                PositionedAudioSource(
                    file: "castle_distant_bells.wav",
                    position: SIMD3<Float>(20, 0, 0),
                    volume: 0.3,
                    looping: false,
                    falloffDistance: 15.0
                )
            ]

        default:
            return []
        }
    }
}
```

### Music System

```swift
class MusicSystem {
    private var currentTrack: AVAudioPlayerNode?
    private let audioEngine: AVAudioEngine

    // Adaptive music based on activity
    func setMusicForActivity(_ activity: GameActivity) {
        let track: String

        switch activity {
        case .exploration:
            track = "\(currentEra.name)_ambient_exploration"
        case .mystery:
            track = "\(currentEra.name)_mystery_investigation"
        case .conversation:
            track = "\(currentEra.name)_dialogue_theme"
        case .discovery:
            track = "discovery_fanfare"
        case .learning:
            track = "\(currentEra.name)_peaceful_study"
        }

        crossfade(to: track, duration: 2.0)
    }

    private func crossfade(to newTrack: String, duration: TimeInterval) {
        // Fade out current track
        currentTrack?.volume = 0.0

        // Load and fade in new track
        let newPlayer = loadTrack(newTrack)
        newPlayer.volume = 0.0
        newPlayer.play()

        // Animate volume change
        animateVolume(newPlayer, to: 0.7, duration: duration)

        currentTrack = newPlayer
    }
}
```

### Sound Effects Library

```swift
enum SoundEffect {
    // Artifact Interactions
    case artifactPickup(material: Material)
    case artifactPlace(material: Material)
    case artifactExamine

    // UI
    case menuSelect
    case menuBack
    case pageFlip
    case notification

    // Discovery
    case artifactDiscovered
    case mysteryClueFound
    case mysteryComplete
    case levelUp

    // Character
    case characterGreeting
    case characterFarewell
    case characterThinking

    // Environment
    case timePortalOpen
    case timePortalClose
    case environmentTransition

    var filename: String {
        switch self {
        case .artifactPickup(.pottery): return "pottery_pickup.wav"
        case .artifactPickup(.metal): return "metal_pickup.wav"
        case .artifactPickup(.stone): return "stone_pickup.wav"
        case .artifactDiscovered: return "discovery_chime.wav"
        case .mysteryComplete: return "mystery_solved_fanfare.wav"
        // ... more cases
        default: return "default_sfx.wav"
        }
    }
}
```

## Accessibility for Gaming

### Visual Accessibility

```swift
struct VisualAccessibility {
    // High Contrast Mode
    static func applyHighContrast() {
        UIColors.artifactHighlight = .yellow
        UIColors.interactiveElements = .white
        UIColors.background = .black
        UIColors.text = .white
        UIColors.borders = .white

        // Increase outline thickness
        OutlineRenderer.thickness = 4.0
    }

    // Colorblind Modes
    enum ColorblindMode {
        case none
        case protanopia   // Red-weak
        case deuteranopia // Green-weak
        case tritanopia   // Blue-weak

        func applyFilter() -> ColorMatrix {
            switch self {
            case .protanopia:
                return ColorMatrix.protanopia
            case .deuteranopia:
                return ColorMatrix.deuteranopia
            case .tritanopia:
                return ColorMatrix.tritanopia
            case .none:
                return ColorMatrix.identity
            }
        }
    }

    // Text Size Scaling
    enum TextSize: Double {
        case small = 0.8
        case medium = 1.0
        case large = 1.3
        case extraLarge = 1.6
        case accessibility = 2.0
    }
}
```

### Motor Accessibility

```swift
struct MotorAccessibility {
    // Dwell-based Selection (no pinch required)
    static func enableDwellSelection(duration: TimeInterval = 1.0) {
        GazeInteractionSystem.dwellTime = duration
        GazeInteractionSystem.requiresPinch = false
        GazeInteractionSystem.visualFeedback = .progressRing
    }

    // Voice-Only Mode
    static func enableVoiceOnlyMode() {
        InputSystem.primaryInput = .voice
        InputSystem.gesturesEnabled = false

        // Expand voice command vocabulary
        VoiceCommandSystem.enableFullVocabulary()
    }

    // Simplified Gestures
    static func enableSimplifiedGestures() {
        GestureRecognition.pinchThreshold = 0.04 // Easier to trigger
        GestureRecognition.grabThreshold = 0.6   // Less curl required
        GestureRecognition.pointThreshold = 0.8  // More forgiving
    }

    // One-Handed Mode
    static func enableOneHandedMode() {
        InputSystem.requiresBothHands = false
        UI.repositionForSingleHand = true
        Artifacts.allowOneHandedManipulation = true
    }
}
```

### Cognitive Accessibility

```swift
struct CognitiveAccessibility {
    // Simplified UI Mode
    static func enableSimplifiedMode() {
        UI.reduceVisualClutter = true
        UI.largerHitTargets = true
        UI.fewerSimultaneousElements = 3
        UI.clearerInstructions = true

        // Disable time pressure
        GameRules.removeTimeLimits = true

        // Linear progression only
        GameFlow.disableBranching = true
    }

    // Visual Schedules
    struct VisualSchedule {
        let steps: [ScheduleStep]

        func display() {
            // Show clear, sequential steps
            // Highlight current step
            // Check off completed steps
        }
    }

    // Reduced Stimulation Mode
    static func enableQuietMode() {
        Audio.reduceAmbientSounds = true
        Visual.reduceParticleEffects = true
        Visual.reduceAnimations = true
        UI.useCalmerColors = true
    }
}
```

## Tutorial and Onboarding Design

### First-Time User Experience (FTUE)

```swift
struct OnboardingFlow {
    enum Step {
        case welcome
        case roomCalibration
        case comfortSettings
        case gestureTraining
        case firstTimeJump
        case firstArtifact
        case firstCharacter
        case journalIntro
        case mysteryIntro
        case completion
    }

    func startOnboarding(player: Player) async {
        // 1. Welcome (30 seconds)
        await showWelcomeScreen()

        // 2. Room Calibration (2 minutes)
        await calibrateRoom()

        // 3. Comfort Settings (1 minute)
        await setupComfortSettings()

        // 4. Gesture Training (3 minutes)
        await teachGestures()

        // 5. First Time Jump - Ancient Egypt (2 minutes)
        await firstTimeTravel()

        // 6. First Artifact Discovery (3 minutes)
        await guidedArtifactDiscovery()

        // 7. First Character Interaction (3 minutes)
        await guidedCharacterMeeting()

        // 8. Journal System (2 minutes)
        await introduceJournal()

        // 9. Simple Mystery (5 minutes)
        await guidedMystery()

        // 10. Completion (1 minute)
        await celebrateCompletion()

        player.hasCompletedOnboarding = true
    }
}
```

### Gesture Tutorial

```swift
struct GestureTutorial {
    func teachPinchGesture() async {
        // Show hand animation
        displayHandAnimation(.pinch)

        // Instructions
        showInstructions("""
        Pinch gesture:
        Touch your thumb and index finger together
        This is how you'll select and pick up artifacts
        """)

        // Practice target
        let practiceTarget = createPracticeTarget()

        // Wait for successful gesture
        repeat {
            await waitForGesture(.pinch)
            if detectPinchAt(practiceTarget.position) {
                playSuccess()
                break
            }
        } while true

        showEncouragement("Great! You've mastered the pinch gesture!")
    }

    func teachAllGestures() async {
        await teachPinchGesture()
        await teachGrabGesture()
        await teachPointGesture()
        await teachVoiceCommands()
    }
}
```

## Difficulty Balancing

### Adaptive Difficulty System

```swift
class AdaptiveDifficultySystem {
    private var playerSkillRating: Double = 5.0 // 1-10 scale
    private var recentPerformance: [Double] = []

    func adjustDifficulty(based on performance: PerformanceMetrics) {
        // Track recent performance
        recentPerformance.append(performance.successRate)
        if recentPerformance.count > 10 {
            recentPerformance.removeFirst()
        }

        // Calculate average performance
        let avgPerformance = recentPerformance.reduce(0, +) / Double(recentPerformance.count)

        // Adjust skill rating
        if avgPerformance > 0.8 {
            // Too easy, increase difficulty
            playerSkillRating = min(10.0, playerSkillRating + 0.2)
        } else if avgPerformance < 0.4 {
            // Too hard, decrease difficulty
            playerSkillRating = max(1.0, playerSkillRating - 0.3)
        }

        // Apply difficulty adjustments
        applyDifficultyLevel(playerSkillRating)
    }

    private func applyDifficultyLevel(_ rating: Double) {
        // Mystery complexity
        MysteryGenerator.complexity = rating / 10.0

        // Number of clues
        MysteryGenerator.clueCount = Int(5 + (10 - rating))

        // Hint availability
        HintSystem.hintCooldown = TimeInterval(30 * (rating / 5.0))

        // Character helpfulness
        CharacterAI.hintFrequency = 1.0 - (rating / 15.0)
    }
}
```

### Difficulty Presets

```swift
enum DifficultyPreset {
    case elementary    // Ages 8-11
    case middle        // Ages 12-14
    case high          // Ages 15-18
    case adult         // Ages 18+
    case adaptive      // Auto-adjusting

    var settings: DifficultySettings {
        switch self {
        case .elementary:
            return DifficultySettings(
                vocabularyLevel: .simple,
                clueCount: 10,
                hintFrequency: .frequent,
                mysteryComplexity: 0.3,
                timeLimit: nil
            )

        case .middle:
            return DifficultySettings(
                vocabularyLevel: .intermediate,
                clueCount: 7,
                hintFrequency: .moderate,
                mysteryComplexity: 0.5,
                timeLimit: nil
            )

        case .high:
            return DifficultySettings(
                vocabularyLevel: .advanced,
                clueCount: 5,
                hintFrequency: .minimal,
                mysteryComplexity: 0.7,
                timeLimit: 3600 // 1 hour
            )

        case .adult:
            return DifficultySettings(
                vocabularyLevel: .scholarly,
                clueCount: 4,
                hintFrequency: .none,
                mysteryComplexity: 0.9,
                timeLimit: 2700 // 45 minutes
            )

        case .adaptive:
            return DifficultySettings.adaptive()
        }
    }
}
```

## Educational Alignment

### Curriculum Standards Integration

```swift
struct CurriculumStandard: Identifiable {
    let id: UUID
    let standardCode: String       // e.g., "CCSS.ELA-LITERACY.RH.6-8.1"
    let description: String
    let gradeLevel: GradeLevel
    let subject: Subject
    let learningObjectives: [LearningObjective]

    enum Subject {
        case history
        case socialStudies
        case language
        case science
        case art
    }

    enum GradeLevel {
        case elementary(3...5)
        case middle(6...8)
        case high(9...12)
    }
}

struct LearningObjective {
    let description: String
    let bloomsLevel: BloomsLevel
    let assessmentCriteria: [AssessmentCriterion]

    enum BloomsLevel {
        case remember      // Recall facts
        case understand    // Explain concepts
        case apply         // Use knowledge in new situations
        case analyze       // Break down information
        case evaluate      // Make judgments
        case create        // Produce new work
    }
}
```

### Assessment Integration

```swift
class AssessmentSystem {
    func createAssessment(for era: HistoricalEra, level: GradeLevel) -> Assessment {
        let objectives = era.learningObjectives.filter { $0.gradeLevel == level }

        return Assessment(
            objectives: objectives,
            questions: generateQuestions(objectives),
            rubric: createRubric(objectives),
            duration: calculateDuration(objectives.count)
        )
    }

    private func generateQuestions(_ objectives: [LearningObjective]) -> [Question] {
        objectives.flatMap { objective in
            switch objective.bloomsLevel {
            case .remember:
                return [MultipleChoiceQuestion(objective: objective)]

            case .understand:
                return [ShortAnswerQuestion(objective: objective)]

            case .apply, .analyze:
                return [ScenarioQuestion(objective: objective)]

            case .evaluate:
                return [ComparisonQuestion(objective: objective)]

            case .create:
                return [ProjectQuestion(objective: objective)]
            }
        }
    }
}
```

This comprehensive design document provides a complete blueprint for creating an engaging, educational, and accessible visionOS game that transforms history learning through spatial computing.
