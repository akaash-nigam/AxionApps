//
//  Comment.swift
//  Reality Annotation Platform
//
//  Comment model for collaboration
//

import Foundation
import SwiftData

@Model
final class Comment {
    // Identity
    @Attribute(.unique) var id: UUID
    var cloudKitRecordName: String?

    // Content
    var text: String
    var authorID: String
    var authorName: String?

    // Relationship
    var annotationID: UUID
    @Relationship(deleteRule: .nullify) var annotation: Annotation?

    // Threading
    var parentCommentID: UUID?
    @Relationship(deleteRule: .nullify) var parentComment: Comment?
    @Relationship(deleteRule: .cascade) var replies: [Comment]

    // Metadata
    var createdAt: Date
    var updatedAt: Date
    var isDeleted: Bool
    var isEdited: Bool

    // Sync
    var syncStatus: String

    init(
        id: UUID = UUID(),
        text: String,
        authorID: String,
        annotationID: UUID,
        authorName: String? = nil
    ) {
        self.id = id
        self.text = text
        self.authorID = authorID
        self.authorName = authorName
        self.annotationID = annotationID
        self.createdAt = Date()
        self.updatedAt = Date()
        self.isDeleted = false
        self.isEdited = false
        self.replies = []
        self.syncStatus = "pending"
    }
}
