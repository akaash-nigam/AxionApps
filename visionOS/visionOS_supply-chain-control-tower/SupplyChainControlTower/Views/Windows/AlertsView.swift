//
//  AlertsView.swift
//  SupplyChainControlTower
//
//  Alert panel showing disruptions and exceptions
//

import SwiftUI

struct AlertsView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if let network = appState.network, !network.disruptions.isEmpty {
                        ForEach(network.disruptions) { disruption in
                            DisruptionCard(disruption: disruption)
                        }
                    } else {
                        ContentUnavailableView(
                            "No Active Alerts",
                            systemImage: "checkmark.circle.fill",
                            description: Text("All systems operating normally")
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("Alerts & Exceptions")
        }
    }
}

// MARK: - Disruption Card

struct DisruptionCard: View {
    let disruption: Disruption
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(spacing: 12) {
                severityIcon
                    .font(.title2)
                    .frame(width: 40)

                VStack(alignment: .leading, spacing: 4) {
                    Text(severityLabel)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(severityColor)
                        .textCase(.uppercase)

                    Text(disruption.type.displayName)
                        .font(.headline)

                    HStack(spacing: 16) {
                        Label("\(disruption.affectedFlows.count) shipments", systemImage: "shippingbox")
                        Label("\(Int(disruption.predictedImpact.delayHours))h delay", systemImage: "clock")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

                Spacer()

                Button(action: { isExpanded.toggle() }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                }
            }

            if isExpanded {
                Divider()

                // Impact Details
                VStack(alignment: .leading, spacing: 8) {
                    Text("Impact Analysis")
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    ImpactRow(label: "Affected Shipments", value: "\(disruption.predictedImpact.affectedShipments)")
                    ImpactRow(label: "Delay", value: "\(Int(disruption.predictedImpact.delayHours)) hours")
                    ImpactRow(label: "Cost Impact", value: "$\(Int(disruption.predictedImpact.costImpact).formatted())")
                }

                // Recommendations
                if !disruption.recommendations.isEmpty {
                    Divider()

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recommendations")
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        ForEach(disruption.recommendations) { recommendation in
                            RecommendationRow(recommendation: recommendation)
                        }
                    }
                }

                // Action Buttons
                Divider()

                HStack(spacing: 12) {
                    Button(action: {}) {
                        Text("View Details")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)

                    Button(action: {}) {
                        Text("Resolve")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .padding()
        .background(severityColor.opacity(0.1))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(severityColor, lineWidth: 2)
        )
        .cornerRadius(12)
    }

    private var severityIcon: some View {
        Group {
            switch disruption.severity {
            case .critical:
                Image(systemName: "exclamationmark.octagon.fill")
                    .foregroundStyle(.red)
            case .high:
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
            case .medium:
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundStyle(.yellow)
            case .low:
                Image(systemName: "info.circle.fill")
                    .foregroundStyle(.blue)
            }
        }
    }

    private var severityLabel: String {
        switch disruption.severity {
        case .critical: return "Critical"
        case .high: return "Warning"
        case .medium: return "Warning"
        case .low: return "Info"
        }
    }

    private var severityColor: Color {
        switch disruption.severity {
        case .critical: return .red
        case .high: return .orange
        case .medium: return .yellow
        case .low: return .blue
        }
    }
}

// MARK: - Impact Row

struct ImpactRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
        .font(.caption)
    }
}

// MARK: - Recommendation Row

struct RecommendationRow: View {
    let recommendation: Recommendation

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(recommendation.title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                Text("\(Int(recommendation.confidence * 100))%")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(recommendation.description)
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 16) {
                Label("$\(Int(recommendation.estimatedCost).formatted())", systemImage: "dollarsign.circle")
                Label("\(Int(recommendation.estimatedTimeSavings))h savings", systemImage: "clock.arrow.circlepath")
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
        .padding(12)
        .background(.thinMaterial)
        .cornerRadius(8)
    }
}

// MARK: - DisruptionType Extension

extension DisruptionType {
    var displayName: String {
        switch self {
        case .weather: return "Weather Alert"
        case .portCongestion: return "Port Congestion"
        case .strike: return "Labor Strike"
        case .geopolitical: return "Geopolitical Risk"
        case .naturalDisaster: return "Natural Disaster"
        case .systemFailure: return "System Failure"
        case .capacityShortage: return "Capacity Shortage"
        }
    }
}

#Preview {
    AlertsView()
        .environment(AppState())
}
