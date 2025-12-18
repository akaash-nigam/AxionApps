import Foundation

// MARK: - Player
struct Player: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var role: PlayerRole
    var position: SIMD3<Float>
    var orientation: simd_quatf
    var activeAbilities: [Ability]
    var stats: PlayerStats
    var avatarConfiguration: AvatarConfig

    init(
        id: UUID = UUID(),
        name: String,
        role: PlayerRole = .hider,
        position: SIMD3<Float> = .zero,
        orientation: simd_quatf = simd_quatf(angle: 0, axis: SIMD3<Float>(0, 1, 0)),
        activeAbilities: [Ability] = [],
        stats: PlayerStats = PlayerStats(),
        avatarConfiguration: AvatarConfig = AvatarConfig()
    ) {
        self.id = id
        self.name = name
        self.role = role
        self.position = position
        self.orientation = orientation
        self.activeAbilities = activeAbilities
        self.stats = stats
        self.avatarConfiguration = avatarConfiguration
    }

    var velocity: SIMD3<Float> {
        // Calculate velocity based on position history
        // This would be tracked in a real implementation
        return .zero
    }
}

// MARK: - Player Role
enum PlayerRole: String, Codable, Equatable {
    case hider
    case seeker
}

// MARK: - Player Stats
struct PlayerStats: Codable, Equatable {
    var totalGamesPlayed: Int = 0
    var gamesWon: Int = 0
    var totalHideTime: TimeInterval = 0
    var totalSeekTime: TimeInterval = 0
    var successfulHides: Int = 0
    var successfulSeeks: Int = 0

    var winRate: Double {
        guard totalGamesPlayed > 0 else { return 0.0 }
        return Double(gamesWon) / Double(totalGamesPlayed)
    }
}

// MARK: - Avatar Config
struct AvatarConfig: Codable, Equatable {
    var bodyType: BodyType = .average
    var height: Height = .medium
    var colorPrimary: String = "#4A90E2"  // Mystic Blue
    var colorSecondary: String = "#9B59B6" // Magical Purple
    var pattern: Pattern = .solid
    var accessory: Accessory = .none

    enum BodyType: String, Codable {
        case slim, average, athletic, stocky
    }

    enum Height: String, Codable {
        case short, medium, tall
    }

    enum Pattern: String, Codable {
        case solid, stripes, dots, gradient
    }

    enum Accessory: String, Codable {
        case none, hat, glasses, cape
    }
}

// MARK: - SIMD Codable Extensions
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
