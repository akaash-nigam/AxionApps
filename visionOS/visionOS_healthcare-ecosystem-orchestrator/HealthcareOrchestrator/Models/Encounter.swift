import Foundation
import SwiftData

@Model
final class Encounter {
    // MARK: - Identifiers
    @Attribute(.unique) var id: UUID

    // MARK: - Encounter Details
    var encounterType: EncounterType
    var status: EncounterStatus
    var admissionDate: Date
    var dischargeDate: Date?
    var chiefComplaint: String?
    var primaryDiagnosis: String?
    var secondaryDiagnoses: [String] = []

    // MARK: - Location
    var facility: String
    var department: String
    var room: String?
    var bed: String?

    // MARK: - Care Team
    var attendingPhysician: String?
    var residents: [String] = []
    var nurses: [String] = []

    // MARK: - Relationships
    @Relationship(inverse: \Patient.encounters) var patient: Patient?
    @Relationship(deleteRule: .cascade) var clinicalNotes: [ClinicalNote] = []
    @Relationship(deleteRule: .cascade) var procedures: [Procedure] = []

    // MARK: - Metadata
    var createdAt: Date
    var updatedAt: Date

    // MARK: - Computed Properties
    var lengthOfStay: TimeInterval? {
        guard let discharge = dischargeDate else {
            return Date().timeIntervalSince(admissionDate)
        }
        return discharge.timeIntervalSince(admissionDate)
    }

    var lengthOfStayDays: Int? {
        guard let los = lengthOfStay else { return nil }
        return Int(los / 86400) // seconds to days
    }

    var isActive: Bool {
        status == .active || status == .observation
    }

    // MARK: - Initialization
    init(
        encounterType: EncounterType,
        status: EncounterStatus = .active,
        admissionDate: Date = Date(),
        facility: String,
        department: String,
        chiefComplaint: String? = nil
    ) {
        self.id = UUID()
        self.encounterType = encounterType
        self.status = status
        self.admissionDate = admissionDate
        self.facility = facility
        self.department = department
        self.chiefComplaint = chiefComplaint
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: - Encounter Type
enum EncounterType: String, Codable, CaseIterable {
    case emergency = "Emergency"
    case inpatient = "Inpatient"
    case outpatient = "Outpatient"
    case observation = "Observation"
    case telehealth = "Telehealth"
    case surgery = "Surgery"

    var systemImage: String {
        switch self {
        case .emergency: return "cross.case.fill"
        case .inpatient: return "bed.double.fill"
        case .outpatient: return "stethoscope"
        case .observation: return "eye.fill"
        case .telehealth: return "video.fill"
        case .surgery: return "staroflife.fill"
        }
    }
}

// MARK: - Encounter Status
enum EncounterStatus: String, Codable, CaseIterable {
    case planned = "Planned"
    case active = "Active"
    case observation = "Observation"
    case completed = "Completed"
    case cancelled = "Cancelled"

    var color: String {
        switch self {
        case .planned: return "gray"
        case .active: return "blue"
        case .observation: return "yellow"
        case .completed: return "green"
        case .cancelled: return "red"
        }
    }
}

// MARK: - Procedure Model
@Model
final class Procedure {
    @Attribute(.unique) var id: UUID
    var code: String
    var name: String
    var performedDate: Date
    var performedBy: String?
    var status: String
    var notes: String?

    @Relationship(inverse: \Encounter.procedures) var encounter: Encounter?

    init(code: String, name: String, performedDate: Date = Date()) {
        self.id = UUID()
        self.code = code
        self.name = name
        self.performedDate = performedDate
        self.status = "completed"
    }
}

// MARK: - Preview Helpers
#if DEBUG
extension Encounter {
    static var preview: Encounter {
        Encounter(
            encounterType: .emergency,
            status: .active,
            admissionDate: Date().addingTimeInterval(-7200), // 2 hours ago
            facility: "General Hospital",
            department: "Emergency Department",
            chiefComplaint: "Chest pain"
        )
    }
}
#endif
