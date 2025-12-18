# Time Machine Adventures - Technical Specification

## Technology Stack

### Core Technologies

#### Swift 6.0+
- **Concurrency**: Async/await for asynchronous operations
- **Actors**: Thread-safe state management
- **Generics**: Type-safe component systems
- **Protocol-Oriented**: Flexible system architecture
- **Value Semantics**: Efficient data structures

```swift
// Example: Actor-based thread-safe game state
actor GameState {
    private var artifacts: [UUID: Artifact] = [:]
    private var discoveries: Set<UUID> = []

    func discoverArtifact(_ artifact: Artifact) async {
        artifacts[artifact.id] = artifact
        discoveries.insert(artifact.id)
    }

    func getDiscoveries() async -> [Artifact] {
        discoveries.compactMap { artifacts[$0] }
    }
}
```

#### SwiftUI for UI/Menus
- **Declarative UI**: Reactive interface design
- **State Management**: @State, @StateObject, @ObservableObject
- **Animations**: Smooth transitions and effects
- **Accessibility**: Built-in VoiceOver support

```swift
struct MainMenuView: View {
    @StateObject var coordinator: GameCoordinator
    @State private var selectedEra: HistoricalEra?

    var body: some View {
        VStack(spacing: 30) {
            Text("Time Machine Adventures")
                .font(.system(size: 48, weight: .bold))

            EraSelectionGrid(eras: coordinator.availableEras, selection: $selectedEra)

            Button("Begin Journey") {
                coordinator.startExploration(era: selectedEra)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
```

#### RealityKit for 3D Gameplay
- **Entity Component System**: Flexible game object architecture
- **Spatial Audio**: 3D positioned sound
- **Physics Simulation**: Realistic object interactions
- **Material System**: PBR rendering
- **Animation**: Skeletal and procedural animation

```swift
// RealityKit entity setup
func createArtifactEntity(artifact: Artifact) -> Entity {
    let entity = Entity()

    // Load 3D model
    if let model = try? await Entity(named: artifact.modelResource) {
        entity.addChild(model)
    }

    // Add components
    entity.components[ArtifactComponent.self] = ArtifactComponent(artifactData: artifact)
    entity.components[InteractiveComponent.self] = InteractiveComponent()

    // Physics
    let physicsBody = PhysicsBodyComponent(
        massProperties: .init(mass: artifact.mass),
        mode: .dynamic
    )
    entity.components[PhysicsBodyComponent.self] = physicsBody

    // Collision
    let collision = CollisionComponent(shapes: [.generateConvex(from: model.model!.mesh)])
    entity.components[CollisionComponent.self] = collision

    return entity
}
```

#### ARKit for Spatial Tracking
- **World Tracking**: 6DoF positioning
- **Plane Detection**: Surface identification
- **Hand Tracking**: Gesture recognition
- **Eye Tracking**: Gaze interaction (privacy-preserving)
- **Room Mapping**: Spatial mesh generation

```swift
class ARSessionManager {
    let session = ARKitSession()
    let worldTracking = WorldTrackingProvider()
    let planeDetection = PlaneDetectionProvider(alignments: [.horizontal, .vertical])
    let handTracking = HandTrackingProvider()

    func start() async throws {
        try await session.run([worldTracking, planeDetection, handTracking])
    }
}
```

#### visionOS 2.0+ Gaming APIs
- **Immersive Spaces**: Full environment control
- **Windows & Volumes**: Multi-mode presentation
- **Spatial Input**: Hand, eye, and voice
- **SharePlay**: Multiplayer experiences
- **App Intents**: Siri integration

### Optional Frameworks

#### GameplayKit
- **State Machines**: Character behavior
- **Pathfinding**: NPC navigation
- **Random Sources**: Procedural generation
- **Rule Systems**: AI decision making

```swift
class CharacterBehaviorStateMachine {
    let stateMachine: GKStateMachine

    init() {
        let idle = IdleState()
        let teaching = TeachingState()
        let conversing = ConversingState()
        let demonstrating = DemonstratingState()

        stateMachine = GKStateMachine(states: [idle, teaching, conversing, demonstrating])
        stateMachine.enter(IdleState.self)
    }
}
```

