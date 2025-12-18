import Foundation
import SwiftData

// MARK: - Facility Model (SwiftData)

@Model
final class FacilityModel {
    @Attribute(.unique) var id: UUID
    var name: String
    var facilityType: String

    // Location
    var latitude: Double
    var longitude: Double
    var altitude: Double?
    var address: String?
    var city: String?
    var country: String?

    // Environmental metrics
    var energyConsumption: Double  // kWh
    var waterUsage: Double  // liters
    var wasteGeneration: Double  // kg
    var emissions: Double  // tCO2e

    // Renewable energy
    var renewableEnergyPercentage: Double

    // 3D visualization position (relative to Earth)
    var spatialX: Float
    var spatialY: Float
    var spatialZ: Float

    // Metadata
    var createdAt: Date
    var updatedAt: Date

    // Relationship to parent carbon footprint
    var carbonFootprint: CarbonFootprintModel?

    init(
        id: UUID = UUID(),
        name: String,
        facilityType: String,
        latitude: Double,
        longitude: Double,
        emissions: Double,
        energyConsumption: Double = 0,
        waterUsage: Double = 0,
        wasteGeneration: Double = 0,
        renewableEnergyPercentage: Double = 0
    ) {
        self.id = id
        self.name = name
        self.facilityType = facilityType
        self.latitude = latitude
        self.longitude = longitude
        self.emissions = emissions
        self.energyConsumption = energyConsumption
        self.waterUsage = waterUsage
        self.wasteGeneration = wasteGeneration
        self.renewableEnergyPercentage = renewableEnergyPercentage
        self.createdAt = Date()
        self.updatedAt = Date()

        // Calculate spatial position (will be set properly during visualization)
        self.spatialX = 0
        self.spatialY = 0
        self.spatialZ = 0
    }
}

// MARK: - View Model (Non-persistent)

struct Facility: Identifiable, Equatable {
    let id: UUID
    let name: String
    let facilityType: FacilityType
    let location: GeoCoordinate
    let address: Address?

    let energyMetrics: EnergyMetrics
    let waterMetrics: WaterMetrics
    let wasteMetrics: WasteMetrics
    let emissions: Double

    let spatialPosition: SIMD3<Float>

    var efficiencyRating: EfficiencyRating {
        // Calculate based on emissions per unit of output
        if emissions < 500 {
            return .excellent
        } else if emissions < 2000 {
            return .good
        } else if emissions < 5000 {
            return .fair
        } else {
            return .poor
        }
    }

    init(from model: FacilityModel) {
        self.id = model.id
        self.name = model.name
        self.facilityType = FacilityType(rawValue: model.facilityType) ?? .other
        self.location = GeoCoordinate(
            latitude: model.latitude,
            longitude: model.longitude,
            altitude: model.altitude
        )
        self.address = Address(
            street: model.address,
            city: model.city ?? "",
            country: model.country ?? ""
        )
        self.energyMetrics = EnergyMetrics(
            consumption: model.energyConsumption,
            renewablePercentage: model.renewableEnergyPercentage
        )
        self.waterMetrics = WaterMetrics(usage: model.waterUsage)
        self.wasteMetrics = WasteMetrics(generation: model.wasteGeneration)
        self.emissions = model.emissions
        self.spatialPosition = SIMD3<Float>(
            model.spatialX,
            model.spatialY,
            model.spatialZ
        )
    }

    static func == (lhs: Facility, rhs: Facility) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Supporting Types

enum FacilityType: String, Codable, CaseIterable {
    case manufacturing = "Manufacturing"
    case warehouse = "Warehouse"
    case office = "Office"
    case dataCenter = "Data Center"
    case retail = "Retail"
    case distribution = "Distribution"
    case research = "Research"
    case other = "Other"

    var icon: String {
        switch self {
        case .manufacturing: return "building.2.fill"
        case .warehouse: return "shippingbox.fill"
        case .office: return "building.fill"
        case .dataCenter: return "server.rack"
        case .retail: return "storefront"
        case .distribution: return "truck.box.fill"
        case .research: return "flask.fill"
        case .other: return "building"
        }
    }
}

struct Address {
    let street: String?
    let city: String
    let country: String

    var fullAddress: String {
        [street, city, country]
            .compactMap { $0 }
            .joined(separator: ", ")
    }
}

struct EnergyMetrics {
    let consumption: Double  // kWh
    let renewablePercentage: Double  // 0-100

    var renewableEnergy: Double {
        consumption * (renewablePercentage / 100.0)
    }

    var fossilFuelEnergy: Double {
        consumption - renewableEnergy
    }
}

struct WaterMetrics {
    let usage: Double  // liters
    var recycledPercentage: Double = 0  // 0-100

    var recycledWater: Double {
        usage * (recycledPercentage / 100.0)
    }
}

struct WasteMetrics {
    let generation: Double  // kg
    var divertedFromLandfill: Double = 0  // 0-100

    var landfillWaste: Double {
        generation * (1.0 - divertedFromLandfill / 100.0)
    }

    var divertedWaste: Double {
        generation * (divertedFromLandfill / 100.0)
    }
}

enum EfficiencyRating: String {
    case excellent = "Excellent"
    case good = "Good"
    case fair = "Fair"
    case poor = "Poor"

    var color: String {
        switch self {
        case .excellent: return "#27AE60"
        case .good: return "#6FCF97"
        case .fair: return "#F2C94C"
        case .poor: return "#E34034"
        }
    }

    var stars: Int {
        switch self {
        case .excellent: return 5
        case .good: return 4
        case .fair: return 3
        case .poor: return 2
        }
    }
}
