# Virtual Pet Ecosystem - Design Document

## Document Overview
This design document covers game design, UI/UX specifications, visual style, audio design, and accessibility for the Virtual Pet Ecosystem visionOS application.

---

## 1. Game Design Document (GDD) Elements

### 1.1 Core Pillars
1. **Emotional Connection**: Foster genuine bonds through persistent, intelligent companions
2. **Spatial Living**: Pets exist as permanent residents in physical space
3. **Personality Evolution**: Each pet develops unique characteristics
4. **Family-Friendly**: Safe, wholesome content for all ages

### 1.2 Design Philosophy
```
"Not just pets. Family members that happen to be magical."
```

- **True Persistence**: Pets continue living even when app is closed
- **Environmental Intelligence**: Pets learn and adapt to home layout
- **Meaningful Interactions**: Every touch, voice, and gaze matters
- **Emergent Stories**: Player-created moments and memories

---

## 2. Core Gameplay Loop

### 2.1 Primary Loop (Daily Cycle)
```
┌─────────────────────────────────────────────────┐
│                                                 │
│  Wake Up → Check on Pets → Care Activities →   │
│  Observe Behaviors → Play/Interact →           │
│  Discover New Traits → Build Bonds →           │
│  Put Pets to Sleep → Background Simulation     │
│                                                 │
└─────────────────────────────────────────────────┘
```

### 2.2 Secondary Loops

#### Discovery Loop
```
Observe pet → Notice new behavior →
Understand preferences → Adapt environment →
Pet evolves → New behaviors emerge
```

#### Mastery Loop
```
Basic care → Advanced nurturing →
Breeding attempts → Genetic understanding →
Rare traits → Collection completion
```

#### Social Loop
```
Raise pets → Share experiences →
Visit friends' pets → Breeding partnerships →
Community events → Competitions
```

---

## 3. Player Progression Systems

### 3.1 Pet Owner Levels
```swift
enum PetOwnerLevel {
    case beginner      // Level 1-5: Learning basics
    case caretaker     // Level 6-15: Competent care
    case breeder       // Level 16-30: Advanced genetics
    case master        // Level 31-50: Complete understanding
    case legend        // Level 51+: Community leader

    var perks: [Perk] {
        switch self {
        case .beginner:
            return [.onePetSlot, .basicFood, .simpleToys]
        case .caretaker:
            return [.threePetSlots, .premiumFood, .advancedToys, .nameRecognition]
        case .breeder:
            return [.fivePetSlots, .specialtyFood, .breedingUnlocked, .geneticTools]
        case .master:
            return [.unlimitedPets, .rarePetAccess, .geneticMastery, .communityLeader]
        case .legend:
            return [.legendaryPets, .customBreeding, .mentorStatus, .exclusiveEvents]
        }
    }
}
```

### 3.2 Experience Gain
```swift
enum ExperienceSource {
    case feeding(points: Int = 5)
    case playing(points: Int = 10)
    case petting(points: Int = 3)
    case training(points: Int = 15)
    case breeding(points: Int = 50)
    case discovery(points: Int = 25)
    case socializing(points: Int = 20)
    case lifeStageTransition(points: Int = 100)

    var points: Int {
        switch self {
        case .feeding(let p): return p
        case .playing(let p): return p
        case .petting(let p): return p
        case .training(let p): return p
        case .breeding(let p): return p
        case .discovery(let p): return p
        case .socializing(let p): return p
        case .lifeStageTransition(let p): return p
        }
    }
}
```

