import SwiftUI

@main
struct MysteryInvestigationApp: App {
    var body: some Scene {
        WindowGroup {
            MainMenuView()
        }

        ImmersiveSpace(id: "CrimeScene") {
            CrimeSceneView()
        }
    }
}
