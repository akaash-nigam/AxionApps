import SwiftUI

@main
struct HolographicBoardGamesApp: App {
    var body: some Scene {
        WindowGroup {
            GameLobbyView()
        }

        ImmersiveSpace(id: "GameBoard") {
            GameBoardView()
        }
    }
}
