//
//  AnalyticsView.swift
//  SmartAgriculture
//
//  Created by Claude Code
//  Copyright © 2025 Smart Agriculture. All rights reserved.
//

import SwiftUI

struct AnalyticsView: View {
    @Environment(FarmManager.self) private var farmManager

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Analytics")
                    .font(.largeTitle.bold())

                if let farm = farmManager.activeFarm {
                    FarmAnalyticsContent(farm: farm)
                } else {
                    EmptyStateView(
                        icon: "chart.xyaxis.line",
                        title: "No Farm Selected",
                        message: "Select a farm to view analytics"
                    )
                }
            }
            .padding()
        }
    }
}

struct FarmAnalyticsContent: View {
    let farm: Farm

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Summary Stats
            SummaryStatsCard(farm: farm)

            // Placeholder for charts
            PlaceholderCard(
                title: "Yield Trends",
                description: "Historical yield data and predictions"
            )

            PlaceholderCard(
                title: "Health Overview",
                description: "Field health metrics over time"
            )

            PlaceholderCard(
                title: "Resource Usage",
                description: "Water, fertilizer, and other inputs"
            )
        }
    }
}

struct SummaryStatsCard: View {
    let farm: Farm

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Summary Statistics")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                StatItem(label: "Total Acres", value: "\(Int(farm.totalAcres))")
                StatItem(label: "Fields", value: "\(farm.totalFields)")
                StatItem(label: "Avg Health", value: "\(Int(farm.averageHealth))%")
                StatItem(label: "Status", value: farm.healthStatus.rawValue)
            }
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(12)
    }
}

struct StatItem: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.title2.bold())
        }
    }
}

struct PlaceholderCard: View {
    let title: String
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)

            Text(description)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()
                .frame(height: 150)
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(12)
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 64))
                .foregroundStyle(.secondary)

            VStack(spacing: 8) {
                Text(title)
                    .font(.title2.bold())

                Text(message)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

#Preview {
    AnalyticsView()
        .environment(FarmManager())
}
