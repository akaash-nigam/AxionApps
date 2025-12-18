# Holographic Board Games - Technical Specification

## Document Overview
This document provides detailed technical specifications for implementing Holographic Board Games on visionOS.

**Version:** 1.0
**Last Updated:** 2025-01-20
**Target Platform:** visionOS 2.0+
**Minimum Requirements:** Apple Vision Pro

---

## 1. Technology Stack

### 1.1 Core Technologies

```yaml
programming_language:
  primary: Swift 6.0
  features:
    - strict_concurrency
    - actor_isolation
    - sendable_types
    - async_await

frameworks:
  ui: SwiftUI 5.0+
  rendering: RealityKit 2.0+
  ar: ARKit 6.0+
  audio: AVFoundation
  networking: GroupActivities
  persistence:
    - CoreData
    - CloudKit
  game_logic: GameplayKit (optional)

platform:
  os: visionOS 2.0+
  device: Apple Vision Pro
  xcode: 16.0+

capabilities_required:
  - Hand Tracking
  - Eye Tracking
  - Spatial Audio
  - SharePlay
  - CloudKit (optional)
```

### 1.2 Development Environment

```yaml
required_tools:
  - Xcode 16.0+
  - macOS 14.0+ (Sonoma)
  - Reality Composer Pro
  - Instruments (profiling)
  - Simulator or Vision Pro device

recommended_tools:
  - Git (version control)
  - SwiftLint (code quality)
  - SwiftFormat (code formatting)
```

---

## 2. Project Structure

### 2.1 Directory Layout

```
HolographicBoardGames/
├── HolographicBoardGames/
│   ├── App/
│   │   ├── HolographicBoardGamesApp.swift
│   │   ├── AppCoordinator.swift
│   │   └── AppState.swift
│   ├── Core/
│   │   ├── GameEngine/
│   │   │   ├── GameLoop.swift
│   │   │   ├── EntityManager.swift
│   │   │   └── SystemManager.swift
│   │   ├── ECS/
│   │   │   ├── Entity.swift
│   │   │   ├── Component.swift
│   │   │   └── System.swift
│   │   └── Events/
│   │       ├── EventBus.swift
│   │       └── GameEvents.swift
│   ├── Games/
│   │   ├── Chess/
│   │   │   ├── Models/
│   │   │   │   ├── ChessGameState.swift
│   │   │   │   ├── ChessPiece.swift
│   │   │   │   ├── ChessMove.swift
│   │   │   │   └── BoardPosition.swift
│   │   │   ├── Logic/
│   │   │   │   ├── ChessRulesEngine.swift
│   │   │   │   ├── MoveValidator.swift
│   │   │   │   └── ChessAI.swift
│   │   │   ├── Components/
│   │   │   │   ├── ChessPieceComponent.swift
│   │   │   │   └── ChessBoardComponent.swift
│   │   │   ├── Systems/
│   │   │   │   ├── ChessMoveSystem.swift
│   │   │   │   └── ChessAnimationSystem.swift
│   │   │   └── Views/
│   │   │       ├── ChessGameView.swift
│   │   │       └── ChessBoardView.swift
│   │   └── GameRegistry.swift
│   ├── Systems/
│   │   ├── Input/
│   │   │   ├── HandTrackingSystem.swift
│   │   │   ├── GestureRecognizer.swift
│   │   │   └── InputProcessor.swift
│   │   ├── Physics/
│   │   │   ├── PhysicsSystem.swift
│   │   │   └── CollisionHandler.swift
│   │   ├── Animation/
│   │   │   ├── AnimationSystem.swift
│   │   │   ├── AnimationController.swift
│   │   │   └── Animations/
│   │   │       ├── PieceMovement.swift
│   │   │       ├── PieceCapture.swift
│   │   │       └── PieceCelebration.swift
│   │   ├── Audio/
│   │   │   ├── SpatialAudioSystem.swift
│   │   │   ├── MusicManager.swift
│   │   │   └── SoundEffects.swift
│   │   ├── Rendering/
│   │   │   ├── RenderSystem.swift
│   │   │   ├── LODSystem.swift
│   │   │   └── MaterialManager.swift
│   │   └── Tutorial/
│   │       ├── TutorialSystem.swift
│   │       ├── TutorialStep.swift
│   │       └── HighlightSystem.swift
│   ├── Multiplayer/
│   │   ├── MultiplayerSession.swift
│   │   ├── NetworkSyncManager.swift
│   │   ├── GroupActivityManager.swift
│   │   └── Messages/
│   │       ├── NetworkMessage.swift
│   │       ├── MoveMessage.swift
│   │       └── StateMessage.swift
│   ├── Persistence/
│   │   ├── GamePersistenceManager.swift
│   │   ├── CloudSyncManager.swift
│   │   └── SaveGame.swift
│   ├── UI/
│   │   ├── Scenes/
│   │   │   ├── MainMenuView.swift
│   │   │   ├── GameSelectionView.swift
│   │   │   └── SettingsView.swift
│   │   ├── Components/
│   │   │   ├── GameButton.swift
│   │   │   ├── PlayerAvatar.swift
│   │   │   └── GameHUD.swift
│   │   └── Styles/
│   │       ├── Colors.swift
│   │       ├── Fonts.swift
│   │       └── Themes.swift
│   ├── Utilities/
│   │   ├── Extensions/
│   │   │   ├── SIMD+Extensions.swift
│   │   │   └── Entity+Extensions.swift
│   │   ├── Helpers/
│   │   │   ├── MathHelpers.swift
│   │   │   └── GeometryHelpers.swift
│   │   └── Constants.swift
│   └── Resources/
│       ├── Assets.xcassets/
│       ├── RealityKitContent/
│       │   ├── ChessPieces.usda
│       │   ├── ChessBoard.usda
│       │   └── Materials/
│       ├── Audio/
│       │   ├── Music/
│       │   └── SFX/
│       └── Localization/
│           └── en.lproj/
├── HolographicBoardGamesTests/
│   ├── GameLogicTests/
│   │   ├── ChessRulesTests.swift
│   │   ├── MovementTests.swift
│   │   └── AITests.swift
│   ├── SystemTests/
│   │   ├── InputSystemTests.swift
│   │   └── PhysicsSystemTests.swift
│   └── IntegrationTests/
│       └── MultiplayerTests.swift
└── HolographicBoardGamesUITests/
    ├── GameFlowTests.swift
    └── AccessibilityTests.swift
```

