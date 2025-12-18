//
//  LegalCase.swift
//  Legal Discovery Universe
//
//  Created by Claude Code
//  Copyright © 2024 Legal Discovery Universe. All rights reserved.
//

import Foundation
import SwiftData

@Model
final class LegalCase {
    @Attribute(.unique) var id: UUID
    var caseNumber: String
    var title: String
    var caseDescription: String
    var status: CaseStatus
    var createdDate: Date
    var lastModified: Date

    // Relationships
    @Relationship(deleteRule: .cascade) var documents: [Document] = []
    @Relationship(deleteRule: .cascade) var entities: [Entity] = []
    @Relationship(deleteRule: .cascade) var timelines: [Timeline] = []
    @Relationship(deleteRule: .cascade) var tags: [Tag] = []
    @Relationship(deleteRule: .cascade) var collaborators: [Collaborator] = []

    // Metadata
    var metadata: CaseMetadata?
    var securityLevel: SecurityLevel
    var privilegeFlags: PrivilegeFlags?

    // Statistics
    var documentCount: Int = 0
    var relevantDocumentCount: Int = 0
    var privilegedDocumentCount: Int = 0
    var reviewProgress: Double = 0.0

    init(
        id: UUID = UUID(),
        caseNumber: String,
        title: String,
        description: String,
        status: CaseStatus = .active,
        securityLevel: SecurityLevel = .confidential
    ) {
        self.id = id
        self.caseNumber = caseNumber
        self.title = title
        self.caseDescription = description
        self.status = status
        self.securityLevel = securityLevel
        self.createdDate = Date()
        self.lastModified = Date()
    }
}

// MARK: - Enumerations

enum CaseStatus: String, Codable {
    case active
    case archived
    case closed
}

enum SecurityLevel: String, Codable {
    case `public`
    case `internal`
    case confidential
    case restricted
    case topSecret
}

// MARK: - Supporting Structures

struct CaseMetadata: Codable {
    var client: String?
    var opposingParty: String?
    var courtName: String?
    var judge: String?
    var filingDate: Date?
    var trialDate: Date?
    var jurisdiction: String?
    var practiceArea: String?
    var leadAttorney: String?
    var customFields: [String: String] = [:]
}

struct PrivilegeFlags: Codable {
    var hasAttorneyClientPrivilege: Bool = false
    var hasWorkProduct: Bool = false
    var hasConfidentialInfo: Bool = false
    var requiresRedaction: Bool = false
    var customPrivileges: [String] = []
}

@Model
final class Collaborator {
    @Attribute(.unique) var id: UUID
    var userId: UUID
    var name: String
    var email: String
    var role: CollaboratorRole
    var permissions: CollaboratorPermissions
    var addedDate: Date

    @Relationship(inverse: \LegalCase.collaborators) var legalCase: LegalCase?

    init(
        id: UUID = UUID(),
        userId: UUID,
        name: String,
        email: String,
        role: CollaboratorRole,
        permissions: CollaboratorPermissions = CollaboratorPermissions()
    ) {
        self.id = id
        self.userId = userId
        self.name = name
        self.email = email
        self.role = role
        self.permissions = permissions
        self.addedDate = Date()
    }
}

enum CollaboratorRole: String, Codable {
    case owner
    case attorney
    case paralegal
    case reviewer
    case viewer
}

struct CollaboratorPermissions: Codable {
    var canView: Bool = true
    var canEdit: Bool = false
    var canDelete: Bool = false
    var canExport: Bool = false
    var canManageUsers: Bool = false
    var canViewPrivileged: Bool = false
}
