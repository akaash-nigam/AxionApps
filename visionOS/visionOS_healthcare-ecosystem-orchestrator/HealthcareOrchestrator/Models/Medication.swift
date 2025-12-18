import Foundation
import SwiftData

@Model
final class Medication {
    // MARK: - Identifiers
    @Attribute(.unique) var id: UUID

    // MARK: - Medication Details
    var name: String
    var genericName: String?
    var dosage: String
    var route: MedicationRoute
    var frequency: String
    var instructions: String?

    // MARK: - Status
    var status: MedicationStatus
    var startDate: Date
    var endDate: Date?

    // MARK: - Clinical Information
    var indication: String?
    var prescribedBy: String?
    var pharmacyNotes: String?

    // MARK: - Relationships
    @Relationship(inverse: \Patient.medications) var patient: Patient?

    // MARK: - Metadata
    var createdAt: Date
    var updatedAt: Date

    // MARK: - Computed Properties
    var isActive: Bool {
        status == .active && (endDate == nil || endDate! > Date())
    }

    var displayName: String {
        if let generic = genericName {
            return "\(name) (\(generic))"
        }
        return name
    }

    // MARK: - Initialization
    init(
        name: String,
        genericName: String? = nil,
        dosage: String,
        route: MedicationRoute,
        frequency: String,
        status: MedicationStatus = .active,
        startDate: Date = Date(),
        prescribedBy: String? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.genericName = genericName
        self.dosage = dosage
        self.route = route
        self.frequency = frequency
        self.status = status
        self.startDate = startDate
        self.prescribedBy = prescribedBy
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: - Medication Route
enum MedicationRoute: String, Codable, CaseIterable {
    case oral = "Oral"
    case intravenous = "IV"
    case intramuscular = "IM"
    case subcutaneous = "SubQ"
    case topical = "Topical"
    case inhalation = "Inhalation"
    case rectal = "Rectal"
    case sublingual = "Sublingual"
    case transdermal = "Transdermal"

    var systemImage: String {
        switch self {
        case .oral: return "pills.fill"
        case .intravenous: return "cross.vial.fill"
        case .intramuscular, .subcutaneous: return "syringe.fill"
        case .topical: return "hand.point.up.left.fill"
        case .inhalation: return "lungs.fill"
        case .rectal, .sublingual, .transdermal: return "cross.fill"
        }
    }
}

// MARK: - Medication Status
enum MedicationStatus: String, Codable, CaseIterable {
    case active = "Active"
    case completed = "Completed"
    case discontinued = "Discontinued"
    case onHold = "On Hold"
    case cancelled = "Cancelled"

    var color: String {
        switch self {
        case .active: return "green"
        case .completed: return "blue"
        case .discontinued: return "orange"
        case .onHold: return "yellow"
        case .cancelled: return "red"
        }
    }
}

// MARK: - Clinical Note Model
@Model
final class ClinicalNote {
    @Attribute(.unique) var id: UUID
    var noteType: NoteType
    var content: String
    var author: String
    var createdAt: Date

    @Relationship(inverse: \Patient.clinicalNotes) var patient: Patient?

    init(noteType: NoteType, content: String, author: String) {
        self.id = UUID()
        self.noteType = noteType
        self.content = content
        self.author = author
        self.createdAt = Date()
    }
}

enum NoteType: String, Codable {
    case progress = "Progress Note"
    case admission = "Admission Note"
    case discharge = "Discharge Summary"
    case consultation = "Consultation"
    case procedure = "Procedure Note"
}

// MARK: - CarePlan Model
@Model
final class CarePlan {
    @Attribute(.unique) var id: UUID
    var title: String
    var description: String
    var status: CarePlanStatus
    var startDate: Date
    var endDate: Date?
    var goals: [String] = []

    @Relationship(inverse: \Patient.carePlans) var patient: Patient?

    init(title: String, description: String, status: CarePlanStatus = .active) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.status = status
        self.startDate = Date()
    }
}

enum CarePlanStatus: String, Codable {
    case draft = "Draft"
    case active = "Active"
    case completed = "Completed"
    case cancelled = "Cancelled"
}

// MARK: - Clinical Alert Model
struct ClinicalAlert: Identifiable, Codable {
    var id: UUID = UUID()
    var patientId: UUID
    var patientName: String
    var alertType: AlertType
    var severity: AlertLevel
    var message: String
    var timestamp: Date = Date()
    var acknowledgedBy: String?
    var acknowledgedAt: Date?

    var isAcknowledged: Bool {
        acknowledgedBy != nil
    }
}

enum AlertType: String, Codable {
    case vitalSign = "Vital Sign"
    case medication = "Medication"
    case lab = "Lab Result"
    case deterioration = "Patient Deterioration"
    case fallRisk = "Fall Risk"
    case sepsis = "Sepsis Alert"
}

// MARK: - Preview Helpers
#if DEBUG
extension Medication {
    static var preview: Medication {
        Medication(
            name: "Metoprolol",
            genericName: "Metoprolol Tartrate",
            dosage: "50mg",
            route: .oral,
            frequency: "Twice daily",
            prescribedBy: "Dr. Johnson"
        )
    }
}
#endif
