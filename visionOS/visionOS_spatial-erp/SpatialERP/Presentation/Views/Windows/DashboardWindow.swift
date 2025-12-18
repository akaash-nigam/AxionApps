import SwiftUI
import SwiftData

struct DashboardWindow: View {
    @Environment(AppState.self) private var appState
    @Environment(\.openWindow) private var openWindow
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    @State private var viewModel: DashboardViewModel

    init() {
        _viewModel = State(initialValue: DashboardViewModel())
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                HeaderView()

                // KPI Cards
                KPICardsView(kpis: viewModel.kpiData)

                // Critical Alerts
                AlertsPanelView(alerts: appState.alerts)

                // Quick Launch
                QuickLaunchView()
            }
            .padding(32)
        }
        .background(.ultraThinMaterial)
        .task {
            await viewModel.loadDashboard()
        }
    }
}

// MARK: - Header View
private struct HeaderView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Spatial ERP")
                    .font(.system(size: 32, weight: .bold))

                Text("Today • \(appState.selectedPeriod.rawValue) • Enterprise View")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button(action: {}) {
                Image(systemName: "gearshape")
                    .font(.title2)
            }
            .buttonStyle(.bordered)
            .accessibilityLabel("Settings")
        }
    }
}

// MARK: - KPI Cards View
private struct KPICardsView: View {
    let kpis: KPIDashboard?

    var body: some View {
        if let kpis = kpis {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                KPICard(
                    title: "Revenue",
                    value: formatCurrency(kpis.financial.revenue),
                    change: kpis.financial.revenueChange,
                    icon: "dollarsign.circle.fill",
                    color: .blue
                )

                KPICard(
                    title: "Profit",
                    value: formatCurrency(kpis.financial.profit),
                    change: 8.1,
                    icon: "chart.line.uptrend.xyaxis.circle.fill",
                    color: .green
                )

                KPICard(
                    title: "Orders",
                    value: "\(kpis.operations.totalOrders)",
                    change: -2.4,
                    icon: "doc.text.fill",
                    color: .orange
                )

                KPICard(
                    title: "Inventory",
                    value: "\(Int(kpis.operations.utilizationRate))%",
                    change: 3.2,
                    icon: "shippingbox.fill",
                    color: .purple
                )
            }
        } else {
            // Loading state
            HStack(spacing: 16) {
                ForEach(0..<4) { _ in
                    KPICardSkeleton()
                }
            }
        }
    }

    private func formatCurrency(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 1

        let millions = value / 1_000_000
        return formatter.string(from: millions as NSNumber)! + "M"
    }
}

// MARK: - KPI Card
struct KPICard: View {
    let title: String
    let value: String
    let change: Double
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)

                Spacer()
            }

            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.system(size: 28, weight: .semibold, design: .rounded))

            HStack(spacing: 4) {
                Image(systemName: change >= 0 ? "arrow.up.right" : "arrow.down.right")
                    .font(.caption)

                Text(String(format: "%.1f%%", abs(change)))
                    .font(.caption)
            }
            .foregroundStyle(change >= 0 ? .green : .red)

            // Mini sparkline
            MiniSparkline(trend: change >= 0 ? .up : .down, color: color)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value), \(change >= 0 ? "up" : "down") \(String(format: "%.1f", abs(change))) percent")
    }
}

// MARK: - Mini Sparkline
struct MiniSparkline: View {
    enum Trend {
        case up, down
    }

    let trend: Trend
    let color: Color

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height

                // Simple sparkline based on trend
                if trend == .up {
                    path.move(to: CGPoint(x: 0, y: height))
                    path.addLine(to: CGPoint(x: width * 0.25, y: height * 0.7))
                    path.addLine(to: CGPoint(x: width * 0.5, y: height * 0.5))
                    path.addLine(to: CGPoint(x: width * 0.75, y: height * 0.3))
                    path.addLine(to: CGPoint(x: width, y: 0))
                } else {
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: width * 0.25, y: height * 0.3))
                    path.addLine(to: CGPoint(x: width * 0.5, y: height * 0.5))
                    path.addLine(to: CGPoint(x: width * 0.75, y: height * 0.7))
                    path.addLine(to: CGPoint(x: width, y: height))
                }
            }
            .stroke(color.opacity(0.5), lineWidth: 2)
        }
        .frame(height: 40)
    }
}

