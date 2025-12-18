//
//  DataModelTests.swift
//  Mystery Investigation Tests
//
//  Unit tests for data models
//

import XCTest
@testable import MysteryInvestigation

final class DataModelTests: XCTestCase {

    // MARK: - CaseData Tests

    func testCaseDataInitialization() {
        // Given
        let caseID = UUID()
        let title = "Test Case"
        let difficulty = CaseData.Difficulty.beginner

        // When
        let caseData = createTestCase(id: caseID, title: title, difficulty: difficulty)

        // Then
        XCTAssertEqual(caseData.id, caseID)
        XCTAssertEqual(caseData.title, title)
        XCTAssertEqual(caseData.difficulty, difficulty)
        XCTAssertFalse(caseData.suspects.isEmpty)
        XCTAssertFalse(caseData.evidence.isEmpty)
    }

    func testCaseDataCodable() throws {
        // Given
        let originalCase = createTestCase()
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        // When
        let encodedData = try encoder.encode(originalCase)
        let decodedCase = try decoder.decode(CaseData.self, from: encodedData)

        // Then
        XCTAssertEqual(decodedCase.id, originalCase.id)
        XCTAssertEqual(decodedCase.title, originalCase.title)
        XCTAssertEqual(decodedCase.difficulty, originalCase.difficulty)
        XCTAssertEqual(decodedCase.suspects.count, originalCase.suspects.count)
        XCTAssertEqual(decodedCase.evidence.count, originalCase.evidence.count)
    }

    func testDifficultyLevels() {
        // Given & When & Then
        XCTAssertEqual(CaseData.Difficulty.tutorial.rawValue, "tutorial")
        XCTAssertEqual(CaseData.Difficulty.beginner.rawValue, "beginner")
        XCTAssertEqual(CaseData.Difficulty.intermediate.rawValue, "intermediate")
        XCTAssertEqual(CaseData.Difficulty.advanced.rawValue, "advanced")
        XCTAssertEqual(CaseData.Difficulty.expert.rawValue, "expert")
    }

    func testDifficultyStars() {
        // Given
        let tutorialCase = createTestCase(difficulty: .tutorial)
        let beginnerCase = createTestCase(difficulty: .beginner)
        let expertCase = createTestCase(difficulty: .expert)

        // When & Then
        XCTAssertEqual(tutorialCase.difficultyStars, 1)
        XCTAssertEqual(beginnerCase.difficultyStars, 2)
        XCTAssertEqual(expertCase.difficultyStars, 5)
    }

    // MARK: - Evidence Tests

    func testEvidenceCreation() {
        // Given
        let evidenceID = UUID()
        let evidenceName = "Test Evidence"
        let evidenceType = Evidence.EvidenceType.fingerprint

        // When
        let evidence = createTestEvidence(
            id: evidenceID,
            name: evidenceName,
            type: evidenceType
        )

        // Then
        XCTAssertEqual(evidence.id, evidenceID)
        XCTAssertEqual(evidence.name, evidenceName)
        XCTAssertEqual(evidence.type, evidenceType)
    }

    func testEvidenceTypes() {
        // Test all evidence types exist
        let types: [Evidence.EvidenceType] = [
            .fingerprint, .dna, .weapon, .document,
            .photograph, .fiber, .footprint, .bloodSpatter,
            .digitalEvidence, .testimony, .miscellaneous
        ]

        XCTAssertEqual(types.count, 11)
    }

    func testEvidenceCodable() throws {
        // Given
        let originalEvidence = createTestEvidence()
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        // When
        let encodedData = try encoder.encode(originalEvidence)
        let decodedEvidence = try decoder.decode(Evidence.self, from: encodedData)

        // Then
        XCTAssertEqual(decodedEvidence.id, originalEvidence.id)
        XCTAssertEqual(decodedEvidence.name, originalEvidence.name)
        XCTAssertEqual(decodedEvidence.type, originalEvidence.type)
        XCTAssertEqual(decodedEvidence.isRedHerring, originalEvidence.isRedHerring)
    }

    func testSpatialAnchorData() {
        // Given
        let anchor = SpatialAnchorData(
            persistenceKey: "test_key",
            surfaceType: .table,
            relativePosition: SIMD3<Float>(1.0, 0.9, 0.0),
            scale: 1.0
        )

        // Then
        XCTAssertEqual(anchor.persistenceKey, "test_key")
        XCTAssertEqual(anchor.surfaceType, .table)
        XCTAssertEqual(anchor.relativePosition.y, 0.9)
        XCTAssertEqual(anchor.scale, 1.0)
    }

