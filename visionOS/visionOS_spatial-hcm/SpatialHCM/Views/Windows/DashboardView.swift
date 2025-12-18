import SwiftUI

struct DashboardView: View {
    @Environment(AppState.self) private var appState
    @State private var showEmployeeList = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                DashboardHeaderView()

                // Quick Stats
                QuickStatsView()

                // Recent Activity
                RecentActivityView()

                // Quick Actions
                QuickActionsView()
            }
            .padding()
        }
        .navigationTitle("Dashboard")
        .task {
            await loadDashboardData()
        }
    }

    private func loadDashboardData() async {
        await appState.organizationState.loadOrganization(using: appState.hrService)
        await appState.analyticsState.loadMetrics(using: appState.analyticsService)
    }
}

// MARK: - Dashboard Header
struct DashboardHeaderView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                if let user = appState.currentUser {
                    Text("Welcome, \(user.firstName)")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text(user.role.rawValue.capitalized)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Welcome to Spatial HCM")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
            }

            Spacer()

            // User avatar
            Circle()
                .fill(.blue.gradient)
                .frame(width: 60, height: 60)
                .overlay {
                    if let user = appState.currentUser {
                        Text(user.firstName.prefix(1))
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                    }
                }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Quick Stats
struct QuickStatsView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        let orgState = appState.organizationState
        let analyticsState = appState.analyticsState

        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            StatCard(
                title: "Total Employees",
                value: "\(orgState.employeeCount)",
                icon: "person.3.fill",
                color: .blue
            )

            StatCard(
                title: "Avg Engagement",
                value: "\(Int(analyticsState.avgEngagement))%",
                icon: "heart.fill",
                color: .green
            )

            StatCard(
                title: "Flight Risks",
                value: "\(orgState.flightRisks.count)",
                icon: "exclamationmark.triangle.fill",
                color: .red
            )

            StatCard(
                title: "High Potential",
                value: "\(orgState.highPotential.count)",
                icon: "star.fill",
                color: .yellow
            )

            StatCard(
                title: "Turnover Rate",
                value: String(format: "%.1f%%", analyticsState.turnoverRate),
                icon: "arrow.triangle.2.circlepath",
                color: .orange
            )

            StatCard(
                title: "eNPS",
                value: "+\(analyticsState.eNPS)",
                icon: "chart.line.uptrend.xyaxis",
                color: .purple
            )
        }
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String
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
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 120)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Recent Activity
struct RecentActivityView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Activity")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                ActivityRow(
                    icon: "person.badge.plus",
                    title: "New Employee Joined",
                    subtitle: "Sarah Chen joined Engineering",
                    time: "2 hours ago",
                    color: .blue
                )

                ActivityRow(
                    icon: "checkmark.circle.fill",
                    title: "Goal Completed",
                    subtitle: "John Doe completed Q2 objectives",
                    time: "5 hours ago",
                    color: .green
                )

                ActivityRow(
                    icon: "star.fill",
                    title: "Performance Review",
                    subtitle: "Q2 reviews are now open",
                    time: "1 day ago",
                    color: .yellow
                )
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Activity Row
struct ActivityRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let time: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(time)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Quick Actions
struct QuickActionsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ActionButton(
                    title: "View Org Chart",
                    icon: "chart.tree",
                    color: .blue
                ) {
                    print("Open Org Chart")
                }

                ActionButton(
                    title: "Team Health",
                    icon: "heart.fill",
                    color: .green
                ) {
                    print("Open Team Health")
                }

                ActionButton(
                    title: "Reports",
                    icon: "doc.text.fill",
                    color: .orange
                ) {
                    print("Open Reports")
                }

                ActionButton(
                    title: "Add Employee",
                    icon: "person.badge.plus",
                    color: .purple
                ) {
                    print("Add Employee")
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Action Button
struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)

                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    DashboardView()
        .environment(AppState())
}
