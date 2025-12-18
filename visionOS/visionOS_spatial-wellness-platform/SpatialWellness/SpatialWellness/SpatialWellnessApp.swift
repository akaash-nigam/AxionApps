import SwiftUI

@main
struct SpatialWellnessApp: App {
    var body: some Scene {
        WindowGroup {
            WellnessDashboardView()
        }

        ImmersiveSpace(id: "WorkoutSpace") {
            WorkoutSpaceView()
        }
    }
}
