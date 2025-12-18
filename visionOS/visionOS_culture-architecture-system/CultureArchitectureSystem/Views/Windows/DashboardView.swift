//
//  DashboardView.swift
//  CultureArchitectureSystem
//
//  Created on 2025-01-20
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openWindow) private var openWindow
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace

    @Query private var organizations: [Organization]
    @State private var viewModel = DashboardViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Health Score Section
                    HealthScoreCard(score: viewModel.healthScore)

                    // Quick Stats
                    HStack(spacing: 16) {
                        StatCard(
                            title: "Engagement",
                            value: "\(Int(viewModel.engagementScore))%",
                            trend: .up
                        )

                        StatCard(
                            title: "Values Aligned",
                            value: "\(viewModel.valuesAligned)",
                            trend: .stable
                        )

                        StatCard(
                            title: "Recognitions",
                            value: "\(viewModel.recognitionCount)",
                            trend: .up
                        )
                    }

                    // Recent Activity
                    ActivityFeedSection(activities: viewModel.recentActivities)

                    // Quick Actions
                    QuickActionsSection(
                        onGiveRecognition: {
                            openWindow(id: "recognition")
                        },
                        onOpenCampus: {
                            Task {
                                await openImmersiveSpace(id: "culture-campus")
                            }
                        }
                    )
                }
                .padding()
            }
            .navigationTitle("Culture Dashboard")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        // Open settings
                    }) {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .task {
                await viewModel.loadDashboardData(
                    cultureService: appModel.cultureService,
                    analyticsService: appModel.analyticsService
                )
            }
            .refreshable {
                await viewModel.loadDashboardData(
                    cultureService: appModel.cultureService,
                    analyticsService: appModel.analyticsService
                )
            }
        }
    }
}

// MARK: - Health Score Card
struct HealthScoreCard: View {
    let score: Double

    var body: some View {
        VStack(spacing: 16) {
            Text("Cultural Health")
                .font(.headline)

            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                    .frame(width: 200, height: 200)

                Circle()
                    .trim(from: 0, to: score / 100)
                    .stroke(healthColor, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(duration: 1.0), value: score)

                VStack {
                    Text("\(Int(score))%")
                        .font(.system(size: 48, weight: .bold))
                        .contentTransition(.numericText())

                    Text(healthStatus)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(32)
        .background(.regularMaterial)
        .cornerRadius(16)
        .shadow(radius: 5)
    }

    var healthColor: Color {
        if score > 80 { .green }
        else if score > 60 { .yellow }
        else { .red }
    }

    var healthStatus: String {
        if score > 80 { "Thriving" }
        else if score > 60 { "Healthy" }
        else { "Needs Attention" }
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let trend: Trend

    enum Trend {
        case up, down, stable

        var icon: String {
            switch self {
            case .up: "arrow.up.right"
            case .down: "arrow.down.right"
            case .stable: "arrow.right"
            }
        }

        var color: Color {
            switch self {
            case .up: .green
            case .down: .red
            case .stable: .gray
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack {
                Text(value)
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()

                Image(systemName: trend.icon)
                    .foregroundStyle(trend.color)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.regularMaterial)
        .cornerRadius(12)
    }
}

// MARK: - Activity Feed Section
struct ActivityFeedSection: View {
    let activities: [Activity]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Activity")
                .font(.headline)

            if activities.isEmpty {
                EmptyStateView(
                    icon: "bell.slash",
                    message: "No recent activity",
                    description: "Activities will appear here as your team engages with culture"
                )
            } else {
                ForEach(activities) { activity in
                    ActivityRow(activity: activity)
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(16)
    }
}

struct ActivityRow: View {
    let activity: Activity

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: activity.type.icon)
                .foregroundStyle(activity.type.color)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(activity.description)
                    .font(.subheadline)

                Text(activity.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Quick Actions Section
struct QuickActionsSection: View {
    let onGiveRecognition: () -> Void
    let onOpenCampus: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)

            HStack(spacing: 12) {
                ActionButton(
                    title: "Give Recognition",
                    icon: "star.fill",
                    color: .yellow,
                    action: onGiveRecognition
                )

                ActionButton(
                    title: "Explore Campus",
                    icon: "mountain.2.fill",
                    color: .blue,
                    action: onOpenCampus
                )
            }
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(16)
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundStyle(color)

                Text(title)
                    .font(.caption)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(color.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
        .hoverEffect()
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let icon: String
    let message: String
    let description: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text(message)
                .font(.headline)

            Text(description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Supporting Types
struct Activity: Identifiable {
    let id = UUID()
    let type: ActivityType
    let description: String
    let timestamp: Date

    enum ActivityType {
        case recognition, behavior, ritual, milestone

        var icon: String {
            switch self {
            case .recognition: "star.fill"
            case .behavior: "bolt.fill"
            case .ritual: "repeat.circle.fill"
            case .milestone: "flag.fill"
            }
        }

        var color: Color {
            switch self {
            case .recognition: .yellow
            case .behavior: .blue
            case .ritual: .purple
            case .milestone: .green
            }
        }
    }
}

// MARK: - Preview
#Preview {
    DashboardView()
        .environment(AppModel())
        .modelContainer(for: [Organization.self, CulturalValue.self])
}
