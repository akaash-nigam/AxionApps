//
//  DashboardView.swift
//  SpatialCRM
//
//  Main dashboard view
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    // MARK: - Properties

    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    @State private var viewModel: DashboardViewModel?

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                headerSection

                // Metrics Grid
                metricsGrid

                // Hot Opportunities
                hotOpportunitiesSection

                // Today's Tasks
                todaysTasksSection

                // Quick Actions
                quickActionsSection
            }
            .padding()
        }
        .navigationTitle("Dashboard")
        .onAppear {
            if viewModel == nil {
                viewModel = DashboardViewModel(modelContext: modelContext)
                Task {
                    await viewModel?.loadData()
                }
            }
        }
    }

    // MARK: - View Components

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Welcome back!")
                .font(.title)
                .fontWeight(.bold)

            Text("Here's your sales overview")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var metricsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            MetricCard(
                title: "My Pipeline",
                value: "$2.4M",
                subtitle: "5 deals closing soon",
                icon: "chart.line.uptrend.xyaxis",
                color: .blue
            )

            MetricCard(
                title: "Win Rate",
                value: "72%",
                subtitle: "+5% vs last month",
                icon: "trophy.fill",
                color: .green
            )

            MetricCard(
                title: "Avg Deal Size",
                value: "$180K",
                subtitle: "+12% vs last quarter",
                icon: "dollarsign.circle.fill",
                color: .orange
            )

            MetricCard(
                title: "Forecast",
                value: "$1.8M",
                subtitle: "This quarter",
                icon: "chart.bar.fill",
                color: .purple
            )
        }
    }

    private var hotOpportunitiesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Hot Opportunities")
                    .font(.headline)
                Spacer()
                Button("View All") {
                    // Navigate to pipeline
                }
                .buttonStyle(.bordered)
            }

            if let viewModel = viewModel {
                ForEach(viewModel.hotOpportunities) { opportunity in
                    OpportunityRow(opportunity: opportunity)
                }
            } else {
                ProgressView()
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }

    private var todaysTasksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Today's Tasks")
                    .font(.headline)
                Spacer()
                Text("\(viewModel?.todaysTasks.count ?? 0) tasks")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let viewModel = viewModel {
                ForEach(viewModel.todaysTasks) { activity in
                    TaskRow(activity: activity)
                }
            } else {
                ProgressView()
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }

    private var quickActionsSection: some View {
        VStack(spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                QuickActionButton(
                    title: "New Opportunity",
                    icon: "plus.circle.fill",
                    color: .blue
                ) {
                    // Create opportunity
                }

                QuickActionButton(
                    title: "Log Call",
                    icon: "phone.fill",
                    color: .green
                ) {
                    // Log call
                }

                QuickActionButton(
                    title: "View Galaxy",
                    icon: "globe",
                    color: .purple
                ) {
                    // Open immersive space
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct MetricCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Spacer()
            }

            Text(value)
                .font(.title)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(subtitle)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial)
        .cornerRadius(12)
    }
}

struct OpportunityRow: View {
    let opportunity: Opportunity

    var body: some View {
        HStack {
            Circle()
                .fill(stageColor)
                .frame(width: 12, height: 12)

            VStack(alignment: .leading) {
                Text(opportunity.name)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(opportunity.account?.name ?? "Unknown")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing) {
                Text(opportunity.amount.formatted(.currency(code: "USD")))
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(opportunity.stage.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 8)
    }

    private var stageColor: Color {
        switch opportunity.stage {
        case .prospecting: .gray
        case .qualification: .blue
        case .needsAnalysis: .cyan
        case .proposal: .orange
        case .negotiation: .yellow
        case .closedWon: .green
        case .closedLost: .red
        }
    }
}

struct TaskRow: View {
    let activity: Activity

    var body: some View {
        HStack {
            Image(systemName: activity.type.icon)
                .foregroundStyle(.blue)

            VStack(alignment: .leading) {
                Text(activity.subject)
                    .font(.subheadline)

                if let scheduled = activity.scheduledAt {
                    Text(scheduled.formatted(date: .omitted, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button {
                // Complete task
            } label: {
                Image(systemName: activity.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(activity.isCompleted ? .green : .secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundStyle(color)

                Text(title)
                    .font(.caption)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.regularMaterial)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - View Model

@Observable
final class DashboardViewModel {
    var hotOpportunities: [Opportunity] = []
    var todaysTasks: [Activity] = []
    var isLoading: Bool = false

    private let modelContext: ModelContext
    private var crmService: CRMService

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.crmService = CRMService(modelContext: modelContext)
    }

    func loadData() async {
        isLoading = true
        defer { isLoading = false }

        do {
            // Load hot opportunities
            let opportunities = try await crmService.fetchOpportunities(filter: .active)
            hotOpportunities = opportunities
                .sorted { $0.aiScore > $1.aiScore }
                .prefix(5)
                .map { $0 }

            // Load today's tasks
            let activities = try await crmService.fetchActivities(filter: .today)
            todaysTasks = activities
        } catch {
            print("Error loading dashboard data: \(error)")
        }
    }
}

// MARK: - Preview

#Preview {
    DashboardView()
        .environment(AppState())
}
