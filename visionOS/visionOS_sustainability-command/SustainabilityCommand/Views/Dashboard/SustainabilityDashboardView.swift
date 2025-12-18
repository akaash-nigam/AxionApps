import SwiftUI
import Charts

struct SustainabilityDashboardView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace

    var body: some View {
        @Bindable var appState = appState

        ScrollView {
            VStack(spacing: 24) {
                // Header
                headerSection

                // Metric Cards
                metricCardsSection

                // Emissions Breakdown Chart
                emissionsBreakdownSection

                // Bottom Actions
                HStack(spacing: 16) {
                    recentAlertsSection
                    quickActionsSection
                }
            }
            .padding(24)
        }
        .frame(width: 1400, height: 900)
        .background(.regularMaterial)
        .glassBackgroundEffect()
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Sustainability Command Center")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                if let org = appState.organization {
                    Text(org.name)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            if appState.isLoading {
                ProgressView()
                    .controlSize(.regular)
            }
        }
    }

    // MARK: - Metric Cards

    private var metricCardsSection: some View {
        HStack(spacing: 16) {
            MetricCard(
                title: "Total Carbon Footprint",
                value: String(format: "%.0f", appState.currentFootprint?.totalEmissions ?? 0),
                unit: "tCO2e",
                change: -5.2,
                icon: "leaf.fill",
                color: .green
            )

            MetricCard(
                title: "Reduction Progress",
                value: "-12%",
                unit: "vs last quarter",
                change: 12.0,
                icon: "arrow.down.circle.fill",
                color: .blue
            )

            MetricCard(
                title: "Goals Status",
                value: "\(appState.goals.filter { $0.status == .achieved }.count) of \(appState.goals.count)",
                unit: "on track",
                change: nil,
                icon: "flag.checkered",
                color: .orange
            )
        }
    }

    // MARK: - Emissions Breakdown

    private var emissionsBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Emissions Breakdown")
                .font(.title2)
                .fontWeight(.semibold)

            if let footprint = appState.currentFootprint {
                Chart(footprint.emissionSources) { source in
                    BarMark(
                        x: .value("Emissions", source.emissions),
                        y: .value("Source", source.name)
                    )
                    .foregroundStyle(by: .value("Category", source.category.rawValue))
                }
                .frame(height: 300)
            } else {
                Text("No data available")
                    .foregroundStyle(.secondary)
                    .frame(height: 300)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Alerts

    private var recentAlertsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Alerts")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                AlertRow(
                    icon: "exclamationmark.triangle.fill",
                    text: "2 facilities over target",
                    color: .orange
                )

                AlertRow(
                    icon: "doc.fill",
                    text: "1 new report ready",
                    color: .blue
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Quick Actions

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)

            VStack(spacing: 8) {
                Button {
                    Task {
                        await openImmersiveSpace(id: "earth-immersive")
                    }
                } label: {
                    Label("View Earth", systemImage: "globe")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button {
                    openWindow(id: "analytics-detail")
                } label: {
                    Label("Analytics", systemImage: "chart.xyaxis.line")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button {
                    openWindow(id: "goals-tracker")
                } label: {
                    Label("Goals", systemImage: "flag.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Supporting Views

struct MetricCard: View {
    let title: String
    let value: String
    let unit: String
    let change: Double?
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)

                Spacer()

                if let change = change {
                    HStack(spacing: 4) {
                        Image(systemName: change >= 0 ? "arrow.up" : "arrow.down")
                        Text(String(format: "%.1f%%", abs(change)))
                    }
                    .font(.caption)
                    .foregroundStyle(change >= 0 ? .green : .red)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: 36, weight: .bold, design: .rounded))

                Text(unit)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

struct AlertRow: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(color)

            Text(text)
                .font(.subheadline)

            Spacer()
        }
    }
}

#Preview {
    SustainabilityDashboardView()
        .environment(AppState())
}
