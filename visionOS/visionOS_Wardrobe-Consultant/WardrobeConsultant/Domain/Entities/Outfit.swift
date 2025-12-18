//
//  Outfit.swift
//  WardrobeConsultant
//
//  Created by Claude Code
//  Copyright © 2025 Wardrobe Consultant. All rights reserved.
//

import Foundation

/// Represents a combination of wardrobe items that form a complete outfit
struct Outfit: Identifiable, Codable, Hashable {
    // MARK: - Identity
    let id: UUID
    var createdAt: Date
    var updatedAt: Date

    // MARK: - Basic Info
    var name: String?
    var occasionType: OccasionType

    // MARK: - Context
    var season: Season?
    var weatherCondition: WeatherCondition?
    var temperatureMin: Int16 // Fahrenheit
    var temperatureMax: Int16

    // MARK: - Style
    var styleType: StyleType?
    var formalityLevel: Int16 // 1-10 scale

    // MARK: - Usage
    var timesWorn: Int
    var lastWornDate: Date?
    var isFavorite: Bool

    // MARK: - AI Generated
    var isAIGenerated: Bool
    var confidenceScore: Float // 0.0-1.0

    // MARK: - Relationships
    var itemIDs: Set<UUID> // References to WardrobeItem IDs

    // MARK: - Initialization
    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        name: String? = nil,
        occasionType: OccasionType = .casual,
        season: Season? = nil,
        weatherCondition: WeatherCondition? = nil,
        temperatureMin: Int16 = 0,
        temperatureMax: Int16 = 100,
        styleType: StyleType? = nil,
        formalityLevel: Int16 = 5,
        timesWorn: Int = 0,
        lastWornDate: Date? = nil,
        isFavorite: Bool = false,
        isAIGenerated: Bool = false,
        confidenceScore: Float = 0.0,
        itemIDs: Set<UUID> = []
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.name = name
        self.occasionType = occasionType
        self.season = season
        self.weatherCondition = weatherCondition
        self.temperatureMin = temperatureMin
        self.temperatureMax = temperatureMax
        self.styleType = styleType
        self.formalityLevel = formalityLevel
        self.timesWorn = timesWorn
        self.lastWornDate = lastWornDate
        self.isFavorite = isFavorite
        self.isAIGenerated = isAIGenerated
        self.confidenceScore = confidenceScore
        self.itemIDs = itemIDs
    }
}

// MARK: - Enumerations
enum StyleType: String, Codable, CaseIterable {
    case minimalist
    case classic
    case trendy
    case edgy
    case bohemian
    case preppy
    case streetwear
    case elegant
    case sporty
    case vintage

    var displayName: String {
        rawValue.capitalized
    }

    var description: String {
        switch self {
        case .minimalist:
            return "Clean lines, neutral colors, simple silhouettes"
        case .classic:
            return "Timeless pieces, traditional cuts, refined look"
        case .trendy:
            return "Current season styles, fashion-forward pieces"
        case .edgy:
            return "Bold choices, unconventional combinations, statement pieces"
        case .bohemian:
            return "Flowy fabrics, mixed patterns, relaxed vibe"
        case .preppy:
            return "Polished, collegiate-inspired, put-together"
        case .streetwear:
            return "Urban fashion, sneakers, casual cool"
        case .elegant:
            return "Sophisticated, refined, polished appearance"
        case .sporty:
            return "Athletic-inspired, comfortable, functional"
        case .vintage:
            return "Retro pieces, nostalgic styles, unique finds"
        }
    }
}

enum WeatherCondition: String, Codable, CaseIterable {
    case clear
    case partlyCloudy
    case cloudy
    case rainy
    case snowy
    case stormy
    case windy
    case foggy

    var displayName: String {
        switch self {
        case .partlyCloudy: return "Partly Cloudy"
        default: return rawValue.capitalized
        }
    }

    var sfSymbol: String {
        switch self {
        case .clear: return "sun.max.fill"
        case .partlyCloudy: return "cloud.sun.fill"
        case .cloudy: return "cloud.fill"
        case .rainy: return "cloud.rain.fill"
        case .snowy: return "cloud.snow.fill"
        case .stormy: return "cloud.bolt.fill"
        case .windy: return "wind"
        case .foggy: return "cloud.fog.fill"
        }
    }
}
