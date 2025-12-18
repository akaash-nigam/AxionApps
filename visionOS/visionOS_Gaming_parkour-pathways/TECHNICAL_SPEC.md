# Parkour Pathways - Technical Specification
*Detailed Implementation Specifications for visionOS Gaming*

## Document Overview

This document provides detailed technical specifications for implementing Parkour Pathways. It covers technology stack, implementation details, performance requirements, and testing specifications.

---

## 1. Technology Stack

### 1.1 Core Technologies

| Technology | Version | Purpose |
|------------|---------|---------|
| Swift | 6.0+ | Primary programming language with strict concurrency |
| SwiftUI | visionOS 2.0+ | UI framework for menus and 2D interfaces |
| RealityKit | 4.0+ | 3D rendering and spatial gameplay |
| ARKit | 6.0+ | Spatial tracking and scene understanding |
| visionOS | 2.0+ | Platform SDK and spatial computing APIs |
| Spatial Audio | AVFoundation | 3D audio and spatial sound |
| SwiftData | 2.0+ | Local data persistence |
| CloudKit | Latest | Cloud sync and leaderboards |
| GameplayKit | Latest | AI and gameplay systems (optional) |

### 1.2 Development Tools

```yaml
development_environment:
  xcode: "16.0+"
  reality_composer_pro: "2.0+"
  instruments: "Profiling and performance analysis"
  create_ml: "Movement analysis ML models"

required_hardware:
  development: "Apple Vision Pro"
  testing: "Apple Vision Pro (multiple units for multiplayer)"
  minimum_mac: "MacBook Pro M2 or later"
```

### 1.3 Third-Party Dependencies

```swift
// Package.swift
dependencies: [
    // None required - using native Apple frameworks
    // Potential additions:
    // - Swift Collections (for advanced data structures)
    // - Swift Numerics (for physics calculations)
]
```

### 1.4 Build Configuration

```yaml
build_settings:
  deployment_target: "visionOS 2.0"
  swift_language_version: "6.0"
  enable_strict_concurrency: true
  optimization_level:
    debug: "-Onone"
    release: "-O"
  compilation_mode:
    debug: "incremental"
    release: "whole-module"
```

---

## 2. Game Mechanics Implementation

### 2.1 Core Movement Mechanics

#### Precision Jumping

```swift
struct PrecisionJumpMechanic {
    // Physics parameters
    let gravity: Float = 9.81 // m/s²
    let minJumpHeight: Float = 0.2 // meters
    let maxJumpHeight: Float = 0.8 // meters

    // Accuracy requirements
    let targetRadius: Float = 0.15 // meters
    let perfectRadius: Float = 0.05 // meters

    // Scoring
    func calculateScore(
        landingPosition: SIMD3<Float>,
        targetPosition: SIMD3<Float>
    ) -> Float {
        let distance = simd_distance(landingPosition, targetPosition)

        if distance <= perfectRadius {
            return 1.0 // Perfect landing
        } else if distance <= targetRadius {
            // Linear falloff from perfect to edge
            let ratio = (targetRadius - distance) / (targetRadius - perfectRadius)
            return 0.5 + (0.5 * ratio)
        } else {
            return 0.0 // Missed target
        }
    }

    // Physics validation
    func isPhysicallyPossible(
        from: SIMD3<Float>,
        to: SIMD3<Float>,
        playerAttributes: PlayerAttributes
    ) -> Bool {
        let horizontalDistance = simd_distance(
            SIMD2(from.x, from.z),
            SIMD2(to.x, to.z)
        )
        let verticalDistance = to.y - from.y

        // Calculate required jump velocity
        let requiredHeight = verticalDistance + (horizontalDistance * 0.5)
        return requiredHeight <= playerAttributes.maxJumpHeight
    }
}
```

#### Vaulting System

```swift
struct VaultMechanic {
    enum VaultType {
        case stepVault     // One hand, stepping motion
        case speedVault    // One hand, legs to side
        case kongVault     // Two hands, legs between
        case lazyVault     // One hand, legs over side
    }

    // Hand placement detection
    struct HandPlacement {
        let position: SIMD3<Float>
        let normal: SIMD3<Float>
        let gripStrength: Float
        let timestamp: Date
    }

    func detectVaultType(
        leftHand: HandPlacement?,
        rightHand: HandPlacement?,
        bodyVelocity: SIMD3<Float>,
        obstacleHeight: Float
    ) -> VaultType? {

        let speed = simd_length(bodyVelocity)
        let twoHandPlacement = leftHand != nil && rightHand != nil

        if twoHandPlacement && speed > 2.0 {
            return .kongVault
        } else if speed > 1.5 {
            return .speedVault
        } else if obstacleHeight < 0.8 {
            return .stepVault
        } else {
            return .lazyVault
        }
    }

    // Technique scoring
    func scoreTechnique(
        vaultType: VaultType,
        handPlacement: [HandPlacement],
        trajectoryData: [MovementSample]
    ) -> TechniqueScore {

        var score = TechniqueScore()

        // Hand placement accuracy
        score.handPlacement = scoreHandPlacement(handPlacement)

        // Body positioning
        score.bodyForm = scoreBodyForm(trajectoryData)

        // Fluidity
        score.fluidity = scoreFluidity(trajectoryData)

        // Speed
        score.speed = scoreSpeed(trajectoryData)

        return score
    }
}
```