#### AVFoundation
- **Spatial Audio**: 3D audio rendering
- **Audio Engine**: Custom audio processing
- **Speech Synthesis**: Character voices
- **Speech Recognition**: Voice commands

#### CoreML
- **Learning Analytics**: Student behavior prediction
- **Difficulty Adjustment**: Adaptive challenge
- **Content Recommendation**: Personalized learning paths

## Game Mechanics Implementation

### Historical Environment Transformation

#### Room Scanning and Calibration

```swift
class RoomCalibrationFlow {
    private let arSession: ARKitSession
    private let sceneReconstruction = SceneReconstructionProvider()

    func calibrate() async throws -> RoomModel {
        // Request permissions
        let permissions: [ARKitSession.Permission] = [
            .worldSensing,
            .handTracking
        ]
        let results = await arSession.requestAuthorization(for: Set(permissions))

        guard results.allSatisfy({ $0.value == .allowed }) else {
            throw CalibrationError.permissionDenied
        }

        // Start scene reconstruction
        try await arSession.run([sceneReconstruction])

        // Scan for 10 seconds
        try await Task.sleep(for: .seconds(10))

        // Process mesh data
        let meshAnchors = sceneReconstruction.meshAnchors
        let roomModel = processRoomMesh(meshAnchors)

        return roomModel
    }

    private func processRoomMesh(_ anchors: [MeshAnchor]) -> RoomModel {
        var surfaces: [Surface] = []
        var bounds: SIMD3<Float> = .zero

        for anchor in anchors {
            // Identify floor, walls, ceiling
            let classification = classifySurface(anchor)
            surfaces.append(Surface(
                type: classification,
                geometry: anchor.geometry,
                transform: anchor.transform
            ))

            // Calculate room bounds
            bounds = max(bounds, anchor.bounds.max)
        }

        return RoomModel(surfaces: surfaces, bounds: bounds)
    }
}
```

#### Environment Overlay System

```swift
class EnvironmentTransformationSystem {
    private var rootEntity: Entity
    private var currentEra: HistoricalEra?
    private var overlayEntities: [Entity] = []

    func transformRoom(to era: HistoricalEra, room: RoomModel) async {
        // Clear previous era
        clearCurrentEnvironment()

        // Load era assets
        let assets = try await loadEraAssets(era)

        // Create wall overlays
        for wall in room.surfaces.filter({ $0.type == .wall }) {
            let overlay = createWallOverlay(wall: wall, era: era, assets: assets)
            overlayEntities.append(overlay)
            rootEntity.addChild(overlay)
        }

        // Create floor overlay
        if let floor = room.surfaces.first(where: { $0.type == .floor }) {
            let floorOverlay = createFloorOverlay(floor: floor, era: era, assets: assets)
            overlayEntities.append(floorOverlay)
            rootEntity.addChild(floorOverlay)
        }

        // Add atmospheric effects
        addAtmosphericEffects(era: era)

        // Position historical elements
        placeHistoricalElements(era: era, room: room)

        currentEra = era
    }

    private func createWallOverlay(wall: Surface, era: HistoricalEra, assets: EraAssets) -> Entity {
        let entity = Entity()

        // Create material based on era
        var material = PhysicallyBasedMaterial()
        material.baseColor = .init(tint: .white, texture: .init(assets.wallTexture))
        material.normal = .init(texture: .init(assets.wallNormalMap))
        material.roughness = .init(floatLiteral: 0.8)

        // Apply to mesh matching wall geometry
        let mesh = MeshResource.generatePlane(
            width: wall.bounds.width,
            height: wall.bounds.height
        )

        entity.components[ModelComponent.self] = ModelComponent(
            mesh: mesh,
            materials: [material]
        )

        entity.transform = Transform(matrix: wall.transform)

        return entity
    }
}
```

### Artifact Discovery and Examination

#### Artifact Placement Algorithm

