import SwiftUI
import RealityKit
import ARKit

/// Central coordinator managing game state, scene transitions, and core systems
/// Acts as the main orchestrator for the entire game experience
@MainActor
class GameCoordinator: ObservableObject {

    // MARK: - Published Properties

    @Published var gameState: GameState = .boot
    @Published var matchState: MatchState?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Core Systems

    private(set) var ecsManager: ECSManager
    private(set) var gameLoop: GameLoop
    private(set) var spatialManager: SpatialEnvironmentManager
    private(set) var networkManager: NetworkManager
    private(set) var audioManager: SpatialAudioManager
    private(set) var inputManager: SpatialInputManager

    // MARK: - Initialization

    init() {
        // Initialize core systems
        self.ecsManager = ECSManager()
        self.gameLoop = GameLoop(targetFrameRate: 90.0)
        self.spatialManager = SpatialEnvironmentManager()
        self.networkManager = NetworkManager()
        self.audioManager = SpatialAudioManager()
        self.inputManager = SpatialInputManager()

        setupSystems()
    }

    // MARK: - Setup

    private func setupSystems() {
        // Register game systems with ECS manager
        ecsManager.registerSystem(CombatSystem())
        ecsManager.registerSystem(MovementSystem())
        ecsManager.registerSystem(AISystem())
        ecsManager.registerSystem(WeaponSystem())
        ecsManager.registerSystem(ProjectileSystem())

        // Configure game loop callbacks
        gameLoop.onUpdate = { [weak self] deltaTime in
            await self?.update(deltaTime: deltaTime)
        }
    }

    // MARK: - State Management

    func transitionToState(_ newState: GameState) async {
        await exitCurrentState()

        gameState = newState

        await enterNewState()
    }

    private func exitCurrentState() async {
        switch gameState {
        case .inMatch:
            await cleanupMatch()
        case .training:
            await cleanupTraining()
        default:
            break
        }
    }

    private func enterNewState() async {
        switch gameState {
        case .boot:
            await initializeGame()
        case .mainMenu:
            break
        case .matchmaking:
            await startMatchmaking()
        case .inMatch(let state):
            await setupMatch(state: state)
        case .training:
            await setupTraining()
        case .postMatch:
            await showPostMatchSummary()
        case .settings:
            break
        }
    }

    // MARK: - Game Initialization

    private func initializeGame() async {
        isLoading = true

        do {
            // Initialize ARKit session
            try await spatialManager.initializeARSession()

            // Setup audio engine
            try await audioManager.setup()

            // Load game data
            await loadGameData()

            // Transition to main menu
            await transitionToState(.mainMenu)

        } catch {
            errorMessage = "Failed to initialize game: \(error.localizedDescription)"
        }

        isLoading = false
    }

    private func loadGameData() async {
        // Load weapon definitions
        await WeaponDataManager.shared.loadWeaponDefinitions()

        // Load map data
        await MapDataManager.shared.loadMaps()

        // Load player progression
        // Handled by AppState
    }

    // MARK: - Matchmaking

    func startMatchmaking(mode: GameMode = .competitive) async {
        await transitionToState(.matchmaking)

        do {
            let matchTicket = MatchmakingTicket(
                playerID: UUID(), // TODO: Get from AppState
                skillRating: 1000, // TODO: Get from player
                preferredMode: mode
            )

            let match = try await networkManager.findMatch(ticket: matchTicket)

            // Found a match, transition to in-match
            let matchState = MatchState.warmup
            await transitionToState(.inMatch(matchState))

        } catch {
            errorMessage = "Matchmaking failed: \(error.localizedDescription)"
            await transitionToState(.mainMenu)
        }
    }

    // MARK: - Match Management

    private func setupMatch(state: MatchState) async {
        isLoading = true

        do {
            // Setup spatial environment
            try await spatialManager.analyzeRoom()

            // Connect to game server
            try await networkManager.connectToMatch()

            // Load map
            let map = await MapDataManager.shared.getCurrentMap()
            await loadMap(map)

            // Setup players
            await setupPlayers()

            // Start game loop
            gameLoop.start()

            matchState = state

        } catch {
            errorMessage = "Failed to setup match: \(error.localizedDescription)"
            await transitionToState(.mainMenu)
        }

        isLoading = false
    }

    private func loadMap(_ map: GameMap) async {
        // TODO: Load map geometry and setup scene
    }

    private func setupPlayers() async {
        // TODO: Spawn players at spawn points
    }

    private func cleanupMatch() async {
        gameLoop.stop()
        await networkManager.disconnectFromMatch()
        ecsManager.clearAllEntities()
    }

    // MARK: - Training Mode

    func startTraining(scenario: TrainingScenario) async {
        await transitionToState(.training)

        do {
            try await spatialManager.analyzeRoom()
            await setupTrainingScenario(scenario)
            gameLoop.start()
        } catch {
            errorMessage = "Failed to start training: \(error.localizedDescription)"
            await transitionToState(.mainMenu)
        }
    }

    private func setupTraining() async {
        // Setup default training scenario
        await setupTrainingScenario(.aimTraining)
    }

    private func setupTrainingScenario(_ scenario: TrainingScenario) async {
        // TODO: Setup training scenario
    }

    private func cleanupTraining() async {
        gameLoop.stop()
        ecsManager.clearAllEntities()
    }

    // MARK: - Game Loop Update

    private func update(deltaTime: TimeInterval) async {
        // Update input
        await inputManager.update(deltaTime: deltaTime)

        // Update ECS systems
        await ecsManager.update(deltaTime: deltaTime)

        // Update spatial audio
        await audioManager.update(listenerPosition: getPlayerPosition())

        // Update network
        if networkManager.isConnected {
            await networkManager.update(deltaTime: deltaTime)
        }
    }

    // MARK: - Helpers

    private func getPlayerPosition() -> SIMD3<Float> {
        // TODO: Get actual player position
        return SIMD3<Float>(0, 1.7, 0)  // Default head height
    }

    private func showPostMatchSummary() async {
        // TODO: Display match summary
    }

    // MARK: - Public API

    func quitToMainMenu() async {
        await transitionToState(.mainMenu)
    }

    func exitGame() {
        gameLoop.stop()
        // Cleanup resources
    }
}

/// Game state enumeration
enum GameState: Equatable {
    case boot
    case mainMenu
    case matchmaking
    case training
    case inMatch(MatchState)
    case postMatch
    case settings
}

/// Match state during gameplay
enum MatchState: Equatable {
    case warmup
    case buyPhase
    case tacticalPhase
    case combatActive
    case roundEnd
    case matchEnd
}

/// Game modes available
enum GameMode: String, Codable {
    case competitive
    case casual
    case training
    case custom
}

/// Training scenarios
enum TrainingScenario {
    case aimTraining
    case movementTraining
    case tacticalScenario
    case weaponMastery
}
