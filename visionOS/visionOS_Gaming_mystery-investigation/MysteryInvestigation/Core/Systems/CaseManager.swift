//
//  CaseManager.swift
//  Mystery Investigation
//
//  Manages case loading, validation, and progression
//

import Foundation

@Observable
class CaseManager {
    private(set) var availableCases: [CaseData] = []
    private var caseCatalog: [UUID: CaseData] = [:]

    init() {
        loadCases()
    }

    // MARK: - Case Loading
    func loadCases() {
        // Load cases from bundle
        // In production, this would load from JSON files or remote server
        availableCases = loadBundledCases()

        for caseData in availableCases {
            caseCatalog[caseData.id] = caseData
        }
    }

    private func loadBundledCases() -> [CaseData] {
        // Tutorial case
        let tutorialCase = createTutorialCase()
        return [tutorialCase]
    }

    // MARK: - Case Queries
    func getCase(byID id: UUID) -> CaseData? {
        return caseCatalog[id]
    }

    func getCasesByDifficulty(_ difficulty: CaseData.Difficulty) -> [CaseData] {
        return availableCases.filter { $0.difficulty == difficulty }
    }

    // MARK: - Solution Validation
    func validateSolution(case caseData: CaseData, accusedSuspect: UUID, evidence: [UUID]) -> Bool {
        // Check if accused is the actual culprit
        guard accusedSuspect == caseData.solution.culpritID else {
            return false
        }

        // Check if player has critical evidence
        let criticalEvidence = Set(caseData.solution.criticalEvidence)
        let providedEvidence = Set(evidence)

        // Player needs at least 70% of critical evidence
        let evidenceRatio = Float(criticalEvidence.intersection(providedEvidence).count) / Float(criticalEvidence.count)

        return evidenceRatio >= 0.7
    }

    // MARK: - Tutorial Case Creation
    private func createTutorialCase() -> CaseData {
        let caseID = UUID()

        // Create suspects
        let butler = Suspect(
            id: UUID(),
            name: "James Butler",
            age: 45,
            occupation: "Butler",
            relationship: "Employee",
            alibi: "I was in the kitchen all evening",
            personality: PersonalityProfile(
                traits: ["Nervous", "Defensive"],
                baseStressLevel: 0.5,
                truthfulness: 0.3,
                cooperativeness: 0.6,
                confessionThreshold: 0.85
            ),
            appearance: AppearanceData(
                modelName: "butler_model",
                height: 1.75,
                description: "Middle-aged man in butler uniform",
                distinctiveFeatures: ["Gray hair", "Mustache"]
            ),
            dialogueTreeID: UUID(),
            isGuilty: true,
            motivations: ["Financial desperation", "Blackmail threat"],
            secretsToHide: ["Gambling debts", "Stole from master"]
        )

        let maid = Suspect(
            id: UUID(),
            name: "Mary Smith",
            age: 32,
            occupation: "Maid",
            relationship: "Employee",
            alibi: "I was cleaning upstairs",
            personality: PersonalityProfile(
                traits: ["Cooperative", "Honest"],
                baseStressLevel: 0.2,
                truthfulness: 0.9,
                cooperativeness: 0.9,
                confessionThreshold: 1.0
            ),
            appearance: AppearanceData(
                modelName: "maid_model",
                height: 1.65,
                description: "Young woman in maid uniform",
                distinctiveFeatures: ["Red hair", "Freckles"]
            ),
            dialogueTreeID: UUID(),
            isGuilty: false,
            motivations: [],
            secretsToHide: []
        )

        // Create evidence
        let fingerprint = Evidence(
            id: UUID(),
            type: .fingerprint,
            name: "Butler's Fingerprint",
            description: "Fingerprint found on weapon",
            detailedDescription: "A clear fingerprint matching the butler's records, found on the handle of the weapon.",
            spatialAnchor: SpatialAnchorData(
                persistenceKey: "evidence_fingerprint_1",
                surfaceType: .table,
                relativePosition: SIMD3<Float>(0, 0.9, 0),
                scale: 1.0
            ),
            isRedHerring: false,
            relatedSuspects: [butler.id],
            requiresTool: .fingerprintKit,
            forensicData: ForensicData(
                analysisType: "Fingerprint Analysis",
                results: ["Match": "Butler fingerprints", "Confidence": "99.8%"],
                conclusionText: "The fingerprints on the weapon definitively match those of the butler.",
                requiredTool: .fingerprintKit
            ),
            discoveryDifficulty: .moderate,
            hintText: "Check the table near the window"
        )

        let witness = Evidence(
            id: UUID(),
            type: .testimony,
            name: "Maid's Testimony",
            description: "Maid saw butler near the scene",
            detailedDescription: "The maid testifies seeing the butler near the study around the time of the crime.",
            spatialAnchor: SpatialAnchorData(
                persistenceKey: "evidence_testimony_1",
                surfaceType: .custom,
                relativePosition: SIMD3<Float>(1.5, 1.7, 0),
                scale: 1.0
            ),
            isRedHerring: false,
            relatedSuspects: [butler.id],
            requiresTool: nil,
            forensicData: nil,
            discoveryDifficulty: .obvious,
            hintText: "Question the maid"
        )

        return CaseData(
            id: caseID,
            title: "The Missing Heirloom",
            description: "A valuable family heirloom has been stolen from the manor. Question suspects and gather evidence to solve your first case.",
            difficulty: .tutorial,
            estimatedTime: 1800, // 30 minutes
            narrative: CaseNarrative(
                briefing: "You've been called to investigate the theft of a priceless family heirloom from Ashford Manor.",
                victimBackground: "Lord Ashford, wealthy nobleman, reported the theft this morning.",
                initialReport: "The heirloom was last seen in the study last night. The household staff are the primary suspects.",
                crimeSetting: "A grand Victorian manor with multiple rooms and staff quarters.",
                unlockableClues: []
            ),
            suspects: [butler, maid],
            evidence: [fingerprint, witness],
            solution: CaseSolution(
                culpritID: butler.id,
                motive: "The butler stole the heirloom to pay off gambling debts",
                method: "Entered the study after dinner using his master key",
                opportunity: "Was alone in the mansion after Lord Ashford retired",
                criticalEvidence: [fingerprint.id, witness.id],
                explanationText: "The butler, desperate to pay off mounting gambling debts, stole the heirloom using his access to all rooms in the manor. His fingerprints on the display case and the maid's testimony place him at the scene of the crime."
            ),
            timelineEvents: []
        )
    }
}
