//
//  AnalyticsView.swift
//  SpatialCRM
//
//  Analytics and reporting view
//

import SwiftUI

struct AnalyticsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Analytics")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                // Placeholder for charts and analytics
                VStack(spacing: 16) {
                    AnalyticsCard(
                        title: "Revenue Trend",
                        value: "$1.8M",
                        change: "+15%",
                        icon: "chart.line.uptrend.xyaxis"
                    )

                    AnalyticsCard(
                        title: "Win Rate",
                        value: "72%",
                        change: "+5%",
                        icon: "trophy.fill"
                    )

                    AnalyticsCard(
                        title: "Average Sales Cycle",
                        value: "45 days",
                        change: "-8 days",
                        icon: "clock.fill"
                    )
                }
                .padding()
            }
        }
        .navigationTitle("Analytics")
    }
}

struct AnalyticsCard: View {
    let title: String
    let value: String
    let change: String
    let icon: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(value)
                    .font(.title)
                    .fontWeight(.bold)

                Text(change)
                    .font(.caption)
                    .foregroundStyle(.green)
            }

            Spacer()

            Image(systemName: icon)
                .font(.largeTitle)
                .foregroundStyle(.blue)
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(12)
    }
}

#Preview {
    AnalyticsView()
}
