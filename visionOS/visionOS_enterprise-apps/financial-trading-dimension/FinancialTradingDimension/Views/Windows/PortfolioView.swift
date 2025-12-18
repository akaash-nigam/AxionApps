import SwiftUI
import Charts

struct PortfolioView: View {
    @Environment(AppModel.self) private var appModel
    @State private var portfolio: Portfolio?
    @State private var riskMetrics: RiskMetrics?
    @State private var isLoading = true

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Loading portfolio...")
                } else if let portfolio = portfolio {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Portfolio Summary
                            PortfolioSummarySection(portfolio: portfolio)

                            // Positions List
                            PositionsSection(portfolio: portfolio, appModel: appModel)

                            // Performance Chart
                            PerformanceChartSection()

                            // Risk Metrics
                            if let metrics = riskMetrics {
                                RiskMetricsSection(metrics: metrics)
                            }

                            // Action Buttons
                            ActionButtonsSection()
                        }
                        .padding()
                    }
                } else {
                    ContentUnavailableView {
                        Label("No Portfolio", systemImage: "chart.line.uptrend.xyaxis")
                    } description: {
                        Text("Create a portfolio to start tracking your investments")
                    } actions: {
                        Button("Create Portfolio") {
                            createPortfolio()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            .navigationTitle("My Portfolio")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        Task {
                            await refreshPortfolio()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .glassBackgroundEffect()
        }
        .task {
            await loadPortfolio()
        }
    }

    private func loadPortfolio() async {
        // Simulate loading
        try? await Task.sleep(for: .milliseconds(500))

        portfolio = appModel.portfolioService.createSamplePortfolio()

        if let portfolio = portfolio {
            riskMetrics = try? await appModel.portfolioService.calculatePortfolioMetrics(portfolio)
        }

        isLoading = false
    }

    private func refreshPortfolio() async {
        guard let portfolio = portfolio else { return }

        appModel.portfolioService.updatePositionPrices(portfolio, marketData: appModel.marketDataUpdates)

        riskMetrics = try? await appModel.portfolioService.calculatePortfolioMetrics(portfolio)
    }

    private func createPortfolio() {
        portfolio = appModel.portfolioService.createSamplePortfolio()
    }
}

struct PortfolioSummarySection: View {
    var portfolio: Portfolio

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Total Value")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(portfolio.totalValue, format: .currency(code: "USD"))
                        .font(.largeTitle.bold())
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 8) {
                    Text("Day P&L")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 4) {
                        Image(systemName: portfolio.totalUnrealizedPnL >= 0 ? "arrow.up.right" : "arrow.down.right")

                        Text(portfolio.totalUnrealizedPnL, format: .currency(code: "USD"))
                            .font(.title2.bold())
                    }
                    .foregroundStyle(portfolio.totalUnrealizedPnL >= 0 ? .green : .red)
                }
            }

            Divider()

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Cash")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(portfolio.cashBalance, format: .currency(code: "USD"))
                        .font(.body.bold())
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Total Return")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(portfolio.totalPercentageReturn, format: .percent.precision(.fractionLength(1)))
                        .font(.body.bold())
                        .foregroundStyle(portfolio.totalPercentageReturn >= 0 ? .green : .red)
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: .rect(cornerRadius: 16))
    }
}

struct PositionsSection: View {
    var portfolio: Portfolio
    var appModel: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Positions")
                .font(.headline)

            VStack(spacing: 8) {
                ForEach(portfolio.positions, id: \.symbol) { position in
                    PositionRow(position: position)
                        .onTapGesture {
                            appModel.selectSymbol(position.symbol)
                        }
                }
            }
        }
    }
}

struct PositionRow: View {
    var position: Position

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(position.symbol)
                    .font(.body.bold())

