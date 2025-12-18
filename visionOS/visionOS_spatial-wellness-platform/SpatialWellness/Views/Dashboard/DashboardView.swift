//
//  DashboardView.swift
//  SpatialWellness
//
//  Created by Claude on 2025-11-17.
//  Copyright © 2025 Spatial Wellness Platform. All rights reserved.
//

import SwiftUI
import SwiftData

/// Main dashboard view - primary interface for health overview
/// Displays key health metrics, daily goals, AI insights, and quick actions
struct DashboardView: View {

    // MARK: - Environment

    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openWindow) private var openWindow
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace

    // MARK: - State

    @State private var viewModel = DashboardViewModel()
    @State private var isRefreshing = false

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                // MARK: Header
                headerSection

                // MARK: Health Metrics Cards
                healthMetricsSection

                // MARK: Daily Goals
                dailyGoalsSection

                // MARK: AI Health Insights
                aiInsightsSection

                // MARK: Quick Actions
                quickActionsSection

            }
            .padding(24)
        }
        .navigationTitle("Spatial Wellness")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    openWindow(id: "settings")
                } label: {
                    Image(systemName: "gearshape.fill")
                }
            }

            ToolbarItem(placement: .primaryAction) {
                Button {
                    Task {
                        await refreshData()
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .disabled(isRefreshing)
            }
        }
        .task {
            await loadDashboard()
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(greetingMessage)
                    .font(.title)
                    .fontWeight(.bold)

                if let user = appState.currentUser {
                    Text("Welcome back, \(user.firstName)")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            // Notification badge
            Button {
                // Show notifications
            } label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bell.fill")
                        .font(.title2)

                    if appState.notificationCount > 0 {
                        Circle()
                            .fill(.red)
                            .frame(width: 20, height: 20)
                            .overlay {
                                Text("\(appState.notificationCount)")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                            }
                            .offset(x: 10, y: -10)
                    }
                }
            }
        }
    }

    // MARK: - Health Metrics Section

    private var healthMetricsSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {

            // Heart Rate Card
            HealthMetricCard(
                icon: "heart.fill",
                title: "Heart Rate",
                value: viewModel.heartRateValue,
                unit: "BPM",
                status: viewModel.heartRateStatus,
                color: .red
            ) {
                openWindow(id: "biometrics")
            }

            // Steps Card
            HealthMetricCard(
                icon: "figure.walk",
                title: "Steps",
                value: viewModel.stepsValue,
                unit: "steps",
                status: .normal,
                color: .green
            ) {
                openWindow(id: "biometrics")
            }

            // Stress Level Card
            HealthMetricCard(
                icon: "brain.head.profile",
                title: "Stress",
                value: viewModel.stressValue,
                unit: "level",
                status: viewModel.stressStatus,
                color: .orange
            ) {
                openWindow(id: "biometrics")
            }
        }
    }

    // MARK: - Daily Goals Section

    private var dailyGoalsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Daily Goals Progress")
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()

                Button("View All") {
                    // Navigate to goals view
                }
                .font(.subheadline)
            }

            VStack(spacing: 12) {
                ForEach(viewModel.dailyGoals) { goal in
                    GoalProgressRow(goal: goal)
                }
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - AI Insights Section

    private var aiInsightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("AI Health Insights")
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()

                Button {
                    // Open AI coach
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "brain")
                        Text("Ask Coach")
                    }
                    .font(.subheadline)
                }
            }

            if let insight = viewModel.topInsight {
                InsightCard(insight: insight)
            } else {
                Text("No new insights today")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    // MARK: - Quick Actions Section

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.title2)
                .fontWeight(.semibold)

            HStack(spacing: 16) {
                QuickActionButton(
                    icon: "figure.mind.and.body",
                    title: "Meditate",
                    color: .purple
                ) {
                    Task {
                        await openImmersiveSpace(id: "meditation")
                        appState.enterImmersiveSpace(.meditation)
                    }
                }

                QuickActionButton(
                    icon: "dumbbell.fill",
                    title: "Workout",
                    color: .red
                ) {
                    Task {
                        await openImmersiveSpace(id: "virtualGym")
                        appState.enterImmersiveSpace(.virtualGym)
                    }
                }

                QuickActionButton(
                    icon: "cube.fill",
                    title: "Health Landscape",
                    color: .blue
                ) {
                    openWindow(id: "healthLandscape")
                }
            }
        }
    }

    // MARK: - Helper Properties

    private var greetingMessage: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12:
            return "Good Morning"
        case 12..<17:
            return "Good Afternoon"
        default:
            return "Good Evening"
        }
    }

    // MARK: - Methods

    private func loadDashboard() async {
        isRefreshing = true
        defer { isRefreshing = false }

        // Load data from ViewModel
        await viewModel.loadDashboard(userId: appState.currentUser?.id ?? UUID())
    }

    private func refreshData() async {
        await loadDashboard()
    }
}

// MARK: - Preview

#Preview("Dashboard") {
    DashboardView()
        .environment(AppState())
}
