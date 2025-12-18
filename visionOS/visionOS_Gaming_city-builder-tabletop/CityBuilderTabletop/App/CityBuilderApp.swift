import SwiftUI

/// Main application entry point for City Builder Tabletop
/// Configures the visionOS app with volumetric and window scenes
@main
struct CityBuilderApp: App {
    @State private var gameCoordinator = GameCoordinator()

    var body: some Scene {
        // Main game volume (primary experience)
        WindowGroup(id: "city-volume") {
            CityVolumeView()
                .environment(gameCoordinator)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1.0, height: 0.5, depth: 1.0, in: .meters)

        // Settings window
        WindowGroup(id: "settings") {
            SettingsView()
                .environment(gameCoordinator)
        }
        .windowStyle(.plain)
        .defaultSize(width: 600, height: 800)

        // Immersive space for full city view (optional)
        ImmersiveSpace(id: "immersive-city") {
            ImmersiveCityView()
                .environment(gameCoordinator)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}
