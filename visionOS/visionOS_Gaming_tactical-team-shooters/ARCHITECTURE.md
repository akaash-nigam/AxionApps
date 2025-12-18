# Tactical Team Shooters - Technical Architecture

## Table of Contents
1. [Game Architecture Overview](#game-architecture-overview)
2. [visionOS-Specific Gaming Patterns](#visionos-specific-gaming-patterns)
3. [Game Data Models & Schemas](#game-data-models--schemas)
4. [RealityKit Gaming Components](#realitykit-gaming-components)
5. [ARKit Integration](#arkit-integration)
6. [Multiplayer Architecture](#multiplayer-architecture)
7. [Physics & Collision Systems](#physics--collision-systems)
8. [Audio Architecture](#audio-architecture)
9. [Performance Optimization](#performance-optimization)
10. [Save/Load System](#saveload-system)

---

## Game Architecture Overview

### Core Game Loop
```swift
class GameEngine {
    // Fixed timestep game loop for consistent physics
    let fixedDeltaTime: TimeInterval = 1.0 / 120.0 // 120 FPS target
    var accumulator: TimeInterval = 0.0

    func update(deltaTime: TimeInterval) {
        accumulator += deltaTime

        while accumulator >= fixedDeltaTime {
            // Fixed update for physics and game logic
            fixedUpdate(fixedDeltaTime)
            accumulator -= fixedDeltaTime
        }

        // Variable update for rendering and interpolation
        let alpha = accumulator / fixedDeltaTime
        variableUpdate(alpha)
    }

    func fixedUpdate(_ deltaTime: TimeInterval) {
        inputSystem.process()
        physicsSystem.simulate(deltaTime)
        gameLogicSystem.update(deltaTime)
        aiSystem.update(deltaTime)
        networkSystem.synchronize()
    }

    func variableUpdate(_ interpolationFactor: Double) {
        renderSystem.interpolate(interpolationFactor)
        audioSystem.update()
        uiSystem.update()
    }
}
```

### Entity-Component-System Architecture
```swift
// Core ECS framework for game objects
protocol Component: AnyObject {
    var entity: Entity? { get set }
}

class Entity {
    let id: UUID
    var components: [ObjectIdentifier: Component] = [:]
    var transform: Transform

    func addComponent<T: Component>(_ component: T) {
        let key = ObjectIdentifier(T.self)
        components[key] = component
        component.entity = self
    }

    func getComponent<T: Component>() -> T? {
        let key = ObjectIdentifier(T.self)
        return components[key] as? T
    }
}

// System processes entities with specific component combinations
protocol System {
    func update(deltaTime: TimeInterval)
    func matchesEntity(_ entity: Entity) -> Bool
}
```

### State Management
```swift
enum GameState {
    case mainMenu
    case matchmaking
    case inGame(GamePhase)
    case pauseMenu
    case endGame(GameResult)
}

enum GamePhase {
    case warmup
    case freezeTime
    case roundActive
    case roundEnd
}

class GameStateManager: ObservableObject {
    @Published var currentState: GameState = .mainMenu
    @Published var matchState: MatchState?

    func transition(to newState: GameState) {
        // Cleanup current state
        exitState(currentState)

        // Enter new state
        currentState = newState
        enterState(newState)
    }
}
```

### Scene Management
```swift
enum GameScene {
    case menu          // Window-based UI
    case lobby         // Volume-based team setup
    case battlefield   // Full immersive space
}

class SceneManager {
    func loadScene(_ scene: GameScene) async {
        switch scene {
        case .menu:
            await loadMenuWindow()
        case .lobby:
            await loadLobbyVolume()
        case .battlefield:
            await loadBattlefieldImmersiveSpace()
        }
    }
}
```

---

## visionOS-Specific Gaming Patterns

### Immersive Space Management
```swift
@main
struct TacticalTeamShootersApp: App {
    @State private var immersionStyle: ImmersionStyle = .progressive

    var body: some Scene {
        // Main menu window
        WindowGroup(id: "main-menu") {
            MainMenuView()
        }
        .windowStyle(.plain)
        .defaultSize(width: 800, height: 600)

        // Team lobby volume
        WindowGroup(id: "lobby", for: LobbyConfiguration.self) { $config in
            TeamLobbyView(configuration: config)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 2, height: 1, depth: 1, in: .meters)

        // Battlefield immersive space
        ImmersiveSpace(id: "battlefield") {
            BattlefieldView()
        }
        .immersionStyle(selection: $immersionStyle, in: .progressive, .full)
    }
}
```

### Room Mapping & Spatial Anchors
```swift
class RoomMappingSystem {
    let arSession: ARKitSession
    let worldTracking: WorldTrackingProvider
    let sceneReconstruction: SceneReconstructionProvider

    // Convert real furniture into tactical cover
    func analyzeTacticalPositions() async -> [TacticalPosition] {
        var positions: [TacticalPosition] = []

        // Get room mesh data
        for update in sceneReconstruction.anchorUpdates {
            if let meshAnchor = update.anchor as? MeshAnchor {
                // Analyze mesh geometry for cover potential
                let coverAnalysis = analyzeCoverPotential(meshAnchor)

                if coverAnalysis.isSuitableForCover {
                    positions.append(TacticalPosition(
                        anchor: meshAnchor,
                        type: coverAnalysis.coverType,
                        heightAdvantage: coverAnalysis.height
                    ))
                }
            }
        }

        return positions
    }

    func analyzeCoverPotential(_ mesh: MeshAnchor) -> CoverAnalysis {
        // Analyze height, width, solidity for tactical use
        let bounds = mesh.geometry.vertices.reduce(into: SIMD3<Float>.zero) { result, vertex in
            result = max(result, abs(vertex))
        }

        let height = bounds.y
        let width = max(bounds.x, bounds.z)

        var coverType: CoverType = .none
        if height > 0.4 && height < 0.8 {
            coverType = .half  // Crouch cover
        } else if height > 0.8 {
            coverType = .full  // Standing cover
        }

        return CoverAnalysis(
            isSuitableForCover: coverType != .none && width > 0.5,
            coverType: coverType,
            height: height
        )
    }
}
```

### Hand Tracking for Weapon Control
```swift
class WeaponControlSystem {
    let handTracking: HandTrackingProvider

    func updateWeaponPose() {
        guard let leftHand = handTracking.leftHand,
              let rightHand = handTracking.rightHand else { return }

        // Two-handed weapon grip
        let dominantHand = rightHand  // TODO: Support left-handed
        let supportHand = leftHand

        // Calculate weapon position and orientation
        let gripPosition = dominantHand.wrist.position
        let aimDirection = calculateAimDirection(
            dominantHand: dominantHand,
            supportHand: supportHand
        )

        // Apply realistic weapon handling
        weapon.position = gripPosition
        weapon.orientation = Quaternion(lookAt: aimDirection)

        // Detect trigger pull gesture
        if isPinchDetected(dominantHand) {
            fireWeapon()
        }
    }

    func calculateAimDirection(
        dominantHand: HandAnchor,
        supportHand: HandAnchor
    ) -> SIMD3<Float> {
        // Use both hands for stability simulation
        let dominantIndex = dominantHand.indexFingerTip.position
        let supportIndex = supportHand.indexFingerTip.position

        let aimVector = normalize(dominantIndex - supportIndex)
        return aimVector
    }
}
```

### Eye Tracking for Tactical Awareness
```swift
class TacticalAwarenessSystem {
    let eyeTracking: EyeTrackingProvider

    func updateTacticalAwareness() {
        guard let gazePoint = eyeTracking.currentGazePoint else { return }

        // Cast ray from eye gaze for threat detection
        let hitResult = performRaycast(from: gazePoint)

        if let enemy = hitResult?.entity as? EnemyEntity {
            // Update threat awareness
            highlightThreat(enemy)

            // Track player attention patterns
            analyticsSystem.recordGazeOnThreat(enemy, duration: gazePoint.dwellTime)
        }

        // Detect if player is looking at teammate for communication
        if let teammate = hitResult?.entity as? PlayerEntity {
            enableQuickComms(with: teammate)
        }
    }
}
```

---

## Game Data Models & Schemas

### Player Model
```swift
struct Player: Codable, Identifiable {
    let id: UUID
    var username: String
    var rank: CompetitiveRank
    var stats: PlayerStats
    var loadout: Loadout
    var teamRole: TeamRole
}

struct PlayerStats: Codable {
    var kills: Int = 0
    var deaths: Int = 0
    var assists: Int = 0
    var accuracy: Double = 0.0
    var headshotPercentage: Double = 0.0
    var tacticalScore: Double = 0.0

    var kdr: Double {
        deaths > 0 ? Double(kills) / Double(deaths) : Double(kills)
    }
}

enum CompetitiveRank: String, Codable {
    case recruit
    case specialist
    case veteran
    case elite
    case master
    case legend
}

enum TeamRole: String, Codable {
    case entryFragger
    case support
    case sniper
    case igl  // In-game leader
    case lurker
}
```

### Weapon System
```swift
struct Weapon: Codable, Identifiable {
    let id: UUID
    let name: String
    let type: WeaponType
    var stats: WeaponStats
    var attachments: [Attachment] = []
}

enum WeaponType: String, Codable {
    case assaultRifle
    case smg
    case sniper
    case shotgun
    case pistol
    case lmg
}

struct WeaponStats: Codable {
    var damage: Int
    var fireRate: Double
    var recoil: RecoilPattern
    var accuracy: Double
    var range: Double
    var magazineSize: Int
    var reloadTime: TimeInterval
}

struct RecoilPattern: Codable {
    var verticalKick: Float
    var horizontalSpread: Float
    var resetTime: TimeInterval
    var pattern: [SIMD2<Float>]  // Spray pattern coordinates
}

struct Attachment: Codable, Identifiable {
    let id: UUID
    let name: String
    let type: AttachmentType
    var modifiers: WeaponModifiers
}

enum AttachmentType: String, Codable {
    case optic
    case barrel
    case grip
    case magazine
    case stock
}
```

### Match Data
```swift
struct Match: Codable, Identifiable {
    let id: UUID
    let matchType: MatchType
    let map: GameMap
    var teams: [Team]
    var rounds: [Round] = []
    var startTime: Date
    var endTime: Date?
    var winner: Team?
}

enum MatchType: String, Codable {
    case casual
    case ranked
    case competitive
    case training
}

struct Team: Codable, Identifiable {
    let id: UUID
    var name: String
    var players: [Player]
    var score: Int = 0
    var side: TeamSide
}

enum TeamSide: String, Codable {
    case attackers
    case defenders
}

struct Round: Codable {
    let number: Int
    var winner: Team
    var duration: TimeInterval
    var kills: [KillEvent]
    var objectiveCompleted: Bool
}
```

### Tactical Equipment
```swift
struct Equipment: Codable, Identifiable {
    let id: UUID
    let name: String
    let type: EquipmentType
    var quantity: Int
}

enum EquipmentType: String, Codable {
    case flashbang
    case smokeGrenade
    case fragGrenade
    case molotov
    case breachCharge
    case defuseKit
}
```

---

## RealityKit Gaming Components

### Custom Components
```swift
// Damage component for entities that can take damage
struct HealthComponent: Component {
    var maxHealth: Float
    var currentHealth: Float
    var armor: Float = 0.0
    var isInvulnerable: Bool = false

    mutating func takeDamage(_ amount: Float) -> Bool {
        guard !isInvulnerable else { return false }

        let damageAfterArmor = max(0, amount - armor)
        currentHealth -= damageAfterArmor

        return currentHealth <= 0
    }
}

// AI behavior component
struct AIComponent: Component {
    var behavior: AIBehavior
    var targetEntity: Entity?
    var alertness: Float = 0.5
    var lastKnownPlayerPosition: SIMD3<Float>?
}

enum AIBehavior {
    case patrol
    case investigate
    case combat
    case retreat
    case cover
}

// Weapon component
struct WeaponComponent: Component {
    var weaponData: Weapon
    var currentAmmo: Int
    var reserveAmmo: Int
    var isReloading: Bool = false
    var lastFireTime: TimeInterval = 0
}

// Ballistics component for projectiles
struct ProjectileComponent: Component {
    var velocity: SIMD3<Float>
    var damage: Float
    var shooter: Entity
    var distanceTraveled: Float = 0.0
    var maxDistance: Float = 100.0
}

// Network sync component
struct NetworkSyncComponent: Component {
    var ownerId: UUID
    var lastSyncTime: TimeInterval
    var predictedPosition: SIMD3<Float>
    var predictedVelocity: SIMD3<Float>
}
```

### Entity Systems
```swift
class CombatSystem: System {
    func update(deltaTime: TimeInterval) {
        // Process all entities with weapon components
        for entity in entities where matchesEntity(entity) {
            guard let weapon = entity.components[WeaponComponent.self] as? WeaponComponent,
                  let transform = entity.components[Transform.self] as? Transform else {
                continue
            }

            if weapon.isReloading {
                updateReload(entity, deltaTime)
            }

            // Update weapon position and orientation
            updateWeaponPose(entity)
        }
    }

    func matchesEntity(_ entity: Entity) -> Bool {
        entity.components[WeaponComponent.self] != nil
    }
}

class ProjectileSystem: System {
    func update(deltaTime: TimeInterval) {
        for entity in entities where matchesEntity(entity) {
            guard var projectile = entity.components[ProjectileComponent.self] as? ProjectileComponent,
                  var transform = entity.components[Transform.self] as? Transform else {
                continue
            }

            // Update projectile position
            let movement = projectile.velocity * Float(deltaTime)
            transform.translation += movement

            // Apply gravity and drag
            projectile.velocity.y -= 9.8 * Float(deltaTime)
            projectile.velocity *= 0.99  // Air resistance

            projectile.distanceTraveled += length(movement)

            // Check for collision
            if let hit = performRaycast(from: transform.translation, direction: projectile.velocity) {
                handleProjectileHit(entity, hit, projectile)
            }

            // Remove if traveled too far
            if projectile.distanceTraveled > projectile.maxDistance {
                entity.removeFromParent()
            }
        }
    }
}
```

---

## ARKit Integration

### World Tracking & Scene Understanding
```swift
class ARGameSession {
    let arSession: ARKitSession
    let worldTracking: WorldTrackingProvider
    let sceneReconstruction: SceneReconstructionProvider
    let handTracking: HandTrackingProvider
    let planeDetection: PlaneDetectionProvider

    func start() async {
        do {
            try await arSession.run([
                worldTracking,
                sceneReconstruction,
                handTracking,
                planeDetection
            ])

            // Start processing AR data
            await processARUpdates()
        } catch {
            print("Failed to start AR session: \(error)")
        }
    }

    func processARUpdates() async {
        // Process world tracking updates
        for await update in worldTracking.anchorUpdates {
            handleWorldUpdate(update)
        }
    }

    func createTacticalMap() -> TacticalMap {
        var map = TacticalMap()

        // Identify floors for player movement
        for anchor in planeDetection.detectedPlanes where anchor.classification == .floor {
            map.addWalkableArea(anchor)
        }

        // Identify walls for cover and boundaries
        for anchor in planeDetection.detectedPlanes where anchor.classification == .wall {
            map.addObstacle(anchor)
        }

        // Add furniture as tactical elements
        for meshAnchor in sceneReconstruction.meshAnchors {
            let tacticalElement = analyzeMeshForGameplay(meshAnchor)
            map.addTacticalElement(tacticalElement)
        }

        return map
    }
}
```

### Spatial Mapping for Cover System
```swift
class CoverSystem {
    var coverPoints: [CoverPoint] = []

    func generateCoverPoints(from room: RoomMesh) -> [CoverPoint] {
        var points: [CoverPoint] = []

        // Analyze room geometry
        for obstacle in room.obstacles {
            let coverPositions = calculateCoverPositions(around: obstacle)

            for position in coverPositions {
                let coverPoint = CoverPoint(
                    position: position,
                    normal: obstacle.surfaceNormal,
                    height: obstacle.height,
                    quality: evaluateCoverQuality(position, obstacle)
                )

                points.append(coverPoint)
            }
        }

        return points
    }

    func evaluateCoverQuality(_ position: SIMD3<Float>, _ obstacle: Obstacle) -> CoverQuality {
        // Check if cover protects from multiple angles
        let protectionAngles = calculateProtectionAngles(position, obstacle)

        // Check sightlines from cover position
        let sightlines = calculateSightlines(from: position)

        // Rate cover quality
        if protectionAngles > 180 && sightlines.count > 3 {
            return .excellent
        } else if protectionAngles > 90 && sightlines.count > 2 {
            return .good
        } else {
            return .poor
        }
    }
}

struct CoverPoint {
    let position: SIMD3<Float>
    let normal: SIMD3<Float>
    let height: Float
    let quality: CoverQuality
}

enum CoverQuality {
    case excellent
    case good
    case poor
}
```

---

## Multiplayer Architecture

### Network Synchronization
```swift
class NetworkManager {
    let multipeerSession: MultipeerConnectivitySession
    let gameSession: GameSession

    // Client-side prediction with server reconciliation
    func synchronizeGameState() {
        // Send local player input to server
        sendPlayerInput(gameSession.localPlayer.input)

        // Receive authoritative state from server
        if let serverState = receiveServerState() {
            reconcileWithServerState(serverState)
        }
    }

    func reconcileWithServerState(_ serverState: GameState) {
        // Server reconciliation for client-side prediction
        let localPlayer = gameSession.localPlayer

        if localPlayer.position != serverState.playerPosition {
            // Replay inputs from server timestamp
            let inputsToReplay = localPlayer.inputHistory.filter {
                $0.timestamp > serverState.timestamp
            }

            // Rewind to server state
            localPlayer.position = serverState.playerPosition
            localPlayer.velocity = serverState.playerVelocity

            // Replay inputs
            for input in inputsToReplay {
                applyInput(input, to: localPlayer)
            }
        }
    }

    // Entity interpolation for smooth remote player movement
    func interpolateRemotePlayers(deltaTime: TimeInterval) {
        for player in gameSession.remotePlayers {
            // Interpolate between last two received states
            if let current = player.currentState,
               let previous = player.previousState {

                let t = Float((CACurrentMediaTime() - current.timestamp) /
                             (current.timestamp - previous.timestamp))

                player.renderPosition = mix(previous.position, current.position, t: t)
                player.renderRotation = simd_slerp(previous.rotation, current.rotation, t)
            }
        }
    }
}
```

### SharePlay Integration
```swift
import GroupActivities

struct TacticalTeamActivity: GroupActivity {
    static let activityIdentifier = "com.tacticalgaming.teamshooters"

    var metadata: GroupActivityMetadata {
        var metadata = GroupActivityMetadata()
        metadata.title = "Tactical Team Shooters Match"
        metadata.type = .generic
        metadata.supportsContinuationOnTV = false
        return metadata
    }
}

class SharePlayManager {
    var groupSession: GroupSession<TacticalTeamActivity>?
    var messenger: GroupSessionMessenger?

    func startSharedMatch() async throws {
        let activity = TacticalTeamActivity()

        switch await activity.prepareForActivation() {
        case .activationPreferred:
            groupSession = try await activity.activate()
            messenger = GroupSessionMessenger(session: groupSession!)

            await configureSharedGameSession()

        case .activationDisabled, .cancelled:
            break
        @unknown default:
            break
        }
    }

    func configureSharedGameSession() async {
        guard let session = groupSession else { return }

        // Synchronize match start
        for await participant in session.$activeParticipants.values {
            print("Player joined: \(participant.id)")
            addPlayerToMatch(participant)
        }
    }
}
```

### Anti-Cheat System
```swift
class AntiCheatSystem {
    // Server-authoritative hit detection
    func validateHit(_ hit: HitReport, from player: Player) -> Bool {
        // Check if shot is physically possible
        guard isPhysicallyPlausible(hit) else {
            reportSuspiciousActivity(player, .impossibleShot)
            return false
        }

        // Validate timing
        guard isTemporallyValid(hit, player) else {
            reportSuspiciousActivity(player, .timingAnomaly)
            return false
        }

        // Check aim accuracy patterns
        if detectsAimbot(player.recentShots) {
            reportSuspiciousActivity(player, .suspiciousAimPattern)
            return false
        }

        return true
    }

    func isPhysicallyPlausible(_ hit: HitReport) -> Bool {
        // Verify bullet trajectory
        let trajectory = hit.hitPosition - hit.shooterPosition
        let distance = length(trajectory)

        // Check if weapon can hit at this distance
        guard distance <= hit.weapon.stats.range else {
            return false
        }

        // Verify line of sight
        if hasObstruction(from: hit.shooterPosition, to: hit.hitPosition) {
            return false
        }

        return true
    }

    func detectsAimbot(_ shots: [Shot]) -> Bool {
        // Analyze shot patterns for inhuman precision
        let headshots = shots.filter { $0.isHeadshot }
        let headshotRate = Double(headshots.count) / Double(shots.count)

        // Suspicious if >90% headshots with instant flicks
        if headshotRate > 0.9 {
            let avgFlickTime = calculateAverageFlickTime(shots)
            if avgFlickTime < 0.05 {  // Faster than human reaction
                return true
            }
        }

        return false
    }
}
```

---

## Physics & Collision Systems

### Ballistics Physics
```swift
class BallisticsSystem {
    func simulateBulletTrajectory(
        from origin: SIMD3<Float>,
        direction: SIMD3<Float>,
        weapon: Weapon
    ) -> BulletTrajectory {

        var trajectory = BulletTrajectory()
        var position = origin
        var velocity = direction * weapon.stats.muzzleVelocity

        let timeStep: Float = 0.01  // 10ms simulation steps
        var time: Float = 0.0

        while time < 5.0 {  // Max 5 second flight time
            // Apply gravity
            velocity.y -= 9.8 * timeStep

            // Apply air resistance
            let dragForce = velocity * velocity * 0.00001  // Simplified drag
            velocity -= dragForce * timeStep

            // Update position
            position += velocity * timeStep
            trajectory.points.append(position)

            // Check for collision
            if let hit = checkCollision(at: position) {
                trajectory.hitPoint = hit
                break
            }

            time += timeStep
        }

        return trajectory
    }

    func calculateBulletDrop(distance: Float, weapon: Weapon) -> Float {
        let time = distance / weapon.stats.muzzleVelocity
        let drop = 0.5 * 9.8 * time * time
        return drop
    }
}

struct BulletTrajectory {
    var points: [SIMD3<Float>] = []
    var hitPoint: SIMD3<Float>?
    var travelDistance: Float = 0.0
}
```

### Collision Detection
```swift
class CollisionSystem {
    var colliders: [Entity: CollisionShape] = [:]
    var spatialHash: SpatialHashGrid

    func detectCollisions() -> [Collision] {
        var collisions: [Collision] = []

        // Broad phase: spatial hashing
        let potentialPairs = spatialHash.queryPotentialCollisions()

        // Narrow phase: precise collision detection
        for (entityA, entityB) in potentialPairs {
            if let collision = checkPreciseCollision(entityA, entityB) {
                collisions.append(collision)
            }
        }

        return collisions
    }

    func checkPreciseCollision(_ a: Entity, _ b: Entity) -> Collision? {
        guard let shapeA = colliders[a],
              let shapeB = colliders[b] else {
            return nil
        }

        // Use SAT (Separating Axis Theorem) for convex shapes
        if let penetration = satCollisionTest(shapeA, shapeB) {
            return Collision(
                entityA: a,
                entityB: b,
                normal: penetration.normal,
                depth: penetration.depth
            )
        }

        return nil
    }

    // Raycast for hit detection
    func raycast(from origin: SIMD3<Float>, direction: SIMD3<Float>) -> RaycastHit? {
        var closestHit: RaycastHit?
        var closestDistance = Float.infinity

        for (entity, collider) in colliders {
            if let hit = rayIntersectsCollider(origin, direction, collider) {
                let distance = length(hit.point - origin)
                if distance < closestDistance {
                    closestDistance = distance
                    closestHit = RaycastHit(
                        entity: entity,
                        point: hit.point,
                        normal: hit.normal,
                        distance: distance
                    )
                }
            }
        }

        return closestHit
    }
}
```

### Recoil Physics
```swift
class RecoilSystem {
    func applyRecoil(to weapon: Entity, pattern: RecoilPattern, shotNumber: Int) {
        // Get recoil vector from pattern
        let patternIndex = shotNumber % pattern.pattern.count
        let recoilVector = pattern.pattern[patternIndex]

        // Apply vertical kick
        let verticalKick = recoilVector.y * pattern.verticalKick

        // Apply horizontal spread with randomness
        let horizontalSpread = recoilVector.x * pattern.horizontalSpread
        let randomSpread = Float.random(in: -0.1...0.1)

        // Calculate final recoil rotation
        let recoilRotation = simd_quatf(
            angle: verticalKick,
            axis: SIMD3<Float>(1, 0, 0)
        ) * simd_quatf(
            angle: horizontalSpread + randomSpread,
            axis: SIMD3<Float>(0, 1, 0)
        )

        // Apply to weapon orientation
        weapon.orientation *= recoilRotation

        // Apply recoil animation
        animateRecoilRecovery(weapon, pattern.resetTime)
    }

    func animateRecoilRecovery(_ weapon: Entity, _ resetTime: TimeInterval) {
        // Smooth recoil recovery using spring physics
        let springDamping: Float = 0.7
        let springStiffness: Float = 150.0

        // Apply spring force to return to neutral position
        // This will be handled in the animation system
    }
}
```

---

## Audio Architecture

### Spatial Audio System
```swift
class SpatialAudioSystem {
    let audioEngine: AVAudioEngine
    let environment: AVAudioEnvironmentNode

    func playWeaponSound(_ sound: WeaponSound, at position: SIMD3<Float>) {
        let playerNode = AVAudioPlayerNode()
        audioEngine.attach(playerNode)

        // Configure spatial audio
        audioEngine.connect(playerNode, to: environment, format: sound.audioFormat)

        // Set 3D position
        environment.position = AVAudio3DPoint(
            x: position.x,
            y: position.y,
            z: position.z
        )

        // Apply distance attenuation
        environment.distanceAttenuationParameters.distanceAttenuationModel = .inverse
        environment.distanceAttenuationParameters.referenceDistance = 1.0
        environment.distanceAttenuationParameters.maximumDistance = 100.0

        // Apply occlusion if behind cover
        if isOccluded(position) {
            applyOcclusionFilter(playerNode)
        }

        playerNode.scheduleBuffer(sound.audioBuffer, completionHandler: nil)
        playerNode.play()
    }

    func updateListenerPosition(_ position: SIMD3<Float>, orientation: simd_quatf) {
        // Update listener position for spatial audio
        environment.listenerPosition = AVAudio3DPoint(
            x: position.x,
            y: position.y,
            z: position.z
        )

        // Update listener orientation
        let forward = orientation.act(SIMD3<Float>(0, 0, -1))
        let up = orientation.act(SIMD3<Float>(0, 1, 0))

        environment.listenerVectorOrientation = AVAudio3DVectorOrientation(
            forward: AVAudio3DVector(x: forward.x, y: forward.y, z: forward.z),
            up: AVAudio3DVector(x: up.x, y: up.y, z: up.z)
        )
    }
}
```

### Audio Occlusion & Reverb
```swift
class AudioEnvironmentSystem {
    func configureRoomAcoustics(_ room: RoomMesh) {
        // Calculate room volume for reverb
        let volume = calculateRoomVolume(room)

        // Determine surface materials
        let materials = analyzeSurfaceMaterials(room)

        // Configure reverb parameters
        let reverbPreset = selectReverbPreset(volume: volume, materials: materials)
        applyReverbPreset(reverbPreset)
    }

    func applyOcclusion(between source: SIMD3<Float>, listener: SIMD3<Float>) -> Float {
        // Raycast to check for obstacles
        let direction = normalize(listener - source)

        if let hit = raycast(from: source, direction: direction) {
            // Calculate occlusion based on material
            let material = hit.entity.material
            return material.soundAbsorption
        }

        return 0.0  // No occlusion
    }
}
```

---

## Performance Optimization

### Level of Detail (LOD) System
```swift
class LODSystem {
    func updateLOD(for entity: Entity, cameraPosition: SIMD3<Float>) {
        let distance = length(entity.position - cameraPosition)

        // Select appropriate LOD level
        let lodLevel: LODLevel
        if distance < 5.0 {
            lodLevel = .high
        } else if distance < 15.0 {
            lodLevel = .medium
        } else if distance < 30.0 {
            lodLevel = .low
        } else {
            lodLevel = .culled
        }

        // Apply LOD to mesh
        if let modelComponent = entity.components[ModelComponent.self] {
            modelComponent.mesh = getLODMesh(entity, lodLevel)
        }

        // Update physics complexity
        if let physicsComponent = entity.components[PhysicsComponent.self] {
            physicsComponent.collider = getLODCollider(entity, lodLevel)
        }
    }
}

enum LODLevel {
    case high      // Full detail, <5m
    case medium    // Reduced polygons, 5-15m
    case low       // Minimal detail, 15-30m
    case culled    // Not rendered, >30m
}
```

### Object Pooling
```swift
class ObjectPool<T: Entity> {
    private var availableObjects: [T] = []
    private var activeObjects: Set<T> = []

    func acquire() -> T {
        if let object = availableObjects.popLast() {
            activeObjects.insert(object)
            return object
        } else {
            let newObject = createNew()
            activeObjects.insert(newObject)
            return newObject
        }
    }

    func release(_ object: T) {
        activeObjects.remove(object)
        object.reset()
        availableObjects.append(object)
    }

    private func createNew() -> T {
        // Factory method for creating new instances
        fatalError("Must override createNew")
    }
}

// Usage for bullets, particles, etc.
class BulletPool: ObjectPool<BulletEntity> {
    override func createNew() -> BulletEntity {
        return BulletEntity()
    }
}
```

### Culling & Occlusion
```swift
class CullingSystem {
    func frustumCull(camera: Camera) -> [Entity] {
        var visibleEntities: [Entity] = []

        for entity in allEntities {
            if isInFrustum(entity, camera) {
                visibleEntities.append(entity)
            }
        }

        return visibleEntities
    }

    func occlusionCull(_ entities: [Entity], camera: Camera) -> [Entity] {
        var visible: [Entity] = []

        // Sort by distance
        let sorted = entities.sorted {
            length($0.position - camera.position) <
            length($1.position - camera.position)
        }

        // Check occlusion from near to far
        for entity in sorted {
            if !isOccluded(entity, by: visible, from: camera) {
                visible.append(entity)
            }
        }

        return visible
    }
}
```

### Frame Rate Management
```swift
class PerformanceManager {
    let targetFrameRate: Double = 120.0
    var currentFrameRate: Double = 120.0

    func adjustQuality() {
        currentFrameRate = measureFrameRate()

        if currentFrameRate < targetFrameRate * 0.95 {
            // Reduce quality
            reduceQualityLevel()
        } else if currentFrameRate > targetFrameRate * 1.05 {
            // Can increase quality
            increaseQualityLevel()
        }
    }

    func reduceQualityLevel() {
        // Reduce shadow quality
        shadowQuality = max(shadowQuality - 1, 0)

        // Reduce particle count
        maxParticles = Int(Double(maxParticles) * 0.8)

        // Increase LOD distance thresholds
        lodDistances = lodDistances.map { $0 * 0.9 }
    }
}
```

---

## Save/Load System

### Save Data Structure
```swift
struct SaveData: Codable {
    let version: String
    let saveDate: Date

    var playerProfile: PlayerProfile
    var gameProgress: GameProgress
    var settings: GameSettings
    var statistics: GlobalStatistics
}

struct PlayerProfile: Codable {
    var username: String
    var level: Int
    var experience: Int
    var rank: CompetitiveRank
    var unlockedWeapons: [UUID]
    var unlockedAttachments: [UUID]
    var loadouts: [Loadout]
}

struct GameProgress: Codable {
    var completedTrainingMissions: [UUID]
    var competitiveMatchesPlayed: Int
    var achievementsUnlocked: [UUID]
    var currentSeason: Int
    var seasonProgress: SeasonProgress
}
```

### Save/Load Manager
```swift
class SaveManager {
    let fileURL: URL

    init() {
        let documentsDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!

        fileURL = documentsDirectory.appendingPathComponent("TacticalTeamShooters.save")
    }

    func save(_ data: SaveData) async throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        let jsonData = try encoder.encode(data)
        try jsonData.write(to: fileURL)

        // Also backup to iCloud
        try await backupToCloud(data)
    }

    func load() async throws -> SaveData {
        // Try loading from local file
        if FileManager.default.fileExists(atPath: fileURL.path) {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            return try decoder.decode(SaveData.self, from: data)
        }

        // Try restoring from iCloud
        if let cloudData = try await restoreFromCloud() {
            return cloudData
        }

        // Return new save data
        return createNewSave()
    }

    func backupToCloud(_ data: SaveData) async throws {
        // Use CloudKit for backup
        // Implementation details...
    }
}
```

---

## Summary

This architecture provides:

1. **High Performance**: 120 FPS capable with LOD, culling, and object pooling
2. **Spatial Computing**: Full integration with visionOS ARKit and RealityKit
3. **Multiplayer Ready**: Client-side prediction, server reconciliation, anti-cheat
4. **Scalable**: ECS architecture supports complex game systems
5. **Professional Grade**: Realistic ballistics, physics, and spatial audio
6. **User Friendly**: Comprehensive save system with cloud backup

The architecture is designed specifically for visionOS gaming, leveraging spatial computing capabilities while maintaining the performance requirements for competitive tactical shooters.