#### Wall Run System

```swift
struct WallRunMechanic {
    // Physics constraints
    let minApproachSpeed: Float = 1.5 // m/s
    let maxAngleFromWall: Float = 45.0 // degrees
    let gravityReduction: Float = 0.6 // 40% less gravity
    let maxDuration: TimeInterval = 2.0 // seconds

    // State machine
    enum WallRunState {
        case approaching
        case engaged
        case disengaging
        case completed
    }

    func canInitiateWallRun(
        playerVelocity: SIMD3<Float>,
        wallNormal: SIMD3<Float>,
        contactPoint: SIMD3<Float>
    ) -> Bool {
        let speed = simd_length(playerVelocity)
        guard speed >= minApproachSpeed else { return false }

        // Calculate approach angle
        let velocityDirection = simd_normalize(playerVelocity)
        let angle = acos(simd_dot(velocityDirection, -wallNormal))
        let angleDegrees = angle * 180.0 / .pi

        return angleDegrees <= maxAngleFromWall
    }

    func updateWallRun(
        state: inout WallRunState,
        timeElapsed: TimeInterval,
        footContact: Bool
    ) {
        switch state {
        case .engaged:
            if !footContact || timeElapsed > maxDuration {
                state = .disengaging
            }
        case .disengaging:
            state = .completed
        default:
            break
        }
    }

    // Apply modified physics during wall run
    func applyWallRunPhysics(
        to entity: Entity,
        wallNormal: SIMD3<Float>
    ) {
        if var physics = entity.components[PhysicsBodyComponent.self] {
            // Reduce gravity effect
            let modifiedGravity = SIMD3<Float>(0, -9.81 * gravityReduction, 0)

            // Add lateral force along wall
            let lateralDirection = cross(wallNormal, SIMD3<Float>(0, 1, 0))
            let lateralForce = lateralDirection * 5.0

            physics.addForce(lateralForce, relativeTo: nil)
        }
    }
}
```

#### Balance Training

```swift
struct BalanceMechanic {
    // Balance parameters
    let stabilityThreshold: Float = 0.1 // meters
    let maxDeviation: Float = 0.3 // meters
    let recoveryTime: TimeInterval = 1.0 // seconds

    struct BalanceState {
        var centerOfMass: SIMD3<Float>
        var supportBase: SIMD3<Float>
        var deviation: Float
        var isStable: Bool
        var timeUnstable: TimeInterval
    }

    func calculateBalance(
        bodyPosition: SIMD3<Float>,
        footPositions: [SIMD3<Float>],
        headPosition: SIMD3<Float>
    ) -> BalanceState {

        // Calculate center of mass (simplified)
        let centerOfMass = calculateCenterOfMass(
            body: bodyPosition,
            head: headPosition
        )

        // Calculate support base (average foot position)
        let supportBase = footPositions.reduce(SIMD3<Float>.zero, +) / Float(footPositions.count)

        // Calculate horizontal deviation
        let deviation = simd_distance(
            SIMD2(centerOfMass.x, centerOfMass.z),
            SIMD2(supportBase.x, supportBase.z)
        )

        // Determine stability
        let isStable = deviation <= stabilityThreshold

        return BalanceState(
            centerOfMass: centerOfMass,
            supportBase: supportBase,
            deviation: deviation,
            isStable: isStable,
            timeUnstable: 0
        )
    }

    // Provide balance assistance via haptics and visual cues
    func provideBalanceAssistance(_ state: BalanceState) {
        if !state.isStable {
            // Calculate correction direction
            let correctionDirection = state.supportBase - state.centerOfMass

            // Trigger directional haptic feedback
            triggerDirectionalHaptic(direction: correctionDirection)

            // Show visual indicator
            showBalanceIndicator(direction: correctionDirection)
        }
    }
}
```

### 2.2 AI Course Generation Mechanics

```swift
class CourseGenerationAlgorithm {
    struct GenerationParameters {
        var spaceModel: RoomModel
        var playerSkill: SkillLevel
        var difficulty: DifficultyLevel
        var duration: TimeInterval
        var focusAreas: [SkillCategory]
    }

    // Main generation algorithm
    func generate(_ params: GenerationParameters) -> CourseData {
        // Phase 1: Space analysis
        let usableSpace = analyzeUsableSpace(params.spaceModel)

        // Phase 2: Calculate obstacle budget
        let obstacleCount = calculateObstacleCount(
            space: usableSpace,
            difficulty: params.difficulty,
            duration: params.duration
        )

        // Phase 3: Select obstacle types
        let obstacleTypes = selectObstacleTypes(
            skillLevel: params.playerSkill,
            focusAreas: params.focusAreas,
            count: obstacleCount
        )

        // Phase 4: Generate obstacle graph
        var graph = ObstacleGraph()

        for obstacleType in obstacleTypes {
            let placement = findOptimalPlacement(
                type: obstacleType,
                existingObstacles: graph.obstacles,
                space: usableSpace,
                playerSkill: params.playerSkill
            )

            if let placement = placement {
                graph.add(createObstacle(
                    type: obstacleType,
                    placement: placement,
                    difficulty: params.difficulty
                ))
            }
        }

        // Phase 5: Optimize flow
        graph = optimizeFlow(graph, playerAttributes: getPlayerAttributes())

        // Phase 6: Validate safety
        validateSafety(&graph, space: params.spaceModel)

        // Phase 7: Add checkpoints
        let checkpoints = generateCheckpoints(graph)

        return CourseData(
            obstacles: graph.obstacles,
            checkpoints: checkpoints,
            spaceRequirements: calculateRequirements(graph)
        )
    }

    // Obstacle placement algorithm
    func findOptimalPlacement(
        type: ObstacleType,
        existingObstacles: [Obstacle],
        space: UsableSpace,
        playerSkill: SkillLevel
    ) -> ObstaclePlacement? {

        // Generate candidate positions
        var candidates: [ObstaclePlacement] = []

        // Grid-based sampling
        for x in stride(from: space.bounds.minX, to: space.bounds.maxX, by: 0.5) {
            for z in stride(from: space.bounds.minZ, to: space.bounds.maxZ, by: 0.5) {
                let position = SIMD3<Float>(x, space.floorHeight, z)

                if isValidPosition(position, type: type, existing: existingObstacles, space: space) {
                    let score = scorePlacement(
                        position: position,
                        type: type,
                        existing: existingObstacles,
                        skill: playerSkill
                    )

                    candidates.append(ObstaclePlacement(
                        position: position,
                        score: score
                    ))
                }
            }
        }

        // Select best placement
        return candidates.max(by: { $0.score < $1.score })
    }
}
```