```swift
class ArtifactPlacementSystem {
    func placeArtifacts(era: HistoricalEra, room: RoomModel) -> [PlacedArtifact] {
        var placements: [PlacedArtifact] = []

        let availableSurfaces = identifyArtifactSurfaces(room: room)
        let artifactsToPlace = selectArtifacts(era: era, count: calculateArtifactCount(room: room))

        for (artifact, surface) in zip(artifactsToPlace, availableSurfaces) {
            let position = calculatePlacementPosition(surface: surface, artifact: artifact)
            let rotation = randomRotation()

            placements.append(PlacedArtifact(
                artifact: artifact,
                position: position,
                rotation: rotation,
                surface: surface,
                isHidden: shouldBeHidden(artifact)
            ))
        }

        return placements
    }

    private func identifyArtifactSurfaces(room: RoomModel) -> [Surface] {
        // Find horizontal surfaces (tables, desks, floor)
        let horizontalSurfaces = room.surfaces.filter { surface in
            let normal = surface.normal
            return abs(normal.y) > 0.9 && surface.bounds.area > 0.1
        }

        // Sort by accessibility and visibility
        return horizontalSurfaces.sorted { s1, s2 in
            let score1 = calculateSurfaceScore(s1, room: room)
            let score2 = calculateSurfaceScore(s2, room: room)
            return score1 > score2
        }
    }

    private func calculateArtifactCount(room: RoomModel) -> Int {
        // Base count on room size
        let area = room.bounds.x * room.bounds.z
        let baseCount = Int(area / 2.0) // One artifact per 2 square meters

        return max(3, min(baseCount, 15)) // Between 3 and 15 artifacts
    }
}
```

#### Detailed Examination Mode

```swift
class ArtifactExaminationView {
    private var artifactEntity: Entity
    private var examinationVolume: Entity
    private var rotationGesture: RotationGesture3D
    private var zoomGesture: MagnificationGesture

    func enterExaminationMode(artifact: Artifact) async {
        // Create dedicated volume for examination
        examinationVolume = Entity()

        // Load high-detail version of artifact
        let detailedModel = try await loadDetailedModel(artifact)
        artifactEntity = detailedModel

        // Position in front of user
        let headPose = await getHeadPose()
        let examinePosition = headPose.position + headPose.forward * 0.5

        artifactEntity.position = examinePosition
        examinationVolume.addChild(artifactEntity)

        // Add interactive components
        setupExaminationControls()

        // Display information overlays
        showArtifactInformation(artifact)

        // Enable gestures
        enableExaminationGestures()
    }

    private func setupExaminationControls() {
        // Rotation
        rotationGesture = RotationGesture3D { value in
            self.artifactEntity.orientation *= simd_quatf(angle: value.rotation, axis: [0, 1, 0])
        }

        // Zoom
        zoomGesture = MagnificationGesture { value in
            let scale = Float(value.magnification)
            self.artifactEntity.scale = SIMD3<Float>(repeating: scale)
        }

        // Hotspot annotations
        addInteractiveHotspots()
    }

    private func addInteractiveHotspots() {
        for hotspot in artifact.interactionPoints {
            let marker = createHotspotMarker(hotspot)
            marker.components[HoverEffectComponent.self] = HoverEffectComponent()

            marker.components[InputTargetComponent.self] = InputTargetComponent()

            artifactEntity.addChild(marker)
        }
    }
}
```

### AI-Powered Historical Characters

#### LLM Integration

