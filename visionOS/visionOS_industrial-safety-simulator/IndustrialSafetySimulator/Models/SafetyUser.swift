import Foundation
import SwiftData

@Model
final class SafetyUser {
    var id: UUID
    var name: String
    var role: WorkerRole
    var department: String
    var hireDate: Date
    var email: String?
    var employeeId: String?

    // Relationships
    @Relationship(deleteRule: .cascade)
    var certifications: [Certification] = []

    @Relationship(deleteRule: .cascade)
    var trainingHistory: [TrainingSession] = []

    @Relationship(deleteRule: .nullify)
    var performanceMetrics: PerformanceMetrics?

    @Relationship(deleteRule: .nullify)
    var assignedTraining: [TrainingModule] = []

    // Computed properties
    var displayName: String {
        name
    }

    var roleDescription: String {
        role.rawValue.capitalized
    }

    init(
        name: String,
        role: WorkerRole,
        department: String,
        hireDate: Date,
        email: String? = nil,
        employeeId: String? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.role = role
        self.department = department
        self.hireDate = hireDate
        self.email = email
        self.employeeId = employeeId
    }
}

// MARK: - Worker Role

enum WorkerRole: String, Codable {
    case operator
    case supervisor
    case safetyManager
    case trainer
    case contractor
    case visitor

    var permissions: Set<Permission> {
        switch self {
        case .operator:
            return [.viewTraining, .completeScenarios]
        case .supervisor:
            return [.viewTraining, .completeScenarios, .viewTeamMetrics]
        case .trainer:
            return [.viewTraining, .completeScenarios, .createScenarios, .assessUsers]
        case .safetyManager:
            return Permission.all
        case .contractor:
            return [.viewTraining, .completeScenarios]
        case .visitor:
            return [.viewTraining]
        }
    }
}

// MARK: - Certification

@Model
final class Certification {
    var id: UUID
    var name: String
    var issueDate: Date
    var expirationDate: Date?
    var issuingOrganization: String
    var certificateNumber: String?

    var isValid: Bool {
        guard let expirationDate = expirationDate else { return true }
        return expirationDate > Date()
    }

    init(
        name: String,
        issueDate: Date,
        expirationDate: Date? = nil,
        issuingOrganization: String,
        certificateNumber: String? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.issueDate = issueDate
        self.expirationDate = expirationDate
        self.issuingOrganization = issuingOrganization
        self.certificateNumber = certificateNumber
    }
}
