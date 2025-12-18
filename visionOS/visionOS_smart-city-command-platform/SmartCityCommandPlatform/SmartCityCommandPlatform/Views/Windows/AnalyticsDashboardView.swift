//
//  AnalyticsDashboardView.swift
//  SmartCityCommandPlatform
//
//  City analytics and performance metrics
//

import SwiftUI

struct AnalyticsDashboardView: View {
    @State private var selectedPeriod: TimePeriod = .day

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Period Selector
                    Picker("Period", selection: $selectedPeriod) {
                        Text("24 Hours").tag(TimePeriod.day)
                        Text("7 Days").tag(TimePeriod.week)
                        Text("30 Days").tag(TimePeriod.month)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    // KPI Cards
                    LazyVGrid(columns: [
                        GridItem(.adaptive(minimum: 250))
                    ], spacing: 16) {
                        KPICard(
                            title: "Avg Response Time",
                            value: "4.2 min",
                            change: -32,
                            trend: .down,
                            color: .green
                        )

                        KPICard(
                            title: "Active Incidents",
                            value: "12",
                            change: +5,
                            trend: .up,
                            color: .orange
                        )

                        KPICard(
                            title: "Citizen Satisfaction",
                            value: "87%",
                            change: +12,
                            trend: .up,
                            color: .blue
                        )

                        KPICard(
                            title: "Infrastructure Health",
                            value: "94%",
                            change: +2,
                            trend: .up,
                            color: .green
                        )
                    }
                    .padding(.horizontal)

                    // Predictive Insights
                    PredictiveInsightsSection()
                }
                .padding(.vertical)
            }
            .navigationTitle("City Analytics")
        }
    }
}

// MARK: - KPI Card

struct KPICard: View {
    let title: String
    let value: String
    let change: Int
    let trend: Trend
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(alignment: .firstTextBaseline) {
                Text(value)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(color)

                Spacer()

                TrendIndicator(change: change, trend: trend)
            }
        }
        .padding()
        .background(.regularMaterial, in: .rect(cornerRadius: 12))
    }
}

struct TrendIndicator: View {
    let change: Int
    let trend: Trend

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: trend == .up ? "arrow.up" : "arrow.down")
            Text("\(abs(change))%")
        }
        .font(.caption)
        .foregroundStyle(trend == .up ? .green : .red)
    }
}

enum Trend {
    case up, down
}

// MARK: - Predictive Insights

struct PredictiveInsightsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("PREDICTIVE INSIGHTS")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 8) {
                InsightRow(
                    icon: "car.fill",
                    text: "Peak congestion expected at 5:30 PM downtown",
                    severity: .warning
                )

                InsightRow(
                    icon: "drop.triangle.fill",
                    text: "Infrastructure alert: Water main in Zone 3 needs attention",
                    severity: .critical
                )

                InsightRow(
                    icon: "leaf.fill",
                    text: "Air quality improvement of 15% predicted this week",
                    severity: .info
                )
            }
        }
        .padding()
        .background(.regularMaterial, in: .rect(cornerRadius: 16))
        .padding(.horizontal)
    }
}

struct InsightRow: View {
    let icon: String
    let text: String
    let severity: InsightSeverity

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(colorForSeverity(severity))

            Text(text)
                .font(.subheadline)

            Spacer()
        }
        .padding(.vertical, 8)
    }

    private func colorForSeverity(_ severity: InsightSeverity) -> Color {
        switch severity {
        case .info: return .blue
        case .warning: return .orange
        case .critical: return .red
        }
    }
}

enum InsightSeverity {
    case info, warning, critical
}

enum TimePeriod {
    case day, week, month
}

#Preview {
    AnalyticsDashboardView()
}
