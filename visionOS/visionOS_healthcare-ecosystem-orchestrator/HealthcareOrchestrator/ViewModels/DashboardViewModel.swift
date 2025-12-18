import Foundation
import SwiftUI
import SwiftData

@Observable
class DashboardViewModel {
    // MARK: - Published State
    var patients: [Patient] = []
    var statistics: HealthcareStatistics?
    var activeAlerts: [ClinicalAlert] = []
    var selectedFilter: PatientFilter = .all
    var isLoading = false
    var errorMessage: String?

    // MARK: - Services
    private let dataService: HealthcareDataService
    private var refreshTask: Task<Void, Never>?

    // MARK: - Computed Properties
    var criticalPatients: [Patient] {
        patients.filter { $0.status == .critical }
    }

    var displayedPatients: [Patient] {
        switch selectedFilter {
        case .all:
            return patients
        case .active:
            return patients.filter { $0.isActive }
        case .critical:
            return criticalPatients
        case .byDepartment(let dept):
            return patients.filter { $0.currentLocation?.contains(dept) == true }
        }
    }

    var hasActiveAlerts: Bool {
        !activeAlerts.isEmpty
    }

    var alertCount: Int {
        activeAlerts.count
    }

    // MARK: - Initialization
    init(modelContext: ModelContext) {
        self.dataService = HealthcareDataService(modelContext: modelContext)
    }

    // MARK: - Data Loading
    @MainActor
    func loadData() async {
        isLoading = true
        errorMessage = nil

        do {
            // Load patients
            patients = try await dataService.fetchPatients(filter: selectedFilter)

            // Load statistics
            statistics = try await dataService.fetchStatistics()

            // Load alerts
            activeAlerts = try await dataService.fetchCriticalAlerts()

            isLoading = false
        } catch {
            errorMessage = "Failed to load data: \(error.localizedDescription)"
            isLoading = false
        }
    }

    @MainActor
    func refreshData() async {
        // Cancel existing refresh task
        refreshTask?.cancel()

        // Start new refresh
        refreshTask = Task {
            await loadData()
        }

        await refreshTask?.value
    }

    // MARK: - Filter Actions
    func applyFilter(_ filter: PatientFilter) {
        selectedFilter = filter
        Task {
            await refreshData()
        }
    }

    // MARK: - Alert Actions
    func acknowledgeAlert(_ alert: ClinicalAlert, by user: String) {
        if let index = activeAlerts.firstIndex(where: { $0.id == alert.id }) {
            var updatedAlert = activeAlerts[index]
            updatedAlert.acknowledgedBy = user
            updatedAlert.acknowledgedAt = Date()
            activeAlerts[index] = updatedAlert

            // Remove after acknowledgment
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.activeAlerts.removeAll { $0.id == alert.id }
            }
        }
    }

    func dismissAlert(_ alert: ClinicalAlert) {
        activeAlerts.removeAll { $0.id == alert.id }
    }

    // MARK: - Patient Actions
    func selectPatient(_ patient: Patient) {
        // This will be handled by NavigationCoordinator
    }

    // MARK: - Auto Refresh
    func startAutoRefresh(interval: TimeInterval = 30) {
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            Task { @MainActor in
                await self.refreshData()
            }
        }
    }

    // MARK: - Cleanup
    deinit {
        refreshTask?.cancel()
    }
}

// MARK: - Patient List Helpers
extension DashboardViewModel {
    func patientsByDepartment() -> [String: [Patient]] {
        Dictionary(grouping: patients) { patient in
            patient.currentLocation ?? "Unknown"
        }
    }

    func sortedDepartments() -> [String] {
        Array(Set(patients.compactMap { $0.currentLocation })).sorted()
    }
}
