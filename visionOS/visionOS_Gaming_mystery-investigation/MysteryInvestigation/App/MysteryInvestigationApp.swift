import SwiftUI
import RealityKit

@main
struct MysteryInvestigationApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var gameCoordinator = GameCoordinator()

    var body: some Scene {
        // Main Menu Window
        WindowGroup(id: "main-menu") {
            MainMenuView()
                .environmentObject(appState)
                .environmentObject(gameCoordinator)
                .frame(width: 800, height: 600)
        }
        .windowStyle(.plain)
        .defaultSize(width: 800, height: 600)

        // Crime Scene Immersive Space
        ImmersiveSpace(id: "crime-scene") {
            CrimeSceneView()
                .environmentObject(appState)
                .environmentObject(gameCoordinator)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)

        // Evidence Examination Volume
        WindowGroup(id: "evidence-viewer") {
            EvidenceExaminationView()
                .environmentObject(gameCoordinator)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1.0, height: 1.0, depth: 1.0, in: .meters)

        // Settings Window
        WindowGroup(id: "settings") {
            SettingsView()
                .environmentObject(appState)
        }
        .windowStyle(.plain)
        .defaultSize(width: 600, height: 800)
    }
}