---

## 3. Game Mechanics Specification

### 3.1 Chess Implementation (MVP)

#### 3.1.1 Piece Specifications

```swift
enum ChessPieceType: String, Codable, CaseIterable {
    case pawn
    case knight
    case bishop
    case rook
    case queen
    case king
}

struct PieceAttributes {
    let type: ChessPieceType
    let modelPath: String
    let materialValue: Int
    let animations: [AnimationType]
}

extension ChessPieceType {
    var attributes: PieceAttributes {
        switch self {
        case .pawn:
            return PieceAttributes(
                type: .pawn,
                modelPath: "Chess/Pieces/Pawn.usdz",
                materialValue: 1,
                animations: [.idle, .walk, .capture, .promote]
            )
        case .knight:
            return PieceAttributes(
                type: .knight,
                modelPath: "Chess/Pieces/Knight.usdz",
                materialValue: 3,
                animations: [.idle, .jump, .capture, .victory]
            )
        case .bishop:
            return PieceAttributes(
                type: .bishop,
                modelPath: "Chess/Pieces/Bishop.usdz",
                materialValue: 3,
                animations: [.idle, .glide, .capture, .blessing]
            )
        case .rook:
            return PieceAttributes(
                type: .rook,
                modelPath: "Chess/Pieces/Rook.usdz",
                materialValue: 5,
                animations: [.idle, .march, .capture, .fortify]
            )
        case .queen:
            return PieceAttributes(
                type: .queen,
                modelPath: "Chess/Pieces/Queen.usdz",
                materialValue: 9,
                animations: [.idle, .gracefulMove, .capture, .dominance]
            )
        case .king:
            return PieceAttributes(
                type: .king,
                modelPath: "Chess/Pieces/King.usdz",
                materialValue: 0,  // Infinite (game ends if captured)
                animations: [.idle, .walk, .captured, .castle]
            )
        }
    }
}
```

#### 3.1.2 Movement Rules

