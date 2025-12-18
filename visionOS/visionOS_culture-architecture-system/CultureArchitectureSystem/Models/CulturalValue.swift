//
//  CulturalValue.swift
//  CultureArchitectureSystem
//
//  Created on 2025-01-20
//

import Foundation
import SwiftData

@Model
final class CulturalValue {
    @Attribute(.unique) var id: UUID
    var name: String
    var valueDescription: String
    var iconName: String
    var colorHex: String
    var alignmentScore: Double
    var behaviors: [String]

    init(
        id: UUID = UUID(),
        name: String,
        valueDescription: String,
        iconName: String = "lightbulb.fill",
        colorHex: String = "#8B5CF6",
        alignmentScore: Double = 0.0,
        behaviors: [String] = []
    ) {
        self.id = id
        self.name = name
        self.valueDescription = valueDescription
        self.iconName = iconName
        self.colorHex = colorHex
        self.alignmentScore = alignmentScore
        self.behaviors = behaviors
    }
}

// MARK: - JSON Serialization Helpers
extension CulturalValue {
    func toDictionary() -> [String: Any] {
        [
            "id": id.uuidString,
            "name": name,
            "description": valueDescription,
            "icon_name": iconName,
            "color_hex": colorHex,
            "alignment_score": alignmentScore,
            "behaviors": behaviors
        ]
    }
}

// MARK: - Value Types
extension CulturalValue {
    enum ValueType: String, CaseIterable {
        case innovation
        case collaboration
        case trust
        case transparency
        case purpose
        case growth
        case diversity
        case excellence

        var defaultIcon: String {
            switch self {
            case .innovation: return "lightbulb.fill"
            case .collaboration: return "person.2.fill"
            case .trust: return "shield.fill"
            case .transparency: return "eye.fill"
            case .purpose: return "target"
            case .growth: return "chart.line.uptrend.xyaxis"
            case .diversity: return "person.3.fill"
            case .excellence: return "star.fill"
            }
        }

        var defaultColor: String {
            switch self {
            case .innovation: return "#8B5CF6" // Purple
            case .collaboration: return "#3B82F6" // Blue
            case .trust: return "#F59E0B" // Gold
            case .transparency: return "#FFFFFF" // Clear/White
            case .purpose: return "#FF6B35" // Orange
            case .growth: return "#10B981" // Green
            case .diversity: return "#EC4899" // Pink
            case .excellence: return "#FBBF24" // Yellow
            }
        }
    }

    static func create(type: ValueType, description: String) -> CulturalValue {
        CulturalValue(
            name: type.rawValue.capitalized,
            valueDescription: description,
            iconName: type.defaultIcon,
            colorHex: type.defaultColor
        )
    }
}