### 3.3 Achievement System
```swift
struct Achievement {
    let id: String
    let name: String
    let description: String
    let icon: String
    let tier: AchievementTier
    let rewards: [Reward]
}

enum AchievementTier {
    case bronze
    case silver
    case gold
    case platinum
    case legendary
}

// Example achievements
let achievements = [
    Achievement(
        id: "first_pet",
        name: "New Companion",
        description: "Adopt your first pet",
        icon: "🐾",
        tier: .bronze,
        rewards: [.experience(50), .currency(100)]
    ),
    Achievement(
        id: "perfect_care",
        name: "Perfect Caretaker",
        description: "Keep a pet at 100% happiness for 7 consecutive days",
        icon: "⭐",
        tier: .gold,
        rewards: [.experience(500), .premiumFood(10), .title("Perfect Caretaker")]
    ),
    Achievement(
        id: "legendary_breeder",
        name: "Legendary Breeder",
        description: "Breed a pet with 5 rare traits",
        icon: "👑",
        tier: .legendary,
        rewards: [.experience(2000), .legendaryPet, .title("Legendary Breeder")]
    )
]
```

---

## 4. Level Design Principles

### 4.1 Spatial Zones in Home

#### Living Room Zone
- **Purpose**: Primary social and play area
- **Pet Behaviors**: Active play, social interaction, visibility seeking
- **Furniture Interactions**: Couches (sleeping), coffee tables (perching), windows (sunbathing)
- **Optimal For**: Luminos, Fluffkins

#### Bedroom Zone
- **Purpose**: Rest and intimate bonding
- **Pet Behaviors**: Sleeping, quiet companionship, trust building
- **Furniture Interactions**: Beds (co-sleeping), nightstands (sitting), closets (hiding)
- **Optimal For**: Shadowlings, Fluffkins

#### Kitchen Zone (Restricted)
- **Purpose**: Feeding area only
- **Pet Behaviors**: Eating, anticipation, food requests
- **Safety**: Restricted movement near hazards
- **Optimal For**: All species during meal times

#### Outdoor/Balcony Zone (Optional)
- **Purpose**: Exploration and environmental stimulation
- **Pet Behaviors**: Sun exposure, weather response, territorial marking
- **Furniture Interactions**: Planters (hiding), railings (perching)
- **Optimal For**: Luminos, Aquarians

### 4.2 Environmental Storytelling
```
Pet Traces:
├── Sleeping spots (indented cushions)
├── Favorite toys left around
├── Footprints in sunny spots
├── Territory markers (visual effects)
└── Interaction memories (ghosted animations)
```

---

## 5. Spatial Gameplay Design for Vision Pro

### 5.1 Depth Layering
```
Layer 1 (0.3m - 1m): Direct Interaction
├── Pet petting
├── Feeding tools
├── Toy interaction
└── Status inspection

Layer 2 (1m - 3m): Observation & Play
├── Pet free roam
├── Play activities
├── Social dynamics
└── Personality expression

Layer 3 (3m+): Environment & Territory
├── Room navigation
├── Favorite spots
├── Environmental learning
└── Background simulation
```

### 5.2 Interaction Comfort Zones
```swift
struct InteractionZone {
    let name: String
    let distance: ClosedRange<Float>
    let actions: [InteractionType]
    let comfortLevel: ComfortLevel
}

let zones = [
    InteractionZone(
        name: "Intimate Zone",
        distance: 0.3...0.7,
        actions: [.petting, .feeding, .detailed_inspection],
        comfortLevel: .high
    ),
    InteractionZone(
        name: "Personal Zone",
        distance: 0.7...1.5,
        actions: [.playing, .calling, .training],
        comfortLevel: .high
    ),
    InteractionZone(
        name: "Social Zone",
        distance: 1.5...3.0,
        actions: [.observing, .commanding, .monitoring],
        comfortLevel: .medium
    ),
    InteractionZone(
        name: "Public Zone",
        distance: 3.0...10.0,
        actions: [.environmental_behavior, .autonomous_actions],
        comfortLevel: .low
    )
]
```

### 5.3 Hand Interaction Choreography
```
Petting Sequence:
1. Pet notices approaching hand (2m distance)
2. Pet shows interest (looks at hand, tail wag)
3. Hand enters personal space (1m)
4. Pet prepares for contact (slight crouch, purr start)
5. Contact begins (0.3m)
6. Petting interaction (smooth stroking)
7. Pet responds (lean in, close eyes, happy sounds)
8. Hand withdraws
9. Pet shows satisfaction (stretch, happy animation)
```

