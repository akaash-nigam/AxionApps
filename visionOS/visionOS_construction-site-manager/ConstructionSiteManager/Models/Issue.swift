//
//  Issue.swift
//  Construction Site Manager
//
//  Issue tracking models
//

import Foundation
import SwiftData

// MARK: - Issue

/// Represents a construction issue
@Model
final class Issue {
    @Attribute(.unique) var id: UUID
    var title: String
    var issueDescription: String
    var type: IssueType
    var priority: IssuePriority
    var status: IssueStatus
    var floor: Int?
    var zone: String?
    var positionX: Float?
    var positionY: Float?
    var positionZ: Float?
    var relatedElementIDs: [String]  // IFC GUIDs
    var assignedTo: String
    var reporter: String
    var createdDate: Date
    var dueDate: Date
    var resolvedDate: Date?
    var closedDate: Date?
    var costImpact: Double?
    var scheduleImpact: TimeInterval?  // In seconds
    var photoURLs: [String]
    var notes: String?

    @Relationship(deleteRule: .cascade) var comments: [IssueComment]
    @Relationship(inverse: \Project.issues) var project: Project?

    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        type: IssueType,
        priority: IssuePriority,
        status: IssueStatus = .open,
        floor: Int? = nil,
        zone: String? = nil,
        position: SIMD3<Float>? = nil,
        relatedElementIDs: [String] = [],
        assignedTo: String,
        reporter: String,
        createdDate: Date = Date(),
        dueDate: Date,
        costImpact: Double? = nil,
        scheduleImpact: TimeInterval? = nil,
        photoURLs: [String] = []
    ) {
        self.id = id
        self.title = title
        self.issueDescription = description
        self.type = type
        self.priority = priority
        self.status = status
        self.floor = floor
        self.zone = zone
        self.relatedElementIDs = relatedElementIDs
        self.assignedTo = assignedTo
        self.reporter = reporter
        self.createdDate = createdDate
        self.dueDate = dueDate
        self.costImpact = costImpact
        self.scheduleImpact = scheduleImpact
        self.photoURLs = photoURLs
        self.comments = []

        if let pos = position {
            self.positionX = pos.x
            self.positionY = pos.y
            self.positionZ = pos.z
        }
    }

    var position: SIMD3<Float>? {
        guard let x = positionX, let y = positionY, let z = positionZ else { return nil }
        return SIMD3<Float>(x, y, z)
    }

    var isOverdue: Bool {
        status != .closed && status != .resolved && Date() > dueDate
    }

    var daysOpen: Int {
        let end = resolvedDate ?? Date()
        return Calendar.current.dateComponents([.day], from: createdDate, to: end).day ?? 0
    }

    var daysUntilDue: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: dueDate).day ?? 0
    }
}

// MARK: - Issue Comment

@Model
final class IssueComment {
    @Attribute(.unique) var id: UUID
    var text: String
    var author: String
    var timestamp: Date
    var photoURLs: [String]

    @Relationship(inverse: \Issue.comments) var issue: Issue?

    init(
        id: UUID = UUID(),
        text: String,
        author: String,
        timestamp: Date = Date(),
        photoURLs: [String] = []
    ) {
        self.id = id
        self.text = text
        self.author = author
        self.timestamp = timestamp
        self.photoURLs = photoURLs
    }
}

// MARK: - Annotation

/// Spatial annotation in AR view
struct Annotation: Codable, Identifiable, Equatable {
    var id: UUID
    var type: AnnotationType
    var text: String
    var author: String
    var timestamp: Date
    var position: SIMD3<Float>
    var status: AnnotationStatus
    var assignedTo: String?
    var photoURLs: [String]

    init(
        id: UUID = UUID(),
        type: AnnotationType,
        text: String,
        author: String,
        timestamp: Date = Date(),
        position: SIMD3<Float>,
        status: AnnotationStatus = .active,
        assignedTo: String? = nil,
        photoURLs: [String] = []
    ) {
        self.id = id
        self.type = type
        self.text = text
        self.author = author
        self.timestamp = timestamp
        self.position = position
        self.status = status
        self.assignedTo = assignedTo
        self.photoURLs = photoURLs
    }
}

enum AnnotationType: String, Codable {
    case note
    case issue
    case measurement
    case photo
    case voice

    var icon: String {
        switch self {
        case .note: return "note.text"
        case .issue: return "exclamationmark.triangle"
        case .measurement: return "ruler"
        case .photo: return "camera"
        case .voice: return "mic"
        }
    }
}

enum AnnotationStatus: String, Codable {
    case active
    case resolved
    case archived

    var displayName: String {
        switch self {
        case .active: return "Active"
        case .resolved: return "Resolved"
        case .archived: return "Archived"
        }
    }
}

// MARK: - Additional Supporting Types

/// Alias for IssueType to support code using IssueCategory
typealias IssueCategory = IssueType

/// Alias for SafetySeverity to support code using AlertSeverity
typealias AlertSeverity = SafetySeverity

/// Comment struct for compatibility (maps to IssueComment)
struct Comment: Identifiable, Codable {
    let id: UUID
    var text: String
    var author: String
    var createdDate: Date

    init(id: UUID = UUID(), text: String, author: String, createdDate: Date) {
        self.id = id
        self.text = text
        self.author = author
        self.createdDate = createdDate
    }
}
