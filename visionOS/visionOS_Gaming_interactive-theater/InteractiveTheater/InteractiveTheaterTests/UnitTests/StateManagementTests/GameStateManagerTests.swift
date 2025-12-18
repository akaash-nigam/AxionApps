import XCTest
@testable import InteractiveTheater

/// Unit tests for GameStateManager
@MainActor
final class GameStateManagerTests: XCTestCase {

    var gameState: GameStateManager!
    var testPerformance: PerformanceData!

    override func setUp() async throws {
        testPerformance = createTestPerformance()
        gameState = GameStateManager(performance: testPerformance)
    }

    override func tearDown() async throws {
        gameState = nil
        testPerformance = nil
    }

    // MARK: - Test Initialization

    func testInitialization() {
        XCTAssertEqual(gameState.currentState, .initialization)
        XCTAssertNotNil(gameState.performance)
        XCTAssertEqual(gameState.performance.id, testPerformance.id)
        XCTAssertTrue(gameState.playerChoices.isEmpty)
        XCTAssertEqual(gameState.performanceProgress.totalTime, 0)
    }

    func testNarrativeStateInitialization() {
        let narrativeState = gameState.narrativeState
        XCTAssertEqual(narrativeState.currentNodeID, testPerformance.narrativeGraph.startNodeID)
        XCTAssertTrue(narrativeState.completedNodes.isEmpty)
    }

    // MARK: - Test State Transitions

    func testValidStateTransition() {
        // initialization -> characterIntroduction is valid
        gameState.transitionTo(.characterIntroduction)
        XCTAssertEqual(gameState.currentState, .characterIntroduction)
    }

    func testChainedValidTransitions() {
        gameState.transitionTo(.characterIntroduction)
        XCTAssertEqual(gameState.currentState, .characterIntroduction)

        gameState.transitionTo(.activePerformance)
        XCTAssertEqual(gameState.currentState, .activePerformance)

        let choiceID = UUID()
        gameState.transitionTo(.decisionPoint(choiceID: choiceID))

        if case .decisionPoint(let id) = gameState.currentState {
            XCTAssertEqual(id, choiceID)
        } else {
            XCTFail("Expected decisionPoint state")
        }
    }

    func testInvalidStateTransition() {
        // Cannot go directly from initialization to performanceComplete
        gameState.transitionTo(.performanceComplete)
        XCTAssertEqual(gameState.currentState, .initialization) // Should stay in current state
    }

    func testPauseFromAnyState() {
        gameState.transitionTo(.characterIntroduction)
        gameState.transitionTo(.paused)
        XCTAssertEqual(gameState.currentState, .paused)
    }

    func testResumeFromPause() {
        gameState.transitionTo(.characterIntroduction)
        gameState.transitionTo(.paused)
        gameState.transitionTo(.activePerformance)
        XCTAssertEqual(gameState.currentState, .activePerformance)
    }

    // MARK: - Test Player Choices

    func testRecordChoice() {
        let choice = PlayerChoice(
            choiceID: UUID(),
            selectedOptionID: UUID(),
            choiceContext: "Test choice"
        )

        gameState.recordChoice(choice)

        XCTAssertEqual(gameState.playerChoices.count, 1)
        XCTAssertEqual(gameState.playerChoices.first?.choiceContext, "Test choice")
    }

    func testMultipleChoices() {
        let choice1 = PlayerChoice(choiceID: UUID(), selectedOptionID: UUID(), choiceContext: "Choice 1")
        let choice2 = PlayerChoice(choiceID: UUID(), selectedOptionID: UUID(), choiceContext: "Choice 2")

        gameState.recordChoice(choice1)
        gameState.recordChoice(choice2)

        XCTAssertEqual(gameState.playerChoices.count, 2)
    }

    // MARK: - Test Node Advancement

    func testAdvanceToNode() {
        // Get a test node
        let nodes = testPerformance.narrativeGraph.nodes
        guard nodes.count > 1 else {
            XCTFail("Test performance needs multiple nodes")
            return
        }

        let nextNode = nodes[1]
        gameState.advanceToNode(nextNode)

        XCTAssertEqual(gameState.currentScene?.id, nextNode.id)
        XCTAssertTrue(gameState.narrativeState.completedNodes.contains(testPerformance.narrativeGraph.startNodeID))
    }

    func testAdvanceToEndingNode() {
        // Create ending node
        let endingNodeID = testPerformance.narrativeGraph.endNodeIDs.first!
        let endingNode = testPerformance.narrativeGraph.findNode(id: endingNodeID)!

        gameState.advanceToNode(endingNode)

        XCTAssertEqual(gameState.currentState, .performanceComplete)
    }