```swift
protocol MovementRule {
    func generateMoves(
        for piece: ChessPiece,
        at position: BoardPosition,
        in state: ChessGameState
    ) -> [BoardPosition]
}

class PawnMovement: MovementRule {
    func generateMoves(
        for piece: ChessPiece,
        at position: BoardPosition,
        in state: ChessGameState
    ) -> [BoardPosition] {
        var moves: [BoardPosition] = []
        let direction = piece.color == .white ? 1 : -1

        // Forward one square
        let oneForward = BoardPosition(
            file: position.file,
            rank: position.rank + direction
        )
        if state.isSquareEmpty(oneForward) {
            moves.append(oneForward)

            // Forward two squares (first move only)
            if !piece.hasMoved {
                let twoForward = BoardPosition(
                    file: position.file,
                    rank: position.rank + (direction * 2)
                )
                if state.isSquareEmpty(twoForward) {
                    moves.append(twoForward)
                }
            }
        }

        // Diagonal captures
        for fileOffset in [-1, 1] {
            let capturePosition = BoardPosition(
                file: position.file + fileOffset,
                rank: position.rank + direction
            )
            if state.hasEnemyPiece(at: capturePosition, enemyOf: piece.color) {
                moves.append(capturePosition)
            }
        }

        // En passant
        if let enPassantSquare = state.enPassantTarget {
            if abs(enPassantSquare.file - position.file) == 1 &&
               enPassantSquare.rank == position.rank + direction {
                moves.append(enPassantSquare)
            }
        }

        return moves
    }
}

class KnightMovement: MovementRule {
    func generateMoves(
        for piece: ChessPiece,
        at position: BoardPosition,
        in state: ChessGameState
    ) -> [BoardPosition] {
        let offsets = [
            (2, 1), (2, -1), (-2, 1), (-2, -1),
            (1, 2), (1, -2), (-1, 2), (-1, -2)
        ]

        return offsets.compactMap { (fileOffset, rankOffset) in
            let newPosition = BoardPosition(
                file: position.file + fileOffset,
                rank: position.rank + rankOffset
            )

            guard newPosition.isValid else { return nil }

            if state.isSquareEmpty(newPosition) ||
               state.hasEnemyPiece(at: newPosition, enemyOf: piece.color) {
                return newPosition
            }

            return nil
        }
    }
}

// Similar implementations for Bishop, Rook, Queen, King...
```

#### 3.1.3 Special Moves

```swift
class SpecialMoveHandler {
    // Castling
    func canCastle(
        king: ChessPiece,
        rook: ChessPiece,
        state: ChessGameState
    ) -> Bool {
        // King and rook must not have moved
        guard !king.hasMoved && !rook.hasMoved else { return false }

        // King must not be in check
        guard !state.isKingInCheck(color: king.color) else { return false }

        // Path must be clear
        let pathPositions = getPathBetween(king.position, rook.position)
        for position in pathPositions {
            if !state.isSquareEmpty(position) {
                return false
            }
            // King cannot pass through check
            if state.isSquareUnderAttack(position, by: king.color.opposite) {
                return false
            }
        }

        return true
    }

    // En Passant
    func canEnPassant(
        pawn: ChessPiece,
        targetSquare: BoardPosition,
        state: ChessGameState
    ) -> Bool {
        guard let enPassantTarget = state.enPassantTarget else {
            return false
        }

        return targetSquare == enPassantTarget &&
               abs(pawn.position.file - targetSquare.file) == 1
    }

    // Promotion
    func shouldPromote(pawn: ChessPiece, to position: BoardPosition) -> Bool {
        let promotionRank = pawn.color == .white ? 7 : 0
        return pawn.type == .pawn && position.rank == promotionRank
    }
}
```

---

## 4. Control Schemes

### 4.1 Hand Tracking Implementation

