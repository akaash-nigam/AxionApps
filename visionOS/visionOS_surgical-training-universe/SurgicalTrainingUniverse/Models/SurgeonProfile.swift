//
//  SurgeonProfile.swift
//  Surgical Training Universe
//
//  Surgeon user profile data model
//

import Foundation
import SwiftData

/// Represents a surgeon's profile and training information
@Model
final class SurgeonProfile {

    // MARK: - Properties

    /// Unique identifier
    @Attribute(.unique) var id: UUID

    /// Surgeon's full name
    var name: String

    /// Email address
    var email: String

    /// Surgical specialization
    var specialization: SurgicalSpecialty

    /// Training level (resident, fellow, attending)
    var level: TrainingLevel

    /// Institution/hospital affiliation
    var institution: String

    /// Profile creation date
    var createdAt: Date

    /// Last active date
    var lastActiveAt: Date

    // MARK: - Statistics

    /// Total procedures completed
    var totalProcedures: Int

    /// Average accuracy score
    var averageAccuracy: Double

    /// Average efficiency score
    var averageEfficiency: Double

    /// Average safety score
    var averageSafety: Double

    // MARK: - Relationships

    /// All procedure sessions performed by this surgeon
    @Relationship(deleteRule: .cascade)
    var sessions: [ProcedureSession]

    /// Earned certifications
    @Relationship(deleteRule: .cascade)
    var certifications: [Certification]

    /// Earned achievements
    @Relationship(deleteRule: .cascade)
    var achievements: [Achievement]

    // MARK: - Initialization

    init(
        name: String,
        email: String,
        specialization: SurgicalSpecialty = .generalSurgery,
        level: TrainingLevel = .resident1,
        institution: String = ""
    ) {
        self.id = UUID()
        self.name = name
        self.email = email
        self.specialization = specialization
        self.level = level
        self.institution = institution
        self.createdAt = Date()
        self.lastActiveAt = Date()
        self.totalProcedures = 0
        self.averageAccuracy = 0.0
        self.averageEfficiency = 0.0
        self.averageSafety = 0.0
        self.sessions = []
        self.certifications = []
        self.achievements = []
    }

    // MARK: - Methods

    /// Update statistics after completing a session
    func updateStatistics(from session: ProcedureSession) {
        totalProcedures += 1

        // Recalculate rolling averages
        let weight = 1.0 / Double(totalProcedures)
        averageAccuracy = (averageAccuracy * (1 - weight)) + (session.accuracyScore * weight)
        averageEfficiency = (averageEfficiency * (1 - weight)) + (session.efficiencyScore * weight)
        averageSafety = (averageSafety * (1 - weight)) + (session.safetyScore * weight)

        lastActiveAt = Date()
    }

    /// Calculate overall performance score (0-100)
    var overallScore: Double {
        return (averageAccuracy + averageEfficiency + averageSafety) / 3.0
    }
}

// MARK: - Supporting Types

/// Surgical specialization categories
enum SurgicalSpecialty: String, Codable {
    case generalSurgery = "General Surgery"
    case cardiacSurgery = "Cardiac Surgery"
    case neurosurgery = "Neurosurgery"
    case orthopedics = "Orthopedics"
    case traumaSurgery = "Trauma Surgery"
    case roboticSurgery = "Robotic Surgery"
    case vascularSurgery = "Vascular Surgery"
    case pediatricSurgery = "Pediatric Surgery"
}

/// Training level progression
enum TrainingLevel: String, Codable, CaseIterable {
    case medicalStudent = "Medical Student"
    case resident1 = "Resident Year 1"
    case resident2 = "Resident Year 2"
    case resident3 = "Resident Year 3"
    case chiefResident = "Chief Resident"
    case fellow = "Fellow"
    case attending = "Attending Surgeon"

    /// Experience level as integer (0-6)
    var experienceLevel: Int {
        switch self {
        case .medicalStudent: return 0
        case .resident1: return 1
        case .resident2: return 2
        case .resident3: return 3
        case .chiefResident: return 4
        case .fellow: return 5
        case .attending: return 6
        }
    }
}
