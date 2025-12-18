//
//  DashboardViewModel.swift
//  FieldServiceAR
//
//  ViewModel for Dashboard
//

import Foundation
import Observation
import SwiftData

@Observable
@MainActor
class DashboardViewModel {
    private let jobRepository: JobRepository
    private let appState: AppState

    // State
    var jobs: [ServiceJob] = []
    var filteredJobs: [ServiceJob] = []
    var selectedFilter: JobFilter = .today
    var searchQuery: String = "" {
        didSet {
            applyFilters()
        }
    }

    var isLoading: Bool = false
    var error: Error?

    init(jobRepository: JobRepository, appState: AppState) {
        self.jobRepository = jobRepository
        self.appState = appState
    }

    func loadJobs() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let allJobs = try await jobRepository.fetchAll()
            jobs = allJobs
            applyFilters()
        } catch {
            self.error = error
        }
    }

    func selectFilter(_ filter: JobFilter) {
        selectedFilter = filter
        applyFilters()
    }

    private func applyFilters() {
        var filtered = jobs

        // Apply status filter
        switch selectedFilter {
        case .today:
            filtered = filtered.filter { $0.isToday }
        case .upcoming:
            filtered = filtered.filter { $0.isUpcoming }
        case .completed:
            filtered = filtered.filter { $0.status == .completed }
        case .all:
            break
        }

        // Apply search
        if !searchQuery.isEmpty {
            let query = searchQuery.lowercased()
            filtered = filtered.filter {
                $0.workOrderNumber.lowercased().contains(query) ||
                $0.title.lowercased().contains(query) ||
                $0.customerName.lowercased().contains(query)
            }
        }

        // Sort by priority and date
        filtered.sort { job1, job2 in
            if job1.priority.order != job2.priority.order {
                return job1.priority.order > job2.priority.order
            }
            return job1.scheduledDate < job2.scheduledDate
        }

        filteredJobs = filtered
    }

    func selectJob(_ job: ServiceJob) {
        appState.selectedJob = job
    }

    func refresh() async {
        await loadJobs()
    }
}

// Job Filter
enum JobFilter: String, CaseIterable {
    case today = "Today"
    case upcoming = "Upcoming"
    case completed = "Completed"
    case all = "All"
}
