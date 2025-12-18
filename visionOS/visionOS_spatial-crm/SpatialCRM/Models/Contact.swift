//
//  Contact.swift
//  SpatialCRM
//
//  Contact data model
//

import Foundation
import SwiftData

@Model
final class Contact {
    // MARK: - Properties

    @Attribute(.unique) var id: UUID
    var firstName: String
    var lastName: String
    var email: String
    var phone: String?
    var title: String
    var role: ContactRole
    var influenceScore: Double
    var isDecisionMaker: Bool
    var isPrimaryContact: Bool

    // Social/Communication
    var linkedInUrl: String?
    var twitterHandle: String?

    // Spatial Properties
    var orbitRadius: Float
    var orbitSpeed: Float
    var orbitAngle: Float

    // Relationships
    var account: Account?
    @Relationship(deleteRule: .cascade) var activities: [Activity]
    @Relationship(deleteRule: .nullify) var relationships: [ContactRelationship]

    // Metadata
    var createdAt: Date
    var updatedAt: Date
    var lastContactedAt: Date?
    var externalId: String?

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        firstName: String,
        lastName: String,
        email: String,
        phone: String? = nil,
        title: String,
        role: ContactRole = .user,
        influenceScore: Double = 50.0,
        isDecisionMaker: Bool = false,
        isPrimaryContact: Bool = false
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phone = phone
        self.title = title
        self.role = role
        self.influenceScore = influenceScore
        self.isDecisionMaker = isDecisionMaker
        self.isPrimaryContact = isPrimaryContact

        // Initialize spatial properties
        self.orbitRadius = Float.random(in: 0.3...0.8)
        self.orbitSpeed = Float.random(in: 0.5...2.0)
        self.orbitAngle = Float.random(in: 0...360)

        // Initialize relationships
        self.activities = []
        self.relationships = []

        // Set timestamps
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // MARK: - Computed Properties

    var fullName: String {
        "\(firstName) \(lastName)"
    }

    var initials: String {
        let first = firstName.prefix(1)
        let last = lastName.prefix(1)
        return "\(first)\(last)".uppercased()
    }
}

// MARK: - Supporting Types

enum ContactRole: String, Codable {
    case champion
    case influencer
    case decisionMaker
    case user
    case blocker
    case unknown
}

@Model
final class ContactRelationship {
    @Attribute(.unique) var id: UUID
    var fromContact: Contact?
    var toContact: Contact?
    var relationshipType: String
    var strength: Double
    var createdAt: Date

    init(from: Contact, to: Contact, type: String, strength: Double = 50.0) {
        self.id = UUID()
        self.fromContact = from
        self.toContact = to
        self.relationshipType = type
        self.strength = strength
        self.createdAt = Date()
    }
}

// MARK: - Sample Data

extension Contact {
    static var sample: Contact {
        Contact(
            firstName: "John",
            lastName: "Smith",
            email: "john.smith@acme.com",
            phone: "+1-555-0199",
            title: "CEO",
            role: .champion,
            influenceScore: 95,
            isDecisionMaker: true,
            isPrimaryContact: true
        )
    }

    static var samples: [Contact] {
        [
            Contact(firstName: "John", lastName: "Smith", email: "john@acme.com", title: "CEO", role: .champion, influenceScore: 95, isDecisionMaker: true, isPrimaryContact: true),
            Contact(firstName: "Sarah", lastName: "Johnson", email: "sarah@acme.com", title: "CTO", role: .influencer, influenceScore: 85, isDecisionMaker: true),
            Contact(firstName: "Mike", lastName: "Chen", email: "mike@acme.com", title: "VP Engineering", role: .user, influenceScore: 70),
            Contact(firstName: "Emily", lastName: "Davis", email: "emily@acme.com", title: "Product Manager", role: .user, influenceScore: 60)
        ]
    }
}