    func testDiscoveryDifficulty() {
        // Given
        let obviousEvidence = createTestEvidence(discoveryDifficulty: .obvious)
        let hiddenEvidence = createTestEvidence(discoveryDifficulty: .hidden)

        // Then
        XCTAssertEqual(obviousEvidence.discoveryDifficulty, .obvious)
        XCTAssertEqual(hiddenEvidence.discoveryDifficulty, .hidden)
    }

    // MARK: - Suspect Tests

    func testSuspectCreation() {
        // Given
        let suspectID = UUID()
        let name = "Test Suspect"

        // When
        let suspect = createTestSuspect(id: suspectID, name: name)

        // Then
        XCTAssertEqual(suspect.id, suspectID)
        XCTAssertEqual(suspect.name, name)
        XCTAssertNotNil(suspect.personality)
    }

    func testSuspectGuiltyState() {
        // Given
        let guiltySuspect = createTestSuspect(isGuilty: true)
        let innocentSuspect = createTestSuspect(isGuilty: false)

        // Then
        XCTAssertTrue(guiltySuspect.isGuilty)
        XCTAssertFalse(innocentSuspect.isGuilty)
    }

    func testPersonalityProfile() {
        // Given
        let profile = PersonalityProfile(
            traits: ["Nervous", "Defensive"],
            baseStressLevel: 0.5,
            truthfulness: 0.3,
            cooperativeness: 0.6,
            confessionThreshold: 0.85
        )

        // Then
        XCTAssertEqual(profile.traits.count, 2)
        XCTAssertTrue(profile.traits.contains("Nervous"))
        XCTAssertEqual(profile.baseStressLevel, 0.5)
        XCTAssertEqual(profile.confessionThreshold, 0.85)
    }

    func testSuspectCodable() throws {
        // Given
        let originalSuspect = createTestSuspect()
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        // When
        let encodedData = try encoder.encode(originalSuspect)
        let decodedSuspect = try decoder.decode(Suspect.self, from: encodedData)

        // Then
        XCTAssertEqual(decodedSuspect.id, originalSuspect.id)
        XCTAssertEqual(decodedSuspect.name, originalSuspect.name)
        XCTAssertEqual(decodedSuspect.isGuilty, originalSuspect.isGuilty)
    }

    // MARK: - Player Progress Tests

    func testPlayerProgressInitialization() {
        // Given & When
        let progress = PlayerProgress()

        // Then
        XCTAssertEqual(progress.detectiveRank, .rookie)
        XCTAssertEqual(progress.totalXP, 0)
        XCTAssertTrue(progress.completedCases.isEmpty)
        XCTAssertTrue(progress.achievements.isEmpty)
    }

    func testXPAccumulation() {
        // Given
        var progress = PlayerProgress()
        let evaluation = CaseEvaluation(correct: true, score: 1000)

        // When
        progress.addCompletedCase(UUID(), evaluation: evaluation)

        // Then
        XCTAssertEqual(progress.totalXP, 1000)
        XCTAssertEqual(progress.completedCases.count, 1)
    }

    func testRankProgression() {
        // Given
        var progress = PlayerProgress()

        // Rookie (0 XP)
        XCTAssertEqual(progress.detectiveRank, .rookie)

        // Junior (5000 XP)
        progress.totalXP = 5000
        progress.addCompletedCase(UUID(), evaluation: CaseEvaluation(correct: true, score: 0))
        XCTAssertEqual(progress.detectiveRank, .junior)

        // Senior (15000 XP)
        progress.totalXP = 15000
        progress.addCompletedCase(UUID(), evaluation: CaseEvaluation(correct: true, score: 0))
        XCTAssertEqual(progress.detectiveRank, .senior)

        // Master (30000 XP)
        progress.totalXP = 30000
        progress.addCompletedCase(UUID(), evaluation: CaseEvaluation(correct: true, score: 0))
        XCTAssertEqual(progress.detectiveRank, .master)

        // Legendary (50000 XP)
        progress.totalXP = 50000
        progress.addCompletedCase(UUID(), evaluation: CaseEvaluation(correct: true, score: 0))
        XCTAssertEqual(progress.detectiveRank, .legendary)
    }

