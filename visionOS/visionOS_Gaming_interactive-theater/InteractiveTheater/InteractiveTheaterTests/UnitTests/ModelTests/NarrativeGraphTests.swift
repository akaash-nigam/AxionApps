import XCTest
@testable import InteractiveTheater

/// Unit tests for NarrativeGraph and related types
final class NarrativeGraphTests: XCTestCase {

    // MARK: - Test NarrativeGraph Creation

    func testNarrativeGraphCreation() {
        let startNodeID = UUID()
        let endNodeID = UUID()

        let graph = NarrativeGraph(
            nodes: [],
            edges: [],
            startNodeID: startNodeID,
            endNodeIDs: [endNodeID]
        )

        XCTAssertEqual(graph.startNodeID, startNodeID)
        XCTAssertEqual(graph.endNodeIDs.count, 1)
        XCTAssertEqual(graph.endNodeIDs.first, endNodeID)
        XCTAssertTrue(graph.nodes.isEmpty)
        XCTAssertTrue(graph.edges.isEmpty)
    }

    // MARK: - Test Finding Nodes

    func testFindNodeByID() {
        let nodeID = UUID()
        let node = createTestNode(id: nodeID, title: "Test Node")
        let graph = NarrativeGraph(
            nodes: [node],
            edges: [],
            startNodeID: nodeID,
            endNodeIDs: []
        )

        let foundNode = graph.findNode(id: nodeID)
        XCTAssertNotNil(foundNode)
        XCTAssertEqual(foundNode?.id, nodeID)
        XCTAssertEqual(foundNode?.sceneData.title, "Test Node")
    }

    func testFindNodeByIDNotFound() {
        let graph = NarrativeGraph(
            nodes: [],
            edges: [],
            startNodeID: UUID(),
            endNodeIDs: []
        )

        let foundNode = graph.findNode(id: UUID())
        XCTAssertNil(foundNode)
    }

    // MARK: - Test Edges

    func testGetOutgoingEdges() {
        let node1ID = UUID()
        let node2ID = UUID()
        let node3ID = UUID()

        let edge1 = NarrativeEdge(fromNodeID: node1ID, toNodeID: node2ID)
        let edge2 = NarrativeEdge(fromNodeID: node1ID, toNodeID: node3ID)
        let edge3 = NarrativeEdge(fromNodeID: node2ID, toNodeID: node3ID)

        let graph = NarrativeGraph(
            nodes: [],
            edges: [edge1, edge2, edge3],
            startNodeID: node1ID,
            endNodeIDs: [node3ID]
        )

        let outgoingFromNode1 = graph.getOutgoingEdges(from: node1ID)
        XCTAssertEqual(outgoingFromNode1.count, 2)

        let outgoingFromNode2 = graph.getOutgoingEdges(from: node2ID)
        XCTAssertEqual(outgoingFromNode2.count, 1)
    }

    // MARK: - Test Navigation

    func testGetNextNodeByChoice() {
        let node1ID = UUID()
        let node2ID = UUID()
        let choiceID = UUID()

        let node1 = createTestNode(id: node1ID, title: "Start")
        let node2 = createTestNode(id: node2ID, title: "Next")

        let edge = NarrativeEdge(
            fromNodeID: node1ID,
            toNodeID: node2ID,
            choiceID: choiceID
        )

        let graph = NarrativeGraph(
            nodes: [node1, node2],
            edges: [edge],
            startNodeID: node1ID,
            endNodeIDs: [node2ID]
        )

        let nextNode = graph.getNextNode(from: node1ID, choiceID: choiceID)
        XCTAssertNotNil(nextNode)
        XCTAssertEqual(nextNode?.id, node2ID)
        XCTAssertEqual(nextNode?.sceneData.title, "Next")
    }

