//
//  DashboardView.swift
//  SupplyChainControlTower
//
//  Main dashboard window with KPIs and active shipments
//

import SwiftUI

struct DashboardView: View {
    @Environment(AppState.self) private var appState
    @State private var kpiMetrics = KPIMetrics.mock()
    @Environment(\.openWindow) private var openWindow
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // KPI Cards
                    HStack(spacing: 16) {
                        KPICard(
                            title: "OTIF",
                            value: String(format: "%.1f%%", kpiMetrics.otif * 100),
                            change: "+2.1%",
                            isPositive: true
                        )

                        KPICard(
                            title: "Shipments",
                            value: "\(kpiMetrics.activeShipments)",
                            subtitle: "Active",
                            isPositive: true
                        )

                        KPICard(
                            title: "Alerts",
                            value: "\(kpiMetrics.alerts)",
                            subtitle: "Medium",
                            isPositive: false
                        )
                    }

                    // Active Shipments Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Active Shipments")
                                .font(.title2)
                                .fontWeight(.semibold)

                            Spacer()

                            Button(action: {}) {
                                HStack {
                                    Text("Filter")
                                    Image(systemName: "line.3.horizontal.decrease.circle")
                                }
                            }
                        }

                        if let network = appState.network {
                            ForEach(network.flows) { flow in
                                ShipmentRow(flow: flow)
                            }
                        } else {
                            // Loading state
                            ProgressView("Loading shipments...")
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }

                    // Action Buttons
                    HStack(spacing: 16) {
                        Button(action: {
                            openWindow(id: "network-volume")
                        }) {
                            Label("Open Network", systemImage: "network")
                        }
                        .buttonStyle(.borderedProminent)

                        Button(action: {
                            openWindow(id: "inventory-volume")
                        }) {
                            Label("Analytics", systemImage: "chart.bar")
                        }
                        .buttonStyle(.bordered)

                        Button(action: {
                            Task {
                                await openImmersiveSpace(id: "command-center")
                            }
                        }) {
                            Label("Planning", systemImage: "globe")
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding()
            }
            .navigationTitle("Supply Chain Control Tower")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button(action: { loadNetwork() }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
        .onAppear {
            loadNetwork()
        }
    }

    private func loadNetwork() {
        // Load mock network for now
        appState.network = SupplyChainNetwork.mockNetwork()
    }
}

// MARK: - KPI Card

struct KPICard: View {
    let title: String
    let value: String
    var subtitle: String?
    var change: String?
    var isPositive: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(statusColor)

            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let change = change {
                HStack(spacing: 4) {
                    Image(systemName: isPositive ? "arrow.up" : "arrow.down")
                        .font(.caption)
                    Text(change)
                        .font(.caption)
                }
                .foregroundStyle(isPositive ? .green : .red)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }

    private var statusColor: Color {
        if title == "Alerts" {
            return isPositive ? .green : .orange
        }
        return .primary
    }
}

// MARK: - Shipment Row

struct ShipmentRow: View {
    let flow: Flow

    var body: some View {
        HStack(spacing: 12) {
            // Transport icon
            Image(systemName: transportIcon)
                .font(.title2)
                .foregroundStyle(statusColor)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text("Shipment #\(flow.shipmentId)")
                    .font(.headline)

                Text("\(flow.currentNode) → \(flow.destinationNode)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if flow.status == .delayed {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.caption)
                        Text("Weather delay: 45min")
                            .font(.caption)
                    }
                    .foregroundStyle(.orange)
                } else if flow.status == .inTransit {
                    Text(etaText)
                        .font(.caption)
                        .foregroundStyle(.green)
                }
            }

            Spacer()

            // Progress bar
            ProgressView(value: flow.actualProgress)
                .frame(width: 100)
        }
        .padding()
        .background(.thinMaterial)
        .cornerRadius(8)
    }

    private var transportIcon: String {
        // This would be determined by the route type
        "shippingbox.fill"
    }

    private var statusColor: Color {
        switch flow.status {
        case .pending: return .blue
        case .inTransit: return .green
        case .delayed: return .orange
        case .delivered: return .green
        case .cancelled: return .red
        }
    }

    private var etaText: String {
        let interval = flow.eta.timeIntervalSinceNow
        let hours = Int(interval / 3600)
        let minutes = Int((interval.truncatingRemainder(dividingBy: 3600)) / 60)

        if hours > 0 {
            return "ETA: \(hours)h \(minutes)m ahead"
        } else if minutes > 0 {
            return "ETA: \(minutes)m ahead"
        } else {
            return "On schedule"
        }
    }
}

#Preview {
    DashboardView()
        .environment(AppState())
}
