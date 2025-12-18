//
//  SurgicalMovement.swift
//  Surgical Training Universe
//
//  Represents a single surgical movement or action
//

import Foundation
import SwiftData

/// Represents a surgical movement performed during a procedure
@Model
final class SurgicalMovement {

    // MARK: - Properties

    /// Unique identifier
    @Attribute(.unique) var id: UUID

    /// Timestamp of the movement
    var timestamp: Date

    /// Type of movement
    var movementType: MovementType

    /// Instrument used
    var instrumentType: InstrumentType

    /// Start position (x, y, z in meters)
    var startPosition: Position3D

    /// End position (x, y, z in meters)
    var endPosition: Position3D

    /// Duration of movement (seconds)
    var duration: TimeInterval

    /// Force applied (0-1 normalized)
    var forceApplied: Double

    /// Velocity (meters/second)
    var velocity: Double

    /// Precision score (0-1)
    var precisionScore: Double

    /// Whether movement was precise (score > 0.8)
    var isPrecise: Bool {
        return precisionScore > 0.8
    }

    /// Affected anatomical region
    var affectedRegion: AnatomicalRegion

    // MARK: - Relationships

    /// Associated procedure session
    var session: ProcedureSession?

    // MARK: - Initialization

    init(
        movementType: MovementType,
        instrumentType: InstrumentType,
        startPosition: Position3D,
        endPosition: Position3D,
        forceApplied: Double,
        affectedRegion: AnatomicalRegion
    ) {
        self.id = UUID()
        self.timestamp = Date()
        self.movementType = movementType
        self.instrumentType = instrumentType
        self.startPosition = startPosition
        self.endPosition = endPosition
        self.forceApplied = forceApplied
        self.affectedRegion = affectedRegion

        // Calculate derived properties
        let distance = startPosition.distance(to: endPosition)
        self.duration = 0.5 // Will be updated in real-time
        self.velocity = distance / max(duration, 0.01)

        // Calculate precision based on movement smoothness
        self.precisionScore = calculatePrecision()
    }

    // MARK: - Methods

    /// Calculate precision score based on movement characteristics
    private func calculatePrecision() -> Double {
        // Factors: steady velocity, appropriate force, smooth trajectory
        var score = 1.0

        // Penalize excessive force
        if forceApplied > 0.8 {
            score -= (forceApplied - 0.8) * 0.5
        }

        // Penalize excessive velocity for delicate movements
        if movementType.requiresPrecision && velocity > 0.1 {
            score -= (velocity - 0.1) * 2.0
        }

        return max(0.0, min(1.0, score))
    }

    /// Update duration when movement completes
    func updateDuration(_ duration: TimeInterval) {
        self.duration = duration
        self.velocity = startPosition.distance(to: endPosition) / max(duration, 0.01)
        self.precisionScore = calculatePrecision()
    }
}

// MARK: - Supporting Types

/// Types of surgical movements
enum MovementType: String, Codable {
    case incision = "Incision"
    case dissection = "Dissection"
    case grasping = "Grasping"
    case cutting = "Cutting"
    case suturing = "Suturing"
    case cauterizing = "Cauterizing"
    case retracting = "Retracting"
    case irrigating = "Irrigating"
    case probing = "Probing"
    case measuring = "Measuring"

    /// Whether this movement requires high precision
    var requiresPrecision: Bool {
        switch self {
        case .incision, .cutting, .suturing: return true
        default: return false
        }
    }
}

/// Surgical instrument types
enum InstrumentType: String, Codable, CaseIterable {
    case scalpel = "Scalpel"
    case forceps = "Forceps"
    case scissors = "Scissors"
    case retractor = "Retractor"
    case suture = "Suture Needle"
    case cautery = "Cautery"
    case clamp = "Clamp"
    case sponge = "Sponge"
    case drain = "Drain"
    case trocar = "Trocar"
    case laparoscope = "Laparoscope"
    case drill = "Surgical Drill"
    case saw = "Surgical Saw"

    /// 3D model filename
    var modelFileName: String {
        return "\(rawValue.lowercased().replacingOccurrences(of: " ", with: "_")).usdz"
    }

    /// Icon name for UI
    var iconName: String {
        return "icon_\(rawValue.lowercased().replacingOccurrences(of: " ", with: "_"))"
    }
}

/// Anatomical regions
enum AnatomicalRegion: String, Codable {
    case head = "Head"
    case neck = "Neck"
    case chest = "Chest"
    case abdomen = "Abdomen"
    case pelvis = "Pelvis"
    case upperExtremity = "Upper Extremity"
    case lowerExtremity = "Lower Extremity"
    case spine = "Spine"
    case heart = "Heart"
    case brain = "Brain"
    case liver = "Liver"
    case kidney = "Kidney"
    case other = "Other"
}

/// 3D position in space
struct Position3D: Codable {
    let x: Double
    let y: Double
    let z: Double

    /// Calculate distance to another position
    func distance(to other: Position3D) -> Double {
        let dx = x - other.x
        let dy = y - other.y
        let dz = z - other.z
        return sqrt(dx*dx + dy*dy + dz*dz)
    }

    /// Zero position
    static let zero = Position3D(x: 0, y: 0, z: 0)
}