// MARK: - KPI Card Skeleton
struct KPICardSkeleton: View {
    @State private var isAnimating = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(.gray.opacity(0.3))
                .frame(width: 40, height: 40)

            RoundedRectangle(cornerRadius: 4)
                .fill(.gray.opacity(0.3))
                .frame(height: 16)

            RoundedRectangle(cornerRadius: 4)
                .fill(.gray.opacity(0.3))
                .frame(height: 32)

            RoundedRectangle(cornerRadius: 4)
                .fill(.gray.opacity(0.3))
                .frame(width: 60, height: 16)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .opacity(isAnimating ? 0.5 : 1.0)
        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Alerts Panel
struct AlertsPanelView: View {
    let alerts: [Alert]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Critical Alerts")
                    .font(.title3)
                    .fontWeight(.semibold)

                Spacer()

                if !alerts.isEmpty {
                    Text("\(alerts.count)")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.red.opacity(0.2), in: Capsule())
                        .foregroundStyle(.red)
                }
            }

            if alerts.isEmpty {
                Text("No critical alerts")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 20)
            } else {
                VStack(spacing: 8) {
                    ForEach(alerts.prefix(3)) { alert in
                        AlertRow(alert: alert)
                    }
                }
            }
        }
        .padding(24)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Alert Row
struct AlertRow: View {
    let alert: Alert

    var severityIcon: String {
        switch alert.severity {
        case .critical: return "exclamationmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .info: return "info.circle.fill"
        }
    }

    var severityColor: Color {
        switch alert.severity {
        case .critical: return .red
        case .warning: return .orange
        case .info: return .blue
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: severityIcon)
                .font(.title3)
                .foregroundStyle(severityColor)

            VStack(alignment: .leading, spacing: 2) {
                Text(alert.title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(alert.message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Quick Launch
struct QuickLaunchView: View {
    @Environment(\.openWindow) private var openWindow
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Launch")
                .font(.title3)
                .fontWeight(.semibold)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                QuickLaunchCard(
                    title: "Financial Analysis",
                    icon: "dollarsign.circle",
                    color: .blue
                ) {
                    openWindow(id: "financial")
                }

                QuickLaunchCard(
                    title: "Operations Center",
                    icon: "gearshape.2",
                    color: .orange
                ) {
                    Task {
                        await openImmersiveSpace(id: "operations-center")
                    }
                }

                QuickLaunchCard(
                    title: "Supply Chain Network",
                    icon: "shippingbox",
                    color: .green
                ) {
                    openWindow(id: "supply-chain-volume")
                }
            }
        }
    }
}

// MARK: - Quick Launch Card
struct QuickLaunchCard: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 40))
                    .foregroundStyle(color)

                Text(title)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open \(title)")
    }
}

// MARK: - Dashboard ViewModel
@Observable
class DashboardViewModel {
    var kpiData: KPIDashboard?
    var isLoading: Bool = false
    var error: Error?

    func loadDashboard() async {
        isLoading = true
        defer { isLoading = false }

        do {
            // Simulate loading data
            try await Task.sleep(for: .milliseconds(500))

            // Mock KPI data
            kpiData = KPIDashboard(
                timestamp: Date(),
                financial: FinancialKPIs(
                    revenue: Decimal(4_200_000),
                    revenueChange: 12.3,
                    profit: Decimal(890_000),
                    profitMargin: 21.2,
                    cashPosition: Decimal(2_500_000),
                    daysPayableOutstanding: 45,
                    daysReceivableOutstanding: 38
                ),
                operations: OperationalKPIs(
                    totalOrders: 1247,
                    completedOrders: 1156,
                    onTimeDelivery: 94.2,
                    averageOEE: 88.5,
                    utilizationRate: 92.1,
                    qualityRate: 98.7
                ),
                supplyChain: SupplyChainKPIs(
                    inventoryValue: Decimal(3_200_000),
                    inventoryTurnover: 12.5,
                    fillRate: 96.8,
                    onTimeDeliveryRate: 94.5,
                    supplierPerformanceScore: 4.3,
                    daysInventoryOnHand: 29
                )
            )
        } catch {
            self.error = error
        }
    }
}

#Preview {
    DashboardWindow()
        .environment(AppState())
}