    func testGetNextNodeInvalidChoice() {
        let node1ID = UUID()
        let node2ID = UUID()

        let node1 = createTestNode(id: node1ID, title: "Start")
        let node2 = createTestNode(id: node2ID, title: "Next")

        let edge = NarrativeEdge(
            fromNodeID: node1ID,
            toNodeID: node2ID,
            choiceID: UUID()
        )

        let graph = NarrativeGraph(
            nodes: [node1, node2],
            edges: [edge],
            startNodeID: node1ID,
            endNodeIDs: [node2ID]
        )

        let nextNode = graph.getNextNode(from: node1ID, choiceID: UUID()) // Different choice
        XCTAssertNil(nextNode)
    }

    // MARK: - Test NarrativeNode Types

    func testNarrativeNodeTypes() {
        let sceneNode = createTestNode(id: UUID(), title: "Scene", type: .scene)
        let choiceNode = createTestNode(id: UUID(), title: "Choice", type: .choicePoint)
        let endingNode = createTestNode(id: UUID(), title: "Ending", type: .ending)

        XCTAssertEqual(sceneNode.type, .scene)
        XCTAssertEqual(choiceNode.type, .choicePoint)
        XCTAssertEqual(endingNode.type, .ending)
    }

    // MARK: - Test SceneData

    func testSceneDataCreation() {
        let settingID = UUID()
        let char1ID = UUID()
        let char2ID = UUID()

        let dialogue = DialogueEntry(
            id: UUID(),
            characterID: char1ID,
            text: "To be or not to be",
            emotion: .contemplative,
            timing: 10.0
        )

        let scene = SceneData(
            title: "Hamlet's Soliloquy",
            description: "Hamlet contemplates existence",
            duration: 180.0,
            settingID: settingID,
            charactersPresent: [char1ID, char2ID],
            dialogueSequence: [dialogue],
            interactiveMoments: []
        )

        XCTAssertEqual(scene.title, "Hamlet's Soliloquy")
        XCTAssertEqual(scene.duration, 180.0)
        XCTAssertEqual(scene.charactersPresent.count, 2)
        XCTAssertEqual(scene.dialogueSequence.count, 1)
    }

    // MARK: - Test InteractiveMoment

    func testInteractiveMomentCreation() {
        let option1 = InteractionOption(
            id: UUID(),
            text: "Comfort Hamlet",
            choiceType: .empathetic,
            consequences: []
        )

        let option2 = InteractionOption(
            id: UUID(),
            text: "Challenge Hamlet's thoughts",
            choiceType: .logical,
            consequences: []
        )

        let interaction = InteractiveMoment(
            id: UUID(),
            type: .dialogue,
            timing: 120.0,
            prompt: "How do you respond?",
            options: [option1, option2]
        )

        XCTAssertEqual(interaction.type, .dialogue)
        XCTAssertEqual(interaction.options.count, 2)
        XCTAssertEqual(interaction.prompt, "How do you respond?")
    }

    // MARK: - Test Codable Conformance

    func testNarrativeGraphCodable() throws {
        let node1 = createTestNode(id: UUID(), title: "Start")
        let node2 = createTestNode(id: UUID(), title: "End")

        let edge = NarrativeEdge(
            fromNodeID: node1.id,
            toNodeID: node2.id
        )

        let graph = NarrativeGraph(
            nodes: [node1, node2],
            edges: [edge],
            startNodeID: node1.id,
            endNodeIDs: [node2.id]
        )

        // Encode
        let encoder = JSONEncoder()
        let data = try encoder.encode(graph)

        // Decode
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(NarrativeGraph.self, from: data)

        XCTAssertEqual(graph.nodes.count, decoded.nodes.count)
        XCTAssertEqual(graph.edges.count, decoded.edges.count)
        XCTAssertEqual(graph.startNodeID, decoded.startNodeID)
    }

    // MARK: - Helper Methods

    private func createTestNode(id: UUID, title: String, type: NodeType = .scene) -> NarrativeNode {
        let sceneData = SceneData(
            title: title,
            description: "Test scene",
            duration: 60.0,
            settingID: UUID(),
            charactersPresent: [],
            dialogueSequence: [],
            interactiveMoments: []
        )

        return NarrativeNode(
            id: id,
            type: type,
            sceneData: sceneData
        )
    }
}

// Extension to support contemplative emotion
extension Emotion {
    static let contemplative: Emotion = .anxiety // Using existing emotion for test
}