### 2.3 Movement Analysis AI

```swift
class MovementAnalysisEngine {
    private let mlModel: MovementClassifier

    // Real-time technique analysis
    func analyzeTechnique(
        samples: [MovementSample],
        expectedMovement: MovementType
    ) -> TechniqueAnalysis {

        // Extract features
        let features = extractFeatures(samples)

        // Run ML model
        guard let prediction = try? mlModel.prediction(features: features) else {
            return TechniqueAnalysis.defaultAnalysis
        }

        // Compare with ideal technique
        let idealTechnique = TechniqueDatabase.shared.getIdeal(expectedMovement)
        let deviations = calculateDeviations(samples, ideal: idealTechnique)

        // Generate actionable feedback
        let feedback = generateFeedback(deviations, prediction: prediction)

        return TechniqueAnalysis(
            movementType: expectedMovement,
            accuracy: prediction.confidence,
            techniqueScore: calculateScore(deviations),
            deviations: deviations,
            feedback: feedback,
            improvementSuggestions: generateSuggestions(deviations)
        )
    }

    // Feature extraction for ML model
    private func extractFeatures(_ samples: [MovementSample]) -> MLFeatures {
        var features = MLFeatures()

        // Velocity profile (10 samples)
        features.velocityProfile = resample(
            samples.map { $0.velocity },
            targetCount: 10
        ).flatMap { [$0.x, $0.y, $0.z] }

        // Acceleration profile (10 samples)
        features.accelerationProfile = resample(
            samples.map { $0.acceleration },
            targetCount: 10
        ).flatMap { [$0.x, $0.y, $0.z] }

        // Joint angles (key joints only)
        features.jointAngles = extractKeyJointAngles(samples)

        // Movement characteristics
        features.maxVelocity = samples.map { simd_length($0.velocity) }.max() ?? 0
        features.avgVelocity = samples.map { simd_length($0.velocity) }.reduce(0, +) / Float(samples.count)
        features.movementDuration = samples.last!.timestamp - samples.first!.timestamp

        // Body positioning
        features.bodyOrientation = extractBodyOrientation(samples)

        return features
    }
}
```

---

## 3. Control Schemes

### 3.1 Hand Tracking Controls

```swift
class HandTrackingController {
    enum HandGesture {
        case pinch(strength: Float)
        case grab(fingers: Set<FingerType>)
        case point(direction: SIMD3<Float>)
        case wave
        case thumbsUp
    }

    // Hand position tracking
    func updateHandTracking() async {
        guard let handTracking = await arkitSession.queryLatestHandTracking() else {
            return
        }

        for anchor in handTracking.anchors {
            // Get hand skeleton
            let skeleton = anchor.skeleton

            // Detect gestures
            let gesture = detectGesture(skeleton)

            // Process based on game context
            switch currentGameContext {
            case .vaulting:
                handleVaultHandPlacement(anchor, gesture)

            case .climbing:
                handleClimbingGrip(anchor, gesture)

            case .balancing:
                handleBalanceAssist(anchor)

            case .menu:
                handleMenuInteraction(anchor, gesture)
            }
        }
    }

    // Gesture recognition
    private func detectGesture(_ skeleton: HandSkeleton) -> HandGesture {
        // Pinch detection
        let thumbTip = skeleton.joint(.thumbTip)
        let indexTip = skeleton.joint(.indexFingerTip)
        let pinchDistance = simd_distance(thumbTip.position, indexTip.position)

        if pinchDistance < 0.02 { // 2cm
            let strength = (0.02 - pinchDistance) / 0.02
            return .pinch(strength: strength)
        }

        // Grab detection
        let fingersTouching = detectFingersTouchingPalm(skeleton)
        if fingersTouching.count >= 3 {
            return .grab(fingers: fingersTouching)
        }

        // Default
        let indexDirection = skeleton.joint(.indexFingerTip).position -
                           skeleton.joint(.indexFingerKnuckle).position
        return .point(direction: simd_normalize(indexDirection))
    }

    // Haptic feedback
    func triggerHaptic(_ pattern: HapticPattern, hand: HandChirality) {
        // Trigger haptic feedback on appropriate controller or device
        switch pattern {
        case .success:
            playHaptic(.success, duration: 0.1)
        case .warning:
            playHaptic(.warning, duration: 0.2)
        case .error:
            playHaptic(.error, duration: 0.3)
        case .continuous(let intensity):
            playHaptic(.continuous(intensity), duration: 0.5)
        }
    }
}
```

