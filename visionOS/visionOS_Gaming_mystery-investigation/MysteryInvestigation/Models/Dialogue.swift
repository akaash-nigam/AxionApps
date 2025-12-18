import Foundation

/// Dialogue tree system for suspect interrogations
struct DialogueTree: Codable {
    var rootNodeID: UUID
    var nodes: [UUID: DialogueNode]
    var currentNodeID: UUID

    mutating func advance(to nodeID: UUID) {
        currentNodeID = nodeID
    }

    func getCurrentNode() -> DialogueNode? {
        return nodes[currentNodeID]
    }
}

/// Individual dialogue node
struct DialogueNode: Codable, Identifiable {
    let id: UUID
    let text: String
    let speaker: Speaker
    var responses: [DialogueResponse]
    var conditions: [DialogueCondition]
    var effects: [DialogueEffect]
    var emotionalState: EmotionalState?

    enum Speaker: Codable {
        case player
        case suspect(UUID)
        case witness(UUID)
        case narrator
    }
}

/// Player dialogue choice/response
struct DialogueResponse: Codable, Identifiable {
    let id: UUID
    let text: String
    let nextNodeID: UUID?
    var requiredEvidence: [UUID]?
    var stressImpact: Float  // How much pressure this adds (-1.0 to 1.0)
    var emotionalTone: EmotionalTone
    var requiresSkillLevel: DetectiveRank?

    enum EmotionalTone: String, Codable {
        case neutral
        case friendly
        case aggressive
        case skeptical
        case empathetic
        case accusatory
    }

    func isAvailable(playerRank: DetectiveRank, collectedEvidence: [UUID]) -> Bool {
        // Check skill requirement
        if let required = requiresSkillLevel {
            guard playerRank.rawValue >= required.rawValue else {
                return false
            }
        }

        // Check evidence requirement
        if let required = requiredEvidence {
            return required.allSatisfy { collectedEvidence.contains($0) }
        }

        return true
    }
}

/// Condition for showing dialogue
struct DialogueCondition: Codable {
    var type: ConditionType
    var value: String?

    enum ConditionType: String, Codable {
        case hasEvidence
        case suspectStressAbove
        case timeElapsed
        case previousResponse
        case interrogationCount
    }

    func isMet(context: InterrogationContext) -> Bool {
        switch type {
        case .hasEvidence:
            guard let evidenceID = UUID(uuidString: value ?? "") else { return false }
            return context.collectedEvidence.contains(evidenceID)

        case .suspectStressAbove:
            guard let threshold = Float(value ?? "0") else { return false }
            return context.suspectStress >= threshold

        case .timeElapsed:
            guard let duration = TimeInterval(value ?? "0") else { return false }
            let elapsed = Date().timeIntervalSince(context.interrogationStartTime)
            return elapsed >= duration

        case .previousResponse:
            guard let responseID = UUID(uuidString: value ?? "") else { return false }
            return context.previousResponses.contains(responseID)

        case .interrogationCount:
            guard let count = Int(value ?? "0") else { return false }
            return context.interrogationCount >= count
        }
    }
}

/// Effect of dialogue choice
struct DialogueEffect: Codable {
    var type: EffectType
    var value: String

    enum EffectType: String, Codable {
        case increaseStress
        case decreaseStress
        case revealInformation
        case changeEmotion
        case triggerConfession
        case improveTrust
        case damageRelationship
    }

    func apply(to context: inout SuspectState) {
        switch type {
        case .increaseStress:
            if let amount = Float(value) {
                context.stressLevel = min(1.0, context.stressLevel + amount)
            }

        case .decreaseStress:
            if let amount = Float(value) {
                context.stressLevel = max(0.0, context.stressLevel - amount)
            }

        case .changeEmotion:
            if let emotion = EmotionalState(rawValue: value) {
                context.currentEmotion = emotion
            }

        case .improveTrust:
            if let amount = Float(value) {
                context.trustLevel = min(1.0, context.trustLevel + amount)
            }

        case .damageRelationship:
            if let amount = Float(value) {
                context.trustLevel = max(0.0, context.trustLevel - amount)
            }

        default:
            break
        }
    }
}

/// Suspect's emotional state during interrogation
enum EmotionalState: String, Codable {
    case calm
    case nervous
    case defensive
    case aggressive
    case guilty
    case confused
    case cooperative
    case hostile
}

/// Suspect state during interrogation
struct SuspectState: Codable {
    var suspectID: UUID
    var stressLevel: Float = 0.0  // 0.0 - 1.0
    var trustLevel: Float = 0.5  // 0.0 - 1.0
    var currentEmotion: EmotionalState = .calm
    var isLying: Bool = false
    var contradictionCount: Int = 0
    var interrogationDuration: TimeInterval = 0

    mutating func updateEmotion() {
        switch stressLevel {
        case 0.0..<0.3:
            currentEmotion = trustLevel > 0.6 ? .cooperative : .calm
        case 0.3..<0.6:
            currentEmotion = .nervous
        case 0.6..<0.8:
            currentEmotion = .defensive
        case 0.8...1.0:
            currentEmotion = isLying ? .guilty : .aggressive
        default:
            currentEmotion = .confused
        }
    }
}

/// Context for evaluating dialogue conditions
struct InterrogationContext {
    let collectedEvidence: [UUID]
    let suspectStress: Float
    let interrogationStartTime: Date
    let previousResponses: [UUID]
    let interrogationCount: Int
}
