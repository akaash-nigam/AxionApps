//
//  GameCoordinator.swift
//  Mystery Investigation
//
//  Central game controller managing game state and flow
//

import SwiftUI
import RealityKit
import Observation

@Observable
class GameCoordinator {
    // MARK: - Game State
    var currentState: GameState = .mainMenu
    var activeCase: CaseData?
    var progress: InvestigationProgress?

    // MARK: - Managers
    var caseManager: CaseManager
    var evidenceManager: EvidenceManager
    var spatialManager: SpatialMappingManager
    var audioManager: SpatialAudioManager
    var saveManager: SaveGameManager

    // MARK: - Player State
    var playerProgress: PlayerProgress
    var settings: GameSettings

    init() {
        // Initialize managers
        self.caseManager = CaseManager()
        self.evidenceManager = EvidenceManager()
        self.spatialManager = SpatialMappingManager()
        self.audioManager = SpatialAudioManager()
        self.saveManager = SaveGameManager()

        // Load player data
        self.playerProgress = saveManager.loadPlayerProgress() ?? PlayerProgress()
        self.settings = saveManager.loadSettings() ?? GameSettings()
    }

    // MARK: - Game Flow Control

    func startNewCase(_ caseData: CaseData) {
        self.activeCase = caseData
        self.progress = InvestigationProgress(caseID: caseData.id)
        self.currentState = .investigating

        // Play investigation music
        audioManager.playInvestigationMusic()
    }

    func pauseGame() {
        currentState = .paused
        audioManager.pauseMusic()
    }

    func resumeGame() {
        currentState = .investigating
        audioManager.resumeMusic()
    }

    func completeCase(evaluation: CaseEvaluation) {
        guard let activeCase = activeCase else { return }

        // Save completion
        playerProgress.addCompletedCase(activeCase.id, evaluation: evaluation)
        saveManager.savePlayerProgress(playerProgress)

        currentState = .caseComplete
        audioManager.playCaseCompleteMusic()
    }

    func returnToMainMenu() {
        // Save progress if in middle of case
        if let progress = progress {
            saveManager.saveCaseProgress(progress)
        }

        activeCase = nil
        progress = nil
        currentState = .mainMenu
        audioManager.playMenuMusic()
    }

    // MARK: - Evidence Discovery

    func discoverEvidence(_ evidence: Evidence) {
        guard var progress = progress else { return }

        progress.discoveredEvidence.insert(evidence.id)
        self.progress = progress

        // Play discovery sound
        audioManager.playEvidenceDiscovery()

        // Update objectives if needed
        updateObjectives()
    }

    // MARK: - Interrogation

    func startInterrogation(suspect: Suspect) {
        currentState = .interrogating(suspect)
        audioManager.playInterrogationMusic()
    }

    func presentEvidence(_ evidence: Evidence, to suspect: Suspect) {
        // Increase suspect stress if evidence is related
        if evidence.relatedSuspects.contains(suspect.id) {
            // Trigger suspect reaction
            audioManager.playSuspectStressed()
        }
    }

    // MARK: - Case Solution

    func submitSolution(accusedSuspect: UUID, evidence: [UUID], theory: String) -> CaseEvaluation {
        guard let activeCase = activeCase else {
            return CaseEvaluation(correct: false, score: 0)
        }

        // Check if accusation is correct
        let isCorrect = caseManager.validateSolution(
            case: activeCase,
            accusedSuspect: accusedSuspect,
            evidence: evidence
        )

        // Calculate score based on performance
        let score = calculateScore(correct: isCorrect)

        return CaseEvaluation(
            correct: isCorrect,
            score: score,
            timeSpent: progress?.timeElapsed ?? 0,
            evidenceCollected: progress?.discoveredEvidence.count ?? 0,
            hintsUsed: progress?.hintsUsed ?? 0
        )
    }

    // MARK: - Private Helpers

    private func updateObjectives() {
        // Check if current objectives are complete
        // Unlock new objectives as appropriate
    }

    private func calculateScore(correct: Bool) -> Int {
        guard let progress = progress, let activeCase = activeCase else { return 0 }

        var score = correct ? 1000 : 0

        // Bonus for speed
        let targetTime: TimeInterval = 3600 // 60 minutes
        if progress.timeElapsed < targetTime {
            score += Int((targetTime - progress.timeElapsed) / 60) * 10
        }

        // Bonus for evidence collection
        let evidencePercent = Float(progress.discoveredEvidence.count) / Float(activeCase.evidence.count)
        score += Int(evidencePercent * 500)

        // Penalty for hints
        score -= progress.hintsUsed * 50

        return max(score, 0)
    }
}

// MARK: - Game State Enum

enum GameState: Equatable {
    case mainMenu
    case caseSelection
    case caseIntroduction(CaseData)
    case investigating
    case interrogating(Suspect)
    case theoryBuilding
    case paused
    case caseComplete

    static func == (lhs: GameState, rhs: GameState) -> Bool {
        switch (lhs, rhs) {
        case (.mainMenu, .mainMenu): return true
        case (.caseSelection, .caseSelection): return true
        case (.investigating, .investigating): return true
        case (.paused, .paused): return true
        case (.caseComplete, .caseComplete): return true
        default: return false
        }
    }
}

// MARK: - Investigation Progress

struct InvestigationProgress: Codable {
    let caseID: UUID
    var discoveredEvidence: Set<UUID> = []
    var interrogatedSuspects: Set<UUID> = []
    var notes: [InvestigationNote] = []
    var currentTheory: Theory?
    var hintsUsed: Int = 0
    var timeElapsed: TimeInterval = 0
    var startTime: Date = Date()

    init(caseID: UUID) {
        self.caseID = caseID
        self.startTime = Date()
    }
}

// MARK: - Case Evaluation

struct CaseEvaluation {
    let correct: Bool
    let score: Int
    var timeSpent: TimeInterval = 0
    var evidenceCollected: Int = 0
    var hintsUsed: Int = 0

    var rating: String {
        if !correct { return "Failed" }
        if score >= 1500 { return "S" }
        if score >= 1200 { return "A" }
        if score >= 900 { return "B" }
        if score >= 600 { return "C" }
        return "D"
    }
}
