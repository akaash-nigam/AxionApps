//
//  SupportingModels.swift
//  Surgical Training Universe
//
//  Additional supporting data models
//

import Foundation
import SwiftData

// MARK: - AI Insight

/// AI-generated insight during a procedure
@Model
final class AIInsight {
    @Attribute(.unique) var id: UUID
    var timestamp: Date
    var category: InsightCategory
    var severity: SeverityLevel
    var message: String
    var suggestedAction: String?
    var affectedArea: AnatomicalRegion?
    var session: ProcedureSession?

    init(
        category: InsightCategory,
        severity: SeverityLevel,
        message: String,
        suggestedAction: String? = nil,
        affectedArea: AnatomicalRegion? = nil
    ) {
        self.id = UUID()
        self.timestamp = Date()
        self.category = category
        self.severity = severity
        self.message = message
        self.suggestedAction = suggestedAction
        self.affectedArea = affectedArea
    }
}

enum InsightCategory: String, Codable {
    case technique = "Technique"
    case safety = "Safety"
    case efficiency = "Efficiency"
    case accuracy = "Accuracy"
    case suggestion = "Suggestion"
    case warning = "Warning"
    case achievement = "Achievement"
}

enum SeverityLevel: String, Codable {
    case info = "Info"
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case critical = "Critical"

    var color: String {
        switch self {
        case .info: return "blue"
        case .low: return "green"
        case .medium: return "yellow"
        case .high: return "orange"
        case .critical: return "red"
        }
    }
}

// MARK: - Complication

/// Surgical complication encountered during procedure
@Model
final class Complication {
    @Attribute(.unique) var id: UUID
    var timestamp: Date
    var type: ComplicationType
    var severity: SeverityLevel
    var description: String
    var resolved: Bool
    var resolutionTime: TimeInterval?
    var session: ProcedureSession?

    init(
        type: ComplicationType,
        severity: SeverityLevel,
        description: String
    ) {
        self.id = UUID()
        self.timestamp = Date()
        self.type = type
        self.severity = severity
        self.description = description
        self.resolved = false
    }

    func resolve(after duration: TimeInterval) {
        self.resolved = true
        self.resolutionTime = duration
    }
}

enum ComplicationType: String, Codable {
    case bleeding = "Bleeding"
    case tissueDamage = "Tissue Damage"
    case nerveDamage = "Nerve Damage"
    case vesselInjury = "Vessel Injury"
    case organPerforation = "Organ Perforation"
    case infection = "Infection"
    case incorrectProcedure = "Incorrect Procedure"
    case instrumentFailure = "Instrument Failure"
    case other = "Other"
}

// MARK: - Anatomical Model

/// 3D anatomical model used in training
@Model
final class AnatomicalModel {
    @Attribute(.unique) var id: UUID
    var name: String
    var type: AnatomyType
    var pathology: PathologyType?
    var variation: AnatomicalVariation
    var complexity: ComplexityLevel
    var modelURL: URL
    var textureURLs: [URL]
    var thumbnailURL: URL?
    var polygonCount: Int
    var fileSize: Int64

    init(
        name: String,
        type: AnatomyType,
        modelURL: URL,
        complexity: ComplexityLevel = .medium
    ) {
        self.id = UUID()
        self.name = name
        self.type = type
        self.modelURL = modelURL
        self.complexity = complexity
        self.textureURLs = []
        self.polygonCount = 50000
        self.fileSize = 0
        self.variation = .standard
    }
}

enum AnatomyType: String, Codable, CaseIterable {
    case heart = "Heart"
    case brain = "Brain"
    case liver = "Liver"
    case kidney = "Kidney"
    case lung = "Lung"
    case stomach = "Stomach"
    case intestines = "Intestines"
    case appendix = "Appendix"
    case gallbladder = "Gallbladder"
    case spine = "Spine"
    case knee = "Knee"
    case hip = "Hip"
    case fullBody = "Full Body"
}

enum PathologyType: String, Codable {
    case none = "None"
    case tumor = "Tumor"
    case inflammation = "Inflammation"
    case infection = "Infection"
    case trauma = "Trauma"
    case degenerative = "Degenerative"
    case congenital = "Congenital"
}

