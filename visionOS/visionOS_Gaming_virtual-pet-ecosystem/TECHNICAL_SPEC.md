# Virtual Pet Ecosystem - Technical Specifications

## Document Overview
This document provides detailed technical specifications for implementing the Virtual Pet Ecosystem visionOS gaming application, including technology stack, implementation details, and performance requirements.

---

## 1. Technology Stack

### 1.1 Core Technologies

#### Swift 6.0+ (Primary Language)
```swift
// Swift 6.0 features used:
// - Strict concurrency checking
// - Typed throws
// - Noncopyable types for performance
// - Embedded Swift for RealityKit components

actor PetManager {
    private var pets: [UUID: Pet] = [:]

    func addPet(_ pet: Pet) async {
        pets[pet.id] = pet
    }

    func getPet(_ id: UUID) async -> Pet? {
        return pets[id]
    }
}
```

#### SwiftUI for UI/Menus
```swift
struct MainMenuView: View {
    @StateObject private var gameState = GameState()

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Virtual Pet Ecosystem")
                    .font(.extraLargeTitle)

                Button("My Pets") {
                    gameState.navigate(to: .petList)
                }

                Button("Adopt New Pet") {
                    gameState.navigate(to: .petSelection)
                }

                Button("Settings") {
                    gameState.navigate(to: .settings)
                }
            }
            .padding()
            .glassBackgroundEffect()
        }
    }
}
```

#### RealityKit for 3D Gameplay
```swift
import RealityKit

class PetRealityView: View {
    var body: some View {
        RealityView { content in
            // Create pet scene
            let petScene = try! await PetSceneBuilder.buildScene()
            content.add(petScene)
        } update: { content in
            // Update pet positions and animations
        }
    }
}
```

#### ARKit for Spatial Tracking
```swift
import ARKit

class ARSessionManager {
    let session = ARKitSession()
    let worldTracking = WorldTrackingProvider()
    let sceneReconstruction = SceneReconstructionProvider()
    let handTracking = HandTrackingProvider()

    func start() async {
        do {
            try await session.run([
                worldTracking,
                sceneReconstruction,
                handTracking
            ])
        } catch {
            print("AR Session failed: \(error)")
        }
    }
}
```

#### visionOS 2.0+ Gaming APIs
- RealityKit 4.0 for advanced rendering
- Spatial Audio with AVFoundation
- GroupActivities for SharePlay
- WorldTracking for persistent anchors
- SceneReconstruction for room understanding

### 1.2 Optional Technologies

#### GameplayKit (Conditional)
```swift
import GameplayKit

// Use for advanced pathfinding
class PetPathfinder {
    private let graph: GKGraph

    func findPath(from start: SIMD3<Float>, to end: SIMD3<Float>) -> [SIMD3<Float>] {
        let startNode = GKGraphNode3D(point: vector_float3(start))
        let endNode = GKGraphNode3D(point: vector_float3(end))

        graph.connectUsingObstacles(node: startNode)
        graph.connectUsingObstacles(node: endNode)

        guard let path = graph.findPath(from: startNode, to: endNode) as? [GKGraphNode3D] else {
            return []
        }

        return path.map { SIMD3<Float>($0.position) }
    }
}
```

#### Core ML for Advanced AI
```swift
import CoreML

class PetBehaviorPredictor {
    private var model: MLModel?

    init() {
        // Load trained behavior model
        model = try? PetBehaviorModel(configuration: .init()).model
    }

    func predictBehavior(for pet: Pet) -> BehaviorState {
        guard let model = model else { return .idle }

        let input = createInput(from: pet)
        let output = try? model.prediction(from: input)

        return BehaviorState(from: output)
    }
}
```

---

## 2. Game Mechanics Implementation

### 2.1 Pet Care System

