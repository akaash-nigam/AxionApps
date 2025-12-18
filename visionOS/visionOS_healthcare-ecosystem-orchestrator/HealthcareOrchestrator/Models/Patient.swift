import Foundation
import SwiftData

@Model
final class Patient {
    // MARK: - Identifiers
    @Attribute(.unique) var id: UUID
    var mrn: String // Medical Record Number

    // MARK: - Demographics
    var firstName: String
    var lastName: String
    var dateOfBirth: Date
    var gender: String

    // MARK: - Clinical Information
    var currentLocation: String?
    var admissionDate: Date?
    var assignedProvider: String?
    var primaryDiagnosis: String?
    var status: PatientStatus

    // MARK: - Contact Information
    var phoneNumber: String?
    var email: String?
    var address: String?

    // MARK: - Relationships
    @Relationship(deleteRule: .cascade) var encounters: [Encounter] = []
    @Relationship(deleteRule: .cascade) var vitalSigns: [VitalSign] = []
    @Relationship(deleteRule: .cascade) var medications: [Medication] = []
    @Relationship(deleteRule: .cascade) var carePlans: [CarePlan] = []
    @Relationship(deleteRule: .cascade) var clinicalNotes: [ClinicalNote] = []

    // MARK: - Metadata
    var createdAt: Date
    var updatedAt: Date

    // MARK: - Computed Properties
    var fullName: String {
        "\(lastName), \(firstName)"
    }

    var age: Int {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year], from: dateOfBirth, to: now)
        return components.year ?? 0
    }

    var isActive: Bool {
        status == .active || status == .critical
    }

    var latestVitalSign: VitalSign? {
        vitalSigns.sorted(by: { $0.recordedAt > $1.recordedAt }).first
    }

    // MARK: - Initialization
    init(
        mrn: String,
        firstName: String,
        lastName: String,
        dateOfBirth: Date,
        gender: String,
        status: PatientStatus = .active
    ) {
        self.id = UUID()
        self.mrn = mrn
        self.firstName = firstName
        self.lastName = lastName
        self.dateOfBirth = dateOfBirth
        self.gender = gender
        self.status = status
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: - Patient Status
enum PatientStatus: String, Codable {
    case active = "Active"
    case critical = "Critical"
    case stable = "Stable"
    case discharged = "Discharged"
    case deceased = "Deceased"

    var color: String {
        switch self {
        case .active: return "blue"
        case .critical: return "red"
        case .stable: return "green"
        case .discharged: return "gray"
        case .deceased: return "black"
        }
    }
}

// MARK: - Preview Helpers
#if DEBUG
extension Patient {
    static var preview: Patient {
        Patient(
            mrn: "12345678",
            firstName: "John",
            lastName: "Smith",
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -67, to: Date())!,
            gender: "Male",
            status: .critical
        )
    }

    static var previewStable: Patient {
        Patient(
            mrn: "87654321",
            firstName: "Jane",
            lastName: "Doe",
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -45, to: Date())!,
            gender: "Female",
            status: .stable
        )
    }
}
#endif