                Text("\(Int(truncating: position.quantity as NSNumber)) shares")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .center, spacing: 4) {
                Text(position.currentPrice, format: .currency(code: "USD"))
                    .font(.body)

                Text("Avg: \(position.averageCost, format: .currency(code: "USD"))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(position.marketValue, format: .currency(code: "USD"))
                    .font(.body.bold())

                HStack(spacing: 4) {
                    Text(position.unrealizedPnL, format: .currency(code: "USD"))
                        .font(.caption)

                    Text("(\(position.percentageReturn, specifier: "%+.1f")%)")
                        .font(.caption)
                }
                .foregroundStyle(position.unrealizedPnL >= 0 ? .green : .red)
            }
        }
        .padding()
        .background(.regularMaterial, in: .rect(cornerRadius: 12))
    }
}

struct PerformanceChartSection: View {
    @State private var performanceData: [PerformanceDataPoint] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Performance (YTD)")
                .font(.headline)

            if performanceData.isEmpty {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.regularMaterial)
                    .frame(height: 200)
                    .overlay {
                        Text("No data available")
                            .foregroundStyle(.secondary)
                    }
            } else {
                Chart(performanceData) { point in
                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("Value", point.value)
                    )
                    .foregroundStyle(.blue)
                    .interpolationMethod(.catmullRom)
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .month)) { _ in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(format: .dateTime.month(.abbreviated))
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let intValue = value.as(Int.self) {
                                Text("$\(intValue / 1000)K")
                            }
                        }
                    }
                }
                .padding()
                .background(.regularMaterial, in: .rect(cornerRadius: 12))
            }
        }
        .task {
            generateSamplePerformanceData()
        }
    }

    private func generateSamplePerformanceData() {
        let calendar = Calendar.current
        let now = Date()

        performanceData = (0..<12).map { month in
            let date = calendar.date(byAdding: .month, value: -12 + month, to: now)!
            let value = 1_000_000 + Double.random(in: -50_000...150_000)
            return PerformanceDataPoint(date: date, value: value)
        }
    }
}

struct RiskMetricsSection: View {
    var metrics: RiskMetrics

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Risk Metrics")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                RiskMetricCard(title: "Sharpe Ratio", value: String(format: "%.2f", metrics.sharpeRatio))
                RiskMetricCard(title: "Beta", value: String(format: "%.2f", metrics.beta))
                RiskMetricCard(title: "Volatility", value: String(format: "%.1f%%", metrics.volatility * 100))
                RiskMetricCard(title: "Max Drawdown", value: String(format: "%.1f%%", metrics.maxDrawdown * 100))
                RiskMetricCard(title: "VaR (95%)", value: metrics.var95, format: .currency(code: "USD"))
                RiskMetricCard(title: "VaR (99%)", value: metrics.var99, format: .currency(code: "USD"))
            }
        }
    }
}

struct RiskMetricCard: View {
    var title: String
    var value: String

    init(title: String, value: String) {
        self.title = title
        self.value = value
    }

    init<T: CVarArg>(title: String, value: T, format: FormatStyle<T, String>) {
        self.title = title
        self.value = format.format(value as! FormatStyle<T, String>.FormatInput)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.body.bold())
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: .rect(cornerRadius: 12))
    }
}

struct ActionButtonsSection: View {
    var body: some View {
        HStack(spacing: 12) {
            Button {
                // Open risk analysis
            } label: {
                Label("Risk Analysis", systemImage: "shield.checkered")
            }
            .buttonStyle(.bordered)
            .frame(maxWidth: .infinity)

            Button {
                // Open trading
            } label: {
                Label("Trade", systemImage: "arrow.left.arrow.right")
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)

            Button {
                // Open 3D visualization
            } label: {
                Label("3D View", systemImage: "cube")
            }
            .buttonStyle(.bordered)
            .frame(maxWidth: .infinity)
        }
    }
}

struct PerformanceDataPoint: Identifiable {
    var id: Date { date }
    var date: Date
    var value: Double
}

#Preview {
    PortfolioView()
        .environment(AppModel())
}
