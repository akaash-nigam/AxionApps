//
//  UserWorkspace.swift
//  AI Agent Coordinator
//
//  User workspace and preferences
//

import Foundation
import SwiftData

@Model
final class UserWorkspace: Identifiable, Codable {
    @Attribute(.unique) var id: UUID
    var name: String
    var createdAt: Date
    var lastModifiedAt: Date

    // Spatial layout preferences
    var savedLayouts: [SavedLayout]
    var defaultLayout: SpatialLayout

    // View preferences
    var viewPreferences: ViewPreferences

    // Agent organization
    var agentGroups: [AgentGroup]

    init(
        id: UUID = UUID(),
        name: String,
        createdAt: Date = Date(),
        lastModifiedAt: Date = Date(),
        savedLayouts: [SavedLayout] = [],
        defaultLayout: SpatialLayout = .galaxy,
        viewPreferences: ViewPreferences = ViewPreferences(),
        agentGroups: [AgentGroup] = []
    ) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.lastModifiedAt = lastModifiedAt
        self.savedLayouts = savedLayouts
        self.defaultLayout = defaultLayout
        self.viewPreferences = viewPreferences
        self.agentGroups = agentGroups
    }

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, name, createdAt, lastModifiedAt
        case savedLayouts, defaultLayout, viewPreferences, agentGroups
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        lastModifiedAt = try container.decode(Date.self, forKey: .lastModifiedAt)
        savedLayouts = try container.decode([SavedLayout].self, forKey: .savedLayouts)
        defaultLayout = try container.decode(SpatialLayout.self, forKey: .defaultLayout)
        viewPreferences = try container.decode(ViewPreferences.self, forKey: .viewPreferences)
        agentGroups = try container.decode([AgentGroup].self, forKey: .agentGroups)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(lastModifiedAt, forKey: .lastModifiedAt)
        try container.encode(savedLayouts, forKey: .savedLayouts)
        try container.encode(defaultLayout, forKey: .defaultLayout)
        try container.encode(viewPreferences, forKey: .viewPreferences)
        try container.encode(agentGroups, forKey: .agentGroups)
    }
}

struct SavedLayout: Codable, Identifiable {
    var id: UUID
    var name: String
    var layoutType: SpatialLayout
    var agentPositions: [UUID: SpatialPosition]
    var savedAt: Date

    init(id: UUID = UUID(), name: String, layoutType: SpatialLayout, agentPositions: [UUID: SpatialPosition] = [:], savedAt: Date = Date()) {
        self.id = id
        self.name = name
        self.layoutType = layoutType
        self.agentPositions = agentPositions
        self.savedAt = savedAt
    }
}

struct ViewPreferences: Codable {
    var refreshInterval: TimeInterval
    var maxAgentsDisplayed: Int
    var qualityLevel: QualityLevel
    var enableSpatialAudio: Bool
    var enableHaptics: Bool
    var colorScheme: String

    init(
        refreshInterval: TimeInterval = 5.0,
        maxAgentsDisplayed: Int = 10000,
        qualityLevel: QualityLevel = .medium,
        enableSpatialAudio: Bool = true,
        enableHaptics: Bool = true,
        colorScheme: String = "auto"
    ) {
        self.refreshInterval = refreshInterval
        self.maxAgentsDisplayed = maxAgentsDisplayed
        self.qualityLevel = qualityLevel
        self.enableSpatialAudio = enableSpatialAudio
        self.enableHaptics = enableHaptics
        self.colorScheme = colorScheme
    }

    enum QualityLevel: String, Codable {
        case low
        case medium
        case high

        var maxAgents: Int {
            switch self {
            case .low: return 5000
            case .medium: return 10000
            case .high: return 50000
            }
        }
    }
}

struct AgentGroup: Codable, Identifiable {
    var id: UUID
    var name: String
    var agentIds: [UUID]
    var color: String
    var icon: String

    init(id: UUID = UUID(), name: String, agentIds: [UUID] = [], color: String = "#007AFF", icon: String = "folder") {
        self.id = id
        self.name = name
        self.agentIds = agentIds
        self.color = color
        self.icon = icon
    }
}