---

## 6. UI/UX for Gaming

### 6.1 HUD Design in Spatial Context

#### Minimal HUD Philosophy
```
"The pet IS the interface. Minimize UI chrome."
```

#### Pet Status Indicators
```swift
struct PetStatusHUD {
    // Appears only on gaze or explicit request
    let healthBar: ProgressBar           // Green gradient
    let happinessIndicator: EmoticonRing // Floating emojis
    let hungerIcon: FoodIcon             // Shrinks when full
    let energyRing: CircularProgress     // Yellow ring

    var displayMode: DisplayMode = .minimal

    enum DisplayMode {
        case hidden        // No UI
        case minimal       // Tiny icons near pet
        case detailed      // Full stats on request
        case always        // For accessibility
    }
}
```

#### Visual Design
```
┌─────────────────────────────────────┐
│                                     │
│       🐾 Fluffy                     │
│       ❤️ 95%  😊 Happy              │
│       🍖 75%  ⚡ 60%                │
│                                     │
│  Appears on gaze (0.5s delay)      │
│  Fades out after 3s                 │
│  Glass morphism effect              │
│                                     │
└─────────────────────────────────────┘
```

### 6.2 Menu Systems

#### Main Menu (Window Mode)
```swift
struct MainMenu: View {
    var body: some View {
        ZStack {
            // Background: Soft gradient with pet silhouettes
            BackgroundView()

            VStack(spacing: 30) {
                // Title
                Text("Virtual Pet Ecosystem")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundStyle(.linearGradient(...))

                // Menu buttons
                VStack(spacing: 20) {
                    MenuButton(title: "My Pets", icon: "🐾") {
                        navigate(to: .petList)
                    }

                    MenuButton(title: "Adopt New Pet", icon: "➕") {
                        navigate(to: .petSelection)
                    }

                    MenuButton(title: "Community", icon: "👥") {
                        navigate(to: .social)
                    }

                    MenuButton(title: "Settings", icon: "⚙️") {
                        navigate(to: .settings)
                    }
                }
            }
        }
        .glassBackgroundEffect()
    }
}
```

#### In-Game Quick Menu (Hand-Attached)
```swift
struct QuickMenu: View {
    @State private var isExpanded = false

    var body: some View {
        HStack(spacing: 15) {
            // Quick actions
            QuickButton(icon: "🍖") {
                FeedingSystem.shared.openFeedingMenu()
            }

            QuickButton(icon: "🎾") {
                PlaySystem.shared.openToySelection()
            }

            QuickButton(icon: "📊") {
                PetStats.shared.showDetails()
            }

            QuickButton(icon: "⏸️") {
                GameState.shared.pause()
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .attachedToHand(.dominant)
        .hiddenOnPinch()
    }
}
```

### 6.3 Pet Selection Interface

#### Species Gallery
```swift
struct PetSelectionView: View {
    @State private var selectedSpecies: PetSpecies?
    @State private var petName: String = ""

    var body: some View {
        VStack {
            Text("Choose Your Companion")
                .font(.largeTitle)
                .padding(.bottom, 40)

            // 3D carousel of pet species
            PetCarousel(selectedSpecies: $selectedSpecies) {
                ForEach(PetSpecies.allCases, id: \.self) { species in
                    Pet3DPreview(species: species)
                        .rotation3DEffect(
                            .degrees(selectedSpecies == species ? 0 : 30),
                            axis: (x: 0, y: 1, z: 0)
                        )
                        .scaleEffect(selectedSpecies == species ? 1.2 : 0.8)
                        .animation(.spring(), value: selectedSpecies)
                }
            }

            // Species info
            if let species = selectedSpecies {
                SpeciesInfoCard(species: species)
                    .transition(.scale.combined(with: .opacity))
            }

            // Name input
            TextField("Name your pet", text: $petName)
                .textFieldStyle(.roundedBorder)
                .frame(width: 300)
                .padding()

            // Adopt button
            Button(action: adoptPet) {
                Text("Adopt \(selectedSpecies?.rawValue ?? "Pet")")
                    .font(.headline)
                    .padding()
                    .frame(width: 250)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(15)
            }
            .disabled(selectedSpecies == nil || petName.isEmpty)
        }
        .padding()
    }
}
```

