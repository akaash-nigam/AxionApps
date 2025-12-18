//
//  AppModel.swift
//  SmartAgriculture
//
//  Created by Claude Code
//  Copyright © 2025 Smart Agriculture. All rights reserved.
//

import Foundation
import SwiftUI
import Observation

// MARK: - App Model

@Observable
final class AppModel {
    // MARK: - Properties

    // App-wide settings
    var settings: AppSettings = AppSettings()

    // Spatial state
    var spatialMode: SpatialMode = .window
    var immersionLevel: ImmersionStyle = .mixed

    // Navigation
    var activeView: ViewType = .dashboard
    var showingAnalytics = false
    var showingControls = false
    var showingNotifications = false

    // Filters & preferences
    var healthThreshold: Double = 0.7
    var dataTimeRange: DateRange = .last30Days
    var visualizationMode: VisualizationMode = .health

    // MARK: - Initialization

    init() {
        // Load saved settings if available
        loadSettings()
    }

    // MARK: - Methods

    func loadSettings() {
        // Load from UserDefaults or other persistence
        if let savedThreshold = UserDefaults.standard.object(forKey: "healthThreshold") as? Double {
            healthThreshold = savedThreshold
        }
    }

    func saveSettings() {
        UserDefaults.standard.set(healthThreshold, forKey: "healthThreshold")
    }

    func toggleWindow(_ windowType: WindowType) {
        switch windowType {
        case .analytics:
            showingAnalytics.toggle()
        case .controls:
            showingControls.toggle()
        case .notifications:
            showingNotifications.toggle()
        }
    }
}

// MARK: - Supporting Types

struct AppSettings: Codable {
    var useMetricUnits: Bool = false
    var enableNotifications: Bool = true
    var autoRefreshInterval: TimeInterval = 300  // 5 minutes
    var offlineMode: Bool = false
}

enum SpatialMode {
    case window
    case volume
    case immersive
}

enum ViewType {
    case dashboard
    case fieldDetail
    case analytics
    case settings
}

enum WindowType {
    case analytics
    case controls
    case notifications
}

enum DateRange: String, CaseIterable {
    case last7Days = "Last 7 Days"
    case last30Days = "Last 30 Days"
    case last90Days = "Last 90 Days"
    case thisYear = "This Year"
    case allTime = "All Time"

    var days: Int {
        switch self {
        case .last7Days: return 7
        case .last30Days: return 30
        case .last90Days: return 90
        case .thisYear: return 365
        case .allTime: return Int.max
        }
    }

    var startDate: Date {
        guard self != .allTime else {
            return Date.distantPast
        }
        return Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
    }
}

enum VisualizationMode: String, CaseIterable {
    case health = "Health"
    case moisture = "Moisture"
    case temperature = "Temperature"
    case ndvi = "NDVI"
    case yield = "Yield Potential"

    var iconName: String {
        switch self {
        case .health: return "heart.fill"
        case .moisture: return "drop.fill"
        case .temperature: return "thermometer"
        case .ndvi: return "leaf.fill"
        case .yield: return "chart.bar.fill"
        }
    }
}