#### Feeding Mechanics
```swift
enum FoodType: String, Codable {
    case regularFood = "Regular Food"
    case premiumFood = "Premium Food"
    case treat = "Treat"
    case specialtyFood = "Specialty Food"

    var nutritionValue: Float {
        switch self {
        case .regularFood: return 0.3
        case .premiumFood: return 0.5
        case .treat: return 0.1
        case .specialtyFood: return 0.7
        }
    }

    var happinessBonus: Float {
        switch self {
        case .regularFood: return 0.1
        case .premiumFood: return 0.2
        case .treat: return 0.4
        case .specialtyFood: return 0.3
        }
    }
}

class FeedingSystem {
    func feed(_ pet: inout Pet, food: FoodType) {
        // Update hunger
        pet.hunger = min(1.0, pet.hunger + food.nutritionValue)

        // Update happiness
        pet.happiness = min(1.0, pet.happiness + food.happinessBonus)

        // Evolve personality based on food preferences
        if food == .treat {
            pet.personality.playfulness += 0.001
        }

        // Trigger animation
        AnimationController.shared.playAnimation(.eating, for: pet)

        // Play sound
        AudioManager.shared.playSound(.eating, at: pet.currentLocation)

        // Record interaction
        pet.memory.interactionHistory.append(
            InteractionEvent(type: .feeding, food: food, timestamp: Date())
        )
    }
}
```

#### Play Mechanics
```swift
enum PlayActivity: String, Codable {
    case fetch = "Fetch"
    case tugOfWar = "Tug of War"
    case hideAndSeek = "Hide and Seek"
    case training = "Training"

    var energyCost: Float {
        switch self {
        case .fetch: return 0.2
        case .tugOfWar: return 0.3
        case .hideAndSeek: return 0.1
        case .training: return 0.15
        }
    }

    var happinessGain: Float {
        switch self {
        case .fetch: return 0.3
        case .tugOfWar: return 0.25
        case .hideAndSeek: return 0.2
        case .training: return 0.15
        }
    }
}

class PlaySystem {
    func play(_ pet: inout Pet, activity: PlayActivity) async {
        guard pet.energy >= activity.energyCost else {
            // Pet too tired
            AnimationController.shared.playAnimation(.tooTired, for: pet)
            return
        }

        // Deduct energy
        pet.energy -= activity.energyCost

        // Add happiness
        pet.happiness = min(1.0, pet.happiness + activity.happinessGain)

        // Personality evolution
        pet.personality.playfulness += 0.002
        pet.personality.loyalty += 0.001

        // Execute activity
        await performActivity(activity, pet: &pet)

        // Record interaction
        pet.memory.interactionHistory.append(
            InteractionEvent(type: .playing, activity: activity, timestamp: Date())
        )
    }

    private func performActivity(_ activity: PlayActivity, pet: inout Pet) async {
        switch activity {
        case .fetch:
            await performFetch(pet: &pet)
        case .tugOfWar:
            await performTugOfWar(pet: &pet)
        case .hideAndSeek:
            await performHideAndSeek(pet: &pet)
        case .training:
            await performTraining(pet: &pet)
        }
    }

    private func performFetch(pet: inout Pet) async {
        // Throw toy
        let toy = VirtualToy.ball
        let throwTarget = generateRandomLocation()

        AnimationController.shared.playAnimation(.watchThrow, for: pet)

        // Pet chases toy
        await pet.moveTo(throwTarget)

        AnimationController.shared.playAnimation(.pickupToy, for: pet)

        // Pet returns
        await pet.returnToPlayer()

        AnimationController.shared.playAnimation(.dropToy, for: pet)
    }
}
```

