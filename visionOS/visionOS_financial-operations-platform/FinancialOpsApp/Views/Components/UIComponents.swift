//
//  UIComponents.swift
//  Financial Operations Platform
//
//  Reusable UI components for visionOS
//

import SwiftUI

// MARK: - KPI Card

struct KPICardView: View {
    let kpi: KPI

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: kpi.category.icon)
                    .foregroundColor(.blue)

                Spacer()

                Image(systemName: kpi.trend.icon)
                    .foregroundColor(colorForTrend(kpi.trend))
            }

            Text(kpi.name)
                .font(.headline)
                .foregroundStyle(.secondary)

            Text(kpi.formattedCurrentValue)
                .font(.system(.title, design: .rounded))
                .fontWeight(.bold)

            HStack {
                Text("Target: \(kpi.formattedTargetValue)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Text("\(kpi.changePercent, specifier: "%.1f")%")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(kpi.changePercent >= 0 ? .green : .red)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }

    private func colorForTrend(_ trend: TrendDirection) -> Color {
        switch trend {
        case .up: return .green
        case .down: return .red
        case .stable: return .blue
        }
    }
}

// MARK: - Alert Card

struct AlertCardView: View {
    let alert: FinancialAlert

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: alert.severity.icon)
                .font(.title2)
                .foregroundColor(colorForSeverity(alert.severity))

            VStack(alignment: .leading, spacing: 4) {
                Text(alert.message)
                    .font(.headline)

                Text(alert.action)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button("Action") {
                // Handle action
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }

    private func colorForSeverity(_ severity: FinancialAlert.AlertSeverity) -> Color {
        switch severity {
        case .low: return .blue
        case .medium: return .yellow
        case .high: return .orange
        case .critical: return .red
        }
    }
}

// MARK: - Transaction Row

struct TransactionRowView: View {
    let transaction: FinancialTransaction
    let onApprove: () -> Void
    let onReject: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.description)
                    .font(.headline)

                HStack {
                    Text(transaction.accountCode)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("•")
                        .foregroundStyle(.secondary)

                    Text(transaction.transactionDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(transaction.formattedAmount)
                    .font(.headline)
                    .fontWeight(.semibold)

                statusBadge(transaction.status)
            }

            if transaction.status == .pending {
                HStack(spacing: 8) {
                    Button {
                        onApprove()
                    } label: {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                    .buttonStyle(.borderless)

                    Button {
                        onReject()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                    }
                    .buttonStyle(.borderless)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(8)
    }

    @ViewBuilder
    private func statusBadge(_ status: TransactionStatus) -> some View {
        Text(status.displayName)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor(status).opacity(0.2))
            .foregroundColor(statusColor(status))
            .cornerRadius(6)
    }

    private func statusColor(_ status: TransactionStatus) -> Color {
        switch status {
        case .draft: return .gray
        case .pending: return .yellow
        case .approved: return .green
        case .posted: return .blue
        case .reconciled: return .green
        case .rejected: return .red
        }
    }
}

// MARK: - Quick Action Button

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(color)

                Text(title)
                    .font(.headline)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(.ultraThinMaterial)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
        .hoverEffect()
    }
}

// MARK: - Empty State

struct EmptyStateView: View {
    let icon: String
    let message: String
    let action: String?
    let onAction: (() -> Void)?

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text(message)
                .font(.headline)
                .foregroundStyle(.secondary)

            if let action = action, let onAction = onAction {
                Button(action) {
                    onAction()
                }
                .buttonStyle(.bordered)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

// MARK: - Sidebar

struct SidebarView: View {
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        List {
            Section("Main") {
                Label("Dashboard", systemImage: "square.grid.2x2")
                Label("Transactions", systemImage: "doc.text")
                Label("Treasury", systemImage: "banknote")
                Label("Analytics", systemImage: "chart.bar")
            }

            Section("3D Views") {
                Label("Cash Flow Universe", systemImage: "water.waves")
                Label("Risk Topography", systemImage: "mountain.2")
                Label("Performance Galaxy", systemImage: "sparkles")
                Label("KPI Volume", systemImage: "cube")
            }

            Section("Operations") {
                Label("Close Management", systemImage: "calendar.badge.checkmark")
                Label("Compliance", systemImage: "checkmark.shield")
            }
        }
        .navigationTitle("FinOps")
    }
}
