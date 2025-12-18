import SwiftUI

/// Main application entry point for Mindfulness Meditation Realms
@main
struct MeditationApp: App {

    @StateObject private var appCoordinator = AppCoordinator()
    @State private var immersionStyle: ImmersionStyle = .full

    var body: some Scene {
        // Main window for menus and navigation
        WindowGroup {
            MainMenuView()
                .environmentObject(appCoordinator)
        }
        .windowStyle(.plain)

        // Immersive space for meditation experiences
        ImmersiveSpace(id: "MeditationRealm") {
            MeditationEnvironmentView()
                .environmentObject(appCoordinator)
        }
        .immersionStyle(selection: $immersionStyle, in: .full)
    }
}