```swift
class HandTrackingInputSystem: System {
    let priority = 100

    // Hand tracking configuration
    struct HandTrackingConfig {
        let pinchThreshold: Float = 0.02  // 2cm
        let hoverDistance: Float = 0.05   // 5cm
        let smoothingFactor: Float = 0.8  // Smooth hand movement
        let deadZone: Float = 0.001       // Ignore tiny movements
    }

    private let config = HandTrackingConfig()
    private var leftHandState = HandState()
    private var rightHandState = HandState()

    struct HandState {
        var isPinching: Bool = false
        var position: SIMD3<Float> = .zero
        var grabbedEntity: Entity?
        var grabOffset: SIMD3<Float> = .zero
    }

    func update(entities: [Entity], deltaTime: TimeInterval) {
        guard let session = ARKitSession.shared,
              let handTracking = session.queryDeviceAnchor(.hand) else {
            return
        }

        // Update left hand
        if let leftHand = handTracking.leftHand {
            updateHand(
                leftHand,
                state: &leftHandState,
                entities: entities
            )
        }

        // Update right hand
        if let rightHand = handTracking.rightHand {
            updateHand(
                rightHand,
                state: &rightHandState,
                entities: entities
            )
        }
    }

    private func updateHand(
        _ hand: HandAnchor,
        state: inout HandState,
        entities: [Entity]
    ) {
        // Get hand joints
        let thumbTip = hand.skeleton.joint(.thumbTip)
        let indexTip = hand.skeleton.joint(.indexFingerTip)

        // Calculate pinch
        let pinchDistance = simd_distance(
            thumbTip.position,
            indexTip.position
        )
        let isPinching = pinchDistance < config.pinchThreshold

        // Smooth hand position
        let rawPosition = indexTip.position
        state.position = simd_mix(
            state.position,
            rawPosition,
            config.smoothingFactor
        )

        // Handle pinch state changes
        if isPinching && !state.isPinching {
            // Pinch started
            onPinchStart(at: state.position, state: &state, entities: entities)
        } else if !isPinching && state.isPinching {
            // Pinch ended
            onPinchEnd(state: &state)
        } else if isPinching && state.isPinching {
            // Pinch held
            onPinchHeld(at: state.position, state: &state)
        } else {
            // No pinch - check for hover
            onHover(at: state.position, entities: entities)
        }

        state.isPinching = isPinching
    }

    private func onPinchStart(
        at position: SIMD3<Float>,
        state: inout HandState,
        entities: [Entity]
    ) {
        // Raycast from hand position
        if let entity = raycast(from: position, in: entities) {
            // Check if entity is interactive
            guard entity.hasComponent(InteractiveComponent.self) else {
                return
            }

            state.grabbedEntity = entity
            state.grabOffset = entity.position - position

            // Trigger grab event
            EventBus.shared.publish(EntityGrabbedEvent(entity: entity))

            // Haptic feedback
            triggerHapticFeedback(.selectionChanged)
        }
    }

    private func onPinchEnd(state: inout HandState) {
        guard let entity = state.grabbedEntity else { return }

        // Trigger release event
        EventBus.shared.publish(EntityReleasedEvent(entity: entity))

        // Haptic feedback
        triggerHapticFeedback(.impact(.light))

        state.grabbedEntity = nil
    }

    private func onPinchHeld(
        at position: SIMD3<Float>,
        state: inout HandState
    ) {
        guard let entity = state.grabbedEntity else { return }

        // Update entity position
        let targetPosition = position + state.grabOffset

        // Smooth movement
        if var transform = entity.component(ofType: TransformComponent.self) {
            transform.position = simd_mix(
                transform.position,
                targetPosition,
                0.3  // Drag smoothing
            )
        }

        // Trigger drag event
        EventBus.shared.publish(EntityDraggedEvent(
            entity: entity,
            position: targetPosition
        ))
    }

    private func onHover(
        at position: SIMD3<Float>,
        entities: [Entity]
    ) {
        if let entity = raycast(from: position, in: entities) {
            guard entity.hasComponent(InteractiveComponent.self) else {
                return
            }

            // Trigger hover event
            EventBus.shared.publish(EntityHoverEvent(entity: entity))
        }
    }
}
```

### 4.2 Eye Tracking Integration

```swift
class EyeTrackingInputSystem: System {
    let priority = 95

    func update(entities: [Entity], deltaTime: TimeInterval) {
        guard let session = ARKitSession.shared,
              let eyeTracking = session.queryDeviceAnchor(.eyeTracking) else {
            return
        }

        // Get gaze direction
        let gazeOrigin = eyeTracking.originFromDevice.position
        let gazeDirection = eyeTracking.direction

        // Raycast from eyes
        if let hitEntity = raycast(
            from: gazeOrigin,
            direction: gazeDirection,
            in: entities
        ) {
            // Highlight gazed entity
            highlightEntity(hitEntity)

            // Publish gaze event
            EventBus.shared.publish(EntityGazedEvent(entity: hitEntity))
        }
    }
}
```

