//
//  ManagerTests.swift
//  Mystery Investigation Tests
//
//  Unit tests for manager classes
//

import XCTest
@testable import MysteryInvestigation

final class ManagerTests: XCTestCase {

    // MARK: - CaseManager Tests

    func testCaseManagerInitialization() {
        // Given & When
        let manager = CaseManager()

        // Then
        XCTAssertNotNil(manager)
        XCTAssertFalse(manager.availableCases.isEmpty, "Should load at least tutorial case")
    }

    func testCaseManagerLoadsT utorialCase() {
        // Given
        let manager = CaseManager()

        // When
        let cases = manager.availableCases

        // Then
        XCTAssertGreaterThanOrEqual(cases.count, 1)
        XCTAssertTrue(cases.contains(where: { $0.difficulty == .tutorial }))
    }

    func testGetCaseByID() {
        // Given
        let manager = CaseManager()
        let firstCase = manager.availableCases.first!

        // When
        let retrievedCase = manager.getCase(byID: firstCase.id)

        // Then
        XCTAssertNotNil(retrievedCase)
        XCTAssertEqual(retrievedCase?.id, firstCase.id)
    }

    func testGetCaseByInvalidID() {
        // Given
        let manager = CaseManager()
        let invalidID = UUID()

        // When
        let retrievedCase = manager.getCase(byID: invalidID)

        // Then
        XCTAssertNil(retrievedCase)
    }

    func testGetCasesByDifficulty() {
        // Given
        let manager = CaseManager()

        // When
        let tutorialCases = manager.getCasesByDifficulty(.tutorial)

        // Then
        XCTAssertFalse(tutorialCases.isEmpty)
        XCTAssertTrue(tutorialCases.allSatisfy { $0.difficulty == .tutorial })
    }

    func testValidateSolutionCorrect() {
        // Given
        let manager = CaseManager()
        let testCase = manager.availableCases.first!

        // When
        let isValid = manager.validateSolution(
            case: testCase,
            accusedSuspect: testCase.solution.culpritID,
            evidence: testCase.solution.criticalEvidence
        )

        // Then
        XCTAssertTrue(isValid, "Should validate correct solution")
    }

    func testValidateSolutionWrongSuspect() {
        // Given
        let manager = CaseManager()
        let testCase = manager.availableCases.first!
        let wrongSuspectID = UUID()

        // When
        let isValid = manager.validateSolution(
            case: testCase,
            accusedSuspect: wrongSuspectID,
            evidence: testCase.solution.criticalEvidence
        )

        // Then
        XCTAssertFalse(isValid, "Should reject wrong suspect")
    }

    func testValidateSolutionInsufficientEvidence() {
        // Given
        let manager = CaseManager()
        let testCase = manager.availableCases.first!

        // When - Only provide 50% of critical evidence
        let halfEvidence = Array(testCase.solution.criticalEvidence.prefix(testCase.solution.criticalEvidence.count / 2))
        let isValid = manager.validateSolution(
            case: testCase,
            accusedSuspect: testCase.solution.culpritID,
            evidence: halfEvidence
        )

        // Then
        XCTAssertFalse(isValid, "Should require at least 70% of critical evidence")
    }

    // MARK: - EvidenceManager Tests

    func testEvidenceManagerInitialization() {
        // Given & When
        let manager = EvidenceManager()

        // Then
        XCTAssertNotNil(manager)
        XCTAssertTrue(manager.discoveredEvidence.isEmpty)
        XCTAssertTrue(manager.examinedEvidence.isEmpty)
    }

    func testDiscoverEvidence() {
        // Given
        let manager = EvidenceManager()
        let evidence = createTestEvidence()

        // When
        manager.discoverEvidence(evidence)

        // Then
        XCTAssertEqual(manager.discoveredEvidence.count, 1)
        XCTAssertEqual(manager.discoveredEvidence[evidence.id]?.id, evidence.id)
    }

    func testDiscoverSameEvidenceTwice() {
        // Given
        let manager = EvidenceManager()
        let evidence = createTestEvidence()

        // When
        manager.discoverEvidence(evidence)
        manager.discoverEvidence(evidence)

        // Then
        XCTAssertEqual(manager.discoveredEvidence.count, 1, "Should not duplicate evidence")
    }

    func testExamineEvidence() {
        // Given
        let manager = EvidenceManager()
        let evidence = createTestEvidence()
        manager.discoverEvidence(evidence)

        // When
        manager.examineEvidence(evidence.id)

        // Then
        XCTAssertTrue(manager.examinedEvidence.contains(evidence.id))
    }

    func testGetEvidenceByID() {
        // Given
        let manager = EvidenceManager()
        let evidence = createTestEvidence()
        manager.discoverEvidence(evidence)

        // When
        let retrieved = manager.getEvidence(byID: evidence.id)

        // Then
        XCTAssertNotNil(retrieved)
        XCTAssertEqual(retrieved?.id, evidence.id)
    }

    func testGetAllEvidence() {
        // Given
        let manager = EvidenceManager()
        let evidence1 = createTestEvidence()
        let evidence2 = createTestEvidence()

        manager.discoverEvidence(evidence1)
        manager.discoverEvidence(evidence2)

        // When
        let allEvidence = manager.getAllEvidence()

        // Then
        XCTAssertEqual(allEvidence.count, 2)
    }

