//
//  DashboardView.swift
//  Financial Operations Platform
//
//  Main dashboard view for visionOS
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    // MARK: - Properties

    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openWindow) private var openWindow
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace

    @State private var viewModel: DashboardViewModel

    // MARK: - Initialization

    init() {
        // Note: In production, inject via environment
        let service = FinancialDataService(
            modelContext: ModelContext(ModelContainer.shared),
            apiClient: .shared
        )
        let treasuryService = TreasuryService(
            modelContext: ModelContext(ModelContainer.shared),
            apiClient: .shared
        )

        _viewModel = State(initialValue: DashboardViewModel(
            financialService: service,
            treasuryService: treasuryService
        ))
    }

    // MARK: - Body

    var body: some View {
        NavigationSplitView {
            // Sidebar
            SidebarView()
        } detail: {
            // Main content
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    headerSection

                    // KPI Cards
                    kpiSection

                    // Alerts
                    if !viewModel.alerts.isEmpty {
                        alertsSection
                    }

                    // Recent Transactions
                    recentTransactionsSection

                    // Quick Actions
                    quickActionsSection
                }
                .padding()
            }
            .navigationTitle("Financial Dashboard")
            .toolbar {
                ToolbarItemGroup {
                    Button("Refresh", systemImage: "arrow.clockwise") {
                        Task { await viewModel.refresh() }
                    }

                    Button("3D View", systemImage: "cube") {
                        Task {
                            await openImmersiveSpace(id: "cash-flow-universe")
                        }
                    }
                }
            }
        }
        .task {
            await viewModel.loadDashboard()
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
                    .controlSize(.large)
            }
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Welcome to Financial Operations")
                .font(.largeTitle)
                .fontWeight(.bold)

            HStack {
                Text("Last updated: \(Date().formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Text("Cash Position: \(viewModel.cashPosition.formatted(.currency(code: "USD")))")
                    .font(.headline)
                    .foregroundColor(viewModel.cashPosition >= 0 ? .green : .red)
            }
        }
    }

    private var kpiSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Key Performance Indicators")
                .font(.title2)
                .fontWeight(.semibold)

            if viewModel.kpis.isEmpty {
                EmptyStateView(
                    icon: "chart.xyaxis.line",
                    message: "No KPIs available",
                    action: "Load Sample Data",
                    onAction: {
                        Task { await viewModel.loadDashboard() }
                    }
                )
                .frame(height: 200)
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(viewModel.kpis) { kpi in
                        KPICardView(kpi: kpi)
                    }
                }
            }
        }
    }

    private var alertsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Alerts")
                .font(.title2)
                .fontWeight(.semibold)

            ForEach(viewModel.alerts) { alert in
                AlertCardView(alert: alert)
            }
        }
    }

    private var recentTransactionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Transactions")
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()

                Button("View All") {
                    openWindow(id: "transactions")
                }
            }

            if viewModel.recentTransactions.isEmpty {
                EmptyStateView(
                    icon: "doc.text",
                    message: "No recent transactions",
                    action: nil,
                    onAction: nil
                )
                .frame(height: 150)
            } else {
                VStack(spacing: 8) {
                    ForEach(viewModel.recentTransactions.prefix(5)) { transaction in
                        TransactionRowView(transaction: transaction) {
                            Task {
                                try? await viewModel.approveTransaction(transaction)
                            }
                        } onReject: {
                            Task {
                                try? await viewModel.rejectTransaction(transaction)
                            }
                        }
                    }
                }
            }
        }
    }

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.title2)
                .fontWeight(.semibold)

            HStack(spacing: 16) {
                QuickActionButton(
                    title: "Process Transaction",
                    icon: "doc.badge.plus",
                    color: .blue
                ) {
                    openWindow(id: "transactions")
                }

                QuickActionButton(
                    title: "Treasury",
                    icon: "banknote",
                    color: .green
                ) {
                    openWindow(id: "treasury")
                }

                QuickActionButton(
                    title: "Run Report",
                    icon: "chart.bar.doc.horizontal",
                    color: .orange
                ) {
                    // Open reports
                }

                QuickActionButton(
                    title: "KPI Volume",
                    icon: "cube.fill",
                    color: .purple
                ) {
                    openWindow(id: "kpi-volume")
                }
            }
        }
    }
}

// MARK: - Model Container Extension

extension ModelContainer {
    static var shared: ModelContainer = {
        let schema = Schema([
            FinancialTransaction.self,
            Account.self,
            CashPosition.self,
            KPI.self,
            RiskAssessment.self,
            CloseTask.self
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()
}

// MARK: - Preview

#Preview {
    DashboardView()
}
