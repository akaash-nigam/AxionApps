//
//  Employee.swift
//  CultureArchitectureSystem
//
//  Created on 2025-01-20
//  Privacy-preserving employee model (NO PII)
//

import Foundation
import SwiftData

@Model
final class Employee {
    @Attribute(.unique) var anonymousId: UUID
    var teamId: UUID
    var departmentId: UUID
    var role: String
    var tenureMonths: Int
    var engagementScore: Double
    var culturalContributions: Int
    var lastActiveDate: Date

    // Privacy: NO personal identifiable information
    // All data aggregated at team level (minimum 5 people)

    init(
        anonymousId: UUID = UUID(),
        teamId: UUID,
        departmentId: UUID,
        role: String,
        tenureMonths: Int = 0,
        engagementScore: Double = 0.0,
        culturalContributions: Int = 0
    ) {
        self.anonymousId = anonymousId
        self.teamId = teamId
        self.departmentId = departmentId
        self.role = role
        self.tenureMonths = tenureMonths
        self.engagementScore = engagementScore
        self.culturalContributions = culturalContributions
        self.lastActiveDate = Date()
    }
}

// MARK: - JSON Serialization Helpers
extension Employee {
    func toDictionary() -> [String: Any] {
        [
            "anonymous_id": anonymousId.uuidString,
            "team_id": teamId.uuidString,
            "department_id": departmentId.uuidString,
            "role": role,
            "tenure_months": tenureMonths,
            "engagement_score": engagementScore,
            "cultural_contributions": culturalContributions,
            "last_active_date": lastActiveDate.timeIntervalSince1970
        ]
    }
}

// MARK: - Role Generalization (Privacy)
extension Employee {
    enum GeneralizedRole: String {
        case leadership
        case engineering
        case product
        case design
        case sales
        case marketing
        case operations
        case support
        case general

        static func generalize(_ specificRole: String) -> GeneralizedRole {
            let lowercased = specificRole.lowercased()

            if lowercased.contains("vp") || lowercased.contains("director") || lowercased.contains("exec") {
                return .leadership
            } else if lowercased.contains("engineer") || lowercased.contains("developer") {
                return .engineering
            } else if lowercased.contains("product") {
                return .product
            } else if lowercased.contains("design") {
                return .design
            } else if lowercased.contains("sales") || lowercased.contains("account") {
                return .sales
            } else if lowercased.contains("marketing") {
                return .marketing
            } else if lowercased.contains("operations") || lowercased.contains("ops") {
                return .operations
            } else if lowercased.contains("support") || lowercased.contains("customer") {
                return .support
            } else {
                return .general
            }
        }
    }

    var generalizedRole: GeneralizedRole {
        GeneralizedRole.generalize(role)
    }
}
