//
//  Scenario.swift
//  MilitaryDefenseTraining
//
//  Created by Claude Code
//

import Foundation
import SwiftData

@Model
final class Scenario {
    var id: UUID
    var name: String
    var type: ScenarioType
    var difficulty: DifficultyLevel
    var durationMinutes: Int
    var scenarioDescription: String
    var objectives: [String]
    var enemyCount: Int
    var environment: EnvironmentType
    var classification: ClassificationLevel
    var isDownloaded: Bool
    var thumbnailURL: String?

    init(
        id: UUID = UUID(),
        name: String,
        type: ScenarioType,
        difficulty: DifficultyLevel = .medium,
        durationMinutes: Int = 30,
        scenarioDescription: String,
        objectives: [String] = [],
        enemyCount: Int = 10,
        environment: EnvironmentType = .urban,
        classification: ClassificationLevel = .confidential,
        isDownloaded: Bool = false,
        thumbnailURL: String? = nil
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.difficulty = difficulty
        self.durationMinutes = durationMinutes
        self.scenarioDescription = scenarioDescription
        self.objectives = objectives
        self.enemyCount = enemyCount
        self.environment = environment
        self.classification = classification
        self.isDownloaded = isDownloaded
        self.thumbnailURL = thumbnailURL
    }
}

// MARK: - Scenario Type
enum ScenarioType: String, Codable, CaseIterable {
    case urbanAssault = "Urban Assault"
    case desertPatrol = "Desert Patrol"
    case buildingClearance = "Building Clearance"
    case convoyEscort = "Convoy Escort"
    case hostageRescue = "Hostage Rescue"
    case reconnaissance = "Reconnaissance"
    case defensivePosition = "Defensive Position"
    case mountainOperations = "Mountain Operations"
    case maritimeAssault = "Maritime Assault"

    var iconName: String {
        switch self {
        case .urbanAssault: return "building.2.fill"
        case .desertPatrol: return "sun.max.fill"
        case .buildingClearance: return "door.left.hand.open"
        case .convoyEscort: return "car.2.fill"
        case .hostageRescue: return "person.2.fill"
        case .reconnaissance: return "binoculars.fill"
        case .defensivePosition: return "shield.fill"
        case .mountainOperations: return "mountain.2.fill"
        case .maritimeAssault: return "water.waves"
        }
    }
}

// MARK: - Difficulty Level
enum DifficultyLevel: String, Codable, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    case expert = "Expert"

    var stars: Int {
        switch self {
        case .easy: return 1
        case .medium: return 2
        case .hard: return 3
        case .expert: return 4
        }
    }

    var color: String {
        switch self {
        case .easy: return "green"
        case .medium: return "yellow"
        case .hard: return "orange"
        case .expert: return "red"
        }
    }
}

// MARK: - Environment Type
enum EnvironmentType: String, Codable, CaseIterable {
    case urban = "Urban"
    case desert = "Desert"
    case mountain = "Mountain"
    case forest = "Forest"
    case arctic = "Arctic"
    case maritime = "Maritime"
    case jungle = "Jungle"

    var description: String {
        switch self {
        case .urban: return "City environment with buildings and streets"
        case .desert: return "Open desert terrain with sand dunes"
        case .mountain: return "High-altitude mountainous terrain"
        case .forest: return "Dense forest with vegetation"
        case .arctic: return "Snow and ice environment"
        case .maritime: return "Coastal and water operations"
        case .jungle: return "Tropical jungle environment"
        }
    }
}
