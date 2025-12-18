//
//  Technician.swift
//  FieldServiceAR
//
//  Technician model
//

import Foundation
import SwiftData

@Model
final class Technician {
    @Attribute(.unique) var id: UUID
    var employeeId: String
    var firstName: String
    var lastName: String
    var email: String
    var phone: String?

    // Skills
    var certifications: [String] = []
    var specializations: [EquipmentCategory] = []
    var skillLevel: SkillLevel = .intermediate

    // Status
    var isActive: Bool = true
    var currentJobId: UUID?

    // Metadata
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        employeeId: String,
        firstName: String,
        lastName: String,
        email: String,
        phone: String? = nil
    ) {
        self.id = id
        self.employeeId = employeeId
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phone = phone
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    var fullName: String {
        "\(firstName) \(lastName)"
    }

    var initials: String {
        let first = firstName.prefix(1).uppercased()
        let last = lastName.prefix(1).uppercased()
        return "\(first)\(last)"
    }
}

// Skill Level
enum SkillLevel: String, Codable {
    case junior = "Junior"
    case intermediate = "Intermediate"
    case senior = "Senior"
    case expert = "Expert"
}

// Customer
@Model
final class Customer {
    @Attribute(.unique) var id: UUID
    var name: String
    var contactName: String?
    var contactEmail: String?
    var contactPhone: String?
    var address: String
    var accountNumber: String?

    init(
        id: UUID = UUID(),
        name: String,
        contactName: String? = nil,
        contactEmail: String? = nil,
        contactPhone: String? = nil,
        address: String,
        accountNumber: String? = nil
    ) {
        self.id = id
        self.name = name
        self.contactName = contactName
        self.contactEmail = contactEmail
        self.contactPhone = contactPhone
        self.address = address
        self.accountNumber = accountNumber
    }
}
