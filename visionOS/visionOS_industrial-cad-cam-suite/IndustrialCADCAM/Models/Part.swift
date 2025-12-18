import Foundation
import SwiftData

@Model
final class Part {
    @Attribute(.unique) var id: UUID
    var name: String
    var partNumber: String
    var revision: String
    var partDescription: String

    // Geometric data (stored as binary)
    @Attribute(.externalStorage)
    var geometryData: Data?

    // Bounding box
    var boundingBoxMin: BoundingPoint
    var boundingBoxMax: BoundingPoint

    // Physical properties
    var volume: Double // mm³
    var surfaceArea: Double // mm²
    var mass: Double // grams
    var density: Double // g/cm³

    // Material
    var materialName: String
    var materialType: String // "metal", "plastic", "composite"

    // Manufacturing
    var manufacturingProcess: String? // "CNC", "3D_Print", "Sheet_Metal"
    var estimatedCost: Double
    var estimatedTime: Double // minutes

    // Quality
    var tolerance: Double // ±mm
    var surfaceFinish: String // "Ra 1.6 μm"

    // Metadata
    var createdDate: Date
    var modifiedDate: Date
    var createdBy: String
    var status: String // "draft", "review", "approved", "manufactured"

    @Relationship(inverse: \Assembly.parts)
    var assemblies: [Assembly]

    init(
        name: String,
        partNumber: String = "",
        materialName: String = "Aluminum 6061-T6"
    ) {
        self.id = UUID()
        self.name = name
        self.partNumber = partNumber.isEmpty ? "PART-\(UUID().uuidString.prefix(8))" : partNumber
        self.revision = "A"
        self.partDescription = ""
        self.boundingBoxMin = BoundingPoint(x: 0, y: 0, z: 0)
        self.boundingBoxMax = BoundingPoint(x: 100, y: 100, z: 100)
        self.volume = 0
        self.surfaceArea = 0
        self.mass = 0
        self.density = 2.7 // Aluminum default
        self.materialName = materialName
        self.materialType = "metal"
        self.estimatedCost = 0
        self.estimatedTime = 0
        self.tolerance = 0.05 // ±0.05mm default
        self.surfaceFinish = "Ra 1.6 μm"
        self.createdDate = Date()
        self.modifiedDate = Date()
        self.createdBy = "Current User"
        self.status = "draft"
        self.assemblies = []
    }

    // MARK: - Methods
    func updateGeometry(_ data: Data) {
        self.geometryData = data
        self.modifiedDate = Date()
    }

    func calculateMass() -> Double {
        return volume / 1000.0 * density // Convert mm³ to cm³, multiply by density
    }

    func touch() {
        modifiedDate = Date()
    }
}

// MARK: - Supporting Types
struct BoundingPoint: Codable {
    var x: Double
    var y: Double
    var z: Double
}
