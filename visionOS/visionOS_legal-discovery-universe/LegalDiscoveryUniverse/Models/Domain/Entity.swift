//
//  Entity.swift
//  Legal Discovery Universe
//
//  Created by Claude Code
//  Copyright © 2024 Legal Discovery Universe. All rights reserved.
//

import Foundation
import SwiftData

@Model
final class Entity {
    @Attribute(.unique) var id: UUID
    var name: String
    var type: EntityType
    var aliases: [String] = []

    // Details
    var email: String?
    var phone: String?
    var address: String?
    var organization: String?
    var title: String?

    // Relationships
    @Relationship(inverse: \LegalCase.entities) var legalCase: LegalCase?
    @Relationship var documents: [Document] = []
    @Relationship(deleteRule: .cascade) var connections: [EntityConnection] = []

    // AI Insights
    var importance: Double = 0.5
    var sentiment: Double = 0.0
    var role: String?
    var documentCount: Int = 0

    // Metadata
    var metadata: [String: String] = [:]
    var notes: String?

    init(
        id: UUID = UUID(),
        name: String,
        type: EntityType
    ) {
        self.id = id
        self.name = name
        self.type = type
    }
}

enum EntityType: String, Codable {
    case person
    case organization
    case location
    case event
    case product
    case concept
    case other
}

@Model
final class EntityConnection {
    @Attribute(.unique) var id: UUID
    var sourceEntityId: UUID
    var targetEntityId: UUID
    var connectionType: ConnectionType
    var strength: Double = 0.5
    var description: String?

    // Supporting data
    var documentIds: [UUID] = []
    var firstObservedDate: Date?
    var lastObservedDate: Date?
    var frequency: Int = 0

    @Relationship(inverse: \Entity.connections) var entity: Entity?

    init(
        id: UUID = UUID(),
        sourceEntityId: UUID,
        targetEntityId: UUID,
        connectionType: ConnectionType,
        strength: Double = 0.5
    ) {
        self.id = id
        self.sourceEntityId = sourceEntityId
        self.targetEntityId = targetEntityId
        self.connectionType = connectionType
        self.strength = strength
    }
}

enum ConnectionType: String, Codable {
    case email
    case meeting
    case contract
    case mention
    case collaboration
    case reporting
    case familial
    case business
    case other
}
