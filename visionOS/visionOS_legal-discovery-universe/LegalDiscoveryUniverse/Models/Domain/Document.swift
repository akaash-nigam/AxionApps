//
//  Document.swift
//  Legal Discovery Universe
//
//  Created by Claude Code
//  Copyright © 2024 Legal Discovery Universe. All rights reserved.
//

import Foundation
import SwiftData

@Model
final class Document {
    @Attribute(.unique) var id: UUID
    var fileName: String
    var fileType: FileType
    var fileSize: Int64
    var contentHash: String

    // Content
    var extractedText: String = ""
    var ocrText: String?
    var metadata: DocumentMetadata?

    // AI Analysis
    var relevanceScore: Double = 0.0
    var privilegeStatus: PrivilegeStatus = .notPrivileged
    var aiAnalysis: AIAnalysis?

    // Relationships
    @Relationship(inverse: \LegalCase.documents) var legalCase: LegalCase?
    @Relationship var relatedDocuments: [Document] = []
    @Relationship var entities: [Entity] = []
    @Relationship var tags: [Tag] = []
    @Relationship(deleteRule: .cascade) var annotations: [Annotation] = []

    // Spatial Properties
    var spatialPosition: SpatialPosition?
    var visualizationMetadata: VisualizationMetadata?

    // Dates
    var documentDate: Date?
    var createdDate: Date
    var modifiedDate: Date
    var reviewedDate: Date?
    var reviewedBy: String?

    // Review State
    var isReviewed: Bool = false
    var isRelevant: Bool = false
    var isPrivileged: Bool = false
    var isKeyEvidence: Bool = false

    init(
        id: UUID = UUID(),
        fileName: String,
        fileType: FileType,
        fileSize: Int64 = 0,
        contentHash: String = "",
        extractedText: String = ""
    ) {
        self.id = id
        self.fileName = fileName
        self.fileType = fileType
        self.fileSize = fileSize
        self.contentHash = contentHash
        self.extractedText = extractedText
        self.createdDate = Date()
        self.modifiedDate = Date()
    }
}

// MARK: - Enumerations

enum FileType: String, Codable {
    case email
    case pdf
    case word
    case excel
    case image
    case video
    case audio
    case other
}

enum PrivilegeStatus: String, Codable {
    case notPrivileged
    case attorneyClient
    case workProduct
    case confidential
    case contested
}

// MARK: - Supporting Structures

struct DocumentMetadata: Codable {
    // Email metadata
    var author: String?
    var from: String?
    var recipient: [String] = []
    var cc: [String] = []
    var bcc: [String] = []
    var subject: String?

    // File metadata
    var dateCreated: Date?
    var dateModified: Date?
    var custodian: String?
    var source: String?
    var path: String?

    // Legal metadata
    var confidentialityLevel: String?
    var batesNumber: String?
    var productionNumber: String?

    // Custom fields
    var customFields: [String: String] = [:]
}

struct AIAnalysis: Codable {
    var relevanceScore: Double = 0.0
    var privilegeConfidence: Double = 0.0
    var keyPhrases: [String] = []
    var entities: [String] = []
    var sentiment: Double = 0.0
    var topics: [String] = []
    var suggestedTags: [String] = []
    var relationships: [String] = []
    var language: String = "en"
    var summary: String?

    var analyzedDate: Date = Date()
    var modelVersion: String = "1.0"
}

struct SpatialPosition: Codable {
    var x: Float = 0.0
    var y: Float = 0.0
    var z: Float = 0.0
    var scale: Float = 1.0
    var rotation: SIMD3<Float> = SIMD3<Float>(0, 0, 0)
}

struct VisualizationMetadata: Codable {
    var clusterID: UUID?
    var color: String = "#FFFFFF"
    var size: Float = 1.0
    var opacity: Float = 1.0
    var isVisible: Bool = true
    var lodLevel: Int = 0 // Level of Detail
}

@Model
final class Annotation {
    @Attribute(.unique) var id: UUID
    var documentId: UUID
    var content: String
    var type: AnnotationType
    var createdBy: String
    var createdDate: Date
    var modifiedDate: Date

    // Position (for highlighting, etc.)
    var pageNumber: Int?
    var startOffset: Int?
    var endOffset: Int?

    // Spatial annotation
    var spatialPosition: SIMD3<Float>?

    @Relationship(inverse: \Document.annotations) var document: Document?

    init(
        id: UUID = UUID(),
        documentId: UUID,
        content: String,
        type: AnnotationType,
        createdBy: String
    ) {
        self.id = id
        self.documentId = documentId
        self.content = content
        self.type = type
        self.createdBy = createdBy
        self.createdDate = Date()
        self.modifiedDate = Date()
    }
}

enum AnnotationType: String, Codable {
    case note
    case highlight
    case flag
    case redaction
    case bookmark
}
