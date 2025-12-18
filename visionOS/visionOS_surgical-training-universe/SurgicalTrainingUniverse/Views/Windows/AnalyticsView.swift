//
//  AnalyticsView.swift
//  Surgical Training Universe
//
//  Performance analytics and progress tracking
//

import SwiftUI
import SwiftData
import Charts

/// Analytics dashboard for performance tracking
struct AnalyticsView: View {

    @Environment(AppState.self) private var appState
    @Query(sort: \ProcedureSession.startTime) private var sessions: [ProcedureSession]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Skill Progression Chart
                    skillProgressionSection

                    // Performance Metrics
                    performanceMetricsSection

                    // Procedure Breakdown
                    procedureBreakdownSection

                    // Recent Insights
                    recentInsightsSection
                }
                .padding(40)
            }
            .navigationTitle("Performance Analytics")
            .background(.regularMaterial)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        exportAnalytics()
                    } label: {
                        Label("Export", systemImage: "square.and.arrow.up")
                    }
                }
            }
        }
    }

    // MARK: - Skill Progression

    private var skillProgressionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Skill Progression (Last 30 Days)")
                .font(.title2)
                .fontWeight(.semibold)

            if sessions.isEmpty {
                emptyChartView
            } else {
                Chart(Array(sessions.suffix(20))) { session in
                    LineMark(
                        x: .value("Date", session.startTime),
                        y: .value("Score", session.overallScore)
                    )
                    .foregroundStyle(.blue)
                    .interpolationMethod(.catmullRom)

                    PointMark(
                        x: .value("Date", session.startTime),
                        y: .value("Score", session.overallScore)
                    )
                    .foregroundStyle(.blue)
                }
                .frame(height: 200)
                .chartYScale(domain: 0...100)
            }
        }
        .padding(24)
        .background(.thinMaterial)
        .cornerRadius(16)
    }

    // MARK: - Performance Metrics

    private var performanceMetricsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Performance Breakdown")
                .font(.title2)
                .fontWeight(.semibold)

            HStack(spacing: 20) {
                MetricCard(
                    title: "Accuracy",
                    value: averageAccuracy,
                    trend: +5.2,
                    color: .blue
                )

                MetricCard(
                    title: "Efficiency",
                    value: averageEfficiency,
                    trend: +3.1,
                    color: .green
                )

                MetricCard(
                    title: "Safety",
                    value: averageSafety,
                    trend: -1.5,
                    color: .orange
                )

                MetricCard(
                    title: "Complications",
                    value: Double(totalComplications),
                    trend: -8.3,
                    color: .red,
                    isInverted: true
                )
            }
        }
    }

    // MARK: - Procedure Breakdown

    private var procedureBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Procedure Distribution")
                .font(.title2)
                .fontWeight(.semibold)

            VStack(spacing: 12) {
                ForEach(procedureCounts.sorted(by: { $0.value > $1.value }).prefix(5), id: \.key) { procedure, count in
                    HStack {
                        Text(procedure.rawValue)
                            .font(.headline)

                        Spacer()

                        Text("\(count) sessions")
                            .foregroundStyle(.secondary)

                        // Progress bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.gray.opacity(0.2))

                                RoundedRectangle(cornerRadius: 4)
                                    .fill(.blue)
                                    .frame(width: geometry.size.width * (Double(count) / Double(maxProcedureCount)))
                            }
                        }
                        .frame(width: 200, height: 8)
                    }
                    .padding()
                    .background(.thinMaterial)
                    .cornerRadius(12)
                }
            }
        }
    }

    // MARK: - Recent Insights

    private var recentInsightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("AI Insights")
                .font(.title2)
                .fontWeight(.semibold)

            VStack(spacing: 12) {
                if allInsights.isEmpty {
                    Text("No insights yet. Complete procedures to receive AI feedback.")
                        .foregroundStyle(.secondary)
                        .padding()
                } else {
                    ForEach(Array(allInsights.prefix(5))) { insight in
                        InsightRow(insight: insight)
                    }
                }
            }
        }
    }

    private var emptyChartView: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("No data yet")
                .font(.headline)

            Text("Complete procedures to see your progress")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .frame(height: 200)
    }

    // MARK: - Computed Properties

    private var averageAccuracy: Double {
        guard !sessions.isEmpty else { return 0 }
        return sessions.map(\.accuracyScore).reduce(0, +) / Double(sessions.count)
    }

    private var averageEfficiency: Double {
        guard !sessions.isEmpty else { return 0 }
        return sessions.map(\.efficiencyScore).reduce(0, +) / Double(sessions.count)
    }

    private var averageSafety: Double {
        guard !sessions.isEmpty else { return 0 }
        return sessions.map(\.safetyScore).reduce(0, +) / Double(sessions.count)
    }

    private var totalComplications: Int {
        sessions.flatMap(\.complications).count
    }

    private var procedureCounts: [ProcedureType: Int] {
        Dictionary(grouping: sessions, by: \.procedureType)
            .mapValues { $0.count }
    }

    private var maxProcedureCount: Int {
        procedureCounts.values.max() ?? 1
    }

    private var allInsights: [AIInsight] {
        sessions.flatMap(\.insights).sorted(by: { $0.timestamp > $1.timestamp })
    }

    // MARK: - Methods

    private func exportAnalytics() {
        // Export analytics data to PDF/CSV
        print("Exporting analytics...")
    }
}

