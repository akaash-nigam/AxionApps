//
//  ProjectType.swift
//  SpatialScreenplayWorkshop
//
//  Created on 2025-11-24
//

import Foundation

/// Defines the type of screenplay project
enum ProjectType: String, Codable, CaseIterable, Identifiable {
    case featureFilm = "Feature Film"
    case tvPilotOneHour = "TV Pilot (1 Hour)"
    case tvPilotHalfHour = "TV Pilot (30 Min)"
    case tvEpisode = "TV Episode"
    case shortFilm = "Short Film"

    var id: String { rawValue }

    /// Target page count for this project type
    var targetPageCount: Int {
        switch self {
        case .featureFilm:
            return 110
        case .tvPilotOneHour:
            return 60
        case .tvPilotHalfHour:
            return 30
        case .tvEpisode:
            return 55
        case .shortFilm:
            return 10
        }
    }

    /// Page count range for this project type
    var pageCountRange: ClosedRange<Int> {
        switch self {
        case .featureFilm:
            return 90...120
        case .tvPilotOneHour:
            return 50...65
        case .tvPilotHalfHour:
            return 25...35
        case .tvEpisode:
            return 45...65
        case .shortFilm:
            return 5...15
        }
    }
}

/// Project status in development lifecycle
enum ProjectStatus: String, Codable, CaseIterable {
    case outline = "Outline"
    case firstDraft = "First Draft"
    case revision = "Revision"
    case locked = "Locked"
    case production = "Production"

    var color: String {
        switch self {
        case .outline:
            return "#9E9E9E"  // Gray
        case .firstDraft:
            return "#2196F3"  // Blue
        case .revision:
            return "#FF9800"  // Orange
        case .locked:
            return "#4CAF50"  // Green
        case .production:
            return "#9C27B0"  // Purple
        }
    }
}

/// Page size for screenplay formatting
enum PageSize: String, Codable, CaseIterable {
    case letter = "US Letter"
    case a4 = "A4"

    /// Size in points (72 points = 1 inch)
    var sizeInPoints: CGSize {
        switch self {
        case .letter:
            return CGSize(width: 612, height: 792)  // 8.5" × 11"
        case .a4:
            return CGSize(width: 595, height: 842)  // 210mm × 297mm
        }
    }
}

/// Color coding mode for scene cards
enum ColorCodingMode: String, Codable, CaseIterable {
    case location = "Location"
    case timeOfDay = "Time of Day"
    case character = "Character"
    case storyThread = "Story Thread"
    case status = "Status"
}

/// Revision color for script changes
enum RevisionColor: String, Codable, CaseIterable {
    case white = "White"
    case blue = "Blue"
    case pink = "Pink"
    case yellow = "Yellow"
    case green = "Green"
    case goldenrod = "Goldenrod"
    case buff = "Buff"
    case salmon = "Salmon"
    case cherry = "Cherry"

    var hexColor: String {
        switch self {
        case .white:
            return "#FFFFFF"
        case .blue:
            return "#2196F3"
        case .pink:
            return "#E91E63"
        case .yellow:
            return "#FFEB3B"
        case .green:
            return "#4CAF50"
        case .goldenrod:
            return "#DAA520"
        case .buff:
            return "#F0DC82"
        case .salmon:
            return "#FA8072"
        case .cherry:
            return "#DE3163"
        }
    }
}
