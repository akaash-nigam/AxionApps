//
//  GameComponents.swift
//  Parkour Pathways
//
//  Custom RealityKit ECS Components
//

import RealityKit
import simd

// MARK: - Obstacle Component

struct ObstacleComponent: Component {
    var type: ObstacleType
    var difficulty: Float
    var isActive: Bool = true
    var interactionState: InteractionState = .idle
    var safetyZone: Float = 0.5 // meters

    enum InteractionState {
        case idle
        case nearby
        case engaged
        case completed
    }
}

// MARK: - Movement Tracking Component

struct MovementTrackingComponent: Component {
    var trackedJoints: Set<TrackedJoint>
    var movementHistory: [MovementSample]
    var currentVelocity: SIMD3<Float> = .zero
    var currentAcceleration: SIMD3<Float> = .zero
    var maxHistorySize: Int = 100

    enum TrackedJoint: String, Hashable {
        case head
        case leftHand
        case rightHand
        case torso
        case leftFoot
        case rightFoot
    }

    mutating func addSample(_ sample: MovementSample) {
        movementHistory.append(sample)
        if movementHistory.count > maxHistorySize {
            movementHistory.removeFirst()
        }
    }
}

// MARK: - Safety Component

struct SafetyComponent: Component {
    var boundaryDistance: Float = .infinity
    var collisionRisk: Float = 0.0
    var isInSafeZone: Bool = true
    var warningLevel: WarningLevel = .none

    enum WarningLevel {
        case none
        case caution
        case warning
        case critical
    }
}

// MARK: - Score Component

struct ScoreComponent: Component {
    var basePoints: Float = 0
    var techniqueMultiplier: Float = 1.0
    var speedBonus: Float = 0.0
    var comboMultiplier: Float = 1.0

    var totalScore: Float {
        (basePoints * techniqueMultiplier * comboMultiplier) + speedBonus
    }
}

// MARK: - Target Component

struct TargetComponent: Component {
    var targetPosition: SIMD3<Float>
    var requiredAccuracy: Float = 0.15 // meters
    var perfectAccuracy: Float = 0.05 // meters
    var isAchieved: Bool = false
    var achievementTime: Date?
    var achievementScore: Float = 0
}

// MARK: - Technique Feedback Component

struct TechniqueFeedbackComponent: Component {
    var currentFeedback: [FeedbackItem] = []
    var displayDuration: TimeInterval = 2.0

    struct FeedbackItem {
        var message: String
        var type: FeedbackType
        var timestamp: Date
        var position: SIMD3<Float>?

        enum FeedbackType {
            case perfect
            case good
            case needsImprovement
            case error
        }
    }

    mutating func addFeedback(_ message: String, type: FeedbackItem.FeedbackType, at position: SIMD3<Float>? = nil) {
        let item = FeedbackItem(
            message: message,
            type: type,
            timestamp: Date(),
            position: position
        )
        currentFeedback.append(item)
    }

    mutating func cleanupExpiredFeedback() {
        let now = Date()
        currentFeedback.removeAll { item in
            now.timeIntervalSince(item.timestamp) > displayDuration
        }
    }
}

// MARK: - Animation State Component

struct AnimationStateComponent: Component {
    var currentAnimation: String?
    var isPlaying: Bool = false
    var loopMode: AnimationLoopMode = .once

    enum AnimationLoopMode {
        case once
        case loop
        case pingPong
    }
}

// MARK: - Highlight Component

struct HighlightComponent: Component {
    var isHighlighted: Bool = false
    var highlightColor: SIMD4<Float> = SIMD4<Float>(1, 1, 0, 1) // Yellow
    var pulseSpeed: Float = 1.0
    var intensity: Float = 1.0
}

// MARK: - Particle Effect Component

struct ParticleEffectComponent: Component {
    var effectType: EffectType
    var isActive: Bool = false
    var duration: TimeInterval = 1.0
    var startTime: Date?

