//
//  Constants.swift
//  CultureArchitectureSystem
//
//  Created on 2025-01-20
//

import Foundation

enum AppConstants {
    // API Configuration
    static let apiBaseURL = "https://api.culturearchitecture.com/v1"
    static let webSocketURL = "wss://realtime.culturearchitecture.com"

    // Privacy Settings
    static let minimumTeamSize = 5  // K-anonymity enforcement

    // Performance Settings
    static let targetFrameRate = 90
    static let maxCacheAge: TimeInterval = 300 // 5 minutes

    // Animation Durations
    static let shortAnimation: TimeInterval = 0.2
    static let mediumAnimation: TimeInterval = 0.3
    static let longAnimation: TimeInterval = 0.5

    // Spatial Distances (meters)
    static let personalSpace: Float = 0.5
    static let socialSpace: Float = 2.0
    static let publicSpace: Float = 5.0
}

enum FeatureFlags {
    static let enableHandTracking = true
    static let enableEyeTracking = false  // Requires explicit user consent
    static let enableVoiceCommands = false  // Future feature
    static let enableOfflineMode = true
    static let enableRealTimeSync = true
}
