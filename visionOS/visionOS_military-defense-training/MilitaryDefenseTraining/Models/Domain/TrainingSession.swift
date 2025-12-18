//
//  TrainingSession.swift
//  MilitaryDefenseTraining
//
//  Created by Claude Code
//

import Foundation
import SwiftData

@Model
final class TrainingSession {
    var id: UUID
    var missionType: MissionType
    var scenarioID: UUID
    var startTime: Date
    var endTime: Date?
    var warriorID: UUID
    var performanceData: Data? // Encoded PerformanceMetrics
    var classificationLevel: ClassificationLevel
    var isCompleted: Bool
    var score: Int

    init(
        id: UUID = UUID(),
        missionType: MissionType,
        scenarioID: UUID,
        startTime: Date = Date(),
        endTime: Date? = nil,
        warriorID: UUID,
        performanceData: Data? = nil,
        classificationLevel: ClassificationLevel = .confidential,
        isCompleted: Bool = false,
        score: Int = 0
    ) {
        self.id = id
        self.missionType = missionType
        self.scenarioID = scenarioID
        self.startTime = startTime
        self.endTime = endTime
        self.warriorID = warriorID
        self.performanceData = performanceData
        self.classificationLevel = classificationLevel
        self.isCompleted = isCompleted
        self.score = score
    }
}

// MARK: - Mission Type
enum MissionType: String, Codable {
    case urbanAssault = "Urban Assault"
    case desertPatrol = "Desert Patrol"
    case buildingClearance = "Building Clearance"
    case convoyEscort = "Convoy Escort"
    case hostageRescue = "Hostage Rescue"
    case reconnaissance = "Reconnaissance"
    case defensivePosition = "Defensive Position"
}

// MARK: - Classification Level
enum ClassificationLevel: Int, Codable, Comparable {
    case unclassified = 0
    case cui = 1           // Controlled Unclassified
    case confidential = 2
    case secret = 3
    case topSecret = 4

    static func < (lhs: ClassificationLevel, rhs: ClassificationLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    var displayName: String {
        switch self {
        case .unclassified: return "UNCLASSIFIED"
        case .cui: return "CUI"
        case .confidential: return "CONFIDENTIAL"
        case .secret: return "SECRET"
        case .topSecret: return "TOP SECRET"
        }
    }

    var bannerColor: String {
        switch self {
        case .unclassified: return "#00FF00"
        case .cui: return "#00BFFF"
        case .confidential: return "#0000FF"
        case .secret: return "#FF0000"
        case .topSecret: return "#FF8C00"
        }
    }
}
