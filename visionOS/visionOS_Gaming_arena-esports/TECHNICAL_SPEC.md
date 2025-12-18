# Arena Esports - Technical Specification Document
*Detailed Technical Specifications for visionOS Competitive Gaming*

---

## Document Overview

**Version:** 1.0
**Last Updated:** 2025-11-19
**Status:** Design Phase
**Related Documents:** ARCHITECTURE.md, DESIGN.md, IMPLEMENTATION_PLAN.md

---

## Table of Contents

1. [Technology Stack](#technology-stack)
2. [Game Mechanics Implementation](#game-mechanics-implementation)
3. [Control Schemes](#control-schemes)
4. [Physics Specifications](#physics-specifications)
5. [Rendering Requirements](#rendering-requirements)
6. [Multiplayer Networking](#multiplayer-networking)
7. [Performance Budgets](#performance-budgets)
8. [Testing Requirements](#testing-requirements)
9. [Security & Anti-Cheat](#security--anti-cheat)
10. [Development Tools & Workflow](#development-tools--workflow)

---

## 1. Technology Stack

### Core Technologies

#### Language & Frameworks
```yaml
Swift:
  version: 6.0+
  features:
    - Strict concurrency checking
    - Actor isolation for thread safety
    - Async/await for asynchronous operations
    - Sendable protocol for data race safety
    - Macros for code generation

SwiftUI:
  version: visionOS 2.0+
  components:
    - ImmersiveSpace for full 3D environments
    - Spatial windows for menus and HUD
    - RealityView for RealityKit integration
    - Ornaments for contextual UI
    - Custom gestures and interactions

RealityKit:
  version: 4.0+
  features:
    - Entity-Component-System architecture
    - Metal-based rendering pipeline
    - Physics simulation and collision detection
    - Particle systems and visual effects
    - Spatial audio integration
    - Custom component registration

ARKit:
  version: visionOS 2.0+
  providers:
    - WorldTrackingProvider (ultra-low latency mode)
    - HandTrackingProvider (precision tracking)
    - PlaneDetectionProvider (environment calibration)
    - SceneReconstructionProvider (optional)
```

#### Networking Stack
```yaml
Primary:
  framework: WebRTC
  purpose: Ultra-low latency game state synchronization
  configuration:
    - Unreliable data channels for state sync
    - Reliable channels for critical events
    - ICE for NAT traversal
    - DTLS for encryption

Secondary:
  framework: URLSession + HTTP/2
  purpose: Match making, authentication, analytics
  features:
    - REST API for tournament data
    - WebSocket for lobby chat
    - Server-sent events for notifications

Load Balancing:
  strategy: Geographic routing
  servers:
    - North America (AWS us-west-2)
    - Europe (AWS eu-central-1)
    - Asia Pacific (AWS ap-northeast-1)
```

#### Data Persistence
```yaml
Local Storage:
  framework: SwiftData
  models:
    - PlayerProgress
    - MatchHistory
    - Settings
    - CachedArenaData

Cloud Sync:
  framework: CloudKit
  containers:
    - Public: Leaderboards, tournaments
    - Private: Player data, statistics
    - Shared: Team data, collaborative features

Caching:
  framework: NSCache
  strategy: LRU (Least Recently Used)
  limits:
    memory: 500 MB
    disk: 2 GB
```

#### Audio System
```yaml
Framework: AVFoundation + Spatial Audio
Configuration:
  sample_rate: 48000 Hz
  bit_depth: 24-bit
  channels: Spatial (Ambisonics)
  buffer_size: 256 samples (low latency)

Sources:
  - Background music (compressed AAC)
  - Sound effects (uncompressed PCM for low latency)
  - Voice chat (Opus codec, 48kbps)
  - Spatial positioning (AVAudio3DEngine)

Processing:
  - Reverb for environment simulation
  - Occlusion for realistic sound blocking
  - Distance attenuation (inverse square law)
  - Doppler effect for moving objects
```

#### Analytics & Telemetry
```yaml
Framework: TelemetryDeck + Custom
Metrics:
  Performance:
    - Frame rate (min, avg, max)
    - Frame time distribution
    - Memory usage
    - Network latency
    - CPU/GPU utilization

  Gameplay:
    - Match outcomes
    - Player actions per minute
    - Accuracy statistics
    - Spatial movement patterns
    - Reaction times

  Business:
    - Session duration
    - Retention rates
    - Conversion funnels
    - Revenue per user

Privacy:
  - All data anonymized
  - User consent required
  - Local processing preferred
  - GDPR compliant
```

---

## 2. Game Mechanics Implementation

### Combat System

#### Weapon System
```swift
protocol Weapon: Sendable {
    var type: WeaponType { get }
    var damage: DamageProfile { get }
    var fireRate: TimeInterval { get }
    var accuracy: AccuracyModel { get }
    var recoil: RecoilPattern { get }
    var ammo: AmmoConfig { get }
}

struct DamageProfile: Sendable {
    let baseDamage: Float
    let headShotMultiplier: Float // 2.0x
    let damageDropoff: [(distance: Float, multiplier: Float)]
    let armorPenetration: Float
}

struct AccuracyModel: Sendable {
    let baseSpread: Float // degrees
    let movingSpread: Float
    let jumpingSpread: Float
    let aimingImprovement: Float // 0.5x when aiming
    let consecutiveShotSpread: Float // Increases with rapid fire
}

struct RecoilPattern: Sendable {
    let verticalKick: Float
    let horizontalKick: Float
    let patternSequence: [SIMD2<Float>] // Predictable pattern
    let recoveryTime: TimeInterval
}

struct AmmoConfig: Sendable {
    let magazineSize: Int
    let reserveAmmo: Int
    let reloadTime: TimeInterval
    let tacticalReloadTime: TimeInterval // Faster if ammo remaining
}

// Weapon implementations
enum WeaponType: Sendable {
    case spatialRifle
    case pulseBlaster
    case gravityLauncher
    case energySword
}

struct SpatialRifle: Weapon {
    let type = WeaponType.spatialRifle

    let damage = DamageProfile(
        baseDamage: 25,
        headShotMultiplier: 2.0,
        damageDropoff: [
            (0, 1.0),
            (10, 1.0),
            (30, 0.8),
            (50, 0.5)
        ],
        armorPenetration: 0.7
    )

    let fireRate: TimeInterval = 0.1 // 600 RPM

    let accuracy = AccuracyModel(
        baseSpread: 0.5,
        movingSpread: 2.0,
        jumpingSpread: 5.0,
        aimingImprovement: 0.5,
        consecutiveShotSpread: 0.2
    )

    let recoil = RecoilPattern(
        verticalKick: 2.0,
        horizontalKick: 0.5,
        patternSequence: [
            SIMD2(0, 2.0),
            SIMD2(-0.5, 2.2),
            SIMD2(0.5, 2.4),
            SIMD2(-0.3, 2.1)
        ],
        recoveryTime: 0.3
    )

    let ammo = AmmoConfig(
        magazineSize: 30,
        reserveAmmo: 120,
        reloadTime: 2.5,
        tacticalReloadTime: 2.0
    )
}
```

#### Hit Detection System
```swift
actor HitDetectionSystem {
    struct RaycastHit {
        let entity: UUID
        let position: SIMD3<Float>
        let normal: SIMD3<Float>
        let distance: Float
        let isHeadshot: Bool
    }

    func performHitscan(
        from origin: SIMD3<Float>,
        direction: SIMD3<Float>,
        maxDistance: Float,
        weapon: Weapon
    ) async -> RaycastHit? {
        // Apply weapon spread
        let spread = calculateSpread(weapon: weapon)
        let finalDirection = applySpread(direction, spread: spread)

        // Perform raycast
        let hit = await physicsWorld.raycast(
            from: origin,
            direction: finalDirection,
            maxDistance: maxDistance
        )

        guard let hit = hit else { return nil }

        // Determine if headshot
        let isHeadshot = await isHeadshotHit(hit)

        // Calculate damage
        let damage = calculateDamage(
            weapon: weapon,
            distance: hit.distance,
            isHeadshot: isHeadshot
        )

        // Apply damage to entity
        await applyDamage(damage, to: hit.entity)

        return RaycastHit(
            entity: hit.entity,
            position: hit.position,
            normal: hit.normal,
            distance: hit.distance,
            isHeadshot: isHeadshot
        )
    }

    private func calculateDamage(
        weapon: Weapon,
        distance: Float,
        isHeadshot: Bool
    ) -> Float {
        var damage = weapon.damage.baseDamage

        // Apply distance falloff
        for (threshold, multiplier) in weapon.damage.damageDropoff.sorted(by: { $0.distance > $1.distance }) {
            if distance >= threshold {
                damage *= multiplier
                break
            }
        }

        // Apply headshot multiplier
        if isHeadshot {
            damage *= weapon.damage.headShotMultiplier
        }

        return damage
    }
}
```

### Movement System

```swift
struct MovementConfig {
    // Speeds in meters per second
    let walkSpeed: Float = 4.5
    let sprintSpeed: Float = 6.5
    let crouchSpeed: Float = 2.5
    let strafeSpeedMultiplier: Float = 0.9
    let backwardSpeedMultiplier: Float = 0.8

    // Jump mechanics
    let jumpHeight: Float = 1.2
    let jumpCooldown: TimeInterval = 0.5
    let airControlMultiplier: Float = 0.3

    // Physics
    let acceleration: Float = 20.0
    let deceleration: Float = 15.0
    let friction: Float = 6.0
    let gravity: Float = 20.0

    // Spatial mechanics
    let verticalMovementEnabled: Bool = true
    let maxVerticalVelocity: Float = 10.0
    let sphericalMovement: Bool = true // For 360-degree arenas
}

actor MovementSystem: GameSystem {
    let priority = 950
    let config = MovementConfig()

    func update(deltaTime: TimeInterval, entities: [any Entity]) async {
        for entity in entities {
            guard var physics = entity.components[PhysicsComponent.self],
                  var transform = entity.components[TransformComponent.self],
                  let input = entity.components[InputComponent.self] else {
                continue
            }

            // Calculate desired velocity
            var desiredVelocity = calculateDesiredVelocity(from: input)

            // Apply movement modifiers
            if input.isSprinting {
                desiredVelocity *= config.sprintSpeed / config.walkSpeed
            } else if input.isCrouching {
                desiredVelocity *= config.crouchSpeed / config.walkSpeed
            }

            // Apply acceleration/deceleration
            let acceleration = config.acceleration * Float(deltaTime)
            physics.velocity = lerp(
                physics.velocity,
                desiredVelocity,
                t: min(acceleration, 1.0)
            )

            // Handle jumping
            if input.jumpPressed && await canJump(entity) {
                physics.velocity.y = sqrt(2.0 * config.gravity * config.jumpHeight)
            }

            // Spherical movement for 360-degree arenas
            if config.sphericalMovement {
                applySphericalMovement(&transform, velocity: physics.velocity, deltaTime: deltaTime)
            }

            entity.components[PhysicsComponent.self] = physics
            entity.components[TransformComponent.self] = transform
        }
    }

    private func applySphericalMovement(
        _ transform: inout TransformComponent,
        velocity: SIMD3<Float>,
        deltaTime: TimeInterval
    ) {
        // Convert to spherical coordinates for 360-degree movement
        let speed = length(velocity)
        let direction = normalize(velocity)

        // Update position on sphere surface
        let angularVelocity = speed / arenaRadius
        let rotation = simd_quatf(angle: angularVelocity * Float(deltaTime), axis: cross(transform.position, direction))

        transform.position = rotation.act(transform.position)
        transform.rotation = rotation * transform.rotation
    }
}
```

### Ability System

```swift
protocol Ability: Sendable {
    var name: String { get }
    var cooldown: TimeInterval { get }
    var duration: TimeInterval { get }
    var energyCost: Float { get }

    func activate(on entity: UUID) async throws
    func deactivate(on entity: UUID) async
}

struct DashAbility: Ability {
    let name = "Spatial Dash"
    let cooldown: TimeInterval = 5.0
    let duration: TimeInterval = 0.3
    let energyCost: Float = 25.0

    let dashDistance: Float = 8.0
    let invulnerabilityFrames: Int = 10 // 10 frames of i-frames

    func activate(on entity: UUID) async throws {
        guard let transform = await getComponent(TransformComponent.self, for: entity),
              let physics = await getComponent(PhysicsComponent.self, for: entity) else {
            throw AbilityError.entityNotFound
        }

        // Calculate dash direction (forward from player view)
        let dashDirection = transform.rotation.act(SIMD3<Float>(0, 0, -1))

        // Apply dash velocity
        var newPhysics = physics
        newPhysics.velocity = dashDirection * (dashDistance / Float(duration))
        await setComponent(newPhysics, for: entity)

        // Grant temporary invulnerability
        await grantInvulnerability(to: entity, frames: invulnerabilityFrames)

        // Visual effect
        await spawnDashEffect(at: transform.position, direction: dashDirection)

        // Audio feedback
        await playSound(.dash, at: transform.position)
    }

    func deactivate(on entity: UUID) async {
        // Reset velocity
        guard var physics = await getComponent(PhysicsComponent.self, for: entity) else { return }
        physics.velocity *= 0.3 // Gradual slowdown
        await setComponent(physics, for: entity)
    }
}

struct ShieldAbility: Ability {
    let name = "Energy Shield"
    let cooldown: TimeInterval = 12.0
    let duration: TimeInterval = 3.0
    let energyCost: Float = 40.0

    let damageReduction: Float = 0.75 // 75% damage reduction
    let shieldHealth: Float = 100.0

    func activate(on entity: UUID) async throws {
        // Create shield entity
        let shieldEntity = createShieldEntity()
        await attachShield(shieldEntity, to: entity)

        // Add shield component
        let shield = ShieldComponent(
            entityID: entity,
            health: shieldHealth,
            damageReduction: damageReduction
        )
        await addComponent(shield, to: entity)

        // Visual effect
        await spawnShieldVisual(on: entity)
        await playSound(.shieldActivate, at: await getPosition(entity))
    }

    func deactivate(on entity: UUID) async {
        await removeComponent(ShieldComponent.self, from: entity)
        await destroyShieldVisual(on: entity)
        await playSound(.shieldDeactivate, at: await getPosition(entity))
    }
}
```

---

## 3. Control Schemes

### Hand Tracking Controls

```swift
enum HandGesture: Sendable {
    case point              // Aiming
    case pinch              // Shoot
    case fist               // Grenade/ability
    case openPalm           // Shield
    case thumbsUp           // Team signal
    case peace              // Reload gesture
}

actor HandGestureRecognizer {
    private let minimumConfidence: Float = 0.85

    func recognizeGesture(from handAnchor: HandAnchor) async -> HandGesture? {
        let skeleton = handAnchor.handSkeleton

        // Point gesture (index extended, others curled)
        if isFingerExtended(.indexFinger, skeleton: skeleton) &&
           !isFingerExtended(.middleFinger, skeleton: skeleton) &&
           !isFingerExtended(.ringFinger, skeleton: skeleton) &&
           !isFingerExtended(.littleFinger, skeleton: skeleton) {
            return .point
        }

        // Pinch gesture (thumb and index close together)
        if isPinching(skeleton: skeleton, confidence: minimumConfidence) {
            return .pinch
        }

        // Fist (all fingers curled)
        if isFingersCurled(skeleton: skeleton) {
            return .fist
        }

        // Open palm (all fingers extended)
        if areAllFingersExtended(skeleton: skeleton) {
            return .openPalm
        }

        return nil
    }

    private func isFingerExtended(_ finger: HandSkeleton.JointName, skeleton: HandSkeleton?) -> Bool {
        guard let skeleton = skeleton else { return false }

        // Check if finger tip is far from palm
        let tip = skeleton.joint(finger)
        let palm = skeleton.joint(.wrist)

        let distance = simd_distance(tip.position, palm.position)
        return distance > 0.15 // 15cm threshold
    }

    private func isPinching(skeleton: HandSkeleton?, confidence: Float) -> Bool {
        guard let skeleton = skeleton else { return false }

        let thumbTip = skeleton.joint(.thumbTip)
        let indexTip = skeleton.joint(.indexFingerTip)

        let distance = simd_distance(thumbTip.position, indexTip.position)
        return distance < 0.02 // 2cm threshold
    }
}

// Hand tracking input mapping
struct HandTrackingInput {
    // Right hand (dominant for most players)
    var aimDirection: SIMD3<Float> // From index finger pointing
    var isShooting: Bool // Pinch gesture
    var isReloading: Bool // Peace gesture
    var abilityTrigger: Bool // Fist gesture

    // Left hand
    var movementDirection: SIMD2<Float> // From palm orientation
    var isShielding: Bool // Open palm
    var teamSignal: TeamSignal? // Various gestures
}
```

### Eye Tracking Controls

```swift
actor EyeTrackingSystem {
    private let eyeTrackingProvider = EyeTrackingProvider()
    private var currentTarget: UUID?
    private let targetLockTime: TimeInterval = 0.3 // Dwell time

    func update() async {
        guard let gaze = await getGazeDirection() else { return }

        // Raycast from eyes to find target
        let hit = await performGazeRaycast(direction: gaze)

        if let hitEntity = hit?.entity {
            // Check if looking at same target
            if hitEntity == currentTarget {
                // Lock-on targeting after dwell time
                await updateTargetLockProgress()
            } else {
                currentTarget = hitEntity
                await resetTargetLockProgress()
            }

            // Highlight target for player
            await highlightEntity(hitEntity)
        } else {
            currentTarget = nil
            await clearHighlight()
        }
    }

    private func getGazeDirection() async -> SIMD3<Float>? {
        // Get eye tracking data
        for await update in eyeTrackingProvider.anchorUpdates {
            // Convert eye gaze to world space direction
            return update.lookAtPoint // Simplified
        }
        return nil
    }
}

struct EyeTrackingConfig {
    let enabled: Bool
    let assistAiming: Bool // Subtle aim assist toward gazed targets
    let targetHighlight: Bool
    let autoTargetLock: Bool
    let dwellTime: TimeInterval

    // Privacy
    let dataRetention: DataRetentionPolicy = .sessionOnly
    let requiresExplicitConsent: Bool = true
}
```

### Game Controller Support

```swift
import GameController

actor GameControllerManager {
    private var connectedControllers: [GCController] = []

    func setupControllers() {
        // Detect connected controllers
        NotificationCenter.default.addObserver(
            forName: .GCControllerDidConnect,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let controller = notification.object as? GCController else { return }
            Task { await self?.registerController(controller) }
        }

        // Register existing controllers
        for controller in GCController.controllers() {
            Task { await registerController(controller) }
        }
    }

    private func registerController(_ controller: GCController) {
        connectedControllers.append(controller)

        // Map extended gamepad inputs
        guard let gamepad = controller.extendedGamepad else { return }

        // Movement
        gamepad.leftThumbstick.valueChangedHandler = { [weak self] _, x, y in
            Task { await self?.handleMovement(x: x, y: y) }
        }

        // Camera/Aim
        gamepad.rightThumbstick.valueChangedHandler = { [weak self] _, x, y in
            Task { await self?.handleAiming(x: x, y: y) }
        }

        // Shooting
        gamepad.rightTrigger.valueChangedHandler = { [weak self] _, value, pressed in
            if pressed {
                Task { await self?.handleShoot() }
            }
        }

        // Abilities
        gamepad.buttonA.valueChangedHandler = { [weak self] _, _, pressed in
            if pressed {
                Task { await self?.handleAbility1() }
            }
        }

        gamepad.buttonB.valueChangedHandler = { [weak self] _, _, pressed in
            if pressed {
                Task { await self?.handleAbility2() }
            }
        }

        // Pause
        gamepad.buttonMenu.valueChangedHandler = { [weak self] _, _, pressed in
            if pressed {
                Task { await self?.handlePause() }
            }
        }
    }
}

struct ControllerSensitivity {
    var aimSensitivity: Float = 1.0
    var aimAcceleration: Float = 1.0
    var deadzone: Float = 0.15
    var invertY: Bool = false
}
```

---

## 4. Physics Specifications

### Physics Configuration

```swift
struct PhysicsConfig {
    // World settings
    let gravity: SIMD3<Float> = [0, -9.81, 0]
    let timeStep: TimeInterval = 1.0 / 120.0 // 120Hz physics
    let maxSubSteps: Int = 4

    // Collision layers
    enum CollisionLayer: UInt32 {
        case player = 1
        case projectile = 2
        case environment = 4
        case trigger = 8
        case all = 0xFFFFFFFF
    }

    // Material properties
    struct PhysicsMaterial {
        let friction: Float
        let bounciness: Float
        let density: Float
    }

    static let materials: [String: PhysicsMaterial] = [
        "player": PhysicsMaterial(friction: 0.5, bounciness: 0.0, density: 70.0),
        "ground": PhysicsMaterial(friction: 0.8, bounciness: 0.1, density: 1000.0),
        "wall": PhysicsMaterial(friction: 0.6, bounciness: 0.3, density: 1000.0),
        "projectile": PhysicsMaterial(friction: 0.1, bounciness: 0.8, density: 1.0)
    ]
}

// Collision detection
actor CollisionSystem: GameSystem {
    let priority = 850
    private var spatialGrid: SpatialGrid

    func update(deltaTime: TimeInterval, entities: [any Entity]) async {
        // Broad phase: Spatial partitioning
        spatialGrid.clear()
        for entity in entities {
            guard let transform = entity.components[TransformComponent.self] else { continue }
            spatialGrid.insert(entity: entity.id, at: transform.position)
        }

        // Narrow phase: Precise collision checks
        for entity in entities {
            guard let transform = entity.components[TransformComponent.self],
                  let collision = entity.components[CollisionComponent.self] else {
                continue
            }

            let nearbyEntities = spatialGrid.query(
                near: transform.position,
                radius: collision.bounds.radius
            )

            for otherID in nearbyEntities where otherID != entity.id {
                if let collision = await checkCollision(entity.id, otherID) {
                    await resolveCollision(collision)
                }
            }
        }
    }

    private func checkCollision(_ a: UUID, _ b: UUID) async -> CollisionInfo? {
        // Get collision shapes and transforms
        // Perform shape-specific collision tests
        // Return collision info if colliding
        return nil // Placeholder
    }

    private func resolveCollision(_ collision: CollisionInfo) async {
        // Apply impulse to separate objects
        // Calculate collision response based on materials
        // Trigger collision events
    }
}

struct CollisionInfo {
    let entityA: UUID
    let entityB: UUID
    let point: SIMD3<Float>
    let normal: SIMD3<Float>
    let penetrationDepth: Float
}
```

---

## 5. Rendering Requirements

### Rendering Pipeline

```swift
struct RenderConfig {
    // Performance targets
    let targetFPS: Int = 120
    let minimumFPS: Int = 90

    // Resolution
    let renderScale: Float = 1.0 // Native resolution
    let dynamicResolutionScaling: Bool = true
    let minRenderScale: Float = 0.75

    // Quality settings
    enum QualityPreset {
        case professional
        case competitive
        case practice
    }

    struct QualitySettings {
        let shadowQuality: ShadowQuality
        let particleQuality: ParticleQuality
        let textureQuality: TextureQuality
        let antiAliasing: AntiAliasingMode
        let ambientOcclusion: Bool
        let postProcessing: Bool
    }

    static let qualityPresets: [QualityPreset: QualitySettings] = [
        .professional: QualitySettings(
            shadowQuality: .high,
            particleQuality: .high,
            textureQuality: .high,
            antiAliasing: .temporal,
            ambientOcclusion: true,
            postProcessing: true
        ),
        .competitive: QualitySettings(
            shadowQuality: .medium,
            particleQuality: .medium,
            textureQuality: .high,
            antiAliasing: .fxaa,
            ambientOcclusion: false,
            postProcessing: false
        ),
        .practice: QualitySettings(
            shadowQuality: .low,
            particleQuality: .low,
            textureQuality: .medium,
            antiAliasing: .none,
            ambientOcclusion: false,
            postProcessing: false
        )
    ]
}

// Foveated rendering for performance
struct FoveatedRenderingConfig {
    let enabled: Bool = true
    let innerRadius: Float = 10.0 // degrees
    let outerRadius: Float = 30.0 // degrees
    let qualityDropoff: Float = 0.5 // 50% resolution at edge
}

// Level of Detail (LOD) system
enum LODLevel: Int {
    case high = 0
    case medium = 1
    case low = 2
    case veryLow = 3
}

struct LODConfig {
    let distances: [LODLevel: Float] = [
        .high: 5.0,
        .medium: 15.0,
        .low: 30.0,
        .veryLow: 50.0
    ]

    let meshSimplification: [LODLevel: Float] = [
        .high: 1.0,
        .medium: 0.7,
        .low: 0.4,
        .veryLow: 0.2
    ]
}
```

### Visual Effects

```swift
// Particle systems
struct ParticleEffect {
    let type: EffectType
    let emissionRate: Int // Particles per second
    let lifetime: TimeInterval
    let velocity: SIMD3<Float>
    let color: SIMD4<Float>
    let size: Float

    enum EffectType {
        case muzzleFlash
        case bulletImpact
        case explosion
        case shield
        case dash
        case death
    }
}

// Post-processing effects
struct PostProcessingStack {
    var bloom: BloomEffect?
    var colorGrading: ColorGradingEffect?
    var motionBlur: MotionBlurEffect? // Minimal for competitive
    var depthOfField: DepthOfFieldEffect? // Disabled for competitive
    var vignette: VignetteEffect?
}

struct BloomEffect {
    var intensity: Float = 0.3
    var threshold: Float = 1.0
    var softKnee: Float = 0.5
}
```

---

## 6. Multiplayer Networking

### Network Protocol

```swift
// Message types
enum NetworkPacket: Codable {
    // Connection
    case connect(playerID: UUID, token: String)
    case disconnect(playerID: UUID)

    // Game state
    case stateSnapshot(snapshot: GameStateSnapshot)
    case stateUpdate(delta: GameStateDelta)

    // Player input
    case input(input: PlayerInput, sequenceNumber: UInt64)

    // Events
    case weaponFired(playerID: UUID, weaponID: UUID, timestamp: TimeInterval)
    case hit(shooterID: UUID, targetID: UUID, damage: Float, timestamp: TimeInterval)
    case death(playerID: UUID, killerID: UUID)

    // Match
    case matchStart
    case matchEnd(results: MatchResults)
    case roundStart(roundNumber: Int)
    case roundEnd
}

// Game state snapshot (sent every second)
struct GameStateSnapshot: Codable {
    let timestamp: TimeInterval
    let serverTick: UInt64
    let players: [PlayerSnapshot]
    let projectiles: [ProjectileSnapshot]
}

struct PlayerSnapshot: Codable {
    let id: UUID
    let position: SIMD3<Float>
    let rotation: simd_quatf
    let velocity: SIMD3<Float>
    let health: Float
    let ammo: Int
}

// State delta (sent every frame)
struct GameStateDelta: Codable {
    let baseTick: UInt64
    let currentTick: UInt64
    let changedPlayers: [UUID: PlayerDelta]
}

struct PlayerDelta: Codable {
    let position: SIMD3<Float>?
    let velocity: SIMD3<Float>?
    let health: Float?
}

// Player input
struct PlayerInput: Codable {
    let timestamp: TimeInterval
    let movementDirection: SIMD2<Float>
    let aimDirection: SIMD3<Float>
    let actions: InputActions
}

struct InputActions: OptionSet, Codable {
    let rawValue: UInt16

    static let shoot = InputActions(rawValue: 1 << 0)
    static let jump = InputActions(rawValue: 1 << 1)
    static let reload = InputActions(rawValue: 1 << 2)
    static let ability1 = InputActions(rawValue: 1 << 3)
    static let ability2 = InputActions(rawValue: 1 << 4)
    static let sprint = InputActions(rawValue: 1 << 5)
}
```

### Synchronization Strategy

```swift
actor NetworkSyncSystem {
    // Client-side prediction
    private var inputHistory: [UInt64: PlayerInput] = [:]
    private var sequenceNumber: UInt64 = 0

    // Server reconciliation
    private var lastProcessedTick: UInt64 = 0

    // Interpolation
    private var snapshotBuffer: [GameStateSnapshot] = []
    private let interpolationDelay: TimeInterval = 0.1 // 100ms

    func sendInput(_ input: PlayerInput) async {
        sequenceNumber += 1
        inputHistory[sequenceNumber] = input

        // Send to server
        let packet = NetworkPacket.input(input: input, sequenceNumber: sequenceNumber)
        await networkManager.send(packet)

        // Apply locally (prediction)
        await applyInput(input)
    }

    func receiveSnapshot(_ snapshot: GameStateSnapshot) async {
        snapshotBuffer.append(snapshot)

        // Keep only recent snapshots
        let cutoffTime = snapshot.timestamp - interpolationDelay * 2
        snapshotBuffer.removeAll { $0.timestamp < cutoffTime }

        // Server reconciliation
        if snapshot.serverTick > lastProcessedTick {
            await reconcile(snapshot)
            lastProcessedTick = snapshot.serverTick
        }
    }

    private func reconcile(_ snapshot: GameStateSnapshot) async {
        // Rewind to server state
        await applySnapshot(snapshot)

        // Replay inputs that occurred after snapshot
        for (seq, input) in inputHistory.sorted(by: { $0.key < $1.key }) {
            if input.timestamp > snapshot.timestamp {
                await applyInput(input)
            }
        }

        // Clean up old inputs
        inputHistory = inputHistory.filter { $0.value.timestamp > snapshot.timestamp }
    }

    func interpolate(at currentTime: TimeInterval) async -> GameStateSnapshot? {
        let renderTime = currentTime - interpolationDelay

        // Find two snapshots to interpolate between
        guard let before = snapshotBuffer.last(where: { $0.timestamp <= renderTime }),
              let after = snapshotBuffer.first(where: { $0.timestamp > renderTime }) else {
            return snapshotBuffer.last
        }

        // Interpolate
        let t = (renderTime - before.timestamp) / (after.timestamp - before.timestamp)
        return interpolate(from: before, to: after, t: Float(t))
    }
}
```

### Matchmaking System

```swift
struct MatchmakingConfig {
    let maxSearchTime: TimeInterval = 60.0
    let skillRangeExpansion: Float = 100.0 // Widen by 100 ELO per 10 seconds
    let regionPriority: Bool = true
    let partySupport: Bool = true
}

actor MatchmakingService {
    struct MatchmakingRequest {
        let playerID: UUID
        let skillRating: Int
        let region: Region
        let partyMembers: [UUID]
        let requestTime: Date
    }

    private var queue: [MatchmakingRequest] = []

    func joinQueue(_ request: MatchmakingRequest) async {
        queue.append(request)
        await findMatches()
    }

    private func findMatches() async {
        var matched: Set<UUID> = []

        for request in queue where !matched.contains(request.playerID) {
            // Calculate acceptable skill range
            let searchDuration = Date().timeIntervalSince(request.requestTime)
            let skillRange = 200 + Int(searchDuration / 10.0) * 100

            // Find compatible players
            let compatiblePlayers = queue.filter { other in
                !matched.contains(other.playerID) &&
                abs(other.skillRating - request.skillRating) <= skillRange &&
                (other.region == request.region || searchDuration > 30)
            }

            // Create match if enough players
            if compatiblePlayers.count >= 10 { // 5v5
                let matchPlayers = Array(compatiblePlayers.prefix(10))
                await createMatch(with: matchPlayers)
                matched.formUnion(matchPlayers.map { $0.playerID })
            }
        }

        // Remove matched players from queue
        queue.removeAll { matched.contains($0.playerID) }
    }
}
```

---

## 7. Performance Budgets

### Frame Time Budget (120 FPS = 8.33ms per frame)

```
Total: 8.33ms
├── Input Processing: 0.5ms
├── Game Logic: 2.0ms
│   ├── Physics: 0.8ms
│   ├── AI/Gameplay: 0.6ms
│   ├── Animation: 0.4ms
│   └── Networking: 0.2ms
├── Rendering: 5.0ms
│   ├── Culling: 0.3ms
│   ├── Shadows: 0.8ms
│   ├── Geometry: 2.0ms
│   ├── Lighting: 0.9ms
│   ├── Post-process: 0.5ms
│   └── UI: 0.5ms
├── Audio: 0.5ms
└── System Overhead: 0.33ms
```

### Memory Budget

```
Total: 4 GB (Vision Pro M2 limit)
├── Code & System: 500 MB
├── Textures: 1500 MB
│   ├── Environment: 800 MB
│   ├── Characters: 400 MB
│   └── Effects: 300 MB
├── Meshes: 600 MB
├── Audio: 300 MB
├── Game State: 200 MB
├── Network Buffers: 100 MB
└── Reserve: 800 MB
```

### Network Budget

```
Upstream (per player):
├── Input: 120 bytes @ 60Hz = 7.2 KB/s
├── Voice: 6 KB/s (compressed)
└── Total: ~15 KB/s

Downstream:
├── State Updates: 100 Hz @ 500 bytes = 50 KB/s
├── Event Messages: 10 KB/s
├── Voice (9 players): 54 KB/s
└── Total: ~115 KB/s

Total bandwidth per player: ~130 KB/s (1 Mbps)
```

---

## 8. Testing Requirements

### Test Coverage Requirements

```yaml
Unit Tests:
  coverage: 80%
  focus_areas:
    - Game logic (combat, movement, abilities)
    - Physics calculations
    - Network message serialization
    - Data persistence

Integration Tests:
  coverage: 60%
  focus_areas:
    - System interactions (physics + collision)
    - Network synchronization
    - UI workflows
    - Audio system integration

End-to-End Tests:
  coverage: 40%
  scenarios:
    - Complete match flow
    - Tournament progression
    - Matchmaking flow
    - Spectator experience

Performance Tests:
  metrics:
    - Frame rate (maintain 90+ FPS)
    - Memory usage (stay under 3.5 GB)
    - Network latency (< 50ms)
    - Load time (< 5 seconds)
```

### Test Implementation

```swift
// Unit test example
@testable import ArenaEsports
import XCTest

final class CombatSystemTests: XCTestCase {
    var hitDetection: HitDetectionSystem!
    var physicsWorld: MockPhysicsWorld!

    override func setUp() async throws {
        physicsWorld = MockPhysicsWorld()
        hitDetection = HitDetectionSystem(physicsWorld: physicsWorld)
    }

    func testHeadshotDamage() async throws {
        // Arrange
        let weapon = SpatialRifle()
        let target = createTestTarget()
        physicsWorld.addTarget(target, headPosition: SIMD3(0, 1.8, 10))

        // Act
        let hit = await hitDetection.performHitscan(
            from: .zero,
            direction: SIMD3(0, 0, 1),
            maxDistance: 100,
            weapon: weapon
        )

        // Assert
        XCTAssertNotNil(hit)
        XCTAssertTrue(hit?.isHeadshot ?? false)

        let expectedDamage = weapon.damage.baseDamage * weapon.damage.headShotMultiplier
        XCTAssertEqual(hit?.damage, expectedDamage, accuracy: 0.1)
    }

    func testDamageDropoff() async throws {
        let weapon = SpatialRifle()

        // Test at various distances
        let testDistances: [Float] = [5, 15, 30, 50]

        for distance in testDistances {
            let target = createTestTarget(at: SIMD3(0, 0, distance))
            physicsWorld.addTarget(target)

            let hit = await hitDetection.performHitscan(
                from: .zero,
                direction: SIMD3(0, 0, 1),
                maxDistance: 100,
                weapon: weapon
            )

            // Verify damage decreases with distance
            if distance <= 10 {
                XCTAssertEqual(hit?.damage, weapon.damage.baseDamage, accuracy: 0.1)
            } else if distance >= 50 {
                XCTAssertLessThan(hit?.damage ?? 0, weapon.damage.baseDamage * 0.6)
            }
        }
    }
}

// Performance test example
final class RenderPerformanceTests: XCTestCase {
    func testComplexSceneFrameRate() throws {
        let renderSystem = RenderSystem()
        let scene = createComplexTestScene(entityCount: 1000)

        measure(metrics: [XCTClockMetric(), XCTCPUMetric(), XCTMemoryMetric()]) {
            // Render 60 frames
            for _ in 0..<60 {
                renderSystem.render(scene: scene, deltaTime: 1.0/120.0)
            }
        }
    }

    func testMemoryUsageUnderLoad() throws {
        let options = XCTMeasureOptions()
        options.iterationCount = 10

        measure(metrics: [XCTMemoryMetric()], options: options) {
            // Spawn many entities
            let entities = (0..<500).map { _ in createTestEntity() }

            // Run game loop
            for _ in 0..<120 { // 1 second at 120 FPS
                GameLoop.shared.update(entities: entities)
            }
        }

        // Memory should stay under budget
        XCTAssertLessThan(getCurrentMemoryUsage(), 3.5 * 1024 * 1024 * 1024) // 3.5 GB
    }
}

// Integration test example
final class MultiplayerIntegrationTests: XCTestCase {
    func testPlayerJoinAndLeave() async throws {
        // Create mock server
        let server = MockGameServer()
        await server.start()

        // Create clients
        let client1 = GameClient()
        let client2 = GameClient()

        // Client 1 joins
        try await client1.connect(to: server.url)
        XCTAssertEqual(server.playerCount, 1)

        // Client 2 joins
        try await client2.connect(to: server.url)
        XCTAssertEqual(server.playerCount, 2)

        // Client 1 leaves
        await client1.disconnect()
        XCTAssertEqual(server.playerCount, 1)

        await server.stop()
    }
}
```

---

## 9. Security & Anti-Cheat

### Anti-Cheat Measures

```swift
actor AntiCheatSystem {
    // Server-side validation
    func validatePlayerAction(_ action: PlayerAction, from player: UUID) async -> Bool {
        // Check action is physically possible
        if !await isPhysicallyPossible(action, for: player) {
            await flagPlayer(player, reason: "Impossible action")
            return false
        }

        // Check for inhuman reaction times
        if action.reactionTime < 0.05 { // 50ms minimum human reaction
            await flagPlayer(player, reason: "Suspicious reaction time")
            return false
        }

        // Check for statistical anomalies
        if await hasStatisticalAnomaly(player) {
            await flagPlayer(player, reason: "Statistical anomaly")
        }

        return true
    }

    // Client integrity checks
    func performIntegrityCheck() async -> Bool {
        // Verify client binary hasn't been modified
        let binaryHash = await computeBinaryHash()
        guard binaryHash == expectedHash else {
            return false
        }

        // Check for known cheat signatures
        if await detectCheatSignatures() {
            return false
        }

        return true
    }

    // Rate limiting
    func checkRateLimit(player: UUID, action: ActionType) async -> Bool {
        let limit = actionLimits[action] ?? 100 // Actions per second
        let count = await getActionCount(player: player, action: action, window: 1.0)
        return count <= limit
    }
}

// Server authority
struct ServerAuthority {
    // All critical game state managed by server
    static let authoritative: Set<ComponentType> = [
        .health,
        .position, // With client prediction
        .inventory,
        .matchState
    ]

    // Client can control these (with validation)
    static let clientControlled: Set<ComponentType> = [
        .input,
        .cameraOrientation,
        .uiState
    ]
}
```

---

## 10. Development Tools & Workflow

### Build Configuration

```swift
// Build settings for different configurations

#if DEBUG
let enableDebugUI = true
let enableLogging = true
let enableProfiling = true
let bypassAuthentication = true
let useLocalServer = true
#elseif STAGING
let enableDebugUI = true
let enableLogging = true
let enableProfiling = false
let bypassAuthentication = false
let useLocalServer = false
#else // RELEASE
let enableDebugUI = false
let enableLogging = false
let enableProfiling = false
let bypassAuthentication = false
let useLocalServer = false
#endif
```

### Continuous Integration

```yaml
# .github/workflows/ci.yml
name: CI

on: [push, pull_request]

jobs:
  test:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v3

      - name: Build
        run: xcodebuild build -scheme ArenaEsports -destination 'platform=visionOS Simulator,name=Apple Vision Pro'

      - name: Run Tests
        run: xcodebuild test -scheme ArenaEsports -destination 'platform=visionOS Simulator,name=Apple Vision Pro'

      - name: Check Code Coverage
        run: |
          xcrun xccov view --report --json DerivedData/Logs/Test/*.xcresult
          # Fail if coverage < 80%
```

---

## Conclusion

This technical specification provides detailed implementation requirements for Arena Esports. Key technical achievements:

- **Ultra-low latency networking** with client-side prediction and server reconciliation
- **90-120 FPS rendering** through aggressive optimization and dynamic quality adjustment
- **Professional-grade controls** with hand tracking, eye tracking, and controller support
- **Comprehensive anti-cheat** with server authority and statistical analysis
- **Extensive testing** covering unit, integration, performance, and end-to-end scenarios

**Next Steps:**
1. Review and validate specifications
2. Set up development environment and CI/CD
3. Begin implementation following the architecture
4. Continuous testing and iteration

---

**Document Status:** Draft - Ready for Review
**Next Document:** DESIGN.md
