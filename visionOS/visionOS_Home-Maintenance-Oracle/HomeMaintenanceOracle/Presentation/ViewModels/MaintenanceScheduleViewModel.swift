//
//  MaintenanceScheduleViewModel.swift
//  HomeMaintenanceOracle
//
//  Created on 2025-11-24.
//  ViewModel for maintenance schedule view
//

import Foundation

@MainActor
class MaintenanceScheduleViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var tasks: [MaintenanceTask] = []
    @Published var isLoading = false
    @Published var showAddTaskSheet = false
    @Published var errorMessage: String?

    // MARK: - Dependencies

    private let maintenanceService: MaintenanceServiceProtocol

    // MARK: - Initialization

    init(maintenanceService: MaintenanceServiceProtocol = AppDependencies.shared.maintenanceService) {
        self.maintenanceService = maintenanceService
    }

    // MARK: - Methods

    func loadTasks() async {
        isLoading = true
        defer { isLoading = false }

        do {
            // Load all upcoming tasks (limit 50)
            let upcomingTasks = try await maintenanceService.getUpcomingTasks(limit: 50)
            let overdueTasks = try await maintenanceService.getOverdueTasks()

            // Combine and sort by due date
            tasks = (upcomingTasks + overdueTasks)
                .sorted { $0.nextDueDate < $1.nextDueDate }

        } catch {
            errorMessage = error.localizedDescription
            print("Failed to load tasks: \(error)")
        }
    }

    func completeTask(_ taskId: UUID) async {
        do {
            try await maintenanceService.completeTask(taskId, completionNotes: nil)

            // Reload tasks to reflect changes
            await loadTasks()

        } catch {
            errorMessage = error.localizedDescription
            print("Failed to complete task: \(error)")
        }
    }

    func deleteTask(_ taskId: UUID) async {
        do {
            try await maintenanceService.deleteTask(taskId)

            // Remove from local list
            tasks.removeAll { $0.id == taskId }

        } catch {
            errorMessage = error.localizedDescription
            print("Failed to delete task: \(error)")
        }
    }
}
