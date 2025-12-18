import SwiftUI
import RealityKit

/// Main application entry point for Escape Room Network
@main
struct EscapeRoomNetworkApp: App {
    @State private var gameViewModel = GameViewModel()
    @State private var appState: AppState = .mainMenu

    var body: some SwiftUI.Scene {
        // Main menu window
        WindowGroup(id: "main-menu") {
            MainMenuView()
                .environment(gameViewModel)
        }
        .windowStyle(.plain)
        .defaultSize(width: 800, height: 600)

        // Settings window
        WindowGroup(id: "settings") {
            SettingsView()
                .environment(gameViewModel)
        }
        .windowStyle(.plain)
        .defaultSize(width: 600, height: 800)

        // Immersive space for gameplay
        ImmersiveSpace(id: "game-space") {
            GameView()
                .environment(gameViewModel)
        }
        .immersionStyle(selection: .constant(gameViewModel.immersionLevel), in: .mixed, .progressive, .full)
    }
}

/// Application state tracking
enum AppState {
    case mainMenu
    case roomScanning
    case playing
    case settings
    case multiplayer
}

/// Concrete immersion style preference
enum ImmersionPreference {
    case mixed
    case progressive
    case full

    var toImmersionStyle: ImmersionStyle {
        switch self {
        case .mixed: return .mixed
        case .progressive: return .progressive
        case .full: return .full
        }
    }
}

/// Game view model managing game state and coordination
@MainActor
@Observable
class GameViewModel {
    var currentGameState: GameState = .initialization
    var immersionPreference: ImmersionPreference = .mixed

    var immersionLevel: ImmersionStyle {
        immersionPreference.toImmersionStyle
    }
    var gameLoopManager: GameLoopManager?
    var puzzleEngine: PuzzleEngine?
    var multiplayerManager: MultiplayerManager?
    var spatialMappingManager: SpatialMappingManager?

    // Game statistics
    var currentPuzzle: Puzzle?
    var puzzleProgress: PuzzleProgress?
    var playerLevel: Int = 1
    var playerXP: Int = 0

    init() {
        setupGame()
    }

    @MainActor
    func setupGame() {
        gameLoopManager = GameLoopManager()
        puzzleEngine = PuzzleEngine()
        multiplayerManager = MultiplayerManager()
        spatialMappingManager = SpatialMappingManager()
    }

    func initializeGameSystems(rootEntity: Entity) async {
        // Initialize game systems with root entity
        await spatialMappingManager?.startRoomScanning()
    }

    func updateGameContent(_ content: RealityViewContent) {
        // Update RealityKit content
    }

    @MainActor
    func handleTap(on entity: Entity) {
        // Handle entity interaction
        print("Tapped on entity: \(entity.name)")
    }

    func startGame(puzzle: Puzzle) {
        currentPuzzle = puzzle
        currentGameState = .playing
        gameLoopManager?.start()
    }

    func pauseGame() {
        currentGameState = .paused
        gameLoopManager?.stop()
    }

    func resumeGame() {
        currentGameState = .playing
        gameLoopManager?.start()
    }
}
