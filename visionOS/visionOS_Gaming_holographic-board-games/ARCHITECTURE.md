# Holographic Board Games - Technical Architecture

## Document Overview
This document defines the comprehensive technical architecture for Holographic Board Games, a visionOS gaming platform that transforms classic board games into living spatial experiences.

**Version:** 1.0
**Last Updated:** 2025-01-20
**Target Platform:** visionOS 2.0+

---

## 1. System Architecture Overview

### 1.1 High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Application Layer                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │  Game Scenes │  │  UI/UX Layer │  │  Multiplayer Sync    │  │
│  └──────────────┘  └──────────────┘  └──────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────────┐
│                      Game Engine Layer                           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │  Game Loop   │  │ State Manager│  │  ECS Framework       │  │
│  └──────────────┘  └──────────────┘  └──────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────────┐
│                       Systems Layer                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │Physics System│  │ Input System │  │  Audio System        │  │
│  │Animation Sys.│  │ AI System    │  │  Persistence System  │  │
│  └──────────────┘  └──────────────┘  └──────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────────┐
│                     Platform Layer (visionOS)                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │  RealityKit  │  │    ARKit     │  │   SwiftUI            │  │
│  │  AVFoundation│  │  SharePlay   │  │   GameplayKit        │  │
│  └──────────────┘  └──────────────┘  └──────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

### 1.2 Core Architectural Principles

1. **Entity-Component-System (ECS)**: Game entities are data-driven with reusable components
2. **Separation of Concerns**: Clear boundaries between rendering, logic, and data
3. **Event-Driven Architecture**: Decoupled systems communicate via events
4. **State Machine Pattern**: Game states managed through explicit state machines
5. **Dependency Injection**: Testable and modular component design

---

## 2. Game Architecture

### 2.1 Game Loop

The core game loop runs at 60-90 FPS and follows this structure:

```swift
protocol GameLoopProtocol {
    func update(deltaTime: TimeInterval)
    func fixedUpdate(deltaTime: TimeInterval)  // Physics at fixed timestep
    func lateUpdate()                           // Post-update cleanup
}

class GameLoop {
    private let targetFPS: Double = 90.0
    private var lastUpdateTime: TimeInterval = 0
    private var accumulator: TimeInterval = 0
    private let fixedDeltaTime: TimeInterval = 1.0 / 60.0

    func run() {
        CADisplayLink.run { [weak self] displayLink in
            guard let self = self else { return }

            let currentTime = displayLink.timestamp
            let deltaTime = currentTime - self.lastUpdateTime
            self.lastUpdateTime = currentTime

            // Variable update for rendering
            self.update(deltaTime: deltaTime)

            // Fixed update for physics
            self.accumulator += deltaTime
            while self.accumulator >= self.fixedDeltaTime {
                self.fixedUpdate(deltaTime: self.fixedDeltaTime)
                self.accumulator -= self.fixedDeltaTime
            }

            // Late update for camera and final adjustments
            self.lateUpdate()
        }
    }
}
```

### 2.2 State Management System

```swift
enum GameState {
    case mainMenu
    case gameSetup
    case playing
    case paused
    case gameOver
    case tutorial
}

protocol GameStateProtocol {
    func onEnter()
    func onUpdate(deltaTime: TimeInterval)
    func onExit()
    func handleInput(_ input: GameInput) -> GameState?
}

class GameStateManager {
    private var currentState: GameStateProtocol
    private var stateHistory: [GameState] = []

    func transition(to newState: GameStateProtocol) {
        currentState.onExit()
        currentState = newState
        currentState.onEnter()
    }
}
```

### 2.3 Entity-Component-System (ECS)

