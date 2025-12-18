//
//  HomeView.swift
//  PhysicalDigitalTwins
//
//  Home dashboard with stats and quick actions
//

import SwiftUI

struct HomeView: View {
    @Environment(AppState.self) private var appState

    @State private var showingScanner = false
    @State private var showingManualEntry = false

    var body: some View {
        @Bindable var state = appState

        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Stats Card
                    StatsCard(
                        totalItems: state.inventory.totalItems,
                        totalValue: state.inventory.totalValue
                    )

                    // Quick Actions
                    QuickActionsSection(
                        onScanBarcode: { showingScanner = true },
                        onAddManually: { showingManualEntry = true }
                    )

                    // Recent Items
                    RecentItemsSection(items: Array(state.inventory.items.prefix(5)))
                }
                .padding()
            }
            .navigationTitle("Physical-Digital Twins")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Scan", systemImage: "barcode.viewfinder") {
                        showingScanner = true
                    }
                }
            }
            .sheet(isPresented: $showingScanner) {
                ScanningView()
            }
            .sheet(isPresented: $showingManualEntry) {
                AddItemManuallyView()
            }
        }
    }
}

// MARK: - Stats Card

struct StatsCard: View {
    let totalItems: Int
    let totalValue: Decimal

    var body: some View {
        HStack(spacing: 16) {
            StatItem(
                title: "Total Items",
                value: "\(totalItems)",
                icon: "square.stack.3d.up",
                color: .blue
            )

            Divider()

            StatItem(
                title: "Total Value",
                value: formatCurrency(totalValue),
                icon: "dollarsign.circle",
                color: .green
            )
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }

    private func formatCurrency(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: value as NSDecimalNumber) ?? "$0"
    }
}

struct StatItem: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(color)

            Text(value)
                .font(.title2)
                .fontWeight(.semibold)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Quick Actions

struct QuickActionsSection: View {
    let onScanBarcode: () -> Void
    let onAddManually: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)

            HStack(spacing: 12) {
                QuickActionButton(
                    title: "Scan Barcode",
                    icon: "barcode.viewfinder",
                    color: .blue,
                    action: onScanBarcode
                )

                QuickActionButton(
                    title: "Add Manually",
                    icon: "plus.circle",
                    color: .green,
                    action: onAddManually
                )
            }
        }
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundStyle(color)

                Text(title)
                    .font(.caption)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Recent Items

struct RecentItemsSection: View {
    let items: [InventoryItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Items")
                .font(.headline)

            if items.isEmpty {
                ContentUnavailableView(
                    "No Items Yet",
                    systemImage: "tray",
                    description: Text("Scan or add your first item to get started")
                )
                .frame(height: 200)
            } else {
                ForEach(items) { item in
                    InventoryRow(item: item)
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .environment(AppState(dependencies: AppDependencies()))
}
