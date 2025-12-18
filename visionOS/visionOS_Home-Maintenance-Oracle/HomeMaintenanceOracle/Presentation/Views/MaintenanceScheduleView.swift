//
//  MaintenanceScheduleView.swift
//  HomeMaintenanceOracle
//
//  Created on 2025-11-24.
//  Maintenance task schedule and tracking
//

import SwiftUI

struct MaintenanceScheduleView: View {

    // MARK: - Properties

    @StateObject private var viewModel = MaintenanceScheduleViewModel()
    @State private var selectedFilter: TaskFilter = .all

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter Picker
                filterPicker

                // Task List
                if viewModel.isLoading {
                    ProgressView("Loading tasks...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if filteredTasks.isEmpty {
                    emptyStateView
                } else {
                    taskListView
                }
            }
            .navigationTitle("Maintenance")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            viewModel.showAddTaskSheet = true
                        } label: {
                            Label("Add Task", systemImage: "plus")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .task {
                await viewModel.loadTasks()
            }
            .refreshable {
                await viewModel.loadTasks()
            }
            .sheet(isPresented: $viewModel.showAddTaskSheet) {
                Text("Add Task Form - TODO")
            }
        }
    }

    // MARK: - View Components

    private var filterPicker: some View {
        Picker("Filter", selection: $selectedFilter) {
            ForEach(TaskFilter.allCases, id: \.self) { filter in
                Text(filter.displayName).tag(filter)
            }
        }
        .pickerStyle(.segmented)
        .padding()
    }

    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("No Tasks", systemImage: "calendar.badge.checkmark")
        } description: {
            Text(emptyStateMessage)
        } actions: {
            Button("Add Task") {
                viewModel.showAddTaskSheet = true
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var taskListView: some View {
        List {
            // Overdue Section
            if !overdueTasks.isEmpty {
                Section {
                    ForEach(overdueTasks) { task in
                        MaintenanceTaskRow(task: task) {
                            await viewModel.completeTask(task.id)
                        }
                    }
                } header: {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.red)
                        Text("Overdue (\(overdueTasks.count))")
                    }
                }
            }

            // Upcoming Section
            if !upcomingTasks.isEmpty {
                Section {
                    ForEach(upcomingTasks) { task in
                        MaintenanceTaskRow(task: task) {
                            await viewModel.completeTask(task.id)
                        }
                    }
                } header: {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundStyle(.blue)
                        Text("Upcoming (\(upcomingTasks.count))")
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    // MARK: - Computed Properties

    private var filteredTasks: [MaintenanceTask] {
        switch selectedFilter {
        case .all:
            return viewModel.tasks
        case .overdue:
            return viewModel.tasks.filter { $0.isOverdue }
        case .thisWeek:
            let weekFromNow = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
            return viewModel.tasks.filter { $0.nextDueDate <= weekFromNow && !$0.isOverdue }
        case .thisMonth:
            let monthFromNow = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
            return viewModel.tasks.filter { $0.nextDueDate <= monthFromNow && !$0.isOverdue }
        }
    }

    private var overdueTasks: [MaintenanceTask] {
        filteredTasks.filter { $0.isOverdue }
    }

    private var upcomingTasks: [MaintenanceTask] {
        filteredTasks.filter { !$0.isOverdue }
    }

    private var emptyStateMessage: String {
        switch selectedFilter {
        case .all:
            return "No maintenance tasks scheduled"
        case .overdue:
            return "No overdue tasks"
        case .thisWeek:
            return "No tasks due this week"
        case .thisMonth:
            return "No tasks due this month"
        }
    }
}

// MARK: - Task Filter

enum TaskFilter: String, CaseIterable {
    case all
    case overdue
    case thisWeek = "this_week"
    case thisMonth = "this_month"

    var displayName: String {
        switch self {
        case .all: return "All"
        case .overdue: return "Overdue"
        case .thisWeek: return "This Week"
        case .thisMonth: return "This Month"
        }
    }
}

// MARK: - Task Row

struct MaintenanceTaskRow: View {
    let task: MaintenanceTask
    let onComplete: () async -> Void

    @State private var isCompleting = false

    var body: some View {
        HStack(spacing: 12) {
            // Priority Indicator
            Circle()
                .fill(priorityColor)
                .frame(width: 8, height: 8)

            // Task Info
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.headline)

                HStack(spacing: 8) {
                    Label(dueDateText, systemImage: "calendar")
                        .font(.caption)
                        .foregroundStyle(task.isOverdue ? .red : .secondary)

                    Label(task.frequency.displayName, systemImage: task.frequency.icon)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()

            // Complete Button
            Button {
                Task {
                    isCompleting = true
                    await onComplete()
                    isCompleting = false
                }
            } label: {
                if isCompleting {
                    ProgressView()
                } else {
                    Image(systemName: "checkmark.circle")
                        .font(.title2)
                        .foregroundStyle(.green)
                }
            }
            .buttonStyle(.plain)
            .disabled(isCompleting)
        }
        .padding(.vertical, 4)
    }

    private var dueDateText: String {
        if task.isOverdue {
            let days = abs(task.daysUntilDue)
            return "\(days)d overdue"
        } else if task.daysUntilDue == 0 {
            return "Due today"
        } else if task.daysUntilDue == 1 {
            return "Due tomorrow"
        } else {
            return "Due in \(task.daysUntilDue)d"
        }
    }

    private var priorityColor: Color {
        switch task.priority {
        case .low: return .gray
        case .medium: return .blue
        case .high: return .orange
        case .critical: return .red
        }
    }
}

// MARK: - Preview

#Preview {
    MaintenanceScheduleView()
}
