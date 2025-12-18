import Foundation
import simd

// MARK: - Core Data Models

/// Represents a puzzle in the game
struct Puzzle: Codable, Identifiable, Equatable {
    let id: UUID
    let title: String
    let description: String
    let difficulty: Difficulty
    let estimatedTime: TimeInterval
    let requiredRoomSize: RoomSize
    let puzzleElements: [PuzzleElement]
    let objectives: [Objective]
    let hints: [Hint]

    enum Difficulty: String, Codable, CaseIterable {
        case beginner
        case intermediate
        case advanced
        case expert

        var displayName: String {
            rawValue.capitalized
        }

        var difficultyMultiplier: Float {
            switch self {
            case .beginner: return 0.8
            case .intermediate: return 1.0
            case .advanced: return 1.2
            case .expert: return 1.5
            }
        }
    }

    enum RoomSize: String, Codable {
        case small      // 1.5m x 1.5m
        case medium     // 2.5m x 2.5m
        case large      // 3.5m x 3.5m
        case multiRoom  // Multiple rooms
    }

    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        difficulty: Difficulty,
        estimatedTime: TimeInterval,
        requiredRoomSize: RoomSize,
        puzzleElements: [PuzzleElement],
        objectives: [Objective],
        hints: [Hint]
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.difficulty = difficulty
        self.estimatedTime = estimatedTime
        self.requiredRoomSize = requiredRoomSize
        self.puzzleElements = puzzleElements
        self.objectives = objectives
        self.hints = hints
    }
}

/// Individual puzzle element (virtual object in room)
struct PuzzleElement: Codable, Identifiable, Equatable {
    let id: UUID
    let type: ElementType
    var position: SIMD3<Float>
    var rotation: simd_quatf
    var scale: SIMD3<Float>
    let modelName: String
    let interactionType: InteractionType
    var metadata: [String: String]

    enum ElementType: String, Codable {
        case clue
        case key
        case lock
        case mechanism
        case decoration
        case hint
    }

    enum InteractionType: String, Codable {
        case tap
        case grab
        case rotate
        case examine
        case combine
    }

    init(
        id: UUID = UUID(),
        type: ElementType,
        position: SIMD3<Float>,
        rotation: simd_quatf = simd_quatf(angle: 0, axis: SIMD3<Float>(0, 1, 0)),
        scale: SIMD3<Float> = SIMD3<Float>(1, 1, 1),
        modelName: String,
        interactionType: InteractionType,
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.type = type
        self.position = position
        self.rotation = rotation
        self.scale = scale
        self.modelName = modelName
        self.interactionType = interactionType
        self.metadata = metadata
    }
}

/// Room mapping data
struct RoomData: Codable, Equatable {
    let id: UUID
    let scanDate: Date
    var dimensions: SIMD3<Float>
    var floorPlan: FloorPlan
    var furniture: [FurnitureItem]
    var anchorPoints: [AnchorPoint]

    struct FloorPlan: Codable, Equatable {
        var vertices: [SIMD3<Float>]
        var polygons: [[Int]]
    }

    struct FurnitureItem: Codable, Identifiable, Equatable {
        let id: UUID
        let type: FurnitureType
        var boundingBox: BoundingBox
        var surfaceNormals: [SIMD3<Float>]

        enum FurnitureType: String, Codable {
            case table, chair, sofa, bed, shelf, desk, cabinet
        }
    }

    struct AnchorPoint: Codable, Identifiable, Equatable {
        let id: UUID
        var position: SIMD3<Float>
        var rotation: simd_quatf
        let anchorType: AnchorType

        enum AnchorType: String, Codable {
            case room, furniture, custom
        }
    }

    struct BoundingBox: Codable, Equatable {
        var center: SIMD3<Float>
        var extents: SIMD3<Float>
    }

    init(
        id: UUID = UUID(),
        scanDate: Date = Date(),
        dimensions: SIMD3<Float> = .zero,
        floorPlan: FloorPlan = FloorPlan(vertices: [], polygons: []),
        furniture: [FurnitureItem] = [],
        anchorPoints: [AnchorPoint] = []
    ) {
        self.id = id
        self.scanDate = scanDate
        self.dimensions = dimensions
        self.floorPlan = floorPlan
        self.furniture = furniture
        self.anchorPoints = anchorPoints
    }
}

/// Player data
struct Player: Codable, Identifiable, Equatable {
    let id: UUID
    var username: String
    var avatar: AvatarData
    var statistics: PlayerStatistics
    var achievements: [Achievement]
    var roomProfile: RoomData?

