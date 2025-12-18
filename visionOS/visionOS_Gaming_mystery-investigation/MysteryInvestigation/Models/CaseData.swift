//
//  CaseData.swift
//  Mystery Investigation
//
//  Core data models for cases, evidence, and suspects
//

import Foundation
import RealityKit

// MARK: - Case Data

struct CaseData: Codable, Identifiable {
    let id: UUID
    let title: String
    let description: String
    let difficulty: Difficulty
    let estimatedTime: TimeInterval // in seconds

    let narrative: CaseNarrative
    let suspects: [Suspect]
    let evidence: [Evidence]
    let solution: CaseSolution
    let timelineEvents: [TimelineEvent]

    var difficultyStars: Int {
        switch difficulty {
        case .tutorial: return 1
        case .beginner: return 2
        case .intermediate: return 3
        case .advanced: return 4
        case .expert: return 5
        }
    }

    enum Difficulty: String, Codable {
        case tutorial
        case beginner
        case intermediate
        case advanced
        case expert
    }
}

// MARK: - Case Narrative

struct CaseNarrative: Codable {
    let briefing: String
    let victimBackground: String
    let initialReport: String
    let crimeSetting: String
    let unlockableClues: [UnlockableClue]
}

struct UnlockableClue: Codable, Identifiable {
    let id: UUID
    let text: String
    let requiresEvidence: [UUID] // Evidence IDs needed to unlock
}

// MARK: - Evidence

struct Evidence: Codable, Identifiable {
    let id: UUID
    let type: EvidenceType
    let name: String
    let description: String
    let detailedDescription: String

    // Spatial information
    let spatialAnchor: SpatialAnchorData

    // Game mechanics
    let isRedHerring: Bool
    let relatedSuspects: [UUID]
    let requiresTool: ForensicTool?
    let forensicData: ForensicData?

    // Discovery
    let discoveryDifficulty: DiscoveryDifficulty
    let hintText: String?

    enum EvidenceType: String, Codable {
        case fingerprint
        case dna
        case weapon
        case document
        case photograph
        case fiber
        case footprint
        case bloodSpatter
        case digitalEvidence
        case testimony
        case miscellaneous
    }

    enum DiscoveryDifficulty: String, Codable {
        case obvious      // Highlighted, easy to find
        case moderate     // Requires some searching
        case hidden       // Requires careful exploration
        case toolRequired // Needs forensic tool
    }
}

// MARK: - Spatial Anchor Data

struct SpatialAnchorData: Codable {
    let persistenceKey: String
    let surfaceType: SurfaceType
    let relativePosition: SIMD3<Float>
    let scale: Float

    enum SurfaceType: String, Codable {
        case floor
        case wall
        case table
        case ceiling
        case custom
    }
}

// MARK: - Forensic Data

struct ForensicData: Codable {
    let analysisType: String
    let results: [String: String]
    let conclusionText: String
    let requiredTool: ForensicTool
}

enum ForensicTool: String, Codable {
    case magnifyingGlass
    case uvLight
    case fingerprintKit
    case dnaAnalyzer
    case photographicDocumentation
}

// MARK: - Suspect

struct Suspect: Codable, Identifiable {
    let id: UUID
    let name: String
    let age: Int
    let occupation: String
    let relationship: String // to victim
    let alibi: String

    let personality: PersonalityProfile
    let appearance: AppearanceData
    let dialogueTreeID: UUID

    let isGuilty: Bool
    let motivations: [String]
    let secretsToHide: [String]
}

// MARK: - Personality Profile

struct PersonalityProfile: Codable {
    let traits: [String]
    let baseStressLevel: Float // 0-1
    let truthfulness: Float // 0-1, lower = more deceptive
    let cooperativeness: Float // 0-1
    let confessionThreshold: Float // Stress level at which they confess
}

// MARK: - Appearance Data

struct AppearanceData: Codable {
    let modelName: String // Reference to 3D model
    let height: Float // in meters
    let description: String
    let distinctiveFeatures: [String]
}

// MARK: - Case Solution

struct CaseSolution: Codable {
    let culpritID: UUID
    let motive: String
    let method: String
    let opportunity: String
    let criticalEvidence: [UUID] // Evidence IDs that prove guilt
    let explanationText: String
}

// MARK: - Timeline Event

struct TimelineEvent: Codable, Identifiable {
    let id: UUID
    let timestamp: TimeInterval // Relative to crime time (negative = before, positive = after)
    let location: String
    let description: String
    let participants: [UUID] // Suspect/victim IDs
    let evidenceCreated: [UUID]? // Evidence left behind
    let animationSequence: String? // Reference to animation
}

// MARK: - Investigation Note

struct InvestigationNote: Codable, Identifiable {
    let id: UUID
    var text: String
    let timestamp: Date
    let noteType: NoteType
    var linkedEvidence: [UUID] = []

    enum NoteType: String, Codable {
        case observation
        case theory
        case reminder
        case question
    }
}

// MARK: - Theory