### 3.2 Eye Tracking Controls

```swift
class EyeTrackingController {
    private var currentGazeTarget: Entity?
    private var gazeStartTime: Date?
    private let dwellTime: TimeInterval = 0.8 // seconds

    func updateEyeTracking() async {
        guard let deviceAnchor = await arkitSession.queryDeviceAnchor() else {
            return
        }

        // Get eye gaze direction
        let gazeDirection = calculateGazeDirection(deviceAnchor)

        // Raycast to find target
        let raycastResults = scene.raycast(
            origin: deviceAnchor.originFromAnchorTransform.translation,
            direction: gazeDirection
        )

        if let hit = raycastResults.first {
            handleGazeTarget(hit.entity)
        } else {
            clearGazeTarget()
        }
    }

    private func handleGazeTarget(_ entity: Entity) {
        // New target
        if entity != currentGazeTarget {
            currentGazeTarget = entity
            gazeStartTime = Date()

            // Highlight entity
            highlightEntity(entity)
        }
        // Continuing to look at same target
        else if let startTime = gazeStartTime {
            let gazeDuration = Date().timeIntervalSince(startTime)

            // Dwell activation
            if gazeDuration >= dwellTime {
                activateEntity(entity)
                clearGazeTarget()
            } else {
                // Show dwell progress
                updateDwellProgress(entity, progress: gazeDuration / dwellTime)
            }
        }
    }

    // Use for targeting
    func getGazeTarget() -> SIMD3<Float>? {
        guard let entity = currentGazeTarget,
              let component = entity.components[TargetComponent.self] else {
            return nil
        }

        return entity.position
    }
}
```

### 3.3 Voice Commands

```swift
class VoiceCommandController {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))

    enum VoiceCommand {
        case startCourse
        case pauseCourse
        case resumeCourse
        case stopCourse
        case adjustDifficulty(DifficultyLevel)
        case requestHelp
        case repeatInstructions
        case nextObstacle
        case previousObstacle
    }

    func startListening() {
        let request = SFSpeechAudioBufferRecognitionRequest()

        speechRecognizer?.recognitionTask(with: request) { [weak self] result, error in
            guard let result = result else { return }

            let transcript = result.bestTranscription.formattedString.lowercased()

            // Parse command
            if let command = self?.parseCommand(transcript) {
                self?.executeCommand(command)
            }
        }
    }

    private func parseCommand(_ transcript: String) -> VoiceCommand? {
        switch transcript {
        case let t where t.contains("start"):
            return .startCourse
        case let t where t.contains("pause"):
            return .pauseCourse
        case let t where t.contains("resume") || t.contains("continue"):
            return .resumeCourse
        case let t where t.contains("stop") || t.contains("end"):
            return .stopCourse
        case let t where t.contains("help"):
            return .requestHelp
        case let t where t.contains("easier"):
            return .adjustDifficulty(.easy)
        case let t where t.contains("harder"):
            return .adjustDifficulty(.hard)
        case let t where t.contains("next"):
            return .nextObstacle
        default:
            return nil
        }
    }
}
```

### 3.4 Game Controller Support

```swift
class GameControllerManager {
    private var connectedControllers: [GCController] = []

    func setupControllers() {
        // Observe controller connections
        NotificationCenter.default.addObserver(
            forName: .GCControllerDidConnect,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let controller = notification.object as? GCController else { return }
            self?.controllerConnected(controller)
        }

        // Handle existing controllers
        connectedControllers = GCController.controllers()
    }

    private func controllerConnected(_ controller: GCController) {
        connectedControllers.append(controller)

        // Configure extended gamepad if available
        if let gamepad = controller.extendedGamepad {
            configureGamepad(gamepad)
        }
    }

    private func configureGamepad(_ gamepad: GCExtendedGamepad) {
        // Movement (left stick)
        gamepad.leftThumbstick.valueChangedHandler = { [weak self] _, x, y in
            self?.handleMovementInput(x: x, y: y)
        }

        // Camera (right stick)
        gamepad.rightThumbstick.valueChangedHandler = { [weak self] _, x, y in
            self?.handleCameraInput(x: x, y: y)
        }

        // Actions
        gamepad.buttonA.pressedChangedHandler = { [weak self] _, _, pressed in
            if pressed { self?.handleJumpAction() }
        }

        gamepad.buttonB.pressedChangedHandler = { [weak self] _, _, pressed in
            if pressed { self?.handleVaultAction() }
        }

        // Triggers
        gamepad.rightTrigger.valueChangedHandler = { [weak self] _, value, pressed in
            self?.handleSprintInput(intensity: value)
        }
    }
}
```

---

## 4. Physics Specifications

### 4.1 Physics Configuration