### 6.4 Feeding Interface
```swift
struct FeedingInterface: View {
    @State private var selectedFood: FoodType?

    var body: some View {
        VStack {
            Text("Feed Your Pet")
                .font(.title)

            // Food selection grid
            LazyVGrid(columns: [GridItem(), GridItem(), GridItem()]) {
                ForEach(FoodType.allCases, id: \.self) { food in
                    FoodCard(food: food, isSelected: selectedFood == food)
                        .onTapGesture {
                            selectedFood = food
                        }
                }
            }
            .padding()

            // Selected food info
            if let food = selectedFood {
                FoodInfoPanel(food: food)
            }

            // Feed button
            Button("Feed") {
                if let food = selectedFood {
                    feedPet(with: food)
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(width: 400, height: 600)
        .glassBackgroundEffect()
    }
}

struct FoodCard: View {
    let food: FoodType
    let isSelected: Bool

    var body: some View {
        VStack {
            Text(food.emoji)
                .font(.system(size: 60))

            Text(food.rawValue)
                .font(.caption)
        }
        .frame(width: 100, height: 100)
        .background(isSelected ? Color.blue.opacity(0.3) : Color.clear)
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(isSelected ? Color.blue : Color.gray, lineWidth: 2)
        )
    }
}
```

### 6.5 Breeding Interface
```swift
struct BreedingInterface: View {
    @State private var parentA: Pet?
    @State private var parentB: Pet?
    @State private var predictedOffspring: GeneticPrediction?

    var body: some View {
        HStack(spacing: 50) {
            // Parent A selection
            VStack {
                Text("Parent A")
                    .font(.headline)

                if let pet = parentA {
                    PetPreview3D(pet: pet)
                    TraitsList(pet: pet)
                } else {
                    PetSelectorButton {
                        parentA = selectPet()
                    }
                }
            }

            // Breeding preview
            VStack {
                Text("❤️")
                    .font(.system(size: 80))

                if let prediction = predictedOffspring {
                    OffspringPreview(prediction: prediction)

                    Text("Possible Traits:")
                        .font(.headline)

                    ForEach(prediction.possibleTraits, id: \.self) { trait in
                        HStack {
                            Text(trait.name)
                            Spacer()
                            Text("\(Int(trait.probability * 100))%")
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Button("Breed") {
                    performBreeding(parentA, parentB)
                }
                .disabled(parentA == nil || parentB == nil)
                .buttonStyle(.borderedProminent)
            }

            // Parent B selection
            VStack {
                Text("Parent B")
                    .font(.headline)

                if let pet = parentB {
                    PetPreview3D(pet: pet)
                    TraitsList(pet: pet)
                } else {
                    PetSelectorButton {
                        parentB = selectPet()
                    }
                }
            }
        }
        .padding()
        .onChange(of: parentA) { _ in updatePrediction() }
        .onChange(of: parentB) { _ in updatePrediction() }
    }

    private func updatePrediction() {
        if let a = parentA, let b = parentB {
            predictedOffspring = GeneticSystem.predict(parents: (a, b))
        }
    }
}
```

---

## 7. Visual Style Guide

### 7.1 Art Direction
**Theme**: Magical Realism
- Realistic pet behaviors with subtle magical elements
- Soft, warm color palette
- Clean, minimalist UI
- Glass morphism for menus
- Particle effects for emotions

### 7.2 Pet Design Specifications

#### Luminos (Light Creatures)
```
Visual Characteristics:
- Bioluminescent body with soft glow
- Semi-transparent edges
- Particle trail when moving
- Warm color palette (yellow, orange, white)
- Smooth, rounded shapes

Animations:
- Gentle floating/hovering
- Pulse breathing effect
- Brightness responds to happiness
- Shimmer when excited

Size: Small to medium (0.2m - 0.4m)
```

