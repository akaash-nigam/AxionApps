import SwiftUI
import Charts
import SwiftData

struct AnalyticsView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext

    @Query private var sessions: [TrainingSession]

    @State private var selectedPeriod: TimePeriod = .lastThirtyDays

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    // Performance Overview Cards
                    performanceOverviewSection

                    // Score Trend Chart
                    scoreTrendSection

                    // Strengths & Improvement Areas
                    strengthsSection

                    // Certifications
                    certificationsSection
                }
                .padding(40)
            }
            .navigationTitle("Safety Performance Analytics")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Export", systemImage: "square.and.arrow.up") {
                        exportReport()
                    }
                }
            }
        }
    }

    // MARK: - Performance Overview

    private var performanceOverviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Performance Overview")
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()

                Picker("Period", selection: $selectedPeriod) {
                    ForEach(TimePeriod.allCases, id: \.self) { period in
                        Text(period.rawValue).tag(period)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 300)
            }

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                MetricCard(
                    title: "Scenarios Completed",
                    value: "18",
                    icon: "checkmark.circle.fill",
                    color: .green
                )

                MetricCard(
                    title: "Average Score",
                    value: "94%",
                    icon: "chart.line.uptrend.xyaxis",
                    color: .blue
                )

                MetricCard(
                    title: "Hazard Detection",
                    value: "87%",
                    icon: "exclamationmark.triangle.fill",
                    color: .orange
                )

                MetricCard(
                    title: "Training Hours",
                    value: "12.5",
                    icon: "clock.fill",
                    color: .purple
                )
            }
        }
    }

    // MARK: - Score Trend

    private var scoreTrendSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Score Trend")
                .font(.title2)
                .fontWeight(.semibold)

            Chart {
                ForEach(sampleScoreData) { data in
                    LineMark(
                        x: .value("Week", data.week),
                        y: .value("Score", data.score)
                    )
                    .foregroundStyle(.blue.gradient)
                    .interpolationMethod(.catmullRom)

                    AreaMark(
                        x: .value("Week", data.week),
                        y: .value("Score", data.score)
                    )
                    .foregroundStyle(.blue.opacity(0.1).gradient)
                    .interpolationMethod(.catmullRom)
                }
            }
            .frame(height: 250)
            .chartYScale(domain: 0...100)
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisValueLabel {
                        if let score = value.as(Double.self) {
                            Text("\(Int(score))%")
                        }
                    }
                    AxisGridLine()
                }
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
    }

    // MARK: - Strengths Section

    private var strengthsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Strengths & Improvement Areas")
                .font(.title2)
                .fontWeight(.semibold)

            VStack(alignment: .leading, spacing: 12) {
                StrengthRow(
                    icon: "checkmark.circle.fill",
                    title: "Excellent: Equipment Safety, Lockout/Tagout",
                    color: .green
                )

                StrengthRow(
                    icon: "exclamationmark.triangle.fill",
                    title: "Needs Practice: Chemical Identification, Fall Protection",
                    color: .orange
                )
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
    }

    // MARK: - Certifications Section

    private var certificationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Certifications")
                .font(.title2)
                .fontWeight(.semibold)

            VStack(alignment: .leading, spacing: 12) {
                CertificationRow(
                    icon: "checkmark.seal.fill",
                    title: "Certified: Basic Safety, Fire Response",
                    color: .green
                )

                CertificationRow(
                    icon: "clock.fill",
                    title: "In Progress: Confined Space Entry (80% complete)",
                    color: .blue
                )
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
    }

    // MARK: - Sample Data

    private var sampleScoreData: [ScoreData] {
        [
            ScoreData(week: "Week 1", score: 75),
            ScoreData(week: "Week 2", score: 85),
            ScoreData(week: "Week 3", score: 78),
            ScoreData(week: "Week 4", score: 92)
        ]
    }

    // MARK: - Actions

    private func exportReport() {
        // Implement PDF export
    }
}

// MARK: - Metric Card

struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(color)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.title)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Strength Row

struct StrengthRow: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(color)

            Text(title)
                .font(.callout)
        }
    }
}

// MARK: - Certification Row

struct CertificationRow: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(color)

            Text(title)
                .font(.callout)
        }
    }
}

// MARK: - Supporting Types

enum TimePeriod: String, CaseIterable {
    case lastSevenDays = "7 Days"
    case lastThirtyDays = "30 Days"
    case lastSixMonths = "6 Months"
    case allTime = "All Time"
}

struct ScoreData: Identifiable {
    let id = UUID()
    let week: String
    let score: Double
}

#Preview {
    AnalyticsView()
        .environment(AppState())
}
