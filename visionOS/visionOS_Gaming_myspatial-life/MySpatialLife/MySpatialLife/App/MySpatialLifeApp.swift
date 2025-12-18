import SwiftUI

@main
struct MySpatialLifeApp: App {
    @State private var appState = AppState()
    @State private var gameCoordinator = GameCoordinator()

    var body: some Scene {
        // Main window for menus
        WindowGroup(id: "main-menu") {
            MainMenuView()
                .environment(appState)
                .environment(gameCoordinator)
        }
        .windowStyle(.plain)
        .defaultSize(width: 800, height: 600)

        // Volume for family living space
        WindowGroup(id: "family-volume") {
            FamilyVolumeView()
                .environment(appState)
                .environment(gameCoordinator)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 2.0, height: 2.0, depth: 2.0, in: .meters)

        // Immersive space for special events
        ImmersiveSpace(id: "immersive-space") {
            ImmersiveGameView()
                .environment(appState)
                .environment(gameCoordinator)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}