#### Fluffkins (Furry Companions)
```
Visual Characteristics:
- Dense, realistic fur simulation
- Expressive eyes
- Rounded body shape
- Earth tones (brown, beige, cream)
- Subtle subsurface scattering

Animations:
- Realistic quadruped movement
- Fur ripples in motion
- Ear and tail expressions
- Grooming behaviors

Size: Medium (0.3m - 0.5m)
```

#### Crystalites (Geometric Beings)
```
Visual Characteristics:
- Crystalline, faceted surfaces
- Reflective materials
- Cool color palette (cyan, purple, blue)
- Sharp, angular geometry
- Refractive light effects

Animations:
- Precise, mechanical movements
- Rotation and alignment behaviors
- Geometric transformations
- Crystallization effects

Size: Small to medium (0.15m - 0.35m)
```

#### Aquarians (Float Like Swimming)
```
Visual Characteristics:
- Translucent, flowing form
- Water-like material
- Blue-green gradient
- Trailing particle effects
- Undulating surfaces

Animations:
- Swimming motions through air
- Graceful, flowing movements
- Ripple effects
- Liquid transformations

Size: Medium (0.25m - 0.45m)
```

#### Shadowlings (Shy Creatures)
```
Visual Characteristics:
- Semi-transparent dark material
- Soft purple glow
- Wispy, ethereal edges
- Dark color palette (black, deep purple)
- Fade in/out effects

Animations:
- Shy, cautious movements
- Quick hiding behaviors
- Fade to shadows
- Peeking animations

Size: Small (0.15m - 0.25m)
```

### 7.3 UI Color System
```swift
struct ColorScheme {
    // Primary colors
    static let primary = Color(#colorLiteral(red: 0.3, green: 0.6, blue: 1.0, alpha: 1.0))
    static let secondary = Color(#colorLiteral(red: 0.9, green: 0.7, blue: 0.4, alpha: 1.0))

    // Status colors
    static let health = Color.green
    static let happiness = Color.yellow
    static let hunger = Color.orange
    static let energy = Color.cyan

    // Emotion colors
    static let joy = Color(#colorLiteral(red: 1.0, green: 0.8, blue: 0.2, alpha: 1.0))
    static let sadness = Color(#colorLiteral(red: 0.4, green: 0.6, blue: 0.9, alpha: 1.0))
    static let excitement = Color(#colorLiteral(red: 1.0, green: 0.4, blue: 0.6, alpha: 1.0))
    static let calm = Color(#colorLiteral(red: 0.6, green: 0.9, blue: 0.7, alpha: 1.0))

    // UI backgrounds
    static let glass = Material.ultraThinMaterial
    static let menuBackground = Material.regularMaterial
}
```

### 7.4 Typography
```swift
struct Typography {
    static let title = Font.system(size: 48, weight: .bold, design: .rounded)
    static let headline = Font.system(size: 32, weight: .semibold, design: .rounded)
    static let body = Font.system(size: 20, weight: .regular, design: .default)
    static let caption = Font.system(size: 16, weight: .light, design: .default)
    static let petName = Font.system(size: 28, weight: .medium, design: .rounded)
}
```

---

## 8. Audio Design

### 8.1 Spatial Audio System