    enum EffectType {
        case completion
        case perfectLanding
        case trail
        case checkpoint
        case error
    }
}

// MARK: - Collision Component

struct CollisionComponent: Component {
    var collisionGroup: CollisionGroup
    var collidesWith: CollisionGroup
    var isTrigger: Bool = false

    struct CollisionGroup: OptionSet {
        let rawValue: UInt32

        static let player = CollisionGroup(rawValue: 1 << 0)
        static let obstacle = CollisionGroup(rawValue: 1 << 1)
        static let boundary = CollisionGroup(rawValue: 1 << 2)
        static let target = CollisionGroup(rawValue: 1 << 3)
        static let furniture = CollisionGroup(rawValue: 1 << 4)

        static let all: CollisionGroup = [.player, .obstacle, .boundary, .target, .furniture]
    }
}

// MARK: - Audio Source Component

struct AudioSourceComponent: Component {
    var soundEffect: SoundEffect
    var isPlaying: Bool = false
    var volume: Float = 1.0
    var isSpatial: Bool = true
    var looping: Bool = false

    enum SoundEffect {
        case footstep
        case landing
        case vaultTouch
        case completion
        case checkpoint
        case error
        case ambient
    }
}

// MARK: - Anchor Component

struct AnchorComponent: Component {
    var anchorID: UUID
    var isWorldLocked: Bool = true
    var anchorType: AnchorType

    enum AnchorType {
        case floor
        case wall
        case furniture
        case custom
    }
}

// MARK: - Visibility Component

struct VisibilityComponent: Component {
    var isVisible: Bool = true
    var fadeOpacity: Float = 1.0
    var renderLayer: RenderLayer = .normal

    enum RenderLayer {
        case background
        case normal
        case foreground
        case ui
    }
}

// MARK: - Interaction Component

struct InteractionComponent: Component {
    var isInteractable: Bool = true
    var interactionType: InteractionType
    var gazeTimer: TimeInterval = 0
    var requiredGazeDuration: TimeInterval = 0.8

    enum InteractionType {
        case tap
        case gaze
        case grab
        case proximity
    }
}

// MARK: - Timer Component

struct TimerComponent: Component {
    var startTime: Date
    var duration: TimeInterval?
    var isPaused: Bool = false

    var elapsed: TimeInterval {
        guard !isPaused else { return 0 }
        return Date().timeIntervalSince(startTime)
    }

    var isExpired: Bool {
        guard let duration = duration else { return false }
        return elapsed >= duration
    }
}

// MARK: - Checkpoint Component

struct CheckpointComponent: Component {
    var order: Int
    var isReached: Bool = false
    var requiredObstacles: [UUID]
    var completedObstacles: Set<UUID> = []

    var canActivate: Bool {
        Set(requiredObstacles) == completedObstacles
    }
}

// MARK: - Ghost Component

struct GhostComponent: Component {
    var recording: GhostRecording
    var currentSampleIndex: Int = 0
    var isPlaying: Bool = false
    var playbackSpeed: Float = 1.0

    struct GhostRecording: Codable {
        var playerID: UUID
        var courseID: UUID
        var samples: [GhostSample]
        var completionTime: TimeInterval

        struct GhostSample: Codable {
            var timestamp: TimeInterval
            var position: SIMD3<Float>
            var rotation: simd_quatf
        }
    }
}

// MARK: - Multiplayer Sync Component

struct MultiplayerSyncComponent: Component {
    var playerID: UUID
    var lastSyncTime: Date = Date()
    var syncFrequency: TimeInterval = 1.0 / 30.0 // 30 Hz
    var interpolationBuffer: [EntitySnapshot] = []

    struct EntitySnapshot {
        var timestamp: Date
        var position: SIMD3<Float>
        var rotation: simd_quatf
        var velocity: SIMD3<Float>
    }

    var needsSync: Bool {
        Date().timeIntervalSince(lastSyncTime) >= syncFrequency
    }
}
