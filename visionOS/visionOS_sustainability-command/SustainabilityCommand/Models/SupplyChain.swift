import Foundation
import SwiftData

// MARK: - Supply Chain Model (SwiftData)

@Model
final class SupplyChainModel {
    @Attribute(.unique) var id: UUID
    var productId: String
    var productName: String
    var totalEmissions: Double  // tCO2e
    var totalDistance: Double  // km

    // Metadata
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        productId: String,
        productName: String,
        totalEmissions: Double,
        totalDistance: Double
    ) {
        self.id = id
        self.productId = productId
        self.productName = productName
        self.totalEmissions = totalEmissions
        self.totalDistance = totalDistance
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: - View Model (Non-persistent)

struct SupplyChain: Identifiable {
    let id: UUID
    let productId: String
    let productName: String
    let stages: [SupplyChainStage]
    let totalEmissions: Double
    let totalDistance: Double

    var emissionsPerKm: Double {
        totalDistance > 0 ? totalEmissions / totalDistance : 0
    }

    init(from model: SupplyChainModel) {
        self.id = model.id
        self.productId = model.productId
        self.productName = model.productName
        self.totalEmissions = model.totalEmissions
        self.totalDistance = model.totalDistance
        self.stages = []  // Would be loaded from relationships
    }
}

struct SupplyChainStage: Identifiable {
    let id: UUID
    let name: String
    let supplier: Supplier
    let location: GeoCoordinate
    let emissions: Double
    let transportMethod: TransportMethod
    let nextStageId: UUID?

    var emissionIntensity: EmissionIntensity {
        if emissions < 100 {
            return .low
        } else if emissions < 500 {
            return .medium
        } else {
            return .high
        }
    }
}

struct Supplier: Identifiable {
    let id: UUID
    let name: String
    let country: String
    let rating: SupplierRating
    let certifications: [String]
}

enum SupplierRating: String, Codable {
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
}

enum TransportMethod: String, Codable {
    case sea = "Sea Freight"
    case air = "Air Freight"
    case rail = "Rail"
    case truck = "Truck"
    case pipeline = "Pipeline"

    var emissionFactor: Double {
        // kg CO2e per ton-km
        switch self {
        case .sea: return 0.01
        case .air: return 0.50
        case .rail: return 0.03
        case .truck: return 0.06
        case .pipeline: return 0.02
        }
    }

    var icon: String {
        switch self {
        case .sea: return "ferry"
        case .air: return "airplane"
        case .rail: return "train.side.front.car"
        case .truck: return "truck.box"
        case .pipeline: return "pipe.and.drop"
        }
    }
}

enum EmissionIntensity {
    case low
    case medium
    case high

    var color: String {
        switch self {
        case .low: return "#27AE60"
        case .medium: return "#F2C94C"
        case .high: return "#E34034"
        }
    }
}