#### Pet Vocalizations
```
Luminos:
├── Happy: Soft chimes, bell-like tones
├── Hungry: Faint ringing, attention-seeking
├── Playful: Quick ascending notes
├── Sleepy: Slow, descending harmonics
└── Greeting: Bright, welcoming tones

Fluffkins:
├── Happy: Soft purring, gentle rumbles
├── Hungry: Light whining, vocal requests
├── Playful: Excited yips, bouncy sounds
├── Sleepy: Deep sighs, settling sounds
└── Greeting: Cheerful chirps

Crystalites:
├── Happy: Harmonic resonance
├── Hungry: Crystalline tapping
├── Playful: Sharp, bright notes
├── Sleepy: Low frequency hum
└── Greeting: Musical chime sequence

Aquarians:
├── Happy: Bubbling, flowing water
├── Hungry: Gentle splashing
├── Playful: Quick water droplets
├── Sleepy: Calm waves
└── Greeting: Rippling sounds

Shadowlings:
├── Happy: Soft whispers, ethereal
├── Hungry: Quiet rustling
├── Playful: Mysterious giggles
├── Sleepy: Fading echoes
└── Greeting: Gentle whispers
```

#### Environmental Sounds
```swift
enum EnvironmentSound {
    case footsteps(surface: SurfaceType)
    case eating(foodType: FoodType)
    case toyInteraction(toy: ToyType)
    case sleeping(breathingPattern: BreathingPattern)
    case movement(speed: Float)

    var audioFile: String {
        switch self {
        case .footsteps(.carpet):
            return "soft_patter.wav"
        case .footsteps(.wood):
            return "click_patter.wav"
        case .eating(.treat):
            return "happy_munching.wav"
        // ... more cases
        }
    }

    var volume: Float {
        switch self {
        case .footsteps: return 0.3
        case .eating: return 0.5
        case .sleeping: return 0.1
        default: return 0.4
        }
    }
}
```

### 8.2 Music System
```swift
class MusicManager {
    enum MusicTrack {
        case mainMenu
        case peaceful        // Low activity
        case playful         // High activity
        case bonding         // Petting/affection
        case nighttime       // Pets sleeping
        case breeding        // Breeding interface
        case community       // Social features
    }

    private var currentTrack: MusicTrack = .peaceful
    private var audioPlayer: AVAudioPlayer?

    func playAdaptiveMusic() {
        // Analyze current game state
        let petActivity = analyzePetActivity()
        let timeOfDay = getCurrentTimeOfDay()

        let newTrack: MusicTrack

        if timeOfDay == .night {
            newTrack = .nighttime
        } else if petActivity > 0.7 {
            newTrack = .playful
        } else if petActivity < 0.3 {
            newTrack = .peaceful
        } else {
            newTrack = .bonding
        }

        if newTrack != currentTrack {
            crossfade(to: newTrack, duration: 2.0)
        }
    }

    private func crossfade(to newTrack: MusicTrack, duration: TimeInterval) {
        // Smooth transition between tracks
        // ...
    }
}
```

### 8.3 UI Sound Effects
```swift
enum UISoundEffect {
    case buttonTap
    case menuOpen
    case menuClose
    case itemSelect
    case achievementUnlock
    case levelUp
    case notification
    case error
    case success

    var audioFile: String {
        switch self {
        case .buttonTap: return "ui_tap.wav"
        case .menuOpen: return "ui_whoosh_in.wav"
        case .achievementUnlock: return "achievement_fanfare.wav"
        // ... more cases
        }
    }
}
```

---

## 9. Accessibility for Gaming

### 9.1 Visual Accessibility

#### High Contrast Mode
```swift
class AccessibilityManager {
    static var isHighContrastEnabled: Bool {
        UIAccessibility.isDarkerSystemColorsEnabled
    }

    func applyHighContrast() {
        if Self.isHighContrastEnabled {
            // Increase UI contrast
            ColorScheme.primary = Color.blue.opacity(1.0)
            ColorScheme.secondary = Color.yellow.opacity(1.0)

            // Add borders to UI elements
            UIElementStyle.borderWidth = 3.0

            // Increase pet visibility
            PetMaterialBuilder.increaseContrast(by: 0.5)
        }
    }
}
```

#### Color Blind Modes
```swift
enum ColorBlindMode {
    case none
    case protanopia    // Red-blind
    case deuteranopia  // Green-blind
    case tritanopia    // Blue-blind

    func adjustColors(_ color: Color) -> Color {
        switch self {
        case .none:
            return color
        case .protanopia:
            return adjustForProtanopia(color)
        case .deuteranopia:
            return adjustForDeuteranopia(color)
        case .tritanopia:
            return adjustForTritanopia(color)
        }
    }
}
```

