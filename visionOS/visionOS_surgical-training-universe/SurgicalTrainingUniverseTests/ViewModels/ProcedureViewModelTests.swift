//
//  ProcedureViewModelTests.swift
//  SurgicalTrainingUniverseTests
//
//  Unit tests for ProcedureViewModel
//

import XCTest
import SwiftData
@testable import SurgicalTrainingUniverse

final class ProcedureViewModelTests: XCTestCase {

    var viewModel: ProcedureViewModel!
    var procedureService: ProcedureService!
    var aiCoach: SurgicalCoachAI!
    var modelContext: ModelContext!
    var testSurgeon: SurgeonProfile!

    override func setUp() async throws {
        let schema = Schema([SurgeonProfile.self, ProcedureSession.self, SurgicalMovement.self, Complication.self, Certification.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])
        modelContext = ModelContext(container)

        testSurgeon = SurgeonProfile(name: "Dr. Procedure Test", email: "proc@test.com", specialization: .generalSurgery, level: .resident2, institution: "Test")
        modelContext.insert(testSurgeon)
        try modelContext.save()

        procedureService = ProcedureService(modelContext: modelContext)
        aiCoach = SurgicalCoachAI()
        viewModel = ProcedureViewModel(procedureService: procedureService, aiCoach: aiCoach, modelContext: modelContext, currentUser: testSurgeon)
    }

    override func tearDown() {
        viewModel = nil
        procedureService = nil
        aiCoach = nil
        modelContext = nil
        testSurgeon = nil
    }

    func testInitialization() {
        XCTAssertNotNil(viewModel)
        XCTAssertNil(viewModel.currentSession)
        XCTAssertFalse(viewModel.isActive)
        XCTAssertFalse(viewModel.isPaused)
        XCTAssertEqual(viewModel.currentPhase, .preparation)
    }

    func testCanStartConditions() {
        XCTAssertTrue(viewModel.canStart)
        viewModel.isActive = true
        XCTAssertFalse(viewModel.canStart)
        viewModel.isActive = false
        viewModel.isLoading = true
        XCTAssertFalse(viewModel.canStart)
    }

    func testCanPauseConditions() {
        XCTAssertFalse(viewModel.canPause)
        viewModel.isActive = true
        XCTAssertTrue(viewModel.canPause)
        viewModel.isPaused = true
        XCTAssertFalse(viewModel.canPause)
    }

    func testCanResumeConditions() {
        XCTAssertFalse(viewModel.canResume)
        viewModel.isActive = true
        viewModel.isPaused = true
        XCTAssertTrue(viewModel.canResume)
    }

    func testFormattedElapsedTime() {
        viewModel.elapsedTime = 65
        XCTAssertEqual(viewModel.formattedElapsedTime, "01:05")
        viewModel.elapsedTime = 3661
        XCTAssertEqual(viewModel.formattedElapsedTime, "1:01:01")
    }

    func testFormattedMetrics() {
        viewModel.currentAccuracy = 85.5
        viewModel.currentEfficiency = 90.2
        viewModel.currentSafety = 92.8
        XCTAssertEqual(viewModel.formattedAccuracy, "85.5%")
        XCTAssertEqual(viewModel.formattedEfficiency, "90.2%")
        XCTAssertEqual(viewModel.formattedSafety, "92.8%")
    }

    func testOverallScore() {
        viewModel.currentAccuracy = 80.0
        viewModel.currentEfficiency = 90.0
        viewModel.currentSafety = 85.0
        let expected = (80.0 + 90.0 + 85.0) / 3.0
        XCTAssertEqual(viewModel.overallScore, expected, accuracy: 0.01)
    }

    @MainActor
    func testStartProcedure() async {
        await viewModel.startProcedure(type: .appendectomy)
        XCTAssertTrue(viewModel.isActive)
        XCTAssertFalse(viewModel.isPaused)
        XCTAssertEqual(viewModel.currentPhase, .incision)
    }

    func testSelectInstrument() {
        viewModel.selectInstrument(.scalpel)
        XCTAssertEqual(viewModel.selectedInstrument, .scalpel)
    }

    func testCompleteStep() {
        let stepId = "test-step"
        viewModel.completeStep(stepId)
        XCTAssertTrue(viewModel.completedSteps.contains(stepId))
    }

    func testPhaseProgressCalculation() {
        viewModel.currentSession = ProcedureSession(procedureType: .appendectomy, surgeon: testSurgeon)
        XCTAssertEqual(viewModel.phaseProgress, 0.0)
    }

    func testHasComplications() {
        XCTAssertFalse(viewModel.hasComplications)
        viewModel.complications = [Complication(timestamp: Date(), type: .bleeding, severity: .medium, description: "Test", resolved: false)]
        XCTAssertTrue(viewModel.hasComplications)
    }

    func testCriticalInsights() {
        let lowInsight = AIInsight(timestamp: Date(), category: .technique, severity: .low, message: "Low", suggestedAction: nil)
        let highInsight = AIInsight(timestamp: Date(), category: .safety, severity: .high, message: "High", suggestedAction: nil)
        viewModel.recentInsights = [lowInsight, highInsight]
        XCTAssertEqual(viewModel.criticalInsights.count, 1)
    }

    func testProcedurePhaseDisplayName() {
        XCTAssertEqual(ProcedurePhase.preparation.displayName, "Preparation")
        XCTAssertEqual(ProcedurePhase.incision.displayName, "Incision")
        XCTAssertEqual(ProcedurePhase.dissection.displayName, "Dissection")
    }

    func testComplicationSafetyImpact() {
        let lowComp = Complication(timestamp: Date(), type: .bleeding, severity: .low, description: "", resolved: false)
        XCTAssertEqual(lowComp.safetyImpact, 5.0)
        let mediumComp = Complication(timestamp: Date(), type: .bleeding, severity: .medium, description: "", resolved: false)
        XCTAssertEqual(mediumComp.safetyImpact, 10.0)
        let highComp = Complication(timestamp: Date(), type: .bleeding, severity: .high, description: "", resolved: false)
        XCTAssertEqual(highComp.safetyImpact, 20.0)
    }

    @MainActor
    func testRecordComplication() async {
        await viewModel.startProcedure(type: .appendectomy)
        let initialSafety = viewModel.currentSafety
        await viewModel.recordComplication(type: .bleeding, severity: .medium, description: "Test bleeding")
        XCTAssertEqual(viewModel.complications.count, 1)
        XCTAssertLessThan(viewModel.currentSafety, initialSafety)
        XCTAssertFalse(viewModel.recentInsights.isEmpty)
    }
}
