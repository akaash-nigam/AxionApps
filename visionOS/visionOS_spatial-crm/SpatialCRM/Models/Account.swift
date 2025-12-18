//
//  Account.swift
//  SpatialCRM
//
//  Account/Customer data model
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class Account {
    // MARK: - Properties

    @Attribute(.unique) var id: UUID
    var name: String
    var industry: String
    var revenue: Decimal
    var employeeCount: Int
    var healthScore: Double
    var riskLevel: RiskLevel

    // Contact Information
    var website: String?
    var phone: String?
    var address: String?

    // Spatial Visualization Properties
    var positionX: Float
    var positionY: Float
    var positionZ: Float
    var visualSize: Float
    var colorHex: String

    // Relationships
    @Relationship(deleteRule: .cascade) var contacts: [Contact]
    @Relationship(deleteRule: .cascade) var opportunities: [Opportunity]
    @Relationship(deleteRule: .cascade) var activities: [Activity]
    @Relationship(inverse: \Territory.accounts) var territories: [Territory]

    // Metadata
    var createdAt: Date
    var updatedAt: Date
    var lastSyncedAt: Date?
    var externalId: String?  // Salesforce/HubSpot ID

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        name: String,
        industry: String = "Technology",
        revenue: Decimal = 0,
        employeeCount: Int = 0,
        healthScore: Double = 50.0,
        riskLevel: RiskLevel = .medium
    ) {
        self.id = id
        self.name = name
        self.industry = industry
        self.revenue = revenue
        self.employeeCount = employeeCount
        self.healthScore = healthScore
        self.riskLevel = riskLevel

        // Initialize spatial properties
        self.positionX = 0
        self.positionY = 0
        self.positionZ = 0
        self.visualSize = 1.0
        self.colorHex = "#007AFF"

        // Initialize empty relationships
        self.contacts = []
        self.opportunities = []
        self.activities = []
        self.territories = []

        // Set timestamps
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // MARK: - Computed Properties

    var position: SIMD3<Float> {
        get { SIMD3(positionX, positionY, positionZ) }
        set {
            positionX = newValue.x
            positionY = newValue.y
            positionZ = newValue.z
        }
    }

    var color: Color {
        Color(hex: colorHex) ?? .blue
    }

    var totalOpportunityValue: Decimal {
        opportunities
            .filter { $0.status == .active }
            .reduce(0) { $0 + $1.amount }
    }

    var primaryContact: Contact? {
        contacts.first { $0.isPrimaryContact }
    }
}

// MARK: - Supporting Types

enum RiskLevel: String, Codable {
    case low
    case medium
    case high
    case critical
}

// MARK: - Sample Data

extension Account {
    static var sample: Account {
        let account = Account(
            name: "Acme Corporation",
            industry: "Enterprise Software",
            revenue: 2_500_000,
            employeeCount: 500,
            healthScore: 92,
            riskLevel: .low
        )
        account.website = "https://acme.example.com"
        account.phone = "+1-555-0123"
        return account
    }

    static var samples: [Account] {
        [
            Account(name: "Acme Corporation", industry: "Enterprise Software", revenue: 2_500_000, employeeCount: 500, healthScore: 92, riskLevel: .low),
            Account(name: "TechCo Industries", industry: "Technology", revenue: 1_200_000, employeeCount: 250, healthScore: 78, riskLevel: .medium),
            Account(name: "Global Enterprises", industry: "Manufacturing", revenue: 5_000_000, employeeCount: 1000, healthScore: 85, riskLevel: .low),
            Account(name: "StartupX", industry: "SaaS", revenue: 500_000, employeeCount: 50, healthScore: 65, riskLevel: .medium),
            Account(name: "MegaCorp", industry: "Retail", revenue: 10_000_000, employeeCount: 5000, healthScore: 45, riskLevel: .high)
        ]
    }
}

// MARK: - Color Extension

extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
