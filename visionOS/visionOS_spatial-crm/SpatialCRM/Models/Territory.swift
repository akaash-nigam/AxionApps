//
//  Territory.swift
//  SpatialCRM
//
//  Territory and SalesRep data models
//

import Foundation
import SwiftData

@Model
final class Territory {
    // MARK: - Properties

    @Attribute(.unique) var id: UUID
    var name: String
    var region: String
    var quota: Decimal
    var actualRevenue: Decimal

    // Geographic bounds (for spatial visualization)
    var boundaryPointsData: Data?  // Encoded array of SIMD3<Float>

    // Heat map data (for performance visualization)
    var heatMapData: Data?

    // Relationships
    @Relationship(deleteRule: .nullify) var accounts: [Account]
    @Relationship(deleteRule: .nullify) var reps: [SalesRep]

    // Metadata
    var createdAt: Date
    var updatedAt: Date

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        name: String,
        region: String,
        quota: Decimal = 0,
        actualRevenue: Decimal = 0
    ) {
        self.id = id
        self.name = name
        self.region = region
        self.quota = quota
        self.actualRevenue = actualRevenue

        // Initialize relationships
        self.accounts = []
        self.reps = []

        // Set timestamps
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // MARK: - Computed Properties

    var quotaAttainment: Double {
        guard quota > 0 else { return 0 }
        return Double(truncating: (actualRevenue / quota) as NSDecimalNumber)
    }

    var boundaryPoints: [SIMD3<Float>] {
        get {
            guard let data = boundaryPointsData else { return [] }
            return (try? JSONDecoder().decode([SIMD3<Float>].self, from: data)) ?? []
        }
        set {
            boundaryPointsData = try? JSONEncoder().encode(newValue)
        }
    }
}

// MARK: - Sales Rep Model

@Model
final class SalesRep {
    // MARK: - Properties

    @Attribute(.unique) var id: UUID
    var firstName: String
    var lastName: String
    var email: String
    var role: SalesRole
    var quota: Decimal
    var achievedRevenue: Decimal

    // Performance Metrics
    var winRate: Double
    var averageDealSize: Decimal
    var activitiesPerWeek: Int

    // Avatar/Profile
    var avatarURL: String?
    var phoneNumber: String?

    // Relationships
    @Relationship(deleteRule: .nullify) var accounts: [Account]
    @Relationship(deleteRule: .nullify) var opportunities: [Opportunity]
    @Relationship(inverse: \Territory.reps) var territories: [Territory]
    @Relationship(deleteRule: .cascade) var activities: [Activity]

    // Metadata
    var createdAt: Date
    var lastLoginAt: Date?
    var externalId: String?

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        firstName: String,
        lastName: String,
        email: String,
        role: SalesRole = .representative,
        quota: Decimal = 0
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.role = role
        self.quota = quota
        self.achievedRevenue = 0

        // Initialize metrics
        self.winRate = 0
        self.averageDealSize = 0
        self.activitiesPerWeek = 0

        // Initialize relationships
        self.accounts = []
        self.opportunities = []
        self.territories = []
        self.activities = []

        // Set timestamp
        self.createdAt = Date()
    }

    // MARK: - Computed Properties

    var fullName: String {
        "\(firstName) \(lastName)"
    }

    var initials: String {
        let first = firstName.prefix(1)
        let last = lastName.prefix(1)
        return "\(first)\(last)".uppercased()
    }

    var quotaAttainment: Double {
        guard quota > 0 else { return 0 }
        return Double(truncating: (achievedRevenue / quota) as NSDecimalNumber)
    }

    var activeOpportunities: [Opportunity] {
        opportunities.filter { $0.status == .active }
    }

    var totalPipelineValue: Decimal {
        activeOpportunities.reduce(0) { $0 + $1.amount }
    }
}

// MARK: - Supporting Types

enum SalesRole: String, Codable {
    case representative
    case accountExecutive
    case accountManager
    case manager
    case director
    case vp
    case cro

    var displayName: String {
        switch self {
        case .representative: return "Sales Representative"
        case .accountExecutive: return "Account Executive"
        case .accountManager: return "Account Manager"
        case .manager: return "Sales Manager"
        case .director: return "Sales Director"
        case .vp: return "VP of Sales"
        case .cro: return "Chief Revenue Officer"
        }
    }
}

// MARK: - Sample Data

extension Territory {
    static var sample: Territory {
        Territory(
            name: "West Coast",
            region: "North America",
            quota: 5_000_000,
            actualRevenue: 3_750_000
        )
    }

    static var samples: [Territory] {
        [
            Territory(name: "West Coast", region: "North America", quota: 5_000_000, actualRevenue: 3_750_000),
            Territory(name: "East Coast", region: "North America", quota: 4_500_000, actualRevenue: 4_200_000),
            Territory(name: "Europe", region: "EMEA", quota: 6_000_000, actualRevenue: 4_800_000),
            Territory(name: "Asia Pacific", region: "APAC", quota: 3_000_000, actualRevenue: 2_100_000)
        ]
    }
}

extension SalesRep {
    static var sample: SalesRep {
        let rep = SalesRep(
            firstName: "John",
            lastName: "Sales",
            email: "john.sales@company.com",
            role: .representative,
            quota: 2_500_000
        )
        rep.achievedRevenue = 1_800_000
        rep.winRate = 0.68
        rep.averageDealSize = 150_000
        rep.activitiesPerWeek = 25
        return rep
    }

    static var samples: [SalesRep] {
        [
            SalesRep(firstName: "John", lastName: "Sales", email: "john@company.com", role: .representative, quota: 2_500_000),
            SalesRep(firstName: "Mary", lastName: "Account", email: "mary@company.com", role: .accountExecutive, quota: 3_000_000),
            SalesRep(firstName: "David", lastName: "Manager", email: "david@company.com", role: .manager, quota: 10_000_000),
            SalesRep(firstName: "Lisa", lastName: "Director", email: "lisa@company.com", role: .director, quota: 25_000_000)
        ]
    }
}