// MARK: - Supporting Views

struct MetricCard: View {
    let title: String
    let value: Double
    let trend: Double
    let color: Color
    var isInverted: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)

            Text(formattedValue)
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(color)

            HStack(spacing: 4) {
                Image(systemName: trendIcon)
                    .foregroundStyle(trendColor)

                Text(formattedTrend)
                    .font(.caption)
                    .foregroundStyle(trendColor)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(.thinMaterial)
        .cornerRadius(16)
    }

    private var formattedValue: String {
        if title == "Complications" {
            return "\(Int(value))"
        } else {
            return "\(Int(value))%"
        }
    }

    private var formattedTrend: String {
        let absValue = abs(trend)
        return String(format: "%.1f%%", absValue)
    }

    private var trendIcon: String {
        let isPositive = isInverted ? (trend < 0) : (trend > 0)
        return isPositive ? "arrow.up.right" : "arrow.down.right"
    }

    private var trendColor: Color {
        let isPositive = isInverted ? (trend < 0) : (trend > 0)
        return isPositive ? .green : .red
    }
}

struct InsightRow: View {
    let insight: AIInsight

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: iconName)
                .font(.title3)
                .foregroundStyle(severityColor)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(insight.category.rawValue)
                        .font(.headline)

                    Spacer()

                    Text(formattedTime)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text(insight.message)
                    .font(.callout)
                    .foregroundStyle(.secondary)

                if let action = insight.suggestedAction {
                    Text("Suggestion: \(action)")
                        .font(.caption)
                        .foregroundStyle(.blue)
                }
            }
        }
        .padding()
        .background(.thinMaterial)
        .cornerRadius(12)
    }

    private var iconName: String {
        switch insight.category {
        case .technique: return "hand.raised.fill"
        case .safety: return "exclamationmark.shield.fill"
        case .efficiency: return "gauge.high"
        case .accuracy: return "target"
        case .suggestion: return "lightbulb.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .achievement: return "star.fill"
        }
    }

    private var severityColor: Color {
        switch insight.severity {
        case .info: return .blue
        case .low: return .green
        case .medium: return .yellow
        case .high: return .orange
        case .critical: return .red
        }
    }

    private var formattedTime: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: insight.timestamp, relativeTo: Date())
    }
}

#Preview {
    AnalyticsView()
        .environment(AppState())
}
