import Foundation

/// Arena type
public enum ArenaType: String, Codable, Sendable {
    case spherical360
    case verticalDominance
    case closeQuarters
    case longRange
}

/// Arena model
public struct Arena: Identifiable, Codable, Sendable {
    public let id: UUID
    public var name: String
    public var type: ArenaType
    public var radius: Float
    public var height: Float
    public var minPlayArea: SIMD2<Float>
    public var recommendedPlayArea: SIMD2<Float>

    public init(
        id: UUID = UUID(),
        name: String,
        type: ArenaType = .spherical360,
        radius: Float = 15.0,
        height: Float = 10.0,
        minPlayArea: SIMD2<Float> = SIMD2(2.0, 2.0),
        recommendedPlayArea: SIMD2<Float> = SIMD2(3.0, 3.0)
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.radius = radius
        self.height = height
        self.minPlayArea = minPlayArea
        self.recommendedPlayArea = recommendedPlayArea
    }

    public var volume: Float {
        // Approximate volume for spherical arena
        return (4.0 / 3.0) * .pi * pow(radius, 3)
    }
}
