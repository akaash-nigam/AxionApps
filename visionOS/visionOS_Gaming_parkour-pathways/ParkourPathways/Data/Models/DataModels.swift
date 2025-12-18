//
//  DataModels.swift
//  Parkour Pathways
//
//  Core data models for the application
//

import Foundation
import SwiftData
import simd

// MARK: - Player Data

@Model
final class PlayerData {
    @Attribute(.unique) var id: UUID
    var username: String
    var skillLevel: SkillLevel
    var physicalProfile: PhysicalProfile
    var achievements: [Achievement]
    var statistics: PlayerStatistics
    var preferences: PlayerPreferences
    var createdAt: Date

    init(
        id: UUID = UUID(),
        username: String,
        skillLevel: SkillLevel = .novice,
        physicalProfile: PhysicalProfile = PhysicalProfile(),
        achievements: [Achievement] = [],
        statistics: PlayerStatistics = PlayerStatistics(),
        preferences: PlayerPreferences = PlayerPreferences(),
        createdAt: Date = Date()
    ) {
        self.id = id
        self.username = username
        self.skillLevel = skillLevel
        self.physicalProfile = physicalProfile
        self.achievements = achievements
        self.statistics = statistics
        self.preferences = preferences
        self.createdAt = createdAt
    }
}

// MARK: - Skill Level

enum SkillLevel: Int, Codable {
    case novice = 0
    case beginner = 1
    case intermediate = 2
    case advanced = 3
    case expert = 4
    case master = 5

    var displayName: String {
        switch self {
        case .novice: return "Novice Traceur"
        case .beginner: return "Beginner Traceur"
        case .intermediate: return "Intermediate Traceur"
        case .advanced: return "Advanced Traceur"
        case .expert: return "Expert Traceur"
        case .master: return "Master Traceur"
        }
    }

    var xpRequired: Int {
        switch self {
        case .novice: return 100
        case .beginner: return 500
        case .intermediate: return 1500
        case .advanced: return 5000
        case .expert: return 15000
        case .master: return Int.max
        }
    }
}

// MARK: - Physical Profile

struct PhysicalProfile: Codable {
    var height: Double = 1.7 // meters
    var reach: Double = 0.7 // meters
    var jumpHeight: Double = 0.5 // meters
    var fitnessLevel: FitnessLevel = .beginner
    var injuries: [InjuryHistory] = []
}

enum FitnessLevel: String, Codable {
    case beginner
    case intermediate
    case advanced
    case elite
}

struct InjuryHistory: Codable, Identifiable {
    let id: UUID
    var type: String
    var date: Date
    var recoveredDate: Date?
}

// MARK: - Achievement

struct Achievement: Codable, Identifiable {
    let id: UUID
    var name: String
    var description: String
    var icon: String
    var xpReward: Int
    var unlockedDate: Date?
    var category: AchievementCategory

    var isUnlocked: Bool {
        unlockedDate != nil
    }
}

enum AchievementCategory: String, Codable {
    case movementMastery
    case competitive
    case training
    case social
}

// MARK: - Player Statistics

struct PlayerStatistics: Codable {
    var totalXP: Int = 0
    var coursesCompleted: Int = 0
    var totalPlayTime: TimeInterval = 0
    var bestCompletionTimes: [UUID: TimeInterval] = [:]
    var skillCategoryLevels: [String: Int] = [:]
    var caloriesBurned: Double = 0
    var perfectLandings: Int = 0
    var flawlessVaults: Int = 0
}

// MARK: - Player Preferences

struct PlayerPreferences: Codable {
    var difficultyPreference: DifficultyLevel = .medium
    var showTutorials: Bool = true
    var audioVolume: Float = 1.0
    var musicVolume: Float = 0.7
    var hapticIntensity: Float = 1.0
    var accessibilityMode: AccessibilityMode = .standard
}

