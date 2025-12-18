//
//  RecognitionFlowIntegrationTests.swift
//  HomeMaintenanceOracleTests
//
//  Created on 2025-11-24.
//  Integration tests for the complete recognition flow
//

import XCTest
@testable import HomeMaintenanceOracle

@MainActor
final class RecognitionFlowIntegrationTests: XCTestCase {

    var cameraService: MockCameraService!
    var imagePreprocessor: ImagePreprocessor!
    var classifier: ApplianceClassifierWrapper!
    var recognitionService: RecognitionService!
    var inventoryService: MockInventoryService!
    var viewModel: RecognitionViewModel!

    override func setUp() async throws {
        try await super.setUp()

        // Set up the complete pipeline
        cameraService = MockCameraService()
        imagePreprocessor = ImagePreprocessor()
        classifier = ApplianceClassifierWrapper()
        recognitionService = RecognitionService(
            preprocessor: imagePreprocessor,
            classifier: classifier
        )
        inventoryService = MockInventoryService()
        viewModel = RecognitionViewModel(
            recognitionService: recognitionService,
            inventoryService: inventoryService,
            cameraService: cameraService
        )
    }

    override func tearDown() async throws {
        viewModel = nil
        recognitionService = nil
        inventoryService = nil
        cameraService = nil
        imagePreprocessor = nil
        classifier = nil
        try await super.tearDown()
    }

    // MARK: - End-to-End Flow Tests

    func testCompleteRecognitionFlow_FromCameraToSave() async throws {
        // Given - User has granted camera permission
        cameraService.shouldGrantPermission = true
        cameraService.authorizationStatus = .authorized

        // When - User initiates capture and recognize
        viewModel.captureAndRecognize()

        // Wait for async operations
        try await Task.sleep(nanoseconds: 500_000_000)

        // Then - Should have recognition result
        XCTAssertNotNil(viewModel.recognitionResult)
        XCTAssertFalse(viewModel.isRecognizing)

        // When - User saves the result
        viewModel.saveAppliance()

        // Wait for save operation
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then - Appliance should be saved to inventory
        XCTAssertEqual(inventoryService.appliances.count, 1)
        XCTAssertNil(viewModel.recognitionResult) // Should reset after save
    }

    func testRecognitionFlow_WithPermissionDenied_ShowsError() async throws {
        // Given - User denies camera permission
        cameraService.shouldGrantPermission = false
        viewModel.cameraPermissionStatus = .notDetermined

        // When - User attempts to recognize
        viewModel.captureAndRecognize()

        // Wait for permission request
        try await Task.sleep(nanoseconds: 200_000_000)

        // Then - Should show error and not proceed
        XCTAssertNotNil(viewModel.error)
        XCTAssertNil(viewModel.recognitionResult)
        XCTAssertEqual(inventoryService.appliances.count, 0)
    }

    func testRecognitionFlow_WithLowQualityImage_ShowsError() async throws {
        // Given - Camera authorized but will return poor quality image
        cameraService.shouldGrantPermission = true
        cameraService.authorizationStatus = .authorized
        // TODO: Mock a low-quality image that fails preprocessing

        // This test would verify that poor quality images are rejected early
        // in the pipeline before reaching the ML model
    }

    // MARK: - Multiple Operations Integration

    func testMultipleRecognitions_InSequence() async throws {
        // Given
        cameraService.shouldGrantPermission = true
        cameraService.authorizationStatus = .authorized

        // When - Perform multiple recognitions
        for _ in 0..<3 {
            viewModel.captureAndRecognize()
            try await Task.sleep(nanoseconds: 500_000_000)

            if viewModel.recognitionResult != nil {
                viewModel.saveAppliance()
                try await Task.sleep(nanoseconds: 100_000_000)
            }
        }

        // Then - All should be saved
        XCTAssertEqual(inventoryService.appliances.count, 3)
    }

    // MARK: - Error Recovery Integration

    func testRecognitionFlow_RecoverFromError() async throws {
        // Given - First attempt fails
        cameraService.shouldGrantPermission = true
        cameraService.authorizationStatus = .authorized
        recognitionService = RecognitionService(
            preprocessor: imagePreprocessor,
            classifier: classifier
        )

        // When - First attempt (will use mock result)
        viewModel.captureAndRecognize()
        try await Task.sleep(nanoseconds: 500_000_000)

        if viewModel.error != nil {
            // When - Reset and try again
            viewModel.reset()
            XCTAssertNil(viewModel.error)

            viewModel.captureAndRecognize()
            try await Task.sleep(nanoseconds: 500_000_000)
        }

        // Then - Should eventually succeed or handle gracefully
        XCTAssertTrue(viewModel.recognitionResult != nil || viewModel.error != nil)
    }
}

// MARK: - Inventory Integration Tests

final class InventoryIntegrationTests: XCTestCase {