#### Affection System
```swift
struct AffectionMetrics {
    var trust: Float = 0.5
    var bonding: Float = 0.5
    var loyalty: Float = 0.5

    var overallAffection: Float {
        return (trust + bonding + loyalty) / 3.0
    }
}

class AffectionSystem {
    func pet(_ pet: inout Pet, duration: TimeInterval, quality: Float) {
        // Calculate affection gain
        let baseGain = Float(duration) * 0.01
        let qualityMultiplier = quality // 0.0 - 1.0 based on gesture smoothness

        let affectionGain = baseGain * qualityMultiplier

        // Update metrics
        pet.affection.trust += affectionGain * 0.5
        pet.affection.bonding += affectionGain * 0.7
        pet.affection.loyalty += affectionGain * 0.3

        // Clamp values
        pet.affection.trust = min(1.0, pet.affection.trust)
        pet.affection.bonding = min(1.0, pet.affection.bonding)
        pet.affection.loyalty = min(1.0, pet.affection.loyalty)

        // Personality impact
        pet.personality.agreeableness += affectionGain * 0.001
        pet.personality.extraversion += affectionGain * 0.0005

        // Trigger purr/happy sounds
        if pet.affection.overallAffection > 0.7 {
            AudioManager.shared.playSound(.happyPurr, at: pet.currentLocation)
            VisualEffectsManager.shared.showHearts(around: pet)
        }

        // Animation
        AnimationController.shared.playAnimation(.enjoyPetting, for: pet)
    }
}
```

### 2.2 Life Cycle System

```swift
class LifeCycleManager {
    private let calendar = Calendar.current

    func updateLifeStage(for pet: inout Pet) {
        let age = Date().timeIntervalSince(pet.birthDate)
        let ageInDays = age / 86400.0

        let newStage: LifeStage

        switch ageInDays {
        case 0..<30:
            newStage = .baby
        case 30..<90:
            newStage = .youth
        case 90..<365:
            newStage = .adult
        default:
            newStage = .elder
        }

        if newStage != pet.lifeStage {
            pet.lifeStage = newStage
            onLifeStageTransition(pet: &pet, to: newStage)
        }
    }

    private func onLifeStageTransition(pet: inout Pet, to stage: LifeStage) {
        // Trigger evolution animation
        AnimationController.shared.playAnimation(.evolution, for: pet)

        // Update stats
        switch stage {
        case .baby:
            break
        case .youth:
            pet.personality.independence += 0.2
            NotificationManager.shared.show("Your pet \(pet.name) has grown to Youth!")
        case .adult:
            pet.personality.independence += 0.3
            // Unlock breeding
            pet.canBreed = true
            NotificationManager.shared.show("Your pet \(pet.name) is now an Adult!")
        case .elder:
            pet.personality.wisdom = 1.0
            NotificationManager.shared.show("Your pet \(pet.name) has become an Elder!")
        }

        // Update appearance
        updateModelForLifeStage(pet: &pet, stage: stage)
    }

    private func updateModelForLifeStage(pet: inout Pet, stage: LifeStage) {
        let modelName = "\(pet.species.rawValue)_\(stage.rawValue)"
        // Load new model
        Task {
            pet.modelEntity = try? await ModelEntity.loadModel(named: modelName)
        }
    }
}
```

---

## 3. Control Schemes

### 3.1 Gesture Recognition

#### Petting Gesture
```swift
class PettingGestureRecognizer {
    private var handAnchorSubscription: AnyCancellable?
    private var previousHandPosition: SIMD3<Float>?
    private var pettingStartTime: Date?
    private var strokeCount: Int = 0

    func startTracking() {
        handAnchorSubscription = HandTrackingProvider.shared.$dominantHand
            .sink { [weak self] hand in
                self?.processHand(hand)
            }
    }

    private func processHand(_ hand: HandAnchor?) {
        guard let hand = hand else {
            endPetting()
            return
        }

        let currentPosition = hand.palmPosition

        if let previous = previousHandPosition {
            let delta = distance(currentPosition, previous)

            // Detect stroking motion
            if delta > 0.01 && delta < 0.1 {
                if pettingStartTime == nil {
                    startPetting()
                }

                strokeCount += 1

                // Calculate petting quality
                let quality = calculatePettingQuality(
                    velocity: delta,
                    smoothness: calculateSmoothness()
                )

                PetInteractionManager.shared.pet(quality: quality)
            }
        }

        previousHandPosition = currentPosition
    }

    private func calculatePettingQuality(velocity: Float, smoothness: Float) -> Float {
        // Ideal velocity: 0.03 - 0.07 m/s
        let velocityScore: Float
        if velocity >= 0.03 && velocity <= 0.07 {
            velocityScore = 1.0
        } else {
            velocityScore = max(0, 1.0 - abs(velocity - 0.05) * 10)
        }

        return (velocityScore + smoothness) / 2.0
    }
}
```