enum AnatomicalVariation: String, Codable {
    case standard = "Standard"
    case pediatric = "Pediatric"
    case elderly = "Elderly"
    case obese = "Obese"
    case unusual = "Unusual Anatomy"
}

enum ComplexityLevel: String, Codable {
    case basic = "Basic"
    case medium = "Medium"
    case advanced = "Advanced"
    case expert = "Expert"

    var polygonBudget: Int {
        switch self {
        case .basic: return 20000
        case .medium: return 50000
        case .advanced: return 100000
        case .expert: return 200000
        }
    }
}

// MARK: - Certification

/// Surgical certification earned by surgeon
@Model
final class Certification {
    @Attribute(.unique) var id: UUID
    var name: String
    var procedureType: ProcedureType
    var earnedDate: Date
    var expiryDate: Date?
    var score: Double
    var requirements: [String]
    var surgeon: SurgeonProfile?

    init(
        name: String,
        procedureType: ProcedureType,
        score: Double,
        requirements: [String] = []
    ) {
        self.id = UUID()
        self.name = name
        self.procedureType = procedureType
        self.earnedDate = Date()
        self.score = score
        self.requirements = requirements
        // Certifications valid for 2 years
        self.expiryDate = Calendar.current.date(byAdding: .year, value: 2, to: Date())
    }

    var isValid: Bool {
        guard let expiry = expiryDate else { return true }
        return Date() < expiry
    }
}

// MARK: - Achievement

/// Gamification achievement
@Model
final class Achievement {
    @Attribute(.unique) var id: UUID
    var title: String
    var description: String
    var iconName: String
    var unlockedDate: Date
    var category: AchievementCategory
    var points: Int
    var surgeon: SurgeonProfile?

    init(
        title: String,
        description: String,
        iconName: String,
        category: AchievementCategory,
        points: Int = 100
    ) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.iconName = iconName
        self.category = category
        self.points = points
        self.unlockedDate = Date()
    }
}

enum AchievementCategory: String, Codable {
    case milestone = "Milestone"
    case mastery = "Mastery"
    case speed = "Speed"
    case precision = "Precision"
    case safety = "Safety"
    case streak = "Streak"
}

// MARK: - Collaboration Session

/// Multi-user collaboration session
@Model
final class CollaborationSession {
    @Attribute(.unique) var id: UUID
    var startTime: Date
    var endTime: Date?
    var participants: [String] // Surgeon IDs
    var leadSurgeonID: String
    var procedureType: ProcedureType
    var isActive: Bool

    init(
        leadSurgeonID: String,
        procedureType: ProcedureType
    ) {
        self.id = UUID()
        self.startTime = Date()
        self.leadSurgeonID = leadSurgeonID
        self.procedureType = procedureType
        self.participants = [leadSurgeonID]
        self.isActive = true
    }

    func addParticipant(_ surgeonID: String) {
        if !participants.contains(surgeonID) {
            participants.append(surgeonID)
        }
    }

    func end() {
        self.endTime = Date()
        self.isActive = false
    }
}

// MARK: - Surgical Instrument (Codable struct for non-persisted data)

/// Surgical instrument definition
struct SurgicalInstrument: Codable, Identifiable {
    let id: UUID
    let name: String
    let type: InstrumentType
    let modelURL: URL
    let interactionMode: InteractionMode
    let hapticProfile: HapticProfile

    init(
        name: String,
        type: InstrumentType,
        modelURL: URL
    ) {
        self.id = UUID()
        self.name = name
        self.type = type
        self.modelURL = modelURL
        self.interactionMode = .direct
        self.hapticProfile = .medium
    }
}

enum InteractionMode: String, Codable {
    case direct = "Direct Manipulation"
    case indirect = "Indirect Control"
    case assisted = "AI Assisted"
}

enum HapticProfile: String, Codable {
    case light = "Light"
    case medium = "Medium"
    case strong = "Strong"
    case custom = "Custom"
}
