//
//  AnalyticsDashboardView.swift
//  Molecular Design Platform
//
//  Analytics and project insights dashboard
//

import SwiftUI
import Charts

struct AnalyticsDashboardView: View {
    @Environment(\.appState) private var appState

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Project Analytics")
                    .font(.largeTitle)
                    .bold()

                // Pipeline Overview
                GroupBox("Pipeline Overview") {
                    VStack(alignment: .leading, spacing: 12) {
                        StatRow(label: "Total Molecules", value: "127")
                        StatRow(label: "Active Simulations", value: "3")
                        StatRow(label: "Completed Experiments", value: "45")

                        ProgressView(value: 0.45)
                            .padding(.vertical, 8)

                        Text("Lead Optimization: 45%")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                }

                // Property Distribution Chart
                GroupBox("Property Distribution") {
                    Chart {
                        ForEach(sampleData, id: \.logP) { data in
                            PointMark(
                                x: .value("LogP", data.logP),
                                y: .value("MW", data.mw)
                            )
                            .foregroundStyle(.blue)
                        }
                    }
                    .frame(height: 200)
                    .padding()
                }

                // Success Rate Trends
                GroupBox("Success Rate Trends") {
                    Chart {
                        ForEach(trends, id: \.month) { trend in
                            LineMark(
                                x: .value("Month", trend.month),
                                y: .value("Success Rate", trend.rate)
                            )
                            .foregroundStyle(.green)
                        }
                    }
                    .frame(height: 200)
                    .padding()
                }
            }
            .padding()
        }
    }

    // Sample data
    private let sampleData = [
        (logP: -0.5, mw: 180.0),
        (logP: 1.2, mw: 250.0),
        (logP: 2.3, mw: 320.0),
        (logP: 0.8, mw: 220.0),
        (logP: 3.1, mw: 450.0)
    ]

    private let trends = [
        (month: "Jan", rate: 30.0),
        (month: "Feb", rate: 42.0),
        (month: "Mar", rate: 55.0),
        (month: "Apr", rate: 68.0),
        (month: "May", rate: 75.0),
        (month: "Jun", rate: 82.0)
    ]
}

struct StatRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(.headline)
                .monospacedDigit()
        }
    }
}

#Preview {
    AnalyticsDashboardView()
}
