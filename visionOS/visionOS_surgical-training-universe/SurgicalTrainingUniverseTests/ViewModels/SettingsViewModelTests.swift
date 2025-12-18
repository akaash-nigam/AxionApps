//
//  SettingsViewModelTests.swift
//  SurgicalTrainingUniverseTests
//
//  Unit tests for SettingsViewModel
//

import XCTest
import SwiftData
@testable import SurgicalTrainingUniverse

final class SettingsViewModelTests: XCTestCase {

    var viewModel: SettingsViewModel!
    var modelContext: ModelContext!
    var testSurgeon: SurgeonProfile!

    override func setUp() async throws {
        let schema = Schema([SurgeonProfile.self, ProcedureSession.self, SurgicalMovement.self, Complication.self, Certification.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])
        modelContext = ModelContext(container)

        testSurgeon = SurgeonProfile(name: "Dr. Settings Test", email: "settings@test.com", specialization: .neurosurgery, level: .fellow, institution: "Settings Hospital")
        modelContext.insert(testSurgeon)
        try modelContext.save()

        viewModel = SettingsViewModel(modelContext: modelContext, currentUser: testSurgeon)
    }

    override func tearDown() {
        viewModel = nil
        modelContext = nil
        testSurgeon = nil
    }

    func testInitialization() {
        XCTAssertNotNil(viewModel)
        XCTAssertEqual(viewModel.editedName, "Dr. Settings Test")
        XCTAssertEqual(viewModel.editedEmail, "settings@test.com")
    }

    func testIsProfileValid() {
        XCTAssertTrue(viewModel.isProfileValid)
        viewModel.editedName = ""
        XCTAssertFalse(viewModel.isProfileValid)
        viewModel.editedName = "Dr. Test"
        viewModel.editedEmail = "invalid-email"
        XCTAssertFalse(viewModel.isProfileValid)
    }

    func testHasUnsavedChanges() {
        XCTAssertFalse(viewModel.hasUnsavedChanges)
        viewModel.editedName = "Dr. Different Name"
        XCTAssertTrue(viewModel.hasUnsavedChanges)
    }

    func testSpecializationDisplayName() {
        viewModel.editedSpecialization = .generalSurgery
        XCTAssertEqual(viewModel.specializationDisplayName, "General Surgery")
        viewModel.editedSpecialization = .neurosurgery
        XCTAssertEqual(viewModel.specializationDisplayName, "Neurosurgery")
    }

    func testTrainingLevelDisplayName() {
        viewModel.editedLevel = .resident1
        XCTAssertEqual(viewModel.trainingLevelDisplayName, "PGY-1 Resident")
        viewModel.editedLevel = .attending
        XCTAssertEqual(viewModel.trainingLevelDisplayName, "Attending Surgeon")
    }

    @MainActor
    func testSaveProfile() async {
        viewModel.editedName = "Dr. Updated Name"
        await viewModel.saveProfile()
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.successMessage)
        XCTAssertEqual(testSurgeon.name, "Dr. Updated Name")
    }

    func testDiscardChanges() {
        viewModel.editedName = "Changed"
        viewModel.discardChanges()
        XCTAssertEqual(viewModel.editedName, testSurgeon.name)
    }

    func testSavePreferences() {
        viewModel.hapticFeedbackEnabled = false
        viewModel.soundEffectsEnabled = false
        viewModel.savePreferences()
        XCTAssertNotNil(viewModel.successMessage)
    }

    func testResetPreferences() {
        viewModel.hapticFeedbackEnabled = false
        viewModel.resetPreferences()
        XCTAssertTrue(viewModel.hapticFeedbackEnabled)
    }

    func testAppVersion() {
        XCTAssertFalse(viewModel.appVersion.isEmpty)
        XCTAssertFalse(viewModel.buildNumber.isEmpty)
        XCTAssertFalse(viewModel.fullVersion.isEmpty)
    }

    func testValidateEmail() {
        XCTAssertTrue(viewModel.validateEmail("test@example.com"))
        XCTAssertFalse(viewModel.validateEmail("invalid-email"))
        XCTAssertFalse(viewModel.validateEmail(""))
    }

    func testExportUserData() {
        let data = viewModel.exportUserData()
        XCTAssertTrue(data.contains("SURGICAL TRAINING UNIVERSE"))
        XCTAssertTrue(data.contains(testSurgeon.name))
        XCTAssertTrue(data.contains(testSurgeon.email))
    }

    func testLightingModeDisplayName() {
        XCTAssertEqual(LightingMode.realistic.displayName, "Realistic")
        XCTAssertEqual(LightingMode.bright.displayName, "Bright")
        XCTAssertEqual(LightingMode.dim.displayName, "Dim")
    }
}
