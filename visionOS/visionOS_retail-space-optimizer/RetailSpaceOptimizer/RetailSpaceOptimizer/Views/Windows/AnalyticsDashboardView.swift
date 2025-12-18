import SwiftUI
import Charts

struct AnalyticsDashboardView: View {
    let storeId: UUID

    @State private var selectedMetric: HeatMapData.HeatMapMetric = .traffic
    @State private var dateRange: DateRange = .last30Days

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // KPI Cards
                HStack(spacing: 16) {
                    KPICard(
                        title: "Sales/sqft",
                        value: "$2,340",
                        change: "+18%",
                        isPositive: true
                    )

                    KPICard(
                        title: "Traffic",
                        value: "12,450",
                        change: "+8%",
                        isPositive: true
                    )

                    KPICard(
                        title: "Conversion",
                        value: "24.5%",
                        change: "+3.2%",
                        isPositive: true
                    )
                }

                // Heat Map Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Performance Heat Map")
                            .font(.headline)

                        Spacer()

                        Picker("Metric", selection: $selectedMetric) {
                            ForEach([
                                HeatMapData.HeatMapMetric.traffic,
                                .sales,
                                .dwellTime,
                                .conversion
                            ], id: \.self) { metric in
                                Text(metric.rawValue).tag(metric)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 400)
                    }

                    // Heat map visualization placeholder
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                        .frame(height: 300)
                        .overlay {
                            Text("Heat Map Visualization")
                                .foregroundStyle(.secondary)
                        }
                }

                // Customer Journey Paths
                VStack(alignment: .leading, spacing: 12) {
                    Text("Customer Journey Paths")
                        .font(.headline)

                    VStack(spacing: 8) {
                        JourneyPathRow(
                            path: "Entrance → Apparel → Checkout",
                            frequency: 425,
                            value: "$87.50"
                        )

                        JourneyPathRow(
                            path: "Entrance → Electronics → Apparel → Checkout",
                            frequency: 312,
                            value: "$142.30"
                        )

                        JourneyPathRow(
                            path: "Entrance → Footwear → Checkout",
                            frequency: 208,
                            value: "$65.20"
                        )
                    }
                }

                // Time Range Selector
                HStack {
                    Picker("Time Range", selection: $dateRange) {
                        Text("Last 7 Days").tag(DateRange.last7Days)
                        Text("Last 30 Days").tag(DateRange.last30Days)
                        Text("Last 90 Days").tag(DateRange.last90Days)
                    }

                    Spacer()

                    Button(action: {}) {
                        Label("Export Report", systemImage: "square.and.arrow.up")
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Analytics Dashboard")
    }
}

// MARK: - KPI Card

struct KPICard: View {
    let title: String
    let value: String
    let change: String
    let isPositive: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.title.bold())

            HStack(spacing: 4) {
                Image(systemName: isPositive ? "arrow.up.right" : "arrow.down.right")
                Text(change)
            }
            .font(.caption)
            .foregroundStyle(isPositive ? .green : .red)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.regularMaterial)
        .cornerRadius(12)
    }
}

// MARK: - Journey Path Row

struct JourneyPathRow: View {
    let path: String
    let frequency: Int
    let value: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(path)
                    .font(.subheadline)

                Text("\(frequency) customers")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("Avg: \(value)")
                .font(.subheadline.bold())
                .foregroundStyle(.green)
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(8)
    }
}

// MARK: - Date Range

enum DateRange {
    case last7Days, last30Days, last90Days
}
