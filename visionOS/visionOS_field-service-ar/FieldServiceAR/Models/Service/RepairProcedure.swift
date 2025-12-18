//
//  RepairProcedure.swift
//  FieldServiceAR
//
//  Repair procedure model
//

import Foundation
import SwiftData

@Model
final class RepairProcedure {
    @Attribute(.unique) var id: UUID
    var title: String
    var procedureDescription: String?
    var estimatedTime: TimeInterval
    var difficulty: DifficultyLevel = .medium

    // Steps
    @Relationship(deleteRule: .cascade)
    var steps: [ProcedureStep] = []

    // Requirements
    var requiredTools: [String] = []
    var safetyWarnings: [String] = []

    // Equipment reference
    var equipmentId: UUID?

    // Metadata
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        procedureDescription: String? = nil,
        estimatedTime: TimeInterval,
        difficulty: DifficultyLevel = .medium,
        equipmentId: UUID? = nil
    ) {
        self.id = id
        self.title = title
        self.procedureDescription = procedureDescription
        self.estimatedTime = estimatedTime
        self.difficulty = difficulty
        self.equipmentId = equipmentId
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    var completedStepsCount: Int {
        steps.filter { $0.status == .completed }.count
    }

    var progressPercentage: Double {
        guard !steps.isEmpty else { return 0 }
        return Double(completedStepsCount) / Double(steps.count) * 100
    }
}

// Procedure Step
@Model
final class ProcedureStep {
    @Attribute(.unique) var id: UUID
    var sequenceNumber: Int
    var instruction: String
    var detailedInstructions: String?
    var estimatedDuration: TimeInterval

    // Status
    var status: StepStatus = .pending

    // Spatial positioning
    var anchorTransformData: Data?

    // Visual overlay configuration
    var overlayType: OverlayType = .highlight
    var targetComponentId: UUID?

    // Requirements
    var requiredTools: [String] = []
    var safetyChecks: [String] = []

    // Completion
    var completedAt: Date?
    var completedBy: UUID?

    init(
        id: UUID = UUID(),
        sequenceNumber: Int,
        instruction: String,
        detailedInstructions: String? = nil,
        estimatedDuration: TimeInterval,
        overlayType: OverlayType = .highlight
    ) {
        self.id = id
        self.sequenceNumber = sequenceNumber
        self.instruction = instruction
        self.detailedInstructions = detailedInstructions
        self.estimatedDuration = estimatedDuration
        self.overlayType = overlayType
    }

    func complete(by technicianId: UUID) {
        status = .completed
        completedAt = Date()
        completedBy = technicianId
    }

    func reset() {
        status = .pending
        completedAt = nil
        completedBy = nil
    }
}

// Step Status
enum StepStatus: String, Codable {
    case pending = "Pending"
    case inProgress = "In Progress"
    case completed = "Completed"
    case skipped = "Skipped"
}

// Difficulty Level
enum DifficultyLevel: String, Codable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    case expert = "Expert"

    var color: String {
        switch self {
        case .easy: return "#34C759"
        case .medium: return "#FFD700"
        case .hard: return "#FF9500"
        case .expert: return "#FF3B30"
        }
    }
}

// Overlay Type
enum OverlayType: String, Codable {
    case arrow = "Arrow"
    case highlight = "Highlight"
    case callout = "Callout"
    case warning = "Warning"
    case measurement = "Measurement"
}