### 4.3 Game Controller Support

```swift
import GameController

class GameControllerInputSystem: System {
    let priority = 90

    private var connectedControllers: [GCController] = []

    init() {
        setupControllerNotifications()
    }

    private func setupControllerNotifications() {
        NotificationCenter.default.addObserver(
            forName: .GCControllerDidConnect,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let controller = notification.object as? GCController {
                self?.controllerConnected(controller)
            }
        }

        NotificationCenter.default.addObserver(
            forName: .GCControllerDidDisconnect,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let controller = notification.object as? GCController {
                self?.controllerDisconnected(controller)
            }
        }
    }

    private func controllerConnected(_ controller: GCController) {
        connectedControllers.append(controller)

        // Configure button handlers
        controller.extendedGamepad?.buttonA.valueChangedHandler = { [weak self] button, value, pressed in
            if pressed {
                self?.handleButtonA()
            }
        }

        // D-pad for piece selection
        controller.extendedGamepad?.dpad.valueChangedHandler = { [weak self] dpad, xValue, yValue in
            self?.handleDPad(x: xValue, y: yValue)
        }
    }
}
```

---

## 5. Physics Specifications

### 5.1 Collision Detection

```swift
struct CollisionLayer: OptionSet {
    let rawValue: UInt32

    static let board      = CollisionLayer(rawValue: 1 << 0)
    static let pieces     = CollisionLayer(rawValue: 1 << 1)
    static let ui         = CollisionLayer(rawValue: 1 << 2)
    static let bounds     = CollisionLayer(rawValue: 1 << 3)
    static let hands      = CollisionLayer(rawValue: 1 << 4)
}

class PhysicsConfiguration {
    static let gravity: SIMD3<Float> = [0, -9.81, 0]
    static let pieceCollisionMatrix: [CollisionLayer: [CollisionLayer]] = [
        .pieces: [.board, .pieces, .bounds],
        .board: [.pieces],
        .hands: [.pieces, .ui]
    ]
}

class PhysicsSystem: System {
    let priority = 50

    private var physicsWorld: PhysicsWorld

    func update(entities: [Entity], deltaTime: TimeInterval) {
        // Step physics simulation
        physicsWorld.step(timeStep: deltaTime)

        // Sync transforms
        syncPhysicsToEntities(entities)

        // Process collisions
        processCollisions()
    }

    private func processCollisions() {
        for collision in physicsWorld.contactTestResults {
            let entityA = collision.bodyA.userData as? Entity
            let entityB = collision.bodyB.userData as? Entity

            guard let a = entityA, let b = entityB else { continue }

            EventBus.shared.publish(CollisionEvent(
                entityA: a,
                entityB: b,
                contactPoint: collision.contactPoint,
                normal: collision.contactNormal
            ))
        }
    }
}
```

### 5.2 Piece Physics

```swift
class PiecePhysicsComponent: Component {
    var entity: Entity?

    let mass: Float
    let friction: Float
    let restitution: Float  // Bounciness
    let isKinematic: Bool   // If true, not affected by forces

    init(
        mass: Float = 1.0,
        friction: Float = 0.5,
        restitution: Float = 0.1,
        isKinematic: Bool = false
    ) {
        self.mass = mass
        self.friction = friction
        self.restitution = restitution
        self.isKinematic = isKinematic
    }
}
```

---

## 6. Rendering Requirements

### 6.1 Material Specifications

```swift
enum MaterialType {
    case wood
    case marble
    case metal
    case glass
    case holographic
}

class MaterialManager {
    private var materials: [MaterialType: PhysicallyBasedMaterial] = [:]

    func createChessPieceMaterial(
        type: MaterialType,
        color: PlayerColor
    ) -> PhysicallyBasedMaterial {
        var material = PhysicallyBasedMaterial()

        switch type {
        case .wood:
            material.baseColor = .init(
                tint: color == .white ? .white : .brown
            )
            material.roughness = .init(floatLiteral: 0.7)
            material.metallic = .init(floatLiteral: 0.0)

        case .marble:
            material.baseColor = .init(
                tint: color == .white ? .white : .black,
                texture: .init(try! .load(named: "marble_texture"))
            )
            material.roughness = .init(floatLiteral: 0.2)
            material.metallic = .init(floatLiteral: 0.1)

        case .metal:
            material.baseColor = .init(
                tint: color == .white ? .silver : .darkGray
            )
            material.roughness = .init(floatLiteral: 0.3)
            material.metallic = .init(floatLiteral: 1.0)

        case .holographic:
            material.baseColor = .init(tint: .white)
            material.emissiveColor = .init(
                color: color == .white ? .cyan : .magenta
            )
            material.roughness = .init(floatLiteral: 0.1)
        }

        return material
    }
}
```