```swift
class HistoricalCharacterAI {
    private let llmService: LLMService
    private var conversationHistory: [ConversationMessage] = []
    private let character: HistoricalCharacter

    init(character: HistoricalCharacter) {
        self.character = character
        self.llmService = LLMService()
    }

    func respond(to input: String, context: ConversationContext) async -> String {
        // Build prompt with character personality and knowledge
        let systemPrompt = buildSystemPrompt()
        let userMessage = buildUserMessage(input, context: context)

        // Add to history
        conversationHistory.append(ConversationMessage(role: .user, content: input))

        // Generate response
        let response = try await llmService.complete(
            system: systemPrompt,
            messages: conversationHistory,
            parameters: LLMParameters(
                temperature: character.personalityTraits.contains(.formal) ? 0.7 : 0.9,
                maxTokens: 200
            )
        )

        // Filter for historical accuracy
        let filteredResponse = ensureHistoricalAccuracy(response)

        // Adapt to student age
        let adaptedResponse = adaptToEducationLevel(filteredResponse, level: context.studentLevel)

        conversationHistory.append(ConversationMessage(role: .assistant, content: adaptedResponse))

        return adaptedResponse
    }

    private func buildSystemPrompt() -> String {
        """
        You are \(character.name), a historical figure from \(character.era.name).

        Personality traits: \(character.personalityTraits.map(\.rawValue).joined(separator: ", "))

        Knowledge domains: \(character.knowledgeDomains.joined(separator: ", "))

        Teaching style: \(character.teachingStyle.description)

        You must:
        - Speak in a manner consistent with your historical period
        - Only discuss topics within your historical knowledge
        - Adapt your language to the student's age and education level
        - Encourage curiosity and critical thinking
        - Correct misconceptions gently
        - Never break character or reference modern events beyond your time

        Current context: The student is exploring \(character.era.name) and learning about \(character.era.civilization).
        """
    }

    private func ensureHistoricalAccuracy(_ response: String) -> String {
        // Check for anachronisms
        let anachronismDetector = AnachronismDetector()
        if let anachronism = anachronismDetector.detect(in: response, era: character.era) {
            // Regenerate without anachronism
            return regenerateWithoutAnachronism(anachronism)
        }

        return response
    }

    private func adaptToEducationLevel(_ response: String, level: EducationLevel) -> String {
        switch level {
        case .elementary:
            return simplifyLanguage(response, gradeLevel: 3-5)
        case .middle:
            return simplifyLanguage(response, gradeLevel: 6-8)
        case .high:
            return response // Keep original complexity
        case .adult:
            return enhanceComplexity(response)
        }
    }
}
```

#### Character Animation and Behavior

```swift
class CharacterAnimationController {
    private var characterEntity: Entity
    private var animationController: AnimationPlaybackController?

    func playAnimation(_ animation: CharacterAnimation, blendDuration: TimeInterval = 0.3) {
        guard let availableAnimations = characterEntity.availableAnimations else { return }

        let animationResource = availableAnimations.first { $0.name == animation.rawValue }

        if let resource = animationResource {
            // Stop current animation
            if let current = animationController {
                current.stop(blendOutDuration: blendDuration)
            }

            // Play new animation
            animationController = characterEntity.playAnimation(
                resource,
                transitionDuration: blendDuration,
                startsPaused: false
            )
        }
    }

    func updateBehavior(state: CharacterBehaviorState, playerPosition: SIMD3<Float>) {
        switch state {
        case .idle:
            playAnimation(.idle)
            // Look around occasionally
            performIdleBehaviors()

        case .teaching:
            playAnimation(.gesturing)
            // Face student
            lookAt(position: playerPosition)

        case .conversing:
            playAnimation(.talking)
            // Maintain eye contact
            maintainEyeContact(playerPosition: playerPosition)

        case .demonstrating:
            playAnimation(.demonstrating)
            // Interact with virtual objects
            interactWithDemonstrationProps()
        }
    }

    private func lookAt(position: SIMD3<Float>) {
        let direction = normalize(position - characterEntity.position)
        let targetRotation = simd_quatf(from: [0, 0, -1], to: direction)

        // Smooth rotation
        let currentRotation = characterEntity.orientation
        let interpolated = simd_slerp(currentRotation, targetRotation, 0.1)

        characterEntity.orientation = interpolated
    }
}
```

## Control Schemes

### Gesture-Based Controls

