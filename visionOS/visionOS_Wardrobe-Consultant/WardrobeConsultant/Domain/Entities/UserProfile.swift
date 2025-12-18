//
//  UserProfile.swift
//  WardrobeConsultant
//
//  Created by Claude Code
//  Copyright © 2025 Wardrobe Consultant. All rights reserved.
//

import Foundation

/// Represents the user's profile with preferences and style information
struct UserProfile: Identifiable, Codable {
    // MARK: - Identity
    let id: UUID
    var createdAt: Date
    var updatedAt: Date

    // MARK: - Size Preferences
    var topSize: String?
    var bottomSize: String?
    var dressSize: String?
    var shoeSize: String?
    var fitPreference: FitPreference

    // MARK: - Style Profile
    var primaryStyle: StyleType
    var secondaryStyle: StyleType?
    var favoriteColors: [String] // Hex colors
    var avoidColors: [String] // Hex colors

    // MARK: - Preferences
    var comfortLevel: ComfortLevel
    var budgetRange: BudgetRange
    var sustainabilityPreference: Bool

    // MARK: - Style Icons
    var styleIcons: [String] // Names or references

    // MARK: - Settings
    var temperatureUnit: TemperatureUnit
    var enableWeatherIntegration: Bool
    var enableCalendarIntegration: Bool
    var enableNotifications: Bool

    // MARK: - Initialization
    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        topSize: String? = nil,
        bottomSize: String? = nil,
        dressSize: String? = nil,
        shoeSize: String? = nil,
        fitPreference: FitPreference = .regular,
        primaryStyle: StyleType = .classic,
        secondaryStyle: StyleType? = nil,
        favoriteColors: [String] = [],
        avoidColors: [String] = [],
        comfortLevel: ComfortLevel = .balanced,
        budgetRange: BudgetRange = .moderate,
        sustainabilityPreference: Bool = false,
        styleIcons: [String] = [],
        temperatureUnit: TemperatureUnit = .fahrenheit,
        enableWeatherIntegration: Bool = true,
        enableCalendarIntegration: Bool = false,
        enableNotifications: Bool = true
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.topSize = topSize
        self.bottomSize = bottomSize
        self.dressSize = dressSize
        self.shoeSize = shoeSize
        self.fitPreference = fitPreference
        self.primaryStyle = primaryStyle
        self.secondaryStyle = secondaryStyle
        self.favoriteColors = favoriteColors
        self.avoidColors = avoidColors
        self.comfortLevel = comfortLevel
        self.budgetRange = budgetRange
        self.sustainabilityPreference = sustainabilityPreference
        self.styleIcons = styleIcons
        self.temperatureUnit = temperatureUnit
        self.enableWeatherIntegration = enableWeatherIntegration
        self.enableCalendarIntegration = enableCalendarIntegration
        self.enableNotifications = enableNotifications
    }
}

// MARK: - Body Measurements (Stored Separately in Keychain)
struct BodyMeasurements: Codable {
    var height: Double? // Inches
    var weight: Double? // Pounds
    var chest: Double? // Inches
    var waist: Double?
    var hips: Double?
    var inseam: Double?
    var shoulderWidth: Double?
    var measurementDate: Date

    init(
        height: Double? = nil,
        weight: Double? = nil,
        chest: Double? = nil,
        waist: Double? = nil,
        hips: Double? = nil,
        inseam: Double? = nil,
        shoulderWidth: Double? = nil,
        measurementDate: Date = Date()
    ) {
        self.height = height
        self.weight = weight
        self.chest = chest
        self.waist = waist
        self.hips = hips
        self.inseam = inseam
        self.shoulderWidth = shoulderWidth
        self.measurementDate = measurementDate
    }
}

// MARK: - Enumerations
enum FitPreference: String, Codable, CaseIterable {
    case slim
    case regular
    case relaxed

    var displayName: String {
        rawValue.capitalized
    }
}

enum ComfortLevel: String, Codable, CaseIterable {
    case comfortFirst
    case balanced
    case styleFirst

    var displayName: String {
        switch self {
        case .comfortFirst: return "Comfort First"
        case .balanced: return "Balanced"
        case .styleFirst: return "Style First"
        }
    }
}

enum BudgetRange: String, Codable, CaseIterable {
    case budget // < $50 per item
    case moderate // $50-150
    case premium // $150-500
    case luxury // $500+

    var displayName: String {
        rawValue.capitalized
    }

    var priceRange: String {
        switch self {
        case .budget: return "Under $50"
        case .moderate: return "$50-$150"
        case .premium: return "$150-$500"
        case .luxury: return "$500+"
        }
    }
}

enum TemperatureUnit: String, Codable {
    case fahrenheit = "F"
    case celsius = "C"

    var displayName: String {
        switch self {
        case .fahrenheit: return "Fahrenheit (°F)"
        case .celsius: return "Celsius (°C)"
        }
    }
}
