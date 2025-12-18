//
//  AnalyticsView.swift
//  CultureArchitectureSystem
//
//  Created on 2025-01-20
//

import SwiftUI
import Charts

struct AnalyticsView: View {
    @Environment(AppModel.self) private var appModel
    @State private var viewModel = AnalyticsViewModel()
    @State private var selectedTimeRange: TimeRange = .thirtyDays

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Time range picker
                    Picker("Time Range", selection: $selectedTimeRange) {
                        ForEach(TimeRange.allCases, id: \.self) { range in
                            Text(range.displayName).tag(range)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    // Engagement Trend Chart
                    EngagementTrendCard(dataPoints: viewModel.engagementData)

                    // Value Breakdown
                    ValueBreakdownCard(values: viewModel.valueBreakdown)

                    // Team Comparison
                    TeamComparisonCard(teams: viewModel.teamComparisons)
                }
                .padding()
            }
            .navigationTitle("Cultural Analytics")
            .task {
                await viewModel.loadAnalytics(service: appModel.analyticsService, range: selectedTimeRange)
            }
            .onChange(of: selectedTimeRange) { _, newRange in
                Task {
                    await viewModel.loadAnalytics(service: appModel.analyticsService, range: newRange)
                }
            }
        }
    }
}

// MARK: - Supporting Views
struct EngagementTrendCard: View {
    let dataPoints: [EngagementDataPoint]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Engagement Trend")
                .font(.headline)

            Chart(dataPoints) { point in
                LineMark(
                    x: .value("Date", point.date),
                    y: .value("Score", point.score)
                )
                .interpolationMethod(.catmullRom)
            }
            .frame(height: 200)
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(16)
    }
}

struct ValueBreakdownCard: View {
    let values: [ValueAlignment]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Value Alignment")
                .font(.headline)

            ForEach(values) { value in
                HStack {
                    Text(value.name)
                        .frame(width: 120, alignment: .leading)

                    ProgressView(value: value.score / 100)
                        .tint(value.color)

                    Text("\(Int(value.score))%")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 40, alignment: .trailing)
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(16)
    }
}

struct TeamComparisonCard: View {
    let teams: [TeamHealthData]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Team Health Comparison")
                .font(.headline)

            Chart(teams) { team in
                BarMark(
                    x: .value("Score", team.healthScore),
                    y: .value("Team", team.name)
                )
                .foregroundStyle(by: .value("Team", team.name))
            }
            .frame(height: 300)
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(16)
    }
}

// MARK: - Supporting Types
enum TimeRange: String, CaseIterable {
    case sevenDays = "7d"
    case thirtyDays = "30d"
    case ninetyDays = "90d"

    var displayName: String {
        switch self {
        case .sevenDays: "7 Days"
        case .thirtyDays: "30 Days"
        case .ninetyDays: "90 Days"
        }
    }

    var days: Int {
        switch self {
        case .sevenDays: 7
        case .thirtyDays: 30
        case .ninetyDays: 90
        }
    }
}

struct EngagementDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let score: Double
}

struct ValueAlignment: Identifiable {
    let id = UUID()
    let name: String
    let score: Double
    let color: Color
}

struct TeamHealthData: Identifiable {
    let id = UUID()
    let name: String
    let healthScore: Double
}

#Preview {
    AnalyticsView()
        .environment(AppModel())
}