```swift
// Entity
struct Entity {
    let id: UUID
    var components: [Component]
}

// Component Protocol
protocol Component: AnyObject {
    var entity: Entity? { get set }
}

// Example Components
class TransformComponent: Component {
    var entity: Entity?
    var position: SIMD3<Float>
    var rotation: simd_quatf
    var scale: SIMD3<Float> = [1, 1, 1]
}

class ChessPieceComponent: Component {
    var entity: Entity?
    var pieceType: ChessPieceType
    var color: PlayerColor
    var hasMoved: Bool = false
}

class AnimationComponent: Component {
    var entity: Entity?
    var currentAnimation: String?
    var animationQueue: [Animation] = []
}

// System Protocol
protocol System {
    var priority: Int { get }
    func update(entities: [Entity], deltaTime: TimeInterval)
}

// Example System
class MovementSystem: System {
    let priority = 10

    func update(entities: [Entity], deltaTime: TimeInterval) {
        for entity in entities {
            guard let transform = entity.component(ofType: TransformComponent.self),
                  let movement = entity.component(ofType: MovementComponent.self) else {
                continue
            }

            transform.position += movement.velocity * Float(deltaTime)
        }
    }
}
```

### 2.4 Event System

```swift
protocol GameEvent {
    var timestamp: Date { get }
}

struct PieceMoveEvent: GameEvent {
    let timestamp = Date()
    let piece: Entity
    let fromPosition: BoardPosition
    let toPosition: BoardPosition
}

struct PieceCaptureEvent: GameEvent {
    let timestamp = Date()
    let attacker: Entity
    let defender: Entity
}

class EventBus {
    static let shared = EventBus()

    private var subscribers: [String: [(GameEvent) -> Void]] = [:]

    func subscribe<T: GameEvent>(
        _ eventType: T.Type,
        handler: @escaping (T) -> Void
    ) -> UUID {
        let key = String(describing: eventType)
        let id = UUID()

        subscribers[key, default: []].append { event in
            if let typedEvent = event as? T {
                handler(typedEvent)
            }
        }

        return id
    }

    func publish<T: GameEvent>(_ event: T) {
        let key = String(describing: T.self)
        subscribers[key]?.forEach { $0(event) }
    }
}
```

---

## 3. visionOS-Specific Architecture

### 3.1 Spatial Modes

The app supports multiple spatial modes based on game type:

```swift
enum SpatialMode {
    case window      // Traditional 2D UI (menus, settings)
    case volume      // 3D bounded space (chess board, card games)
    case immersive   // Full immersive (future D&D campaigns)
}

protocol SpatialScene {
    var mode: SpatialMode { get }
    var volumeSize: SIMD3<Float>? { get }  // For volume mode
    var immersionStyle: ImmersionStyle? { get }  // For immersive mode
}
```

### 3.2 RealityKit Scene Graph

```swift
class BoardGameScene {
    // Root entities
    let rootEntity: Entity
    let boardEntity: Entity
    let piecesEntity: Entity
    let uiEntity: Entity
    let environmentEntity: Entity

    // Anchoring
    let tableAnchor: AnchorEntity

    init() {
        // Create scene hierarchy
        rootEntity = Entity()

        // Board anchor to table surface
        tableAnchor = AnchorEntity(.plane(.horizontal, classification: .table))
        rootEntity.addChild(tableAnchor)

        // Board container
        boardEntity = Entity()
        tableAnchor.addChild(boardEntity)

        // Pieces container
        piecesEntity = Entity()
        boardEntity.addChild(piecesEntity)

        // UI elements
        uiEntity = Entity()
        rootEntity.addChild(uiEntity)

        // Environment (lighting, effects)
        environmentEntity = Entity()
        rootEntity.addChild(environmentEntity)
    }
}
```

### 3.3 Hand Tracking Integration

```swift
class HandTrackingInputSystem: System {
    let priority = 100  // High priority for input

    private var currentGesture: GestureState = .idle

    enum GestureState {
        case idle
        case hovering(entity: Entity)
        case grabbing(entity: Entity, offset: SIMD3<Float>)
        case dragging(entity: Entity)
    }

    func update(entities: [Entity], deltaTime: TimeInterval) {
        guard let handTracking = ARKitSession.shared.handTracking else { return }

        // Process hand joints
        if let rightHand = handTracking.rightHand {
            processHand(rightHand, entities: entities)
        }

        if let leftHand = handTracking.leftHand {
            processHand(leftHand, entities: entities)
        }
    }

    private func processHand(_ hand: HandAnchor, entities: [Entity]) {
        // Detect pinch gesture
        let thumbTip = hand.joint(.thumbTip)
        let indexTip = hand.joint(.indexFingerTip)

        let distance = simd_distance(thumbTip.position, indexTip.position)
        let isPinching = distance < 0.02  // 2cm threshold

        // Ray cast from hand
        let rayOrigin = indexTip.position
        let rayDirection = hand.transform.forward

        // Check for entity intersection
        if let hitEntity = raycast(from: rayOrigin, direction: rayDirection, in: entities) {
            handleEntityInteraction(hitEntity, isPinching: isPinching)
        }
    }
}
```