enum AccessibilityMode: String, Codable {
    case standard
    case highContrast
    case reducedMotion
    case simplified
}

// MARK: - Course Data

@Model
final class CourseData {
    @Attribute(.unique) var id: UUID
    var name: String
    var difficulty: DifficultyLevel
    var obstacles: [Obstacle]
    var checkpoints: [Checkpoint]
    var spaceRequirements: SpaceRequirements
    var estimatedDuration: TimeInterval
    var tags: [String]
    var creatorID: UUID?
    var createdAt: Date
    var isUserGenerated: Bool

    init(
        id: UUID = UUID(),
        name: String,
        difficulty: DifficultyLevel,
        obstacles: [Obstacle],
        checkpoints: [Checkpoint],
        spaceRequirements: SpaceRequirements,
        estimatedDuration: TimeInterval,
        tags: [String] = [],
        creatorID: UUID? = nil,
        createdAt: Date = Date(),
        isUserGenerated: Bool = false
    ) {
        self.id = id
        self.name = name
        self.difficulty = difficulty
        self.obstacles = obstacles
        self.checkpoints = checkpoints
        self.spaceRequirements = spaceRequirements
        self.estimatedDuration = estimatedDuration
        self.tags = tags
        self.creatorID = creatorID
        self.createdAt = createdAt
        self.isUserGenerated = isUserGenerated
    }
}

// MARK: - Difficulty Level

enum DifficultyLevel: String, Codable {
    case easy
    case medium
    case hard
    case expert

    var displayName: String {
        rawValue.capitalized
    }

    var color: String {
        switch self {
        case .easy: return "green"
        case .medium: return "orange"
        case .hard: return "red"
        case .expert: return "purple"
        }
    }
}

// MARK: - Obstacle

struct Obstacle: Codable, Identifiable {
    let id: UUID
    var type: ObstacleType
    var position: SIMD3<Float>
    var rotation: simd_quatf
    var scale: SIMD3<Float>
    var difficulty: Float
    var safetyParameters: SafetyParameters

    init(
        id: UUID = UUID(),
        type: ObstacleType,
        position: SIMD3<Float>,
        rotation: simd_quatf = simd_quatf(),
        scale: SIMD3<Float> = SIMD3<Float>(1, 1, 1),
        difficulty: Float = 0.5,
        safetyParameters: SafetyParameters = SafetyParameters()
    ) {
        self.id = id
        self.type = type
        self.position = position
        self.rotation = rotation
        self.scale = scale
        self.difficulty = difficulty
        self.safetyParameters = safetyParameters
    }
}

enum ObstacleType: String, Codable {
    case precisionTarget
    case virtualWall
    case vaultBox
    case balanceBeam
    case wallRun
    case gap
    case climbingSurface
    case stepVault
    case speedVault
    case kongVault

    var displayName: String {
        switch self {
        case .precisionTarget: return "Precision Target"
        case .virtualWall: return "Virtual Wall"
        case .vaultBox: return "Vault Box"
        case .balanceBeam: return "Balance Beam"
        case .wallRun: return "Wall Run"
        case .gap: return "Gap"
        case .climbingSurface: return "Climbing Surface"
        case .stepVault: return "Step Vault"
        case .speedVault: return "Speed Vault"
        case .kongVault: return "Kong Vault"
        }
    }
}

// MARK: - Safety Parameters

struct SafetyParameters: Codable {
    var minClearance: Float = 0.5 // meters
    var maxApproachSpeed: Float = 5.0 // m/s
    var requiredSkillLevel: SkillLevel = .novice
    var warningZoneRadius: Float = 1.0 // meters
}

// MARK: - Checkpoint

struct Checkpoint: Codable, Identifiable {
    let id: UUID
    var position: SIMD3<Float>
    var order: Int
    var requiredObstacles: [UUID]

    init(
        id: UUID = UUID(),
        position: SIMD3<Float>,
        order: Int,
        requiredObstacles: [UUID] = []
    ) {
        self.id = id
        self.position = position
        self.order = order
        self.requiredObstacles = requiredObstacles
    }
}

