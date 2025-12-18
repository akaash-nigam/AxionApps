//
//  ExperimentManagerTests.swift
//  Science Lab Sandbox Tests
//
//  Unit tests for ExperimentManager
//

import XCTest
@testable import ScienceLabSandbox

@MainActor
final class ExperimentManagerTests: XCTestCase {

    var experimentManager: ExperimentManager!

    override func setUp() async throws {
        experimentManager = ExperimentManager()
    }

    override func tearDown() async throws {
        experimentManager = nil
    }

    // MARK: - Experiment Library Tests

    func testExperimentLibraryLoaded() {
        XCTAssertFalse(experimentManager.experimentLibrary.isEmpty, "Experiment library should not be empty")
        XCTAssertGreaterThanOrEqual(experimentManager.experimentLibrary.count, 1, "Should have at least 1 experiment")
    }

    func testGetExperimentsByDiscipline() {
        let chemistryExperiments = experimentManager.getExperiments(for: .chemistry)

        XCTAssertFalse(chemistryExperiments.isEmpty, "Should have chemistry experiments")

        for experiment in chemistryExperiments {
            XCTAssertEqual(experiment.discipline, .chemistry, "All experiments should be chemistry")
        }
    }

    func testGetExperimentsByDifficulty() {
        let beginnerExperiments = experimentManager.getExperiments(for: .beginner)

        for experiment in beginnerExperiments {
            XCTAssertEqual(experiment.difficulty, .beginner, "All experiments should be beginner level")
        }
    }

    // MARK: - Experiment Lifecycle Tests

    func testSetupExperiment() async throws {
        let experiment = experimentManager.experimentLibrary.first!

        try await experimentManager.setupExperiment(experiment)

        XCTAssertNotNil(experimentManager.currentExperiment, "Current experiment should be set")
        XCTAssertNotNil(experimentManager.currentSession, "Current session should be created")
        XCTAssertTrue(experimentManager.isExperimentActive, "Experiment should be active")
    }

    func testCannotSetupMultipleExperimentsSimultaneously() async {
        let experiment = experimentManager.experimentLibrary.first!

        try? await experimentManager.setupExperiment(experiment)

        do {
            try await experimentManager.setupExperiment(experiment)
            XCTFail("Should not allow setting up experiment when one is already active")
        } catch {
            XCTAssertTrue(error is ExperimentError, "Should throw ExperimentError")
        }
    }

    func testCompleteStep() async throws {
        let experiment = experimentManager.experimentLibrary.first!
        try await experimentManager.setupExperiment(experiment)

        let initialStep = experimentManager.currentStep
        experimentManager.completeCurrentStep()

        XCTAssertEqual(experimentManager.currentStep, initialStep + 1, "Step should increment")
    }

    // MARK: - Data Collection Tests

    func testRecordObservation() async throws {
        let experiment = experimentManager.experimentLibrary.first!
        try await experimentManager.setupExperiment(experiment)

        experimentManager.recordObservation("Test observation", category: .general)

        XCTAssertEqual(experimentManager.currentSession?.observations.count, 1, "Should have 1 observation")
        XCTAssertEqual(experimentManager.currentSession?.observations.first?.text, "Test observation")
    }

    func testRecordMeasurement() async throws {
        let experiment = experimentManager.experimentLibrary.first!
        try await experimentManager.setupExperiment(experiment)

        experimentManager.recordMeasurement(parameter: "Temperature", value: 25.0, unit: "°C")

        XCTAssertEqual(experimentManager.currentSession?.measurements.count, 1, "Should have 1 measurement")
        XCTAssertEqual(experimentManager.currentSession?.measurements.first?.parameter, "Temperature")
        XCTAssertEqual(experimentManager.currentSession?.measurements.first?.value, 25.0)
    }

    func testSetHypothesis() async throws {
        let experiment = experimentManager.experimentLibrary.first!
        try await experimentManager.setupExperiment(experiment)

        experimentManager.setHypothesis("The reaction will produce heat")

        XCTAssertEqual(experimentManager.currentSession?.hypothesis, "The reaction will produce heat")
    }

    func testSetConclusion() async throws {
        let experiment = experimentManager.experimentLibrary.first!
        try await experimentManager.setupExperiment(experiment)

        experimentManager.setConclusion("The hypothesis was confirmed")

        XCTAssertEqual(experimentManager.currentSession?.conclusion, "The hypothesis was confirmed")
    }

    // MARK: - Safety Tests

    func testCheckSafetyWithSafeChemicals() {
        let safeChemicals = [
            Chemical.water,
            Chemical.bakingSoda
        ]

        let safetyLevel = experimentManager.checkSafety(for: safeChemicals)

        XCTAssertEqual(safetyLevel, .safe, "Safe chemicals should return safe level")
    }

    func testCheckSafetyWithDangerousChemicals() {
        let dangerousChemicals = [
            Chemical.hydrochloricAcid,
            Chemical.sodiumHydroxide
        ]

        let safetyLevel = experimentManager.checkSafety(for: dangerousChemicals)

        XCTAssertGreaterThan(safetyLevel, .safe, "Dangerous chemicals should return higher safety level")
    }

    func testRecordSafetyViolation() async throws {
        let experiment = experimentManager.experimentLibrary.first!
        try await experimentManager.setupExperiment(experiment)

        experimentManager.recordSafetyViolation()

        XCTAssertEqual(experimentManager.currentSession?.safetyViolations, 1, "Should have 1 safety violation")
    }

    // MARK: - Session Duration Tests

    func testExperimentDuration() async throws {
        let experiment = experimentManager.experimentLibrary.first!
        try await experimentManager.setupExperiment(experiment)

        // Wait a brief moment
        try await Task.sleep(nanoseconds: 100_000_000)  // 0.1 seconds

        await experimentManager.endExperiment()

        XCTAssertNotNil(experimentManager.currentSession?.duration, "Duration should be calculated")
        XCTAssertGreaterThan(experimentManager.currentSession?.duration ?? 0, 0, "Duration should be positive")
    }
}
