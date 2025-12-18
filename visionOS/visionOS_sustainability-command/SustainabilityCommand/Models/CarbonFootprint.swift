import Foundation
import SwiftData

// MARK: - Carbon Footprint Model

@Model
final class CarbonFootprintModel {
    @Attribute(.unique) var id: UUID
    var timestamp: Date
    var organizationId: String

    // Scope emissions (tCO2e - tons of CO2 equivalent)
    var scope1Emissions: Double  // Direct emissions
    var scope2Emissions: Double  // Energy indirect
    var scope3Emissions: Double  // Value chain

    // Relationships
    @Relationship(deleteRule: .cascade)
    var emissionSources: [EmissionSourceModel]

    @Relationship(deleteRule: .cascade)
    var facilities: [FacilityModel]

    // Temporal data
    var reportingPeriodStart: Date
    var reportingPeriodEnd: Date

    // Verification
    var verificationStatus: String
    var verifiedAt: Date?
    var verifiedBy: String?

    // Metadata
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        organizationId: String,
        scope1: Double,
        scope2: Double,
        scope3: Double,
        reportingPeriodStart: Date,
        reportingPeriodEnd: Date,
        verificationStatus: String = "pending"
    ) {
        self.id = id
        self.timestamp = timestamp
        self.organizationId = organizationId
        self.scope1Emissions = scope1
        self.scope2Emissions = scope2
        self.scope3Emissions = scope3
        self.reportingPeriodStart = reportingPeriodStart
        self.reportingPeriodEnd = reportingPeriodEnd
        self.verificationStatus = verificationStatus
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    var totalEmissions: Double {
        scope1Emissions + scope2Emissions + scope3Emissions
    }
}

// MARK: - Emission Source Model

@Model
final class EmissionSourceModel {
    @Attribute(.unique) var id: UUID
    var name: String
    var category: String  // manufacturing, transportation, facilities, etc.
    var emissions: Double  // tCO2e
    var percentage: Double  // Percentage of total

    // Location (optional)
    var latitude: Double?
    var longitude: Double?

    // Reduction potential
    var reductionPotential: Double?
    var reductionCost: Double?

    // Relationship to parent footprint
    var carbonFootprint: CarbonFootprintModel?

    init(
        id: UUID = UUID(),
        name: String,
        category: String,
        emissions: Double,
        percentage: Double,
        latitude: Double? = nil,
        longitude: Double? = nil,
        reductionPotential: Double? = nil
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.emissions = emissions
        self.percentage = percentage
        self.latitude = latitude
        self.longitude = longitude
        self.reductionPotential = reductionPotential
    }
}

// MARK: - View Model (Non-persistent)

struct CarbonFootprint: Identifiable {
    let id: UUID
    let timestamp: Date
    let organizationId: String

    let scope1Emissions: Double
    let scope2Emissions: Double
    let scope3Emissions: Double

    let emissionSources: [EmissionSource]
    let facilities: [Facility]

    let reportingPeriod: DateInterval
    let verificationStatus: VerificationStatus

    var totalEmissions: Double {
        scope1Emissions + scope2Emissions + scope3Emissions
    }

    var scopeBreakdown: [ScopeEmission] {
        [
            ScopeEmission(scope: .scope1, emissions: scope1Emissions),
            ScopeEmission(scope: .scope2, emissions: scope2Emissions),
            ScopeEmission(scope: .scope3, emissions: scope3Emissions)
        ]
    }

    // Initialize from SwiftData model
    init(from model: CarbonFootprintModel) {
        self.id = model.id
        self.timestamp = model.timestamp
        self.organizationId = model.organizationId
        self.scope1Emissions = model.scope1Emissions
        self.scope2Emissions = model.scope2Emissions
        self.scope3Emissions = model.scope3Emissions
        self.emissionSources = model.emissionSources.map { EmissionSource(from: $0) }
        self.facilities = model.facilities.map { Facility(from: $0) }
        self.reportingPeriod = DateInterval(
            start: model.reportingPeriodStart,
            end: model.reportingPeriodEnd
        )
        self.verificationStatus = VerificationStatus(rawValue: model.verificationStatus) ?? .pending
    }
}

struct EmissionSource: Identifiable {
    let id: UUID
    let name: String
    let category: EmissionCategory
    let emissions: Double
    let percentage: Double
    let location: GeoCoordinate?
    let reductionPotential: Double?

    init(from model: EmissionSourceModel) {
        self.id = model.id
        self.name = model.name
        self.category = EmissionCategory(rawValue: model.category) ?? .other
        self.emissions = model.emissions
        self.percentage = model.percentage
        if let lat = model.latitude, let lon = model.longitude {
            self.location = GeoCoordinate(latitude: lat, longitude: lon)
        } else {
            self.location = nil
        }
        self.reductionPotential = model.reductionPotential
    }
}

enum EmissionCategory: String, Codable, CaseIterable {
    case manufacturing = "Manufacturing"
    case transportation = "Transportation"
    case facilities = "Facilities"
    case energy = "Energy"
    case waste = "Waste"
    case supplyChain = "Supply Chain"
    case other = "Other"

    var icon: String {
        switch self {
        case .manufacturing: return "gearshape.2"
        case .transportation: return "car.fill"
        case .facilities: return "building.2"
        case .energy: return "bolt.fill"
        case .waste: return "trash"
        case .supplyChain: return "shippingbox"
        case .other: return "ellipsis.circle"
        }
    }

    var color: String {
        switch self {
        case .manufacturing: return "#E34034"
        case .transportation: return "#F2994A"
        case .facilities: return "#F2C94C"
        case .energy: return "#F9A826"
        case .waste: return "#828282"
        case .supplyChain: return "#2D9CDB"
        case .other: return "#828282"
        }
    }
}

struct ScopeEmission: Identifiable {
    let id = UUID()
    let scope: EmissionScope
    let emissions: Double

    var percentage: Double = 0.0
}

enum EmissionScope: String, Codable {
    case scope1 = "Scope 1"
    case scope2 = "Scope 2"
    case scope3 = "Scope 3"

    var description: String {
        switch self {
        case .scope1: return "Direct emissions from owned or controlled sources"
        case .scope2: return "Indirect emissions from purchased energy"
        case .scope3: return "All other indirect emissions in the value chain"
        }
    }
}

enum VerificationStatus: String, Codable {
    case pending = "pending"
    case verified = "verified"
    case rejected = "rejected"

    var displayName: String {
        switch self {
        case .pending: return "Pending Verification"
        case .verified: return "Verified"
        case .rejected: return "Verification Rejected"
        }
    }

    var color: String {
        switch self {
        case .pending: return "#F2C94C"
        case .verified: return "#27AE60"
        case .rejected: return "#E34034"
        }
    }
}

struct GeoCoordinate: Codable, Equatable {
    let latitude: Double
    let longitude: Double
    var altitude: Double?

    var description: String {
        String(format: "%.4f°, %.4f°", latitude, longitude)
    }
}
