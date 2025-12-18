//
//  Recommendation.swift
//  SmartAgriculture
//
//  Created by Claude Code
//  Copyright © 2025 Smart Agriculture. All rights reserved.
//

import Foundation

// MARK: - Recommendation

struct Recommendation: Identifiable, Codable, Hashable {
    let id: UUID
    var type: RecommendationType
    var priority: Priority
    var title: String
    var description: String
    var acresAffected: Double
    var estimatedCost: Double
    var expectedBenefit: Double
    var roi: Double  // Return on investment percentage
    var confidence: Double
    var createdAt: Date

    init(
        id: UUID = UUID(),
        type: RecommendationType,
        priority: Priority,
        title: String? = nil,
        description: String,
        acresAffected: Double = 0,
        estimatedCost: Double,
        expectedBenefit: Double,
        confidence: Double = 0.9,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.type = type
        self.priority = priority
        self.title = title ?? type.displayName
        self.description = description
        self.acresAffected = acresAffected
        self.estimatedCost = estimatedCost
        self.expectedBenefit = expectedBenefit
        self.roi = ((expectedBenefit - estimatedCost) / estimatedCost) * 100
        self.confidence = confidence
        self.createdAt = createdAt
    }

    var iconName: String {
        type.iconName
    }
}

// MARK: - Recommendation Type

enum RecommendationType: String, Codable, CaseIterable {
    case fertilizer = "fertilizer"
    case irrigation = "irrigation"
    case pestControl = "pest_control"
    case diseaseControl = "disease_control"
    case soilTreatment = "soil_treatment"
    case harvest = "harvest"
    case replant = "replant"
    case other = "other"

    var displayName: String {
        switch self {
        case .fertilizer: return "Fertilizer Application"
        case .irrigation: return "Irrigation"
        case .pestControl: return "Pest Control"
        case .diseaseControl: return "Disease Control"
        case .soilTreatment: return "Soil Treatment"
        case .harvest: return "Harvest Timing"
        case .replant: return "Replanting"
        case .other: return "Other"
        }
    }

    var iconName: String {
        switch self {
        case .fertilizer: return "drop.fill"
        case .irrigation: return "drop.triangle"
        case .pestControl: return "ant.fill"
        case .diseaseControl: return "cross.case.fill"
        case .soilTreatment: return "leaf.fill"
        case .harvest: return "cart.fill"
        case .replant: return "arrow.clockwise"
        case .other: return "ellipsis.circle.fill"
        }
    }
}

// MARK: - Priority

enum Priority: String, Codable, Comparable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case critical = "critical"

    static func < (lhs: Priority, rhs: Priority) -> Bool {
        let order: [Priority] = [.low, .medium, .high, .critical]
        guard let lhsIndex = order.firstIndex(of: lhs),
              let rhsIndex = order.firstIndex(of: rhs) else {
            return false
        }
        return lhsIndex < rhsIndex
    }

    var displayName: String {
        return rawValue.capitalized
    }
}

// MARK: - Mock Data

extension Recommendation {
    static func mockNitrogenDeficiency() -> Recommendation {
        return Recommendation(
            type: .fertilizer,
            priority: .high,
            description: "Apply 30 lbs/acre nitrogen to address deficiency in affected zones",
            acresAffected: 12.3,
            estimatedCost: 1764.0,  // $42/acre * 42 acres
            expectedBenefit: 3810.0,  // Expected revenue gain
            confidence: 0.94
        )
    }

    static func mockIrrigation() -> Recommendation {
        return Recommendation(
            type: .irrigation,
            priority: .medium,
            description: "Schedule irrigation for low moisture areas",
            acresAffected: 8.7,
            estimatedCost: 150.0,
            expectedBenefit: 500.0,
            confidence: 0.89
        )
    }

    static func mockPestControl() -> Recommendation {
        return Recommendation(
            type: .pestControl,
            priority: .high,
            description: "Apply targeted insecticide for aphid infestation",
            acresAffected: 25.0,
            estimatedCost: 875.0,
            expectedBenefit: 2500.0,
            confidence: 0.91
        )
    }

    static var mockRecommendations: [Recommendation] {
        return [
            mockNitrogenDeficiency(),
            mockIrrigation(),
            mockPestControl()
        ].sorted { $0.roi > $1.roi }  // Sort by ROI descending
    }
}
