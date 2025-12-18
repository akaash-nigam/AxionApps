//
//  LegalEntity.swift
//  Legal Discovery Universe
//
//  Created on 2025-11-17.
//

import Foundation
import SwiftData

@Model
final class LegalEntity {
    // MARK: - Properties

    @Attribute(.unique) var id: UUID
    var name: String
    var type: EntityType
    var aliases: [String]

    // Spatial representation
    var spatialPositionX: Float?
    var spatialPositionY: Float?
    var spatialPositionZ: Float?
    var visualRepresentation: EntityVisualization

    // Relationships
    @Relationship(deleteRule: .cascade) var relationships: [EntityRelationship]
    @Relationship var mentionedIn: [LegalDocument]

    // Analysis
    var importance: Double
    var role: String?
    var entityDescription: String?

    // Contact information (for persons/organizations)
    var email: String?
    var phone: String?
    var address: String?

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        name: String,
        type: EntityType,
        aliases: [String] = [],
        importance: Double = 0.5
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.aliases = aliases
        self.importance = importance
        self.visualRepresentation = type.defaultVisualization
        self.relationships = []
        self.mentionedIn = []
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

    var mentionCount: Int {
        mentionedIn.count
    }

    // MARK: - Methods

    func addRelationship(to entity: LegalEntity, type: RelationshipType, strength: Double = 1.0) -> EntityRelationship {
        let relationship = EntityRelationship(
            from: self,
            to: entity,
            type: type,
            strength: strength
        )
        relationships.append(relationship)
        return relationship
    }
}

// MARK: - Entity Relationship

@Model
final class EntityRelationship {
    @Attribute(.unique) var id: UUID
    var relationshipType: RelationshipType
    var strength: Double
    var relationshipDescription: String?
    var discoveryDate: Date

    // Relationships
    var fromEntity: LegalEntity
    var toEntity: LegalEntity
    @Relationship var evidenceDocuments: [LegalDocument]

    init(
        id: UUID = UUID(),
        from: LegalEntity,
        to: LegalEntity,
        type: RelationshipType,
        strength: Double = 1.0
    ) {
        self.id = id
        self.fromEntity = from
        self.toEntity = to
        self.relationshipType = type
        self.strength = strength
        self.discoveryDate = Date()
        self.evidenceDocuments = []
    }

    var normalizedStrength: Double {
        max(0.0, min(1.0, strength))
    }
}

// MARK: - Supporting Types

enum EntityType: String, Codable {
    case person = "Person"
    case organization = "Organization"
    case location = "Location"
    case event = "Event"
    case concept = "Concept"
    case date = "Date"
    case money = "Monetary Amount"
    case other = "Other"

    var iconName: String {
        switch self {
        case .person: return "person.fill"
        case .organization: return "building.2.fill"
        case .location: return "mappin.circle.fill"
        case .event: return "calendar"
        case .concept: return "lightbulb.fill"
        case .date: return "calendar.badge.clock"
        case .money: return "dollarsign.circle.fill"
        case .other: return "questionmark.circle.fill"
        }
    }

    var color: String {
        switch self {
        case .person: return "blue"
        case .organization: return "green"
        case .location: return "orange"
        case .event: return "purple"
        case .concept: return "yellow"
        case .date: return "gray"
        case .money: return "green"
        case .other: return "gray"
        }
    }

    var defaultVisualization: EntityVisualization {
        switch self {
        case .person: return .sphere
        case .organization: return .cube
        case .location: return .pyramid
        case .event: return .sphere
        case .concept: return .sphere
        case .date: return .marker
        case .money: return .coin
        case .other: return .sphere
        }
    }
}

enum RelationshipType: String, Codable {
    case communication = "Communication"
    case financial = "Financial Transaction"
    case organizational = "Organizational"
    case familial = "Familial"
    case contractual = "Contractual"
    case adversarial = "Adversarial"
    case collaborative = "Collaborative"
    case supervisory = "Supervisory"
    case ownership = "Ownership"
    case other = "Other"

    var lineStyle: LineStyle {
        switch self {
        case .communication: return .solid
        case .financial: return .dashed
        case .organizational: return .dotted
        case .familial: return .solid
        case .contractual: return .solid
        case .adversarial: return .zigzag
        case .collaborative: return .solid
        case .supervisory: return .arrow
        case .ownership: return .arrow
        case .other: return .dotted
        }
    }

    var color: String {
        switch self {
        case .communication: return "blue"
        case .financial: return "green"
        case .organizational: return "gray"
        case .familial: return "purple"
        case .contractual: return "orange"
        case .adversarial: return "red"
        case .collaborative: return "cyan"
        case .supervisory: return "brown"
        case .ownership: return "yellow"
        case .other: return "gray"
        }
    }
}

enum EntityVisualization: String, Codable {
    case sphere = "Sphere"
    case cube = "Cube"
    case pyramid = "Pyramid"
    case marker = "Marker"
    case coin = "Coin"

    var modelName: String {
        switch self {
        case .sphere: return "EntitySphere"
        case .cube: return "EntityCube"
        case .pyramid: return "EntityPyramid"
        case .marker: return "EntityMarker"
        case .coin: return "EntityCoin"
        }
    }
}

enum LineStyle {
    case solid
    case dashed
    case dotted
    case zigzag
    case arrow
}
