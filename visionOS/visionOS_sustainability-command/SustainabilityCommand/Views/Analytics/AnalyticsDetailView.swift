import SwiftUI
import Charts

struct AnalyticsDetailView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedTimeRange: TimeRange = .year

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header with time range selector
                headerSection

                // Emission trends chart
                emissionTrendsSection

                // AI Insights
                aiInsightsSection
            }
            .padding(24)
        }
        .frame(width: 1000, height: 700)
        .background(.regularMaterial)
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            Text("Analytics & Insights")
                .font(.largeTitle)
                .fontWeight(.bold)

            Spacer()

            Picker("Time Range", selection: $selectedTimeRange) {
                ForEach(TimeRange.allCases, id: \.self) { range in
                    Text(range.rawValue).tag(range)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 300)
        }
    }

    // MARK: - Trends

    private var emissionTrendsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Emission Trends")
                .font(.title2)
                .fontWeight(.semibold)

            Chart {
                // Placeholder data - would use real data
                ForEach(0..<12, id: \.self) { month in
                    LineMark(
                        x: .value("Month", month),
                        y: .value("Emissions", Double.random(in: 30000...50000))
                    )
                    .foregroundStyle(.green)
                }
            }
            .frame(height: 250)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - AI Insights

    private var aiInsightsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("AI Insights")
                .font(.title2)
                .fontWeight(.semibold)

            VStack(spacing: 12) {
                InsightCard(
                    icon: "lightbulb.fill",
                    color: .blue,
                    title: "Opportunity: Switch to renewable energy",
                    description: "Shanghai facility could reduce emissions by 18% (2,400 tCO2/year)",
                    metric: "ROI: 14 months"
                )

                InsightCard(
                    icon: "exclamationmark.triangle.fill",
                    color: .orange,
                    title: "Alert: Manufacturing emissions up 8%",
                    description: "vs. last quarter. Root cause analysis suggests equipment inefficiency.",
                    metric: nil
                )
            }
        }
    }
}

struct InsightCard: View {
    let icon: String
    let color: Color
    let title: String
    let description: String
    let metric: String?

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)

                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if let metric = metric {
                    Text(metric)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(color)
                }

                Button("Explore") {
                    // Explore action
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

enum TimeRange: String, CaseIterable {
    case month = "Month"
    case quarter = "Quarter"
    case year = "Year"
    case all = "All Time"
}

#Preview {
    AnalyticsDetailView()
        .environment(AppState())
}