// MARK: - Space Requirements

struct SpaceRequirements: Codable {
    var minWidth: Float = 2.0 // meters
    var minLength: Float = 2.0 // meters
    var minHeight: Float = 2.5 // meters
    var requiredFeatures: [SpaceFeature] = []

    func fits(in roomModel: RoomModel) -> Bool {
        return roomModel.width >= minWidth &&
               roomModel.length >= minLength &&
               roomModel.height >= minHeight
    }
}

enum SpaceFeature: String, Codable {
    case openFloor
    case walls
    case furniture
    case multiLevel
}

// MARK: - Session Metrics

@Model
final class SessionMetrics {
    @Attribute(.unique) var id: UUID
    var startTime: Date
    var endTime: Date?
    var courseId: UUID
    var completionTime: TimeInterval?
    var movementData: [MovementSample]
    var score: Float
    var caloriesBurned: Float
    var techniqueScores: [String: Float]

    init(
        id: UUID = UUID(),
        startTime: Date,
        endTime: Date? = nil,
        courseId: UUID,
        completionTime: TimeInterval? = nil,
        movementData: [MovementSample] = [],
        score: Float = 0,
        caloriesBurned: Float = 0,
        techniqueScores: [String: Float] = [:]
    ) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.courseId = courseId
        self.completionTime = completionTime
        self.movementData = movementData
        self.score = score
        self.caloriesBurned = caloriesBurned
        self.techniqueScores = techniqueScores
    }
}

// MARK: - Movement Sample

struct MovementSample: Codable {
    var timestamp: TimeInterval
    var bodyPosition: SIMD3<Float>
    var velocity: SIMD3<Float>
    var acceleration: SIMD3<Float>
    var handPositions: (left: SIMD3<Float>, right: SIMD3<Float>)
    var headOrientation: simd_quatf
    var jointAngles: [String: Float]
}

// MARK: - Room Model

struct RoomModel: Codable {
    var width: Float
    var length: Float
    var height: Float
    var surfaces: [Surface]
    var furniture: [FurnitureItem]
    var safePlayArea: PlayArea?

    struct Surface: Codable, Identifiable {
        let id: UUID
        var type: SurfaceType
        var vertices: [SIMD3<Float>]
        var normal: SIMD3<Float>
    }

    enum SurfaceType: String, Codable {
        case floor
        case ceiling
        case wall
        case sloped
    }

    struct FurnitureItem: Codable, Identifiable {
        let id: UUID
        var type: FurnitureType
        var position: SIMD3<Float>
        var boundingBox: SIMD3<Float>
    }

    enum FurnitureType: String, Codable {
        case table
        case chair
        case sofa
        case shelf
        case unknown
    }
}

// MARK: - Play Area

struct PlayArea: Codable {
    var bounds: Bounds
    var safeZone: Bounds
    var centerPoint: SIMD3<Float>

    struct Bounds: Codable {
        var min: SIMD3<Float>
        var max: SIMD3<Float>
        var center: SIMD3<Float> {
            (min + max) / 2
        }
    }
}

// MARK: - SIMD Extensions for Codable

extension SIMD3: Codable where Scalar == Float {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let x = try container.decode(Float.self)
        let y = try container.decode(Float.self)
        let z = try container.decode(Float.self)
        self.init(x, y, z)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(self.x)
        try container.encode(self.y)
        try container.encode(self.z)
    }
}

extension simd_quatf: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let x = try container.decode(Float.self)
        let y = try container.decode(Float.self)
        let z = try container.decode(Float.self)
        let w = try container.decode(Float.self)
        self.init(ix: x, iy: y, iz: z, r: w)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(self.imag.x)
        try container.encode(self.imag.y)
        try container.encode(self.imag.z)
        try container.encode(self.real)
    }
}
