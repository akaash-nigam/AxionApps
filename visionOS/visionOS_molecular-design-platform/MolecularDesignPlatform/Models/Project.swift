//
//  Project.swift
//  Molecular Design Platform
//
//  Project organization and collaboration models
//

import Foundation
import SwiftData

// MARK: - Project Model

@Model
class Project {
    @Attribute(.unique) var id: UUID
    var name: String
    var projectDescription: String
    var createdDate: Date
    var modifiedDate: Date

    // Project organization
    @Relationship(deleteRule: .cascade)
    var molecules: [Molecule]

    @Relationship(deleteRule: .cascade)
    var experiments: [Experiment]

    // Collaboration
    var owner: Researcher
    var collaborators: [Researcher]
    var permissions: ProjectPermissions

    // Progress tracking
    var milestones: [Milestone]
    var currentPhase: ResearchPhase

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        name: String,
        description: String = "",
        owner: Researcher
    ) {
        self.id = id
        self.name = name
        self.projectDescription = description
        self.createdDate = Date()
        self.modifiedDate = Date()
        self.molecules = []
        self.experiments = []
        self.owner = owner
        self.collaborators = []
        self.permissions = ProjectPermissions()
        self.milestones = []
        self.currentPhase = .discovery
    }
}

// MARK: - Researcher

struct Researcher: Codable, Identifiable, Equatable {
    let id: UUID
    let name: String
    let email: String
    var role: Role

    enum Role: String, Codable {
        case owner
        case editor
        case viewer

        var canEdit: Bool {
            self == .owner || self == .editor
        }

        var canDelete: Bool {
            self == .owner
        }
    }

    init(id: UUID = UUID(), name: String, email: String, role: Role = .viewer) {
        self.id = id
        self.name = name
        self.email = email
        self.role = role
    }

    static func == (lhs: Researcher, rhs: Researcher) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Project Permissions

struct ProjectPermissions: Codable {
    var isPublic: Bool
    var allowComments: Bool
    var allowExport: Bool

    init(isPublic: Bool = false, allowComments: Bool = true, allowExport: Bool = true) {
        self.isPublic = isPublic
        self.allowComments = allowComments
        self.allowExport = allowExport
    }
}

// MARK: - Research Phase

enum ResearchPhase: String, Codable {
    case discovery
    case leadOptimization
    case preclinical
    case clinical
    case approved

    var displayName: String {
        switch self {
        case .discovery: return "Discovery"
        case .leadOptimization: return "Lead Optimization"
        case .preclinical: return "Preclinical"
        case .clinical: return "Clinical"
        case .approved: return "Approved"
        }
    }

    var progress: Double {
        switch self {
        case .discovery: return 0.2
        case .leadOptimization: return 0.4
        case .preclinical: return 0.6
        case .clinical: return 0.8
        case .approved: return 1.0
        }
    }
}

// MARK: - Milestone

struct Milestone: Codable, Identifiable {
    let id: UUID
    var title: String
    var description: String
    var targetDate: Date
    var isCompleted: Bool
    var completedDate: Date?

    init(
        id: UUID = UUID(),
        title: String,
        description: String = "",
        targetDate: Date,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.targetDate = targetDate
        self.isCompleted = isCompleted
    }
}

// MARK: - Experiment

@Model
class Experiment {
    @Attribute(.unique) var id: UUID
    var name: String
    var experimentDescription: String
    var experimentType: ExperimentType
    var status: ExperimentStatus
    var createdDate: Date
    var completedDate: Date?

    // Results
    var results: ExperimentResults?
    var notes: String

    @Relationship(inverse: \Project.experiments)
    var project: Project?

    init(
        id: UUID = UUID(),
        name: String,
        description: String = "",
        type: ExperimentType
    ) {
        self.id = id
        self.name = name
        self.experimentDescription = description
        self.experimentType = type
        self.status = .planned
        self.createdDate = Date()
        self.notes = ""
    }
}

// MARK: - Experiment Type

enum ExperimentType: String, Codable {
    case synthesis
    case assay
    case crystallography
    case nmr
    case massSpec
    case other

    var displayName: String {
        switch self {
        case .synthesis: return "Synthesis"
        case .assay: return "Biological Assay"
        case .crystallography: return "X-ray Crystallography"
        case .nmr: return "NMR Spectroscopy"
        case .massSpec: return "Mass Spectrometry"
        case .other: return "Other"
        }
    }
}

// MARK: - Experiment Status

enum ExperimentStatus: String, Codable {
    case planned
    case inProgress
    case completed
    case failed

    var displayName: String {
        switch self {
        case .planned: return "Planned"
        case .inProgress: return "In Progress"
        case .completed: return "Completed"
        case .failed: return "Failed"
        }
    }
}

// MARK: - Experiment Results

struct ExperimentResults: Codable {
    var success: Bool
    var data: [String: Double]
    var observations: String
    var attachments: [URL]

    init(
        success: Bool = false,
        data: [String: Double] = [:],
        observations: String = ""
    ) {
        self.success = success
        self.data = data
        self.observations = observations
        self.attachments = []
    }
}
