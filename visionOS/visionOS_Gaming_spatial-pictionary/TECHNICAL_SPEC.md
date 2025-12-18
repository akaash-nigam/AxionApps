# Spatial Pictionary - Technical Specifications

## Document Information
- **Version**: 1.0
- **Last Updated**: 2025-11-19
- **Platform**: Apple Vision Pro
- **Minimum visionOS**: 2.0
- **Target Release**: Q1 2026

---

## Table of Contents
1. [Technology Stack](#technology-stack)
2. [Game Mechanics Implementation](#game-mechanics-implementation)
3. [Control Schemes](#control-schemes)
4. [Physics Specifications](#physics-specifications)
5. [Rendering Requirements](#rendering-requirements)
6. [Multiplayer/Networking Specifications](#multiplayernetworking-specifications)
7. [Performance Budgets](#performance-budgets)
8. [Testing Requirements](#testing-requirements)
9. [Development Tools & Environment](#development-tools--environment)
10. [API & Framework Usage](#api--framework-usage)

---

## 1. Technology Stack

### Core Technologies

```yaml
language:
  primary: Swift 6.0
  features:
    - strict_concurrency: enabled
    - actors: true
    - async_await: true
    - observation_framework: true

frameworks:
  ui:
    - SwiftUI 6.0+ (Menu system, HUD, settings)
    - RealityKit 4.0+ (3D rendering, entities, materials)
    - RealityKitContent (Asset loading)

  spatial:
    - ARKit 6.0+ (Hand tracking, world tracking)
    - visionOS SDK 2.0+
    - Spatial Framework (Coordinate systems)

  game_logic:
    - Observation (State management)
    - Combine (Reactive programming)
    - Foundation (Core utilities)

  multiplayer:
    - GroupActivities (SharePlay)
    - Network (Low-level networking)
    - MultipeerConnectivity (Local mesh network)

  audio:
    - AVFoundation (Spatial audio playback)
    - SpatialAudio (3D sound positioning)

  persistence:
    - SwiftData (Game session storage)
    - CloudKit (iCloud sync)
    - FileManager (Drawing export)

platform:
  deployment_target: visionOS 2.0
  development_target: visionOS 2.1
  architectures: [arm64]
  devices: [Apple Vision Pro]

build_system:
  type: Xcode 16.0+
  swift_version: "6.0"
  minimum_macos: "15.0"
```

### Third-Party Dependencies

```swift
// Package.swift dependencies
dependencies: [
    // None for MVP - using Apple frameworks only
    // Future consideration:
    // - Swift Algorithms (for advanced geometry)
    // - Swift Collections (for efficient data structures)
]
```

### Development Environment

```yaml
required_tools:
  - name: Xcode
    version: "16.0+"
    reason: visionOS development

  - name: Reality Composer Pro
    version: "2.0+"
    reason: 3D asset creation

  - name: Instruments
    version: "16.0+"
    reason: Performance profiling

  - name: Create ML
    version: "6.0+"
    reason: AI model training (future)

optional_tools:
  - name: Blender
    version: "4.0+"
    reason: 3D model creation

  - name: SF Symbols
    version: "6.0+"
    reason: UI iconography
```

---

## 2. Game Mechanics Implementation

### Drawing System Technical Specification

```swift
/// Core drawing engine specifications
class DrawingEngine {
    // MARK: - Performance Requirements

    /// Maximum points per stroke before automatic segmentation
    static let maxPointsPerStroke: Int = 1000

    /// Minimum distance between points to avoid over-sampling
    static let minPointDistance: Float = 0.002 // 2mm

    /// Maximum distance between points before interpolation
    static let maxPointDistance: Float = 0.02 // 2cm

    /// Target stroke update frequency
    static let updateFrequency: Double = 90.0 // Hz

    // MARK: - Drawing Algorithms

    /// Catmull-Rom spline for smooth curves
    func interpolatePoints(_ points: [SIMD3<Float>]) -> [SIMD3<Float>] {
        guard points.count >= 4 else { return points }

        var smoothed: [SIMD3<Float>] = []
        let segments = 8 // Points per spline segment

        for i in 0..<(points.count - 3) {
            let p0 = points[i]
            let p1 = points[i + 1]
            let p2 = points[i + 2]
            let p3 = points[i + 3]

            for t in 0..<segments {
                let t_normalized = Float(t) / Float(segments)
                let point = catmullRom(p0: p0, p1: p1, p2: p2, p3: p3, t: t_normalized)
                smoothed.append(point)
            }
        }

        return smoothed
    }

    /// Catmull-Rom interpolation
    private func catmullRom(p0: SIMD3<Float>, p1: SIMD3<Float>,
                           p2: SIMD3<Float>, p3: SIMD3<Float>,
                           t: Float) -> SIMD3<Float> {
        let t2 = t * t
        let t3 = t2 * t

        return 0.5 * (
            (2 * p1) +
            (-p0 + p2) * t +
            (2 * p0 - 5 * p1 + 4 * p2 - p3) * t2 +
            (-p0 + 3 * p1 - 3 * p2 + p3) * t3
        )
    }

    /// Generate tube mesh from stroke points
    func generateStrokeMesh(points: [SIMD3<Float>],
                          radius: Float,
                          segments: Int = 8) -> MeshResource {
        var vertices: [SIMD3<Float>] = []
        var normals: [SIMD3<Float>] = []
        var indices: [UInt32] = []

        // Create cylindrical mesh along stroke path
        for (index, point) in points.enumerated() {
            let direction = getStrokeDirection(at: index, in: points)
            let right = normalize(cross(direction, SIMD3<Float>(0, 1, 0)))
            let up = normalize(cross(right, direction))

            // Create circle of vertices
            for segment in 0..<segments {
                let angle = Float(segment) * 2.0 * .pi / Float(segments)
                let offset = right * cos(angle) * radius + up * sin(angle) * radius
                vertices.append(point + offset)
                normals.append(normalize(offset))
            }

            // Create triangle strip indices
            if index > 0 {
                for segment in 0..<segments {
                    let current = UInt32(index * segments + segment)
                    let next = UInt32(index * segments + (segment + 1) % segments)
                    let prevCurrent = UInt32((index - 1) * segments + segment)
                    let prevNext = UInt32((index - 1) * segments + (segment + 1) % segments)

                    indices.append(contentsOf: [current, prevCurrent, next])
                    indices.append(contentsOf: [next, prevCurrent, prevNext])
                }
            }
        }

        var descriptor = MeshDescriptor()
        descriptor.positions = MeshBuffer(vertices)
        descriptor.normals = MeshBuffer(normals)
        descriptor.primitives = .triangles(indices)

        return try! MeshResource.generate(from: [descriptor])
    }
}
```

### Turn-Based Game Logic

```swift
/// Turn management system
@Observable
class TurnManager {
    // MARK: - Configuration

    /// Default round duration
    static let defaultRoundDuration: TimeInterval = 90.0

    /// Transition duration between rounds
    static let transitionDuration: TimeInterval = 5.0

    /// Minimum time before allowing skip
    static let minimumDrawTime: TimeInterval = 10.0

    // MARK: - State

    enum TurnPhase {
        case waitingToStart
        case wordSelection(artist: Player, options: [Word])
        case drawing(artist: Player, word: Word, timeRemaining: TimeInterval)
        case guessing(artist: Player, word: Word, guesses: [Guess])
        case reveal(word: Word, winner: Player?, drawing: Drawing3D)
        case scoring(results: RoundResults)
    }

    var currentPhase: TurnPhase = .waitingToStart
    var roundNumber: Int = 0

    // MARK: - Turn Progression

    func startRound(artist: Player, wordOptions: [Word]) {
        currentPhase = .wordSelection(artist: artist, options: wordOptions)
    }

    func selectWord(_ word: Word, artist: Player) {
        currentPhase = .drawing(
            artist: artist,
            word: word,
            timeRemaining: Self.defaultRoundDuration
        )
        startTimer()
    }

    func submitGuess(_ guess: String, by player: Player) -> Bool {
        guard case .drawing(let artist, let word, _) = currentPhase else {
            return false
        }

        let isCorrect = checkGuess(guess, against: word)

        if isCorrect {
            currentPhase = .reveal(word: word, winner: player, drawing: currentDrawing)
            awardPoints(to: [artist, player])
            return true
        }

        return false
    }

    // MARK: - Scoring

    struct ScoringRules {
        static let correctGuessPoints = 100
        static let artistBonusPoints = 50
        static let timeBonus: (TimeInterval) -> Int = { timeRemaining in
            Int(timeRemaining * 2) // 2 points per second remaining
        }
        static let difficultyMultiplier: [Word.Difficulty: Float] = [
            .easy: 1.0,
            .medium: 1.5,
            .hard: 2.0
        ]
    }

    private func awardPoints(to players: [Player]) {
        guard case .reveal(let word, let winner, _) = currentPhase,
              let guesser = winner else { return }

        // Guesser gets base points + time bonus
        let basePoints = ScoringRules.correctGuessPoints
        let timeBonus = ScoringRules.timeBonus(timeRemaining)
        let multiplier = ScoringRules.difficultyMultiplier[word.difficulty] ?? 1.0
        let guesserPoints = Int(Float(basePoints + timeBonus) * multiplier)

        gameState.addScore(guesserPoints, to: guesser.id)

        // Artist gets bonus
        let artistBonus = Int(Float(ScoringRules.artistBonusPoints) * multiplier)
        gameState.addScore(artistBonus, to: currentArtist.id)
    }
}
```

### Word Selection & Category System

```swift
/// AI-driven word selection
class WordSelectionEngine {
    // MARK: - Word Database

    /// In-memory word database (loaded at startup)
    private var wordDatabase: [Word.Category: [Word]] = [:]

    /// Total words available
    static let minimumWordCount = 500 // MVP
    static let targetWordCount = 2000 // V1

    // MARK: - Selection Algorithm

    /// Select words based on difficulty and player history
    func selectWords(
        for players: [Player],
        difficulty: Word.Difficulty,
        categories: Set<Word.Category>,
        count: Int = 3
    ) -> [Word] {
        // Filter by categories
        let availableWords = categories.flatMap { wordDatabase[$0] ?? [] }

        // Filter by difficulty
        let filteredWords = availableWords.filter { $0.difficulty == difficulty }

        // Exclude recently used words (last 50 words)
        let recentWords = Set(gameHistory.recentWords.suffix(50).map(\.id))
        let freshWords = filteredWords.filter { !recentWords.contains($0.id) }

        // Randomly select N words
        return Array(freshWords.shuffled().prefix(count))
    }

    // MARK: - Difficulty Adaptation

    /// Adjust difficulty based on player performance
    func adaptDifficulty(basedOn players: [Player]) -> Word.Difficulty {
        let averageSuccessRate = players.map(\.successRate).reduce(0, +) / Float(players.count)

        switch averageSuccessRate {
        case 0..<0.3: return .easy
        case 0.3..<0.6: return .medium
        default: return .hard
        }
    }

    // MARK: - Word Loading

    /// Load word database from JSON
    func loadWordDatabase() async throws {
        guard let url = Bundle.main.url(forResource: "words", withExtension: "json") else {
            throw WordError.databaseNotFound
        }

        let data = try Data(contentsOf: url)
        let words = try JSONDecoder().decode([Word].self, from: data)

        // Organize by category
        for word in words {
            wordDatabase[word.category, default: []].append(word)
        }
    }
}
```

---

## 3. Control Schemes

### Hand Tracking Implementation

```swift
/// High-precision hand tracking system
@Observable
class HandTrackingController {
    // MARK: - Configuration

    /// Tracking precision target
    static let targetPrecision: Float = 0.002 // 2mm

    /// Latency target
    static let targetLatency: TimeInterval = 0.016 // 16ms

    /// Smoothing factor (0 = no smoothing, 1 = maximum smoothing)
    static let smoothingFactor: Float = 0.3

    // MARK: - Gesture Recognition

    enum HandGesture {
        case idle
        case drawing(position: SIMD3<Float>)
        case erasing(position: SIMD3<Float>)
        case colorPicking(direction: SIMD3<Float>)
        case undo
        case clear
        case confirm
    }

    /// Current gesture state
    private(set) var currentGesture: HandGesture = .idle

    /// Hand anchor tracking
    func update(leftHand: HandAnchor?, rightHand: HandAnchor?) {
        // Use dominant hand (configurable, default right)
        guard let hand = rightHand ?? leftHand else {
            currentGesture = .idle
            return
        }

        // Get hand skeleton
        guard let skeleton = hand.handSkeleton else { return }

        // Detect gesture
        let gesture = recognizeGesture(from: skeleton, chirality: hand.chirality)
        currentGesture = gesture

        // Execute gesture action
        executeGesture(gesture)
    }

    // MARK: - Gesture Recognition Logic

    private func recognizeGesture(
        from skeleton: HandSkeleton,
        chirality: HandAnchor.Chirality
    ) -> HandGesture {
        // Get finger states
        let thumbTip = skeleton.joint(.thumbTip)
        let indexTip = skeleton.joint(.indexFingerTip)
        let middleTip = skeleton.joint(.middleFingerTip)

        // Drawing: Index extended, others curled
        if isFingerExtended(.indexFinger, in: skeleton) &&
           !isFingerExtended(.middleFinger, in: skeleton) {
            let position = indexTip.anchorFromJointTransform.columns.3.xyz
            return .drawing(position: position)
        }

        // Pinch: Thumb and index touching
        if isPinching(thumb: thumbTip, index: indexTip) {
            let position = midpoint(thumbTip.anchorFromJointTransform.columns.3.xyz,
                                   indexTip.anchorFromJointTransform.columns.3.xyz)
            return .drawing(position: position)
        }

        // Eraser: Fist
        if isFist(skeleton) {
            let position = skeleton.joint(.wrist).anchorFromJointTransform.columns.3.xyz
            return .erasing(position: position)
        }

        // Undo: Quick wrist flick left
        if detectWristFlick(chirality: chirality, direction: .left) {
            return .undo
        }

        return .idle
    }

    // MARK: - Helper Functions

    private func isFingerExtended(
        _ finger: HandSkeleton.JointName.FingerName,
        in skeleton: HandSkeleton
    ) -> Bool {
        let tip = skeleton.joint(.fingerTip(finger))
        let knuckle = skeleton.joint(.fingerKnuckle(finger))

        let distance = length(tip.anchorFromJointTransform.columns.3.xyz -
                            knuckle.anchorFromJointTransform.columns.3.xyz)

        return distance > 0.06 // 6cm threshold
    }

    private func isPinching(thumb: HandSkeleton.Joint,
                           index: HandSkeleton.Joint) -> Bool {
        let distance = length(thumb.anchorFromJointTransform.columns.3.xyz -
                            index.anchorFromJointTransform.columns.3.xyz)

        return distance < 0.02 // 2cm threshold
    }

    // MARK: - Position Smoothing

    private var previousPosition: SIMD3<Float>?

    func smoothPosition(_ position: SIMD3<Float>) -> SIMD3<Float> {
        guard let prev = previousPosition else {
            previousPosition = position
            return position
        }

        // Exponential moving average
        let smoothed = prev * Self.smoothingFactor +
                      position * (1.0 - Self.smoothingFactor)

        previousPosition = smoothed
        return smoothed
    }
}
```

### Voice Recognition

```swift
import Speech

/// Voice-based guessing system
class VoiceGuessingController: ObservableObject {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    // MARK: - Configuration

    static let confidenceThreshold: Float = 0.7

    // MARK: - Voice Recognition

    func startListening() throws {
        // Request authorization
        SFSpeechRecognizer.requestAuthorization { status in
            guard status == .authorized else { return }
        }

        // Setup audio session
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            throw VoiceError.recognitionUnavailable
        }

        recognitionRequest.shouldReportPartialResults = true

        // Setup audio input
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) {
            buffer, _ in
            recognitionRequest.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()

        // Start recognition
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) {
            result, error in
            if let result = result {
                let guess = result.bestTranscription.formattedString
                self.handleGuess(guess, confidence: result.bestTranscription.segments.last?.confidence ?? 0)
            }
        }
    }

    func stopListening() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
    }

    // MARK: - Guess Processing

    private func handleGuess(_ guess: String, confidence: Float) {
        guard confidence > Self.confidenceThreshold else { return }

        // Normalize guess
        let normalized = normalizeGuess(guess)

        // Submit to game logic
        gameState.submitGuess(normalized)
    }

    private func normalizeGuess(_ guess: String) -> String {
        return guess
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "[^a-z ]", with: "", options: .regularExpression)
    }
}
```

---

## 4. Physics Specifications

### Canvas Boundary System

```swift
/// Minimal physics for canvas constraints
class CanvasPhysics {
    // MARK: - Canvas Bounds

    struct Bounds {
        let min: SIMD3<Float>
        let max: SIMD3<Float>

        static let standard = Bounds(
            min: SIMD3<Float>(-0.75, -0.75, -0.75),
            max: SIMD3<Float>(0.75, 0.75, 0.75)
        )
    }

    // MARK: - Constraint System

    /// Clamp point to canvas bounds
    func constrainToCanvas(_ point: SIMD3<Float>, bounds: Bounds = .standard) -> SIMD3<Float> {
        return SIMD3<Float>(
            x: max(bounds.min.x, min(bounds.max.x, point.x)),
            y: max(bounds.min.y, min(bounds.max.y, point.y)),
            z: max(bounds.min.z, min(bounds.max.z, point.z))
        )
    }

    /// Check if point is within bounds
    func isWithinCanvas(_ point: SIMD3<Float>, bounds: Bounds = .standard) -> Bool {
        return point.x >= bounds.min.x && point.x <= bounds.max.x &&
               point.y >= bounds.min.y && point.y <= bounds.max.y &&
               point.z >= bounds.min.z && point.z <= bounds.max.z
    }

    // MARK: - Soft Boundaries

    /// Visual feedback as user approaches boundary
    func getBoundaryProximity(_ point: SIMD3<Float>, bounds: Bounds = .standard) -> Float {
        let distances = [
            abs(point.x - bounds.min.x),
            abs(point.x - bounds.max.x),
            abs(point.y - bounds.min.y),
            abs(point.y - bounds.max.y),
            abs(point.z - bounds.min.z),
            abs(point.z - bounds.max.z)
        ]

        let minDistance = distances.min() ?? 0
        return max(0, min(1, minDistance / 0.1)) // 10cm warning zone
    }
}
```

---

## 5. Rendering Requirements

### Material System

```swift
/// Advanced materials for drawing strokes
class StrokeMaterialSystem {
    // MARK: - Material Types

    enum MaterialPreset {
        case solid(color: SIMD4<Float>)
        case glow(color: SIMD4<Float>, intensity: Float)
        case neon(color: SIMD4<Float>)
        case sketch(color: SIMD4<Float>)
        case particle(color: SIMD4<Float>)
    }

    // MARK: - Material Generation

    func createMaterial(preset: MaterialPreset) -> RealityKit.Material {
        switch preset {
        case .solid(let color):
            var material = UnlitMaterial()
            material.color = .init(tint: convertColor(color))
            return material

        case .glow(let color, let intensity):
            var material = UnlitMaterial()
            material.color = .init(tint: convertColor(color))
            material.blending = .transparent(opacity: .init(floatLiteral: 0.8))
            // Add emission
            return material

        case .neon(let color):
            var material = PhysicallyBasedMaterial()
            material.emissiveColor = .init(color: convertColor(color))
            material.emissiveIntensity = 2.0
            return material

        case .sketch(let color):
            var material = UnlitMaterial()
            material.color = .init(tint: convertColor(color))
            material.blending = .transparent(opacity: .init(floatLiteral: 0.6))
            return material

        case .particle(let color):
            var material = UnlitMaterial()
            material.color = .init(tint: convertColor(color))
            material.blending = .transparent(opacity: .init(floatLiteral: 0.9))
            return material
        }
    }

    private func convertColor(_ simd: SIMD4<Float>) -> UIColor {
        return UIColor(
            red: CGFloat(simd.x),
            green: CGFloat(simd.y),
            blue: CGFloat(simd.z),
            alpha: CGFloat(simd.w)
        )
    }
}
```

### Lighting System

```swift
/// Dynamic lighting for drawings
class DrawingLightingSystem {
    // MARK: - Light Configuration

    func setupSceneLighting(for scene: RealityKit.Scene) {
        // Ambient light
        let ambient = DirectionalLight()
        ambient.light.intensity = 500
        ambient.light.color = .white
        scene.addAnchor(ambient)

        // Key light (from above front)
        let keyLight = PointLight()
        keyLight.position = [0, 2, 1]
        keyLight.light.intensity = 1000
        keyLight.light.attenuationRadius = 5.0
        scene.addAnchor(keyLight)

        // Fill light (from below)
        let fillLight = PointLight()
        fillLight.position = [0, -1, 1]
        fillLight.light.intensity = 300
        fillLight.light.color = UIColor(white: 0.8, alpha: 1.0)
        scene.addAnchor(fillLight)

        // Rim light (from behind)
        let rimLight = PointLight()
        rimLight.position = [0, 1, -2]
        rimLight.light.intensity = 500
        scene.addAnchor(rimLight)
    }

    // MARK: - Dynamic Lighting

    func updateLightingForDrawing(drawing: Drawing3D, lights: [PointLight]) {
        // Adjust lighting based on drawing content
        let dominantColor = calculateDominantColor(drawing)
        let complementary = getComplementaryColor(dominantColor)

        // Update fill light to complement drawing colors
        lights.first?.light.color = convertToUIColor(complementary)
    }
}
```

---

## 6. Multiplayer/Networking Specifications

### Network Protocol

```swift
/// Multiplayer networking protocol
protocol MultiplayerProtocol {
    // MARK: - Connection Management

    func connect(to session: SessionID) async throws
    func disconnect() async
    func broadcastMessage<T: Codable>(_ message: T) async throws
    func send<T: Codable>(_ message: T, to participant: ParticipantID) async throws

    // MARK: - State Synchronization

    func syncGameState(_ state: GameState) async throws
    func requestStateSync() async throws

    // MARK: - Drawing Synchronization

    func syncStroke(_ stroke: Stroke3D) async throws
    func syncStrokeDelta(_ delta: StrokeDelta) async throws

    // MARK: - Event Handling

    var onParticipantJoined: ((Participant) -> Void)? { get set }
    var onParticipantLeft: ((ParticipantID) -> Void)? { get set }
    var onMessageReceived: ((Data, ParticipantID) -> Void)? { get set }
}

/// SharePlay implementation
class SharePlayNetworking: MultiplayerProtocol {
    // MARK: - Configuration

    static let maxParticipants = 12
    static let syncInterval: TimeInterval = 0.033 // 30Hz
    static let messageTimeout: TimeInterval = 5.0

    // MARK: - Message Types

    struct StrokeDelta: Codable {
        let strokeID: UUID
        let newPoints: [SIMD3<Float>]
        let startIndex: Int
        let timestamp: Date
    }

    // MARK: - Compression

    func compressStroke(_ stroke: Stroke3D) -> Data {
        // Use delta encoding for point positions
        var compressed: [Int16] = []

        var previousPoint = SIMD3<Int16>(0, 0, 0)

        for point in stroke.points {
            // Convert to millimeters (Int16)
            let current = SIMD3<Int16>(
                Int16(point.x * 1000),
                Int16(point.y * 1000),
                Int16(point.z * 1000)
            )

            // Store delta from previous
            let delta = current - previousPoint
            compressed.append(contentsOf: [delta.x, delta.y, delta.z])

            previousPoint = current
        }

        return Data(bytes: &compressed, count: compressed.count * MemoryLayout<Int16>.size)
    }

    // MARK: - Bandwidth Optimization

    var currentBandwidth: Int = 0 // bytes/second
    static let maxBandwidth = 1_000_000 // 1 MB/s

    func shouldThrottleMessage() -> Bool {
        return currentBandwidth > Self.maxBandwidth
    }
}
```

---

## 7. Performance Budgets

### Frame Time Budget (90 FPS = 11.1ms per frame)

```yaml
frame_time_budget:
  total: 11.1ms

  breakdown:
    input_processing: 2.0ms
    # - Hand tracking: 1.5ms
    # - Voice recognition: 0.3ms
    # - Gesture recognition: 0.2ms

    game_logic: 1.5ms
    # - State updates: 0.5ms
    # - Turn management: 0.3ms
    # - Scoring: 0.2ms
    # - Timer: 0.1ms
    # - AI/word selection: 0.4ms

    rendering: 6.0ms
    # - Mesh updates: 2.0ms
    # - Material updates: 0.5ms
    # - Lighting: 0.5ms
    # - Particle systems: 1.0ms
    # - RealityKit render: 2.0ms

    networking: 1.0ms
    # - Message send: 0.5ms
    # - State sync: 0.5ms

    audio: 0.5ms
    # - Spatial audio: 0.5ms

    buffer: 0.1ms
    # - Margin for spikes
```

### Memory Budget

```yaml
memory_budget:
  total_limit: 750MB
  critical_threshold: 500MB

  breakdown:
    application_code: 50MB
    frameworks: 100MB

    game_state: 10MB
    # - Player data: 1MB
    # - Current session: 5MB
    # - Word database: 4MB

    3d_assets: 200MB
    # - Stroke meshes (active): 100MB
    # - Materials/textures: 50MB
    # - UI assets: 30MB
    # - Particle systems: 20MB

    drawing_data: 150MB
    # - Current round strokes: 50MB
    # - Previous rounds: 100MB

    audio_buffers: 40MB
    # - Spatial audio: 30MB
    # - Sound effects: 10MB

    network_buffers: 20MB
    # - Send queue: 10MB
    # - Receive queue: 10MB

    saved_drawings: 180MB
    # - Compressed gallery: 180MB

  memory_management:
    - Purge old drawings when exceeding 400MB
    - Compress inactive strokes
    - Use texture streaming
    - Implement object pooling
```

### Network Budget

```yaml
network_budget:
  local_multiplayer:
    latency_target: <20ms
    latency_max: <50ms
    bandwidth_per_player: 100KB/s
    max_total_bandwidth: 800KB/s # 8 players

  remote_multiplayer:
    latency_target: <50ms
    latency_max: <150ms
    bandwidth_per_player: 200KB/s
    max_total_bandwidth: 2.4MB/s # 12 players

  message_priorities:
    critical: # Immediate delivery
      - Stroke deltas
      - Correct guesses
      - Turn changes

    high: # <100ms
      - Tool selections
      - Player actions
      - Game state updates

    medium: # <500ms
      - Chat messages
      - UI updates
      - Score updates

    low: # Best effort
      - Ambient effects
      - Analytics
      - Telemetry
```

---

## 8. Testing Requirements

### Unit Testing

```swift
// Example unit test structure
import XCTest
@testable import SpatialPictionary

class DrawingEngineTests: XCTestCase {
    var engine: DrawingEngine!

    override func setUp() {
        super.setUp()
        engine = DrawingEngine()
    }

    func testStrokeInterpolation() {
        // Given
        let points = [
            SIMD3<Float>(0, 0, 0),
            SIMD3<Float>(1, 0, 0),
            SIMD3<Float>(1, 1, 0),
            SIMD3<Float>(0, 1, 0)
        ]

        // When
        let interpolated = engine.interpolatePoints(points)

        // Then
        XCTAssertGreaterThan(interpolated.count, points.count)
        XCTAssertEqual(interpolated.first, points.first)
    }

    func testMeshGeneration() {
        // Test mesh creation from stroke points
    }

    func testPerformance() {
        // Measure mesh generation performance
        measure {
            let points = (0..<1000).map { _ in SIMD3<Float>.random(in: 0...1) }
            _ = engine.generateStrokeMesh(points: points, radius: 0.01)
        }
    }
}
```

### Integration Testing

```yaml
integration_tests:
  multiplayer:
    - test_session_creation
    - test_participant_join_leave
    - test_stroke_synchronization
    - test_state_synchronization
    - test_network_resilience

  gameplay:
    - test_turn_progression
    - test_scoring_system
    - test_word_selection
    - test_timer_accuracy
    - test_guess_validation

  spatial:
    - test_hand_tracking_accuracy
    - test_canvas_positioning
    - test_volume_bounds
    - test_gesture_recognition
```

### Performance Testing

```yaml
performance_tests:
  frame_rate:
    test: sustained_90fps
    duration: 5_minutes
    scenario: active_multiplayer_drawing
    success_criteria: ">85% frames at 90fps"

  memory:
    test: memory_stability
    duration: 30_minutes
    scenario: continuous_gameplay
    success_criteria: "<500MB average, no leaks"

  network:
    test: multiplayer_sync_latency
    participants: 8
    scenario: simultaneous_drawing
    success_criteria: "<50ms sync latency"

  battery:
    test: power_consumption
    duration: 60_minutes
    scenario: typical_gameplay
    success_criteria: "<20% battery drain/hour"
```

### User Acceptance Testing

```yaml
uat_scenarios:
  - name: First Time User Experience
    steps:
      - Launch app
      - Complete tutorial
      - Create first drawing
      - Play first round
    success_criteria:
      - <3 minutes to first round
      - >90% tutorial completion
      - >80% user satisfaction

  - name: Multiplayer Party Experience
    steps:
      - Create multiplayer session
      - Invite 4-8 players
      - Play 5 rounds
      - View gallery
    success_criteria:
      - <2 minutes session setup
      - <5% disconnection rate
      - >85% user engagement
      - >8/10 fun rating

  - name: Comfort and Accessibility
    steps:
      - Play for 30 minutes
      - Use alternative controls
      - Adjust settings
    success_criteria:
      - >8/10 comfort rating
      - >90% accessibility feature discovery
      - <10% fatigue reports
```

---

## 9. Development Tools & Environment

### Xcode Project Configuration

```yaml
project_settings:
  bundle_identifier: com.creativepartygames.spatialpictionary
  version: 1.0.0
  build: 1

  capabilities:
    - GroupActivities (SharePlay)
    - HandTracking
    - SpatialTracking
    - SpeechRecognition
    - iCloud
    - GameCenter (future)

  info_plist_keys:
    NSHandTrackingUsageDescription: "Draw in 3D space using hand gestures"
    NSSpeechRecognitionUsageDescription: "Submit guesses using voice"
    NSMicrophoneUsageDescription: "Voice chat and guessing"

  build_settings:
    SWIFT_VERSION: "6.0"
    IPHONEOS_DEPLOYMENT_TARGET: "2.0"
    ENABLE_STRICT_CONCURRENCY: YES
    SWIFT_UPCOMING_FEATURE_FLAGS: ConciseMagicFile
```

### Reality Composer Pro Setup

```yaml
reality_composer_setup:
  project_name: SpatialPictionaryContent

  assets:
    materials:
      - stroke_materials.usda
      - ui_materials.usda
      - particle_materials.usda

    models:
      - canvas_frame.usdz
      - tool_palette.usdz
      - avatar_base.usdz

    particles:
      - celebration.usda
      - drawing_trail.usda
      - ambient_sparkles.usda

  export_format: .usda
  compression: enabled
```

---

## 10. API & Framework Usage

### Key visionOS APIs

```swift
// Hand Tracking
import ARKit

let handTracking = HandTrackingProvider()
await handTracking.run()

// Spatial Anchors
import RealityKit

let worldAnchor = WorldAnchor(originFromAnchorTransform: transform)
await scene.addAnchor(worldAnchor)

// SharePlay
import GroupActivities

struct GameActivity: GroupActivity {
    static let activityIdentifier = "com.spatialpictionary.game"
    var metadata: GroupActivityMetadata {
        var meta = GroupActivityMetadata()
        meta.title = "Spatial Pictionary"
        meta.type = .generic
        return meta
    }
}

// Spatial Audio
import AVFoundation

let audioEngine = AVAudioEngine()
let environmentNode = AVAudioEnvironmentNode()
environmentNode.renderingAlgorithm = .HRTF
```

---

## Platform Requirements Summary

```yaml
minimum_requirements:
  device: Apple Vision Pro
  os: visionOS 2.0
  memory: 8GB
  storage: 500MB

recommended_requirements:
  device: Apple Vision Pro (latest)
  os: visionOS 2.1+
  memory: 16GB
  storage: 2GB (with saved drawings)

development_requirements:
  macos: 15.0+
  xcode: 16.0+
  vision_pro: physical device or simulator
  apple_developer_account: required
```

---

## Conclusion

This technical specification provides comprehensive implementation guidance for Spatial Pictionary on visionOS. All performance targets, API usage, and system requirements have been designed to ensure a smooth, engaging, and comfortable gaming experience on Apple Vision Pro.

**Next Steps:**
1. Review technical specifications with engineering team
2. Begin development environment setup
3. Start implementation of core systems
4. Continuous testing and performance monitoring

*Document Version: 1.0 | Last Updated: 2025-11-19*