### 6.2 Lighting Configuration

```swift
class LightingSystem {
    func setupGameLighting(in scene: Entity) {
        // Directional light (main sunlight)
        let sunLight = DirectionalLight()
        sunLight.light.intensity = 1000
        sunLight.light.color = .white
        sunLight.shadow = DirectionalLightComponent.Shadow(
            maximumDistance: 5.0,
            depthBias: 0.5
        )
        scene.addChild(sunLight)

        // Ambient light
        let ambient = AmbientLightComponent(
            color: .white,
            intensity: 300
        )
        scene.components.set(ambient)

        // Spot lights for dramatic effect
        addSpotlight(
            at: [2, 3, 2],
            targeting: .zero,
            color: .white,
            intensity: 500,
            in: scene
        )
    }

    private func addSpotlight(
        at position: SIMD3<Float>,
        targeting target: SIMD3<Float>,
        color: UIColor,
        intensity: Float,
        in scene: Entity
    ) {
        let spotlight = SpotLight()
        spotlight.position = position
        spotlight.look(at: target, from: position, relativeTo: nil)
        spotlight.light.color = color
        spotlight.light.intensity = intensity
        spotlight.light.innerAngleInDegrees = 30
        spotlight.light.outerAngleInDegrees = 45
        scene.addChild(spotlight)
    }
}
```

---

## 7. Audio Design

### 7.1 Spatial Audio Configuration

```swift
class SpatialAudioSystem: System {
    let priority = 30

    private let audioEngine = AVAudioEngine()
    private let environment = AVAudioEnvironmentNode()

    init() {
        setupAudioEngine()
    }

    private func setupAudioEngine() {
        // Configure environment
        environment.renderingAlgorithm = .HRTFHQ  // High quality spatial audio
        environment.reverbBlend = 0.2

        // Attach to engine
        audioEngine.attach(environment)
        audioEngine.connect(
            audioEngine.mainMixerNode,
            to: environment,
            format: nil
        )
        audioEngine.connect(
            environment,
            to: audioEngine.outputNode,
            format: nil
        )

        // Start engine
        try? audioEngine.start()
    }

    func playSound(
        _ soundEffect: SoundEffect,
        at position: SIMD3<Float>,
        volume: Float = 1.0
    ) {
        let player = AVAudioPlayerNode()
        audioEngine.attach(player)

        // Connect to environment node
        audioEngine.connect(player, to: environment, format: soundEffect.format)

        // Set 3D position
        player.position = AVAudio3DPoint(
            x: position.x,
            y: position.y,
            z: position.z
        )

        player.volume = volume
        player.scheduleFile(soundEffect.audioFile, at: nil)
        player.play()
    }
}

enum SoundEffect: String {
    case pieceMove = "piece_move"
    case pieceCapture = "piece_capture"
    case check = "check"
    case checkmate = "checkmate"
    case buttonClick = "button_click"
    case victory = "victory"

    var audioFile: AVAudioFile {
        let url = Bundle.main.url(
            forResource: rawValue,
            withExtension: "wav"
        )!
        return try! AVAudioFile(forReading: url)
    }

    var format: AVAudioFormat {
        audioFile.processingFormat
    }
}
```

### 7.2 Music System

```swift
class MusicManager {
    private var backgroundPlayer: AVAudioPlayer?
    private let crossfadeDuration: TimeInterval = 2.0

    enum MusicTrack: String {
        case mainMenu = "main_menu"
        case gameplay = "gameplay_ambient"
        case victory = "victory_theme"
        case defeat = "defeat_theme"
    }

    func play(_ track: MusicTrack, loop: Bool = true) {
        let url = Bundle.main.url(
            forResource: track.rawValue,
            withExtension: "mp3"
        )!

        let newPlayer = try! AVAudioPlayer(contentsOf: url)
        newPlayer.numberOfLoops = loop ? -1 : 0
        newPlayer.volume = 0
        newPlayer.play()

        // Crossfade
        UIView.animate(withDuration: crossfadeDuration) {
            self.backgroundPlayer?.volume = 0
            newPlayer.volume = 0.7
        } completion: { _ in
            self.backgroundPlayer?.stop()
            self.backgroundPlayer = newPlayer
        }
    }
}
```

