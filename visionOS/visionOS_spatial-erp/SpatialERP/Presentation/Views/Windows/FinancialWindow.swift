import SwiftUI
import Charts

struct FinancialWindow: View {
    @Environment(AppState.self) private var appState
    @State private var selectedTab: FinancialTab = .pnl

    enum FinancialTab: String, CaseIterable {
        case pnl = "P&L"
        case costCenters = "Cost Centers"
        case cashFlow = "Cash Flow"
        case budget = "Budget"
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header with tabs
            HeaderTabsView(selectedTab: $selectedTab)

            // Content
            TabView(selection: $selectedTab) {
                ProfitAndLossView()
                    .tag(FinancialTab.pnl)

                CostCentersView()
                    .tag(FinancialTab.costCenters)

                CashFlowView()
                    .tag(FinancialTab.cashFlow)

                BudgetView()
                    .tag(FinancialTab.budget)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .background(.ultraThinMaterial)
    }
}

// MARK: - Header Tabs
private struct HeaderTabsView: View {
    @Binding var selectedTab: FinancialWindow.FinancialTab
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Financial Analysis")
                    .font(.title)
                    .fontWeight(.bold)

                Spacer()

                Picker("Period", selection: $appState.selectedPeriod) {
                    ForEach(FiscalPeriod.allCases, id: \.self) { period in
                        Text(period.rawValue).tag(period)
                    }
                }
                .pickerStyle(.menu)
            }
            .padding(.horizontal, 32)
            .padding(.top, 24)
            .padding(.bottom, 16)

            // Tabs
            HStack(spacing: 0) {
                ForEach(FinancialWindow.FinancialTab.allCases, id: \.self) { tab in
                    Button(action: {
                        selectedTab = tab
                    }) {
                        Text(tab.rawValue)
                            .font(.subheadline)
                            .fontWeight(selectedTab == tab ? .semibold : .regular)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(selectedTab == tab ? Color.blue.opacity(0.1) : Color.clear)
                            .foregroundStyle(selectedTab == tab ? .blue : .primary)
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }

                Spacer()
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 16)

            Divider()
        }
    }
}

// MARK: - P&L View
struct ProfitAndLossView: View {
    @State private var profitAndLoss: ProfitAndLoss?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if let pnl = profitAndLoss {
                    // P&L Table
                    VStack(spacing: 0) {
                        PLRow(label: "Revenue", actual: pnl.revenue, budget: Decimal(40_000_000), isHeader: true)
                        PLRow(label: "Cost of Sales", actual: pnl.costOfSales, budget: Decimal(26_500_000))
                        PLRow(label: "Gross Profit", actual: pnl.grossProfit, budget: Decimal(13_500_000), isSubtotal: true)
                        PLRow(label: "Operating Expenses", actual: pnl.operatingExpenses, budget: Decimal(8_000_000))
                        PLRow(label: "EBITDA", actual: pnl.ebitda, budget: Decimal(5_500_000), isSubtotal: true)
                        PLRow(label: "Interest Expense", actual: pnl.interestExpense, budget: Decimal(500_000))
                        PLRow(label: "Tax Expense", actual: pnl.taxExpense, budget: Decimal(1_400_000))
                        PLRow(label: "Net Income", actual: pnl.netIncome, budget: Decimal(3_700_000), isTotal: true)
                    }
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))

                    // Revenue Trend Chart
                    RevenueTrendChart()
                } else {
                    ProgressView("Loading...")
                }
            }
            .padding(32)
        }
        .task {
            // Load P&L data
            try? await Task.sleep(for: .milliseconds(300))
            profitAndLoss = ProfitAndLoss(
                period: "Q4 2024",
                revenue: Decimal(42_300_000),
                costOfSales: Decimal(28_400_000),
                grossProfit: Decimal(13_900_000),
                operatingExpenses: Decimal(8_200_000),
                ebitda: Decimal(5_700_000),
                interestExpense: Decimal(500_000),
                taxExpense: Decimal(1_400_000),
                netIncome: Decimal(3_800_000)
            )
        }
    }
}

// MARK: - P&L Row
struct PLRow: View {
    let label: String
    let actual: Decimal
    let budget: Decimal
    var isHeader: Bool = false
    var isSubtotal: Bool = false
    var isTotal: Bool = false

