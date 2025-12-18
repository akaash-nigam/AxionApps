import SwiftUI
import SwiftData

struct AnalyticsView: View {
    @Query private var twins: [DigitalTwin]
    @State private var selectedTimeRange: TimeRange = .week

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Time range selector
                    Picker("Time Range", selection: $selectedTimeRange) {
                        ForEach(TimeRange.allCases) { range in
                            Text(range.displayName).tag(range)
                        }
                    }
                    .pickerStyle(.segmented)

                    // Overall metrics
                    overallMetricsSection

                    // Performance trends
                    performanceTrendsSection

                    // Predictions analysis
                    predictionsAnalysisSection
                }
                .padding()
            }
            .navigationTitle("Analytics")
        }
    }

    private var overallMetricsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Overall Performance")
                .font(.title2)
                .bold()

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                AnalyticCard(
                    title: "Average Uptime",
                    value: "99.2%",
                    trend: .up,
                    systemImage: "arrow.up.circle.fill",
                    color: .green
                )

                AnalyticCard(
                    title: "Energy Efficiency",
                    value: "87%",
                    trend: .down,
                    systemImage: "bolt.fill",
                    color: .orange
                )

                AnalyticCard(
                    title: "Maintenance Cost",
                    value: "$12.5K",
                    trend: .down,
                    systemImage: "dollarsign.circle.fill",
                    color: .blue
                )
            }
        }
    }

    private var performanceTrendsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Performance Trends")
                .font(.title2)
                .bold()

            // Placeholder for chart
            VStack {
                Text("Performance Chart")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Text("Chart visualization will be implemented using Charts framework")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
            }
            .frame(height: 300)
            .frame(maxWidth: .infinity)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
    }

    private var predictionsAnalysisSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Prediction Accuracy")
                .font(.title2)
                .bold()

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                StatCard(
                    title: "Predictions Made",
                    value: "47",
                    subtitle: "Last 30 days"
                )

                StatCard(
                    title: "Accuracy Rate",
                    value: "94%",
                    subtitle: "Validated predictions"
                )

                StatCard(
                    title: "Issues Prevented",
                    value: "12",
                    subtitle: "Through proactive action"
                )

                StatCard(
                    title: "Cost Savings",
                    value: "$3.2M",
                    subtitle: "Estimated savings"
                )
            }
        }
    }
}

struct AnalyticCard: View {
    let title: String
    let value: String
    let trend: Trend
    let systemImage: String
    let color: Color

    enum Trend {
        case up, down, stable
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: systemImage)
                    .foregroundStyle(color)
                Spacer()
                Image(systemName: trendIcon)
                    .foregroundStyle(trendColor)
                    .font(.caption)
            }

            Text(value)
                .font(.title)
                .bold()

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private var trendIcon: String {
        switch trend {
        case .up: return "arrow.up.right"
        case .down: return "arrow.down.right"
        case .stable: return "arrow.right"
        }
    }

    private var trendColor: Color {
        switch trend {
        case .up: return .green
        case .down: return .red
        case .stable: return .gray
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.title)
                .bold()

            Text(subtitle)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

enum TimeRange: String, CaseIterable, Identifiable {
    case day = "24H"
    case week = "7D"
    case month = "30D"
    case quarter = "90D"
    case year = "1Y"

    var id: String { rawValue }

    var displayName: String { rawValue }
}

#Preview {
    AnalyticsView()
        .frame(width: 1000, height: 700)
}