    func testPlayerProgressCodable() throws {
        // Given
        var originalProgress = PlayerProgress()
        originalProgress.totalXP = 1000
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        // When
        let encodedData = try encoder.encode(originalProgress)
        let decodedProgress = try decoder.decode(PlayerProgress.self, from: encodedData)

        // Then
        XCTAssertEqual(decodedProgress.totalXP, originalProgress.totalXP)
        XCTAssertEqual(decodedProgress.detectiveRank, originalProgress.detectiveRank)
    }

    // MARK: - Game Settings Tests

    func testGameSettingsDefaults() {
        // Given & When
        let settings = GameSettings()

        // Then
        XCTAssertEqual(settings.uiScale, 1.0)
        XCTAssertEqual(settings.masterVolume, 0.75)
        XCTAssertTrue(settings.handTrackingEnabled)
        XCTAssertTrue(settings.spatialAudioEnabled)
        XCTAssertEqual(settings.colorBlindMode, .none)
    }

    func testGameSettingsCodable() throws {
        // Given
        var originalSettings = GameSettings()
        originalSettings.masterVolume = 0.5
        originalSettings.handTrackingEnabled = false
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        // When
        let encodedData = try encoder.encode(originalSettings)
        let decodedSettings = try decoder.decode(GameSettings.self, from: encodedData)

        // Then
        XCTAssertEqual(decodedSettings.masterVolume, 0.5)
        XCTAssertFalse(decodedSettings.handTrackingEnabled)
    }

    // MARK: - Case Solution Tests

    func testCaseSolutionStructure() {
        // Given
        let culpritID = UUID()
        let evidenceIDs = [UUID(), UUID()]

        let solution = CaseSolution(
            culpritID: culpritID,
            motive: "Financial gain",
            method: "Poisoning",
            opportunity: "Had access to kitchen",
            criticalEvidence: evidenceIDs,
            explanationText: "The butler did it."
        )

        // Then
        XCTAssertEqual(solution.culpritID, culpritID)
        XCTAssertEqual(solution.criticalEvidence.count, 2)
        XCTAssertEqual(solution.motive, "Financial gain")
    }

    // MARK: - Helper Methods

    private func createTestCase(
        id: UUID = UUID(),
        title: String = "Test Case",
        difficulty: CaseData.Difficulty = .beginner
    ) -> CaseData {
        let suspect = createTestSuspect()
        let evidence = createTestEvidence()

        return CaseData(
            id: id,
            title: title,
            description: "Test description",
            difficulty: difficulty,
            estimatedTime: 1800,
            narrative: CaseNarrative(
                briefing: "Test briefing",
                victimBackground: "Test victim",
                initialReport: "Test report",
                crimeSetting: "Test setting",
                unlockableClues: []
            ),
            suspects: [suspect],
            evidence: [evidence],
            solution: CaseSolution(
                culpritID: suspect.id,
                motive: "Test motive",
                method: "Test method",
                opportunity: "Test opportunity",
                criticalEvidence: [evidence.id],
                explanationText: "Test explanation"
            ),
            timelineEvents: []
        )
    }

    private func createTestEvidence(
        id: UUID = UUID(),
        name: String = "Test Evidence",
        type: Evidence.EvidenceType = .fingerprint,
        discoveryDifficulty: Evidence.DiscoveryDifficulty = .obvious
    ) -> Evidence {
        return Evidence(
            id: id,
            type: type,
            name: name,
            description: "Test description",
            detailedDescription: "Detailed test description",
            spatialAnchor: SpatialAnchorData(
                persistenceKey: "test_\(id)",
                surfaceType: .table,
                relativePosition: SIMD3<Float>(0, 0.9, 0),
                scale: 1.0
            ),
            isRedHerring: false,
            relatedSuspects: [],
            requiresTool: nil,
            forensicData: nil,
            discoveryDifficulty: discoveryDifficulty,
            hintText: nil
        )
    }

    private func createTestSuspect(
        id: UUID = UUID(),
        name: String = "Test Suspect",
        isGuilty: Bool = false
    ) -> Suspect {
        return Suspect(
            id: id,
            name: name,
            age: 35,
            occupation: "Test Occupation",
            relationship: "Test Relation",
            alibi: "Test Alibi",
            personality: PersonalityProfile(
                traits: ["Test Trait"],
                baseStressLevel: 0.3,
                truthfulness: 0.7,
                cooperativeness: 0.8,
                confessionThreshold: 0.85
            ),
            appearance: AppearanceData(
                modelName: "test_model",
                height: 1.75,
                description: "Test appearance",
                distinctiveFeatures: []
            ),
            dialogueTreeID: UUID(),
            isGuilty: isGuilty,
            motivations: [],
            secretsToHide: []
        )
    }
}
