import Foundation
import SwiftData

/// Thread-safe healthcare data service using Swift Actor
actor HealthcareDataService {
    // MARK: - Properties
    private let modelContext: ModelContext
    private var patientCache: [UUID: Patient] = [:]
    private let cacheExpiration: TimeInterval = 300 // 5 minutes

    // MARK: - Initialization
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Patient Operations
    func fetchPatients(filter: PatientFilter = .all) async throws -> [Patient] {
        let descriptor = FetchDescriptor<Patient>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )

        let allPatients = try modelContext.fetch(descriptor)

        switch filter {
        case .all:
            return allPatients
        case .active:
            return allPatients.filter { $0.isActive }
        case .critical:
            return allPatients.filter { $0.status == .critical }
        case .byDepartment(let department):
            return allPatients.filter { $0.currentLocation?.contains(department) == true }
        }
    }

    func fetchPatient(id: UUID) async throws -> Patient? {
        // Check cache first
        if let cached = patientCache[id] {
            return cached
        }

        // Fetch from database
        let descriptor = FetchDescriptor<Patient>(
            predicate: #Predicate { $0.id == id }
        )

        let patients = try modelContext.fetch(descriptor)
        let patient = patients.first

        // Update cache
        if let patient = patient {
            patientCache[id] = patient
        }

        return patient
    }

    func createPatient(_ patient: Patient) async throws {
        modelContext.insert(patient)
        try modelContext.save()
        patientCache[patient.id] = patient
    }

    func updatePatient(_ patient: Patient) async throws {
        patient.updatedAt = Date()
        try modelContext.save()
        patientCache[patient.id] = patient
    }

    func deletePatient(_ patient: Patient) async throws {
        modelContext.delete(patient)
        try modelContext.save()
        patientCache.removeValue(forKey: patient.id)
    }

    // MARK: - Vital Signs Operations
    func fetchLatestVitalSigns(for patient: Patient, limit: Int = 10) async throws -> [VitalSign] {
        patient.vitalSigns
            .sorted { $0.recordedAt > $1.recordedAt }
            .prefix(limit)
            .map { $0 }
    }

    func addVitalSign(_ vitalSign: VitalSign, to patient: Patient) async throws {
        patient.vitalSigns.append(vitalSign)
        patient.updatedAt = Date()
        try modelContext.save()
    }

    // MARK: - Alert Operations
    func fetchCriticalAlerts() async throws -> [ClinicalAlert] {
        let patients = try await fetchPatients(filter: .critical)
        var alerts: [ClinicalAlert] = []

        for patient in patients {
            if let latestVitals = patient.latestVitalSign,
               latestVitals.alertLevel == .critical || latestVitals.alertLevel == .emergency {
                let alert = ClinicalAlert(
                    patientId: patient.id,
                    patientName: patient.fullName,
                    alertType: .vitalSign,
                    severity: latestVitals.alertLevel,
                    message: "Critical vital signs: \(latestVitals.criticalValues.joined(separator: ", "))"
                )
                alerts.append(alert)
            }
        }

        return alerts
    }

    // MARK: - Statistics
    func fetchStatistics() async throws -> HealthcareStatistics {
        let allPatients = try await fetchPatients(filter: .all)

        return HealthcareStatistics(
            totalPatients: allPatients.count,
            activePatients: allPatients.filter { $0.isActive }.count,
            criticalPatients: allPatients.filter { $0.status == .critical }.count,
            stablePatients: allPatients.filter { $0.status == .stable }.count
        )
    }

    // MARK: - Cache Management
    func clearCache() {
        patientCache.removeAll()
    }
}

// MARK: - Patient Filter
enum PatientFilter {
    case all
    case active
    case critical
    case byDepartment(String)
}

// MARK: - Healthcare Statistics
struct HealthcareStatistics: Codable {
    var totalPatients: Int
    var activePatients: Int
    var criticalPatients: Int
    var stablePatients: Int

    var criticalPercentage: Double {
        guard totalPatients > 0 else { return 0 }
        return Double(criticalPatients) / Double(totalPatients) * 100
    }
}
