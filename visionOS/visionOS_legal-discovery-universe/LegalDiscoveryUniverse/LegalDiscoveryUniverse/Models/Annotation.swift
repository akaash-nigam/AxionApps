//
//  Annotation.swift
//  Legal Discovery Universe
//
//  Created on 2025-11-17.
//

import Foundation
import SwiftData

@Model
final class Annotation {
    // MARK: - Properties

    @Attribute(.unique) var id: UUID
    var content: String
    var annotationType: AnnotationType
    var createdBy: String
    var createdDate: Date
    var lastModified: Date

    // Spatial anchoring
    var anchorPositionX: Float?
    var anchorPositionY: Float?
    var anchorPositionZ: Float?
    var documentPageNumber: Int?

    // Text range (stored as start and length)
    var textRangeStart: Int?
    var textRangeLength: Int?

    // Collaboration
    @Relationship(deleteRule: .cascade) var replies: [AnnotationReply]
    var isResolved: Bool
    var resolvedBy: String?
    var resolvedDate: Date?

    // Color and styling
    var color: String?
    var tags: [String]

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        content: String,
        type: AnnotationType,
        createdBy: String
    ) {
        self.id = id
        self.content = content
        self.annotationType = type
        self.createdBy = createdBy
        self.createdDate = Date()
        self.lastModified = Date()
        self.isResolved = false
        self.replies = []
        self.tags = []
    }

    // MARK: - Computed Properties

    var anchorPosition: SIMD3<Float>? {
        get {
            guard let x = anchorPositionX,
                  let y = anchorPositionY,
                  let z = anchorPositionZ else {
                return nil
            }
            return SIMD3<Float>(x, y, z)
        }
        set {
            if let position = newValue {
                anchorPositionX = position.x
                anchorPositionY = position.y
                anchorPositionZ = position.z
            } else {
                anchorPositionX = nil
                anchorPositionY = nil
                anchorPositionZ = nil
            }
        }
    }

    var textRange: Range<Int>? {
        guard let start = textRangeStart,
              let length = textRangeLength else {
            return nil
        }
        return start..<(start + length)
    }

    var replyCount: Int {
        replies.count
    }

    // MARK: - Methods

    func addReply(_ reply: AnnotationReply) {
        replies.append(reply)
        lastModified = Date()
    }

    func resolve(by user: String) {
        isResolved = true
        resolvedBy = user
        resolvedDate = Date()
        lastModified = Date()
    }

    func unresolve() {
        isResolved = false
        resolvedBy = nil
        resolvedDate = nil
        lastModified = Date()
    }

    func setTextRange(_ range: Range<Int>) {
        textRangeStart = range.lowerBound
        textRangeLength = range.count
    }
}

// MARK: - Annotation Reply

@Model
final class AnnotationReply {
    @Attribute(.unique) var id: UUID
    var content: String
    var createdBy: String
    var createdDate: Date

    init(
        id: UUID = UUID(),
        content: String,
        createdBy: String
    ) {
        self.id = id
        self.content = content
        self.createdBy = createdBy
        self.createdDate = Date()
    }
}

// MARK: - Supporting Types

enum AnnotationType: String, Codable {
    case note = "Note"
    case highlight = "Highlight"
    case question = "Question"
    case important = "Important"
    case todo = "To-Do"
    case flagPrivilege = "Privilege Flag"
    case keyEvidence = "Key Evidence"
    case redaction = "Redaction"
    case comment = "Comment"

    var iconName: String {
        switch self {
        case .note: return "note.text"
        case .highlight: return "highlighter"
        case .question: return "questionmark.circle"
        case .important: return "exclamationmark.triangle"
        case .todo: return "checkmark.circle"
        case .flagPrivilege: return "shield.fill"
        case .keyEvidence: return "star.fill"
        case .redaction: return "eye.slash.fill"
        case .comment: return "bubble.left.fill"
        }
    }

    var defaultColor: String {
        switch self {
        case .note: return "yellow"
        case .highlight: return "yellow"
        case .question: return "blue"
        case .important: return "red"
        case .todo: return "green"
        case .flagPrivilege: return "red"
        case .keyEvidence: return "gold"
        case .redaction: return "black"
        case .comment: return "blue"
        }
    }
}
