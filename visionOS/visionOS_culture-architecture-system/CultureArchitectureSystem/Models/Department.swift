//
//  Department.swift
//  CultureArchitectureSystem
//
//  Created on 2025-01-20
//

import Foundation
import SwiftData

@Model
final class Department {
    @Attribute(.unique) var id: UUID
    var name: String
    var teamCount: Int
    var employeeCount: Int
    var healthScore: Double

    init(
        id: UUID = UUID(),
        name: String,
        teamCount: Int = 0,
        employeeCount: Int = 0,
        healthScore: Double = 0.0
    ) {
        self.id = id
        self.name = name
        self.teamCount = teamCount
        self.employeeCount = employeeCount
        self.healthScore = healthScore
    }
}

// MARK: - JSON Serialization Helpers
extension Department {
    func toDictionary() -> [String: Any] {
        [
            "id": id.uuidString,
            "name": name,
            "team_count": teamCount,
            "employee_count": employeeCount,
            "health_score": healthScore
        ]
    }
}
