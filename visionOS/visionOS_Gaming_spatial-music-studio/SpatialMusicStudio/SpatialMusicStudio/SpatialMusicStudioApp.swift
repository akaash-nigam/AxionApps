import SwiftUI

@main
struct SpatialMusicStudioApp: App {
    var body: some Scene {
        WindowGroup {
            StudioLobbyView()
        }

        ImmersiveSpace(id: "MusicStudio") {
            MusicStudioView()
        }
    }
}