---

## 4. Game Data Models

### 4.1 Chess Game Model

```swift
// Board representation
struct BoardPosition: Hashable, Codable {
    let file: Int  // 0-7 (a-h)
    let rank: Int  // 0-7 (1-8)

    var algebraic: String {
        let files = ["a", "b", "c", "d", "e", "f", "g", "h"]
        return "\(files[file])\(rank + 1)"
    }
}

enum ChessPieceType: String, Codable {
    case pawn, knight, bishop, rook, queen, king
}

enum PlayerColor: String, Codable {
    case white, black
}

struct ChessPiece: Codable {
    let id: UUID
    let type: ChessPieceType
    let color: PlayerColor
    var position: BoardPosition
    var hasMoved: Bool = false
}

// Game state
struct ChessGameState: Codable {
    var pieces: [UUID: ChessPiece]
    var board: [[UUID?]]  // 8x8 grid
    var currentPlayer: PlayerColor
    var moveHistory: [ChessMove]
    var capturedPieces: [ChessPiece]
    var gameStatus: GameStatus

    enum GameStatus: Codable {
        case inProgress
        case check(PlayerColor)
        case checkmate(winner: PlayerColor)
        case stalemate
        case draw
    }
}

struct ChessMove: Codable {
    let id: UUID
    let piece: ChessPiece
    let from: BoardPosition
    let to: BoardPosition
    let capturedPiece: ChessPiece?
    let isCheck: Bool
    let isCheckmate: Bool
    let isCastle: Bool
    let isEnPassant: Bool
    let promotion: ChessPieceType?
    let timestamp: Date
}
```

### 4.2 Universal Board Game Schema

```swift
protocol BoardGame {
    associatedtype GameStateType: Codable
    associatedtype MoveType: Codable

    var id: UUID { get }
    var name: String { get }
    var playerCount: ClosedRange<Int> { get }
    var currentState: GameStateType { get set }

    func isValidMove(_ move: MoveType) -> Bool
    func applyMove(_ move: MoveType) throws
    func undoMove() throws
    func checkWinCondition() -> GameResult?
}

enum GameResult {
    case winner(playerID: UUID)
    case draw
    case ongoing
}
```

---

## 5. Systems Architecture

### 5.1 Physics System

```swift
class PhysicsSystem: System {
    let priority = 50

    private let physicsWorld: PhysicsWorld

    func update(entities: [Entity], deltaTime: TimeInterval) {
        // Update physics simulation
        physicsWorld.step(deltaTime: deltaTime)

        // Sync physics transforms to entities
        for entity in entities {
            guard let transform = entity.component(ofType: TransformComponent.self),
                  let physics = entity.component(ofType: PhysicsComponent.self) else {
                continue
            }

            // Update entity transform from physics body
            transform.position = physics.body.position
            transform.rotation = physics.body.rotation
        }

        // Handle collisions
        processCollisions()
    }

    private func processCollisions() {
        for collision in physicsWorld.collisions {
            EventBus.shared.publish(CollisionEvent(
                entityA: collision.bodyA.entity,
                entityB: collision.bodyB.entity
            ))
        }
    }
}
```

### 5.2 Animation System