#### Feeding Gesture
```swift
class FeedingGestureRecognizer {
    func detectFeedingGesture() async -> (detected: Bool, foodType: FoodType?) {
        guard let hand = await HandTrackingProvider.shared.dominantHand else {
            return (false, nil)
        }

        // Check for cupped hand posture
        let isCupped = checkCuppedHand(hand)

        guard isCupped else {
            return (false, nil)
        }

        // Check proximity to pet
        if let nearestPet = findNearestPet(to: hand.palmPosition),
           distance(hand.palmPosition, nearestPet.position) < 0.3 {
            return (true, .regularFood)
        }

        return (false, nil)
    }

    private func checkCuppedHand(_ hand: HandAnchor) -> Bool {
        // Get finger joints
        let thumbTip = hand.handSkeleton?.joint(.thumbTip)
        let indexTip = hand.handSkeleton?.joint(.indexFingerTip)
        let middleTip = hand.handSkeleton?.joint(.middleFingerTip)
        let ringTip = hand.handSkeleton?.joint(.ringFingerTip)
        let pinkyTip = hand.handSkeleton?.joint(.littleFingerTip)

        guard let thumb = thumbTip?.position,
              let index = indexTip?.position,
              let middle = middleTip?.position,
              let ring = ringTip?.position,
              let pinky = pinkyTip?.position else {
            return false
        }

        let palm = hand.palmPosition

        // All fingertips should be close to each other and above palm
        let fingersClose = distance(thumb, index) < 0.05 &&
                          distance(index, middle) < 0.05 &&
                          distance(middle, ring) < 0.05 &&
                          distance(ring, pinky) < 0.05

        let fingersAbovePalm = thumb.y > palm.y &&
                              index.y > palm.y &&
                              middle.y > palm.y

        return fingersClose && fingersAbovePalm
    }
}
```

### 3.2 Gaze Interaction
```swift
class GazeInteractionSystem {
    private var gazeTarget: Pet?
    private var gazeDuration: TimeInterval = 0
    private let trustBuildingThreshold: TimeInterval = 3.0

    func update(deltaTime: TimeInterval) {
        guard let currentGaze = EyeTrackingProvider.shared.currentGazeDirection else {
            resetGaze()
            return
        }

        // Raycast to find pet
        if let pet = raycastToPet(from: currentGaze) {
            if pet.id == gazeTarget?.id {
                // Continuing to look at same pet
                gazeDuration += deltaTime

                if gazeDuration >= trustBuildingThreshold {
                    buildTrust(with: pet)
                }
            } else {
                // New pet
                gazeTarget = pet
                gazeDuration = 0
            }

            // Pet looks back at player
            makePetLookAtPlayer(pet)
        } else {
            resetGaze()
        }
    }

    private func buildTrust(with pet: Pet) {
        // Gradual trust increase
        var mutablePet = pet
        mutablePet.affection.trust += 0.001

        // Pet shows happiness
        VisualEffectsManager.shared.showEyeContact(for: pet)
        AudioManager.shared.playSound(.recognitionChirp, at: pet.currentLocation)

        PetManager.shared.update(mutablePet)
    }
}
```

