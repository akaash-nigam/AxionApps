import Foundation
import SwiftData

@Model
final class SafetyScenario {
    var id: UUID
    var name: String
    var scenarioDescription: String
    var environment: EnvironmentType
    var realityKitScene: String // Reference to .usda file
    var difficultyModifiers: [String] = []
    var timeLimit: TimeInterval?
    var passingScore: Double

    @Relationship(deleteRule: .cascade)
    var hazards: [Hazard] = []

    var correctProcedures: [String] = []
    var learningPoints: [String] = []

    init(
        name: String,
        description: String,
        environment: EnvironmentType,
        realityKitScene: String,
        passingScore: Double = 70.0
    ) {
        self.id = UUID()
        self.name = name
        self.scenarioDescription = description
        self.environment = environment
        self.realityKitScene = realityKitScene
        self.passingScore = passingScore
    }
}

// MARK: - Environment Type

enum EnvironmentType: String, Codable, CaseIterable {
    case factoryFloor = "Factory Floor"
    case constructionSite = "Construction Site"
    case chemicalPlant = "Chemical Plant"
    case warehouse = "Warehouse"
    case laboratorychemicalLab = "Laboratory"
    case confinedSpace = "Confined Space"
    case heightsScaffolding = "Heights/Scaffolding"
    case electricalRoom = "Electrical Room"
    case oilAndGas = "Oil & Gas Facility"
    case miningOperation = "Mining Operation"

    var backgroundImage: String {
        switch self {
        case .factoryFloor: return "factory_background"
        case .constructionSite: return "construction_background"
        case .chemicalPlant: return "chemical_plant_background"
        case .warehouse: return "warehouse_background"
        case .laboratorychemicalLab: return "lab_background"
        case .confinedSpace: return "confined_space_background"
        case .heightsScaffolding: return "heights_background"
        case .electricalRoom: return "electrical_background"
        case .oilAndGas: return "oil_gas_background"
        case .miningOperation: return "mining_background"
        }
    }
}

// MARK: - Hazard

@Model
final class Hazard {
    var id: UUID
    var type: HazardType
    var severity: SeverityLevel
    var name: String
    var hazardDescription: String

    // Spatial properties
    var locationX: Float
    var locationY: Float
    var locationZ: Float
    var radius: Float

    var requiresPPE: [PPEType] = []
    var mitigationSteps: [String] = []
    var visualIndicators: [String] = []
    var audioWarnings: [String] = []

    var isActive: Bool = true
    var isDetected: Bool = false

    var location: SIMD3<Float> {
        get { SIMD3<Float>(locationX, locationY, locationZ) }
        set {
            locationX = newValue.x
            locationY = newValue.y
            locationZ = newValue.z
        }
    }

    init(
        type: HazardType,
        severity: SeverityLevel,
        name: String,
        description: String,
        location: SIMD3<Float>,
        radius: Float = 2.0
    ) {
        self.id = UUID()
        self.type = type
        self.severity = severity
        self.name = name
        self.hazardDescription = description
        self.locationX = location.x
        self.locationY = location.y
        self.locationZ = location.z
        self.radius = radius
    }

    func isNearPosition(_ position: SIMD3<Float>) -> Bool {
        let distance = simd_distance(location, position)
        return distance < radius
    }
}

// MARK: - Hazard Type

enum HazardType: String, Codable, CaseIterable {
    case electrical = "Electrical"
    case chemical = "Chemical"
    case mechanical = "Mechanical"
    case fall = "Fall"
    case fire = "Fire"
    case explosion = "Explosion"
    case radiation = "Radiation"
    case biological = "Biological"
    case ergonomic = "Ergonomic"
    case noise = "Noise"
    case heat = "Heat"
    case cold = "Cold"
    case slipTrip = "Slip/Trip"
    case caughtBetween = "Caught Between"
    case struckBy = "Struck By"

    var color: String {
        switch self {
        case .electrical: return "yellow"
        case .chemical: return "orange"
        case .mechanical: return "red"
        case .fall: return "purple"
        case .fire: return "red"
        case .explosion: return "red"
        case .radiation: return "green"
        case .biological: return "blue"
        case .ergonomic: return "gray"
        case .noise: return "yellow"
        case .heat: return "orange"
        case .cold: return "blue"
        case .slipTrip: return "yellow"
        case .caughtBetween: return "red"
        case .struckBy: return "orange"
        }
    }
}

// MARK: - Severity Level

enum SeverityLevel: String, Codable, Comparable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case critical = "Critical"
    case catastrophic = "Catastrophic"

    var order: Int {
        switch self {
        case .low: return 0
        case .medium: return 1
        case .high: return 2
        case .critical: return 3
        case .catastrophic: return 4
        }
    }

    static func < (lhs: SeverityLevel, rhs: SeverityLevel) -> Bool {
        lhs.order < rhs.order
    }

    var color: String {
        switch self {
        case .low: return "green"
        case .medium: return "yellow"
        case .high: return "orange"
        case .critical: return "red"
        case .catastrophic: return "purple"
        }
    }
}

// MARK: - PPE Type

enum PPEType: String, Codable, CaseIterable {
    case hardHat = "Hard Hat"
    case safetyGlasses = "Safety Glasses"
    case hearingProtection = "Hearing Protection"
    case respirator = "Respirator"
    case gloves = "Gloves"
    case safetyBoots = "Safety Boots"
    case harness = "Safety Harness"
    case vest = "High-Visibility Vest"
    case faceshield = "Face Shield"
    case chemicalSuit = "Chemical Suit"

    var icon: String {
        switch self {
        case .hardHat: return "figure.stand"
        case .safetyGlasses: return "eyeglasses"
        case .hearingProtection: return "ear.fill"
        case .respirator: return "lungs.fill"
        case .gloves: return "hand.raised.fill"
        case .safetyBoots: return "shoeprints.fill"
        case .harness: return "figure.walk"
        case .vest: return "person.fill"
        case .faceshield: return "facemask.fill"
        case .chemicalSuit: return "person.fill.checkmark"
        }
    }
}
