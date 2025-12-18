//
// DashboardViewModelTests.swift
// Field Service AR Assistant
//
// Created by Claude on 2025-01-17.
//

import Testing
import Foundation
@testable import FieldServiceAR

@MainActor
final class DashboardViewModelTests {

    // MARK: - Initialization Tests

    @Test("Dashboard ViewModel initializes with correct default state")
    func testInitialization() {
        let viewModel = DashboardViewModel()

        #expect(viewModel.jobs.isEmpty)
        #expect(viewModel.selectedFilter == .all)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.error == nil)
    }

    // MARK: - Filter Tests

    @Test("Filter changes to scheduled correctly")
    func testFilterScheduled() {
        let viewModel = DashboardViewModel()

        viewModel.selectedFilter = .scheduled

        #expect(viewModel.selectedFilter == .scheduled)
    }

    @Test("Filter changes to in progress correctly")
    func testFilterInProgress() {
        let viewModel = DashboardViewModel()

        viewModel.selectedFilter = .inProgress

        #expect(viewModel.selectedFilter == .inProgress)
    }

    @Test("Filtered jobs returns only scheduled jobs")
    func testFilteredJobsScheduled() {
        let viewModel = DashboardViewModel()

        // Create test jobs
        let scheduledJob = ServiceJob(
            workOrderNumber: "WO-001",
            customerName: "Acme Corp",
            scheduledDate: Date(),
            estimatedDuration: 3600
        )
        scheduledJob.status = .scheduled

        let inProgressJob = ServiceJob(
            workOrderNumber: "WO-002",
            customerName: "Test Inc",
            scheduledDate: Date(),
            estimatedDuration: 3600
        )
        inProgressJob.status = .inProgress

        viewModel.jobs = [scheduledJob, inProgressJob]
        viewModel.selectedFilter = .scheduled

        let filtered = viewModel.filteredJobs

        #expect(filtered.count == 1)
        #expect(filtered.first?.workOrderNumber == "WO-001")
    }

    @Test("Filtered jobs returns only in progress jobs")
    func testFilteredJobsInProgress() {
        let viewModel = DashboardViewModel()

        // Create test jobs
        let scheduledJob = ServiceJob(
            workOrderNumber: "WO-001",
            customerName: "Acme Corp",
            scheduledDate: Date(),
            estimatedDuration: 3600
        )
        scheduledJob.status = .scheduled

        let inProgressJob = ServiceJob(
            workOrderNumber: "WO-002",
            customerName: "Test Inc",
            scheduledDate: Date(),
            estimatedDuration: 3600
        )
        inProgressJob.status = .inProgress

        viewModel.jobs = [scheduledJob, inProgressJob]
        viewModel.selectedFilter = .inProgress

        let filtered = viewModel.filteredJobs

        #expect(filtered.count == 1)
        #expect(filtered.first?.workOrderNumber == "WO-002")
    }

    @Test("Filtered jobs returns all jobs when filter is all")
    func testFilteredJobsAll() {
        let viewModel = DashboardViewModel()

        let job1 = ServiceJob(
            workOrderNumber: "WO-001",
            customerName: "Acme Corp",
            scheduledDate: Date(),
            estimatedDuration: 3600
        )

        let job2 = ServiceJob(
            workOrderNumber: "WO-002",
            customerName: "Test Inc",
            scheduledDate: Date(),
            estimatedDuration: 3600
        )

        viewModel.jobs = [job1, job2]
        viewModel.selectedFilter = .all

        let filtered = viewModel.filteredJobs

        #expect(filtered.count == 2)
    }

    // MARK: - Job Management Tests

    @Test("Start job updates status to in progress")
    func testStartJob() {
        let viewModel = DashboardViewModel()

        let job = ServiceJob(
            workOrderNumber: "WO-001",
            customerName: "Acme Corp",
            scheduledDate: Date(),
            estimatedDuration: 3600
        )

        viewModel.jobs = [job]
        viewModel.startJob(job)

        #expect(job.status == .inProgress)
        #expect(job.actualStartTime != nil)
    }

