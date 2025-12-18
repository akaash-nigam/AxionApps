//
//  ManualEntryViewModelTests.swift
//  HomeMaintenanceOracleTests
//
//  Created on 2025-11-24.
//  Unit tests for ManualEntryViewModel
//

import XCTest
@testable import HomeMaintenanceOracle

@MainActor
final class ManualEntryViewModelTests: XCTestCase {

    var sut: ManualEntryViewModel!
    var mockInventoryService: MockInventoryService!

    override func setUp() async throws {
        try await super.setUp()
        mockInventoryService = MockInventoryService()
        sut = ManualEntryViewModel(inventoryService: mockInventoryService)
    }

    override func tearDown() async throws {
        sut = nil
        mockInventoryService = nil
        try await super.tearDown()
    }

    // MARK: - Initial State Tests

    func testInitialState() {
        XCTAssertEqual(sut.selectedCategory, .refrigerator)
        XCTAssertEqual(sut.brand, "")
        XCTAssertEqual(sut.modelNumber, "")
        XCTAssertEqual(sut.serialNumber, "")
        XCTAssertEqual(sut.location, "")
        XCTAssertEqual(sut.notes, "")
        XCTAssertNil(sut.selectedImage)
        XCTAssertTrue(sut.validationErrors.isEmpty)
        XCTAssertFalse(sut.showSuccessAlert)
        XCTAssertFalse(sut.showErrorAlert)
    }

    // MARK: - Validation Tests

    func testIsValid_WithEmptyBrand_ReturnsFalse() {
        // Given
        sut.brand = ""
        sut.modelNumber = "ABC123"

        // When
        let isValid = sut.isValid

        // Then
        XCTAssertFalse(isValid)
        XCTAssertTrue(sut.validationErrors.contains("Brand is required"))
    }

    func testIsValid_WithEmptyModel_ReturnsFalse() {
        // Given
        sut.brand = "Samsung"
        sut.modelNumber = ""

        // When
        let isValid = sut.isValid

        // Then
        XCTAssertFalse(isValid)
        XCTAssertTrue(sut.validationErrors.contains("Model number is required"))
    }

    func testIsValid_WithFutureInstallationDate_ReturnsFalse() {
        // Given
        sut.brand = "Samsung"
        sut.modelNumber = "ABC123"
        sut.installationDate = Date().addingTimeInterval(86400) // Tomorrow

        // When
        let isValid = sut.isValid

        // Then
        XCTAssertFalse(isValid)
        XCTAssertTrue(sut.validationErrors.contains("Installation date cannot be in the future"))
    }

    func testIsValid_WithValidData_ReturnsTrue() {
        // Given
        sut.brand = "Samsung"
        sut.modelNumber = "RF28R7351SR"
        sut.installationDate = Date()

        // When
        let isValid = sut.isValid

        // Then
        XCTAssertTrue(isValid)
        XCTAssertTrue(sut.validationErrors.isEmpty)
    }

    func testIsValid_TrimsWhitespace() {
        // Given
        sut.brand = "  Samsung  "
        sut.modelNumber = "  ABC123  "

        // When
        let isValid = sut.isValid

        // Then
        XCTAssertTrue(isValid)
        XCTAssertTrue(sut.validationErrors.isEmpty)
    }

    // MARK: - Save Appliance Tests

    func testSaveAppliance_WithValidData_SavesSuccessfully() async {
        // Given
        sut.brand = "Samsung"
        sut.modelNumber = "RF28R7351SR"
        sut.selectedCategory = .refrigerator
        sut.serialNumber = "SN12345"
        sut.location = "Kitchen"
        sut.notes = "New appliance"

        // When
        await sut.saveAppliance()

        // Then
        XCTAssertEqual(mockInventoryService.appliances.count, 1)
        let savedAppliance = mockInventoryService.appliances.first
        XCTAssertEqual(savedAppliance?.brand, "Samsung")
        XCTAssertEqual(savedAppliance?.model, "RF28R7351SR")
        XCTAssertEqual(savedAppliance?.category, .refrigerator)
        XCTAssertEqual(savedAppliance?.serialNumber, "SN12345")
        XCTAssertEqual(savedAppliance?.roomLocation, "Kitchen")
        XCTAssertEqual(savedAppliance?.notes, "New appliance")
        XCTAssertTrue(sut.showSuccessAlert)
    }

