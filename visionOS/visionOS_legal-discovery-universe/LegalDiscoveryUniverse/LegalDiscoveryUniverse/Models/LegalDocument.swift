//
//  LegalDocument.swift
//  Legal Discovery Universe
//
//  Created on 2025-11-17.
//

import Foundation
import SwiftData

@Model
final class LegalDocument {
    // MARK: - Properties

    @Attribute(.unique) var id: UUID
    var title: String
    var fileName: String
    var fileType: DocumentType
    var fileSize: Int64
    var pageCount: Int
    var fileURL: URL?

    // Content
    var extractedText: String
    var summary: String?

    // Classification
    var relevanceScore: Double
    var isPrivileged: Bool
    var privilegeType: PrivilegeType?
    var privilegeBasis: String?
    var isKeyEvidence: Bool
    var isProduction: Bool

    // Spatial positioning
    var spatialPositionX: Float?
    var spatialPositionY: Float?
    var spatialPositionZ: Float?
    var spatialCluster: String?

    // AI Analysis
    var aiTags: [String]
    var extractedEntities: [String]
    var sentiment: Double?
    var topicCategories: [String]

    // Metadata
    var author: String?
    var recipient: String?
    var createdDate: Date?
    var modifiedDate: Date?

    // Relationships
    @Relationship var relatedDocuments: [LegalDocument]
    @Relationship var linkedEntities: [LegalEntity]
    @Relationship(deleteRule: .cascade) var annotations: [Annotation]

    // Audit trail
    var uploadDate: Date
    var reviewedBy: String?
    var reviewDate: Date?
    var productionDate: Date?

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        title: String,
        fileName: String,
        fileType: DocumentType,
        fileSize: Int64,
        pageCount: Int = 0
    ) {
        self.id = id
        self.title = title
        self.fileName = fileName
        self.fileType = fileType
        self.fileSize = fileSize
        self.pageCount = pageCount
        self.extractedText = ""
        self.relevanceScore = 0.0
        self.isPrivileged = false
        self.isKeyEvidence = false
        self.isProduction = false
        self.aiTags = []
        self.extractedEntities = []
        self.topicCategories = []
        self.relatedDocuments = []
        self.linkedEntities = []
        self.annotations = []
        self.uploadDate = Date()
    }

    // MARK: - Computed Properties

    var spatialPosition: SIMD3<Float>? {
        get {
            guard let x = spatialPositionX,
                  let y = spatialPositionY,
                  let z = spatialPositionZ else {
                return nil
            }
            return SIMD3<Float>(x, y, z)
        }
        set {
            if let position = newValue {
                spatialPositionX = position.x
                spatialPositionY = position.y
                spatialPositionZ = position.z
            } else {
                spatialPositionX = nil
                spatialPositionY = nil
                spatialPositionZ = nil
            }
        }
    }

    var formattedFileSize: String {
        ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file)
    }

    var relevancePercentage: Int {
        Int(relevanceScore * 100)
    }

    // MARK: - Methods

    func markRelevant(score: Double = 1.0) {
        relevanceScore = max(0.0, min(1.0, score))
    }

    func markPrivileged(type: PrivilegeType, basis: String) {
        isPrivileged = true
        privilegeType = type
        privilegeBasis = basis
    }

    func flagAsKeyEvidence() {
        isKeyEvidence = true
        relevanceScore = max(relevanceScore, 0.9)
    }

    func markReviewed(by reviewer: String) {
        reviewedBy = reviewer
        reviewDate = Date()
    }
}

// MARK: - Supporting Types

enum DocumentType: String, Codable {
    case pdf = "PDF"
    case word = "Word Document"
    case email = "Email"
    case spreadsheet = "Spreadsheet"
    case presentation = "Presentation"
    case image = "Image"
    case text = "Text"
    case other = "Other"

    var iconName: String {
        switch self {
        case .pdf: return "doc.fill"
        case .word: return "doc.text.fill"
        case .email: return "envelope.fill"
        case .spreadsheet: return "tablecells.fill"
        case .presentation: return "person.fill.viewfinder"
        case .image: return "photo.fill"
        case .text: return "doc.plaintext.fill"
        case .other: return "doc.fill"
        }
    }

    var color: String {
        switch self {
        case .pdf: return "red"
        case .word: return "blue"
        case .email: return "green"
        case .spreadsheet: return "green"
        case .presentation: return "orange"
        case .image: return "purple"
        case .text: return "gray"
        case .other: return "gray"
        }
    }
}

enum PrivilegeType: String, Codable {
    case attorneyClient = "Attorney-Client"
    case workProduct = "Work Product"
    case confidential = "Confidential"
    case tradeSecret = "Trade Secret"
    case executivePrivilege = "Executive Privilege"

    var description: String {
        switch self {
        case .attorneyClient:
            return "Communications between attorney and client"
        case .workProduct:
            return "Materials prepared in anticipation of litigation"
        case .confidential:
            return "Confidential business information"
        case .tradeSecret:
            return "Protected trade secret"
        case .executivePrivilege:
            return "Executive or deliberative privilege"
        }
    }
}

// Text block for structured content (future use)
@Model
final class TextBlock {
    @Attribute(.unique) var id: UUID
    var pageNumber: Int
    var content: String
    var boundingBox: String? // Stored as JSON string

    init(id: UUID = UUID(), pageNumber: Int, content: String) {
        self.id = id
        self.pageNumber = pageNumber
        self.content = content
    }
}
