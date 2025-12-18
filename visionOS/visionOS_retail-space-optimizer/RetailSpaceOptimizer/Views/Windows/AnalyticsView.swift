import SwiftUI
import Charts

/// Analytics view for a store
struct AnalyticsView: View {
    let storeID: UUID
    @Environment(AppModel.self) private var appModel
    @State private var dateRange: DateRangeSelection = .last30Days
    @State private var analytics: StoreAnalytics?
    @State private var isLoading = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                HStack {
                    Text("Store Analytics")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Spacer()

                    Picker("Range", selection: $dateRange) {
                        ForEach(DateRangeSelection.allCases, id: \.self) { range in
                            Text(range.title).tag(range)
                        }
                    }
                    .pickerStyle(.menu)
                }
                .padding()

                if isLoading {
                    ProgressView("Loading analytics...")
                        .padding()
                } else if let analytics = analytics {
                    // Key Metrics
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        AnalyticsMetricCard(
                            title: "Total Revenue",
                            value: formatCurrency(analytics.salesData.totalRevenue),
                            change: nil,
                            icon: "dollarsign.circle.fill",
                            color: .green
                        )

                        AnalyticsMetricCard(
                            title: "Conversion",
                            value: String(format: "%.1f%%", analytics.trafficData.conversionRate),
                            change: nil,
                            icon: "chart.line.uptrend.xyaxis",
                            color: .blue
                        )

                        AnalyticsMetricCard(
                            title: "Avg Dwell",
                            value: String(format: "%.1f min", analytics.trafficData.averageDwellMinutes),
                            change: nil,
                            icon: "clock.fill",
                            color: .orange
                        )
                    }
                    .padding(.horizontal)

                    // Traffic Chart
                    GroupBox("Traffic Over Time") {
                        TrafficChart(data: analytics.trafficData)
                            .frame(height: 200)
                    }
                    .padding(.horizontal)

                    // Top Products
                    GroupBox("Top Performing Products") {
                        VStack(spacing: 12) {
                            ForEach(analytics.salesData.topProducts.prefix(5)) { product in
                                ProductPerformanceRow(product: product)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .padding(.horizontal)

                    // Heatmap Preview
                    if let heatmap = analytics.heatmaps.first {
                        GroupBox("Traffic Heatmap") {
                            HeatmapPreview(heatmap: heatmap)
                                .frame(height: 200)
                        }
                        .padding(.horizontal)
                    }

                    // Export Actions
                    HStack(spacing: 12) {
                        Button(action: exportPDF) {
                            Label("Export PDF", systemImage: "doc.fill")
                        }
                        .buttonStyle(.bordered)

                        Button(action: exportCSV) {
                            Label("Export CSV", systemImage: "tablecells")
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                }
            }
        }
        .task {
            await loadAnalytics()
        }
        .onChange(of: dateRange) { _, _ in
            Task { await loadAnalytics() }
        }
    }

    // MARK: - Data Loading

    private func loadAnalytics() async {
        isLoading = true
        defer { isLoading = false }

        // In a real implementation, would fetch from service
        // For now, create mock data
        analytics = createMockAnalytics()
    }

    private func createMockAnalytics() -> StoreAnalytics {
        var analytics = StoreAnalytics(
            storeID: storeID,
            dateRange: dateRange.interval
        )

        analytics.trafficData = TrafficData(
            totalVisitors: 5420,
            uniqueVisitors: 4200,
            averageDwellTime: 780,  // 13 minutes
            peakHours: [11, 12, 13, 14, 15, 16, 17],
            conversionRate: 28.5,
            bounceRate: 12.3,
            repeatVisitorRate: 35.2
        )

        analytics.salesData = SalesData(
            totalRevenue: 125420.50,
            totalTransactions: 1543,
            salesPerSquareFoot: 425.32,
            averageBasketSize: 81.25,
            averageItemsPerBasket: 3.2
        )

        return analytics
    }

    // MARK: - Actions

    private func exportPDF() {
        // Export analytics as PDF
    }

    private func exportCSV() {
        // Export analytics as CSV
    }

    private func formatCurrency(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: value as NSNumber) ?? "$0"
    }
}

// MARK: - Supporting Views

struct AnalyticsMetricCard: View {
    let title: String
    let value: String
    let change: Double?
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)

                Spacer()

                if let change = change {
                    ChangeIndicator(change: change)
                }
            }

            Text(value)
                .font(.title)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct ChangeIndicator: View {
    let change: Double

    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: change >= 0 ? "arrow.up" : "arrow.down")
                .font(.caption2)

            Text(String(format: "%.1f%%", abs(change)))
                .font(.caption)
        }
        .foregroundStyle(change >= 0 ? .green : .red)
    }
}

struct TrafficChart: View {
    let data: TrafficData

    var body: some View {
        // In a real implementation, would use SwiftCharts
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(.tertiary.opacity(0.3))

            Text("Traffic Chart Placeholder")
                .foregroundStyle(.secondary)
        }
    }
}

struct ProductPerformanceRow: View {
    let product: ProductPerformance

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(product.name)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text("SKU: \(product.sku)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing) {
                Text(formatCurrency(product.revenue))
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text("\(product.salesCount) sold")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private func formatCurrency(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: value as NSNumber) ?? "$0"
    }
}

struct HeatmapPreview: View {
    let heatmap: Heatmap

    var body: some View {
        // In a real implementation, would render actual heatmap
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(.blue.opacity(0.3))

            Text("Heatmap Preview")
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Date Range Selection

enum DateRangeSelection: CaseIterable {
    case last7Days
    case last30Days
    case last90Days
    case lastYear

    var title: String {
        switch self {
        case .last7Days: return "Last 7 Days"
        case .last30Days: return "Last 30 Days"
        case .last90Days: return "Last 90 Days"
        case .lastYear: return "Last Year"
        }
    }

    var interval: DateInterval {
        let end = Date()
        let start: Date

        switch self {
        case .last7Days:
            start = end.addingTimeInterval(-7 * 86400)
        case .last30Days:
            start = end.addingTimeInterval(-30 * 86400)
        case .last90Days:
            start = end.addingTimeInterval(-90 * 86400)
        case .lastYear:
            start = end.addingTimeInterval(-365 * 86400)
        }

        return DateInterval(start: start, end: end)
    }
}

#Preview {
    AnalyticsView(storeID: UUID())
        .environment(AppModel())
}
