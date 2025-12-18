import Foundation

// MARK: - Room Layout
struct RoomLayout: Identifiable, Codable {
    let id: UUID
    var scannedDate: Date
    var bounds: BoundingBox
    var furniture: [FurnitureItem]
    var safetyBoundaries: [SafetyBoundary]
    var hidingSpots: [HidingSpot]

    init(
        id: UUID = UUID(),
        scannedDate: Date = Date(),
        bounds: BoundingBox,
        furniture: [FurnitureItem] = [],
        safetyBoundaries: [SafetyBoundary] = [],
        hidingSpots: [HidingSpot] = []
    ) {
        self.id = id
        self.scannedDate = scannedDate
        self.bounds = bounds
        self.furniture = furniture
        self.safetyBoundaries = safetyBoundaries
        self.hidingSpots = hidingSpots
    }
}

// MARK: - Bounding Box
struct BoundingBox: Codable {
    var min: SIMD3<Float>
    var max: SIMD3<Float>

    var center: SIMD3<Float> {
        (min + max) / 2
    }

    var size: SIMD3<Float> {
        max - min
    }
}

// MARK: - Furniture Item
struct FurnitureItem: Identifiable, Codable {
    let id: UUID
    var type: FurnitureType
    var position: SIMD3<Float>
    var size: SIMD3<Float>
    var orientation: simd_quatf
    var hidingPotential: Float  // 0.0 - 1.0

    init(
        id: UUID = UUID(),
        type: FurnitureType,
        position: SIMD3<Float>,
        size: SIMD3<Float>,
        orientation: simd_quatf,
        hidingPotential: Float
    ) {
        self.id = id
        self.type = type
        self.position = position
        self.size = size
        self.orientation = orientation
        self.hidingPotential = min(max(hidingPotential, 0.0), 1.0)
    }

    var forwardVector: SIMD3<Float> {
        // Calculate forward vector from orientation
        let forward = SIMD3<Float>(0, 0, 1)
        return simd_act(orientation, forward)
    }
}

// MARK: - Furniture Type
enum FurnitureType: String, Codable {
    case sofa, chair, table, desk
    case cabinet, shelf, bookshelf
    case bed, dresser, wardrobe
    case plant, decoration

    var defaultHidingPotential: Float {
        switch self {
        case .sofa, .bed, .wardrobe:
            return 0.9
        case .table, .desk, .cabinet:
            return 0.7
        case .chair, .shelf, .bookshelf:
            return 0.5
        case .plant, .decoration:
            return 0.3
        case .dresser:
            return 0.6
        }
    }
}

// MARK: - Hiding Spot
struct HidingSpot: Identifiable, Codable {
    let id: UUID
    var location: SIMD3<Float>
    var quality: Float  // 0.0 - 1.0
    var accessibility: AccessibilityLevel
    var associatedFurniture: UUID?

    init(
        id: UUID = UUID(),
        location: SIMD3<Float>,
        quality: Float,
        accessibility: AccessibilityLevel,
        associatedFurniture: UUID? = nil
    ) {
        self.id = id
        self.location = location
        self.quality = min(max(quality, 0.0), 1.0)
        self.accessibility = accessibility
        self.associatedFurniture = associatedFurniture
    }
}

// MARK: - Accessibility Level
enum AccessibilityLevel: String, Codable {
    case easy      // All ages and abilities
    case moderate  // Requires some mobility
    case difficult // Requires good mobility

    func isAccessible(for requirement: AccessibilityRequirement) -> Bool {
        switch (self, requirement) {
        case (.easy, _):
            return true
        case (.moderate, .moderate), (.moderate, .difficult):
            return true
        case (.difficult, .difficult):
            return true
        default:
            return false
        }
    }
}

enum AccessibilityRequirement {
    case easy, moderate, difficult
}

// MARK: - Safety Boundary
struct SafetyBoundary: Identifiable, Codable {
    let id: UUID
    var points: [SIMD3<Float>]
    var warningDistance: Float = 0.5
    var hardBoundaryDistance: Float = 0.1

    init(
        id: UUID = UUID(),
        points: [SIMD3<Float>],
        warningDistance: Float = 0.5,
        hardBoundaryDistance: Float = 0.1
    ) {
        self.id = id
        self.points = points
        self.warningDistance = warningDistance
        self.hardBoundaryDistance = hardBoundaryDistance
    }
}
