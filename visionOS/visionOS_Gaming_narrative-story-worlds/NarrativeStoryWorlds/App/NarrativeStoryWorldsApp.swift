import SwiftUI

@main
struct NarrativeStoryWorldsApp: App {
    @State private var appModel = AppModel()

    var body: some Scene {
        // Main window for menus and settings
        WindowGroup {
            ContentView()
                .environment(appModel)
        }
        .windowStyle(.plain)

        // Immersive space for the story experience
        ImmersiveSpace(id: "StorySpace") {
            StoryExperienceView()
                .environment(appModel)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}