```swift
class AnimationSystem: System {
    let priority = 20

    func update(entities: [Entity], deltaTime: TimeInterval) {
        for entity in entities {
            guard let animation = entity.component(ofType: AnimationComponent.self),
                  let modelEntity = entity.component(ofType: ModelComponent.self) else {
                continue
            }

            // Update current animation
            if let current = animation.currentAnimation {
                updateAnimation(current, deltaTime: deltaTime, on: modelEntity)
            }

            // Process animation queue
            if animation.currentAnimation == nil && !animation.animationQueue.isEmpty {
                let next = animation.animationQueue.removeFirst()
                playAnimation(next, on: modelEntity)
                animation.currentAnimation = next.name
            }
        }
    }

    func playAnimation(_ animation: Animation, on model: ModelComponent) {
        // Trigger RealityKit animation
        model.entity?.playAnimation(animation)
    }
}
```

### 5.3 Audio System

```swift
class SpatialAudioSystem: System {
    let priority = 30

    private let audioEngine: AVAudioEngine
    private let environmentNode: AVAudioEnvironmentNode

    func update(entities: [Entity], deltaTime: TimeInterval) {
        for entity in entities {
            guard let audio = entity.component(ofType: AudioComponent.self),
                  let transform = entity.component(ofType: TransformComponent.self) else {
                continue
            }

            // Update spatial audio position
            updateSpatialPosition(audio, at: transform.position)
        }
    }

    func playSoundEffect(_ sound: SoundEffect, at position: SIMD3<Float>) {
        let audioSource = AVAudioPlayerNode()
        audioEngine.attach(audioSource)

        // Configure spatial audio
        audioEngine.connect(
            audioSource,
            to: environmentNode,
            format: sound.audioFormat
        )

        // Set 3D position
        environmentNode.position = AVAudio3DPoint(
            x: position.x,
            y: position.y,
            z: position.z
        )

        audioSource.scheduleFile(sound.audioFile, at: nil)
        audioSource.play()
    }
}
```

---

## 6. Multiplayer Architecture

### 6.1 SharePlay Integration

```swift
@Observable
class MultiplayerSession {
    private var groupSession: GroupSession<GameActivity>?
    private var messenger: GroupSessionMessenger?
    private var reliableMessenger: GroupSessionMessenger?

    struct GameActivity: GroupActivity {
        let gameID: UUID
        let gameType: GameType

        var metadata: GroupActivityMetadata {
            var metadata = GroupActivityMetadata()
            metadata.title = "Holographic Board Game"
            metadata.type = .generic
            return metadata
        }
    }

    func startSharing() async throws {
        let activity = GameActivity(
            gameID: UUID(),
            gameType: .chess
        )

        switch await activity.prepareForActivation() {
        case .activationPreferred:
            _ = try await activity.activate()
        case .activationDisabled:
            throw MultiplayerError.sharingDisabled
        case .cancelled:
            throw MultiplayerError.cancelled
        }
    }

    func configureSession(_ session: GroupSession<GameActivity>) {
        groupSession = session
        messenger = GroupSessionMessenger(session: session)
        reliableMessenger = GroupSessionMessenger(
            session: session,
            deliveryMode: .reliable
        )

        session.join()

        // Listen for participants
        Task {
            for await participants in session.$activeParticipants.values {
                handleParticipantsChanged(participants)
            }
        }
    }
}
```

### 6.2 Network Synchronization

```swift
protocol NetworkMessage: Codable {
    var messageID: UUID { get }
    var timestamp: Date { get }
    var senderID: UUID { get }
}

struct MoveMessage: NetworkMessage {
    let messageID = UUID()
    let timestamp = Date()
    let senderID: UUID
    let move: ChessMove
}

struct StateSnapshotMessage: NetworkMessage {
    let messageID = UUID()
    let timestamp = Date()
    let senderID: UUID
    let gameState: ChessGameState
    let stateHash: String
}

class NetworkSyncManager {
    private let messenger: GroupSessionMessenger
    private var messageQueue: [NetworkMessage] = []

    // Send move to all players
    func broadcastMove(_ move: ChessMove) async throws {
        let message = MoveMessage(senderID: localPlayerID, move: move)
        try await messenger.send(message)
    }

    // Receive moves from other players
    func startReceiving() async {
        for await (message, context) in messenger.messages(of: MoveMessage.self) {
            handleReceivedMove(message, from: context.source)
        }
    }

    // Conflict resolution using vector clocks
    private func resolveConflict(
        localState: ChessGameState,
        remoteState: ChessGameState
    ) -> ChessGameState {
        // Host has authority
        return isHost ? localState : remoteState
    }
}
```