```swift
struct PhysicsConfiguration {
    // World settings
    static let gravity = SIMD3<Float>(0, -9.81, 0) // m/s²
    static let timeStep: Float = 1.0/90.0 // 90 Hz
    static let solverIterations: Int = 8
    static let velocityIterations: Int = 6

    // Material properties
    struct Materials {
        static let playerMaterial = PhysicsMaterialResource(
            staticFriction: 0.6,
            dynamicFriction: 0.4,
            restitution: 0.1 // Low bounce
        )

        static let obstacleMaterial = PhysicsMaterialResource(
            staticFriction: 0.8,
            dynamicFriction: 0.6,
            restitution: 0.2
        )

        static let floorMaterial = PhysicsMaterialResource(
            staticFriction: 0.9,
            dynamicFriction: 0.7,
            restitution: 0.0
        )
    }

    // Collision layers
    struct CollisionLayers {
        static let player: CollisionGroup = .init(rawValue: 1 << 0)
        static let obstacle: CollisionGroup = .init(rawValue: 1 << 1)
        static let boundary: CollisionGroup = .init(rawValue: 1 << 2)
        static let target: CollisionGroup = .init(rawValue: 1 << 3)
        static let furniture: CollisionGroup = .init(rawValue: 1 << 4)
    }
}
```

### 4.2 Collision Detection

```swift
class CollisionManager {
    // Collision matrix (what collides with what)
    private func setupCollisionMatrix() {
        // Player collides with obstacles, boundaries, and furniture
        let playerCollides: CollisionGroup = [
            .obstacle,
            .boundary,
            .furniture
        ]

        // Targets only trigger events (no physical collision)
        let targetTriggers: CollisionGroup = [.player]

        // Configure entities
        configureCollisions(
            group: .player,
            collidesWith: playerCollides
        )

        configureCollisions(
            group: .target,
            collidesWith: [],  // No physical collision
            triggers: targetTriggers  // But does trigger events
        )
    }

    // Broad phase collision detection
    func performBroadPhase() -> [CollisionPair] {
        var pairs: [CollisionPair] = []

        // Use spatial hash for efficient broad phase
        let spatialHash = buildSpatialHash(entities: allPhysicsEntities)

        for (cell, entities) in spatialHash {
            // Check entities in same cell and neighboring cells
            let neighbors = getNeighboringCells(cell)

            for entity in entities {
                for neighbor in neighbors {
                    if let neighborEntities = spatialHash[neighbor] {
                        for otherEntity in neighborEntities where entity.id < otherEntity.id {
                            if shouldCheckCollision(entity, otherEntity) {
                                pairs.append(CollisionPair(entity, otherEntity))
                            }
                        }
                    }
                }
            }
        }

        return pairs
    }

    // Narrow phase collision detection
    func performNarrowPhase(_ pairs: [CollisionPair]) -> [Collision] {
        return pairs.compactMap { pair in
            detectCollision(pair.entityA, pair.entityB)
        }
    }
}
```

### 4.3 Character Physics

```swift
class CharacterPhysicsController {
    private let characterHeight: Float = 1.7 // meters
    private let characterRadius: Float = 0.3 // meters
    private let maxSpeed: Float = 5.0 // m/s
    private let acceleration: Float = 20.0 // m/s²

    // Character controller (not rigid body for better control)
    func updateCharacter(deltaTime: Float, input: MovementInput) {
        var desiredVelocity = input.direction * maxSpeed

        // Apply acceleration
        let velocityChange = desiredVelocity - currentVelocity
        let acceleration = min(
            simd_length(velocityChange),
            acceleration * deltaTime
        )

        if simd_length(velocityChange) > 0 {
            currentVelocity += simd_normalize(velocityChange) * acceleration
        }

        // Apply gravity
        currentVelocity.y += gravity * deltaTime

        // Move with collision detection
        let movement = currentVelocity * deltaTime
        performCharacterMove(movement)
    }

    private func performCharacterMove(_ movement: SIMD3<Float>) {
        // Capsule cast for collision
        let castResults = scene.castCapsule(
            from: position,
            to: position + movement,
            radius: characterRadius,
            height: characterHeight
        )

        if let hit = castResults.first {
            // Slide along surface
            let slideMovement = calculateSlideMovement(
                movement: movement,
                hitNormal: hit.normal
            )
            position += slideMovement

            // Update grounded state
            if hit.normal.y > 0.7 {
                isGrounded = true
                currentVelocity.y = 0
            }
        } else {
            // Free movement
            position += movement
            isGrounded = false
        }
    }
}
```

---

## 5. Rendering Requirements

### 5.1 Performance Targets

```swift
struct RenderingPerformanceTargets {
    // Frame rate
    static let targetFPS: Float = 90.0
    static let minimumFPS: Float = 60.0
    static let frameTime: TimeInterval = 1.0/90.0 // 11.1ms

    // Resolution
    static let perEyeResolution = CGSize(width: 2048, height: 2048)

    // Draw calls
    static let maxDrawCalls: Int = 500
    static let targetDrawCalls: Int = 300

    // Triangles
    static let maxTriangles: Int = 2_000_000
    static let targetTriangles: Int = 1_000_000

    // Textures
    static let maxTextureMemory: Int = 512_000_000 // 512MB
    static let maxTextureSize = CGSize(width: 2048, height: 2048)
}
```

### 5.2 LOD System

