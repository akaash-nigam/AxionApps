import Foundation

/// Represents the branching narrative structure of a performance
struct NarrativeGraph: Codable, Sendable {
    let nodes: [NarrativeNode]
    let edges: [NarrativeEdge]
    let startNodeID: UUID
    let endNodeIDs: [UUID]

    init(
        nodes: [NarrativeNode],
        edges: [NarrativeEdge],
        startNodeID: UUID,
        endNodeIDs: [UUID]
    ) {
        self.nodes = nodes
        self.edges = edges
        self.startNodeID = startNodeID
        self.endNodeIDs = endNodeIDs
    }

    /// Find a node by ID
    func findNode(id: UUID) -> NarrativeNode? {
        nodes.first { $0.id == id }
    }

    /// Get all outgoing edges from a node
    func getOutgoingEdges(from nodeID: UUID) -> [NarrativeEdge] {
        edges.filter { $0.fromNodeID == nodeID }
    }

    /// Get the next node based on a choice
    func getNextNode(from currentNodeID: UUID, choiceID: UUID) -> NarrativeNode? {
        guard let edge = edges.first(where: { $0.fromNodeID == currentNodeID && $0.choiceID == choiceID }) else {
            return nil
        }
        return findNode(id: edge.toNodeID)
    }
}

struct NarrativeNode: Codable, Identifiable, Sendable {
    let id: UUID
    let type: NodeType
    let sceneData: SceneData
    let requiredChoices: [UUID]? // Previous choice IDs required to reach this node
    let characterStates: [UUID: CharacterState]

    init(
        id: UUID = UUID(),
        type: NodeType,
        sceneData: SceneData,
        requiredChoices: [UUID]? = nil,
        characterStates: [UUID: CharacterState] = [:]
    ) {
        self.id = id
        self.type = type
        self.sceneData = sceneData
        self.requiredChoices = requiredChoices
        self.characterStates = characterStates
    }
}

enum NodeType: String, Codable, Sendable {
    case scene          // Standard performance scene
    case choicePoint    // Player decision moment
    case branch         // Narrative divergence
    case convergence    // Paths rejoin
    case ending         // Performance conclusion
}

struct SceneData: Codable, Sendable {
    let title: String
    let description: String
    let duration: TimeInterval
    let settingID: UUID
    let charactersPresent: [UUID]
    let dialogueSequence: [DialogueEntry]
    let interactiveMoments: [InteractiveMoment]

    init(
        title: String,
        description: String,
        duration: TimeInterval,
        settingID: UUID,
        charactersPresent: [UUID],
        dialogueSequence: [DialogueEntry],
        interactiveMoments: [InteractiveMoment]
    ) {
        self.title = title
        self.description = description
        self.duration = duration
        self.settingID = settingID
        self.charactersPresent = charactersPresent
        self.dialogueSequence = dialogueSequence
        self.interactiveMoments = interactiveMoments
    }
}

struct DialogueEntry: Codable, Identifiable, Sendable {
    let id: UUID
    let characterID: UUID
    let text: String
    let emotion: Emotion
    let timing: TimeInterval // When in scene this occurs
}

struct InteractiveMoment: Codable, Identifiable, Sendable {
    let id: UUID
    let type: InteractionType
    let timing: TimeInterval
    let prompt: String
    let options: [InteractionOption]
}

enum InteractionType: String, Codable, Sendable {
    case dialogue       // Choose what to say
    case action         // Choose what to do
    case observation    // Choose where to focus
    case moral          // Moral/ethical decision
}

struct InteractionOption: Codable, Identifiable, Sendable {
    let id: UUID
    let text: String
    let choiceType: ChoiceType
    let consequences: [Consequence]
}

enum ChoiceType: String, Codable, Sendable {
    case honest
    case deceptive
    case aggressive
    case peaceful
    case empathetic
    case logical
}

struct Consequence: Codable, Sendable {
    let type: ConsequenceType
    let targetID: UUID? // Character or narrative element affected
    let magnitude: Float // -1.0 to 1.0
    let description: String
}

enum ConsequenceType: String, Codable, Sendable {
    case relationshipChange
    case emotionalShift
    case narrativeBranch
    case characterAction
    case environmentChange
}

struct CharacterState: Codable, Sendable {
    let characterID: UUID
    let emotion: Emotion
    let objective: String
    let position: String // Stage position description
}

struct NarrativeEdge: Codable, Identifiable, Sendable {
    let id: UUID
    let fromNodeID: UUID
    let toNodeID: UUID
    let choiceID: UUID? // If triggered by player choice
    let condition: String? // Narrative condition description

    init(
        id: UUID = UUID(),
        fromNodeID: UUID,
        toNodeID: UUID,
        choiceID: UUID? = nil,
        condition: String? = nil
    ) {
        self.id = id
        self.fromNodeID = fromNodeID
        self.toNodeID = toNodeID
        self.choiceID = choiceID
        self.condition = condition
    }
}