    func testInventoryOperations_CompleteFlow() async throws {
        // Given - Set up services
        let inventoryService = MockInventoryService()

        // When - Add multiple appliances
        let refrigerator = Appliance(
            brand: "Samsung",
            model: "RF28R7351SR",
            category: .refrigerator
        )
        let hvac = Appliance(
            brand: "Carrier",
            model: "HVAC123",
            category: .hvac
        )

        try await inventoryService.addAppliance(refrigerator)
        try await inventoryService.addAppliance(hvac)

        // Then - Should be retrievable
        let allAppliances = try await inventoryService.getAppliances()
        XCTAssertEqual(allAppliances.count, 2)

        // When - Search for specific appliance
        let searchResults = try await inventoryService.searchAppliances(query: "Samsung")

        // Then - Should find correct appliance
        XCTAssertEqual(searchResults.count, 1)
        XCTAssertEqual(searchResults.first?.brand, "Samsung")

        // When - Update appliance
        var updatedRefrigerator = refrigerator
        updatedRefrigerator.notes = "Updated notes"
        try await inventoryService.updateAppliance(updatedRefrigerator)

        // Then - Changes should persist
        let retrieved = try await inventoryService.getAppliance(byId: refrigerator.id)
        XCTAssertEqual(retrieved?.notes, "Updated notes")

        // When - Delete appliance
        try await inventoryService.deleteAppliance(hvac.id)

        // Then - Should be removed
        let remaining = try await inventoryService.getAppliances()
        XCTAssertEqual(remaining.count, 1)
        XCTAssertEqual(remaining.first?.id, refrigerator.id)
    }
}

// MARK: - Maintenance Integration Tests

final class MaintenanceIntegrationTests: XCTestCase {

    func testMaintenanceWorkflow_CompleteFlow() async throws {
        // Given - Set up services
        let repository = MockMaintenanceRepository()
        let notificationManager = MockNotificationManager()
        let maintenanceService = MaintenanceService(
            repository: repository,
            notificationManager: notificationManager
        )

        let appliance = Appliance(
            brand: "Samsung",
            model: "RF28R7351SR",
            category: .refrigerator
        )

        // When - Generate recommended tasks
        let recommendedTasks = maintenanceService.generateRecommendedTasks(for: appliance)
        XCTAssertEqual(recommendedTasks.count, 2)

        // When - Create tasks
        for task in recommendedTasks {
            try await maintenanceService.createTask(task)
        }

        // Then - Tasks should be saved and notifications scheduled
        XCTAssertEqual(repository.tasks.count, 2)
        XCTAssertEqual(notificationManager.scheduledNotifications.count, 2)

        // When - Get upcoming tasks
        let upcomingTasks = try await maintenanceService.getUpcomingTasks(limit: 10)
        XCTAssertEqual(upcomingTasks.count, 2)

        // When - Complete a task
        let taskToComplete = upcomingTasks.first!
        try await maintenanceService.completeTask(taskToComplete.id, completionNotes: "Completed successfully")

        // Then - Task should be marked complete and rescheduled (if recurring)
        let completedTask = try await repository.getTask(taskToComplete.id)
        XCTAssertNotNil(completedTask?.lastCompletedDate)

        if taskToComplete.frequency != .oneTime {
            // Recurring task should have new due date
            XCTAssertFalse(completedTask?.isCompleted ?? true)
            XCTAssertNotEqual(completedTask?.nextDueDate, taskToComplete.nextDueDate)
        }
    }

    func testServiceHistory_CompleteFlow() async throws {
        // Given
        let repository = MockMaintenanceRepository()
        let notificationManager = MockNotificationManager()
        let maintenanceService = MaintenanceService(
            repository: repository,
            notificationManager: notificationManager
        )
        let applianceId = UUID()

        // When - Add multiple service records
        let repair = ServiceHistory(
            applianceId: applianceId,
            serviceDate: Date().addingTimeInterval(-86400 * 30),
            serviceType: .repair,
            cost: 150.00,
            partsReplaced: ["Compressor"]
        )
        let routine = ServiceHistory(
            applianceId: applianceId,
            serviceDate: Date(),
            serviceType: .routine,
            cost: 50.00
        )

        try await maintenanceService.addServiceRecord(repair)
        try await maintenanceService.addServiceRecord(routine)

        // Then - Should be retrievable and sorted
        let history = try await maintenanceService.getServiceHistory(for: applianceId)
        XCTAssertEqual(history.count, 2)
        // Should be sorted with most recent first
        XCTAssertEqual(history.first?.serviceType, .routine)

        // When - Delete a record
        try await maintenanceService.deleteServiceRecord(repair.id)

        // Then - Should be removed
        let updatedHistory = try await maintenanceService.getServiceHistory(for: applianceId)
        XCTAssertEqual(updatedHistory.count, 1)
    }
}
