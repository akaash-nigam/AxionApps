//
//  BehaviorEvent.swift
//  CultureArchitectureSystem
//
//  Created on 2025-01-20
//  Privacy-preserving behavior tracking
//

import Foundation
import SwiftData

@Model
final class BehaviorEvent {
    @Attribute(.unique) var id: UUID
    var anonymousEmployeeId: UUID
    var teamId: UUID
    var eventType: BehaviorType
    var valueId: UUID
    var timestamp: Date
    var impact: Double
    var isSynced: Bool

    init(
        id: UUID = UUID(),
        anonymousEmployeeId: UUID,
        teamId: UUID,
        eventType: BehaviorType,
        valueId: UUID,
        impact: Double = 1.0,
        isSynced: Bool = false
    ) {
        self.id = id
        self.anonymousEmployeeId = anonymousEmployeeId
        self.teamId = teamId
        self.eventType = eventType
        self.valueId = valueId
        self.timestamp = Date()
        self.impact = impact
        self.isSynced = isSynced
    }
}

// MARK: - Behavior Types
enum BehaviorType: String, Codable {
    case collaboration
    case innovation
    case recognition
    case learning
    case valuesDemonstration = "values_demonstration"
    case ritualParticipation = "ritual_participation"
    case feedback
    case mentoring
    case problemSolving = "problem_solving"
    case customerFocus = "customer_focus"
}

// MARK: - JSON Serialization Helpers
extension BehaviorEvent {
    func toDictionary() -> [String: Any] {
        [
            "id": id.uuidString,
            "anonymous_employee_id": anonymousEmployeeId.uuidString,
            "team_id": teamId.uuidString,
            "event_type": eventType.rawValue,
            "value_id": valueId.uuidString,
            "timestamp": timestamp.timeIntervalSince1970,
            "impact": impact,
            "is_synced": isSynced
        ]
    }
}