```swift
class GestureRecognitionSystem {
    private let handTracking: HandTrackingProvider

    // Pinch Gesture
    func detectPinch() -> PinchGesture? {
        guard let hands = handTracking.latestHandTracking else { return nil }

        for (chirality, hand) in [(HandAnchor.Chirality.left, hands.left), (.right, hands.right)] {
            guard let hand = hand else { continue }

            let thumbTip = hand.handSkeleton?.joint(.thumbTip)
            let indexTip = hand.handSkeleton?.joint(.indexFingerTip)

            guard let thumbPos = thumbTip?.anchorFromJointTransform.position,
                  let indexPos = indexTip?.anchorFromJointTransform.position else {
                continue
            }

            let distance = simd_distance(thumbPos, indexPos)

            if distance < 0.02 { // 2cm threshold
                return PinchGesture(
                    chirality: chirality,
                    position: (thumbPos + indexPos) / 2,
                    strength: 1.0 - (distance / 0.02)
                )
            }
        }

        return nil
    }

    // Grab Gesture (full hand close)
    func detectGrab() -> GrabGesture? {
        guard let hands = handTracking.latestHandTracking else { return nil }

        for (chirality, hand) in [(HandAnchor.Chirality.left, hands.left), (.right, hands.right)] {
            guard let hand = hand,
                  let skeleton = hand.handSkeleton else {
                continue
            }

            // Check if all fingers are curled
            let fingersCurled = checkFingersCurled(skeleton)

            if fingersCurled {
                let palmCenter = skeleton.joint(.wrist).anchorFromJointTransform.position

                return GrabGesture(
                    chirality: chirality,
                    position: palmCenter,
                    strength: 1.0
                )
            }
        }

        return nil
    }

    // Point Gesture
    func detectPoint() -> PointGesture? {
        guard let hands = handTracking.latestHandTracking else { return nil }

        for (chirality, hand) in [(HandAnchor.Chirality.left, hands.left), (.right, hands.right)] {
            guard let hand = hand,
                  let skeleton = hand.handSkeleton else {
                continue
            }

            // Index finger extended, others curled
            let indexExtended = isFingerExtended(skeleton, finger: .indexFinger)
            let othersCurled = isFingerCurled(skeleton, finger: .middleFinger) &&
                               isFingerCurled(skeleton, finger: .ringFinger) &&
                               isFingerCurled(skeleton, finger: .littleFinger)

            if indexExtended && othersCurled {
                let indexTip = skeleton.joint(.indexFingerTip).anchorFromJointTransform.position
                let indexBase = skeleton.joint(.indexFingerMetacarpal).anchorFromJointTransform.position
                let direction = normalize(indexTip - indexBase)

                return PointGesture(
                    chirality: chirality,
                    origin: indexBase,
                    direction: direction
                )
            }
        }

        return nil
    }
}
```

### Gaze-Based Interaction

```swift
class GazeInteractionSystem {
    private var currentGazeTarget: Entity?
    private var gazeStartTime: Date?
    private let gazeThreshold: TimeInterval = 0.5 // 500ms dwell time

    func update(deltaTime: TimeInterval) {
        guard let gazeOrigin = getEyeGazeOrigin(),
              let gazeDirection = getEyeGazeDirection() else {
            resetGaze()
            return
        }

        // Raycast to find gaze target
        let ray = Ray(origin: gazeOrigin, direction: gazeDirection)
        let hits = scene.raycast(from: ray.origin, to: ray.direction)

        if let hit = hits.first {
            let entity = hit.entity

            // Check if entity is interactive
            if entity.components.has(InteractiveComponent.self) {
                handleGazeOn(entity: entity)
            } else {
                resetGaze()
            }
        } else {
            resetGaze()
        }
    }

    private func handleGazeOn(entity: Entity) {
        if currentGazeTarget != entity {
            // New gaze target
            currentGazeTarget?.components[InteractiveComponent.self]?.hoverState = .none
            currentGazeTarget = entity
            gazeStartTime = Date()

            entity.components[InteractiveComponent.self]?.hoverState = .hovering
        } else if let startTime = gazeStartTime {
            // Continued gaze
            let gazeDuration = Date().timeIntervalSince(startTime)

            if gazeDuration >= gazeThreshold {
                // Activate interaction
                activateEntity(entity)
                resetGaze()
            }
        }
    }

    private func activateEntity(_ entity: Entity) {
        // Trigger appropriate action based on entity type
        if entity.components.has(ArtifactComponent.self) {
            examineArtifact(entity)
        } else if entity.components.has(CharacterComponent.self) {
            initiateConversation(entity)
        } else if entity.components.has(UIComponent.self) {
            activateUI(entity)
        }
    }
}
```

### Hand Tracking Controls

