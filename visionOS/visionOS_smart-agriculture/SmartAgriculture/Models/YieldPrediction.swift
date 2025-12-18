//
//  YieldPrediction.swift
//  SmartAgriculture
//
//  Created by Claude Code
//  Copyright © 2025 Smart Agriculture. All rights reserved.
//

import Foundation

// MARK: - Yield Prediction

struct YieldPrediction: Codable, Hashable, Identifiable {
    let id: UUID
    var estimatedYield: Double  // Bushels per acre (or appropriate unit)
    var confidence: Double      // 0-1
    var range: ClosedRange<Double>  // Min to max expected yield
    var contributingFactors: [YieldFactor]
    var predictedAt: Date

    init(
        id: UUID = UUID(),
        estimatedYield: Double,
        confidence: Double,
        range: ClosedRange<Double>,
        contributingFactors: [YieldFactor] = [],
        predictedAt: Date = Date()
    ) {
        self.id = id
        self.estimatedYield = estimatedYield
        self.confidence = confidence
        self.range = range
        self.contributingFactors = contributingFactors
        self.predictedAt = predictedAt
    }

    var minYield: Double {
        range.lowerBound
    }

    var maxYield: Double {
        range.upperBound
    }

    var uncertaintyRange: Double {
        maxYield - minYield
    }
}

// MARK: - Yield Factor

struct YieldFactor: Codable, Hashable, Identifiable {
    let id: UUID
    var name: String
    var impact: Double  // -1 to 1 (negative to positive impact)
    var description: String

    init(id: UUID = UUID(), name: String, impact: Double, description: String) {
        self.id = id
        self.name = name
        self.impact = impact
        self.description = description
    }

    var impactLevel: ImpactLevel {
        switch abs(impact) {
        case 0.7...1.0:
            return .high
        case 0.4..<0.7:
            return .medium
        default:
            return .low
        }
    }

    var isPositive: Bool {
        impact > 0
    }
}

enum ImpactLevel: String, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
}

// MARK: - Mock Data

extension YieldPrediction {
    static func mock(estimatedYield: Double = 165.0) -> YieldPrediction {
        let factors: [YieldFactor] = [
            YieldFactor(
                name: "Soil Health",
                impact: 0.6,
                description: "Good soil quality supporting strong growth"
            ),
            YieldFactor(
                name: "Weather Conditions",
                impact: 0.4,
                description: "Favorable temperature and precipitation"
            ),
            YieldFactor(
                name: "Crop Health",
                impact: -0.2,
                description: "Minor stress detected in some areas"
            ),
            YieldFactor(
                name: "Nutrient Levels",
                impact: 0.3,
                description: "Adequate nitrogen and phosphorus"
            )
        ]

        return YieldPrediction(
            estimatedYield: estimatedYield,
            confidence: 0.88,
            range: (estimatedYield * 0.9)...(estimatedYield * 1.1),
            contributingFactors: factors
        )
    }

    static func mockLowYield() -> YieldPrediction {
        let factors: [YieldFactor] = [
            YieldFactor(
                name: "Drought Stress",
                impact: -0.8,
                description: "Severe moisture deficit affecting development"
            ),
            YieldFactor(
                name: "Nutrient Deficiency",
                impact: -0.5,
                description: "Low nitrogen levels limiting growth"
            ),
            YieldFactor(
                name: "Disease Pressure",
                impact: -0.3,
                description: "Leaf blight detected in multiple zones"
            )
        ]

        return YieldPrediction(
            estimatedYield: 95.0,
            confidence: 0.85,
            range: 85.0...105.0,
            contributingFactors: factors
        )
    }
}

// MARK: - Coding for ClosedRange

extension ClosedRange: Codable where Bound: Codable {
    enum CodingKeys: String, CodingKey {
        case lowerBound
        case upperBound
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let lowerBound = try container.decode(Bound.self, forKey: .lowerBound)
        let upperBound = try container.decode(Bound.self, forKey: .upperBound)
        self = lowerBound...upperBound
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(lowerBound, forKey: .lowerBound)
        try container.encode(upperBound, forKey: .upperBound)
    }
}

extension ClosedRange: Hashable where Bound: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(lowerBound)
        hasher.combine(upperBound)
    }
}