    struct AvatarData: Codable, Equatable {
        var avatarColor: String
        var accessories: [String]
    }

    struct PlayerStatistics: Codable, Equatable {
        var totalPuzzlesSolved: Int
        var totalPlayTime: TimeInterval
        var currentLevel: Int
        var currentXP: Int
    }

    struct Achievement: Codable, Identifiable, Equatable {
        let id: UUID
        let name: String
        let description: String
        let unlockedDate: Date
    }

    init(
        id: UUID = UUID(),
        username: String,
        avatar: AvatarData = AvatarData(avatarColor: "blue", accessories: []),
        statistics: PlayerStatistics = PlayerStatistics(totalPuzzlesSolved: 0, totalPlayTime: 0, currentLevel: 1, currentXP: 0),
        achievements: [Achievement] = [],
        roomProfile: RoomData? = nil
    ) {
        self.id = id
        self.username = username
        self.avatar = avatar
        self.statistics = statistics
        self.achievements = achievements
        self.roomProfile = roomProfile
    }
}

/// Puzzle objective
struct Objective: Codable, Identifiable, Equatable {
    let id: UUID
    let title: String
    let description: String
    var isCompleted: Bool
    let requiredElements: [UUID]

    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        isCompleted: Bool = false,
        requiredElements: [UUID] = []
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.isCompleted = isCompleted
        self.requiredElements = requiredElements
    }
}

/// Hint for puzzle assistance
struct Hint: Codable, Identifiable, Equatable {
    let id: UUID
    let text: String
    let difficulty: Int  // 1-3, where 1 is subtle, 3 is direct
    var isRevealed: Bool

    init(
        id: UUID = UUID(),
        text: String,
        difficulty: Int,
        isRevealed: Bool = false
    ) {
        self.id = id
        self.text = text
        self.difficulty = difficulty
        self.isRevealed = isRevealed
    }
}

/// Puzzle solution
struct PuzzleSolution: Codable, Equatable {
    let answer: String
    let elementStates: [UUID: String]

    init(answer: String, elementStates: [UUID: String] = [:]) {
        self.answer = answer
        self.elementStates = elementStates
    }
}

/// Puzzle progress tracking
struct PuzzleProgress: Codable, Equatable {
    let puzzleId: UUID
    var completedObjectives: [UUID]
    var discoveredClues: [UUID]
    var revealedHints: [UUID]
    var elapsedTime: TimeInterval
    var hintCount: Int

    init(
        puzzleId: UUID,
        completedObjectives: [UUID] = [],
        discoveredClues: [UUID] = [],
        revealedHints: [UUID] = [],
        elapsedTime: TimeInterval = 0,
        hintCount: Int = 0
    ) {
        self.puzzleId = puzzleId
        self.completedObjectives = completedObjectives
        self.discoveredClues = discoveredClues
        self.revealedHints = revealedHints
        self.elapsedTime = elapsedTime
        self.hintCount = hintCount
    }
}

/// Validation result for puzzle solutions
struct ValidationResult: Equatable {
    let isCorrect: Bool
    let feedback: String
    let completedObjectives: [UUID]

    init(isCorrect: Bool, feedback: String, completedObjectives: [UUID] = []) {
        self.isCorrect = isCorrect
        self.feedback = feedback
        self.completedObjectives = completedObjectives
    }
}

// MARK: - Extension for SIMD Codable Support

extension SIMD3: Codable where Scalar == Float {
    enum CodingKeys: String, CodingKey {
        case x, y, z
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let x = try container.decode(Float.self, forKey: .x)
        let y = try container.decode(Float.self, forKey: .y)
        let z = try container.decode(Float.self, forKey: .z)
        self.init(x, y, z)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.x, forKey: .x)
        try container.encode(self.y, forKey: .y)
        try container.encode(self.z, forKey: .z)
    }
}

extension simd_quatf: Codable {
    enum CodingKeys: String, CodingKey {
        case x, y, z, w
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let x = try container.decode(Float.self, forKey: .x)
        let y = try container.decode(Float.self, forKey: .y)
        let z = try container.decode(Float.self, forKey: .z)
        let w = try container.decode(Float.self, forKey: .w)
        self.init(ix: x, iy: y, iz: z, r: w)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.imag.x, forKey: .x)
        try container.encode(self.imag.y, forKey: .y)
        try container.encode(self.imag.z, forKey: .z)
        try container.encode(self.real, forKey: .w)
    }
}
