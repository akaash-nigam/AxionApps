//
//  CropType.swift
//  SmartAgriculture
//
//  Created by Claude Code
//  Copyright © 2025 Smart Agriculture. All rights reserved.
//

import Foundation

// MARK: - Crop Type

enum CropType: String, Codable, CaseIterable {
    case corn
    case soybeans
    case wheat
    case cotton
    case rice
    case barley
    case oats
    case sorghum
    case alfalfa
    case sunflower
    case canola
    case sugarbeets
    case potatoes
    case other

    var displayName: String {
        switch self {
        case .corn: return "Corn"
        case .soybeans: return "Soybeans"
        case .wheat: return "Wheat"
        case .cotton: return "Cotton"
        case .rice: return "Rice"
        case .barley: return "Barley"
        case .oats: return "Oats"
        case .sorghum: return "Sorghum"
        case .alfalfa: return "Alfalfa"
        case .sunflower: return "Sunflower"
        case .canola: return "Canola"
        case .sugarbeets: return "Sugar Beets"
        case .potatoes: return "Potatoes"
        case .other: return "Other"
        }
    }

    var iconName: String {
        switch self {
        case .corn: return "leaf.fill"
        case .soybeans: return "leaf"
        case .wheat: return "leaf.arrow.circlepath"
        default: return "leaf"
        }
    }

    var typicalYield: Double {
        // Bushels per acre (or equivalent for non-grain crops)
        switch self {
        case .corn: return 180.0
        case .soybeans: return 50.0
        case .wheat: return 50.0
        case .cotton: return 850.0  // lbs/acre
        case .rice: return 160.0
        case .barley: return 70.0
        case .oats: return 70.0
        case .sorghum: return 70.0
        case .alfalfa: return 5.0   // tons/acre
        case .sunflower: return 1500.0  // lbs/acre
        case .canola: return 40.0
        case .sugarbeets: return 25.0  // tons/acre
        case .potatoes: return 400.0  // cwt/acre
        case .other: return 0.0
        }
    }

    var growingSeasonDays: Int {
        switch self {
        case .corn: return 120
        case .soybeans: return 110
        case .wheat: return 150
        case .cotton: return 160
        case .rice: return 130
        case .barley: return 90
        case .oats: return 90
        case .sorghum: return 100
        case .alfalfa: return 365  // perennial
        case .sunflower: return 90
        case .canola: return 100
        case .sugarbeets: return 180
        case .potatoes: return 120
        case .other: return 120
        }
    }
}

// MARK: - Growth Stage

enum GrowthStage: String, Codable, CaseIterable {
    case preseason = "Preseason"
    case planted = "Planted"
    case emergence = "Emergence"
    case vegetative = "Vegetative"
    case reproductive = "Reproductive"
    case maturity = "Maturity"
    case harvest = "Harvest"
    case postharvest = "Post-Harvest"

    var displayName: String {
        return rawValue
    }

    var progress: Double {
        switch self {
        case .preseason: return 0.0
        case .planted: return 0.1
        case .emergence: return 0.2
        case .vegetative: return 0.4
        case .reproductive: return 0.7
        case .maturity: return 0.9
        case .harvest: return 1.0
        case .postharvest: return 1.0
        }
    }
}
