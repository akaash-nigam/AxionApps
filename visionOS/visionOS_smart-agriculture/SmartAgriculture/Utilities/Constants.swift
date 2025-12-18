//
//  Constants.swift
//  SmartAgriculture
//
//  Created by Claude Code
//  Copyright © 2025 Smart Agriculture. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: - App Constants

enum AppConstants {
    static let appName = "Smart Agriculture"
    static let appVersion = "1.0.0"
    static let buildNumber = "1"

    // API Configuration
    #if DEBUG
    static let apiBaseURL = "https://dev-api.smartagriculture.com/v1"
    static let enableLogging = true
    static let useMockData = true
    #else
    static let apiBaseURL = "https://api.smartagriculture.com/v1"
    static let enableLogging = false
    static let useMockData = false
    #endif
}

// MARK: - Performance Constants

enum PerformanceConstants {
    static let targetFPS: Int = 90
    static let maxDrawCalls: Int = 500
    static let maxTriangles: Int = 1_000_000
    static let maxTextureMemory: Int = 512 * 1024 * 1024 // 512 MB

    // LOD distances (meters)
    static let lodDistances: [Float] = [2.0, 5.0, 15.0]

    // Cache expiration times (seconds)
    static let satelliteImageExpiration: TimeInterval = 86400  // 24 hours
    static let sensorDataExpiration: TimeInterval = 3600       // 1 hour
    static let weatherExpiration: TimeInterval = 1800          // 30 minutes
}

// MARK: - Spatial Constants

enum SpatialConstants {
    // Spatial zones
    static let comfortableDistance: Float = 1.5  // meters
    static let comfortableAngle: Float = -12.0    // degrees below eye level

    static let secondaryDistance: Float = 2.5
    static let secondaryAngle: Float = -8.0

    static let ambientDistance: Float = 8.0

    // Hit targets
    static let minimumHitTarget: CGFloat = 60.0  // points

    // Field visualization
    static let defaultFieldScale: Float = 1.0 / 1000.0  // 1cm = 10m actual
}

// MARK: - Health Constants

enum HealthConstants {
    static let healthThresholdExcellent: Double = 80.0
    static let healthThresholdGood: Double = 60.0
    static let healthThresholdModerate: Double = 40.0
    static let healthThresholdPoor: Double = 20.0

    // NDVI ranges
    static let ndviHealthy: Double = 0.7
    static let ndviModerate: Double = 0.5
    static let ndviPoor: Double = 0.3

    // Moisture levels (%)
    static let moistureOptimal: Double = 50.0
    static let moistureLow: Double = 30.0
    static let moistureCritical: Double = 20.0
}

// MARK: - Color Palette

enum HealthColor {
    // Excellent health: 80-100%
    static let vibrantGreen = Color(red: 0.2, green: 0.8, blue: 0.3)  // #33CC4D

    // Good health: 60-80%
    static let healthyGreen = Color(red: 0.5, green: 0.9, blue: 0.4)  // #80E666

    // Moderate: 40-60%
    static let cautionYellow = Color(red: 1.0, green: 0.8, blue: 0.0) // #FFCC00

    // Poor: 20-40%
    static let warningOrange = Color(red: 1.0, green: 0.53, blue: 0.0) // #FF8800

    // Critical: 0-20%
    static let alertRed = Color(red: 0.87, green: 0.2, blue: 0.2)     // #DD3333

    static func color(for health: Double) -> Color {
        switch health {
        case 80...100:
            return vibrantGreen
        case 60..<80:
            return healthyGreen
        case 40..<60:
            return cautionYellow
        case 20..<40:
            return warningOrange
        default:
            return alertRed
        }
    }
}

enum BrandColor {
    // Primary brand
    static let farmBlue = Color(red: 0.2, green: 0.4, blue: 0.8)      // #3366CC
    static let earthBrown = Color(red: 0.45, green: 0.35, blue: 0.25) // #735A40

    // Accent colors
    static let skyBlue = Color(red: 0.53, green: 0.81, blue: 0.98)    // #87CEEB
    static let sunYellow = Color(red: 1.0, green: 0.84, blue: 0.0)    // #FFD700
}
