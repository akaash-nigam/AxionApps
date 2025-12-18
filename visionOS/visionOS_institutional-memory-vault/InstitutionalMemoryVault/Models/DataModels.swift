//
//  DataModels.swift
//  Institutional Memory Vault
//
//  Core data models for knowledge management
//

import Foundation
import SwiftData

// MARK: - Knowledge Entity

@Model
final class KnowledgeEntity {
    @Attribute(.unique) var id: UUID
    var title: String
    var content: String
    var contentType: KnowledgeContentType
    var createdDate: Date
    var lastModified: Date
    var author: Employee?
    var department: Department?
    var tags: [String]
    var connections: [KnowledgeConnection]
    var accessLevel: AccessLevel
    var spatialPosition: SpatialCoordinate?
    var embeddings: [Float]?
    var metadata: [String: String]

    init(
        id: UUID = UUID(),
        title: String,
        content: String,
        contentType: KnowledgeContentType,
        createdDate: Date = Date(),
        lastModified: Date = Date(),
        author: Employee? = nil,
        department: Department? = nil,
        tags: [String] = [],
        connections: [KnowledgeConnection] = [],
        accessLevel: AccessLevel = .publicOrg,
        spatialPosition: SpatialCoordinate? = nil,
        embeddings: [Float]? = nil,
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.contentType = contentType
        self.createdDate = createdDate
        self.lastModified = lastModified
        self.author = author
        self.department = department
        self.tags = tags
        self.connections = connections
        self.accessLevel = accessLevel
        self.spatialPosition = spatialPosition
        self.embeddings = embeddings
        self.metadata = metadata
    }
}

enum KnowledgeContentType: String, Codable {
    case document
    case expertise
    case decision
    case process
    case story
    case lesson
    case innovation
}

// MARK: - Employee (Knowledge Holder)

@Model
final class Employee {
    @Attribute(.unique) var id: UUID
    var name: String
    var email: String
    var department: Department?
    var role: String
    var expertiseAreas: [String]
    var startDate: Date
    var endDate: Date?
    var knowledgeContributions: [KnowledgeEntity]
    var careerJourney: [CareerMilestone]
    var profileImageData: Data?

    init(
        id: UUID = UUID(),
        name: String,
        email: String,
        department: Department? = nil,
        role: String,
        expertiseAreas: [String] = [],
        startDate: Date = Date(),
        endDate: Date? = nil,
        knowledgeContributions: [KnowledgeEntity] = [],
        careerJourney: [CareerMilestone] = [],
        profileImageData: Data? = nil
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.department = department
        self.role = role
        self.expertiseAreas = expertiseAreas
        self.startDate = startDate
        self.endDate = endDate
        self.knowledgeContributions = knowledgeContributions
        self.careerJourney = careerJourney
        self.profileImageData = profileImageData
    }
}

struct CareerMilestone: Codable, Hashable {
    var date: Date
    var title: String
    var description: String
    var department: String
}

// MARK: - Knowledge Connection

@Model
final class KnowledgeConnection {
    @Attribute(.unique) var id: UUID
    var sourceEntity: KnowledgeEntity?
    var targetEntity: KnowledgeEntity?
    var connectionType: ConnectionType
    var strength: Float
    var context: String?
    var createdBy: Employee?
    var createdDate: Date

    init(
        id: UUID = UUID(),
        sourceEntity: KnowledgeEntity? = nil,
        targetEntity: KnowledgeEntity? = nil,
        connectionType: ConnectionType,
        strength: Float = 1.0,
        context: String? = nil,
        createdBy: Employee? = nil,
        createdDate: Date = Date()
    ) {
        self.id = id
        self.sourceEntity = sourceEntity
        self.targetEntity = targetEntity
        self.connectionType = connectionType
        self.strength = strength
        self.context = context
        self.createdBy = createdBy
        self.createdDate = createdDate
    }
}

enum ConnectionType: String, Codable {
    case relatedTo
    case causedBy
    case leadTo
    case contradicts
    case supports
    case prerequisiteFor
    case successor
}

