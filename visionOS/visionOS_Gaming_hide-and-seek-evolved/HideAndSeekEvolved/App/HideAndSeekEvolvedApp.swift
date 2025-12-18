import SwiftUI

@main
struct HideAndSeekEvolvedApp: App {
    @StateObject private var gameManager = GameManager()
    @StateObject private var immersiveSpaceManager = ImmersiveSpaceManager()

    var body: some Scene {
        // Main window scene for menu and setup
        WindowGroup {
            ContentView()
                .environmentObject(gameManager)
                .environmentObject(immersiveSpaceManager)
        }
        .windowStyle(.plain)

        // Immersive space for gameplay
        ImmersiveSpace(id: "GameplaySpace") {
            GameplayView()
                .environmentObject(gameManager)
        }
        .immersionStyle(selection: .constant(.full), in: .full)
    }
}