    func testGetEvidenceByType() {
        // Given
        let manager = EvidenceManager()
        let fingerprint = createTestEvidence(type: .fingerprint)
        let weapon = createTestEvidence(type: .weapon)

        manager.discoverEvidence(fingerprint)
        manager.discoverEvidence(weapon)

        // When
        let fingerprints = manager.getEvidenceByType(.fingerprint)

        // Then
        XCTAssertEqual(fingerprints.count, 1)
        XCTAssertEqual(fingerprints.first?.type, .fingerprint)
    }

    func testGetRelatedEvidence() {
        // Given
        let manager = EvidenceManager()
        let suspectID = UUID()
        let relatedEvidence = createTestEvidence(relatedSuspects: [suspectID])
        let unrelatedEvidence = createTestEvidence(relatedSuspects: [])

        manager.discoverEvidence(relatedEvidence)
        manager.discoverEvidence(unrelatedEvidence)

        // When
        let related = manager.getRelatedEvidence(for: suspectID)

        // Then
        XCTAssertEqual(related.count, 1)
        XCTAssertTrue(related.first?.relatedSuspects.contains(suspectID) ?? false)
    }

    func testResetManager() {
        // Given
        let manager = EvidenceManager()
        let evidence = createTestEvidence()
        manager.discoverEvidence(evidence)
        manager.examineEvidence(evidence.id)

        // When
        manager.reset()

        // Then
        XCTAssertTrue(manager.discoveredEvidence.isEmpty)
        XCTAssertTrue(manager.examinedEvidence.isEmpty)
    }

    // MARK: - SaveGameManager Tests

    func testSaveGameManagerInitialization() {
        // Given & When
        let manager = SaveGameManager()

        // Then
        XCTAssertNotNil(manager)
    }

    func testSaveAndLoadPlayerProgress() {
        // Given
        let manager = SaveGameManager()
        var progress = PlayerProgress()
        progress.totalXP = 1500
        progress.detectiveRank = .junior

        // When
        manager.savePlayerProgress(progress)
        let loadedProgress = manager.loadPlayerProgress()

        // Then
        XCTAssertNotNil(loadedProgress)
        XCTAssertEqual(loadedProgress?.totalXP, 1500)
        XCTAssertEqual(loadedProgress?.detectiveRank, .junior)

        // Cleanup
        manager.deleteAllData()
    }

    func testSaveAndLoadSettings() {
        // Given
        let manager = SaveGameManager()
        var settings = GameSettings()
        settings.masterVolume = 0.5
        settings.handTrackingEnabled = false

        // When
        manager.saveSettings(settings)
        let loadedSettings = manager.loadSettings()

        // Then
        XCTAssertNotNil(loadedSettings)
        XCTAssertEqual(loadedSettings?.masterVolume, 0.5)
        XCTAssertFalse(loadedSettings?.handTrackingEnabled ?? true)

        // Cleanup
        manager.deleteAllData()
    }

    func testLoadNonexistentData() {
        // Given
        let manager = SaveGameManager()
        manager.deleteAllData() // Ensure clean state

        // When
        let progress = manager.loadPlayerProgress()
        let settings = manager.loadSettings()

        // Then
        XCTAssertNil(progress)
        XCTAssertNil(settings)
    }

    func testSaveCaseProgress() {
        // Given
        let manager = SaveGameManager()
        let caseID = UUID()
        var progress = InvestigationProgress(caseID: caseID)
        progress.discoveredEvidence.insert(UUID())
        progress.hintsUsed = 2

        // When
        manager.saveCaseProgress(progress)
        let loadedProgress = manager.loadCaseProgress(caseID: caseID)

        // Then
        XCTAssertNotNil(loadedProgress)
        XCTAssertEqual(loadedProgress?.caseID, caseID)
        XCTAssertEqual(loadedProgress?.discoveredEvidence.count, 1)
        XCTAssertEqual(loadedProgress?.hintsUsed, 2)

        // Cleanup
        manager.deleteCaseProgress(caseID: caseID)
    }

    func testDeleteAllData() {
        // Given
        let manager = SaveGameManager()
        var progress = PlayerProgress()
        progress.totalXP = 1000
        manager.savePlayerProgress(progress)

        // When
        manager.deleteAllData()
        let loadedProgress = manager.loadPlayerProgress()

        // Then
        XCTAssertNil(loadedProgress)
    }

    // MARK: - Helper Methods

    private func createTestEvidence(
        type: Evidence.EvidenceType = .fingerprint,
        relatedSuspects: [UUID] = []
    ) -> Evidence {
        return Evidence(
            id: UUID(),
            type: type,
            name: "Test Evidence",
            description: "Test description",
            detailedDescription: "Detailed description",
            spatialAnchor: SpatialAnchorData(
                persistenceKey: "test_key",
                surfaceType: .table,
                relativePosition: SIMD3<Float>(0, 0, 0),
                scale: 1.0
            ),
            isRedHerring: false,
            relatedSuspects: relatedSuspects,
            requiresTool: nil,
            forensicData: nil,
            discoveryDifficulty: .obvious,
            hintText: nil
        )
    }
}
