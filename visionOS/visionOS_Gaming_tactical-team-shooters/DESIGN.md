# Tactical Team Shooters - Design Document

## Table of Contents
1. [Game Design Document (GDD) Elements](#game-design-document-gdd-elements)
2. [Core Gameplay Loop](#core-gameplay-loop)
3. [Player Progression Systems](#player-progression-systems)
4. [Level Design Principles](#level-design-principles)
5. [Spatial Gameplay Design](#spatial-gameplay-design)
6. [UI/UX for Gaming](#uiux-for-gaming)
7. [Visual Style Guide](#visual-style-guide)
8. [Audio Design](#audio-design)
9. [Accessibility](#accessibility)
10. [Tutorial and Onboarding](#tutorial-and-onboarding)
11. [Difficulty Balancing](#difficulty-balancing)

---

## Game Design Document (GDD) Elements

### Game Concept
**Title:** Tactical Team Shooters
**Genre:** Competitive Tactical FPS
**Platform:** Apple Vision Pro (visionOS 2.0+)
**Target Audience:** Competitive gamers (18-35), tactical training professionals (20-45)

### Core Pillars
1. **Tactical Realism**: Authentic military tactics and procedures
2. **Spatial Innovation**: Leverage Vision Pro's unique capabilities
3. **Competitive Integrity**: Fair, skill-based gameplay
4. **Team Coordination**: Emphasis on communication and strategy
5. **Professional Training**: Real-world skill development

### Unique Selling Points
- Full 360-degree spatial combat environments
- Physical tactical movement training
- Sub-millimeter precision aiming
- Real furniture integration as cover
- Professional tactical training certification

---

## Core Gameplay Loop

### Match Flow

```
Pre-Match Phase (2 minutes)
├── Team Selection & Role Assignment
├── Loadout Customization
├── Map Voting
└── Strategic Planning

↓

Round Start (15 seconds)
├── Freeze Time: Buy Equipment
├── Team Strategy Review
└── Position Setup

↓

Round Active (2-3 minutes)
├── Tactical Movement
├── Enemy Engagement
├── Objective Execution (Attack/Defend)
└── Team Coordination

↓

Round End (10 seconds)
├── Victory/Defeat Display
├── Score Update
├── MVP Highlight
└── Next Round Preparation

↓

Post-Match (30 seconds)
├── Final Scoreboard
├── Performance Statistics
├── XP & Rewards
├── Rank Update
└── Play Again / Exit
```

### Moment-to-Moment Gameplay

**Every Second:**
- Scan environment for threats
- Maintain tactical positioning
- Monitor team locations
- Adjust aim and stance
- Listen for audio cues

**Every 5-10 Seconds:**
- Make tactical decisions
- Communicate with team
- Reposition for advantage
- Check ammunition/equipment
- Assess objective status

**Every 30-60 Seconds:**
- Execute tactical maneuvers
- Coordinate team pushes
- Adapt strategy
- Manage resources
- Evaluate round state

---

## Player Progression Systems

### Experience & Leveling

```swift
struct ProgressionSystem {
    // Player level (1-100)
    var level: Int = 1
    var currentXP: Int = 0

    func xpRequiredForLevel(_ level: Int) -> Int {
        // Exponential curve: Base * (1.15 ^ level)
        return Int(1000.0 * pow(1.15, Double(level)))
    }

    // XP sources
    enum XPSource {
        case kill(headshot: Bool)          // 100 XP (200 for headshot)
        case assist                        // 50 XP
        case objectiveComplete             // 500 XP
        case roundWin                      // 300 XP
        case matchWin                      // 1000 XP
        case dailyMission                  // 500-2000 XP
        case trainingExercise(score: Int)  // 100-500 XP
    }
}
```

### Competitive Ranking

```swift
enum CompetitiveRank: Int, CaseIterable {
    case recruit        // 0-999 ELO
    case specialist     // 1000-1499
    case veteran        // 1500-1999
    case elite          // 2000-2499
    case master         // 2500-2999
    case legend         // 3000+

    var requiredWins: Int {
        switch self {
        case .recruit: return 0
        case .specialist: return 10
        case .veteran: return 25
        case .elite: return 50
        case .master: return 100
        case .legend: return 200
        }
    }

    var emblem: String {
        // Asset reference for rank emblem
        "Rank_\(rawValue)"
    }
}
```

### Weapon Progression

```swift
struct WeaponProgression {
    let weapon: Weapon
    var kills: Int = 0
    var headshots: Int = 0
    var accuracy: Double = 0.0

    // Unlock attachments based on performance
    var unlockedAttachments: [Attachment] {
        var unlocked: [Attachment] = []

        if kills >= 10 {
            unlocked.append(.holographicSight)
        }
        if kills >= 50 {
            unlocked.append(.compensator)
        }
        if kills >= 100 {
            unlocked.append(.verticalGrip)
        }
        if headshots >= 25 {
            unlocked.append(.magnifiedScope)
        }
        if accuracy >= 0.35 {
            unlocked.append(.extendedMag)
        }

        return unlocked
    }

    // Weapon mastery (Bronze/Silver/Gold)
    var masteryLevel: MasteryLevel {
        if kills >= 500 && accuracy >= 0.40 {
            return .gold
        } else if kills >= 250 && accuracy >= 0.30 {
            return .silver
        } else if kills >= 100 {
            return .bronze
        }
        return .none
    }
}
```

### Achievement System

```swift
struct Achievement: Identifiable {
    let id: UUID
    let title: String
    let description: String
    let icon: String
    let xpReward: Int
    let requirement: AchievementRequirement
}

enum AchievementRequirement {
    case killsInMatch(Int)
    case winStreak(Int)
    case headshotPercentage(Double)
    case clutchRound(playersAlive: Int)
    case teamWipe
    case defuseBomb(timeRemaining: TimeInterval)
    case completeMission(missionId: UUID)
    case reachRank(CompetitiveRank)
}

// Example achievements
let achievements: [Achievement] = [
    Achievement(
        id: UUID(),
        title: "First Blood",
        description: "Get the first kill in a round",
        icon: "FirstBlood",
        xpReward: 100,
        requirement: .killsInMatch(1)
    ),
    Achievement(
        id: UUID(),
        title: "Sharpshooter",
        description: "Achieve 60% headshot percentage in a match",
        icon: "Sharpshooter",
        xpReward: 500,
        requirement: .headshotPercentage(0.60)
    ),
    Achievement(
        id: UUID(),
        title: "Clutch Master",
        description: "Win a 1v4 clutch round",
        icon: "ClutchMaster",
        xpReward: 1000,
        requirement: .clutchRound(playersAlive: 1)
    )
]
```

### Battle Pass (Seasonal)

```swift
struct BattlePass {
    let season: Int
    var tier: Int = 1
    var xp: Int = 0

    let maxTier = 100
    let xpPerTier = 5000

    struct Reward {
        let tier: Int
        let item: RewardItem
        let isPremium: Bool
    }

    enum RewardItem {
        case weaponSkin(Weapon)
        case charm
        case emblem
        case cardBack
        case xpBoost(percentage: Int, duration: TimeInterval)
        case currency(amount: Int)
    }

    // Example rewards
    let rewards: [Reward] = [
        Reward(tier: 1, item: .emblem, isPremium: false),
        Reward(tier: 5, item: .weaponSkin(.assaultRifle), isPremium: true),
        Reward(tier: 10, item: .xpBoost(percentage: 50, duration: 86400), isPremium: false),
        // ... 100 total tiers
    ]
}
```

---

## Level Design Principles

### Map Design Philosophy

1. **Three-Lane Structure**: Classic competitive layout
   - Balanced routes for attackers and defenders
   - Multiple engagement distances (CQB, mid-range, long-range)
   - Verticality for tactical advantage

2. **Landmark-Based Navigation**
   - Clear callout points for team communication
   - Distinctive visual areas for orientation
   - Memorable tactical positions

3. **Risk-Reward Positioning**
   - Power positions require exposure to reach
   - High-risk flanking routes
   - Safe but slower main routes

### Spatial Considerations for Vision Pro

```swift
struct MapDesign {
    // Room requirements
    let minimumPlaySpace = SIMD3<Float>(2.5, 2.5, 2.5)  // 2.5m cube
    let recommendedPlaySpace = SIMD3<Float>(3.5, 2.8, 3.5)  // 3.5m x 2.8m tall

    // Virtual space mapping
    let virtualSpaceScale: Float = 2.0  // 2m virtual = 1m real

    // Cover generation
    func generateCoverFromFurniture(_ room: RoomScan) -> [CoverPoint] {
        var coverPoints: [CoverPoint] = []

        // Identify furniture pieces
        for object in room.objects {
            if object.isTableOrDesk {
                // Table = half cover
                coverPoints.append(CoverPoint(
                    position: object.position,
                    type: .half,
                    facingDirections: calculateFacingDirections(object)
                ))
            } else if object.isChairOrCouch {
                // Chair = partial cover
                coverPoints.append(CoverPoint(
                    position: object.position,
                    type: .partial,
                    facingDirections: calculateFacingDirections(object)
                ))
            } else if object.isWall {
                // Wall corners = full cover
                let corners = findCorners(object)
                for corner in corners {
                    coverPoints.append(CoverPoint(
                        position: corner,
                        type: .full,
                        facingDirections: [corner.normal]
                    ))
                }
            }
        }

        return coverPoints
    }
}
```

### Tactical Positions

```swift
enum TacticalPosition {
    case spawnPoint(team: Team)
    case bombSite(site: String)  // "A" or "B"
    case chokePoint(importance: Float)
    case sniperNest(sightLines: [SIMD3<Float>])
    case rotationRoute(connects: [String])
    case coverPosition(type: CoverType)
}

struct MapLayout {
    let name: String
    let positions: [TacticalPosition]
    let callouts: [String: SIMD3<Float>]

    // Example: "Warehouse" map
    static let warehouse = MapLayout(
        name: "Warehouse",
        positions: [
            .spawnPoint(team: .attackers),
            .spawnPoint(team: .defenders),
            .bombSite(site: "A"),
            .bombSite(site: "B"),
            .chokePoint(importance: 0.9),  // "Main Entrance"
            .sniperNest(sightLines: [/* ... */])
        ],
        callouts: [
            "Main": SIMD3<Float>(0, 0, 10),
            "Catwalk": SIMD3<Float>(5, 2, 15),
            "Boxes": SIMD3<Float>(-3, 0, 8),
            "Back Site": SIMD3<Float>(10, 0, 20),
            "Heaven": SIMD3<Float>(7, 3, 18)
        ]
    )
}
```

---

## Spatial Gameplay Design

### Room-Scale Integration

```swift
class SpatialGameplayManager {
    // Blend real and virtual environments
    func setupBattlefield(in room: ARMeshAnchor) {
        // 1. Scan room boundaries
        let boundaries = extractRoomBoundaries(room)

        // 2. Place spawn points at opposite ends
        let spawnA = boundaries.corners[0]
        let spawnB = boundaries.corners[2]  // Diagonal opposite

        // 3. Identify cover positions
        let coverPositions = identifyNaturalCover(room)

        // 4. Generate objective locations
        let objectiveA = findCentralPosition(near: spawnA)
        let objectiveB = findCentralPosition(near: spawnB)

        // 5. Create virtual enhancements
        addVirtualWalls(at: boundaries.gaps)
        addVirtualCover(supplementing: coverPositions)
        addVirtualObjectives(at: [objectiveA, objectiveB])

        // 6. Setup lighting and atmosphere
        configureSpatialLighting(matching: room.lighting)
        addAtmosphericEffects()
    }

    // Adaptive scaling for different room sizes
    func scaleGameplayForRoom(size: SIMD3<Float>) -> GameplayScale {
        if size.x < 2.5 || size.z < 2.5 {
            return .smallRoom(
                playerCount: 2,  // 1v1 only
                mapScale: 0.75,
                movementSpeed: 0.8
            )
        } else if size.x < 3.5 || size.z < 3.5 {
            return .mediumRoom(
                playerCount: 6,  // 3v3
                mapScale: 1.0,
                movementSpeed: 1.0
            )
        } else {
            return .largeRoom(
                playerCount: 10,  // 5v5
                mapScale: 1.25,
                movementSpeed: 1.0
            )
        }
    }
}
```

### Physical Movement Mechanics

```swift
class PhysicalMovementSystem {
    // Track actual player movement
    func processPlayerMovement() {
        let currentPosition = getHeadsetPosition()
        let deltaMovement = currentPosition - lastPosition

        // Translate real movement to game movement
        var gameMovement = deltaMovement * movementScale

        // Apply movement constraints
        if isPlayerCrouching() {
            gameMovement *= 0.6  // Slower when crouched
            playerCharacter.stance = .crouching
        } else if isPlayerProne() {
            gameMovement *= 0.3  // Very slow when prone
            playerCharacter.stance = .prone
        } else {
            playerCharacter.stance = .standing
        }

        // Update game character position
        playerCharacter.move(by: gameMovement)

        // Generate movement sounds
        if length(gameMovement) > 0.01 {
            playFootstepSound(stance: playerCharacter.stance)
        }

        lastPosition = currentPosition
    }

    func isPlayerCrouching() -> Bool {
        let headHeight = getHeadsetPosition().y
        return headHeight < restingHeadHeight * 0.7
    }

    func isPlayerProne() -> Bool {
        let headHeight = getHeadsetPosition().y
        return headHeight < restingHeadHeight * 0.4
    }
}
```

### Spatial Audio Positioning

```swift
class SpatialAudioGameplay {
    // Use audio for tactical advantage
    func processGameAudio() {
        // Footsteps
        for enemy in nearbyEnemies {
            let distance = length(enemy.position - player.position)

            if distance < audioDetectionRange {
                playSpatialFootsteps(
                    at: enemy.position,
                    volume: calculateVolumeForDistance(distance),
                    surface: enemy.currentSurface
                )
            }
        }

        // Gunfire
        for shot in activeShots {
            playSpatialGunfire(
                at: shot.origin,
                weaponType: shot.weapon,
                direction: shot.direction
            )
        }

        // Environmental audio
        playAmbientSounds()

        // Team voice comms
        for teammate in team.members {
            // Positional voice chat
            routeVoiceAudio(
                from: teammate,
                spatialPosition: teammate.position
            )
        }
    }

    func calculateVolumeForDistance(_ distance: Float) -> Float {
        // Inverse square law
        let referenceDistance: Float = 1.0
        return min(1.0, pow(referenceDistance / distance, 2))
    }
}
```

---

## UI/UX for Gaming

### HUD Design in Spatial Context

```swift
struct GameHUD: View {
    @ObservedObject var gameState: GameState
    @State private var hudOpacity: Double = 1.0

    var body: some View {
        ZStack {
            // Minimal HUD for immersion
            VStack {
                // Top: Match info
                HStack {
                    TeamScoreView(team: .attackers, score: gameState.attackerScore)
                    Spacer()
                    TimerView(timeRemaining: gameState.roundTimeRemaining)
                    Spacer()
                    TeamScoreView(team: .defenders, score: gameState.defenderScore)
                }
                .padding()

                Spacer()

                // Bottom: Player info
                HStack {
                    // Left: Teammate status
                    TeamStatusView(teammates: gameState.teammates)

                    Spacer()

                    // Center: Weapon & ammo
                    VStack {
                        WeaponInfoView(
                            weapon: gameState.player.currentWeapon,
                            ammo: gameState.player.ammo
                        )
                        .font(.system(size: 24, weight: .bold, design: .monospaced))

                        HealthArmorView(
                            health: gameState.player.health,
                            armor: gameState.player.armor
                        )
                    }

                    Spacer()

                    // Right: Minimap
                    MinimapView(
                        map: gameState.currentMap,
                        players: gameState.allPlayers
                    )
                    .frame(width: 200, height: 200)
                }
                .padding()
            }

            // Crosshair (world-locked)
            CrosshairView()
                .position(x: UIScreen.main.bounds.width / 2,
                         y: UIScreen.main.bounds.height / 2)

            // Tactical markers (world-anchored)
            ForEach(gameState.tacticalMarkers) { marker in
                TacticalMarkerView(marker: marker)
                    .position(worldToScreen(marker.position))
            }

            // Damage indicators
            ForEach(gameState.recentDamage) { damage in
                DamageIndicatorView(direction: damage.direction)
                    .transition(.opacity)
            }
        }
        .opacity(hudOpacity)
        .onChange(of: gameState.isInCombat) { inCombat in
            // Reduce HUD opacity during combat for clarity
            hudOpacity = inCombat ? 0.6 : 1.0
        }
    }
}
```

### Menu Systems

```swift
struct MainMenu: View {
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissWindow) var dismissWindow
    @State private var selectedMode: GameMode?

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                BackgroundEffectView()

                VStack(spacing: 40) {
                    // Title
                    VStack(spacing: 10) {
                        Text("TACTICAL TEAM SHOOTERS")
                            .font(.system(size: 48, weight: .black))
                            .foregroundStyle(.white)

                        Text("Precision. Strategy. Teamwork.")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(.gray)
                    }

                    // Main actions
                    VStack(spacing: 20) {
                        Button {
                            selectedMode = .quickMatch
                        } label: {
                            MenuButtonView(
                                title: "Quick Match",
                                subtitle: "Jump into action",
                                icon: "bolt.fill"
                            )
                        }
                        .buttonStyle(.plain)

                        Button {
                            selectedMode = .competitive
                        } label: {
                            MenuButtonView(
                                title: "Competitive",
                                subtitle: "Ranked matchmaking",
                                icon: "shield.fill"
                            )
                        }
                        .buttonStyle(.plain)

                        Button {
                            selectedMode = .training
                        } label: {
                            MenuButtonView(
                                title: "Training",
                                subtitle: "Improve your skills",
                                icon: "target"
                            )
                        }
                        .buttonStyle(.plain)

                        Button {
                            selectedMode = .customGame
                        } label: {
                            MenuButtonView(
                                title: "Custom Game",
                                subtitle: "Create your match",
                                icon: "slider.horizontal.3"
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    .frame(width: 400)

                    // Player stats ornament
                    PlayerCardView()
                }
            }
        }
        .navigationDestination(for: GameMode.self) { mode in
            GameModeView(mode: mode)
        }
        .onAppear {
            // Load player data
        }
    }
}
```

### Settings Interface

```swift
struct SettingsView: View {
    @AppStorage("sensitivity") private var sensitivity: Double = 1.0
    @AppStorage("aimAssist") private var aimAssist: Bool = false
    @AppStorage("graphicsQuality") private var graphicsQuality: GraphicsQuality = .high
    @AppStorage("audioVolume") private var audioVolume: Double = 0.7

    var body: some View {
        Form {
            Section("Controls") {
                VStack(alignment: .leading) {
                    Text("Sensitivity")
                    Slider(value: $sensitivity, in: 0.1...3.0)
                    Text("\(sensitivity, specifier: "%.2f")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Toggle("Aim Assist", isOn: $aimAssist)

                Picker("Dominant Hand", selection: $dominantHand) {
                    Text("Right").tag(Hand.right)
                    Text("Left").tag(Hand.left)
                }
            }

            Section("Graphics") {
                Picker("Quality", selection: $graphicsQuality) {
                    Text("Low").tag(GraphicsQuality.low)
                    Text("Medium").tag(GraphicsQuality.medium)
                    Text("High").tag(GraphicsQuality.high)
                    Text("Ultra").tag(GraphicsQuality.ultra)
                }

                Toggle("Anti-Aliasing", isOn: $antiAliasing)
                Toggle("Shadow Quality", isOn: $shadowQuality)
            }

            Section("Audio") {
                VStack(alignment: .leading) {
                    Text("Master Volume")
                    Slider(value: $audioVolume, in: 0...1)
                }

                Toggle("Spatial Audio", isOn: $spatialAudio)
                Toggle("Voice Chat", isOn: $voiceChat)
            }

            Section("Accessibility") {
                Toggle("Color Blind Mode", isOn: $colorBlindMode)
                Toggle("Reduce Motion", isOn: $reduceMotion)
                Toggle("Text to Speech", isOn: $textToSpeech)
            }
        }
        .navigationTitle("Settings")
    }
}
```

---

## Visual Style Guide

### Art Direction

**Theme:** Near-Future Military Tactical
**Tone:** Serious, Professional, Grounded
**Color Palette:**
- Primary: Military Greens (#2D5016, #4A7C2F)
- Secondary: Tactical Grays (#3A3A3A, #6B6B6B)
- Accent: Mission Orange (#FF6B35)
- UI: Tech Blue (#00A8E8)

### Visual Hierarchy

```swift
enum VisualPriority {
    case critical    // Enemies, threats, objectives
    case high        // Teammates, tactical info
    case medium      // Environment, cover positions
    case low         // Decorative elements, atmosphere

    var renderPriority: Int {
        switch self {
        case .critical: return 1000
        case .high: return 500
        case .medium: return 100
        case .low: return 10
        }
    }

    var visualEmphasis: VisualEmphasis {
        switch self {
        case .critical:
            return VisualEmphasis(
                brightness: 1.2,
                saturation: 1.5,
                outline: true,
                pulseAnimation: true
            )
        case .high:
            return VisualEmphasis(
                brightness: 1.1,
                saturation: 1.2,
                outline: true,
                pulseAnimation: false
            )
        case .medium:
            return VisualEmphasis(
                brightness: 1.0,
                saturation: 1.0,
                outline: false,
                pulseAnimation: false
            )
        case .low:
            return VisualEmphasis(
                brightness: 0.8,
                saturation: 0.8,
                outline: false,
                pulseAnimation: false
            )
        }
    }
}
```

### Material Design

```swift
struct TacticalMaterials {
    // Metal materials for weapons
    static let weaponMetal = PhysicallyBasedMaterial(
        baseColor: .gray,
        metallic: 0.9,
        roughness: 0.3
    )

    // Fabric for tactical gear
    static let tacticalFabric = PhysicallyBasedMaterial(
        baseColor: .init(hex: "2D5016"),
        metallic: 0.0,
        roughness: 0.8
    )

    // Environmental materials
    static let concrete = PhysicallyBasedMaterial(
        baseColor: .init(hex: "A8A8A8"),
        metallic: 0.1,
        roughness: 0.9,
        normalMap: loadTexture("Concrete_Normal")
    )

    static let wood = PhysicallyBasedMaterial(
        baseColor: .init(hex: "8B4513"),
        metallic: 0.0,
        roughness: 0.6,
        normalMap: loadTexture("Wood_Normal")
    )
}
```

### UI Visual Components

```swift
struct TacticalButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 18, weight: .semibold, design: .monospaced))
            .foregroundStyle(.white)
            .frame(height: 50)
            .padding(.horizontal, 30)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(LinearGradient(
                        colors: [Color(hex: "00A8E8"), Color(hex: "0077B6")],
                        startPoint: .top,
                        endPoint: .bottom
                    ))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3), value: configuration.isPressed)
    }
}
```

---

## Audio Design

### Spatial Audio Implementation

```swift
class TacticalAudioEngine {
    let engine = AVAudioEngine()
    let environment = AVAudioEnvironmentNode()

    func setupSpatialAudio() {
        // Configure 3D audio environment
        environment.renderingAlgorithm = .HRTF
        environment.distanceAttenuationParameters.distanceAttenuationModel = .inverse
        environment.distanceAttenuationParameters.referenceDistance = 1.0
        environment.distanceAttenuationParameters.maximumDistance = 100.0
        environment.distanceAttenuationParameters.rolloffFactor = 1.5

        // Reverb for environment
        let reverb = AVAudioUnitReverb()
        reverb.loadFactoryPreset(.largeRoom)
        reverb.wetDryMix = 30

        engine.attach(environment)
        engine.attach(reverb)
        engine.connect(environment, to: reverb, format: nil)
        engine.connect(reverb, to: engine.mainMixerNode, format: nil)

        try? engine.start()
    }

    // Sound categories
    enum SoundCategory {
        case weaponFire
        case weaponReload
        case footsteps
        case voice
        case explosion
        case ambient
        case ui

        var priority: Int {
            switch self {
            case .weaponFire, .explosion: return 100
            case .voice: return 90
            case .footsteps: return 70
            case .weaponReload: return 60
            case .ambient: return 20
            case .ui: return 10
            }
        }

        var maxConcurrent: Int {
            switch self {
            case .weaponFire: return 10
            case .footsteps: return 8
            case .voice: return 5
            case .explosion: return 5
            case .weaponReload: return 5
            case .ambient: return 3
            case .ui: return 2
            }
        }
    }
}
```

### Sound Design Specifications

```swift
struct WeaponSounds {
    // Weapon fire variations
    let fireSounds: [String] = [
        "AK47_Fire_01",
        "AK47_Fire_02",
        "AK47_Fire_03"
    ]

    // Reload sounds (layered)
    struct ReloadSoundSet {
        let magOut: String
        let magIn: String
        let boltRelease: String
        let handling: String
    }

    let reloadSounds = ReloadSoundSet(
        magOut: "AK47_MagOut",
        magIn: "AK47_MagIn",
        boltRelease: "AK47_BoltRelease",
        handling: "AK47_Handling"
    )

    // Surface impact sounds
    let impactSounds: [SurfaceType: [String]] = [
        .metal: ["Impact_Metal_01", "Impact_Metal_02"],
        .concrete: ["Impact_Concrete_01", "Impact_Concrete_02"],
        .wood: ["Impact_Wood_01", "Impact_Wood_02"],
        .flesh: ["Impact_Flesh_01", "Impact_Flesh_02"]
    ]
}

struct FootstepSounds {
    let surfaceSounds: [SurfaceType: [String]] = [
        .concrete: [
            "Footstep_Concrete_01",
            "Footstep_Concrete_02",
            "Footstep_Concrete_03",
            "Footstep_Concrete_04"
        ],
        .metal: [
            "Footstep_Metal_01",
            "Footstep_Metal_02"
        ],
        .wood: [
            "Footstep_Wood_01",
            "Footstep_Wood_02"
        ]
    ]

    // Stance affects volume and pitch
    func getFootstepParams(stance: PlayerStance) -> (volume: Float, pitch: Float) {
        switch stance {
        case .running:
            return (1.0, 1.0)
        case .walking:
            return (0.6, 0.95)
        case .crouching:
            return (0.3, 0.9)
        case .prone:
            return (0.1, 0.85)
        }
    }
}
```

### Music System

```swift
class AdaptiveMusicSystem {
    enum MusicLayer {
        case ambient
        case tension
        case combat
        case victory
        case defeat
    }

    var currentLayers: Set<MusicLayer> = [.ambient]

    func updateMusic(gameState: GameState) {
        // Adaptive music based on gameplay intensity
        if gameState.isInCombat {
            fadeIn(.combat, duration: 2.0)
            fadeOut(.ambient, duration: 2.0)
        } else if gameState.enemiesNearby > 0 {
            fadeIn(.tension, duration: 3.0)
        } else {
            fadeIn(.ambient, duration: 5.0)
            fadeOut(.tension, duration: 5.0)
            fadeOut(.combat, duration: 3.0)
        }

        // Round end music
        if gameState.roundEnded {
            if gameState.playerTeamWon {
                playStinger(.victory)
            } else {
                playStinger(.defeat)
            }
        }
    }
}
```

---

## Accessibility

### Vision Accessibility

```swift
struct VisualAccessibility {
    // Color blind modes
    enum ColorBlindMode {
        case none
        case protanopia     // Red-blind
        case deuteranopia   // Green-blind
        case tritanopia     // Blue-blind

        func adjustColor(_ color: Color) -> Color {
            switch self {
            case .none:
                return color
            case .protanopia:
                return applyProtanopiaFilter(color)
            case .deuteranopia:
                return applyDeuteranopiaFilter(color)
            case .tritanopia:
                return applyTritanopiaFilter(color)
            }
        }
    }

    // High contrast mode
    var highContrastMode: Bool = false {
        didSet {
            if highContrastMode {
                enemyOutlineWidth = 3.0
                allyOutlineWidth = 2.0
                uiContrast = 1.5
            }
        }
    }

    // Text scaling
    var textScale: Float = 1.0  // 0.5 - 2.0 range

    // Visual indicators for audio cues
    var visualAudioCues: Bool = false {
        didSet {
            if visualAudioCues {
                showFootstepIndicators = true
                showGunshotIndicators = true
            }
        }
    }
}
```

### Motor Accessibility

```swift
struct MotorAccessibility {
    // Aim assistance levels
    enum AimAssistLevel {
        case none
        case low        // 20% magnetic aim
        case medium     // 40% magnetic aim
        case high       // 60% magnetic aim

        var strength: Float {
            switch self {
            case .none: return 0.0
            case .low: return 0.2
            case .medium: return 0.4
            case .high: return 0.6
            }
        }
    }

    var aimAssist: AimAssistLevel = .none

    // Auto-reload when empty
    var autoReload: Bool = false

    // Tap to fire instead of hold
    var tapToFire: Bool = false

    // Reduce required movement
    var reducedMovement: Bool = false {
        didSet {
            if reducedMovement {
                // Scale down play space requirements
                minimumPlaySpace *= 0.7
            }
        }
    }

    // Button remapping
    var buttonMapping: [GameAction: InputMethod] = [:]
}
```

### Cognitive Accessibility

```swift
struct CognitiveAccessibility {
    // Simplified HUD
    var simplifiedHUD: Bool = false {
        didSet {
            if simplifiedHUD {
                showOnlyEssentialInfo = true
                reduceVisualClutter = true
            }
        }
    }

    // Extended tutorial
    var extendedTutorial: Bool = false

    // Slower game speed for training
    var trainingGameSpeed: Float = 1.0  // 0.5 - 1.0

    // Clear objective markers
    var objectiveMarkers: Bool = true

    // Waypoint navigation
    var showWaypoints: Bool = false
}
```

### Auditory Accessibility

```swift
struct AuditoryAccessibility {
    // Subtitles for all audio
    var subtitles: Bool = true

    // Visual indicators for spatial audio
    var visualAudioIndicators: Bool = false {
        didSet {
            if visualAudioIndicators {
                // Show direction arrows for sounds
                showFootstepDirections = true
                showGunshotDirections = true
                showVoiceDirections = true
            }
        }
    }

    // Mono audio option
    var monoAudio: Bool = false

    // Vibration feedback for audio cues
    var hapticAudioFeedback: Bool = false
}
```

---

## Tutorial and Onboarding

### Tutorial Flow

```swift
struct TutorialSystem {
    enum TutorialPhase {
        case welcome
        case basicMovement
        case weaponHandling
        case aiming
        case shooting
        case reloading
        case cover
        case teamwork
        case objectives
        case completion
    }

    @Published var currentPhase: TutorialPhase = .welcome
    @Published var progress: Float = 0.0

    func startTutorial() {
        currentPhase = .welcome
        showWelcomeMessage()
    }

    // Phase 1: Welcome & Setup
    func showWelcomeMessage() {
        displayMessage("""
        Welcome to Tactical Team Shooters!

        This tutorial will teach you the fundamentals of spatial tactical combat.

        Expected duration: 10-15 minutes
        """)

        // Room scan
        initiateRoomScan()
    }

    // Phase 2: Basic Movement
    func teachBasicMovement() {
        displayMessage("""
        BASIC MOVEMENT

        Move naturally within your play space to control your character.

        Task: Walk to the waypoint
        """)

        spawnWaypoint(at: playerPosition + SIMD3<Float>(2, 0, 0))

        // Wait for player to reach waypoint
        onWaypointReached {
            completePhase(.basicMovement)
            currentPhase = .weaponHandling
        }
    }

    // Phase 3: Weapon Handling
    func teachWeaponHandling() {
        displayMessage("""
        WEAPON HANDLING

        Use both hands to hold your weapon:
        - Dominant hand: Grip and trigger
        - Support hand: Stabilization

        Task: Pick up the weapon
        """)

        spawnWeapon(at: playerPosition + SIMD3<Float>(0, 0, 1))

        onWeaponPickedUp {
            completePhase(.weaponHandling)
            currentPhase = .aiming
        }
    }

    // Phase 4: Aiming
    func teachAiming() {
        displayMessage("""
        AIMING

        Point your weapon at the target.
        Use both hands for stability and precision.

        Task: Aim at the target
        """)

        spawnTargets(count: 1, static: true)

        onTargetAimed {
            completePhase(.aiming)
            currentPhase = .shooting
        }
    }

    // Phase 5: Shooting
    func teachShooting() {
        displayMessage("""
        SHOOTING

        Pinch your index finger and thumb on your dominant hand to fire.

        Task: Hit 3 targets
        """)

        spawnTargets(count: 3, static: true)

        var hitsRemaining = 3
        onTargetHit {
            hitsRemaining -= 1
            if hitsRemaining == 0 {
                completePhase(.shooting)
                currentPhase = .reloading
            }
        }
    }

    // Continue for all phases...
}
```

### Interactive Training Scenarios

```swift
struct TrainingScenario {
    let id: UUID
    let name: String
    let description: String
    let difficulty: Difficulty
    let objectives: [TrainingObjective]
    let timeLimit: TimeInterval?

    enum Difficulty {
        case beginner
        case intermediate
        case advanced
        case expert
    }

    struct TrainingObjective {
        let description: String
        let requirement: ObjectiveRequirement
        var isCompleted: Bool = false
    }

    enum ObjectiveRequirement {
        case hitTargets(count: Int, accuracy: Float)
        case completeTime(TimeInterval)
        case surviveWaves(count: Int)
        case maintainAccuracy(percentage: Float, shots: Int)
        case headshots(count: Int)
    }

    // Example: Aim Training
    static let aimTraining = TrainingScenario(
        id: UUID(),
        name: "Precision Aim Training",
        description: "Improve your accuracy with moving targets",
        difficulty: .intermediate,
        objectives: [
            TrainingObjective(
                description: "Hit 20 targets",
                requirement: .hitTargets(count: 20, accuracy: 0.6)
            ),
            TrainingObjective(
                description: "Complete within 60 seconds",
                requirement: .completeTime(60)
            )
        ],
        timeLimit: 60
    )

    // Example: Recoil Control
    static let recoilControl = TrainingScenario(
        id: UUID(),
        name: "Recoil Control Mastery",
        description: "Learn to control weapon recoil patterns",
        difficulty: .advanced,
        objectives: [
            TrainingObjective(
                description: "Maintain 70% accuracy over 100 shots",
                requirement: .maintainAccuracy(percentage: 0.7, shots: 100)
            )
        ],
        timeLimit: nil
    )
}
```

---

## Difficulty Balancing

### AI Difficulty Scaling

```swift
enum AIDifficulty {
    case recruit
    case regular
    case veteran
    case elite

    var reactionTime: TimeInterval {
        switch self {
        case .recruit: return 0.8     // 800ms
        case .regular: return 0.5     // 500ms
        case .veteran: return 0.3     // 300ms
        case .elite: return 0.15      // 150ms
        }
    }

    var accuracy: Float {
        switch self {
        case .recruit: return 0.3     // 30% base accuracy
        case .regular: return 0.5     // 50%
        case .veteran: return 0.7     // 70%
        case .elite: return 0.85      // 85%
        }
    }

    var tacticalAwareness: Float {
        switch self {
        case .recruit: return 0.3
        case .regular: return 0.6
        case .veteran: return 0.85
        case .elite: return 1.0
        }
    }

    var aimPrediction: Bool {
        switch self {
        case .recruit, .regular: return false
        case .veteran, .elite: return true
        }
    }
}
```

### Dynamic Difficulty Adjustment

```swift
class DynamicDifficultySystem {
    var playerSkillRating: Float = 0.5  // 0.0 - 1.0
    var consecutiveWins: Int = 0
    var consecutiveLosses: Int = 0

    func adjustDifficulty() {
        // Increase difficulty after wins
        if consecutiveWins >= 3 {
            playerSkillRating = min(1.0, playerSkillRating + 0.05)
            consecutiveWins = 0
        }

        // Decrease difficulty after losses
        if consecutiveLosses >= 3 {
            playerSkillRating = max(0.0, playerSkillRating - 0.05)
            consecutiveLosses = 0
        }

        // Apply difficulty modifiers
        applyDifficultyModifiers(playerSkillRating)
    }

    func applyDifficultyModifiers(_ skillRating: Float) {
        // Enemy count
        let baseEnemyCount = 5
        enemyCount = Int(Float(baseEnemyCount) * (0.8 + skillRating * 0.4))

        // Enemy difficulty
        if skillRating < 0.3 {
            enemyDifficulty = .recruit
        } else if skillRating < 0.6 {
            enemyDifficulty = .regular
        } else if skillRating < 0.85 {
            enemyDifficulty = .veteran
        } else {
            enemyDifficulty = .elite
        }

        // Time limits
        objectiveTimeLimit = TimeInterval(180.0 * (1.5 - skillRating * 0.5))

        // Resource availability
        ammoScarcity = skillRating  // Higher skill = less ammo
    }
}
```

### Competitive Balance

```swift
struct CompetitiveBalance {
    // Weapon balance matrix
    static let weaponBalance: [WeaponType: WeaponBalanceParams] = [
        .assaultRifle: WeaponBalanceParams(
            damage: 30,
            fireRate: 600,  // RPM
            recoil: 0.5,
            accuracy: 0.75,
            price: 2700
        ),
        .smg: WeaponBalanceParams(
            damage: 22,
            fireRate: 900,
            recoil: 0.6,
            accuracy: 0.65,
            price: 1500
        ),
        .sniper: WeaponBalanceParams(
            damage: 100,
            fireRate: 45,
            recoil: 0.9,
            accuracy: 0.95,
            price: 4750
        )
    ]

    struct WeaponBalanceParams {
        let damage: Int
        let fireRate: Int       // Rounds per minute
        let recoil: Float       // 0.0 - 1.0
        let accuracy: Float     // 0.0 - 1.0
        let price: Int          // In-game currency
    }

    // Map balance
    struct MapBalance {
        let attackerWinRate: Float  // Target: 0.48 - 0.52
        let averageRoundTime: TimeInterval
        let sniperEffectiveness: Float

        var isBalanced: Bool {
            attackerWinRate > 0.48 && attackerWinRate < 0.52
        }
    }

    // Meta tracking
    func trackWeaponUsage() -> [WeaponType: Float] {
        // Return usage percentages
        // Target: No weapon > 30% usage
        return weaponUsageStats
    }
}
```

---

## Summary

This design document establishes:

1. **Comprehensive game design** with clear mechanics and progression
2. **Spatial-first UI/UX** optimized for Vision Pro
3. **Professional visual style** appropriate for tactical gaming
4. **Rich spatial audio** for tactical advantage and immersion
5. **Full accessibility** ensuring inclusive gameplay
6. **Structured tutorials** for smooth onboarding
7. **Balanced difficulty** for fair and engaging competition

The design prioritizes spatial gameplay innovation while maintaining competitive integrity and professional tactical authenticity.
