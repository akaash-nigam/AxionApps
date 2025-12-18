import SwiftUI

@main
struct HomeDefenseApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }

        ImmersiveSpace(id: "DefenseSpace") {
            ImmersiveView()
        }
    }
}