### 3.3 Voice Commands
```swift
import Speech

class VoiceCommandSystem {
    private let speechRecognizer = SFSpeechRecognizer()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    func startListening() {
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest?.shouldReportPartialResults = true

        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest!) { result, error in
            if let result = result {
                self.processCommand(result.bestTranscription.formattedString)
            }
        }

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        try? audioEngine.start()
    }

    private func processCommand(_ command: String) {
        let lowercased = command.lowercased()

        // Check for pet names
        for pet in PetManager.shared.allPets {
            if lowercased.contains(pet.name.lowercased()) {
                // Pet hears its name
                respondToName(pet)
            }
        }

        // Process commands
        if lowercased.contains("come here") {
            commandComeHere()
        } else if lowercased.contains("sit") {
            commandSit()
        } else if lowercased.contains("play") {
            commandPlay()
        } else if lowercased.contains("dinner time") || lowercased.contains("eat") {
            commandEat()
        }
    }

    private func respondToName(_ pet: Pet) {
        // Pet looks toward player
        AnimationController.shared.playAnimation(.lookAtPlayer, for: pet)

        // Play recognition sound
        AudioManager.shared.playSound(.nameRecognition, at: pet.currentLocation)

        // Increase loyalty
        var mutablePet = pet
        mutablePet.affection.loyalty += 0.005
        PetManager.shared.update(mutablePet)
    }
}
```

### 3.4 Game Controller Support
```swift
import GameController

class GameControllerManager {
    private var controller: GCController?

    func setup() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(controllerConnected),
            name: .GCControllerDidConnect,
            object: nil
        )

        // Check for already connected controllers
        if let controller = GCController.controllers().first {
            setupController(controller)
        }
    }

    @objc private func controllerConnected(_ notification: Notification) {
        guard let controller = notification.object as? GCController else { return }
        setupController(controller)
    }

    private func setupController(_ controller: GCController) {
        self.controller = controller

        // Map buttons
        controller.extendedGamepad?.buttonA.pressedChangedHandler = { button, value, pressed in
            if pressed {
                // Interact with nearest pet
                self.interactWithNearestPet()
            }
        }

        controller.extendedGamepad?.buttonB.pressedChangedHandler = { button, value, pressed in
            if pressed {
                // Open pet menu
                self.openPetMenu()
            }
        }

        // Map joystick for navigation
        controller.extendedGamepad?.leftThumbstick.valueChangedHandler = { stick, x, y in
            self.moveCamera(x: x, y: y)
        }
    }
}
```

---

## 4. Physics Specifications

### 4.1 Physics Properties
```swift
struct PetPhysicsProperties {
    var mass: Float
    var friction: Float
    var restitution: Float // Bounciness
    var dragCoefficient: Float

    static func properties(for species: PetSpecies) -> PetPhysicsProperties {
        switch species {
        case .luminos:
            return PetPhysicsProperties(
                mass: 0.5,
                friction: 0.1,
                restitution: 0.3,
                dragCoefficient: 0.5 // Floaty
            )
        case .fluffkins:
            return PetPhysicsProperties(
                mass: 2.0,
                friction: 0.8,
                restitution: 0.1,
                dragCoefficient: 0.3 // Heavier
            )
        case .crystalites:
            return PetPhysicsProperties(
                mass: 3.0,
                friction: 0.2,
                restitution: 0.8,
                dragCoefficient: 0.1 // Bouncy
            )
        case .aquarians:
            return PetPhysicsProperties(
                mass: 1.0,
                friction: 0.05,
                restitution: 0.2,
                dragCoefficient: 0.9 // Very floaty
            )
        case .shadowlings:
            return PetPhysicsProperties(
                mass: 0.3,
                friction: 0.3,
                restitution: 0.2,
                dragCoefficient: 0.4 // Light
            )
        }
    }
}
```