```swift
class LODSystem {
    enum LODLevel: Int {
        case high = 0
        case medium = 1
        case low = 2
        case impostor = 3
    }

    struct LODDistances {
        static let high: Float = 2.0 // meters
        static let medium: Float = 5.0
        static let low: Float = 10.0
        static let impostor: Float = 20.0
    }

    func updateLOD(for entity: Entity, cameraPosition: SIMD3<Float>) {
        let distance = simd_distance(entity.position, cameraPosition)
        let lodLevel = determineLODLevel(distance)

        // Update model
        if let model = entity.components[ModelComponent.self] {
            updateModelLOD(entity, level: lodLevel)
        }

        // Update materials
        updateMaterialQuality(entity, level: lodLevel)

        // Update shadows
        updateShadowQuality(entity, level: lodLevel)
    }

    private func determineLODLevel(_ distance: Float) -> LODLevel {
        if distance < LODDistances.high {
            return .high
        } else if distance < LODDistances.medium {
            return .medium
        } else if distance < LODDistances.low {
            return .low
        } else {
            return .impostor
        }
    }
}
```

### 5.3 Shader Configuration

```swift
// Custom shader for obstacles with highlight
struct ObstacleShader {
    static let shader = CustomMaterial.SurfaceShader(
        named: "obstacleShader",
        in: MetalLibrary.default
    )
}

// Metal shader (obstacleShader.metal)
/*
#include <metal_stdlib>
#include <RealityKit/RealityKit.h>
using namespace metal;

[[visible]]
void obstacleShader(realitykit::surface_parameters params)
{
    // Base color
    half3 baseColor = params.material().base_color().rgb;

    // Difficulty-based color tint
    half difficulty = params.material().custom_parameter();
    half3 difficultyTint = mix(
        half3(0, 1, 0),    // Green for easy
        half3(1, 0, 0),    // Red for hard
        difficulty
    );

    // Highlight when nearby
    half proximityHighlight = params.material().custom_parameter_2();
    half3 highlightColor = half3(1, 1, 0) * proximityHighlight;

    // Combine
    half3 finalColor = baseColor * difficultyTint + highlightColor;

    params.surface().set_base_color(finalColor);
}
*/
```

---

## 6. Multiplayer Specifications

### 6.1 Network Architecture

```swift
struct NetworkConfiguration {
    // SharePlay
    static let groupActivityID = "com.parkourpathways.groupactivity"
    static let maxPlayers: Int = 4

    // Network performance
    static let targetLatency: TimeInterval = 0.05 // 50ms
    static let maxAcceptableLatency: TimeInterval = 0.15 // 150ms
    static let updateRate: Int = 30 // updates per second

    // Synchronization
    static let syncInterval: TimeInterval = 1.0/30.0
    static let snapshotBufferSize: Int = 60 // 2 seconds at 30 Hz
}

class NetworkSynchronization {
    // Client-side prediction
    func predictPlayerPosition(
        lastKnownPosition: SIMD3<Float>,
        velocity: SIMD3<Float>,
        latency: TimeInterval
    ) -> SIMD3<Float> {
        // Predict where player will be
        return lastKnownPosition + velocity * Float(latency)
    }

    // Server reconciliation
    func reconcilePosition(
        predictedPosition: SIMD3<Float>,
        serverPosition: SIMD3<Float>,
        threshold: Float = 0.5
    ) -> SIMD3<Float> {
        let error = simd_distance(predictedPosition, serverPosition)

        if error < threshold {
            // Small error: smooth interpolation
            return mix(predictedPosition, serverPosition, t: 0.1)
        } else {
            // Large error: snap to server position
            return serverPosition
        }
    }

    // Entity interpolation for smooth remote player movement
    func interpolateEntity(
        from: EntitySnapshot,
        to: EntitySnapshot,
        alpha: Float
    ) -> EntityState {
        return EntityState(
            position: mix(from.position, to.position, t: alpha),
            rotation: simd_slerp(from.rotation, to.rotation, alpha),
            velocity: mix(from.velocity, to.velocity, t: alpha)
        )
    }
}
```

### 6.2 Leaderboard System

```swift
class LeaderboardManager {
    private let cloudKitContainer = CKContainer.default()

    struct LeaderboardEntry: Codable {
        let playerID: UUID
        let playerName: String
        let courseID: UUID
        let score: Float
        let completionTime: TimeInterval
        let timestamp: Date
        let techniqueScores: [String: Float]
    }

    func submitScore(_ entry: LeaderboardEntry) async throws {
        let record = CKRecord(recordType: "CourseScore")
        record["playerID"] = entry.playerID.uuidString
        record["playerName"] = entry.playerName
        record["courseID"] = entry.courseID.uuidString
        record["score"] = entry.score
        record["completionTime"] = entry.completionTime
        record["timestamp"] = entry.timestamp

        try await cloudKitContainer.publicCloudDatabase.save(record)
    }

    func fetchLeaderboard(
        courseID: UUID,
        limit: Int = 100
    ) async throws -> [LeaderboardEntry] {
        let predicate = NSPredicate(
            format: "courseID == %@",
            courseID.uuidString
        )

        let query = CKQuery(
            recordType: "CourseScore",
            predicate: predicate
        )
        query.sortDescriptors = [
            NSSortDescriptor(key: "score", ascending: false)
        ]

        let results = try await cloudKitContainer.publicCloudDatabase.records(
            matching: query,
            resultsLimit: limit
        )

        return results.matchResults.compactMap { try? $0.1.get() }
            .map { convertToEntry($0) }
    }
}
```