```swift
struct HandTrackingControls {
    // Virtual journal writing
    func detectWritingGesture(hand: HandAnchor) -> WritingGesture? {
        guard let skeleton = hand.handSkeleton else { return nil }

        let indexTip = skeleton.joint(.indexFingerTip).anchorFromJointTransform.position
        let thumbTip = skeleton.joint(.thumbTip).anchorFromJointTransform.position

        // Check if holding virtual pen (pinch)
        let isPinching = simd_distance(indexTip, thumbTip) < 0.02

        if isPinching {
            // Track index finger movement for writing
            return WritingGesture(
                position: indexTip,
                pressure: 1.0,
                isPinching: true
            )
        }

        return nil
    }

    // Two-hand artifact manipulation
    func detectTwoHandedGrab(leftHand: HandAnchor?, rightHand: HandAnchor?) -> TwoHandedGesture? {
        guard let left = leftHand,
              let right = rightHand,
              let leftSkeleton = left.handSkeleton,
              let rightSkeleton = right.handSkeleton else {
            return nil
        }

        let leftPinch = detectPinch(skeleton: leftSkeleton)
        let rightPinch = detectPinch(skeleton: rightSkeleton)

        if leftPinch && rightPinch {
            let leftPos = leftSkeleton.joint(.indexFingerTip).anchorFromJointTransform.position
            let rightPos = rightSkeleton.joint(.indexFingerTip).anchorFromJointTransform.position

            let distance = simd_distance(leftPos, rightPos)
            let center = (leftPos + rightPos) / 2

            return TwoHandedGesture(
                leftPosition: leftPos,
                rightPosition: rightPos,
                center: center,
                distance: distance
            )
        }

        return nil
    }
}
```

### Voice Commands

```swift
class VoiceCommandSystem {
    private let speechRecognizer = SFSpeechRecognizer()
    private let audioEngine = AVAudioEngine()

    func startListening() {
        let request = SFSpeechAudioBufferRecognitionRequest()

        speechRecognizer?.recognitionTask(with: request) { result, error in
            guard let result = result else { return }

            let transcript = result.bestTranscription.formattedString

            // Process commands
            self.processVoiceCommand(transcript)
        }

        // Start audio engine
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            request.append(buffer)
        }

        audioEngine.prepare()
        try? audioEngine.start()
    }

    private func processVoiceCommand(_ transcript: String) {
        let command = parseCommand(transcript.lowercased())

        switch command {
        case .navigation(let era):
            coordinator.navigateToEra(era)

        case .information(let subject):
            displayInformation(about: subject)

        case .characterInteraction(let character, let question):
            askCharacter(character, question: question)

        case .objectManipulation(let action, let object):
            manipulateObject(object, action: action)

        case .systemControl(let action):
            handleSystemAction(action)

        default:
            break
        }
    }

    private func parseCommand(_ text: String) -> VoiceCommand {
        // Time travel commands
        if text.contains("take me to") || text.contains("go to") {
            if let era = extractEra(from: text) {
                return .navigation(era)
            }
        }

        // Information requests
        if text.contains("tell me about") || text.contains("what is") {
            let subject = extractSubject(from: text)
            return .information(subject)
        }

        // Character questions
        if text.contains("ask") {
            let (character, question) = extractCharacterQuestion(from: text)
            return .characterInteraction(character, question)
        }

        return .unknown
    }
}
```

### Game Controller Support

```swift
class GameControllerSystem {
    private var connectedControllers: [GCController] = []

    func setupControllers() {
        // Observe controller connections
        NotificationCenter.default.addObserver(
            forName: .GCControllerDidConnect,
            object: nil,
            queue: .main
        ) { notification in
            if let controller = notification.object as? GCController {
                self.configureController(controller)
            }
        }

        // Configure existing controllers
        for controller in GCController.controllers() {
            configureController(controller)
        }
    }

    private func configureController(_ controller: GCController) {
        guard let gamepad = controller.extendedGamepad else { return }

        // Left stick: Movement
        gamepad.leftThumbstick.valueChangedHandler = { stick, x, y in
            self.handleMovement(x: x, y: y)
        }

        // Right stick: Look around
        gamepad.rightThumbstick.valueChangedHandler = { stick, x, y in
            self.handleLook(x: x, y: y)
        }

        // A button: Select/Interact
        gamepad.buttonA.pressedChangedHandler = { button, value, pressed in
            if pressed {
                self.handleInteract()
            }
        }

        // B button: Back/Cancel
        gamepad.buttonB.pressedChangedHandler = { button, value, pressed in
            if pressed {
                self.handleBack()
            }
        }

        // X button: Open journal
        gamepad.buttonX.pressedChangedHandler = { button, value, pressed in
            if pressed {
                self.openJournal()
            }
        }

        // Y button: Timeline
        gamepad.buttonY.pressedChangedHandler = { button, value, pressed in
            if pressed {
                self.openTimeline()
            }
        }

        // Triggers: Zoom
        gamepad.rightTrigger.valueChangedHandler = { trigger, value, pressed in
            self.handleZoom(value)
        }

        connectedControllers.append(controller)
    }
}
```

