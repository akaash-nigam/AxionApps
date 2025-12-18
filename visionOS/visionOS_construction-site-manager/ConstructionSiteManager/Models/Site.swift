//
//  Site.swift
//  Construction Site Manager
//
//  Core site and project models
//

import Foundation
import SwiftUI
import SwiftData
import CoreLocation

// MARK: - Site Model

/// Represents a construction site
@Model
final class Site {
    @Attribute(.unique) var id: UUID
    var name: String
    var address: Address
    var gpsLatitude: Double
    var gpsLongitude: Double
    var siteOrientation: Double  // Degrees from true north
    var boundaryPoints: [SiteCoordinate]
    var status: SiteStatus
    var startDate: Date
    var completionDate: Date?
    var createdDate: Date
    var lastModifiedDate: Date

    @Relationship(deleteRule: .cascade) var projects: [Project]
    @Relationship(deleteRule: .cascade) var team: [TeamMember]

    init(
        id: UUID = UUID(),
        name: String,
        address: Address,
        gpsLatitude: Double,
        gpsLongitude: Double,
        siteOrientation: Double = 0.0,
        boundaryPoints: [SiteCoordinate] = [],
        status: SiteStatus = .planning,
        startDate: Date = Date(),
        completionDate: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.gpsLatitude = gpsLatitude
        self.gpsLongitude = gpsLongitude
        self.siteOrientation = siteOrientation
        self.boundaryPoints = boundaryPoints
        self.status = status
        self.startDate = startDate
        self.completionDate = completionDate
        self.createdDate = Date()
        self.lastModifiedDate = Date()
        self.projects = []
        self.team = []
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: gpsLatitude, longitude: gpsLongitude)
    }

    var overallProgress: Double {
        guard !projects.isEmpty else { return 0.0 }
        let totalProgress = projects.reduce(0.0) { $0 + $1.progress }
        return totalProgress / Double(projects.count)
    }
}

enum SiteStatus: String, Codable {
    case planning
    case active
    case onHold
    case completed
    case archived

    var displayName: String {
        switch self {
        case .planning: return "Planning"
        case .active: return "Active"
        case .onHold: return "On Hold"
        case .completed: return "Completed"
        case .archived: return "Archived"
        }
    }
}

// MARK: - Project Model

/// Represents a construction project within a site
@Model
final class Project {
    @Attribute(.unique) var id: UUID
    var name: String
    var projectType: ProjectType
    var progress: Double  // 0.0 to 1.0
    var budget: Double
    var actualCost: Double
    var startDate: Date
    var scheduledEndDate: Date
    var actualEndDate: Date?
    var createdDate: Date
    var lastModifiedDate: Date

    @Relationship(deleteRule: .cascade) var bimModels: [BIMModel]
    @Relationship(deleteRule: .cascade) var issues: [Issue]
    @Relationship(deleteRule: .cascade) var milestones: [Milestone]

    @Relationship(inverse: \Site.projects) var site: Site?

    init(
        id: UUID = UUID(),
        name: String,
        projectType: ProjectType,
        progress: Double = 0.0,
        budget: Double = 0.0,
        actualCost: Double = 0.0,
        startDate: Date = Date(),
        scheduledEndDate: Date
    ) {
        self.id = id
        self.name = name
        self.projectType = projectType
        self.progress = progress
        self.budget = budget
        self.actualCost = actualCost
        self.startDate = startDate
        self.scheduledEndDate = scheduledEndDate
        self.createdDate = Date()
        self.lastModifiedDate = Date()
        self.bimModels = []
        self.issues = []
        self.milestones = []
    }

    var isOnBudget: Bool {
        actualCost <= budget
    }

    var isOnSchedule: Bool {
        guard let actualEnd = actualEndDate else {
            return Date() <= scheduledEndDate
        }
        return actualEnd <= scheduledEndDate
    }

    var scheduleVariance: TimeInterval {
        let now = actualEndDate ?? Date()
        return now.timeIntervalSince(scheduledEndDate)
    }

    var budgetVariance: Double {
        actualCost - budget
    }
}

// MARK: - Team Member

@Model
final class TeamMember {
    @Attribute(.unique) var id: UUID
    var name: String
    var email: String
    var phone: String
    var role: TeamRole
    var trade: Discipline?
    var company: String
    var isActive: Bool
    var joinedDate: Date

    @Relationship(inverse: \Site.team) var site: Site?

    init(
        id: UUID = UUID(),
        name: String,
        email: String,
        phone: String,
        role: TeamRole,
        trade: Discipline? = nil,
        company: String,
        isActive: Bool = true,
        joinedDate: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.phone = phone
        self.role = role
        self.trade = trade
        self.company = company
        self.isActive = isActive
        self.joinedDate = joinedDate
    }
}

enum TeamRole: String, Codable, CaseIterable {
    case projectManager
    case superintendent
    case safetyOfficer
    case qualityManager
    case foreman
    case tradeWorker
    case inspector
    case owner
    case architect
    case engineer

    var displayName: String {
        switch self {
        case .projectManager: return "Project Manager"
        case .superintendent: return "Superintendent"
        case .safetyOfficer: return "Safety Officer"
        case .qualityManager: return "Quality Manager"
        case .foreman: return "Foreman"
        case .tradeWorker: return "Trade Worker"
        case .inspector: return "Inspector"
        case .owner: return "Owner"
        case .architect: return "Architect"
        case .engineer: return "Engineer"
        }
    }

    var color: Color {
        switch self {
        case .projectManager: return Color(hex: "#2196F3")    // Blue
        case .superintendent: return Color(hex: "#4CAF50")   // Green
        case .safetyOfficer: return Color(hex: "#F44336")    // Red
        case .qualityManager: return Color(hex: "#9C27B0")   // Purple
        case .foreman: return Color(hex: "#FF9800")          // Orange
        case .tradeWorker: return Color(hex: "#795548")      // Brown
        case .inspector: return Color(hex: "#607D8B")        // Blue Gray
        case .owner: return Color(hex: "#FFD700")            // Gold
        case .architect: return Color(hex: "#E91E63")        // Pink
        case .engineer: return Color(hex: "#00BCD4")         // Cyan
        }
    }
}

// MARK: - Milestone

@Model
final class Milestone {
    @Attribute(.unique) var id: UUID
    var name: String
    var milestoneDescription: String
    var dueDate: Date
    var completedDate: Date?
    var isCompleted: Bool
    var importance: MilestoneImportance

    @Relationship(inverse: \Project.milestones) var project: Project?

    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        dueDate: Date,
        completedDate: Date? = nil,
        isCompleted: Bool = false,
        importance: MilestoneImportance = .normal
    ) {
        self.id = id
        self.name = name
        self.milestoneDescription = description
        self.dueDate = dueDate
        self.completedDate = completedDate
        self.isCompleted = isCompleted
        self.importance = importance
    }

    var isOverdue: Bool {
        !isCompleted && Date() > dueDate
    }
}

enum MilestoneImportance: String, Codable {
    case low
    case normal
    case high
    case critical
}
