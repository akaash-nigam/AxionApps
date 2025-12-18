import SwiftUI

@main
struct HealthcareOrchestratorApp: App {
    var body: some Scene {
        WindowGroup {
            DashboardView()
        }

        ImmersiveSpace(id: "MedicalView") {
            MedicalVisualizationView()
        }
    }
}
