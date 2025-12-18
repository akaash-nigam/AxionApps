//
//  Metadata.swift
//  SpatialScreenplayWorkshop
//
//  Created on 2025-11-24
//

import Foundation

/// Project-level metadata
struct ProjectMetadata: Codable, Hashable {
    var genre: String?
    var targetPageCount: Int?
    var currentPageCount: Double
    var wordCount: Int
    var sceneCount: Int
    var characterCount: Int
    var status: ProjectStatus
    var tags: [String]

    init(
        genre: String? = nil,
        targetPageCount: Int? = nil,
        currentPageCount: Double = 0,
        wordCount: Int = 0,
        sceneCount: Int = 0,
        characterCount: Int = 0,
        status: ProjectStatus = .outline,
        tags: [String] = []
    ) {
        self.genre = genre
        self.targetPageCount = targetPageCount
        self.currentPageCount = currentPageCount
        self.wordCount = wordCount
        self.sceneCount = sceneCount
        self.characterCount = characterCount
        self.status = status
        self.tags = tags
    }

    /// Completion percentage based on target page count
    var completionPercentage: Double? {
        guard let target = targetPageCount, target > 0 else { return nil }
        return min(currentPageCount / Double(target), 1.0) * 100
    }
}

/// Project settings
struct ProjectSettings: Codable, Hashable {
    var defaultFont: String
    var fontSize: Int
    var pageSize: PageSize
    var colorCodingMode: ColorCodingMode
    var autoSaveInterval: TimeInterval
    var revisionColor: RevisionColor

    init(
        defaultFont: String = "Courier",
        fontSize: Int = 12,
        pageSize: PageSize = .letter,
        colorCodingMode: ColorCodingMode = .location,
        autoSaveInterval: TimeInterval = 300,  // 5 minutes
        revisionColor: RevisionColor = .white
    ) {
        self.defaultFont = defaultFont
        self.fontSize = fontSize
        self.pageSize = pageSize
        self.colorCodingMode = colorCodingMode
        self.autoSaveInterval = autoSaveInterval
        self.revisionColor = revisionColor
    }
}

/// Scene-level metadata
struct SceneMetadata: Codable, Hashable {
    var summary: String?
    var mood: String?
    var storyThread: String?
    var importance: SceneImportance
    var estimatedDuration: TimeInterval?
    var shotCount: Int?

    init(
        summary: String? = nil,
        mood: String? = nil,
        storyThread: String? = nil,
        importance: SceneImportance = .important,
        estimatedDuration: TimeInterval? = nil,
        shotCount: Int? = nil
    ) {
        self.summary = summary
        self.mood = mood
        self.storyThread = storyThread
        self.importance = importance
        self.estimatedDuration = estimatedDuration
        self.shotCount = shotCount
    }

    /// Estimated duration in minutes (1 page ≈ 1 minute)
    func estimatedMinutes(pageLength: Double) -> Double {
        estimatedDuration ?? (pageLength * 60)  // Convert pages to seconds
    }
}

/// Character metadata
struct CharacterMetadata: Codable, Hashable {
    var role: CharacterRole
    var lineCount: Int
    var sceneCount: Int
    var firstAppearance: Int?  // Scene number
    var relationships: [UUID: String]  // Character ID to relationship description

    init(
        role: CharacterRole = .supporting,
        lineCount: Int = 0,
        sceneCount: Int = 0,
        firstAppearance: Int? = nil,
        relationships: [UUID: String] = [:]
    ) {
        self.role = role
        self.lineCount = lineCount
        self.sceneCount = sceneCount
        self.firstAppearance = firstAppearance
        self.relationships = relationships
    }
}

/// Character role in story
enum CharacterRole: String, Codable, CaseIterable {
    case protagonist = "Protagonist"
    case antagonist = "Antagonist"
    case supporting = "Supporting"
    case minor = "Minor"
    case extra = "Extra"

    var priority: Int {
        switch self {
        case .protagonist: return 5
        case .antagonist: return 4
        case .supporting: return 3
        case .minor: return 2
        case .extra: return 1
        }
    }
}

/// Note attached to scene or project
struct Note: Codable, Hashable, Identifiable {
    let id: UUID
    var text: String
    var type: NoteType
    var authorId: UUID?
    var isPrivate: Bool
    var color: String?
    var createdAt: Date
    var modifiedAt: Date

    init(
        id: UUID = UUID(),
        text: String,
        type: NoteType = .general,
        authorId: UUID? = nil,
        isPrivate: Bool = true,
        color: String? = nil,
        createdAt: Date = Date(),
        modifiedAt: Date = Date()
    ) {
        self.id = id
        self.text = text
        self.type = type
        self.authorId = authorId
        self.isPrivate = isPrivate
        self.color = color
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
    }
}

enum NoteType: String, Codable, CaseIterable {
    case general = "General"
    case production = "Production"
    case creative = "Creative"
    case technical = "Technical"
    case reminder = "Reminder"

    var icon: String {
        switch self {
        case .general:
            return "note.text"
        case .production:
            return "film"
        case .creative:
            return "lightbulb"
        case .technical:
            return "wrench"
        case .reminder:
            return "bell"
        }
    }
}