---

## 7. AI Architecture

### 7.1 Rule Engine

```swift
protocol GameRules {
    func validateMove(_ move: ChessMove, in state: ChessGameState) -> ValidationResult
    func generateLegalMoves(for piece: ChessPiece, in state: ChessGameState) -> [ChessMove]
    func isKingInCheck(color: PlayerColor, in state: ChessGameState) -> Bool
}

enum ValidationResult {
    case valid
    case invalid(reason: String)
}

class ChessRulesEngine: GameRules {
    func validateMove(_ move: ChessMove, in state: ChessGameState) -> ValidationResult {
        // Validate piece can move to destination
        guard isLegalPieceMove(move, in: state) else {
            return .invalid(reason: "Illegal move for \(move.piece.type)")
        }

        // Validate path is clear
        guard isPathClear(from: move.from, to: move.to, in: state) else {
            return .invalid(reason: "Path is blocked")
        }

        // Validate move doesn't put own king in check
        var testState = state
        try? applyMove(move, to: &testState)

        if isKingInCheck(color: move.piece.color, in: testState) {
            return .invalid(reason: "Move puts king in check")
        }

        return .valid
    }

    func generateLegalMoves(for piece: ChessPiece, in state: ChessGameState) -> [ChessMove] {
        var moves: [ChessMove] = []

        // Generate all possible moves based on piece type
        let candidates = generateCandidateMoves(for: piece)

        // Filter to only legal moves
        for candidate in candidates {
            if case .valid = validateMove(candidate, in: state) {
                moves.append(candidate)
            }
        }

        return moves
    }
}
```

### 7.2 AI Opponent System

```swift
protocol AIPlayer {
    var difficulty: Difficulty { get }
    func chooseMove(from legalMoves: [ChessMove], state: ChessGameState) async -> ChessMove
}

enum Difficulty {
    case beginner
    case intermediate
    case advanced
    case expert
}

class ChessAI: AIPlayer {
    let difficulty: Difficulty

    func chooseMove(from legalMoves: [ChessMove], state: ChessGameState) async -> ChessMove {
        switch difficulty {
        case .beginner:
            return chooseRandomMove(from: legalMoves)
        case .intermediate:
            return chooseMaterialMove(from: legalMoves, state: state)
        case .advanced, .expert:
            return await minimax(state: state, depth: difficulty.searchDepth)
        }
    }

    // Minimax with alpha-beta pruning
    private func minimax(
        state: ChessGameState,
        depth: Int,
        alpha: Float = -.infinity,
        beta: Float = .infinity,
        isMaximizing: Bool = true
    ) async -> ChessMove {
        // AI decision tree implementation
        // Returns best move based on position evaluation
        fatalError("Implement minimax")
    }

    private func evaluatePosition(_ state: ChessGameState) -> Float {
        var score: Float = 0

        // Material evaluation
        for piece in state.pieces.values {
            let value = pieceValue(piece.type)
            score += piece.color == .white ? value : -value
        }

        // Positional evaluation
        // Center control, king safety, pawn structure, etc.

        return score
    }
}
```

### 7.3 Tutorial System

```swift
class TutorialSystem {
    private var currentStep: TutorialStep?
    private let highlightSystem: HighlightSystem

    struct TutorialStep {
        let id: String
        let instruction: String
        let highlightEntities: [Entity]
        let expectedAction: ExpectedAction
        let completionHandler: () -> Void
    }

    enum ExpectedAction {
        case selectPiece(ChessPieceType)
        case movePiece(from: BoardPosition, to: BoardPosition)
        case completeMove
    }

    func startTutorial(type: TutorialType) {
        switch type {
        case .basicChess:
            startBasicChessTutorial()
        case .castling:
            startCastlingTutorial()
        case .enPassant:
            startEnPassantTutorial()
        }
    }

    private func startBasicChessTutorial() {
        let steps = [
            TutorialStep(
                id: "move_pawn",
                instruction: "Move the pawn forward two squares",
                highlightEntities: [getPawn(at: "e2")],
                expectedAction: .movePiece(from: BoardPosition("e2"), to: BoardPosition("e4")),
                completionHandler: { self.nextStep() }
            ),
            // More steps...
        ]

        executeSteps(steps)
    }
}
```

