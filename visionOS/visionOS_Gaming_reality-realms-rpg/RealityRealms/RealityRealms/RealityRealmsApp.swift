import SwiftUI

@main
struct RealityRealmsApp: App {
    var body: some Scene {
        WindowGroup {
            MainMenuView()
        }

        ImmersiveSpace(id: "rpgworld") {
            RPGWorldView()
        }
    }
}