struct Theory: Codable {
    var suspectID: UUID
    var motive: String
    var method: String
    var supportingEvidence: [UUID]
    var confidence: Float // 0-1, calculated based on evidence
}

// MARK: - Player Progress

struct PlayerProgress: Codable {
    var playerID: UUID = UUID()
    var detectiveRank: DetectiveRank = .rookie
    var totalXP: Int = 0
    var completedCases: [UUID: CaseCompletion] = [:]
    var inProgressCases: [UUID: InvestigationProgress] = [:]
    var unlockedTools: Set<String> = []
    var achievements: [Achievement] = []
    var statistics: PlayerStatistics = PlayerStatistics()

    mutating func addCompletedCase(_ caseID: UUID, evaluation: CaseEvaluation) {
        let completion = CaseCompletion(
            caseID: caseID,
            completionDate: Date(),
            evaluation: evaluation
        )
        completedCases[caseID] = completion
        totalXP += evaluation.score
        updateRank()
    }

    private mutating func updateRank() {
        if totalXP >= 50000 {
            detectiveRank = .legendary
        } else if totalXP >= 30000 {
            detectiveRank = .master
        } else if totalXP >= 15000 {
            detectiveRank = .senior
        } else if totalXP >= 5000 {
            detectiveRank = .junior
        } else {
            detectiveRank = .rookie
        }
    }
}

enum DetectiveRank: String, Codable {
    case rookie = "Rookie Detective"
    case junior = "Junior Detective"
    case senior = "Senior Detective"
    case master = "Master Detective"
    case legendary = "Legendary Investigator"
}

struct CaseCompletion: Codable {
    let caseID: UUID
    let completionDate: Date
    let evaluation: CaseEvaluation
}

// Make CaseEvaluation Codable
extension CaseEvaluation: Codable {
    enum CodingKeys: String, CodingKey {
        case correct, score, timeSpent, evidenceCollected, hintsUsed
    }
}

// MARK: - Player Statistics

struct PlayerStatistics: Codable {
    var totalCasesPlayed: Int = 0
    var totalCasesSolved: Int = 0
    var totalPlayTime: TimeInterval = 0
    var averageCaseTime: TimeInterval = 0
    var totalEvidenceCollected: Int = 0
    var totalInterrogations: Int = 0
    var hintsUsedTotal: Int = 0
    var perfectSolves: Int = 0 // S-rank cases
}

// MARK: - Achievement

struct Achievement: Codable, Identifiable {
    let id: UUID
    let name: String
    let description: String
    let iconName: String
    let unlockDate: Date?
    let isUnlocked: Bool

    static let allAchievements: [Achievement] = [
        Achievement(id: UUID(), name: "First Case", description: "Complete your first investigation", iconName: "star.fill", unlockDate: nil, isUnlocked: false),
        Achievement(id: UUID(), name: "Speed Sleuth", description: "Complete a case in under 30 minutes", iconName: "hare.fill", unlockDate: nil, isUnlocked: false),
        Achievement(id: UUID(), name: "Perfectionist", description: "Find all evidence in a case", iconName: "checkmark.seal.fill", unlockDate: nil, isUnlocked: false),
        Achievement(id: UUID(), name: "Master Interrogator", description: "Get a confession without presenting evidence", iconName: "person.fill.questionmark", unlockDate: nil, isUnlocked: false),
    ]
}

// MARK: - Game Settings

struct GameSettings: Codable {
    // Display
    var uiScale: Float = 1.0
    var uiDistance: Float = 1.5 // meters
    var textSize: TextSize = .medium

    // Controls
    var handTrackingEnabled: Bool = true
    var eyeTrackingEnabled: Bool = true
    var voiceCommandsEnabled: Bool = true
    var gazeDwellTime: TimeInterval = 0.5
    var hapticFeedbackStrength: Float = 0.8

    // Audio
    var masterVolume: Float = 0.75
    var musicVolume: Float = 0.6
    var sfxVolume: Float = 0.8
    var dialogueVolume: Float = 0.9
    var spatialAudioEnabled: Bool = true

    // Accessibility
    var colorBlindMode: ColorBlindMode = .none
    var oneHandedMode: Bool = false
    var seatedMode: Bool = false
    var hintFrequency: HintFrequency = .normal
    var contentFilters: ContentFilters = ContentFilters()

    // Gameplay
    var difficulty: DifficultyPreset = .balanced
    var showTutorialHints: Bool = true

    enum TextSize: String, Codable {
        case small, medium, large, extraLarge
    }

    enum ColorBlindMode: String, Codable {
        case none, protanopia, deuteranopia, tritanopia
    }

    enum HintFrequency: String, Codable {
        case none, minimal, normal, frequent
    }

    enum DifficultyPreset: String, Codable {
        case story, balanced, challenging
    }
}

struct ContentFilters: Codable {
    var hideGraphicContent: Bool = false
    var hideViolence: Bool = false
    var educationalModeOnly: Bool = false
}