---

## 8. Persistence Architecture

### 8.1 Local Storage

```swift
class GamePersistenceManager {
    private let fileManager = FileManager.default
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    func saveGame(_ state: ChessGameState, id: UUID) throws {
        let data = try encoder.encode(state)
        let url = getSaveURL(for: id)
        try data.write(to: url)
    }

    func loadGame(id: UUID) throws -> ChessGameState {
        let url = getSaveURL(for: id)
        let data = try Data(contentsOf: url)
        return try decoder.decode(ChessGameState.self, from: data)
    }

    func listSavedGames() throws -> [SavedGame] {
        let directory = getSavesDirectory()
        let files = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: [.creationDateKey])

        return try files.map { url in
            let attributes = try fileManager.attributesOfItem(atPath: url.path)
            return SavedGame(
                id: UUID(uuidString: url.deletingPathExtension().lastPathComponent)!,
                createdAt: attributes[.creationDate] as! Date,
                modifiedAt: attributes[.modificationDate] as! Date
            )
        }
    }
}
```

### 8.2 CloudKit Sync

```swift
class CloudSyncManager {
    private let container = CKContainer.default()
    private let database: CKDatabase

    init() {
        database = container.privateCloudDatabase
    }

    func syncGameState(_ state: ChessGameState) async throws {
        let record = CKRecord(recordType: "GameState")
        record["gameID"] = state.id.uuidString
        record["stateData"] = try JSONEncoder().encode(state)
        record["lastModified"] = Date()

        try await database.save(record)
    }

    func fetchLatestState(gameID: UUID) async throws -> ChessGameState {
        let predicate = NSPredicate(format: "gameID == %@", gameID.uuidString)
        let query = CKQuery(recordType: "GameState", predicate: predicate)

        let results = try await database.records(matching: query)
        guard let record = results.matchResults.first?.1.get(),
              let data = record["stateData"] as? Data else {
            throw PersistenceError.notFound
        }

        return try JSONDecoder().decode(ChessGameState.self, from: data)
    }
}
```

---

## 9. Performance Optimization

### 9.1 Object Pooling

```swift
class ObjectPool<T> {
    private var available: [T] = []
    private var inUse: Set<ObjectIdentifier> = []
    private let factory: () -> T

    init(initialSize: Int = 10, factory: @escaping () -> T) {
        self.factory = factory
        for _ in 0..<initialSize {
            available.append(factory())
        }
    }

    func acquire() -> T {
        if available.isEmpty {
            return factory()
        }

        let object = available.removeLast()
        inUse.insert(ObjectIdentifier(object as AnyObject))
        return object
    }

    func release(_ object: T) {
        inUse.remove(ObjectIdentifier(object as AnyObject))
        available.append(object)
    }
}

// Usage
class EntityPool {
    private let piecePool = ObjectPool<ChessPieceEntity>(initialSize: 32) {
        ChessPieceEntity()
    }

    func spawnPiece(type: ChessPieceType, color: PlayerColor) -> ChessPieceEntity {
        let piece = piecePool.acquire()
        piece.configure(type: type, color: color)
        return piece
    }

    func despawnPiece(_ piece: ChessPieceEntity) {
        piece.reset()
        piecePool.release(piece)
    }
}
```

### 9.2 Level of Detail (LOD)