### 4.2 Collision Detection
```swift
class CollisionDetector {
    func checkCollision(_ entityA: Entity, _ entityB: Entity) -> Bool {
        guard let collisionA = entityA.components[CollisionComponent.self],
              let collisionB = entityB.components[CollisionComponent.self] else {
            return false
        }

        // Get bounding boxes
        let boundsA = entityA.visualBounds(relativeTo: nil)
        let boundsB = entityB.visualBounds(relativeTo: nil)

        return boundsA.intersects(boundsB)
    }

    func handleCollision(between petA: Pet, and petB: Pet) {
        // Calculate collision response
        let normalVector = normalize(petB.position - petA.position)

        // Separate pets
        let separationDistance: Float = 0.1
        petA.position -= normalVector * separationDistance
        petB.position += normalVector * separationDistance

        // Social interaction based on relationship
        let relationship = petA.relationships[petB.id] ?? 0.5

        if relationship > 0.7 {
            // Friendly bump
            triggerFriendlyInteraction(petA, petB)
        } else if relationship < 0.3 {
            // Avoid
            triggerAvoidance(petA, petB)
        }
    }
}
```

---

## 5. Rendering Requirements

### 5.1 Graphics Quality Settings
```swift
enum GraphicsQuality {
    case low
    case medium
    case high
    case ultra

    var shadowQuality: ShadowQuality {
        switch self {
        case .low: return .off
        case .medium: return .soft(radius: 0.05)
        case .high: return .soft(radius: 0.1)
        case .ultra: return .soft(radius: 0.2)
        }
    }

    var maxParticles: Int {
        switch self {
        case .low: return 50
        case .medium: return 100
        case .high: return 200
        case .ultra: return 500
        }
    }

    var textureResolution: Int {
        switch self {
        case .low: return 512
        case .medium: return 1024
        case .high: return 2048
        case .ultra: return 4096
        }
    }
}
```

### 5.2 Material System
```swift
class PetMaterialBuilder {
    static func buildMaterial(for species: PetSpecies, quality: GraphicsQuality) -> Material {
        var material = PhysicallyBasedMaterial()

        switch species {
        case .luminos:
            // Emissive light creature
            material.emissiveColor = .init(tint: .yellow, intensity: 2.0)
            material.baseColor = .init(tint: .white)
            material.roughness = .init(floatLiteral: 0.3)
            material.metallic = .init(floatLiteral: 0.0)

        case .fluffkins:
            // Fuzzy fur
            material.baseColor = .init(tint: .brown)
            material.roughness = .init(floatLiteral: 0.9)
            material.metallic = .init(floatLiteral: 0.0)

            if quality == .high || quality == .ultra {
                // Add subsurface scattering for fur
                material.blending = .transparent(opacity: .init(floatLiteral: 0.9))
            }

        case .crystalites:
            // Geometric crystals
            material.baseColor = .init(tint: .cyan)
            material.roughness = .init(floatLiteral: 0.1)
            material.metallic = .init(floatLiteral: 0.8)
            material.clearcoat = .init(floatLiteral: 1.0)

        case .aquarians:
            // Transparent water-like
            material.baseColor = .init(tint: .blue.withAlphaComponent(0.5))
            material.blending = .transparent(opacity: .init(floatLiteral: 0.6))
            material.roughness = .init(floatLiteral: 0.0)

        case .shadowlings:
            // Dark semi-transparent
            material.baseColor = .init(tint: .black.withAlphaComponent(0.7))
            material.blending = .transparent(opacity: .init(floatLiteral: 0.7))
            material.emissiveColor = .init(tint: .purple, intensity: 0.5)
        }

        return material
    }
}
```

---

## 6. Performance Budgets

### 6.1 Frame Rate Targets
- **Target FPS**: 60 FPS (16.67ms per frame)
- **Minimum FPS**: 55 FPS (18.18ms per frame)
- **Critical FPS**: 45 FPS (22.22ms per frame) - triggers quality reduction

### 6.2 Memory Budget
```swift
struct PerformanceBudget {
    static let maxMemoryUsage: UInt64 = 1_500_000_000 // 1.5 GB
    static let maxActivePets: Int = 10
    static let maxParticlesPerPet: Int = 50
    static let maxPolygonsPerPet: Int = 10_000

    static let frameTimeBudget: TimeInterval = 0.01667 // 60 FPS
    static let aiUpdateBudget: TimeInterval = 0.005    // 5ms
    static let physicsUpdateBudget: TimeInterval = 0.003 // 3ms
    static let renderBudget: TimeInterval = 0.008      // 8ms
}
```

