import SwiftUI
import RealityKit

@main
struct TimeMachineApp: App {
    @StateObject private var coordinator = GameCoordinator()
    @State private var immersionStyle: ImmersionStyle = .mixed

    var body: some Scene {
        // Main Window - Menu and Settings
        WindowGroup {
            MainMenuView()
                .environmentObject(coordinator)
        }
        .defaultSize(width: 800, height: 600)

        // Immersive Space - Historical Exploration
        ImmersiveSpace(id: "HistoricalExploration") {
            HistoricalExplorationView()
                .environmentObject(coordinator)
        }
        .immersionStyle(selection: $immersionStyle, in: .mixed, .progressive, .full)

        // Volume - Artifact Examination
        WindowGroup(id: "ArtifactExamination") {
            ArtifactExaminationView()
                .environmentObject(coordinator)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1.0, height: 1.0, depth: 1.0, in: .meters)

        // Window - Teacher Dashboard
        WindowGroup(id: "TeacherDashboard") {
            TeacherDashboardView()
                .environmentObject(coordinator)
        }
        .defaultSize(width: 1200, height: 800)
    }

    init() {
        // Configure app-level settings
        configureAudio()
        configureGraphics()
    }

    private func configureAudio() {
        // Set up spatial audio environment
        AudioManager.shared.initialize()
    }

    private func configureGraphics() {
        // Configure rendering preferences
        RenderingManager.shared.targetFPS = 90
        RenderingManager.shared.enableFoveatedRendering = true
    }
}