```swift
class LODSystem: System {
    let priority = 5

    enum DetailLevel {
        case high    // Full detail, all features
        case medium  // Simplified models, basic animations
        case low     // Minimal geometry, no animations
    }

    func update(entities: [Entity], deltaTime: TimeInterval) {
        guard let cameraPosition = getMainCameraPosition() else { return }

        for entity in entities {
            guard let transform = entity.component(ofType: TransformComponent.self),
                  let lod = entity.component(ofType: LODComponent.self) else {
                continue
            }

            let distance = simd_distance(transform.position, cameraPosition)
            let newLevel = determineDetailLevel(distance: distance)

            if newLevel != lod.currentLevel {
                updateDetailLevel(entity, to: newLevel)
                lod.currentLevel = newLevel
            }
        }
    }

    private func determineDetailLevel(distance: Float) -> DetailLevel {
        switch distance {
        case 0..<1.0:
            return .high
        case 1.0..<3.0:
            return .medium
        default:
            return .low
        }
    }
}
```

### 9.3 Render Optimization

```swift
class RenderOptimizationSystem {
    // Occlusion culling
    func cullInvisibleEntities(entities: [Entity], camera: Camera) -> [Entity] {
        entities.filter { entity in
            guard let transform = entity.component(ofType: TransformComponent.self),
                  let bounds = entity.component(ofType: BoundsComponent.self) else {
                return false
            }

            return camera.frustum.contains(bounds.boundingBox, at: transform.position)
        }
    }

    // Batch rendering for similar pieces
    func batchRenderPieces(_ pieces: [Entity]) {
        var batches: [MaterialKey: [Entity]] = [:]

        for piece in pieces {
            guard let model = piece.component(ofType: ModelComponent.self) else {
                continue
            }

            let key = MaterialKey(material: model.material)
            batches[key, default: []].append(piece)
        }

        // Render each batch together
        for (_, batch) in batches {
            renderBatch(batch)
        }
    }
}
```

---

## 10. Testing Architecture

### 10.1 Unit Testing

```swift
// Game logic tests
class ChessRulesTests: XCTestCase {
    var rulesEngine: ChessRulesEngine!
    var gameState: ChessGameState!

    override func setUp() {
        rulesEngine = ChessRulesEngine()
        gameState = ChessGameState.newGame()
    }

    func testPawnCanMoveForwardTwo() {
        let pawn = gameState.pieces.values.first { $0.type == .pawn && $0.color == .white }!
        let move = ChessMove(
            piece: pawn,
            from: BoardPosition("e2"),
            to: BoardPosition("e4")
        )

        let result = rulesEngine.validateMove(move, in: gameState)
        XCTAssertEqual(result, .valid)
    }

    func testKnightCanJumpOverPieces() {
        let knight = gameState.pieces.values.first { $0.type == .knight && $0.color == .white }!
        let move = ChessMove(
            piece: knight,
            from: BoardPosition("b1"),
            to: BoardPosition("c3")
        )

        let result = rulesEngine.validateMove(move, in: gameState)
        XCTAssertEqual(result, .valid)
    }
}
```

### 10.2 Integration Testing

```swift
class MultiplayerIntegrationTests: XCTestCase {
    func testMovesSyncBetweenPlayers() async throws {
        let player1 = createMockPlayer(id: UUID())
        let player2 = createMockPlayer(id: UUID())

        let session = MultiplayerSession()

        // Player 1 makes move
        let move = ChessMove(/* ... */)
        try await session.broadcastMove(move)

        // Verify player 2 receives move
        let receivedMove = await player2.waitForMove(timeout: 5.0)
        XCTAssertEqual(receivedMove, move)
    }
}
```

### 10.3 UI Testing

```swift
class ChessGameUITests: XCTestCase {
    func testPieceSelection() {
        let app = XCUIApplication()
        app.launch()

        // Tap on white pawn
        let pawn = app.otherElements["chess_piece_white_pawn_e2"]
        pawn.tap()

        // Verify piece is highlighted
        XCTAssertTrue(pawn.isSelected)

        // Tap destination
        let destination = app.otherElements["board_square_e4"]
        destination.tap()

        // Verify piece moved
        XCTAssertTrue(app.otherElements["chess_piece_white_pawn_e4"].exists)
    }
}
```

---

## 11. Security & Privacy

### 11.1 Anti-Cheat System

