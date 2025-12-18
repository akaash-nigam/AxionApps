import Foundation

/// Manages suspect interrogations and AI-driven dialogue
@MainActor
class InterrogationManager {
    // MARK: - Properties

    private var currentSuspect: Suspect?
    private var suspectState: SuspectState?
    private var dialogueTree: DialogueTree?
    private var interrogationStartTime: Date?
    private var questionHistory: [DialogueResponse] = []
    private var responseHistory: [DialogueNode] = []

    // MARK: - Interrogation Control

    func beginInterrogation(suspect: Suspect) {
        currentSuspect = suspect
        suspectState = SuspectState(suspectID: suspect.id)
        dialogueTree = suspect.dialogue
        interrogationStartTime = Date()
        questionHistory = []
        responseHistory = []

        print("Interrogation started with \(suspect.name)")
    }

    func endInterrogation() -> InterrogationSession {
        guard let suspect = currentSuspect,
              let state = suspectState,
              let startTime = interrogationStartTime else {
            fatalError("No active interrogation to end")
        }

        let session = InterrogationSession(
            id: UUID(),
            suspectID: suspect.id,
            startTime: startTime,
            endTime: Date(),
            questionsAsked: questionHistory,
            responses: responseHistory,
            finalStressLevel: state.stressLevel,
            contradictionsFound: state.contradictionCount
        )

        // Clean up
        currentSuspect = nil
        suspectState = nil
        dialogueTree = nil
        interrogationStartTime = nil

        return session
    }

    // MARK: - Question Processing

    func processQuestion(
        _ question: DialogueResponse,
        to suspect: Suspect,
        withEvidence evidence: [Evidence]
    ) async -> DialogueNode? {
        guard var state = suspectState,
              var tree = dialogueTree else {
            return nil
        }

        // Record question
        questionHistory.append(question)

        // Update suspect stress based on question
        updateStress(for: &state, question: question, evidence: evidence)

        // Apply question effects
        for effect in tree.getCurrentNode()?.effects ?? [] {
            effect.apply(to: &state)
        }

        // Update emotion based on stress
        state.updateEmotion()

        // Generate response
        let response = await generateResponse(
            to: question,
            suspect: suspect,
            state: state,
            evidence: evidence
        )

        // Record response
        if let response = response {
            responseHistory.append(response)
        }

        // Advance dialogue tree
        if let nextID = question.nextNodeID {
            tree.advance(to: nextID)
        }

        // Save updated state
        suspectState = state
        dialogueTree = tree

        return response
    }

    // MARK: - AI Response Generation

    private func generateResponse(
        to question: DialogueResponse,
        suspect: Suspect,
        state: SuspectState,
        evidence: [Evidence]
    ) async -> DialogueNode? {
        // Determine if suspect will lie based on:
        // 1. Their personality
        // 2. Current stress level
        // 3. Evidence presented
        // 4. Whether they're guilty

        let willLie = shouldLie(
            suspect: suspect,
            state: state,
            evidence: evidence,
            questionTone: question.emotionalTone
        )

        // Get next dialogue node
        guard let nextID = question.nextNodeID,
              let nextNode = dialogueTree?.nodes[nextID] else {
            // Generate dynamic response if no scripted dialogue
            return generateDynamicResponse(
                to: question,
                suspect: suspect,
                state: state,
                willLie: willLie
            )
        }

        return nextNode
    }

    private func shouldLie(
        suspect: Suspect,
        state: SuspectState,
        evidence: [Evidence],
        questionTone: DialogueResponse.EmotionalTone
    ) -> Bool {
        // Base lying tendency from profile
        var lyingProbability = suspect.behaviorProfile.lyingTendency

        // Increase if guilty and stressed
        if suspect.isActualCulprit {
            lyingProbability += state.stressLevel * 0.3
        }

        // Decrease if trusted detective (empathetic approach)
        if questionTone == .empathetic {
            lyingProbability -= (state.trustLevel * 0.2)
        }

        // Increase with damning evidence
        let relevantEvidence = evidence.filter { ev in
            ev.relatedSuspects.contains(suspect.id)
        }
        lyingProbability += Float(relevantEvidence.count) * 0.1

        // Random factor
        return Float.random(in: 0...1) < lyingProbability
    }

    private func generateDynamicResponse(
        to question: DialogueResponse,
        suspect: Suspect,
        state: SuspectState,
        willLie: Bool
    ) -> DialogueNode {
        // Generate contextual response based on state and question
        var responseText: String

        switch state.currentEmotion {
        case .calm:
            responseText = willLie ?
                "I can assure you I had nothing to do with this." :
                "I'll tell you everything I know."

        case .nervous:
            responseText = willLie ?
                "I... I don't remember exactly... maybe..." :
                "I'm a bit nervous, but I'll try to help."

        case .defensive:
            responseText = willLie ?
                "Why are you accusing me? I told you I wasn't there!" :
                "Look, I understand you need to ask, but this is difficult."

        case .aggressive:
            responseText = willLie ?
                "This is harassment! I don't have to answer this!" :
                "Fine! You want the truth? Here it is!"

        case .guilty:
            if state.stressLevel > 0.9 {
                responseText = "I... I can't... okay, you got me. I did it."
            } else {
                responseText = willLie ?
                    "I swear I didn't do anything!" :
                    "Maybe I wasn't completely honest before..."
            }

        case .cooperative:
            responseText = "Of course, I want to help in any way I can."

        case .hostile:
            responseText = "I'm done talking to you."

        case .confused:
            responseText = "I'm not sure I understand what you're asking..."
        }

        return DialogueNode(
            id: UUID(),
            text: responseText,
            speaker: .suspect(suspect.id),
            responses: [],  // End of branch
            conditions: [],
            effects: [],
            emotionalState: state.currentEmotion
        )
    }