---

## 7. Performance Budgets

### 7.1 Frame Budget

```yaml
frame_budget:
  target_frame_time: 11.1ms  # 90 FPS

  phase_allocations:
    input_processing: 1.0ms
    game_logic: 3.0ms
    physics: 2.0ms
    ecs_systems: 2.0ms
    spatial_updates: 1.0ms
    audio: 1.0ms
    render_prep: 1.1ms
    reserve: 0.0ms
```

### 7.2 Memory Budget

```yaml
memory_budget:
  total_budget: 2.0GB

  allocations:
    geometry_buffers: 400MB
    textures: 512MB
    audio_buffers: 100MB
    spatial_mapping: 300MB
    movement_history: 50MB
    course_data: 100MB
    system_overhead: 538MB
```

### 7.3 Battery Budget

```yaml
battery_performance:
  target_session_duration: 2.5_hours

  power_optimization:
    - Reduce rendering quality when battery < 20%
    - Lower physics update rate on battery
    - Reduce spatial mapping frequency
    - Disable advanced visual effects

  thermal_management:
    - Monitor device temperature
    - Reduce load when approaching thermal limits
    - Dynamic LOD based on thermal state
```

---

## 8. Testing Requirements

### 8.1 Unit Testing

```swift
class GameLogicTests: XCTestCase {
    func testPrecisionJumpScoring() {
        let mechanic = PrecisionJumpMechanic()

        // Perfect landing
        let perfectScore = mechanic.calculateScore(
            landingPosition: SIMD3<Float>(0, 0, 0),
            targetPosition: SIMD3<Float>(0, 0, 0)
        )
        XCTAssertEqual(perfectScore, 1.0, accuracy: 0.01)

        // Near miss
        let nearScore = mechanic.calculateScore(
            landingPosition: SIMD3<Float>(0.1, 0, 0),
            targetPosition: SIMD3<Float>(0, 0, 0)
        )
        XCTAssertGreaterThan(nearScore, 0.5)
        XCTAssertLessThan(nearScore, 1.0)

        // Complete miss
        let missScore = mechanic.calculateScore(
            landingPosition: SIMD3<Float>(1.0, 0, 0),
            targetPosition: SIMD3<Float>(0, 0, 0)
        )
        XCTAssertEqual(missScore, 0.0)
    }

    func testCourseGeneration() async throws {
        let generator = AICourseGenerator()
        let mockRoom = createMockRoom(width: 3, length: 3)
        let mockPlayer = createMockPlayer(skillLevel: .beginner)

        let course = try await generator.generateCourse(
            for: mockRoom,
            player: mockPlayer,
            difficulty: .medium
        )

        XCTAssertGreaterThan(course.obstacles.count, 0)
        XCTAssertTrue(validateSafety(course, room: mockRoom))
    }
}
```

### 8.2 Integration Testing

```swift
class SpatialIntegrationTests: XCTestCase {
    func testRoomScanningAndCourseGeneration() async throws {
        let spatialSystem = SpatialMappingSystem()
        let generator = AICourseGenerator()

        // Scan mock room
        let roomScan = try await spatialSystem.scanRoom()
        XCTAssertGreaterThan(roomScan.surfaces.count, 0)

        // Generate course for scanned room
        let course = try await generator.generateCourse(
            for: roomScan.roomModel,
            player: mockPlayer,
            difficulty: .medium
        )

        // Verify course fits in room
        XCTAssertTrue(course.fitsIn(roomScan.roomModel))

        // Verify safety constraints
        XCTAssertTrue(validateSafety(course, room: roomScan.roomModel))
    }
}
```

### 8.3 Performance Testing

```swift
class PerformanceTests: XCTestCase {
    func testFrameRateStability() {
        let options = XCTMeasureOptions()
        options.iterationCount = 1000

        measure(metrics: [XCTClockMetric()], options: options) {
            gameLoop.update(deltaTime: 1.0/90.0)
        }

        // Assert average frame time < 11.1ms
    }

    func testMemoryStability() {
        let memoryMetric = XCTMemoryMetric()

        measure(metrics: [memoryMetric]) {
            // Simulate 10-minute gameplay session
            for _ in 0..<600 {
                gameLoop.update(deltaTime: 1.0/90.0)
                RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
            }
        }

        // Assert memory usage < 2GB
        // Assert no significant leaks
    }
}
```

### 8.4 Safety Testing

```swift
class SafetyTests: XCTestCase {
    func testBoundaryDetection() {
        let safetySystem = SafetySystem()
        let boundary = createTestBoundary()

        // Test approaching boundary
        for distance in stride(from: 2.0, through: 0.0, by: -0.1) {
            let position = SIMD3<Float>(distance, 0, 0)
            let status = safetySystem.checkBoundary(position, boundary)

            if distance < 0.3 {
                XCTAssertEqual(status, .critical)
            } else if distance < 0.6 {
                XCTAssertEqual(status, .warning)
            } else {
                XCTAssertEqual(status, .safe)
            }
        }
    }

    func testCollisionPrevention() async {
        let collisionPredictor = CollisionPredictor()

        // Set up collision scenario
        let playerPosition = SIMD3<Float>(0, 0, 0)
        let playerVelocity = SIMD3<Float>(2, 0, 0) // Moving toward obstacle
        let obstacle = createObstacle(at: SIMD3<Float>(1, 0, 0))

        let risk = collisionPredictor.predict(
            position: playerPosition,
            velocity: playerVelocity,
            obstacles: [obstacle]
        )

        XCTAssertGreaterThan(risk, 0.5, "Should detect collision risk")
    }
}
```