```swift
class AntiCheatSystem {
    private let moveValidator: ChessRulesEngine
    private let stateHasher: StateHasher

    func validateRemoteMove(_ move: MoveMessage) -> ValidationResult {
        // Verify move is legal
        let validation = moveValidator.validateMove(move.move, in: currentState)
        guard case .valid = validation else {
            reportSuspiciousActivity(
                playerID: move.senderID,
                reason: "Illegal move attempted"
            )
            return .invalid(reason: "Illegal move")
        }

        // Verify state hash matches
        let expectedHash = stateHasher.hash(currentState)
        if move.stateHash != expectedHash {
            reportSuspiciousActivity(
                playerID: move.senderID,
                reason: "State hash mismatch"
            )
            return .invalid(reason: "State desync detected")
        }

        return .valid
    }
}
```

### 11.2 Privacy Protection

```swift
class PrivacyManager {
    // No spatial data is collected or transmitted
    // All game data stays on device unless explicitly synced via iCloud

    func sanitizeGameData(_ state: ChessGameState) -> ChessGameState {
        var sanitized = state
        // Remove any player-identifiable information
        sanitized.playerNames = nil
        return sanitized
    }

    func requestDataExport() async throws -> Data {
        // GDPR compliance - export all user data
        let allSaves = try GamePersistenceManager.shared.listSavedGames()
        return try JSONEncoder().encode(allSaves)
    }

    func deleteAllUserData() async throws {
        // GDPR compliance - delete all user data
        try GamePersistenceManager.shared.deleteAllSaves()
        try await CloudSyncManager.shared.deleteAllRecords()
    }
}
```

---

## 12. Deployment Architecture

### 12.1 App Distribution

```swift
// Build configurations
enum BuildConfiguration {
    case debug
    case testflight
    case appStore

    var apiEndpoint: URL {
        switch self {
        case .debug:
            return URL(string: "https://dev-api.holographicgames.com")!
        case .testflight:
            return URL(string: "https://staging-api.holographicgames.com")!
        case .appStore:
            return URL(string: "https://api.holographicgames.com")!
        }
    }
}
```

### 12.2 Crash Reporting

```swift
class CrashReporter {
    static func initialize() {
        NSSetUncaughtExceptionHandler { exception in
            logCrash(exception: exception)
        }

        signal(SIGSEGV) { signal in
            logCrash(signal: signal)
        }
    }

    private static func logCrash(exception: NSException) {
        let report = CrashReport(
            exception: exception,
            stackTrace: Thread.callStackSymbols,
            deviceInfo: getDeviceInfo(),
            gameState: captureGameState()
        )

        // Save locally
        try? saveCrashReport(report)

        // Send to backend when network available
        Task {
            try? await uploadCrashReport(report)
        }
    }
}
```

---

## Appendix A: Technology Stack

### Core Technologies
- **Language**: Swift 6.0+
- **UI Framework**: SwiftUI
- **3D Rendering**: RealityKit 2.0+
- **AR Framework**: ARKit 6+
- **Audio**: AVFoundation (Spatial Audio)
- **Networking**: GroupActivities (SharePlay)
- **Persistence**: CoreData, CloudKit
- **Game Logic**: GameplayKit (optional)

### Development Tools
- **IDE**: Xcode 16+
- **Version Control**: Git
- **CI/CD**: Xcode Cloud
- **Testing**: XCTest
- **Profiling**: Instruments

### Third-Party Libraries
- None required (all built with native frameworks)

---

## Appendix B: Performance Targets

| Metric | Target | Critical |
|--------|--------|----------|
| Frame Rate | 90 FPS | 60 FPS |
| Memory Usage | < 1.5 GB | < 2 GB |
| App Launch | < 2s | < 3s |
| Game Load | < 1s | < 2s |
| Network Latency | < 50ms | < 100ms |
| Hand Tracking | < 16ms | < 33ms |
| Audio Latency | < 20ms | < 50ms |

---

*This architecture document provides the technical foundation for building Holographic Board Games as a robust, performant, and maintainable visionOS application.*