### 6.3 Battery Optimization
```swift
class BatteryOptimizer {
    private var thermalState: ProcessInfo.ThermalState = .nominal

    func optimize() {
        thermalState = ProcessInfo.processInfo.thermalState

        switch thermalState {
        case .nominal:
            // Full performance
            GraphicsQuality.current = .high

        case .fair:
            // Slight reduction
            GraphicsQuality.current = .medium
            reduceParticles(by: 0.3)

        case .serious:
            // Significant reduction
            GraphicsQuality.current = .low
            reduceParticles(by: 0.6)
            reduceAIUpdateFrequency(by: 0.5)

        case .critical:
            // Minimal performance
            GraphicsQuality.current = .low
            disableParticles()
            reduceAIUpdateFrequency(by: 0.8)
            pauseNonEssentialPets()

        @unknown default:
            break
        }
    }

    private func pauseNonEssentialPets() {
        // Only simulate pets in view
        let pets = PetManager.shared.allPets
        let camera = CameraManager.shared.currentCamera

        for pet in pets {
            let distance = distance(pet.position, camera.position)

            if distance > 5.0 {
                // Pause this pet
                pet.isPaused = true
            }
        }
    }
}
```

---

## 7. Testing Requirements

### 7.1 Unit Testing Coverage Target: 80%+
```swift
// Example unit test
class PetFeedingTests: XCTestCase {
    var pet: Pet!
    var feedingSystem: FeedingSystem!

    override func setUp() {
        super.setUp()
        pet = Pet(species: .luminos, name: "TestPet")
        feedingSystem = FeedingSystem()
    }

    func testFeedingIncreasesHunger() {
        let initialHunger = pet.hunger

        feedingSystem.feed(&pet, food: .regularFood)

        XCTAssertGreaterThan(pet.hunger, initialHunger)
    }

    func testFeedingIncreasesHappiness() {
        let initialHappiness = pet.happiness

        feedingSystem.feed(&pet, food: .treat)

        XCTAssertGreaterThan(pet.happiness, initialHappiness)
    }

    func testOverfeedingDoesNotExceedMax() {
        pet.hunger = 0.95

        feedingSystem.feed(&pet, food: .premiumFood)

        XCTAssertLessThanOrEqual(pet.hunger, 1.0)
    }
}
```

### 7.2 Integration Testing
```swift
class SpatialIntegrationTests: XCTestCase {
    func testPetPersistenceAcrossAppRelaunch() async {
        // Create and save pet
        let pet = Pet(species: .fluffkins, name: "Fluffy")
        let anchor = await SpatialPersistenceManager.shared.createAnchor(at: SIMD3(0, 0, -2))
        pet.currentLocation.anchorID = anchor

        try await PersistenceManager.shared.save(pet)

        // Simulate app relaunch
        PetManager.shared.clearAll()

        // Load pets
        let loadedPets = try await PersistenceManager.shared.loadAllPets()

        XCTAssertEqual(loadedPets.count, 1)
        XCTAssertEqual(loadedPets.first?.name, "Fluffy")
        XCTAssertNotNil(loadedPets.first?.currentLocation.anchorID)
    }
}
```

### 7.3 Performance Testing
```swift
class PerformanceBenchmarks: XCTestCase {
    func testAISystemPerformance() {
        let pets = (0..<10).map { _ in Pet.createRandom() }
        let aiSystem = PetAISystem()

        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
            for _ in 0..<1000 {
                aiSystem.update(pets: pets, deltaTime: 0.016)
            }
        }
    }

    func testRenderingPerformance() {
        let scene = RealityKitScene()

        for _ in 0..<50 {
            let pet = Pet.createRandom()
            scene.addPet(pet)
        }

        measure(metrics: [XCTClockMetric()]) {
            for _ in 0..<60 {
                scene.update(deltaTime: 1.0/60.0)
            }
        }
    }
}
```

