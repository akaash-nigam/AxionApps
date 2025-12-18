//
//  JobRepositoryTests.swift
//  FieldServiceARTests
//
//  Unit tests for JobRepository
//

import XCTest
import SwiftData
@testable import FieldServiceAR

@MainActor
final class JobRepositoryTests: XCTestCase {
    var modelContainer: ModelContainer!
    var repository: JobRepository!

    override func setUpWithError() throws {
        let schema = Schema([ServiceJob.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [configuration])
        repository = JobRepository(modelContainer: modelContainer)
    }

    override func tearDownWithError() throws {
        modelContainer = nil
        repository = nil
    }

    // MARK: - Fetch Tests

    func testFetchAll() async throws {
        // Given
        let job1 = createJob(workOrder: "WO-001", scheduledDays: 0)
        let job2 = createJob(workOrder: "WO-002", scheduledDays: 1)
        let job3 = createJob(workOrder: "WO-003", scheduledDays: -1)

        try await repository.save(job1)
        try await repository.save(job2)
        try await repository.save(job3)

        // When
        let jobs = try await repository.fetchAll()

        // Then
        XCTAssertEqual(jobs.count, 3)
        // Should be sorted by scheduled date
        XCTAssertEqual(jobs[0].workOrderNumber, "WO-003") // Yesterday
        XCTAssertEqual(jobs[1].workOrderNumber, "WO-001") // Today
        XCTAssertEqual(jobs[2].workOrderNumber, "WO-002") // Tomorrow
    }

    func testFetchToday() async throws {
        // Given
        let todayJob = createJob(workOrder: "WO-TODAY", scheduledDays: 0)
        let tomorrowJob = createJob(workOrder: "WO-TOMORROW", scheduledDays: 1)
        let yesterdayJob = createJob(workOrder: "WO-YESTERDAY", scheduledDays: -1)

        try await repository.save(todayJob)
        try await repository.save(tomorrowJob)
        try await repository.save(yesterdayJob)

        // When
        let todayJobs = try await repository.fetchToday()

        // Then
        XCTAssertEqual(todayJobs.count, 1)
        XCTAssertEqual(todayJobs.first?.workOrderNumber, "WO-TODAY")
    }

    func testFetchUpcoming() async throws {
        // Given
        let futureJob1 = createJob(workOrder: "WO-FUTURE1", scheduledDays: 1)
        let futureJob2 = createJob(workOrder: "WO-FUTURE2", scheduledDays: 7)
        let pastJob = createJob(workOrder: "WO-PAST", scheduledDays: -1)
        let todayJob = createJob(workOrder: "WO-TODAY", scheduledDays: 0)

        try await repository.save(futureJob1)
        try await repository.save(futureJob2)
        try await repository.save(pastJob)
        try await repository.save(todayJob)

        // When
        let upcomingJobs = try await repository.fetchUpcoming()

        // Then
        XCTAssertEqual(upcomingJobs.count, 2)
        XCTAssertTrue(upcomingJobs.contains(where: { $0.workOrderNumber == "WO-FUTURE1" }))
        XCTAssertTrue(upcomingJobs.contains(where: { $0.workOrderNumber == "WO-FUTURE2" }))
    }

    func testFetchById() async throws {
        // Given
        let job = createJob(workOrder: "WO-FIND-ME", scheduledDays: 0)
        try await repository.save(job)
        let jobId = job.id

        // When
        let foundJob = try await repository.fetchById(jobId)

        // Then
        XCTAssertNotNil(foundJob)
        XCTAssertEqual(foundJob?.workOrderNumber, "WO-FIND-ME")
    }

    func testFetchByIdNotFound() async throws {
        // Given
        let randomId = UUID()

        // When
        let job = try await repository.fetchById(randomId)

        // Then
        XCTAssertNil(job)
    }

    // MARK: - Search Tests

    func testSearchByWorkOrderNumber() async throws {
        // Given
        let job1 = createJob(workOrder: "HVAC-12345", scheduledDays: 0)
        let job2 = createJob(workOrder: "ELEC-67890", scheduledDays: 0)
        let job3 = createJob(workOrder: "HVAC-54321", scheduledDays: 0)

        try await repository.save(job1)
        try await repository.save(job2)
        try await repository.save(job3)

        // When
        let results = try await repository.search(query: "HVAC")

        // Then
        XCTAssertEqual(results.count, 2)
        XCTAssertTrue(results.allSatisfy { $0.workOrderNumber.contains("HVAC") })
    }

    func testSearchByCustomerName() async throws {
        // Given
        let job1 = createJob(workOrder: "WO-001", scheduledDays: 0, customer: "Acme Corp")
        let job2 = createJob(workOrder: "WO-002", scheduledDays: 0, customer: "Tech Industries")
        let job3 = createJob(workOrder: "WO-003", scheduledDays: 0, customer: "Acme Manufacturing")

        try await repository.save(job1)
        try await repository.save(job2)
        try await repository.save(job3)

        // When
        let results = try await repository.search(query: "acme")

        // Then
        XCTAssertEqual(results.count, 2)
        XCTAssertTrue(results.allSatisfy { $0.customerName.lowercased().contains("acme") })
    }

    func testSearchCaseInsensitive() async throws {
        // Given
        let job = createJob(workOrder: "TEST-123", scheduledDays: 0)
        try await repository.save(job)

        // When
        let resultsLower = try await repository.search(query: "test")
        let resultsUpper = try await repository.search(query: "TEST")
        let resultsMixed = try await repository.search(query: "TeSt")

        // Then
        XCTAssertEqual(resultsLower.count, 1)
        XCTAssertEqual(resultsUpper.count, 1)
        XCTAssertEqual(resultsMixed.count, 1)
    }

    // MARK: - CRUD Tests

    func testSaveJob() async throws {
        // Given
        let job = createJob(workOrder: "WO-SAVE", scheduledDays: 0)

        // When
        try await repository.save(job)
        let jobs = try await repository.fetchAll()

        // Then
        XCTAssertEqual(jobs.count, 1)
        XCTAssertEqual(jobs.first?.workOrderNumber, "WO-SAVE")
    }

    func testUpdateJob() async throws {
        // Given
        let job = createJob(workOrder: "WO-UPDATE", scheduledDays: 0)
        try await repository.save(job)

        // When
        job.status = .inProgress
        job.priority = .high
        try await repository.update(job)

        let updatedJob = try await repository.fetchById(job.id)

        // Then
        XCTAssertEqual(updatedJob?.status, .inProgress)
        XCTAssertEqual(updatedJob?.priority, .high)
        XCTAssertNotNil(updatedJob?.updatedAt)
    }

    func testDeleteJob() async throws {
        // Given
        let job = createJob(workOrder: "WO-DELETE", scheduledDays: 0)
        try await repository.save(job)
        XCTAssertEqual(try await repository.fetchAll().count, 1)

        // When
        try await repository.delete(job)
        let jobs = try await repository.fetchAll()

        // Then
        XCTAssertEqual(jobs.count, 0)
    }

    // MARK: - Helper Methods

    private func createJob(
        workOrder: String,
        scheduledDays: Int,
        customer: String = "Test Customer"
    ) -> ServiceJob {
        let scheduledDate = Calendar.current.date(
            byAdding: .day,
            value: scheduledDays,
            to: Date()
        )!

        return ServiceJob(
            workOrderNumber: workOrder,
            title: "Test Job",
            scheduledDate: scheduledDate,
            estimatedDuration: 3600,
            customerName: customer,
            siteName: "Test Site",
            address: "123 Test St",
            equipmentId: UUID(),
            equipmentManufacturer: "Test Mfg",
            equipmentModel: "Test Model"
        )
    }
}
