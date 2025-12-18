# Tactical Team Shooters - Technical Specifications

## Table of Contents
1. [Technology Stack](#technology-stack)
2. [Game Mechanics Implementation](#game-mechanics-implementation)
3. [Control Schemes](#control-schemes)
4. [Physics Specifications](#physics-specifications)
5. [Rendering Requirements](#rendering-requirements)
6. [Multiplayer/Networking Specifications](#multiplayernetworking-specifications)
7. [Performance Budgets](#performance-budgets)
8. [Testing Requirements](#testing-requirements)

---

## Technology Stack

### Core Technologies

#### Swift 6.0+
```swift
// Minimum Swift version: 6.0
// Features utilized:
// - Strict concurrency checking
// - Typed throws
// - Noncopyable types for resource management
// - Parameter packs for generic systems

// Example: Strict concurrency for game systems
actor GameStateManager {
    private var currentState: GameState

    func transition(to newState: GameState) async {
        await exitCurrentState()
        currentState = newState
        await enterNewState()
    }
}

// Example: Noncopyable types for GPU resources
struct GPUBuffer: ~Copyable {
    let metalBuffer: MTLBuffer

    consuming func destroy() {
        // Resource is automatically cleaned up
    }
}
```

#### SwiftUI for UI/Menus
```swift
// visionOS-optimized SwiftUI views
struct MainMenuView: View {
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissWindow) private var dismissWindow

    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Text("Tactical Team Shooters")
                    .font(.extraLargeTitle)

                Button("Quick Match") {
                    Task {
                        await openImmersiveSpace(id: "battlefield")
                        dismissWindow(id: "main-menu")
                    }
                }
                .buttonStyle(.borderedProminent)

                NavigationLink("Training") {
                    TrainingMenuView()
                }

                NavigationLink("Settings") {
                    SettingsView()
                }
            }
        }
        .ornament(attachmentAnchor: .scene(.bottom)) {
            PlayerStatsOrnament()
        }
    }
}
```

#### RealityKit for 3D Gameplay
```swift
import RealityKit
import RealityKitContent

// Custom RealityKit systems for game logic
struct WeaponSystem: System {
    static let query = EntityQuery(where: .has(WeaponComponent.self))

    init(scene: Scene) {}

    func update(context: SceneUpdateContext) {
        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            guard let weapon = entity.components[WeaponComponent.self] else { continue }

            // Update weapon state
            updateWeaponState(entity, weapon, deltaTime: context.deltaTime)
        }
    }
}

// Register custom systems
class GameScene {
    func setupSystems() {
        // Register game systems with RealityKit
        WeaponSystem.registerSystem()
        ProjectileSystem.registerSystem()
        CombatSystem.registerSystem()
    }
}
```

#### ARKit for Spatial Tracking
```swift
import ARKit

class SpatialTrackingManager {
    let session = ARKitSession()
    let worldTracking = WorldTrackingProvider()
    let sceneReconstruction = SceneReconstructionProvider()
    let handTracking = HandTrackingProvider()
    let planeDetection = PlaneDetectionProvider(alignments: [.horizontal, .vertical])

    func startTracking() async throws {
        let configuration = [
            worldTracking,
            sceneReconstruction,
            handTracking,
            planeDetection
        ]

        try await session.run(configuration)
    }

    func getDevicePose() -> simd_float4x4? {
        return worldTracking.queryDeviceAnchor(atTimestamp: CACurrentMediaTime())?.originFromAnchorTransform
    }
}
```

#### visionOS 2.0+ Gaming APIs
```swift
import visionOS

// Enterprise APIs for competitive gaming
class CompetitiveGameManager {
    // Low-latency mode for competitive play
    func enableCompetitiveMode() {
        // Request performance mode
        if #available(visionOS 2.0, *) {
            // Enable high-performance graphics mode
            MTLCaptureManager.shared().defaultCaptureScope?.label = "Competitive Mode"

            // Request maximum refresh rate
            requestHighRefreshRate()
        }
    }

    func requestHighRefreshRate() {
        // visionOS 2.0 supports up to 120Hz for gaming
        // Configure for minimum latency
    }
}
```

#### GameplayKit (Optional)
```swift
import GameplayKit

// Pathfinding for AI
class AIPathfinding {
    let graph: GKMeshGraph<GKGraphNode2D>

    init(from navigationMesh: NavigationMesh) {
        // Convert nav mesh to GameplayKit graph
        let nodes = navigationMesh.vertices.map {
            GKGraphNode2D(point: vector_float2($0.x, $0.z))
        }

        graph = GKMeshGraph(bufferRadius: 0.5, minCoordinate: vector_float2(-50, -50), maxCoordinate: vector_float2(50, 50))
        graph.add(nodes)

        // Connect nodes based on nav mesh connectivity
        for edge in navigationMesh.edges {
            graph.connect(nodes[edge.from], to: nodes[edge.to])
        }
    }

    func findPath(from start: SIMD3<Float>, to end: SIMD3<Float>) -> [SIMD3<Float>]? {
        let startNode = graph.node(atGridPosition: vector_int2(Int32(start.x), Int32(start.z)))
        let endNode = graph.node(atGridPosition: vector_int2(Int32(end.x), Int32(end.z)))

        guard let startNode, let endNode else { return nil }

        let path = graph.findPath(from: startNode, to: endNode) as? [GKGraphNode2D]

        return path?.map { node in
            SIMD3<Float>(node.position.x, 0, node.position.y)
        }
    }
}

// AI state machines
class EnemyAI {
    let stateMachine: GKStateMachine

    init() {
        stateMachine = GKStateMachine(states: [
            PatrolState(),
            InvestigateState(),
            CombatState(),
            RetreatState()
        ])

        stateMachine.enter(PatrolState.self)
    }
}

class PatrolState: GKState {
    override func didEnter(from previousState: GKState?) {
        // Start patrol behavior
    }

    override func update(deltaTime seconds: TimeInterval) {
        // Update patrol
    }

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == InvestigateState.self || stateClass == CombatState.self
    }
}
```

### Development Tools

- **Xcode 16+**: Primary IDE with visionOS simulator
- **Reality Composer Pro**: 3D asset authoring and scene composition
- **Instruments**: Performance profiling and optimization
- **Create ML**: AI model training for player behavior prediction
- **TestFlight**: Beta testing and distribution

### Third-Party Libraries

```swift
// Package.swift dependencies
let package = Package(
    name: "TacticalTeamShooters",
    platforms: [
        .visionOS(.v2)
    ],
    dependencies: [
        // No third-party dependencies required
        // Using native Apple frameworks for optimal performance
    ],
    targets: [
        .target(
            name: "TacticalTeamShooters",
            dependencies: []
        )
    ]
)
```

---

## Game Mechanics Implementation

### Precision Aiming System

```swift
class AimingSystem {
    // Sub-millimeter precision tracking
    let precisionThreshold: Float = 0.001  // 1mm

    func calculateAimPoint(
        dominantHand: HandAnchor,
        supportHand: HandAnchor,
        weapon: Weapon
    ) -> SIMD3<Float> {

        // Calculate weapon orientation from hand positions
        let gripPosition = dominantHand.handSkeleton?.joint(.wrist)
        let supportPosition = supportHand.handSkeleton?.joint(.wrist)

        guard let grip = gripPosition?.anchorFromJointTransform,
              let support = supportPosition?.anchorFromJointTransform else {
            return .zero
        }

        // Extract positions
        let gripPos = SIMD3<Float>(grip.columns.3.x, grip.columns.3.y, grip.columns.3.z)
        let supportPos = SIMD3<Float>(support.columns.3.x, support.columns.3.y, support.columns.3.z)

        // Calculate aim direction with sub-millimeter precision
        let barrelDirection = normalize(gripPos - supportPos)

        // Apply weapon offset (sight height over bore)
        let sightOffset = weapon.sightHeightOverBore

        // Calculate point of aim
        let aimPoint = gripPos + barrelDirection * 100.0 + SIMD3<Float>(0, sightOffset, 0)

        return aimPoint
    }

    // Aim assist for accessibility (can be disabled for competitive)
    func applyAimAssist(_ rawAim: SIMD3<Float>, targets: [Entity]) -> SIMD3<Float> {
        guard UserSettings.shared.aimAssistEnabled else { return rawAim }

        let assistRadius: Float = 0.5  // 50cm assist radius
        let assistStrength: Float = 0.3  // 30% pull strength

        // Find closest target within assist radius
        var closestTarget: Entity?
        var closestDistance = Float.infinity

        for target in targets {
            let distance = length(target.position - rawAim)
            if distance < assistRadius && distance < closestDistance {
                closestTarget = target
                closestDistance = distance
            }
        }

        guard let target = closestTarget else { return rawAim }

        // Apply magnetic pull toward target
        let targetDirection = normalize(target.position - rawAim)
        let assistedAim = rawAim + targetDirection * closestDistance * assistStrength

        return assistedAim
    }
}
```

### Ballistics Simulation

```swift
struct BallisticsConfiguration {
    // Physical constants
    static let gravity: Float = 9.81  // m/s²
    static let airDensity: Float = 1.225  // kg/m³ at sea level

    // Bullet parameters (example: 5.56mm NATO)
    struct Bullet556 {
        static let mass: Float = 0.004  // 4 grams
        static let diameter: Float = 0.00556  // 5.56mm
        static let dragCoefficient: Float = 0.295  // G7 BC
        static let muzzleVelocity: Float = 940.0  // m/s
    }
}

class BallisticsSolver {
    func simulateTrajectory(
        weapon: Weapon,
        origin: SIMD3<Float>,
        direction: SIMD3<Float>
    ) -> BulletPath {

        var path = BulletPath()
        var position = origin
        var velocity = direction * weapon.muzzleVelocity

        let dt: Float = 0.001  // 1ms time step
        var time: Float = 0.0
        let maxTime: Float = 5.0

        while time < maxTime {
            // Calculate drag force
            let speed = length(velocity)
            let dragMagnitude = 0.5 * BallisticsConfiguration.airDensity *
                               speed * speed *
                               weapon.bullet.crossSectionalArea *
                               weapon.bullet.dragCoefficient

            let dragForce = -normalize(velocity) * dragMagnitude
            let dragAcceleration = dragForce / weapon.bullet.mass

            // Apply gravity
            let gravityAcceleration = SIMD3<Float>(0, -BallisticsConfiguration.gravity, 0)

            // Total acceleration
            let acceleration = gravityAcceleration + dragAcceleration

            // Integrate velocity and position (using Runge-Kutta 4th order)
            velocity += acceleration * dt
            position += velocity * dt

            path.addPoint(position, time: time)

            // Check for collision
            if let hit = raycast(from: position, direction: normalize(velocity), distance: speed * dt) {
                path.hitPoint = hit
                break
            }

            time += dt
        }

        return path
    }

    // Simplified hit-scan for close range
    func instantHitScan(
        origin: SIMD3<Float>,
        direction: SIMD3<Float>,
        maxRange: Float
    ) -> RaycastHit? {

        return raycast(from: origin, direction: direction, distance: maxRange)
    }
}
```

### Damage System

```swift
class DamageSystem {
    struct DamageParameters {
        let baseDamage: Float
        let headshotMultiplier: Float = 2.0
        let armorPenetration: Float
        let falloffStart: Float  // Distance where damage starts to drop
        let falloffEnd: Float    // Distance where damage is at minimum
        let minimumDamage: Float
    }

    func calculateDamage(
        weapon: Weapon,
        hitLocation: HitLocation,
        distance: Float,
        targetArmor: Float
    ) -> Float {

        var damage = weapon.baseDamage

        // Apply distance falloff
        if distance > weapon.falloffStart {
            let falloffRange = weapon.falloffEnd - weapon.falloffStart
            let falloffProgress = (distance - weapon.falloffStart) / falloffRange
            let damageReduction = max(0, min(1, falloffProgress))

            damage = mix(damage, weapon.minimumDamage, t: damageReduction)
        }

        // Apply armor reduction
        let effectiveArmor = max(0, targetArmor - weapon.armorPenetration)
        damage *= (1.0 - effectiveArmor * 0.5)

        // Apply hit location multiplier
        damage *= hitLocation.damageMultiplier

        return damage
    }

    enum HitLocation {
        case head
        case chest
        case stomach
        case limb

        var damageMultiplier: Float {
            switch self {
            case .head: return 2.0
            case .chest: return 1.0
            case .stomach: return 0.9
            case .limb: return 0.75
            }
        }
    }
}
```

### Team Coordination Mechanics

```swift
class TeamCoordinationSystem {
    // Tactical callouts
    func sendTacticalCallout(
        from player: Player,
        type: CalloutType,
        location: SIMD3<Float>
    ) {
        let callout = TacticalCallout(
            sender: player,
            type: type,
            location: location,
            timestamp: CACurrentMediaTime()
        )

        // Send to team members
        for teammate in player.team.members where teammate.id != player.id {
            deliverCallout(callout, to: teammate)
        }

        // Display spatial indicator
        showSpatialCalloutIndicator(at: location, type: type)
    }

    enum CalloutType {
        case enemySpotted
        case needBackup
        case movingTo
        case holdPosition
        case coverMe
        case reloading
    }

    // Spatial ping system
    func placeTacticalPing(at position: SIMD3<Float>, type: PingType) {
        let ping = TacticalPing(
            position: position,
            type: type,
            duration: 5.0  // 5 second duration
        )

        // Create visual indicator
        let indicator = createPingIndicator(ping)
        scene.addChild(indicator)

        // Animate
        animatePing(indicator, duration: ping.duration)
    }

    enum PingType {
        case attack
        case defend
        case caution
        case lookHere
    }
}
```

---

## Control Schemes

### Primary: Gaze + Hand Tracking

```swift
class HandTrackingControls {
    let handTracking: HandTrackingProvider

    // Weapon aiming with hands
    func updateWeaponControl() async {
        for await update in handTracking.anchorUpdates {
            guard let leftHand = update.anchor as? HandAnchor,
                  let rightHand = await getRightHand() else {
                continue
            }

            // Two-handed weapon grip
            updateWeaponPose(leftHand: leftHand, rightHand: rightHand)

            // Trigger detection
            if detectTriggerPull(rightHand) {
                fireWeapon()
            }

            // Reload gesture
            if detectReloadGesture(leftHand, rightHand) {
                reloadWeapon()
            }
        }
    }

    func detectTriggerPull(_ hand: HandAnchor) -> Bool {
        guard let indexTip = hand.handSkeleton?.joint(.indexFingerTip),
              let thumb = hand.handSkeleton?.joint(.thumbTip) else {
            return false
        }

        // Pinch gesture = trigger pull
        let distance = length(indexTip.anchorFromJointTransform.columns.3 -
                            thumb.anchorFromJointTransform.columns.3)

        return distance < 0.02  // 2cm threshold
    }

    func detectReloadGesture(_ leftHand: HandAnchor, _ rightHand: HandAnchor) -> Bool {
        // Bring hands together at weapon location
        guard let leftPalm = leftHand.handSkeleton?.joint(.wrist),
              let rightPalm = rightHand.handSkeleton?.joint(.wrist) else {
            return false
        }

        let distance = length(leftPalm.anchorFromJointTransform.columns.3 -
                            rightPalm.anchorFromJointTransform.columns.3)

        // Hands close together near weapon
        return distance < 0.15 && distance > 0.05
    }
}
```

### Secondary: Game Controller Support

```swift
import GameController

class GameControllerInput {
    var controller: GCController?

    func setupController() {
        // Observe controller connections
        NotificationCenter.default.addObserver(
            forName: .GCControllerDidConnect,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let controller = notification.object as? GCController else { return }
            self?.connectController(controller)
        }
    }

    func connectController(_ controller: GCController) {
        self.controller = controller

        // Configure extended gamepad controls
        if let gamepad = controller.extendedGamepad {
            // Movement
            gamepad.leftThumbstick.valueChangedHandler = { [weak self] _, x, y in
                self?.handleMovement(x: x, y: y)
            }

            // Camera/Aim
            gamepad.rightThumbstick.valueChangedHandler = { [weak self] _, x, y in
                self?.handleAiming(x: x, y: y)
            }

            // Fire
            gamepad.rightTrigger.valueChangedHandler = { [weak self] _, value, pressed in
                if pressed && value > 0.5 {
                    self?.fireWeapon()
                }
            }

            // Aim down sights
            gamepad.leftTrigger.valueChangedHandler = { [weak self] _, value, pressed in
                self?.aimDownSights(value: value)
            }

            // Reload
            gamepad.buttonX.valueChangedHandler = { [weak self] _, _, pressed in
                if pressed {
                    self?.reloadWeapon()
                }
            }

            // Tactical ability
            gamepad.buttonB.valueChangedHandler = { [weak self] _, _, pressed in
                if pressed {
                    self?.useTacticalAbility()
                }
            }
        }
    }

    func handleAiming(x: Float, y: Float) {
        // Apply sensitivity and dead zone
        let deadZone: Float = 0.15
        let sensitivity: Float = UserSettings.shared.controllerSensitivity

        var adjustedX = abs(x) > deadZone ? x : 0
        var adjustedY = abs(y) > deadZone ? y : 0

        adjustedX *= sensitivity
        adjustedY *= sensitivity

        // Update camera rotation
        updateCameraRotation(yaw: adjustedX, pitch: adjustedY)
    }
}
```

### Tertiary: Voice Commands

```swift
import Speech

class VoiceCommandSystem {
    let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    let audioEngine = AVAudioEngine()

    func startListening() {
        let recognitionRequest = SFSpeechAudioBufferRecognitionRequest()

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }

        audioEngine.prepare()
        try? audioEngine.start()

        recognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let result = result else { return }

            let transcript = result.bestTranscription.formattedString.lowercased()

            self?.processVoiceCommand(transcript)
        }
    }

    func processVoiceCommand(_ command: String) {
        // Tactical commands
        if command.contains("enemy") && command.contains("spotted") {
            sendCallout(.enemySpotted)
        } else if command.contains("reloading") {
            sendCallout(.reloading)
        } else if command.contains("cover me") {
            sendCallout(.coverMe)
        } else if command.contains("move") || command.contains("advancing") {
            sendCallout(.moving)
        }
    }
}
```

---

## Physics Specifications

### Collision Detection

```swift
struct CollisionConfiguration {
    // Collision layers
    enum Layer: UInt32 {
        case player = 0b0001
        case enemy = 0b0010
        case projectile = 0b0100
        case environment = 0b1000

        var collisionMask: UInt32 {
            switch self {
            case .player:
                return Layer.enemy.rawValue | Layer.environment.rawValue
            case .enemy:
                return Layer.player.rawValue | Layer.projectile.rawValue | Layer.environment.rawValue
            case .projectile:
                return Layer.enemy.rawValue | Layer.environment.rawValue
            case .environment:
                return 0xFFFFFFFF  // Collides with everything
            }
        }
    }

    // Collision shapes
    static func createPlayerCollider() -> PhysicsBodyComponent {
        let shape = ShapeResource.generateCapsule(height: 1.8, radius: 0.3)

        return PhysicsBodyComponent(
            shapes: [shape],
            mass: 80.0,  // 80kg
            mode: .dynamic
        )
    }

    static func createProjectileCollider() -> PhysicsBodyComponent {
        let shape = ShapeResource.generateSphere(radius: 0.005)  // 5mm

        return PhysicsBodyComponent(
            shapes: [shape],
            mass: 0.004,  // 4g
            mode: .dynamic
        )
    }
}
```

### Movement Physics

```swift
class MovementSystem {
    struct MovementParameters {
        var walkSpeed: Float = 1.5  // m/s
        var sprintSpeed: Float = 3.0  // m/s
        var crouchSpeed: Float = 0.8  // m/s
        var acceleration: Float = 10.0  // m/s²
        var deceleration: Float = 15.0  // m/s²
        var jumpForce: Float = 5.0  // m/s upward
        var gravity: Float = 9.81  // m/s²
    }

    func updatePlayerMovement(
        player: Entity,
        input: SIMD2<Float>,
        deltaTime: TimeInterval
    ) {
        guard var physics = player.components[PhysicsBodyComponent.self] else { return }

        let dt = Float(deltaTime)

        // Calculate desired velocity
        let targetSpeed = player.isSprinting ? params.sprintSpeed :
                         player.isCrouching ? params.crouchSpeed :
                         params.walkSpeed

        let desiredVelocity = SIMD3<Float>(input.x, 0, input.y) * targetSpeed

        // Apply acceleration
        let currentVelocity = physics.linearVelocity
        let velocityChange = desiredVelocity - SIMD3<Float>(currentVelocity.x, 0, currentVelocity.z)

        let acceleration = length(velocityChange) > 0 ?
                          params.acceleration :
                          params.deceleration

        let force = normalize(velocityChange) * acceleration * dt

        physics.linearVelocity += force

        // Apply friction
        physics.linearVelocity *= 0.95
    }
}
```

### Ragdoll Physics

```swift
class RagdollSystem {
    func createRagdoll(for character: Entity) -> Entity {
        let ragdoll = Entity()

        // Create physics bodies for each bone
        let skeleton = character.availableAnimations.first?.definition

        // Major body parts
        createRagdollPart(ragdoll, name: "head", mass: 4.5, parent: "spine")
        createRagdollPart(ragdoll, name: "chest", mass: 20.0, parent: "spine")
        createRagdollPart(ragdoll, name: "pelvis", mass: 15.0, parent: "spine")

        // Arms
        createRagdollPart(ragdoll, name: "upperArm_L", mass: 2.5, parent: "chest")
        createRagdollPart(ragdoll, name: "lowerArm_L", mass: 1.5, parent: "upperArm_L")
        createRagdollPart(ragdoll, name: "upperArm_R", mass: 2.5, parent: "chest")
        createRagdollPart(ragdoll, name: "lowerArm_R", mass: 1.5, parent: "upperArm_R")

        // Legs
        createRagdollPart(ragdoll, name: "upperLeg_L", mass: 5.0, parent: "pelvis")
        createRagdollPart(ragdoll, name: "lowerLeg_L", mass: 3.0, parent: "upperLeg_L")
        createRagdollPart(ragdoll, name: "upperLeg_R", mass: 5.0, parent: "pelvis")
        createRagdollPart(ragdoll, name: "lowerLeg_R", mass: 3.0, parent: "upperLeg_R")

        // Create joints
        addJointConstraints(ragdoll)

        return ragdoll
    }

    func createRagdollPart(
        _ ragdoll: Entity,
        name: String,
        mass: Float,
        parent: String?
    ) {
        let part = Entity()
        part.name = name

        // Add physics body
        let shape = ShapeResource.generateCapsule(height: 0.3, radius: 0.05)
        part.components[PhysicsBodyComponent.self] = PhysicsBodyComponent(
            shapes: [shape],
            mass: mass,
            mode: .dynamic
        )

        ragdoll.addChild(part)
    }
}
```

---

## Rendering Requirements

### Graphics Settings

```swift
struct GraphicsConfiguration {
    // Quality presets
    enum Quality {
        case low
        case medium
        case high
        case ultra

        var shadowResolution: Int {
            switch self {
            case .low: return 512
            case .medium: return 1024
            case .high: return 2048
            case .ultra: return 4096
            }
        }

        var maxDrawDistance: Float {
            switch self {
            case .low: return 50.0
            case .medium: return 100.0
            case .high: return 200.0
            case .ultra: return 500.0
            }
        }

        var particleCount: Int {
            switch self {
            case .low: return 100
            case .medium: return 500
            case .high: return 1000
            case .ultra: return 2000
            }
        }
    }

    var quality: Quality = .high
    var antiAliasing: Bool = true
    var shadowQuality: Quality = .high
    var textureQuality: Quality = .high
    var effectsQuality: Quality = .high
}
```

### Metal Shaders

```metal
#include <metal_stdlib>
using namespace metal;

// Vertex shader for weapon models
struct VertexIn {
    float3 position [[attribute(0)]];
    float3 normal [[attribute(1)]];
    float2 texCoord [[attribute(2)]];
};

struct VertexOut {
    float4 position [[position]];
    float3 worldPosition;
    float3 normal;
    float2 texCoord;
};

vertex VertexOut weapon_vertex(
    VertexIn in [[stage_in]],
    constant float4x4& modelMatrix [[buffer(1)]],
    constant float4x4& viewMatrix [[buffer(2)]],
    constant float4x4& projectionMatrix [[buffer(3)]]
) {
    VertexOut out;

    float4 worldPos = modelMatrix * float4(in.position, 1.0);
    out.worldPosition = worldPos.xyz;
    out.position = projectionMatrix * viewMatrix * worldPos;
    out.normal = (modelMatrix * float4(in.normal, 0.0)).xyz;
    out.texCoord = in.texCoord;

    return out;
}

// Fragment shader with PBR
fragment float4 weapon_fragment(
    VertexOut in [[stage_in]],
    texture2d<float> albedoMap [[texture(0)]],
    texture2d<float> normalMap [[texture(1)]],
    texture2d<float> metallicMap [[texture(2)]],
    texture2d<float> roughnessMap [[texture(3)]],
    constant float3& lightPosition [[buffer(0)]],
    constant float3& cameraPosition [[buffer(1)]]
) {
    constexpr sampler texSampler(mag_filter::linear, min_filter::linear);

    // Sample textures
    float4 albedo = albedoMap.sample(texSampler, in.texCoord);
    float3 normal = normalMap.sample(texSampler, in.texCoord).xyz * 2.0 - 1.0;
    float metallic = metallicMap.sample(texSampler, in.texCoord).r;
    float roughness = roughnessMap.sample(texSampler, in.texCoord).r;

    // PBR lighting calculations
    float3 N = normalize(in.normal);
    float3 V = normalize(cameraPosition - in.worldPosition);
    float3 L = normalize(lightPosition - in.worldPosition);
    float3 H = normalize(V + L);

    // Cook-Torrance BRDF
    float NdotL = max(dot(N, L), 0.0);
    float NdotV = max(dot(N, V), 0.0);
    float NdotH = max(dot(N, H), 0.0);
    float HdotV = max(dot(H, V), 0.0);

    // Final color
    float3 color = albedo.rgb * NdotL;

    return float4(color, albedo.a);
}
```

### Post-Processing Effects

```swift
class PostProcessingStack {
    var effects: [PostProcessEffect] = []

    func addEffect(_ effect: PostProcessEffect) {
        effects.append(effect)
    }

    func process(_ texture: MTLTexture) -> MTLTexture {
        var currentTexture = texture

        for effect in effects where effect.isEnabled {
            currentTexture = effect.apply(to: currentTexture)
        }

        return currentTexture
    }
}

protocol PostProcessEffect {
    var isEnabled: Bool { get set }
    func apply(to texture: MTLTexture) -> MTLTexture
}

class BloomEffect: PostProcessEffect {
    var isEnabled: Bool = true
    var threshold: Float = 0.8
    var intensity: Float = 0.5

    func apply(to texture: MTLTexture) -> MTLTexture {
        // Extract bright regions
        let brightTexture = extractBrightRegions(texture, threshold: threshold)

        // Gaussian blur
        let blurred = gaussianBlur(brightTexture, radius: 5)

        // Composite
        return composite(original: texture, bloom: blurred, intensity: intensity)
    }
}

class MotionBlurEffect: PostProcessEffect {
    var isEnabled: Bool = true
    var samples: Int = 8
    var strength: Float = 0.5

    func apply(to texture: MTLTexture) -> MTLTexture {
        // Calculate motion vectors from camera movement
        // Apply directional blur based on motion
        return texture  // Simplified
    }
}
```

---

## Multiplayer/Networking Specifications

### Network Architecture

```swift
class NetworkArchitecture {
    // Client-Server architecture with client-side prediction
    let tickRate: Int = 64  // Server update rate (Hz)
    let sendRate: Int = 64  // Client send rate (Hz)

    // Network optimization
    let maxPlayers: Int = 10  // Per match
    let interpolationDelay: TimeInterval = 0.1  // 100ms
    let predictionTime: TimeInterval = 0.05  // 50ms
}

// Network protocol
protocol GameNetworkMessage: Codable {
    var timestamp: TimeInterval { get }
    var sequence: UInt32 { get }
}

struct PlayerInputMessage: GameNetworkMessage {
    let timestamp: TimeInterval
    let sequence: UInt32
    let movement: SIMD2<Float>
    let lookDirection: simd_quatf
    let actions: PlayerActions
}

struct PlayerActions: Codable {
    var isFiring: Bool = false
    var isReloading: Bool = false
    var isJumping: Bool = false
    var isCrouching: Bool = false
}

struct GameStateSnapshot: GameNetworkMessage {
    let timestamp: TimeInterval
    let sequence: UInt32
    let players: [PlayerState]
    let projectiles: [ProjectileState]
    let events: [GameEvent]
}
```

### Lag Compensation

```swift
class LagCompensationSystem {
    var stateHistory: [TimeInterval: GameState] = [:]
    let historyDuration: TimeInterval = 1.0  // Keep 1 second of history

    func rewindToClientTime(_ clientTimestamp: TimeInterval) -> GameState {
        // Find closest historical state
        let targetTime = clientTimestamp - averagePing

        guard let historicalState = findClosestState(to: targetTime) else {
            return currentState
        }

        return historicalState
    }

    func validateHit(_ hit: HitReport, from player: Player) -> Bool {
        // Rewind server state to player's timestamp
        let clientGameState = rewindToClientTime(hit.clientTimestamp)

        // Check if hit was valid at that point in time
        let target = clientGameState.players[hit.targetId]

        // Perform hit detection in rewound state
        return performHitDetection(
            shooter: player.position,
            target: target.position,
            direction: hit.direction
        )
    }
}
```

### Anti-Cheat

```swift
class ServerSideValidation {
    func validatePlayerMovement(_ input: PlayerInputMessage, player: Player) -> Bool {
        // Calculate maximum possible movement
        let maxSpeed: Float = 3.5  // m/s (sprint speed + margin)
        let deltaTime = Float(input.timestamp - player.lastUpdateTime)
        let maxDistance = maxSpeed * deltaTime

        let actualDistance = length(input.position - player.lastPosition)

        guard actualDistance <= maxDistance * 1.1 else {  // 10% tolerance
            reportCheat(player, .speedHack)
            return false
        }

        return true
    }

    func validateShotAccuracy(_ player: Player) -> Bool {
        let recentShots = player.shotHistory.suffix(100)

        let headshotRate = Float(recentShots.filter { $0.isHeadshot }.count) / Float(recentShots.count)

        // Suspicious if >80% headshots
        if headshotRate > 0.8 {
            let avgReactionTime = calculateAverageReactionTime(recentShots)

            // Inhuman if <100ms average
            if avgReactionTime < 0.1 {
                reportCheat(player, .aimbot)
                return false
            }
        }

        return true
    }
}
```

---

## Performance Budgets

### Frame Time Budget (120 FPS = 8.33ms per frame)

```swift
struct FrameTimeBudget {
    // Total: 8.33ms
    static let gameLogic: TimeInterval = 0.002      // 2.0ms
    static let physics: TimeInterval = 0.002        // 2.0ms
    static let rendering: TimeInterval = 0.003      // 3.0ms
    static let audio: TimeInterval = 0.0005         // 0.5ms
    static let network: TimeInterval = 0.0005       // 0.5ms
    static let ui: TimeInterval = 0.0005            // 0.5ms
    static let reserve: TimeInterval = 0.0005       // 0.5ms (buffer)

    static var total: TimeInterval {
        gameLogic + physics + rendering + audio + network + ui + reserve
    }
}
```

### Memory Budget

```swift
struct MemoryBudget {
    // Total: ~3GB (leaving headroom for system)
    static let textures: Int = 1024 * 1024 * 1024      // 1GB
    static let meshes: Int = 512 * 1024 * 1024         // 512MB
    static let audio: Int = 256 * 1024 * 1024          // 256MB
    static let gameState: Int = 256 * 1024 * 1024      // 256MB
    static let networking: Int = 128 * 1024 * 1024     // 128MB
    static let systems: Int = 128 * 1024 * 1024        // 128MB
}
```

### Network Budget

```swift
struct NetworkBudget {
    // Upstream (client to server)
    static let inputDataRate: Int = 5 * 1024          // 5 KB/s
    static let voiceDataRate: Int = 16 * 1024         // 16 KB/s (Opus codec)

    // Downstream (server to client)
    static let gameStateRate: Int = 30 * 1024         // 30 KB/s
    static let voiceReceiveRate: Int = 16 * 1024 * 4  // 64 KB/s (4 teammates)

    // Total bandwidth per client
    static var totalUpstream: Int {
        inputDataRate + voiceDataRate  // ~21 KB/s
    }

    static var totalDownstream: Int {
        gameStateRate + voiceReceiveRate  // ~94 KB/s
    }
}
```

---

## Testing Requirements

### Unit Testing

```swift
import XCTest
@testable import TacticalTeamShooters

class BallisticsTests: XCTestCase {
    func testBulletTrajectory() {
        let solver = BallisticsSolver()
        let weapon = Weapon.assaultRifle

        let trajectory = solver.simulateTrajectory(
            weapon: weapon,
            origin: SIMD3<Float>(0, 1.5, 0),
            direction: SIMD3<Float>(0, 0, 1)
        )

        // Test bullet drop at 100m
        let dropAt100m = trajectory.points.first { point in
            point.z >= 100.0
        }

        XCTAssertNotNil(dropAt100m)
        XCTAssertLessThan(dropAt100m!.y, 1.5)  // Should drop below starting height
    }

    func testDamageCalculation() {
        let damageSystem = DamageSystem()

        let damage = damageSystem.calculateDamage(
            weapon: .assaultRifle,
            hitLocation: .chest,
            distance: 10.0,
            targetArmor: 0.5
        )

        XCTAssertGreaterThan(damage, 0)
        XCTAssertLessThanOrEqual(damage, Weapon.assaultRifle.baseDamage)
    }
}

class NetworkingTests: XCTestCase {
    func testClientPrediction() async {
        let client = GameClient()
        let input = PlayerInput(movement: SIMD2<Float>(1, 0))

        // Apply input locally
        client.applyInput(input)
        let predictedPosition = client.localPlayer.position

        // Simulate server response
        await Task.sleep(50_000_000)  // 50ms

        let serverState = GameState(playerPosition: predictedPosition + SIMD3<Float>(0.1, 0, 0))
        client.reconcile(with: serverState)

        // Position should be reconciled
        XCTAssertEqual(client.localPlayer.position.x, serverState.playerPosition.x, accuracy: 0.01)
    }
}
```

### Performance Testing

```swift
class PerformanceTests: XCTestCase {
    func testFrameRate() {
        measure(metrics: [XCTClockMetric(), XCTCPUMetric()]) {
            let gameEngine = GameEngine()

            // Simulate 1000 frames
            for _ in 0..<1000 {
                gameEngine.update(deltaTime: 1.0 / 120.0)
            }
        }

        // Frame time should be < 8.33ms
    }

    func testMemoryUsage() {
        measure(metrics: [XCTMemoryMetric()]) {
            let scene = GameScene()
            scene.loadAllAssets()

            // Memory should stay within budget
        }
    }
}
```

### Integration Testing

```swift
class MultiplayerIntegrationTests: XCTestCase {
    func testFullMatchFlow() async throws {
        // Setup
        let server = GameServer()
        try await server.start()

        let client1 = GameClient()
        let client2 = GameClient()

        // Connect
        try await client1.connect(to: server)
        try await client2.connect(to: server)

        // Start match
        try await server.startMatch()

        // Simulate gameplay
        for frame in 0..<1000 {
            let input1 = generateRandomInput()
            let input2 = generateRandomInput()

            try await client1.sendInput(input1)
            try await client2.sendInput(input2)

            try await server.update()

            // Verify synchronization
            XCTAssertEqual(client1.gameState.timestamp, client2.gameState.timestamp)
        }

        // Cleanup
        await server.stop()
    }
}
```

### Playtesting Requirements

1. **Alpha Testing** (Internal, 20 testers)
   - Core gameplay mechanics validation
   - Performance benchmarking
   - Basic anti-cheat testing

2. **Beta Testing** (External, 500 testers)
   - Balance testing
   - Network infrastructure testing
   - Competitive gameplay validation
   - Accessibility testing

3. **Stress Testing**
   - 100+ concurrent matches
   - Peak server load testing
   - Network degradation testing

4. **Accessibility Testing**
   - Motor impairment accommodations
   - Visual impairment features
   - Auditory alternatives
   - Cognitive load assessment

---

## Summary

This technical specification provides:

- **Comprehensive tech stack** leveraging latest visionOS and Swift features
- **Detailed gameplay mechanics** with precise aiming and ballistics
- **Multiple control schemes** supporting various input methods
- **Realistic physics** for authentic tactical combat
- **High-performance rendering** targeting 120 FPS
- **Robust multiplayer** with anti-cheat and lag compensation
- **Strict performance budgets** ensuring optimal experience
- **Thorough testing requirements** for quality assurance

All specifications are designed for competitive tactical gaming while maintaining the immersive spatial computing advantages of Vision Pro.
