import Foundation
import Observation

/// Coordinates the overall game state and manages transitions between game phases
/// Uses Swift's Observation framework for reactive state updates
@Observable
final class GameCoordinator {
    // MARK: - Properties

    /// Current game state
    var gameState: GameState

    /// Current game phase
    var currentPhase: GamePhase = .startup

    /// Selected building tool
    var selectedTool: BuildingTool?

    /// Simulation speed multiplier
    var simulationSpeed: SimulationSpeed = .normal

    /// Is the game paused?
    var isPaused: Bool = false

    // MARK: - Initialization

    init() {
        self.gameState = GameState()
    }

    // MARK: - Public Methods

    /// Start a new city
    func startNewCity(name: String) {
        gameState = GameState()
        gameState.cityData.name = name
        currentPhase = .surfaceDetection
    }

    /// Load existing city
    func loadCity(_ cityData: CityData) {
        gameState.cityData = cityData
        currentPhase = .simulation
    }

    /// Transition to next game phase
    func transitionToPhase(_ phase: GamePhase) {
        currentPhase = phase
    }

    /// Toggle pause state
    func togglePause() {
        isPaused.toggle()
    }

    /// Set simulation speed
    func setSimulationSpeed(_ speed: SimulationSpeed) {
        simulationSpeed = speed
    }

    /// Select a building tool
    func selectTool(_ tool: BuildingTool) {
        selectedTool = tool
    }

    /// Deselect current tool
    func deselectTool() {
        selectedTool = nil
    }
}

// MARK: - Game Phase

/// Represents the current phase of the game
enum GamePhase {
    case startup
    case surfaceDetection
    case cityPlanning
    case simulation
    case paused
    case multiplayer
}

// MARK: - Building Tool

/// Tools available for city building
enum BuildingTool {
    case zone(ZoneType)
    case road
    case building(BuildingType)
    case delete
    case inspect
}

// MARK: - Simulation Speed

/// Simulation speed multipliers
enum SimulationSpeed: Float {
    case paused = 0.0
    case slow = 0.5
    case normal = 1.0
    case fast = 2.0
    case ultraFast = 5.0

    var displayName: String {
        switch self {
        case .paused: return "Paused"
        case .slow: return "Slow (0.5x)"
        case .normal: return "Normal (1x)"
        case .fast: return "Fast (2x)"
        case .ultraFast: return "Ultra Fast (5x)"
        }
    }
}
