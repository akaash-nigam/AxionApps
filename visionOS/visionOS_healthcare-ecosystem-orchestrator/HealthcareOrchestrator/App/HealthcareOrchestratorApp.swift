import SwiftUI
import SwiftData

@main
struct HealthcareOrchestratorApp: App {
    // MARK: - State Management
    @State private var immersiveSpaceIsShown = false
    @State private var navigationCoordinator = NavigationCoordinator()

    // MARK: - SwiftData Configuration
    var modelContainer: ModelContainer = {
        let schema = Schema([
            Patient.self,
            Encounter.self,
            VitalSign.self,
            Medication.self,
            CarePlan.self,
            ClinicalNote.self
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )

        do {
            return try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    // MARK: - App Body
    var body: some Scene {
        // MARK: - Dashboard Window (Main Entry Point)
        WindowGroup(id: "dashboard") {
            DashboardView()
                .environment(navigationCoordinator)
        }
        .modelContainer(modelContainer)
        .windowStyle(.automatic)
        .windowResizability(.contentSize)
        .defaultSize(width: 1200, height: 800)

        // MARK: - Patient Detail Window
        WindowGroup(id: "patientDetail", for: UUID.self) { $patientId in
            if let patientId = patientId {
                PatientDetailView(patientId: patientId)
                    .environment(navigationCoordinator)
            } else {
                ContentUnavailableView(
                    "No Patient Selected",
                    systemImage: "person.crop.circle.badge.xmark",
                    description: Text("Select a patient to view details")
                )
            }
        }
        .modelContainer(modelContainer)
        .windowStyle(.plain)
        .defaultSize(width: 1400, height: 1000)

        // MARK: - Analytics Window
        WindowGroup(id: "analytics") {
            AnalyticsView()
                .environment(navigationCoordinator)
        }
        .modelContainer(modelContainer)
        .windowStyle(.automatic)
        .defaultSize(width: 1600, height: 900)

        // MARK: - Care Coordination Volume (3D)
        WindowGroup(id: "careCoordination") {
            CareCoordinationVolume()
                .environment(navigationCoordinator)
        }
        .modelContainer(modelContainer)
        .windowStyle(.volumetric)
        .defaultSize(width: 2.0, height: 2.0, depth: 2.0, in: .meters)

        // MARK: - Clinical Observatory Volume (3D)
        WindowGroup(id: "clinicalObservatory") {
            ClinicalObservatoryVolume()
                .environment(navigationCoordinator)
        }
        .modelContainer(modelContainer)
        .windowStyle(.volumetric)
        .defaultSize(width: 3.0, height: 2.0, depth: 2.0, in: .meters)

        // MARK: - Emergency Response Immersive Space
        ImmersiveSpace(id: "emergencyResponse") {
            EmergencyResponseSpace()
                .environment(navigationCoordinator)
        }
        .modelContainer(modelContainer)
        .immersionStyle(selection: .constant(.full), in: .full)
        .upperLimbVisibility(.visible)
    }
}

// MARK: - Navigation Coordinator
@Observable
class NavigationCoordinator {
    var selectedPatient: Patient?
    var showingEmergencyMode = false
    var activeAlerts: [ClinicalAlert] = []

    func openPatientDetail(_ patient: Patient) {
        selectedPatient = patient
    }

    func enterEmergencyMode() {
        showingEmergencyMode = true
    }

    func exitEmergencyMode() {
        showingEmergencyMode = false
    }

    func addAlert(_ alert: ClinicalAlert) {
        activeAlerts.append(alert)
    }

    func acknowledgeAlert(_ alert: ClinicalAlert) {
        activeAlerts.removeAll { $0.id == alert.id }
    }
}