---

## 8. Multiplayer Specifications

### 8.1 Network Protocol

```swift
protocol NetworkMessage: Codable {
    var messageID: UUID { get }
    var timestamp: Date { get }
    var senderID: UUID { get }
}

// Message types
struct MoveMessage: NetworkMessage {
    let messageID = UUID()
    let timestamp = Date()
    let senderID: UUID
    let move: ChessMove
    let stateHash: String
}

struct ChatMessage: NetworkMessage {
    let messageID = UUID()
    let timestamp = Date()
    let senderID: UUID
    let text: String
}

struct SyncRequestMessage: NetworkMessage {
    let messageID = UUID()
    let timestamp = Date()
    let senderID: UUID
}

struct StateSnapshotMessage: NetworkMessage {
    let messageID = UUID()
    let timestamp = Date()
    let senderID: UUID
    let gameState: ChessGameState
    let stateHash: String
}

struct PlayerJoinedMessage: NetworkMessage {
    let messageID = UUID()
    let timestamp = Date()
    let senderID: UUID
    let playerName: String
    let playerColor: PlayerColor
}
```

### 8.2 State Synchronization

```swift
class StateSynchronizer {
    private var localState: ChessGameState
    private var stateHash: String

    // Vector clock for conflict resolution
    private var vectorClock: [UUID: Int] = [:]

    func handleRemoteMove(_ message: MoveMessage) throws {
        // Verify move is valid
        guard isValidMove(message.move) else {
            throw SyncError.invalidMove
        }

        // Check for conflicts
        if message.stateHash != stateHash {
            try resolveConflict(remoteMessage: message)
        }

        // Apply move
        try applyMove(message.move)

        // Update vector clock
        vectorClock[message.senderID, default: 0] += 1

        // Recalculate hash
        stateHash = calculateStateHash(localState)
    }

    private func resolveConflict(remoteMessage: MoveMessage) throws {
        // Request full state from host
        let syncRequest = SyncRequestMessage(senderID: localPlayerID)
        try await messenger.send(syncRequest)

        // Wait for state snapshot
        // Host has authority in case of conflicts
    }

    private func calculateStateHash(_ state: ChessGameState) -> String {
        let data = try! JSONEncoder().encode(state)
        return SHA256.hash(data: data)
            .compactMap { String(format: "%02x", $0) }
            .joined()
    }
}
```

---

## 9. Performance Budgets

### 9.1 Frame Rate Targets

```yaml
performance_targets:
  frame_rate:
    target: 90 FPS
    minimum: 60 FPS
    measurement: rolling_30s_average

  frame_time:
    target: 11.1ms
    maximum: 16.6ms

  cpu_time:
    game_logic: < 3ms
    physics: < 2ms
    rendering: < 4ms
    audio: < 1ms
    networking: < 1ms
```

### 9.2 Memory Budgets

```yaml
memory_budgets:
  total_app: < 2GB

  breakdown:
    models: < 500MB
    textures: < 400MB
    audio: < 200MB
    code: < 100MB
    game_state: < 50MB
    overhead: < 750MB

  per_game_session: < 300MB
```

### 9.3 Asset Specifications

```yaml
asset_limits:
  3d_models:
    chess_piece:
      polygons: < 5000
      materials: 1-2
      textures: 2048x2048 max

    chess_board:
      polygons: < 10000
      materials: 2-3
      textures: 4096x4096 max

  audio:
    sound_effects:
      format: WAV
      sample_rate: 44.1kHz
      bit_depth: 16bit
      duration: < 3s

    music:
      format: MP3
      bitrate: 192kbps
      duration: 2-5 minutes (looping)
```

---

## 10. Testing Requirements

### 10.1 Unit Test Coverage

