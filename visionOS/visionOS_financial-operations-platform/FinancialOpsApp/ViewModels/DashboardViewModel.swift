//
//  DashboardViewModel.swift
//  Financial Operations Platform
//
//  Dashboard view model with @Observable
//

import Foundation
import SwiftData

@Observable
final class DashboardViewModel {
    // MARK: - Published State

    var kpis: [KPI] = []
    var recentTransactions: [FinancialTransaction] = []
    var alerts: [FinancialAlert] = []
    var cashPosition: Decimal = 0
    var isLoading: Bool = false
    var errorMessage: String?

    // MARK: - Dependencies

    private let financialService: FinancialDataService
    private let treasuryService: TreasuryService

    // MARK: - Initialization

    init(
        financialService: FinancialDataService,
        treasuryService: TreasuryService
    ) {
        self.financialService = financialService
        self.treasuryService = treasuryService
    }

    // MARK: - Public Methods

    @MainActor
    func loadDashboard() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            // Load data in parallel
            async let kpisFetch = financialService.fetchKPIs()
            async let transactionsFetch = financialService.fetchTransactions(
                dateRange: .last30Days,
                accounts: nil,
                status: .pending
            )
            async let cashPositionFetch = treasuryService.getGlobalCashPosition()

            self.kpis = try await kpisFetch
            self.recentTransactions = try await transactionsFetch
            self.cashPosition = try await cashPositionFetch

            // Generate alerts from anomalies
            generateAlerts()
        } catch {
            errorMessage = error.localizedDescription
            print("Dashboard load error: \(error)")
        }
    }

    @MainActor
    func refresh() async {
        await loadDashboard()
    }

    func approveTransaction(_ transaction: FinancialTransaction) async throws {
        try await financialService.approveTransaction(transaction, approvedBy: "currentUser")
        await loadDashboard()
    }

    func rejectTransaction(_ transaction: FinancialTransaction) async throws {
        try await financialService.rejectTransaction(transaction)
        await loadDashboard()
    }

    // MARK: - Private Methods

    private func generateAlerts() {
        alerts.removeAll()

        // Check for pending approvals
        let pendingCount = recentTransactions.filter { $0.status == .pending }.count
        if pendingCount > 10 {
            alerts.append(FinancialAlert(
                severity: .high,
                category: .workflow,
                message: "\(pendingCount) transactions pending approval",
                action: "Review Pending Transactions"
            ))
        }

        // Check KPI targets
        for kpi in kpis where !kpi.isOnTarget {
            alerts.append(FinancialAlert(
                severity: .medium,
                category: .performance,
                message: "\(kpi.name) is \(abs(kpi.variancePercent))% off target",
                action: "View KPI Details"
            ))
        }

        // Check cash position
        if cashPosition < 500_000_000 {
            alerts.append(FinancialAlert(
                severity: .high,
                category: .liquidity,
                message: "Cash position below minimum threshold",
                action: "Review Cash Position"
            ))
        }
    }
}

// MARK: - Financial Alert

struct FinancialAlert: Identifiable {
    let id = UUID()
    let severity: AlertSeverity
    let category: AlertCategory
    let message: String
    let action: String
    let timestamp: Date = Date()

    enum AlertSeverity {
        case low
        case medium
        case high
        case critical

        var color: String {
            switch self {
            case .low: return "blue"
            case .medium: return "yellow"
            case .high: return "orange"
            case .critical: return "red"
            }
        }

        var icon: String {
            switch self {
            case .low: return "info.circle"
            case .medium: return "exclamationmark.circle"
            case .high: return "exclamationmark.triangle"
            case .critical: return "exclamationmark.octagon"
            }
        }
    }

    enum AlertCategory {
        case workflow
        case performance
        case liquidity
        case compliance
        case risk
    }
}
