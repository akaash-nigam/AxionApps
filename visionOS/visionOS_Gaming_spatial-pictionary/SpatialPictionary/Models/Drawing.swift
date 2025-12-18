import Foundation
import simd

/// Represents a 3D stroke in the drawing
struct Stroke3D: Identifiable, Codable {
    let id: UUID
    var points: [SIMD3<Float>]
    var color: CodableColor
    var thickness: Float
    var material: MaterialType
    var timestamps: [TimeInterval] // For replay

    enum MaterialType: String, Codable {
        case solid, glow, sketch, neon, particle

        var displayName: String {
            rawValue.capitalized
        }
    }

    init(
        id: UUID = UUID(),
        points: [SIMD3<Float>],
        color: CodableColor,
        thickness: Float,
        material: MaterialType,
        timestamps: [TimeInterval] = []
    ) {
        self.id = id
        self.points = points
        self.color = color
        self.thickness = thickness
        self.material = material
        self.timestamps = timestamps
    }
}

/// A complete 3D drawing
struct Drawing3D: Identifiable, Codable {
    let id: UUID
    var strokes: [Stroke3D]
    var createdBy: UUID // Player ID
    var word: Word
    var timestamp: Date
    var meshData: Data? // Compressed mesh for saving

    // Metadata
    var viewCount: Int = 0
    var likeCount: Int = 0
    var timeToComplete: TimeInterval = 0

    init(
        id: UUID = UUID(),
        strokes: [Stroke3D] = [],
        createdBy: UUID,
        word: Word,
        timestamp: Date = Date(),
        meshData: Data? = nil
    ) {
        self.id = id
        self.strokes = strokes
        self.createdBy = createdBy
        self.word = word
        self.timestamp = timestamp
        self.meshData = meshData
    }
}

/// Color that can be encoded/decoded
struct CodableColor: Codable, Equatable {
    var red: Float
    var green: Float
    var blue: Float
    var alpha: Float

    init(red: Float, green: Float, blue: Float, alpha: Float = 1.0) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    // Predefined colors
    static let red = CodableColor(red: 1.0, green: 0.0, blue: 0.0)
    static let green = CodableColor(red: 0.0, green: 1.0, blue: 0.0)
    static let blue = CodableColor(red: 0.0, green: 0.0, blue: 1.0)
    static let yellow = CodableColor(red: 1.0, green: 1.0, blue: 0.0)
    static let purple = CodableColor(red: 0.5, green: 0.0, blue: 0.5)
    static let orange = CodableColor(red: 1.0, green: 0.5, blue: 0.0)
    static let white = CodableColor(red: 1.0, green: 1.0, blue: 1.0)
    static let black = CodableColor(red: 0.0, green: 0.0, blue: 0.0)

    static let standardPalette: [CodableColor] = [
        .red, .green, .blue, .yellow, .purple, .orange, .white, .black
    ]
}

// MARK: - Extensions for Testing

extension Stroke3D {
    static func mock(pointCount: Int = 10) -> Stroke3D {
        let points = (0..<pointCount).map { i in
            SIMD3<Float>(Float(i) * 0.01, 0, 0)
        }

        return Stroke3D(
            points: points,
            color: .red,
            thickness: 0.01,
            material: .solid
        )
    }
}

extension Drawing3D {
    static func mock() -> Drawing3D {
        Drawing3D(
            strokes: [.mock()],
            createdBy: UUID(),
            word: .mock()
        )
    }
}
