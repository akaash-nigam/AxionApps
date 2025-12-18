import SwiftUI
import RealityKit
import Combine

/// Central coordinator for game logic and scene management
@MainActor
class GameCoordinator: ObservableObject {
    // MARK: - Published Properties

    @Published var investigationState: InvestigationState
    @Published var currentCase: Case?
    @Published var discoveredEvidence: [Evidence] = []
    @Published var collectedEvidence: [Evidence] = []
    @Published var hypotheses: [Hypothesis] = []
    @Published var currentSuspect: Suspect?
    @Published var investigationProgress: Float = 0.0

    // MARK: - Private Properties

    private let caseManager = CaseManager()
    private let evidenceManager = EvidenceManager()
    private let interrogationManager = InterrogationManager()
    private let deductionEngine = DeductionEngine()
    private let saveManager = SaveManager()

    private var cancellables = Set<AnyCancellable>()
    private var caseStartTime: Date?

    // MARK: - Initialization

    init() {
        self.investigationState = InvestigationState()
        setupObservers()
    }

    // MARK: - Case Management

    func startCase(_ caseID: UUID) async throws {
        guard let loadedCase = try await caseManager.loadCase(caseID) else {
            throw GameError.caseNotFound
        }

        currentCase = loadedCase
        discoveredEvidence = []
        collectedEvidence = []
        hypotheses = []
        investigationProgress = 0.0
        caseStartTime = Date()

        investigationState = InvestigationState(currentCase: loadedCase)

        print("Case started: \(loadedCase.title)")
    }

    func resumeCase(_ caseID: UUID) async throws {
        // Load saved investigation state
        if let savedState = try await saveManager.loadInvestigationProgress(caseID: caseID) {
            investigationState = savedState
            currentCase = savedState.currentCase
            discoveredEvidence = savedState.discoveredEvidence
            collectedEvidence = savedState.collectedEvidence
            hypotheses = savedState.hypotheses
            investigationProgress = savedState.investigationProgress

            print("Case resumed: \(savedState.currentCase?.title ?? "Unknown")")
        }
    }

    func pauseCase() async {
        guard let state = investigationState.currentCase else { return }

        do {
            try await saveManager.saveInvestigationProgress(investigationState)
            print("Case paused and saved")
        } catch {
            print("Failed to save investigation state: \(error)")
        }
    }

    func completeCase(solution: CaseSolution) async -> CaseResult {
        guard let currentCase = currentCase else {
            return CaseResult(isCorrect: false, accuracy: 0.0, timeElapsed: 0, feedback: "No active case")
        }

        let timeElapsed = Date().timeIntervalSince(caseStartTime ?? Date())

        // Evaluate solution
        let evaluation = currentCase.solution.evaluate(against: solution)

        let result = CaseResult(
            isCorrect: evaluation.isCorrect,
            accuracy: evaluation.accuracy,
            timeElapsed: timeElapsed,
            feedback: generateFeedback(evaluation),
            experienceEarned: calculateExperience(evaluation, timeElapsed: timeElapsed)
        )

        // Mark case as completed
        if evaluation.isCorrect {
            investigationState.currentCase = nil
        }

        return result
    }

    // MARK: - Evidence Management

    func discoverEvidence(_ evidence: Evidence) {
        guard !discoveredEvidence.contains(where: { $0.id == evidence.id }) else {
            return
        }

        discoveredEvidence.append(evidence)
        updateProgress()

        print("Evidence discovered: \(evidence.name)")
    }

    func collectEvidence(_ evidence: Evidence) {
        guard !collectedEvidence.contains(where: { $0.id == evidence.id }) else {
            return
        }

        collectedEvidence.append(evidence)
        updateProgress()

        print("Evidence collected: \(evidence.name)")
    }

    func examineEvidence(_ evidence: Evidence, with tool: ForensicToolType) -> ForensicResult {
        return evidenceManager.analyzeEvidence(evidence, using: tool)
    }

    // MARK: - Interrogation

    func startInterrogation(with suspect: Suspect) {
        currentSuspect = suspect
        interrogationManager.beginInterrogation(suspect: suspect)
    }

    func askQuestion(_ question: DialogueResponse, presentingEvidence: [Evidence] = []) async -> DialogueNode? {
        guard let suspect = currentSuspect else { return nil }

        let response = await interrogationManager.processQuestion(
            question,
            to: suspect,
            withEvidence: presentingEvidence
        )

        return response
    }

    func endInterrogation() {
        let session = interrogationManager.endInterrogation()
        investigationState.interrogationNotes.append(session)
        currentSuspect = nil
    }

    // MARK: - Deduction

    func formHypothesis(culprit: UUID, motive: String, evidence: [Evidence]) -> Hypothesis {
        let hypothesis = Hypothesis(
            id: UUID(),
            title: "Case Theory",
            description: motive,
            supportingEvidence: evidence.map { $0.id },
            contradictingEvidence: [],
            confidenceScore: deductionEngine.calculateConfidence(for: evidence),
            isCorrect: nil
        )

        hypotheses.append(hypothesis)
        return hypothesis
    }

    func getSuggestedConnections() -> [EvidenceConnection] {
        return deductionEngine.analyzeEvidence(collectedEvidence)
    }

    // MARK: - Private Methods

    private func setupObservers() {
        // Auto-save periodically
        Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task {
                    await self?.pauseCase()
                }
            }
            .store(in: &cancellables)
    }

    private func updateProgress() {
        guard let currentCase = currentCase else { return }

        let evidenceProgress = Float(collectedEvidence.count) / Float(currentCase.evidence.count)
        let interrogationProgress = Float(investigationState.interrogationNotes.count) / Float(currentCase.suspects.count)

        investigationProgress = (evidenceProgress * 0.6) + (interrogationProgress * 0.4)
    }

    private func generateFeedback(_ evaluation: SolutionEvaluation) -> String {
        if evaluation.isCorrect {
            return "Excellent detective work! You've solved the case."
        } else if evaluation.accuracy > 0.7 {
            return "You're close, but some details don't add up. Review the evidence."
        } else if evaluation.accuracy > 0.4 {
            return "You've made some connections, but the solution isn't quite right."
        } else {
            return "This theory doesn't fit the evidence. Start over with what you know."
        }
    }

    private func calculateExperience(_ evaluation: SolutionEvaluation, timeElapsed: TimeInterval) -> Int {
        var xp = 100  // Base XP

        if evaluation.isCorrect {
            xp += 500  // Completion bonus

            // Speed bonus
            if timeElapsed < 1800 {  // Under 30 minutes
                xp += 200
            }

            // Accuracy bonus
            xp += Int(evaluation.accuracy * 300)
        }

        return xp
    }
}

// MARK: - Supporting Types

struct CaseResult {
    let isCorrect: Bool
    let accuracy: Float
    let timeElapsed: TimeInterval
    let feedback: String
    var experienceEarned: Int = 0
}

struct EvidenceConnection {
    let evidence1: UUID
    let evidence2: UUID
    let relationshipType: RelationshipType
    let confidence: Float

    enum RelationshipType {
        case temporal  // Related by time
        case spatial   // Found near each other
        case forensic  // Forensic match (DNA, fingerprints)
        case logical   // Logical connection
    }
}

enum GameError: Error {
    case caseNotFound
    case invalidState
    case saveFailed
    case loadFailed
}