### 7.4 UI Testing
```swift
class UIAutomationTests: XCTestCase {
    func testPetAdoptionFlow() {
        let app = XCUIApplication()
        app.launch()

        // Tap "Adopt New Pet"
        app.buttons["Adopt New Pet"].tap()

        // Select Luminos
        app.buttons["Luminos"].tap()

        // Enter name
        let nameField = app.textFields["Pet Name"]
        nameField.tap()
        nameField.typeText("Sparky")

        // Confirm
        app.buttons["Adopt"].tap()

        // Verify pet appears
        XCTAssertTrue(app.staticTexts["Sparky"].exists)
    }
}
```

---

## 8. Accessibility Requirements

### 8.1 VoiceOver Support
```swift
extension PetView {
    var accessibilityConfiguration: some View {
        self
            .accessibilityLabel("\(pet.name), a \(pet.species.rawValue)")
            .accessibilityHint("Double tap to interact with your pet")
            .accessibilityValue("Health: \(Int(pet.health * 100))%, Happiness: \(Int(pet.happiness * 100))%")
            .accessibilityAddTraits(.isButton)
    }
}
```

### 8.2 Alternative Input Methods
```swift
class AccessibilityInputManager {
    func enableAlternativeInputs() {
        // Switch control support
        UIAccessibility.post(notification: .screenChanged, argument: nil)

        // Dwell control for gaze-only interaction
        enableDwellControl()

        // Voice-only mode
        if UserDefaults.standard.bool(forKey: "VoiceOnlyMode") {
            VoiceCommandSystem.shared.enableFullControl()
        }
    }

    private func enableDwellControl() {
        // After gazing at pet for 2 seconds, auto-interact
        GazeInteractionSystem.shared.dwellTime = 2.0
        GazeInteractionSystem.shared.dwellEnabled = true
    }
}
```

### 8.3 Reduced Motion
```swift
class MotionAccessibility {
    static var isReduceMotionEnabled: Bool {
        UIAccessibility.isReduceMotionEnabled
    }

    func applyReducedMotion() {
        if Self.isReduceMotionEnabled {
            // Disable particle effects
            VisualEffectsManager.shared.disableParticles()

            // Simplify animations
            AnimationController.shared.useSimpleAnimations = true

            // Remove camera shake
            CameraManager.shared.disableCameraShake()
        }
    }
}
```

---

## 9. Continuous Integration/Deployment

### 9.1 CI Pipeline (GitHub Actions)
```yaml
name: CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v3

      - name: Setup Xcode
        uses: maxim-lobanov/setup-xcode@v1
        with:
          xcode-version: '16.0'

      - name: Run Unit Tests
        run: |
          xcodebuild test \
            -scheme VirtualPetEcosystem \
            -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
            -resultBundlePath TestResults

      - name: Code Coverage
        run: |
          xcrun llvm-cov report \
            --instr-profile=TestResults/Coverage.profdata \
            --arch=arm64

      - name: Performance Tests
        run: |
          xcodebuild test \
            -scheme VirtualPetEcosystem-Performance \
            -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
```

### 9.2 Automated Testing Strategy
- **Pre-commit hooks**: Run unit tests and linting
- **Pull request**: Full test suite + code coverage check (min 80%)
- **Nightly builds**: Performance tests + memory leak detection
- **Release candidates**: Full manual QA + automated UI tests

---

## Summary

This technical specification covers:
- ✅ Complete technology stack (Swift 6.0+, RealityKit, ARKit)
- ✅ Detailed game mechanics implementation
- ✅ All control schemes (gestures, gaze, voice, controllers)
- ✅ Physics and collision systems
- ✅ Rendering and performance requirements
- ✅ Comprehensive testing strategy (unit, integration, performance, UI)
- ✅ Accessibility features
- ✅ CI/CD pipeline

Ready for implementation with test-driven development approach.