    func testSaveAppliance_WithInvalidData_ShowsError() async {
        // Given
        sut.brand = ""
        sut.modelNumber = ""

        // When
        await sut.saveAppliance()

        // Then
        XCTAssertEqual(mockInventoryService.appliances.count, 0)
        XCTAssertTrue(sut.showErrorAlert)
        XCTAssertEqual(sut.errorMessage, "Please fix validation errors")
    }

    func testSaveAppliance_WhenServiceFails_ShowsError() async {
        // Given
        sut.brand = "Samsung"
        sut.modelNumber = "ABC123"
        mockInventoryService.shouldThrowError = true

        // When
        await sut.saveAppliance()

        // Then
        XCTAssertTrue(sut.showErrorAlert)
        XCTAssertNotNil(sut.errorMessage)
    }

    func testSaveAppliance_TrimsWhitespace() async {
        // Given
        sut.brand = "  Samsung  "
        sut.modelNumber = "  ABC123  "
        sut.serialNumber = "  SN12345  "
        sut.location = "  Kitchen  "
        sut.notes = "  Test notes  "

        // When
        await sut.saveAppliance()

        // Then
        let savedAppliance = mockInventoryService.appliances.first
        XCTAssertEqual(savedAppliance?.brand, "Samsung")
        XCTAssertEqual(savedAppliance?.model, "ABC123")
        XCTAssertEqual(savedAppliance?.serialNumber, "SN12345")
        XCTAssertEqual(savedAppliance?.roomLocation, "Kitchen")
        XCTAssertEqual(savedAppliance?.notes, "Test notes")
    }

    func testSaveAppliance_WithEmptyOptionalFields_SavesNil() async {
        // Given
        sut.brand = "Samsung"
        sut.modelNumber = "ABC123"
        sut.serialNumber = ""
        sut.location = ""
        sut.notes = ""

        // When
        await sut.saveAppliance()

        // Then
        let savedAppliance = mockInventoryService.appliances.first
        XCTAssertNil(savedAppliance?.serialNumber)
        XCTAssertNil(savedAppliance?.roomLocation)
        XCTAssertNil(savedAppliance?.notes)
    }

    // MARK: - Reset Tests

    func testReset_ClearsAllFields() {
        // Given
        sut.brand = "Samsung"
        sut.modelNumber = "ABC123"
        sut.serialNumber = "SN123"
        sut.location = "Kitchen"
        sut.notes = "Test"
        sut.validationErrors = ["Error"]

        // When
        sut.reset()

        // Then
        XCTAssertEqual(sut.selectedCategory, .refrigerator)
        XCTAssertEqual(sut.brand, "")
        XCTAssertEqual(sut.modelNumber, "")
        XCTAssertEqual(sut.serialNumber, "")
        XCTAssertEqual(sut.location, "")
        XCTAssertEqual(sut.notes, "")
        XCTAssertNil(sut.selectedImage)
        XCTAssertTrue(sut.validationErrors.isEmpty)
    }

    // MARK: - Category Tests

    func testCategorySelection_UpdatesSelectedCategory() {
        // Given/When
        sut.selectedCategory = .hvac

        // Then
        XCTAssertEqual(sut.selectedCategory, .hvac)
    }

    // MARK: - Installation Date Tests

    func testInstallationDate_DefaultsToToday() {
        // Given
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let installDate = calendar.startOfDay(for: sut.installationDate)

        // Then
        XCTAssertEqual(installDate, today)
    }
}
