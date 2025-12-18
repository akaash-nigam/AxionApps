//
//  LegalCase.swift
//  Legal Discovery Universe
//
//  Created on 2025-11-17.
//

import Foundation
import SwiftData

@Model
final class LegalCase {
    // MARK: - Properties

    @Attribute(.unique) var id: UUID
    var caseNumber: String
    var title: String
    var caseDescription: String
    var status: CaseStatus
    var createdDate: Date
    var lastModified: Date

    // Relationships
    @Relationship(deleteRule: .cascade) var documents: [LegalDocument]
    @Relationship(deleteRule: .cascade) var entities: [LegalEntity]
    @Relationship(deleteRule: .cascade) var timelines: [Timeline]
    @Relationship(deleteRule: .nullify) var collaborators: [Collaborator]

    // Metadata
    var tags: [String]
    var jurisdiction: String
    var estimatedValue: Decimal?
    var riskLevel: RiskLevel
    var priority: CasePriority

    // Statistics
    var totalDocuments: Int
    var reviewedDocuments: Int
    var privilegedDocuments: Int
    var relevantDocuments: Int

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        caseNumber: String,
        title: String,
        description: String,
        status: CaseStatus = .active,
        jurisdiction: String = "Federal",
        riskLevel: RiskLevel = .medium,
        priority: CasePriority = .normal,
        tags: [String] = []
    ) {
        self.id = id
        self.caseNumber = caseNumber
        self.title = title
        self.caseDescription = description
        self.status = status
        self.createdDate = Date()
        self.lastModified = Date()
        self.jurisdiction = jurisdiction
        self.riskLevel = riskLevel
        self.priority = priority
        self.tags = tags
        self.documents = []
        self.entities = []
        self.timelines = []
        self.collaborators = []
        self.totalDocuments = 0
        self.reviewedDocuments = 0
        self.privilegedDocuments = 0
        self.relevantDocuments = 0
    }

    // MARK: - Methods

    func updateStatistics() {
        totalDocuments = documents.count
        reviewedDocuments = documents.filter { $0.reviewDate != nil }.count
        privilegedDocuments = documents.filter { $0.isPrivileged }.count
        relevantDocuments = documents.filter { $0.relevanceScore > 0.5 }.count
        lastModified = Date()
    }

    var reviewProgress: Double {
        guard totalDocuments > 0 else { return 0 }
        return Double(reviewedDocuments) / Double(totalDocuments)
    }

    var privilegeRate: Double {
        guard totalDocuments > 0 else { return 0 }
        return Double(privilegedDocuments) / Double(totalDocuments)
    }

    var relevanceRate: Double {
        guard totalDocuments > 0 else { return 0 }
        return Double(relevantDocuments) / Double(totalDocuments)
    }
}

// MARK: - Supporting Types

enum CaseStatus: String, Codable {
    case active = "Active"
    case review = "In Review"
    case complete = "Complete"
    case archived = "Archived"
    case onHold = "On Hold"
}

enum RiskLevel: String, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case critical = "Critical"

    var color: String {
        switch self {
        case .low: return "green"
        case .medium: return "yellow"
        case .high: return "orange"
        case .critical: return "red"
        }
    }
}

enum CasePriority: String, Codable {
    case low = "Low"
    case normal = "Normal"
    case high = "High"
    case urgent = "Urgent"

    var sortOrder: Int {
        switch self {
        case .low: return 0
        case .normal: return 1
        case .high: return 2
        case .urgent: return 3
        }
    }
}

@Model
final class Collaborator {
    @Attribute(.unique) var id: UUID
    var name: String
    var email: String
    var role: CollaboratorRole
    var joinedDate: Date
    var lastActive: Date?

    init(id: UUID = UUID(), name: String, email: String, role: CollaboratorRole) {
        self.id = id
        self.name = name
        self.email = email
        self.role = role
        self.joinedDate = Date()
    }
}

enum CollaboratorRole: String, Codable {
    case attorney = "Attorney"
    case paralegal = "Paralegal"
    case reviewer = "Reviewer"
    case admin = "Administrator"
    case client = "Client"

    var permissions: Set<Permission> {
        switch self {
        case .attorney:
            return [.read, .write, .delete, .share, .export, .markPrivileged]
        case .paralegal:
            return [.read, .write, .share, .export]
        case .reviewer:
            return [.read, .write]
        case .admin:
            return [.read, .write, .delete, .share, .export, .markPrivileged, .admin]
        case .client:
            return [.read, .export]
        }
    }
}

enum Permission {
    case read
    case write
    case delete
    case share
    case export
    case markPrivileged
    case admin
}