### 9.2 Motor Accessibility

#### Dwell Control
```swift
class DwellControlSystem {
    var dwellTime: TimeInterval = 2.0
    var isEnabled: Bool = false

    private var currentTarget: Entity?
    private var dwellStartTime: Date?

    func update() {
        guard isEnabled else { return }

        if let target = detectGazeTarget() {
            if target == currentTarget {
                let elapsed = Date().timeIntervalSince(dwellStartTime ?? Date())

                if elapsed >= dwellTime {
                    activateTarget(target)
                    dwellStartTime = nil
                    currentTarget = nil
                }
            } else {
                currentTarget = target
                dwellStartTime = Date()
                showDwellProgress(for: target)
            }
        } else {
            currentTarget = nil
            dwellStartTime = nil
        }
    }
}
```

#### Switch Control
```swift
class SwitchControlAdapter {
    func enableSwitchControl() {
        // Single switch: scanning mode
        // Two switches: selection and activation
        // Custom switch configurations

        UIAccessibility.post(
            notification: .announcement,
            argument: "Switch control enabled. Press switch to scan through options."
        )
    }
}
```

### 9.3 Cognitive Accessibility

#### Simplified Mode
```swift
class SimplifiedMode {
    static var isEnabled: Bool = false

    func applySimplifications() {
        if Self.isEnabled {
            // Reduce complexity
            PetManager.shared.maxPets = 1
            BreedingSystem.shared.disable()

            // Simplify care
            PetCareSystem.shared.autoFeed = true
            PetCareSystem.shared.simplifiedNeeds = true

            // Clear UI
            HUDManager.shared.alwaysShowStatus = true
            HUDManager.shared.largeIcons = true

            // Guided tutorials
            TutorialManager.shared.enablePersistentGuides()
        }
    }
}
```

---

## 10. Tutorial and Onboarding Design

### 10.1 First Time User Experience (FTUE)

#### Step 1: Welcome (30 seconds)
```
┌────────────────────────────────────────┐
│ Welcome to Virtual Pet Ecosystem!      │
│                                        │
│ Your journey to magical companionship │
│ starts here.                           │
│                                        │
│ [Continue]                             │
└────────────────────────────────────────┘
```

#### Step 2: Space Setup (60 seconds)
```
Guide user to:
1. Look around the room
2. Identify suitable pet areas
3. Map furniture (automatic via ARKit)
4. Confirm home setup complete
```

#### Step 3: Pet Selection (90 seconds)
```
Interactive tutorial:
1. See all 5 species
2. Learn about each species
3. Choose first pet
4. Name your pet
5. Watch adoption animation
```

#### Step 4: First Interaction (120 seconds)
```
Guided interactions:
1. "Look at your pet to see its status"
2. "Reach out and pet your companion"
3. "Let's feed your pet" (feeding tutorial)
4. "Time to play!" (play tutorial)
5. "Great job! Your pet is happy!"
```

#### Step 5: Independence (Ongoing)
```
Gradual release:
1. Let pet explore on its own
2. Observe natural behaviors
3. Occasional tips appear
4. Achievement unlocks guide progression
```

### 10.2 Progressive Tutorials
```swift
struct TutorialSystem {
    enum Tutorial: String {
        case firstPet = "Adopt your first pet"
        case feeding = "Learn to feed pets"
        case playing = "Play with your pet"
        case affection = "Build bonds through petting"
        case breeding = "Breed your first pet"
        case social = "Visit a friend's pet"
        case genetics = "Understanding genetics"
    }

    func showTutorial(_ tutorial: Tutorial) {
        // Show context-sensitive tutorial
        // Non-intrusive, can be dismissed
        // Stored in user progress
    }
}
```

---

## 11. Difficulty Balancing

### 11.1 Pet Care Difficulty