    @Test("Complete job updates status to completed")
    func testCompleteJob() {
        let viewModel = DashboardViewModel()

        let job = ServiceJob(
            workOrderNumber: "WO-001",
            customerName: "Acme Corp",
            scheduledDate: Date(),
            estimatedDuration: 3600
        )
        job.start()

        viewModel.jobs = [job]
        viewModel.completeJob(job)

        #expect(job.status == .completed)
        #expect(job.actualEndTime != nil)
    }

    // MARK: - Search Tests

    @Test("Search query filters jobs by work order number")
    func testSearchByWorkOrder() {
        let viewModel = DashboardViewModel()

        let job1 = ServiceJob(
            workOrderNumber: "WO-001",
            customerName: "Acme Corp",
            scheduledDate: Date(),
            estimatedDuration: 3600
        )

        let job2 = ServiceJob(
            workOrderNumber: "WO-002",
            customerName: "Test Inc",
            scheduledDate: Date(),
            estimatedDuration: 3600
        )

        viewModel.jobs = [job1, job2]
        viewModel.searchQuery = "WO-001"

        let filtered = viewModel.filteredJobs

        #expect(filtered.count == 1)
        #expect(filtered.first?.workOrderNumber == "WO-001")
    }

    @Test("Search query filters jobs by customer name")
    func testSearchByCustomer() {
        let viewModel = DashboardViewModel()

        let job1 = ServiceJob(
            workOrderNumber: "WO-001",
            customerName: "Acme Corp",
            scheduledDate: Date(),
            estimatedDuration: 3600
        )

        let job2 = ServiceJob(
            workOrderNumber: "WO-002",
            customerName: "Test Inc",
            scheduledDate: Date(),
            estimatedDuration: 3600
        )

        viewModel.jobs = [job1, job2]
        viewModel.searchQuery = "Acme"

        let filtered = viewModel.filteredJobs

        #expect(filtered.count == 1)
        #expect(filtered.first?.customerName == "Acme Corp")
    }

    @Test("Empty search query returns all jobs")
    func testEmptySearch() {
        let viewModel = DashboardViewModel()

        let job1 = ServiceJob(
            workOrderNumber: "WO-001",
            customerName: "Acme Corp",
            scheduledDate: Date(),
            estimatedDuration: 3600
        )

        let job2 = ServiceJob(
            workOrderNumber: "WO-002",
            customerName: "Test Inc",
            scheduledDate: Date(),
            estimatedDuration: 3600
        )

        viewModel.jobs = [job1, job2]
        viewModel.searchQuery = ""

        let filtered = viewModel.filteredJobs

        #expect(filtered.count == 2)
    }

    // MARK: - Priority Tests

    @Test("Jobs sorted by priority correctly")
    func testJobsSortedByPriority() {
        let viewModel = DashboardViewModel()

        let lowPriorityJob = ServiceJob(
            workOrderNumber: "WO-001",
            customerName: "Acme Corp",
            scheduledDate: Date(),
            estimatedDuration: 3600
        )
        lowPriorityJob.priority = .low

        let highPriorityJob = ServiceJob(
            workOrderNumber: "WO-002",
            customerName: "Test Inc",
            scheduledDate: Date(),
            estimatedDuration: 3600
        )
        highPriorityJob.priority = .high

        let criticalPriorityJob = ServiceJob(
            workOrderNumber: "WO-003",
            customerName: "Critical Inc",
            scheduledDate: Date(),
            estimatedDuration: 3600
        )
        criticalPriorityJob.priority = .critical

        viewModel.jobs = [lowPriorityJob, highPriorityJob, criticalPriorityJob]

        let sorted = viewModel.sortedJobs

        #expect(sorted[0].priority == .critical)
        #expect(sorted[1].priority == .high)
        #expect(sorted[2].priority == .low)
    }
}
