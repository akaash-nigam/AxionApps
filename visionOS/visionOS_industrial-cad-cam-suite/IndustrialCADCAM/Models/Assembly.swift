import Foundation
import SwiftData

@Model
final class Assembly {
    @Attribute(.unique) var id: UUID
    var name: String
    var assemblyNumber: String
    var revision: String
    var assemblyDescription: String

    @Relationship
    var parts: [Part]

    var componentPositions: [ComponentPosition] // Store transforms for each part
    var constraints: [AssemblyConstraint]

    // Metadata
    var createdDate: Date
    var modifiedDate: Date
    var status: String

    // Analysis results
    var hasInterferences: Bool
    var interferenceCount: Int

    init(name: String) {
        self.id = UUID()
        self.name = name
        self.assemblyNumber = "ASSY-\(UUID().uuidString.prefix(8))"
        self.revision = "A"
        self.assemblyDescription = ""
        self.parts = []
        self.componentPositions = []
        self.constraints = []
        self.createdDate = Date()
        self.modifiedDate = Date()
        self.status = "draft"
        self.hasInterferences = false
        self.interferenceCount = 0
    }

    // MARK: - Methods
    func addPart(_ part: Part, at position: Transform3D = Transform3D()) {
        parts.append(part)
        componentPositions.append(ComponentPosition(
            partID: part.id,
            transform: position
        ))
        touch()
    }

    func removePart(_ part: Part) {
        if let index = parts.firstIndex(where: { $0.id == part.id }) {
            parts.remove(at: index)
            componentPositions.removeAll { $0.partID == part.id }
            touch()
        }
    }

    func touch() {
        modifiedDate = Date()
    }

    var partCount: Int {
        parts.count
    }
}

// MARK: - Supporting Types
struct ComponentPosition: Codable {
    var partID: UUID
    var transform: Transform3D
}

struct Transform3D: Codable {
    var position: Position3D
    var rotation: Rotation3D
    var scale: Scale3D

    init(
        position: Position3D = Position3D(),
        rotation: Rotation3D = Rotation3D(),
        scale: Scale3D = Scale3D()
    ) {
        self.position = position
        self.rotation = rotation
        self.scale = scale
    }
}

struct Position3D: Codable {
    var x: Double = 0
    var y: Double = 0
    var z: Double = 0
}

struct Rotation3D: Codable {
    var x: Double = 0 // radians
    var y: Double = 0
    var z: Double = 0
}

struct Scale3D: Codable {
    var x: Double = 1.0
    var y: Double = 1.0
    var z: Double = 1.0
}

struct AssemblyConstraint: Codable {
    var id: UUID = UUID()
    var type: ConstraintType
    var part1ID: UUID
    var part2ID: UUID
    var parameters: [String: Double]

    enum ConstraintType: String, Codable {
        case coincident
        case concentric
        case distance
        case angle
        case parallel
        case perpendicular
    }
}