// MARK: - Department & Organization

@Model
final class Department {
    @Attribute(.unique) var id: UUID
    var name: String
    var parentDepartment: Department?
    var subDepartments: [Department]
    var employees: [Employee]
    var knowledgeAssets: [KnowledgeEntity]
    var spatialLocation: SpatialCoordinate?

    init(
        id: UUID = UUID(),
        name: String,
        parentDepartment: Department? = nil,
        subDepartments: [Department] = [],
        employees: [Employee] = [],
        knowledgeAssets: [KnowledgeEntity] = [],
        spatialLocation: SpatialCoordinate? = nil
    ) {
        self.id = id
        self.name = name
        self.parentDepartment = parentDepartment
        self.subDepartments = subDepartments
        self.employees = employees
        self.knowledgeAssets = knowledgeAssets
        self.spatialLocation = spatialLocation
    }
}

@Model
final class Organization {
    @Attribute(.unique) var id: UUID
    var name: String
    var foundingDate: Date
    var departments: [Department]
    var culturalValues: [String]
    var strategicMilestones: [Milestone]

    init(
        id: UUID = UUID(),
        name: String,
        foundingDate: Date,
        departments: [Department] = [],
        culturalValues: [String] = [],
        strategicMilestones: [Milestone] = []
    ) {
        self.id = id
        self.name = name
        self.foundingDate = foundingDate
        self.departments = departments
        self.culturalValues = culturalValues
        self.strategicMilestones = strategicMilestones
    }
}

struct Milestone: Codable, Hashable {
    var date: Date
    var title: String
    var description: String
    var significance: Float
}

// MARK: - Memory Palace Structure

@Model
final class MemoryPalaceRoom {
    @Attribute(.unique) var id: UUID
    var name: String
    var roomType: RoomType
    var spatialPosition: SpatialCoordinate
    var knowledge: [KnowledgeEntity]
    var visualTheme: String
    var accessPolicy: AccessPolicy

    init(
        id: UUID = UUID(),
        name: String,
        roomType: RoomType,
        spatialPosition: SpatialCoordinate,
        knowledge: [KnowledgeEntity] = [],
        visualTheme: String = "default",
        accessPolicy: AccessPolicy
    ) {
        self.id = id
        self.name = name
        self.roomType = roomType
        self.spatialPosition = spatialPosition
        self.knowledge = knowledge
        self.visualTheme = visualTheme
        self.accessPolicy = accessPolicy
    }
}

enum RoomType: String, Codable {
    case temporalHall
    case departmentWing
    case decisionChamber
    case wisdomGarden
    case innovationGallery
    case failureLibrary
    case cultureTemple
}

// MARK: - Supporting Types

struct SpatialCoordinate: Codable, Hashable {
    var x: Float
    var y: Float
    var z: Float
    var scale: Float
    var temporalPosition: Date?

    init(x: Float = 0, y: Float = 0, z: Float = 0, scale: Float = 1.0, temporalPosition: Date? = nil) {
        self.x = x
        self.y = y
        self.z = z
        self.scale = scale
        self.temporalPosition = temporalPosition
    }
}

enum AccessLevel: Int, Codable, Comparable {
    case publicOrg = 0
    case department = 1
    case team = 2
    case confidential = 3
    case restricted = 4

    static func < (lhs: AccessLevel, rhs: AccessLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

struct AccessPolicy: Codable, Hashable {
    var level: AccessLevel
    var allowedDepartments: [UUID]
    var allowedEmployees: [UUID]
    var expirationDate: Date?

    init(
        level: AccessLevel = .publicOrg,
        allowedDepartments: [UUID] = [],
        allowedEmployees: [UUID] = [],
        expirationDate: Date? = nil
    ) {
        self.level = level
        self.allowedDepartments = allowedDepartments
        self.allowedEmployees = allowedEmployees
        self.expirationDate = expirationDate
    }
}