    private var variance: Decimal {
        actual - budget
    }

    private var variancePercentage: Double {
        guard budget > 0 else { return 0 }
        return Double(truncating: ((variance / budget) * 100) as NSNumber)
    }

    var body: some View {
        HStack {
            Text(label)
                .font(isTotal ? .headline : (isSubtotal ? .subheadline.weight(.semibold) : .subheadline))
                .foregroundStyle(isHeader || isSubtotal || isTotal ? .primary : .secondary)

            Spacer()

            // Actual
            Text(formatCurrency(actual))
                .font(.system(.subheadline, design: .monospaced).weight(isTotal ? .semibold : .regular))
                .frame(width: 120, alignment: .trailing)

            // Budget
            Text(formatCurrency(budget))
                .font(.system(.subheadline, design: .monospaced))
                .foregroundStyle(.secondary)
                .frame(width: 120, alignment: .trailing)

            // Variance %
            HStack(spacing: 4) {
                Image(systemName: variancePercentage >= 0 ? "arrow.up" : "arrow.down")
                    .font(.caption2)
                Text(String(format: "%.1f%%", abs(variancePercentage)))
                    .font(.caption)
            }
            .foregroundStyle(varianceForLabel(variancePercentage, isRevenue: isHeader))
            .frame(width: 80, alignment: .trailing)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(isSubtotal || isTotal ? Color.gray.opacity(0.1) : Color.clear)
    }

    private func formatCurrency(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: value as NSNumber) ?? "$0"
    }

    private func varianceForLabel(_ variance: Double, isRevenue: Bool) -> Color {
        // For revenue, positive is good. For expenses, negative is good.
        if isRevenue {
            return variance >= 0 ? .green : .red
        } else {
            return variance <= 0 ? .green : .red
        }
    }
}

// MARK: - Revenue Trend Chart
struct RevenueTrendChart: View {
    let data: [RevenueData] = [
        RevenueData(month: "Jan", revenue: 3.2),
        RevenueData(month: "Feb", revenue: 3.5),
        RevenueData(month: "Mar", revenue: 3.8),
        RevenueData(month: "Apr", revenue: 3.6),
        RevenueData(month: "May", revenue: 4.0),
        RevenueData(month: "Jun", revenue: 4.1),
        RevenueData(month: "Jul", revenue: 3.9),
        RevenueData(month: "Aug", revenue: 4.3),
        RevenueData(month: "Sep", revenue: 4.5),
        RevenueData(month: "Oct", revenue: 4.2),
        RevenueData(month: "Nov", revenue: 4.4),
        RevenueData(month: "Dec", revenue: 4.2)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Revenue Trend (12 Months)")
                .font(.headline)

            Chart(data) { item in
                LineMark(
                    x: .value("Month", item.month),
                    y: .value("Revenue", item.revenue)
                )
                .foregroundStyle(.blue)
                .interpolationMethod(.catmullRom)

                AreaMark(
                    x: .value("Month", item.month),
                    y: .value("Revenue", item.revenue)
                )
                .foregroundStyle(.blue.opacity(0.1))
                .interpolationMethod(.catmullRom)
            }
            .frame(height: 200)
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisValueLabel {
                        if let doubleValue = value.as(Double.self) {
                            Text("$\(Int(doubleValue))M")
                        }
                    }
                }
            }
        }
        .padding(24)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct RevenueData: Identifiable {
    let id = UUID()
    let month: String
    let revenue: Double
}

// MARK: - Cost Centers View
struct CostCentersView: View {
    var body: some View {
        ScrollView {
            Text("Cost Centers View")
                .font(.title)
                .padding()
        }
    }
}

// MARK: - Cash Flow View
struct CashFlowView: View {
    var body: some View {
        ScrollView {
            Text("Cash Flow View")
                .font(.title)
                .padding()
        }
    }
}

// MARK: - Budget View
struct BudgetView: View {
    var body: some View {
        ScrollView {
            Text("Budget View")
                .font(.title)
                .padding()
        }
    }
}

#Preview {
    FinancialWindow()
        .environment(AppState())
}
