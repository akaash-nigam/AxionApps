//
//  SlugLine.swift
//  SpatialScreenplayWorkshop
//
//  Created on 2025-11-24
//

import Foundation

/// Scene slug line (scene heading)
struct SlugLine: Codable, Hashable {
    var setting: Setting
    var location: String
    var timeOfDay: TimeOfDay

    /// Formatted slug line (e.g., "INT. COFFEE SHOP - DAY")
    var formatted: String {
        "\(setting.rawValue). \(location.uppercased()) - \(timeOfDay.rawValue)"
    }

    init(setting: Setting, location: String, timeOfDay: TimeOfDay) {
        self.setting = setting
        self.location = location
        self.timeOfDay = timeOfDay
    }

    /// Parse slug line from text (e.g., "INT. COFFEE SHOP - DAY")
    init?(fromText text: String) {
        let components = text.components(separatedBy: " - ")
        guard components.count == 2 else { return nil }

        // Parse time of day
        guard let timeOfDay = TimeOfDay(rawValue: components[1].trimmingCharacters(in: .whitespaces)) else {
            return nil
        }

        // Parse setting and location
        let settingLocation = components[0]
        let parts = settingLocation.components(separatedBy: ". ")
        guard parts.count >= 2 else { return nil }

        guard let setting = Setting(rawValue: parts[0]) else {
            return nil
        }

        let location = parts[1...].joined(separator: ". ")

        self.setting = setting
        self.location = location
        self.timeOfDay = timeOfDay
    }
}

/// Interior or Exterior setting
enum Setting: String, Codable, CaseIterable {
    case INT = "INT"
    case EXT = "EXT"
    case INT_EXT = "INT./EXT"
    case EXT_INT = "EXT./INT"

    var displayName: String {
        switch self {
        case .INT:
            return "Interior"
        case .EXT:
            return "Exterior"
        case .INT_EXT:
            return "Interior/Exterior"
        case .EXT_INT:
            return "Exterior/Interior"
        }
    }
}

/// Time of day for scene
enum TimeOfDay: String, Codable, CaseIterable {
    case day = "DAY"
    case night = "NIGHT"
    case morning = "MORNING"
    case afternoon = "AFTERNOON"
    case evening = "EVENING"
    case dawn = "DAWN"
    case dusk = "DUSK"
    case later = "LATER"
    case continuous = "CONTINUOUS"
    case momentsLater = "MOMENTS LATER"

    var color: String {
        switch self {
        case .day, .morning, .afternoon:
            return "#FFD54F"  // Yellow
        case .night:
            return "#1A237E"  // Dark blue
        case .dawn:
            return "#FF6F00"  // Orange
        case .dusk, .evening:
            return "#5E35B1"  // Purple
        case .later, .continuous, .momentsLater:
            return "#757575"  // Gray
        }
    }
}

/// Scene status
enum SceneStatus: String, Codable, CaseIterable {
    case draft = "Draft"
    case revised = "Revised"
    case locked = "Locked"
    case needsWork = "Needs Work"
    case approved = "Approved"

    var color: String {
        switch self {
        case .draft:
            return "#9E9E9E"  // Gray
        case .revised:
            return "#2196F3"  // Blue
        case .locked:
            return "#4CAF50"  // Green
        case .needsWork:
            return "#FF5722"  // Red
        case .approved:
            return "#00BCD4"  // Cyan
        }
    }

    var icon: String {
        switch self {
        case .draft:
            return "doc.text"
        case .revised:
            return "arrow.triangle.2.circlepath"
        case .locked:
            return "lock.fill"
        case .needsWork:
            return "exclamationmark.triangle.fill"
        case .approved:
            return "checkmark.circle.fill"
        }
    }
}

/// Scene importance level
enum SceneImportance: String, Codable, CaseIterable {
    case critical = "Critical"
    case important = "Important"
    case supporting = "Supporting"
    case optional = "Optional"

    var priority: Int {
        switch self {
        case .critical: return 4
        case .important: return 3
        case .supporting: return 2
        case .optional: return 1
        }
    }
}
