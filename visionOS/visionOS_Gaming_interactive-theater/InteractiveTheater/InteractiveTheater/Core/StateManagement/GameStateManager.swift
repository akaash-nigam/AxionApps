import Foundation
import Observation

/// Central state manager for game performance
@MainActor
@Observable
class GameStateManager: ObservableObject {
    // MARK: - Performance States
    enum PerformanceState: Equatable {
        case initialization
        case characterIntroduction
        case activePerformance
        case decisionPoint(choiceID: UUID)
        case sceneTransition
        case performanceComplete
        case paused
    }

    // MARK: - State Properties
    var currentState: PerformanceState = .initialization
    var currentScene: NarrativeNode?
    var activeCharacters: [UUID] = []
    var narrativeState: NarrativeState
    var playerChoices: [PlayerChoice] = []
    var performanceProgress: PerformanceProgress

    // Performance reference
    let performance: PerformanceData

    // MARK: - Initialization
    init(performance: PerformanceData) {
        self.performance = performance

        // Initialize narrative state at start node
        let startNode = performance.narrativeGraph.nodes.first { $0.id == performance.narrativeGraph.startNodeID }
        self.narrativeState = NarrativeState(
            currentNodeID: performance.narrativeGraph.startNodeID,
            completedNodes: [],
            narrativeGraph: performance.narrativeGraph
        )

        self.performanceProgress = PerformanceProgress(
            totalTime: 0,
            currentAct: 1,
            currentScene: 1
        )

        self.currentScene = startNode
    }

    // MARK: - State Transitions

    /// Transition to a new state
    func transitionTo(_ newState: PerformanceState) {
        // Validate transition
        guard isValidTransition(from: currentState, to: newState) else {
            print("Invalid state transition attempted from \(currentState) to \(newState)")
            return
        }

        // Execute exit handler for current state
        onExitState(currentState)

        // Update state
        let previousState = currentState
        currentState = newState

        // Execute entry handler for new state
        onEnterState(newState, from: previousState)
    }

    /// Validate if a state transition is allowed
    private func isValidTransition(from current: PerformanceState, to new: PerformanceState) -> Bool {
        switch (current, new) {
        case (.initialization, .characterIntroduction):
            return true
        case (.characterIntroduction, .activePerformance):
            return true
        case (.activePerformance, .decisionPoint):
            return true
        case (.decisionPoint, .activePerformance):
            return true
        case (.activePerformance, .sceneTransition):
            return true
        case (.sceneTransition, .activePerformance):
            return true
        case (.activePerformance, .performanceComplete):
            return true
        case (_, .paused):
            return current != .initialization && current != .performanceComplete
        case (.paused, _):
            return new != .initialization
        default:
            return false
        }
    }

    /// Handle state exit
    private func onExitState(_ state: PerformanceState) {
        switch state {
        case .activePerformance:
            // Save progress
            break
        case .decisionPoint:
            // Record decision time
            break
        default:
            break
        }
    }

    /// Handle state entry
    private func onEnterState(_ state: PerformanceState, from previousState: PerformanceState) {
        switch state {
        case .initialization:
            initializePerformance()
        case .characterIntroduction:
            introduceCharacters()
        case .activePerformance:
            resumePerformance()
        case .decisionPoint(let choiceID):
            presentChoice(choiceID)
        case .sceneTransition:
            transitionScene()
        case .performanceComplete:
            concludePerformance()
        case .paused:
            pausePerformance()
        }
    }

    // MARK: - State Handlers

    private func initializePerformance() {
        // Setup performance environment
        print("Initializing performance: \(performance.title)")
    }

    private func introduceCharacters() {
        // Present main characters
        print("Introducing characters")
    }

    private func resumePerformance() {
        // Continue scene playback
        print("Resuming performance")
    }

    private func presentChoice(_ choiceID: UUID) {
        // Display choice UI to player
        print("Presenting choice: \(choiceID)")
    }

    private func transitionScene() {
        // Transition to next scene
        print("Transitioning scene")
    }

    private func concludePerformance() {
        // Show ending and credits
        print("Performance complete")
    }

    private func pausePerformance() {
        // Pause all systems
        print("Performance paused")
    }

    // MARK: - Player Actions

    /// Record a player choice
    func recordChoice(_ choice: PlayerChoice) {
        playerChoices.append(choice)

        // Update narrative state based on choice
        narrativeState.processChoice(choice.selectedOptionID)

        // Move to next node if available
        if let nextNode = performance.narrativeGraph.getNextNode(
            from: narrativeState.currentNodeID,
            choiceID: choice.choiceID
        ) {
            advanceToNode(nextNode)
        }
    }

    /// Advance to a specific narrative node
    func advanceToNode(_ node: NarrativeNode) {
        narrativeState.advanceToNode(node.id)
        currentScene = node

        // Update active characters based on new scene
        activeCharacters = node.sceneData.charactersPresent

        // Check if this is an ending node
        if performance.narrativeGraph.endNodeIDs.contains(node.id) {
            transitionTo(.performanceComplete)
        } else {
            transitionTo(.activePerformance)
        }
    }

    /// Update performance progress time
    func updateProgress(deltaTime: TimeInterval) {
        performanceProgress.totalTime += deltaTime
    }

    // MARK: - Save/Load

    /// Create save data from current state
    func createSaveData() -> SaveData {
        return SaveData(
            performanceID: performance.id,
            performanceTitle: performance.title,
            currentNodeID: narrativeState.currentNodeID,
            completedNodes: Array(narrativeState.completedNodes),
            choiceHistory: playerChoices,
            playthroughNumber: 1, // TODO: Track playthrough number
            characterStates: [:], // TODO: Capture character states
            relationshipStates: [:], // TODO: Capture relationships
            totalPlayTime: performanceProgress.totalTime,
            decisionPoints: playerChoices.count,
            explorationType: .pragmatic // TODO: Calculate based on choices
        )
    }

    /// Restore from save data
    func restore(from saveData: SaveData) {
        // Restore narrative position
        narrativeState = NarrativeState(
            currentNodeID: saveData.currentNodeID,
            completedNodes: Set(saveData.completedNodes),
            narrativeGraph: performance.narrativeGraph
        )

        // Restore player choices
        playerChoices = saveData.choiceHistory

        // Restore progress
        performanceProgress.totalTime = saveData.totalPlayTime

        // Restore current scene
        currentScene = performance.narrativeGraph.findNode(id: saveData.currentNodeID)
    }
}

// MARK: - Supporting Types

struct NarrativeState {
    var currentNodeID: UUID
    var completedNodes: Set<UUID>
    let narrativeGraph: NarrativeGraph

    init(currentNodeID: UUID, completedNodes: Set<UUID> = [], narrativeGraph: NarrativeGraph) {
        self.currentNodeID = currentNodeID
        self.completedNodes = completedNodes
        self.narrativeGraph = narrativeGraph
    }

    mutating func advanceToNode(_ nodeID: UUID) {
        completedNodes.insert(currentNodeID)
        currentNodeID = nodeID
    }

    mutating func processChoice(_ choiceID: UUID) {
        // Additional choice processing logic
    }
}

struct PerformanceProgress {
    var totalTime: TimeInterval
    var currentAct: Int
    var currentScene: Int
}
