//
//  ServiceJobTests.swift
//  FieldServiceARTests
//
//  Unit tests for ServiceJob model
//

import XCTest
import SwiftData
@testable import FieldServiceAR

@MainActor
final class ServiceJobTests: XCTestCase {
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!

    override func setUpWithError() throws {
        let schema = Schema([ServiceJob.self, MediaEvidence.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [configuration])
        modelContext = ModelContext(modelContainer)
    }

    override func tearDownWithError() throws {
        modelContainer = nil
        modelContext = nil
    }

    // MARK: - Initialization Tests

    func testServiceJobInitialization() throws {
        // Given
        let workOrderNumber = "WO-12345"
        let title = "HVAC Repair"
        let scheduledDate = Date()
        let equipmentId = UUID()

        // When
        let job = ServiceJob(
            workOrderNumber: workOrderNumber,
            title: title,
            scheduledDate: scheduledDate,
            estimatedDuration: 3600,
            customerName: "Acme Corp",
            siteName: "Building A",
            address: "123 Main St",
            equipmentId: equipmentId,
            equipmentManufacturer: "Test Mfg",
            equipmentModel: "Model-001"
        )

        // Then
        XCTAssertNotNil(job.id)
        XCTAssertEqual(job.workOrderNumber, workOrderNumber)
        XCTAssertEqual(job.title, title)
        XCTAssertEqual(job.status, .scheduled)
        XCTAssertEqual(job.priority, .medium)
        XCTAssertEqual(job.estimatedDuration, 3600)
        XCTAssertFalse(job.needsUpload)
    }

    // MARK: - Status Tests

    func testJobStatusTransitions() throws {
        // Given
        let job = createTestJob()

        // Then - Initial state
        XCTAssertEqual(job.status, .scheduled)
        XCTAssertNil(job.actualStartTime)

        // When - Start job
        job.start()

        // Then
        XCTAssertEqual(job.status, .inProgress)
        XCTAssertNotNil(job.actualStartTime)

        // When - Complete job
        job.complete()

        // Then
        XCTAssertEqual(job.status, .completed)
        XCTAssertNotNil(job.actualEndTime)
        XCTAssertTrue(job.needsUpload)
    }

    func testJobStatusColors() throws {
        let statuses: [JobStatus] = [
            .scheduled, .inProgress, .onHold, .completed, .cancelled
        ]

        for status in statuses {
            XCTAssertFalse(status.color.isEmpty, "Status \(status) should have a color")
        }
    }

    // MARK: - Date Helper Tests

    func testIsToday() throws {
        // Given - Job scheduled today
        let todayJob = ServiceJob(
            workOrderNumber: "WO-001",
            title: "Today's Job",
            scheduledDate: Date(),
            estimatedDuration: 3600,
            customerName: "Test",
            siteName: "Test",
            address: "Test",
            equipmentId: UUID(),
            equipmentManufacturer: "Test",
            equipmentModel: "Test"
        )

        // Then
        XCTAssertTrue(todayJob.isToday)

        // Given - Job scheduled tomorrow
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let tomorrowJob = ServiceJob(
            workOrderNumber: "WO-002",
            title: "Tomorrow's Job",
            scheduledDate: tomorrow,
            estimatedDuration: 3600,
            customerName: "Test",
            siteName: "Test",
            address: "Test",
            equipmentId: UUID(),
            equipmentManufacturer: "Test",
            equipmentModel: "Test"
        )

        // Then
        XCTAssertFalse(tomorrowJob.isToday)
    }

    func testIsUpcoming() throws {
        // Given - Future job
        let futureDate = Calendar.current.date(byAdding: .day, value: 5, to: Date())!
        let futureJob = ServiceJob(
            workOrderNumber: "WO-001",
            title: "Future Job",
            scheduledDate: futureDate,
            estimatedDuration: 3600,
            customerName: "Test",
            siteName: "Test",
            address: "Test",
            equipmentId: UUID(),
            equipmentManufacturer: "Test",
            equipmentModel: "Test"
        )

        // Then
        XCTAssertTrue(futureJob.isUpcoming)

        // Given - Past job
        let pastDate = Calendar.current.date(byAdding: .day, value: -5, to: Date())!
        let pastJob = ServiceJob(
            workOrderNumber: "WO-002",
            title: "Past Job",
            scheduledDate: pastDate,
            estimatedDuration: 3600,
            customerName: "Test",
            siteName: "Test",
            address: "Test",
            equipmentId: UUID(),
            equipmentManufacturer: "Test",
            equipmentModel: "Test"
        )

        // Then
        XCTAssertFalse(pastJob.isUpcoming)
    }

    func testIsOverdue() throws {
        // Given - Past job not completed
        let pastDate = Calendar.current.date(byAdding: .day, value: -2, to: Date())!
        let overdueJob = ServiceJob(
            workOrderNumber: "WO-001",
            title: "Overdue Job",
            scheduledDate: pastDate,
            estimatedDuration: 3600,
            customerName: "Test",
            siteName: "Test",
            address: "Test",
            equipmentId: UUID(),
            equipmentManufacturer: "Test",
            equipmentModel: "Test"
        )

        // Then
        XCTAssertTrue(overdueJob.isOverdue)

        // When - Complete the job
        overdueJob.complete()

        // Then
        XCTAssertFalse(overdueJob.isOverdue)
    }

    // MARK: - Duration Tests

    func testActualDuration() throws {
        // Given
        let job = createTestJob()

        // Then - No duration before start
        XCTAssertNil(job.actualDuration)

        // When - Start and complete with known duration
        job.actualStartTime = Date()
        Thread.sleep(forTimeInterval: 0.1) // Small delay
        job.actualEndTime = Date()

        // Then
        XCTAssertNotNil(job.actualDuration)
        XCTAssertGreaterThan(job.actualDuration ?? 0, 0)
    }

    // MARK: - Priority Tests

    func testPriorityOrdering() throws {
        XCTAssertLessThan(JobPriority.low.order, JobPriority.medium.order)
        XCTAssertLessThan(JobPriority.medium.order, JobPriority.high.order)
        XCTAssertLessThan(JobPriority.high.order, JobPriority.critical.order)
    }

    // MARK: - Media Evidence Tests

    func testAddEvidence() throws {
        // Given
        let job = createTestJob()
        let evidence = MediaEvidence(
            type: .photo,
            fileName: "test.jpg",
            notes: "Test photo"
        )

        // When
        job.capturedEvidence.append(evidence)

        // Then
        XCTAssertEqual(job.capturedEvidence.count, 1)
        XCTAssertEqual(job.capturedEvidence.first?.type, .photo)
        XCTAssertEqual(job.capturedEvidence.first?.fileName, "test.jpg")
    }

    // MARK: - Persistence Tests

    func testJobPersistence() throws {
        // Given
        let job = createTestJob()

        // When
        modelContext.insert(job)
        try modelContext.save()

        // Fetch from context
        let descriptor = FetchDescriptor<ServiceJob>()
        let results = try modelContext.fetch(descriptor)

        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.workOrderNumber, job.workOrderNumber)
    }

    // MARK: - Helper Methods

    private func createTestJob() -> ServiceJob {
        ServiceJob(
            workOrderNumber: "WO-TEST",
            title: "Test Job",
            scheduledDate: Date(),
            estimatedDuration: 3600,
            customerName: "Test Customer",
            siteName: "Test Site",
            address: "123 Test St",
            equipmentId: UUID(),
            equipmentManufacturer: "Test Mfg",
            equipmentModel: "Test Model"
        )
    }
}