#### Easy Mode (Default for new users)
```swift
struct EasyDifficulty {
    static let hungerDecayRate: Float = 0.05 // per hour
    static let happinessDecayRate: Float = 0.03
    static let energyRecoveryRate: Float = 0.15
    static let healthRobustness: Float = 0.9
    static let careReminders: Bool = true
    static let autoPause: Bool = true // When absent
}
```

#### Normal Mode
```swift
struct NormalDifficulty {
    static let hungerDecayRate: Float = 0.1
    static let happinessDecayRate: Float = 0.06
    static let energyRecoveryRate: Float = 0.1
    static let healthRobustness: Float = 0.7
    static let careReminders: Bool = true
    static let autoPause: Bool = false
}
```

#### Challenging Mode (For experts)
```swift
struct ChallengingDifficulty {
    static let hungerDecayRate: Float = 0.2
    static let happinessDecayRate: Float = 0.12
    static let energyRecoveryRate: Float = 0.05
    static let healthRobustness: Float = 0.5
    static let careReminders: Bool = false
    static let autoPause: Bool = false
    static let weatherAffectsHealth: Bool = true
    static let socialDynamicsStrong: Bool = true
}
```

### 11.2 Dynamic Difficulty Adjustment
```swift
class DifficultyManager {
    func adjustDifficulty(based on playerPerformance: PlayerPerformance) {
        if playerPerformance.petNegligenceCount > 3 {
            // Player struggling, make easier
            increaseCareSuggestions()
            slowDecayRates(by: 0.2)
        } else if playerPerformance.perfectCareStreak > 7 {
            // Player mastering, can increase challenge
            unlockAdvancedFeatures()
            offerDifficultyIncrease()
        }
    }
}
```

---

## 12. Monetization UX Design

### 12.1 Non-Intrusive Premium Offers
```swift
struct PremiumOffer {
    let context: OfferContext
    let timing: OfferTiming

    enum OfferContext {
        case petSlotFull        // When trying to adopt 2nd pet
        case rareSpeciesFound   // After discovering rare species
        case breedingUnlock     // At adult life stage
        case socialFeature      // When friend invites
    }

    enum OfferTiming {
        case immediate
        case after(TimeInterval)
        case onlyOnce
        case recurring(frequency: TimeInterval)
    }
}
```

### 12.2 Pet Shop UI
```swift
struct PetShopView: View {
    @State private var selectedCategory: ShopCategory = .species

    enum ShopCategory {
        case species
        case accessories
        case habitats
        case food
        case magical
    }

    var body: some View {
        VStack {
            // Category tabs
            CategoryPicker(selection: $selectedCategory)

            // Items grid
            LazyVGrid(columns: [GridItem(), GridItem(), GridItem()]) {
                ForEach(getItems(for: selectedCategory)) { item in
                    ShopItemCard(item: item)
                }
            }

            // Premium subscription banner (non-intrusive)
            if !isPremiumSubscriber {
                PremiumBanner()
                    .transition(.slide)
            }
        }
    }
}

struct ShopItemCard: View {
    let item: ShopItem

    var body: some View {
        VStack {
            // 3D preview
            Model3D(named: item.modelName)
                .frame(width: 150, height: 150)

            Text(item.name)
                .font(.headline)

            HStack {
                Image(systemName: "dollarsign.circle.fill")
                Text("\(item.price, specifier: "%.2f")")
            }
            .foregroundColor(.secondary)

            Button("Purchase") {
                purchase(item)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
    }
}
```

---

## Summary

This design document provides:
- ✅ Complete game design with core loops
- ✅ Player progression and achievement systems
- ✅ Spatial gameplay design for Vision Pro
- ✅ Comprehensive UI/UX specifications
- ✅ Visual style guide for all pet species
- ✅ Detailed audio design with spatial audio
- ✅ Accessibility features for all users
- ✅ Onboarding and tutorial flow
- ✅ Difficulty balancing system
- ✅ Monetization UX that's player-friendly

Ready for implementation following these design specifications.
