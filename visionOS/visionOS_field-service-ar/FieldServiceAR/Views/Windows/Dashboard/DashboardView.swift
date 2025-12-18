//
//  DashboardView.swift
//  FieldServiceAR
//
//  Main dashboard window
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.appState) private var appState
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openWindow) private var openWindow

    @State private var viewModel: DashboardViewModel?
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                headerView

                // Filter Tabs
                filterTabsView

                // Jobs List
                if let vm = viewModel {
                    if vm.isLoading {
                        ProgressView("Loading jobs...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if vm.filteredJobs.isEmpty {
                        emptyStateView
                    } else {
                        jobsListView(jobs: vm.filteredJobs)
                    }
                } else {
                    ProgressView()
                }
            }
            .background(.ultraThinMaterial)
        }
        .task {
            if viewModel == nil {
                let container = DependencyContainer()
                let repository = JobRepository(modelContainer: container.modelContainer)
                viewModel = DashboardViewModel(jobRepository: repository, appState: appState)
                await viewModel?.loadJobs()
            }
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Field Service AR")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Today: \(Date.now, style: .date)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // User menu
            Menu {
                Button("Settings", systemImage: "gearshape") {
                    // Open settings
                }
                Button("Sign Out", systemImage: "arrow.right.square") {
                    // Sign out
                }
            } label: {
                Label(appState.currentUser?.fullName ?? "User", systemImage: "person.circle.fill")
            }
        }
        .padding()
        .background(.regularMaterial)
    }

    // MARK: - Filter Tabs

    private var filterTabsView: some View {
        HStack {
            ForEach(JobFilter.allCases, id: \.self) { filter in
                Button {
                    viewModel?.selectFilter(filter)
                } label: {
                    Text(filter.rawValue)
                        .font(.subheadline)
                        .fontWeight(viewModel?.selectedFilter == filter ? .semibold : .regular)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            viewModel?.selectedFilter == filter ?
                            Color.accentColor.opacity(0.2) : Color.clear
                        )
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }

            Spacer()

            // Search field
            TextField("Search jobs...", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .frame(width: 200)
                .onChange(of: searchText) { _, newValue in
                    viewModel?.searchQuery = newValue
                }
        }
        .padding()
    }

    // MARK: - Jobs List

    private func jobsListView(jobs: [ServiceJob]) -> some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(jobs) { job in
                    JobCard(job: job) {
                        openWindow(id: "job-details", value: job.id)
                    }
                }
            }
            .padding()
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.green)

            Text("All Caught Up!")
                .font(.title2)
                .fontWeight(.bold)

            Text("No jobs scheduled for today.")
                .font(.body)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Button("Browse Equipment") {
                    openWindow(id: "equipment-library")
                }
                .buttonStyle(.bordered)

                Button("View All Jobs") {
                    viewModel?.selectFilter(.all)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Job Card Component

struct JobCard: View {
    let job: ServiceJob
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: equipmentIcon)
                    .foregroundStyle(statusColor)

                VStack(alignment: .leading, spacing: 4) {
                    Text("\(job.workOrderNumber) • \(job.title)")
                        .font(.headline)

                    Text(job.customerName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                StatusBadge(status: job.status)
            }

            // Details
            HStack(spacing: 20) {
                Label(locationText, systemImage: "location.fill")
                Label(timeText, systemImage: "clock.fill")
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            // Equipment
            Text("Equipment: \(job.equipmentManufacturer) \(job.equipmentModel)")
                .font(.caption)
                .foregroundStyle(.secondary)

            Divider()

            // Actions
            HStack {
                Button("View Details") {
                    action()
                }
                .buttonStyle(.bordered)

                Spacer()

                Button {
                    // Start job
                } label: {
                    Label("Start Job", systemImage: "play.fill")
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .hoverEffect()
    }

    private var equipmentIcon: String {
        // Map equipment category to icon
        "wrench.and.screwdriver.fill"
    }

    private var statusColor: Color {
        switch job.status {
        case .scheduled: return .gray
        case .inProgress: return .blue
        case .onHold: return .yellow
        case .completed: return .green
        case .cancelled: return .red
        }
    }

    private var locationText: String {
        if let distance = calculateDistance() {
            return "\(distance) mi away"
        }
        return job.siteName
    }

    private var timeText: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let start = formatter.string(from: job.scheduledDate)
        let end = formatter.string(from: job.scheduledDate.addingTimeInterval(job.estimatedDuration))
        return "\(start) - \(end)"
    }

    private func calculateDistance() -> String? {
        // TODO: Calculate actual distance from current location
        return "2.3"
    }
}

// MARK: - Status Badge

struct StatusBadge: View {
    let status: JobStatus

    var body: some View {
        Text(status.rawValue)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor.opacity(0.2))
            .foregroundStyle(backgroundColor)
            .clipShape(Capsule())
    }

    private var backgroundColor: Color {
        switch status {
        case .scheduled: return .gray
        case .inProgress: return .blue
        case .onHold: return .yellow
        case .completed: return .green
        case .cancelled: return .red
        }
    }
}

#Preview {
    DashboardView()
        .frame(width: 800, height: 600)
}
