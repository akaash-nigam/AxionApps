import SwiftUI

@main
struct TacticalTeamShootersApp: App {
    @State private var immersionStyle: ImmersionStyle = .progressive
    @StateObject private var gameStateManager = GameStateManager()
    @StateObject private var networkManager = NetworkManager()

    var body: some Scene {
        // Main menu window
        WindowGroup(id: "main-menu") {
            MainMenuView()
                .environmentObject(gameStateManager)
                .environmentObject(networkManager)
        }
        .windowStyle(.plain)
        .defaultSize(width: 800, height: 600)

        // Team lobby volume
        WindowGroup(id: "lobby", for: LobbyConfiguration.self) { $config in
            TeamLobbyView(configuration: config ?? LobbyConfiguration())
                .environmentObject(gameStateManager)
                .environmentObject(networkManager)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 2, height: 1, depth: 1, in: .meters)

        // Battlefield immersive space
        ImmersiveSpace(id: "battlefield") {
            BattlefieldView()
                .environmentObject(gameStateManager)
                .environmentObject(networkManager)
        }
        .immersionStyle(selection: $immersionStyle, in: .progressive, .full)
    }
}

// MARK: - Lobby Configuration

struct LobbyConfiguration: Codable, Hashable {
    var teamSize: Int = 5
    var gameMode: GameMode = .competitive
    var mapSelection: String? = nil

    enum GameMode: String, Codable {
        case quickMatch
        case competitive
        case training
        case custom
    }
}
