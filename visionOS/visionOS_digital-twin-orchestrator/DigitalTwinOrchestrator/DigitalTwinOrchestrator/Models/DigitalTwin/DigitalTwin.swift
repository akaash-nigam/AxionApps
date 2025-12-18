import Foundation
import SwiftData
import RealityKit

/// Digital Twin Model - Represents a virtual replica of a physical asset
@Model
final class DigitalTwin: @unchecked Sendable {
    @Attribute(.unique) var id: UUID
    var name: String
    var assetType: AssetType
    var location: GeoLocation?
    var modelURL: URL?

    // Relationships
    @Relationship(deleteRule: .cascade) var sensors: [Sensor]
    @Relationship(deleteRule: .cascade) var components: [Component]
    @Relationship(deleteRule: .nullify) var predictions: [Prediction]

    // Real-time state
    var healthScore: Double
    var operationalStatus: OperationalStatus
    var lastUpdateTimestamp: Date

    // 3D representation
    var spatialAnchorData: Data?  // Serialized spatial anchor
    var transformMatrix: [Float]  // 4x4 matrix as flat array

    // Metadata
    var manufacturer: String?
    var modelNumber: String?
    var serialNumber: String?
    var installDate: Date?
    var warrantyExpiration: Date?

    var createdDate: Date
    var modifiedDate: Date
    var metadata: [String: String]

    init(
        id: UUID = UUID(),
        name: String,
        assetType: AssetType,
        location: GeoLocation? = nil,
        modelURL: URL? = nil,
        healthScore: Double = 100.0,
        operationalStatus: OperationalStatus = .normal
    ) {
        self.id = id
        self.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        self.assetType = assetType
        self.location = location
        self.modelURL = modelURL
        // Clamp health score to valid range 0-100
        self.healthScore = min(100, max(0, healthScore))
        self.operationalStatus = operationalStatus
        self.lastUpdateTimestamp = Date()
        self.createdDate = Date()
        self.modifiedDate = Date()
        self.metadata = [:]
        self.sensors = []
        self.components = []
        self.predictions = []
        self.transformMatrix = Array(repeating: 0, count: 16)
        // Set identity matrix
        self.transformMatrix[0] = 1
        self.transformMatrix[5] = 1
        self.transformMatrix[10] = 1
        self.transformMatrix[15] = 1
    }

    // MARK: - Validation

    /// Validation errors for DigitalTwin
    enum ValidationError: Error, LocalizedError {
        case emptyName
        case invalidHealthScore(Double)
        case invalidModelURL(URL)

        var errorDescription: String? {
            switch self {
            case .emptyName:
                return "Digital twin name cannot be empty"
            case .invalidHealthScore(let score):
                return "Health score \(score) is invalid. Must be between 0 and 100."
            case .invalidModelURL(let url):
                return "Model URL '\(url)' is not a valid USDZ file"
            }
        }
    }

    /// Validate the digital twin before saving
    func validate() throws {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ValidationError.emptyName
        }

        guard healthScore >= 0 && healthScore <= 100 else {
            throw ValidationError.invalidHealthScore(healthScore)
        }

        if let url = modelURL {
            let validExtensions = ["usdz", "usda", "usdc", "reality"]
            guard validExtensions.contains(url.pathExtension.lowercased()) else {
                throw ValidationError.invalidModelURL(url)
            }
        }
    }

    /// Create a validated digital twin, throwing on invalid input
    static func createValidated(
        name: String,
        assetType: AssetType,
        location: GeoLocation? = nil,
        modelURL: URL? = nil,
        healthScore: Double = 100.0,
        operationalStatus: OperationalStatus = .normal
    ) throws -> DigitalTwin {
        // Validate name
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            throw ValidationError.emptyName
        }

        // Validate health score
        guard healthScore >= 0 && healthScore <= 100 else {
            throw ValidationError.invalidHealthScore(healthScore)
        }

        // Validate model URL if provided
        if let url = modelURL {
            let validExtensions = ["usdz", "usda", "usdc", "reality"]
            guard validExtensions.contains(url.pathExtension.lowercased()) else {
                throw ValidationError.invalidModelURL(url)
            }
        }

        return DigitalTwin(
            name: trimmedName,
            assetType: assetType,
            location: location,
            modelURL: modelURL,
            healthScore: healthScore,
            operationalStatus: operationalStatus
        )
    }

    /// Update health score with validation and automatic status update
    func updateHealth(_ newScore: Double) {
        let clampedScore = min(100, max(0, newScore))
        healthScore = clampedScore
        modifiedDate = Date()

        // Auto-update operational status based on health
        switch clampedScore {
        case HealthThresholds.excellent...100:
            operationalStatus = .optimal
        case HealthThresholds.good..<HealthThresholds.excellent:
            operationalStatus = .normal
        case HealthThresholds.fair..<HealthThresholds.good:
            operationalStatus = .warning
        default:
            operationalStatus = .critical
        }
    }

    // MARK: - Computed Properties

    var statusColor: String {
        switch operationalStatus {
        case .optimal: return "green"
        case .normal: return "blue"
        case .warning: return "yellow"
        case .critical: return "red"
        case .offline: return "gray"
        }
    }

    var healthCategory: HealthCategory {
        switch healthScore {
        case 90...100: return .excellent
        case 70..<90: return .good
        case 50..<70: return .fair
        case 0..<50: return .critical
        default: return .unknown
        }
    }

    var activeSensorCount: Int {
        sensors.filter { $0.isActive }.count
    }

    var criticalPredictionsCount: Int {
        predictions.filter { $0.severity == .critical }.count
    }

    // MARK: - Methods

    func updateHealth(basedOn sensors: [Sensor]) {
        guard !sensors.isEmpty else {
            healthScore = 0
            operationalStatus = .offline
            return
        }

        // Calculate weighted health score
        let sensorHealth = sensors.map { sensor -> Double in
            if !sensor.isActive {
                return 0.5
            }

            if sensor.currentValue < sensor.normalRange.lowerBound ||
               sensor.currentValue > sensor.normalRange.upperBound {
                return 0.7
            }

            return 1.0
        }.reduce(0.0, +) / Double(sensors.count)

        healthScore = sensorHealth * 100.0

        // Update operational status
        switch healthScore {
        case 90...100:
            operationalStatus = .optimal
        case 70..<90:
            operationalStatus = .normal
        case 50..<70:
            operationalStatus = .warning
        case 0..<50:
            operationalStatus = .critical
        default:
            operationalStatus = .offline
        }

        lastUpdateTimestamp = Date()
        modifiedDate = Date()
    }
}