### 8.5 Multiplayer Testing

```swift
class MultiplayerTests: XCTestCase {
    func testNetworkSynchronization() async throws {
        let host = createMultiplayerHost()
        let client = createMultiplayerClient()

        // Connect
        try await host.start()
        try await client.connect(to: host)

        // Synchronize positions
        let hostPosition = SIMD3<Float>(1, 0, 0)
        await host.updatePosition(hostPosition)

        // Wait for sync
        try await Task.sleep(nanoseconds: 100_000_000) // 100ms

        let clientPosition = await client.getRemotePlayerPosition(host.playerID)

        // Assert positions match within tolerance
        let distance = simd_distance(hostPosition, clientPosition)
        XCTAssertLessThan(distance, 0.1)
    }

    func testGhostRecording() {
        let recorder = GhostRecordingSystem()
        let courseID = UUID()

        // Record movement
        recorder.startRecording(courseID: courseID)

        for i in 0..<100 {
            let position = SIMD3<Float>(Float(i) * 0.1, 0, 0)
            recorder.recordFrame(position: position, rotation: simd_quatf())
        }

        let recording = recorder.stopRecording()

        XCTAssertEqual(recording.samples.count, 100)
        XCTAssertEqual(recording.courseID, courseID)
    }
}
```

---

## 9. Build and Deployment

### 9.1 Build Configuration

```ruby
# Xcodebuild settings
platform :visionos, '2.0'

target 'ParkourPathways' do
  use_frameworks!

  # Swift settings
  config.build_settings['SWIFT_VERSION'] = '6.0'
  config.build_settings['SWIFT_STRICT_CONCURRENCY'] = 'complete'
  config.build_settings['ENABLE_BITCODE'] = 'NO'

  # Optimization
  config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-O'
  config.build_settings['GCC_OPTIMIZATION_LEVEL'] = '3'

  # Code signing
  config.build_settings['CODE_SIGN_STYLE'] = 'Automatic'
  config.build_settings['DEVELOPMENT_TEAM'] = 'YOUR_TEAM_ID'
end
```

### 9.2 App Store Configuration

```yaml
app_store_metadata:
  app_name: "Parkour Pathways"
  bundle_id: "com.yourcompany.parkourpathways"
  version: "1.0.0"

  categories:
    primary: "Games"
    secondary: "Health & Fitness"

  requirements:
    minimum_visionos: "2.0"
    required_capabilities:
      - com.apple.visionOS
      - com.apple.arkit.hand-tracking
      - com.apple.arkit.world-tracking
      - com.apple.arkit.scene-reconstruction

  privacy:
    camera_usage: "Used for hand and body tracking"
    motion_usage: "Used for movement analysis"
    healthkit_usage: "Used to track fitness metrics"

  age_rating: "9+"
```

---

## 10. Quality Assurance Checklist

```yaml
qa_checklist:
  performance:
    - [ ] Maintains 90 FPS in all gameplay scenarios
    - [ ] Memory usage stays under 2GB
    - [ ] No memory leaks during extended play
    - [ ] Battery drain within acceptable limits
    - [ ] Thermal performance acceptable

  gameplay:
    - [ ] All movement mechanics feel responsive
    - [ ] Course generation produces valid courses
    - [ ] Difficulty scaling works correctly
    - [ ] Scoring system accurate and fair
    - [ ] Tutorial clear and effective

  spatial:
    - [ ] Room scanning reliable in various conditions
    - [ ] Obstacle placement always safe
    - [ ] Hand tracking accurate and responsive
    - [ ] Eye tracking smooth and natural
    - [ ] Spatial audio positioned correctly

  safety:
    - [ ] Boundary detection always active
    - [ ] Collision prevention effective
    - [ ] Emergency stop immediate and reliable
    - [ ] Warning system clear and timely
    - [ ] No unsafe course configurations

  multiplayer:
    - [ ] SharePlay connection reliable
    - [ ] Synchronization smooth and accurate
    - [ ] Leaderboards update correctly
    - [ ] Ghost replay accurate

  compatibility:
    - [ ] Works in various room sizes
    - [ ] Handles different lighting conditions
    - [ ] Supports all input methods
    - [ ] Graceful degradation on lower performance

  accessibility:
    - [ ] VoiceOver support complete
    - [ ] Adjustable difficulty levels
    - [ ] Alternative control schemes available
    - [ ] Visual and audio accessibility options
```

---

## Conclusion

This technical specification provides comprehensive implementation details for Parkour Pathways. All systems are designed to work together to deliver a safe, performant, and engaging spatial gaming experience that pushes the boundaries of what's possible on visionOS.

**Key Technical Achievements:**
- 90 FPS performance target with comprehensive frame budget
- Advanced AI for course generation and movement analysis
- Multi-modal input supporting hands, eyes, voice, and controllers
- Robust physics simulation with safety-first design
- Scalable multiplayer architecture with SharePlay
- Comprehensive testing strategy ensuring quality

The specification balances technical ambition with practical implementation considerations, ensuring the game can be built, tested, and deployed successfully.
