//
//  RiskAssessment.swift
//  Financial Operations Platform
//
//  Risk assessment and management models
//

import Foundation
import SwiftData
import simd

@Model
final class RiskAssessment: Identifiable {
    // MARK: - Properties

    @Attribute(.unique) var id: UUID
    var riskType: RiskType
    var severity: RiskSeverity
    var probability: Double // 0.0 - 1.0
    var impact: Decimal // Monetary impact
    var description: String
    var mitigationStrategy: String?
    var owner: String
    var status: RiskStatus
    var identifiedDate: Date
    var reviewDate: Date
    var resolvedDate: Date?

    // Spatial Properties for Risk Topography
    var topographyPositionX: Float
    var topographyPositionY: Float
    var topographyPositionZ: Float
    var topographyElevation: Float // Higher = more severe

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        riskType: RiskType,
        severity: RiskSeverity,
        probability: Double,
        impact: Decimal,
        description: String,
        mitigationStrategy: String? = nil,
        owner: String,
        status: RiskStatus = .identified,
        identifiedDate: Date = Date(),
        reviewDate: Date,
        topographyPosition: SIMD3<Float> = SIMD3<Float>(0, 0, 0),
        topographyElevation: Float = 0
    ) {
        self.id = id
        self.riskType = riskType
        self.severity = severity
        self.probability = probability
        self.impact = impact
        self.description = description
        self.mitigationStrategy = mitigationStrategy
        self.owner = owner
        self.status = status
        self.identifiedDate = identifiedDate
        self.reviewDate = reviewDate
        self.topographyPositionX = topographyPosition.x
        self.topographyPositionY = topographyPosition.y
        self.topographyPositionZ = topographyPosition.z
        self.topographyElevation = topographyElevation
    }

    // MARK: - Computed Properties

    var topographyPosition: SIMD3<Float> {
        get {
            SIMD3<Float>(topographyPositionX, topographyPositionY, topographyPositionZ)
        }
        set {
            topographyPositionX = newValue.x
            topographyPositionY = newValue.y
            topographyPositionZ = newValue.z
        }
    }

    var riskScore: Double {
        // Risk score = probability × severity (0-100 scale)
        probability * Double(severity.numericValue) * 20
    }

    var isOverdue: Bool {
        reviewDate < Date() && status != .resolved
    }

    var formattedImpact: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: impact as NSDecimalNumber) ?? "\(impact)"
    }

    var daysToReview: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: reviewDate).day ?? 0
    }
}

// MARK: - Risk Type

enum RiskType: String, Codable, CaseIterable {
    case market
    case credit
    case liquidity
    case operational
    case compliance

    var displayName: String {
        rawValue.capitalized + " Risk"
    }

    var icon: String {
        switch self {
        case .market: return "chart.line.uptrend.xyaxis"
        case .credit: return "creditcard"
        case .liquidity: return "drop.fill"
        case .operational: return "gearshape"
        case .compliance: return "checkmark.shield"
        }
    }

    var color: (red: Float, green: Float, blue: Float) {
        switch self {
        case .market: return (1.0, 0.3, 0.3) // Red
        case .credit: return (1.0, 0.6, 0.0) // Orange
        case .liquidity: return (0.0, 0.5, 1.0) // Blue
        case .operational: return (0.6, 0.4, 0.8) // Purple
        case .compliance: return (1.0, 0.8, 0.0) // Yellow
        }
    }
}

// MARK: - Risk Severity

enum RiskSeverity: String, Codable, CaseIterable {
    case low
    case medium
    case high
    case critical

    var displayName: String {
        rawValue.capitalized
    }

    var numericValue: Int {
        switch self {
        case .low: return 1
        case .medium: return 2
        case .high: return 3
        case .critical: return 5
        }
    }

    var color: String {
        switch self {
        case .low: return "green"
        case .medium: return "yellow"
        case .high: return "orange"
        case .critical: return "red"
        }
    }

    var icon: String {
        switch self {
        case .low: return "checkmark.circle"
        case .medium: return "exclamationmark.circle"
        case .high: return "exclamationmark.triangle"
        case .critical: return "exclamationmark.octagon"
        }
    }
}

// MARK: - Risk Status

enum RiskStatus: String, Codable, CaseIterable {
    case identified
    case assessing
    case mitigating
    case monitoring
    case resolved

    var displayName: String {
        rawValue.capitalized
    }

    var color: String {
        switch self {
        case .identified: return "gray"
        case .assessing: return "yellow"
        case .mitigating: return "orange"
        case .monitoring: return "blue"
        case .resolved: return "green"
        }
    }
}

// MARK: - Risk Matrix

struct RiskMatrix: Codable {
    let risks: [[RiskCell]]
    let generatedAt: Date

    struct RiskCell: Codable {
        let probability: Double
        let severity: RiskSeverity
        let riskCount: Int
        let totalImpact: Decimal
    }

    // Generate a 5x5 risk matrix
    static func generate(from risks: [RiskAssessment]) -> RiskMatrix {
        var matrix: [[RiskCell]] = []

        for probabilityLevel in stride(from: 0.0, through: 1.0, by: 0.2) {
            var row: [RiskCell] = []
            for severity in [RiskSeverity.low, .medium, .high, .critical] {
                let matchingRisks = risks.filter {
                    $0.probability >= probabilityLevel &&
                    $0.probability < (probabilityLevel + 0.2) &&
                    $0.severity == severity
                }

                let cell = RiskCell(
                    probability: probabilityLevel,
                    severity: severity,
                    riskCount: matchingRisks.count,
                    totalImpact: matchingRisks.reduce(0) { $0 + $1.impact }
                )
                row.append(cell)
            }
            matrix.append(row)
        }

        return RiskMatrix(risks: matrix, generatedAt: Date())
    }
}

// MARK: - Risk Dashboard

struct RiskDashboard: Codable {
    let totalRisks: Int
    let criticalRisks: Int
    let highRisks: Int
    let risksByType: [RiskType: Int]
    let totalPotentialImpact: Decimal
    let mitigatedImpact: Decimal
    let topRisks: [RiskSummary]
    let generatedAt: Date

    struct RiskSummary: Codable, Identifiable {
        let id: UUID
        let riskType: RiskType
        let severity: RiskSeverity
        let description: String
        let impact: Decimal
        let riskScore: Double
    }
}
