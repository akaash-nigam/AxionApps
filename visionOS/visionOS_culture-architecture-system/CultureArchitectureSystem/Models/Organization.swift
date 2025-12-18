//
//  Organization.swift
//  CultureArchitectureSystem
//
//  Created on 2025-01-20
//

import Foundation
import SwiftData

@Model
final class Organization {
    @Attribute(.unique) var id: UUID
    var name: String
    var culturalValues: [CulturalValue]
    var departments: [Department]
    var cultureHealthScore: Double
    var createdAt: Date
    var updatedAt: Date

    // Relationships
    var culturalLandscape: CulturalLandscape?
    var employees: [Employee]

    init(
        id: UUID = UUID(),
        name: String,
        culturalValues: [CulturalValue] = [],
        departments: [Department] = [],
        employees: [Employee] = [],
        cultureHealthScore: Double = 0.0
    ) {
        self.id = id
        self.name = name
        self.culturalValues = culturalValues
        self.departments = departments
        self.employees = employees
        self.cultureHealthScore = cultureHealthScore
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    func update(from remote: Organization) {
        self.name = remote.name
        self.culturalValues = remote.culturalValues
        self.departments = remote.departments
        self.cultureHealthScore = remote.cultureHealthScore
        self.updatedAt = Date()
    }
}

// MARK: - JSON Serialization Helpers
extension Organization {
    func toDictionary() -> [String: Any] {
        [
            "id": id.uuidString,
            "name": name,
            "cultural_values": culturalValues.map { $0.toDictionary() },
            "departments": departments.map { $0.toDictionary() },
            "culture_health_score": cultureHealthScore,
            "created_at": createdAt.timeIntervalSince1970,
            "updated_at": updatedAt.timeIntervalSince1970
        ]
    }
}

// MARK: - Sample data generator
extension Organization {
    static func mock() -> Organization {
        let org = Organization(name: "TechForward Inc")

        let innovation = CulturalValue(
            name: "Innovation",
            valueDescription: "Continuous improvement and creative thinking"
        )
        let collaboration = CulturalValue(
            name: "Collaboration",
            valueDescription: "Working together towards common goals"
        )
        let trust = CulturalValue(
            name: "Trust",
            valueDescription: "Building and maintaining trust"
        )

        org.culturalValues = [innovation, collaboration, trust]
        org.cultureHealthScore = 85.0

        return org
    }
}
