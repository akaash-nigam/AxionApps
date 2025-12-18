import SwiftUI

/// Main app entry point for Interactive Theater
@main
struct InteractiveTheaterApp: App {
    @State private var immersionStyle: ImmersionStyle = .full
    @StateObject private var appCoordinator = AppCoordinator()

    var body: some Scene {
        // Main menu window
        WindowGroup {
            MainMenuView()
                .environmentObject(appCoordinator)
        }
        .defaultSize(width: 800, height: 600)

        // Immersive theater space for performances
        ImmersiveSpace(id: "theater") {
            TheaterPerformanceView()
                .environmentObject(appCoordinator)
        }
        .immersionStyle(selection: $immersionStyle, in: .full)
    }
}
