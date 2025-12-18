//
//  ProcedureSession.swift
//  Surgical Training Universe
//
//  Represents a single surgical training session
//

import Foundation
import SwiftData

/// A surgical training session with performance tracking
@Model
final class ProcedureSession {

    // MARK: - Properties

    /// Unique identifier
    @Attribute(.unique) var id: UUID

    /// Type of surgical procedure performed
    var procedureType: ProcedureType

    /// Session start time
    var startTime: Date

    /// Session end time (nil if in progress)
    var endTime: Date?

    /// Total duration in seconds
    var duration: TimeInterval

    /// Session status
    var status: SessionStatus

    // MARK: - Performance Metrics

    /// Accuracy score (0-100)
    var accuracyScore: Double

    /// Efficiency score (0-100)
    var efficiencyScore: Double

    /// Safety score (0-100)
    var safetyScore: Double

    /// Overall score (calculated average)
    var overallScore: Double {
        return (accuracyScore + efficiencyScore + safetyScore) / 3.0
    }

    // MARK: - Detailed Metrics

    /// Number of precise movements
    var preciseMovements: Int

    /// Number of errors made
    var errorCount: Int

    /// Time spent in optimal zone (seconds)
    var optimalZoneTime: TimeInterval

    /// Bleeding incidents
    var bleedingIncidents: Int

    /// Tissue damage incidents
    var tissueDamageCount: Int

    // MARK: - Relationships

    /// Surgeon performing the procedure
    var surgeon: SurgeonProfile

    /// Individual surgical movements recorded
    @Relationship(deleteRule: .cascade)
    var movements: [SurgicalMovement]

    /// AI-generated insights during session
    @Relationship(deleteRule: .cascade)
    var insights: [AIInsight]

    /// Complications encountered
    @Relationship(deleteRule: .cascade)
    var complications: [Complication]

    /// Recording metadata (if session was recorded)
    var recordingMetadata: RecordingMetadata?

    // MARK: - Initialization

    init(
        procedureType: ProcedureType,
        surgeon: SurgeonProfile
    ) {
        self.id = UUID()
        self.procedureType = procedureType
        self.surgeon = surgeon
        self.startTime = Date()
        self.endTime = nil
        self.duration = 0
        self.status = .inProgress
        self.accuracyScore = 0
        self.efficiencyScore = 0
        self.safetyScore = 0
        self.preciseMovements = 0
        self.errorCount = 0
        self.optimalZoneTime = 0
        self.bleedingIncidents = 0
        self.tissueDamageCount = 0
        self.movements = []
        self.insights = []
        self.complications = []
    }

    // MARK: - Methods

    /// Complete the procedure session
    func complete() {
        self.endTime = Date()
        self.duration = endTime!.timeIntervalSince(startTime)
        self.status = .completed
        calculateScores()
    }

    /// Abort the procedure session
    func abort(reason: String) {
        self.endTime = Date()
        self.duration = endTime!.timeIntervalSince(startTime)
        self.status = .aborted
    }

    /// Calculate performance scores based on movements and incidents
    private func calculateScores() {
        // Accuracy: Based on precise movements vs errors
        let totalMovements = movements.count
        if totalMovements > 0 {
            accuracyScore = (Double(preciseMovements) / Double(totalMovements)) * 100.0
        }

        // Efficiency: Based on time in optimal zone and procedure duration
        let expectedDuration = procedureType.expectedDuration
        let efficiencyRatio = min(expectedDuration / duration, 1.0)
        efficiencyScore = efficiencyRatio * 100.0

        // Safety: Based on complications and tissue damage
        let maxIncidents = 10
        let totalIncidents = bleedingIncidents + tissueDamageCount + complications.count
        let safetyRatio = max(1.0 - (Double(totalIncidents) / Double(maxIncidents)), 0.0)
        safetyScore = safetyRatio * 100.0
    }

    /// Add a surgical movement to the session
    func addMovement(_ movement: SurgicalMovement) {
        movements.append(movement)
        if movement.isPrecise {
            preciseMovements += 1
        }
    }

    /// Add an AI insight
    func addInsight(_ insight: AIInsight) {
        insights.append(insight)
    }

    /// Record a complication
    func recordComplication(_ complication: Complication) {
        complications.append(complication)

        // Update incident counts
        switch complication.type {
        case .bleeding:
            bleedingIncidents += 1
        case .tissueDamage:
            tissueDamageCount += 1
        default:
            errorCount += 1
        }
    }
}

// MARK: - Supporting Types

/// Procedure types available in the training system
enum ProcedureType: String, Codable, CaseIterable {
    // General Surgery
    case appendectomy = "Appendectomy"
    case cholecystectomy = "Cholecystectomy"
    case herniRepair = "Hernia Repair"

    // Cardiac Surgery
    case cabg = "CABG (Coronary Artery Bypass)"
    case valveReplacement = "Valve Replacement"
    case pericardialWindow = "Pericardial Window"

    // Neurosurgery
    case craniotomy = "Craniotomy"
    case spinalFusion = "Spinal Fusion"
    case ventriculostomy = "Ventriculostomy"

    // Orthopedics
    case hipReplacement = "Hip Replacement"
    case kneeReplacement = "Knee Replacement"
    case fractureRepair = "Fracture Repair"

    // Minimally Invasive
    case laparoscopicSurgery = "Laparoscopic Surgery"
    case endoscopy = "Endoscopy"

    // Trauma
    case traumaLaparotomy = "Trauma Laparotomy"
    case chestTube = "Chest Tube Insertion"

    /// Expected duration for this procedure (in seconds)
    var expectedDuration: TimeInterval {
        switch self {
        case .appendectomy: return 2700 // 45 minutes
        case .cholecystectomy: return 3600 // 60 minutes
        case .herniRepair: return 1800 // 30 minutes
        case .cabg: return 14400 // 4 hours
        case .valveReplacement: return 10800 // 3 hours
        case .craniotomy: return 7200 // 2 hours
        case .hipReplacement: return 5400 // 90 minutes
        case .laparoscopicSurgery: return 2700 // 45 minutes
        default: return 3600 // Default 1 hour
        }
    }

    /// Difficulty level (1-5)
    var difficultyLevel: Int {
        switch self {
        case .chestTube, .herniRepair: return 1
        case .appendectomy, .cholecystectomy: return 2
        case .laparoscopicSurgery, .fractureRepair: return 3
        case .craniotomy, .hipReplacement: return 4
        case .cabg, .valveReplacement: return 5
        default: return 3
        }
    }
}

/// Session status
enum SessionStatus: String, Codable {
    case inProgress = "In Progress"
    case completed = "Completed"
    case aborted = "Aborted"
    case paused = "Paused"
}

/// Recording metadata for session playback
struct RecordingMetadata: Codable {
    let recordingURL: URL
    let duration: TimeInterval
    let fileSize: Int64
    let createdAt: Date
}
