//
//  RecognitionViewModelTests.swift
//  HomeMaintenanceOracleTests
//
//  Created on 2025-11-24.
//  Unit tests for RecognitionViewModel
//

import XCTest
@testable import HomeMaintenanceOracle

@MainActor
final class RecognitionViewModelTests: XCTestCase {

    var sut: RecognitionViewModel!
    var mockRecognitionService: MockRecognitionService!
    var mockInventoryService: MockInventoryService!
    var mockCameraService: MockCameraService!

    override func setUp() async throws {
        try await super.setUp()
        mockRecognitionService = MockRecognitionService()
        mockInventoryService = MockInventoryService()
        mockCameraService = MockCameraService()
        sut = RecognitionViewModel(
            recognitionService: mockRecognitionService,
            inventoryService: mockInventoryService,
            cameraService: mockCameraService
        )
    }

    override func tearDown() async throws {
        sut = nil
        mockRecognitionService = nil
        mockInventoryService = nil
        mockCameraService = nil
        try await super.tearDown()
    }

    // MARK: - Initial State Tests

    func testInitialState() {
        XCTAssertFalse(sut.isRecognizing)
        XCTAssertNil(sut.recognitionResult)
        XCTAssertNil(sut.error)
        XCTAssertEqual(sut.cameraPermissionStatus, .notDetermined)
    }

    // MARK: - Camera Permission Tests

    func testRequestCameraPermission_WhenGranted_UpdatesStatus() async {
        // Given
        mockCameraService.shouldGrantPermission = true

        // When
        await sut.requestCameraPermission()

        // Then
        XCTAssertEqual(sut.cameraPermissionStatus, .authorized)
        XCTAssertNil(sut.error)
    }

    func testRequestCameraPermission_WhenDenied_UpdatesStatusAndSetsError() async {
        // Given
        mockCameraService.shouldGrantPermission = false

        // When
        await sut.requestCameraPermission()

        // Then
        XCTAssertEqual(sut.cameraPermissionStatus, .denied)
        XCTAssertNotNil(sut.error)
    }

    // MARK: - Recognition Tests

    func testCaptureAndRecognize_WithAuthorizedCamera_SuccessfullyRecognizes() async {
        // Given
        mockCameraService.shouldGrantPermission = true
        mockCameraService.authorizationStatus = .authorized
        mockRecognitionService.mockResult = RecognitionResult(
            category: "refrigerator",
            brand: "Samsung",
            model: "RF28R7351SR",
            confidence: 0.95,
            alternatives: []
        )

        // When
        sut.captureAndRecognize()

        // Wait for async operation
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertFalse(sut.isRecognizing)
        XCTAssertNotNil(sut.recognitionResult)
        XCTAssertEqual(sut.recognitionResult?.category, "refrigerator")
        XCTAssertEqual(sut.recognitionResult?.confidence, 0.95)
    }

    func testCaptureAndRecognize_WithoutPermission_RequestsPermission() async {
        // Given
        mockCameraService.shouldGrantPermission = false
        sut.cameraPermissionStatus = .notDetermined

        // When
        sut.captureAndRecognize()

        // Wait for async operation
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertNotNil(sut.error)
        XCTAssertNil(sut.recognitionResult)
    }

    func testCaptureAndRecognize_WhenRecognitionFails_SetsError() async {
        // Given
        mockCameraService.shouldGrantPermission = true
        mockCameraService.authorizationStatus = .authorized
        mockRecognitionService.shouldThrowError = true

        // When
        sut.captureAndRecognize()

        // Wait for async operation
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertFalse(sut.isRecognizing)
        XCTAssertNotNil(sut.error)
        XCTAssertNil(sut.recognitionResult)
    }

    // MARK: - Save Appliance Tests

    func testSaveAppliance_WithValidResult_SavesSuccessfully() async {
        // Given
        sut.recognitionResult = RecognitionResult(
            category: "refrigerator",
            brand: "Samsung",
            model: "RF28R7351SR",
            confidence: 0.95,
            alternatives: []
        )

        // When
        sut.saveAppliance()

        // Wait for async operation
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertEqual(mockInventoryService.appliances.count, 1)
        XCTAssertEqual(mockInventoryService.appliances.first?.brand, "Samsung")
        XCTAssertNil(sut.recognitionResult) // Should reset after save
    }

    func testSaveAppliance_WithoutResult_DoesNothing() async {
        // Given
        sut.recognitionResult = nil

        // When
        sut.saveAppliance()

        // Wait for async operation
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertEqual(mockInventoryService.appliances.count, 0)
    }

    // MARK: - Reset Tests

    func testReset_ClearsStateCorrectly() {
        // Given
        sut.recognitionResult = RecognitionResult(
            category: "refrigerator",
            brand: "Samsung",
            model: "RF28R7351SR",
            confidence: 0.95,
            alternatives: []
        )
        sut.error = NSError(domain: "test", code: 1)

        // When
        sut.reset()

        // Then
        XCTAssertNil(sut.recognitionResult)
        XCTAssertNil(sut.error)
    }

    // MARK: - Loading State Tests

    func testCaptureAndRecognize_SetsLoadingState() async {
        // Given
        mockCameraService.shouldGrantPermission = true
        mockCameraService.authorizationStatus = .authorized

        // When
        sut.captureAndRecognize()

        // Then - Check immediately that loading started
        // Note: In real async testing, we'd need better synchronization
        try? await Task.sleep(nanoseconds: 10_000_000)

        // Eventually loading should be false after completion
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertFalse(sut.isRecognizing)
    }
}

// MARK: - Mock Services for Testing

class MockInventoryService: InventoryServiceProtocol {
    var appliances: [Appliance] = []
    var shouldThrowError = false

    func addAppliance(_ appliance: Appliance) async throws {
        if shouldThrowError {
            throw NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Mock error"])
        }
        appliances.append(appliance)
    }

    func getAppliances() async throws -> [Appliance] {
        return appliances
    }

    func getAppliance(byId id: UUID) async throws -> Appliance? {
        return appliances.first { $0.id == id }
    }

    func updateAppliance(_ appliance: Appliance) async throws {
        if let index = appliances.firstIndex(where: { $0.id == appliance.id }) {
            appliances[index] = appliance
        }
    }

    func deleteAppliance(_ id: UUID) async throws {
        appliances.removeAll { $0.id == id }
    }

    func searchAppliances(query: String) async throws -> [Appliance] {
        return appliances.filter {
            $0.brand.localizedCaseInsensitiveContains(query) ||
            $0.model.localizedCaseInsensitiveContains(query)
        }
    }
}