// MARK: - Supporting Types

enum AssetType: String, Codable {
    case turbine
    case reactor
    case conveyor
    case robot
    case hvac
    case powerGrid
    case pump
    case compressor
    case boiler
    case heatExchanger
    case motor
    case generator
    case valve
    case tank
    case pipeline
    case custom

    var displayName: String {
        switch self {
        case .turbine: return "Turbine"
        case .reactor: return "Reactor"
        case .conveyor: return "Conveyor"
        case .robot: return "Robot"
        case .hvac: return "HVAC System"
        case .powerGrid: return "Power Grid"
        case .pump: return "Pump"
        case .compressor: return "Compressor"
        case .boiler: return "Boiler"
        case .heatExchanger: return "Heat Exchanger"
        case .motor: return "Motor"
        case .generator: return "Generator"
        case .valve: return "Valve"
        case .tank: return "Tank"
        case .pipeline: return "Pipeline"
        case .custom: return "Custom Equipment"
        }
    }

    var iconName: String {
        switch self {
        case .turbine: return "fan.fill"
        case .reactor: return "atom"
        case .conveyor: return "arrow.right.circle.fill"
        case .robot: return "figure.walk"
        case .hvac: return "air.conditioner.horizontal.fill"
        case .powerGrid: return "bolt.fill"
        case .pump: return "pump.fill"
        case .compressor: return "figure.pool.swim"
        case .boiler: return "flame.fill"
        case .heatExchanger: return "arrow.left.arrow.right"
        case .motor: return "gearshape.2.fill"
        case .generator: return "battery.100.bolt"
        case .valve: return "circle.hexagongrid.fill"
        case .tank: return "cylinder.fill"
        case .pipeline: return "pipe.and.drop.fill"
        case .custom: return "gearshape.fill"
        }
    }
}

enum OperationalStatus: String, Codable {
    case optimal
    case normal
    case warning
    case critical
    case offline

    var displayName: String {
        rawValue.capitalized
    }
}

struct GeoLocation: Codable {
    var latitude: Double
    var longitude: Double
    var altitude: Double?
    var facilityName: String?
    var building: String?
    var floor: String?
    var room: String?

    var displayString: String {
        if let room, let building {
            return "\(building) - \(room)"
        } else if let building {
            return building
        } else if let facilityName {
            return facilityName
        } else {
            return String(format: "%.4f, %.4f", latitude, longitude)
        }
    }
}

// MARK: - Extensions

extension DigitalTwin {
    /// Create a sample digital twin for testing
    static func sample(name: String, type: AssetType) -> DigitalTwin {
        let twin = DigitalTwin(
            name: name,
            assetType: type,
            location: GeoLocation(
                latitude: 37.7749,
                longitude: -122.4194,
                facilityName: "Sample Facility",
                building: "Building A",
                floor: "Floor 2",
                room: "Room 201"
            ),
            healthScore: Double.random(in: 60...100),
            operationalStatus: Bool.random() ? .optimal : .normal
        )

        // Add sample sensors
        twin.sensors = [
            Sensor.sample(name: "Temperature", type: .temperature),
            Sensor.sample(name: "Pressure", type: .pressure),
            Sensor.sample(name: "Vibration", type: .vibration)
        ]

        // Add sample components
        twin.components = [
            Component.sample(name: "Main Rotor", type: "Rotor"),
            Component.sample(name: "Bearing Assembly", type: "Bearing"),
            Component.sample(name: "Control Unit", type: "Electronics")
        ]

        return twin
    }

    /// Create multiple sample twins
    static func sampleTwins() -> [DigitalTwin] {
        [
            sample(name: "Turbine A-1", type: .turbine),
            sample(name: "Turbine A-2", type: .turbine),
            sample(name: "Turbine A-3", type: .turbine),
            sample(name: "Reactor B-1", type: .reactor),
            sample(name: "Conveyor C-1", type: .conveyor),
            sample(name: "Robot R-1", type: .robot),
            sample(name: "HVAC System H-1", type: .hvac),
            sample(name: "Pump P-1", type: .pump),
            sample(name: "Compressor CM-1", type: .compressor),
            sample(name: "Heat Exchanger HE-1", type: .heatExchanger)
        ]
    }
}
