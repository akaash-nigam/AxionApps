import SwiftUI
import RealityKit

/// Main app model managing global state
@Observable
@MainActor
class AppModel {
    // MARK: - State
    var currentState: AppState = .mainMenu
    var isImmersiveSpaceShown = false

    // MARK: - Managers
    let gameStateManager: GameStateManager
    let storyManager: StoryManager
    let saveSystem: SaveSystem

    // MARK: - Initialization
    init() {
        self.gameStateManager = GameStateManager()
        self.storyManager = StoryManager()
        self.saveSystem = SaveSystem()
    }

    // MARK: - State Transitions
    func startNewStory() async {
        currentState = .preparingStory
        await storyManager.loadEpisode(1)
        currentState = .playingStory
    }

    func continueStory() async {
        guard let saveData = await saveSystem.loadLatestSave() else {
            return
        }
        currentState = .loadingStory
        await storyManager.restoreFrom(saveData)
        currentState = .playingStory
    }

    func pauseStory() {
        currentState = .paused
        Task {
            await saveSystem.autoSave(storyManager.getCurrentState())
        }
    }

    func resumeStory() {
        currentState = .playingStory
    }

    func exitToMenu() {
        currentState = .mainMenu
        isImmersiveSpaceShown = false
    }
}

// MARK: - App State
enum AppState {
    case mainMenu
    case preparingStory
    case loadingStory
    case playingStory
    case paused
    case settings
}