```swift
// Target: 80% code coverage for game logic

class ChessRulesTests: XCTestCase {
    var engine: ChessRulesEngine!
    var state: ChessGameState!

    override func setUp() {
        super.setUp()
        engine = ChessRulesEngine()
        state = ChessGameState.newGame()
    }

    // Movement tests
    func testPawnInitialMove() { }
    func testPawnCapture() { }
    func testPawnEnPassant() { }
    func testPawnPromotion() { }

    func testKnightMovement() { }
    func testKnightJump() { }

    func testBishopDiagonal() { }
    func testRookStraight() { }
    func testQueenCombined() { }

    func testKingMovement() { }
    func testCastling() { }

    // Check detection
    func testCheckDetection() { }
    func testCheckmateDetection() { }
    func testStalemateDetection() { }

    // Illegal moves
    func testIllegalMoveIntoCheck() { }
    func testIllegalCastleInCheck() { }
    func testIllegalCastleThroughCheck() { }
}
```

### 10.2 Integration Tests

```swift
class GameplayIntegrationTests: XCTestCase {
    func testCompleteGameFlow() async throws {
        // Setup game
        let game = ChessGame()

        // Play sequence of moves
        try game.makeMove(from: "e2", to: "e4")
        try game.makeMove(from: "e7", to: "e5")
        try game.makeMove(from: "g1", to: "f3")

        // Verify state
        XCTAssertEqual(game.state.moveHistory.count, 3)
        XCTAssertEqual(game.state.currentPlayer, .black)
    }

    func testMultiplayerSync() async throws {
        // Create two game instances
        let player1 = GameSession()
        let player2 = GameSession()

        // Connect
        try await player1.connect(to: player2)

        // Player 1 makes move
        try await player1.makeMove(from: "e2", to: "e4")

        // Wait for sync
        try await Task.sleep(for: .milliseconds(100))

        // Verify player 2 sees move
        XCTAssertEqual(player2.state, player1.state)
    }
}
```

### 10.3 UI Tests

```swift
class ChessGameUITests: XCTestCase {
    func testPieceMovement() {
        let app = XCUIApplication()
        app.launch()

        // Start new game
        app.buttons["New Game"].tap()

        // Select white pawn
        let pawn = app.otherElements["piece_white_pawn_e2"]
        pawn.tap()

        // Verify selection highlight
        XCTAssertTrue(pawn.isSelected)

        // Move to e4
        app.otherElements["square_e4"].tap()

        // Verify move completed
        XCTAssertTrue(app.otherElements["piece_white_pawn_e4"].exists)
        XCTAssertFalse(app.otherElements["piece_white_pawn_e2"].exists)
    }
}
```

### 10.4 Performance Tests

```swift
class PerformanceTests: XCTestCase {
    func testFrameRate() {
        measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
            let app = XCUIApplication()
            app.launch()
        }
    }

    func testMemoryUsage() {
        measure(metrics: [XCTMemoryMetric()]) {
            // Load game assets
            let game = ChessGame()
            game.loadAssets()

            // Play 50 moves
            for _ in 0..<50 {
                game.makeRandomMove()
            }
        }
    }
}
```

---

## 11. Build Configurations

### 11.1 Debug Configuration

```yaml
debug:
  optimization_level: none
  swift_compilation_mode: incremental
  debug_symbols: yes
  assertions: enabled
  logging_level: verbose

  features:
    - debug_overlay
    - performance_metrics
    - state_inspector
    - network_simulator
```

### 11.2 Release Configuration

```yaml
release:
  optimization_level: aggressive
  swift_compilation_mode: whole_module
  debug_symbols: no
  assertions: disabled
  logging_level: error

  features:
    - analytics
    - crash_reporting
```

---

## 12. Deployment

### 12.1 App Store Requirements

```yaml
app_store:
  bundle_id: com.holographicgames.boardgames
  version: 1.0.0
  minimum_os: visionOS 2.0

  capabilities:
    - Hand Tracking
    - Eye Tracking
    - Spatial Audio
    - SharePlay
    - Game Center
    - iCloud

  privacy:
    - NSHandsTrackingUsageDescription: "Hand tracking for natural piece movement"
    - NSEyeTrackingUsageDescription: "Eye tracking for interface navigation"

  entitlements:
    - com.apple.developer.arkit.hand-tracking
    - com.apple.developer.group-activities
    - com.apple.developer.icloud-container-identifiers
```

---

*This technical specification provides the detailed requirements for implementing Holographic Board Games on visionOS.*