## Performance Budgets

### Frame Rate Requirements

```swift
struct PerformanceTargets {
    static let targetFPS: Double = 90.0
    static let minimumFPS: Double = 60.0
    static let frameBudgetMS: Double = 1000.0 / targetFPS // ~11.1ms

    static let systemBudgets = [
        "Physics": 2.0,      // 2ms
        "AI": 1.5,           // 1.5ms
        "Rendering": 5.0,    // 5ms
        "Input": 0.5,        // 0.5ms
        "Audio": 1.0,        // 1ms
        "Networking": 0.5,   // 0.5ms
        "UI": 0.6            // 0.6ms
    ]
}
```

### Memory Budgets

```swift
struct MemoryBudgets {
    static let totalMemoryMB: Int = 4096
    static let systemReserveMB: Int = 1024

    static let assetBudgets = [
        "Historical Environments": 1500, // MB
        "Character Models": 500,
        "Artifacts": 800,
        "UI Elements": 300,
        "Audio Assets": 400,
        "AI Systems": 500
    ]

    static var availableMemoryMB: Int {
        totalMemoryMB - systemReserveMB
    }
}
```

### Network Requirements

```swift
struct NetworkRequirements {
    // Multiplayer
    static let maxLatencyMS: Int = 100
    static let idealLatencyMS: Int = 30
    static let tickRate: Int = 30 // Updates per second

    // Content delivery
    static let initialDownloadMB: Int = 850
    static let additionalEraMB: Int = 200
    static let streamingBandwidthMbps: Double = 10.0

    // Bandwidth usage
    static let multiplayerUploadKbps: Double = 50.0
    static let multiplayerDownloadKbps: Double = 150.0
}
```

## Testing Requirements

### Unit Testing

```swift
@testable import TimeMachineAdventures
import XCTest

class ArtifactSystemTests: XCTestCase {
    var artifactSystem: ArtifactInteractionSystem!

    override func setUp() {
        artifactSystem = ArtifactInteractionSystem()
    }

    func testArtifactDiscovery() {
        let artifact = Artifact.mock()
        let discovered = artifactSystem.discoverArtifact(artifact)

        XCTAssertTrue(discovered)
        XCTAssertTrue(artifactSystem.discoveredArtifacts.contains(artifact.id))
    }

    func testArtifactExamination() async throws {
        let artifact = Artifact.mock()
        artifactSystem.discoverArtifact(artifact)

        let details = try await artifactSystem.examineArtifact(artifact)

        XCTAssertNotNil(details)
        XCTAssertEqual(details.historicalContext.count > 0, true)
    }
}
```

### Performance Testing

```swift
class PerformanceTests: XCTestCase {
    func testFrameRate() {
        measure(metrics: [XCTClockMetric(), XCTCPUMetric()]) {
            // Simulate game loop
            for _ in 0..<90 {
                gameCoordinator.update(deltaTime: 1.0/90.0)
            }
        }
    }

    func testMemoryUsage() {
        measure(metrics: [XCTMemoryMetric()]) {
            let era = HistoricalEra.ancientEgypt
            assetManager.loadEra(era)
        }
    }
}
```

### Accessibility Testing

```swift
class AccessibilityTests: XCTestCase {
    func testVoiceOverSupport() {
        let view = MainMenuView()

        XCTAssertTrue(view.isAccessibilityElement)
        XCTAssertNotNil(view.accessibilityLabel)
        XCTAssertNotNil(view.accessibilityHint)
    }

    func testHighContrastMode() {
        let uiConfig = UIConfiguration.highContrast

        XCTAssertGreaterThan(uiConfig.contrastRatio, 7.0) // WCAG AAA
    }
}
```

This technical specification provides comprehensive implementation guidance for Time Machine Adventures, covering all major systems and technologies required to build a performant, educational, and engaging visionOS game.