    // MARK: - Test Progress Tracking

    func testUpdateProgress() {
        let initialTime = gameState.performanceProgress.totalTime

        gameState.updateProgress(deltaTime: 1.0)
        XCTAssertEqual(gameState.performanceProgress.totalTime, initialTime + 1.0)

        gameState.updateProgress(deltaTime: 2.5)
        XCTAssertEqual(gameState.performanceProgress.totalTime, initialTime + 3.5)
    }

    // MARK: - Test Save/Load

    func testCreateSaveData() {
        // Add some choices
        let choice = PlayerChoice(choiceID: UUID(), selectedOptionID: UUID(), choiceContext: "Test")
        gameState.recordChoice(choice)

        // Update progress
        gameState.updateProgress(deltaTime: 100.0)

        let saveData = gameState.createSaveData()

        XCTAssertEqual(saveData.performanceID, testPerformance.id)
        XCTAssertEqual(saveData.performanceTitle, testPerformance.title)
        XCTAssertEqual(saveData.choiceHistory.count, 1)
        XCTAssertEqual(saveData.totalPlayTime, 100.0)
        XCTAssertEqual(saveData.decisionPoints, 1)
    }

    func testRestoreFromSaveData() {
        // Create save data
        let nodes = testPerformance.narrativeGraph.nodes
        let saveNode = nodes.count > 1 ? nodes[1] : nodes[0]

        let choice = PlayerChoice(choiceID: UUID(), selectedOptionID: UUID(), choiceContext: "Saved choice")
        let saveData = SaveData(
            performanceID: testPerformance.id,
            performanceTitle: testPerformance.title,
            currentNodeID: saveNode.id,
            completedNodes: [testPerformance.narrativeGraph.startNodeID],
            choiceHistory: [choice],
            playthroughNumber: 1,
            characterStates: [:],
            relationshipStates: [:],
            totalPlayTime: 150.0,
            decisionPoints: 1,
            explorationType: .heroic
        )

        gameState.restore(from: saveData)

        XCTAssertEqual(gameState.narrativeState.currentNodeID, saveNode.id)
        XCTAssertEqual(gameState.playerChoices.count, 1)
        XCTAssertEqual(gameState.performanceProgress.totalTime, 150.0)
        XCTAssertEqual(gameState.currentScene?.id, saveNode.id)
    }

    // MARK: - Helper Methods

    private func createTestPerformance() -> PerformanceData {
        let startNodeID = UUID()
        let node2ID = UUID()
        let endNodeID = UUID()

        let sceneData1 = SceneData(
            title: "Opening Scene",
            description: "The story begins",
            duration: 60.0,
            settingID: UUID(),
            charactersPresent: [],
            dialogueSequence: [],
            interactiveMoments: []
        )

        let sceneData2 = SceneData(
            title: "Middle Scene",
            description: "The plot thickens",
            duration: 90.0,
            settingID: UUID(),
            charactersPresent: [],
            dialogueSequence: [],
            interactiveMoments: []
        )

        let sceneData3 = SceneData(
            title: "Ending Scene",
            description: "Conclusion",
            duration: 60.0,
            settingID: UUID(),
            charactersPresent: [],
            dialogueSequence: [],
            interactiveMoments: []
        )

        let node1 = NarrativeNode(id: startNodeID, type: .scene, sceneData: sceneData1)
        let node2 = NarrativeNode(id: node2ID, type: .scene, sceneData: sceneData2)
        let node3 = NarrativeNode(id: endNodeID, type: .ending, sceneData: sceneData3)

        let edge1 = NarrativeEdge(fromNodeID: startNodeID, toNodeID: node2ID)
        let edge2 = NarrativeEdge(fromNodeID: node2ID, toNodeID: endNodeID)

        let narrativeGraph = NarrativeGraph(
            nodes: [node1, node2, node3],
            edges: [edge1, edge2],
            startNodeID: startNodeID,
            endNodeIDs: [endNodeID]
        )

        return PerformanceData(
            title: "Test Performance",
            author: "Test Author",
            genre: .tragedy,
            duration: 210.0,
            acts: [],
            characters: [],
            settings: [],
            ageRating: .everyone,
            culturalContext: CulturalContext(
                culture: "Test",
                timePerio: "Modern",
                geographicLocation: "Test Location",
                culturalNotes: "Test notes"
            ),
            educationalObjectives: [],
            historicalPeriod: .contemporary,
            narrativeGraph: narrativeGraph,
            endings: []
        )
    }
}
