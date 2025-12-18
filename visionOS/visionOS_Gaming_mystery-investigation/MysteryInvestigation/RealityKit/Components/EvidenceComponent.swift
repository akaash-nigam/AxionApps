//
//  EvidenceComponent.swift
//  Mystery Investigation
//
//  RealityKit component for evidence entities
//

import RealityKit

/// Component that marks an entity as evidence
struct EvidenceComponent: Component {
    var evidenceData: Evidence
    var isDiscovered: Bool = false
    var examinationProgress: Float = 0.0
    var highlightState: HighlightState = .none

    enum HighlightState {
        case none
        case nearby
        case gazed
        case selected
        case examined
    }
}

/// Component for interactive elements
struct InteractiveComponent: Component {
    var interactionType: InteractionType
    var isEnabled: Bool = true
    var interactionRadius: Float = 0.5 // meters

    enum InteractionType {
        case pickup
        case examine
        case use
        case toggle
        case combine
    }
}

/// Component for suspect holograms
struct HologramComponent: Component {
    var suspectData: Suspect
    var animationState: AnimationState
    var dialogueState: DialogueState
    var currentStressLevel: Float

    init(suspectData: Suspect) {
        self.suspectData = suspectData
        self.animationState = .idle
        self.dialogueState = .waiting
        self.currentStressLevel = suspectData.personality.baseStressLevel
    }

    enum AnimationState {
        case idle
        case talking
        case nervous
        case defensive
        case cooperative
        case confession
    }

    enum DialogueState {
        case waiting
        case speaking
        case listening
        case interrupted
    }

    mutating func increaseStress(by amount: Float) {
        currentStressLevel = min(1.0, currentStressLevel + amount)

        // Update animation state based on stress
        if currentStressLevel > 0.8 {
            animationState = .nervous
        } else if currentStressLevel > 0.5 {
            animationState = .defensive
        }

        // Check for confession
        if currentStressLevel >= suspectData.personality.confessionThreshold {
            animationState = .confession
        }
    }
}

/// Convenience type for evidence entities
typealias EvidenceEntity = Entity