    // MARK: - Stress Calculation

    private func updateStress(
        for state: inout SuspectState,
        question: DialogueResponse,
        evidence: [Evidence]
    ) {
        var stressIncrease: Float = 0.0

        // Base stress from question tone
        switch question.emotionalTone {
        case .aggressive:
            stressIncrease += 0.15
        case .accusatory:
            stressIncrease += 0.20
        case .skeptical:
            stressIncrease += 0.10
        case .empathetic:
            stressIncrease -= 0.05
        case .friendly:
            stressIncrease -= 0.03
        case .neutral:
            break
        }

        // Stress from damning evidence
        let relevantEvidence = evidence.filter { ev in
            ev.relatedSuspects.contains(state.suspectID)
        }
        stressIncrease += Float(relevantEvidence.count) * 0.1

        // Apply stress impact from question
        stressIncrease += question.stressImpact

        // Apply with diminishing returns
        state.stressLevel = min(1.0, state.stressLevel + stressIncrease * (1.0 - state.stressLevel * 0.5))

        // Track duration
        if let startTime = interrogationStartTime {
            state.interrogationDuration = Date().timeIntervalSince(startTime)

            // Stress increases over time
            let timeFactor = Float(state.interrogationDuration / 600.0)  // Every 10 minutes
            state.stressLevel = min(1.0, state.stressLevel + timeFactor * 0.05)
        }
    }

    // MARK: - Contradiction Detection

    func detectContradiction(
        currentResponse: String,
        previousResponses: [String]
    ) -> [String] {
        var contradictions: [String] = []

        // Simple keyword-based contradiction detection
        // In production, this would use NLP/ML

        let currentLower = currentResponse.lowercased()

        for previous in previousResponses {
            let previousLower = previous.lowercased()

            // Example: Time contradictions
            if currentLower.contains("morning") && previousLower.contains("evening") {
                contradictions.append("Conflicting time statements")
            }

            // Example: Location contradictions
            if currentLower.contains("at home") && previousLower.contains("at work") {
                contradictions.append("Conflicting location statements")
            }

            // Example: Yes/No contradictions
            if currentLower.contains("i didn't") && previousLower.contains("i did") {
                contradictions.append("Direct contradiction in statements")
            }
        }

        // Update contradiction count
        if var state = suspectState {
            state.contradictionCount += contradictions.count
            suspectState = state
        }

        return contradictions
    }

    // MARK: - Analysis

    func analyzeInterrogation() -> InterrogationAnalysis {
        guard let state = suspectState,
              let suspect = currentSuspect else {
            return InterrogationAnalysis(
                suspectID: UUID(),
                likelyGuilty: false,
                confidence: 0.0,
                keyIndicators: [],
                recommendations: []
            )
        }

        // Calculate guilt probability
        var guiltScore: Float = 0.0

        // High stress suggests guilt (if they are actually guilty)
        if suspect.isActualCulprit {
            guiltScore += state.stressLevel * 0.4
        }

        // Contradictions indicate deception
        guiltScore += Float(state.contradictionCount) * 0.15

        // Low trust suggests hiding something
        guiltScore += (1.0 - state.trustLevel) * 0.2

        // Emotional state indicators
        switch state.currentEmotion {
        case .guilty:
            guiltScore += 0.3
        case .defensive, .aggressive:
            guiltScore += 0.15
        case .cooperative:
            guiltScore -= 0.1
        default:
            break
        }

        guiltScore = min(1.0, max(0.0, guiltScore))

        // Generate indicators
        var indicators: [String] = []
        if state.stressLevel > 0.7 {
            indicators.append("High stress levels during questioning")
        }
        if state.contradictionCount > 0 {
            indicators.append("\(state.contradictionCount) contradictions detected")
        }
        if state.currentEmotion == .guilty {
            indicators.append("Displays guilty emotional state")
        }

        // Generate recommendations
        var recommendations: [String] = []
        if state.stressLevel > 0.8 {
            recommendations.append("Suspect is highly stressed - may confess with more pressure")
        }
        if state.contradictionCount > 2 {
            recommendations.append("Multiple contradictions found - present evidence to challenge alibi")
        }

        return InterrogationAnalysis(
            suspectID: suspect.id,
            likelyGuilty: guiltScore > 0.6,
            confidence: guiltScore,
            keyIndicators: indicators,
            recommendations: recommendations
        )
    }
}

// MARK: - Supporting Types

struct InterrogationAnalysis {
    let suspectID: UUID
    let likelyGuilty: Bool
    let confidence: Float
    let keyIndicators: [String]
    let recommendations: [String]
}
